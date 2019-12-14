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

@test length(Eolas.vertices(Vertex{Int}, 1)) == 1
@test length(Eolas.vertices(Vertex{Int}, 2)) == 4
@test length(Eolas.vertices(Vertex{Int}, 3)) == 18
@test length(Eolas.vertices(Vertex{Int}, 4)) == 166
@test length(Eolas.vertices(Vertex{Int}, 5)) == 7579

@test Set(name.(Eolas.vertices(Vertex{Int}, 1))) == Set([[1]])
@test Set(name.(Eolas.vertices(Vertex{Int}, 2))) == Set([[1,2], [1], [2], [3]])
@test Set(name.(Eolas.vertices(Vertex{Int}, 3))) == Set([
    [1,2,4], [1,4], [1,2], [2,4], [2,5], [1,6], [3,4], [2], [3,5,6], [1], [4],
    [3,6], [3,5], [5,6], [5], [3], [6], [7]
])

@test Set(name.(Eolas.vertices(Vertex{Int}, 4))) == Set([
    [1,2,4,8], [1,4,8], [1,2,8], [1,2,4], [2,4,8], [1,6,8], [1,4,10], [1,2,12],
    [2,5,8], [2,4,9], [3,4,8], [1,4], [1,2], [2,8], [2,5,9,12], [2,4],
    [1,6,10,12], [3,5,6,8], [3,4,9,10], [1,8], [4,8], [2,9,12], [2,5,12],
    [2,5,9], [1,6,10], [1,6,12], [1,10,12], [3,6,8], [3,5,8], [3,5,6,9,10,12],
    [3,4,10], [3,4,9], [4,9,10], [5,6,8], [3,8], [3,6,9,10,12], [2,12],
    [3,5,9,10,12], [1,6], [3,5,6,10,12], [3,5,6,9,12], [3,5,6,9,10], [1,10],
    [3,4], [2,5], [1,12], [4,10], [4,9], [2,9], [5,8], [5,6,9,10,12], [6,8],
    [3,6,10,12], [3,6,9,12], [3,6,9,10], [3,5,10,12], [3,5,9,12], [3,5,9,10],
    [3,5,6,12], [3,5,6,10], [3,5,6,9], [1,14], [3,9,10,12], [4,11], [2,13],
    [5,9,10,12], [5,6,10,12], [5,6,9,12], [5,6,9,10], [6,9,10,12], [7,8],
    [3,5,12], [3,10,12], [3,5,10], [3,9,12], [3,9,10], [3,6,9], [1], [2], [4],
    [3,5,9,14], [5,10,12], [5,9,12], [5,9,10], [3,6,12], [5,6,11,12], [5,6,10],
    [5,6,9], [6,10,12], [6,9,12], [6,9,10], [3,5,6], [3,6,10,13], [7,9,10,12],
    [8], [5,10], [3,9,14], [5,9,14], [3,10,13], [3,5,9], [5,6,12], [5,6,11],
    [3,6,13], [3,12], [3,6,10], [6,11,12], [6,10,13], [3,5,14], [6,9],
    [7,10,12], [7,9,12], [7,9,10], [5,11,12], [9,10,12], [6,12], [6,11,13],
    [6,10], [3,6], [3,13,14], [5,12], [7,11,12], [7,10,13], [5,9], [7,9,14],
    [5,6], [3,10], [5,11,14], [3,5], [3,9], [9,12], [9,10], [10,12], [7,12],
    [7,11,13,14], [7,10], [3,14], [6,11], [7,9], [6,13], [5,14], [3,13],
    [5,11], [9,14], [10,13], [11,12], [6], [9], [7,11,14], [3], [10], [5],
    [7,13,14], [11,13,14], [7,11,13], [12], [7,13], [11,14], [11,13], [7,11],
    [7,14], [13,14], [11], [13], [7], [14], [15]
])
