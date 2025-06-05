MODULE Utf8;

(** This module implements UTF-8 encoding and utility procedures.
    For direct string manipulation, use the Utf8String module.
 *)

IMPORT SYSTEM, Bitwise;

CONST 
  Bom0 = CHR(0EFH);
  Bom1 = CHR(0BBH);
  Bom2 = CHR(0BFH);

  Mask1B = 080H; (* 0b10000000*)
  Mask2B = 0E0H; (* 0b11100000*)
  Mask3B = 0F0H; (* 0b11110000*)
  Mask4B = 0F8H; (* 0b11111000*)

(** Determine the length of a UTF-8 character based on the first byte 
 Returns the number of bytes in a UTF-8 character starting with firstByte 
 Returns 0 for an invalid byte sequence. *)
PROCEDURE CharLen*(firstByte: CHAR): INTEGER;
VAR
  b : BYTE;
  result : INTEGER;
BEGIN
  b := SYSTEM.VAL(BYTE, firstByte);
  IF Bitwise.And8(b, Mask1B) = 0 THEN result := 1;
  ELSIF Bitwise.And8(b, Mask2B) = 0C0H THEN result := 2;
  ELSIF Bitwise.And8(b, Mask3B) = 0E0H THEN result := 3;
  ELSIF Bitwise.And8(b, Mask4B) = 0F0H THEN result := 4;
  ELSE result := 0; END;
  RETURN result
END CharLen;

(* Test if the passed character is a valid continuation byte. *)
PROCEDURE IsInvalidContinuationByte(c : CHAR) : BOOLEAN;
BEGIN
  RETURN (Bitwise.And8(SYSTEM.VAL(BYTE, c), 0C0H) # 080H)
END IsInvalidContinuationByte;

(* Test if passed buffer contains a valid 2-bytes sequence *)
PROCEDURE IsValid2ByteSequence(buf: ARRAY OF CHAR; i: INTEGER): BOOLEAN;
VAR 
  result: BOOLEAN;
BEGIN
  result := TRUE;
  IF IsInvalidContinuationByte(buf[i + 1]) THEN
    result := FALSE;
  ELSIF (buf[i] = CHR(0C0H)) OR (buf[i] = CHR(0C1H)) THEN
    result := FALSE;
  END;
  RETURN result
END IsValid2ByteSequence;

(* Test if passed buffer contains a valid 3-bytes sequence *)
PROCEDURE IsValid3ByteSequence(buf: ARRAY OF CHAR; i: INTEGER): BOOLEAN;
VAR 
  result: BOOLEAN;
BEGIN
  result := TRUE;
  IF IsInvalidContinuationByte(buf[i + 1]) OR
     IsInvalidContinuationByte(buf[i + 2]) THEN
    result := FALSE;
  ELSIF ((buf[i] = CHR(0E0H)) & (buf[i + 1] < CHR(0A0H))) THEN
    result := FALSE;
  ELSIF ((buf[i] = CHR(0EDH)) & (buf[i + 1] >= CHR(0A0H))) THEN
    result := FALSE;
  END;
  RETURN result
END IsValid3ByteSequence;

(* Test if passed buffer contains a valid 4-bytes sequence *)
PROCEDURE IsValid4ByteSequence(buf: ARRAY OF CHAR; i: INTEGER): BOOLEAN;
VAR 
  result: BOOLEAN;
BEGIN
  result := TRUE;
  IF IsInvalidContinuationByte(buf[i + 1]) OR 
     IsInvalidContinuationByte(buf[i + 2]) OR
     IsInvalidContinuationByte(buf[i + 3]) THEN
    result := FALSE;
  ELSIF ((buf[i] = CHR(0F0H)) & (buf[i + 1] < CHR(090H))) THEN
    result := FALSE;
  ELSIF ((buf[i] > CHR(0F4H)) OR ((buf[i] = CHR(0F4H)) & (buf[i + 1] > CHR(08FH)))) THEN
    result := FALSE;
  END;
  RETURN result
END IsValid4ByteSequence;

(** Returns TRUE if buf[0..len-1] is valid UTF-8 *)
PROCEDURE IsValid*(buf: ARRAY OF CHAR; len: INTEGER): BOOLEAN;
VAR 
  c : CHAR;
  i, expectedCharLen : INTEGER;
  result: BOOLEAN;
BEGIN
  result := TRUE;
  i := 0;
  WHILE (i < len) & (result) DO
    c := buf[i];
    expectedCharLen := CharLen(c);
    IF expectedCharLen = 0 THEN
      (*  Invalid first byte *)
      result := FALSE;
      (* Check if buf has enough bytes for the potential sequence *)
    ELSIF (i + expectedCharLen) > len THEN 
      result := FALSE;
    ELSE
      (* Validate the sequence based on its expected length *)
      CASE expectedCharLen OF
        1: INC(i, 1);
      | 2: IF IsValid2ByteSequence(buf, i) THEN
          INC(i, 2);
        ELSE
          result := FALSE;
        END;
      | 3: IF IsValid3ByteSequence(buf, i) THEN
          INC(i, 3);
        ELSE
          result := FALSE;
        END;
      | 4: IF IsValid4ByteSequence(buf, i) THEN
          INC(i, 4);
        ELSE
          result := FALSE;
        END;
      END;
    END;
  END;
  RETURN result
END IsValid;

(** Returns TRUE if buf starts with a UTF-8 BOM (EF BB BF), otherwise returns FALSE. *)
PROCEDURE HasBOM*(buf: ARRAY OF CHAR; len: INTEGER): BOOLEAN;
VAR 
  result: BOOLEAN;
BEGIN
  result := FALSE;
  IF len >= 3 THEN
      IF (buf[0] = Bom0) & 
         (buf[1] = Bom1) & 
         (buf[2] = Bom2) THEN
      result := TRUE;
    END;
  END;
  RETURN result
END HasBOM;

(** Converts a Unicode code point to UTF-8 and writes it to buf at buf[index].
    Returns TRUE if successful, FALSE if the code point is invalid or buf is too small. *)
PROCEDURE Encode*(codePoint: INTEGER; VAR buf: ARRAY OF CHAR; index: INTEGER; VAR bytesWritten: INTEGER): BOOLEAN;
VAR
  i: ARRAY 4 OF INTEGER;
  result: BOOLEAN;
BEGIN
  result := TRUE;
  IF codePoint <= 07FH THEN
    (* 1-byte ASCII *)
    IF LEN(buf) < index THEN 
      bytesWritten := 0;
      result := FALSE;
    ELSE
      buf[index] := CHR(codePoint);
      bytesWritten := 1;
    END;
  ELSIF codePoint <= 07FFH THEN
    (* 2-byte sequence *)
    IF LEN(buf) < index + 1 THEN 
      bytesWritten := 0;
      result := FALSE;
    ELSE
      i[0] := Bitwise.And(Bitwise.ShiftRight(codePoint, 6), 01FH);
      i[1] := Bitwise.And(codePoint, 03FH);
      buf[index] := CHR(Bitwise.Or8(SYSTEM.VAL(BYTE, i[0]), 0C0H));
      buf[index + 1] := CHR(Bitwise.Or8(SYSTEM.VAL(BYTE, i[1]), 080H));
      bytesWritten := 2;
    END;
  ELSIF codePoint <= 0FFFFH THEN
    (* 3-byte sequence *)
    IF LEN(buf) < index + 2 THEN 
      bytesWritten := 0; 
      result := FALSE;
    ELSE
      i[0] := Bitwise.And(Bitwise.ShiftRight(codePoint, 12), 0FH);
      i[1] := Bitwise.And(Bitwise.ShiftRight(codePoint, 6), 03FH);
      i[2] := Bitwise.And(codePoint, 03FH);
      buf[index] := CHR(Bitwise.Or8(SYSTEM.VAL(BYTE, i[0]), 0E0H));
      buf[index + 1] := CHR(Bitwise.Or8(SYSTEM.VAL(BYTE, i[1]), 080H));
      buf[index + 2] := CHR(Bitwise.Or8(SYSTEM.VAL(BYTE, i[2]), 080H));     
      bytesWritten := 3;
    END;

  ELSIF codePoint <= 10FFFFH THEN
    IF LEN(buf) < index + 3 THEN 
      bytesWritten := 0; 
      result := FALSE; 
    ELSE
      i[0] := Bitwise.And(Bitwise.ShiftRight(codePoint, 18), 07H);
      i[1] := Bitwise.And(Bitwise.ShiftRight(codePoint, 12), 03FH);
      i[2] := Bitwise.And(Bitwise.ShiftRight(codePoint, 6), 03FH);
      i[3] := Bitwise.And(codePoint, 03FH);
      buf[index] := CHR(Bitwise.Or8(SYSTEM.VAL(BYTE, i[0]), 0F0H));
      buf[index + 1] := CHR(Bitwise.Or8(SYSTEM.VAL(BYTE, i[1]), 080H));
      buf[index + 2] := CHR(Bitwise.Or8(SYSTEM.VAL(BYTE, i[2]), 080H));     
      buf[index + 3] := CHR(Bitwise.Or8(SYSTEM.VAL(BYTE, i[3]), 080H));  
      bytesWritten := 4;
    END;
  ELSE
    bytesWritten := 0;
    result := FALSE;
  END;

  RETURN result
END Encode;

(** Converts a byte array to an Unicode code point, starting the decode from buf[index]. 
    Returns TRUE on success, false if the byte sequence is invalid, or if the buffer 
    is too short to contain the potential data. *)
PROCEDURE Decode*(buf: ARRAY OF CHAR; index: INTEGER; VAR codePoint: INTEGER): BOOLEAN;
VAR
  i: ARRAY 4 OF INTEGER;
  len: INTEGER;
  result: BOOLEAN;
BEGIN
  result := TRUE;
  len := CharLen(buf[index]);

  (* Basic Validation *)
  IF (len = 0) OR (index + len > LEN(buf)) THEN
    result := FALSE;
  ELSE
    CASE len OF
      1: (* 1-byte ASCII, no additional validation needed *)
        codePoint := Bitwise.And8(SYSTEM.VAL(BYTE, buf[index]), 07FH);
    | 2: (* 2-byte sequence *)
        IF ~IsValid2ByteSequence(buf, index) THEN
          result := FALSE;
        ELSE
          i[0] := Bitwise.ShiftLeft(Bitwise.And8(SYSTEM.VAL(BYTE, buf[index]), 01FH), 6);
          i[1] := Bitwise.And8(SYSTEM.VAL(BYTE, buf[index+1]), 03FH);
          codePoint := Bitwise.Or(i[0], i[1]);
        END;
    | 3: (* 3-byte sequence *)
        IF ~IsValid3ByteSequence(buf, index) THEN
          result := FALSE;
        ELSE
          i[0] := Bitwise.ShiftLeft(Bitwise.And8(SYSTEM.VAL(BYTE, buf[index]), 0FH), 12);
          i[1] := Bitwise.ShiftLeft(Bitwise.And8(SYSTEM.VAL(BYTE, buf[index+1]), 03FH), 6);
          i[2] := Bitwise.And8(SYSTEM.VAL(BYTE, buf[index+2]), 03FH);
          codePoint := Bitwise.Or(Bitwise.Or(i[0], i[1]), i[2]);
        END;
    | 4: (* 4-byte sequence *)
        IF ~IsValid4ByteSequence(buf, index) THEN
          result := FALSE;
        ELSE
          i[0] := Bitwise.ShiftLeft(Bitwise.And8(SYSTEM.VAL(BYTE, buf[index]), 07H), 18);
          i[1] := Bitwise.ShiftLeft(Bitwise.And8(SYSTEM.VAL(BYTE, buf[index+1]), 03FH), 12);
          i[2] := Bitwise.ShiftLeft(Bitwise.And8(SYSTEM.VAL(BYTE, buf[index+2]), 03FH), 6);
          i[3] := Bitwise.And8(SYSTEM.VAL(BYTE, buf[index+3]), 03FH);
          codePoint := Bitwise.Or(Bitwise.Or(Bitwise.Or(i[0], i[1]), i[2]), i[3]);
        END;
    END;
  END;
  RETURN result
END Decode;

(** Reads the next UTF-8 character (code point) from a byte array, advances the index, and returns the code point. 
    Returns FALSE if the end of the array is reached or an invalid sequence is encountered. *)
PROCEDURE NextChar*(buf: ARRAY OF CHAR; VAR index: INTEGER; VAR codePoint: INTEGER): BOOLEAN;
VAR
  len: INTEGER;
  result: BOOLEAN;
BEGIN
  result := FALSE;
  (* Check for end of buffer *)
  IF (index < LEN(buf)) & Decode(buf, index, codePoint) THEN
    len := CharLen(buf[index]);
  (* Advance index by the length of the sequence *)
    INC(index, len);
    result := TRUE;
  END;
  
  RETURN result
END NextChar;

(** Reads the previous UTF-8 character (code point) from a byte array, retracts the index, and returns the code point. 
    Returns FALSE if the start of the array is reached or an invalid sequence is encountered. *)
PROCEDURE PrevChar*(buf: ARRAY OF CHAR; VAR index: INTEGER; VAR codePoint: INTEGER): BOOLEAN;
VAR
  start, i, len: INTEGER;
  result: BOOLEAN;
BEGIN
  result := FALSE;

  IF (index > 0) THEN
    start := index;
    i := start - 1;

    (* Move back to the first byte of the previous code point *)
    WHILE (i > 0) & (~IsInvalidContinuationByte(buf[i])) DO
      DEC(i);
    END;

    len := CharLen(buf[i]);
    IF len = 0 THEN
      (* Invalid start byte *)
    ELSIF (i + len > LEN(buf)) OR (i + len # start) THEN
      (* Incomplete or invalid sequence *)
    ELSIF ~Decode(buf, i, codePoint) THEN
      (* Decode failed *)
    ELSE
      index := i;
      result := TRUE;
    END;
  END;

  RETURN result
END PrevChar;

(** Copy a code point from src[srcIdx] to dst[destIdx]. *)
PROCEDURE CopyChar*(src: ARRAY OF CHAR; VAR srcIdx: INTEGER; VAR dest: ARRAY OF CHAR; VAR destIdx: INTEGER);
VAR
  len, i: INTEGER;
BEGIN
  len := CharLen(src[srcIdx]);
  FOR i := 0 TO len - 1 DO
    dest[destIdx] := src[srcIdx];
    INC(srcIdx); INC(destIdx);
  END;
END CopyChar;

(** Moves idx beyond the next codepoint in src. *)
PROCEDURE SkipChar*(src: ARRAY OF CHAR; VAR idx: INTEGER);
VAR len: INTEGER;
BEGIN
  len := CharLen(src[idx]);
  INC(idx, len);
END SkipChar;

END Utf8.