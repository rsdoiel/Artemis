(** Obn2Test modules provides testing for Obn2 module.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

*)
MODULE Obn2Test;

IMPORT T := Tests, Obn2;

VAR ts : T.TestSet;

PROCEDURE TestMinMax() : BOOLEAN;
  VAR test : BOOLEAN; x, y, got, expected : INTEGER;
BEGIN test := TRUE;
  x := 11; y := 12;
  expected := x;
  got := Obn2.MIN(x,y);
  T.ExpectedInt(expected, got, "Test Min(x,y)", test);
  expected := y;
  got := Obn2.MAX(x, y);
  T.ExpectedInt(expected, got, "Test Mac(x,y)", test);
  RETURN test
END TestMinMax;

PROCEDURE TestShifts() : BOOLEAN;
  VAR test : BOOLEAN;
BEGIN test := TRUE;
  T.ExpectedBool(TRUE, FALSE, "TestShifts() not implemented.", test);
  RETURN test
END TestShifts;

BEGIN
  T.Init(ts, "Obn2");
  T.Add(ts, TestMinMax);
  T.Add(ts, TestShifts);
  ASSERT(T.Run(ts));
END Obn2Test.
