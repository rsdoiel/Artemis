(** CharFiles.Mod - A module for working with character files, aka
plain text files. It provides is a thin wrapper of the Oakwood Files module
for working with character files.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause
*)
MODULE CharFiles;

IMPORT Files;

VAR
  EOL : ARRAY 3 OF CHAR;

PROCEDURE Old* (name: ARRAY OF CHAR) : Files.File;
BEGIN
  RETURN Files.Old(name)
END Old;

PROCEDURE New* (name: ARRAY OF CHAR) : Files.File;
BEGIN
  RETURN Files.New(name)
END New;

PROCEDURE Register* (f: Files.File);
BEGIN
  Files.Register(f);
END Register;


PROCEDURE Close* (f: Files.File);
BEGIN
  Files.Close(f);
END Close;

(* Copy does a byte copy from source to dest returns the number of bytes copied *)
PROCEDURE Copy* (source : Files.File; dest : Files.File) : INTEGER;
  VAR r1, r2 : Files.Rider;
      x : BYTE;
      i : INTEGER;
BEGIN
  Files.Set(r1, source, 0);
  Files.Set(r2, dest, 0);
  i := 0;
  REPEAT
    Files.Read(r1, x);
    IF r1.eof = FALSE THEN
      Files.Write(r2, x);
      INC(i);
    END;
  UNTIL r1.eof;
  RETURN i
END Copy;

(* Append copies the bytes from extra to then of dest file. *)
PROCEDURE Append* (extra : Files.File; dest : Files.File) : INTEGER;
  VAR r1, r2 : Files.Rider;
      x : BYTE;
      i : INTEGER;
BEGIN
  Files.Set(r1, extra, 0);
  Files.Set(r2, dest, Files.Length(dest));
  i := 0;
  REPEAT
    Files.Read(r1, x);
    IF r1.eof = FALSE THEN
      Files.Write(r2, x);
      INC(i);
    END;
  UNTIL r1.eof;
  RETURN i
END Append;


PROCEDURE Purge* (f: Files.File);
BEGIN
  Files.Purge(f);
END Purge;

PROCEDURE Delete* (name: ARRAY OF CHAR; VAR res: INTEGER);
BEGIN
  Files.Delete(name, res);
END Delete;

PROCEDURE Rename* (old, new: ARRAY OF CHAR; VAR res: INTEGER);
BEGIN
  Files.Rename(old, new, res);
END Rename;

PROCEDURE Length* (f: Files.File): INTEGER;
BEGIN
  RETURN Files.Length(f)
END Length;

PROCEDURE GetDate* (f: Files.File; VAR t, d: INTEGER);
BEGIN
  Files.GetDate(f, t, d);
END GetDate;

PROCEDURE Set* (VAR r: Files.Rider; f: Files.File; pos: INTEGER);
BEGIN
  Files.Set(r, f, pos);
END Set;

PROCEDURE Pos* (VAR r: Files.Rider) : INTEGER;
BEGIN
  RETURN Files.Pos(r)
END Pos;

PROCEDURE Base* (VAR r: Files.Rider) : Files.File;
BEGIN
  RETURN Files.Base(r)
END Base;

PROCEDURE Read* (VAR r: Files.Rider; VAR x: BYTE);
BEGIN
  Files.Read(r, x);
END Read;

PROCEDURE ReadInt* (VAR r: Files.Rider; VAR i: INTEGER);
BEGIN
  Files.ReadInt(r, i);
END ReadInt;

PROCEDURE ReadReal* (VAR r: Files.Rider; VAR x: REAL);
BEGIN
  Files.ReadReal(r, x);
END ReadReal;

PROCEDURE ReadNum* (VAR r: Files.Rider; VAR i: INTEGER);
BEGIN
  Files.ReadNum(r, i);
END ReadNum;

PROCEDURE ReadString* (VAR r: Files.Rider; VAR s: ARRAY OF CHAR);
BEGIN
  Files.ReadString(r, s);
END ReadString;

PROCEDURE ReadSet* (VAR r: Files.Rider; VAR s: SET);
BEGIN
  Files.ReadSet(r, s);
END ReadSet;

PROCEDURE ReadBool* (VAR r: Files.Rider; VAR b: BOOLEAN);
BEGIN
  Files.ReadBool(r, b);
END ReadBool;

PROCEDURE ReadBytes* (VAR r: Files.Rider; VAR buf: ARRAY OF BYTE; n: INTEGER);
BEGIN
  Files.ReadBytes(r, buf, n);
END ReadBytes;

PROCEDURE Write* (VAR r: Files.Rider; x: BYTE);
BEGIN
  Files.Write(r, x);
END Write;

PROCEDURE WriteInt* (VAR r: Files.Rider; i: INTEGER);
BEGIN
  Files.WriteInt(r, i);
END WriteInt;

PROCEDURE WriteReal* (VAR r: Files.Rider; x: REAL);
BEGIN
  Files.WriteReal(r, x);
END WriteReal;

PROCEDURE WriteNum* (VAR r: Files.Rider; i: INTEGER);
BEGIN
  Files.WriteNum(r, i);
END WriteNum;

PROCEDURE WriteString* (VAR r: Files.Rider; s: ARRAY OF CHAR);
BEGIN
  Files.WriteString(r, s);
END WriteString;

PROCEDURE WriteSet* (VAR r: Files.Rider; s: SET);
BEGIN
  Files.WriteSet(r, s);
END WriteSet;

PROCEDURE WriteBool* (VAR r: Files.Rider; b: BOOLEAN);
BEGIN
  Files.WriteBool(r, b);
END WriteBool;

PROCEDURE WriteBytes* (VAR r: Files.Rider; VAR buf: ARRAY OF BYTE; n: INTEGER);
BEGIN
  Files.WriteBytes(r, buf, n);
END WriteBytes;

BEGIN
  (* Default to a Unix tyle EOL marker *)
  EOL[0] := 0AX;
  EOL[1] := 0X;
  EOL[2] := 0X;
END CharFiles.
