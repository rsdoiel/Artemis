(**
    Stack.Mod - A LIFO (Last In, First Out) stack implementation.
    
    Provides classical stack operations with clear semantics using LinkedList as underlying storage.
    
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE Stack;

IMPORT LinkedList, Collections;

TYPE
    (** Opaque pointer to a Stack *)
    Stack* = POINTER TO StackDesc;
    StackDesc = RECORD
        list: LinkedList.List
    END;

(** Constructor: Allocate and initialize a new stack. *)
PROCEDURE New*(): Stack;
VAR stack: Stack;
BEGIN
    NEW(stack);
    stack.list := LinkedList.New();
    RETURN stack
END New;

(** Destructor: Free the stack. *)
PROCEDURE Free*(VAR stack: Stack);
BEGIN
    IF stack # NIL THEN
        LinkedList.Free(stack.list);
        stack := NIL
    END
END Free;

(** Push an item onto the stack. *)
PROCEDURE Push*(stack: Stack; item: Collections.ItemPtr);
BEGIN
    IF ~LinkedList.InsertAt(stack.list, 0, item) THEN
        (* Handle error - should not happen for valid stack *)
    END
END Push;

(** Pop and return the top item from the stack. *)
PROCEDURE Pop*(stack: Stack; VAR result: Collections.ItemPtr);
BEGIN
    LinkedList.RemoveFirst(stack.list, result)
END Pop;

(** Peek at the top item without removing it. Returns TRUE if successful *)
PROCEDURE Top*(stack: Stack; VAR result: Collections.ItemPtr): BOOLEAN;
VAR success: BOOLEAN;
BEGIN
    success := LinkedList.GetAt(stack.list, 0, result);
    RETURN success
END Top;

(** Return the number of items in the stack. *)
PROCEDURE Count*(stack: Stack): INTEGER;
VAR result: INTEGER;
BEGIN
    result := LinkedList.Count(stack.list);
    RETURN result
END Count;

(** Test if the stack is empty. *)
PROCEDURE IsEmpty*(stack: Stack): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    result := LinkedList.IsEmpty(stack.list);
    RETURN result
END IsEmpty;

(** Clear removes all elements from the stack. *)
PROCEDURE Clear*(stack: Stack);
BEGIN
    LinkedList.Clear(stack.list)
END Clear;

(** Apply a procedure to each element in the stack from top to bottom. *)
PROCEDURE Foreach*(stack: Stack; visit: Collections.VisitProc; VAR state: Collections.VisitorState); 
BEGIN
    LinkedList.Foreach(stack.list, visit, state)
END Foreach;

END Stack.
