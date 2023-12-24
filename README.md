---
title: Project Artemis
---

[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)

Artemis
=======

Artemis is an Oberon-07 module collection. My hope is
to encourage continued use and development of the Oberon-07
language and encourage convergence towards compatibility
in implementations of Oberon-07 compilers.  My focus in this project
is using Oberon-07 on POSIX systems.

This project started as a re-imagining of the efforts that
began at the Oakwood Hotel in the 1992. As at Oakwood I hope
to encourage convergence to help code become more portable.
Unlike Oakwood my focus is only on Oberon-07 and systems
implemented in Oberon-07 or providing an Oberon-07 compiler.
That is the scope of Artemis project for now.

Initial development is being done in a POSIX environment and
relies on Karl Landström's [OBNC](https://miasap.se/obnc/) compiler.
As time permits I am attempting to port the changes to other Oberon-07
implementations including Mike Spivey's [Obc-3](https://github.com/Spivoxity/obc-3)
 and Oleg N. Cher's [OfrontPlus](https://github.com/Oleg-N-Cher/OfrontPlus) compiler.

Artemis draws inspiration from Wirth and Reed's Project Oberon 2013,
Joseph Templ's [Ofront](https://github.com/jtempl/ofront) with V4.
It also draws inspiration from the discussions and community on the 
[Oberon List](https://lists.inf.ethz.ch/mailman/listinfo/oberon).

A big thank you goes to all the inspiring people who contributed to
Oberon and Oberon Systems over the years particularly where their
source code is publicly available or through published articles,
presentations or books about the language and system.
All have help me study the path Prof. Wirth and Prof. Gutkneckt
pioneered all those many years ago.

Project Status 2023
-------------------

It's the end of 2023 and I haven't had time to work on this. Busy life.
I still think this is a worth while effort as I head into three years of
a lingering project on my todo list.  I like Oberon-07 very much as a
language but can't really use it conveniently for my personal projects yet.
Time is a bottle neck right now and feeling comfortable asserting some
design choices is another. My guess is I need to have a specific project
as a use case to really get this effort off the ground.  In 2023 the
Oberon community is still active but is generally is small, dispersed and
largely aging (as am I). Makes me feel a little like Don Quote. I have hope
2024 may allow time for Artemis but I suspect I'll reach mid 2025 before I
revisit it again. I remain hopeful but not expecting to much as I finish
2023.


Project layout
--------------

- root
  - obncdocs
  - obnc (not portable)
  - oxford (not portable)
  - ofrontplus (not portable)

The directories named for their compilers will implement modules
providing a common definition but specifically written to that compiler.
This typically will be modules that rely on an underlying C library
or behavior. The plan is for commonly defined modules targeting
a specific compiler to use the "art" prefix. This will give room to 
the compiler developer to either adopt or create their own compatible
implementations. E.g. current I've implemented a Unix and Clock modules
for the OBNC and Oxford compilers. These will be renamed artUnix and
artClock.  Likewise the implementations of extArgs, extEnv I made for
the Oxford compiler will be renamed artArgs and artEnv so that it is clear
these are not the original OBNC modules extensions written by Karl.

### descriptions of the structures

The root repository directory is for modules that are
portable between POSIX Oberon-07 compiler implementations
and portable to an Oberon-07 based Oberon System. Where I've
provided non-canonical implementations I plan to use the "art" prefix
in the module name.

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

The __ofrontplus__ directory contains modules that target the
OfrontPlus compiler. This is primarily integration with C based
libraries. These modules are not portable between compilers but
should work across POSIX systems where OfrontPlus is available.

Module naming
-------------

Any modules which are not canonical to Artemis or are specific to a
compiler implementation must be prefixed with "art". This will allow
for better re-use in other projects (e.g. OfrontPlus) and avoids name
collisions.


Artemis Modules
---------------

[Chars](Chars.Mod) is a module for working with CHAR and
ARRAY OF CHAR.  It is inspired by the Oakwood Strings 
module. It goes beyond the Oakwood minimum.  It can function
as a drop in replacement for the Oakwood Strings module.

[DStrings](DStrings.Mod) provides a dynamic string implementation
for Oberon-07.  The procedures signatures are often 
compatible with the Chars module. It leverages the Rider
concept borrowed from Files and Texts in the Oberon System.

[Tests](Tests.Mod) is a minimal test library used to
implement module tests in Artemis. It tries to honor the
advice of "simple but no simpler".

[Obn2](Obn2.Mod) is a module provides compatibility for some
built-in Oberon-2 procedures that were dropped in the evolution
to Oberon-07.

[Path](Path.Mod) is a module for working with POSIX style paths and file extensions. It does not directly interact with the OS. It does provided a means of working with path strings in a uniform way. By default it assumes the paths are delimited with the '/' character and '.' for file extensions. This is configurable by the Path module's `SetDelimiter()` and `SetExtDelimiter()` procedures.



OBNC specific modules
---------------------

The following modules are not portable to Project Oberon are implemented
specifically for a targeted compiler. 

[artUnix](obnc/artUnix.obn) provides access to some Unix/C facilities.

- `Exit(exitCode : INTEGER);` will cause a program to exist with the given
   POSIX exit code.
- `KernelName(dest : ARRAY OF CHAR)` uses the POSIX command `uname` to populate
  `dest` with the name of the host OS kernel if known
- `Architecture(dest : ARRAY OF CHAR)` uses the POSIX command `uname` to
  populate the `dest` with the name of the host architectures, e.g. x86_64,
  armv7.

[artClock](obnc/artClock.obn) provides an abstraction layer working with the system clock. The implementation uses the C `clock_gettime()` and `clock_settime()`.


Oxford Specific Modules
-----------------------

[artArgs](oxford/artArgs.m) provides an OBNC compatible Args module

[artEnv](oxford/artEnv.m) provides an OBNC compatible Env module

[artConvert](oxford/artConvert.m) provides an OBNC compatible Convert module

[artUnix](oxford/artUnix.m) provides access to some Unix/C facilities.

- `Exit(exitCode : INTEGER);` will cause a program to exist with the given
   POSIX exit code.
- `KernelName(dest : ARRAY OF CHAR)` uses the POSIX command `uname` to populate
  `dest` with the name of the host OS kernel if known
- `Architecture(dest : ARRAY OF CHAR)` uses the POSIX command `uname` to
  populate the `dest` with the name of the host architectures, e.g. x86_64,
  armv7.

[artClock](oxford/artClock.m) is an abstraction layer for working with the system clock. It uses the C `clock_gettime()` and `clock_settime()`.

OfrontPlus Specific Modules
---------------------------

NOTE: These modules are in the planning stages and hopefully included in the next release of Artemis.

[artArgs](ofronplus/artArgs.Mod) provides an OBNC compatible Args module

[artEnv](ofrontplus/artEnv.Mod) provides an OBNC compatible Env module

[artConvert](ofrontplus/artConvert.Mod) provides an OBNC compatible Convert module

[artUnix](ofrontplus/artUnix.Mod) provides access to some Unix/C facilities.

- `Exit(exitCode : INTEGER);` will cause a program to exist with the given
   POSIX exit code.
- `KernelName(dest : ARRAY OF CHAR)` uses the POSIX command `uname` to populate
  `dest` with the name of the host OS kernel if known
- `Architecture(dest : ARRAY OF CHAR)` uses the POSIX command `uname` to
  populate the `dest` with the name of the host architectures, e.g. x86_64,
  armv7.

[artClock](ofrontplus/Clock.Mod) is an abstraction layer for working with the system clock. It uses the C `clock_gettime()` and `clock_settime()`.



Project approach to portability
------------------------------

Artemis is made up of two categories of Oberon-07 modules.
Modules in the root should be portable across POSIX Oberon-07
compilers and portable to Oberon Systems with an Oberon-07 compiler
(e.g. on Project Oberon 2013). A second category are modules
written for specific POSIX based Oberon-07 compilers.

- Portable modules are in "root" project directory
- Compiler specific modules their own sub directories (e.g. "obnc", "oxford"and "ofrontplus")

In the POSIX environment Oberon-07 compilers have not
converged (2021-09-21).  This is true for Oakwood module
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

FIXME: Document handling of imports and compiling OfrontPlus compiler.

