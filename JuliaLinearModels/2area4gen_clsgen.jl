# Description: This script implements the multimachine model of the two-area Kundur system with four generators using the classical model state-space representation. The script is based on the PowerModels.jl package and the functions defined in the previous snippets. The script solves the load flow problem based on the PowerModels.jl package, constructs the linear models of the system and calculates the eigenvalues of the multimachine model. 
# The script is divided into several parts: loading the required packages, solving the load flow problem, defining the linear models of generators and loads, creating the expanded admittance matrix, constructing the global matrices of the two-area Kundur system, and calculating the eigenvalues of the multimachine model. The script provides the eigenvalues of the multimachine model as the final output.
using LinearAlgebra
using BlockDiagonals
include("linmodfun.jl")
using .ssmatrix # Import the module ssmatrixclgen.
using .ymatrix # Import the module ymatrix.
using .solvelf # Import the module solvelf.

# Solving the load flow problem.
Sb, result, data = solvelf_pm("bs_2area4gen.m")

# Admittance matrix
Y_ex = yexmatrix(data) # Transpose the admittance matrix

# Linear model of loads
m = 1 # Constant current characteristic
n = 2 # Constant impedance characteristic
# Admittance matrix of the load 1 (at bus 7)
Yl1 = ymatrixload(m,n,result["solution"]["bus"]["7"]["vm"],result["solution"]["bus"]["7"]["va"],data["load"]["1"]["pd"],data["load"]["1"]["qd"])
# Admittance matrix of the load 2 (at bus 9)
Yl2 = ymatrixload(m,n,result["solution"]["bus"]["9"]["vm"],result["solution"]["bus"]["9"]["va"],data["load"]["2"]["pd"],data["load"]["2"]["qd"])
#Add the load admittance matrix to the expanded admittance matrix
Y_ex[2*7-1:2*7, 2*7-1:2*7] += Yl1
Y_ex[2*9-1:2*9, 2*9-1:2*9] += Yl2

# Linear models of generators 1,2,3,4
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

# Golbal matrices of the two-area Kundur system
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

# Multimachine model of the two-area Kundur system
A = Ad+Bd*((Y_ex-Dd)\Cd)

# Eigenvalues of the multimachine model
lambda = eigvals(A)
l = round.(lambda,digits=2)