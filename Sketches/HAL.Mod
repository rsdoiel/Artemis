(** HAL a hardware abstraction layer *)
MODULE HAL;

TYPE
  VirtualMachine = POINTER TO VirualMachineDesc;
  Command = PROCEDURE(VAR vm : VirtualMachine);
  VirtualMachineDesc = RECORD
                         Configure : Command;
                         Start : Command;
                         Shutdown : Command;
                         Restart : Command;
                         Status : Command;
                       END;


(** Initialize a Virtual Machine *)
PROCEDURE Init(VAR vm : VirtualMachine; configure, start, shutdown, restart, status : Command);
BEGIN
  IF vm = NIL THEN
    NEW(vm);
  END;
  vm.Configure = configure;
  vm.Start = start;
  vm.Shutdown = shutdown;
  vm.Retart = restart;
  vm.Status = status;
END Init;

(** Start "power up" the virtual machine *)
PROCEDURE Start(VAR vm : VirtualMachine);
  vm.Start(vm);
END Start;

(** Shutdown "power off" the virtual machine *)
PROCEDURE Shutdown(VAR vm : VirtualMachine *)
  vm.Shutdown(vm);
END Stop;

(** Restart "reboots" a virtual machine *)
PROCEDURE Restart(VAR vm : VirtualMachine);
  vm.Restart(vm);
END Restart;

(** Status executes a machine "status" method *)
PROCEDURE Status(VAR vm : VirtualMachine);
BEGIN
  vm.Status(vm);
END Status;

END HAL.
