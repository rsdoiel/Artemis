(*
    ExampleDirChecksum.Mod - Directory checksumming tool example
    Demonstrates: Directory scanning, CRC32, extArgs, Files, Out
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
    Author: Artemis Project
*)
MODULE ExampleDirChecksum;

IMPORT Out, extArgs, artDirent, Chars, Collections, Files, CRC32;

CONST
    UsageMsg = "Usage: ExampleDirChecksum <directory>";
    MaxNameLen = 256;
    ReadBufSize = 4096;

TYPE
    (* FileJob = POINTER TO FileJobDesc;
    FileJobDesc = RECORD (Collections.Item)
        name: ARRAY MaxNameLen OF CHAR
    END; *)

    FileResult = POINTER TO FileResultDesc;
    FileResultDesc = RECORD (Collections.Item)
        name: ARRAY MaxNameLen OF CHAR;
        success: BOOLEAN;
        checksum: INTEGER
    END;

VAR
    dir: ARRAY MaxNameLen OF CHAR;
    res: INTEGER;
    debugMode: BOOLEAN;

(* Print a single result line *)
PROCEDURE PrintResult(result : FileResult);
BEGIN
    Out.String(result.name);
    Out.String(" ");
    IF result.success THEN
        Out.Hex(result.checksum)
    ELSE
        Out.String("?")
    END;
    Out.Ln
END PrintResult;

(* Compute CRC32 checksum for a file *)
PROCEDURE ComputeFileChecksum(name: ARRAY OF CHAR; VAR result: FileResult);
VAR
    file: Files.File;
    rider: Files.Rider;
    buffer: ARRAY ReadBufSize OF BYTE;
    bytesRead, i: INTEGER;
    calc: CRC32.Calculator;
BEGIN
    result.name[0] := 0X;
    Chars.Append(name, result.name);
    file := Files.Old(name);
    IF file # NIL THEN
        Files.Set(rider, file, 0);
        calc := CRC32.NewCalculator();
        CRC32.Init(calc);
        WHILE ~rider.eof DO
            Files.ReadBytes(rider, buffer, ReadBufSize);
            bytesRead := ReadBufSize - rider.res;
            FOR i := 0 TO bytesRead - 1 DO
                CRC32.UpdateByte(calc, buffer[i])
            END
        END;
        result.success := TRUE;
        result.checksum := CRC32.Finalize(calc);
        Files.Close(file)
    ELSE
        result.success := FALSE;
        result.checksum := 0
    END
END ComputeFileChecksum;

(* Scan directory and process files *)
PROCEDURE ScanAndProcessDirectory(path: ARRAY OF CHAR);
VAR
    scanner: artDirent.DirScanner;
    name: ARRAY MaxNameLen OF CHAR;
    isDir: BOOLEAN;
    fileCount: INTEGER;
    result: FileResult;
    ok: BOOLEAN;
BEGIN
    fileCount := 0;
    scanner := artDirent.OpenScanner(path);
    IF scanner # NIL THEN
        ok := artDirent.NextEntry(scanner, name, isDir);
        WHILE ok DO
            IF ~isDir THEN
                NEW(result);
                ComputeFileChecksum(name, result);
                PrintResult(result);
                fileCount := fileCount + 1
            END;
            ok := artDirent.NextEntry(scanner, name, isDir)
        END;
        artDirent.CloseScanner(scanner)
    ELSE
        Out.String("Failed to open directory: ");
        Out.String(path); Out.Ln
    END
END ScanAndProcessDirectory;

BEGIN
    IF extArgs.count < 1 THEN
        Out.String(UsageMsg); Out.Ln
    ELSE
        extArgs.Get(0, dir, res);
        debugMode := FALSE;
        ScanAndProcessDirectory(dir)
    END
END ExampleDirChecksum.
