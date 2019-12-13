using Eolas, Test

@test Vertex <: AbstractVertex
@test Vertex{Int} <: AbstractVertex{Int}
@test !(Vertex{Int} <: AbstractVertex{Float64})

@test_throws TypeError Vertex{Int, Vertex{Float64}}

let v = Vertex([1, 2], 0, Vertex{Int}[], Vertex{Int}[])
    @test name(v) == [1,2]
    @test payload(v) == 0
    @test above(v) == Vertex{Int}[]
    @test below(v) == Vertex{Int}[]
end

let v = Vertex([1,2], 1)
    @test name(v) == [1,2]
    @test payload(v) == 1
    @test above(v) == Vertex{Int}[]
    @test below(v) == Vertex{Int}[]
end

let v = Vertex{Int64}([1,2])
    @test name(v) == [1,2]
    @test payload(v) == 0
    @test above(v) == Vertex{Int}[]
    @test below(v) == Vertex{Int}[]
end
