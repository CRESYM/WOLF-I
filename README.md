# WOLF-I: Wide-area Oscillations of Low Frequency in presence of IBRs

Research repository for the **WOLF-I** project, studying the role of inverter-based
resources (IBRs) in the damping of inter-area oscillations in power systems. It
combines reproducible scientific software, Modelica/Julia models, and a public
development diary.

The repository acts as both:

1. A **research archive** — the code, models, and environments needed to reproduce results.
2. A **scientific notebook** — the motivation, methodology, and progress, published as a website.

## Repository structure

```
WOLF-I/
├── README.md            This file
├── LICENSE
├── CITATION.cff         How to cite this work
├── projects/            Independent, reproducible research projects (see projects/README.md)
└── docs/                Jekyll source for the public GitHub Pages site
```

- **`projects/`** — each subfolder is a self-contained study with its own Julia
  environment (`Project.toml` / `Manifest.toml`), models, scripts, and `README.md`.
  See [projects/README.md](projects/README.md) for the per-project convention.
- **`docs/`** — the development diary and project documentation, published via
  GitHub Pages. Blog posts link to the corresponding `projects/` folder, and each
  project README links back to its diary entries.

## Website

The site is published with GitHub Pages, which builds the Jekyll source in `docs/`
automatically on every push to `main` (Settings → Pages → Source: *Deploy from a
branch* → `main` / `/docs`).

Local preview:

```bash
cd docs
bundle install
bundle exec jekyll serve --livereload
```

## Getting involved

Open issues, fork the repo, or suggest improvements. For more information about
the WOLF-I project, contact [alejandra.cedenilla-bote@cresym.eu](mailto:alejandra.cedenilla-bote@cresym.eu).

Research conducted over a 4-year PhD program (Dec 2023 – Nov 2027), in
collaboration with [RTE France](https://www.rte-france.com/),
[IIT Comillas](https://www.iit.comillas.edu/), and [CRESYM](https://cresym.eu/).
