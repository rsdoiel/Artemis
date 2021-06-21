MODULE ORBTest;

IMPORT T := Tests, ORB;

VAR
  ts : T.TestSet;

PROCEDURE TestProcs() : BOOLEAN;
  VAR test : BOOLEAN;
BEGIN test := TRUE;
  ORB.Init();
  T.ExpectedBool(FALSE, test, "TestProcs() not implemented.", test);
  RETURN test
END TestProcs;

BEGIN
  T.Init(ts, "Test ORB");
  T.Add(ts, TestProcs);
  ASSERT(T.Run(ts));
END ORBTest.
