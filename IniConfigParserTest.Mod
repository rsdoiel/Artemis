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
    
    (* Load config with sections from test_data *)
    res := IniConfigParser.LoadConfig("test_data/sections.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "LoadConfig sections result", pass);
    
    (* Test database section *)
    found := IniConfigParser.GetValue(config, "database", "host", value);
    Tests.ExpectedBool(TRUE, found, "Found database host", pass);
    IF found THEN
        Tests.ExpectedString("localhost", value.value, "Database host value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Database host type", pass)
    END;
    
    found := IniConfigParser.GetValue(config, "database", "port", value);
    Tests.ExpectedBool(TRUE, found, "Found database port", pass);
    IF found THEN
        Tests.ExpectedString("5432", value.value, "Database port value", pass);
        Tests.ExpectedInt(IniConfigParser.IntegerType, IniConfigParser.GetType(value), "Database port type", pass)
    END;
    
    found := IniConfigParser.GetValue(config, "database", "ssl", value);
    Tests.ExpectedBool(TRUE, found, "Found database ssl", pass);
    IF found THEN
        Tests.ExpectedString("TRUE", value.value, "Database ssl value", pass);
        Tests.ExpectedInt(IniConfigParser.BooleanType, IniConfigParser.GetType(value), "Database ssl type", pass)
    END;
    
    (* Test logging section *)
    found := IniConfigParser.GetValue(config, "logging", "max_size", value);
    Tests.ExpectedBool(TRUE, found, "Found logging max_size", pass);
    IF found THEN
        Tests.ExpectedString("10.5", value.value, "Logging max_size value", pass);
        Tests.ExpectedInt(IniConfigParser.RealType, IniConfigParser.GetType(value), "Logging max_size type", pass)
    END;
    
    (* Test GetSection function *)
    section := IniConfigParser.GetSection(config, "app");
    Tests.ExpectedBool(section # NIL, TRUE, "GetSection returns valid section", pass);
    
    (* Test nonexistent section *)
    section := IniConfigParser.GetSection(config, "nonexistent");
    Tests.ExpectedBool(section = NIL, TRUE, "GetSection returns NIL for nonexistent", pass);
    
    (* Test value from nonexistent section *)
    found := IniConfigParser.GetValue(config, "nonexistent", "key", value);
    Tests.ExpectedBool(FALSE, found, "No value from nonexistent section", pass);
    
    (* Cleanup *)
    IniConfigParser.FreeConfig(config);
    
    RETURN pass
END TestSectionsFromFile;

PROCEDURE TestTypeDetectionFromFile*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    config: IniConfigParser.Config;
    res: INTEGER;
    value: IniConfigParser.ConfigValuePtr;
    found: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Load config with various types from test_data *)
    res := IniConfigParser.LoadConfig("test_data/types.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "LoadConfig types result", pass);
    
    (* Test quoted strings *)
    found := IniConfigParser.GetDefaultValue(config, "quoted_string", value);
    Tests.ExpectedBool(TRUE, found, "Found quoted_string", pass);
    IF found THEN
        Tests.ExpectedString("This is a quoted string", value.value, "Quoted string value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Quoted string type", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "single_quotes", value);
    Tests.ExpectedBool(TRUE, found, "Found single_quotes", pass);
    IF found THEN
        Tests.ExpectedString("Single quoted value", value.value, "Single quoted value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Single quoted type", pass)
    END;
    
    (* Test positive and negative numbers *)
    found := IniConfigParser.GetDefaultValue(config, "negative_int", value);
    Tests.ExpectedBool(TRUE, found, "Found negative_int", pass);
    IF found THEN
        Tests.ExpectedString("-123", value.value, "Negative int value", pass);
        Tests.ExpectedInt(IniConfigParser.IntegerType, IniConfigParser.GetType(value), "Negative int type", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "negative_real", value);
    Tests.ExpectedBool(TRUE, found, "Found negative_real", pass);
    IF found THEN
        Tests.ExpectedString("-2.718", value.value, "Negative real value", pass);
        Tests.ExpectedInt(IniConfigParser.RealType, IniConfigParser.GetType(value), "Negative real type", pass)
    END;
    
    (* Test boolean values *)
    found := IniConfigParser.GetDefaultValue(config, "boolean_false", value);
    Tests.ExpectedBool(TRUE, found, "Found boolean_false", pass);
    IF found THEN
        Tests.ExpectedString("FALSE", value.value, "Boolean false value", pass);
        Tests.ExpectedInt(IniConfigParser.BooleanType, IniConfigParser.GetType(value), "Boolean false type", pass)
    END;
    
    (* Test edge cases for type detection *)
    found := IniConfigParser.GetDefaultValue(config, "number_with_plus", value);
    Tests.ExpectedBool(TRUE, found, "Found number_with_plus", pass);
    IF found THEN
        Tests.ExpectedString("+789", value.value, "Plus number value", pass);
        Tests.ExpectedInt(IniConfigParser.IntegerType, IniConfigParser.GetType(value), "Plus number type", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "just_dot", value);
    Tests.ExpectedBool(TRUE, found, "Found just_dot", pass);
    IF found THEN
        Tests.ExpectedString(".", value.value, "Just dot value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Just dot type", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "multiple_dots", value);
    Tests.ExpectedBool(TRUE, found, "Found multiple_dots", pass);
    IF found THEN
        Tests.ExpectedString("1.2.3", value.value, "Multiple dots value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Multiple dots type", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "text_with_numbers", value);
    Tests.ExpectedBool(TRUE, found, "Found text_with_numbers", pass);
    IF found THEN
        Tests.ExpectedString("abc123def", value.value, "Text with numbers value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Text with numbers type", pass)
    END;
    
    (* Test empty value *)
    found := IniConfigParser.GetDefaultValue(config, "empty_value", value);
    Tests.ExpectedBool(TRUE, found, "Found empty_value", pass);
    IF found THEN
        Tests.ExpectedString("", value.value, "Empty value", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Empty value type", pass)
    END;
    
    (* Cleanup *)
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
    
    (* Load config with various whitespace scenarios *)
    res := IniConfigParser.LoadConfig("test_data/whitespace.ini", config);
    Tests.ExpectedInt(IniConfigParser.NoError, res, "LoadConfig whitespace result", pass);
    
    (* Test that whitespace around keys and values is trimmed *)
    found := IniConfigParser.GetDefaultValue(config, "leading_space_key", value);
    Tests.ExpectedBool(TRUE, found, "Found leading_space_key", pass);
    IF found THEN
        Tests.ExpectedString("value_with_spaces", value.value, "Leading space key value trimmed", pass)
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
        Tests.ExpectedString("  quoted value with leading/trailing spaces  ", value.value, "Quoted spaces preserved", pass)
    END;
    
    (* Test numeric values with spaces are trimmed and typed correctly *)
    found := IniConfigParser.GetDefaultValue(config, "number_with_spaces", value);
    Tests.ExpectedBool(TRUE, found, "Found number_with_spaces", pass);
    IF found THEN
        Tests.ExpectedString("123", value.value, "Number with spaces trimmed", pass);
        Tests.ExpectedInt(IniConfigParser.IntegerType, IniConfigParser.GetType(value), "Number with spaces typed as integer", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "real_with_spaces", value);
    Tests.ExpectedBool(TRUE, found, "Found real_with_spaces", pass);
    IF found THEN
        Tests.ExpectedString("45.67", value.value, "Real with spaces trimmed", pass);
        Tests.ExpectedInt(IniConfigParser.RealType, IniConfigParser.GetType(value), "Real with spaces typed as real", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "boolean_with_spaces", value);
    Tests.ExpectedBool(TRUE, found, "Found boolean_with_spaces", pass);
    IF found THEN
        Tests.ExpectedString("TRUE", value.value, "Boolean with spaces trimmed", pass);
        Tests.ExpectedInt(IniConfigParser.BooleanType, IniConfigParser.GetType(value), "Boolean with spaces typed as boolean", pass)
    END;
    
    (* Test edge cases with empty-ish values *)
    found := IniConfigParser.GetDefaultValue(config, "almost_empty", value);
    Tests.ExpectedBool(TRUE, found, "Found almost_empty", pass);
    IF found THEN
        Tests.ExpectedString("", value.value, "Almost empty value is empty string", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Almost empty typed as string", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "just_spaces", value);
    Tests.ExpectedBool(TRUE, found, "Found just_spaces", pass);
    IF found THEN
        Tests.ExpectedString("", value.value, "Just spaces value is empty string", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Just spaces typed as string", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "quoted_empty", value);
    Tests.ExpectedBool(TRUE, found, "Found quoted_empty", pass);
    IF found THEN
        Tests.ExpectedString("", value.value, "Quoted empty value is empty string", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Quoted empty typed as string", pass)
    END;
    
    found := IniConfigParser.GetDefaultValue(config, "quoted_spaces", value);
    Tests.ExpectedBool(TRUE, found, "Found quoted_spaces", pass);
    IF found THEN
        Tests.ExpectedString("     ", value.value, "Quoted spaces preserved", pass);
        Tests.ExpectedInt(IniConfigParser.StringType, IniConfigParser.GetType(value), "Quoted spaces typed as string", pass)
    END;
    
    (* Test section with spaces *)
    found := IniConfigParser.GetValue(config, "section_with_spaces", "key_in_spaced_section", value);
    Tests.ExpectedBool(TRUE, found, "Found key in spaced section", pass);
    IF found THEN
        Tests.ExpectedString("value_in_spaced_section", value.value, "Value in spaced section", pass)
    END;
    
    (* Cleanup *)
    IniConfigParser.FreeConfig(config);
    
    RETURN pass
END TestWhitespaceHandling;



BEGIN
    Tests.Init(ts, "IniConfigParser");

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
    
    ASSERT(Tests.Run(ts));
END IniConfigParserTest.
