homebrew-julia
==============

A small tap for the [Homebrew project](http://mxcl.github.com/homebrew/) to install [Julia](http://julialang.org/). After installing Homebrew, run:

```
brew tap staticfloat/julia
brew install --HEAD julia
```

to install Julia.  If you want to use [Gaston]() for plotting, be sure to install Python as a framework, followed by gnuplot with wxmac:

```
brew install python --enable-framework
brew install gnuplot --wx
```
