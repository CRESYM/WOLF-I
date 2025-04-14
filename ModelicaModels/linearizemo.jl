using OMJulia

omc = OMJulia.OMCSession()
sendExpression(omc, "loadFile(\"RLC.mo\")")
sendExpression(omc, "getErrorString()")
sendExpression(omc, "linearize(RLC)")
OMJulia.exit()

mv("linearized_model.mo", "RLC_linearized.mo"; force=true)

rm.(filter(f -> any(endswith(f, ext) for ext in [".c", ".o", ".h", ".bat", ".makefile", ".json" , ".xml", ".mat", ".exe", ".libs", ".log", ".bin"]), readdir()), force=true)


