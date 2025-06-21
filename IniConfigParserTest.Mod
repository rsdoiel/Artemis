(** IniConfigParserTest.Mod - Tests for IniConfigParser.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)
MODULE IniConfigParserTest;

IMPORT IniConfigParser, Files, Strings, Tests, Chars, Dictionary;

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

(* Helper: Assert value and type for default section *)
PROCEDURE AssertDefaultValue(config: IniConfigParser.Config; key : ARRAY OF CHAR; expected: ARRAY OF CHAR; expectedType: INTEGER; VAR pass: BOOLEAN);
VAR value: IniConfigParser.ConfigValuePtr; found: BOOLEAN; msg, suffix: ARRAY 128 OF CHAR;
BEGIN
    found := IniConfigParser.GetDefaultValue(config, key, value);
    msg := "Found ";
    Strings.Append(key, msg);
    Tests.ExpectedBool(TRUE, found, msg, pass);
    IF found THEN
        msg := key;
        suffix := " value";
        Strings.Append(suffix, msg);
        Tests.ExpectedString(expected, value.value, msg, pass);
        msg := key;
        suffix := " type";
        Strings.Append(suffix, msg);
        Tests.ExpectedInt(expectedType, IniConfigParser.GetType(value), msg, pass)
    END
END AssertDefaultValue;

(* Helper: Assert value and type for sectioned value *)
PROCEDURE AssertSectionValue(config: IniConfigParser.Config; section, key, expected: ARRAY OF CHAR; expectedType: INTEGER; VAR pass: BOOLEAN);
VAR value: IniConfigParser.ConfigValuePtr; found: BOOLEAN; msg, suffix: ARRAY 128 OF CHAR;
BEGIN
    found := IniConfigParser.GetValue(config, section, key, value);
    msg := "Found "; Strings.Append(key, msg); suffix := " in "; Strings.Append(suffix, msg); Strings.Append(section, msg);
    Tests.ExpectedBool(TRUE, found, msg, pass);
    IF found THEN
        msg := key; suffix := " value in "; Strings.Append(suffix, msg); Strings.Append(section, msg);
        Tests.ExpectedString(expected, value.value, msg, pass);
        msg := key; suffix := " type in "; Strings.Append(suffix, msg); Strings.Append(section, msg);
        Tests.ExpectedInt(expectedType, IniConfigParser.GetType(value), msg, pass)
    END
END AssertSectionValue;

(* Helper: Populate a sample config for round-trip/save tests *)
PROCEDURE PopulateSampleConfig(VAR config: IniConfigParser.Config);
VAR success: BOOLEAN;
BEGIN
    config := IniConfigParser.NewConfig();
    success := IniConfigParser.SetDefaultValue(config, "app_name", "TestApp");
    success := IniConfigParser.SetDefaultValue(config, "version", "1.0");
    success := IniConfigParser.SetValue(config, "database", "host", "localhost");
    success := IniConfigParser.SetValue(config, "database", "port", "5432");
    success := IniConfigParser.SetValue(config, "database", "ssl", "TRUE");
    success := IniConfigParser.SetValue(config, "logging", "level", "DEBUG");
    success := IniConfigParser.SetValue(config, "logging", "max_size", "10.5")
END PopulateSampleConfig;

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
    content := "key1=value1#key2=123#key3=45.67#key4=TRUE";
    NewLines(content);
    CreateTestFile("test_basic.ini", content, file);
    res := IniConfigParser.LoadConfig("test_basic.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "LoadConfig result", pass);
    Tests.ExpectedInt(IniConfigParser.NoError, IniConfigParser.GetError(config), "Config error", pass);
    AssertDefaultValue(config, "key1", "value1", IniConfigParser.StringType, pass);
    AssertDefaultValue(config, "key2", "123", IniConfigParser.IntegerType, pass);
    AssertDefaultValue(config, "key3", "45.67", IniConfigParser.RealType, pass);
    AssertDefaultValue(config, "key4", "TRUE", IniConfigParser.BooleanType, pass);
    found := IniConfigParser.GetDefaultValue(config, "missing", value);
    Tests.ExpectedBool(FALSE, found, "Missing key not found", pass);
    IniConfigParser.FreeConfig(config);
    CleanupTestFile("test_basic.ini");
    RETURN pass
END TestBasicConfigLoading;

PROCEDURE TestSectionsFromFile*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    res: INTEGER;
    value: IniConfigParser.ConfigValuePtr;
    found: BOOLEAN;
    section: Dictionary.Dictionary;
BEGIN
    pass := TRUE;
    res := IniConfigParser.LoadConfig("test_data/sections.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "LoadConfig sections result", pass);
    AssertSectionValue(config, "database", "host", "localhost", IniConfigParser.StringType, pass);
    AssertSectionValue(config, "database", "port", "5432", IniConfigParser.IntegerType, pass);
    AssertSectionValue(config, "database", "ssl", "TRUE", IniConfigParser.BooleanType, pass);
    AssertSectionValue(config, "logging", "max_size", "10.5", IniConfigParser.RealType, pass);
    section := IniConfigParser.GetSection(config, "app");
    Tests.ExpectedBool(section # NIL, TRUE, "GetSection returns valid section", pass);
    section := IniConfigParser.GetSection(config, "nonexistent");
    Tests.ExpectedBool(section = NIL, TRUE, "GetSection returns NIL for nonexistent", pass);
    found := IniConfigParser.GetValue(config, "nonexistent", "key", value);
    Tests.ExpectedBool(FALSE, found, "No value from nonexistent section", pass);
    IniConfigParser.FreeConfig(config);
    RETURN pass
END TestSectionsFromFile;

PROCEDURE TestTypeDetectionFromFile*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    res: INTEGER;
BEGIN
    pass := TRUE;
    res := IniConfigParser.LoadConfig("test_data/types.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "LoadConfig types result", pass);
    AssertDefaultValue(config, "quoted_string", "This is a quoted string", IniConfigParser.StringType, pass);
    AssertDefaultValue(config, "single_quotes", "Single quoted value", IniConfigParser.StringType, pass);
    AssertDefaultValue(config, "negative_int", "-123", IniConfigParser.IntegerType, pass);
    AssertDefaultValue(config, "negative_real", "-2.718", IniConfigParser.RealType, pass);
    AssertDefaultValue(config, "boolean_false", "FALSE", IniConfigParser.BooleanType, pass);
    AssertDefaultValue(config, "number_with_plus", "+789", IniConfigParser.IntegerType, pass);
    AssertDefaultValue(config, "just_dot", ".", IniConfigParser.StringType, pass);
    AssertDefaultValue(config, "multiple_dots", "1.2.3", IniConfigParser.StringType, pass);
    AssertDefaultValue(config, "text_with_numbers", "abc123def", IniConfigParser.StringType, pass);
    AssertDefaultValue(config, "empty_value", "", IniConfigParser.StringType, pass);
    IniConfigParser.FreeConfig(config);
    RETURN pass
END TestTypeDetectionFromFile;

PROCEDURE TestCommentsAndWhitespace*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    res: INTEGER;
    value: IniConfigParser.ConfigValuePtr;
    found: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Load config with comments and whitespace from test_data *)
    res := IniConfigParser.LoadConfig("test_data/comments.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "LoadConfig comments result", pass);
    
    (* Test that keys are found despite comments and whitespace *)
    found := IniConfigParser.GetDefaultValue(config, "key1", value);
    Tests.ExpectedBool(TRUE, found, "Found key1 with comments", pass);
    IF found THEN
        Tests.ExpectedString("value1", value.value, "Key1 value with comments", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "key2", value);
    Tests.ExpectedBool(TRUE, found, "Found key2 with whitespace", pass);
    IF found THEN
        Tests.ExpectedString("value2", value.value, "Key2 value with whitespace", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "key3", value);
    Tests.ExpectedBool(TRUE, found, "Found key3 after empty lines", pass);
    IF found THEN
        Tests.ExpectedString("value3", value.value, "Key3 value after empty lines", pass)
    END;
    
    (* Test section values with comments *)
    found := IniConfigParser.GetValue(config, "section1", "key4", value);
    Tests.ExpectedBool(TRUE, found, "Found key4 in section1", pass);
    IF found THEN
        Tests.ExpectedString("value4", value.value, "Key4 value in section", pass)
    END;
    
    found := IniConfigParser.GetValue(config, "section2", "key5", value);
    Tests.ExpectedBool(TRUE, found, "Found key5 in section2", pass);
    IF found THEN
        Tests.ExpectedString("value5", value.value, "Key5 value in section2", pass)
    END;
    
    (* Cleanup *)
    IniConfigParser.FreeConfig(config);
    
    RETURN pass
END TestCommentsAndWhitespace;

PROCEDURE TestErrorHandling*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    res: INTEGER;
BEGIN
    pass := TRUE;
    
    (* Test file not found error *)
    res := IniConfigParser.LoadConfig("nonexistent_file.ini", config);
    Tests.ExpectedInt(IniConfigParser.FileNotFound, res, "File not found error", pass);
    Tests.ExpectedInt(IniConfigParser.FileNotFound, IniConfigParser.GetError(config), "Config file not found error", pass);
    IniConfigParser.FreeConfig(config);
    
    (* Test file with syntax errors *)
    res := IniConfigParser.LoadConfig("test_data/errors.ini", config);
    Tests.ExpectedInt(IniConfigParser.SyntaxError, res, "Syntax error detected", pass);
    Tests.ExpectedInt(IniConfigParser.SyntaxError, IniConfigParser.GetError(config), "Config syntax error", pass);
    Tests.ExpectedBool(IniConfigParser.GetErrorLine(config) > 0, TRUE, "Error line number set", pass);
    IniConfigParser.FreeConfig(config);
    
    RETURN pass
END TestErrorHandling;

PROCEDURE TestEmptyAndCommentsOnly*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    res: INTEGER;
    value: IniConfigParser.ConfigValuePtr;
    found: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Test empty file *)
    res := IniConfigParser.LoadConfig("test_data/empty.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "Empty file loads without error", pass);
    Tests.ExpectedInt(IniConfigParser.NoError, IniConfigParser.GetError(config), "Empty file no error", pass);
    
    (* Test that no values are found in empty file *)
    found := IniConfigParser.GetDefaultValue(config, "any_key", value);
    Tests.ExpectedBool(FALSE, found, "No values in empty file", pass);
    
    IniConfigParser.FreeConfig(config);
    
    (* Test file with only comments *)
    res := IniConfigParser.LoadConfig("test_data/comments_only.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "Comments only file loads without error", pass);
    Tests.ExpectedInt(IniConfigParser.NoError, IniConfigParser.GetError(config), "Comments only file no error", pass);
    
    (* Test that no values are found in comments only file *)
    found := IniConfigParser.GetDefaultValue(config, "any_key", value);
    Tests.ExpectedBool(FALSE, found, "No values in comments only file", pass);
    
    IniConfigParser.FreeConfig(config);
    
    RETURN pass
END TestEmptyAndCommentsOnly;

PROCEDURE TestConfigValueCreation*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    configValue: IniConfigParser.ConfigValuePtr;
BEGIN
    pass := TRUE;
    
    (* Test NewConfigValue function *)
    configValue := IniConfigParser.NewConfigValue("test_value", IniConfigParser.StringType, 42);
    Tests.ExpectedBool(configValue # NIL, TRUE, "ConfigValue created", pass);
    IF configValue # NIL THEN
        Tests.ExpectedString("test_value", configValue.value, "ConfigValue value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, configValue.valueType, "ConfigValue type", pass);
        Tests.ExpectedInt(42, configValue.lineNumber, "ConfigValue line number", pass)
    END;
    
    (* Test GetType with NIL pointer *)
    Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(NIL), "GetType with NIL", pass);
    
    RETURN pass
END TestConfigValueCreation;

PROCEDURE TestAPIEdgeCases*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    value: IniConfigParser.ConfigValuePtr;
    found: BOOLEAN;
    section: Dictionary.Dictionary;
BEGIN
    pass := TRUE;
    
    (* Test API functions with NIL config *)
    Tests.ExpectedInt(IniConfigParser.NoError, IniConfigParser.GetError(NIL), "GetError with NIL config", pass);
    Tests.ExpectedInt(0, IniConfigParser.GetErrorLine(NIL), "GetErrorLine with NIL config", pass);
    
    section := IniConfigParser.GetSection(NIL, "any_section");
    Tests.ExpectedBool(section = NIL, TRUE, "GetSection with NIL config", pass);
    
    found := IniConfigParser.GetValue(NIL, "section", "key", value);
    Tests.ExpectedBool(FALSE, found, "GetValue with NIL config", pass);
    
    found := IniConfigParser.GetDefaultValue(NIL, "key", value);
    Tests.ExpectedBool(FALSE, found, "GetDefaultValue with NIL config", pass);
    
    (* Test with valid config but empty sections *)
    config := IniConfigParser.NewConfig();
    Tests.ExpectedBool(config # NIL, TRUE, "NewConfig creates valid config", pass);
    
    (* Test getting nonexistent key from default section *)
    found := IniConfigParser.GetDefaultValue(config, "nonexistent", value);
    Tests.ExpectedBool(FALSE, found, "Nonexistent key not found", pass);
    
    (* Free config twice (should be safe) *)
    IniConfigParser.FreeConfig(config);
    IniConfigParser.FreeConfig(config); (* Should handle NIL gracefully *)
    
    RETURN pass
END TestAPIEdgeCases;

PROCEDURE TestCaseSensitivity*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    res: INTEGER;
    value: IniConfigParser.ConfigValuePtr;
    found: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Load config with case-sensitive sections and keys *)
    res := IniConfigParser.LoadConfig("test_data/case_sensitivity.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "LoadConfig case sensitivity result", pass);
    
    (* Test that section names are case-sensitive *)
    found := IniConfigParser.GetValue(config, "Test Section", "key1", value);
    Tests.ExpectedBool(TRUE, found, "Found key1 in 'Test Section'", pass);
    IF found THEN
        Tests.ExpectedString("value1", value.value, "Value from 'Test Section'", pass)
    END;
    
    found := IniConfigParser.GetValue(config, "test section", "key1", value);
    Tests.ExpectedBool(TRUE, found, "Found key1 in 'test section'", pass);
    IF found THEN
        Tests.ExpectedString("different_value", value.value, "Value from 'test section'", pass)
    END;
    
    (* Test DATABASE vs database sections *)
    found := IniConfigParser.GetValue(config, "DATABASE", "Host", value);
    Tests.ExpectedBool(TRUE, found, "Found Host in DATABASE", pass);
    IF found THEN
        Tests.ExpectedString("SERVER1", value.value, "Host value from DATABASE", pass)
    END;
    
    found := IniConfigParser.GetValue(config, "database", "host", value);
    Tests.ExpectedBool(TRUE, found, "Found host in database", pass);
    IF found THEN
        Tests.ExpectedString("server2", value.value, "host value from database", pass)
    END;
    
    (* Test sections with special characters *)
    found := IniConfigParser.GetValue(config, "section-with-dashes", "key-with-dashes", value);
    Tests.ExpectedBool(TRUE, found, "Found key with dashes", pass);
    IF found THEN
        Tests.ExpectedString("value", value.value, "Value with dashes", pass)
    END;
    
    found := IniConfigParser.GetValue(config, "section_with_underscores", "key_with_underscores", value);
    Tests.ExpectedBool(TRUE, found, "Found key with underscores", pass);
    IF found THEN
        Tests.ExpectedString("value", value.value, "Value with underscores", pass)
    END;
    
    found := IniConfigParser.GetValue(config, "section.with.dots", "key.with.dots", value);
    Tests.ExpectedBool(TRUE, found, "Found key with dots", pass);
    IF found THEN
        Tests.ExpectedString("value", value.value, "Value with dots", pass)
    END;
    
    (* Cleanup *)
    IniConfigParser.FreeConfig(config);
    
    RETURN pass
END TestCaseSensitivity;

PROCEDURE TestWhitespaceHandling*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    res: INTEGER;
    value: IniConfigParser.ConfigValuePtr;
    found: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Load config with whitespace handling from test_data *)
    res := IniConfigParser.LoadConfig("test_data/whitespace.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "LoadConfig whitespace result", pass);
    
    (* Test values with leading/trailing spaces (should be trimmed) *)
    found := IniConfigParser.GetDefaultValue(config, "leading_space_key", value);
    Tests.ExpectedBool(TRUE, found, "Found leading_space_key", pass);
    IF found THEN
        Tests.ExpectedString("value_with_leading_space", value.value, "Leading space key value trimmed", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "trailing_space_key", value);
    Tests.ExpectedBool(TRUE, found, "Found trailing_space_key", pass);
    IF found THEN
        Tests.ExpectedString("value_with_trailing_space", value.value, "Trailing space key value trimmed", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "both_spaces_key", value);
    Tests.ExpectedBool(TRUE, found, "Found both_spaces_key", pass);
    IF found THEN
        Tests.ExpectedString("value_with_both_spaces", value.value, "Both spaces key value trimmed", pass)
    END;
    
    (* Test values with internal spaces (should be preserved) *)
    found := IniConfigParser.GetDefaultValue(config, "key_with_internal_spaces", value);
    Tests.ExpectedBool(TRUE, found, "Found key_with_internal_spaces", pass);
    IF found THEN
        Tests.ExpectedString("value with internal spaces", value.value, "Internal spaces preserved", pass)
    END;
    
    (* Test quoted values preserve internal spaces *)
    found := IniConfigParser.GetDefaultValue(config, "quoted_with_spaces", value);
    Tests.ExpectedBool(TRUE, found, "Found quoted_with_spaces", pass);
    IF found THEN
        Tests.ExpectedString("  value with spaces  ", value.value, "Quoted spaces preserved", pass)
    END;
    
    (* Cleanup *)
    IniConfigParser.FreeConfig(config);
    
    RETURN pass
END TestWhitespaceHandling;

PROCEDURE TestSetValue*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    value: IniConfigParser.ConfigValuePtr;
    found, success: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Create new config *)
    config := IniConfigParser.NewConfig();
    Tests.ExpectedBool(config # NIL, TRUE, "NewConfig for SetValue tests", pass);
    
    (* Test SetDefaultValue *)
    success := IniConfigParser.SetDefaultValue(config, "test_key", "test_value");
    Tests.ExpectedBool(TRUE, success, "SetDefaultValue succeeds", pass);
    
    (* Verify value was set *)
    found := IniConfigParser.GetDefaultValue(config, "test_key", value);
    Tests.ExpectedBool(TRUE, found, "SetDefaultValue - value found", pass);
    IF found THEN
        Tests.ExpectedString("test_value", value.value, "SetDefaultValue - correct value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "SetDefaultValue - correct type", pass)
    END;
    
    (* Test SetValue with section *)
    success := IniConfigParser.SetValue(config, "test_section", "section_key", "section_value");
    Tests.ExpectedBool(TRUE, success, "SetValue succeeds", pass);
    
    (* Verify section value was set *)
    found := IniConfigParser.GetValue(config, "test_section", "section_key", value);
    Tests.ExpectedBool(TRUE, found, "SetValue - value found", pass);
    IF found THEN
        Tests.ExpectedString("section_value", value.value, "SetValue - correct value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "SetValue - correct type", pass)
    END;
    
    (* Test type detection with SetValue *)
    success := IniConfigParser.SetDefaultValue(config, "int_key", "42");
    Tests.ExpectedBool(TRUE, success, "SetValue integer succeeds", pass);
    found := IniConfigParser.GetDefaultValue(config, "int_key", value);
    IF found THEN
        Tests.ExpectedInt(IniConfigParser.IntegerType, IniConfigParser.GetType(value), "SetValue - integer type detected", pass)
    END;
    
    success := IniConfigParser.SetDefaultValue(config, "real_key", "3.14");
    Tests.ExpectedBool(TRUE, success, "SetValue real succeeds", pass);
    found := IniConfigParser.GetDefaultValue(config, "real_key", value);
    IF found THEN
        Tests.ExpectedInt(IniConfigParser.RealType, IniConfigParser.GetType(value), "SetValue - real type detected", pass)
    END;
    
    success := IniConfigParser.SetDefaultValue(config, "bool_key", "TRUE");
    Tests.ExpectedBool(TRUE, success, "SetValue boolean succeeds", pass);
    found := IniConfigParser.GetDefaultValue(config, "bool_key", value);
    IF found THEN
        Tests.ExpectedInt(IniConfigParser.BooleanType, IniConfigParser.GetType(value), "SetValue - boolean type detected", pass)
    END;
    
    (* Test SetValue with NIL config *)
    success := IniConfigParser.SetDefaultValue(NIL, "key", "value");
    Tests.ExpectedBool(FALSE, success, "SetValue with NIL config fails", pass);
    
    (* Cleanup *)
    IniConfigParser.FreeConfig(config);
    
    RETURN pass
END TestSetValue;

PROCEDURE TestSaveConfig*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    result: INTEGER;
BEGIN
    pass := TRUE;
    PopulateSampleConfig(config);
    result := IniConfigParser.SaveConfig(config, "test_save_output.ini");
    Tests.ExpectedInt(IniConfigParser.NoError, result, "SaveConfig succeeds", pass);
    result := IniConfigParser.SaveConfig(NIL, "test_nil.ini");
    Tests.ExpectedInt(IniConfigParser.SyntaxError, result, "SaveConfig with NIL config fails", pass);
    IniConfigParser.FreeConfig(config);
    CleanupTestFile("test_save_output.ini");
    RETURN pass
END TestSaveConfig;

PROCEDURE TestRoundTrip*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config1, config2: IniConfigParser.Config;
    value: IniConfigParser.ConfigValuePtr;
    result: INTEGER;
    found: BOOLEAN;
BEGIN
    pass := TRUE;
    PopulateSampleConfig(config1);
    result := IniConfigParser.SaveConfig(config1, "test_roundtrip.ini");
    Tests.ExpectedInt(IniConfigParser.NoError, result, "Round-trip save succeeds", pass);
    result := IniConfigParser.LoadConfig("test_roundtrip.ini", config2);
    Tests.ExpectedInt(IniConfigParser.NoError, result, "Round-trip load succeeds", pass);
    IF result = IniConfigParser.NoError THEN
        AssertDefaultValue(config2, "app_name", "TestApp", IniConfigParser.StringType, pass);
        AssertDefaultValue(config2, "version", "1.0", IniConfigParser.RealType, pass);
        AssertSectionValue(config2, "database", "host", "localhost", IniConfigParser.StringType, pass);
        found := IniConfigParser.GetValue(config2, "database", "port", value);
        Tests.ExpectedBool(TRUE, found, "Round-trip: database port found", pass);
        IF found THEN
            Tests.ExpectedString("5432", value.value, "Round-trip: database port value", pass);
            Tests.ExpectedInt(IniConfigParser.IntegerType, IniConfigParser.GetType(value), "Round-trip: port type preserved", pass)
        END;
        found := IniConfigParser.GetValue(config2, "database", "ssl", value);
        Tests.ExpectedBool(TRUE, found, "Round-trip: database ssl found", pass);
        IF found THEN
            Tests.ExpectedString("TRUE", value.value, "Round-trip: database ssl value", pass);
            Tests.ExpectedInt(IniConfigParser.BooleanType, IniConfigParser.GetType(value), "Round-trip: ssl type preserved", pass)
        END;
        AssertSectionValue(config2, "logging", "level", "DEBUG", IniConfigParser.StringType, pass);
        found := IniConfigParser.GetValue(config2, "logging", "max_size", value);
        Tests.ExpectedBool(TRUE, found, "Round-trip: logging max_size found", pass);
        IF found THEN
            Tests.ExpectedString("10.5", value.value, "Round-trip: logging max_size value", pass);
            Tests.ExpectedInt(IniConfigParser.RealType, IniConfigParser.GetType(value), "Round-trip: max_size type preserved", pass)
        END
    END;
    IniConfigParser.FreeConfig(config1);
    IniConfigParser.FreeConfig(config2);
    CleanupTestFile("test_roundtrip.ini");
    RETURN pass
END TestRoundTrip;


BEGIN
    Tests.Init(ts, "IniConfigParser Tests");

    Tests.Add(ts, TestBasicConfigLoading);
    Tests.Add(ts, TestSectionsFromFile);
    Tests.Add(ts, TestTypeDetectionFromFile);
    Tests.Add(ts, TestCommentsAndWhitespace);
    Tests.Add(ts, TestErrorHandling);
    Tests.Add(ts, TestEmptyAndCommentsOnly);
    Tests.Add(ts, TestConfigValueCreation);
    Tests.Add(ts, TestAPIEdgeCases);
    Tests.Add(ts, TestCaseSensitivity);
    Tests.Add(ts, TestWhitespaceHandling);
    Tests.Add(ts, TestSetValue);
    Tests.Add(ts, TestSaveConfig);
    Tests.Add(ts, TestRoundTrip);
    
    ASSERT(Tests.Run(ts));
END IniConfigParserTest.
