(** RandomTest.Mod - Tests for Random.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)
MODULE RandomTest;
IMPORT Random, Tests;

VAR
  ts: Tests.TestSet;

PROCEDURE TestInitAndNext*(): BOOLEAN;
VAR
  pass: BOOLEAN;
  first, second: INTEGER;
BEGIN
  pass := TRUE;
  Random.Init(12345);
  first := Random.Next();
  Random.Init(12345);
  second := Random.Next();
  Tests.ExpectedInt(first, second, "Random.Init/Next not repeatable", pass);
  RETURN pass
END TestInitAndNext;

PROCEDURE TestRepeatability*(): BOOLEAN;
VAR
  pass: BOOLEAN; i: INTEGER;
  seq1, seq2: ARRAY 5 OF INTEGER;
BEGIN
  pass := TRUE;
  Random.Init(42);
  FOR i := 0 TO 4 DO seq1[i] := Random.Next() END;
  Random.Init(42);
  FOR i := 0 TO 4 DO seq2[i] := Random.Next() END;
  FOR i := 0 TO 4 DO
    Tests.ExpectedInt(seq1[i], seq2[i], "Random sequence not repeatable", pass)
  END;
  RETURN pass
END TestRepeatability;

PROCEDURE TestRange*(): BOOLEAN;
VAR
  pass: BOOLEAN; i, x: INTEGER;
BEGIN
  pass := TRUE;
  Random.Init(1);
  FOR i := 0 TO 9 DO
    x := Random.Next();
    IF (x <= 0) OR (x >= Random.Modulus) THEN
      pass := FALSE
    END
  END;
  IF ~pass THEN
    Tests.ExpectedInt(1, 0, "Random.Next() out of range", pass)
  END;
  RETURN pass
END TestRange;

PROCEDURE TestNextReal*(): BOOLEAN;
VAR
  pass: BOOLEAN; i: INTEGER; r: REAL;
BEGIN
  pass := TRUE;
  Random.Init(7);
  FOR i := 0 TO 9 DO
    r := Random.NextReal();
    IF (r <= 0.0) OR (r >= 1.0) THEN
      pass := FALSE
    END
  END;
  IF ~pass THEN
    Tests.ExpectedReal(0.5, r, "Random.NextReal() out of range", pass)
  END;
  RETURN pass
END TestNextReal;

BEGIN
  Tests.Init(ts, "Random Tests");
  Tests.Add(ts, TestInitAndNext);
  Tests.Add(ts, TestRepeatability);
  Tests.Add(ts, TestRange);
  Tests.Add(ts, TestNextReal);
  ASSERT(Tests.Run(ts));
END RandomTest.
