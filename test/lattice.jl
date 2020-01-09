include("lattice-vertices.jl")

macro testhasse(t, n::Int, bottom, top)
    vertices = Symbol("VERTICES_$n")
    quote
        let h = Hasse($t, $n)
            @test id(top(h)) == $top
            @test id(bottom(h)) == $bottom
            @test id.(vertices(h)) == $vertices
        end
    end
end

macro testhasse(t, vs, bottom, top)
    ws = eval(vs)
    vertices = Symbol("VERTICES_$(length(ws))")
    topname = [ws]
    bottomname = map(x -> [x], ws)
    quote
        let h = Hasse($t, $vs)
            @test id(top(h)) == $top
            @test name(top(h)) == $topname
            @test id(bottom(h)) == $bottom
            @test name(bottom(h)) == $bottomname
            @test id.(vertices(h)) == $vertices
        end
    end
end

@testset "Unnamed Lattice" begin
    @test UnnamedVertex <: AbstractUnnamedVertex
    @test UnnamedVertex{Int} <: AbstractUnnamedVertex{Int}
    @test !(UnnamedVertex{Int} <: AbstractUnnamedVertex{Float64})

    @test_throws TypeError UnnamedVertex{Int, UnnamedVertex{Float64}}

    let v = UnnamedVertex([1, 2], 2, UnnamedVertex{Int}[], UnnamedVertex{Int}[])
        @test id(v) == [1,2]
        @test payload(v) == 2
        @test above(v) == UnnamedVertex{Int}[]
        @test below(v) == UnnamedVertex{Int}[]
        @test string(v) == "UnnamedVertex([1, 2], 2)"
    end

    let v = UnnamedVertex([1,2], 1)
        @test id(v) == [1,2]
        @test payload(v) == 1
        @test above(v) == UnnamedVertex{Int}[]
        @test below(v) == UnnamedVertex{Int}[]
        @test string(v) == "UnnamedVertex([1, 2], 1)"
    end

    let v = UnnamedVertex{Int64}([1,2])
        @test id(v) == [1,2]
        @test payload(v) == 0
        @test above(v) == UnnamedVertex{Int}[]
        @test below(v) == UnnamedVertex{Int}[]
        @test string(v) == "UnnamedVertex([1, 2], 0)"
    end

    @test isbelow(UnnamedVertex{Int}([1,2]), UnnamedVertex{Int}([1]))
    @test isbelow(UnnamedVertex{Int}([1,2]), UnnamedVertex{Int}([3]))
    @test isbelow(UnnamedVertex{Int}([2]), UnnamedVertex{Int}([2]))
    @test isbelow(UnnamedVertex{Float64}([1,2,4]), UnnamedVertex{Float64}([7]))

    @test !isbelow(UnnamedVertex{Int}([1]), UnnamedVertex{Int}([2]))
    @test !isbelow(UnnamedVertex{Int}([2]), UnnamedVertex{Int}([1,2]))

    @test length(genvertices(UnnamedVertex{Int}, 1)) == 1
    @test length(genvertices(UnnamedVertex{Int}, 2)) == 4
    @test length(genvertices(UnnamedVertex{Int}, 3)) == 18
    @test length(genvertices(UnnamedVertex{Int}, 4)) == 166
    @test length(genvertices(UnnamedVertex{Int}, 5)) == 7579

    @test Set(id.(genvertices(UnnamedVertex{Int}, 1))) == Set(VERTICES_1)
    @test Set(id.(genvertices(UnnamedVertex{Int}, 2))) == Set(VERTICES_2)
    @test Set(id.(genvertices(UnnamedVertex{Int}, 3))) == Set(VERTICES_3)
    @test Set(id.(genvertices(UnnamedVertex{Int}, 4))) == Set(VERTICES_4)

    @test id.(toposort!(genvertices(UnnamedVertex{Int}, 1))) == VERTICES_1
    @test id.(toposort!(genvertices(UnnamedVertex{Int}, 2))) == VERTICES_2
    @test id.(toposort!(genvertices(UnnamedVertex{Int}, 3))) == VERTICES_3
    @test id.(toposort!(genvertices(UnnamedVertex{Int}, 4))) == VERTICES_4

    @testhasse Int 1 [1] [1]
    @testhasse Int 2 [1,2] [3]
    @testhasse Int 3 [1,2,4] [7]
    @testhasse Int 4 [1,2,4,8] [15]

    let h = Hasse(Int, 5)
        @test id(top(h)) == [31]
        @test id(bottom(h)) == [1,2,4,8,16]
    end

    @testset "clone" begin
        let v = UnnamedVertex([1], 1)
            w = UnnamedVertex([2], 2)
            x = UnnamedVertex([1,2], 3, UnnamedVertex{Int}[v,w], UnnamedVertex{Int}[])
            v.below = [x]
            w.below = [x]

            v′ = clone(v)
            x′ = clone(x)

            @test id(v) == [1]
            @test payload(v) == 1
            @test above(v) == UnnamedVertex{Int}[]
            @test below(v) == [x]

            @test id(v′) == [1]
            @test payload(v′) == 1
            @test above(v′) == UnnamedVertex{Int}[]
            @test below(v′) == UnnamedVertex{Int}[]

            @test id(x) == [1,2]
            @test payload(x) == 3
            @test above(x) == [v,w]
            @test below(x) == UnnamedVertex{Int}[]

            @test id(x′) == [1,2]
            @test payload(x′) == 3
            @test above(x′) == UnnamedVertex{Int}[]
            @test below(x′) == UnnamedVertex{Int}[]
        end
    end

    @testset "prune" begin
        let h = Hasse(Int, 3)
            @test_throws ErrorException prune(h)
        end
    end
end

@testset "Named Lattice" begin
    @test Vertex <: AbstractNamedVertex
    @test Vertex{Symbol,Int} <: AbstractNamedVertex{Symbol,Int}
    @test !(Vertex{Symbol,Int} <: AbstractNamedVertex{Symbol,Float64})
    @test !(Vertex{Symbol,Int} <: AbstractNamedVertex{String,Int})

    @test_throws TypeError Vertex{Symbol, Int, Vertex{Symbol,Float64}}
    @test_throws TypeError Vertex{Symbol, Int, Vertex{String,Int}}

    let v = Vertex([1, 2], [[:a],[:b]], 2, Vertex{Symbol,Int}[], Vertex{Symbol,Int}[])
        @test id(v) == [1,2]
        @test name(v) == [[:a],[:b]]
        @test payload(v) == 2
        @test above(v) == Vertex{Symbol,Int}[]
        @test below(v) == Vertex{Symbol,Int}[]
        @test string(v) == "Vertex([:a, :b], 2)"
    end

    let v = Vertex([3], [[:a,:b]], 1)
        @test id(v) == [3]
        @test name(v) == [[:a,:b]]
        @test payload(v) == 1
        @test above(v) == Vertex{Symbol,Int}[]
        @test below(v) == Vertex{Symbol,Int}[]
        @test string(v) == "Vertex([{:a, :b}], 1)"
    end

    let v = Vertex{Symbol,Int64}([1,6], [[:a],[:b,:c]])
        @test id(v) == [1,6]
        @test name(v) == [[:a],[:b,:c]]
        @test payload(v) == 0
        @test above(v) == Vertex{Symbol,Int}[]
        @test below(v) == Vertex{Symbol,Int}[]
        @test string(v) == "Vertex([:a, {:b, :c}], 0)"
    end

    @test isbelow(Vertex{Symbol,Int}([1,2], [[:a], [:b]]), Vertex{Symbol,Int}([1], [[:a]]))
    @test isbelow(Vertex{Symbol,Int}([1,2], [[:a], [:b]]), Vertex{Symbol,Int}([3], [[:a,:b]]))
    @test isbelow(Vertex{Symbol,Int}([2], [[:b]]), Vertex{Symbol,Int}([2], [[:b]]))
    @test isbelow(Vertex{Symbol,Float64}([1,2,4], [[:a],[:b],[:c]]), Vertex{Symbol,Float64}([7],[[:a,:b,:c]]))

    @test !isbelow(Vertex{Symbol,Int}([1], [[:a]]), Vertex{Symbol,Int}([2], [[:b]]))
    @test !isbelow(Vertex{Symbol,Int}([2], [[:b]]), Vertex{Symbol,Int}([1,2], [[:a],[:b]]))

    @test length(genvertices(Vertex{Symbol,Int}, [:a])) == 1
    @test length(genvertices(Vertex{Symbol,Int}, [:a,:b])) == 4
    @test length(genvertices(Vertex{Symbol,Int}, [:a,:b,:c])) == 18
    @test length(genvertices(Vertex{Symbol,Int}, [:a,:b,:c,:d])) == 166
    @test length(genvertices(Vertex{Symbol,Int}, [:a,:b,:c,:d,:e])) == 7579

    @test Set(id.(convert(Vector{UnnamedVertex{Int}}, genvertices(Vertex{Symbol,Int}, [:a])))) == Set(VERTICES_1)
    @test Set(id.(convert(Vector{UnnamedVertex{Int}}, genvertices(Vertex{Symbol,Int}, [:a,:b])))) == Set(VERTICES_2)
    @test Set(id.(convert(Vector{UnnamedVertex{Int}}, genvertices(Vertex{Symbol,Int}, [:a,:b,:c])))) == Set(VERTICES_3)
    @test Set(id.(convert(Vector{UnnamedVertex{Int}}, genvertices(Vertex{Symbol,Int}, [:a,:b,:c,:d])))) == Set(VERTICES_4)

    @test id.(convert(Vector{UnnamedVertex{Int}}, toposort!(genvertices(Vertex{Symbol,Int}, [:a])))) == VERTICES_1
    @test id.(convert(Vector{UnnamedVertex{Int}}, toposort!(genvertices(Vertex{Symbol,Int}, [:a,:b])))) == VERTICES_2
    @test id.(convert(Vector{UnnamedVertex{Int}}, toposort!(genvertices(Vertex{Symbol,Int}, [:a,:b,:c])))) == VERTICES_3
    @test id.(convert(Vector{UnnamedVertex{Int}}, toposort!(genvertices(Vertex{Symbol,Int}, [:a,:b,:c,:d])))) == VERTICES_4

    @testhasse Int [:a] [1] [1]
    @testhasse Int [:a,:b] [1,2] [3]
    @testhasse Int [:a,:b,:c] [1,2,4] [7]
    @testhasse Int [:a,:b,:c,:d] [1,2,4,8] [15]

    let h = Hasse(Int, [:a,:b,:c,:d,:e])
        @test id(top(h)) == [31]
        @test name(top(h)) == [[:a,:b,:c,:d,:e]]

        @test id(bottom(h)) == [1,2,4,8,16]
        @test name(bottom(h)) == [[:a],[:b],[:c],[:d],[:e]]
    end

    @testset "clone" begin
        let v = Vertex([1], [[:a]], 1)
            w = Vertex([2], [[:b]], 2)
            x = Vertex([1,2], [[:a,:b]], 3, Vertex{Symbol,Int}[v,w], Vertex{Symbol,Int}[])
            v.below = [x]
            w.below = [x]

            v′ = clone(v)
            x′ = clone(x)

            @test id(v) == [1]
            @test name(v) == [[:a]]
            @test payload(v) == 1
            @test above(v) == Vertex{Symbol,Int}[]
            @test below(v) == [x]

            @test id(v′) == [1]
            @test name(v) == [[:a]]
            @test payload(v′) == 1
            @test above(v′) == Vertex{Symbol,Int}[]
            @test below(v′) == Vertex{Symbol,Int}[]

            @test id(x) == [1,2]
            @test name(x) == [[:a, :b]]
            @test payload(x) == 3
            @test above(x) == [v,w]
            @test below(x) == Vertex{Symbol,Int}[]

            @test id(x′) == [1,2]
            @test name(x′) == [[:a, :b]]
            @test payload(x′) == 3
            @test above(x′) == Vertex{Symbol,Int}[]
            @test below(x′) == Vertex{Symbol,Int}[]
        end
    end

    @testset "prune" begin
        let h = Hasse(Int, [:a,:b,:c])
            @test_throws ErrorException prune(h)
        end
    end
end
