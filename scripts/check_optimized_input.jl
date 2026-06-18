using SymbolicES
using Symbolics

target_eigenvalue = 0.0 + 3im  # Interarea mode (positive conjugate)
@variables k va 
iinp = "u"
iout = "P"
symvars = "va"
jpod = 3
kbus = 2

λres = Dict{Tuple{String, String, String, Int}, Any}()
ζ = Dict{Tuple{String, String, String, Int}, Any}()
λcheck = Dict{Tuple{String, String, String, Int}, Any}()
λplot = Dict{Tuple{String, String, String, Int}, Vector{ComplexF64}}()
ζcheck = Dict{Tuple{String, String, String, Int}, Any}()
ζplot = Dict{Tuple{String, String, String, Int}, Vector{ComplexF64}}()

dicCheck = Dict(k => 0.0 + 0im, va => -0.49 + 0im)
varrange = Complex.(range(0, 2π; length=100))

c, λres_temp, λcheck_temp, ζ_temp, ζcheck_temp = symanalysis(symvars, dicCheck, iinp, iout, jpod, kbus)

expr_λ = λres_temp[3] 
expr_ζ = ζ_temp[3]

λ_results = ComplexF64[]
ζ_results = ComplexF64[]

for (idx, var_val) in enumerate(varrange)
    sub_dict = Dict(k => 0 + 0im, va => var_val)
    
    # Substitute in both expressions
    λ_sub = substitute(expr_λ, sub_dict)
    ζ_sub = substitute(expr_ζ, sub_dict)
    
    # Evaluate λ and convert to complex number
    λ_re = Symbolics.symbolic_to_float(real(λ_sub))
    λ_im = Symbolics.symbolic_to_float(imag(λ_sub))
    λ_val = complex(λ_re, λ_im)
    push!(λ_results, λ_val)
    
    # Evaluate ζ and convert to complex number
    ζ_re = Symbolics.symbolic_to_float(real(ζ_sub))
    ζ_im = Symbolics.symbolic_to_float(imag(ζ_sub))
    ζ_val = complex(ζ_re, ζ_im)
    push!(ζ_results, ζ_val)
end

using Plots
vals = ζ_results

reals = real.(vals)
imags = imag.(vals)
mags = abs.(vals)
phases = rad2deg.(angle.(vals))
n = length(vals)
plt = plot(layout = (2,2), size=(900,700))
plot!(plt[1,1], 1:n, reals, label="Real", xlabel="Index", ylabel="Real")
plot!(plt[1,2], 1:n, imags, label="Imag", xlabel="Index", ylabel="Imag")
plot!(plt[2,1], 1:n, mags, label="Mag", xlabel="Index", ylabel="Magnitude")
plot!(plt[2,2], 1:n, phases, label="Phase", xlabel="Index", ylabel="Phase (deg)")
