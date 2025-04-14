using Weave

pathjmd = joinpath(@__DIR__, "../AnalysisAndReports/RLC_analysis.jmd")
# First execute the .jl script 
weave(pathjmd, out_path="../WOLF-I/AnalysisAndReports/", doctype="github")