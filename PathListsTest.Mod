MODULE PathListsTest;

IMPORT PathLists, T := Tests;

VAR ts : T.TestSet;

PROCEDURE TestEncodeDecode() : BOOLEAN;
    VAR test, ok : BOOLEAN; src, encoded : ARRAY 1024 OF CHAR;
        pl : PathLists.PathList;
BEGIN test := TRUE;
    src := "/bin:/usr/bin:/usr/local/bin:/home/jane.doe/bin";
    PathLists.Decode(src, pl, ok);
    T.ExpectedBool(TRUE, ok, "Expected to decode src", test);
    T.ExpectedInt(4, PathLists.Length(pl), "Expected 4 paths after decode", test);
    
    (* Test encoding back *)
    PathLists.Encode(pl, ":", encoded, ok);
    T.ExpectedBool(TRUE, ok, "Expected to encode successfully", test);
    T.ExpectedString(src, encoded, "Expected encoded string to match original", test);
    
    PathLists.Free(pl);
    RETURN test
END TestEncodeDecode;

PROCEDURE TestLengthSetDelimiterFind() : BOOLEAN;
    VAR test, ok : BOOLEAN; 
        pl : PathLists.PathList;
        pos : INTEGER;
BEGIN test := TRUE;
    (* Test with empty list *)
    pl := PathLists.New();
    T.ExpectedInt(0, PathLists.Length(pl), "Expected empty list to have length 0", test);
    
    (* Test Find on empty list *)
    pos := PathLists.Find("/bin", pl);
    T.ExpectedInt(-1, pos, "Expected Find to return -1 for empty list", test);
    
    (* Add some paths *)
    PathLists.Append("/bin", pl, ok);
    T.ExpectedBool(TRUE, ok, "Expected append to succeed", test);
    T.ExpectedInt(1, PathLists.Length(pl), "Expected length 1 after append", test);
    
    PathLists.Append("/usr/bin", pl, ok);
    T.ExpectedBool(TRUE, ok, "Expected second append to succeed", test);
    T.ExpectedInt(2, PathLists.Length(pl), "Expected length 2 after second append", test);
    
    (* Test Find *)
    pos := PathLists.Find("/bin", pl);
    T.ExpectedInt(0, pos, "Expected /bin to be found at position 0", test);
    
    pos := PathLists.Find("/usr/bin", pl);
    T.ExpectedInt(1, pos, "Expected /usr/bin to be found at position 1", test);
    
    pos := PathLists.Find("/nonexistent", pl);
    T.ExpectedInt(-1, pos, "Expected nonexistent path to return -1", test);
    
    PathLists.Free(pl);
    RETURN test
END TestLengthSetDelimiterFind;

PROCEDURE TestPrepend() : BOOLEAN;
    VAR test, ok : BOOLEAN;
        pl : PathLists.PathList;
        pos : INTEGER;
BEGIN test := TRUE;
    pl := PathLists.New();
    
    (* Test prepend to empty list *)
    PathLists.Prepend("/first", pl, ok);
    T.ExpectedBool(TRUE, ok, "Expected prepend to empty list to succeed", test);
    T.ExpectedInt(1, PathLists.Length(pl), "Expected length 1 after first prepend", test);
    
    pos := PathLists.Find("/first", pl);
    T.ExpectedInt(0, pos, "Expected /first to be at position 0", test);
    
    (* Test prepend to non-empty list *)
    PathLists.Prepend("/second", pl, ok);
    T.ExpectedBool(TRUE, ok, "Expected second prepend to succeed", test);
    T.ExpectedInt(2, PathLists.Length(pl), "Expected length 2 after second prepend", test);
    
    pos := PathLists.Find("/second", pl);
    T.ExpectedInt(0, pos, "Expected /second to be at position 0 after prepend", test);
    
    pos := PathLists.Find("/first", pl);
    T.ExpectedInt(1, pos, "Expected /first to be at position 1 after prepend", test);
    
    PathLists.Free(pl);
    RETURN test
END TestPrepend;

PROCEDURE TestAppend() : BOOLEAN;
    VAR test, ok : BOOLEAN;
        pl : PathLists.PathList;
        pos : INTEGER;
BEGIN test := TRUE;
    pl := PathLists.New();
    
    (* Test append to empty list *)
    PathLists.Append("/first", pl, ok);
    T.ExpectedBool(TRUE, ok, "Expected append to empty list to succeed", test);
    T.ExpectedInt(1, PathLists.Length(pl), "Expected length 1 after first append", test);
    
    pos := PathLists.Find("/first", pl);
    T.ExpectedInt(0, pos, "Expected /first to be at position 0", test);
    
    (* Test append to non-empty list *)
    PathLists.Append("/second", pl, ok);
    T.ExpectedBool(TRUE, ok, "Expected second append to succeed", test);
    T.ExpectedInt(2, PathLists.Length(pl), "Expected length 2 after second append", test);
    
    pos := PathLists.Find("/first", pl);
    T.ExpectedInt(0, pos, "Expected /first to stay at position 0", test);
    
    pos := PathLists.Find("/second", pl);
    T.ExpectedInt(1, pos, "Expected /second to be at position 1 after append", test);
    
    PathLists.Free(pl);
    RETURN test
END TestAppend;

PROCEDURE TestCut() : BOOLEAN;
    VAR test, ok : BOOLEAN;
        pl : PathLists.PathList;
        pos : INTEGER;
BEGIN test := TRUE; 
    pl := PathLists.New();
    
    (* Test cut from empty list *)
    PathLists.Cut("/nonexistent", pl, ok);
    T.ExpectedBool(FALSE, ok, "Expected cut from empty list to fail", test);
    
    (* Add some paths *)
    PathLists.Append("/first", pl, ok);
    PathLists.Append("/second", pl, ok);
    PathLists.Append("/third", pl, ok);
    T.ExpectedInt(3, PathLists.Length(pl), "Expected length 3 after adding paths", test);
    
    (* Test cut middle element *)
    PathLists.Cut("/second", pl, ok);
    T.ExpectedBool(TRUE, ok, "Expected cut of existing path to succeed", test);
    T.ExpectedInt(2, PathLists.Length(pl), "Expected length 2 after cut", test);
    
    pos := PathLists.Find("/second", pl);
    T.ExpectedInt(-1, pos, "Expected /second to be removed", test);
    
    pos := PathLists.Find("/first", pl);
    T.ExpectedInt(0, pos, "Expected /first to remain at position 0", test);
    
    pos := PathLists.Find("/third", pl);
    T.ExpectedInt(1, pos, "Expected /third to move to position 1", test);
    
    (* Test cut non-existent path *)
    PathLists.Cut("/nonexistent", pl, ok);
    T.ExpectedBool(FALSE, ok, "Expected cut of non-existent path to fail", test);
    T.ExpectedInt(2, PathLists.Length(pl), "Expected length to remain 2", test);
    
    PathLists.Free(pl);
    RETURN test
END TestCut;

PROCEDURE TestApply() : BOOLEAN;
    VAR test, ok : BOOLEAN;
        pathListString : ARRAY 1024 OF CHAR;
BEGIN test := TRUE;
    pathListString := "/bin:/usr/bin";
    
    (* Test PREPEND operation *)
    ok := PathLists.Apply("/usr/local/bin", PathLists.PREPEND, pathListString);
    T.ExpectedBool(TRUE, ok, "Expected PREPEND apply to succeed", test);
    T.ExpectedString("/usr/local/bin:/bin:/usr/bin", pathListString, "Expected prepend result", test);
    
    (* Test APPEND operation *)
    pathListString := "/bin:/usr/bin";
    ok := PathLists.Apply("/usr/local/bin", PathLists.APPEND, pathListString);
    T.ExpectedBool(TRUE, ok, "Expected APPEND apply to succeed", test);
    T.ExpectedString("/bin:/usr/bin:/usr/local/bin", pathListString, "Expected append result", test);
    
    (* Test CUT operation *)
    pathListString := "/bin:/usr/bin:/usr/local/bin";
    ok := PathLists.Apply("/usr/bin", PathLists.CUT, pathListString);
    T.ExpectedBool(TRUE, ok, "Expected CUT apply to succeed", test);
    T.ExpectedString("/bin:/usr/local/bin", pathListString, "Expected cut result", test);
    
    (* Test CUT of non-existent path *)
    pathListString := "/bin:/usr/bin";
    ok := PathLists.Apply("/nonexistent", PathLists.CUT, pathListString);
    T.ExpectedBool(FALSE, ok, "Expected CUT of non-existent path to fail", test);
    
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
