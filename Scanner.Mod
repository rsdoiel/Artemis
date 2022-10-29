MODULE Scanner;

CONST
	(* ERROR in scan, e.g. string start found without end string, position in scan not updated *)
	ERROR* = 0;
	(* OK scan successful, not at end of text, position in scan updated *)
	OK* = 1;
	(* EOT scan successful but at end of text, position in scan not updated *)
	EOT* = 2;
	
	(* Common String Delimiters *)
	EOT*    = 0X   (* end of text *)
	TAB*    = 9X;  (* tab *)
	LF*     = 10X; (* line feed *)
	FF*     = 11X; (* form feed *)
	CR*     = 13X; (* charriage return *)
	SPACE*  = 32X; (* space *)
	DQUOTE* = 34X; (* double quote *)
	SQUOTE* = 39X; (* single quote *)
	SLASH*  = 47X; (* slash or div symbol *)
	BSLASH* = 92X; (* backslash *)

  (** Character constants *)
  DASH*  = "-"; (* dash *)
  LODASH* = "_"; (* underscore or low dash *)
  CARET* = "^"; (* caret *)
  TILDE* = "~"; (* tilde *)

TYPE
	Scanner* = POINTER TO ScannerDesc;
	ScannerDesc* = RECORD
		delimiter: CHAR;
		startString: CHAR;
		endString: CHAR;
		inString: BOOLEAN;
		escape: CHAR;
		Pos*: INTEGER
	END;
		
PROCEDURE Init*(VAR scanner: Scanner; delimiter: CHAR; startString: CHAR; endString: CHAR; Escape: CHAR);
BEGIN
	scanner.delimiter := delimiter;
	scanner.startString := startString;
	scanner.endString := endString;
	scanner.escape := Escape;
	scanner.inString := FALSE;
	scanner.Pos := 0;
END Init;

PROCEDURE ScanChars*(VAR scanner: Scanner; src : ARRAY OF CHAR; VAR value: ARRAY OF CHAR; VAR OK: BOOLEAN);
BEGIN
END ScanChars;


END Scanner.

Scanner
=======

Scanner models a simple text scanner like that needed to process Oberon language files or Pascal.


