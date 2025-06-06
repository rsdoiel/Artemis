(** BitwiseTest.Mod - Tests for Bitwise.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE BitwiseTest;

IMPORT Bitwise, Tests;

VAR
  ts: Tests.TestSet;

PROCEDURE TestAnd*(): BOOLEAN;
  VAR a, b, result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  a := 0FFH; b := 0AAH;
  result := Bitwise.And(a, b);
  Tests.ExpectedInt(0AAH, result, "Bitwise.And failed", test);
  RETURN test
END TestAnd;

PROCEDURE TestOr*(): BOOLEAN;
  VAR a, b, result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  a := 0FFH; b := 0AAH;
  result := Bitwise.Or(a, b);
  Tests.ExpectedInt(0FFH, result, "Bitwise.Or failed", test);
  RETURN test
END TestOr;

PROCEDURE TestXor*(): BOOLEAN;
  VAR a, b, result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  a := 0FFH; b := 0AAH;
  result := Bitwise.Xor(a, b);
  Tests.ExpectedInt(055H, result, "Bitwise.Xor failed", test);
  RETURN test
END TestXor;

PROCEDURE TestNot*(): BOOLEAN;
  VAR a, result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  a := 0H;
  result := Bitwise.Not(a);
  Tests.ExpectedInt(0FFFFFFFFH, result, "Bitwise.Not failed", test);
  RETURN test
END TestNot;

PROCEDURE TestNot8*(): BOOLEAN;
  VAR a, result: BYTE; test: BOOLEAN;
BEGIN
  test := TRUE;
  a := 00H;
  result := Bitwise.Not8(a);
  Tests.ExpectedInt(0FFH, result, "Bitwise.Not8 failed", test);
  RETURN test
END TestNot8;

PROCEDURE TestShiftLeft*(): BOOLEAN;
  VAR result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  result := Bitwise.ShiftLeft(0FFFFH, 1);
  Tests.ExpectedInt(01FFFEH, result, "Bitwise.ShiftLeft failed", test);
  RETURN test
END TestShiftLeft;

PROCEDURE TestShiftRight*(): BOOLEAN;
  VAR result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  result := Bitwise.ShiftRight(0FFFFH, 1);
  Tests.ExpectedInt(07FFFH, result, "Bitwise.ShiftRight failed", test);
  RETURN test
END TestShiftRight;

PROCEDURE TestRotateLeft*(): BOOLEAN;
  VAR result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  result := Bitwise.RotateLeft(0FFFFH, 1);
  Tests.ExpectedInt(01FFFEH, result, "Bitwise.RotateLeft failed", test);
  RETURN test
END TestRotateLeft;

PROCEDURE TestRotateRight*(): BOOLEAN;
  VAR result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  result := Bitwise.RotateRight(0FFFFH, 1);
  Tests.ExpectedInt(080007FFFH, result, "Bitwise.RotateRight failed", test);
  RETURN test
END TestRotateRight;

BEGIN
  Tests.Init(ts, "Bitwise Tests");
  Tests.Add(ts, TestAnd);
  Tests.Add(ts, TestOr);
  Tests.Add(ts, TestXor);
  Tests.Add(ts, TestNot);
  Tests.Add(ts, TestNot8);
  Tests.Add(ts, TestShiftLeft);
  Tests.Add(ts, TestShiftRight);
  Tests.Add(ts, TestRotateLeft);
  Tests.Add(ts, TestRotateRight);
  ASSERT(Tests.Run(ts));
END BitwiseTest.