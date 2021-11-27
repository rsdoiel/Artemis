MODULE Types;

IMPORT Strings;

CONST BUFSIZE* = 256;

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

(* IntShiftRight converts the input integer to a real, multiplies by 0.1
   and converts by to an integer. The value in the ones column is record
   in the VAR parameter r.  E.g. IntShiftRight(123) return 12, r is set to 3. *)
PROCEDURE IntShiftRight*(x : INTEGER; VAR r : INTEGER) : INTEGER;
  VAR i : INTEGER; isNeg : BOOLEAN;
BEGIN
  isNeg := (x < 0);
  i := FLOOR(FLT(ABS(x)) * 0.1);
  r := ABS(x) - (i * 10);
  IF isNeg THEN
    i := i * (-1);
  END;
  RETURN i
END IntShiftRight;

(* IntShiftLeft multiples input value by 10 and adds y. E.g. IntShiftLeft(123, 4) retrurn 1234 *)
PROCEDURE IntShiftLeft*(x, y : INTEGER) : INTEGER;
  VAR i : INTEGER; isNeg : BOOLEAN;
BEGIN
  isNeg := (x < 0);
  i := (ABS(x) * 10) + y;
  IF isNeg THEN
    i := i * (-1);
  END;
  RETURN i
END IntShiftLeft;

(* Itoa converts an INTEGER to an ASCII string setting ok boolean to
   TRUE if value ARRAY OF CHAR holds the full integer, FALSE if
   value was too small to hold the integer value.  *)
PROCEDURE Itoa*(x : INTEGER; VAR value : ARRAY OF CHAR; ok : BOOLEAN);
  VAR i, j, k, l, minL : INTEGER; tmp : ARRAY BUFSIZE OF CHAR; isNeg : BOOLEAN;
BEGIN
  i := 0; j := 0; k := 0; l := LEN(value); isNeg := (x < 0);
  IF isNeg THEN
    (* minimum string length for value is 3, negitive sign, digit and 0X *)
    minL := 3;
  ELSE 
    (* minimum string length for value is 2, one digit and 0X *)
    minL := 2; 
  END;
  ok := (l >= minL) & (LEN(value) >= LEN(tmp));
  IF ok THEN
    IF IsIntDigit(ABS(x)) THEN
      IF isNeg THEN
         value[i] := "-"; INC(i);
      END;
      value[i] := DigitToChar(ABS(x), ok); INC(i); value[i] := 0X;
    ELSE
      x := ABS(x); (* We need to work with the absolute value of x *)
      i := 0; tmp[i] := 0X;
      WHILE (x >= 10) & ok DO
        (* extract the ones columns *)
        x := IntShiftRight(x, k); (* a holds the shifted value, "k" holds the ones column value shifted out. *)
        (* write append k to our temp array holding values in reverser number magnitude *)
        tmp[i] := DigitToChar(k, ok); INC(i); tmp[i] := 0X;
      END;
      (* We now can convert the remaining "ones" column. *)
      tmp[i] := DigitToChar(x, ok); INC(i); tmp[i] := 0X;
      IF ok THEN
        (* now reverse the order of tmp string append each character to value *)
        i := 0; j := Strings.Length(tmp) - 2;
        IF isNeg THEN
          value[i] := "-"; INC(i);
        END;
        j := Strings.Length(tmp) - 1;
        WHILE (j > -1) DO
          value[i]:= tmp[j]; 
          INC(i); DEC(j);
          value[i] := 0X;
        END;
        value[i] := 0X;
      END;
    END; 
  ELSE
    ok := FALSE;
  END;
END Itoa;

(* magnitude takes x and multiplies it be 10^y, If y is positive zeros
   are appended io the right side (i.e. multied by 10). If y is negative
   then the result is shifted left (ie. multied by 0.1 via 
   IntShiftRight().).  The digit(s) shift to the fractional
   side of the decimal are ignored. *)
PROCEDURE magnitude(x, y : INTEGER) : INTEGER;
  VAR z, w : INTEGER;
BEGIN
  z := 1;
  IF y >= 0 THEN
    WHILE y > 0 DO
      z := IntShiftLeft(z, 0);
      DEC(y);
    END;
  ELSE
    WHILE y < 0 DO
      x := IntShiftRight(x, w);
      INC(y);
    END;
  END;
  RETURN (x * z)
END magnitude;

(* Atoi converts an ASCII string to a signed integer value
   setting the ok boolean to TRUE on success and FALSE on error. *)
PROCEDURE Atoi*(source : ARRAY OF CHAR; VAR value : INTEGER; VAR ok : BOOLEAN);
  VAR i, l, a, m: INTEGER; isNeg : BOOLEAN;
BEGIN
  (* "i" is the current CHAR pos we're analyzing, "l" is the
     length of our string, "a" holds the accumulated value,
     "m" holds the current magnitude we're working with *)
  i := 0; l := Strings.Length(source);
  a := 0; m := l - 1; isNeg := FALSE; ok := TRUE;
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

(* SplitRead splits a real value into th boolean isNeg the whole number
   portion w and the fractional part f (as an integer value), m is the 
   power of 10 it was shifted to make f a whole number.
   E.g. SplitReal(1.0123, w, f, m) then w would be 1, f would be
   123 and m would be -5 where (w + (f * 10^(-5)) would equal r. *)
PROCEDURE SplitReal*(r : REAL; VAR isNeg: BOOLEAN; VAR w, f, m : INTEGER);
BEGIN
  Out.String("DEBUG r: ");Out.Real(r, 1); 
  isNeg := (r < 0.0); w := 0; f := 0; m := 0;
  r := ABS(r);
  w := FLOOR(r);
  r := r - FLT(w);
  WHILE r > 0.1 DO
   r := r * 10.0; INC(m);
   f := IntShiftLeft(f, FLOOR(r));
   r := r - FLT(f);
  END;
  IF m > 0 THEN
    m := m * (-1);
  END;
  Out.String(", w: ");Out.Int(w, 1); Out.String(", f: ");Out.Int(f, 1); Out.String(", m: ");Out.Int(m, 1); Out.Ln; (* DEBUG *)
END SplitReal;

(* Rtoa converts a REAL to an ASCII string setting ok boolean to
   TRUE if value ARRAY OF CHAR holds the full REAL, FALSE if
   value was too small to hold the REAL value. E.g. Rtoa(1.2, s, ok)
   then s should hold "1.2" *)
PROCEDURE Rtoa*(source : REAL; VAR value : ARRAY OF CHAR; ok : BOOLEAN);
  VAR w, f, m, i, offset, minL : INTEGER; isNeg : BOOLEAN; buf1, buf2 : ARRAY 256 OF CHAR;
BEGIN
  SplitReal(source, isNeg, w, f, m);
  IF isNeg THEN
    (* minL is "-" + "0.0" + 0X *)
    minL := 5;
    source := ABS(source);
  ELSE
    (* minL "0.0" + 0X *)
    minL := 4;
  END;
  ok := LEN(value) >= minL;
  Itoa(w, buf1, ok);
  IF ok THEN
    Itoa(f, buf2, ok);
    IF isNeg THEN
      (* minL is "-" + buf1 + "." + buf2 + 0X *)
      minL := Strings.Length(buf1) + Strings.Length(buf2) + 3;
    ELSE
      (* minL is buf1 + "." + buf2 + 0X *)
      minL := Strings.Length(buf1) + Strings.Length(buf2) + 2;
    END;      
    ok := ok & (LEN(value) > minL);
    IF ok THEN
      i := 0;
      IF isNeg THEN
        value[i] := "-";INC(i); value[i] := 0X;
      END;
      offset := i;
      i := 0;
      WHILE i < Strings.Length(buf1) DO
        value[offset] := buf1[i]; 
        INC(offset); INC(i); 
        value[offset] := 0X;
      END;
      value[offset] := "."; INC(offset); value[offset] := 0X;
      (* Figure out how mean zero we need to pad. *)
      i := ABS(Strings.Length(buf2) + m);
      (* Add the padding *)
      WHILE i > 0 DO
        value[offset] := "0"; INC(offset); value[offset] := 0X;
        DEC(i);
      END;
      i := 0;
      WHILE i < Strings.Length(buf2) DO
        value[offset] := buf2[i]; 
        INC(offset); INC(i); 
        value[offset] := 0X;
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
