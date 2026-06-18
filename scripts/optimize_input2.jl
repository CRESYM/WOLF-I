using LinearAlgebra
using JuMP
using HiGHS
using Symbolics
using JLD2

jbus1 = 1
jbus2 = 2
jbus3 = 3
iout = "Q"
symvar1 = "va"
@Symbolics.variables va

merged_data = load("results/results_1_shiftbus3.jld2"); #results_1_shiftbus3 #merged_results
ζ = merged_data["ζ"];
λcheck = merged_data["λcheck"];
λcheck[("q", iout, symvar1, jbus3)]

auxv3 = Symbolics.simplify(ζ[("v", iout, symvar1, jbus3)][3], expand=true)
auxp3 = Symbolics.simplify(ζ[("p", iout, symvar1, jbus3)][3], expand=true)
auxq3 = Symbolics.simplify(ζ[("q", iout, symvar1, jbus3)][3], expand=true)

f_v3 = build_function(auxv3, va; expression = Val(false))
f_p3 = build_function(auxp3, va; expression = Val(false))
f_q3 = build_function(auxq3, va; expression = Val(false))

funcs = [
    eval(f_v3),
    eval(f_p3),
    eval(f_q3), 
]

# === Muestreo del dominio ===
N = 2000
va_vals1 = range(0, 2*π; length=N)

# Construir matriz de valores g_matrix (N x 6)
g_matrix = Matrix{Float64}(undef, N, length(funcs))
for (i, va_val) in enumerate(va_vals1)
    for j in 1:length(funcs)  # Índices de funciones puramente imaginarias
        g_matrix[i, j] = imag(funcs[j](va_val))  # ← cambia a real(...) si no son puramente imaginarias
    end
end


# === Formulación de optimización con valores positivos ===
model = Model(HiGHS.Optimizer)

@JuMP.variable(model, a[1:length(funcs)])   # coeficientes de la combinación
@JuMP.variable(model, t >= 0)               # cota mínima garantizada, positiva

for j in 1:length(funcs)
    @constraint(model, -1 <= a[j] <= 1)
end

# Restricciones: dot(g_row, a) >= t para todo va muestreado
for i in 1:N
    @constraint(model, dot(g_matrix[i, :], a) >= t)
end

@objective(model, Max, t)

optimize!(model);

a_opt = value.(a)
println("Optimal coefficients a: ", a_opt)
t_opt = value(t)
