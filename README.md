This tap is not actively maintained
===================================

To install Julia through homebrew, use [`Homebrew cask`](https://caskroom.github.io/); `brew cask install julia`.

To install Julia from source, follow the instructions on the [main Julia github repo](https://github.com/JuliaLang/julia).

This tap is still published as an example of how to build Julia and various dependencies for the curious and enterprising dev looking to build Julia on Homebrew.


homebrew-julia
==============

A small tap for the [Homebrew project](http://mxcl.github.com/homebrew/) to install [Julia](http://julialang.org/). Installation instructions:

```bash
$ brew update
$ brew tap staticfloat/julia
$ brew install julia
```

Common Issues
=============

If you are building Julia from source and you see errors about `libgfortran.dylib`, you most likely need to reinstall the latest `gcc`, `openblas-julia`, `suite-sparse-julia` and `arpack-julia`:

```
$ brew update
$ brew rm gcc openblas-julia suite-sparse-julia arpack-julia
$ brew install gcc openblas-julia suite-sparse-julia arpack-julia 
```

See [this thread](https://github.com/Homebrew/homebrew/issues/33948) for technical details as to why `gfortran` dependencies require this treatment.

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


Rebuilding the system image
===========================

When building Julia, the file `base/userimg.jl`, if it exists, will be included in the cached of compiled code. If there are large libraries that you use often, it can be useful to [`require` those in this file](https://github.com/JuliaLang/Gtk.jl/blob/master/doc/precompilation.md), for example:

```julia
require("Gtk")
require("DataFrames")
require("JuMP")
```

By default, the `userimg.jl` file does not exist, but you can create it yourself and then rebuild the Julia system image.  Place a `userimg.jl` file into `/usr/local/Cellar/julia/<julia version>/share/julia/base` (Assuming Homebrew has been installed to `/usr/local`), then run `build_sysimg.jl` (located in the folder immediatebly above the `base` directory) to rebuild the system image.  The script has many options, to see them all run `./build_sysimg.jl --help`, but if you just want to replace the current system image with the new one you're about to build (and most people do just want that) simply run:

```bash
$ ./build_sysimg.jl --force
```


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
