module Seahawk

using Base.Docs: modules, DocStr, MultiDoc, parsedoc
using CodeTracking
using DocSeeker
using REPL: doc, meta, stripmd
using ReplMaker
using Markdown: MD

const DESCRIPTION_LIMIT = 80

search(string) = search(stdout, string)
function search(io::IO, needle)
    search_results = searchdocs(needle)
    print_results(search_results)
end

flatten(md::MD) = MD(flat_content(md))

# Faster version

function flat_content!(xs, out = [])
  for x in xs
    if isa(x, MD)
      flat_content!(x.content, out)
    else
      push!(out, x)
    end
  end
  return out
end

flat_content(md::MD) = flat_content!(md.content)

function strlimit(str::AbstractString, limit::Integer = 30, ellipsis::AbstractString = "…")
    will_append = length(str) > limit
  
    io = IOBuffer()
    i = 1
    for c in str
      will_append && i > limit - length(ellipsis) && break
      isvalid(c) || continue
  
      print(io, c)
      i += 1
    end
    will_append && print(io, ellipsis)
  
    return String(take!(io))
end

description(docs) = ""
description(docs::MD) = begin
  md = flatten(docs).content
  for part in md
    if part isa Markdown.Paragraph
      desc = Markdown.plain(part)
      occursin("No documentation found.", desc) && return ""
      return strip(strlimit(desc, DESCRIPTION_LIMIT))
    end
  end
  return ""
end

function print_results(search_results)
    for search_result in reverse(search_results)
        print_result(search_result[2])
    end
end

function print_result(res::DocSeeker.DocObj)
    path = CodeTracking.maybe_fix_path(res.path)
    summary = description(res.html)
    printstyled(res.name; color=:green)
    print(" in ")
    printstyled(res.mod; color=:green)
    print(" at ")
    printstyled("$path:$(res.line)"; color=:blue)
    println()
    println(summary)
end

function __init__()
    initrepl(search, 
            prompt_text="Seahawk> ",
            prompt_color = :white, 
            start_key='/', 
            mode_name="Search mode")
end

end
