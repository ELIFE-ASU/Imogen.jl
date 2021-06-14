@testset "Mutual Information" begin
    @test_throws MethodError MutualInfo(0.5, 1.0)
    @test_throws MethodError MutualInfo(tuple(), 3)
    @test_throws MethodError MutualInfo(3, tuple())
    @test_throws MethodError MutualInfo(tuple(), tuple())
    @test_throws MethodError MutualInfo(3, (1.3,))
    for b in -2:1
        @test_throws ArgumentError MutualInfo(b, 2)
        @test_throws ArgumentError MutualInfo(2, b)
    end

    let mi = MutualInfo(2, 3)
        @test mi.joint == zeros(Int, 2, 3)
        @test mi.m1 == zeros(Int, 2)
        @test mi.m2 == zeros(Int, 3)
        @test mi.b1 == (2,)
        @test mi.b2 == (3,)
        @test mi.N == zero(Int)
    end

    let mi = MutualInfo((2, 2), 3)
        @test mi.joint == zeros(Int, 4, 3)
        @test mi.m1 == zeros(Int, 4)
        @test mi.m2 == zeros(Int, 3)
        @test mi.b1 == (2, 2)
        @test mi.b2 == (3,)
        @test mi.N == 0
    end

    let mi = MutualInfo(3, (2, 2))
        @test mi.joint == zeros(Int, 3, 4)
        @test mi.m1 == zeros(Int, 3)
        @test mi.m2 == zeros(Int, 4)
        @test mi.b1 == (3,)
        @test mi.b2 == (2, 2)
        @test mi.N == 0
    end

    let mi = MutualInfo(2, 2)
        observe!(mi, [2,1,2,1], [1,1,2,2])
        @test mi.joint == [1 1; 1 1]
        @test mi.m1 == [2, 2]
        @test mi.m2 == [2, 2]
        @test mi.b1 == (2,)
        @test mi.b2 == (2,)
        @test mi.N == 4
    end

    let mi = MutualInfo(3, 2)
        observe!(mi, [1,2,3,1,2,3], [1,1,2,2,1,2])
        @test mi.joint == [1 1; 2 0; 0 2]
        @test mi.m1 == [2, 2, 2]
        @test mi.m2 == [3, 3]
        @test mi.b1 == (3,)
        @test mi.b2 == (2,)
        @test mi.N == 6
    end

    let mi = MutualInfo(2, 2)
        observe!(mi, [1,1,1,1], [2,2,2,2])
        observe!(mi, [1,2,2,2], [1,1,2,2])
        @test mi.joint == [1 4; 1 2]
        @test mi.m1 == [5, 3]
        @test mi.m2 == [2, 6]
        @test mi.N == 8
    end

    let mi = MutualInfo(2, 2)

        xs = zeros(Int, 1, 4, 2)
        xs[:,:,1] = [1,1,1,1]
        xs[:,:,2] = [1,2,2,2]

        ys = zeros(Int, 1, 4, 2)
        ys[:,:,1] = [2,2,2,2]
        ys[:,:,2] = [1,1,2,2]

        observe!(mi, xs, ys)

        @test mi.joint == [1 4; 1 2]
        @test mi.m1 == [5, 3]
        @test mi.m2 == [2, 6]
        @test mi.N == 8
    end

    let mi = MutualInfo((2,2), (2,2))
        observe!(mi, [1 1 2 2; 1 2 1 2], [2 1 2 1; 1 1 1 1])
        @test mi.joint == [0 1 0 0; 0 1 0 0; 1 0 0 0; 1 0 0 0]
        @test mi.m1 == [1,1,1,1]
        @test mi.m2 == [2,2,0,0]
        @test mi.b1 == (2,2)
        @test mi.b2 == (2,2)
        @test mi.N == 4
    end

    let mi = MutualInfo((2,2), (2,2))
        observe!(mi, [1 2 2 1; 1 1 2 2], [1 1 2 1; 2 1 1 2])
        @test mi.joint == [0 0 1 0; 1 0 0 0; 0 0 1 0; 0 1 0 0]
        @test mi.m1 == [1,1,1,1]
        @test mi.m2 == [1,1,2,0]
        @test mi.b1 == (2,2)
        @test mi.b2 == (2,2)
        @test mi.N == 4
    end

    let mi = MutualInfo((2,2), (2,2))
        xs = zeros(Int, 2, 4, 2)
        xs[:,:,1] = [1 1 2 2; 1 2 1 2]
        xs[:,:,2] = [1 2 2 1; 1 1 2 2]

        ys = zeros(Int, 2, 4, 2)
        ys[:,:,1] = [2 1 2 1; 1 1 1 1]
        ys[:,:,2] = [1 1 2 1; 2 1 1 2]

        observe!(mi, xs, ys)

        @test mi.joint == [0 1 1 0; 1 1 0 0; 1 0 1 0; 1 1 0 0]
        @test mi.m1 == [2,2,2,2]
        @test mi.m2 == [3,3,2,0]
        @test mi.b1 == (2,2)
        @test mi.b2 == (2,2)
        @test mi.N == 8
    end

    @test_throws ArgumentError MutualInfo([0,1,1], [1,1,2])
    @test_throws ArgumentError MutualInfo([2,1,1], [0,1,2])
    @test_throws ArgumentError MutualInfo(Int[], Int[])
    @test_throws ArgumentError MutualInfo(Int[], [1,2])
    @test_throws ArgumentError MutualInfo([1,2], Int[])
    @test_throws ArgumentError MutualInfo([1,2,2], [1,2])
    @test_throws ArgumentError MutualInfo([1,2], [1,2,2])
    @test_throws ArgumentError MutualInfo(ones(Int, 3, 5), ones(Int, 3, 2))
    @test_throws ArgumentError MutualInfo(ones(Int, 3, 2), ones(Int, 3, 5))
    @test_throws ArgumentError MutualInfo(ones(Int, 3, 5, 7), ones(Int, 3, 5, 6))
    @test_throws ArgumentError MutualInfo(ones(Int, 3, 5, 7), ones(Int, 3, 4, 7))

    let mi = MutualInfo([1,1,1,1,1,2,2,2], [2,2,2,2,1,1,2,2])
        @test mi.joint == [1 4; 1 2]
        @test mi.m1 == [5, 3]
        @test mi.m2 == [2, 6]
        @test mi.b1 == (2,)
        @test mi.b2 == (2,)
        @test mi.N == 8
    end

    let mi = MutualInfo([1,1,1,1,1,1,1,1], [2,2,2,2,1,1,2,2])
        @test mi.joint == [2 6; 0 0]
        @test mi.m1 == [8, 0]
        @test mi.m2 == [2, 6]
        @test mi.b1 == (2,)
        @test mi.b2 == (2,)
        @test mi.N == 8
    end

    let xs = zeros(Int, 1, 4, 2)
        xs[:,:,1] = [1,1,1,1]
        xs[:,:,2] = [1,2,2,2]

        ys = zeros(Int, 1, 4, 2)
        ys[:,:,1] = [2,2,2,2]
        ys[:,:,2] = [1,1,2,2]

        mi = MutualInfo(xs, ys)

        @test mi.joint == [1 4; 1 2]
        @test mi.m1 == [5, 3]
        @test mi.m2 == [2, 6]
        @test mi.N == 8
    end

    let xs = [1 1 2 2; 1 2 1 2]
        ys = [2 1 2 1; 1 1 1 1]

        mi = MutualInfo(xs, ys)

        @test mi.joint == [0 1 0 0; 0 1 0 0; 1 0 0 0; 1 0 0 0]
        @test mi.m1 == [1,1,1,1]
        @test mi.m2 == [2,2,0,0]
        @test mi.N == 4
    end

    let xs = [1 2 2 1; 1 1 2 2]
        ys = [1 1 2 1; 2 1 1 2]

        mi = MutualInfo(xs, ys)

        @test mi.joint == [0 0 1 0; 1 0 0 0; 0 0 1 0; 0 1 0 0]
        @test mi.m1 == [1,1,1,1]
        @test mi.m2 == [1,1,2,0]
        @test mi.N == 4
    end

    let xs = zeros(Int, 2, 4, 2)
        xs[:,:,1] = [1 1 2 2; 1 2 1 2]
        xs[:,:,2] = [1 2 2 1; 1 1 2 2]

        ys = zeros(Int, 2, 4, 2)
        ys[:,:,1] = [2 1 2 1; 1 1 1 1]
        ys[:,:,2] = [1 1 2 1; 2 1 1 2]

        mi = MutualInfo(xs, ys)

        @test mi.joint == [0 1 1 0; 1 1 0 0; 1 0 1 0; 1 1 0 0]
        @test mi.m1 == [2,2,2,2]
        @test mi.m2 == [3,3,2,0]
        @test mi.N == 8
    end

    @test_throws ArgumentError observe!(MutualInfo(2,2), [1,2,3], [1,2])
    @test_throws ArgumentError observe!(MutualInfo(2, 2), [0,1,0,1], [0,0,1,1])
    @test_throws BoundsError observe!(MutualInfo(2, 2), [2,3,2,3], [2,2,3,3])

    let mi = observe!(MutualInfo(2, 2), [1,1,2,2], [1,2,1,2])
        clear!(mi)
        @test mi.joint == zeros(Int, 2, 2)
        @test mi.m1 == zeros(Int, 2)
        @test mi.m2 == zeros(Int, 2)
        @test mi.b1 == (2,)
        @test mi.b2 == (2,)
        @test mi.N == zero(Int)
    end

    let mi = observe!(MutualInfo((2,2), (2,3)),
                      [1 1 2 2 1 1; 1 2 1 2 2 1],
                      [1 1 1 1 2 2; 2 3 2 1 1 3])
        clear!(mi)
        @test mi.joint == zeros(Int, 4, 6)
        @test mi.m1 == zeros(Int, 4)
        @test mi.m2 == zeros(Int, 6)
        @test mi.b1 == (2,2)
        @test mi.b2 == (2,3)
        @test mi.N == 0
    end

    let xs = zeros(Int, 2, 4, 2)
        xs[:,:,1] = [1 1 2 2; 1 2 1 2]
        xs[:,:,2] = [1 2 2 1; 1 1 2 2]

        ys = zeros(Int, 2, 4, 2)
        ys[:,:,1] = [2 1 2 1; 1 1 1 1]
        ys[:,:,2] = [1 1 2 1; 2 1 1 2]

        mi = observe!(MutualInfo((2,2), (2,2)), xs, ys)
        clear!(mi)

        @test mi.joint == zeros(Int, 4, 4)
        @test mi.m1 == zeros(Int, 4)
        @test mi.m2 == zeros(Int, 4)
        @test mi.N == 0
    end

    let as = [1,1,1,1,2,2,2,2]
        bs = [2,2,2,2,1,1,1,1]
        @test mutualinfo(as, bs) ≈ 1.0 atol=1e-6
        @test mutualinfo(bs, as) ≈ 1.0 atol=1e-6
    end

    let as = [1,1,2,2,2,2,1,1,1]
        bs = [2,2,1,1,1,1,2,2,2]
        @test mutualinfo(as, bs) ≈ 0.991076 atol=1e-6
        @test mutualinfo(bs, as) ≈ 0.991076 atol=1e-6
    end

    let as = [2,2,1,2,1,2,2,2,1]
        bs = [2,2,1,1,1,2,1,2,2]
        @test mutualinfo(as, bs) ≈ 0.072780 atol=1e-6
        @test mutualinfo(bs, as) ≈ 0.072780 atol=1e-6
    end

    let as = [1,1,1,1,1,1,1,1,1]
        bs = [2,2,2,1,1,1,2,2,2]
        @test mutualinfo(as, bs) ≈ 0.0 atol=1e-6
        @test mutualinfo(bs, as) ≈ 0.0 atol=1e-6
    end

    let as = [2,2,2,2,1,1,1,1,2]
        bs = [2,2,2,1,1,1,2,2,2]
        @test mutualinfo(as, bs) ≈ 0.072780 atol=1e-6
        @test mutualinfo(bs, as) ≈ 0.072780 atol=1e-6
    end

    let as = [2,2,1,1,2,2,1,1,2]
        bs = [2,2,2,1,1,1,2,2,2]
        @test mutualinfo(as, bs) ≈ 0.018311 atol=1e-6
        @test mutualinfo(bs, as) ≈ 0.018311 atol=1e-6
    end

    let as = [2 2 2 2 1 1 1 1 2;
              2 2 1 1 2 2 1 1 2]
        bs = [2 2 2 1 1 1 2 2 2;
              2 2 2 1 1 1 2 2 2]
        mi = MutualInfo(2, 2)
        @test mutualinfo!(mi, as[1,:], bs[1,:]) ≈ 0.072780 atol=1e-6
        @test mutualinfo!(mi, as[2,:], bs[2,:]) ≈ 0.004497 atol=1e-6
    end

    let as = zeros(Int, 1, 9, 2)
        as[:,:,1] = [2,2,2,2,1,1,1,1,2]
        as[:,:,2] = [2,2,1,1,2,2,1,1,2]

        bs = zeros(Int, 1, 9, 2)
        bs[:,:,1] = [2,2,2,1,1,1,2,2,2]
        bs[:,:,2] = [2,2,2,1,1,1,2,2,2]

        @test mutualinfo(as, bs) ≈ 0.004497 atol=1e-6
        @test mutualinfo(bs, as) ≈ 0.004497 atol=1e-6
    end

    let as = [2 2 2 2 1 1 1 1 2;
              2 2 1 1 2 2 1 1 2]
        bs = [2 2 2 1 1 1 2 2 2;
              2 2 2 1 1 1 2 2 2]

        @test mutualinfo(as, bs) ≈ 0.696074 atol=1e-6
        @test mutualinfo(bs, as) ≈ 0.696074 atol=1e-6
    end

    let as = [2 1 2 2 1 2 2 1 2;
              2 2 1 1 2 2 1 1 2]
        bs = [2 2 2 1 1 1 2 2 2;
              2 1 2 1 2 1 2 1 2]

        @test mutualinfo(as, bs) ≈ 1.002172 atol=1e-6
        @test mutualinfo(bs, as) ≈ 1.002172 atol=1e-6
    end

    let as = zeros(Int, 2, 9, 2)
        as[:,:,1] = [2 1 2 2 1 2 2 1 2;
                     2 2 1 1 2 2 1 1 2]
        as[:,:,2] = [2 2 2 2 1 1 1 1 2;
                     2 2 1 1 2 2 1 1 2]

        bs = zeros(Int, 2, 9, 2)
        bs[:,:,1] = [2 2 2 1 1 1 2 2 2;
                     2 1 2 1 2 1 2 1 2]
        bs[:,:,2] = [2 2 2 1 1 1 2 2 2;
                     2 2 2 1 1 1 2 2 2]

        @test mutualinfo(as, bs) ≈ 0.595553 atol=1e-6
        @test mutualinfo(bs, as) ≈ 0.595553 atol=1e-6
    end
end
