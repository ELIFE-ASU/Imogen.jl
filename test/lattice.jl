include("lattice-vertices.jl")

macro testhasse(t, n, bottom, top)
    vertices = Symbol("VERTICES_$n")
    quote
        let h = Hasse{$t}($n)
            @test name(top(h)) == $top
            @test name(bottom(h)) == $bottom
            @test name.(vertices(h)) == $vertices
        end
    end
end

@testset "Vertices and Lattice" begin
    @test Vertex <: AbstractVertex
    @test Vertex{Int} <: AbstractVertex{Int}
    @test !(Vertex{Int} <: AbstractVertex{Float64})

    @test_throws TypeError Vertex{Int, Vertex{Float64}}

    let v = Vertex([1, 2], 2, Vertex{Int}[], Vertex{Int}[])
        @test name(v) == [1,2]
        @test payload(v) == 2
        @test above(v) == Vertex{Int}[]
        @test below(v) == Vertex{Int}[]
        @test string(v) == "Vertex([1, 2], 2)"
    end

    let v = Vertex([1,2], 1)
        @test name(v) == [1,2]
        @test payload(v) == 1
        @test above(v) == Vertex{Int}[]
        @test below(v) == Vertex{Int}[]
        @test string(v) == "Vertex([1, 2], 1)"
    end

    let v = Vertex{Int64}([1,2])
        @test name(v) == [1,2]
        @test payload(v) == 0
        @test above(v) == Vertex{Int}[]
        @test below(v) == Vertex{Int}[]
        @test string(v) == "Vertex([1, 2], 0)"
    end

    @test isbelow(Vertex{Int}([1,2]), Vertex{Int}([1]))
    @test isbelow(Vertex{Int}([1,2]), Vertex{Int}([3]))
    @test isbelow(Vertex{Int}([2]), Vertex{Int}([2]))
    @test isbelow(Vertex{Float64}([1,2,4]), Vertex{Float64}([7]))

    @test !isbelow(Vertex{Int}([1]), Vertex{Int}([2]))
    @test !isbelow(Vertex{Int}([2]), Vertex{Int}([1,2]))

    @test length(genvertices(Vertex{Int}, 1)) == 1
    @test length(genvertices(Vertex{Int}, 2)) == 4
    @test length(genvertices(Vertex{Int}, 3)) == 18
    @test length(genvertices(Vertex{Int}, 4)) == 166
    @test length(genvertices(Vertex{Int}, 5)) == 7579

    @test Set(name.(genvertices(Vertex{Int}, 1))) == Set(VERTICES_1)
    @test Set(name.(genvertices(Vertex{Int}, 2))) == Set(VERTICES_2)
    @test Set(name.(genvertices(Vertex{Int}, 3))) == Set(VERTICES_3)
    @test Set(name.(genvertices(Vertex{Int}, 4))) == Set(VERTICES_4)

    @test name.(toposort!(genvertices(Vertex{Int}, 1))) == VERTICES_1
    @test name.(toposort!(genvertices(Vertex{Int}, 2))) == VERTICES_2
    @test name.(toposort!(genvertices(Vertex{Int}, 3))) == VERTICES_3
    @test name.(toposort!(genvertices(Vertex{Int}, 4))) == VERTICES_4

    @testhasse Int 1 [1] [1]
    @testhasse Int 2 [1,2] [3]
    @testhasse Int 3 [1,2,4] [7]
    @testhasse Int 4 [1,2,4,8] [15]

    let h = Hasse{Int}(5)
        @test name(top(h)) == [31]
        @test name(bottom(h)) == [1,2,4,8,16]
    end
end
