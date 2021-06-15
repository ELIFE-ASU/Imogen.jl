@testset "Transfer Entropy" begin
    @test_throws MethodError TransferEntropy(0.5, 1.0; k=2)
    @test_throws TypeError TransferEntropy(2, 2; k=2.0)
    @test_throws ArgumentError TransferEntropy(2, 2; k=0)
    for b in -2:1
        @test_throws ArgumentError TransferEntropy(b, 2; k=2)
        @test_throws ArgumentError TransferEntropy(2, b; k=2)
    end

    @test_throws ArgumentError TransferEntropy(Int[], Int[]; k=2)
    @test_throws ArgumentError TransferEntropy([1,2,2], Int[]; k=2)
    @test_throws ArgumentError TransferEntropy(Int[], [1,2,3]; k=2)
    @test_throws ArgumentError TransferEntropy([0,1,2], [1,2,2]; k=2)
    @test_throws ArgumentError TransferEntropy([1,1,2], [1,0,2]; k=2)

    let te = TransferEntropy([1,2,1,2,1,2], [1,1,2,2,1,1]; k=2)
        clear!(te)
        @test te.states == zeros(Int, 16)
        @test te.histories == zeros(Int, 4)
        @test te.sources == zeros(Int, 8)
        @test te.predicates == zeros(Int, 8)
        @test te.N == zero(Int)
    end

    @test_throws ArgumentError observe!(TransferEntropy(2,2; k=2), [1,1], [1,2,1,1,2])
    @test_throws ArgumentError observe!(TransferEntropy(2,2; k=2), [1,2], [2,2])

    let as = [2,2,2,1,1], bs = [2,2,1,1,2]
        @test transferentropy(as, as; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(bs, bs; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(as, bs; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 2/3 atol=1e-6
    end

    let as = [1,1,2,2,2,1,1,1,1,2]
        bs = [2,2,1,1,1,1,1,1,2,2]
        @test transferentropy(as, as; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(bs, bs; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(as, bs; k=2) ≈ 0.106844 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 1/2 atol=1e-6
    end

    let as = [1,2,1,2,1,1,2,2,1,1]
        bs = [1,1,2,1,2,2,2,1,2,2]
        @test transferentropy(as, as; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(bs, bs; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(as, bs; k=2) ≈ 1/4 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 0.344361 atol=1e-6
    end

    let as = [1,1,1,2,2], bs = [1,1,2,2,1]
        @test transferentropy(as, as; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(bs, bs; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(as, bs; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 2/3 atol=1e-6
    end

    let as = [2,2,1,1,1,2,2,2,2,1]
        bs = [1,1,2,2,2,2,2,2,1,1]
        @test transferentropy(as, as; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(bs, bs; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(as, bs; k=2) ≈ 0.106844 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 1/2 atol=1e-6
    end

    let as = [2,1,2,1,2,2,1,1,2,2]
        bs = [2,2,1,2,1,1,1,2,1,1]
        @test transferentropy(as, as; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(bs, bs; k=2) ≈ 0.0 atol=1e-6
        @test transferentropy(as, bs; k=2) ≈ 1/4 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 0.344361 atol=1e-6
    end

    let as = [2,1,2,1,2,2,1,1,2,2]
        bs = [2,2,1,2,1,1,1,2,1,1]
        te = TransferEntropy(2, 2; k=2)
        @test transferentropy!(te, as, bs) ≈ 1/4 atol=1e-6
    end

    let as = [4,4,4,3,2,1,1,1,2]
        bs = [3,3,4,4,1,2,2,1,3]
        @test transferentropy(as, bs; k=2) ≈ 0.000000 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 0.571429 atol=1e-6
    end

    let as = [4,2,1,1,3,2,1,3,3]
        bs = [3,3,2,2,2,2,3,1,4]
        @test transferentropy(as, bs; k=2) ≈ 0.393555 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 0.571429 atol=1e-6
    end

    let as = [2 2 2 1 2 1 1 1 2;
              2 2 2 2 1 1 1 1 1]
        bs = [1 1 2 2 1 2 2 1 1;
              2 2 2 2 1 1 1 1 2]
        @test transferentropy(as, bs; k=2) ≈ 0.000000 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 0.571429 atol=1e-6
    end

    let as = [2 2 1 1 1 2 1 1 1;
              2 1 1 1 2 1 1 2 2]
        bs = [1 1 2 2 2 2 1 1 2;
              2 2 1 1 1 1 2 1 2]
        @test transferentropy(as, bs; k=2) ≈ 0.393555 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 0.571429 atol=1e-6
    end

    let as = zeros(Int, 2, 9, 2)
        as[:,:,1] = [2 2 2 1 2 1 1 1 2;
                     2 2 2 2 1 1 1 1 1]
        as[:,:,2] = [2 2 1 1 1 2 1 1 1;
                     2 1 1 1 2 1 1 2 2]

        bs = zeros(Int, 2, 9, 2)
        bs[:,:,1] = [1 1 2 2 1 2 2 1 1;
                     2 2 2 2 1 1 1 1 2]
        bs[:,:,2] = [1 1 2 2 2 2 1 1 2;
                     2 2 1 1 1 1 2 1 2]

        @test transferentropy(as, bs; k=2) ≈ 0.428571 atol=1e-6
        @test transferentropy(bs, as; k=2) ≈ 0.679270 atol=1e-6
    end

    let as = [2 2 1 1 1 2 2 2 2 1;
              2 1 2 1 2 2 1 1 2 2]
        bs = [1 1 2 2 2 2 2 2 1 1;
              2 2 1 2 1 1 1 2 1 1]
        te = TransferEntropy(2, 2; k=2)
        @test transferentropy!(te, as[1,:], bs[1,:]) ≈ 0.106844 atol=1e-6
        @test transferentropy!(te, as[2,:], bs[2,:]) ≈ 0.047181 atol=1e-6
    end
end
