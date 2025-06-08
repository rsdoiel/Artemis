(**
    DoubleLinkedList.mod - A doubly linked list implementation.

    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE DoubleLinkedList;

IMPORT Collections;

TYPE
    (* Internal implementation type, not exposed *)
    Node = RECORD
        item: Collections.ItemPtr;
        next: POINTER TO Node;
        prev: POINTER TO Node
    END;
    NodePtr = POINTER TO Node;

    (** Opaque pointer type *)
    List* = POINTER TO ListDesc; 
    ListDesc = RECORD
        head: NodePtr;
        tail: NodePtr;
        size: INTEGER
    END;

(** Constructor: Allocate and initialize a new double linked list *)
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
    node.prev := list.tail;
    
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
        list.head := list.head.next;
        IF list.head # NIL THEN
            list.head.prev := NIL
        ELSE
            list.tail := NIL
        END;
        DEC(list.size)
    ELSE
        result := NIL
    END
END RemoveFirst;

(** Remove and return the last list element. *)
PROCEDURE RemoveLast*(list: List; VAR result: Collections.ItemPtr);
VAR node: NodePtr;
BEGIN
    IF list.tail # NIL THEN
        node := list.tail;
        result := node.item;
        list.tail := list.tail.prev;
        IF list.tail # NIL THEN
            list.tail.next := NIL
        ELSE
            list.head := NIL
        END;
        DEC(list.size)
    ELSE
        result := NIL
    END
END RemoveLast;

(** Insert a new element at a given position (0-based index). *)
PROCEDURE InsertAt*(list: List; position: INTEGER; item: Collections.ItemPtr): BOOLEAN;
VAR 
    node, newNode: NodePtr;
    i: INTEGER;
    result: BOOLEAN;
BEGIN
    result := FALSE;
    
    (* Insert at beginning if position is 0 *)
    IF position = 0 THEN
        NEW(newNode);
        newNode.item := item;
        newNode.prev := NIL;
        newNode.next := list.head;
        IF list.head # NIL THEN
            list.head.prev := newNode
        ELSE
            list.tail := newNode
        END;
        list.head := newNode;
        INC(list.size);
        result := TRUE
    (* Insert within valid range *)
    ELSIF (position > 0) & (position <= list.size) THEN
        node := list.head;
        i := 0;
        (* Find the node at position-1 *)
        WHILE (i < position-1) & (node # NIL) DO
            node := node.next;
            INC(i)
        END;
        
        IF node # NIL THEN
            NEW(newNode);
            newNode.item := item;
            newNode.next := node.next;
            newNode.prev := node;
            IF node.next # NIL THEN
                node.next.prev := newNode
            ELSE
                list.tail := newNode
            END;
            node.next := newNode;
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

(** Return the list head item. *)
PROCEDURE Head*(list: List; VAR result: Collections.ItemPtr): BOOLEAN;
VAR success: BOOLEAN;
BEGIN
    success := FALSE;
    result := NIL;
    IF list.head # NIL THEN
        result := list.head.item;
        success := TRUE
    END;
    RETURN success
END Head;

(** Return the list tail item. *)
PROCEDURE Tail*(list: List; VAR result: Collections.ItemPtr): BOOLEAN;
VAR success: BOOLEAN;
BEGIN
    success := FALSE;
    result := NIL;
    IF list.tail # NIL THEN
        result := list.tail.item;
        success := TRUE
    END;
    RETURN success
END Tail;

END DoubleLinkedList.
