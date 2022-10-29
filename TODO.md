---
title: To do
---


Action Items
============

Next
----
- [ ] Need a module for working with UTF-8 encoded strings, Scanner need to support UTF-8 encoded files
- [ ] Tests.Mod
	- rename ExpectedString to ExpectedChars (for consistency in Artemis)
	- Conform the const CHAR descriptions between Scanner.Mod and Chars.Mod
- [ ] Chars.Mod
	- QUOTE should be DQUOTE 34X
	- Add SQUOTE 39X
- [ ] Add Scanner.Mod implementing a simple text scanner supporting ARRAY OF CHAR and plain text files
- [x] Clock.Mod should wrap host system clock for use by a more general purpose DateTime.Mod.
- [x] Refactor CharsTest.Mod to test Strings compatible procedures
- [x] Tests module for easily writing tests of modules
- [ ] Reals.Mod should provide easy conversion to/from String for Real with exponential or fixed notations without reliance on extConvert.
- [x] Chars should provide a more modern approach to text processing that the Oakwood Strings module
- [x] Chars module should work as a drop in replacement for Oakwood Strings
- [x] DStrings module for dynamic strings, compatible with Chars and Strings where it makes sense, it should include Rider suppport since we lack index notation for working in the string object
- [ ] JSON module for working with JSON data
- [ ] Document coding conventions on when to use snake, camel case in variables and procedure names.

Requested Ports from Native Oberon
----------------------------------


+ [ ] Files.Mod (Confirm Can I use OBNC's implementation, confirm PO 2013 Files.Mod works as replacement)
+ [ ] Objects.Mod (Port needed for POSIX, port needed for PO 2013)
+ [ ] Display.Mod (Port needed for POSIX, confirm PO 2013 Display.Mod works as replacement)
+ [ ] Fonts.Mod (Port needed for POSIX, confirm PO 2013 Fonts.Mod works as replacement)
+ [ ] Reals.Mod (Port needed for POSIX and for PO 2013)
+ [ ] Texts.Mod, see https://en.wikibooks.org/wiki/Oberon/ETH_Oberon/2003-01-05/Texts.Mod
    + Depends on: Files, Objects, Display, Fonts, and Reals
+ [ ] Figure out if the other Native Oberon modules like Kernel, Modules, Displays.Display.Mod, etc. need to be ported or we can use PO 2013 modules

Someday, maybe
--------------

+ [ ] Reals.Mod
+ [ ] EBNF.Mod and ebnfc.Mod
+ [ ] Scanner.Mod implementing a Texts like Scanner
+ [ ] RISC5 emulator (based on Compiler Construction RISC0 emulator)
+ [ ] Create a Ofront/V4 like dev environment with direct access to host file system
+ [ ] Re-implement Fonts.Mod so Oberon System can use ADA friendly fonts like Open Dyslexia and Atikson Hyperledgable
+ [ ] Rename String.Init() to something that both suggests both initialization AND assignment. NOTE: Set/Get/Put are taken by the Rider procedures to remain signature compatible with Files.Rider
+ [ ] Refactor StringDesc record for holding CHAR to hold INTEGER to allow support for difference character sets (e.g. UTF-8/UTF-32)
+ [ ] Portable Convert module, look at V4 and OBNC implementations as well as Oxford compiler and VOC
+ [ ] RegExp module is needed
+ [ ] CSV module for working with CSV data
+ [ ] XML module for working with XML data
+ [ ] HTML review A2 and Native Oberon-7, evaluate a port to Oberon-7
+ [ ] OBNC ext modules used need to be re-implemented as pure Oberon-7 to allow Artemis to be Oberon-7 compiler agnostic.
+ [ ] Need to test under Oberon Project 2013 in DeWachter's emulator as well as Extended Oberon and IO Core
+ [ ] Cli modules (e.g. OCat) need to be clearly marked as non-portable between Oberon Systems and POSIX
+ [ ] Makefile needs to handle compile Cli modules to sensible lowercase names based on Oberon-7 compiler used


