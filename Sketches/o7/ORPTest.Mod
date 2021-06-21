MODULE ORPTest;

IMPORT T := Tests;

VAR 
  ts : T.TestSet;

PROCEDURE TestProcs() : BOOLEAN;
  VAR test : BOOLEAN;
BEGIN test := TRUE;
  T.ExpectedBool(FALSE, test, "TestProcs() not implemented.", test);
  RETURN test
END TestProcs;

BEGIN
  T.Init(ts, "ORP");
  T.Add(ts, TestProcs);
  ASSERT(T.Run(ts));
END ORPTest.
