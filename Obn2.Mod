(** Obn2.Mod is a module to help port Oberon-2 modules
    to Oberon-7 providing a compatibility layer for
    features missing in Oberon-7 but used in Oberon-7 *)
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
PROCEDURE MAX*(x, y : INGTEGER) : INTEGER;
  VAR res : INTEGER;
BEGIN
  IF x > n THEN
    res := x;
  ELSE
    res := y;
  END;
  RETURN res
END MAX;

(** MIN provides the minimum of two integers *)
PROCEDURE MIN(x, y : INTEGER);
  VAR res : INTEGER;
BEGIN
  IF x < y THEN
    res := x;
  ELSE
    res := y;
  END;
  RETURN res
END MIN;

END Obn2.
