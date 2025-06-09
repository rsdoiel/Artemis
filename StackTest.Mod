(** StackTest.Mod - Tests for Stack.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE StackTest;

IMPORT Stack, Collections, Tests;

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
VAR stack: Stack.Stack; pass: BOOLEAN;
BEGIN
  pass := TRUE;
  stack := Stack.New();
  IF stack = NIL THEN pass := FALSE END;
  IF ~Stack.IsEmpty(stack) THEN pass := FALSE END;
  IF Stack.Count(stack) # 0 THEN pass := FALSE END;
  Stack.Free(stack);
  RETURN pass
END TestNewAndIsEmpty;

PROCEDURE TestPushAndPop(): BOOLEAN;
VAR 
  stack: Stack.Stack; 
  item1, item2, item3: TestItemPtr;
  result: Collections.ItemPtr;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  stack := Stack.New();
  item1 := NewItem(10); item2 := NewItem(20); item3 := NewItem(30);

  (* Test push operations *)
  Stack.Push(stack, item1);
  IF Stack.Count(stack) # 1 THEN pass := FALSE END;
  IF Stack.IsEmpty(stack) THEN pass := FALSE END;

  Stack.Push(stack, item2);
  IF Stack.Count(stack) # 2 THEN pass := FALSE END;

  Stack.Push(stack, item3);
  IF Stack.Count(stack) # 3 THEN pass := FALSE END;

  (* Test LIFO order - should pop in reverse order *)
  Stack.Pop(stack, result);
  IF result = NIL THEN pass := FALSE END;
  IF result(TestItemPtr).value # 30 THEN pass := FALSE END;
  IF Stack.Count(stack) # 2 THEN pass := FALSE END;

  Stack.Pop(stack, result);
  IF result = NIL THEN pass := FALSE END;
  IF result(TestItemPtr).value # 20 THEN pass := FALSE END;
  IF Stack.Count(stack) # 1 THEN pass := FALSE END;

  Stack.Pop(stack, result);
  IF result = NIL THEN pass := FALSE END;
  IF result(TestItemPtr).value # 10 THEN pass := FALSE END;
  IF Stack.Count(stack) # 0 THEN pass := FALSE END;
  IF ~Stack.IsEmpty(stack) THEN pass := FALSE END;

  (* Test pop from empty stack *)
  Stack.Pop(stack, result);
  IF result # NIL THEN pass := FALSE END;

  Stack.Free(stack);
  RETURN pass
END TestPushAndPop;

PROCEDURE TestTop(): BOOLEAN;
VAR
  stack: Stack.Stack;
  item1, item2: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  stack := Stack.New();

  (* Test top on empty stack *)
  success := Stack.Top(stack, result);
  IF success THEN pass := FALSE END;
  IF result # NIL THEN pass := FALSE END;

  (* Test top with one item *)
  item1 := NewItem(42);
  Stack.Push(stack, item1);

  success := Stack.Top(stack, result);
  IF ~success THEN pass := FALSE END;
  IF result = NIL THEN pass := FALSE END;
  IF result(TestItemPtr).value # 42 THEN pass := FALSE END;
  IF Stack.Count(stack) # 1 THEN pass := FALSE END;

  (* Test top with multiple items *)
  item2 := NewItem(84);
  Stack.Push(stack, item2);

  success := Stack.Top(stack, result);
  IF ~success THEN pass := FALSE END;
  IF result(TestItemPtr).value # 84 THEN pass := FALSE END;
  IF Stack.Count(stack) # 2 THEN pass := FALSE END;

  (* Verify multiple calls to Top return same item *)
  success := Stack.Top(stack, result);
  IF result(TestItemPtr).value # 84 THEN pass := FALSE END;

  Stack.Free(stack);
  RETURN pass
END TestTop;

PROCEDURE TestForeach(): BOOLEAN;
VAR
  stack: Stack.Stack;
  item1, item2, item3: TestItemPtr;
  state: TestVisitorState;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  stack := Stack.New();

  (* Test foreach on empty stack *)
  state.sum := 0; state.count := 0;
  Stack.Foreach(stack, Visitor, state);
  IF (state.sum # 0) OR (state.count # 0) THEN pass := FALSE END;

  (* Test foreach with items *)
  item1 := NewItem(10); item2 := NewItem(20); item3 := NewItem(30);
  Stack.Push(stack, item1);
  Stack.Push(stack, item2);
  Stack.Push(stack, item3);

  state.sum := 0; state.count := 0;
  Stack.Foreach(stack, Visitor, state);
  IF (state.sum # 60) OR (state.count # 3) THEN pass := FALSE END;

  (* Test early stop visitor *)
  state.sum := 0; state.count := 0;
  Stack.Foreach(stack, VisitorEarlyStop, state);
  IF (state.sum # 50) OR (state.count # 2) THEN pass := FALSE END;

  Stack.Free(stack);
  RETURN pass
END TestForeach;

PROCEDURE TestClear(): BOOLEAN;
VAR
  stack: Stack.Stack;
  item1, item2, item3: TestItemPtr;
  result: Collections.ItemPtr;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  stack := Stack.New();

  (* Add some items to the stack *)
  item1 := NewItem(10); item2 := NewItem(20); item3 := NewItem(30);
  Stack.Push(stack, item1);
  Stack.Push(stack, item2);
  Stack.Push(stack, item3);

  (* Verify stack has items *)
  IF Stack.Count(stack) # 3 THEN pass := FALSE END;
  IF Stack.IsEmpty(stack) THEN pass := FALSE END;

  (* Clear the stack *)
  Stack.Clear(stack);

  (* Verify stack is now empty *)
  IF Stack.Count(stack) # 0 THEN pass := FALSE END;
  IF ~Stack.IsEmpty(stack) THEN pass := FALSE END;

  (* Pop returns NIL *)
  Stack.Pop(stack, result);
  IF result # NIL THEN pass := FALSE END;

  (* Test that we can still push items after clearing *)
  Stack.Push(stack, NewItem(100));
  IF Stack.Count(stack) # 1 THEN pass := FALSE END;

  Stack.Free(stack);
  RETURN pass
END TestClear;

PROCEDURE TestLIFOSemantics(): BOOLEAN;
VAR
  stack: Stack.Stack;
  i: INTEGER;
  item: TestItemPtr;
  result: Collections.ItemPtr;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  stack := Stack.New();

  (* Push numbers 1 through 10 *)
  FOR i := 1 TO 10 DO
    item := NewItem(i);
    Stack.Push(stack, item)
  END;

  IF Stack.Count(stack) # 10 THEN pass := FALSE END;

  (* Pop and verify LIFO order (10, 9, 8, ..., 1) *)
  FOR i := 10 TO 1 BY -1 DO
    Stack.Pop(stack, result);
    IF result = NIL THEN pass := FALSE END;
    IF result(TestItemPtr).value # i THEN pass := FALSE END
  END;

  IF ~Stack.IsEmpty(stack) THEN pass := FALSE END;

  Stack.Free(stack);
  RETURN pass
END TestLIFOSemantics;

BEGIN
  Tests.Init(ts, "Stack Tests");
  Tests.Add(ts, TestNewAndIsEmpty);
  Tests.Add(ts, TestPushAndPop);
  Tests.Add(ts, TestTop);
  Tests.Add(ts, TestForeach);
  Tests.Add(ts, TestClear);
  Tests.Add(ts, TestLIFOSemantics);
  ASSERT(Tests.Run(ts))
END StackTest.
