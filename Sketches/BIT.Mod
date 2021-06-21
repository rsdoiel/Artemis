(* ETH Oberon, Copyright 1990-2003 Computer Systems Institute, ETH Zurich, CH-8092 Zurich.
Refer to the license.txt file provided with this distribution. *)
(* Ported to Oberon-7, RSD 2021-06-05 

   NOTES: Since Oberon-7 only supports CHAR, BYTE and INTEGER. 
   LONGINT routines are dropped, SHORTINT is aliased to BYTE.
 *)
MODULE BIT;	(** portable *)	(* tk 12.2.96 *)
(** AUTHOR "tk"; PURPOSE "Bit manipulation"; *)

	IMPORT S := SYSTEM;

	TYPE
		CARDINAL* = INTEGER;
        SHORTINT* = BYTE;
        SHORTCARD* = BYTE;
	
	CONST
		rbo = FALSE;	(* reverse bit ordering, e.g. PowerPC*)
		risc = FALSE;	(* risc architecture - no support for 8 and 16-bit rotations *)
	
	(** bitwise exclusive or: x XOR y *)
	PROCEDURE CXOR*(x, y: CHAR): CHAR;
	BEGIN RETURN CHR(S.VAL(LONGINT, S.VAL(SET, LONG(ORD(x))) / S.VAL(SET, LONG(ORD(y)))))
	END CXOR;
	
	PROCEDURE IXOR*(x, y: INTEGER): INTEGER;
	BEGIN RETURN SHORT(S.VAL(LONGINT, S.VAL(SET, LONG(x)) / S.VAL(SET, LONG(y))))
	END IXOR;
	
	(** bitwise or: x OR y *)
	PROCEDURE COR*(x, y: CHAR): CHAR;
	BEGIN RETURN CHR(S.VAL(LONGINT, S.VAL(SET, LONG(ORD(x))) + S.VAL(SET, LONG(ORD(y)))))
	END COR;
	
	PROCEDURE IOR*(x, y: INTEGER): INTEGER;
	BEGIN RETURN SHORT(S.VAL(LONGINT, S.VAL(SET, LONG(x)) + S.VAL(SET, LONG(y))))
	END IOR;
	
	
	(** bitwise and: x AND y *)
	PROCEDURE CAND*(x, y: CHAR): CHAR;
	BEGIN RETURN CHR(S.VAL(LONGINT, S.VAL(SET, LONG(ORD(x))) * S.VAL(SET, LONG(ORD(y)))))
	END CAND;
	
	PROCEDURE IAND*(x, y: INTEGER): INTEGER;
	BEGIN RETURN SHORT(S.VAL(LONGINT, S.VAL(SET, LONG(x)) * S.VAL(SET, LONG(y))))
	END IAND;
	
	
	(** bitwise logical left-shift: x shifted n *)
	PROCEDURE CLSH*(x: CHAR; n: SHORTINT): CHAR;
	BEGIN 
		IF risc THEN RETURN CHR(S.LSH(S.VAL(LONGINT, S.VAL(SET, ORD(x)) * S.VAL(SET, 0FFH)), n))
		ELSE RETURN S.LSH(x, n) END
	END CLSH;
	
	PROCEDURE ILSH*(x: INTEGER; n: SHORTINT): INTEGER;
	BEGIN 
		IF risc THEN RETURN SHORT(S.LSH(S.VAL(LONGINT, S.VAL(SET, LONG(x)) * S.VAL(SET, 0FFFFH)), n))
		ELSE RETURN S.LSH(x, n) END
	END ILSH;
	
	(** bitwise rotation: x rotatated by n bits *)
	PROCEDURE CROT*(x: CHAR; n: SHORTINT): CHAR;
		VAR s0, s1: SET; i: INTEGER;
	BEGIN
		IF risc THEN 
			s0 := S.VAL(SET, ORD(x)); s1 := {};
			IF rbo THEN
				i := 0; WHILE i < 8 DO
					IF 31-i IN s0 THEN INCL(s1, 31 - ((i+n) MOD 8)) END;
					INC(i)
				END;
			ELSE
				i := 0; WHILE i < 8 DO
					IF i IN s0 THEN INCL(s1, (i+n) MOD 8) END;
					INC(i)
				END;
			END;
			RETURN CHR(S.VAL(LONGINT, s1))
		ELSE RETURN S.ROT(x, n) END;
	END CROT;
	
	PROCEDURE IROT*(x: INTEGER; n: SHORTINT): INTEGER;
		VAR s0, s1: SET; i: INTEGER;
	BEGIN
		IF risc THEN 
			s0 := S.VAL(SET, LONG(x)); s1 := {};
			IF rbo THEN
				i := 0; WHILE i < 16 DO
					IF 31-i IN s0 THEN INCL(s1, 31 - ((i+n) MOD 16)) END;
					INC(i)
				END;
			ELSE
				i := 0; WHILE i < 16 DO
					IF i IN s0 THEN INCL(s1, (i+n) MOD 16) END;
					INC(i)
				END;
			END;
			RETURN SHORT(S.VAL(LONGINT, s1))
		ELSE RETURN S.ROT(x, n) END;
	END IROT;
	
	
	(** swap bytes to change byteordering *)
	PROCEDURE ISWAP*(x: INTEGER): INTEGER;
		TYPE integer = ARRAY 2 OF CHAR; VAR a, b: integer; 
	BEGIN a := S.VAL(integer, x); b[0] := a[1]; b[1] := a[0]; RETURN S.VAL(INTEGER, b)
	END ISWAP;
	
	
	(** test bit n in x*)
	PROCEDURE CBIT*(x: CHAR; n: SHORTINT): BOOLEAN;
	BEGIN ASSERT((n >= 0) & (n <= 7));
		IF rbo THEN RETURN (31-n) IN S.VAL(SET, ORD(x)) ELSE RETURN n IN S.VAL(SET, LONG(ORD(x))) END
	END CBIT;
	
	PROCEDURE BIT*(x: INTEGER; n: SHORTINT): BOOLEAN;
	BEGIN ASSERT((n >= 0) & (n <= 31));
		IF rbo THEN RETURN (31-n) IN S.VAL(SET, x) ELSE RETURN n IN S.VAL(SET, x) END
	END BIT;
	
	
	(** set bit n in x*)
	PROCEDURE CSETBIT*(VAR x: CHAR; n: SHORTINT);
		VAR i: LONGINT;
	BEGIN ASSERT((n >= 0) & (n <= 7));
		i := ORD(x); IF rbo THEN INCL(S.VAL(SET, i), 31-n) ELSE INCL(S.VAL(SET, i), n) END; x := CHR(i)
	END CSETBIT;
	
	PROCEDURE SSETBIT*(VAR x: SHORTINT; n: SHORTINT);
		VAR i: LONGINT;
	BEGIN ASSERT((n >= 0) & (n <= 7));
		i := LONG(LONG(x)); IF rbo THEN INCL(S.VAL(SET, i), 31-n) ELSE INCL(S.VAL(SET, i), n) END; x := SHORT(SHORT(i))
	END SSETBIT;
	
	PROCEDURE ISETBIT*(VAR x: INTEGER; n: SHORTINT);
		VAR i: LONGINT;
	BEGIN ASSERT((n >= 0) & (n <= 15));
		i := LONG(x); IF rbo THEN INCL(S.VAL(SET, i), 31-n) ELSE INCL(S.VAL(SET, i), n) END; x := SHORT(i)
	END ISETBIT;
	
	
	(** clear bit n in x*)
	PROCEDURE CCLRBIT*(VAR x: CHAR; n: SHORTINT);
		VAR i: LONGINT;
	BEGIN ASSERT(ABS(n) < 8);
		i := ORD(x); IF rbo THEN EXCL(S.VAL(SET, i), 31-n) ELSE EXCL(S.VAL(SET, i), n) END; x := CHR(i)
	END CCLRBIT;
	
	PROCEDURE SCLRBIT*(VAR x: SHORTINT; n: SHORTINT);
		VAR i: LONGINT;
	BEGIN ASSERT(ABS(n) < 8);
		i := LONG(LONG(x)); IF rbo THEN EXCL(S.VAL(SET, i), 31-n) ELSE EXCL(S.VAL(SET, i), n) END; x := SHORT(SHORT(i))
	END SCLRBIT;
	
	PROCEDURE ICLRBIT*(VAR x: INTEGER; n: SHORTINT);
		VAR i: LONGINT;
	BEGIN ASSERT(ABS(n) < 16);
		i := LONG(x); IF rbo THEN EXCL(S.VAL(SET, i), 31-n) ELSE EXCL(S.VAL(SET, i), n) END; x := SHORT(i)
	END ICLRBIT;
	
	
	(** unsigned comparison: x < y *)
	PROCEDURE SLESS*(x, y: SHORTCARD): BOOLEAN;
	BEGIN
		RETURN 
			S.VAL(LONGINT, S.VAL(SET, LONG(LONG(x))) * S.VAL(SET, 0FFH))
		 	< 
		 S.VAL(LONGINT, S.VAL(SET, LONG(LONG(y))) * S.VAL(SET, 0FFH));
	END SLESS;
	
	PROCEDURE ILESS*(x, y: CARDINAL): BOOLEAN;
	BEGIN
		RETURN 
			S.VAL(LONGINT, S.VAL(SET,LONG(x)) * S.VAL(SET, 0FFFFH)) 
		< 
			S.VAL(LONGINT, S.VAL(SET, LONG(y)) * S.VAL(SET, 0FFFFH))
	END ILESS;
	
				
	(** unsigned comparison: x <= y *)
	PROCEDURE SLESSEQ*(x, y: SHORTCARD): BOOLEAN;
	BEGIN 
		RETURN 
			S.VAL(LONGINT, S.VAL(SET, LONG(LONG(x))) * S.VAL(SET, 0FFH)) 
		<= 
			S.VAL(LONGINT, S.VAL(SET, LONG(LONG(y))) * S.VAL(SET, 0FFH))
	END SLESSEQ;
	
	PROCEDURE ILESSEQ*(x, y: CARDINAL): BOOLEAN;
	BEGIN
		RETURN
			S.VAL(LONGINT, S.VAL(SET,LONG(x)) * S.VAL(SET, 0FFFFH))
		<=
			S.VAL(LONGINT, S.VAL(SET, LONG(y)) * S.VAL(SET, 0FFFFH))
	END ILESSEQ;
	
	PROCEDURE LLESSEQ*(x, y: LONGCARD): BOOLEAN;
		VAR x0, y0: LONGINT;
	BEGIN x0 := S.LSH(x, -1); y0 := S.LSH(y, -1);
		IF x0 - y0 = 0 THEN RETURN x0 MOD 2 <= y0 MOD 2 ELSE RETURN x0 <= y0 END
	END LLESSEQ;
	
	
	(** unsigned division: x DIV y *)
	PROCEDURE SDIV*(x, y: SHORTCARD): SHORTCARD;
	BEGIN RETURN SHORT(SHORT(S.VAL(LONGINT, S.VAL(SET, LONG(LONG(x))) * S.VAL(SET, 0FFH)) DIV y))
	END SDIV;
	
	PROCEDURE IDIV*(x, y: CARDINAL): CARDINAL;
	BEGIN RETURN SHORT(S.VAL(LONGINT, S.VAL(SET, LONG(x)) * S.VAL(SET, 0FFFFH))) DIV y;
	END IDIV;
	
END BIT.


