(** Artemis.Mod holds language constants used by various Artemis modules.
The hope is to have one place to make these global adjustments.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause *)
MODULE Artemis;

CONST
    (* MAX(SET) not available in Oberon-7, 
       MAXSET* holds maximum bit location in a 32 bit Oberon set representation.
       I am assuming bit positions 0 to 31 inclusive. *)
    MAXSET* = 31; 

    (* The maxium static string size. This is useful broadly so is defined
       here and aliased in Chars.Mod *)
    MAXSTR* = 1024;

END Artemis.

Artemis module
==============

Artemis.Mod describes global constants, procedures and variable used by
multiple Artemis project modules. Normally you do not need to call this
module directly unless you are adding or updating Modules to Artemis project.

My current thinking (2021-08-04) is the Artemis module holds the base assumptions
needed to enable code to be portable across POSIX based on Oberon-07 compilers
and hopefully Oberon Systems that also contain Oberon-07 compilers.

