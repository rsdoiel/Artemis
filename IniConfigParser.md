# Artemis IniConfigParser – User Guide

**Module:** IniConfigParser.Mod  
**Project:** Artemis Standard Library Extensions

---

## Overview

The `IniConfigParser` module provides a type-aware parser and writer for INI configuration files in Oberon-07. It is designed for integration with Artemis project, supporting automatic type detection, sectioned configuration, error handling, and config saving.

---

## Features

- **Automatic Type Detection:**
  - Unquoted values are parsed as INTEGER, REAL, BOOLEAN (TRUE/FALSE), or STRING.
  - Quoted values are always treated as strings.
- **Section Support:**
  - Case-sensitive section names.
  - Keys outside any section are placed in a default section.
- **API Procedures:**
  - `LoadConfig`: Loads and parses an INI file.
  - `GetSection`: Retrieves a section by name.
  - `GetValue`: Retrieves a value by key and section.
  - `GetDefaultValue`: Retrieves a value from the default section.
  - `GetType`: Returns the detected type of a value.
  - `SetValue`/`SetDefaultValue`: Set or update values in the config.
  - `SaveConfig`: Saves the configuration back to an INI file.
  - `GetError`/`GetErrorLine`: Retrieve error codes and line numbers for diagnostics.
  - `FreeConfig`: Frees all resources used by a config object.
- **Error Handling:**
  - All major procedures return error codes for robust error reporting.
- **Integration:**
  - Uses Artemis Collections (ArrayList, Dictionary) for internal storage.
  - Designed for Oberon-07 language constraints.

---

## Usage Example

```oberon
MODULE ExampleIniConfigParser;
  IMPORT IniConfigParser, Out;

  VAR
    config: IniConfigParser.Config;
    err: INTEGER;
    value: IniConfigParser.ConfigValuePtr;
    valueType: INTEGER;
    ok: BOOLEAN;

BEGIN
  err := IniConfigParser.LoadConfig("settings.ini", config);
  IF err = IniConfigParser.NoError THEN
    ok := IniConfigParser.GetValue(config, "Database", "port", value);
    IF ok THEN
      valueType := IniConfigParser.GetType(value);
      IF valueType = IniConfigParser.IntegerType THEN
        Out.String("Port: "); Out.Int(ORD(value.value[0]), 0); Out.Ln
      END
    END;
    (* Set a value and save *)
    IniConfigParser.SetValue(config, "Database", "host", "localhost");
    IniConfigParser.SaveConfig(config, "settings-out.ini")
  ELSE
    Out.String("Failed to load config, error code: "); Out.Int(err, 0); Out.Ln
  END;
  IniConfigParser.FreeConfig(config)
END ExampleIniConfigParser.
```

---

## Limitations

- Only fixed-size arrays are supported (Oberon-07 constraint).
- **Maximum token/key/section name length:** 256 characters (see `IniConfigTokenizer.MaxTokenLength`).
- **Maximum value length:** 512 characters (see `ConfigValue.value`).
- **Maximum number of sections/keys:** Limited by available memory; internally uses `ArrayList` and `Dictionary` which dynamically allocate as needed, but are subject to system memory limits.
- No nested sections or multiline values.
- Comments must start at the beginning of a line with a semicolon (`;`).
- Section and key names are case-sensitive.
- Value interpolation and advanced INI features are not supported.
- Type detection is simple and may not handle all edge cases.
- **Maximum INI file size:** Limited by available system memory and Oberon-07 implementation.

---

## Integration Notes

- Uses `Files` for I/O and `Dictionary`/`ArrayList` from Artemis Collections.
- See `IniConfigParserTest.Mod` and `examples/ExampleIniConfigParser.Mod` for more usage examples and tests.
- Documentation is generated with `obncdoc` and available in `obncdoc/IniConfigParser.def`.

---

## See Also

- [Artemis Collections API](./Collections.md)
- [ExampleIniConfigParser.Mod](./examples/ExampleIniConfigParser.Mod)
- [IniConfigParserTest.Mod](./IniConfigParserTest.Mod)

---

© 2025 Artemis Project. BSD 3-Clause License.
