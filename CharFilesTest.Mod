MODULE CharFilesTest;

IMPORT CF := CharFiles, Files, Out, T := Tests;

CONST
  MAXSTR = 256;

VAR
  ts : T.TestSet;

(* TestBasics test the Files module procedures that
   are wrapped by CharFiles with significant changes
   (e.g. have one line procedure bodies) *)
PROCEDURE TestBasics() : BOOLEAN;
VAR f1, f2 : Files.File;
    r : Files.Rider;
    name : ARRAY MAXSTR OF CHAR; 
    test : BOOLEAN;
    p, e, t, d : INTEGER;
BEGIN test := TRUE;
  name := "README.md";
  f1 := CF.Old(name);
  T.ExpectedBool(FALSE, f1 = NIL, "expected to open README.md", test);
  CF.GetDate(f1, t, d);
  e := 2021;
  p := d DIV 512;
  T.ExpectedInt(e, p, "expected file year to be 2021 for README.md", test);
  CF.Set(r, f1, 0);
  p := CF.Pos(r);
  T.ExpectedInt(0, p, "expected rider at zero position", test);
  CF.Set(r, f1, 20);
  p := CF.Pos(r);
  T.ExpectedInt(20, p, "expected rider at twenty position", test);
  e := CF.Length(f1) - 1;
  T.ExpectedBool(TRUE, e > 0, "README.md should be larger than zero", test);
  CF.Set(r, f1, e);
  p := CF.Pos(r);
  T.ExpectedInt(e, p, "expected position last char of file", test);
  f2 := CF.Base(r);
  T.ExpectedBool(TRUE, (f1 = f2), "expected back a copy of f1 pointer", test);
  f2 := CF.New("README.md-Copy");
  CF.Register(f2);
  e := CF.Length(f1); 
  p := CF.Copy(f1, f2);
  T.ExpectedInt(e, p, "expected to copy all bytes from f1 to f2", test);
  p := CF.Length(f2);
  T.ExpectedInt(e, p, "expected to f1 and f2 to have same length", test);
  p := CF.Append(f1, f2);
  T.ExpectedInt(e, p, "expected copy f1 to the end of f2", test);
  e := CF.Length(f1) * 2;
  p := CF.Length(f2);
  T.ExpectedInt(e, p, "expected f2 to be twice as big as f2", test);

  e := 0;
  CF.Rename("README.md-Copy", "Test.Copy", p);
  CF.Close(f2);
  f2 := CF.Old("Test.Copy");
  T.ExpectedBool(TRUE, (f2 # NIL), "expected to re-open Test.Copy after rename", test);
  T.ExpectedInt(e, p, "expected README.md-Copy to rename to Test.Copy", test);
  CF.Purge(f2);
  p := CF.Length(f2);
  T.ExpectedInt(e, p, "expected Test.Copy to be empty", test);
  CF.Close(f2);
  CF.Delete("Test.Copy", p);
  T.ExpectedInt(e, p, "expected Test.Copy to be remove from file system", test);
  
  RETURN test
END TestBasics;

(* TestWrites test the write procedure in CharFiles module *)
PROCEDURE TestWrites() : BOOLEAN;
  VAR f : Files.File;
      r : Files.Rider;
      x : BYTE; c : CHAR; i : INTEGER; j : REAL; k : SET;
      s : ARRAY MAXSTR OF CHAR; b : BOOLEAN;
      z : ARRAY 3 OF BYTE;
      test : BOOLEAN;
BEGIN test := TRUE;
  (* Create a file for writing to *)
  f := CF.New("TestWrite.txt");
  CF.Set(r, f, 0);
  CF.Register(f);

  (* Setup sample test data to write to a CHAR file *)
  x := ORD("A"); (* 32 or ASCII "A" *)
  i := 101;
  c := "q";
  j := 3.145;
  k := {1,3,5};
  s := "Hello World";
  b := TRUE;
  z[0] := ORD("A");
  z[1] := ORD("B");
  z[2] := 0;

  (* Execute our write procedures, then we can read them back
     and check our results *)
  CF.Write(r, x); CF.WriteLn(r);  (* write "A" + LF *)
  CF.WriteInt(r, i); CF.WriteLn(r); (* write "101" + LF *)
  CF.WriteReal(r, j); CF.WriteLn(r); (* write "3.145" + LF *)
  (* FIXME: CF.WriteNum(r1, i); CF.WriteLn(r1); *) (* FIXME: not use *)
  CF.WriteChar(r, c); CF.WriteLn(r); (* write "q" + LF *)
  CF.WriteString(r, s); CF.WriteLn(r);
  CF.WriteSet(r, k); CF.WriteLn(r);
  CF.WriteBool(r, b); CF.WriteLn(r);
  CF.WriteBytes(r, z, 3); CF.WriteLn(r);
  CF.Close(f); (* force everything to be written to disk and close *)

  (* Get first line *)
  f := Files.Old("TestWrite.txt");
  T.ExpectedBool(TRUE, (f # NIL), "Should have written TestWrite.txt file", test);
  Files.Set(r, f, 0);
  Files.Read(r, x);
  T.ExpectedBool(TRUE, (CHR(x) = "A"), "Expected A to be written", test);
  Files.Read(r, x);
  T.ExpectedBool(TRUE, (x = 10), "Expected newline", test);
  (* Now read out 101 *)
  Files.Read(r, x);

  RETURN test
END TestWrites;

(* TestReads test the read procedures in CharFiles module *)
PROCEDURE TestReads() : BOOLEAN;
BEGIN
  Out.String("TestsReads() not implemented");Out.Ln;
  RETURN FALSE
END TestReads;

BEGIN
  T.Init(ts, "CharFiles Test");
  T.Add(ts, TestBasics, "TestBasics");
  T.Add(ts, TestWrites, "TestWrites");
  T.Add(ts, TestReads, "TestReads");
  ASSERT(T.Run(ts));
END CharFilesTest.
