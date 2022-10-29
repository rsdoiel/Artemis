MODULE ScannerTest;

IMPORT Scanner, T := Tests;

VAR ts : T.TestSet;

PROCEDURE TestScanner() : BOOLEAN;
	VAR s : Scanner.Scanner; 
	    txt, token, expected : ARRAY 256 OF CHAR;
	    test, OK : BOOLEAN;
BEGIN test := FALSE;
	txt := "I think pi is about 3.145";
	Scanner.Init(s, Scanner.SPACE, Scanner.DQUOTE, Scanner.DQUOTE, Scanner.BSLASH);
	expected := "I"
	Scanner.ScanChars(s, txt, token, OK);
	T.ExpectedBool(TRUE, OK, "Scanner.Chars(s, txt, token, OK) should be true", test);
	T.ExpectedString(expected, token, "Expected 'I', got something else", test);
	
	RETURN test
END TestScanner;

BEGIN
	T.Init(ts, "Test Scanner");
	T.Add(ts, TestScanner);
	ASSERT(T.Run(ts));
END ScannerTest.
