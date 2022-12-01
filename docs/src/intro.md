
`ConformalPrediction.jl` is a package for Uncertainty Quantification (UQ) through Conformal Prediction (CP) in Julia. It is designed to work with supervised models trained in [MLJ](https://alan-turing-institute.github.io/MLJ.jl/dev/) Blaom et al. (2020). Conformal Prediction is distribution-free, easy-to-understand, easy-to-use and model-agnostic.

# 📖 Background

Conformal Prediction is a scalable frequentist approach to uncertainty quantification and coverage control. It promises to be an easy-to-understand, distribution-free and model-agnostic way to generate statistically rigorous uncertainty estimates. Interestingly, it can even be used to complement Bayesian methods.

The animation below is lifted from a small blog post that introduces the topic and the package (\[[TDS](https://towardsdatascience.com/conformal-prediction-in-julia-351b81309e30)\], \[[Quarto](https://www.paltmeyer.com/blog/posts/conformal-prediction/#fig-anim)\]). It shows conformal prediction sets for two different samples and changing coverage rates. Standard conformal classifiers produce set-valued predictions: for ambiguous samples these sets are typically large (for high coverage) or empty (for low coverage).

![Conformal Prediction in action: Prediction sets for two different samples and changing coverage rates. As coverage grows, so does the size of the prediction sets.](https://raw.githubusercontent.com/pat-alt/blog/main/posts/conformal-prediction/www/medium.gif)

## 🚩 Installation

You can install the latest stable release from the general registry:

``` julia
using Pkg
Pkg.add("ConformalPrediction")
```

The development version can be installed as follows:

``` julia
using Pkg
Pkg.add(url="https://github.com/pat-alt/ConformalPrediction.jl")
```

## 🔁 Status

This package is in its early stages of development and therefore still subject to changes to the core architecture and API. The following CP approaches have been implemented in the development version:

**Regression**:

- Inductive
- Naive Transductive
- Jackknife
- Jackknife+
- Jackknife-minmax
- CV+
- CV-minmax

**Classification**:

- Inductive (LABEL (Sadinle, Lei, and Wasserman 2019))
- Adaptive Inductive

The package has been tested for the following supervised models offered by [MLJ](https://alan-turing-institute.github.io/MLJ.jl/dev/).

**Regression**:

``` julia
using ConformalPrediction
keys(tested_atomic_models[:regression])
```

    KeySet for a Dict{Symbol, Expr} with 4 entries. Keys:
      :nearest_neighbor
      :evo_tree
      :light_gbm
      :decision_tree

**Classification**:

``` julia
keys(tested_atomic_models[:classification])
```

    KeySet for a Dict{Symbol, Expr} with 4 entries. Keys:
      :nearest_neighbor
      :evo_tree
      :light_gbm
      :decision_tree

## 🔍 Usage Example

To illustrate the intended use of the package, let’s have a quick look at a simple regression problem. Using [MLJ](https://alan-turing-institute.github.io/MLJ.jl/dev/) we first generate some synthetic data and then determine indices for our training, calibration and test data:

``` julia
using MLJ
X, y = MLJ.make_regression(1000, 2)
train, test = partition(eachindex(y), 0.4, 0.4)
```

We then import a decision tree ([`EvoTrees.jl`](https://github.com/Evovest/EvoTrees.jl)) following the standard [MLJ](https://alan-turing-institute.github.io/MLJ.jl/dev/) procedure.

``` julia
EvoTreeRegressor = @load EvoTreeRegressor pkg=EvoTrees
model = EvoTreeRegressor() 
```

To turn our conventional model into a conformal model, we just need to declare it as such by using `conformal_model` wrapper function. The generated conformal model instance can wrapped in data to create a *machine*. Finally, we proceed by fitting the machine on training data using the generic `fit!` method:

``` julia
using ConformalPrediction
conf_model = conformal_model(model)
mach = machine(conf_model, X, y)
fit!(mach, rows=train)
```

Predictions can then be computed using the generic `predict` method. The code below produces predictions for the first `n` samples. Each tuple contains the lower and upper bound for the prediction interval.

``` julia
n = 5
Xtest = selectrows(X, first(test,n))
ytest = y[first(test,n)]
predict(mach, Xtest)
```

    ╭──────────────────────────────────────────────────────────╮
    │                                                          │
    │      (1)   (-0.9864061984981062, 2.2503222170961554)     │
    │      (2)   (-0.7192196826151477, 2.5175087329791137)     │
    │      (3)   (-0.33838267507136344, 2.898345740522898)     │
    │      (4)   (-2.838413186252051, 0.39831522934221053)     │
    │      (5)   (-0.7192196826151477, 2.5175087329791137)     │
    │                                                          │
    │                                                          │
    ╰────────────────────────────────────────────── 5 items ───╯

## 🛠 Contribute

Contributions are welcome! Please follow the [SciML ColPrac guide](https://github.com/SciML/ColPrac).

## 🎓 References

Blaom, Anthony D., Franz Kiraly, Thibaut Lienart, Yiannis Simillides, Diego Arenas, and Sebastian J. Vollmer. 2020. “MLJ: A Julia Package for Composable Machine Learning.” *Journal of Open Source Software* 5 (55): 2704. <https://doi.org/10.21105/joss.02704>.

Sadinle, Mauricio, Jing Lei, and Larry Wasserman. 2019. “Least Ambiguous Set-Valued Classifiers with Bounded Error Levels.” *Journal of the American Statistical Association* 114 (525): 223–34.