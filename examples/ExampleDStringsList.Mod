(** ExampleDStringsList.Mod - Demonstrates using DStrings with LinkedList.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE ExampleDStringsList;

IMPORT DStrings, LinkedList, Collections, Out;

TYPE
  PrintState = RECORD (Collections.VisitorState) END;
VAR
  list: LinkedList.List;
  s: DStrings.String;
  state: PrintState;

PROCEDURE PrintString(item: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
VAR
  s: DStrings.String;
  buf: ARRAY 128 OF CHAR;
  n: INTEGER;
BEGIN
  s := item(DStrings.String);
  DStrings.ToChars(s, buf, n);
  Out.String(buf); Out.Ln;
  RETURN TRUE
END PrintString;

BEGIN
  list := LinkedList.New();

  NEW(s); DStrings.Init("Hello, Artemis!", s);
  LinkedList.Append(list, s);

  NEW(s); DStrings.Init("Dynamic strings in a list.", s);
  LinkedList.Append(list, s);

  NEW(s); DStrings.Init("Oberon-07 Collections Demo.", s);
  LinkedList.Append(list, s);

  Out.String("List Count:"); Out.Int(LinkedList.Count(list), 0); Out.Ln;

  LinkedList.Foreach(list, PrintString, state)
END ExampleDStringsList.