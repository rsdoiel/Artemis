(** StrBuf.Mod implements a Files like buffer using DString.

Copyright (C) 2021 R. S. Doiel <rsdoiel@gmail.com> This Source Code Form is subject to the terms of the Mozilla PublicLicense, v. 2.0. If a copy of the MPL was not distributed with thisfile, You can obtain one at http://mozilla.org/MPL/2.0/. *)
MODULE StrBuf;

IMPORT Chars, DString, Convert := extConvert;

(** 
  * The following methods work using Riders treating a DString 
  * as a buffer. Combining a Rider and a DString Provides a powerful
  * approach to processing plain text in memory. 
  *)

(** The following functions are based Files procedure signatures *)

(** Read takes a Rider and reads the next CHAR from a DString, 
    setting the value of b (a BYTE). It similar to DString.Get but
    is a proper procedure instead of a function. *)
PROCEDURE Read*(VAR r : DString.Rider; VAR value : BYTE);
  VAR c : CHAR;
BEGIN
  c := DString.Get(r); value := ORD(c);
END Read;

(** ReadChar takes a Rider and returns the next CHAR from a DString.
    It is like DString.Get but implemented as a proper procedure instead of
    a function. *)
PROCEDURE ReadChar*(VAR r : DString.Rider; VAR value : CHAR);
BEGIN
  value := DString.Get(r);
END ReadChar;

(** ReadInt reads an integer from Rider. *)
PROCEDURE ReadInt*(VAR r : DString.Rider; VAR value : INTEGER);
  VAR buf : ARRAY 25 OF CHAR; i, j : INTEGER; c : CHAR;
      done : BOOLEAN; 
BEGIN
  (* Find our first digit *)
  c := DString.Get(r);
  WHILE (Chars.IsDigit(c) = FALSE) & (c # 0X) DO
    c := DString.Get(r);
  END;
  IF Chars.IsDigit(c) THEN
    (* NOTE : the loop condition contains (i < 24) because a trailing 0X *)
    i := 0; buf[i] := c; buf[i+1] := 0X; buf[24] := 0X;
    WHILE Chars.IsDigit(c) & (i < 24) DO
      buf[i] := c; buf[i+1] := 0X;
      c := DString.Get(r);
      INC(i);
    END;
    Convert.StringToInt(buf, j, done);
    IF done THEN value := j END
  END;
END ReadInt;

(** ReadReal reads a real from Rider *)
PROCEDURE ReadReal*(VAR r : DString.Rider; VAR value : REAL);
BEGIN
  (*FIXME: need to implemented *)
END ReadReal;

(** ReadNum reads an integer from the rider that is compactly encoded *)
PROCEDURE ReadNum*(VAR r : DString.Rider; VAR value : INTEGER);
BEGIN
  (*FIXME: need to implemented *)
END ReadNum;

(** ReadString takes a Rider and reads from a String until Rider.eot
    encountered. *)
PROCEDURE ReadString*(VAR r : DString.Rider; VAR dest : DString.String);
BEGIN
  (*FIXME: need to implemented *)
END ReadString;

(** ReadSet reads a set from a Rider *)
PROCEDURE ReadSet*(VAR r : DString.Rider; VAR value : SET);
BEGIN
  (*FIXME: need to implemented *)
END ReadSet;

(** ReadBool reads a boolean from Rider *)
PROCEDURE ReadBool*(VAR r : DString.Rider; VAR value : BOOLEAN);
BEGIN
  (*FIXME: need to implemented *)
END ReadBool;

(** ReadBytes reads an ARRAY OF BYTE from a Rider *)
PROCEDURE ReadBytes*(VAR r : DString.Rider; buf : ARRAY OF BYTE; n : INTEGER);
BEGIN
  (*FIXME: need to implemented *)
END ReadBytes;

(** Write takes a Rider and writes a BYTE advancing the Rider *)
PROCEDURE Write*(VAR r : DString.Rider; value : BYTE);
BEGIN
  (*FIXME: need to implemented *)
END Write;

(** WriteChar takes a Rider and a char and writes it to a String *)
PROCEDURE WriteChar*(VAR r : DString.Rider; value : CHAR);
BEGIN
  (*FIXME: need to implemented *)
END WriteChar;

(** WriteChars takes a Rider and writes an ARRAY OF CHAR to String *)
PROCEDURE WriteChars*(VAR r: DString.Rider; value : ARRAY OF CHAR);
BEGIN
  (*FIXME: need to implemented *)
END WriteChars;

(** WriteString takes a Rider and a String writes the content into a 
    String until terminating 0X is encountered *)
PROCEDURE WriteString*(VAR r : DString.Rider; source : DString.String);
BEGIN
  (*FIXME: need to implemented *)
END WriteString;

(** WriteInt takes a Rider, String, integer and padding count and writes
    the value i to the string *)
PROCEDURE WriteInt*(VAR r : DString.Rider; value : INTEGER);
BEGIN
  (*FIXME: need to implemented *)
END WriteInt;

(** WriteReal takes a Rider, String and Real value and writes it into
    the String *)
PROCEDURE WriteReal*(VAR r: DString.Rider; value : REAL);
BEGIN
  (*FIXME: need to implemented *)
END WriteReal;

(** WriteRealFixed takes a Rider, String and Real number converting the
    Real number into decimal  notation *)
PROCEDURE WriteRealFixed*(VAR r : DString.Rider; value, l : REAL);
BEGIN
  (*FIXME: need to implemented *)
END WriteRealFixed;

(** WriteBool takes a Rider, String and Boolean converting the boolean
    into "true" or "false" *)
PROCEDURE WriteBool*(VAR r : DString.Rider; value : BOOLEAN);
BEGIN
  (*FIXME: need to implemented *)
END WriteBool;

(** WriteBytes takes a Rider and writes an ARRAY OF BYTE to a String *)
PROCEDURE WriteBytes*(VAR r : String.Rider; buf : ARRAY OF BYTE; n : INTEGER);
BEGIN
  (*FIXME: need to implemented *)
END WriteBytes;

BEGIN
END StrBuf.

