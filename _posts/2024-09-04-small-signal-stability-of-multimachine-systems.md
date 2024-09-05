---
layout: post
title:  "Small-Signal Stability of Multimachine Systems: A Step-by-Step Guide. Reference frame transformation."
date:   2024-09-04 08:54:44 +0200
categories: linearmodel
---
{% include welcome_wolf-i.md %}

*In the upcoming blog posts, I will detail the systematic procedure for constructing the linear model of an electrical system. This process follows the method proposed in ["Power System Stability and Control" by Prabha S. Kundur and Om P. Malik.](https://www.accessengineeringlibrary.com/content/book/9781260473544)*

<div style="display: flex; justify-content: center; align-items: center;">

  <div style="text-align: center; margin-right: 20px;">
    <img src="../../../../assets/mermaid-diagram-2024-09-05-132725.png" alt="Diagrama Mermaid" style="width: 700px;">
    <p><em>Building a multimachine linear system</em></p>
  </div>

  <div style="text-align: center;">
    <img src="../../../../assets/2024-07-30-reference-frame-transformation.png" alt="Transformación de marco de referencia" style="width: 500px;">
    <p><em>Reference frame tranformation and associated angles between axes and variables</em></p>
  </div>

</div>

$$i_{dq} = R i_{IR} \rightarrow \begin{bmatrix} i_{d} \\ i_{q} \end{bmatrix} = \begin{bmatrix}-cos(\delta) && sin(\delta) \\ sin(\delta) && cos(\delta)\end{bmatrix} \begin{bmatrix} i_{I} \\i_{R} \end{bmatrix}$$

- Linearizing: 
$$\Delta i_{dq} = {\frac{dR}{d \delta}}|_{\delta  = \delta_0}i_{IR0} \Delta x+R \Delta i_{IR} = {\frac{dR}{d \delta}}|_{\delta  = \delta_0}{R^{-1}i_{dq}}_{0} \Delta x+R \Delta i_{IR} = t_i \Delta x + R \Delta i_{IR}$$

- Defining : 
$$t_i = {\frac{dR}{d \delta}}|_{\delta  = \delta_0}i_{IR0} =\begin{bmatrix}sin(\delta) && cos(\delta) \\ cos(\delta) && -sin(\delta)\end{bmatrix}\begin{bmatrix}-cos(\delta) && sin(\delta) \\ sin(\delta) && cos(\delta)\end{bmatrix} i_{dq0} = \begin{bmatrix}0 && i_{q0} && 0 && \cdots && 0 \\ 0 && -i_{d0}  && 0 && \cdots && 0 \end{bmatrix}$$ ; $$[t_i] = 2 \times n$$ , being $$n$$ the number of state variables.

$$v_{dq} = R v_{IR} \rightarrow \begin{bmatrix} v_{d} \\ v_{q} \end{bmatrix} = \begin{bmatrix}-cos(\delta) && sin(\delta) \\ sin(\delta) && cos(\delta)\end{bmatrix} \begin{bmatrix} v_{I} \\ v_{R} \end{bmatrix}$$

- Linearizing : 
$$\Delta v_{dq} = {\frac{dR}{d \delta}}|_{\delta  = \delta_0}v_{IR0} \Delta x+R \Delta v_{IR} = {\frac{dR}{d \delta}}|_{\delta  = \delta_0}{R^{-1}v_{dq}}_{0} \Delta x+R \Delta v_{IR} = t_v \Delta x + R \Delta v_{IR}$$
- Defining: 
$$t_v = {\frac{dR}{d \delta}}|_{\delta  = \delta_0}v_{IR0} =\begin{bmatrix}sin(\delta) && cos(\delta) \\ cos(\delta) && -sin(\delta)\end{bmatrix}\begin{bmatrix}-cos(\delta) && sin(\delta) \\ sin(\delta) && cos(\delta)\end{bmatrix} v_{dq0} = \begin{bmatrix}0 && v_{q0} && 0 && \cdots && 0 \\ 0 && -v_{d0}  && 0 && \cdots && 0 \end{bmatrix}$$ ; $$[t_v] = 2 \times n$$ , being $$n$$ the number of state variables.
- State space equations : 
$$\Delta \dot{x}_i = A_i \Delta x_i + B_i \Delta v_{dq} \rightarrow \Delta \dot{x}_i = A_i \Delta x_i + B_i (t_v \Delta x + R \Delta v_{IR})$$ ; 
$$\Delta i_{dq} = C_i \Delta x_i + D_i \Delta v_{dq} \rightarrow t_i \Delta x + R \Delta i_{IR} = C_i \Delta x_i + D_i (t_v \Delta x + R \Delta v_{IR})$$

$$A = A_i + B_i t_v$$

$$B = B_i R$$

$$C = R^{-1}(C_i + D_i t_v - t_i)$$

$$D = R^{-1}D_iR$$