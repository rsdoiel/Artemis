(** extArgs.m provides access to POSIX system arguments. It is based
    on the definition found in OBNC's extended library extArgs.Mod. *)
MODULE extArgs;

IMPORT Args;

VAR
  count*: INTEGER; (*number of arguments*)

(** Get provides access to the parameters passed one the command line.
The parameters are n:th command line argument (0 <= n < count). 

The parameter res is provided for compatibilty with OBNC
extArgs. It is ignored. *)
PROCEDURE Get*(n: INTEGER; VAR arg: ARRAY OF CHAR; VAR res: INTEGER);
BEGIN
  (* The zero's arg need to be the first parameter from the command line *)
  Args.GetArg(n + 1, arg);  res := 0;
END Get;

BEGIN
  count := Args.argc - 1;
END extArgs.

