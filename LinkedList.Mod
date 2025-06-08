(** LinkedList.mod - A singly linked list implementation.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE LinkedList;

IMPORT Collections;

TYPE
    (* Internal implementation type, not exposed *)
    Node = RECORD
        item: Collections.ItemPtr;
        next: POINTER TO Node
    END;
    NodePtr = POINTER TO Node;

    (** Opaque pointer to a List *)
    List* = POINTER TO ListDesc; 
    ListDesc = RECORD
        head: NodePtr;
        tail: NodePtr;
        size: INTEGER
    END;
   
(** Constructor: Allocate and initialize a new list *)
PROCEDURE New*(): List;
VAR list: List;
BEGIN
    NEW(list);
    list.head := NIL;
    list.tail := NIL;
    list.size := 0;
    RETURN list
END New;

(** Destructor: (optional, only if you want to clear memory) *)
PROCEDURE Free*(VAR list: List);
BEGIN
    list := NIL
END Free;

(** Append a new element. *)
PROCEDURE Append*(list: List; item: Collections.ItemPtr);
VAR node: NodePtr;
BEGIN
    NEW(node);
    node.item := item;
    node.next := NIL;
    
    IF list.head = NIL THEN
        list.head := node;
        list.tail := node
    ELSE
        list.tail.next := node;
        list.tail := node
    END;
    INC(list.size)
END Append;

(** Remove and return the first list element. *)
PROCEDURE RemoveFirst*(list: List; VAR result: Collections.ItemPtr);
VAR node: NodePtr;
BEGIN
    IF list.head # NIL THEN
        node := list.head;
        result := node.item;
        list.head := node.next;
        IF list.head = NIL THEN
            list.tail := NIL
        END;
        DEC(list.size)
    ELSE
        result := NIL
    END
END RemoveFirst;

(** Insert a new element after a given position (0-based index). *)
PROCEDURE InsertAt*(list: List; position: INTEGER; item: Collections.ItemPtr): BOOLEAN;
VAR 
    node, newNode: NodePtr;
    i: INTEGER;
    result: BOOLEAN;
BEGIN
    result := FALSE;
    
    (** Insert at beginning if position is 0 *)
    IF position = 0 THEN
        NEW(newNode);
        newNode.item := item;
        newNode.next := list.head;
        list.head := newNode;
        IF list.tail = NIL THEN
            list.tail := newNode
        END;
        INC(list.size);
        result := TRUE
    (** Insert within valid range *)
    ELSIF (position > 0) & (position <= list.size) THEN
        node := list.head;
        i := 0;
        (** Find the node at position-1 *)
        WHILE (i < position-1) & (node # NIL) DO
            node := node.next;
            INC(i)
        END;
        
        IF node # NIL THEN
            NEW(newNode);
            newNode.item := item;
            newNode.next := node.next;
            node.next := newNode;
            IF list.tail = node THEN
                list.tail := newNode
            END;
            INC(list.size);
            result := TRUE
        END
    END;
    
    RETURN result
END InsertAt;

(** Return the number of elements in the list. *)
PROCEDURE Count*(list: List): INTEGER;
BEGIN
    RETURN list.size
END Count;

(** Test if the list is empty. *)
PROCEDURE IsEmpty*(list: List): BOOLEAN;
BEGIN
    RETURN list.head = NIL
END IsEmpty;

(** Apply a procedure to each element in the list, passing a state variable. 
If visit returns FALSE, iteration stops. *)
PROCEDURE Foreach*(list: List; visit: Collections.VisitProc; VAR state: Collections.VisitorState);
VAR current: NodePtr; cont: BOOLEAN;
BEGIN
    current := list.head;
    cont := TRUE;
    WHILE (current # NIL) & cont DO
        cont := visit(current.item, state);
        current := current.next
    END
END Foreach;

(** Get item at specified position (0-based index), returns TRUE if successful. *)
PROCEDURE GetAt*(list: List; position: INTEGER; VAR result: Collections.ItemPtr): BOOLEAN;
VAR 
    current: NodePtr;
    i: INTEGER;
    success: BOOLEAN;
BEGIN
    success := FALSE;
    result := NIL;
    
    IF (position >= 0) & (position < list.size) THEN
        current := list.head;
        i := 0;
        WHILE (i < position) & (current # NIL) DO
            current := current.next;
            INC(i)
        END;
        
        IF current # NIL THEN
            result := current.item;
            success := TRUE
        END
    END;
    
    RETURN success
END GetAt;

(** Remove item at specified position (0-based index), returns TRUE if successful. *)
PROCEDURE RemoveAt*(list: List; position: INTEGER; VAR result: Collections.ItemPtr): BOOLEAN;
VAR 
    current, previous: NodePtr;
    i: INTEGER;
    success: BOOLEAN;
BEGIN
    success := FALSE;
    result := NIL;
    
    IF (position >= 0) & (position < list.size) THEN
        (* Remove head *)
        IF position = 0 THEN
            RemoveFirst(list, result);
            success := TRUE
        ELSE
            (* Find the node at position-1 and position *)
            previous := list.head;
            i := 0;
            WHILE (i < position - 1) & (previous # NIL) DO
                previous := previous.next;
                INC(i)
            END;
            
            IF (previous # NIL) & (previous.next # NIL) THEN
                current := previous.next;
                result := current.item;
                previous.next := current.next;
                
                (* Update tail if we removed the last node *)
                IF current = list.tail THEN
                    list.tail := previous
                END;
                
                DEC(list.size);
                success := TRUE
            END
        END
    END;
    
    RETURN success
END RemoveAt;

END LinkedList.