(** ClockTest.Mod - Tests for Clock.Mod.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

*)
MODULE ClockTest;

IMPORT T := Tests, Env := extEnv, Clock := artClock, Out, Strings;

VAR ts : T.TestSet;

PROCEDURE DisplayClock(ct : Clock.Clock);
  VAR i, hours, minutes : INTEGER;
BEGIN
  Out.Int(ct.year, 4); 
  Out.String("-");
  IF ct.month < 10 THEN
    Out.String("0"); Out.Int(ct.month, 1); 
  ELSE
    Out.Int(ct.month, 2); 
  END;
  Out.String("-");
  IF ct.day < 10 THEN
    Out.String("0"); Out.Int(ct.month, 1);
  ELSE
    Out.Int(ct.day, 2);
  END; 
  Out.String(" ");
  IF ct.hour < 10 THEN
    Out.String("0"); Out.Int(ct.hour, 1);
  ELSE
    Out.Int(ct.hour, 2);
  END;
  Out.String(":");
  IF ct.minute < 10 THEN
    Out.String("0"); Out.Int(ct.minute, 1);
  ELSE
    Out.Int(ct.minute, 2);
  END;
  Out.String(":");
  IF ct.second < 10 THEN
    Out.String("0"); Out.Int(ct.second, 1);
  ELSE
    Out.Int(ct.second, 2);
  END;
  IF ct.isDST < 0 THEN
    Out.String(" "); (* DST info not available *)
  ELSIF ct.isDST = 0 THEN
    Out.String(" (ST)");
  ELSIF ct.isDST = 1 THEN
    Out.String(" (DST)");
  END;
  i := ABS(ct.utcOffset);
  IF (i >= 0) & (i <= 86400) THEN
    hours := (i DIV 3600) MOD 60;
    minutes := (i MOD 3600);
    Out.String(" UTC");
    IF (ct.utcOffset >= 0) THEN
      Out.String("+");
      IF hours < 10 THEN
        Out.String("0");
      END;
      Out.Int(hours, 1);
    ELSE
      Out.String("-");
      IF (ABS(hours) < 10) THEN
        Out.String("0");
      END;
      Out.Int(ABS(hours), 1);
    END;
    IF minutes < 10 THEN
      Out.String("0"); Out.Int(minutes, 1);
    ELSE
      Out.Int(minutes, 2);
    END;
  END;
  Out.Ln();
END DisplayClock;

PROCEDURE TestClockAndTime*() : BOOLEAN;
  VAR test : BOOLEAN; t1 : Clock.Clock;
BEGIN test := TRUE;
  NEW(t1);
  Clock.Get(t1);
  T.ExpectedBool(TRUE, (t1.year > 2020), "Expected t1.year > 2020", test);
  T.ExpectedBool(TRUE, ((t1.month >= 1) & (t1.month <= 12)), "Expected (t1.month >= 1) & (t1.mongth <= 12)", test);
  T.ExpectedBool(TRUE, (t1.day > 0), "Expected t1.day > 0", test);
  T.ExpectedBool(TRUE, (t1.hour > -1), "Expected t1.hour > 0", test);
  T.ExpectedBool(TRUE, (t1.minute > -1), "Expected t1.minute > 0", test);
  T.ExpectedBool(TRUE, (t1.second > -1), "Expected t1.second > 0", test);

  RETURN test
END TestClockAndTime;

PROCEDURE TestClockSet*() : BOOLEAN;
  VAR test : BOOLEAN; ct, tt, sc : Clock.Clock; ok : BOOLEAN;
      uname, os : ARRAY 256 OF CHAR; res : INTEGER;
BEGIN test := TRUE;
  Env.Get("OS", os, res);
  Env.Get("SUDO_USER", uname, res);
  IF os = "Linux" THEN
    Out.String("Skipping TestClockSet(), Clock.Set() is not permitted under Linux"); Out.Ln();
  ELSIF (Strings.Length(uname) = 0) & (os = "Darwin") THEN
    Out.String(" Skipping TestSet(), Clock.Set() requires admin privilleges for Darwin (macOS)");Out.Ln();
    Out.String(" You can try rerunning tests with");Out.Ln();
    Out.Ln(); Out.String("             sudo make test");Out.Ln();Out.Ln();
  ELSE
    NEW(ct); NEW(tt); NEW(sc);
    Clock.Get(ct);
    Out.String(" Current clock: ");DisplayClock(ct);
    tt.year := ct.year + 1;
    tt.month := ct.month + 1;
    IF tt.month > 12 THEN
      INC(tt.year);
      ct.month := 1;
    END;
    tt.day := ct.day;
    tt.hour := ct.hour;
    tt.minute := ct.minute;
    tt.second := ct.second;
    tt.isDST := ct.isDST;
    tt.utcOffset := ct.utcOffset;
    Clock.Get(sc); (* Save the time to reset later *)
    Clock.Set(tt, ok);
    T.ExpectedBool(TRUE, ok, "Clock.Set(tt, ok) failed", test);
    IF ok THEN
      Out.String("     New clock: ");DisplayClock(tt);
    
      T.ExpectedBool(TRUE, ok, "Clock.Set(tt, ok) ", test);
    
      T.ExpectedBool(TRUE, (Clock.clock.year = tt.year), "new time year", test);
      T.ExpectedBool(TRUE, (Clock.clock.month = tt.month), "new time month", test);
      T.ExpectedBool(TRUE, (Clock.clock.day = tt.day), "new time day", test);
      T.ExpectedBool(TRUE, (Clock.clock.hour = tt.hour), "new time hour", test);
      T.ExpectedBool(TRUE, (Clock.clock.minute = tt.minute), "new time minute", test);
      T.ExpectedBool(TRUE, (Clock.clock.second = tt.second), "new time second", test);
      (* Reset the clock *)
      Clock.Set(sc, ok);
      Clock.Get(ct); 
      Out.String("   Reset clock: "); DisplayClock(ct);
    END;
  END;

  RETURN test
END TestClockSet;

BEGIN
  T.Init(ts, "Test Clock");
  T.Add(ts, TestClockAndTime);
  T.Add(ts, TestClockSet);
  ASSERT(T.Run(ts));
END ClockTest.


