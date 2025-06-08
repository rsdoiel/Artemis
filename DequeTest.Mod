(*
    DequeTest.Mod - Unit tests for Deque.Mod
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE DequeTest;

IMPORT Deque, Collections, Tests;

TYPE
    TestItem = RECORD (Collections.Item)
        value: INTEGER
    END;
    TestItemPtr = POINTER TO TestItem;
    TestVisitorState = RECORD (Collections.VisitorState)
        sum, count: INTEGER
    END;

VAR
    ts: Tests.TestSet;

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

PROCEDURE TestNewAndIsEmpty(): BOOLEAN;
VAR dq: Deque.Deque; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dq := Deque.New();
    IF ~Deque.IsEmpty(dq) THEN pass := FALSE END;
    IF Deque.Count(dq) # 0 THEN pass := FALSE END;
    Deque.Free(dq);
    RETURN pass
END TestNewAndIsEmpty;

PROCEDURE TestAppendAndRemove(): BOOLEAN;
VAR dq: Deque.Deque; a, b, c: TestItemPtr; res: Collections.ItemPtr; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dq := Deque.New();
    a := NewItem(1); b := NewItem(2); c := NewItem(3);
    Deque.Append(dq, a);
    Deque.Append(dq, b);
    Deque.Append(dq, c);
    IF Deque.IsEmpty(dq) THEN pass := FALSE END;
    IF Deque.Count(dq) # 3 THEN pass := FALSE END;
    Deque.RemoveFirst(dq, res);
    IF res # a THEN pass := FALSE END;
    Deque.RemoveLast(dq, res);
    IF res # c THEN pass := FALSE END;
    Deque.RemoveFirst(dq, res);
    IF res # b THEN pass := FALSE END;
    IF ~Deque.IsEmpty(dq) THEN pass := FALSE END;
    Deque.Free(dq);
    RETURN pass
END TestAppendAndRemove;

PROCEDURE TestPrependAndRemove(): BOOLEAN;
VAR dq: Deque.Deque; a, b, c: TestItemPtr; res: Collections.ItemPtr; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dq := Deque.New();
    a := NewItem(1); b := NewItem(2); c := NewItem(3);
    Deque.Prepend(dq, a);
    Deque.Prepend(dq, b);
    Deque.Prepend(dq, c);
    IF Deque.Count(dq) # 3 THEN pass := FALSE END;
    Deque.RemoveFirst(dq, res);
    IF res # c THEN pass := FALSE END;
    Deque.RemoveLast(dq, res);
    IF res # a THEN pass := FALSE END;
    Deque.RemoveFirst(dq, res);
    IF res # b THEN pass := FALSE END;
    IF ~Deque.IsEmpty(dq) THEN pass := FALSE END;
    Deque.Free(dq);
    RETURN pass
END TestPrependAndRemove;

PROCEDURE TestForeach(): BOOLEAN;
VAR dq: Deque.Deque; a, b, c: TestItemPtr;
    state: TestVisitorState; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dq := Deque.New();
    a := NewItem(1); b := NewItem(2); c := NewItem(3);
    Deque.Append(dq, a); Deque.Append(dq, b); Deque.Append(dq, c);
    state.sum := 0; state.count := 0;
    Deque.Foreach(dq, Visitor, state);
    IF (state.sum # 6) OR (state.count # 3) THEN pass := FALSE END;
    Deque.Free(dq);
    RETURN pass
END TestForeach;

BEGIN
    Tests.Init(ts, "Deque Tests");
    Tests.Add(ts, TestNewAndIsEmpty);
    Tests.Add(ts, TestAppendAndRemove);
    Tests.Add(ts, TestPrependAndRemove);
    Tests.Add(ts, TestForeach);
    ASSERT(Tests.Run(ts));
END DequeTest.
