(**
    HeapSortTest.Mod - Unit tests for HeapSort.Mod
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE HeapSortTest;

IMPORT HeapSort, ArrayList, Collections, Tests;

TYPE
    TestItem = RECORD (Collections.Item)
        value: INTEGER
    END;
    TestItemPtr = POINTER TO TestItem;

VAR
    ts: Tests.TestSet;

(** Create a new test item with value *)
PROCEDURE NewItem(value: INTEGER): TestItemPtr;
VAR item: TestItemPtr;
BEGIN
    NEW(item);
    item.value := value;
    RETURN item
END NewItem;

(** Comparison function for ascending order *)
PROCEDURE AscendingCompare(left, right: Collections.ItemPtr): BOOLEAN;
VAR 
    leftItem, rightItem: TestItemPtr;
    result: BOOLEAN;
BEGIN
    leftItem := left(TestItemPtr);
    rightItem := right(TestItemPtr);
    result := leftItem.value < rightItem.value;
    RETURN result
END AscendingCompare;

(** Comparison function for descending order *)
PROCEDURE DescendingCompare(left, right: Collections.ItemPtr): BOOLEAN;
VAR 
    leftItem, rightItem: TestItemPtr;
    result: BOOLEAN;
BEGIN
    leftItem := left(TestItemPtr);
    rightItem := right(TestItemPtr);
    result := leftItem.value > rightItem.value;
    RETURN result
END DescendingCompare;

(** Helper to create a list with given values *)
PROCEDURE CreateList(values: ARRAY OF INTEGER; count: INTEGER): ArrayList.ArrayList;
VAR 
    list: ArrayList.ArrayList;
    item: TestItemPtr;
    success: BOOLEAN;
    i: INTEGER;
BEGIN
    list := ArrayList.New();
    FOR i := 0 TO count - 1 DO
        item := NewItem(values[i]);
        success := ArrayList.Append(list, item);
        ASSERT(success)
    END;
    RETURN list
END CreateList;

(** Helper to verify list contents *)
PROCEDURE VerifyList(list: ArrayList.ArrayList; expected: ARRAY OF INTEGER; count: INTEGER): BOOLEAN;
VAR 
    result: BOOLEAN;
    item: Collections.ItemPtr;
    success: BOOLEAN;
    i: INTEGER;
BEGIN
    result := TRUE;
    
    IF ArrayList.Count(list) # count THEN
        result := FALSE
    ELSE
        FOR i := 0 TO count - 1 DO
            success := ArrayList.GetAt(list, i, item);
            IF ~success OR (item(TestItemPtr).value # expected[i]) THEN
                result := FALSE
            END
        END
    END;
    
    RETURN result
END VerifyList;

PROCEDURE TestSortInPlaceEmpty*(): BOOLEAN;
VAR 
    list: ArrayList.ArrayList;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Test empty list *)
    list := ArrayList.New();
    HeapSort.SortInPlace(list, AscendingCompare);
    Tests.ExpectedInt(0, ArrayList.Count(list), "Empty list should remain empty", pass);
    ArrayList.Free(list);
    
    (* Test NIL list *)
    list := NIL;
    HeapSort.SortInPlace(list, AscendingCompare); (* Should not crash *)
    
    RETURN pass
END TestSortInPlaceEmpty;

PROCEDURE TestSortInPlaceSingle*(): BOOLEAN;
VAR 
    list: ArrayList.ArrayList;
    values: ARRAY 1 OF INTEGER;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    
    values[0] := 42;
    list := CreateList(values, 1);
    
    HeapSort.SortInPlace(list, AscendingCompare);
    Tests.ExpectedBool(TRUE, VerifyList(list, values, 1), "Single item should remain unchanged", pass);
    
    ArrayList.Free(list);
    RETURN pass
END TestSortInPlaceSingle;

PROCEDURE TestSortInPlaceAscending*(): BOOLEAN;
VAR 
    list: ArrayList.ArrayList;
    values, expected: ARRAY 5 OF INTEGER;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Input: 5, 2, 8, 1, 9 *)
    values[0] := 5; values[1] := 2; values[2] := 8; values[3] := 1; values[4] := 9;
    (* Expected: 1, 2, 5, 8, 9 *)
    expected[0] := 1; expected[1] := 2; expected[2] := 5; expected[3] := 8; expected[4] := 9;
    
    list := CreateList(values, 5);
    HeapSort.SortInPlace(list, AscendingCompare);
    
    Tests.ExpectedBool(TRUE, VerifyList(list, expected, 5), "Should sort in ascending order", pass);
    
    ArrayList.Free(list);
    RETURN pass
END TestSortInPlaceAscending;

PROCEDURE TestSortInPlaceDescending*(): BOOLEAN;
VAR 
    list: ArrayList.ArrayList;
    values, expected: ARRAY 5 OF INTEGER;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Input: 5, 2, 8, 1, 9 *)
    values[0] := 5; values[1] := 2; values[2] := 8; values[3] := 1; values[4] := 9;
    (* Expected: 9, 8, 5, 2, 1 *)
    expected[0] := 9; expected[1] := 8; expected[2] := 5; expected[3] := 2; expected[4] := 1;
    
    list := CreateList(values, 5);
    HeapSort.SortInPlace(list, DescendingCompare);
    
    Tests.ExpectedBool(TRUE, VerifyList(list, expected, 5), "Should sort in descending order", pass);
    
    ArrayList.Free(list);
    RETURN pass
END TestSortInPlaceDescending;

PROCEDURE TestSortNonDestructive*(): BOOLEAN;
VAR 
    original, sorted: ArrayList.ArrayList;
    values, expectedSorted: ARRAY 4 OF INTEGER;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Input: 3, 1, 4, 2 *)
    values[0] := 3; values[1] := 1; values[2] := 4; values[3] := 2;
    (* Expected sorted: 1, 2, 3, 4 *)
    expectedSorted[0] := 1; expectedSorted[1] := 2; expectedSorted[2] := 3; expectedSorted[3] := 4;
    
    original := CreateList(values, 4);
    sorted := HeapSort.Sort(original, AscendingCompare);
    
    Tests.ExpectedBool(TRUE, VerifyList(original, values, 4), "Original list should be unchanged", pass);
    Tests.ExpectedBool(TRUE, VerifyList(sorted, expectedSorted, 4), "Sorted list should be correct", pass);
    
    ArrayList.Free(original);
    ArrayList.Free(sorted);
    RETURN pass
END TestSortNonDestructive;

PROCEDURE TestIsSorted*(): BOOLEAN;
VAR 
    list: ArrayList.ArrayList;
    values: ARRAY 5 OF INTEGER;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Test sorted list *)
    values[0] := 1; values[1] := 2; values[2] := 5; values[3] := 8; values[4] := 9;
    list := CreateList(values, 5);
    Tests.ExpectedBool(TRUE, HeapSort.IsSorted(list, AscendingCompare), "Should recognize sorted list", pass);
    ArrayList.Free(list);
    
    (* Test unsorted list *)
    values[0] := 5; values[1] := 2; values[2] := 8; values[3] := 1; values[4] := 9;
    list := CreateList(values, 5);
    Tests.ExpectedBool(FALSE, HeapSort.IsSorted(list, AscendingCompare), "Should recognize unsorted list", pass);
    ArrayList.Free(list);
    
    (* Test empty list *)
    list := ArrayList.New();
    Tests.ExpectedBool(TRUE, HeapSort.IsSorted(list, AscendingCompare), "Empty list should be considered sorted", pass);
    ArrayList.Free(list);
    
    (* Test single item *)
    values[0] := 42;
    list := CreateList(values, 1);
    Tests.ExpectedBool(TRUE, HeapSort.IsSorted(list, AscendingCompare), "Single item should be considered sorted", pass);
    ArrayList.Free(list);
    
    RETURN pass
END TestIsSorted;

PROCEDURE TestFindKthSmallest*(): BOOLEAN;
VAR 
    list: ArrayList.ArrayList;
    values: ARRAY 7 OF INTEGER;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Input: 5, 2, 8, 1, 9, 3, 7 *)
    (* Sorted: 1, 2, 3, 5, 7, 8, 9 *)
    values[0] := 5; values[1] := 2; values[2] := 8; values[3] := 1; 
    values[4] := 9; values[5] := 3; values[6] := 7;
    
    list := CreateList(values, 7);
    
    (* Test various k values *)
    success := HeapSort.FindKthSmallest(list, 0, AscendingCompare, result);
    Tests.ExpectedBool(TRUE, success, "Should find 0th smallest", pass);
    Tests.ExpectedInt(1, result(TestItemPtr).value, "0th smallest should be 1", pass);
    
    success := HeapSort.FindKthSmallest(list, 2, AscendingCompare, result);
    Tests.ExpectedBool(TRUE, success, "Should find 2nd smallest", pass);
    Tests.ExpectedInt(3, result(TestItemPtr).value, "2nd smallest should be 3", pass);
    
    success := HeapSort.FindKthSmallest(list, 6, AscendingCompare, result);
    Tests.ExpectedBool(TRUE, success, "Should find 6th smallest", pass);
    Tests.ExpectedInt(9, result(TestItemPtr).value, "6th smallest should be 9", pass);
    
    (* Test out of bounds *)
    success := HeapSort.FindKthSmallest(list, 7, AscendingCompare, result);
    Tests.ExpectedBool(FALSE, success, "Should fail for out of bounds k", pass);
    
    success := HeapSort.FindKthSmallest(list, -1, AscendingCompare, result);
    Tests.ExpectedBool(FALSE, success, "Should fail for negative k", pass);
    
    ArrayList.Free(list);
    RETURN pass
END TestFindKthSmallest;

PROCEDURE TestMergeSorted*(): BOOLEAN;
VAR 
    list1, list2, merged: ArrayList.ArrayList;
    values1, values2, expected: ARRAY 10 OF INTEGER;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* List1: 1, 3, 5, 7 *)
    values1[0] := 1; values1[1] := 3; values1[2] := 5; values1[3] := 7;
    (* List2: 2, 4, 6, 8, 9 *)
    values2[0] := 2; values2[1] := 4; values2[2] := 6; values2[3] := 8; values2[4] := 9;
    (* Expected: 1, 2, 3, 4, 5, 6, 7, 8, 9 *)
    expected[0] := 1; expected[1] := 2; expected[2] := 3; expected[3] := 4; expected[4] := 5;
    expected[5] := 6; expected[6] := 7; expected[7] := 8; expected[8] := 9;
    
    list1 := CreateList(values1, 4);
    list2 := CreateList(values2, 5);
    merged := HeapSort.MergeSorted(list1, list2, AscendingCompare);
    
    Tests.ExpectedBool(TRUE, VerifyList(merged, expected, 9), "Should merge correctly", pass);
    
    ArrayList.Free(list1);
    ArrayList.Free(list2);
    ArrayList.Free(merged);
    RETURN pass
END TestMergeSorted;

PROCEDURE TestMergeSortedEdgeCases*(): BOOLEAN;
VAR 
    list1, list2, merged: ArrayList.ArrayList;
    values: ARRAY 3 OF INTEGER;
    pass: BOOLEAN;
BEGIN
    pass := TRUE;
    
    (* Test merging with empty list *)
    values[0] := 1; values[1] := 2; values[2] := 3;
    list1 := CreateList(values, 3);
    list2 := ArrayList.New();
    merged := HeapSort.MergeSorted(list1, list2, AscendingCompare);
    
    Tests.ExpectedBool(TRUE, VerifyList(merged, values, 3), "Should handle empty second list", pass);
    
    ArrayList.Free(list1);
    ArrayList.Free(list2);
    ArrayList.Free(merged);
    
    (* Test merging empty with non-empty *)
    list1 := ArrayList.New();
    list2 := CreateList(values, 3);
    merged := HeapSort.MergeSorted(list1, list2, AscendingCompare);
    
    Tests.ExpectedBool(TRUE, VerifyList(merged, values, 3), "Should handle empty first list", pass);
    
    ArrayList.Free(list1);
    ArrayList.Free(list2);
    ArrayList.Free(merged);
    
    (* Test merging two empty lists *)
    list1 := ArrayList.New();
    list2 := ArrayList.New();
    merged := HeapSort.MergeSorted(list1, list2, AscendingCompare);
    
    Tests.ExpectedInt(0, ArrayList.Count(merged), "Should handle two empty lists", pass);
    
    ArrayList.Free(list1);
    ArrayList.Free(list2);
    ArrayList.Free(merged);
    
    RETURN pass
END TestMergeSortedEdgeCases;

PROCEDURE TestLargeDataset*(): BOOLEAN;
VAR 
    list: ArrayList.ArrayList;
    item: TestItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    pass: BOOLEAN;
    i, prev, curr: INTEGER;
BEGIN
    pass := TRUE;
    
    (* Create a large unsorted list *)
    list := ArrayList.New();
    FOR i := 0 TO 99 DO
        item := NewItem((i * 17 + 23) MOD 100); (* Pseudo-random values *)
        success := ArrayList.Append(list, item);
        ASSERT(success)
    END;
    
    Tests.ExpectedInt(100, ArrayList.Count(list), "Should have 100 items", pass);
    Tests.ExpectedBool(FALSE, HeapSort.IsSorted(list, AscendingCompare), "Should not be sorted initially", pass);
    
    (* Sort the list *)
    HeapSort.SortInPlace(list, AscendingCompare);
    
    Tests.ExpectedInt(100, ArrayList.Count(list), "Should still have 100 items after sorting", pass);
    Tests.ExpectedBool(TRUE, HeapSort.IsSorted(list, AscendingCompare), "Should be sorted after sorting", pass);
    
    (* Verify it's actually sorted by checking a few adjacent pairs *)
    FOR i := 0 TO 10 DO
        success := ArrayList.GetAt(list, i, result);
        ASSERT(success);
        prev := result(TestItemPtr).value;
        success := ArrayList.GetAt(list, i + 1, result);
        ASSERT(success);
        curr := result(TestItemPtr).value;
        Tests.ExpectedBool(TRUE, prev <= curr, "Adjacent items should be in order", pass)
    END;
    
    ArrayList.Free(list);
    RETURN pass
END TestLargeDataset;

BEGIN
    Tests.Init(ts, "HeapSort Tests");
    Tests.Add(ts, TestSortInPlaceEmpty);
    Tests.Add(ts, TestSortInPlaceSingle);
    Tests.Add(ts, TestSortInPlaceAscending);
    Tests.Add(ts, TestSortInPlaceDescending);
    Tests.Add(ts, TestSortNonDestructive);
    Tests.Add(ts, TestIsSorted);
    Tests.Add(ts, TestFindKthSmallest);
    Tests.Add(ts, TestMergeSorted);
    Tests.Add(ts, TestMergeSortedEdgeCases);
    Tests.Add(ts, TestLargeDataset);
    ASSERT(Tests.Run(ts));
END HeapSortTest.
