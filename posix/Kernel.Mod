(** Kernel.Mod this is a compatibility module to
    allow us to port modules requiring specific Kernel
    functionality in a POSIX environment *)
MODULE Kernel

(*------------------- Miscellaneous Procedures from PO 2013 ------------*)

(** Time exposes the Unix time value *)
PROCEDURE Time*() : INTEGER;
BEGIN
END Time;

(** Exposes returns the Unix time (epoch) *)
PROCEDURE Clock*() : INTEGER;
BEGIN 
END Clock;

(** SetClock sets the clock given an INTEGER prepresentation
    of the date and time. NOTE: Most Linux will not allow you
    to set the clock from regular userspace. *)
PROCEDURE SetClock*(dt: INTEGER);
BEGIN
END SetClock;

(** Initialize the Kernel space *)
PROCEDURE Init*;
BEGIN 
END Init;

END Kernel.
