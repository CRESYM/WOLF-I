include("render_jmd.jl")     # loads the functions (no auto-run now)

# first call: activates the project env, instantiates, loads PowerModels etc.
# — slow once (10–20 min the first time), then cached for the session
render("projects/202505-Two-Area-Four-Gen-Linear-Model/2area4gen_clsgen.jmd")

# second call reuses everything already loaded — fast
render("projects/202505-Two-Area-Four-Gen-Linear-Model/2area4gen_detgen.jmd")
