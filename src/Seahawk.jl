module Seahawk

using Base.Docs: modules, DocStr, MultiDoc, parsedoc
using CodeTracking
using REPL: doc, meta, stripmd
using ReplMaker
using Markdown

struct SearchResult
    doc::DocStr
    text :: AbstractString
    summary :: AbstractString
    relevance :: Float64
end

function searchdoc!(search_results, haystack::MultiDoc, needle)
    for v in values(haystack.docs)
        searchdoc!(search_results, v, needle) && return true
    end
    false
end

function searchdoc!(search_results, haystack::DocStr, needle)
    searchdoc!(search_results, haystack, parsedoc(haystack), needle) && return true
    if haskey(haystack.data, :fields)
        for doc in values(haystack.data[:fields])
            searchdoc!(search_results, haystack, doc, needle) && return true
        end
    end
    false
end

## Markdown search simply strips all markup and searches plain text version
searchdoc!(search_results, doc, haystack::Markdown.MD, needle) = 
    searchdoc!(search_results, doc, stripmd(haystack.content), needle)

function searchdoc!(search_results, doc, haystack::AbstractString, needle)
    pos = findfirst(needle, haystack)
    pos === nothing && return false
    push!(search_results, SearchResult(doc, haystack, haystack, 0.0))
    return true
end

search(string) = search(stdout, string)
function search(io::IO, needle)
    search_results = Vector{SearchResult}()
    for mod in modules
        # Module doc might be in README.md instead of the META dict
        # searchdoc!(search_results, doc(mod), needle)
        for (k, v) in meta(mod)
            searchdoc!(search_results, v, needle)
        end
    end
    print_results(search_results)
end

function print_results(search_results)
    for search_result in search_results
        print_result(search_result)
    end
end

function print_result(res::SearchResult)
    data = res.doc.data
    path = CodeTracking.maybe_fix_path(data[:path])
    printstyled(data[:binding]; color=:green)
    print(" with ")
    printstyled(data[:typesig]; color=:green)
    print(" in ")
    printstyled("$path:$(data[:linenumber])"; color=:blue)
    println()
end

function __init__()
    initrepl(search, 
            prompt_text="Seahawk> ",
            prompt_color = :white, 
            start_key='/', 
            mode_name="Search mode")
end

end
