homebrew-julia
==============

A small tap for the [Homebrew project](http://mxcl.github.com/homebrew/) to install [Julia](http://julialang.org/). Installation instructions:

```bash
$ brew update
$ brew tap staticfloat/julia
$ brew install julia
```


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


Using OpenBLAS HEAD or specifying CPU targets
=============================================
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

When installing OpenBLAS on that shiny new piece of hardware that just came out, note that OpenBLAS may not have the software available to autodetect your processor type.  You can manually specify a CPU target architecture by specifying `--target` when building OpenBLAS.  For instance, to specify the Sandybridge archiceture (a good fallback for most modern macs):
``` bash
$ brew install openblas-julia --target=SANDYBRIDGE
```


Providing your own userimg.jl
=============================

When building Julia, the file `base/userimg.jl`, if it exists, will be included in the cached of compiled code. If there are large libraries that you use often, it can be useful to [`require` those in this file](https://github.com/JuliaLang/Gtk.jl/blob/master/doc/precompilation.md), for example:

```julia
require("Gtk")
require("DataFrames")
require("JuMP")
```

By default, the `userimg.jl` file does not exist, but you can provide it yourself, using the `--userimg` option (using `reinstall` rather than `install` if Julia is already installed):

```bash
$ brew install julia --build-from-source --userimg=$HOME/julia/myuserimg.jl
```

The file will then be copied and renamed before the main build, potentially leading to significant speedups when loading the specified modules.


Upgrading Julia
===============
To upgrade Julia, remove and reinstall (Typically you will be doing this when living on the latest development version, so we have included all `--HEAD` commands here):

```bash
$ brew rm julia
$ brew install --HEAD julia
```

Run tests after upgrading to make sure everything is functioning as expected. Even when Julia is able to build, the tests might still fail due to dependencies.

```bash
$ brew test -v --HEAD julia
```

If compilation of Julia fails, or the tests fail, you may have to remove these dependencies and recompile:

```bash
$ brew rm julia arpack-julia suite-sparse-julia openblas-julia
$ brew install -v --HEAD julia && brew test -v --HEAD julia
```

This procedure is necessary after upgrading `gcc`, as the location of the `gfortran` libraries changes.
