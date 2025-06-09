(*
    Copyright (c) 2025, Artemis Project
    All rights reserved. 3-clause BSD license.

    Module: ArrayList
    Description: Chunked array list for dynamic, indexable collections built on LinkedList.
    Author: Artemis Contributors
*)

MODULE ArrayList;

IMPORT Collections, LinkedList;

CONST
    ChunkSize* = 64;  (* Tune as needed *)

TYPE
    ArrayList* = POINTER TO ArrayListDesc;
    ArrayListDesc = RECORD
        chunks: LinkedList.List;
        count: INTEGER
    END;

    ChunkPtr = POINTER TO Chunk;
    Chunk = RECORD (Collections.Item)
        items: ARRAY ChunkSize OF Collections.ItemPtr;
        count: INTEGER
    END;

(** Create a new, empty ArrayList *)
PROCEDURE New*(): ArrayList;
VAR
    list: ArrayList;
    chunk: ChunkPtr;
    result: ArrayList;
BEGIN
    NEW(list);
    list.chunks := LinkedList.New();
    NEW(chunk);
    chunk.count := 0;
    LinkedList.Append(list.chunks, chunk);
    list.count := 0;
    result := list;
    RETURN result
END New;

(** Free the ArrayList and all its chunks *)
PROCEDURE Free*(VAR list: ArrayList);
BEGIN
    LinkedList.Clear(list.chunks);
    LinkedList.Free(list.chunks);
    list.count := 0
END Free;

(** Append an item to the end of the list. Returns TRUE if successful *)
PROCEDURE Append*(list: ArrayList; item: Collections.ItemPtr): BOOLEAN;
VAR
    result: BOOLEAN;
    chunk: ChunkPtr;
    lastChunk: Collections.ItemPtr;
    found: BOOLEAN;
    chunkCount: INTEGER;
BEGIN
    chunkCount := LinkedList.Count(list.chunks);
    found := LinkedList.GetAt(list.chunks, chunkCount - 1, lastChunk);
    chunk := lastChunk(ChunkPtr);
    
    IF chunk.count = ChunkSize THEN
        NEW(chunk);
        chunk.count := 0;
        LinkedList.Append(list.chunks, chunk)
    END;
    
    chunk.items[chunk.count] := item;
    INC(chunk.count);
    INC(list.count);
    result := TRUE;
    RETURN result
END Append;

(** Get the item at the given index. Returns TRUE if found, item in VAR result *)
PROCEDURE GetAt*(list: ArrayList; index: INTEGER; VAR result: Collections.ItemPtr): BOOLEAN;
VAR
    found: BOOLEAN;
    chunkIndex, base: INTEGER;
    chunk: ChunkPtr;
    chunkItem: Collections.ItemPtr;
    chunkCount: INTEGER;
BEGIN
    found := FALSE;
    IF (index >= 0) & (index < list.count) THEN
        base := 0;
        chunkCount := LinkedList.Count(list.chunks);
        chunkIndex := 0;
        WHILE (chunkIndex < chunkCount) & ~found DO
            IF LinkedList.GetAt(list.chunks, chunkIndex, chunkItem) THEN
                chunk := chunkItem(ChunkPtr);
                IF index < base + chunk.count THEN
                    result := chunk.items[index - base];
                    found := TRUE
                ELSE
                    base := base + chunk.count;
                    INC(chunkIndex)
                END
            ELSE
                chunkIndex := chunkCount (* Exit loop *)
            END
        END
    END;
    RETURN found
END GetAt;

(** Set the item at the given index. Returns TRUE if successful *)
PROCEDURE SetAt*(list: ArrayList; index: INTEGER; item: Collections.ItemPtr): BOOLEAN;
VAR
    result: BOOLEAN;
    chunkIndex, base: INTEGER;
    chunk: ChunkPtr;
    chunkItem: Collections.ItemPtr;
    chunkCount: INTEGER;
BEGIN
    result := FALSE;
    IF (index >= 0) & (index < list.count) THEN
        base := 0;
        chunkCount := LinkedList.Count(list.chunks);
        chunkIndex := 0;
        WHILE (chunkIndex < chunkCount) & ~result DO
            IF LinkedList.GetAt(list.chunks, chunkIndex, chunkItem) THEN
                chunk := chunkItem(ChunkPtr);
                IF index < base + chunk.count THEN
                    chunk.items[index - base] := item;
                    result := TRUE
                ELSE
                    base := base + chunk.count;
                    INC(chunkIndex)
                END
            ELSE
                chunkIndex := chunkCount (* Exit loop *)
            END
        END
    END;
    RETURN result
END SetAt;

(** Return the number of items in the list *)
PROCEDURE Count*(list: ArrayList): INTEGER;
VAR
    result: INTEGER;
BEGIN
    result := list.count;
    RETURN result
END Count;

(** Returns TRUE if the list is empty *)
PROCEDURE IsEmpty*(list: ArrayList): BOOLEAN;
VAR
    result: BOOLEAN;
BEGIN
    result := list.count = 0;
    RETURN result
END IsEmpty;

(** Remove all items from the list *)
PROCEDURE Clear*(list: ArrayList);
VAR
    chunk: ChunkPtr;
BEGIN
    LinkedList.Clear(list.chunks);
    NEW(chunk);
    chunk.count := 0;
    LinkedList.Append(list.chunks, chunk);
    list.count := 0
END Clear;

(** Remove the last item from the list. Returns TRUE if successful *)
PROCEDURE RemoveLast*(list: ArrayList): BOOLEAN;
VAR
    result: BOOLEAN;
    chunkCount: INTEGER;
    lastChunk, removedChunk: Collections.ItemPtr;
    chunk: ChunkPtr;
    success: BOOLEAN;
BEGIN
    result := FALSE;
    IF list.count > 0 THEN
        chunkCount := LinkedList.Count(list.chunks);
        IF LinkedList.GetAt(list.chunks, chunkCount - 1, lastChunk) THEN
            chunk := lastChunk(ChunkPtr);
            DEC(chunk.count);
            DEC(list.count);
            
            (* If the chunk becomes empty and it's not the only chunk, remove it *)
            IF (chunk.count = 0) & (chunkCount > 1) THEN
                success := LinkedList.RemoveAt(list.chunks, chunkCount - 1, removedChunk);
                ASSERT(success)
            END;
            result := TRUE
        END
    END;
    RETURN result
END RemoveLast;

(** Iterate over all items, calling visitor for each *)
PROCEDURE Foreach*(list: ArrayList; visit: Collections.VisitProc; VAR state: Collections.VisitorState);
VAR
    chunkIndex, itemIndex: INTEGER;
    chunk: ChunkPtr;
    chunkItem: Collections.ItemPtr;
    chunkCount: INTEGER;
    continueVisiting: BOOLEAN;
BEGIN
    chunkCount := LinkedList.Count(list.chunks);
    chunkIndex := 0;
    continueVisiting := TRUE;
    WHILE (chunkIndex < chunkCount) & continueVisiting DO
        IF LinkedList.GetAt(list.chunks, chunkIndex, chunkItem) THEN
            chunk := chunkItem(ChunkPtr);
            itemIndex := 0;
            WHILE (itemIndex < chunk.count) & continueVisiting DO
                continueVisiting := visit(chunk.items[itemIndex], state);
                INC(itemIndex)
            END;
            INC(chunkIndex)
        ELSE
            chunkIndex := chunkCount (* Exit loop *)
        END
    END
END Foreach;

END ArrayList.
