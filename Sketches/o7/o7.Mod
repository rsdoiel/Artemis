(** o7.Mod implements a Oberon-7 to XXX code generator. *)
MODULE o7;

IMPORT Config, Unix, Out;

VAR
  i, res : INTEGER;
  arg : ARRAY 256 OF CHAR;

PROCEDURE usage(exitCode : INTEGER);
BEGIN
  Out.Ln;
  Out.String("USAGE ");Out.String(Config.appName);
  Out.String(" MODULE_NAME"); Out.Ln;
  Out.Ln;
  Out.String("An Oberon-7 compiler"); Out.Ln;
  Unix.Exit(exitCode);
END usage;

PROCEDURE Compile*(name : ARRAY OF CHAR);
BEGIN
  Out.String("Compile("); Out.String(name);
  Out.String("), not implemented."); Out.Ln;
END Compile;

BEGIN
  Config.Init();
  Out.String(Config.appName); Out.String(" version ");
  Out.String(Config.version); Out.Ln;
  IF Config.argCount > 0 THEN
    FOR i := 0 TO Config.argCount DO
      Config.GetArg(i, arg, res);
      Compile(arg);
    END;
  ELSE
    usage(1);
  END;
END o7.

