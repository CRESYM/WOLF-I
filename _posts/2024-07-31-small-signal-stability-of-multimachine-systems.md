---
layout: post
title:  "Small-Signal Stability of Multimachine Systems: A Step-by-Step Guide. Reference frame transformation."
date:   2024-07-31 07:00:00 +0200
categories: linearmodel
---
{% include welcome_wolf-i.md %}

*In the upcoming blog posts, I will detail the systematic procedure for constructing the linear model of an electrical system. This process follows the method proposed in ["Power System Stability and Control" by Prabha S. Kundur and Om P. Malik.](https://www.accessengineeringlibrary.com/content/book/9781260473544)*


- $$\begin{bmatrix}\Delta i_{I} \\\Delta i_{R} \end{bmatrix} = \begin{bmatrix}cos(\delta) && -sin(\delta) \\\ sin(\delta) && cos(\delta)\end{bmatrix} \begin{bmatrix}\Delta i_{d} \\\Delta i_{q} \end{bmatrix} \rightarrow  \begin{bmatrix}\Delta i_{d} \\\Delta i_{q} \end{bmatrix}  = \begin{bmatrix}cos(\delta) && -sin(\delta) \\\ sin(\delta) && cos(\delta)\end{bmatrix}^{-1} \begin{bmatrix}\Delta i_{I} \\\Delta i_{R} \end{bmatrix}$$ &nbsp;
- $$\begin{bmatrix}\Delta v_{I} \\\Delta v_{R} \end{bmatrix} = \begin{bmatrix}cos(\delta) && -sin(\delta) \\\ sin(\delta) && cos(\delta)\end{bmatrix} \begin{bmatrix}\Delta v_{d} \\ \Delta v_{q} \end{bmatrix} \rightarrow  \begin{bmatrix}\Delta v_{d} \\ \Delta v_{q} \end{bmatrix} =  \begin{bmatrix}cos(\delta) && -sin(\delta) \\\ sin(\delta) && cos(\delta)\end{bmatrix} ^{-1} \begin{bmatrix}\Delta v_{I} \\\Delta v_{R} \end{bmatrix}$$ &nbsp;
- $$\Delta \dot{x}_i = A_i \Delta x_i + B_i \Delta v \rightarrow \Delta \dot{x}_i = A_i \Delta x_i + B_i R^{-1} \Delta v_{IR}$$ &nbsp;
- $$\Delta i_i = C_i \Delta x_i - Y_i \Delta v \rightarrow R^{-1} \Delta i_{IR} = C_i \Delta x_i - Y_i R^{-1} \Delta v_{IR} \rightarrow \Delta i_{IR} = R C_i \Delta x_i - R Y_i R^{-1} \Delta v_{IR}$$ &nbsp;

![alt text](../../../../assets/2024-07-30-reference-frame-transformation.png)