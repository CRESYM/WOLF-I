using SymbolicES
using Test

@testset "SymbolicES" begin
    # Smoke test: the package loads and its public API is exported.
    @test isdefined(SymbolicES, :symanalysis)
    @test isdefined(SymbolicES, :dict_to_df)
    @test isdefined(SymbolicES, :symvar_labels)
    @test isdefined(SymbolicES, :process_results)

    # Label dictionaries are populated as expected.
    @test SymbolicES.symvar_labels["kH"] == "Inertia Ratio"
    @test Set(keys(SymbolicES.iout_labels)) == Set(["P", "Q"])
end
