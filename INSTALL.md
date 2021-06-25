---
title: Installation
---

Installation
============

Installing a released version

1. Change into that directory you want to place Artemis
2. Unzip the release Zip file
3. Make sure the "Artemis"  "bin" sub-directory is in your PATH 

Example
-------

```
    mkdir -p $HOME/tools
    cd $HOME/tools
    unzip $HOME/Download/Artemis-0.0.1-Linux-x86_64.zip
    export PATH="$HOME/tools/Artimis/bin:$PATH"
```

From source
-----------

Compiling from source requires [OBNC](https://miasap.se/obnc), Git,
GNU Make, a C compiler and linker.

1. Clone the Git repository for the project
2. Change into the repository directory
3. Run `make`, `make test`, and `sudo make install`

Example install:

```
    git clone git@github.com:rsdoiel/Artemis
    cd Artemis
    make
    make full_test
    sudo make install
```

Example uninstall

```
    cd Artemis
    sudo make uninstall
```

The Makefile supports an installation prefix. If
you install with a prefix you need to uninstall with
the same prefix. E.g.

```
    sudo make install prefix=/opt/local
    sudo make uninstall prefix=/opt/local
```


