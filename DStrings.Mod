(** DStrings.Mod implements a dynamic string with Rider support in Oberon-7.

Copyright (C) 2021 R. S. Doiel <rsdoiel@gmail.com> This Source Code Form is subject to the terms of the Mozilla PublicLicense, v. 2.0. If a copy of the MPL was not distributed with thisfile, You can obtain one at http://mozilla.org/MPL/2.0/. *)
MODULE DStrings;

IMPORT Chars, Convert := extConvert, Strings, Out;

CONST
  MAXSET = 32; (* Oberon-7 doesn't have a MAX(T) for set, assuming 32 *)
  (** Constants describing special characters *)
  EOT* = Chars.EOT;
  TAB* = Chars.TAB;
  LF*  = Chars.LF;
  FF*  = Chars.FF;
  CR*  = Chars.CR;

  (** Constants commonly used characters to quote things.  *)
  QUOT*   = Chars.QUOT; (* ", double quote *)
  AMP*    = Chars.AMP;  (* &, ampersand *)
  APOS*   = Chars.APOS; (* ', apostrophe *)
  LPAR*   = Chars.LPAR; (* (, left paren *)
  RPAR*   = Chars.RPAR; (* ), right paren *)
  AST*    = Chars.AST;    (* *, asterisk *)
  LT*     = Chars.LT;     (* <, less than *)
  EQUALS* = Chars.EQUALS; (* =, equal sign *)
  GT*     = Chars.GT;     (* >, greater than *)
  LBRACK* = Chars.LBRACK; (* [, left square bracket *)
  RBRACK* = Chars.RBRACK; (* ], right square bracket *)
  LBRACE* = Chars.LBRACE; (* left curly brace *)
  RBRACE* = Chars.RBRACE; (* right curly brace *)

TYPE
  (** String, StringDesc implements a data structure to provide
      dynamic string in Oberon-7 type. NOTE: In memory the
      implentation is currently a private linked list of CHAR. *)
  String*     = POINTER TO StringDesc;
  StringDesc* = RECORD
                  c: CHAR;
                  next : String
                END;

  (** Rider when combined with a String gives you a char buffer 
      with a File like interface.

      NOTE: The Rider has two public attributes. Rider.eot and
      Rider.pos. Use the pos attribute to get the position of the
      rider in a string. The procedure Pos is used to mimic the
      Oakwood Pos procedure in Strings module operating on array of
      char. *)
  Rider* = RECORD
             start, cursor : String;
             pos* : INTEGER;
             eot* : BOOLEAN 
           END;

(* minimum takes two integer and returns the smaller one *)
PROCEDURE minimum(a, b : INTEGER) : INTEGER;
  VAR res : INTEGER;
BEGIN
  IF a < b THEN res := a; ELSE res := b; END;
  RETURN res
END minimum;

(** Init takes an ARRAY OF CHAR and a String copying the values from
    the ARRAY OF CHAR into String. Init is destructive and will
    overwrite or allocate memory for each element as needed.

    If you initialize a long String then Initialize to a shorter
    one the element with the 0X will indicate the end of the string.
    The procedure Prune can be used to unlink the first element after
    the initial 0X. *)
PROCEDURE Init*(str : ARRAY OF CHAR; VAR s : String);
  VAR i : INTEGER; cur : String;
BEGIN
  IF s = NIL THEN
    NEW(s); s.next := NIL;
  END;
  s.c := 0X; 
  cur := s;
  i := 0;
  WHILE (i < LEN(str)) & (str[i] # 0X)  DO
    cur.c := str[i];
    IF cur.next = NIL THEN
      NEW(cur.next); cur.next.next := NIL; cur.next.c := 0X; 
    ELSE
      cur.next.c := 0X;
    END;
    INC(i); cur := cur.next;
  END;
END Init;

(** Set takes a Rider, a String and a pos and initializes a Rider
    to that position. *)
PROCEDURE Set*(VAR r : Rider; s : String; pos : INTEGER);
BEGIN
  r.start := s;
  r.cursor := s;
  r.pos := 0;
  WHILE (r.cursor # NIL) & (r.cursor.c # 0X) & (r.pos < pos) DO
      INC(r.pos); r.cursor := r.cursor.next
  END;
  IF (r.cursor = NIL) OR (r.cursor.c = 0X) THEN
    r.eot := TRUE;
  ELSE
    r.eot := FALSE;
  END;
END Set;

(** Base returns the string the Rider operates on *)
PROCEDURE Base*( r : Rider ) : String;
BEGIN
  RETURN r.start
END Base;
  
(** Peek takes a Rider RETURN CHAR value without moving the rider. *)
PROCEDURE Peek*(r : Rider) : CHAR;
  VAR c : CHAR;
BEGIN
  IF r.cursor # NIL THEN
    c := r.cursor.c
  ELSE
    c := 0X;
  END
  RETURN c
END Peek;
   
(** Get returns a CHAR found at the pos or 0X. It advances the
    current position of the Rider. NOTE the rider has a public
    attribute eot which becomes TRUE if 0X is encountered, remains
    FALSE otherwise. *)
PROCEDURE Get*(VAR r : Rider) : CHAR;
  VAR c : CHAR;
BEGIN
  c := Peek(r);
  (* Advance the rider *)
  IF r.cursor # NIL THEN
    r.cursor := r.cursor.next; 
    INC(r.pos);
  END;
  (* Update the rider *)
  IF (r.cursor = NIL) OR (r.cursor.c = 0X) THEN
    r.eot := TRUE;
  ELSE
    r.eot := FALSE; 
  END;
  RETURN c
END Get;

(** Put sets the value of what the rider is pointing at 
    then moves the rider to the next element. It will
    allocate new elements as needed ans ensure the last
    element remains an 0X. *)
PROCEDURE Put*(VAR r : Rider; c : CHAR);
BEGIN
  (* Set the new value *)
  IF r.cursor = NIL THEN
    NEW(r.cursor);
    r.pos := 0;
    r.cursor.next := NIL;
  END;
  r.cursor.c := c;
  (* Advance the rider *)
  IF r.cursor.next = NIL THEN
    NEW(r.cursor.next);
    r.cursor.next.c := 0X;
    r.cursor.next.next := NIL;
  END;
  r.cursor := r.cursor.next; INC(r.pos);
  (* Update the rider *)
  IF (r.cursor = NIL) OR (r.cursor.c = 0X) THEN
    r.eot := TRUE;
  ELSE
    r.eot := FALSE;
  END;
END Put;

(** Copy duplicates the contents into another. It will
    initialize the destination if needed. *)
PROCEDURE Copy*(source : String; VAR dest : String);
  VAR r, w : Rider; c : CHAR;
BEGIN
  IF dest = NIL THEN
    Init("", dest);
  END;
  Set(r, source, 0);
  Set(w, dest, 0);
  c := Get(r);
  WHILE (c # 0X) DO
    Put(w, c);
    c := Get(r);
  END;
END Copy;

(** CopyChars copies an ARRAY OF CHAR into a String initalizing
    destination String if necessary *)
PROCEDURE CopyChars*(source : ARRAY OF CHAR; VAR dest : String);
  VAR w : Rider; i : INTEGER;
BEGIN
  IF dest = NIL THEN
    Init("", dest);
  END;
  Set(w, dest, 0);
  i := 0;
  WHILE (source[i] # 0X) DO
    Put(w, source[i]);
    INC(i);
  END;
  Put(w, 0X);
END CopyChars;

(** Clear sets all element of a DString to 0X. NOTE this not
    free memory allocated by NEW. *)
PROCEDURE Clear*(VAR dest : String);
  VAR cur : String;
BEGIN
  cur := dest;
  WHILE cur # NIL DO
    cur.c := 0X;
    cur := cur.next;
  END;
END Clear;

(** Prune removes trailing String elements after the first 0X,
    The removed elements should then be able to be garbage
    collected. *)
PROCEDURE Prune*(VAR s : String);
  VAR cur : String;
BEGIN
  cur := s;
  WHILE (cur # NIL) & (cur.c # 0X) DO
    cur := cur.next;
  END;
  IF (cur # NIL) & (cur.c = 0X) THEN
    cur.next := NIL;
  END;
END Prune;

(** ToChars copies the contents from a String into an ARRAY OF CHARs
    return the number of chars trunctated and terminating the
    ARRAY OF CHAR with an 0X *)
PROCEDURE ToChars*(s : String; VAR str: ARRAY OF CHAR; VAR res : INTEGER);
  VAR i : INTEGER; cur : String;
BEGIN
  i := 0; res := 0;
  cur := s;
  WHILE (i < LEN(str)) & (cur # NIL) & (cur.c # 0X) DO
    str[i] := cur.c;
    INC(i); cur := cur.next;
  END;
  IF i < LEN(str) THEN
    str[i] := 0X;
  ELSIF i >= LEN(str) - 1 THEN
    i := LEN(str) - 1;
    str[i] := 0X;
    WHILE (cur # NIL) & (cur.c # 0X) DO cur := cur.next; INC(res) END;
  END;
END ToChars;


(** String procedures that implement Oakword Strings functionality but for the String type instread of ARRAY OF CHAR *)

(** Length is the number of CHAR before 0X is encountered. *)
PROCEDURE Length*( s : String ) : INTEGER;
  VAR i : INTEGER; cur : String;
BEGIN
  cur := s; i := 0;
  WHILE (cur # NIL) & (cur.c # 0X) DO cur := cur.next; INC(i); END;
  RETURN i
END Length;

(** Insert *)
PROCEDURE Insert*(source : String; pos : INTEGER; VAR dest : String);
  VAR src, prev, rest : String; w : Rider; c : CHAR;

  PROCEDURE ptr(r : Rider) : String;
  BEGIN
    RETURN r.cursor
  END ptr;

BEGIN
  (* make copy of the source string *)
  Copy(source, src);
  (* point prev at src *)
  IF pos > 0 THEN
    Set(w, dest, (pos - 1));
    (* move to prev to before insert point *)
    prev := ptr(w);
    c := Get(w);
    (* save rest of string to rest *)
    rest := ptr(w);
    prev.next := src;
    (* move to new end of prev *)
    WHILE (prev.next # NIL) & (prev.next.c # 0X) DO
      prev := prev.next;
    END;
    (* repoint end of prev to rest *)
    prev.next := rest;
  ELSE
    (* move to new end of prev *)
    Set(w, dest, 0);
    prev := src;
    (* save rest of string to rest *)
    rest := ptr(w);
    rest := dest;
    dest := src;
    (* move to new end of prev *)
    WHILE (prev.next # NIL) & (prev.next.c # 0X) DO
      prev := prev.next;
    END;
    prev.next := rest;
  END;
END Insert;

(** Append *)
PROCEDURE Append*(extra : String; VAR dest: String);
  VAR src, cur : String;
BEGIN
  Copy(extra, src);
  cur := dest;
  IF (cur # NIL) & (cur.c # 0X) THEN
    WHILE (cur.next # NIL) & (cur.next.c # 0X) DO
      cur := cur.next;
    END;
    cur.next := src;
  ELSE
    dest := src;
  END;
END Append;

(** Delete *)
PROCEDURE Delete*(VAR s : String; pos, n : INTEGER);
  VAR cur, cut : String; i, j : INTEGER;
BEGIN
  ASSERT(pos >= 0);
  ASSERT(pos < Length(s));
  IF (s # NIL) THEN
    (* Find the start of the cut *)
    cur := s;
    i := 0;
    WHILE (i < (pos - 1)) & (cur.next # NIL) DO
      cur := cur.next; INC(i);
    END;
    (* Find the end of the cut *)
    j := 0;
    cut := cur;
    WHILE (j < n) & (cut.next # NIL) DO 
      cut := cut.next; INC(j);
    END;
    IF pos = 0 THEN
      s := cut;
    ELSE
      cur.next := cut.next; 
    END;
  END;
END Delete;

(** Replace replace the contents of dest with source starting at
    pos. *)
PROCEDURE Replace*(source : String; pos : INTEGER; VAR dest : String);
BEGIN
  Delete(dest, pos, Length(source));
  Insert(source, pos, dest);
END Replace;

(** Extract *)
PROCEDURE Extract*(source : String; pos, n : INTEGER; VAR dest : String);
  VAR cur, copy : String; i : INTEGER;
BEGIN
  cur := source;
  i := 0;
  (* Move to start of copy *)
  WHILE (i < pos) & (cur # NIL) DO
    cur := cur.next; INC(i);
  END;
  (* Copy substring *)
  i := 0;
  IF dest = NIL THEN
    NEW(dest); dest.next := NIL; dest.c := 0X;
  END;
  copy := dest;
  copy.c := 0X;
  WHILE  (i < n) & (cur # NIL) & (cur.c # 0X) DO
    copy.c := cur.c;
    IF (copy.next = NIL) THEN
      NEW(copy.next); copy.next.next := NIL;
    END;
    copy.next.c := 0X;
    cur := cur.next; copy := copy.next; INC(i);
  END;
END Extract;

(** Pos return the position of the first occurrance of pattern in
    source starting at pos. If pattern not found return -1.
    pos must be less than length of s. *) 
PROCEDURE Pos*(pattern, source : String; pos : INTEGER) : INTEGER;
  VAR is, res : INTEGER; pr, sr : Rider; a, b : CHAR;
BEGIN
  ASSERT(pos >= 0);
  ASSERT(pos < Length(source));
  is := pos; res := -1; 
  a := "a"; (* give 'a' a dummy value to start loop *)
  WHILE (res = -1) & (a # 0X) DO
    Set(sr, source, is); Set(pr, pattern, 0); 
    a := Get(sr); b := Get(pr);
    WHILE (a = b) & (a # 0X) & (b # 0X) DO
        a := Get(sr); b := Get(pr);
    END;
    IF (b = 0X) THEN
      res := is;
    END;
    INC(is);
  END;
  RETURN res
END Pos;

(** Cap replace lower case 'a' to 'z' with uppercase 'A' to 'Z' *)
PROCEDURE Cap*(VAR s : String);
  VAR cur : String;
BEGIN
  cur := s;
  WHILE (cur # NIL) & (cur.c # 0X) DO
    IF (cur.c >= "a") & (cur.c <= "z") THEN
      cur.c := CHR(ORD("A") + ORD(cur.c) - ORD("a"));
    END;
    cur := cur.next;
  END;
END Cap;

(** Beyond Oakwood, the follows the procedure signatures of Chars.Mod *)

(** Equal - compares two string and returns TRUE if all elements
    match through to the terminating 0X *)    
PROCEDURE Equal*( s1, s2 : String) : BOOLEAN;
  VAR res : BOOLEAN; r1, r2 : Rider; c1, c2 : CHAR;
BEGIN
  Set(r1, s1, 0);
  Set(r2, s2, 0);
  res := TRUE;
  WHILE res & (r1.eot = FALSE) & (r2.eot = FALSE) DO
    c1 := Get(r1); c2 := Get(r2);
    IF c1 # c2 THEN
      res := FALSE;
    END;
  END;
  RETURN res
END Equal;

(** StartsWith compares a prefix String with a source string,
    returns TRUE if prefix matches, FALSE otherwise. *)
PROCEDURE StartsWith*(prefix, source : String) : BOOLEAN;
  VAR res : BOOLEAN; pr, sr : Rider; a, b : CHAR;
BEGIN res := TRUE;
  Set(pr, prefix, 0); Set(sr, source, 0);
  a := " "; b := " "; (* Set a dummy start value *)
  WHILE res & (a # 0X) & (a = b) DO
    a := Get(pr); 
    b := Get(sr);
    IF (a # 0X) & (a # b) THEN
      res := FALSE;
    END;
  END;
  RETURN res
END StartsWith;

(** EndsWith compares a suffix with source String. Returns
    TRUE if suffix is found, FALSE otherwise. *)
PROCEDURE EndsWith*(suffix, source : String) : BOOLEAN;
  VAR l1, l2 : INTEGER; r1, r2 : Rider; c1, c2 : CHAR; res : BOOLEAN;
BEGIN res := TRUE;
  l1 := Length(suffix); l2 := Length(source);
  Set(r1, suffix, 0); (* r1 is set to start of suffix *)
  Set(r2, source, l2 - l1); (* r2 is set to start of suffix in source *)
  (* check each CHAR to see if they match, update result if not. *)
  WHILE (res = TRUE) & (c1 # 0X) & (c2 #0X) DO
    c1 := Get(r1); c2 := Get(r2);
    IF c1 # c2 THEN
      res := FALSE;
    END;
  END;
  RETURN res
END EndsWith;

(* TrimPrefix cuts the prefix from the beginning of a String
   if present. *)
PROCEDURE TrimPrefix*(prefix : String; VAR source : String);
  VAR l : INTEGER;
BEGIN
  IF StartsWith(prefix, source) THEN
    l := Length(prefix);
    Delete(source, 0, l);
  END;
END TrimPrefix;

(* TrimSuffix cuts the suffix from the end of a String
   if present. *)
PROCEDURE TrimSuffix*(suffix : String; VAR source : String);
  VAR l1, l2, pos : INTEGER;
BEGIN
  IF EndsWith(suffix, source) THEN
    l1 := Length(suffix);
    l2 := Length(source);
    pos := l2 - l1;
    Delete(source, pos, l1);
  END;
END TrimSuffix;

(** TrimString removes cutString from beginning and end of a string *)
PROCEDURE TrimString*(cutString : String; VAR source : String);
BEGIN
  TrimPrefix(cutString, source);
  TrimSuffix(cutString, source);
END TrimString;

(** TrimLeft removes any of the characters in cutset (an
    ARRAY OF CHAR) from left end of String *)
PROCEDURE TrimLeft*(cutset : ARRAY OF CHAR; VAR source : String);
  VAR r : Rider; c : CHAR; l : INTEGER;
BEGIN
  Set(r, source, 0);
  l := 0; c := Get(r);
  WHILE (c # 0X) & Chars.InCharList(c, cutset) DO
    c := Get(r); INC(l);
  END;
  IF l > 0 THEN
    Delete(source, 0, (l - 1));
  END;
END TrimLeft;

(** TrimRight removes any of the characters in cutset (an
    ARRAY OF CHAR) from right end of String *)
PROCEDURE TrimRight*(cutset: ARRAY OF CHAR; VAR source : String);
  VAR r : Rider; c : CHAR; l, pos : INTEGER; inList : BOOLEAN;
BEGIN
  Set(r, source, 0);
  inList := FALSE; l := 0; pos := -1; c := Get(r);
  WHILE (c # 0X) DO
    IF (inList = FALSE) & Chars.InCharList(c, cutset) THEN
      pos := l;
      inList := TRUE;
    ELSIF Chars.InCharList(c, cutset) = FALSE THEN
      pos := -1;
      inList := FALSE;
    END;
    c := Get(r);
    INC(l);
  END;
  IF (pos # -1) & (l > 0) THEN
    Delete(source, pos, l - pos);
  END;
END TrimRight;

(** TrimCutset removes any of the characters in cutset (an 
    ARRAY OF CHAR) from left or right side of String *)
PROCEDURE Trim*(cutset : ARRAY OF CHAR; VAR source : String);
BEGIN
  TrimLeft(cutset, source);
  TrimRight(cutset, source);
END Trim;

(** TrimSpaceLeft removes leading space characters from beginning
    of String. *)
PROCEDURE TrimSpaceLeft*(VAR source : String);
BEGIN
  TrimLeft(Chars.spaces, source);
END TrimSpaceLeft;

(** TrimSpaceRight removes trailing space characters from end of
    String *)
PROCEDURE TrimSpaceRight*(VAR source : String);
BEGIN
  TrimRight(Chars.spaces, source);
END TrimSpaceRight;

(** TrimSpace removes leading and trailing space characters from String *)
PROCEDURE TrimSpace*(VAR source : String);
BEGIN
  TrimLeft(Chars.spaces, source);
  TrimRight(Chars.spaces, source);
END TrimSpace;

(** Quote add leading and trailing CHAR to a string. This
    makes it easy to add double single or any specific 
    characters to a string.

    Example: Adding double quotes around a string.

        String.Init("this string needs quotes", source);
        String.QuoteString(QUOT, QUOT, source);

  *)
PROCEDURE Quote*(leftQuote, rightQuote : CHAR; VAR source : String);
  VAR cur : String;
BEGIN
  NEW(cur);
  cur.c := leftQuote;
  cur.next := source;
  source := cur;
  WHILE (cur.next # NIL) & (cur.c # 0X) DO
    cur := cur.next;
  END;
  IF cur.c = 0X THEN
     cur.c := rightQuote;
  ELSE
     NEW(cur.next);
     cur := cur.next;
     cur.next := NIL;
     cur.c := rightQuote;
  END;
  IF cur.next = NIL THEN
    NEW(cur.next);
    cur := cur.next;
    cur.c := 0X;
  END;
END Quote;


(** 
  * The following procedures work using Riders treating a String 
  * as a buffer. Combining a Rider and a String Provides a powerful
  * approach for working with plain text in memory. 
  *
  * The procedures are based Files procedure signatures.
  *)


(** Read takes a Rider and reads the next CHAR from a DString, 
    setting the value of b (a BYTE). It similar to Get but
    is a proper procedure instead of a function. *)
PROCEDURE Read*(VAR r : Rider; VAR value : BYTE);
  VAR c : CHAR;
BEGIN
  c := Get(r); value := ORD(c);
END Read;

(** ReadChar takes a Rider and returns the next CHAR from a 
    It is like Get but implemented as a proper procedure instead of
    a function. *)
PROCEDURE ReadChar*(VAR r : Rider; VAR value : CHAR);
BEGIN
  value := Get(r);
END ReadChar;

(** ReadInt reads an integer from Rider. *)
PROCEDURE ReadInt*(VAR r : Rider; VAR value : INTEGER);
  VAR buf : ARRAY 25 OF CHAR; i, j : INTEGER; c : CHAR;
      done : BOOLEAN; 
BEGIN
  c := " ";
  (* Find our first digit *)
  WHILE (Chars.IsDigit(Peek(r)) = FALSE) & (c # 0X) DO c := Get(r); END;
  IF Chars.IsDigit(Peek(r)) THEN
    (* NOTE : the loop condition contains (i < 24) because a trailing 0X *)
    i := 0; buf[0] := 0X; buf[24] := 0X;
    WHILE Chars.IsDigit(Peek(r)) & (i < 24) DO
      buf[i] := Get(r); 
      INC(i); buf[i] := 0X;
    END;
    Convert.StringToInt(buf, j, done);
    IF done THEN value := j END
  END;
END ReadInt;

(** ReadReal reads a real from Rider in decimal notation *)
PROCEDURE ReadReal*(VAR r : Rider; VAR value : REAL);
  VAR i, l : INTEGER; res : REAL; c : CHAR; s : ARRAY 256 OF CHAR; done : BOOLEAN;
BEGIN l := LEN(s);
  (* Initialize string to hold copy of real number *)
  FOR i := 0 TO LEN(s) - 1 DO s[i] := 0X; END;
  i := 0; c := " ";
  (* Find first digit *)
  WHILE (Chars.IsDigit(Peek(r)) = FALSE) & (c # 0X) DO
    c := Get(r); 
  END;
  (* Get integer number before decimal *)
  IF Chars.IsDigit(Peek(r)) THEN
    WHILE Chars.IsDigit(Peek(r)) & (i < l) DO
      s[i] := Get(r); INC(i); s[i] := 0X;
    END;
    IF Peek(r) = "." THEN
      (* Get decimal fraction *)
      s[i] := Get(r); INC(i);
      WHILE Chars.IsDigit(Peek(r)) & (i < l) DO
        s[i] := Get(r); 
        INC(i); s[i] := 0X;
      END;
      (* Try converting to Real value *)
      Convert.StringToReal(s, res, done);
      (* If converted successfully then update value *)
      IF done THEN value := res END;
    END;
  END;
END ReadReal;

(** ReadString takes a Rider and extracts through Rider.eot content
    saving results in dest ARRAY OF CHAR *)
PROCEDURE ReadString*(VAR r : Rider; VAR dest : ARRAY OF CHAR);
  VAR i, l : INTEGER; s : String; c : CHAR;
BEGIN
  s := Base(r);
  i := 0; l := minimum(Length(s), LEN(dest)); dest[l] := 0X;
  REPEAT
    c := Get(r); dest[i] := c; 
    INC(i);
  UNTIL (i >= l) OR (c = 0X);
END ReadString;

(** ReadDString takes a Rider and extracts through Rider.eot content
    saving the results in dest String. *)
PROCEDURE ReadDString*(VAR r : Rider; VAR dest : String);
  VAR pos, l : INTEGER; s : String;
BEGIN 
  pos := r.pos; s := Base(r); l := Length(s);
  Extract(s, pos, l - pos, dest);
END ReadDString;

(** ReadBool reads a boolean representation from Rider.
    Recognized values are 1, 0, t, f, true, false including
    upper and lower case variations. *)
PROCEDURE ReadBool*(VAR r : Rider; VAR value : BOOLEAN);
  VAR c : CHAR; i : INTEGER;
BEGIN
  (* Move beyond spaces *)
  c := Peek(r);
  WHILE (c = " ") & (c # 0X) DO c := Get(r); END;
  IF Chars.InCharList(c, "0fF") THEN
    c := Get(r);  (* advance rider *)
    value := FALSE;
    c := Peek(r);
    IF (c = "a") OR (c = "A") THEN
      FOR i := 0 TO 4 DO c := Get(r); END;
    END;
  ELSIF Chars.InCharList(c, "1tT") THEN
    c := Get(r); (* advance rider *)
    value := TRUE;
    c := Peek(r);
    IF (c = "r") OR (c = "R") THEN
      FOR i := 0 TO 3 DO c := Get(r); END;
    END;
  END;
END ReadBool;

(** ReadBytes reads an ARRAY OF BYTE from a Rider *)
PROCEDURE ReadBytes*(VAR r : Rider; VAR buf : ARRAY OF BYTE; n : INTEGER);
  VAR i, l : INTEGER; c : CHAR;
BEGIN
  l := minimum(n, LEN(buf) - 1);
  FOR i := 0 TO l DO
    c := Get(r); buf[i] := ORD(c);
  END;
END ReadBytes;

(** ReadSet reads a set from a Rider *)
PROCEDURE ReadSet*(VAR r : Rider; VAR value : SET);
  VAR c : CHAR; i, j, k : INTEGER;
BEGIN
  (* skip leading spaces *)
  c := Peek(r);
  WHILE (c = " ") & (c # 0X) DO c := Get(r); END;
  (* Read the SET literal and update value *)
  IF c = "{" THEN (* start of SET literal *)
    WHILE Chars.InCharList(c, "{},. 123456890") & (c # 0X) DO
      IF Chars.InCharList(c, "1234567890") THEN
        ReadInt(r, i); INCL(value, i); c := Get(r);
      ELSIF c = "." THEN (* handle .. notation *)
        c := Get(r);
        IF c = "." THEN
           ReadInt(r, j);
           FOR k := i + 1 TO j DO
             INCL(value, k);
           END;
        END;
        c := Get(r);
      ELSIF c = "}" THEN
        c := 0X
      ELSE
        c := Get(r);
      END;
    END; (* end of looping through set literal *)
  END;
END ReadSet;

(**ReadFixed reads a real value with fixed decimal notation.
   E.g. s holds "3.145" read with ReadRealFixed(r, pi, 2) would
   Set pi to 3.14 but advance the rider beyond the value read *)
PROCEDURE ReadFixed*(VAR r : Rider; VAR value : REAL; n : INTEGER);
  VAR tmp : ARRAY 64 OF CHAR; c : CHAR; i, l, h, f : INTEGER;
      ok : BOOLEAN;

  PROCEDURE power(r : REAL; n : INTEGER) : REAL;
    VAR i : INTEGER; res : REAL;
  BEGIN
    n := ABS(n);
    IF n = 0 THEN
      res := 1.0;
    ELSIF n = 1 THEN
      res := r;
    ELSE
      res := r;
      FOR i := 2 TO n DO
        res := res * r;
      END;
    END;
    RETURN res
  END power;

BEGIN
  c := Peek(r);
  (* Advance beyond while space *)
  WHILE (c = " ") & (c # 0X) DO c := Get(r); END;
  IF Chars.IsDigit(c) THEN
    i := 0; l := LEN(tmp);
    WHILE (i < l) & Chars.IsDigit(c) DO
      tmp[i] := c; c := Get(r);
      INC(i); 
    END;
    tmp[i] := 0X;
    IF c = "." THEN
      Convert.StringToInt(tmp, h, ok);
      c := Get(r); tmp[0] := 0X;
      i := 0;
      WHILE (i < l) & Chars.IsDigit(c) DO
        tmp[i] := c; c := Get(r);
        INC(i);
      END;
      tmp[i] := 0X;
      (* Truncate the string *)
      tmp[n] := 0X;
      Convert.StringToInt(tmp, f, ok);
      value := FLT(h) + (FLT(f) * power(0.1, n));  
    END;
  END;
END ReadFixed;

(** Write takes a Rider and writes a BYTE advancing the Rider *)
PROCEDURE Write*(VAR r : Rider; value : BYTE);
BEGIN
  Put(r, CHR(value));
END Write;

(** WriteChar takes a Rider and a char and writes it to a String *)
PROCEDURE WriteChar*(VAR r : Rider; value : CHAR);
BEGIN
  Put(r, value);
END WriteChar;

(** WriteString takes a Rider and writes an ARRAY OF CHAR to String *)
PROCEDURE WriteString*(VAR r: Rider; value : ARRAY OF CHAR);
  VAR i, l : INTEGER;
BEGIN
  l := Strings.Length(value) - 1;
  FOR i := 0 TO l DO
    Put(r, value[i]);
  END;
END WriteString;

(** WriteDString takes a Rider and a String writes the content into a 
    String until terminating 0X is encountered *)
PROCEDURE WriteDString*(VAR r : Rider; source : String);
  VAR c : CHAR; s : Rider;
BEGIN
  Set(s, source, 0); c := Get(r);
  WHILE c # 0X DO
    Put(s, c); c := Get(r);
  END;
END WriteDString;

(** WriteInt takes a Rider, String, integer and padding count and writes
    the value i to the string *)
PROCEDURE WriteInt*(VAR r : Rider; value : INTEGER);
  VAR ok : BOOLEAN; buf : ARRAY 1024 OF CHAR;
BEGIN
  Chars.IntToString(value, buf, ok);
  IF ok THEN WriteString(r, buf); END;
END WriteInt;

(** WriteReal takes a Rider, String and Real value and writes it into
    the String *)
PROCEDURE WriteReal*(VAR r: Rider; value : REAL);
  VAR ok : BOOLEAN; buf : ARRAY 1024 OF CHAR;
BEGIN 
  Chars.RealToString(value, buf, ok);
  IF ok THEN WriteString(r, buf); END;
END WriteReal;

(** WriteBool takes a Rider, String and Boolean converting the boolean
    into "true" or "false" *)
PROCEDURE WriteBool*(VAR r : Rider; value : BOOLEAN);
  VAR s : ARRAY 7 OF CHAR;
BEGIN
  IF value THEN s := "true"; ELSE s := "false"; END;
  WriteString(r, s);
END WriteBool;

(** WriteBytes takes a Rider and writes an ARRAY OF BYTE to a String *)
PROCEDURE WriteBytes*(VAR r : Rider; buf : ARRAY OF BYTE; n : INTEGER);
  VAR l, i : INTEGER;
BEGIN
  l := minimum(LEN(buf), n) - 1;
  FOR i := 0 TO l DO Write(r, buf[i]) END;
END WriteBytes;

(** WriteSet reads a set from a Rider *)
PROCEDURE WriteSet*(VAR r : Rider; value : SET);
  VAR i, j : INTEGER; comma : BOOLEAN;
BEGIN
(*FIXME: This doesn't use the .. shorthand for consecutive values *)
  WriteChar(r, "{");
  comma := FALSE;
  i := 0;
  WHILE i <= MAXSET DO
    IF i IN value THEN
      IF comma THEN
        WriteString(r, ",");
      ELSE
        comma := TRUE;
      END;
      WriteInt(r, i);
(* Check to see if we have a consecutive sequence *)
      IF (i # MAXSET) & (i IN value) & ((i + 1) IN value) THEN
        j := i;
        WHILE (j # MAXSET) & (j IN value) & ((j + 1) IN value) DO
          INC(j);
        END;
        IF (j > (i + 1)) THEN
          i := j;
          WriteString(r, "..");
          WriteInt(r, i);
        END;
      END;
    END;
    INC(i);
  END;
  WriteChar(r, "}");
END WriteSet;

(**WriteFixed writes a renumber with a fixed number of decimal places
   to a string. E.g. write out dollar ammounts as 1.32 rather then E
   notation *)
PROCEDURE WriteFixed*(VAR r : Rider; value : REAL; n : INTEGER);
  VAR tmp : ARRAY 64 OF CHAR; ok : BOOLEAN;
BEGIN 
  Chars.FixedToString(value, n, tmp, ok);
  IF ok THEN WriteString(r, tmp); END;
END WriteFixed;

BEGIN Out.String(""); (* DEBUG *)
END DStrings.

DStrings provides a dynamic allocated string type to Oberon-7.
DStrings mirrors the Oakwood Strings module where sensible.
In addition it provides a String Rider allowing a string to
be processed similar to a file.



