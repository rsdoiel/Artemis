(** Utf8Test.Mod - Tests for Utf8.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE Utf8Test;

IMPORT Utf8, Tests;

VAR
    ts: Tests.TestSet;

PROCEDURE TestCharLen*(): BOOLEAN;
VAR
    test: BOOLEAN;
BEGIN
    test := TRUE;
    
    Tests.ExpectedInt(1, Utf8.CharLen("A"), "CharLen('A') should be 1", test);
    Tests.ExpectedInt(2, Utf8.CharLen(CHR(0C2H)), "CharLen(0C2H) should be 2", test);
    Tests.ExpectedInt(3, Utf8.CharLen(CHR(0E0H)), "CharLen(0E0H) should be 3", test);
    Tests.ExpectedInt(4, Utf8.CharLen(CHR(0F0H)), "CharLen(0F0H) should be 4", test);
    Tests.ExpectedInt(0, Utf8.CharLen(CHR(0FFH)), "CharLen(0FFH) should be 0 (invalid)", test);
    
    RETURN test
END TestCharLen;

PROCEDURE TestHasBOM*(): BOOLEAN;
VAR
    buf: ARRAY 7 OF CHAR;
    test: BOOLEAN;
BEGIN
    test := TRUE;
    
    (* Valid: EF BB BF *)
    buf[0] := CHR(0EFH); buf[1] := CHR(0BBH); buf[2] := CHR(0BFH);
    Tests.ExpectedBool(TRUE, Utf8.HasBOM(buf, 3), "HasBOM should detect valid BOM", test);
    
    (* Too short *)
    Tests.ExpectedBool(FALSE, Utf8.HasBOM(buf, 2), "HasBOM should fail on short buffer", test);
    
    (* Valid, with extra data *)
    buf[3] := CHR(65);
    Tests.ExpectedBool(TRUE, Utf8.HasBOM(buf, 4), "HasBOM should detect valid BOM with extra data", test);
    
    (* Wrong BOM sequence *)
    buf[2] := CHR(0BCH);
    Tests.ExpectedBool(FALSE, Utf8.HasBOM(buf, 3), "HasBOM should fail on invalid BOM", test);
    
    (* ASCII: "ABC" *)
    buf[0] := CHR(65); buf[1] := CHR(66); buf[2] := CHR(67);
    Tests.ExpectedBool(FALSE, Utf8.HasBOM(buf, 3), "HasBOM should fail on ASCII", test);
    
    RETURN test
END TestHasBOM;

PROCEDURE TestIsValid*(): BOOLEAN;
VAR
    buf: ARRAY 7 OF CHAR;
    test: BOOLEAN;
BEGIN
    test := TRUE;
    
    (* Valid 1-byte ASCII *)
    buf[0] := CHR(65);
    Tests.ExpectedBool(TRUE, Utf8.IsValid(buf, 1), "IsValid should accept ASCII", test);
    
    (* Valid 2-byte UTF-8: U+00A2 (¢) = C2 A2 *)
    buf[0] := CHR(0C2H); buf[1] := CHR(0A2H);
    Tests.ExpectedBool(TRUE, Utf8.IsValid(buf, 2), "IsValid should accept 2-byte UTF-8", test);
    
    (* Valid 3-byte UTF-8: U+20AC (€) = E2 82 AC *)
    buf[0] := CHR(0E2H); buf[1] := CHR(082H); buf[2] := CHR(0ACH);
    Tests.ExpectedBool(TRUE, Utf8.IsValid(buf, 3), "IsValid should accept 3-byte UTF-8", test);
    
    (* Valid 4-byte UTF-8: U+1F600 (😀) = F0 9F 98 80 *)
    buf[0] := CHR(0F0H); buf[1] := CHR(09FH); buf[2] := CHR(098H); buf[3] := CHR(080H);
    Tests.ExpectedBool(TRUE, Utf8.IsValid(buf, 4), "IsValid should accept 4-byte UTF-8", test);
    
    (* Invalid: incomplete 2-byte sequence *)
    buf[0] := CHR(0C2H); buf[1] := CHR(0);
    Tests.ExpectedBool(FALSE, Utf8.IsValid(buf, 1), "IsValid should reject incomplete 2-byte", test);
    
    (* Invalid: overlong encoding for ASCII 'A' *)
    buf[0] := CHR(0C1H); buf[1] := CHR(0A1H); buf[2] := CHR(0);
    Tests.ExpectedBool(FALSE, Utf8.IsValid(buf, 2), "IsValid should reject overlong ASCII", test);
    
    (* Invalid: incomplete 3-byte sequence *)
    buf[0] := CHR(0E2H); buf[1] := CHR(082H); buf[2] := CHR(0);
    Tests.ExpectedBool(FALSE, Utf8.IsValid(buf, 2), "IsValid should reject incomplete 3-byte", test);
    
    (* Invalid: incomplete 4-byte sequence *)
    buf[0] := CHR(0F0H); buf[1] := CHR(09FH); buf[2] := CHR(098H); buf[3] := CHR(0);
    Tests.ExpectedBool(FALSE, Utf8.IsValid(buf, 3), "IsValid should reject incomplete 4-byte", test);
    
    (* Valid: mixed valid sequence *)
    buf[0] := CHR(65); (* 'A' *)
    buf[1] := CHR(0C2H); buf[2] := CHR(0A2H); (* ¢ *)
    buf[3] := CHR(0E2H); buf[4] := CHR(082H); buf[5] := CHR(0ACH); (* € *) 
    buf[6] := CHR(0);
    Tests.ExpectedBool(TRUE, Utf8.IsValid(buf, 6), "IsValid should accept mixed valid UTF-8", test);
    
    RETURN test
END TestIsValid;

PROCEDURE TestEncode*(): BOOLEAN;
VAR
    smallBuf: ARRAY 2 OF CHAR;
    buf: ARRAY 4 OF CHAR;
    bytesWritten: INTEGER;
    expected: ARRAY 4 OF CHAR;
    result, test: BOOLEAN;
BEGIN
    test := TRUE;
    
    (* 1-byte ASCII: U+0041 'A' *)
    expected[0] := CHR(65);
    result := Utf8.Encode(65, buf, 0, bytesWritten);
    Tests.ExpectedBool(TRUE, result, "Encode ASCII should succeed", test);
    Tests.ExpectedInt(1, bytesWritten, "Encode ASCII byte count", test);
    IF result & (bytesWritten = 1) THEN
        Tests.ExpectedChar(expected[0], buf[0], "Encode ASCII output", test);
    END;
    
    (* 2-byte: U+00A2 (¢) = C2 A2 *)
    expected[0] := CHR(0C2H); expected[1] := CHR(0A2H);
    result := Utf8.Encode(162, buf, 0, bytesWritten);
    Tests.ExpectedBool(TRUE, result, "Encode U+00A2 should succeed", test);
    Tests.ExpectedInt(2, bytesWritten, "Encode U+00A2 byte count", test);
    IF result & (bytesWritten = 2) THEN
        Tests.ExpectedChar(expected[0], buf[0], "Encode U+00A2 output byte 1", test);
        Tests.ExpectedChar(expected[1], buf[1], "Encode U+00A2 output byte 2", test);
    END;
    
    (* 3-byte: U+20AC (€) = E2 82 AC *)
    expected[0] := CHR(0E2H); expected[1] := CHR(082H); expected[2] := CHR(0ACH);
    result := Utf8.Encode(8364, buf, 0, bytesWritten);
    Tests.ExpectedBool(TRUE, result, "Encode U+20AC should succeed", test);
    Tests.ExpectedInt(3, bytesWritten, "Encode U+20AC byte count", test);
    IF result & (bytesWritten = 3) THEN
        Tests.ExpectedChar(expected[0], buf[0], "Encode U+20AC output byte 1", test);
        Tests.ExpectedChar(expected[1], buf[1], "Encode U+20AC output byte 2", test);
        Tests.ExpectedChar(expected[2], buf[2], "Encode U+20AC output byte 3", test);
    END;
    
    (* 4-byte: U+1F600 (😀) = F0 9F 98 80 *)
    expected[0] := CHR(0F0H); expected[1] := CHR(09FH); expected[2] := CHR(098H); expected[3] := CHR(080H);
    result := Utf8.Encode(128512, buf, 0, bytesWritten);
    Tests.ExpectedBool(TRUE, result, "Encode U+1F600 should succeed", test);
    Tests.ExpectedInt(4, bytesWritten, "Encode U+1F600 byte count", test);
    IF result & (bytesWritten = 4) THEN
        Tests.ExpectedChar(expected[0], buf[0], "Encode U+1F600 output byte 1", test);
        Tests.ExpectedChar(expected[1], buf[1], "Encode U+1F600 output byte 2", test);
        Tests.ExpectedChar(expected[2], buf[2], "Encode U+1F600 output byte 3", test);
        Tests.ExpectedChar(expected[3], buf[3], "Encode U+1F600 output byte 4", test);
    END;
    
    (* Invalid: code point > U+10FFFF *)
    result := Utf8.Encode(1114112, buf, 0, bytesWritten);
    Tests.ExpectedBool(FALSE, result, "Encode invalid code point should fail", test);
    Tests.ExpectedInt(0, bytesWritten, "Encode invalid code point byte count", test);
    
    (* Invalid: buffer too small for 4-byte sequence *)
    result := Utf8.Encode(128512, smallBuf, 0, bytesWritten);
    Tests.ExpectedBool(FALSE, result, "Encode with small buffer should fail", test);
    Tests.ExpectedInt(0, bytesWritten, "Encode with small buffer byte count", test);
    
    RETURN test
END TestEncode;

PROCEDURE TestEncodeDecodeIntegration*(): BOOLEAN;
VAR
    buf: ARRAY 4 OF CHAR;
    bytesWritten, decoded: INTEGER;
    encodeResult, decodeResult, test: BOOLEAN;
BEGIN
    test := TRUE;
    
    (* ASCII: U+0041 'A' *)
    encodeResult := Utf8.Encode(65, buf, 0, bytesWritten);
    Tests.ExpectedBool(TRUE, encodeResult, "EncodeDecode: ASCII encode should succeed", test);
    IF encodeResult THEN
        decodeResult := Utf8.Decode(buf, 0, decoded);
        Tests.ExpectedBool(TRUE, decodeResult, "EncodeDecode: ASCII decode should succeed", test);
        Tests.ExpectedInt(65, decoded, "EncodeDecode: ASCII round trip", test);
    END;
    
    (* 2-byte: U+00A2 (¢) *)
    encodeResult := Utf8.Encode(162, buf, 0, bytesWritten);
    Tests.ExpectedBool(TRUE, encodeResult, "EncodeDecode: U+00A2 encode should succeed", test);
    IF encodeResult THEN
        decodeResult := Utf8.Decode(buf, 0, decoded);
        Tests.ExpectedBool(TRUE, decodeResult, "EncodeDecode: U+00A2 decode should succeed", test);
        Tests.ExpectedInt(162, decoded, "EncodeDecode: U+00A2 round trip", test);
    END;
    
    (* 3-byte: U+20AC (€) *)
    encodeResult := Utf8.Encode(8364, buf, 0, bytesWritten);
    Tests.ExpectedBool(TRUE, encodeResult, "EncodeDecode: U+20AC encode should succeed", test);
    IF encodeResult THEN
        decodeResult := Utf8.Decode(buf, 0, decoded);
        Tests.ExpectedBool(TRUE, decodeResult, "EncodeDecode: U+20AC decode should succeed", test);
        Tests.ExpectedInt(8364, decoded, "EncodeDecode: U+20AC round trip", test);
    END;
    
    (* 4-byte: U+1F600 (😀) *)
    encodeResult := Utf8.Encode(128512, buf, 0, bytesWritten);
    Tests.ExpectedBool(TRUE, encodeResult, "EncodeDecode: U+1F600 encode should succeed", test);
    IF encodeResult THEN
        decodeResult := Utf8.Decode(buf, 0, decoded);
        Tests.ExpectedBool(TRUE, decodeResult, "EncodeDecode: U+1F600 decode should succeed", test);
        Tests.ExpectedInt(128512, decoded, "EncodeDecode: U+1F600 round trip", test);
    END;
    
    (* Invalid: code point > U+10FFFF *)
    encodeResult := Utf8.Encode(1114112, buf, 0, bytesWritten);
    Tests.ExpectedBool(FALSE, encodeResult, "EncodeDecode: Invalid encode should fail", test);
    
    RETURN test
END TestEncodeDecodeIntegration;

PROCEDURE TestNextChar*(): BOOLEAN;
VAR
    buf: ARRAY 8 OF CHAR;
    idx, codePoint: INTEGER;
    result, test: BOOLEAN;
BEGIN
    test := TRUE;
    
    (* ASCII: "A" *)
    buf[0] := CHR(65);
    idx := 0;
    result := Utf8.NextChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "NextChar: ASCII should succeed", test);
    Tests.ExpectedInt(65, codePoint, "NextChar: ASCII codepoint", test);
    Tests.ExpectedInt(1, idx, "NextChar: ASCII next index", test);
    
    (* 2-byte: U+00A2 (¢) = C2 A2 *)
    buf[0] := CHR(0C2H); buf[1] := CHR(0A2H);
    idx := 0;
    result := Utf8.NextChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "NextChar: 2-byte should succeed", test);
    Tests.ExpectedInt(162, codePoint, "NextChar: 2-byte codepoint", test);
    Tests.ExpectedInt(2, idx, "NextChar: 2-byte next index", test);
    
    (* 3-byte: U+20AC (€) = E2 82 AC *)
    buf[0] := CHR(0E2H); buf[1] := CHR(082H); buf[2] := CHR(0ACH);
    idx := 0;
    result := Utf8.NextChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "NextChar: 3-byte should succeed", test);
    Tests.ExpectedInt(8364, codePoint, "NextChar: 3-byte codepoint", test);
    Tests.ExpectedInt(3, idx, "NextChar: 3-byte next index", test);
    
    (* 4-byte: U+1F600 (😀) = F0 9F 98 80 *)
    buf[0] := CHR(0F0H); buf[1] := CHR(09FH); buf[2] := CHR(098H); buf[3] := CHR(080H);
    idx := 0;
    result := Utf8.NextChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "NextChar: 4-byte should succeed", test);
    Tests.ExpectedInt(128512, codePoint, "NextChar: 4-byte codepoint", test);
    Tests.ExpectedInt(4, idx, "NextChar: 4-byte next index", test);
    
    (* Mixed: "A" + "¢" + "€" + partial "😀" *)
    buf[0] := CHR(65); (* 'A' *)
    buf[1] := CHR(0C2H); buf[2] := CHR(0A2H); (* ¢ *)
    buf[3] := CHR(0E2H); buf[4] := CHR(082H); buf[5] := CHR(0ACH); (* € *)
    buf[6] := CHR(0F0H); buf[7] := CHR(09FH); (* partial 4-byte *)
    
    idx := 0;
    result := Utf8.NextChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "NextChar: Mixed ASCII should succeed", test);
    Tests.ExpectedInt(65, codePoint, "NextChar: Mixed ASCII codepoint", test);
    Tests.ExpectedInt(1, idx, "NextChar: Mixed ASCII next index", test);
    
    result := Utf8.NextChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "NextChar: Mixed 2-byte should succeed", test);
    Tests.ExpectedInt(162, codePoint, "NextChar: Mixed 2-byte codepoint", test);
    Tests.ExpectedInt(3, idx, "NextChar: Mixed 2-byte next index", test);
    
    result := Utf8.NextChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "NextChar: Mixed 3-byte should succeed", test);
    Tests.ExpectedInt(8364, codePoint, "NextChar: Mixed 3-byte codepoint", test);
    Tests.ExpectedInt(6, idx, "NextChar: Mixed 3-byte next index", test);
    
    result := Utf8.NextChar(buf, idx, codePoint);
    Tests.ExpectedBool(FALSE, result, "NextChar: Mixed incomplete 4-byte should fail", test);
    Tests.ExpectedInt(6, idx, "NextChar: Mixed incomplete 4-byte index unchanged", test);
    
    (* Invalid: start at end of buffer *)
    idx := 8;
    result := Utf8.NextChar(buf, idx, codePoint);
    Tests.ExpectedBool(FALSE, result, "NextChar: End of buffer should fail", test);
    Tests.ExpectedInt(8, idx, "NextChar: End of buffer index unchanged", test);
    
    (* Invalid: bad first byte *)
    buf[0] := CHR(0FFH);
    idx := 0;
    result := Utf8.NextChar(buf, idx, codePoint);
    Tests.ExpectedBool(FALSE, result, "NextChar: Invalid first byte should fail", test);
    Tests.ExpectedInt(0, idx, "NextChar: Invalid first byte index unchanged", test);
    
    RETURN test
END TestNextChar;

PROCEDURE TestPrevChar*(): BOOLEAN;
VAR
    buf: ARRAY 8 OF CHAR;
    idx, codePoint: INTEGER;
    result, test: BOOLEAN;
BEGIN
    test := TRUE;
    
    (* ASCII: "A" *)
    buf[0] := CHR(65);
    idx := 1;
    result := Utf8.PrevChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "PrevChar: ASCII should succeed", test);
    Tests.ExpectedInt(65, codePoint, "PrevChar: ASCII codepoint", test);
    Tests.ExpectedInt(0, idx, "PrevChar: ASCII prev index", test);
    
    (* 2-byte: U+00A2 (¢) = C2 A2 *)
    buf[0] := CHR(0C2H); buf[1] := CHR(0A2H);
    idx := 2;
    result := Utf8.PrevChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "PrevChar: 2-byte should succeed", test);
    Tests.ExpectedInt(162, codePoint, "PrevChar: 2-byte codepoint", test);
    Tests.ExpectedInt(0, idx, "PrevChar: 2-byte prev index", test);
    
    (* 3-byte: U+20AC (€) = E2 82 AC *)
    buf[0] := CHR(0E2H); buf[1] := CHR(082H); buf[2] := CHR(0ACH);
    idx := 3;
    result := Utf8.PrevChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "PrevChar: 3-byte should succeed", test);
    Tests.ExpectedInt(8364, codePoint, "PrevChar: 3-byte codepoint", test);
    Tests.ExpectedInt(0, idx, "PrevChar: 3-byte prev index", test);
    
    (* 4-byte: U+1F600 (😀) = F0 9F 98 80 *)
    buf[0] := CHR(0F0H); buf[1] := CHR(09FH); buf[2] := CHR(098H); buf[3] := CHR(080H);
    idx := 4;
    result := Utf8.PrevChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "PrevChar: 4-byte should succeed", test);
    Tests.ExpectedInt(128512, codePoint, "PrevChar: 4-byte codepoint", test);
    Tests.ExpectedInt(0, idx, "PrevChar: 4-byte prev index", test);
    
    (* Mixed: "A" + "¢" + "€" + partial "😀" *)
    buf[0] := CHR(65); (* 'A' *)
    buf[1] := CHR(0C2H); buf[2] := CHR(0A2H); (* ¢ *)
    buf[3] := CHR(0E2H); buf[4] := CHR(082H); buf[5] := CHR(0ACH); (* € *)
    buf[6] := CHR(0F0H); buf[7] := CHR(09FH); (* partial 4-byte *)
    
    idx := 6;
    result := Utf8.PrevChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "PrevChar: Mixed 3-byte should succeed", test);
    Tests.ExpectedInt(8364, codePoint, "PrevChar: Mixed 3-byte codepoint", test);
    Tests.ExpectedInt(3, idx, "PrevChar: Mixed 3-byte prev index", test);
    
    result := Utf8.PrevChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "PrevChar: Mixed 2-byte should succeed", test);
    Tests.ExpectedInt(162, codePoint, "PrevChar: Mixed 2-byte codepoint", test);
    Tests.ExpectedInt(1, idx, "PrevChar: Mixed 2-byte prev index", test);
    
    result := Utf8.PrevChar(buf, idx, codePoint);
    Tests.ExpectedBool(TRUE, result, "PrevChar: Mixed ASCII should succeed", test);
    Tests.ExpectedInt(65, codePoint, "PrevChar: Mixed ASCII codepoint", test);
    Tests.ExpectedInt(0, idx, "PrevChar: Mixed ASCII prev index", test);
    
    (* Invalid: at start of buffer *)
    idx := 0;
    result := Utf8.PrevChar(buf, idx, codePoint);
    Tests.ExpectedBool(FALSE, result, "PrevChar: At start should fail", test);
    Tests.ExpectedInt(0, idx, "PrevChar: At start index unchanged", test);
    
    (* Invalid: bad start byte *)
    buf[0] := CHR(0FFH);
    idx := 1;
    result := Utf8.PrevChar(buf, idx, codePoint);
    Tests.ExpectedBool(FALSE, result, "PrevChar: Invalid start byte should fail", test);
    Tests.ExpectedInt(1, idx, "PrevChar: Invalid start byte index unchanged", test);
    
    RETURN test
END TestPrevChar;

BEGIN
    Tests.Init(ts, "UTF-8 Tests");
    Tests.Add(ts, TestCharLen);
    Tests.Add(ts, TestHasBOM);
    Tests.Add(ts, TestIsValid);
    Tests.Add(ts, TestEncode);
    Tests.Add(ts, TestEncodeDecodeIntegration);
    Tests.Add(ts, TestNextChar);
    Tests.Add(ts, TestPrevChar);
    ASSERT(Tests.Run(ts));
END Utf8Test.