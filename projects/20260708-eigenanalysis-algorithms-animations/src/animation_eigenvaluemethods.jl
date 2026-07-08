using LinearAlgebra
using Random

function a_powermethod(A::AbstractMatrix, maxiter::Integer=10)
    F = eigen(Symmetric(Matrix(A)))         # ascending, orthonormal eigenvectors
    p = sortperm(F.values; rev = true)      # reorder so index 1 = dominant
    λ = F.values[p]
    v = F.vectors[:, p]
    n = size(A, 1)

    a = zeros(maxiter + 1, n)               # coefficients in the eigenbasis, one row per iterate
    x = zeros(n, maxiter + 1)               # the unit iterates xₖ, one column per iterate

    # Generic start where the dominant component (index 1) is deliberately the SMALLEST,
    # so the convergence is dramatic.
    a0 = n == 3 ? [1.0, 2.0, 3.0] : collect(1.0:n)
    x[:, 1] = v * a0
    x[:, 1] ./= norm(x[:, 1])
    a[1, :] = v' * x[:, 1]                   # exact coefficients of the normalized start

    for k in 1:maxiter
        y  = A * x[:, k]
        ny = norm(y)
        x[:, k + 1] = y / ny
        a[k + 1, :] = (λ .* a[k, :]) ./ ny   # aᵢ ← λᵢ aᵢ / ‖y‖
    end

    return a, x, λ, v
end

# Unshifted QR algorithm on a SYMMETRIC real matrix A, instrumented for animation.
function a_qr(A::AbstractMatrix, maxiter::Integer=10)
    F = eigen(Symmetric(Matrix(A)))         # ascending, orthonormal eigenvectors
    p = sortperm(F.values; rev = true)      # reorder so index 1 = dominant
    λ = F.values[p]
    v = F.vectors[:, p]
    n = size(A, 1)

    Ait = zeros(n, n, maxiter + 1)          # the iterates Aₖ
    Pit = zeros(n, n, maxiter + 1)          # the accumulated frames Pₖ = Q₁⋯Qₖ
    Ait[:, :, 1] = A                        # A₁ = A
    Pit[:, :, 1] = Matrix(I, n, n)          # P₀ = I

    for k in 1:maxiter
        Q, R = qr(Ait[:, :, k])             # Aₖ = Qₖ Rₖ
        Ait[:, :, k + 1] = R * Q            # Aₖ₊₁ = Rₖ Qₖ  (= Qₖᵀ Aₖ Qₖ)
        Pit[:, :, k + 1] = Pit[:, :, k] * Q # Pₖ = Pₖ₋₁ Qₖ
    end

    return Ait, Pit, λ, v
end

# Rayleigh quotient iteration on a SYMMETRIC real matrix A, instrumented for animation.
function a_rqi(A::AbstractMatrix, x0::AbstractVector, maxiter::Integer=6; tol::Real=1e-12)
    F = eigen(Symmetric(Matrix(A)))         # ascending, orthonormal eigenvectors
    p = sortperm(F.values; rev = true)      # reorder so index 1 = dominant (match other methods)
    λ = F.values[p]
    v = F.vectors[:, p]
    n = size(A, 1)

    x   = zeros(n, maxiter + 1)             # the unit iterates xₖ, one column per iterate
    a   = zeros(maxiter + 1, n)             # coefficients in the eigenbasis, one row per iterate
    σ   = zeros(maxiter + 1)                # the shifts σₖ = ρ(xₖ)  (Rayleigh quotients)
    res = zeros(maxiter + 1)                # residual ‖A xₖ − σₖ xₖ‖, exposes the cubic collapse

    # Normalized start, its exact eigenbasis coefficients, and the first Rayleigh quotient.
    x[:, 1] = x0 / norm(x0)
    a[1, :] = v' * x[:, 1]
    σ[1]    = x[:, 1]' * A * x[:, 1]
    res[1]  = norm(A * x[:, 1] - σ[1] * x[:, 1])

    for k in 1:maxiter
        # Solve (A − σₖ I) w = xₖ  (shift-and-invert with the current shift). The Rayleigh
        # quotient σₖ reaches the eigenvalue to machine precision within a few steps, making
        # (A − σₖ I) exactly singular — which IS the convergence signal. Catch it and hold the
        # converged eigenpair for the remaining frames so the animation doesn't trail to zeros.
        local w
        try
            w = (A - σ[k] * I) \ x[:, k]
        catch
            for j in (k + 1):(maxiter + 1)
                x[:, j] = x[:, k];  a[j, :] = a[k, :];  σ[j] = σ[k];  res[j] = res[k]
            end
            break
        end

        xk = w / norm(w)
        if dot(xk, x[:, k]) < 0             # keep the sign consistent for a smooth animation
            xk .*= -1
        end
        x[:, k + 1]   = xk
        a[k + 1, :]   = v' * xk
        σ[k + 1]      = xk' * A * xk
        res[k + 1]    = norm(A * xk - σ[k + 1] * xk)
    end

    return x, a, σ, res, λ, v
end

# Arnoldi on a SYMMETRIC real matrix A, instrumented for animation.
function a_arnoldi(A::AbstractMatrix, x0::AbstractVector, maxiter::Integer=size(A, 1);
                   tol::Real=1e-12)
    F = eigen(Symmetric(Matrix(A)))         # ascending, orthonormal eigenvectors
    p = sortperm(F.values; rev = true)      # reorder so index 1 = dominant
    λ = F.values[p]
    v = F.vectors[:, p]
    n = size(A, 1)
    m = min(maxiter, n)                     # a Krylov space of A can't exceed dimension n

    V    = zeros(n, m + 1)                  # orthonormal Krylov basis, one column per step
    H    = zeros(m + 1, m)                  # upper-Hessenberg (symmetric tridiagonal here)
    Ritz = fill(NaN, m, m)                  # Ritz[1:k, k] = Ritz values from Hₖ

    V[:, 1] = x0 / norm(x0)

    kdone = m
    for k in 1:m
        w = A * V[:, k]
        for i in 1:k                        # modified Gram-Schmidt against the basis
            H[i, k] = dot(V[:, i], w)
            w -= H[i, k] * V[:, i]
        end
        for i in 1:k                        # one reorthogonalization pass (numerical safety)
            c = dot(V[:, i], w)
            H[i, k] += c
            w -= c * V[:, i]
        end

        # Ritz values of the current k-dimensional Krylov space, dominant-first.
        Ritz[1:k, k] = sort(eigvals(Symmetric(H[1:k, 1:k])); rev = true)

        H[k + 1, k] = norm(w)
        if H[k + 1, k] < tol                # invariant subspace found → exact from here on
            kdone = k
            break
        end
        V[:, k + 1] = w / H[k + 1, k]
    end

    # Hold the converged spectrum across any remaining columns so the animation lingers
    # on the exact result instead of trailing into NaN.
    for k in (kdone + 1):m
        Ritz[:, k] = Ritz[:, kdone]
    end

    return H, Ritz, λ, v, kdone
end

# FEAST on a SYMMETRIC real matrix A, instrumented for animation.
function a_feast(A::AbstractMatrix, σ::Real, r::Real;
                 ne::Integer=8, m0::Integer=6, nstep::Integer=6, seed::Integer=1)
    F = eigen(Symmetric(Matrix(A)))
    p = sortperm(F.values)                     # ascending along the real λ-axis
    EVALS = F.values[p]
    EVEC  = F.vectors[:, p]
    n = length(EVALS)

    # Discretized circular contour: nodes z_k on the circle, trapezoidal weights w_k.
    θ  = [2π * (k - 0.5) / ne for k in 1:ne]
    zk = [σ + r * cis(t) for t in θ]
    wk = [r * cis(t) / ne for t in θ]

    # Scalar rational filter ρ(λ) = Σ_k w_k /(z_k − λ); |ρ| is the gain on each mode.
    ρ(λ) = abs(sum(wk[k] / (zk[k] - λ) for k in 1:ne))
    ρλ     = ρ.(EVALS)
    inside = BitVector(abs.(EVALS .- σ) .< r)

    # Random start subspace; s_j = ‖vⱼᵀ Y‖ is its initial energy on eigendirection j.
    Random.seed!(seed)
    Y = randn(n, m0)
    C = EVEC' * Y                              # coefficients in the eigenbasis (n × m0)
    s = [norm(@view C[j, :]) for j in 1:n]

    # After q passes the energy on direction j scales as |ρ(λⱼ)|^q · s_j. Normalize each
    # frame to its own peak so the surviving in-contour modes sit at 1 and the rest fall.
    energy = zeros(nstep + 1, n)
    for q in 0:nstep
        e = (ρλ .^ q) .* s
        energy[q + 1, :] = e ./ max(maximum(e), eps())
    end

    return EVALS, EVEC, inside, zk, energy
end