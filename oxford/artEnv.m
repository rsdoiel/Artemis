(**artEnv.m is a compatible module for code written for OBNC but compiler with Obc-3 

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

*)
MODULE artEnv;

IMPORT Args, Strings;

PROCEDURE Get*(name : ARRAY OF CHAR; VAR value : ARRAY OF CHAR; VAR res : INTEGER);
  VAR i, l1, l2 : INTEGER; val : ARRAY 512 OF CHAR;
BEGIN
  l1 := LEN(value) - 1; (* Allow for trailing 0X *)
  Args.GetEnv(name, val);
  l2 := Strings.Length(val);
  IF l2 <= l1 THEN
    res := 0;
  ELSE
    res := l2 - l1;
  END;
  i := 0;
  WHILE (i < l2) & (val[i] # 0X) DO
      value[i] := val[i];
      INC(i);
  END;
  value[i] := 0X;
END Get;

END artEnv.
