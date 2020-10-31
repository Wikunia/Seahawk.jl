using Seahawk
using Test

@testset "Seahawk.jl" begin
@testset "Cosine" begin
    results = Seahawk.search(stdout, "cosine"; silent=true)
    # check if Base.cos was found
    found = false
    for result in results
        if result[2].name == "cos" && result[2].mod == "Base"
            found = true
            break
        end
    end
    Seahawk.print_results(results[1:2])
    @test found
end

@testset "Pkg.add" begin
    results = Seahawk.search(stdout, "add package"; silent=true)
    # check if Base.cos was found
    found = false
    for result in results
        if result[2].name == "add" && result[2].mod == "Pkg"
            found = true
            break
        end
    end
    @test found
end

@testset "Seahawk.search" begin
    results = Seahawk.search(stdout, "Search docstrings"; silent=true)
    # check if Base.cos was found
    found = false
    for result in results
        if result[2].name == "search" && result[2].mod == "Seahawk"
            found = true
            break
        end
    end
    @test found
end
end
