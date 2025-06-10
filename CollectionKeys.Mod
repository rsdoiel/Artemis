(** CollectionKeys.mod - Key types and operations for key-value collections.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE CollectionKeys;

IMPORT Collections, Bitwise;

TYPE
    (** Base type for all keys *)
    Key* = RECORD(Collections.Item)
        (* Base key type - extend this for specific key types *)
    END;
    KeyPtr* = POINTER TO Key;
    
    (** Integer key implementation *)
    IntegerKey* = RECORD(Key)
        value*: INTEGER
    END;
    IntegerKeyPtr* = POINTER TO IntegerKey;
    
    (** String key implementation *)
    StringKey* = RECORD(Key)
        value*: ARRAY 256 OF CHAR
    END;
    StringKeyPtr* = POINTER TO StringKey;
    
    (** Key operations interface *)
    KeyOps* = RECORD
        hash*: PROCEDURE(key: KeyPtr; size: INTEGER): INTEGER;
        equals*: PROCEDURE(key1, key2: KeyPtr): BOOLEAN
    END;

(** Create integer key *)
PROCEDURE NewIntegerKey*(value: INTEGER): IntegerKeyPtr;
VAR key: IntegerKeyPtr;
BEGIN
    NEW(key);
    key.value := value;
    RETURN key
END NewIntegerKey;

(** Create string key *)
PROCEDURE NewStringKey*(value: ARRAY OF CHAR): StringKeyPtr;
VAR key: StringKeyPtr;
    i: INTEGER;
BEGIN
    NEW(key);
    (* Copy the string *)
    i := 0;
    WHILE (i < LEN(key.value) - 1) & (i < LEN(value)) & (value[i] # 0X) DO
        key.value[i] := value[i];
        INC(i)
    END;
    key.value[i] := 0X; (* Null terminate *)
    RETURN key
END NewStringKey;

(* Hash function for integer keys *)
PROCEDURE HashInteger(key: KeyPtr; size: INTEGER): INTEGER;
VAR 
    intKey: IntegerKeyPtr;
    hash: INTEGER;
BEGIN
    intKey := key(IntegerKeyPtr);
    hash := Bitwise.Xor(intKey.value, Bitwise.ShiftRight(intKey.value, 16));
    hash := hash * 73;
    hash := Bitwise.Xor(hash, Bitwise.ShiftRight(hash, 13));
    hash := hash * 37;
    hash := Bitwise.Xor(hash, Bitwise.ShiftRight(hash, 9));
    IF hash < 0 THEN hash := -hash END;
    RETURN hash MOD size
END HashInteger;

(* Equality function for integer keys *)
PROCEDURE EqualsInteger(key1, key2: KeyPtr): BOOLEAN;
VAR 
    intKey1, intKey2: IntegerKeyPtr;
    result: BOOLEAN;
BEGIN
    intKey1 := key1(IntegerKeyPtr);
    intKey2 := key2(IntegerKeyPtr);
    result := intKey1.value = intKey2.value;
    RETURN result
END EqualsInteger;

(* Hash function for string keys - djb2 algorithm *)
PROCEDURE HashString(key: KeyPtr; size: INTEGER): INTEGER;
VAR 
    strKey: StringKeyPtr;
    hash, i: INTEGER;
    c: CHAR;
BEGIN
    strKey := key(StringKeyPtr);
    hash := 5381; (* djb2 magic number *)
    i := 0;
    c := strKey.value[i];
    WHILE c # 0X DO
        hash := hash * 33 + ORD(c);
        INC(i);
        c := strKey.value[i]
    END;
    IF hash < 0 THEN hash := -hash END;
    RETURN hash MOD size
END HashString;

(* Equality function for string keys *)
PROCEDURE EqualsString(key1, key2: KeyPtr): BOOLEAN;
VAR 
    strKey1, strKey2: StringKeyPtr;
    i: INTEGER;
    result: BOOLEAN;
BEGIN
    strKey1 := key1(StringKeyPtr);
    strKey2 := key2(StringKeyPtr);
    result := TRUE;
    i := 0;
    
    WHILE (strKey1.value[i] # 0X) & (strKey2.value[i] # 0X) & result DO
        IF strKey1.value[i] # strKey2.value[i] THEN
            result := FALSE
        END;
        INC(i)
    END;
    
    (* Check if both strings ended at the same position *)
    IF result THEN
        result := (strKey1.value[i] = 0X) & (strKey2.value[i] = 0X)
    END;
    
    RETURN result
END EqualsString;

(** Get integer key operations *)
PROCEDURE IntegerKeyOps*(VAR ops: KeyOps);
BEGIN
    ops.hash := HashInteger;
    ops.equals := EqualsInteger
END IntegerKeyOps;

(** Get string key operations *)
PROCEDURE StringKeyOps*(VAR ops: KeyOps);
BEGIN
    ops.hash := HashString;
    ops.equals := EqualsString
END StringKeyOps;

END CollectionKeys.
