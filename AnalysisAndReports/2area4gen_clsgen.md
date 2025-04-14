# Linear Model of Two-Area Four-Generator System. The simplest one. 

**Description: This script implements the multimachine model of the two-area Kundur system with four generators using the classical model state-space representation for the synchronous machines.** This is the simplest model we can find for the two-area four-generator system, as it uses a synchronous machine model with only two state variables.

The script solves the load flow problem based on the PowerModels.jl package, constructs the linear models of the system and calculates the eigenvalues of the multimachine model. All the scripts and functions used in this example are available in the [SSSinJulia repository](https://github.com/Alejandra-CB/SSSinJulia/tree/main/scr): 
- ``bs_2area4gen.m``: Contains the static data of the network.
- ``ssanalysis.jl``: Implements the functions to solve the load flow problem, create the expanded admittance matrix, and define the linear models of the generators and loads.
    - ``solvelf_pm``: Solves the load flow problem using the PowerModels.jl package.
    - ``ssmatrixclgen.jl``: Implements the classical generator model.
    - ``ymatrix.jl``: Creates the expanded admittance matrix.
    - ``ymatrixload.jl``: Implements the load model.
    - ``IRframe.jl``: Transforms the linear model of the generators from the d-q rotating frame to the I-R frame.   
- ``2area4generator_clsgen.jl``: This script.


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
Y_ex = yexmatrix(data)
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
Y_ex
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





# Linear models of generators
The classical generator model is implemented in the `ssmatrixclgen.jl` function. The theoretical background for this model is provided [here](https://cresym.github.io/WOLF-I/2024/09/02/small-signal-stability-of-multimachine-systems.html).
Each generator's linear model is initially defined in its own d-q rotating frame. It is then transformed to the I-R frame, which is common to all generators. This transformation is handled by the `IRframe.jl` function. The theoretical background for this process can be found [here](https://cresym.github.io/WOLF-I/2024/09/04/small-signal-stability-of-multimachine-systems.html).

```julia
const H1 = 6.5 # Inertia constant of the generators 1 and 3
const H2 = 6.175 # Inertia constant of the generators 2 and 4
const KD = 0 # Damping coefficient
const f = 60 # Nominal frequency
const Ra = 0.0025 # Armature resistance
const Xd = 0.3  # Direct-axis synchronous reactance
const Sbg = 900 # Base power of generators parameters in MVA
A1, B1, C1, D1 = ssmatrixclgen(H1,KD,f,Ra,Xd,result["solution"]["bus"]["1"]["vm"],result["solution"]["bus"]["1"]["va"],result["solution"]["gen"]["1"]["pg"],result["solution"]["gen"]["1"]["qg"],Sb,Sbg)
A2, B2, C2, D2 = ssmatrixclgen(H1,KD,f,Ra,Xd,result["solution"]["bus"]["2"]["vm"],result["solution"]["bus"]["2"]["va"],result["solution"]["gen"]["2"]["pg"],result["solution"]["gen"]["2"]["qg"],Sb,Sbg)
A3, B3, C3, D3 = ssmatrixclgen(H2,KD,f,Ra,Xd,result["solution"]["bus"]["3"]["vm"],result["solution"]["bus"]["3"]["va"],result["solution"]["gen"]["3"]["pg"],result["solution"]["gen"]["3"]["qg"],Sb,Sbg)
A4, B4, C4, D4 = ssmatrixclgen(H2,KD,f,Ra,Xd,result["solution"]["bus"]["4"]["vm"],result["solution"]["bus"]["4"]["va"],result["solution"]["gen"]["4"]["pg"],result["solution"]["gen"]["4"]["qg"],Sb,Sbg)

println("Example of the matrices of the generator 1. In this order: A, B, C, D")
display(A1)
display(B1)
display(C1)
display(D1)
```

```
Example of the matrices of the generator 1. In this order: A, B, C, D
2×2 Matrix{Float64}:
   0.0    -0.288771
 376.991   0.0
2×2 Matrix{Float64}:
  0.224365  -0.177077
 -0.0        0.0
2×2 Matrix{Float64}:
 -0.0  21.1527
  0.0  25.9017
2×2 Matrix{Float64}:
  -0.249983  29.9979
 -29.9979    -0.249983
```





# Golbal matrices of the two-area Kundur system
Now we construct the global matrices for the entire system by combining the linear models of the generators with the expanded admittance matrix (that includes the linear model of loads). The theoretical background for this process can be found [here](https://cresym.github.io/WOLF-I/2024/07/30/small-signal-stability-of-multimachine-systems.html):

```julia
Ad = BlockDiagonal([A1, A2, A3, A4])
Bd = zeros(size(Ad, 1), size(Y_ex, 2))
Cd = zeros(size(Y_ex, 1), size(Ad, 1))
Dd = zeros(size(Y_ex, 1), size(Y_ex, 2))

Bd[2*1-1:2*1, 2*1-1:2*1] .= B1
Bd[2*2-1:2*2, 2*2-1:2*2] .= B2
Bd[2*3-1:2*3, 2*3-1:2*3] .= B3
Bd[2*4-1:2*4, 2*4-1:2*4] .= B4

Cd[2*1-1:2*1, 2*1-1:2*1] .= C1
Cd[2*2-1:2*2, 2*2-1:2*2] .= C2
Cd[2*3-1:2*3, 2*3-1:2*3] .= C3
Cd[2*4-1:2*4, 2*4-1:2*4] .= C4

Dd[2*1-1:2*1, 2*1-1:2*1] .= D1
Dd[2*2-1:2*2, 2*2-1:2*2] .= D2
Dd[2*3-1:2*3, 2*3-1:2*3] .= D3
Dd[2*4-1:2*4, 2*4-1:2*4] .= D4

# Multimachine A matrix of the two-area Kundur system
A = Ad+Bd*((Y_ex-Dd)\Cd)

println("Multimachine A matrix:")
display(A)
```

```
Multimachine A matrix:
8×8 Matrix{Float64}:
   0.0    -0.0686602     0.0    …   0.00353248    0.0     0.00291799
 376.991   0.0           0.0        0.0           0.0     0.0
   0.0     0.0650855     0.0        0.00690358    0.0     0.00746521
   0.0     0.0         376.991      0.0           0.0     0.0
   0.0     0.00663027    0.0       -0.0755119     0.0     0.0587131
   0.0     0.0           0.0    …   0.0           0.0     0.0
   0.0     0.00971995    0.0        0.0645026     0.0    -0.0901967
   0.0     0.0           0.0        0.0         376.991   0.0
```





# Eigenvalues of the multimachine model
We can analyze the system stability by calculating its eigenvalues:
```julia
lambda = eigvals(A)
l = round.(lambda,digits=2)
```

```
8-element Vector{ComplexF64}:
 -0.0 - 7.21im
 -0.0 + 7.21im
  0.0 - 3.41im
  0.0 + 3.41im
  0.0 - 0.0im
  0.0 + 0.0im
  0.0 - 7.4im
  0.0 + 7.4im
```





This completes our linear model of the two-area, four-generator system. The eigenvalues offer insights into the system's stability characteristics.

We can identify three distinct oscillatory modes.

To analyze which generators are affected by each mode, additional small-signal stability analysis is required. We will cover this analysis in future posts.

If you have any comments or would like to contribute, please don't hesitate to get in touch with us! 