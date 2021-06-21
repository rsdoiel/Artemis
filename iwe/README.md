IWE -- Integrated Writer's Environment
======================================

The basic concept is to create a hybrid writing platform
based on Project Oberon 2013 and build out features similar
to those found in Scrivener.

The concept is to use the same module structure for Project Oberon
2013 but adapt the modules to map into the host system.  Within
the IWE you can compile new IWE runnable modules. These will be
hosted directly on the host OS file system but will be objects based
on Wirth's risc5 instruction set.  To make this portable I'll
use a hardware abstraction layer, written in Oberon-7, that will
map the hosts' UI into the IWE program space. I am hopeful this
can be a ralatively then layer probably providing access to a
window to hold the IWE that can be written to via OpenGL or SDL
calls, mapping of the system clock and file system. 

Unlike Wirth's risc5 implementation the framebuffer, heap and stack
can be dynamic structures that reflect resources on the host system rather
than fixed structure you'd find in actual hardware.

The HAL will hold the emulator it will boot a "disk image" based on
Project Oberon 2013 FPGA. 

The HAL will be compiled with OBNC but within IWE the code will be
compiled with Wirth's compiler ported to Oberon-7 (e.g. LONGINT
becomes INTEGER).

I suspect modules like FileDir will need to become more like the
File system modues in Native Oberon but unlike those they don't need
to map down to the disk block but rather make host system calls for
reading/writing resources.





