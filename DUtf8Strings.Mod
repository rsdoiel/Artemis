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

(** CopyChars copies an ARRAY OF CHAR (UTF-8 encoded) into a DUtf8String. *)
PROCEDURE CopyChars*(source: ARRAY OF CHAR; VAR dest: DUtf8String);
BEGIN
  Init(source, dest);
END CopyChars;


(** Extract extracts count codepoints from source starting at position pos. *)
PROCEDURE Extract*(source: DUtf8String; pos, count: INTEGER; VAR dest: DUtf8String);
VAR
  cur: DUtf8String;
  i, copied: INTEGER;
  destCur, prev: DUtf8String;
BEGIN
  Clear(dest);
  
  IF (source = NIL) OR (pos < 0) OR (count <= 0) THEN
    (* Nothing to extract *)
  ELSE
    (* Find starting position *)
    cur := source;
    i := 0;
    WHILE (cur # NIL) & (cur.codepoint[0] # 0X) & (i < pos) DO
      cur := cur.next;
      i := i + 1;
    END;
    
    (* Extract count codepoints *)
    copied := 0;
    destCur := dest;
    prev := NIL;
    WHILE (cur # NIL) & (cur.codepoint[0] # 0X) & (copied < count) DO
      (* Copy codepoint *)
      i := 0;
      WHILE (i < 5) & (cur.codepoint[i] # 0X) DO
        destCur.codepoint[i] := cur.codepoint[i];
        i := i + 1;
      END;
      destCur.codepoint[i] := 0X;
      
      prev := destCur;
      copied := copied + 1;
      cur := cur.next;
      
      (* Prepare next node if needed *)
      IF (cur # NIL) & (cur.codepoint[0] # 0X) & (copied < count) THEN
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
END Extract;


(** Append appends source string to the end of dest. *)
PROCEDURE Append*(source: DUtf8String; VAR dest: DUtf8String);
VAR
  destCur, srcCur: DUtf8String;
  i: INTEGER;
BEGIN
  IF source = NIL THEN
    (* Nothing to append *)
  ELSIF (dest = NIL) OR (dest.codepoint[0] = 0X) THEN
    (* Dest is empty, just copy source *)
    Copy(source, dest);
  ELSE
    (* Find end of dest *)
    destCur := dest;
    WHILE (destCur.next # NIL) & (destCur.next.codepoint[0] # 0X) DO
      destCur := destCur.next;
    END;
    
    (* Append source nodes *)
    srcCur := source;
    WHILE (srcCur # NIL) & (srcCur.codepoint[0] # 0X) DO
      NEW(destCur.next);
      destCur.next.next := NIL;
      
      (* Copy codepoint *)
      i := 0;
      WHILE (i < 5) & (srcCur.codepoint[i] # 0X) DO
        destCur.next.codepoint[i] := srcCur.codepoint[i];
        i := i + 1;
      END;
      destCur.next.codepoint[i] := 0X;
      
      destCur := destCur.next;
      srcCur := srcCur.next;
    END;
  END;
END Append;

(** Insert inserts source string at position pos (in codepoints) in dest. *)
PROCEDURE Insert*(source: DUtf8String; pos: INTEGER; VAR dest: DUtf8String);
VAR
  prefix, suffix: DUtf8String;
  cur: DUtf8String;
BEGIN
  IF pos <= 0 THEN
    (* Insert at beginning *)
    Copy(source, prefix);
    (* Find end of prefix *)
    cur := prefix;
    WHILE (cur # NIL) & (cur.next # NIL) & (cur.next.codepoint[0] # 0X) DO
      cur := cur.next;
    END;
    (* Attach dest to end of prefix *)
    IF cur # NIL THEN
      cur.next := dest;
    END;
    dest := prefix;
  ELSE
    (* Split dest at position pos *)
    Extract(dest, 0, pos, prefix);
    Extract(dest, pos, Length(dest) - pos, suffix);
    
    (* Rebuild: prefix + source + suffix *)
    Copy(prefix, dest);
    Append(source, dest);
    Append(suffix, dest);
  END;
END Insert;


(** Delete deletes count codepoints from string s starting at position pos. *)
PROCEDURE Delete*(VAR s: DUtf8String; pos, count: INTEGER);
VAR
  prefix, suffix: DUtf8String;
  len: INTEGER;
BEGIN
  len := Length(s);
  IF (pos < 0) OR (count <= 0) OR (pos >= len) THEN
    (* Nothing to delete *)
  ELSE
    (* Adjust count if it goes beyond string length *)
    IF pos + count > len THEN
      count := len - pos;
    END;
    
    (* Extract prefix and suffix *)
    Extract(s, 0, pos, prefix);
    Extract(s, pos + count, len - (pos + count), suffix);
    
    (* Rebuild string *)
    Copy(prefix, s);
    Append(suffix, s);
  END;
END Delete;

(** Pos returns the codepoint position of first occurrence of pattern in source, or -1 if not found. *)
PROCEDURE Pos*(pattern, source: DUtf8String; startPos: INTEGER): INTEGER;
VAR
  srcPos, patternLen, sourceLen: INTEGER;
  srcCur, patCur: DUtf8String;
  match: BOOLEAN;
  i, j: INTEGER;
  result: INTEGER;
BEGIN
  result := -1;
  patternLen := Length(pattern);
  sourceLen := Length(source);
  
  IF (patternLen > 0) & (startPos >= 0) & (startPos < sourceLen) THEN
    srcPos := startPos;
    WHILE (srcPos <= sourceLen - patternLen) & (result = -1) DO
      (* Check for match at current position *)
      match := TRUE;
      
      (* Get to srcPos position *)
      srcCur := source;
      i := 0;
      WHILE (srcCur # NIL) & (i < srcPos) DO
        srcCur := srcCur.next;
        i := i + 1;
      END;
      
      (* Compare pattern *)
      patCur := pattern;
      j := 0;
      WHILE (j < patternLen) & match & (srcCur # NIL) & (patCur # NIL) DO
        (* Compare codepoints *)
        i := 0;
        WHILE (i < 5) & (srcCur.codepoint[i] = patCur.codepoint[i]) & (srcCur.codepoint[i] # 0X) DO
          i := i + 1;
        END;
        
        IF (srcCur.codepoint[i] # patCur.codepoint[i]) THEN
          match := FALSE;
        ELSE
          srcCur := srcCur.next;
          patCur := patCur.next;
          j := j + 1;
        END;
      END;
      
      IF match THEN
        result := srcPos;
      ELSE
        srcPos := srcPos + 1;
      END;
    END;
  END;
  
  RETURN result
END Pos;


(** Replaces the first occurrence of pattern in source with substitute. *)
PROCEDURE Replace*(pattern, substitute: DUtf8String; VAR source: DUtf8String);
VAR
  pos, patternLen: INTEGER;
BEGIN
  pos := Pos(pattern, source, 0);
  IF pos >= 0 THEN
    patternLen := Length(pattern);
    Delete(source, pos, patternLen);
    Insert(substitute, pos, source);
  END;
END Replace;

(** Equal compares two DUtf8String values for equality. *)
PROCEDURE Equal*(s1, s2: DUtf8String): BOOLEAN;
VAR
  r1, r2: Rider;
  c1, c2: INTEGER;
  result: BOOLEAN;
BEGIN
  Set(r1, s1, 0);
  Set(r2, s2, 0);
  result := TRUE;
  
  WHILE result & (~r1.eot) & (~r2.eot) DO
    c1 := Get(r1);
    c2 := Get(r2);
    IF c1 # c2 THEN
      result := FALSE;
    END;
  END;
  
  (* Both should end at the same time for equality *)
  IF result & (r1.eot # r2.eot) THEN
    result := FALSE;
  END;
  
  RETURN result
END Equal;

(** StartsWith checks if source string starts with prefix *)
PROCEDURE StartsWith*(prefix, source: DUtf8String): BOOLEAN;
VAR
  pr, sr: Rider;
  c1, c2: INTEGER;
  result: BOOLEAN;
BEGIN
  result := TRUE;
  Set(pr, prefix, 0);
  Set(sr, source, 0);
  
  WHILE result & (~pr.eot) & (~sr.eot) DO
    c1 := Get(pr);
    c2 := Get(sr);
    IF c1 # c2 THEN
      result := FALSE;
    END;
  END;
  
  (* If prefix is not fully consumed, it doesn't match *)
  IF result & (~pr.eot) THEN
    result := FALSE;
  END;
  
  RETURN result
END StartsWith;

(** EndsWith checks if source string ends with suffix *)
PROCEDURE EndsWith*(suffix, source: DUtf8String): BOOLEAN;
VAR
  l1, l2, startPos: INTEGER;
  sr, suf: Rider;
  c1, c2: INTEGER;
  result: BOOLEAN;
BEGIN
  result := TRUE;
  l1 := Length(suffix);
  l2 := Length(source);
  
  IF l1 > l2 THEN
    result := FALSE;
  ELSE
    startPos := l2 - l1;
    Set(sr, source, startPos);
    Set(suf, suffix, 0);
    
    WHILE result & (~sr.eot) & (~suf.eot) DO
      c1 := Get(sr);
      c2 := Get(suf);
      IF c1 # c2 THEN
        result := FALSE;
      END;
    END;
    
    (* Both should end at the same time *)
    IF result & (sr.eot # suf.eot) THEN
      result := FALSE;
    END;
  END;
  
  RETURN result
END EndsWith;

(** Cap converts lowercase ASCII letters (a-z) to uppercase (A-Z) in place.
    UTF-8 characters beyond ASCII are left unchanged. *)
PROCEDURE Cap*(VAR s: DUtf8String);
VAR
  cur: DUtf8String;
  codePoint, bytesUsed: INTEGER;
  valid: BOOLEAN;
BEGIN
  cur := s;
  WHILE (cur # NIL) & (cur.codepoint[0] # 0X) DO
    valid := Utf8.Decode(cur.codepoint, 0, codePoint);
    IF valid & (codePoint >= ORD("a")) & (codePoint <= ORD("z")) THEN
      (* Convert lowercase to uppercase *)
      codePoint := ORD("A") + (codePoint - ORD("a"));
      (* Re-encode the uppercase character *)
      valid := Utf8.Encode(codePoint, cur.codepoint, 0, bytesUsed);
      (* Ensure proper termination *)
      IF valid & (bytesUsed < 5) THEN
        cur.codepoint[bytesUsed] := 0X;
      END;
    END;
    cur := cur.next;
  END;
END Cap;

(** Peek returns the current codepoint without advancing the rider position.
    Returns 0 if at end of string or on invalid UTF-8. *)
PROCEDURE Peek*(r: Rider): INTEGER;
VAR
  codePoint: INTEGER;
  valid: BOOLEAN;
  result: INTEGER;
BEGIN
  result := 0;
  IF (r.cursor # NIL) & (r.cursor.codepoint[0] # 0X) THEN
    valid := Utf8.Decode(r.cursor.codepoint, 0, codePoint);
    IF valid THEN
      result := codePoint;
    END;
  END;
  RETURN result
END Peek;

(** Put writes a codepoint at the current rider position and advances.
    Allocates new nodes as needed for string expansion. *)
PROCEDURE Put*(VAR r: Rider; codePoint: INTEGER);
VAR
  bytesUsed: INTEGER;
  valid: BOOLEAN;
BEGIN
  (* Ensure we have a node to write to *)
  IF r.cursor = NIL THEN
    NEW(r.cursor);
    r.cursor.next := NIL;
    r.pos := 0;
  END;
  
  (* Encode the codepoint into current node *)
  valid := Utf8.Encode(codePoint, r.cursor.codepoint, 0, bytesUsed);
  IF valid & (bytesUsed < 5) THEN
    r.cursor.codepoint[bytesUsed] := 0X;
  END;
  
  (* Ensure next node exists for next operation *)
  IF r.cursor.next = NIL THEN
    NEW(r.cursor.next);
    r.cursor.next.next := NIL;
    r.cursor.next.codepoint[0] := 0X;
  END;
  
  (* Advance rider *)
  r.cursor := r.cursor.next;
  r.pos := r.pos + 1;
  r.eot := (r.cursor = NIL) OR (r.cursor.codepoint[0] = 0X);
END Put;

(** TrimPrefix removes prefix from beginning of source if it matches *)
PROCEDURE TrimPrefix*(prefix: DUtf8String; VAR source: DUtf8String);
VAR
  prefixLen: INTEGER;
BEGIN
  IF StartsWith(prefix, source) THEN
    prefixLen := Length(prefix);
    Delete(source, 0, prefixLen);
  END;
END TrimPrefix;

(** TrimSuffix removes suffix from end of source if it matches *)
PROCEDURE TrimSuffix*(suffix: DUtf8String; VAR source: DUtf8String);
VAR
  suffixLen, sourceLen, pos: INTEGER;
BEGIN
  IF EndsWith(suffix, source) THEN
    suffixLen := Length(suffix);
    sourceLen := Length(source);
    pos := sourceLen - suffixLen;
    Delete(source, pos, suffixLen);
  END;
END TrimSuffix;

(** TrimString removes cutString from both beginning and end of source *)
PROCEDURE TrimString*(cutString: DUtf8String; VAR source: DUtf8String);
BEGIN
  TrimPrefix(cutString, source);
  TrimSuffix(cutString, source);
END TrimString;

(** TrimLeft removes codepoints from beginning of source if they match any in cutset *)
PROCEDURE TrimLeft*(cutset: ARRAY OF INTEGER; cutsetLen: INTEGER; VAR source: DUtf8String);
VAR
  r: Rider;
  codePoint, trimCount, i: INTEGER;
  found: BOOLEAN;
BEGIN
  Set(r, source, 0);
  trimCount := 0;
  
  WHILE ~r.eot DO
    codePoint := Get(r);
    found := FALSE;
    
    (* Check if current codepoint is in cutset *)
    i := 0;
    WHILE (i < cutsetLen) & ~found DO
      IF codePoint = cutset[i] THEN
        found := TRUE;
      END;
      i := i + 1;
    END;
    
    IF found THEN
      trimCount := trimCount + 1;
    ELSE
      (* Stop at first non-matching character *)
      r.eot := TRUE; (* Exit loop *)
    END;
  END;
  
  IF trimCount > 0 THEN
    Delete(source, 0, trimCount);
  END;
END TrimLeft;

(** TrimRight removes codepoints from end of source if they match any in cutset *)
PROCEDURE TrimRight*(cutset: ARRAY OF INTEGER; cutsetLen: INTEGER; VAR source: DUtf8String);
VAR
  r: Rider;
  codePoint, pos, i: INTEGER;
  found, inTrimRegion: BOOLEAN;
BEGIN
  Set(r, source, 0);
  pos := 0;
  inTrimRegion := FALSE;
  
  WHILE ~r.eot DO
    codePoint := Get(r);
    found := FALSE;
    
    (* Check if current codepoint is in cutset *)
    i := 0;
    WHILE (i < cutsetLen) & ~found DO
      IF codePoint = cutset[i] THEN
        found := TRUE;
      END;
      i := i + 1;
    END;
    
    IF found & ~inTrimRegion THEN
      (* Start of potential trim region *)
      pos := r.pos - 1; (* Position where trimming would start *)
      inTrimRegion := TRUE;
    ELSIF ~found THEN
      (* Non-trimmable character found, reset *)
      inTrimRegion := FALSE;
    END;
  END;
  
  (* If we ended in a trim region, trim from that position *)
  IF inTrimRegion THEN
    Delete(source, pos, Length(source) - pos);
  END;
END TrimRight;

(** Trim removes codepoints from both ends of source if they match any in cutset *)
PROCEDURE Trim*(cutset: ARRAY OF INTEGER; cutsetLen: INTEGER; VAR source: DUtf8String);
BEGIN
  TrimLeft(cutset, cutsetLen, source);
  TrimRight(cutset, cutsetLen, source);
END Trim;

(** TrimSpaces removes Unicode whitespace characters from both ends *)
PROCEDURE TrimSpaces*(VAR source: DUtf8String);
VAR
  spaces: ARRAY 6 OF INTEGER; (* Common Unicode whitespace *)
BEGIN
  (* Common whitespace characters: space, tab, LF, VT, FF, CR *)
  spaces[0] := 32;   (* space *)
  spaces[1] := 9;    (* tab *)
  spaces[2] := 10;   (* line feed *)
  spaces[3] := 11;   (* vertical tab *)
  spaces[4] := 12;   (* form feed *)
  spaces[5] := 13;   (* carriage return *)
  
  Trim(spaces, 6, source);
END TrimSpaces;

(** Quote adds leftQuote at beginning and rightQuote at end of string *)
PROCEDURE Quote*(leftQuote, rightQuote: INTEGER; VAR source: DUtf8String);
VAR
  leftStr, rightStr: DUtf8String;
  bytesUsed: INTEGER;
  valid: BOOLEAN;
BEGIN
  (* Create single-codepoint strings for quotes *)
  NEW(leftStr);
  leftStr.next := NIL;
  valid := Utf8.Encode(leftQuote, leftStr.codepoint, 0, bytesUsed);
  IF valid & (bytesUsed < 5) THEN
    leftStr.codepoint[bytesUsed] := 0X;
  END;
  
  NEW(rightStr);
  rightStr.next := NIL;
  valid := Utf8.Encode(rightQuote, rightStr.codepoint, 0, bytesUsed);
  IF valid & (bytesUsed < 5) THEN
    rightStr.codepoint[bytesUsed] := 0X;
  END;
  
  (* Insert at beginning and append at end *)
  Insert(leftStr, 0, source);
  Append(rightStr, source);
END Quote;

(** Prune removes trailing nodes after the first node with 0X terminator.
    This helps with memory optimization after string operations. *)
PROCEDURE Prune*(VAR s: DUtf8String);
VAR
  cur: DUtf8String;
BEGIN
  cur := s;
  WHILE (cur # NIL) & (cur.codepoint[0] # 0X) DO
    cur := cur.next;
  END;
  
  (* If we found a terminator node, cut off everything after it *)
  IF (cur # NIL) & (cur.codepoint[0] = 0X) THEN
    cur.next := NIL;
  END;
END Prune;

END DUtf8Strings.
