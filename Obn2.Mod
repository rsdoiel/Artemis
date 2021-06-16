(** Obn2.Mod is a module to help port Oberon-2 modules
    to Oberon-7 providing a compatibility layer for
    features missing in Oberon-7 but used in Oberon-7 *)
MODULE Obn2;

(** ASH provides the Oberon-2 built-in ASH functionilty for 
    Oberon-7.  See description of providing ASH in documentation
    on Oberon-7 for positive and negative values *)
PROCEDURE ASH*();
BEGIN
END ASH.

END Obn2.
