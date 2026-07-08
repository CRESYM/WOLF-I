# main.jl — single entry point to render every eigenvalue-method animation
using LinearAlgebra
using Random

include(joinpath(@__DIR__, "..", "src", "eigen_viz.jl"))
include(joinpath(@__DIR__, "..", "src", "eigen_methods_anim.jl"))

# --------------------------------------------------------------------------- #
#  The shared 3×3 problem                                                      #
# --------------------------------------------------------------------------- #
# Symmetric A = Q diag(λ) Qᵀ with a fixed orthonormal eigen-frame Q. Used by the
# power method, QR and RQI so every animation shows the same spectrum.
# Well-separated top eigenvalues converge fast; close ones converge slowly.
const LAMBDAS3 = [3.0, 1.0, 0.5]
const Q3       = Matrix(qr([2.0 0.0 1.0; 1.0 2.0 0.0; 0.0 1.0 2.0]).Q)
const A3       = Symmetric(Q3 * Diagonal(LAMBDAS3) * Q3')

# A bigger, well-spread spectrum, shared by Arnoldi and FEAST — the two methods
# whose story is the spectrum itself and which need several eigenvalues to be
# interesting. For Arnoldi the extremes (10, −8) are pinned down first while the
# crowded interior fills in last; for FEAST a contour can enclose a few modes and
# leave others at varying distances to fade at visibly different rates.
const LAMBDAS_BIG = [10.0, 7.0, 5.0, 3.0, 2.0, 1.0, -1.0, -3.0, -5.0, -8.0]
const N_BIG       = length(LAMBDAS_BIG)
const A_BIG = let
    Random.seed!(1)
    Qb = Matrix(qr(randn(N_BIG, N_BIG)).Q)          # fixed orthonormal eigen-frame
    Symmetric(Qb * Diagonal(LAMBDAS_BIG) * Qb')
end

# --------------------------------------------------------------------------- #
#  One builder per method → (animation bundle, output filename)                #
# --------------------------------------------------------------------------- #
function build_power()
    DATA = powermethod_anim(A3; nstep = 10)
    av = build_eigenbasis_anim(DATA.EVALS, DATA.EVEC, DATA.Acoef, DATA.XSEQ;
                               nstep = DATA.nstep, caption = DATA.caption)
    return av, joinpath("results", "anim_powermethod_3d.mp4")
end

function build_qr()
    DATA = qr_anim(A3; nstep = 12)
    av = build_qr_anim(DATA.EVALS, DATA.EVEC, DATA.Ait, DATA.Pit;
                       nstep = DATA.nstep, caption = DATA.caption)
    return av, joinpath("results", "anim_qr_3d.mp4")
end

function build_rqi()
    # x₀ leans toward v2 (λ = 1) so the shift slides in and snaps onto the MIDDLE
    # eigenvalue — the contrast with the power method (which drives to λ = 3).
    x0 = Q3 * [0.6, 1.0, 0.3]
    DATA = rqi_anim(A3, x0; nstep = 6)
    av = build_rqi_anim(DATA.EVALS, DATA.EVEC, DATA.XSEQ, DATA.σ, DATA.target;
                        nstep = DATA.nstep, caption = DATA.caption)
    return av, joinpath("results", "anim_rqi_3d.mp4")
end

function build_arnoldi()
    Random.seed!(2)
    x0 = randn(N_BIG)                               # generic start: excites every mode
    DATA = arnoldi_anim(A_BIG, x0; nstep = N_BIG)
    av = build_arnoldi_anim(DATA.EVALS, DATA.H, DATA.Ritz, DATA.kdone;
                            nstep = DATA.nstep, caption = DATA.caption)
    return av, joinpath("results", "anim_arnoldi_2d.mp4")
end

function build_feast()
    # FEAST reuses the larger A_BIG spectrum (like Arnoldi), so the contour has
    # several eigenvalues at different distances to filter. Contour on the real
    # axis: circle centre σ, radius r → interval [σ−r, σ+r] = [−0.8, 4.8] here,
    # which cleanly encloses {1, 2, 3} (retained, gain ρ≈1). The just-outside modes
    # λ=−1 and λ=5 (gain ρ≈0.3) fade GRADUALLY over the passes, while the far ones
    # (−3, −5, −8, 7, 10) are killed almost at once — the filtering shows as a fade,
    # not a single jump. (r is kept off the eigenvalues so none sits on the contour.)
    DATA = feast_anim(A_BIG, 2.0, 2.8; ne = 12, m0 = 8, nstep = 6)
    av = build_feast_anim(DATA.EVALS, DATA.inside, DATA.σ, DATA.r,
                          DATA.zk, DATA.energy;
                          nstep = DATA.nstep, caption = DATA.caption)
    return av, joinpath("results", "anim_feast_2d.mp4")
end

const BUILDERS = (
    power   = build_power,
    qr      = build_qr,
    rqi     = build_rqi,
    arnoldi = build_arnoldi,
    feast   = build_feast,
)

# --------------------------------------------------------------------------- #
#  Drivers                                                                     #
# --------------------------------------------------------------------------- #
function render_one(name)
    key = Symbol(name)
    haskey(BUILDERS, key) ||
        error("unknown method \"$name\"; choose from $(join(keys(BUILDERS), ", "))")
    av, file = BUILDERS[key]()
    return render_anim(av, file)
end

render_all() = foreach(render_one, keys(BUILDERS))

# Script entry point: `julia main.jl [names...]`
if abspath(PROGRAM_FILE) == @__FILE__
    isempty(ARGS) ? render_all() : foreach(render_one, ARGS)
end