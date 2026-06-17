#!/usr/bin/env julia
#
# Render a Weave example (.jmd) into a Jekyll page under docs/_examples/.
#
# Usage:
#   julia tools/render_example.jl <path-to.jmd>     # explicit file
#   julia tools/render_example.jl <project-name>    # shortcut for projects/<name>/example.jmd
#
# Examples:
#   julia tools/render_example.jl example-template
#   julia tools/render_example.jl projects/202505-Two-Area-Four-Gen-Linear-Model/2area4gen_clsgen.jmd
#
# A project may hold several .jmd files; each renders to its own page at
# /examples/<slug>/, where <slug> is the .jmd file name (or the project folder
# name when the file is the generic example.jmd).
#
# Page metadata (title/summary/related post) is NOT kept in the .jmd — it lives
# in the METADATA table below, keyed by slug. Add an entry per example; a missing
# entry just falls back to defaults (title = slug, no summary). The code runs in
# the nearest enclosing project environment (the directory above the .jmd that
# contains a Project.toml), so results are reproducible. Weave is a build tool:
# install it once in your global environment with
#   julia -e 'using Pkg; Pkg.add("Weave")'

using Pkg
using Weave
using Dates

const REPO = normpath(joinpath(@__DIR__, ".."))

# Per-example page metadata, keyed by slug. Optional fields: summary, post, post_title.
const METADATA = Dict{String,NamedTuple}(
    "example-template" => (
        title = "Example template",
        summary = "Minimal template showing the Weave-to-Jekyll example pipeline.",
    ),
    "2area4gen_clsgen" => (
        title = "Two-Area Four-Generator System (classical model)",
        summary = "The simplest multimachine linear model, using the classical synchronous machine model.",
    ),
    "2area4gen_detgen" => (
        title = "Two-Area Four-Generator System (detailed model)",
        summary = "Multimachine linear model using the detailed synchronous machine model.",
    ),
)

"Resolve the CLI argument to a .jmd path (explicit file or projects/<name>/example.jmd)."
function resolve_jmd(arg)
    isfile(arg) && return abspath(arg)
    cand = joinpath(REPO, "projects", arg, "example.jmd")
    isfile(cand) && return cand
    error("Could not find a .jmd for '$arg' (not a file, and no projects/$arg/example.jmd).")
end

"Walk up from `start` to the nearest directory containing a Project.toml; fallback to `start`."
function find_project_dir(start)
    d = start
    while true
        isfile(joinpath(d, "Project.toml")) && return d
        parent = dirname(d)
        parent == d && return start
        d = parent
    end
end

git_commit(repo) = try
    readchomp(`git -C $repo rev-parse --short HEAD`)
catch
    ""
end

to_url(p) = replace(p, '\\' => '/')

function render(arg)
    jmd = resolve_jmd(arg)
    jmd_dir = dirname(jmd)
    project_dir = find_project_dir(jmd_dir)

    # Page slug: the .jmd file name, or the project folder name for example.jmd.
    base = first(splitext(basename(jmd)))
    slug = base == "example" ? basename(project_dir) : base
    meta = get(METADATA, slug, NamedTuple())

    # Run the example in its project environment.
    Pkg.activate(project_dir)
    Pkg.instantiate()

    # Weave the .jmd from its own directory so relative paths (includes, data
    # files) resolve as the author intended; output goes to a temp dir.
    outdir = mktempdir()
    cd(jmd_dir) do
        weave(jmd; doctype = "github", out_path = outdir)
    end
    weaved = read(joinpath(outdir, base * ".md"), String)

    relproj     = to_url(relpath(project_dir, REPO))
    title       = get(meta, :title, slug)
    summary     = get(meta, :summary, "")
    post        = get(meta, :post, "")
    post_title  = get(meta, :post_title, "blog post")
    project_url = "https://github.com/CRESYM/WOLF-I/tree/main/$relproj"

    io = IOBuffer()
    println(io, "---")
    println(io, "layout: example")
    println(io, "title: \"", title, "\"")
    isempty(summary) || println(io, "summary: \"", summary, "\"")
    println(io, "project: ", project_url)
    println(io, "project_name: ", relproj)
    if !isempty(post)
        println(io, "post: ", post)
        println(io, "post_title: \"", post_title, "\"")
    end
    println(io, "generated: ", Dates.today())
    commit = git_commit(REPO)
    isempty(commit) || println(io, "commit: ", commit)
    println(io, "---")
    println(io)
    print(io, weaved)

    outfile = joinpath(REPO, "docs", "_examples", slug * ".md")
    mkpath(dirname(outfile))
    write(outfile, String(take!(io)))
    @info "Rendered example" source=jmd output=outfile slug=slug
end

length(ARGS) == 1 || error("Usage: julia tools/render_example.jl <path-to.jmd | project-name>")
render(ARGS[1])
