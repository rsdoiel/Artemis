MODULE TestOut;

IMPORT SYSTEM, Out := artOut;

PROCEDURE TestOutput();
BEGIN
  Out.String("Hello World");Out.Ln;
  Out.Int(123, 10);Out.Ln;
  Out.Real(1.359, 10); Out.Ln;
END TestOutput;

BEGIN
    TestOutput();
END TestOut.

Compile with OfrontPlus

    ofront+ TestOut.Mod -m
    cc TestOut.c
