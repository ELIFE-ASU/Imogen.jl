macro test_near(a, b, ϵ::Float64=1e-10)
    quote
        @test $a.Iₘᵢₙ ≈ $b.Iₘᵢₙ atol=$ϵ
        @test $a.Π ≈ $b.Π atol=$ϵ
    end |> esc
end

@testset "Williams and Beer" begin
    @testset "primatives" begin
        @test iszero(zero(WilliamsBeer))
        @test iszero(WilliamsBeer(0.0, 0.0))
        @test iszero(WilliamsBeer(1.0, 0.0))
        @test !iszero(WilliamsBeer(0.0, 1.0))
        @test !iszero(WilliamsBeer(1.0, 1.0))
    end

    @testset "unnamed pid" begin
        let lattice = pid(WilliamsBeer, [1,2,2,1], [1 2 1 2; 1 1 2 2])
            expect = [WilliamsBeer(0.0, 0.0),
                      WilliamsBeer(0.0, 0.0),
                      WilliamsBeer(0.0, 0.0),
                      WilliamsBeer(1.0, 1.0)]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i]
            end
        end

        let lattice = pid(WilliamsBeer, [1,1,1,2], [1 2 1 2; 1 1 2 2])
            x = 1.5 - 0.75 * log2(3)
            expect = [WilliamsBeer(x, x),
                      WilliamsBeer(x, 0.0),
                      WilliamsBeer(x, 0.0),
                      WilliamsBeer(x + 0.5, 0.5)]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i]
            end
        end

        let lattice = pid(WilliamsBeer, [1,2,2,2], [1 2 1 2; 1 1 2 2])
            x = 1.5 - 0.75 * log2(3)
            expect = [WilliamsBeer(x, x),
                      WilliamsBeer(x, 0.0),
                      WilliamsBeer(x, 0.0),
                      WilliamsBeer(x + 0.5, 0.5)]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i]
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
                @test_near payload(lattice[i]) expect[i] 1e-6
            end
        end

        let lattice = pid(WilliamsBeer, [1,2,3], [1 1 2; 1 2 1])
            x, y = log2(3) - 1, 1/3
            expect = [WilliamsBeer(x, x),
                      WilliamsBeer(x + y, y),
                      WilliamsBeer(x + y, y),
                      WilliamsBeer(x + 1, y)]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i]
            end
        end

        let lattice = pid(WilliamsBeer, [1,2,2,3], [1 1 2 2; 1 2 2 1])
            expect = [WilliamsBeer(0.5, 0.5),
                      WilliamsBeer(0.5, 0.0),
                      WilliamsBeer(1.0, 0.5),
                      WilliamsBeer(1.5, 0.5)]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i]
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

        @testset "prune" begin
            @test_throws ErrorException prune(Hasse(WilliamsBeer, 3))

            let lattice = pid(WilliamsBeer, [1,2,2,1], [1 2 1 2; 1 1 2 2]) |> prune
                expect = [WilliamsBeer(1.0, 1.0)]
                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i]
                end
            end

            let lattice = pid(WilliamsBeer, [1,1,1,2], [1 2 1 2; 1 1 2 2]) |> prune
                x = 1.5 - 0.75 * log2(3)
                expect = [WilliamsBeer(x, x),
                          WilliamsBeer(x + 0.5, 0.5)]
                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i]
                end
            end

            let lattice = pid(WilliamsBeer, [1,2,2,2], [1 2 1 2; 1 1 2 2]) |> prune
                x = 1.5 - 0.75 * log2(3)
                expect = [WilliamsBeer(x, x),
                          WilliamsBeer(x + 0.5, 0.5)]
                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i]
                end
            end

            let expect = [WilliamsBeer(0.001317, 0.001317),
                          WilliamsBeer(0.011000, 0.009683),
                          WilliamsBeer(0.012888, 0.001887)]
                lattice = pid(WilliamsBeer,
                              [1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2],
                              [1 1 1 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2;
                               1 2 2 1 1 2 2 2 1 1 2 2 2 2 1 1 2 2 2 2]) |> prune

                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i] 1e-6
                end
            end

            let lattice = pid(WilliamsBeer, [1,2,3], [1 1 2; 1 2 1]) |> prune
                x, y = log2(3) - 1, 1/3
                expect = [WilliamsBeer(x, x),
                          WilliamsBeer(x + y, y),
                          WilliamsBeer(x + y, y),
                          WilliamsBeer(x + 1, y)]
                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i]
                end
            end

            let lattice = pid(WilliamsBeer, [1,2,2,3], [1 1 2 2; 1 2 2 1]) |> prune
                expect = [WilliamsBeer(0.5, 0.5),
                          WilliamsBeer(1.0, 0.5),
                          WilliamsBeer(1.5, 0.5)]
                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i]
                end
            end
        end
    end

    @testset "named pid" begin
        @test_throws ArgumentError pid(WilliamsBeer, [1,1,1], [1 1 1; 2 2 2], [:a])
        @test_throws ArgumentError pid(WilliamsBeer, [1,1,1], [1 1 1; 2 2 2], [:a,:b,:c])

        let lattice = pid(WilliamsBeer, [1,2,2,1], [1 2 1 2; 1 1 2 2], [:a, :b])
            expect = [(name=[[:a],[:b]], payload=WilliamsBeer(0.0, 0.0)),
                      (name=[[:a]],      payload=WilliamsBeer(0.0, 0.0)),
                      (name=[[:b]],      payload=WilliamsBeer(0.0, 0.0)),
                      (name=[[:a,:b]],   payload=WilliamsBeer(1.0, 1.0))]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i][:payload]
                @test name(lattice[i]) == expect[i][:name]
            end
        end

        let lattice = pid(WilliamsBeer, [1,1,1,2], [1 2 1 2; 1 1 2 2], ["Fst", "Dxy"])
            x = 1.5 - 0.75 * log2(3)
            expect = [(name=[["Fst"],["Dxy"]], payload=WilliamsBeer(x, x)),
                      (name=[["Fst"]],         payload=WilliamsBeer(x, 0.0)),
                      (name=[["Dxy"]],         payload=WilliamsBeer(x, 0.0)),
                      (name=[["Fst","Dxy"]],   payload=WilliamsBeer(x + 0.5, 0.5))]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i][:payload]
                @test name(lattice[i]) == expect[i][:name]
            end
        end

        let lattice = pid(WilliamsBeer, [1,2,2,2], [1 2 1 2; 1 1 2 2], [:α, :β])
            x = 1.5 - 0.75 * log2(3)
            expect = [(name=[[:α], [:β]], payload=WilliamsBeer(x, x)),
                      (name=[[:α]],       payload=WilliamsBeer(x, 0.0)),
                      (name=[[:β]],       payload=WilliamsBeer(x, 0.0)),
                      (name=[[:α, :β]],   payload=WilliamsBeer(x + 0.5, 0.5))]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i][:payload]
                @test name(lattice[i]) == expect[i][:name]
            end
        end

        let expect = [(name=[['a'],['b']], payload=WilliamsBeer(0.001317, 0.001317)),
                      (name=[['a']],       payload=WilliamsBeer(0.011000, 0.009683)),
                      (name=[['b']],       payload=WilliamsBeer(0.001317, 0.000000)),
                      (name=[['a','b']],   payload=WilliamsBeer(0.012888, 0.001887))]
            lattice = pid(WilliamsBeer,
                          [1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2],
                          [1 1 1 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2;
                           1 2 2 1 1 2 2 2 1 1 2 2 2 2 1 1 2 2 2 2],
                          ['a', 'b'])

            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i][:payload] 1e-6
                @test name(lattice[i]) == expect[i][:name]
            end
        end

        let lattice = pid(WilliamsBeer, [1,2,3], [1 1 2; 1 2 1], [8, 3])
            x, y = log2(3) - 1, 1/3
            expect = [(name=[[8],[3]], payload=WilliamsBeer(x, x)),
                      (name=[[8]],     payload=WilliamsBeer(x + y, y)),
                      (name=[[3]],     payload=WilliamsBeer(x + y, y)),
                      (name=[[8,3]],   payload=WilliamsBeer(x + 1, y))]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i][:payload]
                @test name(lattice[i]) == expect[i][:name]
            end
        end

        let lattice = pid(WilliamsBeer, [1,2,2,3], [1 1 2 2; 1 2 2 1], [0.5, 1.3])
            expect = [(name=[[0.5],[1.3]], payload=WilliamsBeer(0.5, 0.5)),
                      (name=[[0.5]],       payload=WilliamsBeer(0.5, 0.0)),
                      (name=[[1.3]],       payload=WilliamsBeer(1.0, 0.5)),
                      (name=[[0.5,1.3]],   payload=WilliamsBeer(1.5, 0.5))]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i][:payload]
                @test name(lattice[i]) == expect[i][:name]
            end
        end

        let lattice = pid(WilliamsBeer,
                          [1,2,2,3,3,2,3,4,4,3,2,3,4,2,2,3,3,2,3,2],
                          [2 2 1 2 2 1 2 1 2 2 2 1 1 2 1 2 1 2 2 1;
                           2 1 1 1 2 2 2 1 1 2 1 2 2 1 2 2 1 1 1 2;
                           1 1 2 2 2 2 1 1 2 1 2 2 1 2 2 2 1 1 1 1;
                           1 1 1 2 2 2 2 1 2 2 2 1 2 2 2 1 1 2 2 1],
                          [:w,:x,:y,:z])
            total = mapreduce(α -> payload(α).Π, +, vertices(lattice))
            near(total, payload(top(lattice)).Iₘᵢₙ)
        end

        let stimulus = rand(1:2, 1000)
            responses = rand(1:2, 4, 1000)
            lattice = pid(WilliamsBeer, stimulus, responses, [:a,:b,:c,:d])
            total = mapreduce(α -> payload(α).Π, +, vertices(lattice))
            near(total, payload(top(lattice)).Iₘᵢₙ)
        end

        @testset "prune" begin
            @test_throws ErrorException prune(Hasse(WilliamsBeer, [:α, :β, :γ]))

            let lattice = pid(WilliamsBeer, [1,2,2,1], [1 2 1 2; 1 1 2 2], [:a, :b]) |> prune
                expect = [(name=[[:a,:b]], payload=WilliamsBeer(1.0, 1.0))]
                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i][:payload]
                    @test name(lattice[i]) == expect[i][:name]
                end
            end

            let lattice = pid(WilliamsBeer, [1,1,1,2], [1 2 1 2; 1 1 2 2], ["Fst", "Dxy"]) |> prune
                x = 1.5 - 0.75 * log2(3)
                expect = [(name=[["Fst"],["Dxy"]], payload=WilliamsBeer(x, x)),
                          (name=[["Fst","Dxy"]],   payload=WilliamsBeer(x + 0.5, 0.5))]
                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i][:payload]
                    @test name(lattice[i]) == expect[i][:name]
                end
            end

            let lattice = pid(WilliamsBeer, [1,2,2,2], [1 2 1 2; 1 1 2 2], [:α, :β]) |> prune
                x = 1.5 - 0.75 * log2(3)
                expect = [(name=[[:α], [:β]], payload=WilliamsBeer(x, x)),
                          (name=[[:α, :β]],   payload=WilliamsBeer(x + 0.5, 0.5))]
                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i][:payload]
                    @test name(lattice[i]) == expect[i][:name]
                end
            end

            let expect = [(name=[['a'],['b']], payload=WilliamsBeer(0.001317, 0.001317)),
                          (name=[['a']],       payload=WilliamsBeer(0.011000, 0.009683)),
                          (name=[['a','b']],   payload=WilliamsBeer(0.012888, 0.001887))]
                lattice = pid(WilliamsBeer,
                              [1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2],
                              [1 1 1 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2;
                               1 2 2 1 1 2 2 2 1 1 2 2 2 2 1 1 2 2 2 2],
                              ['a', 'b']) |> prune

                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i][:payload] 1e-6
                    @test name(lattice[i]) == expect[i][:name]
                end
            end

            let lattice = pid(WilliamsBeer, [1,2,3], [1 1 2; 1 2 1], [8, 3]) |> prune
                x, y = log2(3) - 1, 1/3
                expect = [(name=[[8],[3]], payload=WilliamsBeer(x, x)),
                          (name=[[8]],     payload=WilliamsBeer(x + y, y)),
                          (name=[[3]],     payload=WilliamsBeer(x + y, y)),
                          (name=[[8,3]],   payload=WilliamsBeer(x + 1, y))]
                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i][:payload]
                    @test name(lattice[i]) == expect[i][:name]
                end
            end

            let lattice = pid(WilliamsBeer, [1,2,2,3], [1 1 2 2; 1 2 2 1], [0.5, 1.3]) |> prune
                expect = [(name=[[0.5],[1.3]], payload=WilliamsBeer(0.5, 0.5)),
                          (name=[[1.3]],       payload=WilliamsBeer(1.0, 0.5)),
                          (name=[[0.5,1.3]],   payload=WilliamsBeer(1.5, 0.5))]
                for i in eachindex(lattice)
                    @test_near payload(lattice[i]) expect[i][:payload]
                    @test name(lattice[i]) == expect[i][:name]
                end
            end
        end
    end

    @testset "pid!" begin
        let lattice = pid(WilliamsBeer, [1,2,2,1], [1 2 1 2; 1 1 2 2])
            pid!(lattice, [1,1,1,2], [1 2 1 2; 1 1 2 2])

            x = 1.5 - 0.75 * log2(3)
            expect = [WilliamsBeer(x, x),
                      WilliamsBeer(x, 0.0),
                      WilliamsBeer(x, 0.0),
                      WilliamsBeer(x + 0.5, 0.5)]
            for i in eachindex(lattice)
                @test_near payload(lattice[i]) expect[i]
            end
        end
    end
end
