---
layout: post
title:  "Small-Signal Stability of Multimachine Systems: A Step-by-Step Guide. Representation of static loads."
date:   2024-08-30 08:54:44 +0200
categories: linearmodel
---
{% include welcome_wolf-i.md %}

*In the upcoming blog posts, I will detail the systematic procedure for constructing the linear model of an electrical system. This process follows the method proposed in ["Power System Stability and Control" by Prabha S. Kundur and Om P. Malik.](https://www.accessengineeringlibrary.com/content/book/9781260473544)*

- Considering :
	- Voltage : $$v = v_R + jv_I$$
	- Current : $$i = i_R + ji_I$$
	- Apparent power : $$s = vi^* = p + jq$$
	- Admittance matrix : $$i = Yv$$
- We are working with static loads, that means that no dynamic behaviour is associated with this loads. Hence, we are looking for integrating this elements in the admittance matrix of the systems. That means that we are looking for a representation in the form : $$\Delta i = Y_L \Delta v \rightarrow \begin{bmatrix}\Delta i_{I} \\ \Delta i_{R} \end{bmatrix}= \begin{bmatrix} G_{II} && B_{IR} \\ B_{RI} && G_{RR} \end{bmatrix} \begin{bmatrix}\Delta v_{I} \\\Delta v_{R} \end{bmatrix}$$

# Constant impedance (linear) load
- Conductance : $$G_L = \frac{P_{L0}}{V_0^2} = cte$$
- Susceptance : $$B_L = - \frac{Q_{L0}}{V_0^2} = cte$$
- Current : $$i_L = i_{LI} + ji_{LR} = Y_L v = (G_L + jB_L)(v_I +jv_R)$$
	- Linearizing : $$\Delta i_L = G_L \Delta v_I + j B_L \Delta v_I + j G_L \Delta v_R - B_L \Delta v_R = \Delta i_I + j \Delta i_R$$
	- In matrix form : $$\begin{bmatrix}\Delta i_{I} \\ \Delta i_{R} \end{bmatrix}= \begin{bmatrix} G_L && -B_L \\ B_L && G_L \end{bmatrix} \begin{bmatrix}\Delta v_{I} \\\Delta v_{R} \end{bmatrix}$$

# Nonlinear load
Consider the loads whose voltage - dependent characteristics are expressed as :
- Active and reactive power : $$P_L = P_{L0} (\frac{V}{V_0})^m$$ ; $$Q_L = Q_{L0} (\frac{V}{V_0})^n$$
- Voltage : $$V = \sqrt{v_I^2 + v_R^2}$$

Linearizing $$i_L$$ :  $$i_L = (\frac{S}{v})^* = \frac{P_L - jQ_L}{v_R - jv_I} = \frac{P_L - jQ_L}{v_R - jv_I} \frac{v_R+ jv_I}{v_R + jv_I} = \frac {P_L v_R +jP_Lv_I +v_IQ_L -j Q_Lv_R}{v_I^2 + v_R^2}$$

- $$i_R = \frac{P_Lv_R+Q_Lv_I}{V^2} \rightarrow \Delta i_R = \frac{\partial i_R}{\partial v_I}|_{t = 0} \Delta v_I +  \frac{\partial i_R}{\partial v_R}|_{t = 0} \Delta v_R$$
- $$\frac{\partial i_R}{\partial v_R}|_{t = 0} \Delta v_R = \frac{P_{L0}}{V_0^2} \Delta v_R + \frac{v_{R0}}{V_0^2} \Delta P_L + \frac{(-2)P_{L0}v_{R0}}{V_0^3}\Delta V + \frac{v_{I0}}{V_{0}^2}\Delta Q_L + \frac{(-2)Q_{L0}v_{I0}}{V_0^3}\Delta V$$
- $$\frac{\partial i_R}{\partial v_I}|_{t = 0} \Delta v_R = \frac{v_{R0}}{V_0^2} \Delta P_L + \frac{(-2)P_{L0}v_{R0}}{V_0^3}\Delta V + \frac{Q_{L0}}{V_0^2}\Delta v_R + \frac {v_{I0}}{V_0^2}\Delta Q_L + \frac{(-2)Q_{L0}v_{I0}}{V_0^3}\Delta V$$
- $$i_I = \frac{P_Lv_I-Q_Lv_R}{V^2} ; \Delta i_I = \frac{\partial i_I}{\partial v_I}|_{v_I =v_{I0}} \Delta v_I +  \frac{\partial i_R}{\partial v_R}|_{v_R =v_{R0}} \Delta v_R$$
- $$\frac{\partial i_I}{\partial v_R}|_{t = 0} \Delta v_R = \frac{- Q_{L0}}{V_0^2} \Delta v_R + (-1)\frac{v_{R0}}{V_0^2} \Delta Q_L + \frac{(-2)(-1)Q_{L0}v_{R0}}{V_0^3}\Delta V + \frac{v_{I0}}{V_{0}^2}\Delta P_L + \frac{(-2)P_{L0}v_{I0}}{V_0^3}\Delta V$$
- $$\frac{\partial i_I}{\partial v_I}|_{t = 0} \Delta v_I = (-1)\frac{v_{R0}}{V_0^2} \Delta Q_L + (-1)\frac{(-2)Q_{L0}v_{R0}}{V_0^3}\Delta V + \frac{P_{L0}}{V_0^2}\Delta v_I + \frac {v_{I0}}{V_0^2}\Delta P_L + \frac{(-2)P_{L0}v_{I0}}{V_0^3}\Delta V$$

Linearizing $$P_L$$ and $$Q_L$$ : 
- $$\Delta P_L = \frac {\partial P_L}{\partial V}|_{t = 0} \Delta V = P_{L0} m (\frac{V_0}{V_0})^{m-1} \frac{1}{V_0}\Delta V = m \frac{P_{L0}}{V_0}\Delta V$$
- $$\Delta Q_L = \frac {\partial Q_L}{\partial V}|_{t = 0} \Delta V = Q_{L0} n (\frac{V_0}{V_0})^{n-1} \frac{1}{V_0}\Delta V = n \frac{Q_{L0}}{V_0}\Delta V$$
	
Linearizing $$V$$ : 
- $$\Delta V = \frac{\delta V}{\delta v_I}|_{v_I =v_{d0}} \Delta v_I +  \frac{\delta V}{\delta v_R}|_{v_R =v_{q0}} \Delta v_R = \frac{v_{d0}}{V_0}\Delta v_I + \frac{v_{q0}}{V_0}\Delta v_R$$
- $$\frac{\partial V}{\partial v_I}|_{t = 0} \Delta v_I = \frac{1}{2} \frac{2 v_{I0}}{\sqrt{v_{I0}^2 + v_{R0}^2}}\Delta v_I = \frac{v_{I0}}{V_0}\Delta v_I$$
- $$\frac{\partial V}{\partial v_R}|_{t = 0} \Delta v_R = \frac{1}{2} \frac{2 v_{R0}}{\sqrt{v_{I0}^2 + v_{R0}^2}}\Delta v_R = \frac{v_{R0}}{V_0}\Delta v_R$$

If in the current equations $$\Delta i_I$$ ​ and $$\Delta i_R$$ ​, we substitute the values of $$\Delta P_L$$ ​, $$\Delta Q_L$$ ​ and $$\Delta V$$ with the expression of $$\Delta v_I$$ ​ and $$\Delta v_R$$ ​, we obtain an expression for $$\Delta i_I$$ ​ and $$\Delta i_R$$ ​ that only depends on $$\Delta v_I$$ ​ and $$\Delta v_R$$ ​, which allows us to identify the terms of the admittance matrix.
- $$G_{RR} = \frac{P_{L0}}{V_0^2}(1 + \frac{v_{d0}^2}{V_0^2}(m-2)) + \frac{Q_{L0}}{V_0^2}(\frac{v_{q0}v_{d0}}{V_0^2}(n-2))$$
- $$B_{RI} = \frac{Q_{L0}}{V_0^2}(1 + \frac{v_{q0}^2}{V_0^2}(n-2)) + \frac{P_{L0}}{V_0^2}(\frac{v_{q0}v_{d0}}{V_0^2}(m-2))$$
- $$B_{IR} = - \frac{Q_{L0}}{V_0^2}(1 + \frac{v_{d0}^2}{V_0^2}(n-2)) + \frac{P_{L0}}{V_0^2}(\frac{v_{q0}v_{d0}}{V_0^2}(m-2))$$
- $$G_{II} = \frac{P_{L0}}{V_0^2}(1 + \frac{v_{q0}^2}{V_0^2}(m-2)) - \frac{Q_{L0}}{V_0^2}(\frac{v_{q0}v_{d0}}{V_0^2}(n-2))$$
- Note that if have $$n = m = 2$$ , we obtain the equations of a constant impedance (linear) load.