# Using Artemis Collections in Real-World Oberon-07: The INI Config Parser

The Artemis project provides a modern, type-safe set of collection modules for Oberon-07, including `ArrayList`, `Dictionary`, `Stack`, `Queue`, and more. These collections are designed to be easy to use, safe, and efficient, while respecting the language’s constraints and philosophy.

One of the best ways to see these collections in action is through the `IniConfigParser` module, which parses and writes INI configuration files. Let’s walk through how the collections are used in a real-world Oberon-07 application.

## Why Collections Matter

Oberon-07 doesn’t have built-in dynamic arrays or hash tables. Artemis Collections fills this gap with:

- **ArrayList**: A dynamic array for storing items of any type.
- **Dictionary**: A flexible key-value store supporting both integer and string keys.
- **Stack/Queue**: Classic LIFO/FIFO structures for algorithms and data processing.

All collections use a common `Collections.ItemPtr` type, so you can store any kind of object, and the API is consistent across modules.

## Example: Parsing an INI File

Suppose you want to load a configuration file, look up some values, and maybe update and save it. Here’s how you’d do it with Artemis IniConfigParser:

```oberon
MODULE ExampleIniConfigParser;
  IMPORT IniConfigParser, Out;

  VAR
    config: IniConfigParser.Config;
    err: INTEGER;
    value: IniConfigParser.ConfigValuePtr;
    ok: BOOLEAN;

BEGIN
  err := IniConfigParser.LoadConfig("settings.ini", config);
  IF err = IniConfigParser.NoError THEN
    ok := IniConfigParser.GetValue(config, "Database", "port", value);
    IF ok THEN
      Out.String("Database port: "); Out.String(value.value); Out.Ln
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

## How It Works Under the Hood

- **Sections** are stored as an `ArrayList` of dictionaries.
- Each **section** is a `Dictionary` mapping keys to values.
- The **default section** (for keys outside any `[section]`) is just another dictionary at index 0.
- All values are wrapped in a `ConfigValue` record, which stores the string, its detected type (string, integer, real, boolean), and the line number.

The parser uses the collections API to add, look up, and remove sections and keys. For example, to get a section:

```oberon
section := IniConfigParser.GetSection(config, "database");
```

And to get a value from a section:

```oberon
ok := IniConfigParser.GetValue(config, "database", "host", value);
```

## Features

- **Automatic type detection**: Values like `42`, `3.14`, or `TRUE` are recognized as integer, real, or boolean.
- **Case-sensitive**: Section and key names are case-sensitive.
- **Error handling**: All major procedures return error codes, so you can check for problems.
- **Resource management**: You must call `FreeConfig` when done to release memory.

For more details, check out the full ExampleIniConfigParser.Mod and the API documentation.

---

© 2025 Artemis Project. BSD 3-Clause License.