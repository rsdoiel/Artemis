(** HashMap.mod - A hashmap implementation using separate chaining.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE HashMap;

IMPORT Collections, LinkedList, CollectionKeys;

CONST
    DefaultSize* = 16;
    MaxSize = 1024;

TYPE
    (** Key-Value pair for storage *)
    KeyValuePair* = RECORD(Collections.Item)
        key*: CollectionKeys.KeyPtr;
        value*: Collections.ItemPtr
    END;
    KeyValuePairPtr* = POINTER TO KeyValuePair;

    (* BucketArray is hidden - clients don't need to know about buckets *)
    BucketArray = ARRAY MaxSize OF LinkedList.List;

    (** Opaque pointer to a HashMap *)
    HashMap* = POINTER TO HashMapDesc;
    (* HashMapDesc is private - clients can't access internal fields *)
    HashMapDesc = RECORD
        buckets: BucketArray;
        size: INTEGER;
        count: INTEGER;
        keyOps: CollectionKeys.KeyOps
    END;

(** Create a new key-value pair *)
PROCEDURE NewKeyValuePair*(key: CollectionKeys.KeyPtr; value: Collections.ItemPtr): KeyValuePairPtr;
VAR pair: KeyValuePairPtr;
BEGIN
    NEW(pair);
    pair.key := key;
    pair.value := value;
    RETURN pair
END NewKeyValuePair;

(* Internal helper function *)
PROCEDURE FindInBucket(list: LinkedList.List; key: CollectionKeys.KeyPtr; keyOps: CollectionKeys.KeyOps; VAR found: KeyValuePairPtr): BOOLEAN;
VAR 
    i: INTEGER;
    item: Collections.ItemPtr;
    pair: KeyValuePairPtr;
    result: BOOLEAN;
BEGIN
    result := FALSE;
    found := NIL;
    
    FOR i := 0 TO LinkedList.Count(list) - 1 DO
        IF LinkedList.GetAt(list, i, item) THEN
            pair := item(KeyValuePairPtr);
            IF keyOps.equals(pair.key, key) THEN
                found := pair;
                result := TRUE
            END
        END
    END;
    
    RETURN result
END FindInBucket;

(** Constructor: Allocate and initialize a new hashmap with specified size *)
PROCEDURE NewWithSize*(initialSize: INTEGER; keyOps: CollectionKeys.KeyOps): HashMap;
VAR 
    map: HashMap;
    i: INTEGER;
BEGIN
    NEW(map);
    IF initialSize <= 0 THEN
        initialSize := DefaultSize
    END;
    IF initialSize > MaxSize THEN
        initialSize := MaxSize
    END;
    
    map.size := initialSize;
    map.count := 0;
    map.keyOps := keyOps;
    
    FOR i := 0 TO map.size - 1 DO
        map.buckets[i] := LinkedList.New()
    END;
    
    RETURN map
END NewWithSize;

(** Constructor: Allocate and initialize a new hashmap with integer keys *)
PROCEDURE New*(): HashMap;
VAR 
    result: HashMap;
    ops: CollectionKeys.KeyOps;
BEGIN
    CollectionKeys.IntegerKeyOps(ops);
    result := NewWithSize(DefaultSize, ops);
    RETURN result
END New;

(** Constructor: Allocate and initialize a new hashmap with string keys *)
PROCEDURE NewStringMap*(): HashMap;
VAR 
    result: HashMap;
    ops: CollectionKeys.KeyOps;
BEGIN
    CollectionKeys.StringKeyOps(ops);
    result := NewWithSize(DefaultSize, ops);
    RETURN result
END NewStringMap;

(** Destructor: Free the hashmap *)
PROCEDURE Free*(VAR map: HashMap);
VAR i: INTEGER;
BEGIN
    IF map # NIL THEN
        FOR i := 0 TO map.size - 1 DO
            LinkedList.Free(map.buckets[i])
        END;
        map := NIL
    END
END Free;

(** Insert or update a key-value pair *)
PROCEDURE PutKey*(map: HashMap; key: CollectionKeys.KeyPtr; value: Collections.ItemPtr);
VAR 
    index: INTEGER;
    bucket: LinkedList.List;
    existingPair: KeyValuePairPtr;
    newPair: KeyValuePairPtr;
BEGIN
    index := map.keyOps.hash(key, map.size);
    bucket := map.buckets[index];
    
    IF FindInBucket(bucket, key, map.keyOps, existingPair) THEN
        (* Update existing key *)
        existingPair.value := value
    ELSE
        (* Insert new key-value pair *)
        newPair := NewKeyValuePair(key, value);
        LinkedList.Append(bucket, newPair);
        INC(map.count)
    END
END PutKey;

(** Insert or update a key-value pair with integer key *)
PROCEDURE Put*(map: HashMap; key: INTEGER; value: Collections.ItemPtr);
VAR intKey: CollectionKeys.IntegerKeyPtr;
BEGIN
    intKey := CollectionKeys.NewIntegerKey(key);
    PutKey(map, intKey, value)
END Put;

(** Insert or update a key-value pair with string key *)
PROCEDURE PutString*(map: HashMap; key: ARRAY OF CHAR; value: Collections.ItemPtr);
VAR strKey: CollectionKeys.StringKeyPtr;
BEGIN
    strKey := CollectionKeys.NewStringKey(key);
    PutKey(map, strKey, value)
END PutString;

(** Get a value by key *)
PROCEDURE GetKey*(map: HashMap; key: CollectionKeys.KeyPtr; VAR value: Collections.ItemPtr): BOOLEAN;
VAR 
    index: INTEGER;
    bucket: LinkedList.List;
    pair: KeyValuePairPtr;
    result: BOOLEAN;
BEGIN
    index := map.keyOps.hash(key, map.size);
    bucket := map.buckets[index];
    
    IF FindInBucket(bucket, key, map.keyOps, pair) THEN
        value := pair.value;
        result := TRUE
    ELSE
        value := NIL;
        result := FALSE
    END;
    
    RETURN result
END GetKey;

(** Get a value by integer key *)
PROCEDURE Get*(map: HashMap; key: INTEGER; VAR value: Collections.ItemPtr): BOOLEAN;
VAR 
    intKey: CollectionKeys.IntegerKeyPtr;
    result: BOOLEAN;
BEGIN
    intKey := CollectionKeys.NewIntegerKey(key);
    result := GetKey(map, intKey, value);
    RETURN result
END Get;

(** Get a value by string key *)
PROCEDURE GetString*(map: HashMap; key: ARRAY OF CHAR; VAR value: Collections.ItemPtr): BOOLEAN;
VAR 
    strKey: CollectionKeys.StringKeyPtr;
    result: BOOLEAN;
BEGIN
    strKey := CollectionKeys.NewStringKey(key);
    result := GetKey(map, strKey, value);
    RETURN result
END GetString;

(** Check if a key exists in the hashmap *)
PROCEDURE ContainsKey*(map: HashMap; key: CollectionKeys.KeyPtr): BOOLEAN;
VAR 
    index: INTEGER;
    bucket: LinkedList.List;
    pair: KeyValuePairPtr;
    result: BOOLEAN;
BEGIN
    index := map.keyOps.hash(key, map.size);
    bucket := map.buckets[index];
    result := FindInBucket(bucket, key, map.keyOps, pair);
    RETURN result
END ContainsKey;

(** Check if an integer key exists in the hashmap *)
PROCEDURE Contains*(map: HashMap; key: INTEGER): BOOLEAN;
VAR 
    intKey: CollectionKeys.IntegerKeyPtr;
    result: BOOLEAN;
BEGIN
    intKey := CollectionKeys.NewIntegerKey(key);
    result := ContainsKey(map, intKey);
    RETURN result
END Contains;

(** Check if a string key exists in the hashmap *)
PROCEDURE ContainsString*(map: HashMap; key: ARRAY OF CHAR): BOOLEAN;
VAR 
    strKey: CollectionKeys.StringKeyPtr;
    result: BOOLEAN;
BEGIN
    strKey := CollectionKeys.NewStringKey(key);
    result := ContainsKey(map, strKey);
    RETURN result
END ContainsString;

(** Remove a key-value pair from the hashmap *)
PROCEDURE RemoveKey*(map: HashMap; key: CollectionKeys.KeyPtr): BOOLEAN;
VAR 
    index, i: INTEGER;
    bucket: LinkedList.List;
    item: Collections.ItemPtr;
    pair: KeyValuePairPtr;
    result: BOOLEAN;
BEGIN
    result := FALSE;
    index := map.keyOps.hash(key, map.size);
    bucket := map.buckets[index];
    
    FOR i := 0 TO LinkedList.Count(bucket) - 1 DO
        IF LinkedList.GetAt(bucket, i, item) THEN
            pair := item(KeyValuePairPtr);
            IF map.keyOps.equals(pair.key, key) THEN
                IF LinkedList.RemoveAt(bucket, i, item) THEN
                    DEC(map.count);
                    result := TRUE
                END
            END
        END
    END;
    
    RETURN result
END RemoveKey;

(** Remove an integer key-value pair from the hashmap *)
PROCEDURE Remove*(map: HashMap; key: INTEGER): BOOLEAN;
VAR 
    intKey: CollectionKeys.IntegerKeyPtr;
    result: BOOLEAN;
BEGIN
    intKey := CollectionKeys.NewIntegerKey(key);
    result := RemoveKey(map, intKey);
    RETURN result
END Remove;

(** Remove a string key-value pair from the hashmap *)
PROCEDURE RemoveString*(map: HashMap; key: ARRAY OF CHAR): BOOLEAN;
VAR 
    strKey: CollectionKeys.StringKeyPtr;
    result: BOOLEAN;
BEGIN
    strKey := CollectionKeys.NewStringKey(key);
    result := RemoveKey(map, strKey);
    RETURN result
END RemoveString;

(** Get the number of key-value pairs in the hashmap *)
PROCEDURE Count*(map: HashMap): INTEGER;
VAR result: INTEGER;
BEGIN
    result := map.count;
    RETURN result
END Count;

(** Test if the hashmap is empty *)
PROCEDURE IsEmpty*(map: HashMap): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
    result := map.count = 0;
    RETURN result
END IsEmpty;

(** Get the current load factor as percentage *)
PROCEDURE LoadFactor*(map: HashMap): INTEGER;
VAR result: INTEGER;
BEGIN
    IF map.size = 0 THEN
        result := 0
    ELSE
        result := (map.count * 100) DIV map.size
    END;
    RETURN result
END LoadFactor;

(** Apply a procedure to each key-value pair in the hashmap *)
PROCEDURE Foreach*(map: HashMap; visit: Collections.VisitProc; VAR state: Collections.VisitorState);
VAR 
    i, j: INTEGER;
    bucket: LinkedList.List;
    item: Collections.ItemPtr;
    pair: KeyValuePairPtr;
    continue: BOOLEAN;
BEGIN
    continue := TRUE;
    i := 0;
    WHILE (i < map.size) & continue DO
        bucket := map.buckets[i];
        j := 0;
        WHILE (j < LinkedList.Count(bucket)) & continue DO
            IF LinkedList.GetAt(bucket, j, item) THEN
                pair := item(KeyValuePairPtr);
                continue := visit(pair, state)
            END;
            INC(j)
        END;
        INC(i)
    END
END Foreach;

END HashMap.
