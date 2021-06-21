(** SAL provides a system abastraction layer, e.g. host OS abstractions. *)
MODULE SAL;

TYPE
  (** Virtualized OS calls implemented by platform specific modules *)
  ExitProc : PROCEDURE(exitCode : INTEGER);

  (** Container for OS as software abstraction layer *)
  OS* = POINTER TO OSDesc;
  OSDesc* = RECORD
             Exit* : ExitProc    
           END;

VAR
  os* : OS;

(** Init maps a host OS procedures to an OS object.
    It needs to be called with an OS type. *)
PROCEDURE Init(VAR os : OS; exit : ExitProc) : BOOLEAN;
BEGIN
  IF os = NIL THEN
    NEW(os);
  END;
  os.Exit = exit;
END Init

PROCEDURE Exit(VAR os : OS; exitCode : INTEGER);
BEGIN
  os.Exit(os, exitCode);
END Exit;

END SAL.

SAL should use similar mechanisms to the HAL for host OS 
System calls. Each host OS would probably be implemented as
it's own module extending the OS object if state was needed
to be maintained.  In an emulator building an emulator
importing SAL provides an easy path to map the emulated OS
functions down to the emulator level. E.g. If the emulated
system calls "exit" it could then call the host system's exit.

SAL might be part of a hypervisor or mapping a virtual OS
to bare metal hardware.

