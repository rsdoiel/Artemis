(** IniConfigParserTest.Mod - Tests for IniConfigParser.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)
MODULE IniConfigParserTest;

IMPORT IniConfigParser, Files, Strings, Tests, Chars, Dictionary, Out;

VAR
    ts: Tests.TestSet;

(* Helper to create a test file with given content *)
PROCEDURE CreateTestFile(filename, content: ARRAY OF CHAR; VAR file: Files.File);
VAR writer: Files.Rider; i: INTEGER;
BEGIN
    file := Files.New(filename);
    Files.Set(writer, file, 0);
    i := 0;
    WHILE (i < LEN(content)) & (content[i] # 0X) DO
        Files.Write(writer, ORD(content[i]));
        INC(i)
    END;
    Files.Register(file);        (* Make file visible and close it *)
    Files.Close(file)
END CreateTestFile;

(* Helper to clean up test file *)
PROCEDURE CleanupTestFile(filename: ARRAY OF CHAR);
VAR res: INTEGER;
BEGIN
    Files.Delete(filename, res)
END CleanupTestFile;

(* Replace # with Linefeed chars. *)
PROCEDURE NewLines(VAR s : ARRAY OF CHAR);
VAR pos : INTEGER;
BEGIN
    pos := 0;
    WHILE pos # -1 DO
        pos := Strings.Pos("#", s, pos);
        IF pos # -1 THEN
            s[pos] := Chars.LF
        END
    END
END NewLines;

PROCEDURE TestBasicConfigLoading*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    file: Files.File;
    res: INTEGER;
    content: ARRAY 512 OF CHAR;
    value: IniConfigParser.ConfigValuePtr;
    found: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Create a simple INI file - replace # with LF *)
    content := "key1=value1#key2=123#key3=45.67#key4=TRUE";
    NewLines(content);
    
    CreateTestFile("test_basic.ini", content, file);
    
    (* Load config *)
    res := IniConfigParser.LoadConfig("test_basic.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "LoadConfig result", pass);
    Tests.ExpectedInt(IniConfigParser.NoError, IniConfigParser.GetError(config), "Config error", pass);
    
    (* Test string value *)
    found := IniConfigParser.GetDefaultValue(config, "key1", value);
    Tests.ExpectedBool(TRUE, found, "Found key1", pass);
    IF found THEN
        Tests.ExpectedString("value1", value.value, "Key1 value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Key1 type", pass)
    END;
    
    (* Test integer value *)
    found := IniConfigParser.GetDefaultValue(config, "key2", value);
    Tests.ExpectedBool(TRUE, found, "Found key2", pass);
    IF found THEN
        Tests.ExpectedString("123", value.value, "Key2 value", pass);
        Tests.ExpectedInt(IniConfigParser.IntegerType, IniConfigParser.GetType(value), "Key2 type", pass)
    END;
    
    (* Test real value *)
    found := IniConfigParser.GetDefaultValue(config, "key3", value);
    Tests.ExpectedBool(TRUE, found, "Found key3", pass);
    IF found THEN
        Tests.ExpectedString("45.67", value.value, "Key3 value", pass);
        Tests.ExpectedInt(IniConfigParser.RealType, IniConfigParser.GetType(value), "Key3 type", pass)
    END;
    
    (* Test boolean value *)
    found := IniConfigParser.GetDefaultValue(config, "key4", value);
    Tests.ExpectedBool(TRUE, found, "Found key4", pass);
    IF found THEN
        Tests.ExpectedString("TRUE", value.value, "Key4 value", pass);
        Tests.ExpectedInt(IniConfigParser.BooleanType, IniConfigParser.GetType(value), "Key4 type", pass)
    END;
    
    (* Test missing key *)
    found := IniConfigParser.GetDefaultValue(config, "missing", value);
    Tests.ExpectedBool(FALSE, found, "Missing key not found", pass);
    
    (* Cleanup *)
    IniConfigParser.FreeConfig(config);
    CleanupTestFile("test_basic.ini");
    
    RETURN pass
END TestBasicConfigLoading;



BEGIN
    Tests.Init(ts, "IniConfigParser");

    Tests.Add(ts, TestBasicConfigLoading);
    
    ASSERT(Tests.Run(ts));
END IniConfigParserTest.
