# DataVoyager

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/queryverse/DataVoyager.jl.svg?branch=master)](https://travis-ci.org/queryverse/DataVoyager.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/a685j81wd9nlxia6/branch/master?svg=true)](https://ci.appveyor.com/project/queryverse/datavoyager-jl/branch/master)
[![codecov.io](http://codecov.io/github/queryverse/DataVoyager.jl/coverage.svg?branch=master)](http://codecov.io/github/queryverse/DataVoyager.jl?branch=master)

## Overview

This package provides julia integration for the [Voyager](https://github.com/vega/voyager) data exploration tool.

## Getting Started

DataVoyager.jl can be used for data exploration. It can help you visualize and understand any data that is in a tabular format.

You can install the package at the Pkg REPL-mode with:
````julia
(v1.0) pkg> add DataVoyager
````

## Exploring data

You create a new voyager window by calling ``Voyager``:
````julia
using DataVoyager

v = Voyager()
````

By itself this is not very useful, the next step is to load some data into voyager. Lets assume your data is in a ``DataFrame``:
````julia
using DataFrames, DataVoyager

data = DataFrame(a=rand(100), b=randn(100))

v = Voyager(data)
````

You can also use the pipe to load data into voyager:
````julia
using DataFrames, DataVoyager

data = DataFrame(a=rand(100), b=randn(100))

v = data |> Voyager()
````

With a more interesting data source
```julia
using VegaDatasets, DataVoyager

v = dataset("cars") |> Voyager()
```

You can load any [IterableTables.jl](https://github.com/queryverse/IterableTables.jl) source into voyager, i.e. not just ``DataFrame``s. For example, you can load some data from a CSV file with [CSVFiles.jl](https://github.com/queryverse/CSVFiles.jl), filter them with [Query.jl](https://github.com/queryverse/Query.jl) and then visualize the result with voyager:
````julia
using FileIO, CSVFiles, Query, DataVoyager

v = load("data.csv") |> @filter(_.age>30) |> Voyager()
````
In this example the data is streamed directly into voyager and at no point is any ``DataFrame`` allocated.

## Extracting plots

You can also access a plot that you have created in the voyager UI from julia, for example to save the plot to disc.

You can access the currently active plot in a given voyager window ``v`` with the brackets syntax:

````julia
using VegaDatasets, DataVoyager, VegaLite

v = dataset("cars") |> Voyager()

plot1 = v[]
````

At this point ``plot1`` will hold a standard [VegaLite.jl](https://github.com/fredo-dedup/VegaLite.jl) plot object. You can use the normal [VegaLite.jl](https://github.com/fredo-dedup/VegaLite.jl) functions to display such a plot, or save it to disc:

````julia
display(plot1)

plot1 |> save("figure1.pdf")
````

A useful pattern here is to save the plot as a vega-lite JSON file to disc, without the data:

````julia
using VegaDatasets, DataVoyager, VegaLite

v = dataset("cars") |> Voyager()

# Now create the plot in the UI

v[] |> save("figure1.vegalite"; include_data=false)
````

At a later point you can then load this figure specification again, but pipe new data into it:

````julia
using VegaLite, VegaDatasets

dataset("cars") |> load("figure1.vegalite")
````
