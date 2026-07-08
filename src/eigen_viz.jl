# eigen_viz.jl
# Reusable graphics + style for the "vector in the eigenbasis" 3D representation.
#
# This file knows NOTHING about any particular eigenvalue method. It is handed the
# animation data (eigenvalues, eigenvectors, per-iterate coefficients and unit
# iterates) plus a caption function, and it returns a figure together with a
# `show_step!` updater and a frame schedule. Any method that produces those four
# arrays (power iteration, shift-and-invert, ...) can drive the same picture.
#
#   Left  : Axis3 with the orthonormal eigen-frame, the dominant eigenline (dashed),
#           the hero arrow xₖ, and a faded trail of past iterates.
#   Right : live bar chart of |aᵢ|  (for a unit xₖ, Σ aᵢ² = 1, so |a₁| = cos angle
#           between xₖ and the dominant eigenvector).

using LinearAlgebra
using CairoMakie
using Printf

# --------------------------------------------------------------------------- #
#  Style                                                                       #
# --------------------------------------------------------------------------- #
const ECOLS  = [:orange, :cyan, :orchid]   # eigenvector colours, dominant = orange
const HEROCOL = :yellow                    # the iterate xₖ
const R      = 1.25                        # 3D view half-range (vectors are unit)
const SEIG   = 1.05                        # length of the eigen-frame arrows
const SITER  = 1.05                        # length of the hero / trail arrows
const FIGSIZE = (1280, 660)                # shared figure size → identical video dimensions

p3(v) = Point3f(v[1], v[2], v[3])
v3(v) = Vec3f(v[1], v[2], v[3])

# --------------------------------------------------------------------------- #
#  Shared building blocks (mutualized across the 3D-frame builders)            #
# --------------------------------------------------------------------------- #
# The power method, QR and RQI all draw the SAME picture of the eigenbasis:
# an isometric Axis3, the eigenlines as dashed rays through the origin coloured
# per eigenvector, the fixed eigenvector arrows, and per-vector λ labels. Only
# the *moving* overlay (hero arrow / rotating frame / spectrum) differs. These
# helpers hold that shared style so the three representations stay visually
# identical (this is the clean QR look, applied everywhere).

# Isometric Axis3 with the house style, clamped to the unit-vector view box.
function eigen_axis3(pos)
    ax = Axis3(pos; aspect = :data, xlabel = "x", ylabel = "y", zlabel = "z",
               protrusions = 25, perspectiveness = 0.0,
               azimuth = π/4, elevation = atan(1 / sqrt(2)))
    limits!(ax, -R, R, -R, R, -R, R)
    return ax
end

# Centered caption label spanning the given columns; returns its Observable.
function caption_label!(fig, cols)
    cap = Observable("")
    Label(fig[0, cols], cap; fontsize = 17, color = :white, padding = (0, 0, 8, 0),
          tellwidth = false, justification = :center)
    return cap
end

# The eigen-frame: the eigenvectors drawn as dashed rays through the origin
# (one per eigenvector, coloured) + λ labels. `highlight` thickens/brightens one
# eigenline (used by RQI to mark the target); `digits` sets the λ label precision.
# This dashed-line representation is shared by every 3D builder, so the eigenvectors
# look identical across the power method, QR and RQI.
function draw_eigenframe!(ax, EVALS, EVEC; digits::Int = 1, highlight::Int = 0)
    n = length(EVALS)
    labfmt = Printf.Format("v%d  λ=%.$(digits)f")
    for i in 1:n
        e  = EVEC[:, i]
        hl = i == highlight
        lines!(ax, [-1.4e[1], 1.4e[1]], [-1.4e[2], 1.4e[2]], [-1.4e[3], 1.4e[3]];
               color = (ECOLS[i], hl ? 0.6 : 0.4), linestyle = :dash,
               linewidth = hl ? 1.8 : 1.5)
        text!(ax, (SEIG + 0.06) .* e...;
              text = Printf.format(labfmt, i, EVALS[i]),
              color = ECOLS[i], fontsize = 14, align = (:center, :center))
    end
    return ax
end

# --------------------------------------------------------------------------- #
#  Frame schedule (one displayed step = one iteration)                         #
# --------------------------------------------------------------------------- #
# Returns a vector of step indices (0 .. nstep) with holds at the start and end.
function default_frames(nstep::Int; intro::Int = 18, per::Int = 18, tail::Int = 24)
    frames = Int[]
    append!(frames, fill(0, intro))                       # intro hold on the start
    for k in 0:nstep, _ in 1:per; push!(frames, k); end   # linger on each iteration
    append!(frames, fill(nstep, tail))                    # hold on convergence
    return frames
end

# --------------------------------------------------------------------------- #
#  Figure builder                                                              #
# --------------------------------------------------------------------------- #
# Arguments (all per-method data; eigenpairs ordered dominant-first):
#   EVALS :: n            eigenvalues
#   EVEC  :: n×n          orthonormal eigenvectors as columns
#   Acoef :: (nstep+1)×n  coefficients of each iterate in the eigenbasis (row = step)
#   XSEQ  :: n×(nstep+1)  the unit iterates xₖ as columns (sign-aligned upstream)
# Keywords:
#   nstep   :: Int                       number of iterations
#   caption :: step::Int -> String       method-specific caption for each step
#   frames                               frame schedule (defaults to default_frames)
#   bartitle                             title above the coefficient bar chart
#
# Returns a NamedTuple (; fig, show_step!, frames, nstep).
function build_eigenbasis_anim(EVALS, EVEC, Acoef, XSEQ;
                               nstep::Int,
                               caption,
                               frames = default_frames(nstep),
                               bartitle::AbstractString = "components in the eigenbasis")
    n = length(EVALS)

    set_theme!(theme_black())
    fig = Figure(size = FIGSIZE)
    cap = caption_label!(fig, 1:2)

    # ---- left: 3D eigen-frame (shared clean style) ------------------------ #
    ax = eigen_axis3(fig[1, 1])
    draw_eigenframe!(ax, EVALS, EVEC; digits = 1)

    # faded trail of past iterates
    trail_o = Observable(Point3f[])
    trail_d = Observable(Vec3f[])
    arrows3d!(ax, trail_o, trail_d; color = RGBAf(0.6, 0.6, 0.6, 0.30),
              tipradius = 0.02, shaftradius = 0.006)

    # hero arrow xₖ
    iter_o = Observable([Point3f(0)])
    iter_d = Observable([v3(SITER .* XSEQ[:, 1])])
    arrows3d!(ax, iter_o, iter_d; color = HEROCOL, tipradius = 0.05, shaftradius = 0.018)

    # ---- right: coefficient bar chart ------------------------------------- #
    axb = Axis(fig[1, 2]; title = bartitle, xlabel = "eigenvector", ylabel = "|aᵢ|",
               xticks = (1:n, [@sprintf("v%d (λ=%.1f)", i, EVALS[i]) for i in 1:n]))
    limits!(axb, 0.4, n + 0.6, 0.0, 1.05)
    bars = Observable(abs.(Acoef[1, :]))
    barplot!(axb, 1:n, bars; color = ECOLS[1:n], strokecolor = :white, strokewidth = 0.5)

    colsize!(fig.layout, 1, Relative(0.62))

    # ---- per-frame updater ------------------------------------------------ #
    function show_step!(step::Int)                  # step = 0 .. nstep
        iter_d[] = [v3(SITER .* XSEQ[:, step + 1])]
        if step >= 1
            trail_o[] = fill(Point3f(0), step)
            trail_d[] = [v3(SITER .* XSEQ[:, i]) for i in 1:step]
        else
            trail_o[] = Point3f[]; trail_d[] = Vec3f[]
        end
        bars[] = abs.(Acoef[step + 1, :])
        cap[]  = caption(step)
    end

    return (; fig, show_step!, frames, nstep)
end

# --------------------------------------------------------------------------- #
#  QR-algorithm figure builder                                                 #
# --------------------------------------------------------------------------- #
# Side-by-side view of the unshifted QR algorithm:
#   Left  : the accumulated orthonormal frame Pₖ = Q₁⋯Qₖ (3 arrows) rotating onto
#           the fixed eigen-directions (dashed lines). Column i → eigenvector i.
#   Right : a heatmap of Aₖ; off-diagonal cells fade to 0 while the diagonal
#           settles onto the eigenvalues. The two panels show the same event:
#           the frame aligning ⟺ the matrix diagonalizing.
#
# Arguments (eigenpairs ordered dominant-first):
#   EVALS :: n            eigenvalues
#   EVEC  :: n×n          orthonormal eigenvectors as columns
#   Ait   :: n×n×(nstep+1)  the iterates Aₖ as slices
#   Pit   :: n×n×(nstep+1)  the accumulated frames Pₖ as slices (Pit[:,:,1] = I)
function build_qr_anim(EVALS, EVEC, Ait, Pit;
                       nstep::Int, caption,
                       frames = default_frames(nstep))
    n = length(EVALS)

    # Sign-align each frame column to the previous one so the arrows never flip
    # mid-animation (the eigen-lines are sign-agnostic, so any consistent sign is fine).
    Pseq = copy(Pit)
    for i in 1:n, k in 2:size(Pseq, 3)
        dot(Pseq[:, i, k], Pseq[:, i, k - 1]) < 0 && (Pseq[:, i, k] .*= -1)
    end

    set_theme!(theme_black())
    fig = Figure(size = FIGSIZE)
    cap = caption_label!(fig, 1:3)

    # ---- left: rotating frame Pₖ ------------------------------------------ #
    # Same dashed eigen-frame as the other 3D builders; the moving frame Pₖ
    # (drawn below) is the animated object rotating onto those eigenlines.
    ax = eigen_axis3(fig[1, 1])
    draw_eigenframe!(ax, EVALS, EVEC; digits = 1)

    # the accumulated frame columns (start at the standard axes, rotate onto vᵢ)
    frame_dir = Observable([v3(SITER .* Pseq[:, i, 1]) for i in 1:n])
    arrows3d!(ax, fill(Point3f(0), n), frame_dir;
              color = ECOLS[1:n], tipradius = 0.05, shaftradius = 0.018)

    # ---- right: heatmap of Aₖ --------------------------------------------- #
    maxabs = maximum(abs, EVALS)
    axh = Axis(fig[1, 2]; title = "Aₖ  (→ diagonal)", aspect = DataAspect(),
               yreversed = true, xlabel = "column j", ylabel = "row i",
               xticks = 1:n, yticks = 1:n)
    # heatmap!(xs, ys, Z) draws Z[a,b] at (a,b); we want value Aₖ[i,j] at (x=j, y=i),
    # so Z = transpose(Aₖ). Colour by magnitude: diagonal bright, off-diagonal → dark.
    heat = Observable(permutedims(abs.(Ait[:, :, 1])))
    hm = heatmap!(axh, 1:n, 1:n, heat; colormap = :inferno, colorrange = (0, maxabs))
    Colorbar(fig[1, 3], hm; label = "|Aₖ[i,j]|", width = 12)

    # numeric overlay (signed values), with text colour adapting to cell brightness
    cellpos = [Point2f(j, i) for i in 1:n for j in 1:n]   # order: i outer, j inner
    celltxt = Observable([@sprintf("%.2f", Ait[i, j, 1]) for i in 1:n for j in 1:n])
    cellcol = Observable([abs(Ait[i, j, 1]) > 0.55maxabs ? :black : :white
                          for i in 1:n for j in 1:n])
    text!(axh, cellpos; text = celltxt, color = cellcol,
          fontsize = 15, align = (:center, :center))

    colsize!(fig.layout, 1, Relative(0.5))

    # ---- per-frame updater ------------------------------------------------ #
    function show_step!(step::Int)                  # step = 0 .. nstep
        frame_dir[] = [v3(SITER .* Pseq[:, i, step + 1]) for i in 1:n]
        Ak = @view Ait[:, :, step + 1]
        heat[]    = permutedims(abs.(Ak))
        celltxt[] = [@sprintf("%.2f", Ak[i, j]) for i in 1:n for j in 1:n]
        cellcol[] = [abs(Ak[i, j]) > 0.55maxabs ? :black : :white
                     for i in 1:n for j in 1:n]
        cap[] = caption(step)
    end

    return (; fig, show_step!, frames, nstep)
end

# --------------------------------------------------------------------------- #
#  Rayleigh-quotient-iteration figure builder                                  #
# --------------------------------------------------------------------------- #
# Side-by-side view of RQI:
#   Left  : the eigen-frame with the hero arrow xₖ rotating onto the eigenvector
#           RQI locks onto (the `target` eigenline is highlighted). Same picture
#           as the power method, but the target need not be the dominant one.
#   Right : the spectrum of A drawn on a horizontal axis — the eigenvalues as
#           fixed coloured marks, and the shift σₖ = ρ(xₖ) as a moving marker
#           that slides and snaps onto the target eigenvalue. The two panels show
#           the same event: the vector aligning ⟺ the shift locking on.
#
# Arguments (eigenpairs ordered dominant-first):
#   EVALS  :: n            eigenvalues
#   EVEC   :: n×n          orthonormal eigenvectors as columns
#   XSEQ   :: n×(nstep+1)  the unit iterates xₖ as columns (sign-aligned upstream)
#   σ      :: (nstep+1)    the shift sequence σₖ (Rayleigh quotients)
#   target :: Int          index of the eigenpair RQI converged to
function build_rqi_anim(EVALS, EVEC, XSEQ, σ, target;
                        nstep::Int, caption,
                        frames = default_frames(nstep))
    n = length(EVALS)

    set_theme!(theme_black())
    fig = Figure(size = FIGSIZE)
    cap = caption_label!(fig, 1:2)

    # ---- left: 3D eigen-frame (shared clean style; target eigenline lit) --- #
    ax = eigen_axis3(fig[1, 1])
    draw_eigenframe!(ax, EVALS, EVEC; digits = 2, highlight = target)

    # faded trail of past iterates
    trail_o = Observable(Point3f[])
    trail_d = Observable(Vec3f[])
    arrows3d!(ax, trail_o, trail_d; color = RGBAf(0.6, 0.6, 0.6, 0.30),
              tipradius = 0.02, shaftradius = 0.006)

    # hero arrow xₖ
    iter_o = Observable([Point3f(0)])
    iter_d = Observable([v3(SITER .* XSEQ[:, 1])])
    arrows3d!(ax, iter_o, iter_d; color = HEROCOL, tipradius = 0.05, shaftradius = 0.018)

    # ---- right: spectrum with the moving shift σₖ ------------------------- #
    lo, hi = extrema(EVALS)
    pad = 0.18 * (hi - lo) + 0.1
    axs = Axis(fig[1, 2]; title = "spectrum of A   &   shift σₖ",
               xlabel = "eigenvalue axis",
               yticksvisible = false, yticklabelsvisible = false,
               ygridvisible = false, xgridvisible = false)
    limits!(axs, lo - pad, hi + pad, -0.6, 1.0)
    hidespines!(axs, :t, :r, :l)

    # the spectral axis (baseline through the eigenvalues)
    lines!(axs, [lo - pad, hi + pad], [0.0, 0.0]; color = (:white, 0.5), linewidth = 1.5)

    # target eigenvalue: a highlight ring behind its mark
    scatter!(axs, [EVALS[target]], [0.0]; color = RGBAf(0, 0, 0, 0), markersize = 30,
             strokecolor = ECOLS[target], strokewidth = 2.5)

    # eigenvalues as fixed coloured marks with labels
    scatter!(axs, EVALS, zeros(n); color = ECOLS[1:n], markersize = 17,
             strokecolor = :white, strokewidth = 0.8)
    for i in 1:n
        text!(axs, EVALS[i], -0.16; text = @sprintf("v%d\nλ=%.2f", i, EVALS[i]),
              color = ECOLS[i], fontsize = 13, align = (:center, :top))
    end

    # the shift σₖ: a stem + downward triangle + value label, all sliding together
    σx    = Observable(σ[1])
    stem  = lift(x -> [Point2f(x, 0.0), Point2f(x, 0.5)], σx)
    lines!(axs, stem; color = HEROCOL, linewidth = 2.5)
    scatter!(axs, lift(x -> [Point2f(x, 0.5)], σx);
             marker = :dtriangle, color = HEROCOL, markersize = 18)
    σpos = lift(x -> [Point2f(x, 0.6)], σx)
    σtxt = Observable([@sprintf("σₖ = %.3f", σ[1])])
    text!(axs, σpos; text = σtxt, color = HEROCOL, fontsize = 15,
          align = (:center, :bottom))

    colsize!(fig.layout, 1, Relative(0.6))

    # ---- per-frame updater ------------------------------------------------ #
    function show_step!(step::Int)                  # step = 0 .. nstep
        iter_d[] = [v3(SITER .* XSEQ[:, step + 1])]
        if step >= 1
            trail_o[] = fill(Point3f(0), step)
            trail_d[] = [v3(SITER .* XSEQ[:, i]) for i in 1:step]
        else
            trail_o[] = Point3f[]; trail_d[] = Vec3f[]
        end
        σx[]   = σ[step + 1]
        σtxt[] = [@sprintf("σₖ = %.3f", σ[step + 1])]
        cap[]  = caption(step)
    end

    return (; fig, show_step!, frames, nstep)
end

# --------------------------------------------------------------------------- #
#  Arnoldi / Lanczos figure builder                                            #
# --------------------------------------------------------------------------- #
# The only method here whose story is the spectrum itself, so it drops the 3D
# eigen-frame:
#   Left  : the real line. True eigenvalues of A as fixed hollow rings; the Ritz
#           values eig(Hₖ) as filled dots coloured by distance to the nearest true
#           eigenvalue. They appear at the extremes first, fill inward as k grows,
#           and nest inside every ring exactly at k = n.
#   Right : a heatmap of Hₖ = Vₖᵀ A Vₖ growing from 1×1 to n×n — the Hessenberg
#           (here tridiagonal) staircase being built. The two panels show one event:
#           the small matrix filling in ⟺ its eigenvalues locking onto A's spectrum.
#
# Arguments (eigenpairs ordered dominant-first):
#   EVALS :: n            true eigenvalues
#   H     :: (m+1)×m      the Hessenberg matrix (leading Hₖ = H[1:k,1:k])
#   Ritz  :: m×m          column k = Ritz values of Hₖ (dominant-first, NaN-padded)
#   kdone :: Int          step at which convergence was reached (display holds after)
nearest_logdist(z, lt) = log10(max(minimum(abs.(z .- lt)), 1e-16))

function build_arnoldi_anim(EVALS, H, Ritz, kdone;
                            nstep::Int, caption,
                            frames = default_frames(nstep))
    n = length(EVALS)
    m = size(Ritz, 2)

    set_theme!(theme_black())
    fig = Figure(size = FIGSIZE)
    cap = caption_label!(fig, 1:3)

    # ---- left: the spectrum with the Ritz values -------------------------- #
    lo, hi = extrema(EVALS)
    pad = 0.10 * (hi - lo) + 0.2
    axs = Axis(fig[1, 1]; title = "spectrum of A   &   Ritz values eig(Hₖ)",
               xlabel = "eigenvalue axis",
               yticksvisible = false, yticklabelsvisible = false,
               ygridvisible = false, xgridvisible = false)
    limits!(axs, lo - pad, hi + pad, -0.7, 0.7)
    hidespines!(axs, :t, :r, :l)

    # spectral axis (baseline through the eigenvalues)
    lines!(axs, [lo - pad, hi + pad], [0.0, 0.0]; color = (:white, 0.5), linewidth = 1.5)

    # true eigenvalues: fixed hollow rings + value labels
    scatter!(axs, EVALS, zeros(n); marker = :circle, markersize = 26,
             color = :transparent, strokecolor = :white, strokewidth = 1.6,
             label = "true λ")
    for i in 1:n
        text!(axs, EVALS[i], -0.14; text = @sprintf("%.1f", EVALS[i]),
              color = (:white, 0.7), fontsize = 11, align = (:center, :top))
    end

    # faded trail of the previous step's Ritz values
    trail = Observable(Point2f[])
    scatter!(axs, trail; color = (:gray, 0.35), markersize = 10)

    # Ritz values: filled dots coloured by distance to the nearest true eigenvalue
    ritz_pts = Observable(Point2f[])
    ritz_col = Observable(Float64[])
    scr = scatter!(axs, ritz_pts; color = ritz_col, colormap = Reverse(:viridis),
                   colorrange = (-13, 0), markersize = 15,
                   strokecolor = :white, strokewidth = 0.6, label = "Ritz value")
    Colorbar(fig[1, 2], scr; label = "log₁₀ dist to nearest true λ", width = 12)
    axislegend(axs; position = :rt, framevisible = true, padding = (4, 4, 4, 4))

    # ---- right: heatmap of Hₖ growing ------------------------------------- #
    maxabs = maximum(abs, @view H[1:m, 1:m])
    axh = Axis(fig[1, 3]; title = "Hₖ = Vₖᵀ A Vₖ   (grows to n×n)", aspect = DataAspect(),
               yreversed = true, xlabel = "column j", ylabel = "row i",
               xticks = 1:m, yticks = 1:m)
    # value |Hₖ[i,j]| at (x=j, y=i)  ->  Z = permutedims(masked |H|); cells outside the
    # k×k leading block are NaN so they render as background and the block "grows".
    heat = Observable(fill(NaN, m, m))
    hm = heatmap!(axh, 1:m, 1:m, heat; colormap = :inferno, colorrange = (0, maxabs))
    Colorbar(fig[1, 4], hm; label = "|Hₖ[i,j]|", width = 12)

    colsize!(fig.layout, 1, Relative(0.52))

    # ---- per-frame updater ------------------------------------------------ #
    function show_step!(step::Int)                  # step = 0 .. m  (= Krylov dim k)
        if step == 0
            ritz_pts[] = Point2f[]; ritz_col[] = Float64[]; trail[] = Point2f[]
            heat[] = fill(NaN, m, m)
        else
            k   = min(step, kdone)
            cur = filter(isfinite, Ritz[:, step])
            ritz_pts[] = [Point2f(z, 0.0) for z in cur]
            ritz_col[] = [nearest_logdist(z, EVALS) for z in cur]
            prev = step > 1 ? filter(isfinite, Ritz[:, step - 1]) : Float64[]
            trail[] = [Point2f(z, 0.0) for z in prev]

            Z = fill(NaN, m, m)                       # [i, j] layout, masked outside k×k
            Z[1:k, 1:k] = abs.(H[1:k, 1:k])
            heat[] = permutedims(Z)
        end
        cap[] = caption(step)
    end

    return (; fig, show_step!, frames, nstep = m)
end

# --------------------------------------------------------------------------- #
#  FEAST figure builder                                                        #
# --------------------------------------------------------------------------- #
# FEAST has no rotating vector; its story is a contour integral that acts as a spectral
# FILTER. Two panels, one event:
#   Left  : the complex plane. The contour C — a circle of centre σ, radius r — is drawn
#           dashed and divided into its ne quadrature nodes zₖ (the ∮ becomes Σₖ over
#           these). The eigenvalues sit on the real axis; each is drawn as a dot whose
#           SIZE tracks its current subspace energy, so enclosed modes stay large while
#           the rest shrink away as passes accumulate.
#   Right : the same energies as bars per eigendirection. The random start excites every
#           direction; each pass scales direction j by |ρ(λⱼ)|^q, amplifying the enclosed
#           modes (gain ≈1) and suppressing the rest (gain →0).
# The dots shrinking on the contour picture (left) ARE the bars collapsing (right) — the
# filter amplifying inside the contour and killing everything outside.
#
# Arguments (eigenpairs ordered ascending along the λ-axis):
#   EVALS  :: n            eigenvalues (real; they lie on the real axis of the ℂ-plane)
#   inside :: BitVector    which eigenvalues lie inside the contour
#   σ, r                   contour centre and radius (circle in ℂ on the real axis)
#   zk     :: ne           the quadrature nodes on the contour (complex)
#   energy :: (nstep+1)×n  per-frame normalized subspace energy on each eigendirection
function build_feast_anim(EVALS, inside, σ, r, zk, energy;
                          nstep::Int, caption,
                          frames = default_frames(nstep))
    n  = length(EVALS)
    ne = length(zk)
    incol   = :gold
    outcol  = RGBAf(0.55, 0.55, 0.62, 1.0)
    markcol = [inside[j] ? incol : outcol for j in 1:n]
    esize(e) = 7 .+ 30 .* e                         # eigenvalue dot size from its energy

    set_theme!(theme_black())
    fig = Figure(size = FIGSIZE)
    cap = caption_label!(fig, 1:2)

    span = maximum(EVALS) - minimum(EVALS)
    xlo  = minimum(EVALS) - 0.08span - 0.8
    xhi  = maximum(EVALS) + 0.08span + 0.8

    # ---- left: the contour in ℂ, divided into ne nodes -------------------- #
    axc = Axis(fig[1, 1]; title = "contour C  &  its $(ne) quadrature nodes zₖ",
               xlabel = "Re(z)", ylabel = "Im(z)", aspect = DataAspect())
    limits!(axc, xlo, xhi, -(r + 1.1), r + 1.1)

    # the real axis (where the spectrum lives)
    lines!(axc, [xlo, xhi], [0.0, 0.0]; color = (:white, 0.35), linewidth = 1.2)

    # the contour circle
    ts = range(0, 2π, length = 240)
    lines!(axc, σ .+ r .* cos.(ts), r .* sin.(ts);
           color = (:royalblue, 0.9), linestyle = :dash, linewidth = 2, label = "contour C")

    # radial spokes to each node make the subdivision explicit, then the node markers
    for z in zk
        lines!(axc, [σ, real(z)], [0.0, imag(z)]; color = (:royalblue, 0.25), linewidth = 1)
    end
    scatter!(axc, real.(zk), imag.(zk); marker = :circle, markersize = 12,
             color = :cyan, strokecolor = :white, strokewidth = 0.8, label = "nodes zₖ")

    # eigenvalues on the real axis; marker size ∝ current subspace energy
    esz = Observable(esize(energy[1, :]))
    scatter!(axc, EVALS, zeros(n); markersize = esz, color = markcol,
             strokecolor = :white, strokewidth = 0.8)
    axislegend(axc; position = :rt, framevisible = true, padding = (4, 4, 4, 4))

    # ---- right: filter amplifies enclosed modes, suppresses the rest ------ #
    axb = Axis(fig[1, 2]; title = "subspace energy per eigendirection   (gain ρ(λ)^q)",
               xlabel = "λ   (eigenvalue)", ylabel = "relative energy")
    limits!(axb, xlo, xhi, 0.0, 1.08)
    vspan!(axb, σ - r, σ + r; color = (:gold, 0.10))   # mark the enclosed window
    bw   = 0.55 * minimum(diff(EVALS))                 # bar width from the tightest spacing
    bars = Observable(energy[1, :])
    barplot!(axb, EVALS, bars; width = bw, color = markcol,
             strokecolor = :white, strokewidth = 0.5)

    colsize!(fig.layout, 1, Relative(0.5))

    # ---- per-frame updater ------------------------------------------------ #
    function show_step!(step::Int)                  # step = 0 .. nstep  (= pass count q)
        e = energy[step + 1, :]
        esz[]  = esize(e)
        bars[] = e
        cap[]  = caption(step)
    end

    return (; fig, show_step!, frames, nstep)
end

# --------------------------------------------------------------------------- #
#  Recording                                                                   #
# --------------------------------------------------------------------------- #
function render_anim(av, filename::AbstractString; framerate::Int = 24)
    record(av.fig, filename, eachindex(av.frames); framerate = framerate) do f
        av.show_step!(av.frames[f])
    end
    @info "wrote $filename"
    return filename
end
