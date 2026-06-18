# Projects

Each subfolder here is an **independent, reproducible research project**. A project
contains everything needed to understand and reproduce its results, and can be run
on its own.

## Per-project layout

```
projects/<Project_Name>/
├── README.md          Purpose, requirements, how to run, related posts/publications
├── Project.toml       Julia dependencies for this project
├── Manifest.toml      Pinned versions (commit this — it is what makes the project reproducible)
├── *.jmd              Weave source(s) for published example(s): prose + ```julia
│                       blocks. Each .jmd renders to its own /examples/ page.
├── src/               Reusable source code
├── scripts/           Entry-point scripts (e.g. run_simulation.jl)
├── models/            Modelica models (.mo) used by the project
├── data/              Input data
└── results/           Generated outputs (figures, matrices, reports)
```

## Julia environment

Each project carries its own environment. To set it up / reproduce:

```bash
cd projects/<Project_Name>
julia --project=.
```

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

Commit both `Project.toml` and `Manifest.toml`.