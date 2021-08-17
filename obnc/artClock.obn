(** Clock.Mod - a hardware abstraction module.

Copyright (C) 2021 R. S. Doiel

Released under The 3-Clause BSD License.
See https://opensource.org/licenses/BSD-3-Clause

*)
MODULE artClock; (** NOT PORTABLE, Assumes OBNC compiler *)

TYPE
  (** Clock and ClockDesc types holds a normalized presentation
      of the system clock data structures. *)
  Clock* = POINTER TO ClockDesc;
  ClockDesc* = RECORD
               (** this is what is used by clock_gettime(), clock_settime()  and would be used to do time intervals. *)
               seconds : INTEGER; (** Unix EPoch in seconds *)
               nanoSeconds : INTEGER; (** nanoseconds *)

               (** The following are based on C struct tm *)
               year* : INTEGER; (** Normalized year *)
               month* : INTEGER; (** 1 through 12, Jan. through Dec. *)
               day* : INTEGER; (** 1 through 31 *)
               hour* : INTEGER; (** 0 through 23 *)
               minute* : INTEGER; (** 0 through 59 *)
               second* : INTEGER; (** 0 through 59 *)
               (** wDay is day of week 0 - 6, 6 = Saturday, 0 is Monday *) 
               wDay* : INTEGER;
               (** yDay is a julian style date, days since start of year *)
               yDay* : INTEGER;
               (** isDST has three possible settings. 
                  -1 (negative number) info unavailable,
                  zero if Standard Time, one if
                  Daylight Savings Time *)
               isDST* : INTEGER; 
               (** utcOffset can be impacted by isDST state
                   and implementations on local system.
                   E.g. America/Los Angeles PST is -08:00 UTC,
                   America/Los Angeles PDT is -07:00 UTC *)
               utcOffset* : INTEGER
             END;

VAR
  (** clock holds the values for the last call to either
      Update() or Get(). *)
  clock* : Clock;
  (** clockError is TRUE if an error occurred on the last call
      to the host's get_clocktime(), otherwise it is set to FALSE *)
  clockError : BOOLEAN;

(** Interface into POSIX time, date infrastructure. 
    These procedures call into POSIX via OBNC's C interface. *)

(* GetRtcTime set the values of second,
   minute, hour, day, month, year, wDay, yDay,
   isDST and utcOffset based on the local time value returned
   by C clock_gettime() and localtime() functions. The final
   parameter "ok" will be TRUE if the call to clock_gettime()
   was successful and FALSE otherwise.

   NOTE: The values for year, month, day are normalized before
   being updated.  Year reflects the current year and month
   is in the range of 1 through 12. *)
PROCEDURE GetRtcTime(VAR second, minute, hour, day, month, year, wDay, yDay,  isDST, utcOffset, seconds, nanoSeconds : INTEGER; VAR ok : BOOLEAN);
BEGIN
END GetRtcTime;

(* SetRtcTime sets the system clock using C clock_settime(). You
   must of permission (e.g. root) for this to succeed. You provide
   Year should be actual year (adjusting for 1900 happens in the C
   level code) and month should be 1 to 12. If setting the system
   time is successful then ok will be TRUE otherwise it will be
   set to FALSE. *)
PROCEDURE SetRtcTime(second, minute, hour, day, month, year, wDay, yDay, isDST, utcOffset : INTEGER; VAR ok : BOOLEAN);
BEGIN
END SetRtcTime;

(** Copy copies the values from source clock to destination *)
PROCEDURE Copy*(source : Clock; VAR dest : Clock);
BEGIN
    dest.seconds := source.seconds;
    dest.nanoSeconds := source.nanoSeconds;
    dest.second := source.second;
    dest.minute := source.minute;
    dest.hour := source.hour;
    dest.day := source.day;
    dest.month := source.month;
    dest.year := source.year;
    dest.wDay := source.wDay;
    dest.yDay := source.yDay;
    dest.isDST := source.isDST;
    dest.utcOffset := source.utcOffset;
END Copy;

(** Update populates Clock.clock based on what is
    returned by host system clock. 

    NOTE: the year is normalized and month is in range 1 to 12
    unlike the values return POSIX localtime(). *)
PROCEDURE Update*();
  VAR second, minute, hour, day, month, year, wDay, yDay, 
      isDST, utcOffset, seconds, nanoSeconds : INTEGER; 
      ok : BOOLEAN;
BEGIN
  GetRtcTime(second, minute, hour, day, month, year, wDay, yDay, isDST, utcOffset, seconds, nanoSeconds, ok);
  (* Update the record requested, update the module's clock record *)
  IF clock = NIL THEN
    NEW(clock);
  END;
  clockError := ~ ok;
  IF ok THEN
    clock.seconds := seconds;
    clock.nanoSeconds := nanoSeconds;
    clock.year := year;
    clock.month := month;
    clock.day := day;
    clock.hour := hour;
    clock.minute := minute;
    clock.second := second;
    clock.wDay := wDay;
    clock.yDay := yDay;
    clock.isDST := isDST;
    clock.utcOffset := utcOffset;
  END;
END Update;


(** Get updates Clock.clock and sets the value of the
    Clock from Clock.clock.

    NOTE: the year is normalized and month is in range 1 to 12
    unlike the values return POSIX localtime(). *)
PROCEDURE Get*(VAR c : Clock);
BEGIN
  Update();
  (* Update the record requested, update the module's clock record *)
  IF c = NIL THEN
    NEW(c);
  END;
  Copy(clock, c);
END Get;

(** Set attempts to set the host system clock. On most systems
    this will require root level permissions.  If successful 
    Clock.clock is updated and the value of 
    ok will be TRUE. If the host system clock isn't updated 
    (e.g. you don't have permission) then ok is set to FALSE.

    NOTE: SetRtcTime() uses the C clock_settime() and localtime().  *)
PROCEDURE Set*(c : Clock; VAR ok : BOOLEAN);
BEGIN
  SetRtcTime(c.second, c.minute, c.hour, c.day, c.month, c.year, c.wDay, c.yDay, c.isDST, c.utcOffset, ok);
  IF ok THEN 
    Copy(c, clock);
  END;
END Set;

BEGIN Update();
END artClock.


artClock
========

artClock implements an interface into the C level clock functions.

+ clock_gettime()
+ localtime()
+ clock_settime()


