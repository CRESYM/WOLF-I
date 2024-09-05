---
layout: post
title:  "Small-Signal Stability of Multimachine Systems: A Step-by-Step Guide. Integrating Individual Dynamic Models into a Global Model."
date:   2024-07-30 08:54:44 +0200
categories: linearmodel
---
{% include welcome_wolf-i.md %}

*In the upcoming blog posts, I will detail the systematic procedure for constructing the linear model of an electrical system. This process follows the method proposed in ["Power System Stability and Control" by Prabha S. Kundur and Om P. Malik.](https://www.accessengineeringlibrary.com/content/book/9781260473544)*

- The linearized model of each dynamic device is expressed in the following form :

$$\Delta \dot{x}_i = A_i \Delta x_i + B_i \Delta v_i$$

$$\Delta i_i = C_i \Delta x_i + D_i \Delta v_i$$

- Where:
	- $$\Delta x_i$$ : perturbed values of the individual device state variables.
	- $$\Delta i_i$$ : perturbed value of the current injection into the network from the device.
	- $$\Delta v_i$$ : perturbed value of the network bus voltages.

- Such state equations for all the dynamic devices in the system may be combined into the form :

$$\Delta \dot{x} = A_D \Delta x + B_D \Delta v$$

$$\Delta i = C_D \Delta x + D_D \Delta v$$

- Where :
	- $$\Delta x$$ : state vector of the complete system.
	- $$A_D$$ , $$B_D$$ , $$C_D$$ and $$D_D$$ : block diagonal matrices composed of $$A_i$$ , $$B_i$$ , $$C_i$$ and $$D_i$$ matrices respectively, associated with the individual devices.

- The interconnecting transmission network is represented by the node equation : $$\Delta i = Y_N \Delta v$$
	- The elements of $$Y_N$$ include the effects of nonlinear static loads.
- Hence : $$C_D \Delta x + D_D \Delta v = Y_N \Delta v \rightarrow \Delta v = (Y_N - D_D)^{-1} C_D x \rightarrow \Delta \dot{x} = A_D x + B_D (Y_N - D_D)^{-1} C_D x = Ax$$

$$\rightarrow A = A_D + B_D (Y_N - D_D)^{-1} C_D$$
