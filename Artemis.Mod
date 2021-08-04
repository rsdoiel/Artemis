(** Artemis.Mod holds language constants used by various Artemis modules.
The hope is to have one place to make these global adjustments.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause *)
MODULE Artemis;

CONST

    (* MAX(SET) not available in Oberon-7, 
       SET holds nothing or bit positions 0 through 31 *)
    MAXSET* = 31; 
    (* The maxium static string size. This is useful broadly so is defined
       here and aliased in Chars.Mod *)
    MAXSTR* = 1024;

END Artemis.