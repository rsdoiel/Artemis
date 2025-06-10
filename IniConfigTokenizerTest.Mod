(** IniConfigTokenizerTest.Mod - Tests for IniConfigTokenizer.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)
MODULE IniConfigTokenizerTest;

IMPORT IniConfigTokenizer, Files, Tests, Chars;

VAR
    ts: Tests.TestSet;

(* Helper to create a test file with given content *)
PROCEDURE CreateTestFile(content: ARRAY OF CHAR; VAR file: Files.File);
VAR writer: Files.Rider; i: INTEGER;
BEGIN
    file := Files.New("test.ini");
    Files.Set(writer, file, 0);
    i := 0;
    WHILE (i < LEN(content)) & (content[i] # 0X) DO
        Files.Write(writer, ORD(content[i]));
        INC(i)
    END;
    Files.Set(writer, file, 0); (* Reset to beginning *)
    Files.Register(file)        (* Make file visible and close it *)
END CreateTestFile;

PROCEDURE TestBasicTokens*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    file: Files.File;
    res : INTEGER;
    content: ARRAY 256 OF CHAR;
BEGIN
    pass := TRUE;
    
    (* Test section token *)
    content := "[section1]";
    CreateTestFile(content, file);
    IniConfigTokenizer.Init(tokenizer, file);
    
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.SectionToken, token.type, "Section token type", pass);
    Tests.ExpectedString("section1", token.value, "Section token value", pass);
    Tests.ExpectedInt(1, token.line, "Section token line", pass);
    
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.EofToken, token.type, "EOF after section", pass);
    
    Files.Close(file);
    Files.Delete("test.ini", res);
    RETURN pass
END TestBasicTokens;

PROCEDURE TestKeyValuePairs*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    file: Files.File;
    res : INTEGER;
    content: ARRAY 256 OF CHAR;
BEGIN
    pass := TRUE;
    
    content := "key1=value1";
    CreateTestFile(content, file);
    IniConfigTokenizer.Init(tokenizer, file);
    
    (* Test key token *)
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.KeyToken, token.type, "Key token type", pass);
    Tests.ExpectedString("key1", token.value, "Key token value", pass);
    
    (* Test value token *)
    IniConfigTokenizer.GetValue(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.ValueToken, token.type, "Value token type", pass);
    Tests.ExpectedString("value1", token.value, "Value token value", pass);
    
    Files.Close(file);
    Files.Delete("test.ini", res);
    RETURN pass
END TestKeyValuePairs;

PROCEDURE TestQuotedValues*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    file: Files.File;
    res : INTEGER;
    content: ARRAY 256 OF CHAR;
BEGIN
    pass := TRUE;
    
    (* Test double-quoted value *)
    content := "key1='quoted value'";
    CreateTestFile(content, file);
    IniConfigTokenizer.Init(tokenizer, file);
    
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.KeyToken, token.type, "Key token type", pass);
    Tests.ExpectedString("key1", token.value, "Key token value", pass);
    
    IniConfigTokenizer.GetValue(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.ValueToken, token.type, "Value token type", pass);
    Tests.ExpectedString("quoted value", token.value, "Quoted value content", pass);
    
    Files.Close(file);
    Files.Delete("test.ini", res);
    RETURN pass
END TestQuotedValues;

PROCEDURE TestComments*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    file: Files.File;
    res : INTEGER;
    content: ARRAY 256 OF CHAR;
BEGIN
    pass := TRUE;
    
    content := "; This is a comment";
    CreateTestFile(content, file);
    IniConfigTokenizer.Init(tokenizer, file);
    
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.CommentToken, token.type, "Comment token type", pass);
    
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.EofToken, token.type, "EOF after comment", pass);
    
    Files.Close(file);
    Files.Delete("test.ini", res);
    RETURN pass
END TestComments;

PROCEDURE TestWhitespaceHandling*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    file: Files.File;
    res : INTEGER;
    content: ARRAY 256 OF CHAR;
BEGIN
    pass := TRUE;
    
    content := "  key1  =  value1  ";
    CreateTestFile(content, file);
    IniConfigTokenizer.Init(tokenizer, file);
    
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.KeyToken, token.type, "Key token type", pass);
    Tests.ExpectedString("key1", token.value, "Trimmed key value", pass);
    
    IniConfigTokenizer.GetValue(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.ValueToken, token.type, "Value token type", pass);
    Tests.ExpectedString("value1", token.value, "Trimmed value", pass);
    
    Files.Close(file);
    Files.Delete("test.ini", res);
    RETURN pass
END TestWhitespaceHandling;

PROCEDURE TestMultipleLines*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    file: Files.File;
    res : INTEGER;
    content: ARRAY 256 OF CHAR;
BEGIN
    pass := TRUE;
    
    (* Create multi-line content *)
    content := "[section1]";
    Chars.Append(Chars.LF, content);
    Chars.Append("key1=value1", content);
    Chars.Append(Chars.LF, content);
    Chars.Append("; comment", content);
    Chars.Append(Chars.LF, content);
    Chars.Append("key2=value2", content);
    
    CreateTestFile(content, file);
    IniConfigTokenizer.Init(tokenizer, file);
    
    (* Test section *)
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.SectionToken, token.type, "Section token", pass);
    Tests.ExpectedString("section1", token.value, "Section name", pass);
    Tests.ExpectedInt(1, token.line, "Section line number", pass);
    
    (* Test first key *)
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.KeyToken, token.type, "First key token", pass);
    Tests.ExpectedString("key1", token.value, "First key name", pass);
    Tests.ExpectedInt(2, token.line, "First key line number", pass);
    
    IniConfigTokenizer.GetValue(tokenizer, token);
    Tests.ExpectedString("value1", token.value, "First value", pass);
    
    (* Test comment *)
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.CommentToken, token.type, "Comment token", pass);
    Tests.ExpectedInt(3, token.line, "Comment line number", pass);
    
    (* Test second key *)
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.KeyToken, token.type, "Second key token", pass);
    Tests.ExpectedString("key2", token.value, "Second key name", pass);
    Tests.ExpectedInt(4, token.line, "Second key line number", pass);
    
    IniConfigTokenizer.GetValue(tokenizer, token);
    Tests.ExpectedString("value2", token.value, "Second value", pass);
    
    (* Test EOF *)
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.EofToken, token.type, "EOF token", pass);
    
    Files.Close(file);
    Files.Delete("test.ini", res);
    RETURN pass
END TestMultipleLines;

PROCEDURE TestEmptyLines*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    file: Files.File;
    res : INTEGER;
    content: ARRAY 256 OF CHAR;
BEGIN
    pass := TRUE;
    
    content := "[section]";
    Chars.Append(Chars.LF, content);
    Chars.Append(Chars.LF, content); (* Empty line *)
    Chars.Append("key=value", content);
    
    CreateTestFile(content, file);
    IniConfigTokenizer.Init(tokenizer, file);
    
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.SectionToken, token.type, "Section after empty line", pass);
    
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.KeyToken, token.type, "Key after empty line", pass);
    Tests.ExpectedInt(3, token.line, "Correct line number after empty line", pass);
    
    Files.Close(file);
    Files.Delete("test.ini", res);
    RETURN pass
END TestEmptyLines;

PROCEDURE TestSyntaxError*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    file: Files.File;
    res : INTEGER;
    content: ARRAY 256 OF CHAR;
BEGIN
    pass := TRUE;
    
    content := "invalid_line_without_equals";
    CreateTestFile(content, file);
    IniConfigTokenizer.Init(tokenizer, file);
    
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.ErrorToken, token.type, "Error token for invalid syntax", pass);
    Tests.ExpectedInt(IniConfigTokenizer.SyntaxError, token.error, "Syntax error code", pass);
    
    Files.Close(file);
    Files.Delete("test.ini", res);
    RETURN pass
END TestSyntaxError;

PROCEDURE TestUtilityFunctions*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    tokenizer: IniConfigTokenizer.Tokenizer;
    file: Files.File;
    res : INTEGER;
    content: ARRAY 256 OF CHAR;
BEGIN
    pass := TRUE;
    
    content := "key=value";
    CreateTestFile(content, file);
    IniConfigTokenizer.Init(tokenizer, file);
    
    Tests.ExpectedBool(FALSE, IniConfigTokenizer.AtEof(tokenizer), "Not at EOF initially", pass);
    Tests.ExpectedInt(1, IniConfigTokenizer.GetLine(tokenizer), "Initial line number", pass);
    Tests.ExpectedInt(IniConfigTokenizer.NoError, IniConfigTokenizer.GetError(tokenizer), "No error initially", pass);
    
    Files.Close(file);
    Files.Delete("test.ini", res);
    RETURN pass
END TestUtilityFunctions;

PROCEDURE TestSpecialCharacters*(): BOOLEAN;
VAR
    pass: BOOLEAN;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    file: Files.File;
    res : INTEGER;
    content: ARRAY 256 OF CHAR;
BEGIN
    pass := TRUE;
    
    (* Test section with spaces and special characters *)
    content := "[section with spaces]";
    CreateTestFile(content, file);
    IniConfigTokenizer.Init(tokenizer, file);
    
    IniConfigTokenizer.NextToken(tokenizer, token);
    Tests.ExpectedInt(IniConfigTokenizer.SectionToken, token.type, "Section with spaces type", pass);
    Tests.ExpectedString("section with spaces", token.value, "Section with spaces value", pass);
    
    Files.Close(file);
    Files.Delete("test.ini", res);
    RETURN pass
END TestSpecialCharacters;

BEGIN
    Tests.Init(ts, "Test IniConfigTokenizer");
    Tests.Add(ts, TestBasicTokens);
    Tests.Add(ts, TestKeyValuePairs);
    Tests.Add(ts, TestQuotedValues);
    Tests.Add(ts, TestComments);
    Tests.Add(ts, TestWhitespaceHandling);
    Tests.Add(ts, TestMultipleLines);
    Tests.Add(ts, TestEmptyLines);
    Tests.Add(ts, TestSyntaxError);
    Tests.Add(ts, TestUtilityFunctions);
    Tests.Add(ts, TestSpecialCharacters);
    ASSERT(Tests.Run(ts))
END IniConfigTokenizerTest.
