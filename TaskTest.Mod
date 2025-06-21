(**
    TaskTest.Mod - Minimal tests for Task cooperative scheduler and channels
    
    Copyright (C) 2025
    Released under The 3-Clause BSD License.
*)
MODULE TaskTest;

IMPORT Task, Tests, Collections;

TYPE
    (** Wrapper for INTEGER - a Collections.Item *)
    IntegerWrapper* = RECORD(Collections.Item)
        value*: INTEGER
    END;
    IntegerWrapperPtr* = POINTER TO IntegerWrapper;

    (* Context descriptor - pass data to tasks. *)
    MyContext = POINTER TO MyContextDesc;
    MyContextDesc = RECORD (Task.TaskContextDesc)
        value: INTEGER;
        counter: INTEGER
    END;

VAR ts: Tests.TestSet;

(** Create a new INTEGER wrapper *)
PROCEDURE NewIntegerWrapper(i: INTEGER): Collections.ItemPtr;
VAR wrapper: IntegerWrapperPtr; result: Collections.ItemPtr;
BEGIN
    NEW(wrapper);
    wrapper.value := i;
    result := wrapper;
    RETURN result
END NewIntegerWrapper;

PROCEDURE MyTask(ctx: Task.TaskContext);
VAR myCtx: MyContext;
BEGIN
  myCtx := ctx(MyContext);
  
  CASE myCtx.resumePoint OF
  | 0: (* Initialization *)
    myCtx.counter := 0; Task.Yield(ctx)
  | 1: (* Work phase *)
    INC(myCtx.counter);
    IF myCtx.counter < 3 THEN Task.YieldAt(ctx, 1) ELSE Task.Yield(ctx) END
  | 2: (* Completion *)
    myCtx.value := 255
  END
END MyTask;

PROCEDURE TestChannelSendReceive(): BOOLEAN;
VAR ch: Task.Channel; ok: BOOLEAN; pass: BOOLEAN; msg, out : Collections.ItemPtr;
BEGIN
    msg := NewIntegerWrapper(42);
    pass := TRUE;
    ch := Task.NewChannel(2);
    ok := Task.Send(ch, msg);
    pass := pass & (ok = TRUE);
    ok := Task.Receive(ch, out);
    pass := pass & (ok = TRUE);
    pass := pass & (out(IntegerWrapperPtr).value = 42);
    RETURN pass
END TestChannelSendReceive;

PROCEDURE TestChannelBufferLimits(): BOOLEAN;
VAR ch: Task.Channel; ok: BOOLEAN; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    ch := Task.NewChannel(1);
    ok := Task.Send(ch, NewIntegerWrapper(1));
    pass := pass & (ok = TRUE);
    ok := Task.Send(ch, NewIntegerWrapper(2));
    pass := pass & (ok = FALSE);
    RETURN pass
END TestChannelBufferLimits;

PROCEDURE TestChannelEmptyReceive(): BOOLEAN;
VAR ch: Task.Channel; out: Collections.ItemPtr; ok: BOOLEAN; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    ch := Task.NewChannel(1);
    ok := Task.Receive(ch, out);
    pass := pass & (ok = FALSE);
    RETURN pass
END TestChannelEmptyReceive;

PROCEDURE TestScheduler(): BOOLEAN;
VAR sched: Task.Scheduler; ctx : MyContext; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    sched := Task.NewScheduler();
    NEW(ctx); ctx.value := 42;
    Task.AddTask(sched, MyTask, ctx);
    Task.Run(sched);
    pass := pass & (ctx.value = 255);
    RETURN pass
END TestScheduler;

PROCEDURE TestYielding(): BOOLEAN;
VAR sched: Task.Scheduler; ctx1, ctx2: MyContext; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    sched := Task.NewScheduler();
    
    (* Add two tasks that will interleave *)
    NEW(ctx1); ctx1.value := 10;
    NEW(ctx2); ctx2.value := 20;
    
    Task.AddTask(sched, MyTask, ctx1);
    Task.AddTask(sched, MyTask, ctx2);
    Task.Run(sched);
    
    pass := pass & (ctx1.value = 255);
    pass := pass & (ctx2.value = 255);
    RETURN pass
END TestYielding; 

BEGIN
    Tests.Init(ts, "Task Tests");
    Tests.Add(ts, TestChannelSendReceive);
    Tests.Add(ts, TestChannelBufferLimits);
    Tests.Add(ts, TestChannelEmptyReceive);
    Tests.Add(ts, TestScheduler);
    Tests.Add(ts, TestYielding);
    ASSERT(Tests.Run(ts));
END TaskTest.
