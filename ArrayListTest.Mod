(** ArrayListTest.Mod - Tests for ArrayList.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE ArrayListTest;

IMPORT ArrayList, Collections, Tests;

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
VAR list: ArrayList.ArrayList; pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := ArrayList.New();
  IF ~ArrayList.IsEmpty(list) THEN pass := FALSE END;
  IF ArrayList.Count(list) # 0 THEN pass := FALSE END;
  ArrayList.Free(list);
  RETURN pass
END TestNewAndIsEmpty;

PROCEDURE TestAppendAndCount(): BOOLEAN;
VAR 
    list: ArrayList.ArrayList; 
    n1, n2, n3: TestItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := ArrayList.New();
  n1 := NewItem(1); n2 := NewItem(2); n3 := NewItem(3);

  success := ArrayList.Append(list, n1);
  IF ~success THEN pass := FALSE END;
  IF ArrayList.Count(list) # 1 THEN pass := FALSE END;

  success := ArrayList.Append(list, n2);
  IF ~success THEN pass := FALSE END;
  IF ArrayList.Count(list) # 2 THEN pass := FALSE END;

  success := ArrayList.Append(list, n3);
  IF ~success THEN pass := FALSE END;
  IF ArrayList.Count(list) # 3 THEN pass := FALSE END;

  (* Test access to appended items *)
  success := ArrayList.GetAt(list, 0, result);
  IF ~success OR (result # n1) THEN pass := FALSE END;

  success := ArrayList.GetAt(list, 1, result);
  IF ~success OR (result # n2) THEN pass := FALSE END;

  success := ArrayList.GetAt(list, 2, result);
  IF ~success OR (result # n3) THEN pass := FALSE END;

  ArrayList.Free(list);
  RETURN pass
END TestAppendAndCount;

PROCEDURE TestGetAtAndSetAt(): BOOLEAN;
VAR
  list: ArrayList.ArrayList;
  n1, n2, n3, n4: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := ArrayList.New();
  n1 := NewItem(10); n2 := NewItem(20); n3 := NewItem(30); n4 := NewItem(99);
  
  success := ArrayList.Append(list, n1);
  success := ArrayList.Append(list, n2);
  success := ArrayList.Append(list, n3);

  (* Test GetAt *)
  success := ArrayList.GetAt(list, 0, result);
  IF ~success OR (result # n1) THEN pass := FALSE END;
  
  success := ArrayList.GetAt(list, 1, result);
  IF ~success OR (result # n2) THEN pass := FALSE END;
  
  success := ArrayList.GetAt(list, 2, result);
  IF ~success OR (result # n3) THEN pass := FALSE END;
  
  (* Test out of bounds access *)
  success := ArrayList.GetAt(list, -1, result);
  IF success THEN pass := FALSE END;
  
  success := ArrayList.GetAt(list, 3, result);
  IF success THEN pass := FALSE END;

  (* Test SetAt *)
  success := ArrayList.SetAt(list, 1, n4);
  IF ~success THEN pass := FALSE END;
  
  success := ArrayList.GetAt(list, 1, result);
  IF ~success OR (result # n4) THEN pass := FALSE END;
  
  (* Test SetAt out of bounds *)
  success := ArrayList.SetAt(list, -1, n4);
  IF success THEN pass := FALSE END;
  
  success := ArrayList.SetAt(list, 3, n4);
  IF success THEN pass := FALSE END;

  ArrayList.Free(list);
  RETURN pass
END TestGetAtAndSetAt;

PROCEDURE TestForeach(): BOOLEAN;
VAR
  list: ArrayList.ArrayList;
  n1, n2, n3: TestItemPtr;
  state: TestVisitorState;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := ArrayList.New();
  n1 := NewItem(10); n2 := NewItem(20); n3 := NewItem(30);
  success := ArrayList.Append(list, n1);
  success := ArrayList.Append(list, n2);
  success := ArrayList.Append(list, n3);

  state.sum := 0; state.count := 0;
  ArrayList.Foreach(list, Visitor, state);
  IF (state.sum # 60) OR (state.count # 3) THEN pass := FALSE END;

  state.sum := 0; state.count := 0;
  ArrayList.Foreach(list, VisitorEarlyStop, state);
  IF (state.sum # 30) OR (state.count # 2) THEN pass := FALSE END;

  ArrayList.Free(list);
  RETURN pass
END TestForeach;

PROCEDURE TestClear(): BOOLEAN;
VAR
  list: ArrayList.ArrayList;
  n1, n2, n3: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := ArrayList.New();
  n1 := NewItem(10); n2 := NewItem(20); n3 := NewItem(30);
  
  (* Add some items to the list *)
  success := ArrayList.Append(list, n1);
  success := ArrayList.Append(list, n2);
  success := ArrayList.Append(list, n3);
  
  (* Verify list has items *)
  IF ArrayList.Count(list) # 3 THEN pass := FALSE END;
  IF ArrayList.IsEmpty(list) THEN pass := FALSE END;
  
  (* Clear the list *)
  ArrayList.Clear(list);
  
  (* Verify list is now empty *)
  IF ArrayList.Count(list) # 0 THEN pass := FALSE END;
  IF ~ArrayList.IsEmpty(list) THEN pass := FALSE END;
  
  (* Verify that GetAt returns FALSE for any position *)
  success := ArrayList.GetAt(list, 0, result);
  IF success THEN pass := FALSE END;
  
  (* Test that we can still append items after clearing *)
  success := ArrayList.Append(list, NewItem(100));
  IF ArrayList.Count(list) # 1 THEN pass := FALSE END;
  IF ArrayList.IsEmpty(list) THEN pass := FALSE END;
  
  (* Test clearing an already empty list *)
  ArrayList.Clear(list);
  ArrayList.Clear(list); (* Should not cause issues *)
  IF ArrayList.Count(list) # 0 THEN pass := FALSE END;
  IF ~ArrayList.IsEmpty(list) THEN pass := FALSE END;

  ArrayList.Free(list);
  RETURN pass
END TestClear;

PROCEDURE TestLargeList(): BOOLEAN;
VAR
  list: ArrayList.ArrayList;
  i: INTEGER;
  item: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := ArrayList.New();
  
  (* Add more items than fit in a single chunk (ChunkSize = 64) *)
  FOR i := 0 TO 99 DO
    item := NewItem(i);
    success := ArrayList.Append(list, item);
    IF ~success THEN pass := FALSE END
  END;
  
  (* Verify count *)
  IF ArrayList.Count(list) # 100 THEN pass := FALSE END;
  
  (* Verify we can access all items *)
  FOR i := 0 TO 99 DO
    success := ArrayList.GetAt(list, i, result);
    IF ~success OR (result(TestItemPtr).value # i) THEN pass := FALSE END
  END;
  
  (* Test setting items across chunks *)
  FOR i := 0 TO 99 DO
    item := NewItem(i * 2);
    success := ArrayList.SetAt(list, i, item);
    IF ~success THEN pass := FALSE END
  END;
  
  (* Verify the changes *)
  FOR i := 0 TO 99 DO
    success := ArrayList.GetAt(list, i, result);
    IF ~success OR (result(TestItemPtr).value # i * 2) THEN pass := FALSE END
  END;

  ArrayList.Free(list);
  RETURN pass
END TestLargeList;

PROCEDURE TestChunkBoundaries(): BOOLEAN;
VAR
  list: ArrayList.ArrayList;
  i: INTEGER;
  item: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := ArrayList.New();
  
  (* Add exactly one chunk worth of items (ChunkSize = 64) *)
  FOR i := 0 TO ArrayList.ChunkSize - 1 DO
    item := NewItem(i);
    success := ArrayList.Append(list, item);
    IF ~success THEN pass := FALSE END
  END;
  
  (* Verify count *)
  IF ArrayList.Count(list) # ArrayList.ChunkSize THEN pass := FALSE END;
  
  (* Add one more item to trigger a new chunk *)
  item := NewItem(ArrayList.ChunkSize);
  success := ArrayList.Append(list, item);
  IF ~success THEN pass := FALSE END;
  
  (* Verify count *)
  IF ArrayList.Count(list) # ArrayList.ChunkSize + 1 THEN pass := FALSE END;
  
  (* Verify we can access the item in the new chunk *)
  success := ArrayList.GetAt(list, ArrayList.ChunkSize, result);
  IF ~success OR (result(TestItemPtr).value # ArrayList.ChunkSize) THEN pass := FALSE END;
  
  (* Verify we can still access items in the first chunk *)
  success := ArrayList.GetAt(list, 0, result);
  IF ~success OR (result(TestItemPtr).value # 0) THEN pass := FALSE END;
  
  success := ArrayList.GetAt(list, ArrayList.ChunkSize - 1, result);
  IF ~success OR (result(TestItemPtr).value # ArrayList.ChunkSize - 1) THEN pass := FALSE END;

  ArrayList.Free(list);
  RETURN pass
END TestChunkBoundaries;

PROCEDURE TestEmptyListOperations(): BOOLEAN;
VAR
  list: ArrayList.ArrayList;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  state: TestVisitorState;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  list := ArrayList.New();
  
  (* Test operations on empty list *)
  success := ArrayList.GetAt(list, 0, result);
  IF success THEN pass := FALSE END;
  
  success := ArrayList.SetAt(list, 0, NewItem(42));
  IF success THEN pass := FALSE END;
  
  (* Test foreach on empty list *)
  state.sum := 0; state.count := 0;
  ArrayList.Foreach(list, Visitor, state);
  IF (state.sum # 0) OR (state.count # 0) THEN pass := FALSE END;
  
  (* Verify empty state *)
  IF ~ArrayList.IsEmpty(list) THEN pass := FALSE END;
  IF ArrayList.Count(list) # 0 THEN pass := FALSE END;

  ArrayList.Free(list);
  RETURN pass
END TestEmptyListOperations;

BEGIN
  Tests.Init(ts, "ArrayList Tests");
  Tests.Add(ts, TestNewAndIsEmpty);
  Tests.Add(ts, TestAppendAndCount);
  Tests.Add(ts, TestGetAtAndSetAt);
  Tests.Add(ts, TestForeach);
  Tests.Add(ts, TestClear);
  Tests.Add(ts, TestLargeList);
  Tests.Add(ts, TestChunkBoundaries);
  Tests.Add(ts, TestEmptyListOperations);
  ASSERT(Tests.Run(ts));
END ArrayListTest.
