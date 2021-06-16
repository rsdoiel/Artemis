(** CharsTest.Mod - test procedure the Chars.Mod.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause
*)
MODULE CharsTest;

IMPORT Chars, Out, T := Tests;

CONST
    MAXSTR = Chars.MAXSTR;

VAR
    ts : T.TestSet;

(* Test Oakwood Module compatibility *)

PROCEDURE TestLength() : BOOLEAN;
  VAR test : BOOLEAN; a, b : ARRAY MAXSTR OF CHAR;
BEGIN test := TRUE;
  a := "abc";
  T.ExpectedInt(3, Chars.Length(a), "a = 'abc' should be length 3", test); 
  b := "defghi";
  T.ExpectedInt(6, Chars.Length(b), "b = 'defghi' should be length 6", test); 
  a[0] := 0X;
  T.ExpectedInt(0, Chars.Length(a), "a = '' should be zero", test);
  RETURN test
END TestLength;

PROCEDURE TestInsert() : BOOLEAN;
  VAR test : BOOLEAN; s1, s2, expected: ARRAY MAXSTR OF CHAR;
BEGIN test := TRUE;
  expected := "one two three";
  s1 := "two three";
  s2 := "one ";
  Chars.Insert(s2, 0, s1);
  T.ExpectedString(expected, s1, "Insert('one ', 0, 'two three')", test);

  Chars.Clear(s1); Chars.Clear(s2);
  s1 := "one three";
  s2 := "two ";
  Chars.Insert(s2, 4, s1);
  T.ExpectedString(expected, s1, "Insert('two ', 4, 'one three')", test);

  Chars.Clear(s1); Chars.Clear(s2);
  s1 := "one three";
  s2 := " two";
  Chars.Insert(s2, 3, s1);
  T.ExpectedString(expected, s1, "Insert('two ', 3, 'one three')", test);

  RETURN test
END TestInsert;

PROCEDURE TestAppend() : BOOLEAN;
VAR c, s : ARRAY MAXSTR OF CHAR; test : BOOLEAN;
BEGIN
    test := TRUE;
    Chars.Clear(c);
    Chars.Clear(s);
    c := "3";
    s := "2";
    Chars.Append(c, s);
    T.ExpectedString("23", s, "Expected A return TRUE, FALSE", test);
    T.ExpectedInt(2, Chars.Length(s), "Expected length 2 for string ", test);
    RETURN test
END TestAppend;

PROCEDURE TestDelete() : BOOLEAN;
  VAR test : BOOLEAN; s1, expected: ARRAY MAXSTR OF CHAR;
BEGIN test := TRUE;
  Chars.Clear(expected); Chars.Clear(s1);
  expected := "two three four";
  s1 := "one two three four";
  Chars.Delete(s1, 0, 4);
  T.ExpectedString(expected, s1, "Delete('one two three four', 0, 4)", test);

  Chars.Clear(expected); Chars.Clear(s1);
  expected := "one three four";
  s1 := "one two three four";
  Chars.Delete(s1, 4, 4);
  T.ExpectedString(expected, s1, "Delete('one two three four', 4, 4)", test);

  Chars.Clear(expected); Chars.Clear(s1);
  expected := "one two three";
  s1 := "one two three four";
  Chars.Delete(s1, 13, 5);
  T.ExpectedString(expected, s1, "Delete('one two three four', 13, 5)", test);

  Chars.Clear(expected); Chars.Clear(s1);
  expected := "one two three";
  s1 := "one two three four";
  Chars.Delete(s1, 13, 10);
  T.ExpectedString(expected, s1, "Delete('one two three four', 13, 10)", test);

  Chars.Clear(expected); Chars.Clear(s1);
  expected := "one><three four";
  s1 := "one>two<three four";
  Chars.Delete(s1, 4, 3);
  T.ExpectedString(expected, s1, "Delete('one>two<three four', 4, 3)", test);

  RETURN test
END TestDelete;

PROCEDURE TestReplace() : BOOLEAN;
  VAR test : BOOLEAN; source, dest, expected : ARRAY MAXSTR OF CHAR;
BEGIN test := TRUE;
  Chars.Clear(expected); Chars.Clear(source); Chars.Clear(dest);
  expected := "one 222 three";
  source := "222";
  dest := "one two three";
  Chars.Replace(source, 4, dest);
  T.ExpectedString(expected, dest, "Replace('222', 4, dest)", test);

  Chars.Clear(expected); Chars.Clear(source);
  expected := "111 222 three";
  source := "111";
  Chars.Replace(source, 0, dest);
  T.ExpectedString(expected, dest, "Replace('111', 0, dest)", test);

  Chars.Clear(expected); Chars.Clear(source);
  expected := "111 222 33333";
  source := "33333";
  Chars.Replace(source, 8, dest);
  T.ExpectedString(expected, dest, "Replace('33333', 8, dest)", test);

  RETURN test
END TestReplace;

PROCEDURE TestCap() : BOOLEAN;
  VAR test : BOOLEAN; got, expected : ARRAY MAXSTR OF CHAR;
BEGIN test := TRUE;
  expected := "ABCDE";
  got := "AbCdE";
  Chars.Cap(got);
  T.ExpectedString(expected, got, "Cap('AbCdE')", test);
  RETURN test
END TestCap;

PROCEDURE TestExtract() : BOOLEAN;
  VAR test : BOOLEAN; s1, s2, expected : ARRAY MAXSTR OF CHAR;
BEGIN test := TRUE;
  expected := "one";
  s1 := "one two three";
  Chars.Extract(s1, 0, 3, s2);
  T.ExpectedString(expected, s2, "Extract(s1, 0, 3, s2)", test);
  expected := "two";
  Chars.Extract(s1, 4, 3, s2);
  T.ExpectedString(expected, s2, "Extract(s1, 4, 3, s2)", test);
  expected := "three";
  Chars.Extract(s1, 8, 12, s2);
  T.ExpectedString(expected, s2, "Extract(s1, 8, 12, s2)", test);
  RETURN test
END TestExtract;


(* Test Chars extended features *)
PROCEDURE TestIsX() : BOOLEAN;
  VAR test, expected, got : BOOLEAN;
BEGIN test := TRUE;
  expected := TRUE; got := Chars.IsAlpha("T");
  T.ExpectedBool(expected, got, "IsAlpha(T)", test);
  got := Chars.IsPrintable("T");
  T.ExpectedBool(expected, got, "IsPrintable(T)", test);
  expected := FALSE;
  got := Chars.IsPrintable(13X);
  T.ExpectedBool(expected, got, "IsPrintable(13X)", test);
  RETURN test
END TestIsX;

PROCEDURE TestEqual() : BOOLEAN;
VAR test, testVal : BOOLEAN; s1, s2 : ARRAY MAXSTR OF CHAR;
BEGIN test := TRUE;
    Chars.Clear(s1);
    Chars.Clear(s2);
    s1 := "One Two Three";
    s2 := "One Two Three";
    testVal := Chars.Equal(s1, s2);
    T.ExpectedBool(TRUE, testVal, "Chars.Equal('One Two Three', 'One Two Three')", test);
    
    Chars.Clear(s2);
    s2 := "two three four";
    testVal := Chars.Equal(s1, s2);
    T.ExpectedBool(FALSE, testVal, "Chars.Equal('One Two Three', 'two three four')", test);
    
	RETURN test
END TestEqual;

PROCEDURE TestAppendChar() : BOOLEAN;
  VAR c : CHAR; expectS, gotS : ARRAY 32 OF CHAR; test : BOOLEAN;
BEGIN
    test := TRUE;
    Chars.Clear(expectS);
    Chars.Clear(gotS);
    c := "5";
    Chars.Copy("test5", expectS);
    Chars.Copy("test", gotS);
    Chars.AppendChar(c, gotS);
    T.ExpectedString(expectS, gotS, "AppendChar(c, gotS) 5", test);
    RETURN test
END TestAppendChar;

PROCEDURE TestInsertChar() : BOOLEAN;
  VAR c : CHAR; expectS, gotS : ARRAY 32 OF CHAR; test : BOOLEAN;
BEGIN
  test := TRUE;
  Chars.Clear(expectS); Chars.Clear(gotS);
  c := "0";
  Chars.Copy("0test5", expectS);
  Chars.Copy("test5", gotS);
  Chars.InsertChar(c, 0, gotS);
  T.ExpectedString(expectS, gotS, "InsertChar(c, 0, gotS) 0", test);

  RETURN test
END TestInsertChar;

PROCEDURE DisplayStrings(msg, s1, s2 : ARRAY OF CHAR);
BEGIN
  Out.String(msg);Out.String(" '");
  Out.String(s1); Out.String("', '");
  Out.String(s2); Out.String("'"); Out.Ln();
END DisplayStrings;

PROCEDURE TestWith() : BOOLEAN;
VAR test : BOOLEAN; prefix, suffix, src : ARRAY Chars.MAXSTR OF CHAR;
BEGIN
    test := TRUE;
    Chars.Clear(prefix);Chars.Clear(src);Chars.Clear(suffix);
    prefix := "define(";
    suffix := ");";
    src := "define(OS, 'Linux');";
    IF Chars.StartsWith(prefix, src) # TRUE THEN
       DisplayStrings("Expected StartsWith() to be TRUE for prefix/src, ", prefix, src);
       test := FALSE;
    END;
    IF Chars.EndsWith(suffix, src) # TRUE THEN
       DisplayStrings("Expected EndsWith() to be TRUE for suffix/src, ", suffix, src);
       test := FALSE;
    END;
    Chars.Clear(src);
    src := "This is a silly string and message.";
    IF Chars.StartsWith(prefix, src) # FALSE THEN
       DisplayStrings("Expected StartsWith() to be FALSE for prefix/src, ", prefix, src);
       test := FALSE;
    END;
    IF Chars.EndsWith(suffix, src) # FALSE THEN
       DisplayStrings("Expected EndsWith() to be FALSE for prefix/src, ", suffix, src);
       test := FALSE;
    END;
    RETURN test
END TestWith;

PROCEDURE TestTrim() : BOOLEAN;
VAR test : BOOLEAN; prefix, suffix, src, expected : ARRAY Chars.MAXSTR OF CHAR;
BEGIN
    test := TRUE;
    Chars.Clear(prefix);Chars.Clear(src);Chars.Clear(suffix);Chars.Clear(expected);
    prefix := "define(";
    suffix := ");";
    src := "define(OS, 'Linux');";
    Chars.TrimPrefix(prefix, src);
    IF Chars.Equal(src, "OS, 'Linux');") # TRUE THEN
       DisplayStrings("Expected TrimPrefix() failed for prefix/src, ", prefix, src);
       test := FALSE;
    END;
    Chars.TrimSuffix(suffix, src);
    IF Chars.Equal(src, "OS, 'Linux'") # TRUE THEN
       DisplayStrings("Expected TrimSuffix() failed for suffix/src, ", suffix, src);
       test := FALSE;
    END;
    
    Chars.Clear(src);Chars.Clear(expected);
    expected := "This is a silly string and message.";
    src := "This is a silly string and message.";
    Chars.TrimPrefix(prefix, src);
    IF Chars.Equal(src, expected) # TRUE THEN
       DisplayStrings("Expected TrimPrefix('define(', ...) failed for expected/src, ", expected, src);
       test := FALSE;
    END;
    Chars.TrimSuffix(suffix, src);
    IF Chars.Equal(src, expected) # TRUE THEN
       DisplayStrings("Expected TrimSuffix(');', ...) failed for expected/src, ", expected, src);
       test := FALSE;
    END;

    Chars.Clear(src);Chars.Clear(expected);
	expected := "Hello World";
	src := "     Hello World            ";
	Chars.TrimSpace(src);
	IF src # expected THEN
		DisplayStrings("Expected trim space: ", expected, src);
	END;

    RETURN test
END TestTrim;

PROCEDURE TestPadding() : BOOLEAN;
  VAR test : BOOLEAN;
    expectS, gotS : ARRAY 256 OF CHAR;
BEGIN test := TRUE;
  expectS := "^^^^Fred";
  gotS := "Fred";
  Chars.LeftPad("^", 8, gotS);
  T.ExpectedString(expectS, gotS, "LeftPad('^', 8, gotS)", test);
  expectS := "^^^^Fred----";
  Chars.RightPad("-", 12, gotS);
  T.ExpectedString(expectS, gotS, "Right('-', 8, gotS)", test);
  gotS := "Fred";
  expectS := "....Fred....";
  Chars.Pad(".", 12, gotS);
  T.ExpectedString(expectS, gotS, "Pad('.', 8, gotS)", test);
  RETURN test
END TestPadding;

PROCEDURE TestIntToString() : BOOLEAN;
  VAR test, ok : BOOLEAN; i : INTEGER;
      expectS, gotS : ARRAY 1024 OF CHAR;
BEGIN test := TRUE;
  i := 0;
  expectS := "0"; gotS[0] := 0X;
  Chars.IntToString(i, gotS, ok);
  T.ExpectedBool(TRUE, ok, "IntToString(0, gotS, ok) ok", test);
  T.ExpectedString(expectS, gotS, "IntToString(0, gotS, ok) string", test);

  i := 42;
  expectS := "42"; gotS[0] := 0X;
  Chars.IntToString(i, gotS, ok);
  T.ExpectedBool(TRUE, ok, "IntToString(42, gotS, ok) ok", test);
  T.ExpectedString(expectS, gotS, "IntToString(42, gotS, ok) string", test);

  i := 1459000000;
  expectS := "1459000000"; gotS[0] := 0X;
  Chars.IntToString(i, gotS, ok);
  T.ExpectedBool(TRUE, ok, "IntToString(1459000000, gotS, ok) ok", test);
  T.ExpectedString(expectS, gotS, "IntToString(1459000000, gotS, ok) string", test);

  RETURN test
END TestIntToString;

PROCEDURE TestRealToString() : BOOLEAN;
  VAR test, ok : BOOLEAN; r : REAL;
      expectS, gotS : ARRAY 256 OF CHAR;
BEGIN test := TRUE;
  r := 3.1459;
  expectS := "3.1459"; gotS[0] := 0X;
  Chars.RealToString(r, gotS, ok);
  T.ExpectedBool(TRUE, ok, "ReadToString(3.1459, gotS, ok) ok", test);
  T.ExpectedString(expectS, gotS, "RealToString(3.1459, gotS, ok) string", test);
  RETURN test
END TestRealToString;

PROCEDURE TestFixedToString() : BOOLEAN;
  VAR test, ok : BOOLEAN; r : REAL;
      expectS, gotS : ARRAY 256 OF CHAR;
BEGIN test := TRUE;
  r := 3.1459;
  expectS := "3.14"; gotS[0] := 0X;
  Chars.RealToString(r, gotS, ok);
  T.ExpectedBool(TRUE, ok, "FixedToString(3.1459, 2, gotS, ok) ok", test);
  RETURN test
END TestFixedToString;

PROCEDURE TestSetToString() : BOOLEAN;
  VAR test : BOOLEAN; set : SET; expected, got : ARRAY 256 OF CHAR;
BEGIN test := TRUE;
  set := {1,3,5..7,11};
  expected := "{1,3,5..7,11}";
  Chars.SetToString(set, got);
  T.ExpectedString(expected, got, "SetToString({1,3,5..7,11}, got)", test);
  set := {};
  expected := "{}";
  Chars.SetToString(set, got);
  T.ExpectedString(expected, got, "SetToString({}, got)", test);
  set := {0};
  expected := "{0}";
  Chars.SetToString(set, got);
  T.ExpectedString(expected, got, "SetToString({0}, got)", test);
  set := {1,3,5,6,11};
  expected := "{1,3,5,6,11}";
  Chars.SetToString(set, got);
  T.ExpectedString(expected, got, "SetToString({1,3,5,6,11}, got)", test);

  RETURN test
END TestSetToString;

PROCEDURE TestBoolToString() : BOOLEAN;
  VAR test : BOOLEAN;
      expectS, gotS : ARRAY 256 OF CHAR;
BEGIN test := TRUE;
  expectS := "true";
  Chars.BoolToString(TRUE, gotS);
  T.ExpectedString(expectS, gotS, "BoolToString(TRUE, gotS)", test);
  expectS := "false";
  Chars.BoolToString(FALSE, gotS);
  T.ExpectedString(expectS, gotS, "BoolToString(FALSE, gotS)", test);
  RETURN test
END TestBoolToString;


BEGIN
    (* Intialize our Test Set *)
    T.Init(ts, "Test Chars");

    (* Test Oakwood module compatibility *)
    T.Add(ts, TestLength);
    T.Add(ts, TestInsert);
    T.Add(ts, TestAppend);
    T.Add(ts, TestDelete);
    T.Add(ts, TestReplace);
    T.Add(ts, TestExtract);
    T.Add(ts, TestCap);

    (* Test Extended Chars module compatibility *)
    T.Add(ts, TestEqual);
    T.Add(ts, TestAppendChar);
    T.Add(ts, TestInsertChar);
    T.Add(ts, TestWith);
    T.Add(ts, TestTrim);
    T.Add(ts, TestIsX);
    T.Add(ts, TestPadding);

    (* Converts to String *)
    T.Add(ts, TestIntToString);
    T.Add(ts, TestRealToString);
    T.Add(ts, TestFixedToString);
    T.Add(ts, TestSetToString);
    T.Add(ts, TestBoolToString);

    (* Run our test set *)
    ASSERT(T.Run(ts));
END CharsTest.

CharsTest
=========

Tests the Chars module.


