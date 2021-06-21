(* Ported version of RISC module defined in Compiler Construction book 
   to Oberon-7 *)
MODULE RISC0;     (*NW 22.9.07 / 15.12.2013 / RSD 2021-06-03 *)
  IMPORT SYSTEM, Scanner, Out, Math;
  CONST
    MOV = 0; LSHL = 1; ASHR = 2; ROT = 3;
    AND = 4; ANN = 5; IOR = 6; XOR = 7;
    ADD = 8; SUB = 9;  MUL = 10; Div = 11;

  VAR IR: INTEGER;   (*instruction register*)
    PC: INTEGER;   (*program counter*)
    N, Z: BOOLEAN;  (*condition flags*)
    R: ARRAY 16 OF INTEGER;
    H: INTEGER;  (*aux register for division*)
    
  PROCEDURE Execute*(VAR M: ARRAY OF INTEGER; pc: INTEGER;
      VAR S: Scanner.Scanner);
    VAR a, b, op, im: INTEGER;  (*instruction fields*)
      adr, A, B, C: INTEGER;
      MemSize: INTEGER;
  BEGIN PC := 0; R[13] := pc * 4; R[14] := LEN(M)*4;
    REPEAT (*interpretation cycle*)
      IR := M[PC]; INC(PC);
      a := IR DIV 1000000H MOD 10H;
      b := IR DIV 100000H MOD 10H;
      op := IR DIV 10000H MOD 10H;
      im := IR MOD 10000H;
      IF ~ODD(ASR(IR, -31)) THEN  (*~p:  register instruction*)
        B := R[b];
        IF ~ODD(ASR(IR, -30)) THEN (*~q*) C := R[IR MOD 10H]
        ELSIF ~ODD(ASR(IR, -28)) THEN (*q&~v*) C := im 
        ELSE (*q&v*) C := im + 0FFFF0000H
        END ;
        CASE op OF
            MOV: IF ~ODD(ASR(IR, -29)) THEN A := C ELSE A := H END |
            LSHL: A := LSL(B, C) |
            ASHR: A := ASR(B, -C) |
            ROT: A := ROR(B, -C) |
            AND: A := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET, B) * SYSTEM.VAL(SET, C)) |
            ANN: A := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET, B) - SYSTEM.VAL(SET, C)) |
            IOR: A := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET, B) + SYSTEM.VAL(SET, C)) |
            XOR: A := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET, B) / SYSTEM.VAL(SET, C)) |
            ADD: A := B + C |
            SUB: A := B - C |
            MUL: A := B * C |
            Div: A := B DIV C; H := B MOD C
         END ;
         R[a] := A; N := A < 0; Z := A = 0
      ELSIF ~ODD(ASR(IR, -30)) THEN (*p & ~q: memory instruction*)
        adr := (R[b] + IR MOD 100000H) DIV 4;
        IF ~ODD(ASR(IR, -29)) THEN
          IF adr >= 0 THEN (*load*) R[a] := M[adr]; N := A < 0; Z := A = 0
          ELSE (*input*)
            IF adr = -1 THEN (*ReadInt*) Scanner.Scan(S); R[a] := S.i;
            ELSIF adr = -2 THEN (*eot*)  Z := S.class # Scanner.Int
            END 
          END
        ELSE
          IF adr >= 0 THEN (*store*) M[adr] := R[a];
          ELSE (*output*);
            IF adr = -1 THEN Out.Int(R[a], 4)
            ELSIF adr = -2 THEN Out.Char(CHR(R[a] MOD 80H))
            ELSIF adr = -3 THEN Out.Ln;
            END
          END
        END
      ELSE (* p & q: branch instruction*)
        IF (a = 0) & N OR (a = 1) & Z OR (a = 5) & N OR (a = 6) & (N OR Z) OR (a = 7) OR
            (a = 8) & ~N OR (a = 9) & ~Z OR (a = 13) & ~N OR (a = 14) & ~(N OR Z) THEN
          IF ODD(ASR(IR, -28)) THEN R[15] := PC * 4 END ;
          IF ODD(ASR(IR, -29)) THEN PC := (PC + (IR MOD 1000000H)) MOD 40000H 
          ELSE PC := R[IR MOD 10H] DIV 4
          END
        END
      END
    UNTIL PC = 0;
  END Execute;
END RISC0.

