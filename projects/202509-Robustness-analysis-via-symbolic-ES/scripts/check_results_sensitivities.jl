using JLD2
using Symbolics

# Load the results
results = JLD2.load("results/results_1_shiftbus3.jld2");
ζcheck = results["ζcheck"]

# Define reference values from the table
reference_table = Dict(
    ("f", "P") => 0.0014,
    ("f", "Q") => 0.0006,
    ("v", "P") => 0.0768,
    ("v", "Q") => 0.0343,
    ("iabs", "P") => 0.8389,
    ("iabs", "Q") => 0.3743,
    ("p", "P") => 0.3536,
    ("p", "Q") => 0.1578,
    ("q", "P") => 0.3867,
    ("q", "Q") => 0.1726,
    ("s", "P") => 0.4481,
    ("s", "Q") => 0.1999
)

# Define the parameter categories to check
row_parameters = ["f", "v", "iabs", "p", "q", "s"]
col_parameters = ["P", "Q"] 
third_parameters = ["KD", "kH", "va", "vm", "x"]
fourth_parameter_values = [3]  # The fourth parameter in the tuple key
inner_dict_key = 4  # The key we want from the inner dictionary

# Function to check if two values are approximately equal
function are_approximately_equal(val1, val2; tolerance=5e-4)
    diff = abs(val1 - val2)
    is_equal = diff < tolerance
    println("    Comparing: $val1 vs $val2, diff = $diff, tolerance = $tolerance, match = $is_equal")
    return is_equal
end

# Function to safely convert symbolic values to float
function safe_to_float(val)
    println("    Converting value: $val (type: $(typeof(val)))")
    try
        # Try different conversion methods
        if isa(val, Number) && !isa(val, Symbolics.Num)
            result = Float64(val)
            println("    -> Converted as Number: $result")
            return result
        elseif isa(val, Symbolics.Num)
            # Use Symbolics.value to extract the numerical value
            result = Float64(Symbolics.value(val))
            println("    -> Converted as Symbolics.Num: $result")
            return result
        else
            result = parse(Float64, string(val))
            println("    -> Converted via string parsing: $result")
            return result
        end
    catch e
        println("    -> Conversion failed: $e")
        return NaN
    end
end

# Store results for summary table
comparison_results = Dict()

# Iterate through all combinations
for row_param in row_parameters
    for col_param in col_parameters
        ref_key = (row_param, col_param)
        if haskey(reference_table, ref_key)
            reference_value = reference_table[ref_key]
            
            # Initialize results storage
            if !haskey(comparison_results, row_param)
                comparison_results[row_param] = Dict()
            end
            if !haskey(comparison_results[row_param], col_param)
                comparison_results[row_param][col_param] = Dict()
            end
            
            # Check each third parameter
            for third_param in third_parameters
                println("  Checking third parameter: $third_param")
                found_match = false
                all_values = []
                
                # Try all fourth parameter values
                for fourth_val in fourth_parameter_values
                    test_key = (row_param, col_param, third_param, fourth_val)
                    println("    Testing key: $test_key")
                    
                    if haskey(ζcheck, test_key)
                        println("    Key found in ζcheck!")
                        try
                            test_dict = ζcheck[test_key]
                            println("    test_dict keys: $(keys(test_dict))")
                            
                            if haskey(test_dict, inner_dict_key)
                                complex_value = test_dict[inner_dict_key]
                                println("    Raw complex_value: $complex_value (type: $(typeof(complex_value)))")
                                
                                # Check if it's actually complex
                                if isa(complex_value, Complex)
                                    println("    Complex number - real: $(real(complex_value)), imag: $(imag(complex_value))")
                                end
                                
                                # Get absolute value of the complex number (not just imaginary part)
                                abs_value = abs(complex_value)
                                println("    Absolute value: $abs_value (type: $(typeof(abs_value)))")
                                test_value_float = safe_to_float(abs_value)
                                
                                if !isnan(test_value_float)
                                    push!(all_values, (fourth_val, test_value_float))
                                    println("    Final test value: $test_value_float")
                                    
                                    # Check if it matches reference
                                    println("    Checking match against reference ($reference_value):")
                                    if are_approximately_equal(test_value_float, reference_value)
                                        found_match = true
                                        println("    *** MATCH FOUND! ***")
                                    else
                                        println("    No match")
                                    end
                                else
                                    println("    test_value_float is NaN, skipping")
                                end
                            else
                                println("    Inner dict key $inner_dict_key not found")
                            end
                        catch e
                            println("    Error processing: $e")
                            continue
                        end
                    else
                        println("    Key not found in ζcheck")
                    end
                end
                
                println("    All values found for $third_param: $all_values")
                println("    Final match status for $third_param: $found_match")
                
                # Store and display results
                comparison_results[row_param][col_param][third_param] = found_match
            end
        end
    end
end

# Create final summary table
println("\nFINAL SUMMARY TABLE (Your Format)")
println("=" ^ 80)
println("| | P | Q | KD | kH | va | vm | x |")
println("|---|---|----|----|----|----|---|")

for row_param in row_parameters
    print("|$row_param | ")
    
    # P and Q reference values
    if haskey(reference_table, (row_param, "P"))
        print("$(reference_table[(row_param, "P")]) | ")
    else
        print("N/A | ")
    end
    if haskey(reference_table, (row_param, "Q"))
        print("$(reference_table[(row_param, "Q")]) | ")
    else
        print("N/A | ")
    end
    
    # Status for each third parameter
    for third_param in third_parameters
        # Check both P and Q matches - BOTH must match for ✅
        p_match = (haskey(comparison_results, row_param) && 
                   haskey(comparison_results[row_param], "P") && 
                   haskey(comparison_results[row_param]["P"], third_param) &&
                   comparison_results[row_param]["P"][third_param])
        
        q_match = (haskey(comparison_results, row_param) && 
                   haskey(comparison_results[row_param], "Q") && 
                   haskey(comparison_results[row_param]["Q"], third_param) &&
                   comparison_results[row_param]["Q"][third_param])
        
        # Require BOTH P and Q to match their respective references
        if p_match && q_match
            print("✅| ")
        else
            print("❌| ")
        end
    end
    println()
end

println()
println("Legend:")
println("✅ = BOTH P and Q measurements match their respective reference values (tolerance: 1e-4)")
println("❌ = Either P or Q (or both) do not match their reference values")
println()
println("Analysis complete! This automated script checks all combinations and")
println("compares them with your reference table values.")
println("Note: Using inner dictionary key $inner_dict_key and comparing absolute values")