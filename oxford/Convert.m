MODULE Convert;

(** This module provides source compatibility with OBNC's extention
module extConvert. It wrap's Mike Spivey's Conv.m and provides the
additional convertion procedures in one place. *)

IMPORT Conv;

(*Conversions between numbers and strings

All conversions from a string skips over preceeding whitespace.*)

PROCEDURE IntToString(i: INTEGER; VAR s: ARRAY OF CHAR; VAR done: BOOLEAN);
(** IntToString(i, s, d) returns in s the decimal representation of i. If s is large enough to hold the result, d is set to TRUE. Otherwise d is set to FALSE.*)

PROCEDURE RealToString(x: REAL; VAR s: ARRAY OF CHAR; VAR done: BOOLEAN);
(** RealToString(x, s, d) returns in s a string representation of x. If s is large enough to hold the result, d is set to TRUE. Otherwise d is set to FALSE.*)

PROCEDURE StringToInt(s: ARRAY OF CHAR; VAR i: INTEGER; VAR done: BOOLEAN);
(** StringToInt(s, i, d) returns in i the integer constant in s according to the format

	integer = digit {digit} | digit {hexDigit} "H".
	hexDigit = digit | "A" | "B" | "C" | "D" | "E" | "F".
	
d indicates the success of the operation. *)

PROCEDURE StringToReal(s: ARRAY OF CHAR; VAR x: REAL; VAR done: BOOLEAN);
(*StringToReal(s, x, d) returns in x the real number in s according to the format

	real = digit {digit} "." {digit} [ScaleFactor].
	ScaleFactor = "E" ["+" | "-"] digit {digit}.

d indicates the success of the operation. *)

END Convert.
