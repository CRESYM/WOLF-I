# Two-Area Four-Generator Linear Model

Eigenvalue calculation of Kundur's classic **two-area, four-generator** power system, implemented in Julia.

Each generator and voltage-dependent load is represented by a small
state-space model in its own *dq* frame, rotated into a common network (real /
imaginary) frame and coupled through the expanded nodal admittance matrix. The
multimachine system matrix is assembled as

```
A = Ad + Bd · (Y_ex − Dd)⁻¹ · Cd
```

and its eigenvalues give the electromechanical modes of the system.

## Requirements

- Julia ≥ 1.10 (developed on 1.12)
- Dependencies are pinned in `Project.toml` / `Manifest.toml`
  (`PowerModels`, `BlockDiagonals`, `Symbolics`, `Nemo`, `Plots`, and the
  standard library `LinearAlgebra`).

Instantiate the exact environment from the repository root with:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

## Repository layout

```
.
├── README.md
├── LICENSE                  MIT license
├── CITATION.cff             Citation metadata (GitHub "Cite this repository")
├── Project.toml             Julia dependencies
├── Manifest.toml            Pinned versions (reproducible environment)
├── 2area4gen_clsgen.jmd     Weave source for the published classical-model example
├── 2area4gen_detgen.jmd     Weave source for the published detailed-model example
├── src/
│   └── linmodfun.jl         Reusable modules: load flow (solvelf), admittance
│                            matrices (ymatrix), state-space models (ssmatrix)
├── scripts/                 Entry-point analysis scripts (see below)
├── data/                    MATPOWER case files (network input data)
└── results/                 Generated outputs (figures, matrices)
```

### Scripts

| Script | Generator model | Notes |
|---|---|---|
| `scripts/2area4gen_clsgen.jl` | Classical (2 states) | Eigenvalues of the multimachine model |
| `scripts/2area4gen_detgen.jl` | Detailed 1d-2q (6 states) | Eigenvalues of the multimachine model |

### Data

| File | Description |
|---|---|
| `data/bs_2area4gen.m` | Kundur two-area, four-generator network (11 buses, MATPOWER format) |
| `data/bs_3bus.m` | Reduced three-bus study network (MATPOWER format), kept for future three-bus studies |

## Citation

If you use this software, please cite it. Citation metadata is provided in
[`CITATION.cff`](CITATION.cff); on GitHub you can use the **"Cite this
repository"** button to export BibTeX/APA. For example:

> Cedenilla Bote, A. (2026). *Two-Area Four-Generator Linear Model* [Computer
> software]. https://github.com/Alejandra-CB/202505-Two-Area-Four-Gen-Linear-Model

## License

Released under the MIT License — see [`LICENSE`](LICENSE).
