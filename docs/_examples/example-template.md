---
layout: example
title: "Example template"
summary: "Minimal template showing the Weave-to-Jekyll example pipeline."
project: https://github.com/CRESYM/WOLF-I/tree/main/projects/example-template
project_name: projects/example-template
generated: 2026-06-17
commit: ac7abe2
---

# Example template

This page is a **template**. To create a real example: copy this folder, rename
it, replace the code and prose below with your analysis, fill in `example.yml`,
then render it with

```
julia tools/render_example.jl <your-project-name>
```

Everything below is ordinary Markdown with fenced ` ```julia ` code blocks; Weave
runs each block and inserts the real output beneath it.

We build a tiny state matrix:

```julia
using LinearAlgebra

A = [0.0  -1.0;
     1.0   0.0]
```

```
2×2 Matrix{Float64}:
 0.0  -1.0
 1.0   0.0
```





Its eigenvalues are purely imaginary, so this system is a marginally stable
oscillator — the kind of result you would then comment on:

```julia
eigvals(A)
```

```
2-element Vector{ComplexF64}:
 0.0 - 1.0im
 0.0 + 1.0im
```


