MODULE Scanner;

CONST
	(* ERROR in scan, e.g. string start found without end string, position in scan not updated *)
	ERROR* = 0;
	(* OK scan successful, not at end of text, position in scan updated *)
	OK* = 1;
	(* EOT scan successful but at end of text, position in scan not updated *)
	EOT* = 2;

TYPE
	Scanner* = POINTER TO ScannerDesc;
	ScannerDesc* = RECORD
		delimiter: CHAR;
		startString: CHAR;
		endString: CHAR;
		inString: BOOLEAN;
		escape: CHAR;
		Pos*: INTEGER;
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

PROCEDURE ScanChars*(VAR scanner: Scanner; src : ARRAY OF CHARS; VAR value: ARRAY OF CHAR; VAR OK: BOOLEAN);
BEGIN
END ScanChars;


END Scanner.

Scanner
=======

Scanner models a simple text scanner like that needed to process Oberon language files or Pascal.


