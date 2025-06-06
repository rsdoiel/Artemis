MODULE Bitwise;

(** This module implements bitwise operations for the INTEGER and BYTE types. *)

IMPORT SYSTEM;

PROCEDURE And8*(a, b: BYTE): BYTE;
(** Perform bitwise AND operation on two bytes. *)
VAR 
    set: SET;
BEGIN
    (* Perform bitwise AND *)
    set := SYSTEM.VAL(SET, a) * SYSTEM.VAL(SET, b);
    
    (* Convert back to INTEGER *)
    RETURN SYSTEM.VAL(BYTE, set)
END And8;

PROCEDURE And*(a, b: INTEGER): INTEGER;
(** Perform bitwise AND operation on two integers. *)
VAR 
    set: SET;
BEGIN
    (* Perform bitwise AND *)
    set := SYSTEM.VAL(SET, a) * SYSTEM.VAL(SET, b);
    
    (* Convert back to INTEGER *)
    RETURN SYSTEM.VAL(INTEGER, set)
END And;

PROCEDURE Or8*(a, b: BYTE): BYTE;
(** Perform bitwise OR operation on two bytes. *)
VAR 
    set: SET;
BEGIN
    (* Perform bitwise OR *)
    set := SYSTEM.VAL(SET, a) + SYSTEM.VAL(SET, b);
    
    (* Convert back to BYTE *)
    RETURN SYSTEM.VAL(BYTE, set)
END Or8;

PROCEDURE Or*(a, b: INTEGER): INTEGER;
(** Perform bitwise OR operation on two integers. *)
VAR 
    set: SET;
BEGIN
    (* Perform bitwise OR *)
    set := SYSTEM.VAL(SET, a) + SYSTEM.VAL(SET, b);
    
    (* Convert back to INTEGER *)
    RETURN SYSTEM.VAL(INTEGER, set)
END Or;

PROCEDURE Xor8*(a, b: BYTE): BYTE;
(** Perform bitwise XOR operation on two bytes. *)
VAR 
    set: SET;
BEGIN   
    (* Perform bitwise XOR *)
    set := SYSTEM.VAL(SET, a) / SYSTEM.VAL(SET, b);
    
    (* Convert back to BYTE *)
    RETURN SYSTEM.VAL(BYTE, set)
END Xor8;

PROCEDURE Xor*(a, b: INTEGER): INTEGER;
(** Perform bitwise XOR operation on two integers. *)
VAR 
    set: SET;
BEGIN   
    (* Perform bitwise XOR *)
    set := SYSTEM.VAL(SET, a) / SYSTEM.VAL(SET, b);
    
    (* Convert back to INTEGER *)
    RETURN SYSTEM.VAL(INTEGER, set)
END Xor;

PROCEDURE Not8*(a: BYTE): BYTE;
(** Perform bitwise NOT operation on a byte. *)
VAR 
    set: SET;
BEGIN
    (* Use the BIC (AND NOT) operation *)
    set := SYSTEM.VAL(SET, 0FFH) - SYSTEM.VAL(SET, a);
    
    (* Convert back to BYTE *)
    RETURN SYSTEM.VAL(BYTE, set)
END Not8;

(** Perform bitwise NOT operation on an integer. *)
PROCEDURE Not*(a: INTEGER): INTEGER;
VAR 
    set: SET;
BEGIN
    (* Use the BIC (AND NOT) operation *)
    set := SYSTEM.VAL(SET, 0FFFFFFFFH) - SYSTEM.VAL(SET, a);
    
    (* Convert back to INTEGER *)
    RETURN SYSTEM.VAL(INTEGER, set)
END Not;


PROCEDURE ShiftLeft8*(a: BYTE; n: BYTE): BYTE;
(** Perform shift left operation on a byte. *)
BEGIN
    RETURN LSL(a, n)
END ShiftLeft8;

PROCEDURE ShiftRight8*(a: BYTE; n: BYTE): BYTE;
(** Perform signed shift right operation on a byte. *)
BEGIN
    RETURN ASR(a, n)
END ShiftRight8;

PROCEDURE RotateLeft8*(a: BYTE; n: BYTE): BYTE;
(** Perform rotate left operation on a byte. *)
BEGIN
    RETURN ROR(a, 32 - n)
END RotateLeft8;

PROCEDURE RotateRight8*(a: BYTE; n: BYTE): BYTE;
(** Perform rotate right operation on a byte. *)
BEGIN
    RETURN ROR(a, n)
END RotateRight8;


PROCEDURE ShiftLeft*(a: INTEGER; n: INTEGER): INTEGER;
(** Perform shift left operation on an integer. *)
BEGIN
    RETURN LSL(a, n)
END ShiftLeft;

PROCEDURE ShiftRight*(a: INTEGER; n: INTEGER): INTEGER;
(** Perform signed shift right operation on an integer. *)
BEGIN
    RETURN ASR(a, n)
END ShiftRight;

PROCEDURE RotateLeft*(a: INTEGER; n: INTEGER): INTEGER;
(** Perform rotate left operation on an integer. *)
BEGIN
    RETURN ROR(a, 32 - n)
END RotateLeft;

PROCEDURE RotateRight*(a: INTEGER; n: INTEGER): INTEGER;
(** Perform rotate right operation on an integer. *)
BEGIN
    RETURN ROR(a, n)
END RotateRight;

END Bitwise.
