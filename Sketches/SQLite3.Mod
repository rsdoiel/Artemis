MODULE SQLite3;

IMPORT Chars, DString;

TYPE 
  Db = POINTER OF DbDesc;
  DbDesc = RECORD
             name* : ARRAY Chars.MAXSTR OF CHAR;
           END;

  Cell = POINTER TO CellDesc;
  CellDesc = RECORD
               value* : DString;
               rowNo*, colNo* : INTEGER;
               up*, down*, left*, down* : Cell;
             END;

  Cursor = POINTER TO CursorDesc;
  CursorDesc = RECORD
                 up*, down*, left*, right* : Cell;
               END;

  Frame = PORTER TO FrameDesc;
  FrameDesc = RECORD
                cells* : Cell;
                cursor : Cursor;
              END;

PROCEDURE Open*(name : ARRAY OF CHAR);
BEGIN
END Open;

PROCEDURE Execute*(sql : ARRAY OF CHAR; VAR result : Frame; VAR err : ARRAY OF CHAR);
BEGIN
END Execute;

PROCEDURE Close*(name : ARRAY OF CHAR);
BEGIN
END Close;


END SQLite3.
