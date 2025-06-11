(** Log.Mod - Basic logging module for Artemis

Copyright (C) 2025 Artemis Project

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

This module provides basic logging functionality with multiple log levels,
support for console and file output, and timestamping capabilities.
*)
MODULE Log;

IMPORT Out, Err := extErr, Files, Clock := artClock, Convert := extConvert, Chars;

CONST
  (* Log levels *)
  DEBUG* = 0;
  INFO* = 1; 
  WARNING* = 2;
  ERROR* = 3;
  
  (* Output destinations *)
  CONSOLE* = 0;
  FILE* = 1;
  BOTH* = 2;
  
  (* Internal constants *)
  MAX_MESSAGE_LEN = Chars.MAXSTR;
  MAX_FILENAME_LEN = Chars.MEDIUMSTR;
  MAX_LEVELNAME_LEN = 16;
  MAX_TEMP_LEN = 32;
  MAX_TIMESTAMP_LEN = 32;

TYPE
  (* Opaque pointer - implementation details hidden from clients *)
  Logger* = POINTER TO LoggerDesc;
  LoggerDesc = RECORD  (* Not exported - opaque type *)
    level: INTEGER;        (* Minimum log level to output *)
    destination: INTEGER;  (* Where to output: CONSOLE, FILE, or BOTH *)
    filename: ARRAY MAX_FILENAME_LEN OF CHAR;
    file: Files.File;
    timestamp: BOOLEAN     (* Whether to include timestamps *)
  END;

(* Safe string concatenation helper *)
PROCEDURE SafeAppend(source: ARRAY OF CHAR; VAR dest: ARRAY OF CHAR);
BEGIN
  IF LEN(dest) - Chars.Length(dest) > Chars.Length(source) THEN
    Chars.Append(source, dest)
  ELSE
    (* Buffer would overflow *)
  END
END SafeAppend;

(** Create a new logger with specified minimum level and destination *)
PROCEDURE New*(level, destination: INTEGER; filename: ARRAY OF CHAR): Logger;
  VAR logger: Logger;
  ok : BOOLEAN;
BEGIN
  ok := TRUE;
  NEW(logger);

  IF logger = NIL THEN
    ok := FALSE (* Allocation failure *)
  END;
  
  (* Validate parameters *)
  IF (level < DEBUG) OR (level > ERROR) THEN
    ok := FALSE
  END;
  
  IF (destination < CONSOLE) OR (destination > BOTH) THEN
    ok := FALSE
  END;

  IF ok THEN  
    logger.level := level;
    logger.destination := destination;
    logger.timestamp := TRUE;
    
    IF (destination = FILE) OR (destination = BOTH) THEN
      logger.filename[0] := 0X; (* Initialize as empty string *)
      SafeAppend(filename, logger.filename);
      logger.file := Files.New(logger.filename);
      IF logger.file = NIL THEN
        (* Fallback to console if file creation fails *)
        logger.destination := CONSOLE
      ELSE
          Files.Register(logger.file)
      END
    ELSE
      logger.file := NIL
    END;
  END;
  
  RETURN logger
END New;

(** Set the minimum log level for the logger *)
PROCEDURE SetLevel*(logger: Logger; level: INTEGER);
BEGIN
  IF (logger # NIL) & (level >= DEBUG) & (level <= ERROR) THEN
    logger.level := level
  END
END SetLevel;

(** Get the current log level for the logger *)
PROCEDURE GetLevel*(logger: Logger): INTEGER;
BEGIN
  RETURN logger.level
END GetLevel;

(** Enable or disable timestamping *)
PROCEDURE SetTimestamp*(logger: Logger; enabled: BOOLEAN);
BEGIN
  logger.timestamp := enabled
END SetTimestamp;

(** Get current timestamp setting *)
PROCEDURE GetTimestamp*(logger: Logger): BOOLEAN;
BEGIN
  RETURN logger.timestamp
END GetTimestamp;

(** Get the current destination setting *)
PROCEDURE GetDestination*(logger: Logger): INTEGER;
BEGIN
  RETURN logger.destination
END GetDestination;

(* Internal procedure to get level name as string *)
PROCEDURE GetLevelName(level: INTEGER; VAR levelName: ARRAY OF CHAR);
BEGIN
  levelName[0] := 0X; (* Initialize as empty string *)
  IF level = DEBUG THEN
    SafeAppend("DEBUG", levelName)
  ELSIF level = INFO THEN
    SafeAppend("INFO", levelName)
  ELSIF level = WARNING THEN
    SafeAppend("WARNING", levelName)
  ELSIF level = ERROR THEN
    SafeAppend("ERROR", levelName)
  ELSE
    SafeAppend("UNKNOWN", levelName)
  END
END GetLevelName;

(* Internal helper to append a padded integer to a string *)
PROCEDURE AppendPaddedInt(value: INTEGER; VAR dest: ARRAY OF CHAR);
  VAR temp: ARRAY MAX_TEMP_LEN OF CHAR; ok: BOOLEAN;
BEGIN
  IF value < 10 THEN
    SafeAppend("0", dest)
  END;
  temp[0] := 0X;
  Convert.IntToString(value, temp, ok);
  IF ok THEN
    SafeAppend(temp, dest)
  END
END AppendPaddedInt;

(* Internal helper to append an unpaded integer to a string *)
PROCEDURE AppendInt(value: INTEGER; VAR dest: ARRAY OF CHAR);
  VAR temp: ARRAY MAX_TEMP_LEN OF CHAR; ok: BOOLEAN;
BEGIN
  temp[0] := 0X;
  Convert.IntToString(value, temp, ok);
  IF ok THEN
    SafeAppend(temp, dest)
  END
END AppendInt;

(* Internal procedure to format timestamp *)
PROCEDURE FormatTimestamp(VAR timestamp: ARRAY OF CHAR);
  VAR clock: Clock.Clock;
BEGIN
  timestamp[0] := 0X; (* Clear the string *)
  Clock.Get(clock);
  
  (* Format: YYYY-MM-DD HH:MM:SS *)
  AppendInt(clock.year, timestamp);
  SafeAppend("-", timestamp);
  AppendPaddedInt(clock.month, timestamp);
  SafeAppend("-", timestamp);
  AppendPaddedInt(clock.day, timestamp);
  SafeAppend(" ", timestamp);
  AppendPaddedInt(clock.hour, timestamp);
  SafeAppend(":", timestamp);
  AppendPaddedInt(clock.minute, timestamp);
  SafeAppend(":", timestamp);
  AppendPaddedInt(clock.second, timestamp)
END FormatTimestamp;

(* Internal procedure to write to console *)
PROCEDURE WriteToConsole(level: INTEGER; message: ARRAY OF CHAR);
BEGIN
  IF level = ERROR THEN
    Err.String(message);
    Err.Ln
  ELSE
    Out.String(message);
    Out.Ln
  END
END WriteToConsole;

(* Internal procedure to write to file *)
PROCEDURE WriteToFile(file: Files.File; message: ARRAY OF CHAR);
  VAR 
    rider: Files.Rider;
    newline: BYTE;
    i: INTEGER;
BEGIN
  IF file # NIL THEN
    Files.Set(rider, file, Files.Length(file));
    
    (* Write message character by character to avoid writing the terminating 0X *)
    i := 0;
    WHILE (i < LEN(message)) & (message[i] # 0X) DO
      Files.Write(rider, ORD(message[i]));
      INC(i)
    END;
    
    newline := ORD(Chars.LF); (* Line feed *)
    Files.Write(rider, newline)
    (* Note: File is kept open for subsequent writes - closed only in Close() *)
  END
END WriteToFile;

(** Log a message with specified level using ARRAY OF CHAR *)
PROCEDURE LogMessage*(logger: Logger; level: INTEGER; message: ARRAY OF CHAR);
  VAR 
    formattedMsg: ARRAY MAX_MESSAGE_LEN OF CHAR;
    levelName: ARRAY MAX_LEVELNAME_LEN OF CHAR;
    timestamp: ARRAY MAX_TIMESTAMP_LEN OF CHAR;
BEGIN
  IF (logger = NIL) OR (level < logger.level) THEN
    (* Couldn't log. *)
  ELSE
    formattedMsg[0] := 0X; (* Clear the string *)
    
    (* Add timestamp if enabled *)
    IF logger.timestamp THEN
        FormatTimestamp(timestamp);
        SafeAppend(timestamp, formattedMsg);
        SafeAppend(" ", formattedMsg)
    END;
    
    (* Add level *)
    GetLevelName(level, levelName);
    SafeAppend("[", formattedMsg);
    SafeAppend(levelName, formattedMsg);
    SafeAppend("] ", formattedMsg);
    
    (* Add message *)
    SafeAppend(message, formattedMsg);
    
    (* Output based on destination *)
    IF (logger.destination = CONSOLE) OR (logger.destination = BOTH) THEN
        WriteToConsole(level, formattedMsg)
    END;
    
    IF (logger.destination = FILE) OR (logger.destination = BOTH) THEN
        WriteToFile(logger.file, formattedMsg)
    END
  END;
END LogMessage;

(** Convenience procedures for common log levels *)

(** Log a debug message *)
PROCEDURE Debug*(logger: Logger; message: ARRAY OF CHAR);
BEGIN
  LogMessage(logger, DEBUG, message)
END Debug;

(** Log an info message *)
PROCEDURE Info*(logger: Logger; message: ARRAY OF CHAR);
BEGIN
  LogMessage(logger, INFO, message)
END Info;

(** Log a warning message *)
PROCEDURE Warning*(logger: Logger; message: ARRAY OF CHAR);
BEGIN
  LogMessage(logger, WARNING, message)
END Warning;

(** Log an error message *)
PROCEDURE Error*(logger: Logger; message: ARRAY OF CHAR);
BEGIN
  LogMessage(logger, ERROR, message)
END Error;

(** Convenience procedures using the default logger *)

(** Close the logger and flush any pending writes *)
PROCEDURE Close*(logger: Logger);
BEGIN
  IF (logger # NIL) & (logger.file # NIL) THEN
    Files.Close(logger.file)
  END
END Close;

BEGIN
END Log.