(** CharFiles.Mod - A module for working with character files, aka
plain text files. It provides is a thin wrapper of the Oakwood Files module
for working with character files.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause
*)
MODULE CharFiles;

IMPORT Files;

  TYPE
    File = Files.File;

    Rider = Files.Rider;

  PROCEDURE Old(name: ARRAY OF CHAR): File;
  BEGIN
    RETURN Files.Old(name)
  END Old;

  PROCEDURE New(name: ARRAY OF CHAR): File;
  BEGIN
    RETURN Files.New(name)
  END New;

  PROCEDURE Register(f: File);
  BEGIN
    Files.Register(f);
  END Register;

  PROCEDURE Close(f: File);
  BEGIN
    Files.Close(f);
  END Close;

  PROCEDURE Purge(f: File);
  BEGIN
    Files.Purge(f);
  END Purge;

  PROCEDURE Delete(name: ARRAY OF CHAR; VAR res: INTEGER);
  BEGIN
    Files.Delete(name, res);
  END Delete;

  PROCEDURE Rename(old, new: ARRAY OF CHAR; VAR res: INTEGER);
  BEGIN
    Files.Rename(old, new, res);
  END Rename;

  PROCEDURE Length(f: File): INTEGER;
  BEGIN
    RETURN Files.Length(f)
  END Length;

  PROCEDURE GetDate(f: File; VAR t, d: INTEGER);
  BEGIN
    Files.GetDate(f, t, d);
  END GetDate;

  PROCEDURE Set(VAR r: Rider; f: File; pos: INTEGER);
  BEGIN
    Files.Set(r, f, pos);
  END Set;

  PROCEDURE Pos(VAR r: Rider): INTEGER;
  BEGIN
    RETURN Files.Pos(r)
  END Pos;

  PROCEDURE Base(VAR r: Rider): File;
  BEGIN
    RETURN Files.Base(r)
  END Base;

  PROCEDURE Read(VAR r: Rider; VAR x: BYTE);
  BEGIN
    Files.Read(r, x);
  END Read;

  PROCEDURE ReadInt(VAR r: Rider; VAR i: INTEGER);
  BEGIN
    Files.ReadInt(r, i);
  END ReadInt;

  PROCEDURE ReadReal(VAR r: Rider; VAR x: REAL);
  BEGIN
    Files.ReadReal(r, x);
  END ReadReal;

  PROCEDURE ReadNum(VAR r: Rider; VAR i: INTEGER);
  BEGIN
    Files.ReadNum(r, i);
  END ReadNum;

  PROCEDURE ReadString(VAR r: Rider; VAR s: ARRAY OF CHAR);
  BEGIN
    Files.ReadString(r, s);
  END ReadString;

  PROCEDURE ReadSet(VAR r: Rider; VAR s: SET);
  BEGIN
    Files.ReadSet(r, s);
  END ReadSet;

  PROCEDURE ReadBool(VAR r: Rider; VAR b: BOOLEAN);
  BEGIN
    Files.ReadBool(r, b);
  END ReadBool;

  PROCEDURE ReadBytes(VAR r: Rider; VAR buf: ARRAY OF BYTE; n: INTEGER);
  BEGIN
    Files.ReadBytes(r, buf, n);
  END ReadBytes;

  PROCEDURE Write(VAR r: Rider; x: BYTE);
  BEGIN
    Files.Write(r, x);
  END Write;

  PROCEDURE WriteInt(VAR r: Rider; i: INTEGER);
  BEGIN
    Files.WriteInt(r, i);
  END WriteInt;

  PROCEDURE WriteReal(VAR r: Rider; x: REAL);
  BEGIN
    Files.WriteReal(r, x);
  END WriteReal;

  PROCEDURE WriteNum(VAR r: Rider; i: INTEGER);
  BEGIN
    Files.WriteNum(r, i);
  END WriteNum;

  PROCEDURE WriteString(VAR r: Rider; s: ARRAY OF CHAR);
  BEGIN
    Files.WriteString(r, s);
  END WriteString;

  PROCEDURE WriteSet(VAR r: Rider; s: SET);
  BEGIN
    Files.WriteSet(r, s);
  END WriteSet;

  PROCEDURE WriteBool(VAR r: Rider; b: BOOLEAN);
  BEGIN
    Files.Write(r, b);
  END WriteBool;

  PROCEDURE WriteBytes(VAR r: Rider; VAR buf: ARRAY OF BYTE; n: INTEGER);
  BEGIN
    Files.WriteBytes(r, buf, n);
  END WriteBytes;

END CharFiles.
