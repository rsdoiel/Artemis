(* Dictionary.mod - Dictionary wrapper for HashMap (Artemis Standard Library)

Copyright (C) 2025

Released under The 3-Clause BSD License.
Author: Artemis Project
*)

MODULE Dictionary;

IMPORT Collections, HashMap;

TYPE
    Dictionary* = POINTER TO DictionaryDesc;
    DictionaryDesc = RECORD
        map: HashMap.HashMap
    END;

(** Create a new dictionary with integer keys *)
PROCEDURE New*(): Dictionary;
VAR dict: Dictionary;
BEGIN
    NEW(dict);
    dict.map := HashMap.New();
    RETURN dict
END New;

(** Create a new dictionary with string keys *)
PROCEDURE NewStringDict*(): Dictionary;
VAR dict: Dictionary;
BEGIN
    NEW(dict);
    dict.map := HashMap.NewStringMap();
    RETURN dict
END NewStringDict;

(** Free the dictionary and all its resources *)
PROCEDURE Free*(VAR dict: Dictionary);
BEGIN
    IF dict # NIL THEN
        HashMap.Free(dict.map);
        dict := NIL
    END
END Free;

(** Insert or update a value by integer key *)
PROCEDURE Put*(dict: Dictionary; key: INTEGER; value: Collections.ItemPtr);
BEGIN
    IF dict # NIL THEN
        HashMap.Put(dict.map, key, value)
    END
END Put;

(** Insert or update a value by string key *)
PROCEDURE PutString*(dict: Dictionary; key: ARRAY OF CHAR; value: Collections.ItemPtr);
BEGIN
    IF dict # NIL THEN
        HashMap.PutString(dict.map, key, value)
    END
END PutString;

(** Get a value by integer key *)
PROCEDURE Get*(dict: Dictionary; key: INTEGER; VAR value: Collections.ItemPtr): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    IF dict # NIL THEN
        result := HashMap.Get(dict.map, key, value)
    ELSE
        result := FALSE
    END;
    RETURN result
END Get;

(** Get a value by string key *)
PROCEDURE GetString*(dict: Dictionary; key: ARRAY OF CHAR; VAR value: Collections.ItemPtr): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    IF dict # NIL THEN
        result := HashMap.GetString(dict.map, key, value)
    ELSE
        result := FALSE
    END;
    RETURN result
END GetString;

(** Remove a value by integer key *)
PROCEDURE Remove*(dict: Dictionary; key: INTEGER): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    IF dict # NIL THEN
        result := HashMap.Remove(dict.map, key)
    ELSE
        result := FALSE
    END;
    RETURN result
END Remove;

(** Remove a value by string key *)
PROCEDURE RemoveString*(dict: Dictionary; key: ARRAY OF CHAR): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    IF dict # NIL THEN
        result := HashMap.RemoveString(dict.map, key)
    ELSE
        result := FALSE
    END;
    RETURN result
END RemoveString;

(** Check if an integer key exists in the dictionary *)
PROCEDURE Contains*(dict: Dictionary; key: INTEGER): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    IF dict # NIL THEN
        result := HashMap.Contains(dict.map, key)
    ELSE
        result := FALSE
    END;
    RETURN result
END Contains;

(** Check if a string key exists in the dictionary *)
PROCEDURE ContainsString*(dict: Dictionary; key: ARRAY OF CHAR): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    IF dict # NIL THEN
        result := HashMap.ContainsString(dict.map, key)
    ELSE
        result := FALSE
    END;
    RETURN result
END ContainsString;

(** Get the number of key-value pairs in the dictionary *)
PROCEDURE Count*(dict: Dictionary): INTEGER;
VAR result: INTEGER;
BEGIN
    IF dict # NIL THEN
        result := HashMap.Count(dict.map)
    ELSE
        result := 0
    END;
    RETURN result
END Count;

(** Test if the dictionary is empty *)
PROCEDURE IsEmpty*(dict: Dictionary): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    IF dict # NIL THEN
        result := HashMap.IsEmpty(dict.map)
    ELSE
        result := TRUE
    END;
    RETURN result
END IsEmpty;

(** Remove all key-value pairs from the dictionary *)
PROCEDURE Clear*(dict: Dictionary);
BEGIN
    IF dict # NIL THEN
        HashMap.Clear(dict.map)
    END
END Clear;

(** Apply a procedure to each value in the dictionary *)
PROCEDURE Foreach*(dict: Dictionary; visit: Collections.VisitProc; VAR state: Collections.VisitorState);
BEGIN
    IF dict # NIL THEN
        HashMap.Foreach(dict.map, visit, state)
    END
END Foreach;

END Dictionary.
