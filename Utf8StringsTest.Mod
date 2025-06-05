(** Utf8StringsTest.Mod - Tests for Utf8Strings.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE Utf8StringsTest;

IMPORT Utf8Strings, Tests;

VAR
  ts: Tests.TestSet;

PROCEDURE TestLength*(): BOOLEAN;
VAR s: ARRAY 64 OF CHAR; len: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  s := "AΩ😀";
  len := Utf8Strings.Length(s);
  Tests.ExpectedInt(3, len, "Length('AΩ😀')", test);
  RETURN test
END TestLength;

PROCEDURE TestCopy*(): BOOLEAN;
VAR s, t: ARRAY 64 OF CHAR; test: BOOLEAN;
BEGIN
  test := TRUE;
  s := "AΩ😀";
  Utf8Strings.Copy(s, t);
  Tests.ExpectedString(s, t, "Copy", test);
  RETURN test
END TestCopy;

PROCEDURE TestInsert*(): BOOLEAN;
VAR s, u: ARRAY 64 OF CHAR; test: BOOLEAN;
BEGIN
  test := TRUE;
  s := "AΩ😀";
  Utf8Strings.Insert(s, 1, "X", u);
  Tests.ExpectedString("AXΩ😀", u, "Insert 'X' at pos 1", test);
  RETURN test
END TestInsert;

PROCEDURE TestAppend*(): BOOLEAN;
VAR s, u: ARRAY 64 OF CHAR; test: BOOLEAN;
BEGIN
  test := TRUE;
  s := "AΩ😀";
  Utf8Strings.Append(s, "!", u);
  Tests.ExpectedString("AΩ😀!", u, "Append '!'", test);
  RETURN test
END TestAppend;

PROCEDURE TestDelete*(): BOOLEAN;
VAR s, u: ARRAY 64 OF CHAR; test: BOOLEAN;
BEGIN
  test := TRUE;
  s := "AΩ😀";
  Utf8Strings.Delete(s, 1, 1, u);
  Tests.ExpectedString("A😀", u, "Delete at pos 1", test);
  RETURN test
END TestDelete;

PROCEDURE TestExtract*(): BOOLEAN;
VAR s, u: ARRAY 64 OF CHAR; test: BOOLEAN;
BEGIN
  test := TRUE;
  s := "AΩ😀";
  Utf8Strings.Extract(s, 1, 2, u);
  Tests.ExpectedString("Ω😀", u, "Extract 2 from pos 1", test);
  RETURN test
END TestExtract;

PROCEDURE TestPos*(): BOOLEAN;
VAR s: ARRAY 64 OF CHAR; pos: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  s := "AΩ😀ΩA";
  pos := Utf8Strings.Pos("A", s, 0);
  Tests.ExpectedInt(0, pos, "Pos('A', ... , 0)", test);

  pos := Utf8Strings.Pos("Ω", s, 0);
  Tests.ExpectedInt(1, pos, "Pos('Ω', ... , 0)", test);

  pos := Utf8Strings.Pos("😀", s, 0);
  Tests.ExpectedInt(2, pos, "Pos('😀', ... , 0)", test);

  pos := Utf8Strings.Pos("Ω", s, 2);
  Tests.ExpectedInt(3, pos, "Pos('Ω', ... , 2)", test);

  pos := Utf8Strings.Pos("Z", s, 0);
  Tests.ExpectedInt(-1, pos, "Pos('Z', ... , 0)", test);

  pos := Utf8Strings.Pos("A", s, 4);
  Tests.ExpectedInt(4, pos, "Pos('A', ... , 4)", test);

  pos := Utf8Strings.Pos("A", s, 5);
  Tests.ExpectedInt(-1, pos, "Pos('A', ... , 5)", test);

  pos := Utf8Strings.Pos("AΩ😀ΩA", s, 0);
  Tests.ExpectedInt(0, pos, "Pos(full, ... , 0)", test);

  pos := Utf8Strings.Pos("AΩ😀ΩAΩ", s, 0);
  Tests.ExpectedInt(-1, pos, "Pos(longer, ... , 0)", test);

  RETURN test
END TestPos;

PROCEDURE TestReplace*(): BOOLEAN;
VAR s, expected: ARRAY 64 OF CHAR; test: BOOLEAN;
BEGIN
  test := TRUE;
  s := "AΩ😀";
  Utf8Strings.Replace("X", 1, s);
  expected := "AX😀";
  Tests.ExpectedString(expected, s, "Replace 'Ω' with 'X'", test);

  s := "AΩ😀";
  Utf8Strings.Replace("Z", 0, s);
  expected := "ZΩ😀";
  Tests.ExpectedString(expected, s, "Replace 'A' with 'Z'", test);

  s := "AΩ😀";
  Utf8Strings.Replace("!", 2, s);
  expected := "AΩ!";
  Tests.ExpectedString(expected, s, "Replace '😀' with '!'", test);

  s := "AΩ😀";
  Utf8Strings.Replace("XY", 1, s);
  expected := "AXY";
  Tests.ExpectedString(expected, s, "Replace 'Ω😀' with 'XY'", test);

  s := "AΩ😀";
  Utf8Strings.Replace("", 1, s);
  expected := "AΩ😀";
  Tests.ExpectedString(expected, s, "Replace with '' (Oakwood: no-op)", test);

  RETURN test
END TestReplace;

BEGIN
  Tests.Init(ts, "Utf8Strings Tests");
  Tests.Add(ts, TestLength);
  Tests.Add(ts, TestCopy);
  Tests.Add(ts, TestInsert);
  Tests.Add(ts, TestAppend);
  Tests.Add(ts, TestDelete);
  Tests.Add(ts, TestExtract);
  Tests.Add(ts, TestPos);
  Tests.Add(ts, TestReplace);
  ASSERT(Tests.Run(ts));
END Utf8StringsTest.