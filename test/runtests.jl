using Eolas, Test

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

@test Eolas.isbelow(Vertex{Int}([1,2]), Vertex{Int}([1]))
@test Eolas.isbelow(Vertex{Int}([1,2]), Vertex{Int}([3]))
@test Eolas.isbelow(Vertex{Int}([2]), Vertex{Int}([2]))
@test Eolas.isbelow(Vertex{Float64}([1,2,4]), Vertex{Float64}([7]))

@test !Eolas.isbelow(Vertex{Int}([1]), Vertex{Int}([2]))
@test !Eolas.isbelow(Vertex{Int}([2]), Vertex{Int}([1,2]))
