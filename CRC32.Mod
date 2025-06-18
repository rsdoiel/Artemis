(**
    CRC32.Mod - File and data checksumming utilities
    
    Provides streaming checksum calculation for large files and data.
    Uses the Files Rider pattern for memory-efficient processing.
    
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
    Author: Artemis Project
*)
MODULE CRC32;

IMPORT Files, Bitwise;

CONST
    (** CRC32 IEEE 802.3 polynomial, reversed *)
    CRC32_POLY = 0EDB88320H;
    
    (** Buffer size for file processing - 64KB chunks *)
    BUFFER_SIZE = 65536;

TYPE
    (** CRC32 calculator with state *)
    Calculator* = POINTER TO CalculatorDesc;
    CalculatorDesc* = RECORD
        state: INTEGER;
        initialized: BOOLEAN
    END;

VAR
    (* Pre-computed CRC32 lookup table *)
    crc32Table: ARRAY 256 OF INTEGER;
    tableInitialized: BOOLEAN;

(* Initialize CRC32 lookup table *)
PROCEDURE InitCRC32Table;
VAR i, j, crc: INTEGER;
BEGIN
    IF ~tableInitialized THEN
        FOR i := 0 TO 255 DO
            crc := i;
            FOR j := 0 TO 7 DO
                IF Bitwise.And(crc, 1) # 0 THEN
                    crc := Bitwise.Xor(Bitwise.LogicalShiftRight(crc, 1), CRC32_POLY)
                ELSE
                    crc := Bitwise.LogicalShiftRight(crc, 1)
                END
            END;
            crc32Table[i] := crc
        END;
        tableInitialized := TRUE
    END
END InitCRC32Table;

(** Create a new CRC32 calculator *)
PROCEDURE NewCalculator*(): Calculator;
VAR calc: Calculator;
BEGIN
    NEW(calc);
    calc.initialized := FALSE;
    calc.state := 0;
    RETURN calc
END NewCalculator;

(** Initialize calculator for new CRC32 calculation *)
PROCEDURE Init*(calc: Calculator);
BEGIN
    ASSERT(calc # NIL);
    InitCRC32Table;
    calc.state := 0FFFFFFFFH;
    calc.initialized := TRUE
END Init;

(** Update CRC32 with a single byte *)
PROCEDURE UpdateByte*(calc: Calculator; byte: INTEGER);
VAR tableIndex: INTEGER;
BEGIN
    ASSERT(calc # NIL);
    ASSERT(calc.initialized);
    
    tableIndex := Bitwise.And(Bitwise.Xor(calc.state, byte), 0FFH);
    calc.state := Bitwise.Xor(Bitwise.LogicalShiftRight(calc.state, 8), crc32Table[tableIndex])
END UpdateByte;

(** Update CRC32 with buffer of bytes *)
PROCEDURE UpdateBuffer*(calc: Calculator; buffer: ARRAY OF BYTE; length: INTEGER);
VAR i: INTEGER;
BEGIN
    ASSERT(calc # NIL);
    ASSERT(calc.initialized);
    ASSERT(length >= 0);
    ASSERT(length <= LEN(buffer));
    
    FOR i := 0 TO length - 1 DO
        UpdateByte(calc, buffer[i])
    END
END UpdateBuffer;

(** Finalize CRC32 calculation and return result *)
PROCEDURE Finalize*(calc: Calculator): INTEGER;
VAR result: INTEGER;
BEGIN
    ASSERT(calc # NIL);
    ASSERT(calc.initialized);
    
    result := Bitwise.Xor(calc.state, 0FFFFFFFFH);
    RETURN result
END Finalize;

(** Convert CRC32 result to hexadecimal string *)
PROCEDURE ToString*(checksum: INTEGER; VAR result: ARRAY OF CHAR);
VAR i, digit, pos: INTEGER;
    hexChars: ARRAY 17 OF CHAR;
BEGIN
    ASSERT(LEN(result) >= 9); (* Need space for 8 hex digits + 0X *)
    
    hexChars := "0123456789abcdef";
    result[8] := 0X;
    pos := 7;
    
    FOR i := 0 TO 7 DO
        digit := Bitwise.And(checksum, 0FH);
        result[pos] := hexChars[digit];
        checksum := Bitwise.LogicalShiftRight(checksum, 4);
        DEC(pos)
    END
END ToString;

(** Calculate CRC32 for entire file using streaming *)
PROCEDURE CalculateFile*(filename: ARRAY OF CHAR; VAR checksum: INTEGER; VAR success: BOOLEAN);
VAR 
    file: Files.File;
    rider: Files.Rider;
    calc: Calculator;
    buffer: ARRAY BUFFER_SIZE OF BYTE;
    bytesRead, i: INTEGER;
BEGIN
    success := FALSE;
    checksum := 0;
    
    file := Files.Old(filename);
    IF file # NIL THEN
        calc := NewCalculator();
        Init(calc);
        
        Files.Set(rider, file, 0);
        
        (* Process file in chunks *)
        WHILE ~rider.eof DO
            bytesRead := 0;
            
            (* Read chunk into buffer *)
            FOR i := 0 TO BUFFER_SIZE - 1 DO
                IF ~rider.eof THEN
                    Files.Read(rider, buffer[i]);
                    IF ~rider.eof THEN
                        INC(bytesRead)
                    END
                END
            END;
            
            (* Update checksum with this chunk *)
            IF bytesRead > 0 THEN
                UpdateBuffer(calc, buffer, bytesRead)
            END
        END;
        
        checksum := Finalize(calc);
        success := TRUE
    END
END CalculateFile;

(** Calculate CRC32 for array of characters *)
PROCEDURE CalculateString*(data: ARRAY OF CHAR): INTEGER;
VAR 
    calc: Calculator;
    i, len: INTEGER;
    result: INTEGER;
BEGIN
    calc := NewCalculator();
    Init(calc);
    
    (* Find string length *)
    len := 0;
    WHILE (len < LEN(data)) & (data[len] # 0X) DO
        INC(len)
    END;
    
    (* Update checksum with each character *)
    FOR i := 0 TO len - 1 DO
        UpdateByte(calc, ORD(data[i]))
    END;
    
    result := Finalize(calc);
    RETURN result
END CalculateString;

(** Calculate CRC32 for Files.Rider - allows processing part of file *)
PROCEDURE CalculateRider*(VAR rider: Files.Rider; length: INTEGER; 
                         VAR checksum: INTEGER; VAR success: BOOLEAN);
VAR 
    calc: Calculator;
    buffer: ARRAY BUFFER_SIZE OF BYTE;
    remaining, chunkSize, bytesRead, i: INTEGER;
BEGIN
    success := FALSE;
    checksum := 0;
    
    calc := NewCalculator();
    Init(calc);
    
    remaining := length;
    
    WHILE (remaining > 0) & ~rider.eof DO
        (* Determine chunk size *)
        IF remaining < BUFFER_SIZE THEN
            chunkSize := remaining
        ELSE
            chunkSize := BUFFER_SIZE
        END;
        
        (* Read chunk *)
        bytesRead := 0;
        FOR i := 0 TO chunkSize - 1 DO
            IF ~rider.eof THEN
                Files.Read(rider, buffer[i]);
                IF ~rider.eof THEN
                    INC(bytesRead)
                END
            END
        END;
        
        (* Update checksum *)
        IF bytesRead > 0 THEN
            UpdateBuffer(calc, buffer, bytesRead);
            DEC(remaining, bytesRead)
        END
    END;
    
    checksum := Finalize(calc);
    success := TRUE
END CalculateRider;

BEGIN
    tableInitialized := FALSE
END CRC32.