using LinearAlgebra
using ControlSystems

function extract_matrices(file_path)
    A = B = C = D = nothing
    matrix_name = ""
    collecting = false
    matrix_lines = []

    for line in eachline(file_path)
        line = strip(line)

        # Start collecting if we find a matrix definition
        if occursin("parameter Real", line)
            if occursin("A[", line)
                matrix_name = "A"
            elseif occursin("B[", line)
                matrix_name = "B"
            elseif occursin("C[", line)
                matrix_name = "C"
            elseif occursin("D[", line)
                matrix_name = "D"
            else
                continue
            end
            collecting = true
            matrix_lines = []
            continue
        end

        # Accumulate lines inside [ ... ];
        if collecting
            push!(matrix_lines, line)
            if occursin("];", line)
                full_matrix_string = join(matrix_lines, " ")
                mat = parse_modelica_matrix(full_matrix_string)
                if matrix_name == "A"
                    A = mat
                elseif matrix_name == "B"
                    B = mat
                elseif matrix_name == "C"
                    C = mat
                elseif matrix_name == "D"
                    D = mat
                end
                collecting = false
            end
        end
    end

    return A, B, C, D
end

function parse_modelica_matrix(matrix_str)
    # Extract inside of [ ... ]
    inside = match(r"\[(.*)\];", matrix_str).captures[1]

    # Split rows by ';'
    row_strs = split(inside, ';')
    mat = []

    for row_str in row_strs
        row = parse.(Float64, split(strip(row_str), ','))
        push!(mat, row)
    end

    return reduce(vcat, [row' for row in mat])  # Stack row vectors into a matrix
end
