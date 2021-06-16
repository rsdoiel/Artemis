Artemis
=======

Artemis is an Oberon-7 module collection. My hope is
to encourage continued use and development of the Oberon-7
language and encourage convergence towards compatibility
in implementations of Oberon-7 compilers. 

This project started as a re-imagining of the efforts that
began at the Oakwood Hotel in the 1992. As at Oakwood I hope
to encourage convergence to help my Oberon code to become 
more portable but unlike Oakwood my focus is only on Oberon-7
and systems implemented in Oberon-7 or providing an Oberon-7
compiler (the scope of Artemis is narrow).

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

[Obn2](Obn2.Mod) is a module is for Oberon-2 compatible
built-in procedures that were dropped in the evolution to Oberon-7.

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

[TextsCmdLn](obnc/TextsCmdLn.Mod) an port of Texts from
Project Oberon 2013 Texts module to a POSIX environment.

[ocat](obnc/ocat.Mod) is a naive implementation of Joseph Templ's ocat


Oxford Specific Modules
-----------------------

[extEnv](oxford/Env.m) provides an OBNC compatible Env module

[extConvert](oxford/Convert.m) provides an OBNC compatible Convert module

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

[TextsCmdLn](oxford/TextsCmdLn.m) a port of Texts from
Project Oberon 2013 Texts module to a POSIX environment.

[ocat](oxford/ocat.m) is a naive implementation of Joseph Templ's ocat


Command line tools
------------------

The following are modules are implementation of POSIX CLI.

**ocat** is inspired by Joseph Templ's `ocat` command from
[Ofront](https://github.com/jtempl/ofront).  It converts Oberon Texts
into plain text used on POSIX systems.  There is also an option to
convert tabs to spaces. It will attempt to convert LF, CR or CRLF to
a system appropriate end of line.


Project approach to portability
------------------------------

Artemis is made up of several categories of Oberon-7 modules.
Modules in the root should be portable across POSIX Oberon-7
compilers and portable to an Oberon Systems based on Project Oberon
2013. A second category are modules written for specific 
POSIX based Oberon-7 compilers. The third category is code 
ported from historic Oberon Systems such as S3 and V4.

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

In the __obnc__ directory is an example of create an implementation
of **ocat**. My implementation uses the module "Chars" from the
Artemis project. This means you need to include both portable and
non-portable code to compile **ocat**.  With OBNC you need to
set some environment variables to let the compiler known where to
search for modules. Here's what you can do to compile this
implementation of **ocat** in the __obnc__ directory.

~~~
export OBNC_IMPORT_PATH=".:../"
obnc ocat.Mod
~~~

For the Obc-3 compiler we need to be in the __oxford__ sub-directory.
With Obc-3 you can just provide the full path the module you want to
include. Compiling the implementation of **ocat** in the __oxford__
directory looks like

~~~
obc -o ocat ../Chars.Mod -m ocat.m
~~~


