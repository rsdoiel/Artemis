Development Notes
=================

Display & Fonts
---------------

Two module that are used by Texts.Mod are Display and Fonts. In the
Oberon System these are standard modules. In the POSIX environment they
are not. The closest is the XYPlane module from the Oakwood Guidelines.

There are two approaches for replicating Display and Fonts in a
POSIX setting. They could be made headless, meaning they would never
attach to a real viewer or they could be integrate into the GUI of
the host system. I am currently exploring SDL2 as an option
for integrating them into a host environment. 

It is possible that copilation options could be chosen (e.g. the
module search path) to pick which approach was appropriate for compiling
in a POSIX environment. As an example a command line tool which is
using Texts for compatibility with Oberon Texts but not for displaying
them might be better off with a headless implementation.  On the otherhand
if you wanted to recreate the Oberon Edit command then headless doesn't
do much for you.

The primary difference between a headless Texts and a displayable one
is how it is hooked in to the actual rendering process. So a Display0.Mod
could be the headless one while Display.Mod extended Display0 to provide
real GUI rendering via a portable framework like SDL2.

