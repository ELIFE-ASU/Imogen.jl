function near(a::WilliamsBeer, b::WilliamsBeer; ϵ=1e-10)
    near(a.Iₘᵢₙ, b.Iₘᵢₙ; ϵ=ϵ) && near(a.Π, b.Π; ϵ=ϵ)
end

@testset "Williams and Beer" begin
    let lattice = pid(WilliamsBeer, [1,2,2,1], [1 2 1 2; 1 1 2 2])
        expect = [WilliamsBeer(0.0, 0.0),
                  WilliamsBeer(0.0, 0.0),
                  WilliamsBeer(0.0, 0.0),
                  WilliamsBeer(1.0, 1.0)]
        for i in eachindex(lattice)
            @test near(payload(lattice[i]), expect[i])
        end
    end

    let lattice = pid(WilliamsBeer, [1,1,1,2], [1 2 1 2; 1 1 2 2])
        x = 1.5 - 0.75 * log2(3)
        expect = [WilliamsBeer(x, x),
                  WilliamsBeer(x, 0.0),
                  WilliamsBeer(x, 0.0),
                  WilliamsBeer(x + 0.5, 0.5)]
        for i in eachindex(lattice)
            @test near(payload(lattice[i]), expect[i])
        end
    end

    let lattice = pid(WilliamsBeer, [1,2,2,2], [1 2 1 2; 1 1 2 2])
        x = 1.5 - 0.75 * log2(3)
        expect = [WilliamsBeer(x, x),
                  WilliamsBeer(x, 0.0),
                  WilliamsBeer(x, 0.0),
                  WilliamsBeer(x + 0.5, 0.5)]
        for i in eachindex(lattice)
            @test near(payload(lattice[i]), expect[i])
        end
    end

    let expect = [WilliamsBeer(0.001317, 0.001317),
                  WilliamsBeer(0.011000, 0.009683),
                  WilliamsBeer(0.001317, 0.000000),
                  WilliamsBeer(0.012888, 0.001887)]
        lattice = pid(WilliamsBeer,
                      [1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2],
                      [1 1 1 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2;
                       1 2 2 1 1 2 2 2 1 1 2 2 2 2 1 1 2 2 2 2])

        for i in eachindex(lattice)
            @test near(payload(lattice[i]), expect[i]; ϵ=1e-6)
        end
    end

    let lattice = pid(WilliamsBeer, [1,2,3], [1 1 2; 1 2 1])
        x, y = log2(3) - 1, 1/3
        expect = [WilliamsBeer(x, x),
                  WilliamsBeer(x + y, y),
                  WilliamsBeer(x + y, y),
                  WilliamsBeer(x + 1, y)]
        for i in eachindex(lattice)
            @test near(payload(lattice[i]), expect[i])
        end
    end

    let lattice = pid(WilliamsBeer, [1,2,2,3], [1 1 2 2; 1 2 2 1])
        expect = [WilliamsBeer(0.5, 0.5),
                  WilliamsBeer(0.5, 0.0),
                  WilliamsBeer(1.0, 0.5),
                  WilliamsBeer(1.5, 0.5)]
        for i in eachindex(lattice)
            @test near(payload(lattice[i]), expect[i])
        end
    end

    let lattice = pid(WilliamsBeer,
                      [1,2,2,3,3,2,3,4,4,3,2,3,4,2,2,3,3,2,3,2],
                      [2 2 1 2 2 1 2 1 2 2 2 1 1 2 1 2 1 2 2 1;
                       2 1 1 1 2 2 2 1 1 2 1 2 2 1 2 2 1 1 1 2;
                       1 1 2 2 2 2 1 1 2 1 2 2 1 2 2 2 1 1 1 1;
                       1 1 1 2 2 2 2 1 2 2 2 1 2 2 2 1 1 2 2 1])
        total = mapreduce(α -> payload(α).Π, +, vertices(lattice))
        near(total, payload(top(lattice)).Iₘᵢₙ)
    end

    let stimulus = rand(1:2, 1000)
        responses = rand(1:2, 4, 1000)
        lattice = pid(WilliamsBeer, stimulus, responses)
        total = mapreduce(α -> payload(α).Π, +, vertices(lattice))
        near(total, payload(top(lattice)).Iₘᵢₙ)
    end
end
