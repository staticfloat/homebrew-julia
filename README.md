homebrew-julia
==============

A small tap for the [Homebrew project](http://mxcl.github.com/homebrew/) to install [Julia](http://julialang.org/). After installing Homebrew, you must install a fortran compiler (See below if you care about using a newer gfortran). After that, all other dependencies will automatically be downloaded and compiled followed by Julia herself:

```
brew install gfortran
brew tap staticfloat/julia
brew install --HEAD --env=std julia
```

If you want to use [Gaston](https://bitbucket.org/mbaz/gaston) for plotting, install gnuplot with the optional `wxmac` included before trying to plot with Gaston:

```
brew install gnuplot --wx
```


Using a newer version of gfortran
=================================
Some may prefer a more recent version of gfortran, in which case gfortran-4.7 is available through the [`homebrew-dupes` Tap](https://github.com/Homebrew/homebrew-dupes) (Note that this can take a very long time):

```
brew tap homebrew/dupes
brew install gcc --enable-fortran
```

If you have installed the 4.7 version of gfortran, you must export the `FC` variable to tell the julia build process where to find it, as well as tell it to automatically include the default fortran flags:

```
export FC=$(brew --prefix)/bin/gfortran-4.7
brew install --HEAD julia --default-fortran-flags
```