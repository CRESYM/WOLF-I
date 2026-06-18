# Core packages
using LinearAlgebra
using Symbolics
using SymbolicUtils
using BlockDiagonals
using PowerModels
using DataFrames

module symbolictools
using ..Symbolics
using ..SymbolicUtils
export convert_to_rational
# Converts Float64s into Rational{BigInt}
convert_to_rational = SymbolicUtils.Prewalk(x -> 
    (x isa Float64 && !(x isa Bool)) ? Rational{BigInt}(rationalize(x)) : x)

# Simplify small coefficients
convert_to_simplify = SymbolicUtils.Prewalk(x -> 
    (x isa Float64 && !(x isa Bool) && (abs(x) < 1e-8)) ? 0.0 : x)
end # module simplifysim

# Controllability and observability factors
module contobsfac
using ..Symbolics
using ..PowerModels
export obsfac, confac
function confac(result, var, n, ndif, jbus) 
    vm = result["solution"]["bus"][string(jbus)]["vm"]
    vr = vm*cos(result["solution"]["bus"][string(jbus)]["va"])
    vi = vm*sin(result["solution"]["bus"][string(jbus)]["va"])
    if var == "P"
        cfac0 = 1/vm^2*[vi; vr]
    elseif var == "Q"
        cfac0 = 1/vm^2*[-vr; vi]
    else 
        error("Variable not recognized")
    end

    cfac = zeros(Num,n) 
    cfac[ndif+2*jbus-1:ndif+2*jbus] = cfac0
    return cfac
end # function

function find_branch_between_buses(data, bus1, bus2)
    for (branch_id, branch_data) in data["branch"]
        f_bus = branch_data["f_bus"]
        t_bus = branch_data["t_bus"]
        
        if f_bus == bus1 && t_bus == bus2
            return parse(Int, branch_id), 1
        elseif f_bus == bus2 && t_bus == bus1
            return parse(Int, branch_id), -1
        end
    end
    return nothing, nothing  # No se encontró la rama
end

function obsfac(result, data, Yl, var, n, ndif, jbus; kbus=0) 
    vm = result["solution"]["bus"][string(jbus)]["vm"]
    vr = vm*cos(result["solution"]["bus"][string(jbus)]["va"])
    vi = vm*sin(result["solution"]["bus"][string(jbus)]["va"])
    if var == "iabs" || var == "p" || var == "q" || var == "s" || var == "u"
        if kbus != 0
            vmk = result["solution"]["bus"][string(kbus)]["vm"]
            vrk = vmk*cos(result["solution"]["bus"][string(kbus)]["va"])
            vik = vmk*sin(result["solution"]["bus"][string(kbus)]["va"])
            branch_id, branch_k = find_branch_between_buses(data, jbus, kbus)
            yj = 1/(data["branch"][string(branch_id)]["br_r"] + 1im*data["branch"][string(branch_id)]["br_x"]) 
            gjk = real(yj)
            bjk = imag(yj) 
            gj = sqrt(Yl[jbus][1, 1]^2 + Yl[jbus][2, 2]^2)
            bj = data["branch"][string(branch_id)]["b_to"] +  sqrt(Yl[jbus][1, 2]^2 + Yl[jbus][2, 1]^2)
            pg = branch_k*result["solution"]["branch"][string(branch_id)]["pt"] 
            qg = branch_k*result["solution"]["branch"][string(branch_id)]["qt"] 
            i = conj((pg + 1im*qg)/(vm))
            iabs = abs(i)
        else
            error("kbus must be different from 0 for P, Q or s")
        end
    end

    if var == "v"
        ofac0 = 1/vm*[vi ; vr]
    elseif var == "θ" || var == "f"
        ofac0 = 1/vm^2*[vr ; -vi]
    elseif var == "iabs"
        c1 = 1/iabs*(((bj + bjk)^2 + (gj + gjk)^2)*vi + (-(bj + bjk)*bjk - (gj + gjk)*gjk)*vik + (bj*gjk - gj*bjk)*vrk)
        c2 = 1/iabs*(((gj + gjk)^2 + (bj + bjk)^2)*vr + (-(gj + gjk)*gjk - (bj + bjk)*bjk)*vrk + (gj*bjk - bj*gjk)*vik)
        c3 = 1/iabs*((-bjk*(bj + bjk) - gjk*(gj + gjk))*vi + (bj*gjk - gj*bjk)*vr + (bjk^2+gjk^2)*vik)
        c4 = 1/iabs*((-gjk*(gj + gjk) - bjk*(bj + bjk))*vr + (gjk*bj - bjk*gj)*vi + (bjk^2+gjk^2)*vrk)
        ofac0 = [c1 ; c2 ; c3 ; c4]'
    elseif var == "p"
        c1 = 2*(gj + gjk)*vi - gjk*vik - bjk*vrk 
        c2 = 2*(gj + gjk)*vr - gjk*vrk + bjk*vik
        c3 = -gjk*vi + bjk*vr 
        c4 = -gjk*vr - bjk*vi
        ofac0 = [c1 ; c2 ; c3 ; c4]
    elseif var == "q"
        c1 = -2*(bj + bjk)*vi - gjk*vrk + bjk*vik 
        c2 = -2*(bj + bjk)*vr + bjk*vrk + gjk*vik
        c3 = +bjk*vi + gjk*vr
        c4 = +bjk*vr - gjk*vi
        ofac0 = [c1 ; c2 ; c3 ; c4]
    elseif var == "s"
        sg = sqrt(pg^2 + qg^2)
        c1p = 2*(gj + gjk)*vi - gjk*vik - bjk*vrk 
        c2p = 2*(gj + gjk)*vr - gjk*vrk + bjk*vik
        c3p = -gjk*vi + bjk*vr 
        c4p = -gjk*vr - bjk*vi
        op = [c1p ; c2p ; c3p ; c4p]
        
        c1q = -2*(bj + bjk)*vi - gjk*vrk + bjk*vik 
        c2q = -2*(bj + bjk)*vr + bjk*vrk + gjk*vik
        c3q = +bjk*vi + gjk*vr
        c4q = +bjk*vr - gjk*vi
        oq = [c1q ; c2q ; c3q ; c4q]

        ofac0 = pg/sg*op + qg/sg*oq
    elseif var == "u"
                c1p = 2*(gj + gjk)*vi - gjk*vik - bjk*vrk 
        c2p = 2*(gj + gjk)*vr - gjk*vrk + bjk*vik
        c3p = -gjk*vi + bjk*vr 
        c4p = -gjk*vr - bjk*vi
        op = [c1p ; c2p ; c3p ; c4p]
        
        c1q = -2*(bj + bjk)*vi - gjk*vrk + bjk*vik 
        c2q = -2*(bj + bjk)*vr + bjk*vrk + gjk*vik
        c3q = +bjk*vi + gjk*vr
        c4q = +bjk*vr - gjk*vi
        oq = [c1q ; c2q ; c3q ; c4q]

        ov = 1/vm*[vi ; vr; 0; 0]

        ofac0 = -1000*ov + 165*op + 41*oq
    else
        error("Variable not recognized")
    end

    ofac = zeros(Num,n)
    ofac[ndif+2*jbus-1:ndif+2*jbus] = ofac0[1:2]

    if kbus != 0
        ofac[ndif+2*kbus-1:ndif+2*kbus] = ofac0[3:4]
    end

    return ofac'
end # function
end # module

module buildsystem 
using ..Symbolics
using ..BlockDiagonals
using ..PowerModels
using ..symbolictools
export system_cl, explicitsystem_cl, yexmatrixsym, implicitsystem_ol
function yexmatrixsym(data, result, jload, m, n)
    # Admittance matrix
    Y = sym_admittance_matrix(data).matrix 
    # Expanded admittance matrix to real and imaginary parts [YII YIR; YRI YRR]
    Yreal = real(Y)
    Yimag = imag(Y)
    Y_ex = zeros(Num, 2*size(Y, 1), 2*size(Y, 2)) # Preallocate the expanded matrix
    Y_ex[1:2:end, 1:2:end] .= Yreal # Fill the real part of the expanded matrix
    Y_ex[2:2:end, 2:2:end] .= Yreal # Fill the real part of the expanded matrix
    Y_ex[1:2:end, 2:2:end] .= Yimag # Fill the imaginary part of the expanded matrix
    Y_ex[2:2:end, 1:2:end] .= -Yimag # Fill the imaginary part of the expanded matrix

    nb = length(data["bus"])
    Yl = Dict{Int, Matrix{Float64}}(i => zeros(2,2) for i in 1:nb) # Dictionary to store the load admittance matrices
    # Linear model of loads
    for j in jload
        vm = result["solution"]["bus"][string(j)]["vm"]
        va = result["solution"]["bus"][string(j)]["va"]
        PL0 = data["load"][string(j)]["pd"]
        QL0 = data["load"][string(j)]["qd"]
        Yl[j] = ymatrixload(m, n, vm, va, PL0, QL0)
        # Add the load admittance matrix to the expanded admittance matrix
        Y_ex[2*j-1:2*j, 2*j-1:2*j] += Yl[j]
    end

    return Y_ex, Yl
end

# Function for creating the load admittance matrix.
function ymatrixload(m,n,vm,va,PL0,QL0)
    vR = vm*cos(va)
    vI = vm*sin(va)
    BIR = QL0/vm^2*((n-2)vR^2/vm^2+1) - PL0/vm^2*((m-2)vR*vI/vm^2)
    GII = PL0/vm^2*((m-2)vI^2/vm^2+1) - QL0/vm^2*((n-2)vR*vI/vm^2)
    GRR = PL0/vm^2*((m-2)vR^2/vm^2+1) + QL0/vm^2*((n-2)vR*vI/vm^2)
    BRI = QL0/vm^2*((n-2)vI^2/vm^2+1) + PL0/vm^2*((m-2)vR*vI/vm^2)


    YL = [GII -BIR ; BRI GRR]
    return YL
end 

struct AdmittanceMatrix{T}
    idx_to_bus::Vector{Int}
    bus_to_idx::Dict{Int,Int}
    matrix::Matrix{T}
end

function sym_admittance_matrix(data::Dict{String,<:Any})
    buses = [x.second for x in data["bus"] if (x.second[PowerModels.pm_component_status["bus"]] != PowerModels.pm_component_status_inactive["bus"])]
    sort!(buses, by=x->x["index"])

    idx_to_bus = [x["index"] for x in buses]
    bus_to_idx = Dict(x["index"] => i for (i,x) in enumerate(buses))

    n = length(idx_to_bus)
    m = zeros(Complex{Num},n,n)

    for (i,branch) in data["branch"]
        f_bus = branch["f_bus"]
        t_bus = branch["t_bus"]
        if branch[PowerModels.pm_component_status["branch"]] != PowerModels.pm_component_status_inactive["branch"] && haskey(bus_to_idx, f_bus) && haskey(bus_to_idx, t_bus)
            f_bus = bus_to_idx[f_bus]
            t_bus = bus_to_idx[t_bus]
            y = inv(branch["br_r"] + branch["br_x"]im)
            tr, ti = PowerModels.calc_branch_t(branch)
            t = tr + ti*1im
            lc_fr = branch["g_fr"] + branch["b_fr"]im
            lc_to = branch["g_to"] + branch["b_to"]im
            m[f_bus, t_bus] += -y/conj(t)
            m[t_bus, f_bus] += -(y/t)
            m[f_bus, f_bus] += (y + lc_fr)/(t * conj(t))
            m[t_bus, t_bus] += (y + lc_to)

        end
    end

    for (i,shunt) in data["shunt"]
        shunt_bus = shunt["shunt_bus"]
        if shunt[PowerModels.pm_component_status["shunt"]] != PowerModels.pm_component_status_inactive["shunt"] && haskey(bus_to_idx, shunt_bus)
            bus = bus_to_idx[shunt_bus]

            ys = shunt["gs"] + shunt["bs"]im

            m[bus, bus] += ys
        end
    end

    return AdmittanceMatrix(idx_to_bus, bus_to_idx, m)
end

function system_cl(Y_ex, A1, A2, B1, B2, C1, C2, D1, D2,Bk,Ck,iinp)
    @variables k 

    Ad = BlockDiagonal([A1, A2])
    Bd = zeros(Num,size(Ad, 1), size(Y_ex, 2))
    Cd = zeros(Num,size(Y_ex, 1), size(Ad, 1))
    Dd = zeros(Num,size(Y_ex, 1), size(Y_ex, 2))

    Bd[2*1-1:2*1, 2*1-1:2*1] .= B1
    Bd[2*2-1:2*2, 2*2-1:2*2] .= B2

    Cd[2*1-1:2*1, 2*1-1:2*1] .= C1
    Cd[2*2-1:2*2, 2*2-1:2*2] .= C2

    Dd[2*1-1:2*1, 2*1-1:2*1] .= D1
    Dd[2*2-1:2*2, 2*2-1:2*2] .= D2

    ndif = size(Ad, 1)
    # Matrices of the explicit system
    A = Ad+Bd*((Y_ex-Dd)\Cd)
    B = Bd*((Y_ex-Dd)\Bk[ndif+1:end])
    if iinp == "f" 
        C = (Ck[ndif+1:end]'*((Y_ex-Dd)\Cd))* A / (2*pi*60)
    else
        C = (Ck[ndif+1:end]'*((Y_ex-Dd)\Cd))
    end 

    Aex = A - B * k * C
    #Aex = Symbolics.simplify.(Aex0; expand=true, threaded=true)
    return Aex
end # function

function implicitsystem_ol(Y_ex, A1, A2, B1, B2, C1, C2, D1, D2)
    Ad = BlockDiagonal([A1, A2])
    Bd = zeros(Num,size(Ad, 1), size(Y_ex, 2))
    Cd = zeros(Num,size(Y_ex, 1), size(Ad, 1))
    Dd = zeros(Num,size(Y_ex, 1), size(Y_ex, 2))

    Bd[2*1-1:2*1, 2*1-1:2*1] .= B1
    Bd[2*2-1:2*2, 2*2-1:2*2] .= B2

    Cd[2*1-1:2*1, 2*1-1:2*1] .= C1
    Cd[2*2-1:2*2, 2*2-1:2*2] .= C2

    Dd[2*1-1:2*1, 2*1-1:2*1] .= D1
    Dd[2*2-1:2*2, 2*2-1:2*2] .= D2

    # Matrix of the implicit system
    Aim = [
        Ad  Bd;
        Cd  (Y_ex-Dd)
    ]

    Aim = Symbolics.simplify.(Aim; expand=true, threaded=true)
    return Aim
end

function explicitsystem_cl(Aim, Bk, Ck, ndif)
    @variables k 
    Aimk = Aim - Bk * k * Ck
    #Aimk = Symbolics.simplify.(Aimk; expand=true, threaded=true)
    A11 = Aimk[1:ndif, 1:ndif]
    A12 = Aimk[1:ndif, ndif+1:end]
    A21 = Aimk[ndif+1:end, 1:ndif]
    A22 = Aimk[ndif+1:end, ndif+1:end]
    Aex = A11 + A12 * (A22 \ A21);
    return Aex
end # function
end # module buildsystem

module system_eigenanalysis
using ..Symbolics
using ..LinearAlgebra
using ..symbolictools
export eigenanalysis, sensitivitycalculation
@variables λ k x kH va KD
function eigenanalysis(Aex, dicCheck)
    #Aex = Symbolics.simplify.(Aex; expand=true, threaded=true)
    c = Dict{Int, Num}()
    λres = Dict{}()
    λcheck = Dict{}()
    aux = Aex - λ * I;
    expr = det(aux);
    simplified_expr = expr |> expand;
    simplified_expr = Symbolics.unwrap(simplified_expr);
    simplified_expr = symbolictools.convert_to_simplify(simplified_expr);
    simplified_expr = symbolictools.convert_to_rational(simplified_expr);
    sim_expr::Num = simplified_expr;
    #sim_expr::Num = Symbolics.simplify(simplified_expr, expand=true, threaded=true) |> expand
    tol=1e-6

    c[1] = substitute(sim_expr, Dict( λ => 0.0)); 
    c[2] = Symbolics.coeff(sim_expr, λ);
    c[3] = Symbolics.coeff(sim_expr, λ^2);
    c[4] = Symbolics.coeff(sim_expr, λ^3);
    c[5] = Symbolics.coeff(sim_expr, λ^4);

    # Additional check for numerical evaluation when the symbolic variable is the denominator
    # Check if x is not in the symbolic variables of the main expression
    expr_sym_vars = Symbolics.get_variables(sim_expr)
    if !any(isequal(x, var) for var in expr_sym_vars)
        for i in 1:5
            aux1 = c[i] |> expand |> simplify
            aux2 = 1/aux1 |> expand |> simplify
            sym_vars = Symbolics.get_variables(aux2)
            if length(sym_vars) == 1
                # Only wrap the part that might throw an error
                try
                    aux3 = 1 / Symbolics.coeff(aux2, sym_vars[1])
                    if aux3 <= tol
                        c[i] = 0.0
                    end
                catch e
                    println("Skipping index $i due to coeff error: $e")
                    continue
                end
            end
        end
    end 


    # Numerical evaluation of coefficients for checking the type of equation to solve
    c1f = Symbolics.symbolic_to_float(c[1])
    c2f = Symbolics.symbolic_to_float(c[2])
    c4f = Symbolics.symbolic_to_float(c[4])


    if !(c2f isa Num) && !(c4f isa Num) && !(c2f isa SymbolicUtils.BasicSymbolic) && !(c4f isa SymbolicUtils.BasicSymbolic)
        if abs(c2f) < tol && abs(c4f) < tol 
            aux = c[3]^2 - 4*c[1]*c[5];
            aux_1 = (-c[3] + sqrt(aux))/(2*c[5]);
            aux_2 = (-c[3] - sqrt(aux))/(2*c[5]);

            λres[1] = + sqrt(aux_1);
            λres[2] = - sqrt(aux_1);
            λres[3] = + sqrt(aux_2);
            λres[4] = - sqrt(aux_2);
        end 
    elseif !(c1f isa Num) && !(c1f isa SymbolicUtils.BasicSymbolic)
        if abs(c1f) < tol 
            # One root is zero
            A = c[5]; B = c[4]; C = c[3]; D = c[2]; E = c[1]; 
            Δ0 = B^2 - 3*A*C
            Δ1 = 2*B^3 - 9*A*B*C + 27*A^2*D
            C1 = ((Δ1 + sqrt(Δ1^2 - 4*Δ0^3))/2)^(1/3) # Cubic root of C

            ξ = (-1 + sqrt(-3 + 0im)) / 2  # Complex cube root of unity
            ω = (-1 - sqrt(-3 + 0im)) / 2  # Complex cube root of unity

            λres[1] = 0;
            λres[2] = (-1/(3*A)) * (B + C1 + Δ0/(C1))
            λres[3] = (-1/(3*A)) * (B + ξ*C1 + Δ0/(ξ*C1))
            λres[4] = (-1/(3*A)) * (B + ω*C1 + Δ0/(ω*C1))
        end
    else 
        # Esto es un poco trampa, lo resuelvo así porque se que 2 autovalores son cero. 
        aux = c[3]^2 - 4*c[1]*c[5];
        aux_1 = (-c[3] + sqrt(aux))/(2*c[5]);
        aux_2 = (-c[3] - sqrt(aux))/(2*c[5]);

        λres[1] = + sqrt(aux_1);
        λres[2] = - sqrt(aux_1);
        λres[3] = + sqrt(aux_2);
        λres[4] = - sqrt(aux_2);
        # A = c[5]; B = c[4]; C = c[3]; D = c[2]; E = c[1];

        # ca = -(3*B^2)/(8*A^2) + C/A
        # cb = (B^3)/(8*A^3) - (B*C)/(2*A^2) + D/A
        # cc = -(3*B^4)/(256*A^4) + (B^2*C)/(16*A^3) - (B*D)/(4*A^2) + E/A

        # P = -ca^2/12 - cc
        # Q = -ca^3/108 + ca*cc/3 - cb^2/8
        # R = -Q/2 + sqrt(Q^2/4 + P^3/27)

        # U = R^(1/3) # Cubic root of R

        # y = -5/6*ca + U - P/(3*U)
        # W = sqrt(ca + 2*y)

        # λres[1] = -B/(4*A)+ (+W + sqrt(-(3*ca + 2*y + (2*cb)/W)))/2
        # λres[2] = -B/(4*A)+ (-W + sqrt(-(3*ca + 2*y - (2*cb)/W)))/2
        # λres[3] = -B/(4*A)+ (+W - sqrt(-(3*ca + 2*y + (2*cb)/W)))/2
        # λres[4] = -B/(4*A)+ (-W - sqrt(-(3*ca + 2*y - (2*cb)/W)))/2

    end

    for i in 1:4
        λcheck[i] = substitute(λres[i], dicCheck)
    end

    return c, λres, λcheck
end # function

function sensitivitycalculation(λres, dicCheck, iinp)
    println("   --- Starting Sensitivity Calculation ---")
    println("   Input: $(length(λres)) eigenvalues")
    # for i in 1:4
    #     λres[i] = Symbolics.simplify(λres[i], expand=true, threaded=true)
    # end

    # Force garbage collection before starting
    GC.gc()
    
    println("   Step 1: Setting up differential operator...")
    D = Differential(k)
    dλres = Dict{}()
    ζ = Dict{}()
    ζcheck = Dict{}()
    println("   ✓ Differential operator created")
    
    println("   Step 2: Computing derivatives of eigenvalues...")
    for i in 1:4
        print("      - Processing eigenvalue $i...")
        dλres[i] = expand_derivatives(D(λres[i]));
        println(" ✓")
    end
    println("   ✓ All derivatives computed")

    println("   Step 3: Evaluating sensitivities at k ")
    k0 = Dict(k => dicCheck[k])
    for i in 1:4
        print("      - Sensitivity $i...")
        # Check if dλres[i] is already complex
        if dλres[i] isa Complex
            # If so, substitute with real part of k0
            ζ[i] = substitute(dλres[i], Dict(k => real(dicCheck[k])))
        else
            ζ[i] = substitute(dλres[i], k0)
        end
        println(" ✓")
        # Force GC after each simplification
        #GC.gc()
    end
    println("   ✓ All sensitivities evaluated")

    for i in 1:4
        ζcheck[i] = substitute(ζ[i], dicCheck)
    end
    
    println("   --- Sensitivity Calculation Completed ---")
    return ζ, ζcheck
end # function
end # module system_eigenanalysis

module process_results
using ..Symbolics
using ..DataFrames
export dict_to_df, iinp_labels, iout_labels, symvar_labels

# Label mappings
const iinp_labels = Dict(
    "v" => "Bus Voltage",
    "f" => "Bus Frequency",
    "iabs" => "Line Current",
    "p" => "Line Active Power",
    "q" => "Line Reactive Power",
    "s" => "Line Apparent Power"
)

const iout_labels = Dict(
    "P" => "Active Power Injection",
    "Q" => "Reactive Power Injection"
)

const symvar_labels = Dict(
    "kH" => "Inertia Ratio",
    "x"  => "Line Impedance",
    "va" => "Power Flow Pattern",
    "vm" => "Voltage Magnitude",
    "KD" => "Damping"
)

function dict_to_df(dict_data)
    rows = DataFrame[]
    for ((iinp, iout, symvar, jpod), values) in dict_data
        symvalues = [v[1] for v in values]
        sensivalues = [v[2] for v in values]
        df = DataFrame(
            iinp   = repeat([iinp], length(values)),
            iout   = repeat([iout], length(values)),
            symvar = repeat([symvar], length(values)),
            jpod   = repeat([jpod], length(values)),
            symvalue = symvalues,
            sensivalue = sensivalues,
        )
        push!(rows, df)
    end
    vcat(rows...)
end
end # module process_results