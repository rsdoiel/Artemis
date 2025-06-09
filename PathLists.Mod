(** PathLists is a module for working with a delimited list of paths. *)
MODULE PathLists;
    IMPORT Chars, Path, LinkedList, Collections;

CONST
    (** Merge operations *)
    PREPEND* = 1; (** Insert into path list *)
    APPEND* = 2;  (** Add to end of path list *)
    CUT* = 3; (** Remove from path from path list *)

TYPE
    PathList* = POINTER TO PathListDesc;
    PathListDesc = RECORD
        list: LinkedList.List
    END;
    
    PathItem = RECORD (Collections.Item)
        path: ARRAY Path.MAXLENGTH OF CHAR
    END;
    PathItemPtr = POINTER TO PathItem;

VAR
    delimiter : CHAR;

(** NewPathItem creates a new PathItem with the given path *)
PROCEDURE NewPathItem(path: ARRAY OF CHAR): PathItemPtr;
VAR item: PathItemPtr;
BEGIN
    NEW(item);
    Chars.Copy(path, item.path);
    RETURN item
END NewPathItem;

(** New creates a new empty PathList *)
PROCEDURE New*(): PathList;
VAR pathList: PathList;
BEGIN
    NEW(pathList);
    pathList.list := LinkedList.New();
    RETURN pathList
END New;

(** Free releases memory used by a PathList *)
PROCEDURE Free*(VAR pathList: PathList);
BEGIN
    IF pathList # NIL THEN
        LinkedList.Free(pathList.list);
        pathList := NIL
    END
END Free;

(** Length returns the length of the PathList *)
PROCEDURE Length*(pathList : PathList) : INTEGER;
BEGIN 
    RETURN LinkedList.Count(pathList.list)
END Length;

(** Find takes a path and searches a path list return -1 if not found
or the position where it was found (zero indexed) *)
PROCEDURE Find*(path : ARRAY OF CHAR; pathList : PathList) : INTEGER;
VAR 
    pos, result: INTEGER; 
    item: Collections.ItemPtr;
    success, found: BOOLEAN;
BEGIN 
    pos := 0;
    found := FALSE;
    result := -1;
    WHILE (pos < LinkedList.Count(pathList.list)) & ~found DO
        success := LinkedList.GetAt(pathList.list, pos, item);
        IF success & Chars.Equal(item(PathItemPtr).path, path) THEN
            result := pos;
            found := TRUE
        ELSE
            INC(pos)
        END
    END;
    RETURN result
END Find;

(** Prepend takes a path and a path list and prepends path to path list updating
  path list. *)
PROCEDURE Prepend*(path : ARRAY OF CHAR; VAR pathList : PathList; VAR success : BOOLEAN);
VAR item: PathItemPtr;
BEGIN 
    IF pathList = NIL THEN
        pathList := New()
    END;
    item := NewPathItem(path);
    success := LinkedList.InsertAt(pathList.list, 0, item)
END Prepend;

(** Append takes a path and path list and adds the path to the end of path list *)
PROCEDURE Append*(path: ARRAY OF CHAR; VAR pathList : PathList; VAR success : BOOLEAN);
VAR item: PathItemPtr;
BEGIN 
    IF pathList = NIL THEN
        pathList := New()
    END;
    item := NewPathItem(path);
    LinkedList.Append(pathList.list, item);
    success := TRUE
END Append;

(** Cut takes a path and a path list and removes the path element from path list. *)
PROCEDURE Cut*(path : ARRAY OF CHAR; VAR pathList : PathList; VAR success : BOOLEAN);
VAR 
    pos: INTEGER;
    result: Collections.ItemPtr;
BEGIN 
    success := FALSE;
    IF pathList # NIL THEN
        pos := Find(path, pathList);
        IF pos >= 0 THEN
            success := LinkedList.RemoveAt(pathList.list, pos, result)
        END
    END
END Cut;

(** SetDelimiter sets the delimiter to be used for encoding and decoding paths *)
PROCEDURE SetDelimiter(c : CHAR);
BEGIN delimiter := c;
END SetDelimiter;

(** Encode takes a PathList and encodes it into pathListString using the delimiter provided *)
PROCEDURE Encode*(pathList : PathList; delimiter: CHAR; VAR pathListString : ARRAY OF CHAR; VAR success : BOOLEAN);
VAR 
    i, count: INTEGER;
    item: Collections.ItemPtr;
    delimStr: ARRAY 2 OF CHAR;
    getSuccess, continue: BOOLEAN;
BEGIN
    success := FALSE;
    continue := TRUE;
    pathListString[0] := 0X;
    delimStr[0] := delimiter;
    delimStr[1] := 0X;
    
    IF pathList # NIL THEN
        count := LinkedList.Count(pathList.list);
        i := 0;
        WHILE (i < count) & continue DO
            getSuccess := LinkedList.GetAt(pathList.list, i, item);
            IF getSuccess THEN
                IF i > 0 THEN
                    IF Chars.Length(pathListString) + 1 >= LEN(pathListString) THEN
                        continue := FALSE (* Not enough space *)
                    ELSE
                        Chars.Append(delimStr, pathListString)
                    END
                END;
                IF continue & (Chars.Length(pathListString) + Chars.Length(item(PathItemPtr).path) >= LEN(pathListString)) THEN
                    continue := FALSE (* Not enough space *)
                ELSIF continue THEN
                    Chars.Append(item(PathItemPtr).path, pathListString)
                END
            ELSE
                continue := FALSE (* Failed to get item *)
            END;
            INC(i)
        END;
        success := continue
    END
END Encode;

(** Decode takes a path list string and decodes it into a PathList data structure *)
PROCEDURE Decode*(pathListString : ARRAY OF CHAR; VAR pathList : PathList; VAR success : BOOLEAN);
VAR 
    i, start, len: INTEGER;
    pathBuffer: ARRAY Path.MAXLENGTH OF CHAR;
    item: PathItemPtr;
    delimStr: ARRAY 2 OF CHAR;
    continue: BOOLEAN;
BEGIN
    success := FALSE;
    continue := TRUE;
    delimStr[0] := delimiter;
    delimStr[1] := 0X;
    
    (* Free existing list if present *)
    IF pathList # NIL THEN
        LinkedList.Free(pathList.list)
    END;
    pathList := New();
    
    len := Chars.Length(pathListString);
    IF len = 0 THEN
        success := TRUE
    ELSE
        start := 0;
        FOR i := 0 TO len DO
            IF ((i = len) OR (pathListString[i] = delimiter)) & continue THEN
                (* Extract path from start to i-1 *)
                IF i > start THEN
                    IF (i - start) < LEN(pathBuffer) THEN
                        Chars.Extract(pathListString, start, i - start, pathBuffer);
                        item := NewPathItem(pathBuffer);
                        LinkedList.Append(pathList.list, item)
                    ELSE
                        LinkedList.Free(pathList.list);
                        pathList := NIL;
                        continue := FALSE (* Path too long *)
                    END
                END;
                start := i + 1
            END
        END;
        
        IF continue THEN
            success := TRUE
        END
    END
END Decode;

(** Apply takes a path, an operation and a path list string. It applies the operation
    using the path and pathList updating pathList. Return TRUE of successful,
    FALSE otherwise. *)
PROCEDURE Apply*(path: ARRAY OF CHAR; operation: INTEGER; VAR pathListString: ARRAY OF CHAR): BOOLEAN;
    VAR success, encodeSuccess : BOOLEAN; pathList : PathList;
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
        
        IF success THEN
            Encode(pathList, delimiter, pathListString, encodeSuccess);
            success := encodeSuccess
        END;
        
        Free(pathList)
    END;
    RETURN success
END Apply;

BEGIN
    SetDelimiter(":"); (** NOTE: The colon is the default delimiter. *)
END PathLists.