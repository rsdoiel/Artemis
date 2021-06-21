MODULE ConfigTest;

IMPORT T := Tests, Config, Strings;

VAR
  ts : T.TestSet;

PROCEDURE TestInit*() : BOOLEAN;
  VAR test : BOOLEAN;
BEGIN test := TRUE;
  Config.Init();
  T.ExpectedBool(TRUE, (Strings.Length(Config.version) > 0), "Config.version should be a non-empty string", test);
  T.ExpectedBool(TRUE, (Strings.Length(Config.prefix) > 0), "Config.prefix should be a non-empty string", test);
  T.ExpectedBool(TRUE, (Strings.Length(Config.libDir) > 0), "Config.libDir should be a non-empty string", test);
  RETURN test
END TestInit;

BEGIN
  T.Init(ts, "Config");
  T.Add(ts, TestInit);
  ASSERT(T.Run(ts));
END ConfigTest.
