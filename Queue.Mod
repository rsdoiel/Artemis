(**
    Queue.Mod - A FIFO (First In, First Out) queue implementation.
    
    Provides classical queue operations with clear semantics using LinkedList as underlying storage.
    
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE Queue;

IMPORT LinkedList, Collections;

TYPE
    (** Opaque pointer to a Queue *)
    Queue* = POINTER TO QueueDesc;
    QueueDesc = RECORD
        list: LinkedList.List
    END;

(** Constructor: Allocate and initialize a new queue. *)
PROCEDURE New*(): Queue;
VAR queue: Queue;
BEGIN
    NEW(queue);
    queue.list := LinkedList.New();
    RETURN queue
END New;

(** Destructor: Free the queue. *)
PROCEDURE Free*(VAR queue: Queue);
BEGIN
    IF queue # NIL THEN
        LinkedList.Free(queue.list);
        queue := NIL
    END
END Free;

(** Enqueue an item to the rear of the queue. *)
PROCEDURE Enqueue*(queue: Queue; item: Collections.ItemPtr);
BEGIN
    LinkedList.Append(queue.list, item)
END Enqueue;

(** Dequeue and return the front item from the queue. *)
PROCEDURE Dequeue*(queue: Queue; VAR result: Collections.ItemPtr);
BEGIN
    LinkedList.RemoveFirst(queue.list, result)
END Dequeue;

(** Peek at the front item without removing it. *)
PROCEDURE Front*(queue: Queue; VAR result: Collections.ItemPtr): BOOLEAN;
VAR success: BOOLEAN;
BEGIN
    success := LinkedList.GetAt(queue.list, 0, result);
    IF ~success THEN result := NIL END;
    RETURN success
END Front;

(** Get the number of items in the queue. *)
PROCEDURE Count*(queue: Queue): INTEGER;
BEGIN
    RETURN LinkedList.Count(queue.list)
END Count;

(** Check if the queue is empty. *)
PROCEDURE IsEmpty*(queue: Queue): BOOLEAN;
BEGIN
    RETURN LinkedList.IsEmpty(queue.list)
END IsEmpty;

(** Clear all items from the queue. *)
PROCEDURE Clear*(queue: Queue);
BEGIN
    LinkedList.Clear(queue.list)
END Clear;

(** Apply a visitor procedure to each item in the queue (front to rear order). *)
PROCEDURE Foreach*(queue: Queue; visitor: Collections.VisitProc; VAR state: Collections.VisitorState);
BEGIN
    LinkedList.Foreach(queue.list, visitor, state)
END Foreach;

END Queue.
