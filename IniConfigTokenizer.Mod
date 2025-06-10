(** IniConfigTokenizer.Mod - Line-based tokenizer for INI configuration files.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE IniConfigTokenizer;

IMPORT Files, Chars;

CONST
    (* Token types *)
    EofToken* = 0;
    SectionToken* = 1;
    KeyToken* = 2;
    ValueToken* = 3;
    CommentToken* = 4;
    ErrorToken* = 5;

    (* Error codes *)
    NoError* = 0;
    SyntaxError* = 1;
    IOError* = 2;

    (* Maximum token length *)
    MaxTokenLength* = 256;

TYPE
    Token* = RECORD
        type*: INTEGER;
        value*: ARRAY MaxTokenLength OF CHAR;
        line*: INTEGER;
        error*: INTEGER
    END;

    Tokenizer* = POINTER TO TokenizerDesc;
    TokenizerDesc = RECORD
        reader: Files.Rider;
        currentLine: INTEGER;
        currentChar: CHAR;
        atEof: BOOLEAN;
        error: INTEGER
    END;

(* Internal: Read next character from file *)
PROCEDURE ReadChar(tokenizer: Tokenizer);
VAR ch: BYTE;
BEGIN
    IF ~tokenizer.atEof THEN
        Files.Read(tokenizer.reader, ch);
        tokenizer.currentChar := CHR(ch);
        IF tokenizer.reader.eof THEN
            tokenizer.atEof := TRUE;
            tokenizer.currentChar := 0X
        ELSIF tokenizer.currentChar = Chars.LF THEN
            INC(tokenizer.currentLine)
        END
    END
END ReadChar;

(** Initialize tokenizer for reading from a file *)
PROCEDURE Init*(VAR tokenizer: Tokenizer; file: Files.File);
VAR result: Tokenizer;
BEGIN
    NEW(result);
    Files.Set(result.reader, file, 0);
    result.currentLine := 1;
    result.atEof := FALSE;
    result.error := NoError;
    ReadChar(result);
    tokenizer := result
END Init;

(* Internal: Skip whitespace characters except newlines *)
PROCEDURE SkipWhitespace(tokenizer: Tokenizer);
BEGIN
    WHILE ~tokenizer.atEof & Chars.IsSpace(tokenizer.currentChar) & 
          (tokenizer.currentChar # Chars.CR) & (tokenizer.currentChar # Chars.LF) DO
        ReadChar(tokenizer)
    END
END SkipWhitespace;

(* Internal: Skip to end of line *)
PROCEDURE SkipToEOL(tokenizer: Tokenizer);
BEGIN
    WHILE ~tokenizer.atEof & (tokenizer.currentChar # Chars.CR) & 
          (tokenizer.currentChar # Chars.LF) DO
        ReadChar(tokenizer)
    END;
    (* Skip the line ending *)
    IF tokenizer.currentChar = Chars.CR THEN
        ReadChar(tokenizer);
        IF tokenizer.currentChar = Chars.LF THEN
            ReadChar(tokenizer)
        END
    ELSIF tokenizer.currentChar = Chars.LF THEN
        ReadChar(tokenizer)
    END
END SkipToEOL;

(* Internal: Read an identifier (key or value) *)
PROCEDURE ReadIdentifier(tokenizer: Tokenizer; VAR value: ARRAY OF CHAR);
VAR pos: INTEGER;
BEGIN
    pos := 0;
    WHILE ~tokenizer.atEof & (tokenizer.currentChar # "=") & 
          (tokenizer.currentChar # Chars.CR) & (tokenizer.currentChar # Chars.LF) &
          (pos < LEN(value) - 1) DO
        value[pos] := tokenizer.currentChar;
        INC(pos);
        ReadChar(tokenizer)
    END;
    value[pos] := 0X;
    
    (* Trim trailing whitespace *)
    WHILE (pos > 0) & Chars.IsSpace(value[pos - 1]) DO
        DEC(pos);
        value[pos] := 0X
    END
END ReadIdentifier;

(* Internal: Read a value (after = sign) - stops at semicolon comments *)
PROCEDURE ReadValueIdentifier(tokenizer: Tokenizer; VAR value: ARRAY OF CHAR);
VAR pos: INTEGER;
BEGIN
    pos := 0;
    WHILE ~tokenizer.atEof & (tokenizer.currentChar # ";") & 
          (tokenizer.currentChar # Chars.CR) & (tokenizer.currentChar # Chars.LF) &
          (pos < LEN(value) - 1) DO
        value[pos] := tokenizer.currentChar;
        INC(pos);
        ReadChar(tokenizer)
    END;
    value[pos] := 0X;
    
    (* Trim trailing whitespace *)
    WHILE (pos > 0) & Chars.IsSpace(value[pos - 1]) DO
        DEC(pos);
        value[pos] := 0X
    END
END ReadValueIdentifier;

(* Internal: Read a quoted string value *)
PROCEDURE ReadQuotedString(tokenizer: Tokenizer; VAR value: ARRAY OF CHAR);
VAR pos: INTEGER; quote: CHAR;
BEGIN
    quote := tokenizer.currentChar;
    ReadChar(tokenizer); (* Skip opening quote *)
    pos := 0;
    
    WHILE ~tokenizer.atEof & (tokenizer.currentChar # quote) & 
          (tokenizer.currentChar # Chars.CR) & (tokenizer.currentChar # Chars.LF) &
          (pos < LEN(value) - 1) DO
        value[pos] := tokenizer.currentChar;
        INC(pos);
        ReadChar(tokenizer)
    END;
    
    IF tokenizer.currentChar = quote THEN
        ReadChar(tokenizer) (* Skip closing quote *)
    END;
    
    value[pos] := 0X
END ReadQuotedString;

(* Internal: Read a section name *)
PROCEDURE ReadSection(tokenizer: Tokenizer; VAR value: ARRAY OF CHAR);
VAR pos, start: INTEGER;
BEGIN
    ReadChar(tokenizer); (* Skip opening [ *)
    pos := 0;
    
    WHILE ~tokenizer.atEof & (tokenizer.currentChar # "]") & 
          (tokenizer.currentChar # Chars.CR) & (tokenizer.currentChar # Chars.LF) &
          (pos < LEN(value) - 1) DO
        value[pos] := tokenizer.currentChar;
        INC(pos);
        ReadChar(tokenizer)
    END;
    
    IF tokenizer.currentChar = "]" THEN
        ReadChar(tokenizer) (* Skip closing ] *)
    END;
    
    value[pos] := 0X;
    
    (* Trim trailing whitespace *)
    WHILE (pos > 0) & Chars.IsSpace(value[pos - 1]) DO
        DEC(pos);
        value[pos] := 0X
    END;
    
    (* Trim leading whitespace *)
    start := 0;
    WHILE (start < pos) & Chars.IsSpace(value[start]) DO
        INC(start)
    END;
    
    (* Shift string if needed *)
    IF start > 0 THEN
        pos := 0;
        WHILE (start + pos < LEN(value)) & (value[start + pos] # 0X) DO
            value[pos] := value[start + pos];
            INC(pos)
        END;
        value[pos] := 0X
    END
END ReadSection;

(* Internal: Read a value (after = sign) *)
PROCEDURE ReadValue(tokenizer: Tokenizer; VAR value: ARRAY OF CHAR);
BEGIN
    SkipWhitespace(tokenizer);
    
    IF (tokenizer.currentChar = Chars.QUOT) OR (tokenizer.currentChar = Chars.APOS) THEN
        ReadQuotedString(tokenizer, value)
    ELSE
        ReadValueIdentifier(tokenizer, value)
    END
END ReadValue;

(** Get the next token from the input *)
PROCEDURE NextToken*(tokenizer: Tokenizer; VAR token: Token);
VAR done: BOOLEAN;
BEGIN
    token.error := NoError;
    token.line := tokenizer.currentLine;
    token.value[0] := 0X;
    done := FALSE;
    
    IF tokenizer.atEof THEN
        token.type := EofToken;
        done := TRUE
    END;
    
    IF ~done THEN
        SkipWhitespace(tokenizer);
        
        (* Skip empty lines *)
        WHILE ~tokenizer.atEof & ((tokenizer.currentChar = Chars.CR) OR (tokenizer.currentChar = Chars.LF)) DO
            SkipToEOL(tokenizer);
            SkipWhitespace(tokenizer);
            token.line := tokenizer.currentLine
        END;
        
        IF tokenizer.atEof THEN
            token.type := EofToken;
            done := TRUE
        END
    END;
    
    IF ~done THEN
        (* Check for comment *)
        IF tokenizer.currentChar = ";" THEN
            token.type := CommentToken;
            SkipToEOL(tokenizer);
            done := TRUE
        END
    END;
    
    IF ~done THEN
        (* Check for section *)
        IF tokenizer.currentChar = "[" THEN
            token.type := SectionToken;
            ReadSection(tokenizer, token.value);
            SkipToEOL(tokenizer);
            done := TRUE
        END
    END;
    
    IF ~done THEN
        (* Read key *)
        ReadIdentifier(tokenizer, token.value);
        
        IF tokenizer.currentChar = "=" THEN
            token.type := KeyToken;
            ReadChar(tokenizer); (* Skip = *)
            done := TRUE
        END
    END;
    
    IF ~done THEN
        (* If we get here, it's a syntax error *)
        token.type := ErrorToken;
        token.error := SyntaxError;
        SkipToEOL(tokenizer)
    END
END NextToken;

(** Get the value token after a key token *)
PROCEDURE GetValue*(tokenizer: Tokenizer; VAR token: Token);
BEGIN
    token.error := NoError;
    token.line := tokenizer.currentLine;
    token.type := ValueToken;
    ReadValue(tokenizer, token.value);
    SkipToEOL(tokenizer)
END GetValue;

(** Check if tokenizer has reached end of file *)
PROCEDURE AtEof*(tokenizer: Tokenizer): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    result := tokenizer.atEof;
    RETURN result
END AtEof;

(** Get current line number *)
PROCEDURE GetLine*(tokenizer: Tokenizer): INTEGER;
VAR result: INTEGER;
BEGIN
    result := tokenizer.currentLine;
    RETURN result
END GetLine;

(** Get current error state *)
PROCEDURE GetError*(tokenizer: Tokenizer): INTEGER;
VAR result: INTEGER;
BEGIN
    result := tokenizer.error;
    RETURN result
END GetError;

END IniConfigTokenizer.
