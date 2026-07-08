# eigen_methods_anim.jl
# Per-method "generation logic": turn a raw solver run into animation-ready data
# for the eigenbasis representation in eigen_viz.jl.
#
# Each method gets one function returning the bundle
#     (; EVALS, EVEC, Acoef, XSEQ, nstep, caption)
# where
#   EVALS :: n            eigenvalues, dominant-first
#   EVEC  :: n×n          orthonormal eigenvectors as columns, dominant-first
#   Acoef :: (nstep+1)×n  coefficients of each iterate in the eigenbasis
#   XSEQ  :: n×(nstep+1)  the unit iterates, sign-aligned so the arrow never flips
#   caption :: step -> String
#
# Add other methods (shift-and-invert, ...) as sibling functions below.

using LinearAlgebra
using Printf
using Random

include(joinpath(@__DIR__, "animation_eigenvaluemethods.jl"))   # raw solvers: a_powermethod, gep_*

# Sign-align consecutive iterates so the hero arrow never flips between frames.
function sign_align(X)
    Y = copy(X)
    for k in 2:size(Y, 2)
        dot(Y[:, k], Y[:, k - 1]) < 0 && (Y[:, k] .= -Y[:, k])
    end
    return Y
end

# --------------------------------------------------------------------------- #
#  Power method                                                                #
# --------------------------------------------------------------------------- #
function powermethod_anim(A; nstep::Int = 14)
    Acoef, Xiter, EVALS, EVEC = a_powermethod(A, nstep)
    XSEQ = sign_align(Xiter)

    caption = function (step::Int)
        θ = rad2deg(acos(clamp(abs(Acoef[step + 1, 1]), 0, 1)))
        @sprintf("Power iteration  xₖ₊₁ = A·xₖ / ‖A·xₖ‖   —   step %d / %d   ·   angle to dominant eigenvector: %.1f°",
                 step, nstep, θ)
    end

    return (; EVALS, EVEC, Acoef, XSEQ, nstep, caption)
end

# --------------------------------------------------------------------------- #
#  QR algorithm                                                                #
# --------------------------------------------------------------------------- #
offdiag_norm(M) = sqrt(max(sum(abs2, M) - sum(abs2, diag(M)), 0.0))

function qr_anim(A; nstep::Int = 20)
    Ait, Pit, EVALS, EVEC = a_qr(A, nstep)

    caption = function (step::Int)
        od = offdiag_norm(@view Ait[:, :, step + 1])
        @sprintf("QR algorithm   Aₖ = QₖRₖ,  Aₖ₊₁ = RₖQₖ   —   step %d / %d   ·   off-diagonal norm: %.2e",
                 step, nstep, od)
    end

    return (; EVALS, EVEC, Ait, Pit, nstep, caption)
end

# --------------------------------------------------------------------------- #
#  Rayleigh quotient iteration                                                 #
# --------------------------------------------------------------------------- #
# Unlike the power method, RQI is not steered by the dominant eigenvalue: the
# shift σₖ = ρ(xₖ) chases the vector, so it locks onto whichever eigenpair the
# start x₀ leans toward. We report that converged index as `target` so the
# graphics can highlight the eigenline RQI actually found.
function rqi_anim(A, x0; nstep::Int = 6)
    Xiter, Acoef, σ, res, EVALS, EVEC = a_rqi(A, x0, nstep)
    XSEQ   = sign_align(Xiter)
    target = argmin(abs.(EVALS .- σ[end]))     # eigenvalue RQI converged to

    caption = function (step::Int)
        @sprintf("Rayleigh quotient iteration   (A − σₖI) xₖ₊₁ = xₖ,  σₖ = xₖᵀA xₖ   —   step %d / %d   ·   σ = %.4f   ·   residual %.1e",
                 step, nstep, σ[step + 1], res[step + 1])
    end

    return (; EVALS, EVEC, Acoef, XSEQ, σ, res, target, nstep, caption)
end

# --------------------------------------------------------------------------- #
#  Arnoldi / Lanczos                                                           #
# --------------------------------------------------------------------------- #
# Unlike the vector-in-ℝ³ methods, Arnoldi's story lives in the spectrum: the
# Ritz values (eigenvalues of the leading block Hₖ) migrate onto the true
# eigenvalues of A, capturing the extremes first and coinciding with the whole
# spectrum exactly at k = n. `step` here is the Krylov dimension k: step 0 shows
# the bare spectrum (no Ritz values yet), step k shows the k Ritz values of Hₖ.
function arnoldi_anim(A, x0; nstep::Int = size(A, 1))
    H, Ritz, EVALS, EVEC, kdone = a_arnoldi(A, x0, nstep)
    m = size(Ritz, 2)                       # actual number of steps (min(nstep, n))

    caption = function (step::Int)
        if step == 0
            @sprintf("Arnoldi / Lanczos on A   ·   Ritz values = eig(Hₖ),  Hₖ = Vₖᵀ A Vₖ   —   start (Krylov dim 0)")
        else
            k   = min(step, kdone)
            sub = k < m ? H[k + 1, k] : 0.0     # subdiagonal hₖ₊₁,ₖ → 0 signals convergence
            @sprintf("Arnoldi / Lanczos   Ritz values = eig(Hₖ)   —   step %d / %d   ·   Krylov dim %d   ·   subdiagonal hₖ₊₁,ₖ = %.2e",
                     step, m, k, sub)
        end
    end

    return (; EVALS, EVEC, H, Ritz, kdone, nstep = m, caption)
end

# --------------------------------------------------------------------------- #
#  FEAST (contour-filtered subspace iteration)                                 #
# --------------------------------------------------------------------------- #
# Unlike the vector-in-ℝ³ methods, FEAST's story is a spectral FILTER: the contour
# integral projector acts on each eigenvector vⱼ as a scalar gain ρ(λⱼ)^q that is ≈1
# inside the contour and ≈0 outside, so `step` is the pass count q — step 0 is the raw
# random subspace, step q is after q applications. The raw filter/energy data comes from
# a_feast; this wrapper only attaches the caption. See a_feast for the model detail.
function feast_anim(A, σ::Real, r::Real; ne::Int = 8, m0::Int = 6,
                    nstep::Int = 6, seed::Int = 1)
    EVALS, EVEC, inside, zk, energy = a_feast(A, σ, r; ne, m0, nstep, seed)

    caption = function (step::Int)
        nin = count(inside)
        @sprintf("FEAST   P = (1/2πi)∮(zI−A)⁻¹dz ≈ Σₖ wₖ(zₖI−A)⁻¹ over %d nodes,  gain ρ(λ)^q   —   pass %d / %d   ·   %d eigenvalue%s enclosed",
                 ne, step, nstep, nin, nin == 1 ? "" : "s")
    end

    return (; EVALS, EVEC, inside, σ, r, zk, energy, ne, nstep, caption)
end

# --------------------------------------------------------------------------- #
#  (future) other methods, e.g.
#  function shiftinvert_anim(A, σ; nstep = 14) ... end
# --------------------------------------------------------------------------- #