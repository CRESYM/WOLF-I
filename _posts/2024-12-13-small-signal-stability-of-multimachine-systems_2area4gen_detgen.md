---
layout: post
title:  "Small-Signal Stability of Multimachine Systems: Linear Model of Two-Area Four-Generator System."
date:   2024-12-12 08:54:44 +0200
tag: linearmodel
---
{% include welcome_wolf-i.md %}

*In the upcoming blog posts, I will detail the systematic procedure for constructing the linear model of an electrical system. This process follows the method proposed in ["Power System Stability and Control" by Prabha S. Kundur and Om P. Malik.](https://www.accessengineeringlibrary.com/content/book/9781260473544)*

# Linear Model of Two-Area Four-Generator System. Detailed Model of Synchronous Generators. 

**Description: This script implements the multimachine model of the two-area Kundur system with four generators using the detailed model state-space representation.** 

The script solves the load flow problem based on the PowerModels.jl package, constructs the linear models of the system and calculates the eigenvalues of the multimachine model. All the scripts and functions used in this example are available in the [SSSinJulia repository](https://github.com/Alejandra-CB/SSSinJulia/tree/main/scr): 
- ``bs_2area4gen.m``: Contains the static data of the network.
- ``ssanalysis.jl``: Implements the functions to solve the load flow problem, create the expanded admittance matrix, and define the linear models of the generators and loads.
    - ``solvelf_pm``: Solves the load flow problem using the PowerModels.jl package.
    - ``ssmatrixclgen.jl``: Implements the classical generator model.
    - ``ymatrix.jl``: Creates the expanded admittance matrix.
    - ``ymatrixload.jl``: Implements the load model.
    - ``IRframe.jl``: Transforms the linear model of the generators from the d-q rotating frame to the I-R frame.   
- ``2area4generator_detgen.jl``: This script.


The script is divided into several parts: loading the required packages, solving the load flow problem, defining the linear models of generators and loads, creating the expanded admittance matrix, constructing the global matrices of the two-area Kundur system, and calculating the eigenvalues of the multimachine model. The script provides the eigenvalues of the multimachine model as the final output.

## Setup and Package Loading
We start by loading the necessary packages and modules:
```julia
using LinearAlgebra
using BlockDiagonals
include("sssanalysis.jl")
using .ssmatrix # Import the module ssmatrixclgen.
using .ymatrix # Import the module ymatrix.
using .solvelf # Import the module solvelf.
```




# Solving the load flow problem.
The load flow solution provides the equilibrium point from which we will calculate linear models of the generators and loads.
To calculate the load flow, we first needed to define the static data of the network in the file `bs_2area4gen.m`.
The function `solvelf_pm` is used to solve the load flow problem with the `PowerModels.jl` package ([documentation](https://lanl-ansi.github.io/PowerModels.jl/stable/)).

```julia
Sb, result, data = solvelf_pm("bs_2area4gen.m")
```




# Admittance matrix
Next, we create the expanded admittance matrix:
```julia
Y_ex = yexmatrix(data) # Transpose the admittance matrix
```

```
22×22 Matrix{Float64}:
   0.0    -60.241   0.0      0.0    …     0.0        0.0       0.0
  60.241    0.0     0.0      0.0          0.0        0.0       0.0
   0.0      0.0     0.0    -60.241        0.0        0.0       0.0
   0.0      0.0    60.241    0.0          0.0        0.0       0.0
   0.0      0.0     0.0      0.0          0.0        0.0      60.241
   0.0      0.0     0.0      0.0    …     0.0      -60.241     0.0
   0.0      0.0     0.0      0.0         60.241      0.0       0.0
   0.0      0.0     0.0      0.0          0.0        0.0       0.0
   0.0     60.241   0.0      0.0          0.0        0.0       0.0
 -60.241    0.0     0.0      0.0          0.0        0.0       0.0
   ⋮                                ⋱                ⋮       
   0.0      0.0     0.0      0.0          0.0        0.0       0.0
   0.0      0.0     0.0      0.0          0.0        0.0       0.0
   0.0      0.0     0.0      0.0    …     0.0        0.0       0.0
   0.0      0.0     0.0      0.0         99.0099     0.0       0.0
   0.0      0.0     0.0      0.0         -9.90099    0.0       0.0
   0.0      0.0     0.0      0.0       -198.824     -3.9604   39.604
   0.0      0.0     0.0      0.0         13.8614   -39.604    -3.9604
   0.0      0.0     0.0      0.0    …    39.604      3.9604  -99.823
   0.0      0.0     0.0      0.0         -3.9604    99.823     3.9604
```





# Linear model of loads
We model the loads using constant current (m=1) and constant impedance (n=2) characteristics. The load admittance matrix is then added to the expanded admittance matrix. The load model is implemented in the `ymatrixload.jl` function, and the theoretical background is provided at [this link](https://cresym.github.io/WOLF-I/2024/08/30/small-signal-stability-of-multimachine-systems.html).

```julia
m = 1 # Constant current characteristic
n = 2 # Constant impedance characteristic
# Admittance matrix of the load 1 (at bus 7)
Yl1 = ymatrixload(m,n,result["solution"]["bus"]["7"]["vm"],result["solution"]["bus"]["7"]["va"],data["load"]["1"]["pd"],data["load"]["1"]["qd"])
# Admittance matrix of the load 2 (at bus 9)
Yl2 = ymatrixload(m,n,result["solution"]["bus"]["9"]["vm"],result["solution"]["bus"]["9"]["va"],data["load"]["2"]["pd"],data["load"]["2"]["qd"])
#Add the load admittance matrix to the expanded admittance matrix
Y_ex[2*7-1:2*7, 2*7-1:2*7] += Yl1
Y_ex[2*9-1:2*9, 2*9-1:2*9] += Yl2
```

```
2×2 Matrix{Float64}:
  26.9971  -107.134
 121.606     15.1244
```





# Linear models of generators
The detailed generator model is implemented in the `ssmatrixgen1d2q.jl` function. The theoretical background for this model is provided [here](https://cresym.github.io/WOLF-I/2024/12/13/small-signal-stability-of-multimachine-systems.html).
Each generator's linear model is initially defined in its own d-q rotating frame. It is then transformed to the I-R frame, which is common to all generators. This transformation is handled by the `IRframe.jl` function. The theoretical background for this process can be found [here](https://cresym.github.io/WOLF-I/2024/09/04/small-signal-stability-of-multimachine-systems.html).

```julia
H1 = 6.5 # Inertia constant of the generators 1 and 3
H2 = 6.175 # Inertia constant of the generators 2 and 4
KD = 0 # Damping coefficient
f = 60 # Nominal frequency
Ra = 0.0025 # Armature resistance
Xd = 1.8  # Direct-axis synchronous reactance
Xdp = 0.3 # Direct-axis transient reactance
Xq = 1.7 # Quadrature-axis synchronous reactance
Xqp = 0.55 # Quadrature-axis transient reactance
Xdpp = 0.25 # Direct-axis subtransient reactance
Xqpp = 0.25 # Quadrature-axis subtransient reactance
Xl = 0.2 # Leakage reactance
Td0p = 8 # Direct-axis transient open-circuit time constant
Tq0p = 0.4 # Quadrature-axis transient open-circuit time constant
Td0pp = 0.03 # Direct-axis subtransient open-circuit time constant
Tq0pp = 0.05 # Quadrature-axis subtransient open-circuit time constant
Sbg = 900 # Base power of generators parameters in MVA
A1, B1, C1, D1 = ssmatrixgen1d2q(H1,KD,f,Ra,Xd,Xq,Xl,Xdp,Xqp,Xdpp,Xqpp,Td0p,Tq0p,Td0pp,Tq0pp,result["solution"]["bus"]["1"]["vm"],result["solution"]["bus"]["1"]["va"],result["solution"]["gen"]["1"]["pg"],result["solution"]["gen"]["1"]["qg"],Sb,Sbg)
A2, B2, C2, D2 = ssmatrixgen1d2q(H1,KD,f,Ra,Xd,Xq,Xl,Xdp,Xqp,Xdpp,Xqpp,Td0p,Tq0p,Td0pp,Tq0pp,result["solution"]["bus"]["2"]["vm"],result["solution"]["bus"]["2"]["va"],result["solution"]["gen"]["2"]["pg"],result["solution"]["gen"]["2"]["qg"],Sb,Sbg)
A3, B3, C3, D3 = ssmatrixgen1d2q(H2,KD,f,Ra,Xd,Xq,Xl,Xdp,Xqp,Xdpp,Xqpp,Td0p,Tq0p,Td0pp,Tq0pp,result["solution"]["bus"]["3"]["vm"],result["solution"]["bus"]["3"]["va"],result["solution"]["gen"]["3"]["pg"],result["solution"]["gen"]["3"]["qg"],Sb,Sbg)
A4, B4, C4, D4 = ssmatrixgen1d2q(H2,KD,f,Ra,Xd,Xq,Xl,Xdp,Xqp,Xdpp,Xqpp,Td0p,Tq0p,Td0pp,Tq0pp,result["solution"]["bus"]["4"]["vm"],result["solution"]["bus"]["4"]["va"],result["solution"]["gen"]["4"]["pg"],result["solution"]["gen"]["4"]["qg"],Sb,Sbg)
```

```
([0.0 -0.34974590854237 … -0.025898409722745267 -0.20268320652583258; 376.9
9111843077515 0.0 … 0.0 0.0; … ; 0.0 -1.5898411019477947 … -9.7754867370405
77 7.347122430614078; 0.0 -20.77392373211786 … 12.26697330266973 -43.997600
23997601], [0.35120799000742503 0.0034684291315465188; 0.0 0.0; … ; 1.80644
55955738077 -1.152446053907153; 23.6042224488311 -15.058628437720145], [-0.
0 0.3952184935555524 … 2.186547232309129 17.11210877459319; 0.0 39.03667106
336945 … 3.280789416140824 25.675743256754284], [-0.3599640035996394 35.996
400359964014; -35.996400359964 -0.359964003599643])
```





# Golbal matrices of the two-area Kundur system
Now we construct the global matrices for the entire system by combining the linear models of the generators with the expanded admittance matrix (that includes the linear model of loads). The theoretical background for this process can be found [here](https://cresym.github.io/WOLF-I/2024/07/30/small-signal-stability-of-multimachine-systems.html):

```julia
Ad = BlockDiagonal([A1, A2, A3, A4])
Bd = zeros(size(Ad, 1), size(Y_ex, 2))
Cd = zeros(size(Y_ex, 1), size(Ad, 1))
Dd = zeros(size(Y_ex, 1), size(Y_ex, 2))

Bd[6*1-5:6*1, 2*1-1:2*1] .= B1
Bd[6*2-5:6*2, 2*2-1:2*2] .= B2
Bd[6*3-5:6*3, 2*3-1:2*3] .= B3
Bd[6*4-5:6*4, 2*4-1:2*4] .= B4

Cd[2*1-1:2*1, 6*1-5:6*1] .= C1
Cd[2*2-1:2*2, 6*2-5:6*2] .= C2
Cd[2*3-1:2*3, 6*3-5:6*3] .= C3
Cd[2*4-1:2*4, 6*4-5:6*4] .= C4

Dd[2*1-1:2*1, 2*1-1:2*1] .= D1
Dd[2*2-1:2*2, 2*2-1:2*2] .= D2
Dd[2*3-1:2*3, 2*3-1:2*3] .= D3
Dd[2*4-1:2*4, 2*4-1:2*4] .= D4

# Multimachine model of the two-area Kundur system
A = Ad+Bd*((Y_ex-Dd)\Cd)
```

```
24×24 Matrix{Float64}:
   0.0    -0.0755969   -0.0420278   …   0.000902588    0.00706373
 376.991   0.0          0.0             0.0            0.0
   0.0    -0.0972545   -1.10974         0.00109585     0.00857619
   0.0    -3.24182     29.6754          0.0365282      0.285873
   0.0    -0.231835    -0.0393418       0.00299739     0.0234579
   0.0    -3.02931     -0.514066    …   0.0391659      0.306516
   0.0     0.070786     0.0195065       0.00149938     0.0117343
   0.0     0.0          0.0             0.0            0.0
   0.0     0.0435157    0.0438495       0.00155826     0.0121951
   0.0     1.45052      1.46165         0.051942       0.406503
   ⋮                                ⋱                
   0.0     0.126199     0.213785    …   0.0868385      0.679606
   0.0     0.0334136   -0.00699054      0.0397673      0.311222
   0.0     0.436605    -0.091343        0.519626       4.06664
   0.0     0.00983517   0.00460219     -0.00402562    -0.0315049
   0.0     0.0          0.0             0.0            0.0
   0.0     0.00428641   0.0102282   …   0.00233853     0.0183016
   0.0     0.14288      0.340939        0.0779511      0.610052
   0.0     0.056657    -0.00220576     -9.62283        8.54183
   0.0     0.740319    -0.0288219      14.2617       -28.3867
```





# Eigenvalues of the multimachine model
We can analyze the system stability by calculating its eigenvalues:
```julia
lambda = eigvals(A)
l = round.(lambda,digits=2)
```

```
24-element Vector{ComplexF64}:
 -37.23 + 0.0im
 -37.15 + 0.0im
 -36.21 + 0.0im
 -36.04 + 0.0im
  -34.8 + 0.0im
 -33.41 + 0.0im
 -30.39 + 0.0im
 -28.89 + 0.0im
   -4.7 + 0.0im
  -4.66 + 0.0im
        ⋮
  -0.58 + 6.79im
  -0.17 + 0.0im
  -0.17 + 0.0im
  -0.12 - 3.43im
  -0.12 + 3.43im
  -0.04 + 0.0im
   -0.0 + 0.0im
    0.0 + 0.0im
    0.0 + 0.0im
```


