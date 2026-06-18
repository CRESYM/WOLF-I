## Importing necessary packages and modules
# Core packages
using LinearAlgebra
using Symbolics

# Local modules
include("linmodfun.jl")
using .ssmatrix
using .solvelf

include("symtools.jl") 
using .contobsfac 
using .buildsystem
using .system_eigenanalysis

module SymbolicAnalysis
    using ..LinearAlgebra
    using ..Symbolics
    using ..ssmatrix
    using ..solvelf
    using ..contobsfac
    using ..buildsystem
    using ..system_eigenanalysis

    export symanalysis

    function symanalysis(symvars, dicCheck, iinp, iout, jpod, kbus)
        println("=== Starting Symbolic Analysis ===")
        println("Symbolic variables: ", symvars)
        println("Input type: $iinp, Output type: $iout, POD bus: $jpod")
        
        println("\n1. Loading power flow data...")
        Sb, result, data = solvelf_pm("data/bs_2area2gen_shiftbus3.m"); # LF.
        println("✓ Power flow solved successfully")

        # Check if x should be symbolic based on symvars
        if symvars == "x"
            println("\n2. Setting up symbolic reactance (x)...")
            @variables x
            data["branch"]["2"]["br_x"] = x # Symbolic reactance
            #data["branch"]["2"]["br_r"] = 0 # Resistance 0 to simplify the system
            # data["branch"]["2"]["br_r"] = 0 # Resistance 0 to simplify the system
            println("✓ Branch reactance set as symbolic variable")
        else
            println("\n2. Using numerical reactance value")
        end        
        println("\n3. Building admittance matrix...")
        jload = [1, 2] # Load buses
        Y_ex, Yl = yexmatrixsym(data, result, jload, 1, 2); # Expanded admittance matrix
        println("✓ Admittance matrix built successfully")

        # Dynamic data 
        println("\n4. Setting up dynamic data...")
        H = Dict{Int, Any}()
        if symvars == "kH"
            println("   - Setting up symbolic inertia (kH)...")
            @variables kH
            H1 = 6.5
            H[1] = H1
            H[2] = kH * H1 
            println("   ✓ H[1] = $H1, H[2] = kH * $H1")
        else
            println("   - Using numerical inertia values...")
            H[1] = 6.5 # Inertia constant of the generator 1
            H[2] = 6.5 # Inertia constant of the generator 2
            println("   ✓ H[1] = $(H[1]), H[2] = $(H[2])")
        end
        
        if symvars == "KD"
            println("   - Setting up symbolic damping coefficient (KD)...")
            @variables KD
            KD = KD # Symbolic damping coefficient
            println("   ✓ KD set as symbolic variable")
        else
            println("   - Using numerical damping coefficient value")
            KD = 0 # Damping coefficient

        end

        f = 60 # Nominal frequency
        Ra = 0.0025 # Armature resistance
        Xd = 0.3  # Direct-axis synchronous reactance
        Sbg = 900 # Base power of generators parameters in MVA
        A = Dict{Int, Matrix{Num}}(); B = Dict{Int, Matrix{Num}}(); C = Dict{Int, Matrix{Num}}(); D = Dict{Int, Matrix{Num}}();

        println("\n5. Computing state-space matrices for generators...")
        for j in 1:length(data["gen"])
            println("   - Processing generator $j...")
            jgen = string(j)
            vm = result["solution"]["bus"][jgen]["vm"]
            va = result["solution"]["bus"][jgen]["va"]
            pg = result["solution"]["gen"][jgen]["pg"]
            qg = result["solution"]["gen"][jgen]["qg"]
            Sb = result["solution"]["baseMVA"]
            A[j], B[j], C[j], D[j] = ssmatrixclgen(H[j], KD, f, Ra, Xd, vm, va, pg, qg, Sb, Sbg)
        end
        println("✓ State-space matrices computed for all generators")
        println("\n6. Building system matrices...")
        ndif = sum(size(A[j], 1) for j in 1:length(A)) # Number of dynamic states
        n = ndif + size(Y_ex,1) # Number of variables in the system
        println("✓ System matrices built.")

        if symvars == "vm" # Check if vm should be symbolic
            println("\n7. Setting up symbolic voltage magnitude (vm) for bus $jpod...")
            @variables vm
            result["solution"]["bus"]["3"] = Dict{String, Any}(result["solution"]["bus"][string(jpod)])
            result["solution"]["bus"]["3"]["vm"] = vm  # now assign symbolic vm
            println("✓ Voltage magnitude set as symbolic variable")
        else
            println("\n7. Using numerical voltage magnitude values")
        end       
        
        if symvars == "va" # Check if va should be symbolic
            println("\n7. Setting up symbolic voltage angle (va) for bus $jpod...")
            @variables va
            result["solution"]["bus"]["3"] = Dict{String, Any}(result["solution"]["bus"][string(jpod)])
            result["solution"]["bus"]["1"] = Dict{String, Any}(result["solution"]["bus"][string(jpod)])
            result["solution"]["bus"]["3"]["va"] = va  # now assign symbolic va
            result["solution"]["bus"]["1"]["va"] = 2*va
            println("✓ Voltage angle set as symbolic variable")
        else
            println("\n7. Using numerical voltage angle values")
        end  
        println("\n8. Computing controllability and observability matrices...")
        Bk = confac(result, iout, n, ndif, jpod) # Controllability matrix
        Ck = obsfac(result, data, Yl, iinp, n, ndif, jpod; kbus) # Observability matrix
        println("✓ Control matrices computed. Bk size: $(size(Bk)), Ck size: $(size(Ck))")

        println("\n9. Building closed-loop system...")
        Aex = system_cl(Y_ex, A[1], A[2], B[1], B[2], C[1], C[2], D[1], D[2], Bk, Ck, iinp);
        if symvars == "x"
            println("   - Simplifying if symbolic reactance")
            Aex = Symbolics.simplify(Aex, expand = true)
            println("   ✓ Completed.")
        end
        println("✓ Closed-loop system built. Size: $(size(Aex))")

        println("\n10. Performing eigenvalue analysis...")
        c, λres, λcheck = eigenanalysis(Aex,dicCheck); # Eigenvalues of the system with feedback
        println("✓ Eigenvalue analysis completed. Found $(length(λres)) eigenvalues")
        
        println("\n11. Computing sensitivity analysis...")
        ζ, ζcheck = sensitivitycalculation(λres, dicCheck, iinp) # Sensitivity calculation for k = 0 (open-loop system)
        println("✓ Sensitivity analysis completed")
        
        println("\n=== Symbolic Analysis Completed Successfully ===\n")
        return c, λres, λcheck, ζ, ζcheck

    end 
end # module SymbolicAnalysis
