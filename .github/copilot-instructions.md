# Copilot Instructions for Artemis Project

- **Project Goal:** Standard Library extensions for Oberon-07, including collections, string manipulation, and more. 
- **Language:** Oberon-07
- **Constraints:** 
  - Only fixed-size arrays are allowed by the language. 
  - Open array parameters are allowed as procedure parameters only.
  - Function return values **must be handled**.
  - Return is only allowed as the last statement in a procedure. Use a `result` variable for returning values.
  - No early returns are allowed.
  - Forward declarations for procedures are not allowed (only for pointers).
  - A situation requiring mutual recursion can be handled by using procedure types to make indirect calls.
  - The last statement before an `END` or an `ELSE` **must not end with a semicolon**.
  - For bitwise operations, use our own implementation from `Bitwise.mod`.
  - Use VAR in procedure parameters for mutable variables.
  - The CASE statement does not have a default case.
  - SYSTEM.VAL() does not allow procedure parameters, use a local variable to convert types.
- **Best Practices**
  - Functions and procedures should be clear, concise, and well-structured.
  - Use helper functions to avoid code duplication.
  - Use modules to encapsulate functionality. Use opaque pointers to expose necessary types. Hide implementation details.
  - Export only what is necessary; keep the interface clean.
  - Use meaningful names for modules, procedures, and variables.
  - Use PascalCase for module names, constants and procedures and camelCase for variables.


## Building

- The project uses **GNU Make** for building.
- New modules and tests should be discovered by the Makefile automatically.

## Testing

- Tests should be granular enough to help identify problems, but avoid excess verbosity.

## Documentation

- Documentation is generated using `obncdoc` (supports whole folder only) and placed in the `docs/` directory.
- Generated documentation is available in `obncdoc/*.def`. 
- Exported procedures documentation comment lines start with `(**` and end with `*)`, so obncdoc finds them.
- Internal procedures documentation comment lines start with `(*` and end with `*)`, so they are not included in the API documentation.
- The header should contain a copyright notice for the 3 clause BSD license, the module name, a brief description, and the author.