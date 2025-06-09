(** ExampleDUtf8StringsList.Mod - Demonstrates using DUtf8Strings with LinkedList.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE ExampleDUtf8StringsList;

IMPORT DUtf8Strings, LinkedList, Collections, Out;

TYPE
  PrintState = RECORD (Collections.VisitorState) END;
VAR
  list: LinkedList.List;
  s: DUtf8Strings.DUtf8String;
  state: PrintState;

PROCEDURE PrintUtf8String(item: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
VAR
  s: DUtf8Strings.DUtf8String;
  buf: ARRAY 256 OF CHAR;
  truncated: INTEGER;
BEGIN
  s := item(DUtf8Strings.DUtf8String);
  DUtf8Strings.ToChars(s, buf, truncated);
  Out.String(buf); Out.Ln;
  RETURN TRUE
END PrintUtf8String;

BEGIN
  list := LinkedList.New();

  NEW(s); DUtf8Strings.Init("Hello, Artemis!", s);
  LinkedList.Append(list, s);

  NEW(s); DUtf8Strings.Init("Dynamic UTF-8: 例子, пример, مثال", s);
  LinkedList.Append(list, s);

  NEW(s); DUtf8Strings.Init("Oberon-07 🚀 Unicode Demo.", s);
  LinkedList.Append(list, s);

  Out.String("List Count:"); Out.Int(LinkedList.Count(list), 0); Out.Ln;

  LinkedList.Foreach(list, PrintUtf8String, state)
END ExampleDUtf8StringsList.
