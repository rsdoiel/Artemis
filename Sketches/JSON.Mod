(** JSON.Mod proovides both json data types and encoding, decoding procedures.

Copyright (C) 2021 R. S. Doiel <rsdoiel@gmail.com> This Source Code Form is subject to the terms of the Mozilla PublicLicense, v. 2.0. If a copy of the MPL was not distributed with thisfile, You can obtain one at http://mozilla.org/MPL/2.0/. *)
MODULE JSON;

IMPORT DStrings;

CONST

    (** Object types *)
    ErrorType*   = 0;
    NullType*    = 1;
    BooleanType* = 2;
    NumberType*  = 3;
    StringType*  = 4;
    ArrayType*   = 5;
    ObjectType*  = 6;

TYPE

    (** Node points at a NodeDesc record which holds a JSON data type *)
    Node*     = POINTER TO NodeDesc;
    NodeDesc* = RECORD
                   value* : DStrings.String;
                   type* : INTEGER;
                   child : Node;
                   next : Node
                END;
    
(** typeToStr is used in testing to translate the const value type 
    to a human readable string *)
PROCEDURE typeToStr*(n : INTEGER; VAR t : ARRAY OF CHAR);
BEGIN 
  IF n = ErrorType THEN
    t := "error type";
  ELSIF n = NullType THEN
    t := "null type";
  ELSIF n = BooleanType THEN
    t := "boolean type";
  ELSIF n = NumberType THEN
    t := "number type";
  ELSIF n = StringType THEN
    t := "string type";
  ELSIF n = ArrayType THEN
    t := "array type";
  ELSIF n = ObjectType THEN
    t := "object type";
  ELSE
    t := "unknown type";
  END;
END typeToStr;

(** TypeStr takes a node and sets the value of *t* to a human readable
    string describing type. *)
PROCEDURE TypeStr*(n : Node; VAR t : ARRAY OF CHAR);
BEGIN 
  IF n = NIL THEN
    t := "Unallocated node";
  ELSE
    typeToStr(n.type, t);
  END;
END TypeStr;

(** Decode takes a DStrings.String and returns a JSON Node representation
    of the object. *)
PROCEDURE Decode*(sources : DStrings.String; VAR node : Node);
BEGIN
  IF node = NIL THEN
    NEW(node); node.type := ErrorType; 
    node.child := NIL;
    node.next := NIL;
  END;

END Decode;

(** Encode takes a Node and encodes the Node in JSON notation
    as a DStrings.String object *)
PROCEDURE Encode*(node : Node; VAR s : DStrings.String );
BEGIN
END Encode;

END JSON.

JSON module needs to do more than just encode and decode. It needs
to provide a basic set of JSON data types, Null, Bool, Number, String,
Array and Object.  Array and Object needs to support mixed types as
attributes or cells.  Each simple type will need a means of being converted
to and from Oberon-7 basic types. 
