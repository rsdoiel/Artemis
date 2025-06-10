(** QueueTest.Mod - Tests for Queue.Mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE QueueTest;

IMPORT Queue, Collections, Tests;

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
VAR queue: Queue.Queue; pass: BOOLEAN;
BEGIN
  pass := TRUE;
  queue := Queue.New();
  IF queue = NIL THEN pass := FALSE END;
  IF ~Queue.IsEmpty(queue) THEN pass := FALSE END;
  IF Queue.Count(queue) # 0 THEN pass := FALSE END;
  Queue.Free(queue);
  RETURN pass
END TestNewAndIsEmpty;

PROCEDURE TestEnqueueAndDequeue(): BOOLEAN;
VAR 
  queue: Queue.Queue; 
  item1, item2, item3: TestItemPtr;
  result: Collections.ItemPtr;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  queue := Queue.New();
  item1 := NewItem(10); item2 := NewItem(20); item3 := NewItem(30);

  (* Test enqueue operations *)
  Queue.Enqueue(queue, item1);
  IF Queue.Count(queue) # 1 THEN pass := FALSE END;
  IF Queue.IsEmpty(queue) THEN pass := FALSE END;

  Queue.Enqueue(queue, item2);
  IF Queue.Count(queue) # 2 THEN pass := FALSE END;

  Queue.Enqueue(queue, item3);
  IF Queue.Count(queue) # 3 THEN pass := FALSE END;

  (* Test FIFO order - should dequeue in insertion order *)
  Queue.Dequeue(queue, result);
  IF result = NIL THEN pass := FALSE END;
  IF result(TestItemPtr).value # 10 THEN pass := FALSE END;
  IF Queue.Count(queue) # 2 THEN pass := FALSE END;

  Queue.Dequeue(queue, result);
  IF result = NIL THEN pass := FALSE END;
  IF result(TestItemPtr).value # 20 THEN pass := FALSE END;
  IF Queue.Count(queue) # 1 THEN pass := FALSE END;

  Queue.Dequeue(queue, result);
  IF result = NIL THEN pass := FALSE END;
  IF result(TestItemPtr).value # 30 THEN pass := FALSE END;
  IF Queue.Count(queue) # 0 THEN pass := FALSE END;
  IF ~Queue.IsEmpty(queue) THEN pass := FALSE END;

  (* Test dequeue from empty queue *)
  Queue.Dequeue(queue, result);
  IF result # NIL THEN pass := FALSE END;

  Queue.Free(queue);
  RETURN pass
END TestEnqueueAndDequeue;

PROCEDURE TestFront(): BOOLEAN;
VAR
  queue: Queue.Queue;
  item1, item2, item3: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  queue := Queue.New();
  
  (* Test front on empty queue *)
  success := Queue.Front(queue, result);
  IF success THEN pass := FALSE END;
  IF result # NIL THEN pass := FALSE END;

  item1 := NewItem(100); item2 := NewItem(200); item3 := NewItem(300);
  
  (* Test front with one item *)
  Queue.Enqueue(queue, item1);
  success := Queue.Front(queue, result);
  IF ~success THEN pass := FALSE END;
  IF result = NIL THEN pass := FALSE END;
  IF result(TestItemPtr).value # 100 THEN pass := FALSE END;
  IF Queue.Count(queue) # 1 THEN pass := FALSE END; (* Front should not remove *)

  (* Test front with multiple items *)
  Queue.Enqueue(queue, item2);
  Queue.Enqueue(queue, item3);
  success := Queue.Front(queue, result);
  IF ~success THEN pass := FALSE END;
  IF result(TestItemPtr).value # 100 THEN pass := FALSE END; (* Still the first item *)
  IF Queue.Count(queue) # 3 THEN pass := FALSE END; (* No items removed *)

  (* Dequeue one item and test front again *)
  Queue.Dequeue(queue, result);
  success := Queue.Front(queue, result);
  IF ~success THEN pass := FALSE END;
  IF result(TestItemPtr).value # 200 THEN pass := FALSE END; (* Now second item is front *)

  Queue.Free(queue);
  RETURN pass
END TestFront;

PROCEDURE TestForeach(): BOOLEAN;
VAR
  queue: Queue.Queue;
  item1, item2, item3: TestItemPtr;
  state: TestVisitorState;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  queue := Queue.New();

  (* Test foreach on empty queue *)
  state.sum := 0; state.count := 0;
  Queue.Foreach(queue, Visitor, state);
  IF (state.sum # 0) OR (state.count # 0) THEN pass := FALSE END;

  (* Test foreach with items *)
  item1 := NewItem(10); item2 := NewItem(20); item3 := NewItem(30);
  Queue.Enqueue(queue, item1);
  Queue.Enqueue(queue, item2);
  Queue.Enqueue(queue, item3);

  state.sum := 0; state.count := 0;
  Queue.Foreach(queue, Visitor, state);
  IF (state.sum # 60) OR (state.count # 3) THEN pass := FALSE END;

  (* Test early stop visitor *)
  state.sum := 0; state.count := 0;
  Queue.Foreach(queue, VisitorEarlyStop, state);
  IF (state.sum # 30) OR (state.count # 2) THEN pass := FALSE END;

  Queue.Free(queue);
  RETURN pass
END TestForeach;

PROCEDURE TestClear(): BOOLEAN;
VAR
  queue: Queue.Queue;
  item1, item2, item3: TestItemPtr;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  queue := Queue.New();
  item1 := NewItem(10); item2 := NewItem(20); item3 := NewItem(30);
  
  (* Add some items to the queue *)
  Queue.Enqueue(queue, item1);
  Queue.Enqueue(queue, item2);
  Queue.Enqueue(queue, item3);
  
  (* Verify queue has items *)
  IF Queue.Count(queue) # 3 THEN pass := FALSE END;
  IF Queue.IsEmpty(queue) THEN pass := FALSE END;
  
  (* Clear the queue *)
  Queue.Clear(queue);
  
  (* Verify queue is now empty *)
  IF Queue.Count(queue) # 0 THEN pass := FALSE END;
  IF ~Queue.IsEmpty(queue) THEN pass := FALSE END;
  
  (* Dequeue returns NIL *)
  Queue.Dequeue(queue, result);
  IF result # NIL THEN pass := FALSE END;
  
  (* Front returns FALSE *)
  success := Queue.Front(queue, result);
  IF success THEN pass := FALSE END;
  
  (* Test that we can still enqueue items after clearing *)
  Queue.Enqueue(queue, NewItem(100));
  IF Queue.Count(queue) # 1 THEN pass := FALSE END;
  IF Queue.IsEmpty(queue) THEN pass := FALSE END;

  Queue.Free(queue);
  RETURN pass
END TestClear;

PROCEDURE TestLargeQueue(): BOOLEAN;
VAR
  queue: Queue.Queue;
  item: TestItemPtr;
  result: Collections.ItemPtr;
  i: INTEGER;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  queue := Queue.New();
  
  (* Add many items *)
  FOR i := 1 TO 1000 DO
    item := NewItem(i);
    Queue.Enqueue(queue, item)
  END;
  
  IF Queue.Count(queue) # 1000 THEN pass := FALSE END;
  IF Queue.IsEmpty(queue) THEN pass := FALSE END;
  
  (* Dequeue all items and verify FIFO order *)
  FOR i := 1 TO 1000 DO
    Queue.Dequeue(queue, result);
    IF result = NIL THEN pass := FALSE END;
    IF result(TestItemPtr).value # i THEN pass := FALSE END
  END;
  
  IF Queue.Count(queue) # 0 THEN pass := FALSE END;
  IF ~Queue.IsEmpty(queue) THEN pass := FALSE END;

  Queue.Free(queue);
  RETURN pass
END TestLargeQueue;

PROCEDURE TestMixedOperations(): BOOLEAN;
VAR
  queue: Queue.Queue;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  queue := Queue.New();
  
  (* Mix enqueue and dequeue operations *)
  Queue.Enqueue(queue, NewItem(1));
  Queue.Enqueue(queue, NewItem(2));
  
  Queue.Dequeue(queue, result);
  IF result(TestItemPtr).value # 1 THEN pass := FALSE END;
  
  Queue.Enqueue(queue, NewItem(3));
  Queue.Enqueue(queue, NewItem(4));
  
  success := Queue.Front(queue, result);
  IF ~success OR (result(TestItemPtr).value # 2) THEN pass := FALSE END;
  
  Queue.Dequeue(queue, result);
  IF result(TestItemPtr).value # 2 THEN pass := FALSE END;
  
  Queue.Dequeue(queue, result);
  IF result(TestItemPtr).value # 3 THEN pass := FALSE END;
  
  IF Queue.Count(queue) # 1 THEN pass := FALSE END;
  
  Queue.Dequeue(queue, result);
  IF result(TestItemPtr).value # 4 THEN pass := FALSE END;
  
  IF ~Queue.IsEmpty(queue) THEN pass := FALSE END;

  Queue.Free(queue);
  RETURN pass
END TestMixedOperations;

PROCEDURE TestEmptyQueueOperations(): BOOLEAN;
VAR
  queue: Queue.Queue;
  result: Collections.ItemPtr;
  success: BOOLEAN;
  state: TestVisitorState;
  pass: BOOLEAN;
BEGIN
  pass := TRUE;
  queue := Queue.New();
  
  (* Test operations on empty queue *)
  Queue.Dequeue(queue, result);
  IF result # NIL THEN pass := FALSE END;
  
  success := Queue.Front(queue, result);
  IF success THEN pass := FALSE END;
  
  (* Test foreach on empty queue *)
  state.sum := 0; state.count := 0;
  Queue.Foreach(queue, Visitor, state);
  IF (state.sum # 0) OR (state.count # 0) THEN pass := FALSE END;
  
  (* Verify empty state *)
  IF ~Queue.IsEmpty(queue) THEN pass := FALSE END;
  IF Queue.Count(queue) # 0 THEN pass := FALSE END;

  Queue.Free(queue);
  RETURN pass
END TestEmptyQueueOperations;

BEGIN
  Tests.Init(ts, "Queue Tests");
  Tests.Add(ts, TestNewAndIsEmpty);
  Tests.Add(ts, TestEnqueueAndDequeue);
  Tests.Add(ts, TestFront);
  Tests.Add(ts, TestForeach);
  Tests.Add(ts, TestClear);
  Tests.Add(ts, TestLargeQueue);
  Tests.Add(ts, TestMixedOperations);
  Tests.Add(ts, TestEmptyQueueOperations);
  ASSERT(Tests.Run(ts));
END QueueTest.
