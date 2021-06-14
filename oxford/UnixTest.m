MODULE UnixTest;

IMPORT T := Tests, Unix, Out, Env := extEnv;

VAR
  ts : T.TestSet;
  successes, errors : INTEGER;

PROCEDURE TestKernelName() : BOOLEAN;
  VAR test: BOOLEAN; expected, got : ARRAY 256 OF CHAR; res : INTEGER;
BEGIN test := TRUE;
  Env.Get("OS", expected, res); 
  IF expected[0] = 0X THEN
    Out.String("Skipping TestKernelName(), missing environment"); Out.Ln();
    Out.String("variable OS (aka kernel name) needed to verify Unix.Kernel()"); Out.Ln();
  ELSE
    Unix.KernelName(got);
    T.ExpectedString(expected, got, "Unix.KernelName(s) should match env. OS", test);
  END;
  RETURN test
END TestKernelName;

PROCEDURE TestArchitectureName() : BOOLEAN;
  VAR test: BOOLEAN; expected, got : ARRAY 24 OF CHAR; res : INTEGER;
BEGIN test := TRUE;
  Env.Get("ARCH", expected, res);
  IF expected[0] = 0X THEN
    Out.String("Skipping TestArchitectureName(), missing environment"); Out.Ln();
    Out.String("variable ARCH needed to verify Unix.Architecture()"); Out.Ln();
  ELSE
    Unix.Architecture(got);
    T.ExpectedString(expected, got, "Unix.Architecture(s) should match env. OS", test);
  END;
  RETURN test
END TestArchitectureName;

PROCEDURE TestExit() : BOOLEAN;
BEGIN
  Unix.Exit(0);
  RETURN FALSE
END TestExit;

BEGIN
  T.Init(ts, "Test Unix");
  T.Add(ts, TestKernelName);
  T.Add(ts, TestArchitectureName);
  ASSERT(T.Run(ts));
  (* Testing Unix.Exit(1) is tricky *)
  successes := 0; errors := 0;
  IF ~ TestExit() THEN
    Out.String("Test of Unix.Exit(), failed"); Out.Ln();
    ASSERT(FALSE);
  END;
END UnixTest.
