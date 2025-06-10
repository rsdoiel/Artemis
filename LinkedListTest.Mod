(** LinkedListTest.Mod - Tests for LinkedList.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE LinkedListTest;

IMPORT LinkedList, Collections, Tests;

TYPE
  TestItem = RECORD (Collections.Item)
    value: INTEGER
  END;
  TestItemPtr = POINTER TO TestItem;

  TestVisitorState = RECORD (Collections.VisitorState)
    sum, count: INTEGER
  END;

VAR
  ts : Tests.TestSet;

PROCEDURE Visitor(item: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
BEGIN
  state(TestVisitorState).sum := state(TestVisitorState).sum + item(TestItemPtr).value;
  INC(state(TestVisitorState).count);
  RETURN TRUE
END Visitor;

PROCEDURE VisitorEarlyStop(item: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
BEGIN
  state(TestVisitorState).sum := state(TestVisitorState).sum + item(TestItemPtr).value;
  INC(state(TestVisitorState).count);
  RETURN state(TestVisitorState).count < 2
END VisitorEarlyStop;

PROCEDURE NewItem(val: INTEGER): TestItemPtr;
VAR item: TestItemPtr;
BEGIN
  NEW(item);
  item.value := val;
  RETURN item
END NewItem;

PROCEDURE TestNewAndIsEmpty(): BOOLEAN;
VAR list: LinkedList.List; pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := LinkedList.New();
  IF ~LinkedList.IsEmpty(list) THEN pass := FALSE END;
  IF LinkedList.Count(list) # 0 THEN pass := FALSE END;
  LinkedList.Free(list);
  RETURN pass
END TestNewAndIsEmpty;

PROCEDURE TestAppendAndRemove(): BOOLEAN;
VAR 
    list: LinkedList.List; 
    n1, n2, n3: TestItemPtr;
    out: Collections.ItemPtr;
    pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := LinkedList.New();
  n1 := NewItem(1); n2 := NewItem(2); n3 := NewItem(3);

  LinkedList.Append(list, n1);
  IF LinkedList.Count(list) # 1 THEN pass := FALSE END;

  LinkedList.Append(list, n2);
  IF LinkedList.Count(list) # 2 THEN pass := FALSE END;

  LinkedList.Append(list, n3);
  IF LinkedList.Count(list) # 3 THEN pass := FALSE END;

  LinkedList.RemoveFirst(list, out);
  IF out # n1 THEN pass := FALSE END;
  IF LinkedList.Count(list) # 2 THEN pass := FALSE END;

  LinkedList.RemoveFirst(list, out);
  IF out # n2 THEN pass := FALSE END;
  IF LinkedList.Count(list) # 1 THEN pass := FALSE END;

  LinkedList.RemoveFirst(list, out);
  IF out # n3 THEN pass := FALSE END;
  IF LinkedList.Count(list) # 0 THEN pass := FALSE END;

  LinkedList.RemoveFirst(list, out);
  IF out # NIL THEN pass := FALSE END;
  IF LinkedList.Count(list) # 0 THEN pass := FALSE END;

  LinkedList.Free(list);
  RETURN pass
END TestAppendAndRemove;

PROCEDURE TestInsertAt(): BOOLEAN;
VAR
  list: LinkedList.List;
  n1, n2, n3, n4, n5: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := LinkedList.New();
  n1 := NewItem(1); n2 := NewItem(2); n3 := NewItem(3); n4 := NewItem(4); n5 := NewItem(5);

  LinkedList.Append(list, n1);
  LinkedList.Append(list, n2);
  LinkedList.Append(list, n4); (* List: n1 -> n2 -> n4 *)

  (* Insert n3 at position 2 (between n2 and n4): n1 -> n2 -> n3 -> n4 *)
  success := LinkedList.InsertAt(list, 2, n3);
  IF ~success THEN pass := FALSE END;
  IF LinkedList.Count(list) # 4 THEN pass := FALSE END;
  
  (* Verify insertion using GetAt *)
  success := LinkedList.GetAt(list, 2, result);
  IF ~success OR (result # n3) THEN pass := FALSE END;

  (* Insert at the end of the list *)
  success := LinkedList.InsertAt(list, 4, n5);
  IF ~success THEN pass := FALSE END;
  IF LinkedList.Count(list) # 5 THEN pass := FALSE END;
  
  success := LinkedList.GetAt(list, 4, result);
  IF ~success OR (result # n5) THEN pass := FALSE END;

  (* Insert at invalid position *)
  success := LinkedList.InsertAt(list, 10, NewItem(99));
  IF success THEN pass := FALSE END;
  IF LinkedList.Count(list) # 5 THEN pass := FALSE END;

  LinkedList.Free(list);
  RETURN pass
END TestInsertAt;

PROCEDURE TestForeach(): BOOLEAN;
VAR
  list: LinkedList.List;
  n1, n2, n3: TestItemPtr;
  state: TestVisitorState;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := LinkedList.New();
  n1 := NewItem(10); n2 := NewItem(20); n3 := NewItem(30);
  LinkedList.Append(list, n1);
  LinkedList.Append(list, n2);
  LinkedList.Append(list, n3);

  state.sum := 0; state.count := 0;
  LinkedList.Foreach(list, Visitor, state);
  IF (state.sum # 60) OR (state.count # 3) THEN pass := FALSE END;

  state.sum := 0; state.count := 0;
  LinkedList.Foreach(list, VisitorEarlyStop, state);
  IF (state.sum # 30) OR (state.count # 2) THEN pass := FALSE END;

  LinkedList.Free(list);
  RETURN pass
END TestForeach;

PROCEDURE TestGetAt(): BOOLEAN;
VAR
  list: LinkedList.List;
  n1, n2, n3: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := LinkedList.New();
  n1 := NewItem(10); n2 := NewItem(20); n3 := NewItem(30);
  LinkedList.Append(list, n1);
  LinkedList.Append(list, n2);
  LinkedList.Append(list, n3);

  success := LinkedList.GetAt(list, 0, result);
  IF ~success OR (result # n1) THEN pass := FALSE END;
  
  success := LinkedList.GetAt(list, 1, result);
  IF ~success OR (result # n2) THEN pass := FALSE END;
  
  success := LinkedList.GetAt(list, 2, result);
  IF ~success OR (result # n3) THEN pass := FALSE END;
  
  (* Test out of bounds access *)
  success := LinkedList.GetAt(list, -1, result);
  IF success THEN pass := FALSE END;
  
  success := LinkedList.GetAt(list, 3, result);
  IF success THEN pass := FALSE END;

  LinkedList.Free(list);
  RETURN pass
END TestGetAt;

PROCEDURE TestClear(): BOOLEAN;
VAR
  list: LinkedList.List;
  n1, n2, n3: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := LinkedList.New();
  n1 := NewItem(10); n2 := NewItem(20); n3 := NewItem(30);
  
  (* Add some items to the list *)
  LinkedList.Append(list, n1);
  LinkedList.Append(list, n2);
  LinkedList.Append(list, n3);
  
  (* Verify list has items *)
  IF LinkedList.Count(list) # 3 THEN pass := FALSE END;
  IF LinkedList.IsEmpty(list) THEN pass := FALSE END;
  
  (* Clear the list *)
  LinkedList.Clear(list);
  
  (* Verify list is now empty *)
  IF LinkedList.Count(list) # 0 THEN pass := FALSE END;
  IF ~LinkedList.IsEmpty(list) THEN pass := FALSE END;
  
  (* Verify that GetAt returns FALSE for any position *)
  success := LinkedList.GetAt(list, 0, result);
  IF success THEN pass := FALSE END;
  
  (* Verify that RemoveFirst returns NIL *)
  LinkedList.RemoveFirst(list, result);
  IF result # NIL THEN pass := FALSE END;
  
  (* Test that we can still append items after clearing *)
  LinkedList.Append(list, NewItem(100));
  IF LinkedList.Count(list) # 1 THEN pass := FALSE END;
  IF LinkedList.IsEmpty(list) THEN pass := FALSE END;
  
  (* Test clearing an already empty list *)
  LinkedList.Clear(list);
  LinkedList.Clear(list); (* Should not cause issues *)
  IF LinkedList.Count(list) # 0 THEN pass := FALSE END;
  IF ~LinkedList.IsEmpty(list) THEN pass := FALSE END;

  LinkedList.Free(list);
  RETURN pass
END TestClear;

BEGIN
  Tests.Init(ts, "LinkedList Tests");
  Tests.Add(ts, TestNewAndIsEmpty);
  Tests.Add(ts, TestAppendAndRemove);
  Tests.Add(ts, TestInsertAt);
  Tests.Add(ts, TestForeach);
  Tests.Add(ts, TestGetAt);
  Tests.Add(ts, TestClear);
  ASSERT(Tests.Run(ts));
END LinkedListTest.