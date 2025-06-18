(** CRC32Test.Mod - Tests for CRC32.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)
MODULE CRC32Test;
IMPORT CRC32, Tests, Files;

(* 
 * Validation checksums were generated with the python3 zlib module:
 * echo -n "The quick brown fox jumps over the lazy dog" | python3 -c "import sys, zlib; print(f'{zlib.crc32(sys.stdin.buffer.read()) & 0xFFFFFFFF:x}')"
 *)

VAR
  ts: Tests.TestSet;

PROCEDURE TestStringCalculations*(): BOOLEAN;
VAR
  pass: BOOLEAN;
  result: INTEGER;
BEGIN
  pass := TRUE;
  
  (* Test CRC32 for empty string - expected: 0 *)
  result := CRC32.CalculateString("");
  Tests.ExpectedInt(0, result, "CRC32 for empty string incorrect", pass);
  
  (* Test CRC32 for single char - expected: 0E8B7BE43H *)
  result := CRC32.CalculateString("a");
  Tests.ExpectedInt(0E8B7BE43H, result, "CRC32 for 'a' incorrect", pass);
  
  (* Test CRC32 for short string - expected: 0352441C2H *)
  result := CRC32.CalculateString("abc");
  Tests.ExpectedInt(0352441C2H, result, "CRC32 for 'abc' incorrect", pass);
  
  (* Test CRC32 for longer string - expected: 0414FA339H *)
  result := CRC32.CalculateString("The quick brown fox jumps over the lazy dog");
  Tests.ExpectedInt(0414FA339H, result, "CRC32 for pangram incorrect", pass);
  
  RETURN pass
END TestStringCalculations;

PROCEDURE TestCalculatorWorkflow*(): BOOLEAN;
VAR
  pass: BOOLEAN;
  calc: CRC32.Calculator;
  buffer: ARRAY 5 OF BYTE;
  result, directResult: INTEGER;
BEGIN
  pass := TRUE;
  
  (* Test Calculator interface with UpdateByte *)
  calc := CRC32.NewCalculator();
  CRC32.Init(calc);
  CRC32.UpdateByte(calc, ORD("a"));
  CRC32.UpdateByte(calc, ORD("b"));
  CRC32.UpdateByte(calc, ORD("c"));
  result := CRC32.Finalize(calc);
  
  directResult := CRC32.CalculateString("abc");
  Tests.ExpectedInt(directResult, result, "Calculator incremental mismatch", pass);
  
  (* Test UpdateBuffer vs individual UpdateByte calls *)
  buffer[0] := ORD("a");
  buffer[1] := ORD("b");
  buffer[2] := ORD("c");
  
  calc := CRC32.NewCalculator();
  CRC32.Init(calc);
  CRC32.UpdateBuffer(calc, buffer, 3);
  result := CRC32.Finalize(calc);
  
  Tests.ExpectedInt(directResult, result, "UpdateBuffer calculation mismatch", pass);
  
  RETURN pass
END TestCalculatorWorkflow;

PROCEDURE TestToString*(): BOOLEAN;
VAR
  pass: BOOLEAN;
  hexStr: ARRAY 16 OF CHAR;
  expected: ARRAY 16 OF CHAR;
BEGIN
  pass := TRUE;
  
  (* Test ToString conversion *)
  CRC32.ToString(0E8B7BE43H, hexStr);
  expected := "e8b7be43";
  Tests.ExpectedString(expected, hexStr, "CRC32.ToString incorrect", pass);
  
  (* Test ToString with zero *)
  CRC32.ToString(0, hexStr);
  expected := "00000000";
  Tests.ExpectedString(expected, hexStr, "CRC32.ToString for zero incorrect", pass);
  
  RETURN pass
END TestToString;

PROCEDURE TestBinaryData*(): BOOLEAN;
VAR
  pass: BOOLEAN;
  calc: CRC32.Calculator;
  buffer: ARRAY 5 OF BYTE;
  result: INTEGER;
BEGIN
  pass := TRUE;
  
  (* Test with binary data: 00 01 02 03 FF *)
  buffer[0] := 0;
  buffer[1] := 1;
  buffer[2] := 2;
  buffer[3] := 3;
  buffer[4] := 255;
  
  calc := CRC32.NewCalculator();
  CRC32.Init(calc);
  CRC32.UpdateBuffer(calc, buffer, 5);
  result := CRC32.Finalize(calc);
  
  (* Expected: 07B35F858H *)
  Tests.ExpectedInt(07B35F858H, result, "CRC32 for binary data incorrect", pass);
  
  RETURN pass
END TestBinaryData;

(* Helper to create a test file with given content *)
PROCEDURE CreateTestFile(content: ARRAY OF CHAR; filename: ARRAY OF CHAR; VAR file: Files.File);
VAR writer: Files.Rider; i: INTEGER;
BEGIN
    file := Files.New(filename);
    Files.Set(writer, file, 0);
    i := 0;
    WHILE (i < LEN(content)) & (content[i] # 0X) DO
        Files.Write(writer, ORD(content[i]));
        INC(i)
    END;
    Files.Register(file)
END CreateTestFile;

PROCEDURE TestFileOperations*(): BOOLEAN;
VAR
  pass: BOOLEAN;
  file: Files.File;
  rider: Files.Rider;
  checksum: INTEGER;
  success: BOOLEAN;
  res: INTEGER;
  content: ARRAY 64 OF CHAR;
BEGIN
  pass := TRUE;
  
  (* Test basic file calculation *)
  content := "abc";
  CreateTestFile(content, "test_crc.tmp", file);
  Files.Close(file);
  
  CRC32.CalculateFile("test_crc.tmp", checksum, success);
  Tests.ExpectedBool(TRUE, success, "CalculateFile should succeed", pass);
  Tests.ExpectedInt(0352441C2H, checksum, "File CRC32 for 'abc' incorrect", pass);
  
  (* Test rider calculation on same file *)
  file := Files.Old("test_crc.tmp");
  Files.Set(rider, file, 0);
  CRC32.CalculateRider(rider, 3, checksum, success);
  Tests.ExpectedBool(TRUE, success, "CalculateRider should succeed", pass);
  Tests.ExpectedInt(0352441C2H, checksum, "Rider CRC32 should match file CRC32", pass);
  Files.Close(file);
  
  Files.Delete("test_crc.tmp", res);
  
  (* Test error handling - non-existent file *)
  CRC32.CalculateFile("nonexistent.tmp", checksum, success);
  Tests.ExpectedBool(FALSE, success, "CalculateFile should fail for non-existent file", pass);
  
  RETURN pass
END TestFileOperations;

(* Large file tests *)

(* Helper to create a large test file with repeating pattern *)
PROCEDURE CreateLargeTestFile(pattern: ARRAY OF CHAR; size: INTEGER; filename: ARRAY OF CHAR; VAR file: Files.File; VAR success: BOOLEAN);
VAR 
    writer: Files.Rider; 
    i, patternLen, patternIndex: INTEGER;
BEGIN
    success := FALSE;
    file := Files.New(filename);
    IF file # NIL THEN
        Files.Set(writer, file, 0);
        
        (* Find pattern length *)
        patternLen := 0;
        WHILE (patternLen < LEN(pattern)) & (pattern[patternLen] # 0X) DO
            INC(patternLen)
        END;
        
        IF patternLen > 0 THEN
            patternIndex := 0;
            FOR i := 0 TO size - 1 DO
                Files.Write(writer, ORD(pattern[patternIndex]));
                INC(patternIndex);
                IF patternIndex >= patternLen THEN
                    patternIndex := 0
                END
            END;
            Files.Register(file);
            success := TRUE
        END
    END
END CreateLargeTestFile;

(* Helper to clean up test file and ignore errors *)
PROCEDURE CleanupTestFile(filename: ARRAY OF CHAR);
VAR res: INTEGER;
BEGIN
    Files.Delete(filename, res)
    (* Ignore result - cleanup is best effort *)
END CleanupTestFile;

(** Test buffer boundary and large file processing *)
PROCEDURE TestLargeFileProcessing*(): BOOLEAN;
VAR
  pass: BOOLEAN;
  file: Files.File;
  checksum, expectedChecksum: INTEGER;
  success: BOOLEAN;
  calc: CRC32.Calculator;
  pattern: ARRAY 16 OF CHAR;
  i: INTEGER;
BEGIN
  pass := TRUE;
  pattern := "x";
  
  (* Test 1: File exactly at buffer boundary (65536 bytes) *)
  CreateLargeTestFile(pattern, 65536, "test_boundary.tmp", file, success);
  Files.Close(file);
  Tests.ExpectedBool(TRUE, success, "Boundary file creation should succeed", pass);
  
  IF success THEN
    CRC32.CalculateFile("test_boundary.tmp", checksum, success);
    Tests.ExpectedBool(TRUE, success, "Boundary file CRC32 calculation should succeed", pass);
    
    (* Verify by calculating expected checksum manually *)
    calc := CRC32.NewCalculator();
    CRC32.Init(calc);
    FOR i := 0 TO 65535 DO
      CRC32.UpdateByte(calc, ORD("x"))
    END;
    expectedChecksum := CRC32.Finalize(calc);
    
    Tests.ExpectedInt(expectedChecksum, checksum, "Boundary file CRC32 should match manual calculation", pass);
    CleanupTestFile("test_boundary.tmp")
  END;
  
  (* Test 2: File larger than buffer (requires multi-chunk processing) *)
  pattern := "0123456789abcde";
  CreateLargeTestFile(pattern, 100000, "test_large.tmp", file, success);
  Files.Close(file);
  Tests.ExpectedBool(TRUE, success, "Large file creation should succeed", pass);
  
  IF success THEN
    CRC32.CalculateFile("test_large.tmp", checksum, success);
    Tests.ExpectedBool(TRUE, success, "Large file CRC32 calculation should succeed", pass);
    
    (* Verify by calculating expected checksum manually *)
    calc := CRC32.NewCalculator();
    CRC32.Init(calc);
    FOR i := 0 TO 99999 DO
      CRC32.UpdateByte(calc, ORD(pattern[i MOD 15]))
    END;
    expectedChecksum := CRC32.Finalize(calc);
    
    Tests.ExpectedInt(expectedChecksum, checksum, "Large file CRC32 should match manual calculation", pass);
    CleanupTestFile("test_large.tmp")
  END;
  
  RETURN pass
END TestLargeFileProcessing;

(** Test consistency between different calculation methods *)
PROCEDURE TestMethodConsistency*(): BOOLEAN;
VAR
  pass: BOOLEAN;
  file: Files.File;
  rider: Files.Rider;
  fileChecksum, riderChecksum, stringChecksum: INTEGER;
  success: BOOLEAN;
  testData: ARRAY 1024 OF CHAR;
  i: INTEGER;
BEGIN
  pass := TRUE;
  
  (* Create test data - repeated pattern that fits in string *)
  FOR i := 0 TO 1022 DO
    testData[i] := CHR(ORD("A") + (i MOD 26))
  END;
  testData[1023] := 0X;
  
  (* Method 1: String calculation *)
  stringChecksum := CRC32.CalculateString(testData);
  
  (* Method 2: File calculation *)
  CreateTestFile(testData, "test_consistency.tmp", file);
  Files.Close(file);
  CRC32.CalculateFile("test_consistency.tmp", fileChecksum, success);
  Tests.ExpectedBool(TRUE, success, "Consistency file calculation should succeed", pass);
  
  (* Method 3: Rider calculation *)
  file := Files.Old("test_consistency.tmp");
  Files.Set(rider, file, 0);
  CRC32.CalculateRider(rider, 1023, riderChecksum, success);
  Tests.ExpectedBool(TRUE, success, "Consistency rider calculation should succeed", pass);
  Files.Close(file);
  
  (* All methods should produce same result *)
  Tests.ExpectedInt(stringChecksum, fileChecksum, "File method should match string method", pass);
  Tests.ExpectedInt(stringChecksum, riderChecksum, "Rider method should match string method", pass);
  
  CleanupTestFile("test_consistency.tmp");
  
  RETURN pass
END TestMethodConsistency;

(** Test empty file edge case *)
PROCEDURE TestEmptyFileProcessing*(): BOOLEAN;
VAR
  pass: BOOLEAN;
  file: Files.File;
  checksum: INTEGER;
  success: BOOLEAN;
BEGIN
  pass := TRUE;
  
  (* Create empty file *)
  file := Files.New("test_empty.tmp");
  Files.Register(file);
  Files.Close(file);
  
  (* Calculate CRC32 of empty file *)
  CRC32.CalculateFile("test_empty.tmp", checksum, success);
  Tests.ExpectedBool(TRUE, success, "Empty file calculation should succeed", pass);
  Tests.ExpectedInt(0, checksum, "Empty file CRC32 should be 0", pass);
  
  CleanupTestFile("test_empty.tmp");
  
  RETURN pass
END TestEmptyFileProcessing;

BEGIN
  Tests.Init(ts, "CRC32 Tests");
  Tests.Add(ts, TestStringCalculations);
  Tests.Add(ts, TestCalculatorWorkflow);
  Tests.Add(ts, TestToString);
  Tests.Add(ts, TestBinaryData);
  Tests.Add(ts, TestFileOperations);
  Tests.Add(ts, TestLargeFileProcessing);
  Tests.Add(ts, TestMethodConsistency);
  Tests.Add(ts, TestEmptyFileProcessing);
  ASSERT(Tests.Run(ts))
END CRC32Test.
