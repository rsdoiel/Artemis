(** DUtf8Strings.Mod implements a dynamic UTF-8 string with Rider support in Oberon-7.

Copyright (C) 2025 Artemis Project

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause
*)
MODULE DUtf8Strings;

IMPORT Utf8, Collections;

TYPE
  (** DUtf8String implements a dynamic UTF-8 string as a linked list of codepoints.
      Each node stores one UTF-8 codepoint (1-4 bytes) with proper encoding. *)
  DUtf8String* = POINTER TO DUtf8StringDesc;
  DUtf8StringDesc* = RECORD (Collections.Item)
    codepoint: ARRAY 5 OF CHAR; (* UTF-8 sequence, 1-4 bytes + 0X terminator *)
    next: DUtf8String
  END;

  (** Rider provides file-like interface for traversing/modifying DUtf8String.
      All positions are in Unicode codepoints, not bytes. *)
  Rider* = RECORD
    start, cursor: DUtf8String;
    pos*: INTEGER;
    eot*: BOOLEAN
  END;

(* Helper: AllocateIfNil allocates a new node if pointer is NIL *)
PROCEDURE AllocateIfNil(VAR s: DUtf8String);
BEGIN
  IF s = NIL THEN
    NEW(s);
    s.next := NIL;
    s.codepoint[0] := 0X;
  END;
END AllocateIfNil;

(** Init takes an ARRAY OF CHAR (UTF-8 encoded) and initializes a DUtf8String.
    The source array is expected to contain valid UTF-8. *)
PROCEDURE Init*(source: ARRAY OF CHAR; VAR s: DUtf8String);
VAR
  srcIdx, codePoint, bytesWritten: INTEGER;
  cur: DUtf8String;
  valid: BOOLEAN;
BEGIN
  AllocateIfNil(s);
  cur := s;
  srcIdx := 0;
  
  (* Handle empty string case *)
  IF (srcIdx >= LEN(source)) OR (source[srcIdx] = 0X) THEN
    cur.codepoint[0] := 0X;
    cur.next := NIL;
  ELSE
    WHILE (srcIdx < LEN(source)) & (source[srcIdx] # 0X) DO
      valid := Utf8.Decode(source, srcIdx, codePoint);
      IF valid THEN
        (* Store the UTF-8 sequence in current node *)
        valid := Utf8.Encode(codePoint, cur.codepoint, 0, bytesWritten);
        IF valid THEN
          cur.codepoint[bytesWritten] := 0X; (* Ensure termination *)
          (* Advance source index by the UTF-8 character length *)
          srcIdx := srcIdx + Utf8.CharLen(source[srcIdx]);
          (* Prepare next node if not at end *)
          IF (srcIdx < LEN(source)) & (source[srcIdx] # 0X) THEN
            NEW(cur.next);
            cur.next.next := NIL;
            cur.next.codepoint[0] := 0X;
            cur := cur.next;
          END;
        ELSE
          (* Encoding failed, stop *)
          srcIdx := LEN(source);
        END;
      ELSE
        (* Decoding failed, skip this byte *)
        srcIdx := srcIdx + 1;
      END;
    END;
    
    (* Ensure last node is properly terminated *)
    cur.next := NIL;
  END;
END Init;

(** Length returns the number of Unicode codepoints in the string. *)
PROCEDURE Length*(s: DUtf8String): INTEGER;
VAR
  count: INTEGER;
  cur: DUtf8String;
BEGIN
  count := 0;
  cur := s;
  WHILE (cur # NIL) & (cur.codepoint[0] # 0X) DO
    count := count + 1;
    cur := cur.next;
  END;
  RETURN count
END Length;

(** Set initializes a Rider to position pos (in codepoints) in the string. *)
PROCEDURE Set*(VAR r: Rider; s: DUtf8String; pos: INTEGER);
VAR
  i: INTEGER;
BEGIN
  r.start := s;
  r.cursor := s;
  r.pos := 0;
  
  (* Advance to the specified position *)
  i := 0;
  WHILE (i < pos) & (r.cursor # NIL) & (r.cursor.codepoint[0] # 0X) DO
    r.cursor := r.cursor.next;
    i := i + 1;
  END;
  
  r.pos := i;
  r.eot := (r.cursor = NIL) OR (r.cursor.codepoint[0] = 0X);
END Set;

(** Base returns the string the Rider operates on. *)
PROCEDURE Base*(r: Rider): DUtf8String;
BEGIN
  RETURN r.start
END Base;

(** Get returns the current codepoint and advances the Rider. *)
PROCEDURE Get*(VAR r: Rider): INTEGER;
VAR
  codePoint: INTEGER;
  valid: BOOLEAN;
BEGIN
  codePoint := 0;
  IF (r.cursor # NIL) & (r.cursor.codepoint[0] # 0X) THEN
    valid := Utf8.Decode(r.cursor.codepoint, 0, codePoint);
    IF ~valid THEN
      codePoint := 0;
    END;
    (* Advance rider *)
    r.cursor := r.cursor.next;
    r.pos := r.pos + 1;
  END;
  
  (* Update eot status *)
  r.eot := (r.cursor = NIL) OR (r.cursor.codepoint[0] = 0X);
  
  RETURN codePoint
END Get;

(** ToChars converts the DUtf8String to an ARRAY OF CHAR (UTF-8 encoded).
    Returns the number of bytes that were truncated due to insufficient space. *)
PROCEDURE ToChars*(s: DUtf8String; VAR dest: ARRAY OF CHAR; VAR truncated: INTEGER);
VAR
  cur: DUtf8String;
  destIdx, srcIdx, len: INTEGER;
BEGIN
  cur := s;
  destIdx := 0;
  truncated := 0;
  
  WHILE (cur # NIL) & (cur.codepoint[0] # 0X) DO
    len := Utf8.CharLen(cur.codepoint[0]);
    
    (* Check if there's enough space in destination *)
    IF destIdx + len < LEN(dest) THEN
      (* Copy the UTF-8 sequence *)
      srcIdx := 0;
      WHILE (srcIdx < len) & (srcIdx < 4) DO
        dest[destIdx] := cur.codepoint[srcIdx];
        destIdx := destIdx + 1;
        srcIdx := srcIdx + 1;
      END;
    ELSE
      (* Count truncated bytes *)
      truncated := truncated + len;
    END;
    
    cur := cur.next;
  END;
  
  (* Null terminate *)
  IF destIdx < LEN(dest) THEN
    dest[destIdx] := 0X;
  ELSIF LEN(dest) > 0 THEN
    dest[LEN(dest) - 1] := 0X;
  END;
END ToChars;

(** Copy duplicates the source string into dest, allocating as needed. *)
PROCEDURE Copy*(source: DUtf8String; VAR dest: DUtf8String);
VAR
  srcCur, destCur, prev: DUtf8String;
  i: INTEGER;
BEGIN
  IF source = NIL THEN
    dest := NIL;
  ELSE
    AllocateIfNil(dest);
    srcCur := source;
    destCur := dest;
    prev := NIL;
    
    (* Handle empty source case *)
    IF srcCur.codepoint[0] = 0X THEN
      destCur.codepoint[0] := 0X;
      destCur.next := NIL;
    ELSE
      WHILE (srcCur # NIL) & (srcCur.codepoint[0] # 0X) DO
        (* Copy the codepoint *)
        i := 0;
        WHILE (i < 5) & (srcCur.codepoint[i] # 0X) DO
          destCur.codepoint[i] := srcCur.codepoint[i];
          i := i + 1;
        END;
        destCur.codepoint[i] := 0X; (* Ensure termination *)
        
        prev := destCur;
        srcCur := srcCur.next;
        
        (* Prepare next node if needed *)
        IF (srcCur # NIL) & (srcCur.codepoint[0] # 0X) THEN
          NEW(destCur.next);
          destCur.next.next := NIL;
          destCur.next.codepoint[0] := 0X;
          destCur := destCur.next;
        END;
      END;
      
      (* Ensure proper termination *)
      IF prev # NIL THEN
        prev.next := NIL;
      END;
    END;
  END;
END Copy;

(** Clear sets the string to empty (single node with 0X codepoint). *)
PROCEDURE Clear*(VAR s: DUtf8String);
BEGIN
  AllocateIfNil(s);
  s.codepoint[0] := 0X;
  s.next := NIL;
END Clear;

END DUtf8Strings.
