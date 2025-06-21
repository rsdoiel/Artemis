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
  (* Basic AND test *)
  a := 0FFH; b := 0AAH;
  result := Bitwise.And(a, b);
  Tests.ExpectedInt(0AAH, result, "Bitwise.And basic test failed", test);
  
  (* Edge cases *)
  result := Bitwise.And(0, 0FFFFFFFFH);
  Tests.ExpectedInt(0, result, "Bitwise.And with zero failed", test);
  
  result := Bitwise.And(0FFFFFFFFH, 0FFFFFFFFH);
  Tests.ExpectedInt(0FFFFFFFFH, result, "Bitwise.And with all bits set failed", test);
  
  result := Bitwise.And(0FFFFFFFFH, 0);
  Tests.ExpectedInt(0, result, "Bitwise.And all bits with zero failed", test);
  
  (* Negative numbers *)
  result := Bitwise.And(-1, 0FFH);
  Tests.ExpectedInt(0FFH, result, "Bitwise.And with negative number failed", test);
  
  RETURN test
END TestAnd;

PROCEDURE TestAnd8*(): BOOLEAN;
  VAR a, b, result: BYTE; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic AND test *)
  a := 0FFH; b := 0AAH;
  result := Bitwise.And8(a, b);
  Tests.ExpectedInt(0AAH, result, "Bitwise.And8 basic test failed", test);
  
  (* Edge cases *)
  result := Bitwise.And8(0, 0FFH);
  Tests.ExpectedInt(0, result, "Bitwise.And8 with zero failed", test);
  
  result := Bitwise.And8(0FFH, 0FFH);
  Tests.ExpectedInt(0FFH, result, "Bitwise.And8 with all bits set failed", test);
  
  result := Bitwise.And8(0F0H, 00FH);
  Tests.ExpectedInt(0, result, "Bitwise.And8 non-overlapping bits failed", test);
  
  RETURN test
END TestAnd8;

PROCEDURE TestOr*(): BOOLEAN;
  VAR a, b, result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic OR test *)
  a := 0FFH; b := 0AAH;
  result := Bitwise.Or(a, b);
  Tests.ExpectedInt(0FFH, result, "Bitwise.Or basic test failed", test);
  
  (* Edge cases *)
  result := Bitwise.Or(0, 0);
  Tests.ExpectedInt(0, result, "Bitwise.Or with zeros failed", test);
  
  result := Bitwise.Or(0F0H, 00FH);
  Tests.ExpectedInt(0FFH, result, "Bitwise.Or complementary bits failed", test);
  
  result := Bitwise.Or(0FFFFFFFFH, 0);
  Tests.ExpectedInt(0FFFFFFFFH, result, "Bitwise.Or all bits with zero failed", test);
  
  RETURN test
END TestOr;

PROCEDURE TestOr8*(): BOOLEAN;
  VAR a, b, result: BYTE; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic OR test *)
  a := 0F0H; b := 00FH;
  result := Bitwise.Or8(a, b);
  Tests.ExpectedInt(0FFH, result, "Bitwise.Or8 basic test failed", test);
  
  (* Edge cases *)
  result := Bitwise.Or8(0, 0);
  Tests.ExpectedInt(0, result, "Bitwise.Or8 with zeros failed", test);
  
  result := Bitwise.Or8(0AAH, 055H);
  Tests.ExpectedInt(0FFH, result, "Bitwise.Or8 alternating bits failed", test);
  
  RETURN test
END TestOr8;

PROCEDURE TestXor*(): BOOLEAN;
  VAR a, b, result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic XOR test *)
  a := 0FFH; b := 0AAH;
  result := Bitwise.Xor(a, b);
  Tests.ExpectedInt(055H, result, "Bitwise.Xor basic test failed", test);
  
  (* Identity tests *)
  result := Bitwise.Xor(0AAH, 0AAH);
  Tests.ExpectedInt(0, result, "Bitwise.Xor identity test failed", test);
  
  result := Bitwise.Xor(0, 0AAH);
  Tests.ExpectedInt(0AAH, result, "Bitwise.Xor with zero failed", test);
  
  (* Complementary bits *)
  result := Bitwise.Xor(0F0H, 00FH);
  Tests.ExpectedInt(0FFH, result, "Bitwise.Xor complementary bits failed", test);
  
  RETURN test
END TestXor;

PROCEDURE TestXor8*(): BOOLEAN;
  VAR a, b, result: BYTE; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic XOR test *)
  a := 0FFH; b := 0AAH;
  result := Bitwise.Xor8(a, b);
  Tests.ExpectedInt(055H, result, "Bitwise.Xor8 basic test failed", test);
  
  (* Identity tests *)
  result := Bitwise.Xor8(0AAH, 0AAH);
  Tests.ExpectedInt(0, result, "Bitwise.Xor8 identity test failed", test);
  
  result := Bitwise.Xor8(0, 0AAH);
  Tests.ExpectedInt(0AAH, result, "Bitwise.Xor8 with zero failed", test);
  
  RETURN test
END TestXor8;

PROCEDURE TestNot*(): BOOLEAN;
  VAR a, result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic NOT test *)
  a := 0H;
  result := Bitwise.Not(a);
  Tests.ExpectedInt(0FFFFFFFFH, result, "Bitwise.Not zero failed", test);
  
  (* All bits set *)
  result := Bitwise.Not(0FFFFFFFFH);
  Tests.ExpectedInt(0, result, "Bitwise.Not all bits failed", test);
  
  (* Pattern test *)
  result := Bitwise.Not(0AAH);
  Tests.ExpectedInt(0FFFFFF55H, result, "Bitwise.Not pattern failed", test);
  
  RETURN test
END TestNot;

PROCEDURE TestNot8*(): BOOLEAN;
  VAR a, result: BYTE; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic NOT test *)
  a := 00H;
  result := Bitwise.Not8(a);
  Tests.ExpectedInt(0FFH, result, "Bitwise.Not8 zero failed", test);
  
  (* All bits set *)
  result := Bitwise.Not8(0FFH);
  Tests.ExpectedInt(0, result, "Bitwise.Not8 all bits failed", test);
  
  (* Pattern test *)
  result := Bitwise.Not8(0AAH);
  Tests.ExpectedInt(055H, result, "Bitwise.Not8 pattern failed", test);
  
  RETURN test
END TestNot8;

PROCEDURE TestShiftLeft*(): BOOLEAN;
  VAR result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic shift left *)
  result := Bitwise.ShiftLeft(0FFFFH, 1);
  Tests.ExpectedInt(01FFFEH, result, "Bitwise.ShiftLeft basic failed", test);
  
  (* Zero shift *)
  result := Bitwise.ShiftLeft(0FFFFH, 0);
  Tests.ExpectedInt(0FFFFH, result, "Bitwise.ShiftLeft zero shift failed", test);
  
  (* Large shift *)
  result := Bitwise.ShiftLeft(0FFFFH, 32);
  Tests.ExpectedInt(0, result, "Bitwise.ShiftLeft large shift failed", test);
  
  (* Negative shift *)
  result := Bitwise.ShiftLeft(0FFFFH, -1);
  Tests.ExpectedInt(0FFFFH, result, "Bitwise.ShiftLeft negative shift failed", test);
  
  (* Shift by 1 bit *)
  result := Bitwise.ShiftLeft(1, 1);
  Tests.ExpectedInt(2, result, "Bitwise.ShiftLeft single bit failed", test);
  
  RETURN test
END TestShiftLeft;

PROCEDURE TestShiftLeft8*(): BOOLEAN;
  VAR result: BYTE; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic shift left *)
  result := Bitwise.ShiftLeft8(0FH, 1);
  Tests.ExpectedInt(01EH, result, "Bitwise.ShiftLeft8 basic failed", test);
  
  (* Zero shift *)
  result := Bitwise.ShiftLeft8(0FFH, 0);
  Tests.ExpectedInt(0FFH, result, "Bitwise.ShiftLeft8 zero shift failed", test);
  
  (* Large shift *)
  result := Bitwise.ShiftLeft8(0FFH, 8);
  Tests.ExpectedInt(0, result, "Bitwise.ShiftLeft8 large shift failed", test);
  
  (* Overflow test *)
  result := Bitwise.ShiftLeft8(0FFH, 1);
  Tests.ExpectedInt(0FEH, result, "Bitwise.ShiftLeft8 overflow failed", test);
  
  RETURN test
END TestShiftLeft8;

PROCEDURE TestShiftRight*(): BOOLEAN;
  VAR result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic shift right *)
  result := Bitwise.ShiftRight(0FFFFH, 1);
  Tests.ExpectedInt(07FFFH, result, "Bitwise.ShiftRight basic failed", test);
  
  (* Zero shift *)
  result := Bitwise.ShiftRight(0FFFFH, 0);
  Tests.ExpectedInt(0FFFFH, result, "Bitwise.ShiftRight zero shift failed", test);
  
  (* Large shift with positive number *)
  result := Bitwise.ShiftRight(0FFFFH, 32);
  Tests.ExpectedInt(0, result, "Bitwise.ShiftRight large shift positive failed", test);
  
  (* Large shift with negative number *)
  result := Bitwise.ShiftRight(-1, 32);
  Tests.ExpectedInt(-1, result, "Bitwise.ShiftRight large shift negative failed", test);
  
  (* Negative number shift *)
  result := Bitwise.ShiftRight(-8, 1);
  Tests.ExpectedInt(-4, result, "Bitwise.ShiftRight negative number failed", test);
  
  RETURN test
END TestShiftRight;

PROCEDURE TestLogicalShiftRight*(): BOOLEAN;
  VAR a, result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  
  (* Basic logical shift right - positive number *)
  result := Bitwise.LogicalShiftRight(0FFFFH, 1);
  Tests.ExpectedInt(07FFFH, result, "Bitwise.LogicalShiftRight basic positive failed", test);
  
  (* Logical shift of negative number should fill with zeros *)
  result := Bitwise.LogicalShiftRight(-1, 1);
  Tests.ExpectedInt(7FFFFFFFH, result, "Bitwise.LogicalShiftRight negative number failed", test);
  
  (* Compare with arithmetic shift to verify difference *)
  a := -8; (* 0xFFFFFFF8 *)
  result := Bitwise.LogicalShiftRight(a, 1);
  Tests.ExpectedInt(7FFFFFFCH, result, "Bitwise.LogicalShiftRight vs arithmetic failed", test);
  
  (* Zero shift *)
  result := Bitwise.LogicalShiftRight(0FFFFH, 0);
  Tests.ExpectedInt(0FFFFH, result, "Bitwise.LogicalShiftRight zero shift failed", test);
  
  (* Large shift *)
  result := Bitwise.LogicalShiftRight(0FFFFFFFFH, 32);
  Tests.ExpectedInt(0, result, "Bitwise.LogicalShiftRight large shift failed", test);
  
  (* High bit set *)
  result := Bitwise.LogicalShiftRight(80000000H, 1);
  Tests.ExpectedInt(40000000H, result, "Bitwise.LogicalShiftRight high bit failed", test);
  
  RETURN test
END TestLogicalShiftRight;

PROCEDURE TestShiftRight8*(): BOOLEAN;
  VAR result: BYTE; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic shift right *)
  result := Bitwise.ShiftRight8(0FEH, 1);
  Tests.ExpectedInt(07FH, result, "Bitwise.ShiftRight8 basic failed", test);
  
  (* Zero shift *)
  result := Bitwise.ShiftRight8(0FFH, 0);
  Tests.ExpectedInt(0FFH, result, "Bitwise.ShiftRight8 zero shift failed", test);
  
  (* Large shift *)
  result := Bitwise.ShiftRight8(0FFH, 8);
  Tests.ExpectedInt(0, result, "Bitwise.ShiftRight8 large shift failed", test);
  
  (* Single bit *)
  result := Bitwise.ShiftRight8(2, 1);
  Tests.ExpectedInt(1, result, "Bitwise.ShiftRight8 single bit failed", test);
  
  RETURN test
END TestShiftRight8;

PROCEDURE TestRotateLeft*(): BOOLEAN;
  VAR result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic rotate left *)
  result := Bitwise.RotateLeft(0FFFFH, 1);
  Tests.ExpectedInt(01FFFEH, result, "Bitwise.RotateLeft basic failed", test);
  
  (* Zero rotation *)
  result := Bitwise.RotateLeft(0FFFFH, 0);
  Tests.ExpectedInt(0FFFFH, result, "Bitwise.RotateLeft zero rotation failed", test);
  
  (* Full rotation *)
  result := Bitwise.RotateLeft(0FFFFH, 32);
  Tests.ExpectedInt(0FFFFH, result, "Bitwise.RotateLeft full rotation failed", test);
  
  (* High bit rotation *)
  result := Bitwise.RotateLeft(080000000H, 1);
  Tests.ExpectedInt(1, result, "Bitwise.RotateLeft high bit failed", test);
  
  RETURN test
END TestRotateLeft;

PROCEDURE TestRotateLeft8*(): BOOLEAN;
  VAR result: BYTE; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic rotate left *)
  result := Bitwise.RotateLeft8(0FH, 1);
  Tests.ExpectedInt(01EH, result, "Bitwise.RotateLeft8 basic failed", test);
  
  (* Zero rotation *)
  result := Bitwise.RotateLeft8(0FFH, 0);
  Tests.ExpectedInt(0FFH, result, "Bitwise.RotateLeft8 zero rotation failed", test);
  
  (* Full rotation *)
  result := Bitwise.RotateLeft8(0FFH, 8);
  Tests.ExpectedInt(0FFH, result, "Bitwise.RotateLeft8 full rotation failed", test);
  
  (* High bit rotation *)
  result := Bitwise.RotateLeft8(080H, 1);
  Tests.ExpectedInt(1, result, "Bitwise.RotateLeft8 high bit failed", test);
  
  RETURN test
END TestRotateLeft8;

PROCEDURE TestRotateRight*(): BOOLEAN;
  VAR result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic rotate right *)
  result := Bitwise.RotateRight(0FFFFH, 1);
  Tests.ExpectedInt(080007FFFH, result, "Bitwise.RotateRight basic failed", test);
  
  (* Zero rotation *)
  result := Bitwise.RotateRight(0FFFFH, 0);
  Tests.ExpectedInt(0FFFFH, result, "Bitwise.RotateRight zero rotation failed", test);
  
  (* Full rotation *)
  result := Bitwise.RotateRight(0FFFFH, 32);
  Tests.ExpectedInt(0FFFFH, result, "Bitwise.RotateRight full rotation failed", test);
  
  (* Low bit rotation *)
  result := Bitwise.RotateRight(1, 1);
  Tests.ExpectedInt(080000000H, result, "Bitwise.RotateRight low bit failed", test);
  
  RETURN test
END TestRotateRight;

PROCEDURE TestRotateRight8*(): BOOLEAN;
  VAR result: BYTE; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Basic rotate right *)
  result := Bitwise.RotateRight8(0F0H, 1);
  Tests.ExpectedInt(078H, result, "Bitwise.RotateRight8 basic failed", test);
  
  (* Zero rotation *)
  result := Bitwise.RotateRight8(0FFH, 0);
  Tests.ExpectedInt(0FFH, result, "Bitwise.RotateRight8 zero rotation failed", test);
  
  (* Full rotation *)
  result := Bitwise.RotateRight8(0FFH, 8);
  Tests.ExpectedInt(0FFH, result, "Bitwise.RotateRight8 full rotation failed", test);
  
  (* Low bit rotation *)
  result := Bitwise.RotateRight8(1, 1);
  Tests.ExpectedInt(080H, result, "Bitwise.RotateRight8 low bit failed", test);
  
  RETURN test
END TestRotateRight8;

PROCEDURE TestCombinedOperations*(): BOOLEAN;
  VAR a, b, result: INTEGER; test: BOOLEAN;
BEGIN
  test := TRUE;
  (* Test De Morgan's law: NOT(a AND b) = (NOT a) OR (NOT b) *)
  a := 0AAH; b := 055H;
  result := Bitwise.Not(Bitwise.And(a, b));
  Tests.ExpectedInt(Bitwise.Or(Bitwise.Not(a), Bitwise.Not(b)), result, "De Morgan's law failed", test);
  
  (* Test XOR identity: a XOR b XOR b = a *)
  result := Bitwise.Xor(Bitwise.Xor(a, b), b);
  Tests.ExpectedInt(a, result, "XOR identity failed", test);
  
  (* Test shift equivalence: left shift by n = multiply by 2^n (for small values) *)
  a := 5;
  result := Bitwise.ShiftLeft(a, 2);
  Tests.ExpectedInt(20, result, "Shift left equivalence failed", test);
  
  RETURN test
END TestCombinedOperations;

BEGIN
  Tests.Init(ts, "Bitwise Tests");
  Tests.Add(ts, TestAnd);
  Tests.Add(ts, TestAnd8);
  Tests.Add(ts, TestOr);
  Tests.Add(ts, TestOr8);
  Tests.Add(ts, TestXor);
  Tests.Add(ts, TestXor8);
  Tests.Add(ts, TestNot);
  Tests.Add(ts, TestNot8);
  Tests.Add(ts, TestShiftLeft);
  Tests.Add(ts, TestShiftLeft8);
  Tests.Add(ts, TestShiftRight);
  Tests.Add(ts, TestLogicalShiftRight);
  Tests.Add(ts, TestShiftRight8);
  Tests.Add(ts, TestRotateLeft);
  Tests.Add(ts, TestRotateLeft8);
  Tests.Add(ts, TestRotateRight);
  Tests.Add(ts, TestRotateRight8);
  Tests.Add(ts, TestCombinedOperations);
  ASSERT(Tests.Run(ts))
END BitwiseTest.