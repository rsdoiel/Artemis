MODULE CharFilesTest;

IMPORT CharFiles, T := Tests;

VAR
  ts : T.TestSet;

(* TestBasics test the Files module procedures that
   are wrapped by CharFiles with significant changes
   (e.g. have one line procedure bodies) *)
PROCEDURE TestBasics() : BOOLEAN;
BEGIN
  Out.String("TestsBasics() not implemented");Out.Ln;
  RETURN FALSE
END TestBasics;

(* TestWrites test the write procedure in CharFiles module *)
PROCEDURE TestWrites() : BOOLEAN;
BEGIN
  Out.String("TestsWrites() not implemented");Out.Ln;
  RETURN FALSE
END TestWrites;

(* TestReads test the read procedures in CharFiles module *)
PROCEDURE TestReads() : BOOLEAN;
BEGIN
  Out.String("TestsReads() not implemented");Out.Ln;
  RETURN FALSE
END TestReads;

BEGIN
  T.Init(ts, "CharFiles Test");
  T.Add(ts, TestBasics);
  T.Add(ts, TestWrites);
  T.Add(ts, TestReads);
  ASSERT(T.Run(ts));
END CharFilesTest.
