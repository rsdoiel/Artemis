(** IniConfigParser.Mod - Main parser for INI configuration files.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE IniConfigParser;

IMPORT IniConfigTokenizer, Files, ArrayList, Dictionary, Collections, Chars;

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
    
    (** Dictionary wrapper for ArrayList storage *)
    DictionaryWrapper = RECORD(Collections.Item)
        dict: Dictionary.Dictionary
    END;
    DictionaryWrapperPtr = POINTER TO DictionaryWrapper;
    
    (** INI Configuration parser *)
    Config* = POINTER TO ConfigDesc;
    ConfigDesc = RECORD
        sections: ArrayList.ArrayList; (* ArrayList of Dictionary *)
        sectionNames: ArrayList.ArrayList; (* ArrayList of string section names *)
        error: INTEGER;
        errorLine: INTEGER
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

(** Create a new dictionary wrapper *)
PROCEDURE NewDictionaryWrapper(dict: Dictionary.Dictionary): Collections.ItemPtr;
VAR wrapper: DictionaryWrapperPtr; result: Collections.ItemPtr;
BEGIN
    NEW(wrapper);
    wrapper.dict := dict;
    result := wrapper;
    RETURN result
END NewDictionaryWrapper;

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
PROCEDURE FindSectionIndex(config: Config; sectionName: ARRAY OF CHAR): INTEGER;
VAR 
    i, count: INTEGER;
    nameItem: Collections.ItemPtr;
    sectionNamePtr: SectionNamePtr;
    found: BOOLEAN;
    j: INTEGER;
    result: INTEGER;
BEGIN
    result := -1;
    count := ArrayList.Count(config.sectionNames);
    i := 0;
    found := FALSE;
    
    WHILE (i < count) & ~found DO
        IF ArrayList.GetAt(config.sectionNames, i, nameItem) THEN
            sectionNamePtr := nameItem(SectionNamePtr);
            
            (* Compare section names *)
            j := 0;
            found := TRUE;
            WHILE (j < LEN(sectionName)) & (j < LEN(sectionNamePtr.name)) & 
                  (sectionName[j] # 0X) & (sectionNamePtr.name[j] # 0X) & found DO
                IF sectionName[j] # sectionNamePtr.name[j] THEN
                    found := FALSE
                END;
                INC(j)
            END;
            
            (* Check if both strings ended at same position *)
            IF found & ((sectionName[j] # 0X) OR (sectionNamePtr.name[j] # 0X)) THEN
                found := FALSE
            END;
            
            IF found THEN
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
    wrapper: DictionaryWrapperPtr;
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
        wrapper := section(DictionaryWrapperPtr);
        result := wrapper.dict
    ELSE
        (* Create new section *)
        dict := Dictionary.NewStringDict();
        nameItem := NewSectionName(sectionName);
        
        success := ArrayList.Append(config.sections, NewDictionaryWrapper(dict));
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
    
    success := ArrayList.Append(config.sections, NewDictionaryWrapper(defaultSection));
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
    wrapper: DictionaryWrapperPtr;
BEGIN
    IF config # NIL THEN
        (* Free all section dictionaries *)
        count := ArrayList.Count(config.sections);
        FOR i := 0 TO count - 1 DO
            IF ArrayList.GetAt(config.sections, i, section) THEN
                wrapper := section(DictionaryWrapperPtr);
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
PROCEDURE LoadConfig*(filename: ARRAY OF CHAR; VAR config: Config): INTEGER;
VAR 
    file: Files.File;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;
    currentSection: Dictionary.Dictionary;
    currentSectionName: ARRAY 256 OF CHAR;
    currentKey: ARRAY 256 OF CHAR;
    configValue: ConfigValuePtr;
    valueType: INTEGER;
    result: INTEGER;
BEGIN
    result := NoError;
    config := NewConfig();
    
    (* Try to open file *)
    file := Files.Old(filename);
    IF file = NIL THEN
        result := FileNotFound;
        config.error := FileNotFound
    ELSE
        (* Initialize tokenizer *)
        IniConfigTokenizer.Init(tokenizer, file);
        
        (* Start with default section *)
        currentSectionName[0] := 0X;
        currentSection := GetOrCreateSection(config, currentSectionName);
        
        (* Parse tokens *)
        WHILE (~IniConfigTokenizer.AtEof(tokenizer)) & (result = NoError) DO
            IniConfigTokenizer.NextToken(tokenizer, token);
            
            IF token.type = IniConfigTokenizer.SectionToken THEN
                (* Switch to new section *)
                Chars.Copy(token.value, currentSectionName);
                currentSection := GetOrCreateSection(config, currentSectionName)
                
            ELSIF token.type = IniConfigTokenizer.KeyToken THEN
                (* Store the key and get the value for this key *)
                Chars.Copy(token.value, currentKey);
                IniConfigTokenizer.GetValue(tokenizer, token);
                
                IF token.type = IniConfigTokenizer.ValueToken THEN
                    (* Detect value type and store *)
                    valueType := DetectValueType(token.value);
                    configValue := NewConfigValue(token.value, valueType, token.line);
                    Dictionary.PutString(currentSection, currentKey, configValue)
                ELSE
                    (* Error: expected value after key *)
                    result := SyntaxError;
                    config.error := SyntaxError;
                    config.errorLine := token.line
                END
                
            ELSIF token.type = IniConfigTokenizer.CommentToken THEN
                (* Skip comments *)
                
            ELSIF token.type = IniConfigTokenizer.ErrorToken THEN
                (* Tokenizer error *)
                result := SyntaxError;
                config.error := SyntaxError;
                config.errorLine := token.line
                
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
    wrapper: DictionaryWrapperPtr;
    success: BOOLEAN;
    result: Dictionary.Dictionary;
BEGIN
    result := NIL;
    
    IF config # NIL THEN
        sectionIndex := FindSectionIndex(config, sectionName);
        IF sectionIndex >= 0 THEN
            success := ArrayList.GetAt(config.sections, sectionIndex, section);
            IF success THEN
                wrapper := section(DictionaryWrapperPtr);
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

END IniConfigParser.
