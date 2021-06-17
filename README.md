Artemis
=======

Artemis is an Oberon-7 module collection. My hope is
to encourage continued use and development of the Oberon-7
language and encourage convergence towards compatibility
in implementations of Oberon-7 compilers. 

This project started as a re-imagining of the efforts that
began at the Oakwood Hotel in the 1992. As at Oakwood I hope
to encourage convergence to help code become more portable.
Unlike Oakwood my focus is only on Oberon-7 and systems
implemented in Oberon-7 or providing an Oberon-7 compiler.
That is the scope of Artemis project for now.

Initial development is being done in a POSIX environment and
relies on Karl Landström's [OBNC](https://miasap.se/obnc/) compiler
and Mike Spivey's [Obc-3](https://github.com/Spivoxity/obc-3).

Artemis draws inspiration from Wirth and Reed's Project Oberon 2013,
Joseph Templ's [Ofront](https://github.com/jtempl/ofront) with V4.
It also draws inspiration from the discussions and community on the 
[Oberon List](https://lists.inf.ethz.ch/mailman/listinfo/oberon).

A big thank you goes to all the inspiring people who contributed to
Oberon and Oberon Systems over the years particularly where their
source code is publicly available or through published articles,
presentations and who wrote books about the language and system.
All have help me study path Prof. Wirth and Prof. Gutkneckt
pioneered all the many years ago.


Project layout
--------------

- root
    - obncdocs
    - obnc (not portable)
    - oxford (not portable)
    - ports
        - s3
        - v4

The root repository directory is for modules that are
portable between POSIX Oberon-7 compiler implementations
and portable to an Oberon-7 based Oberon System. 

The __obncdocs__ directory contains documentation of the
module definitions for the common modules in the root directory.

The __obnc__ directory contains modules that target
specific features of the OBNC compiler. This is primarily
integration with C based libraries and services. These aren't
portable between compilers but should work across POSIX systems
where OBNC is available.

The __oxford__ directory contains modules that target the
Oxford Oberon Compiler, aka Obc-3. This is primarily
integration with C based libraries and services. These aren't
portable between compilers but should work across POSIX systems
where Obc-3 is available.

The __ports__ directory contains sub directories of code ported
from a historic Oberon System, usually the original code was
implemented in Oberon-2. The code in the __ports__ directory
are subject to their own copyright and licenses. __ports__
is focused on "porting" code from S3 (Native Oberon) and 
V4 (Linz Oberon) to Oberon-7 as an exploration of Oberon-7 language
and with an eye to eventually porting to the Oberon System
that evolved from Project Oberon 2013.


New Modules
-----------

[Chars](Chars.Mod) is a module for working with CHAR and
ARRAY OF CHAR.  It is inspired by the Oakwood Strings 
module. It goes beyond the Oakwood minimum.  It can function
as a drop in replacement for the Oakwood Strings module.

[DStrings](DStrings.Mod) provides a dynamic string implementation
for Oberon-7.  The procedures signatures are often 
compatible with the Chars module. It leverages the Rider
concept borrowed from Files and Texts in the Oberon System.

[Tests](Tests.Mod) is a minimal test library used to
implement module tests in Artemis. It tries to honor the
advice of "simple but no simpler".

[Obn2](Obn2.Mod) is a module provides compatibilty for some
built-in Oberon-2 procedures that were dropped in the evolution
to Oberon-7.


OBNC specific modules
---------------------

The [following modules](np/README.md) are not portable to Project Oberon.
They even require use of the OBNC compiler so are not portable for use
with other POSIX compilers. This is due to dependency on OBNC extension
modules or because they are derived from C code and use C libraries. 

[Unix](obnc/Unix.Mod) provides access to some Unix/C facilities.

- `Exit(exitCode : INTEGER);` will cause a program to exist with the given
   POSIX exit code.
- `KernelName(dest : ARRAY OF CHAR)` uses the POSIX command `uname` to populate
  `dest` with the name of the host OS kernel if known
- `Architecture(dest : ARRAY OF CHAR)` uses the POSIX command `uname` to
  populate the `dest` with the name of the host architectures, e.g. x86_64,
  armv7.

[Clock](obnc/Clock.Mod) is an abstraction layer for system clock built.
It uses the C `clock_gettime()` and `clock_settime()`.


Oxford Specific Modules
-----------------------

[extArgs](oxford/extArgs.m) provides an OBNC compatible Env module

[extEnv](oxford/extEnv.m) provides an OBNC compatible Env module

[extConvert](oxford/extConvert.m) provides an OBNC compatible Convert module

[Unix](oxford/Unix.m) provides access to some Unix/C facilities.

- `Exit(exitCode : INTEGER);` will cause a program to exist with the given
   POSIX exit code.
- `KernelName(dest : ARRAY OF CHAR)` uses the POSIX command `uname` to populate
  `dest` with the name of the host OS kernel if known
- `Architecture(dest : ARRAY OF CHAR)` uses the POSIX command `uname` to
  populate the `dest` with the name of the host architectures, e.g. x86_64,
  armv7.

[Clock](oxford/Clock.m) is an abstraction layer for system clock built.
It uses the C `clock_gettime()` and `clock_settime()`.


Project approach to portability
------------------------------

Artemis is made up of several categories of Oberon-7 modules.
Modules in the root should be portable across POSIX Oberon-7
compilers and portable to Oberon Systems with an Oberon-7 compiler
(e.g.  on Project Oberon 2013). A second category are modules
written for specific POSIX based Oberon-7 compilers. The third
category is code ported from historic Oberon Systems such as 
S3 (aka Native Oberon) and V4 (aka Linz Oberon).

- Portable modules are in "root" project directory
- Compiler specific modules their own sub directories (e.g. "obnc", "oxford")
- Ported modules in the "ports" sub directory

In the POSIX environment Oberon-7 compilers have not
converged (2021-06-16).  This is true for Oakwood module
implementations and and particularly true for
how C code is integrated. The later is the important
divergence as integration with legacy C libraries and services
is likely to be required for some time into the future.

Putting it all together
-----------------------

Both non-portable and portable modules can be used together in
a project. This requires knowing the compiler you're using and
targeting it's way of managing where to find modules.

An example is using [Tests.Mod](Tests.Mod) for the **clocktest**
implementations in both __obnc__ and __oxford__ directories.
With OBNC you need to set some environment variables to let the
compiler known where to search for modules.
Here's what you can do to compile this implementation of **clocktest**
in the __obnc__ directory.

~~~
export OBNC_IMPORT_PATH=".:../"
obnc -o clocktest ClockTest.obn
~~~

With Obc-3 you can just provide the full path to the module you want to
include. Compiling the implementation of **clocktest** in the __oxford__
directory looks like ---

~~~
obc -07 -o clocktest Clock.m ../Tests.m extEnv.m ClockTest.m
~~~

NOTE (2021-06-16): Not sure why yet but I found it necessary to
rename Tests.Mod to Tests.m to get compilation with obc. It might
be because the other files I am compiling use the '.m' extension.
Need to check with Mike.





