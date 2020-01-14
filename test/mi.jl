@testset "Mutual Information" begin
    @test_throws MethodError MIDist(0.5, 1.0)
    for b in -2:1
        @test_throws ArgumentError MIDist(b, 2)
        @test_throws ArgumentError MIDist(2, b)
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
end
