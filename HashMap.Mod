(** HashMap.mod - A hashmap implementation using separate chaining.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE HashMap;

IMPORT Collections, CollectionKeys;

CONST
    DefaultSize* = 16;
    MaxSize = 1024;
    BucketCapacity = 16;  (* Maximum items per bucket *)

TYPE
    (** Key-Value pair for storage *)
    KeyValuePair* = RECORD(Collections.Item)
        key*: CollectionKeys.KeyPtr;
        value*: Collections.ItemPtr
    END;
    KeyValuePairPtr* = POINTER TO KeyValuePair;

    (* Internal bucket item *)
    BucketItem = RECORD
        pair: KeyValuePairPtr;
        used: BOOLEAN
    END;
    
    (* Internal bucket structure *)
    Bucket = RECORD
        items: ARRAY BucketCapacity OF BucketItem;
        count: INTEGER
    END;

    (* BucketArray is hidden - clients don't need to know about buckets *)
    BucketArray = ARRAY MaxSize OF Bucket;

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
PROCEDURE FindInBucket(VAR bucket: Bucket; key: CollectionKeys.KeyPtr; keyOps: CollectionKeys.KeyOps; VAR found: KeyValuePairPtr): BOOLEAN;
VAR 
    i: INTEGER;
    result: BOOLEAN;
BEGIN
    result := FALSE;
    found := NIL;
    
    i := 0;
    WHILE (i < bucket.count) & ~result DO
        IF bucket.items[i].used & keyOps.equals(bucket.items[i].pair.key, key) THEN
            found := bucket.items[i].pair;
            result := TRUE
        END;
        INC(i)
    END;
    
    RETURN result
END FindInBucket;

(* Internal helper to add item to bucket *)
PROCEDURE AddToBucket(VAR bucket: Bucket; pair: KeyValuePairPtr): BOOLEAN;
VAR 
    result: BOOLEAN;
BEGIN
    result := FALSE;
    
    IF bucket.count < BucketCapacity THEN
        bucket.items[bucket.count].pair := pair;
        bucket.items[bucket.count].used := TRUE;
        INC(bucket.count);
        result := TRUE
    END;
    
    RETURN result
END AddToBucket;

(* Internal helper to remove item from bucket *)
PROCEDURE RemoveFromBucket(VAR bucket: Bucket; key: CollectionKeys.KeyPtr; keyOps: CollectionKeys.KeyOps): BOOLEAN;
VAR 
    i, j: INTEGER;
    result: BOOLEAN;
BEGIN
    result := FALSE;
    
    i := 0;
    WHILE (i < bucket.count) & ~result DO
        IF bucket.items[i].used & keyOps.equals(bucket.items[i].pair.key, key) THEN
            (* Mark as unused *)
            bucket.items[i].used := FALSE;
            bucket.items[i].pair := NIL;
            
            (* Shift remaining items down *)
            FOR j := i TO bucket.count - 2 DO
                bucket.items[j] := bucket.items[j + 1]
            END;
            
            DEC(bucket.count);
            result := TRUE
        END;
        INC(i)
    END;
    
    RETURN result
END RemoveFromBucket;

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
    
    (* Initialize buckets *)
    FOR i := 0 TO map.size - 1 DO
        map.buckets[i].count := 0
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
BEGIN
    IF map # NIL THEN
        map := NIL
    END
END Free;

(** Insert or update a key-value pair *)
PROCEDURE PutKey*(map: HashMap; key: CollectionKeys.KeyPtr; value: Collections.ItemPtr);
VAR 
    index: INTEGER;
    existingPair: KeyValuePairPtr;
    newPair: KeyValuePairPtr;
BEGIN
    index := map.keyOps.hash(key, map.size);
    
    IF FindInBucket(map.buckets[index], key, map.keyOps, existingPair) THEN
        (* Update existing key *)
        existingPair.value := value
    ELSE
        (* Insert new key-value pair *)
        newPair := NewKeyValuePair(key, value);
        IF AddToBucket(map.buckets[index], newPair) THEN
            INC(map.count)
        END
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
    pair: KeyValuePairPtr;
    result: BOOLEAN;
BEGIN
    index := map.keyOps.hash(key, map.size);
    
    IF FindInBucket(map.buckets[index], key, map.keyOps, pair) THEN
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
    pair: KeyValuePairPtr;
    result: BOOLEAN;
BEGIN
    index := map.keyOps.hash(key, map.size);
    result := FindInBucket(map.buckets[index], key, map.keyOps, pair);
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
    index: INTEGER;
    result: BOOLEAN;
BEGIN
    index := map.keyOps.hash(key, map.size);
    
    IF RemoveFromBucket(map.buckets[index], key, map.keyOps) THEN
        DEC(map.count);
        result := TRUE
    ELSE
        result := FALSE
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
    continue: BOOLEAN;
BEGIN
    continue := TRUE;
    i := 0;
    WHILE (i < map.size) & continue DO
        j := 0;
        WHILE (j < map.buckets[i].count) & continue DO
            IF map.buckets[i].items[j].used THEN
                continue := visit(map.buckets[i].items[j].pair, state)
            END;
            INC(j)
        END;
        INC(i)
    END
END Foreach;

(** Clear removes all key-value pairs from the hashmap. *)
PROCEDURE Clear*(map: HashMap);
VAR i: INTEGER;
BEGIN
    IF map # NIL THEN
        FOR i := 0 TO map.size - 1 DO
            map.buckets[i].count := 0
        END;
        map.count := 0
    END
END Clear;

END HashMap.
