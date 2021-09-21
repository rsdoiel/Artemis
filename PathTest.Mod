MODULE PathTest;

IMPORT T := Tests, Path, Chars;

VAR ts : T.TestSet;

PROCEDURE TestMaxPath() : BOOLEAN;
    VAR test : BOOLEAN;
BEGIN test := TRUE;
    T.ExpectedInt(1024, Path.MAXLENGTH, "Current path maximum assumption", test);
    RETURN test
END TestMaxPath;

PROCEDURE TestSetDelimiter() : BOOLEAN;
    VAR test : BOOLEAN;
BEGIN test := TRUE;
    T.ExpectedChar(Chars.SLASH, Path.delimiter, "Checking default delimiter", test);
    Path.SetDelimiter(Chars.BSLASH);
    T.ExpectedChar(Chars.BSLASH, Path.delimiter, "Checking set delimiter to ';'", test);
    Path.SetDelimiter(Chars.SLASH);
    T.ExpectedChar(Chars.SLASH, Path.delimiter, "Checking set delimiter to ':'", test);
    RETURN test
END TestSetDelimiter;

PROCEDURE TestPrepend() : BOOLEAN;
    VAR test, ok : BOOLEAN; a : ARRAY Path.MAXLENGTH OF CHAR;
BEGIN test := TRUE;
    a[0] := 0X;
    Path.Prepend("", a, ok);
    T.ExpectedBool(TRUE, ok, "Path.Prepend('', a) ok -> ''", test);
    T.ExpectedString("", a, "Path.Prepend('', a)", test);
    Path.Prepend("/me", a, ok);
    T.ExpectedBool(TRUE, ok, "Path.Prepend('/me', a) ok -> /me", test);
    T.ExpectedString("/me", a, "Path.Prepend('/me', a)", test);
    Path.Prepend("/home", a, ok);
    T.ExpectedBool(TRUE, ok, "Path.Prepend('/home', a) ok -> /home/me", test);
    T.ExpectedString("/home/me", a, "Path.Prepend('home', a)", test);
    RETURN test
END TestPrepend;

PROCEDURE TestAppend() : BOOLEAN;
    VAR test, ok : BOOLEAN; a : ARRAY Path.MAXLENGTH OF CHAR;
BEGIN test := TRUE;
    a := "";
    Path.Append("", a, ok);
    T.ExpectedBool(TRUE, ok, "Path.Append('', a) ok -> ''", test);
    T.ExpectedString("", a, "Path.Append('', a)", test);
    Path.Append("/", a, ok);
    T.ExpectedBool(TRUE, ok, "Path.Append('/', a) ok -> '/'", test);
    T.ExpectedString("/", a, "Path.Append('/', a)", test);
    Path.Append("home", a, ok);
    T.ExpectedBool(TRUE, ok, "Path.Append('home', a) ok -> /home", test);
    T.ExpectedString("/home", a, "Path.Append('home', a)", test);
    Path.Append("me", a, ok);
    T.ExpectedBool(TRUE, ok, "Path.Append('', a) ok -> /home/me", test);
    T.ExpectedString("/home/me", a, "Path.Append('me', a) ok -> /home/me", test);
    RETURN test
END TestAppend;

PROCEDURE TestBasename() : BOOLEAN;
    VAR test, ok : BOOLEAN; a, expected, got : ARRAY Path.MAXLENGTH OF CHAR;
BEGIN test := TRUE;
    a := "/home/me/.profile";
    expected := ".profile";
    Path.Basename(a, got, ok);
    T.ExpectedBool(TRUE, ok, "Basename(a, got, ok) ok -> ?", test);
    T.ExpectedString(expected, got, "Path.Basename(a, got, ok)", test);
    RETURN test
END TestBasename;

PROCEDURE TestDirname() : BOOLEAN;
    VAR test, ok : BOOLEAN; a, expected, got : ARRAY Path.MAXLENGTH OF CHAR;
BEGIN test := TRUE;
    a := "/home/me/.profile";
    expected := "/home/me";
    Path.Dirname(a, got, ok);
    T.ExpectedBool(TRUE, ok, "Dirname(a, got, ok) ok -> ?", test);
    T.ExpectedString(expected, got, "Path.Dirname(a, got, ok)", test);
    RETURN test
END TestDirname;

PROCEDURE TestExt() : BOOLEAN;
    VAR test, ok : BOOLEAN; a, expected, got : ARRAY Path.MAXLENGTH OF CHAR;
BEGIN test := TRUE;
    a := "/home/me/README.txt";
    expected := ".txt";
    Path.Ext(a, got, ok);
    T.ExpectedBool(TRUE, ok, "Ext(a, got, ok) ok -> ?", test);
    T.ExpectedString(expected, got, "Path.Ext(a, got, ok)", test);
    RETURN test
END TestExt;

BEGIN 
    T.Init(ts, "Test Path");
    T.Add(ts, TestMaxPath);
    T.Add(ts, TestSetDelimiter);
    T.Add(ts, TestPrepend);
    T.Add(ts, TestAppend);
    T.Add(ts, TestDirname);
    T.Add(ts, TestBasename);
    T.Add(ts, TestExt);
    ASSERT(T.Run(ts));
END PathTest.
