(** artOut.Mod implements the traditional Oakwoord style Out module
for OfrontPlus. It relies heavely on C level integration.  *)
MODULE artOut;

IMPORT SYSTEM;

PROCEDURE Open;
BEGIN
END Open;

(* printfChar implements C implementation using printf *)
PROCEDURE -printfChar(ch: CHAR) 'printf("%c", ch);';

(* Char implements the exported procedure using printfChar() *)
PROCEDURE Char*(ch: CHAR);
BEGIN
  printfChar(ch);
END Char;

(* printfString provides the C implementation using printf *)
PROCEDURE -printfString(str: ARRAY OF CHAR) 'printf("%s", str);';

(* String implements the exported procedure using printfString() *)
PROCEDURE String*(str: ARRAY OF CHAR);
BEGIN
  printfString(str);
END String;

(* printfInt provides the C implementation using printf and sprintf.
   sprintf is used to build the format string then call printf *)
PROCEDURE -printfInt(i, n : INTEGER) '(char buf[256]; sprintf(buf, "%%d", n); printf(buf, i))';

(* Int implements the exported procedure using printfInt() *)
PROCEDURE Int*(i, n : INTEGER);
BEGIN
  printfInt(i, n);
END Int;

(* FIXME: need to build the format string then call printf
   printfReal provides the C implementation using printf *)
PROCEDURE -printfReal(x : REAL; n : INTEGER) '(char buf[256]; sprintf(buf, "%%f", n); printf(buf, x))';

(* Real implements the exported procedure using printfReal() *)
PROCEDURE Real*(x : REAL; n : INTEGER); 
BEGIN
  printfReal(x, n);
END Real;

(* printfLn provides the C implementation using printf *)
PROCEDURE -printfLn 'printf("\n");';

(* Ln implements the exported procedure using ln() *)
PROCEDURE Ln*;
BEGIN
  printfLn();
END Ln;

END artOut.
