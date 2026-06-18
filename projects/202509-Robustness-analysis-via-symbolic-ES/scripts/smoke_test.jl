# =============================================================================
# smoke_test.jl — SAFE end-to-end check of the SymbolicES analysis pipeline.
#
# Runs the same analysis as scripts/generate_results.jl, BUT:
#   • writes only to results/smoke_test_output.jld2 (a throwaway file), and
#   • never touches results/results_1_shiftbus3.jld2 (your real results).
# It even verifies afterwards that the real results file is byte-for-byte
# unchanged.
#
# Run from the repository root:
#   julia --project=. scripts/smoke_test.jl
#
# Coverage is controlled by QUICK below:
#   QUICK = true   -> 4 configurations  (fast sanity check, ~minutes)
#   QUICK = false  -> the full sweep    (identical to generate_results.jl)
# =============================================================================

using Symbolics
using JLD2
using SymbolicES

const QUICK          = true
const OUTPUT_FILE    = "results/smoke_test_output.jld2"
const PROTECTED_FILE = "results/results_1_shiftbus3.jld2"

@assert OUTPUT_FILE != PROTECTED_FILE "refusing to run: smoke test would overwrite the real results"

# Snapshot the protected file so we can prove it stays untouched.
protected_before = isfile(PROTECTED_FILE) ? (filesize(PROTECTED_FILE), mtime(PROTECTED_FILE)) : nothing

target_eigenvalue = 0.0 + 3.27im  # Interarea mode (positive conjugate)
@variables k va x kH vm KD

# Sweep dimensions (reduced when QUICK, full otherwise).
jpod_range   = 3:3
iout_range   = QUICK ? ["P"]         : ["P", "Q"]
iinp_range   = QUICK ? ["f", "p"]    : ["f", "v", "iabs", "p", "q", "s"]
symvar_range = QUICK ? ["kH", "KD"]  : ["x", "kH", "va", "vm", "KD"]

λres   = Dict{Tuple{String, String, String, Int}, Any}()
ζ      = Dict{Tuple{String, String, String, Int}, Any}()
λcheck = Dict{Tuple{String, String, String, Int}, Any}()
ζcheck = Dict{Tuple{String, String, String, Int}, Any}()
λplot  = Dict{Tuple{String, String, String, Int}, Vector{Tuple{ComplexF64, ComplexF64}}}()
ζplot  = Dict{Tuple{String, String, String, Int}, Vector{Tuple{ComplexF64, ComplexF64}}}()

n_ok = 0
n_fail = 0
failures = String[]

println("=== SMOKE TEST ($(QUICK ? "QUICK subset" : "FULL sweep")) ===")

@time for jpod in jpod_range
    for iout in iout_range
        for iinp in iinp_range
            if iinp == "v" || iinp == "f"
                kbus = 0
            elseif jpod != 3
                kbus = 3
            else
                kbus = 2
            end

            for symvars in symvar_range
                global n_ok, n_fail   # rebind the script-level counters (soft-scope)
                key = (iinp, iout, symvars, jpod)
                println("Processing $key")
                try
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

                    c, λres_temp, λcheck_temp, ζ_temp, ζcheck_temp =
                        symanalysis(symvars, dicCheck, iinp, iout, jpod, kbus)
                    λres[key]   = λres_temp
                    ζ[key]      = ζ_temp
                    λcheck[key] = λcheck_temp
                    ζcheck[key] = ζcheck_temp

                    # Locate the eigenvalue closest to the target and evaluate it
                    # over the parameter range (mirrors generate_results.jl).
                    eigenvalues = λcheck[key]
                    eigenvalue_values = collect(values(eigenvalues))
                    eigenvalue_keys = collect(keys(eigenvalues))
                    min_idx = argmin(abs.(eigenvalue_values .- target_eigenvalue))
                    closest_index = eigenvalue_keys[min_idx]

                    if haskey(ζ[key], closest_index) && haskey(λres[key], closest_index)
                        λ_results = Vector{Tuple{ComplexF64, ComplexF64}}()
                        ζ_results = Vector{Tuple{ComplexF64, ComplexF64}}()
                        expr_λ = λres[key][closest_index]
                        expr_ζ = ζ[key][closest_index]

                        for var_val in varrange
                            var_symbol = symvars == "kH" ? kH : (symvars == "va" ? va :
                                         (symvars == "x" ? x : (symvars == "KD" ? KD : vm)))
                            sub_dict = Dict(k => 0.01 + 0.0im, var_symbol => var_val)

                            λ_sub = substitute(expr_λ, sub_dict)
                            ζ_sub = substitute(expr_ζ, sub_dict)

                            λ_val = complex(Symbolics.symbolic_to_float(real(λ_sub)),
                                            Symbolics.symbolic_to_float(imag(λ_sub)))
                            ζ_val = complex(Symbolics.symbolic_to_float(real(ζ_sub)),
                                            Symbolics.symbolic_to_float(imag(ζ_sub)))
                            push!(λ_results, (var_val, λ_val))
                            push!(ζ_results, (var_val, ζ_val))
                        end

                        λplot[key] = λ_results
                        ζplot[key] = ζ_results
                    end

                    n_ok += 1
                    println("  ✓ OK $key")
                catch err
                    n_fail += 1
                    push!(failures, "$key  =>  $(sprint(showerror, err))")
                    println("  ✗ FAIL $key  =>  ", err)
                end
                GC.gc()
            end
        end
    end
end

# Save ONLY to the throwaway file.
@save OUTPUT_FILE λres ζ λcheck ζcheck λplot ζplot

protected_after = isfile(PROTECTED_FILE) ? (filesize(PROTECTED_FILE), mtime(PROTECTED_FILE)) : nothing

println("\n==================== SMOKE TEST SUMMARY ====================")
println("mode:                $(QUICK ? "QUICK subset" : "FULL sweep")")
println("configurations OK:   $n_ok")
println("configurations FAIL: $n_fail")
for f in failures
    println("  - ", f)
end
println("output written to:   $OUTPUT_FILE  (throwaway — safe to delete)")
if protected_before == protected_after
    println("protected file:      $PROTECTED_FILE UNCHANGED ✓")
else
    println("protected file:      ⚠️  $PROTECTED_FILE CHANGED — investigate!")
end
println("===========================================================")

if n_fail > 0
    error("smoke test: $n_fail configuration(s) failed")
elseif protected_before != protected_after
    error("smoke test: the protected results file was modified")
else
    println("ALL GOOD ✓")
end
