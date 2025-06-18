# Task Module: Cooperative Multitasking for Oberon-07

## What is it?

The **Task** module provides stackless coroutines and cooperative multitasking for Oberon-07. Perfect for:
- **MCUs and embedded systems** (no stack per task)
- **Single-core systems** (no threading overhead)
- **Predictable scheduling** (no preemption)

## Key Features

- **Stackless coroutines** - Tasks store their state in context records  
- **Cooperative scheduling** - Tasks voluntarily yield control  
- **Channel communication** - Buffered message passing between tasks  
- **Zero threading** - Pure cooperative, no OS dependencies  
- **Memory efficient** - No stack per task, just small context records  

## Basic Usage Pattern

```oberon
IMPORT Task;

(* 1. Define your task context *)
TYPE
    MyContext = POINTER TO MyContextDesc;
    MyContextDesc = RECORD (Task.TaskContextDesc)
        counter: INTEGER;
        maxCount: INTEGER
    END;

(* 2. Write your task procedure *)
PROCEDURE MyTask(ctx: Task.TaskContext);
VAR myCtx: MyContext;
BEGIN
    myCtx := ctx(MyContext);
    
    CASE myCtx.resumePoint OF
    | 0: (* Initialization *)
        myCtx.counter := 0; 
        Task.Yield(ctx)
        
    | 1: (* Work loop *)
        INC(myCtx.counter);
        Out.Int(myCtx.counter, 0); Out.Ln;
        IF myCtx.counter < myCtx.maxCount THEN
            Task.YieldAt(ctx, 1)  (* Stay in this phase *)
        ELSE
            Task.Yield(ctx)       (* Move to next phase *)
        END
        
    | 2: (* Completion *)
        Out.String("Done!"); Out.Ln
    END
END MyTask;

(* 3. Set up and run *)
VAR scheduler: Task.Scheduler; context: MyContext;
BEGIN
    scheduler := Task.NewScheduler();
    NEW(context); 
    context.maxCount := 5;
    
    Task.AddTask(scheduler, MyTask, context);
    Task.Run(scheduler)
END
```

## Channels for Communication

```oberon
IMPORT Task, Out;

(* Create buffered channel *)
VAR ch: Task.Channel;
BEGIN
    ch := Task.NewChannel(10);  (* Buffer size 10 *)
    
    (* Send message (non-blocking) *)
    IF Task.Send(ch, myMessage) THEN
        Out.String("Sent!"); Out.Ln
    ELSE
        Out.String("Channel full"); Out.Ln
    END;
    
    (* Receive message (non-blocking) *)
    IF Task.Receive(ch, receivedMsg) THEN
        Out.String("Received!"); Out.Ln
    ELSE
        Out.String("Channel empty"); Out.Ln
    END
END
```

## Why Stackless?

**Traditional coroutines:**
- Each task needs its own stack
- Stack switching overhead
- Memory overhead grows with task count

**Stackless coroutines:**
- Tasks store state in small context records
- No stack switching - just case statements
- Memory usage is O(1) per task

## Example

```oberon
MODULE TaskExample;
IMPORT Task, Out;

TYPE
    CounterCtx = POINTER TO CounterCtxDesc;
    CounterCtxDesc = RECORD (Task.TaskContextDesc)
        count: INTEGER
    END;

PROCEDURE Counter(ctx: Task.TaskContext);
VAR c: CounterCtx;
BEGIN
    c := ctx(CounterCtx);
    CASE c.resumePoint OF
    | 0: c.count := 1; Task.Yield(ctx)
    | 1: Out.Int(c.count, 0); Out.Ln; INC(c.count);
         IF c.count <= 3 THEN Task.YieldAt(ctx, 1) END
    END
END Counter;

VAR sched: Task.Scheduler; ctx: CounterCtx;
BEGIN
    sched := Task.NewScheduler();
    NEW(ctx);
    Task.AddTask(sched, Counter, ctx);
    Task.Run(sched)
END TaskExample.
```

**Output:**
```
1
2
3
```

## When to Use Tasks

 - **Producer-Consumer patterns**  
 - **State machines** with multiple phases  
 - **Background processing** that needs to yield periodically  
 - **Event-driven systems** without callbacks  
 - **Embedded systems** where memory and predictability matter  

## Scheduler Lifetime

⚠️ **Important:** The scheduler runs until **all tasks complete**. For long-running systems:

**For embedded/forever-running systems:**
```oberon
(* Create a "supervisor" task that never finishes *)
PROCEDURE SupervisorTask(ctx: Task.TaskContext);
BEGIN
    CASE ctx.resumePoint OF
    | 0: (* Do periodic work *)
        CheckSensors();
        Task.YieldAt(ctx, 0)  (* Loop forever *)
    END
END SupervisorTask;
```

**For batch processing:**
```oberon
(* Let all tasks finish naturally - scheduler will exit *)
Task.Run(scheduler);
Out.String("All work completed!"); Out.Ln;
```

This gives you **explicit control** over when your program should terminate.

## Key Rules

1. **Always use CASE statements** for resume points
2. **Call Yield() or YieldAt()** to give other tasks a chance
3. **Extend TaskContextDesc** for your task data
4. **No early returns** - follow Oberon-07 rules
5. **Tasks finish** when they reach the end without yielding

---

**See `examples/ExampleTask.Mod` for a complete producer-consumer demonstration!**
