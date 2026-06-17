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
# Each .jmd starts with a small YAML header (between --- lines) holding the page
# metadata, e.g.:
#
#   ---
#   title: Two-Area Four-Generator System (classical model)
#   summary: The simplest multimachine linear model.
#   post: /2024/09/06/some-post.html      # optional related diary post
#   post_title: My related post           # optional
#   ---
#
# The code runs in the nearest enclosing project environment (the directory above
# the .jmd that contains a Project.toml), so results are reproducible. Weave is a
# build tool: install it once in your global environment with
#   julia -e 'using Pkg; Pkg.add("Weave")'

using Pkg
using Weave
using Dates

const REPO = normpath(joinpath(@__DIR__, ".."))

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

"Split a leading `--- ... ---` YAML header off the document; return (header, body)."
function split_header(text)
    lines = split(text, '\n')
    if !isempty(lines) && strip(lines[1]) == "---"
        closing = findnext(l -> strip(l) == "---", lines, 2)
        if closing !== nothing
            return join(lines[2:closing-1], '\n'), join(lines[closing+1:end], '\n')
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

to_url(p) = replace(p, '\\' => '/')

function render(arg)
    jmd = resolve_jmd(arg)
    jmd_dir = dirname(jmd)
    project_dir = find_project_dir(jmd_dir)

    # Page slug: the .jmd file name, or the project folder name for example.jmd.
    base = first(splitext(basename(jmd)))
    name = base == "example" ? basename(project_dir) : base

    header, body = split_header(read(jmd, String))
    meta = parse_flat_yaml(header)

    # Run the example in its project environment.
    Pkg.activate(project_dir)
    Pkg.instantiate()

    # Weave only the body (Weave never sees the metadata header). Write the body
    # to a temp file *next to the .jmd* and run from there, so relative paths
    # (includes, data files) resolve exactly as the author intended.
    tmpsrc = joinpath(jmd_dir, "_render_tmp.jmd")
    outdir = mktempdir()
    weaved = ""
    try
        write(tmpsrc, body)
        cd(jmd_dir) do
            weave(tmpsrc; doctype = "github", out_path = outdir)
        end
        weaved = read(joinpath(outdir, "_render_tmp.md"), String)
    finally
        isfile(tmpsrc) && rm(tmpsrc)
    end

    relproj     = to_url(relpath(project_dir, REPO))
    title       = get(meta, "title", name)
    summary     = get(meta, "summary", "")
    post        = get(meta, "post", "")
    post_title  = get(meta, "post_title", "blog post")
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

    outfile = joinpath(REPO, "docs", "_examples", name * ".md")
    mkpath(dirname(outfile))
    write(outfile, String(take!(io)))
    @info "Rendered example" source=jmd output=outfile slug=name
end

length(ARGS) == 1 || error("Usage: julia tools/render_example.jl <path-to.jmd | project-name>")
render(ARGS[1])
