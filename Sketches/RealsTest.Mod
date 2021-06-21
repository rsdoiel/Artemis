MODULE RealsTest;

IMPORT T := Tests, Reals;

VAR
  ts : T.TestSet;

PROCEDURE TestSplitFixed() : BOOLEAN;
  VAR test : BOOLEAN; r : REAL; i, m : INTEGER;
BEGIN test := TRUE;
  r := 3.14159;
  Reals.SplitFixed(r, 2, i, m);
  T.ExpectedInt(3, i, "SplitFixed(r, 2, i, m) i = 3", test);
  T.ExpectedInt(14, m, "SplitFixed(r, 2, i, m) m = 14", test);
  RETURN test
END TestSplitFixed;


PROCEDURE TestFixedToString() : BOOLEAN;
  VAR test : BOOLEAN; r : REAL;
      expected, got : ARRAY 256 OF CHAR;
BEGIN test := TRUE;
  r := 3.14159;
  expected := "3.14";
  Reals.FixedToString(r, 2, got);
  T.ExpectedString(expected, got, "FixedToString(3.14159, 2, got)", test);
  RETURN test
END TestFixedToString;

PROCEDURE TestSplitReal() : BOOLEAN;
  VAR test, neg : BOOLEAN; r : REAL; i, m, exp : INTEGER;
BEGIN test := TRUE;
  r := 3.1459;
  Reals.splitReal(r, neg, i, m, exp);
  T.ExpectedBool(FALSE, neg, "splitReal(3.1459, i, m, exp) -> neg", test);
  T.ExpectedInt(3, i, "splitReal(3.1459, i, m, exp) -> i", test);
  T.ExpectedInt(1459, m, "splitReal(3.1459, i, m, exp) -> m", test);
  T.ExpectedInt(4, exp, "splitReal(3.1450, i, m, exp) -> exp", test);
  RETURN test
END TestSplitReal;

BEGIN
  T.Init(ts, "Test Reals");
  T.Add(ts,TestSplitFixed);
  T.Add(ts,TestFixedToString);
  T.Add(ts,TestSplitReal);
  ASSERT(T.Run(ts));
END RealsTest.
