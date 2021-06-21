(** JSONTest.Mod implements tests for the JSON Module.

Copyright (C) 2021 R. S. Doiel <rsdoiel@gmail.com> This Source Code Form is subject to the terms of the Mozilla PublicLicense, v. 2.0. If a copy of the MPL was not distributed with thisfile, You can obtain one at http://mozilla.org/MPL/2.0/. *)
MODULE JSONTest;

IMPORT JSON, DStrings, Out, T := Tests;

VAR 
  ts : T.TestSet;

PROCEDURE DisplayNode*(msg: ARRAY OF CHAR; node : JSON.Node);
BEGIN
END DisplayNode;

PROCEDURE ExpectedNodeType( t : INTEGER; node : JSON.Node; VAR test: BOOLEAN);
  VAR expected, got : ARRAY 256 OF CHAR; 
BEGIN
  JSON.typeToStr(t, expected);
  JSON.TypeStr(node, got);
  IF node = NIL THEN
    Out.String("decode failed to allocate node"); Out.Ln();
    test := FALSE;
  ELSIF node.type # t THEN
    Out.String("Expected "); Out.String(expected); Out.String(", got "); Out.String(got); Out.Ln();
    test := FALSE;
  END;
END ExpectedNodeType;

(*
PROCEDURE UnexpectedNodeType( t : INTEGER; node : JSON.Node; VAR test: BOOLEAN);
  VAR expected, got : ARRAY 256 OF CHAR; 
BEGIN
  JSON.typeToStr(t, expected);
  JSON.TypeStr(node, got);
  IF node = NIL THEN
    Out.String("decode failed to allocate node"); Out.Ln();
    test := FALSE;
  ELSIF node.type = t THEN
    Out.String("Unexpected "); Out.String(expected); Out.String(", got "); Out.String(got); Out.Ln();
    test := FALSE;
  END;
END UnexpectedNodeType;
*)

PROCEDURE TestDecode() : BOOLEAN;
  VAR 
    test : BOOLEAN; s : DStrings.String; 
    node : JSON.Node;
BEGIN test := TRUE;
  DStrings.Init("null", s);
  JSON.Decode(s, node); 
  ExpectedNodeType(JSON.NullType, node, test);
  DStrings.Init("true", s);
  JSON.Decode(s, node);
  ExpectedNodeType(JSON.BooleanType, node, test);
  DStrings.Init("false", s);
  JSON.Decode(s, node);
  ExpectedNodeType(JSON.BooleanType, node, test);

  Out.String("TestDecode not implemented");Out.Ln();
  test := FALSE;
  RETURN test
END TestDecode;

PROCEDURE TestEncode() : BOOLEAN;
  VAR 
    test : BOOLEAN;
BEGIN
  test := TRUE;
  Out.String("TestEncode not implemented");Out.Ln();
  test := FALSE;
  RETURN test
END TestEncode;

BEGIN
  T.Init(ts, "Test JSON");
  T.Add(ts,TestDecode);
  T.Add(ts,TestEncode);
  ASSERT(T.Run(ts));
END JSONTest.

JSONTest
========

T.the JSON module.



