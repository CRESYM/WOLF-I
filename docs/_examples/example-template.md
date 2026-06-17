---
layout: example
title: "Example template"
summary: "Minimal template showing the Weave-to-Jekyll example pipeline."
project: https://github.com/CRESYM/WOLF-I/tree/main/projects/example-template
project_name: projects/example-template
generated: 2026-06-17
commit: 6aec7d6
---


This page is a **template**. To create a real example: copy this folder, rename
it, replace the header and content below with your analysis, then render it with

```
julia tools/render_example.jl <your-project-name>
```

The block between the `---` lines above is the page metadata (it never reaches
Weave). Everything here is ordinary Markdown with fenced ` ```julia ` code
blocks; Weave runs each block and inserts the real output beneath it.

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


