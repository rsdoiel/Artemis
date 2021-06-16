(** Unix.m provides an interface to some POSIX services.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

*)
MODULE Unix;

VAR
  kernel, architecture : ARRAY 24 OF CHAR;


(*
 * C implemented procedures
 * ------------------------
 *)

(* uname does a popen call to `uname` *)
PROCEDURE uname(opt : CHAR; VAR dest : ARRAY OF CHAR);
BEGIN
END uname;

(** Exit performs a system exit with error number *)
PROCEDURE Exit*(exitCode : INTEGER);
BEGIN
END Exit;

(*
 * Oberon-7 implemented procedures
 * -------------------------------
 *)

(* mininum returns the lesser of two integer *)
PROCEDURE minimum(a, b : INTEGER) : INTEGER;
  VAR res : INTEGER;
BEGIN
  IF a < b THEN res := a; ELSE res := b; END;
  RETURN res
END minimum;

(* copy an array of chars, truncate dest if needed *)
PROCEDURE copyChars(source : ARRAY OF CHAR; VAR dest : ARRAY OF CHAR);
  VAR i, l : INTEGER;
BEGIN 
  l := minimum(LEN(source), LEN(dest)) - 2; (* leave room of 0X *)
  IF l < 1 THEN l := 0 END;
  i := 0; dest[i] := 0X;
  WHILE (i < l) & (source[i] # 0X) DO
    dest[i] := source[i];  
    INC(i);
  END;
  dest[i] := 0X; DEC(i);
  IF (dest[i] = 10X) OR (dest[i] = 13X) THEN
    dest[i] := 0X;
  END;
END copyChars;


(** KernelName attempts a system exec call to `uname -s` to determine the
    Kernel name, e.g. Linux, Darwin, Windows *)
PROCEDURE KernelName*(VAR dest : ARRAY OF CHAR);
BEGIN
  IF kernel[0] = 0X THEN
    uname("s", kernel);
  END;
  copyChars(kernel, dest);
END KernelName;

(** Architecture attempts a system exec call to `uname -m` to determine
    the machine archtecture, e.g. i386, x86_64 *)
PROCEDURE Architecture*(VAR dest : ARRAY OF CHAR);
BEGIN
  IF architecture[0] = 0X THEN
    uname("m", architecture);
  END;
  copyChars(architecture, dest);
END Architecture;


BEGIN kernel[0] := 0X; architecture[0] := 0X;
END Unix.
