#!/usr/bin/env julia
#
# Render a project's Weave example into a Jekyll page under docs/_examples/.
#
# Usage:
#   julia tools/render_example.jl <project-name>
# e.g.
#   julia tools/render_example.jl example-template
#
# The example lives in projects/<name>/example.jmd and starts with a small YAML
# header (between --- lines) holding the page metadata, e.g.:
#
#   ---
#   title: Two-Area Four-Generator System (classical model)
#   summary: The simplest multimachine linear model.
#   post: /2024/09/06/some-post.html      # optional related diary post
#   post_title: My related post           # optional
#   ---
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

"Split a leading `--- ... ---` YAML header off the document; return (header, body)."
function split_header(text)
    lines = split(text, '\n')
    if !isempty(lines) && strip(lines[1]) == "---"
        closing = findnext(l -> strip(l) == "---", lines, 2)
        if closing !== nothing
            header = join(lines[2:closing-1], '\n')
            body = join(lines[closing+1:end], '\n')
            return header, body
        end
    end
    return "", text
end

"Parse a flat `key: value` block (no nesting). Lines starting with # are ignored."
function parse_flat_yaml(header)
    meta = Dict{String,String}()
    for line in split(header, '\n')
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

    header, body = split_header(read(jmd, String))
    meta = parse_flat_yaml(header)

    # Run the example in the project's own environment.
    Pkg.activate(project_dir)
    Pkg.instantiate()

    # Weave only the body (Weave never sees the metadata header). Write the body
    # to a temp file *inside the project dir* so relative paths (includes, data
    # files) resolve exactly as they do for the original example.jmd.
    tmpsrc = joinpath(project_dir, "_render_tmp.jmd")
    outdir = mktempdir()
    weaved = ""
    try
        write(tmpsrc, body)
        weave(tmpsrc; doctype = "github", out_path = outdir)
        weaved = read(joinpath(outdir, "_render_tmp.md"), String)
    finally
        isfile(tmpsrc) && rm(tmpsrc)
    end

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
