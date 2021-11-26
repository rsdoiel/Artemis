MODULE Types;

IMPORT Strings, Out;

CONST BUFSIZE = 256;

(* IsIntDigit checks if an INTEGER is in the range of 0 through 9 *)
PROCEDURE IsIntDigit*(i : INTEGER) : BOOLEAN;
BEGIN
  RETURN ((i >= 0) & (i <= 9))
END IsIntDigit;

(* IsCharDigit checks ch and returns TRUE if a digit ("0" .. "9" found)
   or FALSE if it is not a digit. *)
PROCEDURE IsCharDigit*(ch : CHAR) : BOOLEAN;
BEGIN
  RETURN ((ch >= "0") & (ch <= "9"))
END IsCharDigit;

(* IsDigitOrSign checks ch and returns TRUE if a digit ("0" .. "9" or
   "-" found) or FALSE if it is not a digit. *)
PROCEDURE IsDigitOrSign*(ch : CHAR) : BOOLEAN;
BEGIN 
  RETURN (IsCharDigit(ch) OR (ch = "-") OR (ch = "+"))
END IsDigitOrSign;

(* IsDigitSignOrPeriod check ch and returns TRUE if it is a digit,
   a minus sign or a period. It returns FALSE if not. *)
PROCEDURE IsDigitSignOrPeriod*(ch : CHAR) : BOOLEAN;
BEGIN
  RETURN (IsDigitOrSign(ch) OR (ch = "."))
END IsDigitSignOrPeriod;

(* CharToDigit converts an ASCII char representing an single digit to
   an integer value. *)
PROCEDURE CharToDigit*(ch : CHAR; VAR ok : BOOLEAN) : INTEGER;
BEGIN
  ok := IsCharDigit(ch);
  RETURN (ORD(ch) - ORD("0"))
END CharToDigit;

(* DigitToChar converts an INTEGER in range of 0 through 9 to a character *)
PROCEDURE DigitToChar*(i : INTEGER; VAR ok : BOOLEAN) : CHAR;
BEGIN
  ok := IsIntDigit(i);
  RETURN (CHR(ORD("0") + i))
END DigitToChar;

(* power10 returns the given power of ten for positive exponents. *)
PROCEDURE power10(exp : INTEGER) : INTEGER;
  VAR a, i : INTEGER;
BEGIN
  IF exp  < 1 THEN
    a := 1;
  ELSE
    a := 1; i := 1;
    WHILE i < exp DO
      a := a * 10;
      INC(i);
    END;
  END;
  RETURN a
END power10;

(* magnitude takes an integer value and magnitude and returns
   a adjusted integer. *)
PROCEDURE magnitude(i, m : INTEGER) : INTEGER;
BEGIN
  RETURN (i * power10(m))
END magnitude;

(* Itoa converts an INTEGER to an ASCII string setting ok boolean to
   TRUE if value ARRAY OF CHAR holds the full integer, FALSE if
   value was too small to hold the integer value.  *)
PROCEDURE Itoa*(source : INTEGER; VAR value : ARRAY OF CHAR; ok : BOOLEAN);
  VAR i, l, j, k : INTEGER; a, b : REAL; tmp : ARRAY 256 OF CHAR; isNeg : BOOLEAN;
BEGIN
  i := 0; j := 0; l := LEN(value) - 2; a := 0.0; b := 0.0; isNeg := FALSE;
  ok := TRUE;
  IF (l > 2) & (LEN(value) >= LEN(tmp))  THEN
    IF source < 0 THEN
      isNeg := TRUE;
    END;
    ok := TRUE;
    j := ABS(source);
    i := 0; tmp[i] := 0X;
    WHILE (j >= 10) & ok DO
      (* extract the ones columns *)
      a := FLT(j);
      b := a * 0.1;
      k := FLOOR(a - (b * 10.0));
      (* write this to a temp array in reverser number magnitude *)
      tmp[i] := DigitToChar(k, ok); INC(i); tmp[i] := 0X;
      (* Shift the decimal place right *)
      j := FLOOR(b);
    END;
    IF ok THEN
      (* handle the final magnitude *)
      tmp[i] := DigitToChar(j, ok); INC(i); tmp[i] := 0X;
      IF isNeg THEN
        tmp[i] := "-"; INC(i); tmp[i] := 0X;
      END;
      (* now reverse the order of tmp string append each character to value *)
      i := 0; j := Strings.Length(tmp) - 1;
      WHILE (j >= 0) DO
        value[i]:= tmp[j];
        INC(i); DEC(j);
      END;
      value[i] := 0X;
    END;
  ELSE
    ok := FALSE;
  END;
END Itoa;


(* Atoi converts an ASCII string to a signed integer value setting the ok boolean to TRUE on success and FALSE on error. *)
PROCEDURE Atoi*(source : ARRAY OF CHAR; VAR value : INTEGER; VAR ok : BOOLEAN);
  VAR i, l, a, m: INTEGER; isNeg : BOOLEAN;
BEGIN
  (* "i" is the current CHAR pos we're analyzing, "l" is the
     length of our string, "a" holds the accumulated value,
     "m" holds the current magnitude we're working with *)
  i := 0; l := Strings.Length(source);
  a := 0; m := l; isNeg := FALSE; ok := TRUE;
  (* Validate magnitude and sign behavior *)
  IF (l > 0) & (source[0] = "-") THEN
    INC(i); DEC(m);
    isNeg := TRUE;
  ELSIF (l > 0) & (source[0] = "+") THEN
    INC(i); DEC(m);
  END;

  (* The accumulator should always hold a positive integer, if the
     sign flips we have overflow, ok should be set to FALSE *)
  ok := TRUE;
  WHILE (i < l) & ok DO
    a := a + magnitude(CharToDigit(source[i], ok), m);
    IF a < 0 THEN
      ok := FALSE; (* we have an overflow condition *)
    END;
    DEC(m);
    INC(i);
  END;
  IF ok THEN
    IF (i = l) THEN
      IF isNeg THEN
        value := a * (-1);
      ELSE
        value := a;
      END;
    END;
  END;
END Atoi;

(* Rtoa converts a REAL to an ASCII string setting ok boolean to
   TRUE if value ARRAY OF CHAR holds the full REAL, FALSE if
   value was too small to hold the REAL value. The encoding uses
   exponential notation *)
PROCEDURE Rtoa*(source : REAL; VAR value : ARRAY OF CHAR; ok : BOOLEAN);
  VAR minL, l, w, i, offset : INTEGER; a, f : REAL; isNeg : BOOLEAN; buf1, buf2 : ARRAY 256 OF CHAR;
BEGIN
  l := LEN(value) - 1; (* know the size of our dest. string *)
  IF source >= 0.0 THEN
    isNeg := FALSE;
    (* We need a min length of 4 for value, 0.0 + 0X *)
    minL := 4;
  ELSE
    isNeg := TRUE;
    source := source * (-1.0);
    (* We need a min length of 5 for value, sign + 0.0 + 0X *)
    minL := 5;
  END;
  Out.String("DEBUG minL: ");Out.Int(minL, 1);Out.Ln;
  IF l < minL THEN
    ok := FALSE;
  END;
  IF ok THEN
    w :=  FLOOR(source); (* Whole number *)
    Itoa(w, buf1, ok);
    IF ok THEN
      (* We need a minimum length of Length(buf1) + minL *)
      minL := minL + Strings.Length(buf1);
      IF l < minL THEN
        ok := FALSE;
      END;
    END;
    Out.String("DEBUG source: ");Out.Real(source, 1);Out.String(", w: ");Out.Int(w, 1);Out.Ln;
    IF ok THEN
      a := FLT(w);         (* whole  number part, as REAL *)
      f := source - a;     (* fractional part, unshifted *)
      (* Shift b until it is a whole number *)
      a := f;
      WHILE (a > 0.0) & ok DO
        f := f * 10.0;  (* shift the fractional value *)
        a := f - FLT(FLOOR(f));
        INC(minL);
        IF l < minL THEN
          ok := FALSE;
        END;
      END;
    END;
    IF ok THEN
      IF f = 0.0 THEN
        buf2 := "0"; ok := TRUE;
      ELSE
        Itoa(FLOOR(f), buf2, ok);
      END;
      Out.String("DEBUG buf1: ");Out.String(buf1);Out.Ln;
      Out.String("DEBUG buf2: ");Out.String(buf2);Out.Ln;
      IF ok THEN
        (* At this point we should have enough room to copy the sign,
	   whole number, decimal and fractional part to value string *)
        offset := 0; i := 0;
        IF isNeg THEN
          value[i] := "-"; INC(i); value[i] := 0X;
          INC(offset);
        END;
        i := 0;
        WHILE (i < l) & (buf1[i] # 0X) DO
          value[i + offset] := buf1[i]; INC(i); value[i + offset] := 0X;
        END;
        offset := offset + i;
        value[offset] := "."; INC(offset); value[offset] := 0X;
        i := 0;
        WHILE (i < l) & (buf2[i] # 0X) DO
          value[i + offset] := buf2[i]; INC(i); value[i + offset] := 0X;
        END;
      END;
    END;
  END;
END Rtoa;

(* Ator converts an ASCII string to an REAL value setting the ok boolean to TRUE on successful conversion and FALSE on error. *)
PROCEDURE Ator*(source : ARRAY OF CHAR; VAR value : REAL; VAR ok : BOOLEAN);
  VAR i, l, start, w, a : INTEGER; f : REAL; isNeg : BOOLEAN; buf : ARRAY BUFSIZE OF CHAR;
BEGIN
  i := 0; l := Strings.Length(source);
  start := 0; w := 0; f := 0.0;
  isNeg := FALSE; ok := TRUE;
  (* Handle sign *)
  IF (l > 0) & (source[0] = "-") THEN
    INC(i);
    isNeg := TRUE;
  ELSIF (l > 0) & (source[0] = "+") THEN
    INC(i);
  END;
  (* Update the start position *)
  start := i;
  (* Scan for whole number value *)
  WHILE (i < l) & IsCharDigit(source[i]) DO
    INC(i);
  END;
  Strings.Extract(source, start, (i - 1), buf);
  Atoi(buf, a, ok);
  IF ok THEN
     (* Scan for fractional value *)
     start := 1;
     Strings.Extract(source, start, (l - 1), buf);
     Atoi(buf, i, ok);
     f := FLT(i);
  END;
  IF ok THEN
    (* Shift fractional part right until value is less than 1 *)
    WHILE (f >= 1.0) DO
      f := f * 0.1;
    END;
    (* put the whole and fractional part together and set value *)
    value := FLT(w) + f;
    IF isNeg THEN
      value := ABS(value) * (-1.0);
    END;
  END;
END Ator;


END Types.
