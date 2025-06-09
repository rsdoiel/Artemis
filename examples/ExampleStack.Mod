(**
    ExampleStack.Mod - Demonstration of Stack collection usage
    
    Shows practical examples of stack operations including:
    - Basic stack operations (push, pop, top)
    - LIFO semantics demonstration  
    - Function call simulation
    - Expression evaluation (reverse Polish notation)
    - Undo/redo functionality simulation
    
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE ExampleStack;

IMPORT Stack, Collections, Out;

TYPE
    (* Example item types *)
    NumberItem = RECORD(Collections.Item)
        value: INTEGER
    END;
    NumberItemPtr = POINTER TO NumberItem;
    
    OperationItem = RECORD(Collections.Item)
        name: ARRAY 32 OF CHAR;
        value: INTEGER
    END;
    OperationItemPtr = POINTER TO OperationItem;
    
    (* Simple visitor state for printing *)
    PrintState = RECORD(Collections.VisitorState)
        (* No additional fields needed for printing *)
    END;

(** Create a new number item *)
PROCEDURE NewNumber(value: INTEGER): NumberItemPtr;
VAR item: NumberItemPtr;
BEGIN
    NEW(item);
    item.value := value;
    RETURN item
END NewNumber;

(** Create a new operation item *)
PROCEDURE NewOperation(name: ARRAY OF CHAR; value: INTEGER): OperationItemPtr;
VAR item: OperationItemPtr; i: INTEGER;
BEGIN
    NEW(item);
    item.value := value;
    
    (* Copy name manually *)
    i := 0;
    WHILE (i < LEN(name) - 1) & (i < LEN(item.name) - 1) & (name[i] # 0X) DO
        item.name[i] := name[i];
        INC(i)
    END;
    item.name[i] := 0X;
    
    RETURN item
END NewOperation;

(** Print a number item *)
PROCEDURE PrintNumber(item: NumberItemPtr);
BEGIN
    Out.Int(item.value, 0)
END PrintNumber;

(** Print an operation item *)
PROCEDURE PrintOperation(item: OperationItemPtr);
BEGIN
    Out.String(item.name); Out.String(" ("); Out.Int(item.value, 0); Out.String(")")
END PrintOperation;

(** Demonstrate basic stack operations *)
PROCEDURE DemonstrateBasicOperations();
VAR 
    stack: Stack.Stack;
    item: NumberItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    i: INTEGER;
BEGIN
    Out.String("=== Basic Stack Operations ==="); Out.Ln;
    
    stack := Stack.New();
    
    (* Push some numbers *)
    Out.String("Pushing numbers 1, 2, 3, 4, 5:"); Out.Ln;
    FOR i := 1 TO 5 DO
        item := NewNumber(i);
        Stack.Push(stack, item);
        Out.String("  Pushed: "); PrintNumber(item); Out.Ln
    END;
    
    Out.Ln;
    Out.String("Stack contains "); Out.Int(Stack.Count(stack), 0); Out.String(" items"); Out.Ln;
    
    (* Peek at top *)
    success := Stack.Top(stack, result);
    IF success THEN
        Out.String("Top item (peek): ");
        PrintNumber(result(NumberItemPtr)); Out.Ln
    END;
    Out.Ln;
    
    (* Pop all items *)
    Out.String("Popping all items (LIFO order):"); Out.Ln;
    WHILE ~Stack.IsEmpty(stack) DO
        Stack.Pop(stack, result);
        IF result # NIL THEN
            Out.String("  Popped: ");
            PrintNumber(result(NumberItemPtr)); Out.Ln
        END
    END;
    
    Out.String("Stack is now empty"); Out.Ln;
    Stack.Free(stack)
END DemonstrateBasicOperations;

(** Simulate function call stack *)
PROCEDURE DemonstrateFunctionCallStack();
VAR 
    callStack: Stack.Stack;
    operation: OperationItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
BEGIN
    Out.String("=== Function Call Stack Simulation ==="); Out.Ln;
    
    callStack := Stack.New();
    
    (* Simulate nested function calls *)
    Out.String("Simulating nested function calls:"); Out.Ln;
    
    operation := NewOperation("main()", 1);
    Stack.Push(callStack, operation);
    Out.String("  Call: "); PrintOperation(operation); Out.Ln;
    
    operation := NewOperation("processData()", 2);
    Stack.Push(callStack, operation);
    Out.String("  Call: "); PrintOperation(operation); Out.Ln;
    
    operation := NewOperation("validateInput()", 3);
    Stack.Push(callStack, operation);
    Out.String("  Call: "); PrintOperation(operation); Out.Ln;
    
    operation := NewOperation("checkFormat()", 4);
    Stack.Push(callStack, operation);
    Out.String("  Call: "); PrintOperation(operation); Out.Ln;
    
    Out.Ln;
    Out.String("Call stack depth: "); Out.Int(Stack.Count(callStack), 0); Out.Ln;
    
    (* Show current function *)
    success := Stack.Top(callStack, result);
    IF success THEN
        Out.String("Currently executing: "); 
        PrintOperation(result(OperationItemPtr)); Out.Ln
    END;
    Out.Ln;
    
    (* Simulate function returns *)
    Out.String("Functions returning (unwinding stack):"); Out.Ln;
    WHILE ~Stack.IsEmpty(callStack) DO
        Stack.Pop(callStack, result);
        IF result # NIL THEN
            Out.String("  Return from: ");
            PrintOperation(result(OperationItemPtr)); Out.Ln
        END
    END;
    
    Out.String("All functions returned, stack empty"); Out.Ln;
    Stack.Free(callStack)
END DemonstrateFunctionCallStack;

(** Evaluate a simple postfix expression *)
PROCEDURE DemonstrateRPNCalculator();
VAR 
    operandStack: Stack.Stack;
    number: NumberItemPtr;
    result: Collections.ItemPtr;
    a, b: NumberItemPtr;
    finalResult: INTEGER;
BEGIN
    Out.String("=== Reverse Polish Notation Calculator ==="); Out.Ln;
    Out.String("Evaluating: 3 4 + 2 * 7 -"); Out.Ln;
    Out.String("(Should equal: ((3 + 4) * 2) - 7 = 7)"); Out.Ln; Out.Ln;
    
    operandStack := Stack.New();
    
    (* Process: 3 4 + 2 * 7 - *)
    
    (* Push 3 *)
    number := NewNumber(3);
    Stack.Push(operandStack, number);
    Out.String("Push 3"); Out.Ln;
    
    (* Push 4 *)
    number := NewNumber(4);
    Stack.Push(operandStack, number);
    Out.String("Push 4"); Out.Ln;
    
    (* Add: pop 4, pop 3, push 7 *)
    Stack.Pop(operandStack, result);
    b := result(NumberItemPtr);
    Stack.Pop(operandStack, result);
    a := result(NumberItemPtr);
    number := NewNumber(a.value + b.value);
    Stack.Push(operandStack, number);
    Out.String("Add: "); Out.Int(a.value, 0); Out.String(" + "); 
    Out.Int(b.value, 0); Out.String(" = "); Out.Int(number.value, 0); Out.Ln;
    
    (* Push 2 *)
    number := NewNumber(2);
    Stack.Push(operandStack, number);
    Out.String("Push 2"); Out.Ln;
    
    (* Multiply: pop 2, pop 7, push 14 *)
    Stack.Pop(operandStack, result);
    b := result(NumberItemPtr);
    Stack.Pop(operandStack, result);
    a := result(NumberItemPtr);
    number := NewNumber(a.value * b.value);
    Stack.Push(operandStack, number);
    Out.String("Multiply: "); Out.Int(a.value, 0); Out.String(" * "); 
    Out.Int(b.value, 0); Out.String(" = "); Out.Int(number.value, 0); Out.Ln;
    
    (* Push 7 *)
    number := NewNumber(7);
    Stack.Push(operandStack, number);
    Out.String("Push 7"); Out.Ln;
    
    (* Subtract: pop 7, pop 14, push 7 *)
    Stack.Pop(operandStack, result);
    b := result(NumberItemPtr);
    Stack.Pop(operandStack, result);
    a := result(NumberItemPtr);
    number := NewNumber(a.value - b.value);
    Stack.Push(operandStack, number);
    Out.String("Subtract: "); Out.Int(a.value, 0); Out.String(" - "); 
    Out.Int(b.value, 0); Out.String(" = "); Out.Int(number.value, 0); Out.Ln;
    
    (* Get final result *)
    Stack.Pop(operandStack, result);
    finalResult := result(NumberItemPtr).value;
    
    Out.Ln;
    Out.String("Final result: "); Out.Int(finalResult, 0); Out.Ln;
    Out.String("Stack is empty: ");
    IF Stack.IsEmpty(operandStack) THEN Out.String("TRUE") ELSE Out.String("FALSE") END; 
    Out.Ln;
    
    Stack.Free(operandStack)
END DemonstrateRPNCalculator;

(** Simulate undo/redo functionality *)
PROCEDURE DemonstrateUndoRedo();
VAR 
    undoStack, redoStack: Stack.Stack;
    operation: OperationItemPtr;
    result: Collections.ItemPtr;
BEGIN
    Out.String("=== Undo/Redo Stack Simulation ==="); Out.Ln;
    
    undoStack := Stack.New();
    redoStack := Stack.New();
    
    (* Perform some operations *)
    Out.String("Performing operations:"); Out.Ln;
    
    operation := NewOperation("Type 'Hello'", 1);
    Stack.Push(undoStack, operation);
    Out.String("  Action: "); PrintOperation(operation); Out.Ln;
    
    operation := NewOperation("Delete 'lo'", 2);
    Stack.Push(undoStack, operation);
    Out.String("  Action: "); PrintOperation(operation); Out.Ln;
    
    operation := NewOperation("Type 'p'", 3);
    Stack.Push(undoStack, operation);
    Out.String("  Action: "); PrintOperation(operation); Out.Ln;
    
    Out.Ln;
    Out.String("Document state: 'Help'"); Out.Ln;
    Out.String("Undo stack has "); Out.Int(Stack.Count(undoStack), 0); Out.String(" operations"); Out.Ln;
    Out.Ln;
    
    (* Undo operations *)
    Out.String("Undoing operations:"); Out.Ln;
    Stack.Pop(undoStack, result);
    operation := result(OperationItemPtr);
    Stack.Push(redoStack, operation);
    Out.String("  Undo: "); PrintOperation(operation); Out.String(" -> Document: 'Hel'"); Out.Ln;
    
    Stack.Pop(undoStack, result);
    operation := result(OperationItemPtr);
    Stack.Push(redoStack, operation);
    Out.String("  Undo: "); PrintOperation(operation); Out.String(" -> Document: 'Hello'"); Out.Ln;
    
    Out.Ln;
    Out.String("Undo stack: "); Out.Int(Stack.Count(undoStack), 0); Out.String(" operations"); Out.Ln;
    Out.String("Redo stack: "); Out.Int(Stack.Count(redoStack), 0); Out.String(" operations"); Out.Ln;
    Out.Ln;
    
    (* Redo operations *)
    Out.String("Redoing operations:"); Out.Ln;
    Stack.Pop(redoStack, result);
    operation := result(OperationItemPtr);
    Stack.Push(undoStack, operation);
    Out.String("  Redo: "); PrintOperation(operation); Out.String(" -> Document: 'Hel'"); Out.Ln;
    
    Out.String("Document restored to previous state"); Out.Ln;
    
    Stack.Free(undoStack);
    Stack.Free(redoStack)
END DemonstrateUndoRedo;

(** Visitor procedure to print stack items *)
PROCEDURE PrintVisitor(item: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
VAR number: NumberItemPtr;
BEGIN
    number := item(NumberItemPtr);
    Out.Int(number.value, 0); Out.String(" ");
    RETURN TRUE
END PrintVisitor;

(** Demonstrate stack with visitor pattern *)
PROCEDURE DemonstrateVisitorPattern();
VAR 
    stack: Stack.Stack;
    item: NumberItemPtr;
    state: PrintState;
    i: INTEGER;
BEGIN
    Out.String("=== Stack Visitor Pattern ==="); Out.Ln;
    
    stack := Stack.New();
    
    (* Add some numbers *)
    FOR i := 1 TO 5 DO
        item := NewNumber(i * 10);
        Stack.Push(stack, item)
    END;
    
    Out.String("Stack contains (top to bottom): ");
    Stack.Foreach(stack, PrintVisitor, state);
    Out.Ln;
    
    Stack.Free(stack)
END DemonstrateVisitorPattern;

BEGIN
    Out.String("=== Stack Examples ==="); Out.Ln; Out.Ln;
    
    DemonstrateBasicOperations();
    Out.Ln;
    
    DemonstrateFunctionCallStack();
    Out.Ln;
    
    DemonstrateRPNCalculator();
    Out.Ln;
    
    DemonstrateUndoRedo();
    Out.Ln;
    
    DemonstrateVisitorPattern();
    
    Out.String("=== Stack Examples Complete ==="); Out.Ln
END ExampleStack.
