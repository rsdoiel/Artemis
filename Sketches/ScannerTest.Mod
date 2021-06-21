MODULE ScannerTest;

IMPORT Tests, Scanner, Chars, Files, Out;

CONST
  QUOT = 34X;
  LF = 10X;
  CR = 13X;

VAR
  ts : Tests.TestSet;
  S : Scanner.Scanner;

PROCEDURE quote(source : ARRAY OF CHAR; VAR dest : ARRAY OF CHAR);
  VAR l : INTEGER;
BEGIN
  l := Chars.Length(source);
  Chars.Clear(dest);
  dest[0] := QUOT; dest[1] := 0X;
  Chars.Append(source, dest);
  dest[l + 1] := QUOT;
  dest[l + 2] := 0X;
END quote;

PROCEDURE WriteLn(VAR W : Files.Rider);
BEGIN
  Files.WriteChar(W, CR);
  Files.WriteChar(W, LF);
END WriteLn;

PROCEDURE SetupTestData(name : ARRAY OF CHAR);
  VAR F : Files.File; W : Files.Rider; s : ARRAY 256 OF CHAR;
BEGIN
  F := Files.New(name); Files.Register(F);
  Files.Set(W, F, 0);
  (*
  Files.WriteInt(W, 1);
  Files.WriteReal(W, 2.2);
  *)
  s := "Fred";
  Files.WriteString(W, s); WriteLn(W);
  quote("Hello World", s);
  Out.String("DEBUG s ");Out.String(s); Out.Ln;
  Files.WriteString(W, s); WriteLn(W);
  Files.WriteChar(W, "Z"); WriteLn(W);
END SetupTestData;

PROCEDURE TestScan() : BOOLEAN;
  VAR test : BOOLEAN; iCnt : INTEGER;
BEGIN test := TRUE;
  iCnt := 0;
  Scanner.OpenScanner(S, Files.Old("test1.dat"), 0);
  WHILE (S.eof = FALSE) & test  DO
    Out.String("line: ");Out.Int(S.line, 1);
    Out.String(", class: ");
    IF S.class = Scanner.Inval THEN
      Out.String(" invalid symbol "); Out.String(S.s); Out.Ln;
    ELSIF S.class = Scanner.Name THEN
      Out.String(" name = "); Out.String(S.s); Out.Ln;
    ELSIF S.class = Scanner.Int THEN
      Out.String(" int = "); Out.Int(S.i, 1); Out.Ln;
    ELSIF S.class = Scanner.Real THEN
      Out.String(" real = "); Out.Real(S.x, 1); Out.Ln;
    ELSIF S.class = Scanner.Char THEN
      Out.String(" char = "); Out.Char(S.c); Out.Ln;
    ELSIF S.class = Scanner.String THEN
      Out.String(" string = "); Out.String(S.s); Out.Ln;
    ELSE
      test := FALSE;
    END;
    IF iCnt > 10 THEN
      test := FALSE;
    END;
    INC(iCnt);
  END;
  RETURN test
END TestScan;

BEGIN
  SetupTestData("test1.dat");
  Tests.Init(ts, "Test Scanner");
  Tests.Add(ts, TestScan);
  ASSERT(Tests.Run(ts));
END ScannerTest.

