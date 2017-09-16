# Circle plot with bundled edges

[![Travis-CI Build Status](https://travis-ci.org/garthtarr/edgebundleR.svg?branch=master)](https://travis-ci.org/garthtarr/edgebundleR) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/edgebundleR)](http://cran.r-project.org/package=edgebundleR/) [![](http://cranlogs.r-pkg.org/badges/edgebundleR)](http://cran.r-project.org/package=edgebundleR)

This package allows R users to easily create a hierarchical edge bundle plot.  The underlying D3 code was adapted from  Mike Bostock's examples (see [here](http://bl.ocks.org/mbostock/7607999) or [here](https://mbostock.github.io/d3/talk/20111116/bundle.html)) and the package is based on the [htmlwidgets](https://github.com/ramnathv/htmlwidgets) framework.

Many thanks to [timelyportfolio](https://github.com/timelyportfolio) for some major improvements.

## Installation

You can install `edgebundleR` from Github using the `devtools` package as follows:

```s
# install.packages("devtools")
devtools::install_github("garthtarr/edgebundleR")
```

Or you can get it on CRAN:

```s
install.packages("edgebundleR")
```


## Usage

```s
library(edgebundleR)
```

The main function in the edgebundleR package is `edgebundle()`.  It takes in a variety of inputs:
 - an igraph object
 - a symmetric matrix, e.g. a correlation matrix or (regularised) precision matrix
 - a JSON file structured with `name` and `imports` as the keys


The result of the `edgebundle()` function is a webpage that is rendered in the RStudio Viewer pane by default, but also may be exported to a self contained webpage, embedded in an Rmarkdown document or used in a Shiny web application.

