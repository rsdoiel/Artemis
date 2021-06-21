MODULE o7front;

IMPORT Config, Unix, Chars, Args := extArgs, Out;

CONST
  MAXSTR = 2024;
  SMLSTR = 256;

  (* o7front Flags *)
  MAIN = 1;            (* -m *)
  SYMBOLS = 2;         (* -s *)
  EXTEND_MODULES = 3;  (* -e *)
  INCLUDE_HEADER = 4;  (* -i *)
  RANGE_VALUES = 5;    (* -r *)
  INDEX_CHECK = 6;     (* -x *)
  ASSERTIONS = 7;      (* -a *)
  POINTER_INIT = 8;    (* -p *)
  TYPE_CHECKS = 9;     (* -t *)
  VERBOSE = 10;        (* -V *)
  DEBUG_SYMBOLS = 11;  (* -G *)
  OPTIMIZATIONS = 12;  (* -O *)
  C_OPTIONS = 13;      (* -C *)
  OUTFILE = 14;        (* -o *)


VAR
  appName, cFlags : ARRAY SMLSTR OF CHAR;
  inName, outName : ARRAY MAXSTR OF CHAR;
  i, l, res : INTEGER;
  options : SET;

(** Usage describes how to use this program *)
PROCEDURE Usage(exitCode : INTEGER);
BEGIN
  Out.String("USAGE: o7c [OPTIONS] MODULE [MODULE ...]");Out.Ln();
  Out.Ln();
  Out.String("Compile Oberon-07 modules.");Out.Ln();
  Unix.Exit(exitCode);
END Usage;

PROCEDURE Compile*();
BEGIN
  Out.String(appName);Out.Char(" ");Out.String(Config.version);Out.Ln();
  Out.String("Compiling ");Out.String(inName); Out.Ln();
END Compile;

PROCEDURE SetOptions(VAR arg : ARRAY OF CHAR);
BEGIN
  Chars.TrimLeft("-", arg);
  WHILE Strings.Length(arg) > 0 DO
    IF Chars.Equal("m", arg) THEN
      INCL(options, MAIN);
    ELSIF Chars.Equal("s", arg) THEN
      INCL(options, SYMBOLS);
    ELSIF Chars.Equal("e", arg) THEN
      INCL(options, EXTEND_MODULES);
    ELSIF Chars.Equal("i", arg) THEN
      INCL(options, INCLUDE_HEADER);
    ELSIF Chars.Equal("r", arg) THEN
      INCL(options, RANGE_VALUES);
    ELSIF Chars.Equal("x", arg) THEN
      INCL(options, INDEX_CHECK);
    ELSIF Chars.Equal("a", arg) THEN
      INCL(options, ASSERTIONS);
    ELSIF Chars.Equal("p", arg) THEN
      INCL(options, POINTER_INIT);
    ELSIF Chars.Equal("t", arg) THEN
      INCL(options, TYPE_CHECKS);
    ELSIF Chars.Equal("V", arg) THEN
      INCL(options, VERBOSE);
    ELSIF Chars.Equal("G", arg) THEN
      INCL(options, DEBUG_SYMBOLS);
    ELSIF Chars.Equal("O", arg) THEN
      INCL(options, OPTIMIZATIONS);
    ELSIF Chars.Equal("C", arg) THEN
      INCL(options, C_OPTIONS);
    ELSIF Chars.Equal("o", arg) THEN
      INCL(options, OUTFILE);
    END;
    Chars.Delete(arg, 0, 1);
  END;
END SetOptions;


BEGIN
  appName := "o7front";
  outName[0] := 0X; inName[0] := 0X; cFlags[0] := 0X;
  Config.Init();
  IF Args.count > 0 THEN
    FOR i := 0 TO Argx.count - 1 DO
      Arg.Get(i, arg, res);
      IF Chars.StartsWith("-", arg) THEN
        SetOptions(arg);
      ELSIF OUTFILE IN options THEN
        outName := arg;
        EXCL(option, OUTFILE);
      ELSIF C_OPTION IN options THEN
        cFlags := arg;
        EXCL(option, C_OPTION);
      ELSE
        inName := arg;
        Compile();
      END;
    END;
  ELSE
    Usage(1);
  END;
END o7front.

