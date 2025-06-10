(* Example: Using IniConfigParser to read, modify, and save INI configuration files *)

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
        
    (* Settings section for demonstration *)
    ELSIF sectionName = "settings" THEN
        found := IniConfigParser.GetValue(config, "settings", "theme", value);
        IF found THEN ShowValue("theme", value) END;
        
        found := IniConfigParser.GetValue(config, "settings", "auto_save", value);
        IF found THEN ShowValue("auto_save", value) END;
        
        found := IniConfigParser.GetValue(config, "settings", "timeout", value);
        IF found THEN ShowValue("timeout", value) END;
        
        found := IniConfigParser.GetValue(config, "settings", "max_connections", value);
        IF found THEN ShowValue("max_connections", value) END
    END;
    Out.Ln
END ShowSection;

PROCEDURE DemoConfigCreation();
VAR
    newConfig: IniConfigParser.Config;
    success: BOOLEAN;
    saveResult: INTEGER;
BEGIN
    Out.String("=== Creating and Saving Configuration ==="); Out.Ln; Out.Ln;
    
    (* Create a new configuration *)
    newConfig := IniConfigParser.NewConfig();
    
    IF newConfig # NIL THEN
        Out.String("Created new configuration."); Out.Ln;
        
        (* Set values in default section *)
        success := IniConfigParser.SetDefaultValue(newConfig, "app_name", "Demo Application");
        IF ~success THEN Out.String("Error setting app_name"); Out.Ln END;
        success := IniConfigParser.SetDefaultValue(newConfig, "version", "2.1");
        IF ~success THEN Out.String("Error setting version"); Out.Ln END;
        success := IniConfigParser.SetDefaultValue(newConfig, "build_number", "1042");
        IF ~success THEN Out.String("Error setting build_number"); Out.Ln END;
        Out.String("Added values to default section."); Out.Ln;
        
        (* Set database configuration *)
        success := IniConfigParser.SetValue(newConfig, "database", "host", "prod-server.example.com");
        IF ~success THEN Out.String("Error setting database host"); Out.Ln END;
        success := IniConfigParser.SetValue(newConfig, "database", "port", "3306");
        IF ~success THEN Out.String("Error setting database port"); Out.Ln END;
        success := IniConfigParser.SetValue(newConfig, "database", "ssl", "TRUE");
        IF ~success THEN Out.String("Error setting database ssl"); Out.Ln END;
        success := IniConfigParser.SetValue(newConfig, "database", "timeout", "30.5");
        IF ~success THEN Out.String("Error setting database timeout"); Out.Ln END;
        Out.String("Added database configuration."); Out.Ln;
        
        (* Set logging configuration *)
        success := IniConfigParser.SetValue(newConfig, "logging", "level", "INFO");
        success := IniConfigParser.SetValue(newConfig, "logging", "max_size", "50.0");
        success := IniConfigParser.SetValue(newConfig, "logging", "rotate", "TRUE");
        success := IniConfigParser.SetValue(newConfig, "logging", "backup_count", "5");
        Out.String("Added logging configuration."); Out.Ln;
        
        (* Set user preferences *)
        success := IniConfigParser.SetValue(newConfig, "settings", "theme", "dark");
        success := IniConfigParser.SetValue(newConfig, "settings", "auto_save", "TRUE");
        success := IniConfigParser.SetValue(newConfig, "settings", "timeout", "300");
        success := IniConfigParser.SetValue(newConfig, "settings", "max_connections", "100");
        Out.String("Added user settings."); Out.Ln; Out.Ln;
        
        (* Display the created configuration *)
        Out.String("Created configuration contents:"); Out.Ln;
        Out.String("Default section:"); Out.Ln;
        found := IniConfigParser.GetDefaultValue(newConfig, "app_name", value);
        IF found THEN ShowValue("app_name", value) END;
        found := IniConfigParser.GetDefaultValue(newConfig, "version", value);
        IF found THEN ShowValue("version", value) END;
        found := IniConfigParser.GetDefaultValue(newConfig, "build_number", value);
        IF found THEN ShowValue("build_number", value) END;
        Out.Ln;
        
        ShowSection(newConfig, "database");
        ShowSection(newConfig, "logging");
        ShowSection(newConfig, "settings");
        
        (* Save the configuration *)
        Out.String("Saving configuration to 'generated_config.ini'..."); Out.Ln;
        
        (* Debug: Verify config is not NIL before saving *)
        IF newConfig = NIL THEN
            Out.String("ERROR: Config is NIL before save!"); Out.Ln
        ELSE
            Out.String("Config is valid, attempting save..."); Out.Ln
        END;
        
        saveResult := IniConfigParser.SaveConfig(newConfig, "generated_config.ini");
        
        IF saveResult = IniConfigParser.NoError THEN
            Out.String("Configuration saved successfully!"); Out.Ln
        ELSE
            Out.String("Error saving configuration: ");
            CASE saveResult OF
                IniConfigParser.FileNotFound: Out.String("File not found")
                | IniConfigParser.SyntaxError: Out.String("Syntax error")
                | IniConfigParser.IOError: Out.String("I/O error")
            END;
            Out.Ln
        END;
        Out.Ln;
        
        (* Clean up *)
        IniConfigParser.FreeConfig(newConfig)
    ELSE
        Out.String("Failed to create new configuration!"); Out.Ln
    END
END DemoConfigCreation;

PROCEDURE DemoConfigModification();
VAR
    modifyConfig: IniConfigParser.Config;
    loadResult, saveResult: INTEGER;
    success: BOOLEAN;
BEGIN
    Out.String("=== Loading and Modifying Existing Configuration ==="); Out.Ln; Out.Ln;
    
    (* Load the configuration we just created *)
    loadResult := IniConfigParser.LoadConfig("generated_config.ini", modifyConfig);
    
    IF loadResult = IniConfigParser.NoError THEN
        Out.String("Loaded 'generated_config.ini' successfully."); Out.Ln; Out.Ln;
        
        (* Show current database port *)
        Out.String("Current database configuration:"); Out.Ln;
        found := IniConfigParser.GetValue(modifyConfig, "database", "port", value);
        IF found THEN ShowValue("port", value) END;
        found := IniConfigParser.GetValue(modifyConfig, "database", "timeout", value);
        IF found THEN ShowValue("timeout", value) END;
        Out.Ln;
        
        (* Modify some values *)
        Out.String("Modifying configuration:"); Out.Ln;
        success := IniConfigParser.SetValue(modifyConfig, "database", "port", "5432");
        Out.String("  Changed database port to 5432"); Out.Ln;
        
        success := IniConfigParser.SetValue(modifyConfig, "database", "timeout", "45.0");
        Out.String("  Changed database timeout to 45.0"); Out.Ln;
        
        success := IniConfigParser.SetDefaultValue(modifyConfig, "version", "2.2");
        Out.String("  Updated version to 2.2"); Out.Ln;
        
        (* Add new values *)
        success := IniConfigParser.SetValue(modifyConfig, "logging", "file", "/var/log/app.log");
        Out.String("  Added log file path"); Out.Ln;
        
        success := IniConfigParser.SetValue(modifyConfig, "settings", "enable_cache", "TRUE");
        Out.String("  Added cache setting"); Out.Ln;
        Out.Ln;
        
        (* Show modified values *)
        Out.String("Modified database configuration:"); Out.Ln;
        found := IniConfigParser.GetValue(modifyConfig, "database", "port", value);
        IF found THEN ShowValue("port", value) END;
        found := IniConfigParser.GetValue(modifyConfig, "database", "timeout", value);
        IF found THEN ShowValue("timeout", value) END;
        Out.Ln;
        
        Out.String("Updated version:"); Out.Ln;
        found := IniConfigParser.GetDefaultValue(modifyConfig, "version", value);
        IF found THEN ShowValue("version", value) END;
        Out.Ln;
        
        (* Save the modified configuration *)
        Out.String("Saving modified configuration to 'modified_config.ini'..."); Out.Ln;
        saveResult := IniConfigParser.SaveConfig(modifyConfig, "modified_config.ini");
        
        IF saveResult = IniConfigParser.NoError THEN
            Out.String("Modified configuration saved successfully!"); Out.Ln
        ELSE
            Out.String("Error saving modified configuration."); Out.Ln
        END;
        Out.Ln;
        
        (* Clean up *)
        IniConfigParser.FreeConfig(modifyConfig)
    ELSE
        Out.String("Failed to load configuration for modification."); Out.Ln
    END
END DemoConfigModification;

BEGIN
    Out.String("IniConfigParser Example - Read/Write Configuration Management"); Out.Ln;
    Out.String("============================================================="); Out.Ln; Out.Ln;
    
    (* Demonstrate configuration creation and saving *)
    DemoConfigCreation();
    
    (* Demonstrate configuration loading and modification *)
    DemoConfigModification();
    
    (* Original example: Load configuration from existing test file *)
    Out.String("=== Loading Existing Test Configuration ==="); Out.Ln; Out.Ln;
    result := IniConfigParser.LoadConfig("test_data/example.ini", config);
    
    IF result = IniConfigParser.NoError THEN
        Out.String("Successfully loaded test configuration!"); Out.Ln; Out.Ln;
        
        (* Show sections and their values *)
        ShowSection(config, "database");
        ShowSection(config, "logging");
        ShowSection(config, "app");
        
        (* Example: Get value from default section (if any existed) *)
        Out.String("Default section values:"); Out.Ln;
        found := IniConfigParser.GetDefaultValue(config, "app_name", value);
        IF found THEN
            ShowValue("app_name", value)
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
        Out.String("Test configuration freed successfully."); Out.Ln
        
    ELSE
        Out.String("Error loading test configuration: ");
        CASE result OF
            IniConfigParser.FileNotFound: Out.String("File not found")
            | IniConfigParser.SyntaxError: Out.String("Syntax error")
            | IniConfigParser.IOError: Out.String("I/O error")
        END;
        Out.Ln
    END;
    
    Out.Ln;
    Out.String("Example completed. Check 'generated_config.ini' and 'modified_config.ini' files."); Out.Ln
END ExampleIniConfigParser.
