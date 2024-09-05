---
layout: post
title:  "Small-Signal Stability of Multimachine Systems: A Step-by-Step Guide. Generator represented by the classical model."
date:   2024-09-02 08:54:44 +0200
categories: linearmodel
---
{% include welcome_wolf-i.md %}

*In the upcoming blog posts, I will detail the systematic procedure for constructing the linear model of an electrical system. This process follows the method proposed in ["Power System Stability and Control" by Prabha S. Kundur and Om P. Malik.](https://www.accessengineeringlibrary.com/content/book/9781260473544)*

*In p.u.*
We are looking for a representation :
- $$\Delta \dot{x}_i = A_i \Delta x_i + B_i \Delta v$$&nbsp; 
- $$\Delta i_i = C_i \Delta x_i + D_i \Delta v$$&nbsp;
- Where : $$\Delta v = \begin{bmatrix}\Delta v_{d} \\\Delta v_{q} \end{bmatrix}$$ ; $$\Delta i_i = \begin{bmatrix}\Delta i_{d} \\\Delta i_{q} \end{bmatrix}$$ .
In order to obtain the state-space representation matrices $$A_i$$ , $$B_i$$ , $$C_i$$ and $$D_i$$ , we consider the stator voltage equations and the equations of motion.
# The stator voltage equations
- $$v_d= -\psi_q -R_a i_d$$&nbsp;
- $$v_q = \psi_d -R_a i_q$$&nbsp;
- Where $$\psi_d = -L_di_d + L_{ad} i_{fd}$$ and $$\psi_q = -L_q i_q$$ .
- If we linearize the equations, considering $$i_d$$ and $$i_q$$ as the only inputs ( $$i_{fd} = cte \rightarrow \Delta i_{fd} = 0$$ ). From example 5.1  :
    - $$\Delta v_d = \frac {\delta v_d}{\delta iq}|_{t=0} \Delta i_q + \frac {\delta v_d}{\delta id}|_{t=0} \Delta i_d$$
    - $$\Delta v_q = \frac {\delta v_q}{\delta iq}|_{t=0} \Delta i_q + \frac {\delta v_q}{\delta id}|_{t=0} \Delta i_d$$
- Considering $$L_d = L_q \rightarrow \begin{bmatrix}\Delta v_{d} \\\Delta v_{q} \end{bmatrix} = \begin{bmatrix}-R_a && L\\\ -L && -R_a\end{bmatrix}\begin{bmatrix}\Delta i_{d} \\\Delta i_{q} \end{bmatrix}$$
	- $$\rightarrow \begin{bmatrix}\Delta i_{d} \\\Delta i_{q} \end{bmatrix} = \begin{bmatrix}-R_a && L \\\ -L && -R_a\end{bmatrix}^{-1} \begin{bmatrix}\Delta v_{d} \\\Delta v_{q} \end{bmatrix}$$ &nbsp;
	- Hence : $$C_i = - \begin{bmatrix}0 && 0\\\ 0 &&0\end{bmatrix}$$ and $$D_i = \begin{bmatrix}-R_a && L \\\ -L && -R_a\end{bmatrix}^{-1}$$

# The equations of motion
- $$\Delta \delta = \frac {1}{\omega_0} \frac{d \Delta \delta}{dt}$$&nbsp;

**The swing equation:** $$T_a = T_m - T_e$$
- It is often desirable to include a component of damping torque $$K_D$$ , not accounted for the calculation of $$T_e$$ , separately.
    - $$2H \frac{d \Delta \omega_r}{dt} = \Delta T_m - \Delta T_e - K_D \Delta \omega_r$$&nbsp;
- If we linearize the previous equation : $$\frac{d \Delta \omega_r}{dt} =\frac {1}{2H}[\Delta T_m - \Delta T_e - K_D \Delta \omega_r]$$
    - $$\Delta T_m = 0$$ : as we consider as inputs $$i_d$$ and $$i_q$$ .
    - Air-gap torque : $$T_e = \psi_d i_q - \psi_q i_d = (-L_di_d + L_{ad} i_{fd})i_q - L_q i_q i_d$$
        - If $$L_d = L_q$$ and $$L_{ad} i_{fd} = e_0 \rightarrow T_e = e_0 i_q \rightarrow \Delta T_e = e_0 \Delta i_q$$
- We arrange the equations in the form of matrices and we get :
    - $$\begin{bmatrix}\Delta \dot\omega_r \\ \Delta \dot\delta \end{bmatrix} = \begin{bmatrix} \frac {- K_D}{2H} && 0 \\\ \omega_0 && 0\end{bmatrix}\begin{bmatrix}\Delta \omega_r \\ \Delta \delta \end{bmatrix} + \begin{bmatrix} 0 && -\frac{e_{0}}{2H} \\\ 0 && 0\end{bmatrix} \begin{bmatrix}\Delta i_{d} \\\Delta i_{q} \end{bmatrix}$$&nbsp;
- Taking into account the stator voltage equations : $$\Delta i_i = C_i \Delta x_i + D_i \Delta v$$
- $$A_i = \begin{bmatrix} \frac {- K_D}{2H} && 0 \\\ \omega_0 && 0\end{bmatrix} + \begin{bmatrix} 0 && -\frac{e_{0}}{2H} \\\ 0 && 0\end{bmatrix} C_i$$&nbsp;
- $$B_i =\begin{bmatrix} 0 && -\frac{e_{0}}{2H} \\\ 0 && 0\end{bmatrix} D_i$$&nbsp;