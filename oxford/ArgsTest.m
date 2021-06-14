MODULE ArgsTest;

IMPORT T := Tests, Args := extArgs, Out;

VAR ts : T.TestSet;

PROCEDURE TestOneTwoThree() : BOOLEAN;
  VAR test : BOOLEAN; one, two, three : ARRAY 12 OF CHAR;
      res : INTEGER;
BEGIN test := TRUE;
  T.ExpectedInt(3, Args.count, "Args.count for 'argtest one two three'", test);
  IF Args.count = 3 THEN
    Args.Get(0, one, res);
    Args.Get(1, two, res);
    Args.Get(2, three, res);

    T.ExpectedString("one", one, "Args.Get(0, one, res) for 'argtest one two three'", test);
    T.ExpectedString("two", two, "Args.Get(1, two, res) for 'argtest one two three'", test);
    T.ExpectedString("three", three, "Args.Get(2, three, res) for 'argtest one two three'", test);
  END;
  RETURN test
END TestOneTwoThree;

BEGIN
  Out.String("NOTE: run `argtest one two three`"); Out.Ln;
  T.Init(ts, "ArgsTest");
  T.Add(ts, TestOneTwoThree);
  ASSERT(T.Run(ts));
END ArgsTest.

