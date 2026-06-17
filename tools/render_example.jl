#!/usr/bin/env julia
#
# Render a project's Weave example into a Jekyll page under docs/_examples/.
#
# Usage:
#   julia tools/render_example.jl <project-name>
# e.g.
#   julia tools/render_example.jl example-template
#
# The example's own code runs in projects/<name>/ using that project's
# Project.toml/Manifest.toml, so results are reproducible. Weave itself is a
# build tool: install it once in your global environment with
#   julia -e 'using Pkg; Pkg.add("Weave")'
# Julia's stacked environments make it available while the project env is active.

using Pkg
using Weave
using Dates

const REPO = normpath(joinpath(@__DIR__, ".."))

"Parse a flat `key: value` metadata file (no nesting). Lines starting with # are ignored."
function parse_meta(path)
    meta = Dict{String,String}()
    isfile(path) || return meta
    for line in eachline(path)
        s = strip(line)
        (isempty(s) || startswith(s, "#")) && continue
        idx = findfirst(==(':'), s)
        idx === nothing && continue
        key = strip(s[1:idx-1])
        val = strip(strip(s[idx+1:end]), ['"'])
        meta[String(key)] = String(val)
    end
    return meta
end

git_commit(repo) = try
    readchomp(`git -C $repo rev-parse --short HEAD`)
catch
    ""
end

function render(name)
    project_dir = joinpath(REPO, "projects", name)
    jmd = joinpath(project_dir, "example.jmd")
    isfile(jmd) || error("No example.jmd found in $project_dir")
    meta = parse_meta(joinpath(project_dir, "example.yml"))

    # Run the example in the project's own environment.
    Pkg.activate(project_dir)
    Pkg.instantiate()

    # Weave to a temporary dir, then wrap with Jekyll front matter.
    outdir = mktempdir()
    weave(jmd; doctype = "github", out_path = outdir)
    weaved = read(joinpath(outdir, "example.md"), String)

    title       = get(meta, "title", name)
    summary     = get(meta, "summary", "")
    post        = get(meta, "post", "")
    post_title  = get(meta, "post_title", "blog post")
    project_url = "https://github.com/CRESYM/WOLF-I/tree/main/projects/$name"

    io = IOBuffer()
    println(io, "---")
    println(io, "layout: example")
    println(io, "title: \"", title, "\"")
    isempty(summary) || println(io, "summary: \"", summary, "\"")
    println(io, "project: ", project_url)
    println(io, "project_name: projects/", name)
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

    outfile = joinpath(REPO, "docs", "_examples", name * ".md")
    mkpath(dirname(outfile))
    write(outfile, String(take!(io)))
    @info "Rendered example" source=jmd output=outfile
end

length(ARGS) == 1 || error("Usage: julia tools/render_example.jl <project-name>")
render(ARGS[1])
