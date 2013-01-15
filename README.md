homebrew-julia
==============

A small tap for the [Homebrew project](http://mxcl.github.com/homebrew/) to install [Julia](http://julialang.org/). After installing Homebrew, you must install a fortran compiler. After that, all other dependencies will automatically be downloaded and compiled followed by Julia herself:

```
$ brew update
$ brew install gfortran
$ brew tap homebrew/science
$ brew tap staticfloat/julia
$ brew install --HEAD julia
```

Note that warnings about tapping the custom version of `suite-sparse` over `mxcl/suite-sparse` are normal, and to manually install this patched version of Suite Sparse you may use `brew install staticfloat/julia/suitesparse`, although this should be unnecessary as the Julia formula internally depends on `staticfloat/julia/suite-sparse` and will install it automatically.

If you want to use [Gaston](https://bitbucket.org/mbaz/gaston) for plotting, install gnuplot with the optional `wxmac` included before trying to plot with Gaston:

```
$ brew install gnuplot --wx
```

Using OpenBLAS HEAD
===================
If you wish to test the newest development version of [OpenBLAS](https://github.com/xianyi/OpenBLAS) with Julia, you can do so by manually unlinking OpenBLAS, and installing the HEAD version of the formula:

```
$ brew unlink openblas
$ brew install openblas --HEAD
```

This will install the latest `develop` branch of OpenBLAS.  Julia will happily link against this new version, but unfortunately SuiteSparse will not, so we must recompile SuiteSparse and therefore Julia:

```
$ brew rm suite-sparse julia
$ brew install --HEAD julia
```

Conflicts with Homebrew-science
===============================
There is currently a bug in Homebrew that causes incorrect versions of SuiteSparse and OpenBLAS to be installed if you have Homebrew-science tapped.  The Homebrew bug is [being tracked](https://github.com/mxcl/homebrew/issues/16375), but please report your julia-specfic problems [in this tap](https://github.com/staticfloat/homebrew-julia/issues).