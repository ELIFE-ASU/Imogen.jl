@testset "Active Information" begin
    @test_throws MethodError ActiveInfo(0.5, 1.0)
    for b in -2:1
        @test_throws ArgumentError ActiveInfo(b, 2)
    end
    for k in -2:0
        @test_throws ArgumentError ActiveInfo(2, k)
    end

    let ai = ActiveInfo(2, 1)
        @test ai.joint == zeros(Int, 2, 2)
        @test ai.future == zeros(Int, 2)
        @test ai.history == zeros(Int, 2)
        @test ai.b == 2
        @test ai.k == 1
        @test ai.N == zero(Int)
    end

    let ai = ActiveInfo(2, 3)
        @test ai.joint == zeros(Int, 2, 8)
        @test ai.future == zeros(Int, 2)
        @test ai.history == zeros(Int, 8)
        @test ai.b == 2
        @test ai.k == 3
        @test ai.N == zero(Int)
    end

    let ai = ActiveInfo(2, 2)
        observe!(ai, [2,1,2,1])
        @test ai.joint == [0 1 0 0; 0 0 1 0]
        @test ai.future == [1,1]
        @test ai.history == [0,1,1,0]
        @test ai.b == 2
        @test ai.k == 2
        @test ai.N == 2
    end

    let ai = ActiveInfo(2, 2)
        observe!(ai, [1,1,1,1])
        observe!(ai, [1,2,2,2])
        @test ai.joint == [2 0 0 0; 0 1 0 1]
        @test ai.future == [2,2]
        @test ai.history == [2,1,0,1]
        @test ai.N == 4
    end

    @test_throws ArgumentError ActiveInfo([0,1,1]; k=2)
    @test_throws ArgumentError ActiveInfo(Int[]; k=2)
    @test_throws ArgumentError ActiveInfo([1]; k=2)
    @test_throws ArgumentError ActiveInfo([1,2]; k=2)

    @test_throws ArgumentError observe!(ActiveInfo(2, 2), [1,2])
    @test_throws BoundsError observe!(ActiveInfo(2, 2), [1,2,3])
    @test_throws BoundsError observe!(ActiveInfo(2, 2), [0,0,1,1])
    @test_throws BoundsError observe!(ActiveInfo(2, 2), [2,3,2,3])

    let as = [2,2,1,1,2,1,1,2]
        @test activeinfo(as; k=2) ≈ 0.918296 atol=1e-6
    end

    let as = [1,2,2,2,2,2,2,2,2]
        @test activeinfo(as; k=2) ≈ 0.0 atol=1e-6
    end

    let as = [1,1,2,2,2,2,1,1,1]
        @test activeinfo(as; k=2) ≈ 0.305958 atol=1e-6
    end

    let as = [2,1,1,1,1,1,1,2,2]
        @test activeinfo(as; k=2) ≈ 0.347458 atol=1e-6
    end

    let as = [1,1,1,1,1,2,2,1,1]
        @test activeinfo(as; k=2) ≈ 0.399533 atol=1e-6
    end

    let as = [1,1,1,1,2,2,1,1,1]
        @test activeinfo(as; k=2) ≈ 0.399533 atol=1e-6
    end

    let as = [2,2,2,1,1,1,1,2,2]
        @test activeinfo(as; k=2) ≈ 0.305958 atol=1e-6
    end

    let as = [1,1,1,2,2,2,2,1,1]
        @test activeinfo(as; k=2) ≈ 0.305958 atol=1e-6
    end

    let as = [1,1,1,1,1,1,2,2,1]
        @test activeinfo(as; k=2) ≈ 0.347458 atol=1e-6
    end

    let as = [4,4,4,3,2,1,1,1,2]
        @test activeinfo(as; k=2) ≈ 1.270942 atol=1e-6
    end

    let as = [3,3,4,4,4,4,3,2,1]
        @test activeinfo(as; k=2) ≈ 1.270942 atol=1e-6
    end

    let as = [3,3,3,3,3,3,2,2,2]
        @test activeinfo(as; k=2) ≈ 0.469566 atol=1e-6
    end

    @testset "AI is a Mutual Information" for k in 1:9
        let xs = rand(1:2, 1000)
            ai = activeinfo(xs; k)
            @test ai ≈ mutualinfo(encodehistories(xs, k; warn=false)[1:end-1], xs[1+k:end]) atol=1e-6
            @test ai ≈ mutualinfo(encodehistories(xs, k; warn=false, recode=true)[1:end-1], xs[1+k:end]) atol=1e-6
        end
        let xs = rand(1:3, 1000)
            ai = activeinfo(xs; k)
            @test ai ≈ mutualinfo(encodehistories(xs, k; warn=false)[1:end-1], xs[1+k:end]) atol=1e-6
            @test ai ≈ mutualinfo(encodehistories(xs, k; warn=false, recode=true)[1:end-1], xs[1+k:end]) atol=1e-6
        end
        let xs = rand(1:4, 1000)
            ai = activeinfo(xs; k)
            @test ai ≈ mutualinfo(encodehistories(xs, k; warn=false)[1:end-1], xs[1+k:end]) atol=1e-6
            @test ai ≈ mutualinfo(encodehistories(xs, k; warn=false, recode=true)[1:end-1], xs[1+k:end]) atol=1e-6
        end
    end
end
