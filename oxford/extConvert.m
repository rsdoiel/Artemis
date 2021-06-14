(** extConvert.m provides procedures to convert between numbers and
    strings. It is based on the definition found in OBNC's 
    extended library extConvert.Mod. *)
MODULE extConvert;

IMPORT SYSTEM;

(** Conversions between numbers and strings

All conversions from a string skips over preceeding whitespace. *)

(** IntToString(i, s, d) returns in s the decimal representation of i. 
The done parameters is for compatibility, it is alwasy TRUE. *)
PROCEDURE IntToString*(i: INTEGER; VAR s: ARRAY OF CHAR; VAR done: BOOLEAN);
  VAR l : INTEGER;
BEGIN
  l := LEN(s); done := TRUE;
  IntToString0(i, s, l); 
END IntToString;

PROCEDURE IntToString0(i : INTEGER; VAR s : ARRAY OF CHAR; l : INTEGER) IS "conv_int_to_string";

(** RealToString(x, s, d) returns in s a string representation of x. If s is large enough to hold the result, d is set to TRUE. Otherwise d is set to FALSE.*)
PROCEDURE RealToString*(x: REAL; VAR s: ARRAY OF CHAR; VAR done: BOOLEAN);
  VAR l : INTEGER;
BEGIN
  l := LEN(s);
  RealToString0(x, s, l);
END RealToString;

PROCEDURE RealToString0(x: REAL; VAR s: ARRAY OF CHAR; l : INTEGER) IS "conv_real_to_string";


(** StringToInt(s, i, d) returns in i the integer constant in s according to the format

	integer = digit {digit} | digit {hexDigit} "H".
	hexDigit = digit | "A" | "B" | "C" | "D" | "E" | "F".
	
d indicates the success of the operation.*)
PROCEDURE StringToInt*(s: ARRAY OF CHAR; VAR i: INTEGER; VAR done: BOOLEAN);
BEGIN
  done := TRUE;
  StringToInt0(s, i);
END StringToInt;

PROCEDURE StringToInt0(s : ARRAY OF CHAR; VAR i : INTEGER) IS "conv_string_to_int";

(** StringToReal(s, x, d) returns in x the real number in s according to the format

	real = digit {digit} "." {digit} [ScaleFactor].
	ScaleFactor = "E" ["+" | "-"] digit {digit}.

d indicates the success of the operation. *)
PROCEDURE StringToReal*(s: ARRAY OF CHAR; VAR x: REAL; VAR done: BOOLEAN);
BEGIN
  done := TRUE;
  StringToReal0(s, x);
END StringToReal;

PROCEDURE StringToReal0(s: ARRAY OF CHAR; VAR x : REAL) IS "conv_string_to_real";

BEGIN
  SYSTEM.LOADLIB("./extConvert.so");
END extConvert.

