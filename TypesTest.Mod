MODULE TypesTest;
  IMPORT Types, T := Tests;

VAR
    ts : T.TestSet;

PROCEDURE TestIsA() : BOOLEAN;
  VAR test, expected, got : BOOLEAN;
BEGIN test := TRUE;
  expected := TRUE;
  got := Types.IsCharDigit("7");
  T.ExpectedBool(expected, got, "Types.IsDigit(7)", test);
  got := Types.IsDigitOrSign("-");
  T.ExpectedBool(expected, got, "Types.IsDigitOrSign(-)", test);
  got := Types.IsDigitOrSign("+");
  T.ExpectedBool(expected, got, "Types.IsDigitOrSign(+)", test);
  got := Types.IsDigitSignOrPeriod(".");
  T.ExpectedBool(expected, got, "Types.IsDigitSignOrPeriod(.)", test);

  expected := FALSE;
  got := Types.IsCharDigit("-");
  T.ExpectedBool(expected, got, "Types.IsDigit(-)", test);
  got := Types.IsCharDigit("q");
  T.ExpectedBool(expected, got, "Types.IsDigitOrSign(q)", test);

  RETURN test
END TestIsA;

PROCEDURE TestDigitHandling() : BOOLEAN;
  VAR test : BOOLEAN; i, j : INTEGER; ch : CHAR;
BEGIN test := TRUE;
  i := 0;
  WHILE (i < 10) & test DO
    ch := Types.DigitToChar(i, test);
    test := test & Types.IsCharDigit(ch);
    INC(i);
  END;
  i := ORD("0");
  WHILE (i <= ORD("9")) & test DO
    j := Types.CharToDigit(CHR(i), test);
    test := test & Types.IsIntDigit(j);
    INC(i);
  END;
  RETURN test
END TestDigitHandling;

PROCEDURE TestItoa() : BOOLEAN;
  VAR test, ok : BOOLEAN; expected, got : ARRAY 256 OF CHAR;
      src : INTEGER;
BEGIN test := TRUE;
  src := 1;
  expected := "1";
  Types.Itoa(src, got, ok);
  T.ExpectedString(expected, got, "Itoa(1, got, ok)", test);

  src := -1;
  expected := "-1";
  Types.Itoa(src, got, ok);
  T.ExpectedString(expected, got, "Itoa(-1, got, ok)", test);
(*
  src := 12;
  expected := "12";
  Types.Itoa(src, got, ok);
  T.ExpectedString(expected, got, "Itoa(12, got, ok)", test);

  src := -12;
  expected := "-12";
  Types.Itoa(src, got, ok);
  T.ExpectedString(expected, got, "Itoa(-12, got, ok)", test);

  src := -1234;
  expected := "-1234";
  Types.Itoa(src, got, ok);
  T.ExpectedString(expected, got, "Itoa(-1234, got, ok)", test);

  src := 1234567890;
  expected := "1234567890";
  Types.Itoa(src, got, ok);
  T.ExpectedString(expected, got, "Itoa(1234567890, got, ok)", test);
  T.ExpectedBool(TRUE, ok, "Itoa(1234567890, got,ok), ok = TRUE, expected no overflow", test);

  src := -1234567890;
  expected := "-1234567890";
  Types.Itoa(src, got, ok);
  T.ExpectedString(expected, got, "Itoa(-1234567890, got, ok)", test);
  T.ExpectedBool(TRUE, ok, "Itoa(-1234567890, got,ok), ok = TRUE, expected no overflow", test);

  src := 2147483647;
  expected := "2147483647";
  Types.Itoa(src, got, ok);
  T.ExpectedString(expected, got, "Itoa(2147483647, got, ok)", test);
  T.ExpectedBool(TRUE, ok, "Itoa(2147483647, got, ok) ok = TRUE, expected no overflow", test);

  src := -2147483647;
  expected := "-2147483647";
  Types.Itoa(src, got, ok);
  T.ExpectedString(expected, got, "Itoa(-2147483647, got, ok)", test);
  T.ExpectedBool(TRUE, ok, "Itoa(-2147483647, got, ok) should not have detected overflow, ok = TRUE", test);

  T.ExpectedBool(TRUE, FALSE, "TestItoa() not implemented", test);
  *)
  RETURN test
END TestItoa;

PROCEDURE TestAtoi() : BOOLEAN;
  VAR test, ok : BOOLEAN; expected, got : INTEGER;
      src : ARRAY 256 OF CHAR;
BEGIN test := TRUE;
  src := "1";
  expected := 1;
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`1`, got, ok)", test);

  src := "+1";
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`+1`, got, ok)", test);

  src := "-1";
  expected := -1;
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`-1`, got, ok)", test);

  src := "12";
  expected := 12;
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`12`, got, ok)", test);

  src := "+12";
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`12`, got, ok)", test);

  src := "-12";
  expected := -12;
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`-12`, got, ok)", test);

  src := "-1234";
  expected := -1234;
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`-1234`, got, ok)", test);

  src := "1234567890";
  expected := 1234567890;
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`1234567890`, got, ok)", test);
  T.ExpectedBool(TRUE, ok, "Atoi(`1234567890`, got, ok), ok = TRUE, expected no overflow", test);

  src := "-1234567890";
  expected := -1234567890;
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`-1234567890`, got, ok)", test);
  T.ExpectedBool(TRUE, ok, "Atoi(`-1234567890`, got, ok), ok = TRUE, expected no overflow", test);

  src := "2147483647";
  expected := 2147483647;
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`2147483647`, got, ok)", test);
  T.ExpectedBool(TRUE, ok, "Atoi(`2147483647`, got, ok) ok = TRUE, expected no overflow", test);

  src := "-2147483647";
  expected := -2147483647;
  Types.Atoi(src, got, ok);
  T.ExpectedInt(expected, got, "Atoi(`-2147483647`, got, ok)", test);
  T.ExpectedBool(TRUE, ok, "Atoi(`-2147483647`, got, ok) should not have detected overflow, ok = TRUE", test);

  (* NOTE: where the integer gets beyond range the compiler should
     detect and abort compilation *)
  RETURN test
END TestAtoi;


PROCEDURE TestRtoa() : BOOLEAN;
  VAR test, ok : BOOLEAN; expected, got : ARRAY 256 OF CHAR;
    src : REAL;
BEGIN test := TRUE;
  src := 1.0;
  expected := "1.0";
  Types.Rtoa(src, got, ok);
  T.ExpectedString(expected, got, "Rtoa(1.0, got, ok)", test);

  src := -1.0;
  expected := "-1.0";
  Types.Rtoa(src, got, ok);
  T.ExpectedString(expected, got, "Rtoa(-1.0, got, ok)", test);
  RETURN test
END TestRtoa;

PROCEDURE TestAtor() : BOOLEAN;
  VAR test, ok : BOOLEAN; expected, got : REAL; src : ARRAY 256 OF CHAR;
BEGIN test := TRUE;
  T.ExpectedBool(TRUE, FALSE, "TestAtor() not implemented", test);
(*  
  src := "1.0";
  expected := 1.0;
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`1.0`, got, ok)", test);

  src := "+1.0";
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`+1.0`, got, ok)", test);

  src := "-1.0";
  expected := -1.0;
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`-1.0`, got, ok)", test);

  src := "1.2";
  expected := 1.2;
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`1.2`, got, ok)", test);

  src := "+1.2";
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`1.2`, got, ok)", test);

  src := "-1.2";
  expected := -1.2;
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`-1.2`, got, ok)", test);

  src := "-12.34";
  expected := -12.34;
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`-12.34`, got, ok)", test);

  src := "12345.67890";
  expected := 12345.6789;
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`12345.67890`, got, ok)", test);
  T.ExpectedBool(TRUE, ok, "Ator(`12345.67890`, got, ok), ok = TRUE, expected no overflow", test);

  src := "-1.234567890";
  expected := -1.234567890;
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`-1.234567890`, got,ok)", test);
  T.ExpectedBool(TRUE, ok, "Ator(`-1.234567890`, got,ok), ok = TRUE, expected no overflow", test);

  src := "214748364.7";
  expected := 214748364.7;
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`214748364.7`, got, ok)", test);
  T.ExpectedBool(TRUE, ok, "Ator(`214748364.7`, got, ok) ok = TRUE, expected no overflow", test);

  src := "-2147483647.0";
  expected := -2147483647.0;
  Types.Ator(src, got, ok);
  T.ExpectedReal(expected, got, "Ator(`-2147483647.0`, got,ok)", test);
  T.ExpectedBool(TRUE, ok, "Ator(`-2147483647.0`, got, ok) should not have detected overflow, ok = TRUE", test);
*)
  RETURN test
END TestAtor;


BEGIN
  T.Init(ts, "Test Types module");
  T.Add(ts, TestIsA, "Test IsA");
  T.Add(ts, TestDigitHandling, "Test Digit Handling");
  T.Add(ts, TestItoa, "Test Itoa");
  T.Add(ts, TestAtoi, "Test Atoi");
  T.Add(ts, TestRtoa, "Test Rtoa");
  T.Add(ts, TestAtor, "Test Ator");
  ASSERT(T.Run(ts));
END TypesTest.
