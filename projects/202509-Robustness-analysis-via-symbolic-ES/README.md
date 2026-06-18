# Robustness Analysis via Symbolic Eigenvalue Sensitivities

Symbolic small-signal stability analysis of a multi-machine power system. The
code builds the closed-loop state-space model of a two-machine system
(classical generator model), keeps a chosen physical parameter **symbolic**, and
derives closed-form expressions for the system eigenvalues and their
sensitivities. Sweeping the symbolic parameter then reveals how the
inter-area mode igenvalue sensitivity moves — i.e. how *robust* the POD is to
variation in that parameter.

The symbolic engine is [Symbolics.jl](https://symbolics.juliasymbolics.org/);
load flow uses [PowerModels.jl](https://lanl-ansi.github.io/PowerModels.jl/).

## Method in brief

For each configuration the pipeline:

1. Solves the power flow for the network model (`bs_2area2gen_shiftbus3.m`).
2. Replaces one parameter with a symbolic variable and assembles the closed-loop
   state matrix `Aex` symbolically (generator state-space + network admittance +
   a controllability/observability feedback channel).
3. Computes eigenvalues and modal sensitivities of `Aex` as expressions in that
   symbolic variable.
4. Evaluates the expressions over a numerical range and tracks the inter-area
   mode (target ≈ `0 + 3.27i`).

Sweeps are run over combinations of:

| Dimension | Values | Meaning |
|-----------|--------|---------|
| `symvars` | `x`, `kH`, `va`, `vm`, `KD` | symbolic parameter: line reactance, inertia ratio H₂/H₁, bus voltage angle, bus voltage magnitude, generator damping |
| `iinp`    | `f`, `v`, `iabs`, `p`, `q`, `s` | feedback input signal type |
| `iout`    | `P`, `Q` | feedback output type |
| `jpod`    | bus index (e.g. `3`) | location of the damping/feedback channel |

## Repository structure

```
src/        the SymbolicES package — the analysis engine
scripts/    runnable entry points — these are what you run
data/       input network models (MATLAB format, read by PowerModels)
test/        package smoke tests (`]test`)
results/    generated .jld2 / .csv output      (git-ignored)
figures/    generated figures                  (git-ignored)
old/        archived experimental code         (git-ignored)
```

This repo **is** the `SymbolicES` Julia package: activate it with `--project=.`
and `using SymbolicES` makes the public API (`symanalysis`, `dict_to_df`, the
label dictionaries) available — no relative `include`s needed.

### `src/` — the `SymbolicES` package
| File | Provides |
|------|----------|
| [src/SymbolicES.jl](src/SymbolicES.jl) | **Package entry.** Loads the modules below and re-exports the public API |
| [src/linmodfun.jl](src/linmodfun.jl) | load flow (`solvelf`), generator state-space (`ssmatrix`) |
| [src/symtools.jl](src/symtools.jl) | symbolic toolkit: `buildsystem` (symbolic admittance matrix + closed-loop assembly), `contobsfac` (controllability/observability), `system_eigenanalysis` (eigenvalues + sensitivities), plus result-processing helpers (`process_results`) |
| [src/symanalysis.jl](src/symanalysis.jl) | `SymbolicAnalysis.symanalysis(...)` — the end-to-end analysis for one configuration |

### `scripts/` — runnable entry points

**Orchestration**
| File | Role |
|------|------|
| [scripts/generate_results.jl](scripts/generate_results.jl) | **Main driver.** Sweeps all dimensions, calls `symanalysis`, saves `results/results_1_shiftbus3.jld2` |
| [scripts/merge_results.jl](scripts/merge_results.jl) | Merges several `*.jld2` result files into one |
| [scripts/optimize_input2.jl](scripts/optimize_input2.jl) | Optimizes feedback-input coefficients (JuMP + HiGHS) to maximize a guaranteed sensitivity bound |

**Validation / post-processing**
| File | Role |
|------|------|
| [scripts/check_results_eigenvalues.jl](scripts/check_results_eigenvalues.jl) | Sanity-checks the computed eigenvalues, writes a CSV summary |
| [scripts/check_results_sensitivities.jl](scripts/check_results_sensitivities.jl) | Sanity-checks the sensitivity expressions |
| [scripts/check_optimized_input.jl](scripts/check_optimized_input.jl) | Verifies the optimized input from `optimize_input2.jl` |

**Plotting** (write to `figures/`)
| File | Produces |
|------|----------|
| [scripts/plot_results_general.jl](scripts/plot_results_general.jl) | Grid of sensitivity-vs-parameter plots across all configurations |
| [scripts/plot_results_eigenvalues.jl](scripts/plot_results_eigenvalues.jl) | Eigenvalue trajectories vs parameter |
| [scripts/plot_results_f.jl](scripts/plot_results_f.jl) | Frequency / damping plots |
| [scripts/vector_addition_plot.jl](scripts/vector_addition_plot.jl) | Standalone illustrative figure |

### `data/` and generated folders
- [data/](data/) — input network models (MATLAB format, read by PowerModels). Active model: `bs_2area2gen_shiftbus3.m`.
- `results/` — generated `.jld2` data and `.csv` summaries (git-ignored; folder kept by `.gitkeep`).
- `figures/` — generated figures (git-ignored; folder kept by `.gitkeep`).
- `old/` — archived obsolete/experimental code (git-ignored).

## Requirements

- Julia ≥ 1.10 (developed on 1.12).
- Dependencies are declared in [Project.toml](Project.toml) and pinned in the
  committed `Manifest.toml`.

## Setup

```julia
julia --project=. -e 'using Pkg; Pkg.instantiate()'   # install the exact pinned versions
julia --project=. -e 'using Pkg; Pkg.test()'          # optional: smoke-test the package
```

> **Version pin (important).** `Manifest.toml` is committed and pins the exact
> known-good stack — notably **Symbolics 6.58.0 / SymbolicUtils 3.32.0**. Newer
> Symbolics 7 / SymbolicUtils 4 currently break the analysis (rational-overflow
> and symbolic-comparison errors in the eigenvalue step), so `Project.toml` caps
> `Symbolics` below 7. Run `Pkg.instantiate()` (not `Pkg.update()`) to reproduce
> results exactly. See `scripts/smoke_test.jl` to verify the pipeline runs.

In the REPL or a script, load the library with:

```julia
using SymbolicES   # exports `symanalysis`, `dict_to_df`, the label dictionaries, …
```

## Usage

Run every script **from the repository root** with the project environment active
(`--project=.`). Scripts resolve paths relative to the root (`data/…`, `results/…`,
`figures/…`), so the working directory must be the repo root.

```bash
# 1. Generate results (the long step) -> results/results_1_shiftbus3.jld2
julia --project=. scripts/generate_results.jl

# 2. (optional) Validate the run -> results/lambda_check_analysis_*.csv
julia --project=. scripts/check_results_eigenvalues.jl
julia --project=. scripts/check_results_sensitivities.jl

# 3. Plot -> figures/
julia --project=. scripts/plot_results_general.jl
julia --project=. scripts/plot_results_eigenvalues.jl

# 4. (optional) Optimize the feedback input
julia --project=. scripts/optimize_input2.jl
julia --project=. scripts/check_optimized_input.jl
```

For interactive work, run the same files in the Julia REPL or VS Code so the
in-memory result dictionaries (`λres`, `ζ`, `λcheck`, …) stay available for
inspection.

> **Note on file names:** result and figure file names (e.g.
> `results/results_1_shiftbus3.jld2`, `figures/all_sensi_3.png`) are currently
> hard-coded in the scripts. Adjust them at the top/bottom of each script as needed.

## License

Released under the [MIT License](LICENSE) — free to use, modify, and
redistribute, provided the copyright and license notice are retained.
