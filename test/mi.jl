@testset "Mutual Information" begin
    @test_throws MethodError MIDist(0.5, 1.0)
    for b in -2:1
        @test_throws ArgumentError MIDist(b, 2)
        @test_throws ArgumentError MIDist(2, b)
    end

    let mi = MIDist(2, 3)
        @test mi.joint == zeros(Int, 2, 3)
        @test mi.m1 == zeros(Int, 2)
        @test mi.m2 == zeros(Int, 3)
        @test mi.b1 == 2
        @test mi.b2 == 3
        @test mi.N == zero(Int)
    end

    let mi = MIDist(2,2)
        observe!(mi, [2,1,2,1], [1,1,2,2])
        @test mi.joint == [1 1; 1 1]
        @test mi.m1 == [2, 2]
        @test mi.m2 == [2, 2]
        @test mi.b1 == 2
        @test mi.b2 == 2
        @test mi.N == 4
    end

    let mi = MIDist(3, 2)
        observe!(mi, [1,2,3,1,2,3], [1,1,2,2,1,2])
        @test mi.joint == [1 1; 2 0; 0 2]
        @test mi.m1 == [2, 2, 2]
        @test mi.m2 == [3, 3]
        @test mi.b1 == 3
        @test mi.b2 == 2
        @test mi.N == 6
    end

    let mi = MIDist(2, 2)
        observe!(mi, [1,1,1,1], [2,2,2,2])
        observe!(mi, [1,2,2,2], [1,1,2,2])
        @test mi.joint == [1 4; 1 2]
        @test mi.m1 == [5, 3]
        @test mi.m2 == [2, 6]
        @test mi.N == 8
    end

    @test_throws BoundsError observe!(MIDist(2, 2), [0,1,0,1], [0,0,1,1])
    @test_throws BoundsError observe!(MIDist(2, 2), [2,3,2,3], [2,2,3,3])

    let mi = observe!(MIDist(2, 2), [1,1,2,2], [1,2,1,2])
        clear!(mi)
        @test mi.joint == zeros(Int, 2, 2)
        @test mi.m1 == zeros(Int, 2)
        @test mi.m2 == zeros(Int, 2)
        @test mi.b1 == 2
        @test mi.b2 == 2
        @test mi.N == zero(Int)
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
        mi = MIDist(2, 2)
        @test mutualinfo!(mi, as[1,:], bs[1,:]) ≈ 0.072780 atol=1e-6
        @test mutualinfo!(mi, as[2,:], bs[2,:]) ≈ 0.004497 atol=1e-6
    end
end
