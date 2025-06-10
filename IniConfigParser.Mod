(** IniConfigParser.Mod - Main parser for INI configuration files.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE IniConfigParser;

IMPORT IniConfigTokenizer, Files, ArrayList, Dictionary, Collections, Chars, CollectionWrappers;

CONST
    (* Error codes *)
    NoError* = 0;
    FileNotFound* = 1;
    SyntaxError* = 2;
    IOError* = 3;
    
    (* Value types *)
    StringType* = 0;
    IntegerType* = 1;
    RealType* = 2;
    BooleanType* = 3;
    
    (* Default section name *)
    DefaultSectionName = "";

TYPE
    (** Configuration value with type information *)
    ConfigValue* = RECORD(Collections.Item)
        value*: ARRAY 512 OF CHAR;
        valueType*: INTEGER;
        lineNumber*: INTEGER
    END;
    ConfigValuePtr* = POINTER TO ConfigValue;
    
    (** Section name holder *)
    SectionName = RECORD(Collections.Item)
        name: ARRAY 256 OF CHAR
    END;
    SectionNamePtr = POINTER TO SectionName;
    
    (** INI Configuration parser *)
    Config* = POINTER TO ConfigDesc;
    ConfigDesc = RECORD
        sections: ArrayList.ArrayList; (* ArrayList of Dictionary *)
        sectionNames: ArrayList.ArrayList; (* ArrayList of string section names *)
        error: INTEGER;
        errorLine: INTEGER
    END;
    
    (** Write visitor state for saving config to file *)
    WriteVisitorState = RECORD(Dictionary.DictVisitorState)
        writer: Files.Rider;
        sectionName: ARRAY 256 OF CHAR;
        success: BOOLEAN
    END;

(** Create a new ConfigValue *)
PROCEDURE NewConfigValue*(value: ARRAY OF CHAR; valueType, lineNumber: INTEGER): ConfigValuePtr;
VAR 
    configValue: ConfigValuePtr;
    i: INTEGER;
    result: ConfigValuePtr;
BEGIN
    NEW(configValue);
    
    (* Copy value string *)
    i := 0;
    WHILE (i < LEN(value) - 1) & (i < LEN(configValue.value) - 1) & (value[i] # 0X) DO
        configValue.value[i] := value[i];
        INC(i)
    END;
    configValue.value[i] := 0X;
    
    configValue.valueType := valueType;
    configValue.lineNumber := lineNumber;
    result := configValue;
    RETURN result
END NewConfigValue;

(** Create a new section name holder *)
PROCEDURE NewSectionName(name: ARRAY OF CHAR): Collections.ItemPtr;
VAR 
    sectionName: SectionNamePtr;
    i: INTEGER;
    result: Collections.ItemPtr;
BEGIN
    NEW(sectionName);
    
    (* Copy section name *)
    i := 0;
    WHILE (i < LEN(name) - 1) & (i < LEN(sectionName.name) - 1) & (name[i] # 0X) DO
        sectionName.name[i] := name[i];
        INC(i)
    END;
    sectionName.name[i] := 0X;
    
    result := sectionName;
    RETURN result
END NewSectionName;

(** Detect value type based on content *)
PROCEDURE DetectValueType(value: ARRAY OF CHAR): INTEGER;
VAR 
    i: INTEGER;
    hasDigit, hasDot: BOOLEAN;
    result: INTEGER;
BEGIN
    result := StringType; (* Default *)
    
    (* Check for boolean values first *)
    IF (value[0] = "T") & (value[1] = "R") & (value[2] = "U") & (value[3] = "E") & (value[4] = 0X) THEN
        result := BooleanType
    ELSIF (value[0] = "F") & (value[1] = "A") & (value[2] = "L") & (value[3] = "S") & (value[4] = "E") & (value[5] = 0X) THEN
        result := BooleanType
    ELSE
        (* Check for numeric values *)
        i := 0;
        hasDigit := FALSE;
        hasDot := FALSE;
        
        (* Skip leading whitespace *)
        WHILE (i < LEN(value)) & (value[i] # 0X) & Chars.IsSpace(value[i]) DO
            INC(i)
        END;
        
        (* Skip optional sign *)
        IF (i < LEN(value)) & (value[i] # 0X) & ((value[i] = "+") OR (value[i] = "-")) THEN
            INC(i)
        END;
        
        (* Check digits and decimal point *)
        WHILE (i < LEN(value)) & (value[i] # 0X) & ~Chars.IsSpace(value[i]) DO
            IF (value[i] >= "0") & (value[i] <= "9") THEN
                hasDigit := TRUE
            ELSIF value[i] = "." THEN
                IF hasDot THEN
                    (* Multiple dots - not a number *)
                    hasDigit := FALSE;
                    i := LEN(value) (* Exit loop *)
                ELSE
                    hasDot := TRUE
                END
            ELSE
                (* Invalid character for number *)
                hasDigit := FALSE;
                i := LEN(value) (* Exit loop *)
            END;
            INC(i)
        END;
        
        (* Skip trailing whitespace *)
        WHILE (i < LEN(value)) & (value[i] # 0X) & Chars.IsSpace(value[i]) DO
            INC(i)
        END;
        
        (* If we reached end and found digits, it's a number *)
        IF hasDigit & ((i >= LEN(value)) OR (value[i] = 0X)) THEN
            IF hasDot THEN
                result := RealType
            ELSE
                result := IntegerType
            END
        END
    END;
    
    RETURN result
END DetectValueType;

(** Find section index by name *)
PROCEDURE StringsEqual(a, b: ARRAY OF CHAR): BOOLEAN;
VAR i: INTEGER; equal: BOOLEAN;
BEGIN
    i := 0; equal := TRUE;
    WHILE (i < LEN(a)) & (i < LEN(b)) & (a[i] # 0X) & (b[i] # 0X) & equal DO
        IF a[i] # b[i] THEN equal := FALSE END;
        INC(i)
    END;
    IF equal & ((a[i] # 0X) OR (b[i] # 0X)) THEN equal := FALSE END;
    RETURN equal
END StringsEqual;

PROCEDURE FindSectionIndex(config: Config; sectionName: ARRAY OF CHAR): INTEGER;
VAR 
    i, count: INTEGER;
    nameItem: Collections.ItemPtr;
    sectionNamePtr: SectionNamePtr;
    result: INTEGER;
BEGIN
    result := -1;
    count := ArrayList.Count(config.sectionNames);
    i := 0;
    WHILE (i < count) & (result = -1) DO
        IF ArrayList.GetAt(config.sectionNames, i, nameItem) THEN
            sectionNamePtr := nameItem(SectionNamePtr);
            IF StringsEqual(sectionName, sectionNamePtr.name) THEN
                result := i
            END
        END;
        INC(i)
    END;
    RETURN result
END FindSectionIndex;

(** Get or create section dictionary *)
PROCEDURE GetOrCreateSection(config: Config; sectionName: ARRAY OF CHAR): Dictionary.Dictionary;
VAR 
    sectionIndex: INTEGER;
    section: Collections.ItemPtr;
    dict: Dictionary.Dictionary;
    nameItem: Collections.ItemPtr;
    success: BOOLEAN;
    result: Dictionary.Dictionary;
BEGIN
    sectionIndex := FindSectionIndex(config, sectionName);
    
    IF sectionIndex >= 0 THEN
        (* Section exists, get it *)
        success := ArrayList.GetAt(config.sections, sectionIndex, section);
        ASSERT(success);
        result := section(CollectionWrappers.DictionaryWrapperPtr).dict
    ELSE
        (* Create new section *)
        dict := Dictionary.NewStringDict();
        nameItem := NewSectionName(sectionName);
        
        success := ArrayList.Append(config.sections, CollectionWrappers.NewDictionaryWrapper(dict));
        ASSERT(success);
        success := ArrayList.Append(config.sectionNames, nameItem);
        ASSERT(success);
        
        result := dict
    END;
    
    RETURN result
END GetOrCreateSection;

(** Create a new configuration *)
PROCEDURE NewConfig*(): Config;
VAR 
    config: Config;
    defaultSection: Dictionary.Dictionary;
    defaultName: Collections.ItemPtr;
    success: BOOLEAN;
    result: Config;
BEGIN
    NEW(config);
    config.sections := ArrayList.New();
    config.sectionNames := ArrayList.New();
    config.error := NoError;
    config.errorLine := 0;
    
    (* Create default section *)
    defaultSection := Dictionary.NewStringDict();
    defaultName := NewSectionName(DefaultSectionName);
    
    success := ArrayList.Append(config.sections, CollectionWrappers.NewDictionaryWrapper(defaultSection));
    ASSERT(success);
    success := ArrayList.Append(config.sectionNames, defaultName);
    ASSERT(success);
    
    result := config;
    RETURN result
END NewConfig;

(** Free configuration and all its resources *)
PROCEDURE FreeConfig*(VAR config: Config);
VAR 
    i, count: INTEGER;
    section: Collections.ItemPtr;
    wrapper: CollectionWrappers.DictionaryWrapperPtr;
BEGIN
    IF config # NIL THEN
        (* Free all section dictionaries *)
        count := ArrayList.Count(config.sections);
        FOR i := 0 TO count - 1 DO
            IF ArrayList.GetAt(config.sections, i, section) THEN
                wrapper := section(CollectionWrappers.DictionaryWrapperPtr);
                Dictionary.Free(wrapper.dict)
            END
        END;
        
        (* Free ArrayLists *)
        ArrayList.Free(config.sections);
        ArrayList.Free(config.sectionNames);
        
        config := NIL
    END
END FreeConfig;

(** Load configuration from file *)
(* Internal: Handle section token, switch to new section *)
PROCEDURE HandleSectionToken(VAR currentSection: Dictionary.Dictionary;
                            VAR currentSectionName: ARRAY OF CHAR;
                            config: Config;
                            token: IniConfigTokenizer.Token);
BEGIN
    Chars.Copy(token.value, currentSectionName);
    currentSection := GetOrCreateSection(config, currentSectionName)
END HandleSectionToken;

(* Internal: Handle key token, store key-value pair *)
PROCEDURE HandleKeyToken(VAR currentSection: Dictionary.Dictionary;
                        VAR currentKey: ARRAY OF CHAR;
                        config: Config;
                        tokenizer: IniConfigTokenizer.Tokenizer;
                        VAR token: IniConfigTokenizer.Token;
                        VAR result: INTEGER);
VAR
    valueType: INTEGER;
    configValue: ConfigValuePtr;
BEGIN
    Chars.Copy(token.value, currentKey);
    IniConfigTokenizer.GetValue(tokenizer, token);
    IF token.type = IniConfigTokenizer.ValueToken THEN
        valueType := DetectValueType(token.value);
        configValue := NewConfigValue(token.value, valueType, token.line);
        Dictionary.PutString(currentSection, currentKey, configValue)
    ELSE
        result := SyntaxError;
        config.error := SyntaxError;
        config.errorLine := token.line
    END
END HandleKeyToken;

(* Internal: Handle error token, set error state *)
PROCEDURE HandleErrorToken(config: Config; token: IniConfigTokenizer.Token; VAR result: INTEGER);
BEGIN
    result := SyntaxError;
    config.error := SyntaxError;
    config.errorLine := token.line
END HandleErrorToken;

PROCEDURE LoadConfig*(filename: ARRAY OF CHAR; VAR config: Config): INTEGER;
VAR 
    file: Files.File;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    currentSection: Dictionary.Dictionary;
    currentSectionName: ARRAY 256 OF CHAR;
    currentKey: ARRAY 256 OF CHAR;
    result: INTEGER;
BEGIN
    result := NoError;
    config := NewConfig();
    file := Files.Old(filename);
    IF file = NIL THEN
        result := FileNotFound;
        config.error := FileNotFound
    ELSE
        IniConfigTokenizer.Init(tokenizer, file);
        currentSectionName[0] := 0X;
        currentSection := GetOrCreateSection(config, currentSectionName);
        WHILE (~IniConfigTokenizer.AtEof(tokenizer)) & (result = NoError) DO
            IniConfigTokenizer.NextToken(tokenizer, token);
            IF token.type = IniConfigTokenizer.SectionToken THEN
                HandleSectionToken(currentSection, currentSectionName, config, token)
            ELSIF token.type = IniConfigTokenizer.KeyToken THEN
                HandleKeyToken(currentSection, currentKey, config, tokenizer, token, result)
            ELSIF token.type = IniConfigTokenizer.CommentToken THEN
                (* Skip comments *)
            ELSIF token.type = IniConfigTokenizer.ErrorToken THEN
                HandleErrorToken(config, token, result)
            ELSIF token.type = IniConfigTokenizer.EofToken THEN
                (* End of file - normal exit *)
            (* Else: ignore unknown token types *)
            END
        END;
        Files.Close(file)
    END;
    RETURN result
END LoadConfig;

(** Get section by name *)
PROCEDURE GetSection*(config: Config; sectionName: ARRAY OF CHAR): Dictionary.Dictionary;
VAR 
    sectionIndex: INTEGER;
    section: Collections.ItemPtr;
    wrapper: CollectionWrappers.DictionaryWrapperPtr;
    success: BOOLEAN;
    result: Dictionary.Dictionary;
BEGIN
    result := NIL;
    
    IF config # NIL THEN
        sectionIndex := FindSectionIndex(config, sectionName);
        IF sectionIndex >= 0 THEN
            success := ArrayList.GetAt(config.sections, sectionIndex, section);
            IF success THEN
                wrapper := section(CollectionWrappers.DictionaryWrapperPtr);
                result := wrapper.dict
            END
        END
    END;
    
    RETURN result
END GetSection;

(** Get value from specific section *)
PROCEDURE GetValue*(config: Config; sectionName, key: ARRAY OF CHAR; VAR value: ConfigValuePtr): BOOLEAN;
VAR 
    section: Dictionary.Dictionary;
    item: Collections.ItemPtr;
    found: BOOLEAN;
    result: BOOLEAN;
BEGIN
    result := FALSE;
    value := NIL;
    
    IF config # NIL THEN
        section := GetSection(config, sectionName);
        IF section # NIL THEN
            found := Dictionary.GetString(section, key, item);
            IF found THEN
                value := item(ConfigValuePtr);
                result := TRUE
            END
        END
    END;
    
    RETURN result
END GetValue;

(** Get value from default section *)
PROCEDURE GetDefaultValue*(config: Config; key: ARRAY OF CHAR; VAR value: ConfigValuePtr): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    result := GetValue(config, DefaultSectionName, key, value);
    RETURN result
END GetDefaultValue;

(** Get value type for a ConfigValue *)
PROCEDURE GetType*(value: ConfigValuePtr): INTEGER;
VAR result: INTEGER;
BEGIN
    IF value # NIL THEN
        result := value.valueType
    ELSE
        result := StringType (* Default *)
    END;
    RETURN result
END GetType;

(** Get error information *)
PROCEDURE GetError*(config: Config): INTEGER;
VAR result: INTEGER;
BEGIN
    IF config # NIL THEN
        result := config.error
    ELSE
        result := NoError
    END;
    RETURN result
END GetError;

(** Get error line number *)
PROCEDURE GetErrorLine*(config: Config): INTEGER;
VAR result: INTEGER;
BEGIN
    IF config # NIL THEN
        result := config.errorLine
    ELSE
        result := 0
    END;
    RETURN result
END GetErrorLine;

(** Set value in specific section *)
PROCEDURE SetValue*(config: Config; sectionName, key, value: ARRAY OF CHAR): BOOLEAN;
VAR 
    section: Dictionary.Dictionary;
    configValue: ConfigValuePtr;
    valueType: INTEGER;
    result: BOOLEAN;
BEGIN
    result := FALSE;
    
    IF config # NIL THEN
        section := GetOrCreateSection(config, sectionName);
        IF section # NIL THEN
            valueType := DetectValueType(value);
            configValue := NewConfigValue(value, valueType, 0);
            Dictionary.PutString(section, key, configValue);
            result := TRUE
        END
    END;
    
    RETURN result
END SetValue;

(** Set value in default section *)
PROCEDURE SetDefaultValue*(config: Config; key, value: ARRAY OF CHAR): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    result := SetValue(config, DefaultSectionName, key, value);
    RETURN result
END SetDefaultValue;

(** Visitor procedure for writing key-value pairs to file *)
PROCEDURE WriteKeyValue(key: ARRAY OF CHAR; value: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
VAR 
    configValue: ConfigValuePtr;
    i: INTEGER;
BEGIN
    configValue := value(ConfigValuePtr);
    
    IF state(WriteVisitorState).success THEN
        (* Write key *)
        i := 0;
        WHILE (i < LEN(key)) & (key[i] # 0X) & state(WriteVisitorState).success DO
            Files.Write(state(WriteVisitorState).writer, ORD(key[i]));
            IF state(WriteVisitorState).writer.res # 0 THEN 
                state(WriteVisitorState).success := FALSE 
            END;
            INC(i)
        END;
        
        (* Write = *)
        IF state(WriteVisitorState).success THEN
            Files.Write(state(WriteVisitorState).writer, ORD("="));
            IF state(WriteVisitorState).writer.res # 0 THEN 
                state(WriteVisitorState).success := FALSE 
            END
        END;
        
        (* Write value *)
        IF state(WriteVisitorState).success THEN
            i := 0;
            WHILE (i < LEN(configValue.value)) & (configValue.value[i] # 0X) & state(WriteVisitorState).success DO
                Files.Write(state(WriteVisitorState).writer, ORD(configValue.value[i]));
                IF state(WriteVisitorState).writer.res # 0 THEN 
                    state(WriteVisitorState).success := FALSE 
                END;
                INC(i)
            END
        END;
        
        (* Write newline *)
        IF state(WriteVisitorState).success THEN
            Files.Write(state(WriteVisitorState).writer, ORD(Chars.LF));
            IF state(WriteVisitorState).writer.res # 0 THEN 
                state(WriteVisitorState).success := FALSE 
            END
        END
    END;
    
    (* Return TRUE to continue iteration, FALSE to stop *)
    (* We continue even on I/O errors, tracking success in the state *)
    RETURN TRUE
END WriteKeyValue;

(* Internal: Write section header to file, including blank line and [section] *)
PROCEDURE WriteSectionHeader(VAR writer: Files.Rider; sectionName: ARRAY OF CHAR; VAR isFirstSection: BOOLEAN; VAR success: BOOLEAN);
VAR j: INTEGER;
BEGIN
    IF sectionName[0] # 0X THEN
        (* Add blank line before section (except after empty default section) *)
        IF ~isFirstSection THEN
            Files.Write(writer, ORD(Chars.LF));
            IF writer.res # 0 THEN success := FALSE END
        END;
        IF success THEN
            Files.Write(writer, ORD("["));
            IF writer.res # 0 THEN success := FALSE END;
            j := 0;
            WHILE (j < LEN(sectionName)) & (sectionName[j] # 0X) & success DO
                Files.Write(writer, ORD(sectionName[j]));
                IF writer.res # 0 THEN success := FALSE END;
                INC(j)
            END;
            IF success THEN
                Files.Write(writer, ORD("]"));
                IF writer.res # 0 THEN success := FALSE END;
                Files.Write(writer, ORD(Chars.LF));
                IF writer.res # 0 THEN success := FALSE END
            END
        END;
        isFirstSection := FALSE
    END
END WriteSectionHeader;

(** Save configuration to file *)
PROCEDURE SaveConfig*(config: Config; filename: ARRAY OF CHAR): INTEGER;
VAR 
    file: Files.File;
    writeState: WriteVisitorState;
    result: INTEGER;
    i, count: INTEGER;
    section: Collections.ItemPtr;
    wrapper: CollectionWrappers.DictionaryWrapperPtr;
    nameItem: Collections.ItemPtr;
    sectionNamePtr: SectionNamePtr;
    success: BOOLEAN;
    isFirstSection: BOOLEAN;
BEGIN
    result := NoError;
    IF config = NIL THEN
        result := SyntaxError
    ELSE
        file := Files.New(filename);
        IF file = NIL THEN
            result := IOError
        ELSE
            FOR i := 0 TO LEN(writeState.sectionName) - 1 DO
                writeState.sectionName[i] := 0X
            END;
            writeState.success := TRUE;
            writeState.writer.res := 0;
            Files.Set(writeState.writer, file, 0);
            writeState.success := TRUE;
            isFirstSection := TRUE;
            count := ArrayList.Count(config.sections);
            i := 0;
            WHILE (i < count) & writeState.success DO
                success := ArrayList.GetAt(config.sections, i, section);
                IF success THEN
                    wrapper := section(CollectionWrappers.DictionaryWrapperPtr);
                    success := ArrayList.GetAt(config.sectionNames, i, nameItem);
                    IF success THEN
                        sectionNamePtr := nameItem(SectionNamePtr);
                        Chars.Copy(sectionNamePtr.name, writeState.sectionName);
                        WriteSectionHeader(writeState.writer, writeState.sectionName, isFirstSection, writeState.success);
                        IF writeState.success THEN
                            Dictionary.ForeachString(wrapper.dict, WriteKeyValue, writeState)
                        END
                    ELSE
                        writeState.success := FALSE
                    END
                ELSE
                    writeState.success := FALSE
                END;
                INC(i)
            END;
            IF writeState.success THEN
                Files.Register(file)
            ELSE
                result := IOError
            END;
            Files.Close(file)
        END
    END;
    RETURN result
END SaveConfig;

END IniConfigParser.
