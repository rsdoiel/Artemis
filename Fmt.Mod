(** Types.Mod - A module for working with plain text files.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause
*)
MODULE Fmt;

IMPORT Files, Strings, Types;

CONST 
  OberonEOL* = 0; UnixEOL* = 1; WindowsEOL* = 3;
  CR = 13; LF = 10; NULL = 0;
  BUFSIZE = 512; 

TYPE
  (* FilterFunc takes a CHAR as a parameter and returns 
     TRUE if filter allows the character and FALSE if not. *)
  FilterFunc = PROCEDURE (ch : CHAR) : BOOLEAN;

VAR 
  (* ok holds the last outcome of calling a type conversion *)
  ok* : BOOLEAN; 
  (* eolType defaults to UnixEOL, use SetEOLType to change output line ending *)
  eolType : INTEGER;

(* SetEOLType explicitly set the type of end of line to use on writes *)
PROCEDURE SetEOLType*(t : INTEGER);
BEGIN
  eolType := t;
END SetEOLType;

(* Scan takes a Files.Rider, a filter function returning TRUE for allowed
   characters or FALSE if not. The final parameter is an ARRAY OF CHAR 
   to hold the token literal scanned. *)
PROCEDURE Scan*(VAR r : Files.Rider; allowChar : FilterFunc; VAR token : ARRAY OF CHAR);
  VAR value : BYTE; i, l : INTEGER; done : BOOLEAN;
BEGIN
  l := LEN(token) - 1; i := 0; done := FALSE;
  REPEAT
    Files.Read(r, value);
    IF allowChar(CHR(value)) & (i < l) THEN
      token[i] := CHR(value); token[i + 1] := 0X;
      INC(i);    
    ELSE
      done := TRUE;
    END;
  UNTIL done;
END Scan;

(* WriteChar writes a CHAR *)
PROCEDURE WriteChar*(VAR r : Files.Rider; ch : CHAR);
BEGIN
  Files.Write(r, ORD(ch));
END WriteChar;

(* WriteString writes an ARRAY OF CHAR upto and excluding the NULL or
   a line ending marker ending (i.e. CR or LF). *)
PROCEDURE WriteString*(VAR r: Files.Rider; s : ARRAY OF CHAR);
  VAR i : INTEGER; 
BEGIN
  i := 0;
  WHILE (i < LEN(s)) & (s[i] # 0X) & (s[i] # CHR(CR)) & (s[i] # CHR(LF)) DO
    WriteChar(r, s[i]);
    INC(i);
  END;
END WriteString;

(* WritePadding writes a single CHAR n times using the rider *)
PROCEDURE WritePadding*(VAR r : Files.Rider; pad : CHAR; n : INTEGER);
  VAR i : INTEGER;
BEGIN
  i := 0;
  WHILE i < n DO
    WriteChar(r, pad);
    INC(i);
  END;
END WritePadding;

(* WriteInt writes an INTEGER *)
PROCEDURE WriteInt*(VAR r : Files.Rider; value, n : INTEGER);
  VAR s : ARRAY BUFSIZE OF CHAR;
BEGIN
  Types.Itoa(value, s, ok);
  IF Strings.Length(s) < n THEN
    WritePadding(r, " ", n - Strings.Length(s));
  END;
  WriteString(r, s);
END WriteInt;

(* WriteReal writes a REAL with a procedure signature like
   Out.WriteReal() *)
PROCEDURE WriteReal*(VAR r: Files.Rider; value : REAL; n : INTEGER);
  VAR s : ARRAY BUFSIZE OF CHAR;
BEGIN
  ok := TRUE;
  Types.Rtoa(value, s, ok);
  IF Strings.Length(s) < n THEN
    WritePadding(r, " ", n - Strings.Length(s));
  END;
  WriteString(r, s);
END WriteReal;

(* WriteLn writes an end of line marker based on OS preference *)
PROCEDURE WriteLn*(VAR r : Files.Rider);
BEGIN
  IF eolType = UnixEOL THEN
    Files.Write(r, LF);
  ELSIF eolType = WindowsEOL THEN
    Files.Write(r, CR); Files.Write(r, LF);
  ELSE
    (* Default to OberonEOL *)
    Files.Write(r, CR);
  END;
END WriteLn;

(* ReadInt reads an INTEGER from a file *)
PROCEDURE ReadInt*(VAR r : Files.Rider; VAR value : INTEGER);
  VAR token : ARRAY BUFSIZE OF CHAR;
      i : INTEGER;
BEGIN
  Scan(r, Types.IsDigit, token);
  Types.Atoi(token, i, ok);
  IF ok THEN
    value := i;
  END;
END ReadInt;

(* ReadReal reads a REAL from a file *)
PROCEDURE ReadReal*(VAR r : Files.Rider; VAR value : REAL);
  VAR token : ARRAY BUFSIZE OF CHAR;
      j : REAL;
BEGIN
  Scan(r, Types.IsNumericChar,  token);
  Types.Ator(token, j, ok);
  IF ok THEN
    value := j;
  END;
END ReadReal;

(* ReadChar reads a CHAR from a file *)
PROCEDURE ReadChar*(VAR r : Files.Rider; VAR ch : CHAR);
  VAR value : BYTE;
BEGIN
  Files.Read(r, value);
  ch := CHR(value);
END ReadChar;

(* ReadString reads sequence of CHAR into an ARRAY OF CHAR from a file
stopping at end of line, length of ARRAY OF CHAR minus 1 or end of
file which ever is encountered first *)
PROCEDURE ReadString*(VAR r : Files.Rider; VAR s : ARRAY OF CHAR);
  VAR done : BOOLEAN; i, l, pos : INTEGER; value : BYTE;
BEGIN
  done := FALSE;
  i := 0; l := LEN(s) - 2;
  REPEAT
    Files.Read(r, value);
    IF (i >= l) OR (value = NULL) OR (value = CR) OR (value = LF) THEN
      done := TRUE;
      (* See if we have an end of line marker if CR check if we need to advance for a LF in CRLF *)
      IF (value = CR) THEN 
        pos := Files.Pos(r);
        Files.Read(r, value);
        (* If not backup the Rider one character *)
        IF value # LF THEN
          Files.Set(r, Files.Base(r), pos);
        END;
      END;
    ELSE
      (* Append character to ARRAY OF CHAR *)
      s[i] := CHR(value); s[i + 1] := 0X;
    END;
    INC(i);
  UNTIL done;
END ReadString;

BEGIN eolType := OberonEOL;
END Fmt.
