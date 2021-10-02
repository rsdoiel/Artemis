(** artOut.Mod implements the traditional Oakwoord style Out module
for OfrontPlus.  It relies heavely on C level integration.
*)
MODULE artOut;

IMPORT SYSTEM;

PROCEDURE Open;
BEGIN
END Open;

(* char implements C implementation using printf *)
PROCEDURE -char(ch: CHAR) 'printf("%c", ch);';

(* Char implements the exported procedure using char() *)
PROCEDURE Char*(ch: CHAR);
BEGIN
  char(ch);
END Char;

(* string provides the C implementation using printf *)
PROCEDURE -string(str: ARRAY OF CHAR) 'printf("%s", str);';

(* String implements the exported procedure using string() *)
PROCEDURE String*(str: ARRAY OF CHAR);
BEGIN
  string(str);
END String;

(* FIXME: need to build the format string then calling printf *)
(* int provides the C implementation using printf *)
PROCEDURE -int(i, n : INTEGER) 'printf("%d", i);';

(* Int implements the exported procedure using int() *)
PRCEDURE Int*(i, n : INTEGER);
BEGIN
  int(i, n);
END Int;

(* FIXME: need to build the format string then call printf *)
(* real provides the C implementation using printf *)
PROCEDURE -real(x : REAL; n : INTEGER) 'printf("%f", x);';

(* Real implements the exported procedure using real() *)
PROCEDURE Real*(x : REAL; n : INTEGER); 
BEGIN
  real(x, n);
END Real;

(* ln provides the C implementation using printf *)
PROCEDURE -ln 'printf("\n");'

(* Ln implements the exported procedure using ln() *)
PROCEDURE Ln*;
BEGIN
  ln();
END Ln;

END artOut.
