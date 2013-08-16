homebrew-julia
==============

A small tap for the [Homebrew project](http://mxcl.github.com/homebrew/) to install [Julia](http://julialang.org/). After installing Homebrew, you must install a fortran compiler. After that, all other dependencies will automatically be downloaded and compiled followed by Julia herself:

```
$ brew update
$ brew install gfortran
$ brew tap staticfloat/julia
$ brew install --HEAD julia
```

If you want to use [Gaston](https://bitbucket.org/mbaz/gaston) for plotting, install gnuplot with the optional `wxmac` included before trying to plot with Gaston:

```
$ brew install gnuplot --wx
```

Compiling 64-bit Julia
======================
Julia and dependent libraries can be compiled in 64-bit mode, allowing for 64-bit array indexes, and therefore arrays larger than 2^32 elements along a single axis.  To compile Julia in 64-bit mode, specify the `--64bit` option when installing:

```
$ brew install --HEAD --64bit julia
```

This will compile all necessary dependencies as 64-bit as well, with a `64` suffix on the name to distinguish these dependencies from their 32-bit counterparts (e.g. `openblas-julia` has the 64-bit counterpart `openblas-julia64`).  Note that it currently is not possible to install 32-bit and 64-bit julia side-by-side.


Compiling against Accelerate
============================

Julia can use Apple's native BLAS libraries instead of OpenBLAS which may improve performance in some linear-algebra heavy tasks. To compile julia with this configuration, pass the `--with-accelerate` option to `brew install`.  Note that the `julia`, `arpack-julia` and `sauite-sparse-julia` formula all take in this option, and when switching from an OpenBLAS-backed julia to an Accelerate-backed julia, you must remove and reinstall all dependencies:

```
$ brew rm julia arpack-julia suite-sparse-julia
$ brew install --HEAD julia --with-accelerate
```

Also note that the `--with-accelerate` option and the `--64bit` options are mutually exclusive; Accelerate does not have a 64-bit interface.


Using OpenBLAS HEAD
===================
If you wish to test the newest development version of [OpenBLAS](https://github.com/xianyi/OpenBLAS) with Julia, you can do so by manually unlinking OpenBLAS, and installing the HEAD version of the formula:

```
$ brew unlink openblas-julia
$ brew install openblas-julia --HEAD
```

This will install the latest `develop` branch of OpenBLAS.  Julia will happily link against this new version, but unfortunately SuiteSparse will not, so we must recompile SuiteSparse and therefore Julia:

```
$ brew rm suite-sparse-julia julia
$ brew install --HEAD julia
```

Upgrading Julia
===============
To upgrade Julia, remove and recompile from `HEAD`.

```bash
$ brew rm julia
$ brew install --HEAD julia
```

Run tests after upgrading to make sure everything is functioning as expected. Even when Julia is able to build, the tests might still fail because of dependencies.

```bash
$ brew test -v julia
```

If your test fail, possibly due to dependencies getting out of sync, remove the dependencies too and recompile.

```bash
$ brew rm julia arpack-julia suite-sparse-julia
$ brew install --HEAD julia
```

Check again after each install, `brew test -v julia`.

