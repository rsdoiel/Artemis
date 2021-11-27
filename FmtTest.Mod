(** FmtTest.Mod - test procedure the Fmt.Mod.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause
*)
MODULE FmtTest;
  IMPORT T := Tests; (* Fmt; *)

VAR 
  ts : T.TestSet;

PROCEDURE TestInts() : BOOLEAN;
  VAR test : BOOLEAN;
BEGIN test := TRUE;
  T.ExpectedBool(TRUE, FALSE, "TestInts() not implemented", test);
  RETURN test
END TestInts;

PROCEDURE TestReals() : BOOLEAN;
  VAR test : BOOLEAN;
BEGIN test := TRUE;
  T.ExpectedBool(TRUE, FALSE, "TestReals() not implemented", test);
  RETURN test
END TestReals;

BEGIN
  T.Init(ts, "Test Fmt");
  T.Add(ts, TestInts, "TestInts");
  T.Add(ts, TestReals, "TestReals");
  ASSERT(T.Run(ts));
END FmtTest.
