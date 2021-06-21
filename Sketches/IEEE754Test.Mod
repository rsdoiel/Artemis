MODULE IEEE754Test;

IMPORT SYSTEM, Out;

VAR
 pi : REAL;

(** SplitReal converts a REAL into two integers
    fractional and exponent *)
PROCEDURE SplitReal*(r : REAL; VAR neg : BOOLEAN; VAR m, exp : INTEGER);
BEGIN
  neg := (r < 0.0);
  IF neg THEN
    r := r * (-1.0);
  END;
  m := 0; exp := 0;
  REPEAT 
    m := m + FLOOR((FLT(FLOOR(r)) * Math.power(2, FLT(exp))));
    r := (r - FLT(m)) * 2.0;
    INC(exp);
  UNTIL r <= 0.0;
END SplitReal;

(**RealToString converts a REAL to string *)
PROCEDURE RealToString*(r : REAL; VAR dest : ARRAY OF CHAR; VAR ok : BOOLEAN);
  VAR tmp : ARRAY 256 OF CHAR; ok1, neg : BOOLEAN; m, exp : INTEGER;
BEGIN
  SplitReal(r, neg, m, exp);
  IF neg THEN
    dest[0] := "-"; dest[1] := 0X;
  ELSE
    dest[0] := 0X;
  END;
  intToString(m, tmp, ok1);
  ok := (ok & ok1);
  Strings.Append(tmp, dest);
  Strings.Append("e", dest);
  intToString(exp, tmp, ok1);
  ok := (ok & ok1);
  Strings.Append(tmp, dest);
END RealToString;


(** DisplayIEEE754, Jörg Schrieb implementation from ETH mail list *)
PROCEDURE DisplayIEEE754*(x: REAL);
  VAR s: SET;

  PROCEDURE Bits(str: ARRAY OF CHAR; s: SET; left, right: INTEGER);
    VAR i : INTEGER;
  BEGIN
    Out.String(str);
    FOR i := left TO right BY -1 DO
      IF i IN s THEN Out.Char("1") ELSE Out.Char("0") END;
    END;
  END Bits;

BEGIN
  (* Cast REAL to SET to get the bit values *)
  s := SYSTEM.VAL(SET, x);
  (* Pickup the sign by checking bit 31 *)
  Out.String("sign is ");
  IF 31 IN s THEN Out.Char("-") ELSE Out.Char("+") END;
  (* Display the exponent with Bits *)
  Bits(", expo (binary): ", s, 30, 23);
  (* Display the fractional part with Bits *)
  Bits(" frac (binary): ", s, 22, 0);
  Out.Ln;
END DisplayIEEE754;

PROCEDURE DisplayBits(r : REAL);
  VAR s : SET; i : INTEGER;
BEGIN
  Out.String("01234567890123456789012345678901"); Out.Ln;
  s := SYSTEM.VAL(SET, r);
  FOR i := 31 TO 0 BY -1 DO
    IF i IN s THEN
      Out.Char("1");
    ELSE
      Out.Char("0");
    END;
  END;
END DisplayBits;

BEGIN
  pi := 3.1459;
  DisplayBits(pi); Out.Ln;
  DisplayIEEE754(pi);
END IEEE754Test.
