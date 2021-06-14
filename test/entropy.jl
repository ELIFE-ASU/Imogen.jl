@testset "Entropy" begin
    @test_throws MethodError Entropy()
    @test_throws MethodError Entropy(0.0)
    @test_throws MethodError Entropy(0, 1.0)
    for b in -2:0
        @test_throws ArgumentError Entropy(b, 2)
        @test_throws ArgumentError Entropy(2, b)
    end

    let dist = Entropy(2)
        @test dist.data == zeros(Int, 2)
        @test dist.bs == (2,)
        @test dist.N == 0
    end

    let dist = Entropy(2, 3)
        @test dist.data == zeros(Int, 6)
        @test dist.bs == (2, 3)
        @test dist.N == 0
    end

    let dist = Entropy(3)
        observe!(dist, [1,2,3,2,3])
        @test dist.data == [1,2,2]
        @test dist.bs == (3,)
        @test dist.N == 5
    end

    let dist = Entropy(3)
        observe!(dist, [1 2 3 2 3])
        @test dist.data == [1,2,2]
        @test dist.bs == (3,)
        @test dist.N == 5
    end

    let dist = Entropy(2, 2)
        observe!(dist, [2 1 2 1; 1 1 2 2])
        @test dist.data == [1,1,1,1]
        @test dist.bs == (2, 2)
        @test dist.N == 4
    end

    let dist = Entropy(2, 3)
        data = zeros(Int, 2, 4, 3)
        data[:,:,1] = [1 1 1 1; 2 2 2 2]
        data[:,:,2] = [1 2 2 2; 1 3 3 2]
        data[:,:,3] = [1 1 1 1; 2 2 2 2]

        observe!(dist, data)

        @test dist.data == [1,0,8,1,0,2]
        @test dist.bs == (2, 3)
        @test dist.N == 12
    end

    let dist = Entropy(2, 3)
        observe!(dist, [1 1 1 1; 2 2 2 2])
        observe!(dist, [1 2 2 2; 1 3 3 2])
        @test dist.data == [1,0,4,1,0,2]
        @test dist.bs == (2, 3)
        @test dist.N == 8
    end

    @test_throws ArgumentError Entropy(Int[])
    @test_throws ArgumentError Entropy(zeros(Int, 0, 0))
    @test_throws ArgumentError Entropy([1,2,0])
    @test_throws ArgumentError Entropy([0 1 1; 1 1 2])
    @test_throws ArgumentError Entropy([2 1 1; 0 1 2])

    let dist = Entropy([1 1 1 1 1 2 2 2; 2 2 2 2 1 1 2 2])
        @test dist.data == [1,1,4,2]
        @test dist.bs == (2, 2)
        @test dist.N == 8
    end

    let dist = Entropy([1 1 1 1 1 1 1 1; 2 2 2 2 1 1 2 2])
        @test dist.data == [2,6]
        @test dist.bs == (1,2)
        @test dist.N == 8
    end

    let data = zeros(Int, 2, 5, 3)
        data[:,:,1] = [1 1 1 1 1; 2 2 2 2 2]
        data[:,:,2] = [1 2 2 1 1; 3 3 2 2 1]
        data[:,:,3] = [1 1 1 3 3; 1 1 1 2 2]

        dist = Entropy(data)

        @test dist.data == [4,0,0,6,1,2,1,1,0]
        @test dist.bs == (3, 3)
        @test dist.N == 15
    end

    @test_throws BoundsError observe!(Entropy(2), [1 2 3])
    @test_throws BoundsError observe!(Entropy(2), [1,2,3])
    @test_throws BoundsError observe!(Entropy(2, 2), [1 2 3; 1 2 3])

    let dist = observe!(Entropy(2), [1,2,2,1,1])
        clear!(dist)
        @test dist.data == zeros(Int, 2)
        @test dist.bs == (2,)
        @test dist.N == 0
    end

    let dist = observe!(Entropy(2, 2), [1 1 2 2; 1 2 1 2])
        clear!(dist)
        @test dist.data == zeros(Int, 4)
        @test dist.bs == (2,2)
        @test dist.N == 0
    end

    let data = zeros(Int, 2, 5, 3)
        data[:,:,1] = [1 1 1 1 1; 2 2 2 2 2]
        data[:,:,2] = [1 2 2 1 1; 3 3 2 2 1]
        data[:,:,3] = [1 1 1 3 3; 1 1 1 2 2]

        dist = Entropy(data)
        clear!(dist)

        @test dist.data == zeros(Int, 9)
        @test dist.bs == (3, 3)
        @test dist.N == 0
    end

    let xs = [1 1 1 1 2 2 2 2;
              2 2 2 2 1 1 1 1]
        @test entropy(xs) ≈ 1.0 atol=1e-6
    end

    let xs = [1 1 2 2 2 2 1 1 1;
              2 2 1 1 1 1 2 2 2]
        @test entropy(xs) ≈ 0.991076 atol=1e-6
    end

    let xs = [2 2 1 2 1 2 2 2 1;
              2 2 1 1 1 2 1 2 2]
        @test entropy(xs) ≈ 1.836592 atol=1e-6
    end

    let xs = [1 1 1 1 1 1 1 1 1;
              2 2 2 1 1 1 2 2 2]
        @test entropy(xs) ≈ 0.918296 atol=1e-6
    end

    let xs = [2 2 2 2 1 1 1 1 2;
              2 2 2 1 1 1 2 2 2]
        @test entropy(xs) ≈ 1.836592 atol=1e-6
    end

    let xs = [2 2 1 1 2 2 1 1 2;
              2 2 2 1 1 1 2 2 2]
        @test entropy(xs) ≈ 1.891061 atol=1e-6
    end

    let xs = [1 2 1 2 1 2 2 2 2]
        @test entropy(xs) ≈ 0.918296 atol=1e-6
    end

    let xs = [1,2,1,2,1,2,2,2,2]
        @test entropy(xs) ≈ 0.918296 atol=1e-6
    end

    let xs = [1,2,3,1,2,3,1,1,3]
        @test entropy(xs) ≈ 1.530493 atol=1e-6
    end

    let xs = zeros(Int, 1, 5, 2)
        xs[:,:,1] = [1,2,1,2,1]
        xs[:,:,2] = [1,2,3,2,1]

        @test entropy(xs) ≈ 1.360964 atol=1e-6
    end

    let xs = zeros(Int, 2, 9, 2)
        xs[:,:,1] = [2 2 1 1 2 2 1 1 2;
                     2 2 2 1 1 1 2 2 2]
        xs[:,:,2] = [1 1 1 1 1 1 1 1 1;
                     2 2 2 1 1 1 2 2 2]

        @test entropy(xs) ≈ 1.765246 atol=1e-6
    end
end
