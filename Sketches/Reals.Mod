MODULE Reals;

IMPORT SYSTEM, Math, Strings, Out;

(**
 * Utility procedures, not exported
 **)
PROCEDURE minimum(a, b : INTEGER) : INTEGER;
  VAR res : INTEGER;
BEGIN
  IF a < b THEN res := a ELSE res := b END;
  RETURN res
END minimum;
  
(*
 * Exported procedures
 *)

(**SplitFixed takes a real number and returns a whole number
   and factitional as integers for a fixed number of
   decimal places. 
   E.g. `SplitFixed(3.14159, 2, i, m);` would update
   i to 3 and m to 14. *)
PROCEDURE SplitFixed*(r : REAL; n : INTEGER; VAR i, m : INTEGER);
  VAR a, b : REAL;
BEGIN
  a := FLT(FLOOR(r));
  b := (r - a) * Math.power(10.0, FLT(n));
  i := FLOOR(r); m := FLOOR(b);
END SplitFixed;

(**FixedToString converts an REAL value to a fixed decimal notation
   in string format. E.g. `Reals.FixedToString(3.14159, 2, s);`
   would set the value of strings `s` to "3.14" *)
PROCEDURE FixedToString*(r : REAL; n : INTEGER; VAR dest : ARRAY OF CHAR);
  VAR i, m : INTEGER; tmp : ARRAY 256 OF CHAR; ok : BOOLEAN;

  (* flip reverses the string *)
  PROCEDURE flip(VAR dest : ARRAY OF CHAR);
    VAR start, end : INTEGER; ch : CHAR;
  BEGIN
    start := 0; end := Strings.Length(dest) - 1;
    WHILE start < end DO
      ch := dest[start];
      dest[start] := dest[end];
      dest[end] := ch;
      INC(start); DEC(end);
    END;
  END flip;
  
  (* convert an integer to a string *)
  PROCEDURE intToString(value : INTEGER; VAR dest : ARRAY OF CHAR; VAR ok : BOOLEAN);
    VAR i, m : INTEGER;
  BEGIN
    ok := TRUE; dest[0] := 0X; i := 0;
    (* Make sure we have a long enough array of char *)
    IF LEN(dest) < (value + 1) THEN
      ok := FALSE;
    ELSIF value = 0 THEN
      (* Handle the trivial zero case *)
      dest[0] := "0"; dest[1] := 0X;
    ELSE
      (* build a string, least significant digit first *)
      i := 0;
      IF value < 0 THEN
        dest[0] := "-";
        INC(i);
        value := ABS(value);
      END;
      WHILE value # 0 DO
        m := value MOD 10; (* get the least significant digit *)
        dest[i] := CHR(m + ORD("0"));
        (* Shift a digit for next significant digit *)
        value := value DIV 10;
        INC(i);
      END;
      dest[i] := 0X;
      (* convert to most significant digit first *)
      flip(dest);
    END;
  END intToString;
  
BEGIN
  SplitFixed(r, n, i, m); 
  dest[0] := 0X; tmp[0] := 0X;
  intToString(i, tmp, ok);
  Strings.Append(tmp, dest);
  Strings.Append(".", dest);
  intToString(m, tmp, ok);
  Strings.Append(tmp, dest);
END FixedToString;


(**OutFixed takes `r` (REAL) displays a `w` (INTEGER) width
   number with `n` (INTEGER) decimal places *)
PROCEDURE OutFixed*(r : REAL; w, n : INTEGER);
  VAR dest : ARRAY 256 OF CHAR; i, l : INTEGER;
BEGIN
  (* convert `r` to a string with `n` decimal places *)
  FixedToString(r, n, dest);
  (* Display space padding if needed *)
  l := Strings.Length(dest);
  l := minimum(l, w) - 1;
  FOR i := 0 TO l DO Out.Char(" "); END;
  (* display string *)
  Out.String(dest);
END OutFixed;

END Reals.


To implement RealToStr() look at Native Oberon implementation
in Strings.Mod. Can be ported to Reals and Chars?

Also read an article at ucexperiment.wordpress.com from 2016-02-23
by Jim Eli, https://ucexperiment.wordpress.com/2016/02/23/lean-and-mean-float-to-string-conversion-ftoa/ that illustrates implementing an
lean ftoa for Arduino.

