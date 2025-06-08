(**
    Deque.Mod
    Double-ended queue implementation using DoubleLinkedList.
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE Deque;

IMPORT DoubleLinkedList, Collections;

TYPE
    Deque* = POINTER TO DequeDesc;
    DequeDesc = RECORD
        list: DoubleLinkedList.List
    END;

(** Constructor: Allocate and initialize a new deque. *)
PROCEDURE New*(): Deque;
VAR dq: Deque;
BEGIN
    NEW(dq);
    dq.list := DoubleLinkedList.New();
    RETURN dq
END New;

(** Destructor: Free the deque. *)
PROCEDURE Free*(VAR dq: Deque);
BEGIN
    IF dq # NIL THEN
        DoubleLinkedList.Free(dq.list);
        dq := NIL
    END
END Free;

(** Add an item to the front of the deque. *)
PROCEDURE Prepend*(dq: Deque; item: Collections.ItemPtr);
BEGIN
    IF ~DoubleLinkedList.InsertAt(dq.list, 0, item) THEN
        (* Handle error - should not happen for valid deque *)
    END
END Prepend;

(** Add an item to the back of the deque. *)
PROCEDURE Append*(dq: Deque; item: Collections.ItemPtr);
BEGIN
    DoubleLinkedList.Append(dq.list, item)
END Append;

(** Remove and return the first item. *)
PROCEDURE RemoveFirst*(dq: Deque; VAR result: Collections.ItemPtr);
BEGIN
    DoubleLinkedList.RemoveFirst(dq.list, result)
END RemoveFirst;

(** Remove and return the last item. *)
PROCEDURE RemoveLast*(dq: Deque; VAR result: Collections.ItemPtr);
BEGIN
    DoubleLinkedList.RemoveLast(dq.list, result)
END RemoveLast;

(** Return the number of items in the deque. *)
PROCEDURE Count*(dq: Deque): INTEGER;
VAR result: INTEGER;
BEGIN
    result := DoubleLinkedList.Count(dq.list);
    RETURN result
END Count;

(** Test if the deque is empty. *)
PROCEDURE IsEmpty*(dq: Deque): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    result := DoubleLinkedList.IsEmpty(dq.list);
    RETURN result
END IsEmpty;


(** Apply a procedure to each element in the deque. *)
PROCEDURE Foreach*(dq: Deque; visit: Collections.VisitProc; VAR state: Collections.VisitorState); 
BEGIN
    DoubleLinkedList.Foreach(dq.list, visit, state)
END Foreach;

END Deque.
