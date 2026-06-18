# Core packages
using Symbolics
using JLD2

# Local modules
using SymbolicES

target_eigenvalue = 0.0 + 3.27im  # Interarea mode (positive conjugate)
@variables k va x kH vm KD

# Initialize dictionaries with tuples as keys (iinp, iout, symvar, jpod)
λres = Dict{Tuple{String, String, String, Int}, Any}()
ζ = Dict{Tuple{String, String, String, Int}, Any}()
λcheck = Dict{Tuple{String, String, String, Int}, Any}()
λplot = Dict{Tuple{String, String, String, Int}, Vector{Tuple{ComplexF64, ComplexF64}}}()
ζplot = Dict{Tuple{String, String, String, Int}, Vector{Tuple{ComplexF64, ComplexF64}}}()
ζcheck = Dict{Tuple{String, String, String, Int}, Any}()


@time for jpod in 3:3
    for iout in ["P", "Q"]
        for iinp in ["f","v", "iabs", "p", "q", "s"]
            if iinp == "v" || iinp == "f"
                kbus = 0
            elseif jpod != 3
                kbus = 3
            else            
                kbus = 2
            end 

            for symvars in ["x","kH", "va", "vm", "KD"]
                println("Processing iinp: $iinp, iout: $iout, symvars: $symvars, jpod: $jpod")
                if symvars == "kH"
                    dicCheck = Dict(k => 0.0 + 0im, kH => 1.0 + 0im)
                    varrange = Complex.(exp.(range(log(0.1), log(10); length=100)))
                elseif symvars == "va"
                    dicCheck = Dict(k => 0.0 + 0im, va => -0.682268 + 0im)
                    varrange = Complex.(0:0.1:2*pi)
                elseif symvars == "x"
                    dicCheck = Dict(k => 0.0 + 0im, x => 0.15 + 0im)
                    varrange = Complex.(exp.(range(log(0.015), log(1.5); length=100)))
                elseif symvars == "vm"
                    dicCheck = Dict(k => 0.0 + 0im, vm => 0.934392 + 0im)
                    varrange = Complex.(0.5:0.1:1.5)
                elseif symvars == "KD"
                    dicCheck = Dict(k => 0.0 + 0im, KD => 0.0 + 0im)
                    varrange = Complex.(0:0.1:10)
                end 

                c, λres_temp, λcheck_temp, ζ_temp, ζcheck_temp = symanalysis(symvars, dicCheck, iinp, iout, jpod, kbus)
                λres[(iinp, iout, symvars, jpod)] = λres_temp
                ζ[(iinp, iout, symvars, jpod)] = ζ_temp
                λcheck[(iinp, iout, symvars, jpod)] = λcheck_temp
                ζcheck[(iinp, iout, symvars, jpod)] = ζcheck_temp
                println("Processed iinp: $iinp, iout: $iout, symvars: $symvars, jpod: $jpod") # For tracking
                # Find the index of the eigenvalue closest to the target
                key = (iinp, iout, symvars, jpod)
                if haskey(λcheck, key) && haskey(ζ, key)
                    eigenvalues = λcheck[key]
                    
                    # Find the eigenvalue closest to target_eigenvalue (compact version)
                    eigenvalue_values = collect(values(eigenvalues))
                    eigenvalue_keys = collect(keys(eigenvalues))
                    min_idx = argmin(abs.(eigenvalue_values .- target_eigenvalue))
                    closest_index = eigenvalue_keys[min_idx]
                    
                    println("  -> Closest eigenvalue index: $closest_index")
                    
                    # Extract the corresponding elements from λ and ζ and evaluate over varrange
                    if haskey(ζ[key], closest_index) && haskey(λres[key], closest_index)
                        println("    ✓ Found expressions for eigenvalue/eigenvector at index $closest_index")
                        λ_results = Vector{Tuple{ComplexF64, ComplexF64}}()
                        ζ_results = Vector{Tuple{ComplexF64, ComplexF64}}()
                        
                        expr_λ = λres[key][closest_index]  # Get eigenvalue at closest_index
                        test = substitute(expr_λ, dicCheck)

                        expr_ζ = ζ[key][closest_index]    # Get eigenvector element at closest_index
                        println("    → Starting evaluation over $(length(varrange)) points...")
                        
                        for (idx, var_val) in enumerate(varrange)
                            # Create substitution dictionary based on variable type
                            var_symbol = symvars == "kH" ? kH : (symvars == "va" ? va : (symvars == "x" ? x : (symvars == "KD" ? KD : vm)))
                            sub_dict = Dict(k => 0.01 + 0.0im, var_symbol => var_val)

                            # Substitute in both expressions
                            λ_sub = substitute(expr_λ, sub_dict)
                            ζ_sub = substitute(expr_ζ, sub_dict)

                            # Evaluate λ and convert to complex number
                            λ_re = Symbolics.symbolic_to_float(real(λ_sub))
                            λ_im = Symbolics.symbolic_to_float(imag(λ_sub))
                            λ_val = complex(λ_re, λ_im)
                            push!(λ_results, (var_val, λ_val))

                            # Evaluate ζ and convert to complex number
                            ζ_re = Symbolics.symbolic_to_float(real(ζ_sub))
                            ζ_im = Symbolics.symbolic_to_float(imag(ζ_sub))
                            ζ_val = complex(ζ_re, ζ_im)
                            push!(ζ_results, (var_val, ζ_val))
                        end
                        
                        println("    ✓ Evaluation completed! Stored $(length(λ_results)) λ values and $(length(ζ_results)) ζ values")
                        λplot[key] = λ_results
                        ζplot[key] = ζ_results
                    else
                        println("    ✗ Missing expressions for index $closest_index")
                    end
                end
                GC.gc()
            end
        end
    end
end



# Save results to a JLD2 file
@save "results/results_1_shiftbus3.jld2" λres ζ λcheck ζcheck λplot ζplot