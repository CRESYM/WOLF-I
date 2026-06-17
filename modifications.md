# WOLF-I Project Restructuring Plan

## Objective

The goal of this restructuring is to transform WOLF-I into a long-term research repository combining:

* Scientific software and simulation projects.
* Reproducible computational environments.
* Modelica models and Julia-based tools.
* A development diary documenting the evolution of the project.
* A public website generated with GitHub Pages.

The repository should act both as:

1. A research archive containing the code and models required to reproduce results.
2. A scientific notebook explaining the motivation, methodology, and progress of the project.

---

# Target Repository Structure

The final repository should follow this structure:

```
WOLF-I/
│
├── README.md
├── LICENSE
├── CITATION.cff
│
├── projects/
│   │
│   ├── Project_A/
│   │   ├── README.md
│   │   ├── Project.toml
│   │   ├── Manifest.toml
│   │   ├── src/
│   │   ├── scripts/
│   │   ├── models/
│   │   ├── data/
│   │   └── results/
│   │
│   ├── Project_B/
│   │   ├── README.md
│   │   ├── Project.toml
│   │   ├── Manifest.toml
│   │   ├── src/
│   │   ├── scripts/
│   │   └── models/
│   │
│   └── ...
│
├── website/
│   │
│   ├── _config.yml
│   ├── _posts/
│   ├── _pages/
│   ├── assets/
│   └── projects/
│
└── .github/
    └── workflows/
```

---

# Repository Philosophy

## Research projects

Each research activity should be independent.

A project inside `projects/` must contain everything needed to understand and reproduce its results:

* Source code.
* Julia environment.
* Modelica models.
* Input data.
* Scripts used for simulations.
* Generated results.
* A README explaining the purpose and execution procedure.

Each project should be executable independently.

Example:

```
projects/Project_A/

README.md
Project.toml
Manifest.toml
scripts/run_simulation.jl
models/system.mo
results/
```

---

# Julia Environment Management

Each Julia project must contain its own environment.

Inside each project:

```
Project.toml
Manifest.toml
```

The environment should be activated with:

```bash
julia --project=.
```

Dependencies must be added locally to each project.

Example:

```julia
using Pkg

Pkg.activate(".")
Pkg.instantiate()
```

This guarantees that simulations can be reproduced in the future.

---

# Modelica Models

Modelica files should remain inside the project where they are used.

Example:

```
projects/Project_A/models/

plant.mo
controller.mo
experiment.mo
```

Each model should include:

* A meaningful name.
* Documentation comments.
* Parameters description.
* Required simulation settings.

---

# Project README Files

Each project should contain a README file.

Example:

```
projects/Project_A/README.md
```

The README should include:

## Purpose

Explain the scientific objective.

## Structure

Describe the main folders.

## Requirements

Software requirements:

* Julia version.
* OpenModelica version.
* Required packages.

## Running simulations

Example:

```bash
julia --project=. scripts/main.jl
```

## Related publications

List papers, reports, or presentations.

## Related blog posts

Link to the corresponding development diary entries.

---

# Website Structure

The website will remain focused on communication and documentation.

The website should contain:

```
website/

_posts/
    Development diary entries

_pages/
    Static pages

projects/
    Description of research projects

assets/
    Images and figures
```

The website is not the place for storing scientific code.

Instead, blog entries should link to the corresponding project folder.

Example:

Blog entry:

```
2026-07-02-project-A.md
```

contains:

```
The code associated with this study is available here:

projects/Project_A
```

---

# Development Diary

The diary documents the evolution of the research.

Examples:

```
_posts/

2026-06-17-initial-setup.md

2026-07-02-project-A-development.md

2026-08-10-model-validation.md
```

Each post should explain:

* What was attempted.
* Why it was needed.
* Main results.
* Problems encountered.
* Links to code and data.

---

# Migration Steps

## Step 1 - Create the new structure

Create:

```
projects/
website/
.github/workflows/
```

Move the current website files into:

```
website/
```

---

## Step 2 - Move research code

For each existing code branch:

Create:

```
projects/Project_Name/
```

Move:

* Julia scripts.
* Modelica files.
* Data.
* Results.

Create:

```
README.md
```

for each project.

---

## Step 3 - Create Julia environments

For each Julia project:

```bash
cd projects/Project_Name

julia
```

Then:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

Commit:

```
Project.toml
Manifest.toml
```

---

## Step 4 - Configure GitHub Pages

The website should be generated automatically using GitHub Actions.

The main branch should contain:

```
projects/
website/
.github/
```

The website is published from the generated output.

---

## Step 5 - Add documentation links

Every research project should be connected in both directions:

Blog → Code

and

Code → Blog

Example:

```
Blog post
    |
    ↓
projects/Project_A

projects/Project_A/README.md
    |
    ↓
Related publications and diary entries
```

---

# Long-Term Goals

The final WOLF-I repository should provide:

* Reproducible simulations.
* Clear scientific history.
* Public documentation.
* Easy collaboration.
* Long-term maintainability.

The repository should remain understandable years after the original development.
