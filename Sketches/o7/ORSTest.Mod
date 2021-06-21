MODULE ORSTest;

IMPORT T := Tests, ORS;

VAR
  ts : T.TestSet;

PROCEDURE TestProcs() : BOOLEAN;
  VAR test : BOOLEAN; name : ARRAY 256 OF CHAR; pos : INTEGER;
BEGIN test := TRUE;
  name := "testcode/T1.Mod"; 
  ORS.Init(name);
  pos := ORS.Pos();
  T.ExpectedInt(0, pos, "pos should be zero after call to ORS.Init('testcode/T1.Mod')", test);
(**
PROCEDURE CopyId*(VAR ident: Ident);
PROCEDURE Pos*(): INTEGER;
PROCEDURE Mark*(msg: ARRAY OF CHAR);
PROCEDURE Identifier(VAR sym: INTEGER);
PROCEDURE String;
PROCEDURE HexString;
PROCEDURE Ten(e: INTEGER): REAL;
PROCEDURE Number(VAR sym: INTEGER);
PROCEDURE comment;
PROCEDURE Get*(VAR sym: INTEGER);
PROCEDURE EnterKW(sym: INTEGER; name: ARRAY OF CHAR);
EnterKW(procedure, "PROCEDURE");
**)
  RETURN test
END TestProcs;

BEGIN
  T.Init(ts, "ORS");
  T.Add(ts, TestProcs);
  ASSERT(T.Run(ts));
END ORSTest.

