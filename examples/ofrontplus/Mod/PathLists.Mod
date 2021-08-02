(** PathLists is a module for working with a delimited list of paths. *)
MODULE PathLists;
    IMPORT Chars, Path;

CONST
    (** Merge operations *)
    PREPEND = 1; (** Insert into path list *)
    APPEND = 2;  (** Add to end of path list *)
    CUT = 3; (** Remove from path from path list *)

TYPE
    PathList* = POINTER TO PathListDesc;
    PathListDesc* = RECORD
        part : ARRAY Path.MAXLENGTH OF CHAR;
        next : PathList
    END;

VAR
    delimiter : CHAR;

(** Length returns the length of the PathList *)
PROCEDURE Length*(pathList : PathList) : INTEGER;
    VAR res : INTEGER; cur : PathList;
BEGIN res := 0; cur := pathList;
    WHILE cur # NIL DO INC(res); cur := cur.next; END;
    RETURN res
END Length;

(** Find takes a path and searches a path list return -1 if not found
or the position where it was found (zero indexed) *)
PROCEDURE Find*(path : ARRAY OF CHAR; pathList : PathList) : INTEGER;
    VAR res, pos : INTEGER; cur : PathList;
BEGIN res := -1; pos := 0; cur := pathList;
    WHILE (cur # NIL) & (res = -1) DO
        IF Chars.Equal(cur.part, path) THEN
            res := pos;
        END;
        INC(pos); cur := cur.next;
    END;
    RETURN res
END Find;

(** Prepend takes a path and a path list and prepends path to path list updating
  path list. *)
PROCEDURE Prepend*(path : ARRAY OF CHAR; VAR pathList : PathList; VAR success : BOOLEAN);
BEGIN 
    success := FALSE; (* FIXME: Prepend not implemented. *)
END Prepend;

(** Append takes a path and path list and adds the path to the end of path list *)
PROCEDURE Append*(path: ARRAY OF CHAR; VAR pathList : PathList; VAR success : BOOLEAN);
BEGIN 
    success := FALSE; (* FIXME: Append not implemented. *)
END Append;

(** Cut takes a path and a path list and removes the path element from path list. *)
PROCEDURE Cut*(path : ARRAY OF CHAR; VAR pathList : PathList; VAR success : BOOLEAN);
BEGIN 
    success := FALSE; (* FIXME: Cut not implemented *)
END Cut;

(** SetDelimiter sets the delimiter to be used for encoding and decoding paths *)
PROCEDURE SetDelimiter(c : CHAR);
BEGIN delimiter := c;
END SetDelimiter;

(** Encode takes a PathList and encodes it into pathListString using the delimiter provided *)
PROCEDURE Encode*(pathList : PathList; delimiter: CHAR; VAR pathListString : ARRAY OF CHAR; VAR success : BOOLEAN);
BEGIN
    success := FALSE; (* FIXME: Not implemented *)
END Encode;

(** Decode takes a path list string and decodes it into a PathList data structure *)
PROCEDURE Decode*(pathListString : ARRAY OF CHAR; VAR pathList : PathList; success : BOOLEAN);
BEGIN
    success := FALSE; (* FIXME: Not implemented *)
END Decode;

(** Apply takes a path, an operation and a path list string. It applies the operation
    using the path and pathList updating pathList. Return TRUE of successful,
    FALSE otherwise. *)
PROCEDURE Apply*(path: ARRAY OF CHAR; operation: INTEGER; VAR pathListString: ARRAY OF CHAR): BOOLEAN;
    VAR success : BOOLEAN; pathList : PathList;
BEGIN
    Decode(pathListString, pathList, success);
    IF success THEN
        IF operation = PREPEND THEN
            Prepend(path, pathList, success)
        ELSIF operation = APPEND THEN
            Append(path, pathList, success)
        ELSIF operation = CUT THEN
            Cut(path, pathList, success)
        END;
    END;
    RETURN success
END Apply;

BEGIN
    SetDelimiter(":"); (** NOTE: The colon is the default delimiter. *)
END PathLists.