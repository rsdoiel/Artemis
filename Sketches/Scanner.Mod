(* Implements a Texts.Scanner on Files *)
MODULE Scanner;

IMPORT Files;

CONST (*scanner symbol classes*)
  Inval* = 0;         (*invalid symbol*)
  Name* = 1;          (*name s (length len)*)
  String* = 2;        (*literal string s (length len)*)
  Int* = 3;           (*integer i (decimal or hexadecimal)*)
  Real* = 4;          (*real number x*)
  Char* = 6;          (*special character c*)

  TAB = 9X; CR = 13X; LF = 10X;

TYPE
  Scanner* = RECORD (Files.Rider)
    nextCh*: CHAR;
    line*, class*: INTEGER;
    i*: INTEGER;
    x*: REAL;
    c*: CHAR;
    len*: INTEGER;
    s*: ARRAY 32 OF CHAR
  END;

PROCEDURE Read(VAR S: Scanner; VAR ch : CHAR);
  VAR x : BYTE;
BEGIN
  Files.Read(S, x); ch := CHR(x); 
END Read;

(* ------------------ Oberon-7 port of Scanners by NW --------------- *)

PROCEDURE OpenScanner* (VAR S: Scanner; F: Files.File; pos: INTEGER);
BEGIN Files.Set(S, F, pos); S.line := 0; S.nextCh := " "
END OpenScanner;

(*floating point formats:
  x = 1.m * 2^(e-127)   bit 0: sign, bits 1- 8: e, bits  9-31: m
  x = 1.m * 2^(e-1023)  bit 0: sign, bits 1-11: e, bits 12-63: m *)

PROCEDURE Ten(n: INTEGER): REAL;
  VAR t, p: REAL;
BEGIN t := 1.0; p := 10.0;   (*compute 10^n *)
  WHILE n > 0 DO
    IF ODD(n) THEN t := p * t END ;
    p := p*p; n := n DIV 2
  END ;
  RETURN t
END Ten;

PROCEDURE Scan* (VAR S: Scanner);
  CONST maxExp = 38; maxM = 16777216; (*2^24*)
  VAR ch: CHAR;
    neg, negE, hex: BOOLEAN;
    i, j, h, d, e, n, s: INTEGER;
    x: REAL;
BEGIN ch := S.nextCh; i := 0;
  WHILE (ch = " ") OR (ch = TAB) OR (ch = CR) OR (ch = LF) DO
    IF (ch = CR) OR (ch = LF) THEN INC(S.line) END ;
    Read(S, ch)
  END ;
  IF ("A" <= ch) & (ch <= "Z") OR ("a" <= ch) & (ch <= "z") THEN (*name*)
    REPEAT S.s[i] := ch; INC(i); Read(S, ch)
    UNTIL ((ch < "0") & (ch # ".") OR ("9" < ch) & (ch < "A") OR ("Z" < ch) & (ch < "a") OR ("z" < ch)) OR (i = 31);
    S.s[i] := 0X; S.len := i; S.class := Name
  ELSIF ch = 22X THEN (*string*)
    Read(S, ch);
    WHILE (ch # 22X) & (ch >= " ") & (i # 31) DO S.s[i] := ch; INC(i); Read(S, ch) END;
    S.s[i] := 0X; S.len := i+1; Read(S, ch); S.class := String
  ELSE hex := FALSE;
    IF ch = "-" THEN neg := TRUE; Read(S, ch) ELSE neg := FALSE END ;
    IF ("0" <= ch) & (ch <= "9") THEN (*number*)
      n := ORD(ch) - 30H; h := n; Read(S, ch);
      WHILE ("0" <= ch) & (ch <= "9") OR ("A" <= ch) & (ch <= "F") DO
        IF ch <= "9" THEN d := ORD(ch) - 30H ELSE d := ORD(ch) - 37H; hex := TRUE END ;
        n := 10*n + d; h := 10H*h + d; Read(S, ch)
      END ;
      IF ch = "H" THEN (*hex integer*) Read(S, ch); S.i := h; S.class := Int  (*neg?*)
      ELSIF ch = "." THEN (*real number*)
        Read(S, ch); x := 0.0; e := 0; j := 0;
        WHILE ("0" <= ch) & (ch <= "9") DO  (*fraction*)
          h := 10*n + (ORD(ch) - 30H);
          IF h < maxM THEN n := h; INC(j) END ;
          Read(S, ch)
        END ;
        IF ch = "E" THEN (*scale factor*)
          s := 0; Read(S, ch);
          IF ch = "-" THEN negE := TRUE; Read(S, ch)
          ELSE negE := FALSE;
            IF ch = "+" THEN Read(S, ch) END
          END ;
          WHILE ("0" <= ch) & (ch <= "9") DO
            s := s*10 + ORD(ch) - 30H; Read(S, ch)
          END ;
          IF negE THEN DEC(e, s) ELSE INC(e, s) END ;
        END ;
        x := FLT(n); DEC(e, j);
        IF e < 0 THEN
          IF e >= -maxExp THEN x := x / Ten(-e) ELSE x := 0.0 END
        ELSIF e > 0 THEN
          IF e <= maxExp THEN x := Ten(e) * x ELSE x := 0.0 END
        END ;
        IF neg THEN S.x := -x ELSE S.x := x END ;
        IF hex THEN S.class := 0 ELSE S.class := Real END
      ELSE (*decimal integer*)
        IF neg THEN S.i := -n ELSE S.i := n END;
        IF hex THEN S.class := Inval ELSE S.class := Int END
      END
    ELSE (*spectal character*) S.class := Char;
      IF neg THEN S.c := "-" ELSE S.c := ch; Read(S, ch) END
    END
  END ;
  S.nextCh := ch
END Scan;

END Scanner.
