(** helloworld.m is intended to test the Obc-3 compiler installation. *)
MODULE helloworld;

IMPORT Args, Strings, Out;
(* NOTE: Args provide GetEnv() for obc-3 *)
VAR
  name : ARRAY 256 OF CHAR;

BEGIN
  Args.GetEnv("USER", name);
  IF Strings.Length(name) > 0 THEN
    Out.String("Hello ");Out.String(name); Out.Ln;
  ELSE
    Out.String("Hello World!"); Out.Ln;
  END;
END helloworld.
