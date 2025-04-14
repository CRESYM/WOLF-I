# Description: This script implements the multimachine model of the two-area Kundur system with four generators using the detailed model state-space representation. The script is based on the PowerModels.jl package and the functions defined in the previous snippets. The script solves the load flow problem based on the PowerModels.jl package, constructs the linear models of the system and calculates the eigenvalues of the multimachine model. 
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

# Golbal matrices of the two-area Kundur system
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

# Eigenvalues of the multimachine model
lambda = eigvals(A)
l = round.(lambda,digits=2)