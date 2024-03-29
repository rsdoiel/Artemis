(** Obn2.Mod is a module to help port Oberon-2 modules to Oberon-7.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

*)
MODULE Obn2;

(** ASH provides the Oberon-2 built-in ASH functionilty for 
    Oberon-7.  See description of providing ASH in documentation
    on Oberon-7 for positive and negative values *)
PROCEDURE ASH*(x, n : INTEGER) : INTEGER;
  VAR res : INTEGER;
BEGIN
    IF n > 0 THEN
        res := LSL(x, n);
    ELSE
        res := ASR(x, n);
    END;
    RETURN res
END ASH;

(** MAX returns the maximum of two integers *)
PROCEDURE MAX*(x, y : INTEGER) : INTEGER;
  VAR res : INTEGER;
BEGIN
  IF x > y THEN
    res := x;
  ELSE
    res := y;
  END;
  RETURN res
END MAX;

(** MIN provides the minimum of two integers *)
PROCEDURE MIN(x, y : INTEGER) : INTEGER;
  VAR res : INTEGER;
BEGIN
  IF x < y THEN
    res := x;
  ELSE
    res := y;
  END;
  RETURN res
END MIN;

(** ENTIER is a wrapper around FLOOR, you should really just use
    FLOOR. *)
PROCEDURE ENTIER(r : REAL) : INTEGER;
BEGIN
  RETURN FLOOR(r)
END ENTIER;

(** HALT is a wrapper around ASSERT(FALSE), you should just replace
    ASSERT(FALSE) *) 
PROCEDURE HALT();
BEGIN
  ASSERT(FALSE);
END HALT;

(** ROT is a wrapper around ROR, you should just replace ROT with ROR *)
PROCEDURE ROT(x, n : INTEGER) : INTEGER;
BEGIN
  RETURN ROR(x, n)
END ROT;

END Obn2.
