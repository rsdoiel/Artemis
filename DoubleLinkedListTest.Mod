(** DoubleLinkedListTest.Mod - Tests for DoubleLinkedList.Mod.

Copyright (C) 2025
Released under The 3-Clause BSD License.
*)

MODULE DoubleLinkedListTest;

IMPORT DoubleLinkedList, Collections, Tests;

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

PROCEDURE NewItem(val: INTEGER): TestItemPtr;
VAR item: TestItemPtr;
BEGIN
  NEW(item);
  item.value := val;
  RETURN item
END NewItem;

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

PROCEDURE TestNewAndIsEmpty(): BOOLEAN;
VAR list: DoubleLinkedList.List; pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := DoubleLinkedList.New();
  IF ~DoubleLinkedList.IsEmpty(list) THEN pass := FALSE END;
  IF DoubleLinkedList.Count(list) # 0 THEN pass := FALSE END;
  DoubleLinkedList.Free(list);
  RETURN pass
END TestNewAndIsEmpty;

PROCEDURE TestAppendAndRemove(): BOOLEAN;
VAR 
    list: DoubleLinkedList.List; 
    n1, n2, n3: TestItemPtr;
    out: Collections.ItemPtr;
    pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := DoubleLinkedList.New();
  n1 := NewItem(1); n2 := NewItem(2); n3 := NewItem(3);

  DoubleLinkedList.Append(list, n1);
  IF DoubleLinkedList.Count(list) # 1 THEN pass := FALSE END;

  DoubleLinkedList.Append(list, n2);
  IF DoubleLinkedList.Count(list) # 2 THEN pass := FALSE END;

  DoubleLinkedList.Append(list, n3);
  IF DoubleLinkedList.Count(list) # 3 THEN pass := FALSE END;

  DoubleLinkedList.RemoveFirst(list, out);
  IF out # n1 THEN pass := FALSE END;
  IF DoubleLinkedList.Count(list) # 2 THEN pass := FALSE END;

  DoubleLinkedList.RemoveLast(list, out);
  IF out # n3 THEN pass := FALSE END;
  IF DoubleLinkedList.Count(list) # 1 THEN pass := FALSE END;

  DoubleLinkedList.RemoveFirst(list, out);
  IF out # n2 THEN pass := FALSE END;
  IF DoubleLinkedList.Count(list) # 0 THEN pass := FALSE END;

  DoubleLinkedList.RemoveFirst(list, out);
  IF out # NIL THEN pass := FALSE END;
  IF DoubleLinkedList.Count(list) # 0 THEN pass := FALSE END;

  DoubleLinkedList.Free(list);
  RETURN pass
END TestAppendAndRemove;

PROCEDURE TestIsEmpty(): BOOLEAN;
VAR 
    list: DoubleLinkedList.List; 
    n: TestItemPtr; 
    out: Collections.ItemPtr;
    pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := DoubleLinkedList.New();
  IF ~DoubleLinkedList.IsEmpty(list) THEN pass := FALSE END;
  n := NewItem(42);
  DoubleLinkedList.Append(list, n);
  IF DoubleLinkedList.IsEmpty(list) THEN pass := FALSE END;
  DoubleLinkedList.RemoveFirst(list, out);
  IF ~DoubleLinkedList.IsEmpty(list) THEN pass := FALSE END;
  DoubleLinkedList.Free(list);
  RETURN pass
END TestIsEmpty;

PROCEDURE TestInsertAt(): BOOLEAN;
VAR
  list: DoubleLinkedList.List;
  n1, n2, n3, n4, n5: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := DoubleLinkedList.New();
  n1 := NewItem(1); n2 := NewItem(2); n3 := NewItem(3); n4 := NewItem(4); n5 := NewItem(5);

  DoubleLinkedList.Append(list, n1);
  DoubleLinkedList.Append(list, n2);
  DoubleLinkedList.Append(list, n4); (* List: n1 -> n2 -> n4 *)

  (* Insert n3 at position 2 (between n2 and n4): n1 -> n2 -> n3 -> n4 *)
  success := DoubleLinkedList.InsertAt(list, 2, n3);
  IF ~success THEN pass := FALSE END;
  IF DoubleLinkedList.Count(list) # 4 THEN pass := FALSE END;
  
  (* Verify insertion using GetAt *)
  success := DoubleLinkedList.GetAt(list, 2, result);
  IF ~success OR (result # n3) THEN pass := FALSE END;

  (* Insert at the beginning *)
  success := DoubleLinkedList.InsertAt(list, 0, n5);
  IF ~success THEN pass := FALSE END;
  IF DoubleLinkedList.Count(list) # 5 THEN pass := FALSE END;
  
  success := DoubleLinkedList.GetAt(list, 0, result);
  IF ~success OR (result # n5) THEN pass := FALSE END;

  (* Insert at invalid position *)
  success := DoubleLinkedList.InsertAt(list, 10, NewItem(99));
  IF success THEN pass := FALSE END;
  IF DoubleLinkedList.Count(list) # 5 THEN pass := FALSE END;

  DoubleLinkedList.Free(list);
  RETURN pass
END TestInsertAt;

PROCEDURE TestForeach(): BOOLEAN;
VAR
  list: DoubleLinkedList.List;
  n1, n2, n3: TestItemPtr;
  state: TestVisitorState;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := DoubleLinkedList.New();
  n1 := NewItem(10); n2 := NewItem(20); n3 := NewItem(30);
  DoubleLinkedList.Append(list, n1);
  DoubleLinkedList.Append(list, n2);
  DoubleLinkedList.Append(list, n3);

  state.sum := 0; state.count := 0;
  DoubleLinkedList.Foreach(list, Visitor, state);
  IF (state.sum # 60) OR (state.count # 3) THEN pass := FALSE END;

  state.sum := 0; state.count := 0;
  DoubleLinkedList.Foreach(list, VisitorEarlyStop, state);
  IF (state.sum # 30) OR (state.count # 2) THEN pass := FALSE END;

  DoubleLinkedList.Free(list);
  RETURN pass
END TestForeach;

PROCEDURE TestGetAt(): BOOLEAN;
VAR
  list: DoubleLinkedList.List;
  n1, n2, n3: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := DoubleLinkedList.New();
  n1 := NewItem(10); n2 := NewItem(20); n3 := NewItem(30);
  DoubleLinkedList.Append(list, n1);
  DoubleLinkedList.Append(list, n2);
  DoubleLinkedList.Append(list, n3);

  success := DoubleLinkedList.GetAt(list, 0, result);
  IF ~success OR (result # n1) THEN pass := FALSE END;
  
  success := DoubleLinkedList.GetAt(list, 1, result);
  IF ~success OR (result # n2) THEN pass := FALSE END;
  
  success := DoubleLinkedList.GetAt(list, 2, result);
  IF ~success OR (result # n3) THEN pass := FALSE END;
  
  (* Test out of bounds access *)
  success := DoubleLinkedList.GetAt(list, -1, result);
  IF success THEN pass := FALSE END;
  
  success := DoubleLinkedList.GetAt(list, 3, result);
  IF success THEN pass := FALSE END;

  DoubleLinkedList.Free(list);
  RETURN pass
END TestGetAt;

PROCEDURE TestHeadTail(): BOOLEAN;
VAR
  list: DoubleLinkedList.List;
  n1, n2, n3: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := DoubleLinkedList.New();
  
  (* Test empty list *)
  success := DoubleLinkedList.Head(list, result);
  IF success THEN pass := FALSE END;
  
  success := DoubleLinkedList.Tail(list, result);
  IF success THEN pass := FALSE END;
  
  (* Test with items *)
  n1 := NewItem(10); n2 := NewItem(20); n3 := NewItem(30);
  DoubleLinkedList.Append(list, n1);
  DoubleLinkedList.Append(list, n2);
  DoubleLinkedList.Append(list, n3);

  success := DoubleLinkedList.Head(list, result);
  IF ~success OR (result # n1) THEN pass := FALSE END;
  
  success := DoubleLinkedList.Tail(list, result);
  IF ~success OR (result # n3) THEN pass := FALSE END;

  DoubleLinkedList.Free(list);
  RETURN pass
END TestHeadTail;

PROCEDURE TestClear(): BOOLEAN;
VAR
  list: DoubleLinkedList.List;
  n1, n2, n3: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := DoubleLinkedList.New();
  n1 := NewItem(10); n2 := NewItem(20); n3 := NewItem(30);
  
  (* Add some items to the list *)
  DoubleLinkedList.Append(list, n1);
  DoubleLinkedList.Append(list, n2);
  DoubleLinkedList.Append(list, n3);
  
  (* Verify list has items *)
  IF DoubleLinkedList.Count(list) # 3 THEN pass := FALSE END;
  IF DoubleLinkedList.IsEmpty(list) THEN pass := FALSE END;
  
  (* Clear the list *)
  DoubleLinkedList.Clear(list);
  
  (* Verify list is now empty *)
  IF DoubleLinkedList.Count(list) # 0 THEN pass := FALSE END;
  IF ~DoubleLinkedList.IsEmpty(list) THEN pass := FALSE END;
  
  (* Verify that GetAt returns FALSE for any position *)
  success := DoubleLinkedList.GetAt(list, 0, result);
  IF success THEN pass := FALSE END;
  
  (* Verify that RemoveFirst returns NIL *)
  DoubleLinkedList.RemoveFirst(list, result);
  IF result # NIL THEN pass := FALSE END;
  
  (* Test that we can still append items after clearing *)
  DoubleLinkedList.Append(list, NewItem(100));
  IF DoubleLinkedList.Count(list) # 1 THEN pass := FALSE END;
  IF DoubleLinkedList.IsEmpty(list) THEN pass := FALSE END;
  
  (* Test clearing an already empty list *)
  DoubleLinkedList.Clear(list);
  DoubleLinkedList.Clear(list); (* Should not cause issues *)
  IF DoubleLinkedList.Count(list) # 0 THEN pass := FALSE END;
  IF ~DoubleLinkedList.IsEmpty(list) THEN pass := FALSE END;

  DoubleLinkedList.Free(list);
  RETURN pass
END TestClear;

BEGIN
  Tests.Init(ts, "DoubleLinkedList Tests");
  Tests.Add(ts, TestNewAndIsEmpty);
  Tests.Add(ts, TestAppendAndRemove);
  Tests.Add(ts, TestIsEmpty);
  Tests.Add(ts, TestInsertAt);
  Tests.Add(ts, TestForeach);
  Tests.Add(ts, TestGetAt);
  Tests.Add(ts, TestHeadTail);
  Tests.Add(ts, TestClear);
  ASSERT(Tests.Run(ts));
END DoubleLinkedListTest.
