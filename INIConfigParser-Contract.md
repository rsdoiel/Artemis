# Artemis INI Config Parser – Preliminary Contract (MVP)

**Project:** Artemis Standard Library Extensions  
**Feature:** INI Config Parser  

---

## Design Decisions & Requirements

### 1. Type Detection
- The parser will automatically detect types for unquoted values:
  - **INTEGER**: numbers without dots
  - **REAL**: numbers with dots
  - **BOOLEAN**: TRUE/FALSE (case-sensitive)
  - **STRING**: all other unquoted values
- Quoted values are always treated as strings; no type detection inside quotes.

### 2. Section Handling
- Section names are **case-sensitive**.
- There will be a **default section** for keys outside any section.

### 3. API Design
- The API will include:
  - `LoadConfig`
  - `GetSection`
  - `GetValue`
  - `GetType` (to enable validation and type casts)
- Only loading configs is required for MVP; saving can be added later.

### 4. Error Handling
- Procedures will return error codes for error reporting.

### 5. Tokenization
- A simple, line-based tokenizer will be used, as long as it meets requirements.

---

## Notes
- No nested sections.
- No multiline values.
- Comments must start at the beginning of a line with a semicolon (`;`).
- Use Oberon-07 Files module for I/O.
- Use Dictionary from Collections API for section key-values.
- Section representation: ArrayList of Dictionaries, with a default section.

---

## Implementation
 - IniConfigTokenizer - dedicated tokenizer module,  handles file operations.
 - IniConfigParser - parser, uses tokenizer to produce arraylist of dictionaries, (user facing module), pr

## Testing
 - Follow test organization example given in RandomTest.Mod

This document summarizes the Q&A and design contract for the Artemis INI Config Parser MVP. Further refinements and features may be added after the MVP is complete.
