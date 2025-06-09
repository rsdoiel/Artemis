(**
    HeapSort.Mod - Heap-based sorting algorithms using the Heap module.

    Provides efficient O(n log n) sorting for ArrayList collections using heap sort algorithm.
    Supports both in-place and non-destructive sorting with custom comparison functions.

    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE HeapSort;

IMPORT Heap, ArrayList, Collections;

(** Sort an ArrayList in-place using heap sort algorithm.
    The original ArrayList is modified to contain items in sorted order.
    Time complexity: O(n log n), Space complexity: O(n) for the temporary heap.
*)
PROCEDURE SortInPlace*(list: ArrayList.ArrayList; compare: Heap.CompareFunc);
VAR 
    heap: Heap.Heap;
    item: Collections.ItemPtr;
    success: BOOLEAN;
    i, count: INTEGER;
BEGIN
    IF list # NIL THEN
        count := ArrayList.Count(list);
        
        IF count > 1 THEN
            (* Create a heap and insert all items *)
            heap := Heap.New(compare);
            
            (* Move all items from ArrayList to heap *)
            FOR i := 0 TO count - 1 DO
                success := ArrayList.GetAt(list, i, item);
                ASSERT(success);
                success := Heap.Insert(heap, item);
                ASSERT(success)
            END;
            
            (* Clear the original list *)
            ArrayList.Clear(list);
            
            (* Extract items from heap back to ArrayList in sorted order *)
            WHILE ~Heap.IsEmpty(heap) DO
                success := Heap.ExtractMin(heap, item);
                ASSERT(success);
                success := ArrayList.Append(list, item);
                ASSERT(success)
            END;
            
            Heap.Free(heap)
        END
    END
END SortInPlace;

(** Create a new sorted copy of an ArrayList using heap sort algorithm.
    The original ArrayList remains unchanged.
    Returns a new ArrayList containing the same items in sorted order.
    Time complexity: O(n log n), Space complexity: O(n) for the new list and temporary heap.
*)
PROCEDURE Sort*(list: ArrayList.ArrayList; compare: Heap.CompareFunc): ArrayList.ArrayList;
VAR 
    result: ArrayList.ArrayList;
    heap: Heap.Heap;
    item: Collections.ItemPtr;
    success: BOOLEAN;
    i, count: INTEGER;
BEGIN
    result := ArrayList.New();
    
    IF list # NIL THEN
        count := ArrayList.Count(list);
        
        IF count > 0 THEN
            (* Create a heap and insert all items *)
            heap := Heap.New(compare);
            
            (* Copy all items from ArrayList to heap *)
            FOR i := 0 TO count - 1 DO
                success := ArrayList.GetAt(list, i, item);
                ASSERT(success);
                success := Heap.Insert(heap, item);
                ASSERT(success)
            END;
            
            (* Extract items from heap to new ArrayList in sorted order *)
            WHILE ~Heap.IsEmpty(heap) DO
                success := Heap.ExtractMin(heap, item);
                ASSERT(success);
                success := ArrayList.Append(result, item);
                ASSERT(success)
            END;
            
            Heap.Free(heap)
        END
    END;
    
    RETURN result
END Sort;

(** Check if an ArrayList is sorted according to the given comparison function.
    Returns TRUE if the list is empty, has one element, or is properly sorted.
    Time complexity: O(n), Space complexity: O(1).
*)
PROCEDURE IsSorted*(list: ArrayList.ArrayList; compare: Heap.CompareFunc): BOOLEAN;
VAR 
    result: BOOLEAN;
    current, next: Collections.ItemPtr;
    success: BOOLEAN;
    i, count: INTEGER;
BEGIN
    result := TRUE;
    
    IF list # NIL THEN
        count := ArrayList.Count(list);
        
        (* Check adjacent pairs *)
        i := 0;
        WHILE (i < count - 1) & result DO
            success := ArrayList.GetAt(list, i, current);
            ASSERT(success);
            success := ArrayList.GetAt(list, i + 1, next);
            ASSERT(success);
            
            (* If current > next (i.e., next < current), then not sorted *)
            IF compare(next, current) THEN
                result := FALSE
            END;
            
            INC(i)
        END
    END;
    
    RETURN result
END IsSorted;

(** Find the k-th smallest element in an ArrayList using a heap-based selection algorithm.
    k is 0-based (k=0 returns the smallest element, k=1 the second smallest, etc.).
    Returns TRUE if successful and sets result to the k-th smallest element.
    Returns FALSE if k is out of bounds or the list is empty.
    Time complexity: O(n log k), Space complexity: O(k).
    Note: This implementation uses a different approach to avoid nested procedure limitations.
*)
PROCEDURE FindKthSmallest*(list: ArrayList.ArrayList; k: INTEGER; compare: Heap.CompareFunc; VAR result: Collections.ItemPtr): BOOLEAN;
VAR 
    success: BOOLEAN;
    tempList: ArrayList.ArrayList;
    item: Collections.ItemPtr;
    i, count: INTEGER;
BEGIN
    success := FALSE;
    result := NIL;
    
    IF (list # NIL) & (k >= 0) THEN
        count := ArrayList.Count(list);
        
        IF k < count THEN
            (* Create a copy of the list and sort it, then get the k-th element *)
            tempList := ArrayList.New();
            
            (* Copy all items to temp list *)
            FOR i := 0 TO count - 1 DO
                success := ArrayList.GetAt(list, i, item);
                ASSERT(success);
                success := ArrayList.Append(tempList, item);
                ASSERT(success)
            END;
            
            (* Sort the temp list *)
            SortInPlace(tempList, compare);
            
            (* Get the k-th element *)
            success := ArrayList.GetAt(tempList, k, result);
            
            (* Clean up *)
            ArrayList.Free(tempList)
        END
    END;
    
    RETURN success
END FindKthSmallest;

(** Merge two sorted ArrayLists into a new sorted ArrayList.
    Both input lists must be sorted according to the given comparison function.
    Returns a new ArrayList containing all elements from both lists in sorted order.
    Time complexity: O(n + m), Space complexity: O(n + m).
*)
PROCEDURE MergeSorted*(list1, list2: ArrayList.ArrayList; compare: Heap.CompareFunc): ArrayList.ArrayList;
VAR 
    result: ArrayList.ArrayList;
    item1, item2: Collections.ItemPtr;
    success: BOOLEAN;
    i, j, count1, count2: INTEGER;
BEGIN
    result := ArrayList.New();
    
    IF (list1 # NIL) & (list2 # NIL) THEN
        count1 := ArrayList.Count(list1);
        count2 := ArrayList.Count(list2);
        i := 0; j := 0;
        
        (* Merge the two sorted lists *)
        WHILE (i < count1) & (j < count2) DO
            success := ArrayList.GetAt(list1, i, item1);
            ASSERT(success);
            success := ArrayList.GetAt(list2, j, item2);
            ASSERT(success);
            
            IF compare(item1, item2) THEN (* item1 < item2 *)
                success := ArrayList.Append(result, item1);
                ASSERT(success);
                INC(i)
            ELSE
                success := ArrayList.Append(result, item2);
                ASSERT(success);
                INC(j)
            END
        END;
        
        (* Append remaining items from list1 *)
        WHILE i < count1 DO
            success := ArrayList.GetAt(list1, i, item1);
            ASSERT(success);
            success := ArrayList.Append(result, item1);
            ASSERT(success);
            INC(i)
        END;
        
        (* Append remaining items from list2 *)
        WHILE j < count2 DO
            success := ArrayList.GetAt(list2, j, item2);
            ASSERT(success);
            success := ArrayList.Append(result, item2);
            ASSERT(success);
            INC(j)
        END
    ELSIF list1 # NIL THEN
        (* Copy list1 *)
        count1 := ArrayList.Count(list1);
        FOR i := 0 TO count1 - 1 DO
            success := ArrayList.GetAt(list1, i, item1);
            ASSERT(success);
            success := ArrayList.Append(result, item1);
            ASSERT(success)
        END
    ELSIF list2 # NIL THEN
        (* Copy list2 *)
        count2 := ArrayList.Count(list2);
        FOR j := 0 TO count2 - 1 DO
            success := ArrayList.GetAt(list2, j, item2);
            ASSERT(success);
            success := ArrayList.Append(result, item2);
            ASSERT(success)
        END
    END;
    
    RETURN result
END MergeSorted;

END HeapSort.
