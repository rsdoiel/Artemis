---
title: Obc-3 modules
---

Oxford - Not portable
=====================

DRAFT: sketch of untested code.

FIXME: I have not gotten the current Obc-3 to compile under Darwin (macOS).

Modules in this directory are being ported to the Obc-3 compiler
and should be compiled with the `-07` option.

- [Obc-3 compiler](https://spivey.oriel.ox.ac.uk/corner/Oxford_Oberon-2_compiler)
- [How to add primitives to Obc-3](https://spivey.oriel.ox.ac.uk/corner/How_to_add_primitives_to_OBC)

Pre-requisites
--------------

**Debian systems**

~~~bash
  sudo apt install build-essential autotools automake autoconf git
  sudo apt install ocaml
  sudo apt install libgtksourceview2.0-dev
  git clone git@github.com:Spivoxity/obc-3
~~~

NOTE: Unresolved issues on macOS
--------------------------------

I am currently running into issues compiling these modules on macOS.
Not sure if this is specific to my Mac (it is rather vintage) or due
to problems with compiler flags. I suspect my Makefile is not calling
the right options for macOS compilation.

