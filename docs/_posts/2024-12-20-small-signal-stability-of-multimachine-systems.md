---
layout: post
title:  "Two-area Four-generator Kundur system"
date:   2024-12-20 08:54:44 +0200
description: "Two reproducible, executable examples that build the multimachine linear model of Kundur's two-area, four-generator system and compute its eigenvalues, using the classical and detailed synchronous machine models."
tag: insights
---

Two executable examples are available showing how to build a multimachine linear model and compute its eigenvalues, applied to Kundur's **two-area, four-generator** system. Each one gives a step-by-step explanation of the procedure — from solving the load flow to assembling the global matrices and calculating the eigenvalues. Both are generated directly from the code in [`projects/202505-Two-Area-Four-Gen-Linear-Model/`]({{ site.baseurl }}/examples/), so the results shown are produced by the code itself:

- [Two-Area Four-Generator System (classical model)]({{ site.baseurl }}/examples/2area4gen-clsgen/) — the simplest multimachine linear model, using the classical synchronous machine model (two state variables per generator).
- [Two-Area Four-Generator System (detailed model)]({{ site.baseurl }}/examples/2area4gen-detgen/) — the multimachine linear model using the detailed 1d-2q synchronous machine model (six state variables per generator).

Both examples follow the method proposed in ["Power System Stability and Control" by Prabha S. Kundur and Om P. Malik.](https://www.accessengineeringlibrary.com/content/book/9781260473544)
