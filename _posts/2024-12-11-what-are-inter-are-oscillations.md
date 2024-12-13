---
layout: post
title:  "What are inter-area oscillations and why are they important?"
date:   2024-12-11 08:54:44 +0200
tag: Analysis
---
{% include welcome_wolf-i.md %}

*In the upcoming blog posts, I will detail the systematic procedure for constructing the linear model of an electrical system. This process follows the method proposed in ["Power System Stability and Control" by Prabha S. Kundur and Om P. Malik.](https://www.accessengineeringlibrary.com/content/book/9781260473544)*

In Europe, inter-area oscillations are a resonance phenomenon that occurs between generating units in different regions of the European continental grid. These units oscillate at low frequencies (typically between 0.1 and 1 Hz), causing fluctuations in various electrical parameters, including active power, voltage, and frequency. 

The most poorly damped inter-area mode in Europe is currently the East-Centre-West inter-area mode, where
oscillations in the Iberian Peninsula and Turkey are out of phase with central Europe.

![alt text]({{ site.baseurl }}/assets/interareaanimation.gif)

The animation demonstrates the evolution of an East-Center-West oscillation pattern across four countries. 
In this context, the chosen measure to represent these oscillations is the **evolution of rotor speed and position**. 

- **Germany (green)**  
- **France (red)**  
- **Spain (blue)**  
- **Turkey (black)**  

Each country's oscillation reflects its phase and amplitude relative to the others:  
- **Germany** oscillates with the **maximum amplitude** and is in **opposite phase** to the other countries.  
- **France** oscillates **in phase** with Spain and Turkey but with a **smaller amplitude**.  
- **Spain and Turkey** exhibit **identical amplitudes** and oscillate perfectly **in phase**.

## Damping Effects on Oscillations

The animation further illustrates how the system behaves under three damping scenarios:  
1. **Zero damping**: Oscillations persist indefinitely, making the system unstable.  
2. **Positive damping**: Oscillations gradually subside, achieving a stable and controllable state.  
3. **Negative damping**: Oscillations grow uncontrollably, leading to system instability and potential failure.  

From an operational perspective, **positive damping** is the desired condition. It ensures that oscillations diminish over time, enabling operators to maintain a **predictable and controllable system**. In contrast, zero or negative damping jeopardizes stability and complicates system management.

These oscillations represent an **exchange of energy** between different areas of the grid. In the example, France, Spain, and Turkey oscillate in sync, collectively exchanging energy with Germany. The amplitude differences highlight the varying levels of participation in this energy exchange. 
