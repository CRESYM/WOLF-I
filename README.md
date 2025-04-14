# Small Signal Stability in Julia

A modular collection of tools, models, and reports for linear system modeling, analysis, and documentation centered around power systems and inter-area oscillations.

This repository focuses on **[small signal stability analysis using Julia](#)** and it integrates:
- 🧩 Physical system modeling in **Modelica** and **Julia**.
- ⚙️ Linearization and matrix extraction.
- 📈 System analysis.
- 🧪 Reproducible scientific reporting with **Weave.jl**.

> This repository is **example-based**: the goal is to build a growing library of specific case studies that illustrate key concepts in small-signal stability, particularly in the context of inter-area oscillations.

> **Note**: This work is part of the [WOLF-I Project](https://cresym.github.io/WOLF-I/), which studies inter-area oscillations in power systems, especially under high IBR penetration (inverter-based resources).

## 📁 Structure

| Repository         | Description                                                 |
|--------------------|-------------------------------------------------------------|
| `ModelicaModels`   | Physical systems modeled and linearized in Modelica         |
| `JuliaLinearModels`| Linear models generated in Julia                            |
| `LinearSystemAnalysis` | Scripts for in-depth linear system analysis             |
| `ScientificReports`| Reproducible reports using `Weave.jl`                       |


## 📎 Related Links

- 📘 [WOLF-I Project](https://cresym.github.io/WOLF-I/)

## 📬 Contributions

Feel free to open issues, fork the repo, or suggest improvements. 
