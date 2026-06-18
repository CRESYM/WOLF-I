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

## Publishing an example

A worked example is written as a `.jmd` file (Markdown prose with ` ```julia `
code blocks) and rendered into a styled, **executable** page on the website. The
results shown are produced by the code, so they cannot drift.

Render it locally (Weave runs the code in the project's own environment):

```bash
# one-time, in your global Julia env:
julia -e 'using Pkg; Pkg.add("Weave")'

# render a .jmd file:
julia tools/render_jmd.jl projects/<Project_Name>/<file>.jmd
```

A project may hold several `.jmd` files; **each renders to its own page**. The
page slug is the `.jmd` file name, published at `/examples/<slug>/` and listed on
the site's **Examples** index. Re-run it whenever the code changes (there is no
CI; the page carries a "generated on … / commit …" stamp so staleness is visible).

The page title and summary (and an optional related post) are **not** in the
`.jmd` — set them in the `METADATA` table near the top of
[`../tools/render_jmd.jl`](../tools/render_jmd.jl), keyed by slug. A missing
entry just falls back to defaults (title = the slug, no summary).

## Documentation links

Every project should be connected to the development diary in both directions:

- the project `README.md` links to its related blog posts in [`../docs/_posts/`](../docs/_posts/), and
- a dated blog post links to the canonical example at `/examples/<Project_Name>/`,
  which in turn links back to the project folder and the post.
