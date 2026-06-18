using JLD2
using DataFrames
using CSV
using Symbolics

#merged_data = load("results/merged_results.jld2");
merged_data = load("results/results_1_shiftbus3.jld2");
# Prepare DataFrame
df = DataFrame(iinp=Any[], iout=Any[], symvar=Any[], jpod=Any[], status=String[])

function check_entry(vals)
	tol = 2e-1
	target_eigenvalue = 3.27
	# If vals is a Dict, use its values
	v = vals isa Dict ? collect(values(vals)) : vals
	println("  [check_entry] Values: ", v)
	zeros = count(x -> abs(x) < tol, v)
	threes = count(x -> abs(abs(x) - target_eigenvalue) < tol, v)
	println("  [check_entry] zeros: ", zeros, " (should be 2), threes: ", threes, " (should be 2)")
	if zeros == 2 && threes == 2
		println("  [check_entry] Result: correct")
		return "correct"
	else
		println("  [check_entry] Result: incorrect")
		return "incorrect"
	end
end


for (key, vals) in merged_data["λcheck"]
	println("Checking key: ", key)
	v = vals isa Dict ? collect(values(vals)) : vals
	println("Values: ", v)
	status = check_entry(vals)
	push!(df, (key[1], key[2], key[3], key[4], status))
end


# Save DataFrame to CSV
CSV.write("results/lambda_check_analysis_1_shiftbus3.csv", df)
println("Analysis complete. Results saved to results/lambda_check_analysis_1_shiftbus3.csv.")

#CSV.write("results/lambda_check_2.csv", df_results)
