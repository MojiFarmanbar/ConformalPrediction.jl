using MLJ
using Plots

# Data:
X, y = MLJ.make_blobs(1000, 2, centers=2)
train, test = partition(eachindex(y), 0.8)

# Atomic and conformal models:
models = tested_atomic_models[:classification]
conformal_models = merge(values(available_models[:classification])...)

# Test workflow:
@testset "Classification" begin

    for (model_name, import_call) in models

        @testset "$(model_name)" begin

            # Import and instantiate atomic model:
            Model = eval(import_call)       
            model = Model()                 

            for _method in keys(conformal_models)

                @testset "Method: $(_method)" begin

                    # Instantiate conformal models:
                    conf_model = conformal_model(model; method=_method)
                    conf_model = conformal_models[_method](model)
                    @test isnothing(conf_model.scores)
        
                    # Fit/Predict:
                    mach = machine(conf_model, X, y)
                    fit!(mach, rows=train)
                    @test !isnothing(conf_model.scores)
                    predict(mach, selectrows(X, test))

                    # Plot
                    plot(mach.model, mach.fitresult, X, y)

                end

            end

        end
        
    end
    
end