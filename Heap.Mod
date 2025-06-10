(**
    Heap.mod - A binary min-heap implementation using ArrayList.

    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE Heap;

IMPORT Collections, ArrayList;

TYPE
    (** Comparison function type - returns TRUE if left < right *)
    CompareFunc* = PROCEDURE(left, right: Collections.ItemPtr): BOOLEAN;
    
    (** Opaque pointer to a Heap *)
    Heap* = POINTER TO HeapDesc;
    HeapDesc = RECORD
        items: ArrayList.ArrayList;
        compare: CompareFunc
    END;

(** Constructor: Allocate and initialize a new heap with a comparison function *)
PROCEDURE New*(compare: CompareFunc): Heap;
VAR heap: Heap;
BEGIN
    NEW(heap);
    heap.items := ArrayList.New();
    heap.compare := compare;
    RETURN heap
END New;

(** Destructor: Free the heap *)
PROCEDURE Free*(VAR heap: Heap);
BEGIN
    IF heap # NIL THEN
        ArrayList.Free(heap.items);
        heap := NIL
    END
END Free;

(* Internal helper: get parent index *)
PROCEDURE ParentIndex(index: INTEGER): INTEGER;
VAR result: INTEGER;
BEGIN
    result := (index - 1) DIV 2;
    RETURN result
END ParentIndex;

(* Internal helper: get left child index *)
PROCEDURE LeftChildIndex(index: INTEGER): INTEGER;
VAR result: INTEGER;
BEGIN
    result := 2 * index + 1;
    RETURN result
END LeftChildIndex;

(* Internal helper: get right child index *)
PROCEDURE RightChildIndex(index: INTEGER): INTEGER;
VAR result: INTEGER;
BEGIN
    result := 2 * index + 2;
    RETURN result
END RightChildIndex;

(* Internal helper: swap two items in the heap *)
PROCEDURE SwapItems(heap: Heap; i, j: INTEGER);
VAR 
    itemI, itemJ: Collections.ItemPtr;
    success: BOOLEAN;
BEGIN
    success := ArrayList.GetAt(heap.items, i, itemI);
    ASSERT(success);
    success := ArrayList.GetAt(heap.items, j, itemJ);
    ASSERT(success);
    success := ArrayList.SetAt(heap.items, i, itemJ);
    ASSERT(success);
    success := ArrayList.SetAt(heap.items, j, itemI);
    ASSERT(success)
END SwapItems;

(* Internal helper: restore heap property upward from given index *)
PROCEDURE HeapifyUp(heap: Heap; index: INTEGER);
VAR 
    parent: INTEGER;
    current, parentItem: Collections.ItemPtr;
    success: BOOLEAN;
BEGIN
    WHILE index > 0 DO
        parent := ParentIndex(index);
        success := ArrayList.GetAt(heap.items, index, current);
        ASSERT(success);
        success := ArrayList.GetAt(heap.items, parent, parentItem);
        ASSERT(success);
        
        IF heap.compare(current, parentItem) THEN
            SwapItems(heap, index, parent);
            index := parent
        ELSE
            index := 0 (* Break the loop *)
        END
    END
END HeapifyUp;

(* Internal helper: restore heap property downward from given index *)
PROCEDURE HeapifyDown(heap: Heap; index: INTEGER);
VAR 
    size, smallest, left, right: INTEGER;
    current, leftItem, rightItem, smallestItem: Collections.ItemPtr;
    success: BOOLEAN;
    hasLeft, hasRight: BOOLEAN;
BEGIN
    size := ArrayList.Count(heap.items);
    
    WHILE index < size DO
        smallest := index;
        left := LeftChildIndex(index);
        right := RightChildIndex(index);
        
        (* Check if left child exists and is smaller *)
        hasLeft := left < size;
        IF hasLeft THEN
            success := ArrayList.GetAt(heap.items, smallest, current);
            ASSERT(success);
            success := ArrayList.GetAt(heap.items, left, leftItem);
            ASSERT(success);
            IF heap.compare(leftItem, current) THEN
                smallest := left
            END
        END;
        
        (* Check if right child exists and is smaller *)
        hasRight := right < size;
        IF hasRight THEN
            success := ArrayList.GetAt(heap.items, smallest, smallestItem);
            ASSERT(success);
            success := ArrayList.GetAt(heap.items, right, rightItem);
            ASSERT(success);
            IF heap.compare(rightItem, smallestItem) THEN
                smallest := right
            END
        END;
        
        (* If smallest is not the current index, swap and continue *)
        IF smallest # index THEN
            SwapItems(heap, index, smallest);
            index := smallest
        ELSE
            index := size (* Break the loop *)
        END
    END
END HeapifyDown;

(** Insert an item into the heap *)
PROCEDURE Insert*(heap: Heap; item: Collections.ItemPtr): BOOLEAN;
VAR 
    success: BOOLEAN;
    newIndex: INTEGER;
BEGIN
    success := ArrayList.Append(heap.items, item);
    IF success THEN
        newIndex := ArrayList.Count(heap.items) - 1;
        HeapifyUp(heap, newIndex)
    END;
    RETURN success
END Insert;

(** Extract the minimum item from the heap. Returns TRUE if successful *)
PROCEDURE ExtractMin*(heap: Heap; VAR result: Collections.ItemPtr): BOOLEAN;
VAR 
    success: BOOLEAN;
    size: INTEGER;
    lastItem: Collections.ItemPtr;
BEGIN
    success := FALSE;
    result := NIL;
    size := ArrayList.Count(heap.items);
    
    IF size > 0 THEN
        (* Get the minimum (root) *)
        success := ArrayList.GetAt(heap.items, 0, result);
        ASSERT(success);
        
        IF size = 1 THEN
            (* Only one item, just remove it *)
            success := ArrayList.RemoveLast(heap.items);
            ASSERT(success)
        ELSE
            (* Move last item to root and remove the last item *)
            success := ArrayList.GetAt(heap.items, size - 1, lastItem);
            ASSERT(success);
            success := ArrayList.SetAt(heap.items, 0, lastItem);
            ASSERT(success);
            success := ArrayList.RemoveLast(heap.items);
            ASSERT(success);
            
            (* Restore heap property *)
            HeapifyDown(heap, 0)
        END;
        success := TRUE
    END;
    
    RETURN success
END ExtractMin;

(** Peek at the minimum item without removing it. Returns TRUE if successful *)
PROCEDURE PeekMin*(heap: Heap; VAR result: Collections.ItemPtr): BOOLEAN;
VAR success: BOOLEAN;
BEGIN
    success := FALSE;
    result := NIL;
    IF ArrayList.Count(heap.items) > 0 THEN
        success := ArrayList.GetAt(heap.items, 0, result)
    END;
    RETURN success
END PeekMin;

(** Return the number of items in the heap *)
PROCEDURE Count*(heap: Heap): INTEGER;
VAR result: INTEGER;
BEGIN
    result := ArrayList.Count(heap.items);
    RETURN result
END Count;

(** Returns TRUE if the heap is empty *)
PROCEDURE IsEmpty*(heap: Heap): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    result := ArrayList.IsEmpty(heap.items);
    RETURN result
END IsEmpty;

(** Remove all items from the heap *)
PROCEDURE Clear*(heap: Heap);
BEGIN
    ArrayList.Clear(heap.items)
END Clear;

(** Iterate over all items in heap order (level-order traversal) *)
PROCEDURE Foreach*(heap: Heap; visit: Collections.VisitProc; VAR state: Collections.VisitorState);
BEGIN
    ArrayList.Foreach(heap.items, visit, state)
END Foreach;

END Heap.
