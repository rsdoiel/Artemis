MODULE ConvertTest;

IMPORT T := Tests, Convert := extConvert;

VAR ts : T.TestSet;

PROCEDURE TestIntConvs() : BOOLEAN;
  VAR test, ok : BOOLEAN; 
      expectI, gotI : INTEGER;
      expectS, gotS : ARRAY 128 OF CHAR;
BEGIN test := TRUE;
  gotS[0] := 0X; gotI := 0;
  expectI := 101;
  expectS := "101";

  Convert.StringToInt(expectS, gotI, ok);
  T.ExpectedBool(TRUE, ok, "StringToInt('101', gotI, ok) true", test);
  T.ExpectedInt(expectI, gotI, "StringToInt('101', gotI, ok)", test);

  Convert.IntToString(expectI, gotS, ok);
  T.ExpectedBool(TRUE, ok, "IntToString(101, gotS, ok) true", test);
  T.ExpectedString(expectS, gotS, "IntToString(101, gotS, ok)", test);
  
  RETURN test
END TestIntConvs;

PROCEDURE TestRealConvs() : BOOLEAN;
  VAR test, ok : BOOLEAN; 
      expectR, gotR : REAL;
      expectS, gotS : ARRAY 128 OF CHAR;
BEGIN test := TRUE;
  gotR := 0.0; gotS[0] := 0X;
  expectR := 3.1459;
  expectS := "3.145900";

  Convert.StringToReal(expectS, gotR, ok);
  T.ExpectedBool(TRUE, ok, "StringToReal('3.1459', gotR, ok) true", test);
  T.ExpectedReal(expectR, gotR, "StringToReal('3.1459', gotR, ok)", test);

  Convert.RealToString(expectR, gotS, ok);
  T.ExpectedBool(TRUE, ok, "RealToString(3.1459, gotS; ok) true", test);
  T.ExpectedString(expectS, gotS, "RealToString(3.1459, gotS, ok)", test);

  RETURN test
END TestRealConvs;

BEGIN
  T.Init(ts, "extConvert");
  T.Add(ts, TestIntConvs);
  T.Add(ts, TestRealConvs);
  ASSERT(T.Run(ts));
END ConvertTest.
