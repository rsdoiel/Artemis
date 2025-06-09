(**
    ExampleQueue.Mod - Demonstrates using Queue for FIFO operations.

    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE ExampleQueue;

IMPORT Queue, Collections, Out;

TYPE
    (* Example task item for task scheduling *)
    Task = RECORD(Collections.Item)
        name: ARRAY 32 OF CHAR;
        taskId: INTEGER;
        estimatedTime: INTEGER (* in minutes *)
    END;
    TaskPtr = POINTER TO Task;

    (* Customer service ticket *)
    Ticket = RECORD(Collections.Item)
        ticketId: INTEGER;
        customerName: ARRAY 24 OF CHAR;
        issue: ARRAY 64 OF CHAR;
        timestamp: INTEGER
    END;
    TicketPtr = POINTER TO Ticket;

    (* Print job for printer queue *)
    PrintJob = RECORD(Collections.Item)
        jobId: INTEGER;
        filename: ARRAY 32 OF CHAR;
        pages: INTEGER;
        owner: ARRAY 16 OF CHAR
    END;
    PrintJobPtr = POINTER TO PrintJob;

    (* Visitor state for demonstration *)
    TaskVisitorState = RECORD(Collections.VisitorState)
        totalTime: INTEGER;
        taskCount: INTEGER
    END;

VAR
    taskQueue, urgentQueue: Queue.Queue;
    ticketQueue: Queue.Queue;
    printerQueue: Queue.Queue;
    task: TaskPtr;
    ticket: TicketPtr;
    printJob: PrintJobPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    state: TaskVisitorState;
    i: INTEGER;

(** Create a new task item *)
PROCEDURE NewTask(id, time: INTEGER; name: ARRAY OF CHAR): TaskPtr;
VAR 
    newTask: TaskPtr;
    j: INTEGER;
BEGIN
    NEW(newTask);
    newTask.taskId := id;
    newTask.estimatedTime := time;
    
    (* Copy name manually *)
    j := 0;
    WHILE (j < LEN(name) - 1) & (j < LEN(newTask.name) - 1) & (name[j] # 0X) DO
        newTask.name[j] := name[j];
        INC(j)
    END;
    newTask.name[j] := 0X;
    
    RETURN newTask
END NewTask;

(** Create a new support ticket *)
PROCEDURE NewTicket(id, timestamp: INTEGER; customer, issue: ARRAY OF CHAR): TicketPtr;
VAR 
    newTicket: TicketPtr;
    j: INTEGER;
BEGIN
    NEW(newTicket);
    newTicket.ticketId := id;
    newTicket.timestamp := timestamp;
    
    (* Copy customer name *)
    j := 0;
    WHILE (j < LEN(customer) - 1) & (j < LEN(newTicket.customerName) - 1) & (customer[j] # 0X) DO
        newTicket.customerName[j] := customer[j];
        INC(j)
    END;
    newTicket.customerName[j] := 0X;
    
    (* Copy issue description *)
    j := 0;
    WHILE (j < LEN(issue) - 1) & (j < LEN(newTicket.issue) - 1) & (issue[j] # 0X) DO
        newTicket.issue[j] := issue[j];
        INC(j)
    END;
    newTicket.issue[j] := 0X;
    
    RETURN newTicket
END NewTicket;

(** Create a new print job *)
PROCEDURE NewPrintJob(id, pages: INTEGER; filename, owner: ARRAY OF CHAR): PrintJobPtr;
VAR 
    newJob: PrintJobPtr;
    j: INTEGER;
BEGIN
    NEW(newJob);
    newJob.jobId := id;
    newJob.pages := pages;
    
    (* Copy filename *)
    j := 0;
    WHILE (j < LEN(filename) - 1) & (j < LEN(newJob.filename) - 1) & (filename[j] # 0X) DO
        newJob.filename[j] := filename[j];
        INC(j)
    END;
    newJob.filename[j] := 0X;
    
    (* Copy owner name *)
    j := 0;
    WHILE (j < LEN(owner) - 1) & (j < LEN(newJob.owner) - 1) & (owner[j] # 0X) DO
        newJob.owner[j] := owner[j];
        INC(j)
    END;
    newJob.owner[j] := 0X;
    
    RETURN newJob
END NewPrintJob;

(** Visitor procedure to count task time *)
PROCEDURE TaskTimeCounter(item: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
VAR taskItem: TaskPtr;
BEGIN
    taskItem := item(TaskPtr);
    INC(state(TaskVisitorState).totalTime, taskItem.estimatedTime);
    INC(state(TaskVisitorState).taskCount);
    RETURN TRUE
END TaskTimeCounter;

(** Print a task's details *)
PROCEDURE PrintTask(task: TaskPtr);
BEGIN
    Out.String("  Task #"); Out.Int(task.taskId, 0);
    Out.String(" '"); Out.String(task.name); Out.String("'");
    Out.String(" ("); Out.Int(task.estimatedTime, 0); Out.String(" min)"); Out.Ln
END PrintTask;

(** Print a ticket's details *)
PROCEDURE PrintTicket(ticket: TicketPtr);
BEGIN
    Out.String("  Ticket #"); Out.Int(ticket.ticketId, 0);
    Out.String(" from "); Out.String(ticket.customerName);
    Out.String(": "); Out.String(ticket.issue); Out.Ln
END PrintTicket;

(** Print a print job's details *)
PROCEDURE PrintJobDetails(job: PrintJobPtr);
BEGIN
    Out.String("  Job #"); Out.Int(job.jobId, 0);
    Out.String(" '"); Out.String(job.filename); Out.String("'");
    Out.String(" ("); Out.Int(job.pages, 0); Out.String(" pages)");
    Out.String(" by "); Out.String(job.owner); Out.Ln
END PrintJobDetails;

(** Demonstrate task scheduling queue *)
PROCEDURE DemonstrateTaskScheduling();
BEGIN
    Out.String("=== Task Scheduling Example (FIFO Queue) ==="); Out.Ln;
    Out.String("Tasks are processed in the order they arrive"); Out.Ln; Out.Ln;
    
    taskQueue := Queue.New();
    
    (* Add tasks to the queue *)
    Out.String("Adding tasks to queue:"); Out.Ln;
    
    task := NewTask(1, 30, "Code review");
    Queue.Enqueue(taskQueue, task);
    Out.String("Added: "); PrintTask(task);
    
    task := NewTask(2, 45, "Update documentation");
    Queue.Enqueue(taskQueue, task);
    Out.String("Added: "); PrintTask(task);
    
    task := NewTask(3, 15, "Fix minor bug");
    Queue.Enqueue(taskQueue, task);
    Out.String("Added: "); PrintTask(task);
    
    task := NewTask(4, 60, "Implement feature");
    Queue.Enqueue(taskQueue, task);
    Out.String("Added: "); PrintTask(task);
    
    task := NewTask(5, 20, "Write tests");
    Queue.Enqueue(taskQueue, task);
    Out.String("Added: "); PrintTask(task);
    
    Out.Ln;
    Out.String("Queue contains "); Out.Int(Queue.Count(taskQueue), 0); Out.String(" tasks"); Out.Ln;
    
    (* Use visitor to calculate total time *)
    state.totalTime := 0; state.taskCount := 0;
    Queue.Foreach(taskQueue, TaskTimeCounter, state);
    Out.String("Total estimated time: "); Out.Int(state.totalTime, 0); Out.String(" minutes"); Out.Ln; Out.Ln;
    
    (* Peek at next task *)
    success := Queue.Front(taskQueue, result);
    IF success THEN
        Out.String("Next task to process (peek): ");
        PrintTask(result(TaskPtr));
        Out.Ln
    END;
    
    (* Process tasks in FIFO order *)
    Out.String("Processing tasks in order received:"); Out.Ln;
    WHILE ~Queue.IsEmpty(taskQueue) DO
        Queue.Dequeue(taskQueue, result);
        IF result # NIL THEN
            Out.String("Processing: ");
            PrintTask(result(TaskPtr))
        END
    END;
    
    Out.Ln;
    Out.String("All tasks processed. Queue is now empty."); Out.Ln;
    Queue.Free(taskQueue)
END DemonstrateTaskScheduling;

(** Demonstrate customer support ticket queue *)
PROCEDURE DemonstrateCustomerSupport();
BEGIN
    Out.String("=== Customer Support Queue Example ==="); Out.Ln;
    Out.String("Support tickets are handled first-come, first-served"); Out.Ln; Out.Ln;
    
    ticketQueue := Queue.New();
    
    (* Add support tickets *)
    Out.String("Receiving support tickets:"); Out.Ln;
    
    ticket := NewTicket(1001, 900, "Alice Smith", "Login issues");
    Queue.Enqueue(ticketQueue, ticket);
    Out.String("Received: "); PrintTicket(ticket);
    
    ticket := NewTicket(1002, 905, "Bob Johnson", "Password reset");
    Queue.Enqueue(ticketQueue, ticket);
    Out.String("Received: "); PrintTicket(ticket);
    
    ticket := NewTicket(1003, 910, "Carol Davis", "Account suspended");
    Queue.Enqueue(ticketQueue, ticket);
    Out.String("Received: "); PrintTicket(ticket);
    
    ticket := NewTicket(1004, 915, "David Wilson", "Billing question");
    Queue.Enqueue(ticketQueue, ticket);
    Out.String("Received: "); PrintTicket(ticket);
    
    Out.Ln;
    Out.String("Support queue has "); Out.Int(Queue.Count(ticketQueue), 0); Out.String(" pending tickets"); Out.Ln; Out.Ln;
    
    (* Process tickets in order *)
    Out.String("Processing tickets in order received:"); Out.Ln;
    WHILE ~Queue.IsEmpty(ticketQueue) DO
        Queue.Dequeue(ticketQueue, result);
        IF result # NIL THEN
            Out.String("Handling: ");
            PrintTicket(result(TicketPtr))
        END
    END;
    
    Out.Ln;
    Out.String("All tickets resolved."); Out.Ln;
    Queue.Free(ticketQueue)
END DemonstrateCustomerSupport;

(** Demonstrate print job queue *)
PROCEDURE DemonstratePrinterQueue();
BEGIN
    Out.String("=== Printer Queue Example ==="); Out.Ln;
    Out.String("Print jobs are processed in submission order"); Out.Ln; Out.Ln;
    
    printerQueue := Queue.New();
    
    (* Add print jobs *)
    Out.String("Submitting print jobs:"); Out.Ln;
    
    printJob := NewPrintJob(501, 3, "report.pdf", "Alice");
    Queue.Enqueue(printerQueue, printJob);
    Out.String("Submitted: "); PrintJobDetails(printJob);
    
    printJob := NewPrintJob(502, 1, "memo.doc", "Bob");
    Queue.Enqueue(printerQueue, printJob);
    Out.String("Submitted: "); PrintJobDetails(printJob);
    
    printJob := NewPrintJob(503, 12, "presentation.ppt", "Carol");
    Queue.Enqueue(printerQueue, printJob);
    Out.String("Submitted: "); PrintJobDetails(printJob);
    
    printJob := NewPrintJob(504, 2, "invoice.pdf", "David");
    Queue.Enqueue(printerQueue, printJob);
    Out.String("Submitted: "); PrintJobDetails(printJob);
    
    Out.Ln;
    Out.String("Printer queue has "); Out.Int(Queue.Count(printerQueue), 0); Out.String(" jobs"); Out.Ln; Out.Ln;
    
    (* Process jobs in order *)
    Out.String("Printing jobs in submission order:"); Out.Ln;
    WHILE ~Queue.IsEmpty(printerQueue) DO
        Queue.Dequeue(printerQueue, result);
        IF result # NIL THEN
            Out.String("Printing: ");
            PrintJobDetails(result(PrintJobPtr))
        END
    END;
    
    Out.Ln;
    Out.String("All print jobs completed."); Out.Ln;
    Queue.Free(printerQueue)
END DemonstratePrinterQueue;

(** Demonstrate queue operations and behavior *)
PROCEDURE DemonstrateQueueOperations();
BEGIN
    Out.String("=== Queue Operations Demo ==="); Out.Ln;
    Out.String("Demonstrating enqueue, dequeue, front, and clear operations"); Out.Ln; Out.Ln;
    
    urgentQueue := Queue.New();
    
    (* Start with empty queue *)
    Out.String("Starting with empty queue"); Out.Ln;
    Out.String("IsEmpty: "); 
    IF Queue.IsEmpty(urgentQueue) THEN Out.String("TRUE") ELSE Out.String("FALSE") END;
    Out.String(", Count: "); Out.Int(Queue.Count(urgentQueue), 0); Out.Ln; Out.Ln;
    
    (* Add some items *)
    Out.String("Enqueuing items:"); Out.Ln;
    FOR i := 1 TO 3 DO
        task := NewTask(i, i * 10, "Urgent task");
        Queue.Enqueue(urgentQueue, task);
        Out.String("  Enqueued task "); Out.Int(i, 0);
        Out.String(" (Count: "); Out.Int(Queue.Count(urgentQueue), 0); Out.String(")"); Out.Ln
    END;
    Out.Ln;
    
    (* Peek at front *)
    success := Queue.Front(urgentQueue, result);
    IF success THEN
        Out.String("Front item (peek, no removal): Task #");
        Out.Int(result(TaskPtr).taskId, 0); Out.Ln
    END;
    Out.String("Count after peek: "); Out.Int(Queue.Count(urgentQueue), 0); Out.Ln; Out.Ln;
    
    (* Dequeue one item *)
    Queue.Dequeue(urgentQueue, result);
    IF result # NIL THEN
        Out.String("Dequeued: Task #"); Out.Int(result(TaskPtr).taskId, 0); Out.Ln;
        Out.String("Count after dequeue: "); Out.Int(Queue.Count(urgentQueue), 0); Out.Ln; Out.Ln
    END;
    
    (* Add more items *)
    Out.String("Adding more items:"); Out.Ln;
    FOR i := 4 TO 5 DO
        task := NewTask(i, i * 10, "New task");
        Queue.Enqueue(urgentQueue, task);
        Out.String("  Enqueued task "); Out.Int(i, 0); Out.Ln
    END;
    Out.String("Total count: "); Out.Int(Queue.Count(urgentQueue), 0); Out.Ln; Out.Ln;
    
    (* Clear queue *)
    Out.String("Clearing queue..."); Out.Ln;
    Queue.Clear(urgentQueue);
    Out.String("After clear - IsEmpty: ");
    IF Queue.IsEmpty(urgentQueue) THEN Out.String("TRUE") ELSE Out.String("FALSE") END;
    Out.String(", Count: "); Out.Int(Queue.Count(urgentQueue), 0); Out.Ln;
    
    Queue.Free(urgentQueue)
END DemonstrateQueueOperations;

BEGIN
    Out.String("Queue Examples"); Out.Ln;
    Out.String("=============="); Out.Ln; Out.Ln;
    
    DemonstrateTaskScheduling();
    Out.Ln; Out.String("----------------------------------------"); Out.Ln; Out.Ln;
    
    DemonstrateCustomerSupport();
    Out.Ln; Out.String("----------------------------------------"); Out.Ln; Out.Ln;
    
    DemonstratePrinterQueue();
    Out.Ln; Out.String("----------------------------------------"); Out.Ln; Out.Ln;
    
    DemonstrateQueueOperations();
    
    Out.Ln; Out.String("Queue examples completed."); Out.Ln
END ExampleQueue.
