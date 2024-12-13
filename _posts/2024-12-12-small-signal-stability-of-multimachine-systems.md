---
layout: post
title:  "Small-Signal Stability of Multimachine Systems: A Step-by-Step Guide. Generator represented by the detailed model."
date:   2024-12-12 08:54:44 +0200
tag: linearmodel
---
{% include welcome_wolf-i.md %}

*In the upcoming blog posts, I will detail the systematic procedure for constructing the linear model of an electrical system. This process follows the method proposed in ["Power System Stability and Control" by Prabha S. Kundur and Om P. Malik.](https://www.accessengineeringlibrary.com/content/book/9781260473544)*

*In p.u.*
We are looking for a representation :

$$\Delta \dot{x}_i = A_i \Delta x_i + B_i \Delta v$$

$$\Delta i_i = C_i \Delta x_i + D_i \Delta v$$

- Where : $$\Delta v = \begin{bmatrix}\Delta v_{d} \\\Delta v_{q} \end{bmatrix}$$ ; $$\Delta i_i = \begin{bmatrix}\Delta i_{d} \\\Delta i_{q} \end{bmatrix}$$ .
In order to obtain the state-space representation matrices $$A_i$$ , $$B_i$$ , $$C_i$$ and $$D_i$$ , we consider the stator voltage equations and the equations of motion.

# The rotor circuit equations

$$p \psi_{fd} = \frac{\omega_0 R_{fd}}{X_{ad}} E_{fd} - \omega_0 R_{fd} i_{fd}$$

$$p \psi_{1d} = -\omega_0 R_{1d} i_{1d}$$

$$p \psi_{1q} = -\omega_0 R_{1q} i_{1q}$$

$$p \psi_{2q} = -\omega_0 R_{2q} i_{2q}$$

- The rotor currents are given by :
    $$i_{fd} = \frac{1}{X_{fd}}(\psi_{fd} - \psi_{ad})$$

    $$i_{1d} = \frac{1}{X_{1d}}(\psi_{1d} - \psi_{ad})$$
    
    $$i_{1q} = \frac{1}{X_{1q}}(\psi_{1q} - \psi_{aq})$$
    
    $$i_{2q} = \frac{1}{X_{2q}}(\psi_{2q} - \psi_{aq})$$

- The d- and q-axis mutual flux linkages are given by:
    $$\psi_{ad} = -X_{ad}i_d + X_{ad}i_{fd}+X_{ad}i_{1d} = xaux_d (-i_d + \frac{\psi_{fd}}{X_{fd}}+\frac{\psi_{1d}}{X_{1d}})$$
    
    $$\psi_{aq} = -X_{aq}i_q + X_{aq}i_{1q}+X_{aq}i_{2q} = xaux_q (-i_q + \frac{\psi_{1q}}{X_{1q}}+\frac{\psi_{2q}}{X_{2q}})$$
    
    $$xaux_d = \frac{1}{\frac{1}{X_{ad}} + \frac{1}{X_{fd}}+ \frac{1}{X_{1d}}}$$
    
    $$xaux_q = \frac{1}{\frac{1}{X_{aq}} + \frac{1}{X_{1q}}+ \frac{1}{X_{2q}}}$$

- Linearizing the previous equations and considering $$\Delta E_{fd} = 0$$ :
    
    $$\Delta \psi_{ad} = xaux_d (-\Delta i_d + \frac{\Delta \psi_{fd}}{X_{fd}}+\frac{\Delta \psi_{1d}}{X_{1d}})$$
    
    $$\Delta \psi_{aq} = xaux_q (-\Delta i_q + \frac{\Delta \psi_{1q}}{X_{1q}}+\frac{\Delta \psi_{2q}}{X_{2q}})$$
    
    $$\Delta i_{fd} = \frac{1}{X_{fd}}(\Delta \psi_{fd} - \Delta \psi_{ad}) = \frac{1}{X_{fd}}(\Delta \psi_{fd} - xaux_d (-\Delta i_d + \frac{\Delta \psi_{fd}}{X_{fd}}+\frac{\Delta \psi_{1d}}{X_{1d}}))$$
    
    $$\Delta i_{1d} = \frac{1}{X_{1d}}(\Delta \psi_{1d} - \Delta \psi_{ad}) = \frac{1}{X_{1d}}(\Delta \psi_
    {1d} - xaux_d (-\Delta i_d + \frac{\Delta \psi_{fd}}{X_{fd}}+\frac{\Delta \psi_{1d}}{X_{1d}}))$$
    
    $$\Delta i_{1q} = \frac{1}{X_{1q}}(\Delta \psi_{1q} - \Delta \psi_{aq}) = \frac{1}{X_{1q}}(\Delta \psi_{1q} - xaux_q (-\Delta i_q + \frac{\Delta \psi_{1q}}{X_{1q}}+\frac{\Delta \psi_{2q}}{X_{2q}}))$$
    
    $$\Delta i_{2q} = \frac{1}{X_{2q}}(\Delta \psi_{2q} - \Delta \psi_{aq}) =  \frac{1}{X_{2q}}(\Delta \psi_{2q} - xaux_q (-\Delta i_q + \frac{\Delta \psi_{1q}}{X_{1q}}+\frac{\Delta \psi_{2q}}{X_{2q}}))$$
    
    $$\Delta \dot \psi_{fd} = \frac{\omega_0 R_{fd}}{X_{ad}} \Delta E_{fd} - \omega_0 R_{fd} \Delta i_{fd} = -\omega_0 R_{fd} \frac{1}{X_{fd}}(\Delta \psi_{fd} - xaux_d (-\Delta i_d + \frac{\Delta \psi_{fd}}{X_{fd}}+\frac{\Delta \psi_{1d}}{X_{1d}}))$$
    
    $$\Delta \dot \psi_{1d} = -\omega_0 R_{1d} \Delta i_{1d} =  -\omega_0 R_{1d}  \frac{1}{X_{1d}}(\Delta \psi_{1d} - xaux_d (-\Delta i_d + \frac{\Delta \psi_{fd}}{X_{fd}}+\frac{\Delta \psi_{1d}}{X_{1d}}))$$
    
    $$\Delta \dot \psi_{1q} = -\omega_0 R_{1q} \Delta i_{1q} = -\omega_0 R_{1q} \frac{1}{X_{1q}}(\Delta \psi_{1q} - xaux_q (-\Delta i_q + \frac{\Delta \psi_{1q}}{X_{1q}}+\frac{\Delta \psi_{2q}}{X_{2q}}))$$
    
    $$\Delta \dot \psi_{2q} = -\omega_0 R_{2q} \Delta i_{2q} = -\omega_0 R_{2q}\frac{1}{X_{2q}}(\Delta \psi_{2q} - xaux_q (-\Delta i_q + \frac{\Delta \psi_{1q}}{X_{1q}}+\frac{\Delta \psi_{2q}}{X_{2q}}))$$
    
# The stator voltage equations

$$v_d = -R_a i_d + X_l i_q - \psi_{ad}$$

$$v_q = -R_a i_q - X_l i_d + \psi_{aq}$$

- Linearizing the previous equations:
    
    $$\Delta v_d = -R_a \Delta i_d + X_l \Delta i_q - \Delta \psi_{aq} = -R_a \Delta i_d + X_l \Delta i_q - xaux_q (-\Delta i_q + \frac{\Delta \psi_{1q}}{X_{1q}}+\frac{\Delta \psi_{2q}}{X_{2q}})$$
    $$\Delta v_q = -R_a \Delta i_q - X_l \Delta i_d + \Delta \psi_{ad} = -R_a \Delta i_q - X_l \Delta i_d +  xaux_d (-\Delta i_d + \frac{\Delta \psi_{fd}}{X_{fd}}+\frac{\Delta \psi_{1d}}{X_{1d}})$$

# The swing equation

$$p \omega_r = \frac{1}{2H}(T_m - T_e)$$

$$T_e = \psi_d i_q - \psi_q i_d = \psi_{ad} i_q - \psi_{aq} i_d$$

- Linearizing the previous equations and adding a term to account for the damping:
    
    $$\Delta T_e = i_{q0} \Delta \psi_{ad} + \psi_{ad0} \Delta i_q - i_{d0} \Delta \psi_{aq} - \psi_{aq0} \Delta i_d = i_{q0}xaux_d (-\Delta i_d + \frac{\Delta \psi_{fd}}{X_{fd}}+\frac{\Delta \psi_{1d}}{X_{1d}})+ \psi_{ad0} \Delta i_q - i_{d0}xaux_q (-\Delta i_q + \frac{\Delta \psi_{1q}}{X_{1q}}+\frac{\Delta \psi_{2q}}{X_{2q}}) - \psi_{aq0} \Delta i_d$$
    
    $$\Delta \dot \omega_r = \frac{1}{2H}(\Delta T_m - \Delta T_e - K_D \Delta \omega_r)$$

# Arranging the previous equations to assemble the state space equations:

$$a_{11} = -\frac{K_D}{2H}$$

$$a_{12} = 0$$

$$a_{13} = - \frac{1}{2H} \frac{i_{q0}xaux_d}{X_{fd}}$$

$$a_{14} = -\frac{1}{2H}\frac{i_{q0}xaux_d}{X_{1d}}$$

$$a_{15} = -\frac{1}{2H} \frac {-i_{d0} xaux_q}{X_{1q}}$$

$$a_{16} = -\frac{1}{2H} \frac{-i_{d0}xaux_q}{X_{2q}}$$

$$a_{21} = \omega_0$$

$$a_{22} = 0$$

$$a_{23} = 0$$

$$a_{24} = 0$$

$$a_{25} = 0$$

$$a_{26} = 0$$

$$a_{31} = 0$$

$$a_{32} = 0$$

$$a_{33} = -\omega_0 R_{fd} \frac{1}{X_{fd}}(1-\frac{xaux_d}{X_{fd}})$$

$$a_{34} = -\omega_0 R_{fd} \frac{1}{X_{fd}}(-\frac{xaux_d}{X_{1d}})$$

$$a_{35} = 0$$

$$a_{36} = 0$$

$$a_{41} = 0$$

$$a_{42} = 0$$

$$a_{43} = -\omega_0 R_{1d}  \frac{1}{X_{1d}}(- \frac{xaux_d}{X_{fd}})$$

$$a_{44} = -\omega_0 R_{1d}  \frac{1}{X_{1d}}(1- \frac{xaux_d}{X_{1d}})$$

$$a_{45} = 0$$

$$a_{46} =0$$

$$a_{51} =0$$

$$a_{52} = 0$$

$$a_{53} = 0$$

$$a_{54} = 0$$

$$a_{55} = -\omega_0 R_{1q} \frac{1}{X_{1q}}(1 - \frac{xaux_q}{x_{1q}})$$

$$a_{56} =  -\omega_0 R_{1q} \frac{1}{X_{1q}}(- \frac{xaux_q}{x_{2q}})$$

$$a_{61} = 0$$

$$a_{62} =0$$

$$a_{63} = 0$$

$$a_{64} = 0$$

$$a_{65} = -\omega_0 R_{2q}\frac{1}{X_{2q}} (\frac{-xaux_q}{X_{1q}})$$

$$a_{66} = -\omega_0 R_{2q}\frac{1}{X_{2q}} (1 - \frac{xaux_q}{X_{2q}})$$

$$b_{11} = \frac{-1}{2H} (-\psi_{aq0} - i_{q0}xaux_d)$$

$$b_{12} = \frac{-1}{2H} (\psi_{ad0} + i_{d0}xaux_q)$$

$$b_{21} = 0$$

$$b_{22} = 0$$

$$b_{31} = -\omega_0 R_{fd} \frac{xaux_d}{X_{fd}}$$

$$b_{32} = 0$$

$$b_{41} = -\omega_0 R_{1d}  \frac{xaux_d}{X_{1d}}$$

$$b_{42} = 0$$

$$b_{51} = 0$$

$$b_{52} = -\omega_0 R_{1q} \frac{xaux_q}{X_{1q}}$$

$$b_{61} = 0$$

$$b_{62} = -\omega_0 R_{2q} \frac{xaux_q}{X_{2q}}$$

$$c_{11} = 0$$

$$c_{12} = 0$$

$$c_{13} = 0$$

$$c_{14} = 0$$

$$c_{15} = \frac{- xaux_q}{x_{1q}}$$

$$c_{16} =  \frac{-xaux_q}{x_{2q}}$$
$$c_{21} = 0$$

$$c_{22} = 0$$

$$c_{23} = \frac{xaux_d}{X_{fd}}$$

$$c_{24} = \frac{xaux_d}{X_{1d}}$$

$$c_{25} = 0$$

$$c_{26} = 0$$

$$d_{11} = -R_a$$

$$d_{12} = X_l + xaux_q$$

$$d_{21} = -X_l - xaux_d$$

$$d_{22} = -R_a$$
