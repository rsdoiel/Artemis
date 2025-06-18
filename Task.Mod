(**
    Task.Mod - Cooperative task scheduler with stackless coroutines and channels
    
    Implements stackless coroutines using resume points and case statements.
    Suitable for MCUs and single-core systems. No threads, no blocking, no preemption.
    
    Usage Pattern (Oberon-07 compliant):
    
    PROCEDURE MyTask(ctx: TaskContext);
    VAR myCtx: MyContext;
    BEGIN
      myCtx := ctx(MyContext);
      
      CASE myCtx.resumePoint OF
      | 0: (* Phase 0 *) DoInitialization; Yield(ctx)
      | 1: (* Phase 1 *) DoWork; IF moreWork THEN YieldAt(ctx, 1) ELSE Yield(ctx) END  
      | 2: (* Phase 2 *) DoCleanup (* No yield = finished *)
      END
    END MyTask;
    
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
    Author: Artemis Project
*)
MODULE Task;

IMPORT Collections, Queue;

CONST 
    READY = 0; 
    RUNNING = 1;
    YIELDED = 2;
    FINISHED = 3;

TYPE
    (** Base context for all tasks - extend this for task-specific data *)
    TaskContext* = POINTER TO TaskContextDesc;
    TaskContextDesc* = RECORD (Collections.Item)
        resumePoint*: INTEGER  (** Current resume point for stackless coroutines *)
    END;

    (** Task procedure signature - receives context as parameter *)
    TaskProc* = PROCEDURE (ctx : TaskContext);
    
    (* Internal task representation *)
    Task = POINTER TO TaskDesc;
    TaskDesc = RECORD (Collections.Item)
        proc: TaskProc;
        context: TaskContext;
        state: INTEGER
    END;
    
    (** Cooperative task scheduler *)
    Scheduler* = POINTER TO SchedulerDesc;
    SchedulerDesc = RECORD
        tasks: Queue.Queue;
        current: Task
    END;
    
    (** Buffered communication channel *)
    Channel* = POINTER TO ChannelDesc;
    ChannelDesc = RECORD
        buffer: Queue.Queue;
        capacity: INTEGER
    END;

VAR
    currentTask: Task;
    yieldRequested: BOOLEAN;

(** Create a new cooperative task scheduler *)
PROCEDURE NewScheduler*(): Scheduler;
VAR sched: Scheduler;
BEGIN
    NEW(sched);
    sched.tasks := Queue.New();
    sched.current := NIL;
    RETURN sched
END NewScheduler;

(** Add a task to the scheduler with its context *)
PROCEDURE AddTask*(sched: Scheduler; proc: TaskProc; ctx : TaskContext);
VAR t: Task;
BEGIN
    IF (sched # NIL) & (proc # NIL) THEN
        NEW(t); 
        t.proc := proc; 
        t.context := ctx;
        t.state := READY;
        IF ctx # NIL THEN ctx.resumePoint := 0 END;
        Queue.Enqueue(sched.tasks, t)
    END
END AddTask;

(** Yield control to next task and auto-increment resume point *)
PROCEDURE Yield*(ctx: TaskContext);
BEGIN
    IF (currentTask # NIL) & (ctx # NIL) THEN
        INC(ctx.resumePoint);
        currentTask.state := YIELDED;
        yieldRequested := TRUE
    END
END Yield;

(** Yield control and set specific resume point for loops/branches *)
PROCEDURE YieldAt*(ctx: TaskContext; point: INTEGER);
BEGIN
    IF (currentTask # NIL) & (ctx # NIL) THEN
        ctx.resumePoint := point;
        currentTask.state := YIELDED;
        yieldRequested := TRUE
    END
END YieldAt;

(** Run scheduler in round-robin fashion until all tasks complete *)
PROCEDURE Run*(sched: Scheduler);
VAR t: Collections.ItemPtr; task: Task;
BEGIN
    IF sched # NIL THEN
        WHILE ~Queue.IsEmpty(sched.tasks) DO
            Queue.Dequeue(sched.tasks, t);
            task := t(Task);
            
            IF task.state # FINISHED THEN
                currentTask := task;
                task.state := RUNNING;
                yieldRequested := FALSE;
                
                (* Run the task *)
                IF task.proc # NIL THEN
                    task.proc(task.context)
                END;
                
                (* Check what happened *)
                IF yieldRequested THEN
                    (* Task yielded, put it back in queue *)
                    Queue.Enqueue(sched.tasks, task)
                ELSE
                    (* Task completed without yielding *)
                    task.state := FINISHED
                END;
                
                currentTask := NIL
            END
        END
    END
END Run;

(** Create a buffered channel for message passing between tasks *)
PROCEDURE NewChannel*(capacity: INTEGER): Channel;
VAR ch: Channel;
BEGIN
    NEW(ch);
    ch.buffer := Queue.New();
    ch.capacity := capacity;
    RETURN ch
END NewChannel;

(** Send message to channel - returns FALSE if buffer is full *)
PROCEDURE Send*(ch: Channel; msg: Collections.ItemPtr): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    result := FALSE;
    IF (ch # NIL) & (Queue.Count(ch.buffer) < ch.capacity) THEN
        Queue.Enqueue(ch.buffer, msg);
        result := TRUE
    END;
    RETURN result
END Send;

(** Receive message from channel - returns FALSE if buffer is empty *)
PROCEDURE Receive*(ch: Channel; VAR msg: Collections.ItemPtr): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    result := FALSE;
    msg := NIL;
    IF (ch # NIL) & (Queue.Count(ch.buffer) > 0) THEN
        Queue.Dequeue(ch.buffer, msg);
        result := TRUE
    END;
    RETURN result
END Receive;

BEGIN
    currentTask := NIL;
    yieldRequested := FALSE
END Task.
