MODULE EnvTest;

IMPORT T := Tests, Env := extEnv, Out;

VAR ts : T.TestSet;

PROCEDURE TestEnv() : BOOLEAN;
  VAR test : BOOLEAN; value : ARRAY 256 OF CHAR;
      res : INTEGER;
BEGIN test := TRUE;
  Env.Get("GOOD_NIGHT", value, res);
  T.ExpectedString("Irine", value, "Env.Get('GOOD_NIGHT', value, res') for 'env GOOD_NIGHT=Irine envtest'", test);
  RETURN test
END TestEnv;

BEGIN
  Out.String("NOTE: run `env GOOD_NIGHT=Irine envtest`"); Out.Ln;
  T.Init(ts, "EnvTest");
  T.Add(ts, TestEnv);
  ASSERT(T.Run(ts));
END EnvTest.

