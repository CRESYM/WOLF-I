#!/usr/bin/env julia
#
# Render a Weave .jmd into a Jekyll example page under docs/_examples/.
#
# Usage:
#   julia tools/render_jmd.jl <path-to.jmd>
#
# Example:
#   julia tools/render_jmd.jl projects/202505-Two-Area-Four-Gen-Linear-Model/2area4gen_clsgen.jmd
#
# A project may hold several .jmd files; each renders to its own page at
# /examples/<slug>/, where <slug> is the .jmd file name.
#
# Page metadata (title/summary/related post) is NOT kept in the .jmd — it lives
# in the METADATA table below, keyed by slug. Add an entry per page; a missing
# entry just falls back to defaults (title = slug, no summary). The code runs in
# the nearest enclosing project environment (the directory above the .jmd that
# contains a Project.toml), so results are reproducible. Weave is a build tool:
# install it once in your global environment with
#   julia -e 'using Pkg; Pkg.add("Weave")'

using Pkg
using Weave
using Dates

const REPO = normpath(joinpath(@__DIR__, ".."))

# Per-page metadata, keyed by slug (the .jmd file name). Optional: summary, post, post_title.
const METADATA = Dict{String,NamedTuple}(
    "2area4gen_clsgen" => (
        title = "Two-Area Four-Generator System (classical model)",
        summary = "The simplest multimachine linear model, using the classical synchronous machine model.",
    ),
    "2area4gen_detgen" => (
        title = "Two-Area Four-Generator System (detailed model)",
        summary = "Multimachine linear model using the detailed synchronous machine model.",
    ),
)

"Resolve the CLI argument to an absolute .jmd path."
function resolve_jmd(arg)
    isfile(arg) && return abspath(arg)
    error("Not a file: '$arg' — pass the path to a .jmd (e.g. projects/<name>/<file>.jmd).")
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

    slug = first(splitext(basename(jmd)))
    meta = get(METADATA, slug, NamedTuple())

    # Run the .jmd in its project environment.
    Pkg.activate(project_dir)
    Pkg.instantiate()

    # Weave with out_path = :doc so Weave runs the code with the .jmd's own
    # directory as the working directory — relative includes and data paths
    # (e.g. "data/bs_2area4gen.m") resolve as the author intended. Weave writes
    # the .md next to the .jmd; we read it and then remove it.
    weaved_md = joinpath(jmd_dir, slug * ".md")
    weaved = ""
    try
        weave(jmd; doctype = "github", out_path = :doc)
        weaved = read(weaved_md, String)
    finally
        isfile(weaved_md) && rm(weaved_md)
    end

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
    @info "Rendered example page" source=jmd output=outfile slug=slug
end

# Auto-run only when executed as a script (julia tools/render_jmd.jl <arg>).
# When included in the REPL this is skipped, so you can call render("…") directly:
#   julia> include("tools/render_jmd.jl")
#   julia> render("projects/<name>/<file>.jmd")
if abspath(PROGRAM_FILE) == @__FILE__
    length(ARGS) == 1 || error("Usage: julia tools/render_jmd.jl <path-to.jmd>")
    render(ARGS[1])
end
