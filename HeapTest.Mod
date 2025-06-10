(**
    HeapTest.Mod - Unit tests for Heap.Mod
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE HeapTest;

IMPORT Heap, Collections, Tests;

TYPE
    TestItem = RECORD (Collections.Item)
        value: INTEGER;
        priority: INTEGER
    END;
    TestItemPtr = POINTER TO TestItem;
    
    TestVisitorState = RECORD (Collections.VisitorState)
        sum, count: INTEGER
    END;

VAR
    ts: Tests.TestSet;

(** Create a new test item with value and priority *)
PROCEDURE NewItem(value, priority: INTEGER): TestItemPtr;
VAR item: TestItemPtr;
BEGIN
    NEW(item);
    item.value := value;
    item.priority := priority;
    RETURN item
END NewItem;

(** Comparison function for min-heap based on priority *)
PROCEDURE MinCompare(left, right: Collections.ItemPtr): BOOLEAN;
VAR 
    leftItem, rightItem: TestItemPtr;
    result: BOOLEAN;
BEGIN
    leftItem := left(TestItemPtr);
    rightItem := right(TestItemPtr);
    result := leftItem.priority < rightItem.priority;
    RETURN result
END MinCompare;

(** Comparison function for max-heap based on priority *)
PROCEDURE MaxCompare(left, right: Collections.ItemPtr): BOOLEAN;
VAR 
    leftItem, rightItem: TestItemPtr;
    result: BOOLEAN;
BEGIN
    leftItem := left(TestItemPtr);
    rightItem := right(TestItemPtr);
    result := leftItem.priority > rightItem.priority;
    RETURN result
END MaxCompare;

(** Visitor procedure for testing iteration *)
PROCEDURE SumVisitor(item: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
BEGIN
    state(TestVisitorState).sum := state(TestVisitorState).sum + item(TestItemPtr).value;
    INC(state(TestVisitorState).count);
    RETURN TRUE
END SumVisitor;

PROCEDURE TestNewAndFree*(): BOOLEAN;
VAR 
    heap: Heap.Heap;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    
    heap := Heap.New(MinCompare);
    Tests.ExpectedBool(TRUE, heap # NIL, "Heap.New should return non-nil", pass);
    Tests.ExpectedBool(TRUE, Heap.IsEmpty(heap), "New heap should be empty", pass);
    Tests.ExpectedInt(0, Heap.Count(heap), "New heap should have count 0", pass);
    
    Heap.Free(heap);
    Tests.ExpectedBool(TRUE, heap = NIL, "Heap.Free should set heap to NIL", pass);
    
    RETURN pass
END TestNewAndFree;

PROCEDURE TestInsertAndPeek*(): BOOLEAN;
VAR 
    heap: Heap.Heap;
    item1, item2, item3, peeked: TestItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    heap := Heap.New(MinCompare);
    
    (* Test insert and peek *)
    item1 := NewItem(100, 5);
    item2 := NewItem(200, 3);
    item3 := NewItem(300, 7);
    
    success := Heap.Insert(heap, item1);
    Tests.ExpectedBool(TRUE, success, "Insert should succeed", pass);
    Tests.ExpectedInt(1, Heap.Count(heap), "Count should be 1 after insert", pass);
    Tests.ExpectedBool(FALSE, Heap.IsEmpty(heap), "Heap should not be empty", pass);
    
    success := Heap.PeekMin(heap, result);
    Tests.ExpectedBool(TRUE, success, "PeekMin should succeed", pass);
    peeked := result(TestItemPtr);
    Tests.ExpectedInt(5, peeked.priority, "Min should have priority 5", pass);
    Tests.ExpectedInt(100, peeked.value, "Min should have value 100", pass);
    
    (* Insert item with lower priority *)
    success := Heap.Insert(heap, item2);
    Tests.ExpectedBool(TRUE, success, "Second insert should succeed", pass);
    Tests.ExpectedInt(2, Heap.Count(heap), "Count should be 2", pass);
    
    success := Heap.PeekMin(heap, result);
    Tests.ExpectedBool(TRUE, success, "PeekMin should succeed", pass);
    peeked := result(TestItemPtr);
    Tests.ExpectedInt(3, peeked.priority, "Min should now have priority 3", pass);
    Tests.ExpectedInt(200, peeked.value, "Min should have value 200", pass);
    
    (* Insert item with higher priority *)
    success := Heap.Insert(heap, item3);
    Tests.ExpectedBool(TRUE, success, "Third insert should succeed", pass);
    Tests.ExpectedInt(3, Heap.Count(heap), "Count should be 3", pass);
    
    success := Heap.PeekMin(heap, result);
    Tests.ExpectedBool(TRUE, success, "PeekMin should succeed", pass);
    peeked := result(TestItemPtr);
    Tests.ExpectedInt(3, peeked.priority, "Min should still have priority 3", pass);
    
    Heap.Free(heap);
    RETURN pass
END TestInsertAndPeek;

PROCEDURE TestExtractMin*(): BOOLEAN;
VAR 
    heap: Heap.Heap;
    item1, item2, item3, extracted: TestItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    heap := Heap.New(MinCompare);
    
    (* Insert items with different priorities *)
    item1 := NewItem(100, 5);
    item2 := NewItem(200, 2);
    item3 := NewItem(300, 8);
    
    success := Heap.Insert(heap, item1);
    ASSERT(success);
    success := Heap.Insert(heap, item2);
    ASSERT(success);
    success := Heap.Insert(heap, item3);
    ASSERT(success);
    
    (* Extract minimum (should be item2 with priority 2) *)
    success := Heap.ExtractMin(heap, result);
    Tests.ExpectedBool(TRUE, success, "ExtractMin should succeed", pass);
    extracted := result(TestItemPtr);
    Tests.ExpectedInt(2, extracted.priority, "Extracted should have priority 2", pass);
    Tests.ExpectedInt(200, extracted.value, "Extracted should have value 200", pass);
    Tests.ExpectedInt(2, Heap.Count(heap), "Count should be 2 after extraction", pass);
    
    (* Extract next minimum (should be item1 with priority 5) *)
    success := Heap.ExtractMin(heap, result);
    Tests.ExpectedBool(TRUE, success, "Second ExtractMin should succeed", pass);
    extracted := result(TestItemPtr);
    Tests.ExpectedInt(5, extracted.priority, "Extracted should have priority 5", pass);
    Tests.ExpectedInt(100, extracted.value, "Extracted should have value 100", pass);
    Tests.ExpectedInt(1, Heap.Count(heap), "Count should be 1 after extraction", pass);
    
    (* Extract last item (should be item3 with priority 8) *)
    success := Heap.ExtractMin(heap, result);
    Tests.ExpectedBool(TRUE, success, "Third ExtractMin should succeed", pass);
    extracted := result(TestItemPtr);
    Tests.ExpectedInt(8, extracted.priority, "Extracted should have priority 8", pass);
    Tests.ExpectedInt(300, extracted.value, "Extracted should have value 300", pass);
    Tests.ExpectedInt(0, Heap.Count(heap), "Count should be 0 after extraction", pass);
    Tests.ExpectedBool(TRUE, Heap.IsEmpty(heap), "Heap should be empty", pass);
    
    (* Try to extract from empty heap *)
    success := Heap.ExtractMin(heap, result);
    Tests.ExpectedBool(FALSE, success, "ExtractMin from empty heap should fail", pass);
    
    Heap.Free(heap);
    RETURN pass
END TestExtractMin;

PROCEDURE TestMaxHeap*(): BOOLEAN;
VAR 
    heap: Heap.Heap;
    item1, item2, item3, extracted: TestItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    heap := Heap.New(MaxCompare); (* Use max-heap comparison *)
    
    (* Insert items with different priorities *)
    item1 := NewItem(100, 5);
    item2 := NewItem(200, 2);
    item3 := NewItem(300, 8);
    
    success := Heap.Insert(heap, item1);
    ASSERT(success);
    success := Heap.Insert(heap, item2);
    ASSERT(success);
    success := Heap.Insert(heap, item3);
    ASSERT(success);
    
    (* For max-heap, ExtractMin actually extracts maximum *)
    success := Heap.ExtractMin(heap, result);
    Tests.ExpectedBool(TRUE, success, "ExtractMin should succeed", pass);
    extracted := result(TestItemPtr);
    Tests.ExpectedInt(8, extracted.priority, "Max-heap should extract priority 8 first", pass);
    
    success := Heap.ExtractMin(heap, result);
    Tests.ExpectedBool(TRUE, success, "Second ExtractMin should succeed", pass);
    extracted := result(TestItemPtr);
    Tests.ExpectedInt(5, extracted.priority, "Max-heap should extract priority 5 second", pass);
    
    success := Heap.ExtractMin(heap, result);
    Tests.ExpectedBool(TRUE, success, "Third ExtractMin should succeed", pass);
    extracted := result(TestItemPtr);
    Tests.ExpectedInt(2, extracted.priority, "Max-heap should extract priority 2 last", pass);
    
    Heap.Free(heap);
    RETURN pass
END TestMaxHeap;

PROCEDURE TestLargeDataset*(): BOOLEAN;
VAR 
    heap: Heap.Heap;
    item: TestItemPtr;
    result: Collections.ItemPtr;
    extracted: TestItemPtr;
    success: BOOLEAN;
    pass: BOOLEAN;
    i, lastPriority: INTEGER;
BEGIN
    pass := TRUE;
    heap := Heap.New(MinCompare);
    
    (* Insert items with random priorities *)
    FOR i := 0 TO 99 DO
        item := NewItem(i, (i * 17 + 23) MOD 100); (* Pseudo-random priorities *)
        success := Heap.Insert(heap, item);
        ASSERT(success)
    END;
    
    Tests.ExpectedInt(100, Heap.Count(heap), "Should have 100 items", pass);
    
    (* Extract all items and verify they come out in sorted order *)
    lastPriority := -1;
    FOR i := 0 TO 99 DO
        success := Heap.ExtractMin(heap, result);
        Tests.ExpectedBool(TRUE, success, "ExtractMin should succeed", pass);
        extracted := result(TestItemPtr);
        Tests.ExpectedBool(TRUE, extracted.priority >= lastPriority, "Priority should be non-decreasing", pass);
        lastPriority := extracted.priority
    END;
    
    Tests.ExpectedBool(TRUE, Heap.IsEmpty(heap), "Heap should be empty after extracting all", pass);
    
    Heap.Free(heap);
    RETURN pass
END TestLargeDataset;

PROCEDURE TestClear*(): BOOLEAN;
VAR 
    heap: Heap.Heap;
    item: TestItemPtr;
    success: BOOLEAN;
    pass: BOOLEAN;
    i: INTEGER;
BEGIN
    pass := TRUE;
    heap := Heap.New(MinCompare);
    
    (* Add some items *)
    FOR i := 1 TO 10 DO
        item := NewItem(i, i);
        success := Heap.Insert(heap, item);
        ASSERT(success)
    END;
    
    Tests.ExpectedInt(10, Heap.Count(heap), "Should have 10 items", pass);
    Tests.ExpectedBool(FALSE, Heap.IsEmpty(heap), "Heap should not be empty", pass);
    
    (* Clear the heap *)
    Heap.Clear(heap);
    
    Tests.ExpectedInt(0, Heap.Count(heap), "Count should be 0 after clear", pass);
    Tests.ExpectedBool(TRUE, Heap.IsEmpty(heap), "Heap should be empty after clear", pass);
    
    (* Test that we can still add items after clearing *)
    item := NewItem(42, 42);
    success := Heap.Insert(heap, item);
    Tests.ExpectedBool(TRUE, success, "Should be able to insert after clear", pass);
    Tests.ExpectedInt(1, Heap.Count(heap), "Count should be 1 after inserting", pass);
    
    Heap.Free(heap);
    RETURN pass
END TestClear;

PROCEDURE TestForeach*(): BOOLEAN;
VAR 
    heap: Heap.Heap;
    item: TestItemPtr;
    state: TestVisitorState;
    success: BOOLEAN;
    pass: BOOLEAN;
    i: INTEGER;
BEGIN
    pass := TRUE;
    heap := Heap.New(MinCompare);
    
    (* Add items with values 1, 2, 3, 4, 5 *)
    FOR i := 1 TO 5 DO
        item := NewItem(i, i);
        success := Heap.Insert(heap, item);
        ASSERT(success)
    END;
    
    (* Test foreach *)
    state.sum := 0;
    state.count := 0;
    Heap.Foreach(heap, SumVisitor, state);
    
    Tests.ExpectedInt(15, state.sum, "Sum of values should be 15", pass);
    Tests.ExpectedInt(5, state.count, "Should visit 5 items", pass);
    
    Heap.Free(heap);
    RETURN pass
END TestForeach;

PROCEDURE TestHeapProperty*(): BOOLEAN;
VAR 
    heap: Heap.Heap;
    item: TestItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    pass: BOOLEAN;
    i: INTEGER;
BEGIN
    pass := TRUE;
    heap := Heap.New(MinCompare);
    
    (* Insert items in descending priority order *)
    FOR i := 20 TO 1 BY -1 DO
        item := NewItem(i, i);
        success := Heap.Insert(heap, item);
        ASSERT(success);
        
        (* After each insertion, the minimum should be the smallest so far *)
        success := Heap.PeekMin(heap, result);
        Tests.ExpectedBool(TRUE, success, "PeekMin should succeed", pass);
        Tests.ExpectedInt(i, result(TestItemPtr).priority, "Min priority should be correct", pass)
    END;
    
    Tests.ExpectedInt(20, Heap.Count(heap), "Should have 20 items", pass);
    
    Heap.Free(heap);
    RETURN pass
END TestHeapProperty;

BEGIN
    Tests.Init(ts, "Heap Tests");
    Tests.Add(ts, TestNewAndFree);
    Tests.Add(ts, TestInsertAndPeek);
    Tests.Add(ts, TestExtractMin);
    Tests.Add(ts, TestMaxHeap);
    Tests.Add(ts, TestLargeDataset);
    Tests.Add(ts, TestClear);
    Tests.Add(ts, TestForeach);
    Tests.Add(ts, TestHeapProperty);
    ASSERT(Tests.Run(ts));
END HeapTest.
