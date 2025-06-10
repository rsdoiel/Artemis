(* Example: Using IniConfigParser to read and parse INI configuration files *)

MODULE ExampleIniConfigParser;

IMPORT IniConfigParser, Out;

VAR
    config: IniConfigParser.Config;
    value: IniConfigParser.ConfigValuePtr;
    result: INTEGER;
    found: BOOLEAN;

PROCEDURE ShowValue(name: ARRAY OF CHAR; value: IniConfigParser.ConfigValuePtr);
BEGIN
    Out.String("  "); Out.String(name); Out.String(" = ");
    Out.String(value.value);
    Out.String(" (");
    CASE IniConfigParser.GetType(value) OF
        IniConfigParser.StringType: Out.String("STRING")
        | IniConfigParser.IntegerType: Out.String("INTEGER")
        | IniConfigParser.RealType: Out.String("REAL")
        | IniConfigParser.BooleanType: Out.String("BOOLEAN")
    END;
    Out.String(")"); Out.Ln
END ShowValue;

PROCEDURE ShowSection(config: IniConfigParser.Config; sectionName: ARRAY OF CHAR);
BEGIN
    Out.String("["); Out.String(sectionName); Out.String("]"); Out.Ln;
    
    (* Database section examples *)
    IF sectionName = "database" THEN
        found := IniConfigParser.GetValue(config, "database", "host", value);
        IF found THEN ShowValue("host", value) END;
        
        found := IniConfigParser.GetValue(config, "database", "port", value);
        IF found THEN ShowValue("port", value) END;
        
        found := IniConfigParser.GetValue(config, "database", "timeout", value);
        IF found THEN ShowValue("timeout", value) END;
        
        found := IniConfigParser.GetValue(config, "database", "ssl", value);
        IF found THEN ShowValue("ssl", value) END
        
    (* Logging section examples *)
    ELSIF sectionName = "logging" THEN
        found := IniConfigParser.GetValue(config, "logging", "level", value);
        IF found THEN ShowValue("level", value) END;
        
        found := IniConfigParser.GetValue(config, "logging", "file", value);
        IF found THEN ShowValue("file", value) END;
        
        found := IniConfigParser.GetValue(config, "logging", "rotate", value);
        IF found THEN ShowValue("rotate", value) END;
        
        found := IniConfigParser.GetValue(config, "logging", "max_size", value);
        IF found THEN ShowValue("max_size", value) END
        
    (* App section examples *)
    ELSIF sectionName = "app" THEN
        found := IniConfigParser.GetValue(config, "app", "name", value);
        IF found THEN ShowValue("name", value) END;
        
        found := IniConfigParser.GetValue(config, "app", "version", value);
        IF found THEN ShowValue("version", value) END;
        
        found := IniConfigParser.GetValue(config, "app", "debug", value);
        IF found THEN ShowValue("debug", value) END
    END;
    Out.Ln
END ShowSection;

BEGIN
    Out.String("IniConfigParser Example"); Out.Ln;
    Out.String("======================="); Out.Ln; Out.Ln;
    
    (* Load configuration from file *)
    result := IniConfigParser.LoadConfig("test_data/example.ini", config);
    
    IF result = IniConfigParser.NoError THEN
        Out.String("Successfully loaded configuration!"); Out.Ln; Out.Ln;
        
        (* Show sections and their values *)
        ShowSection(config, "database");
        ShowSection(config, "logging");
        ShowSection(config, "app");
        
        (* Example: Get value from default section (if any existed) *)
        Out.String("Default section values:"); Out.Ln;
        found := IniConfigParser.GetDefaultValue(config, "some_key", value);
        IF found THEN
            ShowValue("some_key", value)
        ELSE
            Out.String("  (no values in default section)"); Out.Ln
        END;
        Out.Ln;
        
        (* Example: Error handling for missing keys *)
        Out.String("Testing missing key:"); Out.Ln;
        found := IniConfigParser.GetValue(config, "database", "missing_key", value);
        IF found THEN
            ShowValue("missing_key", value)
        ELSE
            Out.String("  Key 'missing_key' not found in 'database' section"); Out.Ln
        END;
        Out.Ln;
        
        (* Example: Error handling for missing section *)
        Out.String("Testing missing section:"); Out.Ln;
        found := IniConfigParser.GetValue(config, "missing_section", "any_key", value);
        IF found THEN
            ShowValue("any_key", value)
        ELSE
            Out.String("  Section 'missing_section' not found"); Out.Ln
        END;
        Out.Ln;
        
        (* Clean up *)
        IniConfigParser.FreeConfig(config);
        Out.String("Configuration freed successfully."); Out.Ln
        
    ELSE
        Out.String("Error loading configuration: ");
        CASE result OF
            IniConfigParser.FileNotFound: Out.String("File not found")
            | IniConfigParser.SyntaxError: Out.String("Syntax error")
            | IniConfigParser.IOError: Out.String("I/O error")
        END;
        Out.Ln
    END
END ExampleIniConfigParser.
