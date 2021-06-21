MODULE ebnfc;

IMPORT EBNF, Chars, Out, Unix, Args := extArgs;

VAR 
  name : ARRAY Chars.MAXSTR OF CHAR;
  i, res : INTEGER;

PROCEDURE usage(exit_code : INTEGER);
BEGIN
  Out.String("USAGE: ebnf FILENAME [FILENAME ...]"); Out.Ln();
  Out.Ln();
  Out.String("Compile (aka validate) an file containing EBNF notation");Out.Ln();
  Out.Ln();
  Out.String("EBNF Compiler ");Out.String(EBNF.version); Out.Ln;
  Unix.Exit(exit_code);
END usage;

BEGIN
  IF Args.count = 0 THEN
    usage(1);
  END;
  FOR i := 0 TO (Args.count - 1) DO
    Args.Get(i, name, res);
    IF Chars.StartsWith("-h", name) OR Chars.StartsWith("--h", name) THEN
      usage(0);
    ELSIF Chars.StartsWith("-v", name) OR Chars.StartsWith("--v", name) THEN
      Out.String("EBNF Compiler ");Out.String(EBNF.version); Out.Ln;
    ELSE
      Out.String("EBNF Compiler ");Out.String(EBNF.version); Out.Ln;
      Out.String(name);Out.Ln;
      EBNF.Compile(name);
    END;
  END;
END ebnfc.
