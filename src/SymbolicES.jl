"""
    SymbolicES

Symbolic eigenvalue-sensitivity analysis of a multi-machine power system.

This top-level module ties the library together. `symanalysis.jl` itself
includes `linmodfun.jl` and `symtools.jl`, so every submodule
(`solvelf`, `ssmatrix`, `symbolictools`, `contobsfac`, `buildsystem`,
`system_eigenanalysis`, `process_results`, `SymbolicAnalysis`) is defined
under `SymbolicES`.

Public API:
- `symanalysis(...)` — end-to-end analysis for one configuration.
- `dict_to_df`, `iinp_labels`, `iout_labels`, `symvar_labels` — result helpers.
- `process_results` — the helper submodule (for qualified access).
"""
module SymbolicES

include("symanalysis.jl")

using .SymbolicAnalysis
using .process_results

export symanalysis
export dict_to_df, iinp_labels, iout_labels, symvar_labels
export process_results

end # module SymbolicES
