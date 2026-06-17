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

## Documentation links

Every project should be connected to the development diary in both directions:

- the project `README.md` links to its related blog posts in [`../docs/_posts/`](../docs/_posts/), and
- the blog post links back to the project folder.
