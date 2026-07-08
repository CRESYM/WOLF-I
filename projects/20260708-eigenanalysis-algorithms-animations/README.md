# Eigenvalue-method animations

Short, self-contained [Makie](https://docs.makie.org/) animations of five classic
eigenvalue algorithms running on a shared symmetric matrix, so the methods can be
compared side by side.

| Method | What the animation shows | Output |
|---|---|---|
| **Power iteration** | the unit iterate `xₖ` rotating onto the dominant eigenvector; bar chart of its eigenbasis coefficients | `anim_powermethod_3d.mp4` |
| **QR algorithm** | the accumulated frame `Pₖ = Q₁⋯Qₖ` rotating onto the eigenvectors while `Aₖ` flattens to a diagonal | `anim_qr_3d.mp4` |
| **Rayleigh-quotient iteration** | `xₖ` locking onto the eigenvector its start leans toward, while the shift `σₖ` slides along the spectrum | `anim_rqi_3d.mp4` |
| **Arnoldi / Lanczos** | Ritz values `eig(Hₖ)` migrating onto the true spectrum (extremes first) as `Hₖ` grows | `anim_arnoldi_2d.mp4` |
| **FEAST** | a contour-integral filter amplifying the enclosed eigenmodes and suppressing the rest | `anim_feast_2d.mp4` |

## Running

Requires Julia with `CairoMakie` (first run precompiles it, which takes a few minutes):

```julia
import Pkg; Pkg.add("CairoMakie")
```

Then, from this directory:

```sh
julia scripts/main.jl                 # render every animation
julia scripts/main.jl power qr        # render only the named methods
```

or from a REPL:

```julia
include("scripts/main.jl")
render_all()                  # or: render_one("rqi")
```

The power method, QR and RQI use the same 3×3 matrix `A3` (defined at the top of
`scripts/main.jl`). Arnoldi and FEAST — whose story is the spectrum itself — share a larger,
well-spread matrix `A_BIG`. Edit those two blocks to change the problems.

Rendered videos are written to `results/`.
The `results/.gitkeep` file is only there so the folder exists in a fresh clone.

## Layout

```
Project.toml                         Julia project metadata
Manifest.toml                        resolved dependency set
scripts/main.jl                     entry point: defines the matrices, one builder per method
src/animation_eigenvaluemethods.jl  raw instrumented solvers (a_powermethod, a_qr, a_rqi, a_arnoldi, a_feast)
src/eigen_methods_anim.jl           wraps each solver run into animation-ready data + captions
src/eigen_viz.jl                    reusable figure builders + shared 3D-frame style + render_anim
results/*.mp4                       generated animations
```

The three 3D-frame methods (power, QR, RQI) share one eigen-frame style via the
`draw_eigenframe!` / `eigen_axis3` helpers in `eigen_viz.jl`, so their pictures are
visually identical; only the moving overlay (hero arrow, rotating frame, or spectrum)
differs per method.
