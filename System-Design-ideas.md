---
title: "System Design ideas"
---

System Design Ideas
===================

These are my working notes about building up a Oberon System like
writing environment based on Project Oberon 2013 approach and
inspired by Ofront and V4.

The system depends on the [OBNC]() compiler.

Hardware Abstractions - HAL
---------------------------

In order to re-use as much code as possible from Project Oberon 2013,
V4 and other implementations it seems like a good idea to create
a low level HAL (hardware abstraction layer) from which a light weight
kernel could  assemble. It should describe the array of devices
that the system will know from boot, e.g. keyboard, mouse, display,
and network connection, virtual file system.

System Abastractions - SAL
--------------------------

The target of Artemis includes three types of Operating Systems --
POSIX, RISC OS and Oberon Syste. There will be things that need to
be emulated to make sense in an Oberon System, SAL should provide
a common abstraction for this. Considering the http abstraction
of protocol://user:password@host/path plus mime typing.
Host system simply serves up URL space. Another model to look at
is the FUSE file system.


### Host OS Challenges

A challenge that might occur as I try to get OBNC up on RISC OS
along with Artemis is in mapping host OS functions. An idea about
building for specific host systems would be do use a Module that is
dynamically generated at compile time that would select the appropriate
host OS module for mapping functions. In effect this would be like a
module that configures things. It could be templated in Bash easily
and generated from a shell script for cross compilation.

+ run mkcompatibiliy.bash
+ this generates HostOS.Mod
   + HostOS.Mod would define a PROCEDURE Types for mapping
   + It would contain a RECORD with generatic PROCEDURE attributes
   + This record could then be used by other modules importing HostOS.Mod
+ the generated HostOS.Mod would then point at the correct host OS module, e.g. Unix.Mod, RiscOS.Mod, Windows.Mod to map the lower level functionilty needed.

I should look up the post on the Oberon mail list about a File System
module in place of FileDir module as this is trying to address a similar
issue.


Kernel Description
------------------

The Artemis Kernel needs to provide functionality in three specific
areas for an Oberon System environment. System clock access and
management, memory management and a minimal amount of File System
support to bring up higher level modules like FilesDir, Modules, etc.
provides a collection of hardware abstractions

The Artemis Kernel is inspired by the V4 implementation
in Ofront but built as a simplified just as the FPGA Oberon
adapted for a host Unix environment.

Since I am relieing on a host system's C compiler via OBNC for
compiling the system I will wrap Unix functions needed to provide
a uniform interface for Kernel to leverage.  Conceptually these should
be able to be replaced by driver code in a bare native kernel module
should the project evolve back in that direction. This is inline with
the approach taken in V4 and NativeOberon.

from the host system. It ties together a few "Sys*" modules which
implement host system interfaces. The idea behind the Kernel module
is to provide core support needed to bring up a Project Oberon 2013
style of work envinronment. 


Services
--------

+ Clock for system clock interaction
+ Mem for memory management
+ FS for system prematives

Clock
-----

Here we take advantage of the OBNC compiler's ability to 
access C level code. We can use the host computer's C libraries
to provide access to the clock.

Mem
---

In the Project Oberon's kernel memory management methods are
provided including garbage collection. The OBNC compiler also
provides these but in keeping with Artemis' theme of creating
a hosted Project Oberon environment implement the same memory
management functionality in the Artemis kernel.  Since the
assumption of how much memory is avialable is so different from
the FPGA implementation the Kernel is also responsible for making
sensible configurations. 

FS
--

Artemis' Kernel module is used directly by FileDir and as a result
should provide the necessary file primative access to the host
system. This also means the kernel can use the same primatives for
access configuration if needed.


