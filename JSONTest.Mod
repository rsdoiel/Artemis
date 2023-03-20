MODULE JSONTest;

IMPORT JSON, Out, T := Tests;

VAR
  ts : T.TestSet;

PROCEDURE TestSelf() : BOOLEAN;
  VAR test : BOOLEAN; self : JSON.Self; str : ARRAY 256 OF CHAR;
BEGIN test := FALSE;
  JSON.TypeName(self, str);Out.String(str);Out.Ln; (* DEBUG *)


  Out.String("DEBUG TestSelf() not implemented");Out.Ln;
  RETURN test
END TestSelf;

BEGIN
  (* Initialize our TestSet *)
  T.Init(ts, "JSON Test");
  T.Add(ts, TestSelf);
  (* Run our tests *)
  ASSERT(T.Run(ts));
END JSONTest.
