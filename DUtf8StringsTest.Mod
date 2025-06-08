(** DUtf8StringsTest.Mod tests the DUtf8Strings module.

Copyright (C) 2025 Artemis Project

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause
*)
MODULE DUtf8StringsTest;

IMPORT T := Tests, DUtf8Strings;

VAR 
  ts : T.TestSet;

(* Helper: ExpectedDUtf8String compares two DUtf8String values *)
PROCEDURE ExpectedDUtf8String(expected, got : DUtf8Strings.DUtf8String; msg : ARRAY OF CHAR; VAR test : BOOLEAN);
VAR
  expectedChars, gotChars: ARRAY 256 OF CHAR;
  truncated: INTEGER;
BEGIN
  DUtf8Strings.ToChars(expected, expectedChars, truncated);
  DUtf8Strings.ToChars(got, gotChars, truncated);
  T.ExpectedString(expectedChars, gotChars, msg, test);
END ExpectedDUtf8String;

PROCEDURE TestInit() : BOOLEAN;
VAR
  test: BOOLEAN;
  s: DUtf8Strings.DUtf8String;
  len: INTEGER;
BEGIN
  test := TRUE;
  
  (* Test empty string *)
  DUtf8Strings.Init("", s);
  len := DUtf8Strings.Length(s);
  T.ExpectedInt(0, len, "Init empty string length", test);
  
  (* Test ASCII string *)
  DUtf8Strings.Init("Hello", s);
  len := DUtf8Strings.Length(s);
  T.ExpectedInt(5, len, "Init ASCII string length", test);
  
  (* Test UTF-8 string with multibyte characters *)
  DUtf8Strings.Init("Hëllö", s); (* ë and ö are 2-byte UTF-8 *)
  len := DUtf8Strings.Length(s);
  T.ExpectedInt(5, len, "Init UTF-8 string length", test);
  
  RETURN test
END TestInit;

PROCEDURE TestToChars() : BOOLEAN;
VAR
  test: BOOLEAN;
  s: DUtf8Strings.DUtf8String;
  result: ARRAY 32 OF CHAR;
  truncated: INTEGER;
BEGIN
  test := TRUE;
  
  (* Test ASCII conversion *)
  DUtf8Strings.Init("Hello", s);
  DUtf8Strings.ToChars(s, result, truncated);
  T.ExpectedString("Hello", result, "ToChars ASCII", test);
  T.ExpectedInt(0, truncated, "ToChars ASCII no truncation", test);
  
  (* Test empty string conversion *)
  DUtf8Strings.Init("", s);
  DUtf8Strings.ToChars(s, result, truncated);
  T.ExpectedChar(0X, result[0], "ToChars empty string", test);
  T.ExpectedInt(0, truncated, "ToChars empty no truncation", test);
  
  RETURN test
END TestToChars;

PROCEDURE TestCopy() : BOOLEAN;
VAR
  test: BOOLEAN;
  source, dest: DUtf8Strings.DUtf8String;
  sourceLen, destLen: INTEGER;
BEGIN
  test := TRUE;
  
  (* Test copying ASCII string *)
  DUtf8Strings.Init("Test", source);
  DUtf8Strings.Copy(source, dest);
  sourceLen := DUtf8Strings.Length(source);
  destLen := DUtf8Strings.Length(dest);
  T.ExpectedInt(sourceLen, destLen, "Copy ASCII length match", test);
  T.ExpectedInt(4, sourceLen, "Copy ASCII source length", test);
  ExpectedDUtf8String(source, dest, "Copy ASCII content", test);
  
  (* Test copying empty string *)
  DUtf8Strings.Init("", source);
  DUtf8Strings.Copy(source, dest);
  destLen := DUtf8Strings.Length(dest);
  T.ExpectedInt(0, destLen, "Copy empty string", test);
  
  RETURN test
END TestCopy;

PROCEDURE TestRider() : BOOLEAN;
VAR
  test: BOOLEAN;
  s: DUtf8Strings.DUtf8String;
  r: DUtf8Strings.Rider;
  codepoint: INTEGER;
  base: DUtf8Strings.DUtf8String;
BEGIN
  test := TRUE;
  
  (* Test rider on ASCII string *)
  DUtf8Strings.Init("ABC", s);
  DUtf8Strings.Set(r, s, 0);
  
  (* Test Base procedure *)
  base := DUtf8Strings.Base(r);
  T.ExpectedBool(TRUE, base = s, "Rider Base", test);
  
  (* Test Get procedure *)
  codepoint := DUtf8Strings.Get(r);
  T.ExpectedInt(ORD("A"), codepoint, "Rider Get first char", test);
  
  codepoint := DUtf8Strings.Get(r);
  T.ExpectedInt(ORD("B"), codepoint, "Rider Get second char", test);
  
  T.ExpectedInt(2, r.pos, "Rider position", test);
  T.ExpectedBool(FALSE, r.eot, "Rider not at end", test);
  
  codepoint := DUtf8Strings.Get(r);
  T.ExpectedInt(ORD("C"), codepoint, "Rider Get third char", test);
  T.ExpectedBool(TRUE, r.eot, "Rider at end", test);
  
  RETURN test
END TestRider;

PROCEDURE TestClear() : BOOLEAN;
VAR
  test: BOOLEAN;
  s: DUtf8Strings.DUtf8String;
  len: INTEGER;
BEGIN
  test := TRUE;
  
  DUtf8Strings.Init("Hello", s);
  DUtf8Strings.Clear(s);
  len := DUtf8Strings.Length(s);
  T.ExpectedInt(0, len, "Clear string", test);
  
  RETURN test
END TestClear;

BEGIN
  T.Init(ts, "DUtf8StringsTest");
  T.Add(ts, TestInit);
  T.Add(ts, TestToChars);
  T.Add(ts, TestCopy);
  T.Add(ts, TestRider);
  T.Add(ts, TestClear);
  ASSERT(T.Run(ts));
END DUtf8StringsTest.
