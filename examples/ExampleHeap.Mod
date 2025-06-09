(**
    ExampleHeap.Mod - Demonstrates using Heap for priority queue operations.

    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE ExampleHeap;

IMPORT Heap, Collections, Out;

TYPE
    (* Example task item with priority *)
    Task = RECORD(Collections.Item)
        name: ARRAY 32 OF CHAR;
        priority: INTEGER;
        taskId: INTEGER
    END;
    TaskPtr = POINTER TO Task;

    (* Visitor state for demonstration *)
    TaskVisitorState = RECORD(Collections.VisitorState)
        totalTasks: INTEGER;
        highPriorityCount: INTEGER
    END;

VAR
    minHeap, maxHeap: Heap.Heap;
    task: TaskPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    state: TaskVisitorState;
    i: INTEGER;

(** Create a new task item *)
PROCEDURE NewTask(id, priority: INTEGER; name: ARRAY OF CHAR): TaskPtr;
VAR 
    newTask: TaskPtr;
    j: INTEGER;
BEGIN
    NEW(newTask);
    newTask.taskId := id;
    newTask.priority := priority;
    
    (* Copy name manually *)
    j := 0;
    WHILE (j < LEN(name) - 1) & (j < LEN(newTask.name) - 1) & (name[j] # 0X) DO
        newTask.name[j] := name[j];
        INC(j)
    END;
    newTask.name[j] := 0X;
    
    RETURN newTask
END NewTask;

(** Min-heap comparison: lower priority values have higher precedence *)
PROCEDURE MinPriorityCompare(left, right: Collections.ItemPtr): BOOLEAN;
VAR 
    leftTask, rightTask: TaskPtr;
    result: BOOLEAN;
BEGIN
    leftTask := left(TaskPtr);
    rightTask := right(TaskPtr);
    result := leftTask.priority < rightTask.priority;
    RETURN result
END MinPriorityCompare;

(** Max-heap comparison: higher priority values have higher precedence *)
PROCEDURE MaxPriorityCompare(left, right: Collections.ItemPtr): BOOLEAN;
VAR 
    leftTask, rightTask: TaskPtr;
    result: BOOLEAN;
BEGIN
    leftTask := left(TaskPtr);
    rightTask := right(TaskPtr);
    result := leftTask.priority > rightTask.priority;
    RETURN result
END MaxPriorityCompare;

(** Visitor procedure to count tasks *)
PROCEDURE TaskCounter(item: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
VAR taskItem: TaskPtr;
BEGIN
    taskItem := item(TaskPtr);
    INC(state(TaskVisitorState).totalTasks);
    IF taskItem.priority <= 2 THEN (* High priority tasks *)
        INC(state(TaskVisitorState).highPriorityCount)
    END;
    RETURN TRUE
END TaskCounter;

(** Print a task's details *)
PROCEDURE PrintTask(task: TaskPtr);
BEGIN
    Out.String("  Task #"); Out.Int(task.taskId, 0);
    Out.String(" '"); Out.String(task.name); Out.String("'");
    Out.String(" (Priority: "); Out.Int(task.priority, 0); Out.String(")"); Out.Ln
END PrintTask;

(** Demonstrate priority queue operations *)
PROCEDURE DemonstratePriorityQueue();
BEGIN
    Out.String("=== Priority Queue Example (Min-Heap) ==="); Out.Ln;
    Out.String("Lower priority numbers = higher precedence"); Out.Ln; Out.Ln;
    
    minHeap := Heap.New(MinPriorityCompare);
    
    (* Add tasks with different priorities *)
    Out.String("Adding tasks to priority queue:"); Out.Ln;
    
    task := NewTask(1, 3, "Send email");
    success := Heap.Insert(minHeap, task);
    Out.String("Added: "); PrintTask(task);
    
    task := NewTask(2, 1, "Critical bug fix");
    success := Heap.Insert(minHeap, task);
    Out.String("Added: "); PrintTask(task);
    
    task := NewTask(3, 5, "Update docs");
    success := Heap.Insert(minHeap, task);
    Out.String("Added: "); PrintTask(task);
    
    task := NewTask(4, 2, "Code review");
    success := Heap.Insert(minHeap, task);
    Out.String("Added: "); PrintTask(task);
    
    task := NewTask(5, 1, "Security patch");
    success := Heap.Insert(minHeap, task);
    Out.String("Added: "); PrintTask(task);
    
    Out.Ln;
    Out.String("Queue contains "); Out.Int(Heap.Count(minHeap), 0); Out.String(" tasks"); Out.Ln;
    Out.Ln;
    
    (* Peek at highest priority task *)
    success := Heap.PeekMin(minHeap, result);
    IF success THEN
        Out.String("Next task to process (peek): ");
        PrintTask(result(TaskPtr));
        Out.Ln
    END;
    
    (* Process tasks in priority order *)
    Out.String("Processing tasks in priority order:"); Out.Ln;
    WHILE ~Heap.IsEmpty(minHeap) DO
        success := Heap.ExtractMin(minHeap, result);
        IF success THEN
            Out.String("Processing: ");
            PrintTask(result(TaskPtr))
        END
    END;
    
    Out.Ln;
    Out.String("All tasks processed. Queue is now empty."); Out.Ln;
    Heap.Free(minHeap)
END DemonstratePriorityQueue;

(** Demonstrate max-heap behavior *)
PROCEDURE DemonstrateMaxHeap();
BEGIN
    Out.String("=== Max-Heap Example ==="); Out.Ln;
    Out.String("Higher priority numbers = higher precedence"); Out.Ln; Out.Ln;
    
    maxHeap := Heap.New(MaxPriorityCompare);
    
    (* Add the same tasks but now higher numbers have priority *)
    Out.String("Adding tasks to max-heap:"); Out.Ln;
    
    FOR i := 1 TO 5 DO
        CASE i OF
            1: task := NewTask(1, 3, "Medium task")
        |   2: task := NewTask(2, 8, "High priority")
        |   3: task := NewTask(3, 2, "Low priority")
        |   4: task := NewTask(4, 9, "Critical task")
        |   5: task := NewTask(5, 5, "Normal task")
        END;
        success := Heap.Insert(maxHeap, task);
        Out.String("Added: "); PrintTask(task)
    END;
    
    Out.Ln;
    Out.String("Extracting in max-heap order (highest priority first):"); Out.Ln;
    WHILE ~Heap.IsEmpty(maxHeap) DO
        success := Heap.ExtractMin(maxHeap, result); (* Still called ExtractMin but extracts max due to comparison *)
        IF success THEN
            Out.String("Processing: ");
            PrintTask(result(TaskPtr))
        END
    END;
    
    Heap.Free(maxHeap)
END DemonstrateMaxHeap;

(** Demonstrate heap with visitor pattern *)
PROCEDURE DemonstrateVisitorPattern();
BEGIN
    Out.String("=== Visitor Pattern Example ==="); Out.Ln;
    
    minHeap := Heap.New(MinPriorityCompare);
    
    (* Add various tasks *)
    FOR i := 1 TO 10 DO
        task := NewTask(i, (i * 3) MOD 7 + 1, "Task");
        success := Heap.Insert(minHeap, task);
        ASSERT(success)
    END;
    
    Out.String("Added 10 tasks with various priorities"); Out.Ln;
    Out.String("Using visitor to count tasks by priority:"); Out.Ln;
    
    (* Use visitor to analyze the heap *)
    state.totalTasks := 0;
    state.highPriorityCount := 0;
    Heap.Foreach(minHeap, TaskCounter, state);
    
    Out.String("Total tasks: "); Out.Int(state.totalTasks, 0); Out.Ln;
    Out.String("High priority tasks (≤2): "); Out.Int(state.highPriorityCount, 0); Out.Ln;
    Out.String("Regular priority tasks: "); Out.Int(state.totalTasks - state.highPriorityCount, 0); Out.Ln;
    
    Heap.Free(minHeap)
END DemonstrateVisitorPattern;

(** Demonstrate heap operations edge cases *)
PROCEDURE DemonstrateEdgeCases();
VAR emptyHeap: Heap.Heap;
BEGIN
    Out.String("=== Edge Cases Example ==="); Out.Ln;
    
    emptyHeap := Heap.New(MinPriorityCompare);
    
    (* Test operations on empty heap *)
    Out.String("Testing empty heap:"); Out.Ln;
    Out.String("Is empty: ");
    IF Heap.IsEmpty(emptyHeap) THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    Out.String("Count: "); Out.Int(Heap.Count(emptyHeap), 0); Out.Ln;
    
    success := Heap.PeekMin(emptyHeap, result);
    Out.String("PeekMin result: ");
    IF success THEN Out.String("SUCCESS (unexpected!)") ELSE Out.String("FAILED (expected)") END; Out.Ln;
    
    success := Heap.ExtractMin(emptyHeap, result);
    Out.String("ExtractMin result: ");
    IF success THEN Out.String("SUCCESS (unexpected!)") ELSE Out.String("FAILED (expected)") END; Out.Ln;
    Out.Ln;
    
    (* Test single item operations *)
    Out.String("Testing single item operations:"); Out.Ln;
    task := NewTask(1, 42, "Only task");
    success := Heap.Insert(emptyHeap, task);
    Out.String("Inserted single task"); Out.Ln;
    Out.String("Count: "); Out.Int(Heap.Count(emptyHeap), 0); Out.Ln;
    
    success := Heap.PeekMin(emptyHeap, result);
    IF success THEN
        Out.String("Peeked: "); PrintTask(result(TaskPtr))
    END;
    
    success := Heap.ExtractMin(emptyHeap, result);
    IF success THEN
        Out.String("Extracted: "); PrintTask(result(TaskPtr))
    END;
    
    Out.String("Count after extraction: "); Out.Int(Heap.Count(emptyHeap), 0); Out.Ln;
    Out.Ln;
    
    (* Test clear operation *)
    FOR i := 1 TO 5 DO
        task := NewTask(i, i, "Task");
        success := Heap.Insert(emptyHeap, task);
        ASSERT(success)
    END;
    
    Out.String("Added 5 tasks, count: "); Out.Int(Heap.Count(emptyHeap), 0); Out.Ln;
    Heap.Clear(emptyHeap);
    Out.String("After clear, count: "); Out.Int(Heap.Count(emptyHeap), 0); Out.Ln;
    
    Heap.Free(emptyHeap)
END DemonstrateEdgeCases;

BEGIN
    Out.String("=== Heap Examples ==="); Out.Ln; Out.Ln;
    
    DemonstratePriorityQueue();
    Out.Ln;
    
    DemonstrateMaxHeap();
    Out.Ln;
    
    DemonstrateVisitorPattern();
    Out.Ln;
    
    DemonstrateEdgeCases();
    
    Out.String("=== Heap Examples Complete ==="); Out.Ln
END ExampleHeap.
