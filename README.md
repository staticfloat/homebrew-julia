homebrew-julia
==============

A small tap for the [Homebrew project](http://mxcl.github.com/homebrew/) to install [Julia](http://julialang.org/). After installing Homebrew, you must install a fortran compiler. After that, all other dependencies will automatically be downloaded and compiled followed by Julia herself:

```bash
$ brew update
$ brew install gfortran
$ brew tap staticfloat/julia
$ brew install julia
```

If you want to use [Gaston](https://bitbucket.org/mbaz/gaston) for plotting, install gnuplot with the optional `wxmac` included before trying to plot with Gaston:

```bash
$ brew install gnuplot --wx
```

Compiling 64-bit Julia
======================
Julia and dependent libraries can be compiled in 64-bit mode, allowing for 64-bit array indexes, and therefore arrays larger than 2^32 elements along a single axis.  To compile Julia in 64-bit mode, specify the `--64bit` option when installing:

```bash
$ brew install --64bit julia
```

This will compile all necessary dependencies as 64-bit as well, with a `64` suffix on the name to distinguish these dependencies from their 32-bit counterparts (e.g. `openblas-julia` has the 64-bit counterpart `openblas-julia64`).  Note that it currently is not possible to install 32-bit and 64-bit julia side-by-side.


Compiling against Accelerate
============================

Julia can use Apple's native BLAS libraries instead of OpenBLAS which may improve performance in some linear-algebra heavy tasks. To compile julia with this configuration, pass the `--with-accelerate` option to `brew install`.  Note that the `julia`, `arpack-julia` and `sauite-sparse-julia` formula all take in this option, and when switching from an OpenBLAS-backed julia to an Accelerate-backed julia, you must remove and reinstall all dependencies:

```bash
$ brew rm julia arpack-julia suite-sparse-julia
$ brew install julia --with-accelerate
```

Also note that the `--with-accelerate` option and the `--64bit` options are mutually exclusive; Accelerate does not have a 64-bit interface.

Building a bleeding-edge version of Julia
=========================================
If you wish to test the newest development version of Julia, you can build with the `--HEAD` option:

```bash
$ brew install --HEAD julia
```

Note that to run the test suite you must also pass the `--HEAD` option to `brew`:
```bash
$ brew test -v --HEAD julia
```


Using OpenBLAS HEAD
===================
If you wish to test the newest development version of [OpenBLAS](https://github.com/xianyi/OpenBLAS) with Julia, you can do so by manually unlinking OpenBLAS, and installing the HEAD version of the formula:

```bash
$ brew unlink openblas-julia
$ brew install openblas-julia --HEAD
```

This will install the latest `develop` branch of OpenBLAS.  Julia will happily link against this new version, but unfortunately SuiteSparse will not, so we must recompile SuiteSparse and therefore Julia:

```bash
$ brew rm suite-sparse-julia julia
$ brew install julia
```

Upgrading Julia
===============
To upgrade Julia, remove and recompile (Typically you will be doing this when living on the latest development version, so we have included all `--HEAD` commands here):

```bash
$ brew rm julia
$ brew install --HEAD julia
```

Run tests after upgrading to make sure everything is functioning as expected. Even when Julia is able to build, the tests might still fail due to dependencies.

```bash
$ brew test -v --HEAD julia
```

If your tests fail, possibly due to dependencies getting out of sync, remove the dependencies and recompile:

```bash
$ brew rm julia arpack-julia suite-sparse-julia
$ brew install --HEAD julia && brew test -v --HEAD julia
```

Note that this procedure is necessary after upgrading `gfortran`, as the location of the `gfortran` libraries changes.  If you have an idea on how to avoid this problem, I'd love to hear about it.
