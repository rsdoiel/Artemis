MODULE SQLite3Test;

IMPORT T := Tests;

VAR
  title : ARRAY 256 OF CHAR;
  successes, errors : INTEGER;

PROCEDURE TestSQLite() : BOOLEAN;
  VAR test : BOOLEAN;
BEGIN test := TRUE;
  T.ExpectedBool(FALSE, test, "TestSQLite() not implemented", test);
  RETURN test
END TestSQLite;

BEGIN
  title := "SQLite3 module"; successes := 0; errors := 0;
  T.ShowTitle(title);
  T.Test(TestSQLite, successes, errors);
  T.Summarize(title, successes, errors);
END SQLite3Test.

