(** DStringTest.Mod implements tests for the DStrings Module.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause
*)
MODULE DStringsTest;

IMPORT T := Tests, DStrings, Chars, Out, Strings, Convert := extConvert;

VAR 
  ts : T.TestSet;


PROCEDURE displayString(str1, str2 : DStrings.String; msg: ARRAY OF CHAR);
  VAR i, res : INTEGER; s1, s2 : ARRAY 1024 OF CHAR;
BEGIN
  FOR i := 0 TO 1023 DO s1[i] := 0X; s2[i] := 0X; END;
  DStrings.ToChars(str1, s1, res);
  DStrings.ToChars(str2, s2, res);
  Out.String("Expected '");Out.String(s1);
  Out.String("', got '");Out.String(s2);
  Out.String("' "); Out.String(msg); Out.Ln();
END displayString;

(* ExpectedDString compare two DStrings.String, 
   set test to FALSE if they don't match and display a message *)
PROCEDURE ExpectedDString(expected, got : DStrings.String; msg : ARRAY OF CHAR; VAR test : BOOLEAN);
BEGIN
  IF DStrings.Equal(expected, got) = FALSE THEN
    displayString(expected, got, msg);
    test := FALSE;
  END;
END ExpectedDString;


PROCEDURE TestInit() : BOOLEAN;
  VAR 
    test : BOOLEAN; str1, str2, str3 : DStrings.String;
    i : INTEGER;
BEGIN test := TRUE;
  DStrings.Init("One Two Three", str1);
  i := DStrings.Length(str1);
  IF i # 13 THEN
    Out.String("Init failed, should have length of 13 for str1, got ");
    Out.Int(i, 1);Out.Ln();
    test := FALSE;
  ELSE
    DStrings.Init("One Two Three", str2);
    IF DStrings.Equal(str1, str2) = FALSE THEN
      test := FALSE;
      displayString(str1, str2, "expected equal strings");
    ELSE
      DStrings.Init("One Four Five Six", str3);
      IF DStrings.Equal(str1, str3) = TRUE THEN
        test := FALSE;
        displayString(str1, str2, "expected unequal strings");
      END;
    END;
  END;
  RETURN test
END TestInit;

PROCEDURE TestToChars() : BOOLEAN;
  VAR 
    test : BOOLEAN; str : DStrings.String; c : CHAR;
    s : ARRAY 1024 OF CHAR; i,j,k, res : INTEGER;
    r : DStrings.Rider;
BEGIN
  test := TRUE;
  s := "One Two Three";
  i := Strings.Length(s);
  DStrings.Init(s, str); 
  j := DStrings.Length(str);
  IF i # j THEN
    Out.String("Expected str length ");Out.Int(i, 1);
    Out.String(", got ");Out.Int(j, 1); Out.Ln();
    test := FALSE;
  ELSE
    Chars.Clear(s);
    k := Strings.Length(s);
    IF k # 0 THEN
      Out.String("Expected to clear string s");Out.Ln();
      test := FALSE;
    END;
    DStrings.ToChars(str, s, res);
    IF res > 0 THEN
      Out.String("Expected all chars to get copied, ");
      Out.Int(res, 1); Out.String(" not copied");Out.Ln();
      test := FALSE;
    END;
    k := Strings.Length(s);
    IF i # k THEN
      Out.String("Expected copied string length ");Out.Int(i, 1);
      Out.String(", got ");Out.Int(k, 1); Out.Ln();
      test := FALSE;
    END;
    i := 0;
    DStrings.Set(r, str, 0);
    WHILE (i < Strings.Length(s)) & (test = TRUE) DO 
      c := DStrings.Get(r);
      IF s[i] # c THEN
        Out.String("Expected char '");Out.Char(s[i]); 
        Out.String("', got "); Out.Char(c);
        Out.String(" at position "); Out.Int(i, 1);
        Out.Ln();
        test := FALSE;
      END;
      INC(i);
    END;
  END;

  RETURN test
END TestToChars;

PROCEDURE TestRider() : BOOLEAN;
  VAR test : BOOLEAN; r : DStrings.Rider; s, q : DStrings.String;
    i, j, k : INTEGER; c : CHAR;
    t : ARRAY 256 OF CHAR;
BEGIN test := TRUE;
  t := "One Two Three Four Five";
  DStrings.Init("One Two Three Four Five", s);
  k := DStrings.Length(s);
  DStrings.Set(r, s, 0);
  q := DStrings.Base(r);
  IF s # q THEN
    Out.String("Expected q to point to the same string as s");
    test := FALSE;
  END;
  i := 0;
  WHILE i < k DO
    c := DStrings.Peek(r); j := r.pos;
    T.ExpectedInt(i, j, "Peek r.pos", test);
    T.ExpectedChar(t[i], c, "Peek r.pos", test);
    c := DStrings.Get(r); j := r.pos;
    T.ExpectedChar(t[i], c, "Get r.pos", test);
    T.ExpectedInt(i+1, j, "Get r.pos", test);
    INC(i);
  END;
  DStrings.Init("Eleven Twelve Thirteen Fourteen Fifteen", s);
  DStrings.Set(r, s, 0);
  i := 0;
  WHILE i < k DO
    c := CHR(i + ORD("a"));     
    DStrings.Put(r, c);
    T.ExpectedInt(i + 1, r.pos, "Put, r.pos", test);
    INC(i);
  END;
  DStrings.Set(r, s, 0);
  i := 0;
  WHILE i < k DO
    c := DStrings.Get(r);
    T.ExpectedChar(c, CHR(i + ORD("a")), "c := Get(r)", test);
    INC(i);
  END;
  DStrings.Init("", s);
  DStrings.Set(r, s, 0);
  i := 0;
  WHILE i < k DO
    c := CHR(i + ORD("a"));     
    DStrings.Put(r, c);
    T.ExpectedInt(i + 1, r.pos, "Put, r.pos", test);
    INC(i);
  END;
  DStrings.Set(r, s, 0);
  i := 0;
  WHILE i < k DO
    c := DStrings.Get(r);
    T.ExpectedChar(c, CHR(i + ORD("a")), "c := Get(r)", test);
    INC(i);
  END;
  RETURN test
END TestRider;

PROCEDURE TestCopy() : BOOLEAN;
  VAR test : BOOLEAN; str1, str2 : DStrings.String;
BEGIN test := TRUE;
  DStrings.Init("Twenty Thirty Fourty", str1);
  DStrings.Copy(str1, str2);
  ExpectedDString(str1, str2, "Copy(str1,str2)", test);
  RETURN test
END TestCopy;

PROCEDURE TestInsert() : BOOLEAN;
  VAR test : BOOLEAN; s1, s2, expected: DStrings.String;
BEGIN test := TRUE;
  DStrings.Init("one two three", expected);
  DStrings.Init("two three", s1);
  DStrings.Init("one ", s2);
  DStrings.Insert(s2, 0, s1);
  ExpectedDString(expected, s1, "Insert('one ', 0, 'two three')", test);

  DStrings.Init("one three", s1);
  DStrings.Init("two ", s2);
  DStrings.Insert(s2, 4, s1);
  ExpectedDString(expected, s1, "Insert('two ', 4, 'one three')", test);

  DStrings.Init("one three", s1);
  DStrings.Init(" two", s2);
  DStrings.Insert(s2, 3, s1);
  ExpectedDString(expected, s1, "Insert('two ', 3, 'one three')", test);

  RETURN test
END TestInsert;

PROCEDURE TestAppend() : BOOLEAN;
  VAR test : BOOLEAN; s1, s2, expected: DStrings.String;
BEGIN test := TRUE;
  DStrings.Init("one two three four", expected);
  DStrings.Init("one two three ", s1);
  DStrings.Init("four", s2);
  DStrings.Append(s2, s1);
  ExpectedDString(expected, s1, "Append('four ', 'one two three')", test);

  RETURN test
END TestAppend;

PROCEDURE TestDelete() : BOOLEAN;
  VAR test : BOOLEAN; s1, expected: DStrings.String;
BEGIN test := TRUE;
  DStrings.Init("two three four", expected);
  DStrings.Init("one two three four", s1);
  DStrings.Delete(s1, 0, 4);
  ExpectedDString(expected, s1, "Delete('one two three four', 0, 4)", test);

  DStrings.Init("one three four", expected);
  DStrings.Init("one two three four", s1);
  DStrings.Delete(s1, 4, 4);
  ExpectedDString(expected, s1, "Delete('one two three four', 4, 4)", test);

  DStrings.Init("one two three", expected);
  DStrings.Init("one two three four", s1);
  DStrings.Delete(s1, 13, 5);
  ExpectedDString(expected, s1, "Delete('one two three four', 13, 5)", test);

  DStrings.Init("one two three", expected);
  DStrings.Init("one two three four", s1);
  DStrings.Delete(s1, 13, 10);
  ExpectedDString(expected, s1, "Delete('one two three four', 13, 10)", test);
  DStrings.Init("one><three four", expected);
  DStrings.Init("one>two<three four", s1);
  DStrings.Delete(s1, 4, 3);
  ExpectedDString(expected, s1, "Delete('one>two<three four', 4, 3)", test);

  RETURN test
END TestDelete;

PROCEDURE TestExtract() : BOOLEAN;
  VAR test : BOOLEAN; s1, s2, expected : DStrings.String;
BEGIN test := TRUE;
  DStrings.Init("one two three", s1);
  DStrings.Init("one", expected);
  DStrings.Extract(s1, 0, 3, s2);
  ExpectedDString(expected, s2, "Extract(s1, 0, 3, s2)", test);
  DStrings.Init("two", expected);
  DStrings.Extract(s1, 4, 3, s2);
  ExpectedDString(expected, s2, "Extract(s1, 4, 3, s2)", test);
  DStrings.Init("three", expected);
  DStrings.Extract(s1, 8, 12, s2);
  ExpectedDString(expected, s2, "Extract(s1, 8, 12, s2)", test);

  RETURN test
END TestExtract;

PROCEDURE TestPos() : BOOLEAN;
  VAR test : BOOLEAN; s1, s2 : DStrings.String; expected, got : INTEGER;
BEGIN test := TRUE;
  DStrings.Init("one two three", s1);
  DStrings.Init("one", s2);
  got := DStrings.Pos(s2, s1, 0);
  expected := 0;
  T.ExpectedInt(expected, got, "DStrings.Pos('one',s1, 0)", test);
  expected := -1;
  got := DStrings.Pos(s2, s1, 4);
  T.ExpectedInt(expected, got, "DStrings.Pos('one',s1, 4)", test);
  DStrings.Init("two", s2);
  expected := 4;
  got := DStrings.Pos(s2, s1, 0);
  T.ExpectedInt(expected, got, "DStrings.Pos('two',s1, 0)", test);
  expected := -1;
  got := DStrings.Pos(s2, s1, 6);
  T.ExpectedInt(expected, got, "DStrings.Pos('two',s1, 6)", test);

  RETURN test
END TestPos;

PROCEDURE TestReplace() : BOOLEAN;
  VAR test : BOOLEAN; source, dest, expected : DStrings.String;
BEGIN test := TRUE;
  DStrings.Init("222", source);
  DStrings.Init("one two three", dest);
  DStrings.Init("one 222 three", expected);
  DStrings.Replace(source, 4, dest);
  ExpectedDString(expected, dest, "Replace('222', 4, dest)", test);

  DStrings.Init("111", source);
  DStrings.Init("111 222 three", expected);
  DStrings.Replace(source, 0, dest);
  ExpectedDString(expected, dest, "Replace('111', 0, dest)", test);

  DStrings.Init("33333", source);
  DStrings.Init("111 222 33333", expected);
  DStrings.Replace(source, 8, dest);
  ExpectedDString(expected, dest, "Replace('33333', 8, dest)", test);

  RETURN test
END TestReplace;

PROCEDURE TestCap() : BOOLEAN;
  VAR test : BOOLEAN; got, expected : DStrings.String;
BEGIN test := TRUE;
  DStrings.Init("AbCdE", got);
  DStrings.Init("ABCDE", expected);
  DStrings.Cap(got);
  ExpectedDString(expected, got, "Cap('AbCdE')", test);
  RETURN test
END TestCap;

PROCEDURE TestStartsWith() : BOOLEAN;
  VAR test : BOOLEAN; prefix, source : DStrings.String; 
      expected, got : BOOLEAN;
BEGIN test := TRUE;
  DStrings.Init("one", prefix);
  DStrings.Init("one two three", source);
  expected := TRUE;
  got := DStrings.StartsWith(prefix, source);
  T.ExpectedBool(expected, got, "StartsWith('one', 'one two three')", test);

  expected := FALSE;
  DStrings.Init("two", prefix);
  got := DStrings.StartsWith(prefix, source);
  T.ExpectedBool(expected, got, "StartsWith('two', 'one two three')", test);

  RETURN test
END TestStartsWith;

(*
 * Tests for the Files like interface into DStrings.
 *)

PROCEDURE TestReadProcs() : BOOLEAN;
  VAR test, ok, bt : BOOLEAN; b1 : BYTE; r1 : DStrings.Rider;
      expectS, s1, s2 : DStrings.String; expectC, c1 : CHAR; 
      expectCS, cs : ARRAY 256 OF CHAR;
      expectI, i : INTEGER; expectR, a : REAL;
      expectBytes, ba : ARRAY 4 OF BYTE;
      expectSet, gotSet : SET;
BEGIN test := TRUE;
  expectC := "N";
  DStrings.Init("No. 42, Pi is 3.145 real", s1);
  DStrings.Set(r1, s1, 0);
  DStrings.Read(r1, b1);
  T.ExpectedChar(expectC, CHR(b1), "Read(r1, b1) -> 'N'", test);
  expectC := "o";
  DStrings.ReadChar(r1, c1);
  T.ExpectedChar(expectC, c1, "ReadChar(r1, c1) -> 'o'", test); 
  DStrings.ReadChar(r1, c1);
  expectI := 42; i := -1;
  DStrings.ReadInt(r1, i);
  T.ExpectedInt(expectI, i, "ReadInt(r1, c1) -> 42", test);
  Convert.StringToReal("3.145", expectR, ok); a := 0.0;
  DStrings.ReadReal(r1, a);
  T.ExpectedReal(expectR, a, "ReadReal(r1, a) -> 3.145", test);

  expectCS := " real";
  DStrings.ReadString(r1, cs);
  T.ExpectedString(expectCS, cs, "ReadString(r1, cs) -> ' real'", test);

  expectCS := "No. 42, Pi is 3.145 real";
  DStrings.Init(expectCS, expectS);
  DStrings.Init(expectCS, s1);
  DStrings.Init("", s2);
  DStrings.Set(r1, s1, 0);
  DStrings.ReadDString(r1, s2);
  ExpectedDString(expectS, s2, "ReadDString(r1, s) -> 'No. 42, Pi is 3.145 real'", test);

  expectCS := "t f true false 1 0 T F TRUE FALSE True False";
  DStrings.Init(expectCS, expectS);
  DStrings.Init(expectCS, s1);
  DStrings.Set(r1, s1, 0);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(TRUE, bt, "ReadBool(r, b) -> t", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(FALSE, bt, "ReadBool(r, b) -> f", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(TRUE, bt, "ReadBool(r, b) -> true", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(FALSE, bt, "ReadBool(r, b) -> false", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(TRUE, bt, "ReadBool(r, b) -> 1", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(FALSE, bt, "ReadBool(r, b) -> 0", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(TRUE, bt, "ReadBool(r, b) -> T", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(FALSE, bt, "ReadBool(r, b) -> F", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(TRUE, bt, "ReadBool(r, b) -> TRUE", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(FALSE, bt, "ReadBool(r, b) -> FALSE", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(TRUE, bt, "ReadBool(r, b) -> True", test);
  DStrings.ReadBool(r1, bt);
  T.ExpectedBool(FALSE, bt, "ReadBool(r, b) -> False", test);

  expectCS[0] := 1X; expectCS[1] := 2X;
  expectCS[2] := 3X; expectCS[3] := 0X;
  expectBytes[0] := 1; expectBytes[1] := 2;
  expectBytes[2] := 3; expectBytes[3] := 0;
  DStrings.Init(expectCS, s1);
  DStrings.Set(r1, s1, 0);
  DStrings.ReadBytes(r1, ba, 4);
  T.ExpectedBytes(expectBytes, ba, 4, "ReadBytes(r1, ba, 4) 1230", test);

  expectSet := {2,3,4,6,7,8,10};
  DStrings.Init("{2,3,4,6,7,8,10}", s1);
  DStrings.Set(r1, s1, 0);
  DStrings.ReadSet(r1, gotSet);
  T.ExpectedSet(expectSet, gotSet, "ReadSet(r1, gotSet);", test);

  DStrings.Init(" 3.1459 ", s1);
  DStrings.Set(r1, s1, 0);
  DStrings.ReadFixed(r1, a, 2);
  T.ExpectedReal(3.14, a, "ReadFixed(r1, a, 2)", test);

  RETURN test
END TestReadProcs;

PROCEDURE TestWriteProcs() : BOOLEAN;
  VAR test : BOOLEAN; expectDS, gotDS, src : DStrings.String;
      a : ARRAY 256 OF CHAR; b : BYTE; c : CHAR; W : DStrings.Rider;
      bytes : ARRAY 7 OF BYTE; i : INTEGER; set : SET;
      expectS : ARRAY 256 OF CHAR;
BEGIN test := TRUE;
  DStrings.Init("X", expectDS);
  DStrings.Init("", gotDS);
  DStrings.Set(W, gotDS, 0);
  b := ORD("X"); c := "Y"; a := "Z and other letters";
  DStrings.Write(W, b);
  ExpectedDString(expectDS, gotDS, "Write(W, b)", test);
  DStrings.CopyChars("XY", expectDS);
  DStrings.WriteChar(W, c);
  ExpectedDString(expectDS, gotDS, "WriteChar(W, c)", test);

  DStrings.Init("XYZ and other letters", expectDS);
  DStrings.WriteString(W, a);
  ExpectedDString(expectDS, gotDS, "WriteString(W, a)", test);
   
  DStrings.Init("XYZ and other letters. Then the dinosaurs arrived. ", expectDS);
  DStrings.Init(". Then the dinosaurs arrived. ", src);
  DStrings.WriteDString(W, src);
  ExpectedDString(expectDS, gotDS, "WriteDString(W, src)", test);

  DStrings.Init("XYZ and other letters. Then the dinosaurs arrived. 1", expectDS);
  DStrings.WriteInt(W, 1);
  ExpectedDString(expectDS, gotDS, "WriteInt(W, 1)", test);

  DStrings.Init("XYZ and other letters. Then the dinosaurs arrived. 13.1459", expectDS);
  DStrings.WriteReal(W, 3.1459);
  ExpectedDString(expectDS, gotDS, "WriteReal(W, 3.1459)", test);

  DStrings.Init("3.14", expectDS);
  DStrings.Clear(gotDS);
  DStrings.Set(W, gotDS, 0);
  DStrings.WriteFixed(W, 3.1459, 2);
  ExpectedDString(expectDS, gotDS, "WriteFixed(W, 3.1459, 2)", test);

  DStrings.Init("true", expectDS);
  DStrings.Clear(gotDS);
  DStrings.Set(W, gotDS, 0);
  DStrings.WriteBool(W, TRUE);
  ExpectedDString(expectDS, gotDS, "WriteBool(W, TRUE)", test);

  DStrings.Init("false", expectDS);
  DStrings.Clear(gotDS);
  DStrings.Set(W, gotDS, 0);
  DStrings.WriteBool(W, FALSE);
  ExpectedDString(expectDS, gotDS, "WriteBool(W, FALSE)", test);

  FOR i := 0 TO 6 DO
    bytes[i] := ORD("l") + i;
  END;
  DStrings.Init("lmnopqr", expectDS);
  DStrings.Clear(gotDS);
  DStrings.Set(W, gotDS, 0);
  DStrings.WriteBytes(W, bytes, LEN(bytes));
  ExpectedDString(expectDS, gotDS, "WriteBytes(W, bytes)", test);

  set := {};
  DStrings.Init("{}", expectDS);
  DStrings.Clear(gotDS);
  DStrings.Set(W, gotDS, 0);
  DStrings.WriteSet(W, set);
  ExpectedDString(expectDS, gotDS, "WriteSet(W, set) {}", test);

  set := {1};
  DStrings.Init("{1}", expectDS);
  DStrings.ToChars(expectDS, expectS, i);
  DStrings.Clear(gotDS);
  DStrings.Set(W, gotDS, 0);
  DStrings.WriteSet(W, set);
  ExpectedDString(expectDS, gotDS, "WriteSet(W, set) {1}", test);

  set := {1,5,9,23,24};
  DStrings.Init("{1,5,9,23,24}", expectDS);
  DStrings.Clear(gotDS);
  DStrings.Set(W, gotDS, 0);
  DStrings.WriteSet(W, set);
  ExpectedDString(expectDS, gotDS, "WriteSet(W, set) {1,5,9,23,24}", test);

  set := {1,3,5..7,11};
  DStrings.Init("{1,3,5..7,11}", expectDS);
  DStrings.Clear(gotDS);
  DStrings.Set(W, gotDS, 0);
  DStrings.WriteSet(W, set);
  ExpectedDString(expectDS, gotDS, "WriteSet(W, set) {1,3,5..7,11}", test);

  RETURN test
END TestWriteProcs;

BEGIN
  T.Init(ts, "Test DStrings");
  T.Add(ts,TestInit);
  T.Add(ts,TestToChars);
  T.Add(ts,TestRider);
  T.Add(ts,TestCopy);

  (* Test the Chars based procedures *)
  T.Add(ts,TestInsert);
  T.Add(ts,TestAppend);
  T.Add(ts,TestDelete);
  T.Add(ts,TestExtract);
  T.Add(ts,TestPos);
  T.Add(ts,TestReplace);
  T.Add(ts,TestCap);
  T.Add(ts,TestStartsWith);

  (* Test the Files base procedures *)
  T.Add(ts,TestReadProcs);
  T.Add(ts,TestWriteProcs);

  (* Run tests *)
  ASSERT(T.Run(ts));
END DStringsTest.

DStringsTest
============

Tests the DStrings module.


