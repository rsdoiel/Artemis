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
  - You cannot substitute a procedure into SYSTEM.VAL(), use a local variable in such cases.
  - Oberon-07 reintroduced FOR loops, so **use them instead of WHILE loops where appropriate**.
  - There is no enumeration type in oberon 07. use INTEGER. 
- **Best Practices**
  - Functions and procedures should be clear, concise, and well-structured.
  - Use helper functions to avoid code duplication.
  - Use modules to encapsulate functionality. Use opaque pointers to expose necessary types. Hide implementation details.
  - Export only what is necessary; keep the interface clean.
  - Use meaningful names for modules, procedures, and variables.
  - Use PascalCase for module names, constants and procedures and camelCase for variables.

## Implementation Guidelines
- Conceptual clarity is more important than performance.
- Avoid hidden complexity.
- Each type has straightforward, focused logic, preferably one concern.
- Observe type safety.

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
- Be conservative and factual in documentation statements, do not exaggerate.

## Creating C wrappers

1. Create a file named M.obn with the the exported declarations.
   Proper Procedures should have empty bodies to satisfy syntax requirements.
   Example: `PROCEDURE MyProc; BEGIN END MyProc;` 
   Function procedures should have a dummy return value to satisfy syntax requirements.
   Example: `PROCEDURE MyFunc() : BOOLEAN; BEGIN RETURN TRUE END MyFunc;` 

2. Create a file named MTest.obn which imports M (and preferably  write
    unit tests for M)
3. Build MTest with the command
        obnc MTest.obn
4. Copy the generated file .obnc/M.c to the current directory. In M.c,
    delete the generator comment on the first line and change  the  path
    in the include directive from M.h to .obnc/M.h.
5. Implement M.c.

### Notes on C Wrappers

1. The initialization function M__Init is called each time a client
  module imports M. Its statements should therefore be  guarded  with an
  initialization flag to make sure they are executed only once.