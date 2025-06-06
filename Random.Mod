MODULE Random;

(** Lehmer multiplicative linear congruential generator (MLCG) for INTEGER and REAL random numbers. *)

CONST
    Modulus* = 2147483647;   (* 2^31-1, a Mersenne prime *)
    Multiplier* = 48271;      (* Park-Miller MINSTD *)

VAR
    state: INTEGER;

PROCEDURE Init*(seed: INTEGER);
(** Initialize the generator with a seed in 1..Modulus-1 *)
BEGIN
    IF (seed > 0) & (seed < Modulus) THEN
        state := seed
    ELSE
        state := 1
    END
END Init;

PROCEDURE Next*(): INTEGER;
(** Return the next random integer in 1..Modulus-1 *)
VAR
    result, hi, lo, test: INTEGER;
BEGIN
    (* Schrage's method: computes (Multiplier * state) MOD Modulus without overflow. *)
    hi := state DIV 44488; (* q = Modulus DIV Multiplier = 44488 *)
    lo := state MOD 44488; (* r = Modulus MOD Multiplier = 3399 *)
    test := Multiplier * lo - 3399 * hi;
    IF test > 0 THEN
        state := test
    ELSE
        state := test + Modulus
    END;
    result := state;
    RETURN result
END Next;

PROCEDURE NextReal*(): REAL;
(** Return the next random number in (0,1) *)
VAR
    result: REAL;
    n: INTEGER;
BEGIN
    n := Next();
    result := FLT(n) / FLT(Modulus);
    RETURN result
END NextReal;

END Random.