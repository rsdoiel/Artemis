---
title: Ports, from Oberon-2 to Oberon-07
---

README Ports
============


The ports directory contains modules that were ported to a
POSIX environment from previous Oberon Systems written in 
Oberon-2. The ported code is written in Oberon-7. Where necessary
compatibility modules have been created to minimize the changes
to the ported code.

- [s3](s3/) contains ports from Native Oberon to Oberon-7
- [v4](v4/) contains ports of Linz V4 code to Oberon-7

NOTE: Authorship of the modules in this sub directory vary.
They included "ported" code. The "ports" retain their original
authorship, copyright, license, etc.

Porting Strategy
----------------

1. [Porting the Oberon Compiler from Oberon to Oberon-07](https://people.inf.ethz.ch/wirth/Oberon/PortingOberon.pdf), Niklaus Wirth, 2007-08-15.
2. [Differences between Revised Oberon and Oberon](https://people.inf.ethz.ch/wirth/Oberon/Oberon07.pdf), Niklaus Wirth, 2008-03-22 / 2011-07-05
3. [The Programming Language Oberon](https://people.inf.ethz.ch/wirth/Oberon/Oberon07.Report.pdf), Niklaus Wirth, Revision 2013-10-01 / 2016-05-03
    - aka "The Programming Language Oberon-07 (Revised Oberon)"
    - Karl Landström provides an [HTML version](http://miasap.se/obnc/oberon-report.html)

What follows are my notes which might be helpful to others (YMMV).

The basic data types in Oberon-7 are more limitted. In some cases the
data types could simply be mapped to the newer version of the language.
The built-in procedures and functions are different from Oberon-2 to
Oberon-7. The [Obn2.Mod](Obn2.Mod) provides a small collection of
formerly build-in Oberon-2 function for use in Oberon-7.


| Oberon-2 | Oberon-7      | Compatibility  |
|:---------|:--------------|:---------------|
| LONGINT  | INTEGER       |                |
| LONGREAL | REAL          |                |
| SHORTINT | BYTE          |                |
| ASH      |               | Obn2.ASH       |
| MAX      |               | Obn2.MAX       |
| MIN      |               | Obn2.MIN       |
| ENTIER   | FLOOR         | Obn2.ENTIER    |
| HALT     | ASSERT(FALSE) | Obn2.HALT      |
| ROT      | ROR           | Obn2.ROT       |


POSIX compilers
---------------

Artemis and these ports have been developed with two Oberon-7
POSIX based compilers in mind

- [OBNC](https://)
- [Obc-3](https://github.com/Spivoxity/Obc-3 "aka Oxford Oberon Compiler")

OBNC advantage is it is realatively easy to port between POSIX systems.
It only requires a good C compiler and optionally SDL 1.2. Obc-3 has the
advantage of also being able to compile both Oberon-2 and Oberon-7
code selectable with a command line flag. This has been used to help
compare behaviors in the language.


OBNC
----

Standard compiler envocation, `obnc MODULE_NAME`

Haven't noticed deviation from Oakwood except Out has some
additional output formats.


Oxford Oberon Compiler (obc-3)
------------------------------

Standard compiler envocation, `obc -07 DEP_MODULE_LIST PROG_MODULE -m`

The latest version on GitHub includes a more Oakwood-ish
implementation of Out and Math modules.


