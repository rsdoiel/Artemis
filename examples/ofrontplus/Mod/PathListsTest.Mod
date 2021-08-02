MODULE PathListsTest;

IMPORT PathLists, T := Tests;

VAR ts : T.TestSet;

PROCEDURE TestEncodeDecode() : BOOLEAN;
    VAR test : BOOLEAN;
BEGIN test := TRUE;
    T.ExpectedBool(TRUE, FALSE, "TestEncodeDecode() not implemented", test);
    RETURN test
END TestEncodeDecode;

PROCEDURE TestLengthSetDelimiterFind() : BOOLEAN;
    VAR test : BOOLEAN;
BEGIN test := TRUE;
    T.ExpectedBool(TRUE, FALSE, "TestLengthSetDelimiterFind() not implemented.", test);
    RETURN test
END TestLengthSetDelimiterFind;

PROCEDURE TestPrepend() : BOOLEAN;
    VAR test : BOOLEAN;
BEGIN test := TRUE;
    T.ExpectedBool(TRUE, FALSE, "TestPrepend() not implemented.", test);
    RETURN test
END TestPrepend;

PROCEDURE TestAppend() : BOOLEAN;
    VAR test : BOOLEAN;
BEGIN test := TRUE;
    T.ExpectedBool(TRUE, FALSE, "TestAppend() not implemented. ", test);
    RETURN test
END TestAppend;

PROCEDURE TestCut() : BOOLEAN;
    VAR test : BOOLEAN;
BEGIN test := TRUE; 
    T.ExpectedBool(TRUE, FALSE, "TestCut() not implemented. ", test);
    RETURN test
END TestCut;

PROCEDURE TestApply() : BOOLEAN;
    VAR test : BOOLEAN;
BEGIN test := TRUE;
    T.ExpectedBool(TRUE,FALSE, "TestApply() not implemented.", test);
    RETURN test
END TestApply;

BEGIN
    T.Init(ts, "Test PathLists");
    T.Add(ts, TestEncodeDecode);
    T.Add(ts, TestLengthSetDelimiterFind);
    T.Add(ts, TestPrepend);
    T.Add(ts, TestAppend);
    T.Add(ts, TestCut);
    T.Add(ts, TestApply);
    ASSERT(T.Run(ts));
END PathListsTest.