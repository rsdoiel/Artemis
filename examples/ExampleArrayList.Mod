(** ExampleArrayList.Mod - Demonstrates using ArrayList for dynamic, indexable storage.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE ExampleArrayList;

IMPORT ArrayList, Collections, Out;

TYPE
    (* Example item type extending Collections.Item *)
    NumberItem = RECORD(Collections.Item)
        value: INTEGER;
        description: ARRAY 32 OF CHAR
    END;
    NumberItemPtr = POINTER TO NumberItem;

    (* Visitor state for demonstration *)
    SumVisitorState = RECORD(Collections.VisitorState)
        sum, count: INTEGER
    END;

VAR
    list: ArrayList.ArrayList;
    item: NumberItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    state: SumVisitorState;
    i: INTEGER;

(** Create a new number item *)
PROCEDURE NewNumberItem(val: INTEGER; desc: ARRAY OF CHAR): NumberItemPtr;
VAR 
    newItem: NumberItemPtr;
    j: INTEGER;
BEGIN
    NEW(newItem);
    newItem.value := val;
    
    (* Copy description manually since we can't use Strings module *)
    j := 0;
    WHILE (j < LEN(desc) - 1) & (j < LEN(newItem.description) - 1) & (desc[j] # 0X) DO
        newItem.description[j] := desc[j];
        INC(j)
    END;
    newItem.description[j] := 0X;
    
    RETURN newItem
END NewNumberItem;

(** Visitor procedure to sum all values *)
PROCEDURE SumVisitor(item: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
VAR numberItem: NumberItemPtr;
BEGIN
    numberItem := item(NumberItemPtr);
    state(SumVisitorState).sum := state(SumVisitorState).sum + numberItem.value;
    INC(state(SumVisitorState).count);
    RETURN TRUE
END SumVisitor;

(** Print an item's details *)
PROCEDURE PrintItem(index: INTEGER; item: NumberItemPtr);
BEGIN
    Out.String("  ["); Out.Int(index, 0); Out.String("] ");
    Out.String(item.description); Out.String(": "); Out.Int(item.value, 0); Out.Ln
END PrintItem;

BEGIN
    Out.String("=== ArrayList Example ==="); Out.Ln; Out.Ln;
    
    (* Create a new ArrayList *)
    list := ArrayList.New();
    Out.String("Created new ArrayList"); Out.Ln;
    Out.String("Initial count: "); Out.Int(ArrayList.Count(list), 0); Out.Ln;
    Out.String("Is empty: "); 
    IF ArrayList.IsEmpty(list) THEN Out.String("TRUE") ELSE Out.String("FALSE") END;
    Out.Ln; Out.Ln;
    
    (* Add some items *)
    Out.String("Adding items to the list:"); Out.Ln;
    
    item := NewNumberItem(42, "Answer");
    success := ArrayList.Append(list, item);
    Out.String("Added: Answer (42) - Success: ");
    IF success THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    
    item := NewNumberItem(13, "Lucky");
    success := ArrayList.Append(list, item);
    Out.String("Added: Lucky (13) - Success: ");
    IF success THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    
    item := NewNumberItem(7, "Magic");
    success := ArrayList.Append(list, item);
    Out.String("Added: Magic (7) - Success: ");
    IF success THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    
    item := NewNumberItem(100, "Century");
    success := ArrayList.Append(list, item);
    Out.String("Added: Century (100) - Success: ");
    IF success THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    
    Out.Ln;
    Out.String("Current count: "); Out.Int(ArrayList.Count(list), 0); Out.Ln;
    Out.Ln;
    
    (* Display all items using random access *)
    Out.String("Displaying items using GetAt:"); Out.Ln;
    FOR i := 0 TO ArrayList.Count(list) - 1 DO
        success := ArrayList.GetAt(list, i, result);
        IF success THEN
            PrintItem(i, result(NumberItemPtr))
        ELSE
            Out.String("  Failed to get item at index "); Out.Int(i, 0); Out.Ln
        END
    END;
    Out.Ln;
    
    (* Test SetAt - update an item *)
    Out.String("Updating item at index 1:"); Out.Ln;
    item := NewNumberItem(99, "Updated");
    success := ArrayList.SetAt(list, 1, item);
    Out.String("SetAt result: ");
    IF success THEN Out.String("SUCCESS") ELSE Out.String("FAILED") END; Out.Ln;
    
    success := ArrayList.GetAt(list, 1, result);
    IF success THEN
        Out.String("New value at index 1: ");
        PrintItem(1, result(NumberItemPtr))
    END;
    Out.Ln;
    
    (* Use the visitor pattern to sum all values *)
    Out.String("Using Foreach to sum all values:"); Out.Ln;
    state.sum := 0;
    state.count := 0;
    ArrayList.Foreach(list, SumVisitor, state);
    Out.String("Total sum: "); Out.Int(state.sum, 0); Out.Ln;
    Out.String("Items visited: "); Out.Int(state.count, 0); Out.Ln;
    Out.Ln;
    
    (* Test with many items to demonstrate chunking *)
    Out.String("Testing with many items (demonstrating chunking):"); Out.Ln;
    Out.String("Adding 100 more items..."); Out.Ln;
    
    FOR i := 1 TO 100 DO
        item := NewNumberItem(i, "Item");
        success := ArrayList.Append(list, item);
        IF ~success THEN
            Out.String("Failed to add item "); Out.Int(i, 0); Out.Ln
        END
    END;
    
    Out.String("Total count after adding 100 items: "); Out.Int(ArrayList.Count(list), 0); Out.Ln;
    
    (* Access items across chunk boundaries *)
    Out.String("Accessing items across chunk boundaries:"); Out.Ln;
    
    success := ArrayList.GetAt(list, 63, result);  (* Last item in first chunk *)
    IF success THEN
        Out.String("Item at index 63: "); Out.Int(result(NumberItemPtr).value, 0); Out.Ln
    END;
    
    success := ArrayList.GetAt(list, 64, result);  (* First item in second chunk *)
    IF success THEN
        Out.String("Item at index 64: "); Out.Int(result(NumberItemPtr).value, 0); Out.Ln
    END;
    
    success := ArrayList.GetAt(list, 103, result); (* Last item *)
    IF success THEN
        Out.String("Item at index 103: "); Out.Int(result(NumberItemPtr).value, 0); Out.Ln
    END;
    Out.Ln;
    
    (* Test bounds checking *)
    Out.String("Testing bounds checking:"); Out.Ln;
    success := ArrayList.GetAt(list, -1, result);
    Out.String("GetAt(-1): ");
    IF success THEN Out.String("SUCCESS (unexpected!)") ELSE Out.String("FAILED (expected)") END; Out.Ln;
    
    success := ArrayList.GetAt(list, 200, result);
    Out.String("GetAt(200): ");
    IF success THEN Out.String("SUCCESS (unexpected!)") ELSE Out.String("FAILED (expected)") END; Out.Ln;
    Out.Ln;
    
    (* Clear the list *)
    Out.String("Clearing the list:"); Out.Ln;
    Out.String("Count before clear: "); Out.Int(ArrayList.Count(list), 0); Out.Ln;
    ArrayList.Clear(list);
    Out.String("Count after clear: "); Out.Int(ArrayList.Count(list), 0); Out.Ln;
    Out.String("Is empty after clear: ");
    IF ArrayList.IsEmpty(list) THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    Out.Ln;
    
    (* Test adding after clear *)
    Out.String("Testing append after clear:"); Out.Ln;
    item := NewNumberItem(999, "After Clear");
    success := ArrayList.Append(list, item);
    Out.String("Append after clear: ");
    IF success THEN Out.String("SUCCESS") ELSE Out.String("FAILED") END; Out.Ln;
    Out.String("Count: "); Out.Int(ArrayList.Count(list), 0); Out.Ln;
    Out.Ln;
    
    (* Clean up *)
    ArrayList.Free(list);
    Out.String("ArrayList freed."); Out.Ln;
    Out.Ln;
    Out.String("=== ArrayList Example Complete ==="); Out.Ln
END ExampleArrayList.
