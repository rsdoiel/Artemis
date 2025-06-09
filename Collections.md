# Collections in Oberon-ML

This document describes the collection modules implemented in Oberon-ML: `LinkedList`, `DoubleLinkedList`, `Deque`, `ArrayList`, `HashMap`, and `Dictionary`. Each module provides a different type of collection with its own interface and use cases.

## Overview

- **LinkedList**: Singly-linked list for simple, linear data storage with position-based access.
- **DoubleLinkedList**: Doubly-linked list supporting bidirectional traversal and efficient insertions/removals at both ends.
- **Deque**: Double-ended queue built on `DoubleLinkedList`, supporting efficient insertion and removal at both ends.
- **ArrayList**: Dynamic array with indexable access, implemented using chunked arrays for efficient growth.
- **HashMap**: Hash table with separate chaining for efficient key-value storage and retrieval.
- **Dictionary**: Flexible key-value store supporting both integer and string keys, with a unified API.

## API Design Principles

The collections API follows modern software engineering principles:

1. **Information Hiding**: Internal structures (nodes, descriptors, buckets) are encapsulated and not exposed to client code.
2. **Position-Based Access**: Linear collections use 0-based indexing instead of exposing internal node references.
3. **Consistent Type System**: All collections use `Collections.ItemPtr` as the universal item type.
4. **Safe Error Handling**: Operations that can fail (like `GetAt`, `InsertAt`, `Get`) return boolean success indicators.
5. **Uniform Interfaces**: Similar operations across different collection types have consistent signatures.
6. **Flexible Key Support**: Dictionary supports both integer and string keys with a unified interface.

## Supported Data Structures and Operations

| LinkedList      | DoubleLinkedList         | Deque           | ArrayList       | HashMap         | Dictionary      |
|----------------|-------------------------|-----------------|-----------------|-----------------|----------------|
| New            | New                     | New             | New             | New             | New            |
| -              | -                       | -               | -               | NewWithSize     | NewStringDict  |
| Free           | Free                    | Free            | Free            | Free            | Free           |
| Append         | Append                  | Append          | Append          | Put             | Put, PutString |
| -              | Prepend                 | Prepend         | -               | -               | -              |
| InsertAt       | InsertAt                | -               | -               | -               | -              |
| RemoveFirst    | RemoveFirst             | RemoveFirst     | -               | Remove          | Remove, RemoveString |
| -              | RemoveLast              | RemoveLast      | -               | -               | -              |
| GetAt          | GetAt                   | -               | GetAt           | Get             | Get, GetString |
| -              | -                       | -               | SetAt           | -               | -              |
| -              | Head                    | -               | -               | -               | -              |
| -              | Tail                    | -               | -               | -               | -              |
| Count          | Count                   | Count           | Count           | Count           | Count          |
| IsEmpty        | IsEmpty                 | IsEmpty         | IsEmpty         | IsEmpty         | IsEmpty        |
| Clear          | Clear                   | Clear           | Clear           | Clear           | Clear          |
| Foreach        | Foreach                 | Foreach         | Foreach         | Foreach         | Foreach        |
| -              | -                       | -               | -               | Contains        | Contains, ContainsString |


## Module Summaries

### LinkedList
- **Purpose:** Simple, efficient singly-linked list.
- **Key Procedures:**
  - `New`, `Free`, `Append`, `RemoveFirst`, `InsertAt`, `GetAt`, `Count`, `IsEmpty`, `Clear`, `Foreach`
- **Notes:** Position-based access with 0-based indexing. Only supports removal from the front. `Clear` removes all elements from the list.

### DoubleLinkedList
- **Purpose:** More flexible list with bidirectional links.
- **Key Procedures:**
  - `New`, `Free`, `Append`, `Prepend`, `InsertAt`, `RemoveFirst`, `RemoveLast`, `GetAt`, `Head`, `Tail`, `Count`, `IsEmpty`, `Clear`, `Foreach`
- **Notes:** Position-based insertion and access with 0-based indexing. Supports removal from both ends and efficient access to head/tail elements. `Clear` removes all elements from the list.

### Deque
- **Purpose:** Double-ended queue for efficient insertion/removal at both ends.
- **Key Procedures:**
  - `New`, `Free`, `Append`, `Prepend`, `RemoveFirst`, `RemoveLast`, `Count`, `IsEmpty`, `Clear`, `Foreach`
- **Notes:** Built on `DoubleLinkedList` for efficiency and code reuse. `Clear` removes all elements from the deque.

### ArrayList
- **Purpose:** Dynamic array providing indexable access with automatic growth.
- **Key Procedures:**
  - `New`, `Free`, `Append`, `GetAt`, `SetAt`, `Count`, `IsEmpty`, `Clear`, `Foreach`
- **Notes:** Implemented using chunked arrays (64-item chunks) managed by `LinkedList`. Provides O(1) append and reasonable random access performance. Index-based access with 0-based indexing. `Clear` removes all elements from the list.

### HashMap
- **Purpose:** Hash table for efficient key-value storage and retrieval.
- **Key Procedures:**
  - `New`, `NewWithSize`, `Free`, `Put`, `Get`, `Contains`, `Remove`, `Count`, `IsEmpty`, `LoadFactor`, `Clear`, `Foreach`
- **Key Types:**
  - `KeyValuePair`: Record type extending `Collections.Item` with `key` (INTEGER) and `value` (Collections.ItemPtr) fields
  - `NewKeyValuePair`: Constructor for creating key-value pairs
- **Notes:** Uses separate chaining with LinkedLists for collision resolution. Keys are INTEGER type. Fixed-size bucket array with configurable initial size. `Clear` removes all key-value pairs from the map.

### Dictionary
- **Purpose:** Flexible key-value store supporting both integer and string keys with a unified API.
- **Key Procedures:**
  - `New`, `NewStringDict`, `Free`, `Put`, `PutString`, `Get`, `GetString`, `Remove`, `RemoveString`, `Contains`, `ContainsString`, `Count`, `IsEmpty`, `Clear`, `Foreach`
- **Notes:**
  - Supports both integer and string keys, with dedicated procedures for each.
  - `Foreach` applies a visitor procedure to all values in the dictionary.
  - `Clear` removes all key-value pairs from the dictionary.

## Usage Examples

### LinkedList Example

```oberon
IMPORT LinkedList, Collections;

TYPE
    MyItem = RECORD (Collections.Item)
        value: INTEGER
    END;
    MyItemPtr = POINTER TO MyItem;

VAR 
    list: LinkedList.List;
    item: MyItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;

BEGIN
    list := LinkedList.New();
    
    (* Create and add items *)
    NEW(item); item.value := 42;
    LinkedList.Append(list, item);
    
    (* Insert at specific position *)
    NEW(item); item.value := 10;
    success := LinkedList.InsertAt(list, 0, item);
    
    (* Access items by position *)
    success := LinkedList.GetAt(list, 1, result);
    IF success THEN
        (* Use result(MyItemPtr).value *)
    END;
    
    LinkedList.Free(list);
END.
```

### ArrayList Example

```oberon
IMPORT ArrayList, Collections;

TYPE
    MyItem = RECORD (Collections.Item)
        value: INTEGER
    END;
    MyItemPtr = POINTER TO MyItem;

VAR 
    list: ArrayList.ArrayList;
    item: MyItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    i: INTEGER;

BEGIN
    list := ArrayList.New();
    
    (* Append items to the list *)
    FOR i := 0 TO 99 DO
        NEW(item); item.value := i * 10;
        success := ArrayList.Append(list, item);
    END;
    
    (* Access items by index *)
    success := ArrayList.GetAt(list, 50, result);
    IF success THEN
        (* Use result(MyItemPtr).value *)
    END;
    
    (* Update an item at specific index *)
    NEW(item); item.value := 999;
    success := ArrayList.SetAt(list, 25, item);
    
    (* Access elements efficiently across chunk boundaries *)
    success := ArrayList.GetAt(list, 63, result);  (* Last item in first chunk *)
    success := ArrayList.GetAt(list, 64, result);  (* First item in second chunk *)
    
    ArrayList.Free(list);
END.
```

### HashMap Example

```oberon
IMPORT HashMap, Collections, CollectionKeys;

TYPE
    MyItem = RECORD (Collections.Item)
        name: ARRAY 32 OF CHAR;
        value: INTEGER
    END;
    MyItemPtr = POINTER TO MyItem;

VAR 
    map: HashMap.HashMap;
    item: MyItemPtr;
    result: Collections.ItemPtr;
    ops: CollectionKeys.KeyOps;
    success: BOOLEAN;

BEGIN
    (* Create HashMap with integer keys *)
    map := HashMap.New();
    
    (* Or create with custom size *)
    CollectionKeys.IntegerKeyOps(ops);
    map := HashMap.NewWithSize(32, ops);
    
    (* Create and store items *)
    NEW(item); 
    item.name := "test";
    item.value := 42;
    HashMap.Put(map, 123, item);
    
    (* Retrieve items by key *)
    success := HashMap.Get(map, 123, result);
    IF success THEN
        (* Use result(MyItemPtr).value *)
    END;
    
    (* Check if key exists *)
    IF HashMap.Contains(map, 123) THEN
        (* Key is present *)
    END;
    
    (* Remove items *)
    success := HashMap.Remove(map, 123);
    
    HashMap.Free(map);
END.
```

### Dictionary Example

```oberon
IMPORT Dictionary, Collections;

TYPE
    MyItem = RECORD (Collections.Item)
        value: INTEGER
    END;
    MyItemPtr = POINTER TO MyItem;

VAR
    dict: Dictionary.Dictionary;
    item: MyItemPtr;
    result: Collections.ItemPtr;
    found: BOOLEAN;

BEGIN
    (* Create a dictionary with integer keys *)
    dict := Dictionary.New();

    (* Or create a dictionary with string keys *)
    dict := Dictionary.NewStringDict();

    (* Insert by integer key *)
    NEW(item); item.value := 42;
    Dictionary.Put(dict, 123, item);

    (* Insert by string key *)
    NEW(item); item.value := 99;
    Dictionary.PutString(dict, "foo", item);

    (* Retrieve by integer key *)
    found := Dictionary.Get(dict, 123, result);
    IF found THEN
        (* Use result(MyItemPtr).value *)
    END;

    (* Retrieve by string key *)
    found := Dictionary.GetString(dict, "foo", result);
    IF found THEN
        (* Use result(MyItemPtr).value *)
    END;

    (* Remove by integer key *)
    Dictionary.Remove(dict, 123);

    (* Remove by string key *)
    Dictionary.RemoveString(dict, "foo");

    Dictionary.Free(dict);
END.
```

## Extending Collections

All collection modules work with items that extend the base `Collections.Item` type. The collections use `Collections.ItemPtr` (which is `POINTER TO Collections.Item`) as the universal item type, providing type safety while allowing flexibility.

### HashMap Key-Value Pairs

The HashMap module provides a special `KeyValuePair` type that extends `Collections.Item`:

```oberon
TYPE
    KeyValuePair* = RECORD(Collections.Item)
        key*: CollectionKeys.KeyPtr;
        value*: Collections.ItemPtr
    END;
```

This allows HashMap to work seamlessly with the visitor pattern used by `Foreach`, where the visitor receives `KeyValuePair` items containing both the key and the associated value.

## CollectionKeys Module

The `CollectionKeys` module provides extensible key support for key-value collections like HashMap. It defines base key types and operations that can be extended for different key types.

### Key Types

```oberon
TYPE
    (* Base key type - extend for specific key types *)
    Key* = RECORD(Collections.Item) END;
    KeyPtr* = POINTER TO Key;
    
    (* Integer key implementation *)
    IntegerKey* = RECORD(Key)
        value*: INTEGER
    END;
    IntegerKeyPtr* = POINTER TO IntegerKey;
    
    (* Key operations interface *)
    KeyOps* = RECORD
        hash*: PROCEDURE(key: KeyPtr; size: INTEGER): INTEGER;
        equals*: PROCEDURE(key1, key2: KeyPtr): BOOLEAN
    END;
```

### Usage

```oberon
(* Create integer key operations *)
VAR ops: CollectionKeys.KeyOps;
CollectionKeys.IntegerKeyOps(ops);

(* Use with HashMap *)
map := HashMap.NewWithSize(32, ops);

(* Or use convenience constructor for integer keys *)
map := HashMap.New();
```

### Extending with Custom Key Types

Future key types can be added by extending the base `Key` type and providing appropriate hash and equality functions:

```oberon
(* Example: String key type *)
TYPE
    StringKey = RECORD(CollectionKeys.Key)
        value: ARRAY 256 OF CHAR
    END;
    StringKeyPtr = POINTER TO StringKey;

PROCEDURE HashString(key: CollectionKeys.KeyPtr; size: INTEGER): INTEGER;
    (* Implementation for string hashing *)

PROCEDURE EqualsString(key1, key2: CollectionKeys.KeyPtr): BOOLEAN;
    (* Implementation for string comparison *)

PROCEDURE StringKeyOps(VAR ops: CollectionKeys.KeyOps);
BEGIN
    ops.hash := HashString;
    ops.equals := EqualsString
END StringKeyOps;
```

### Information Hiding

The collection modules implement proper information hiding:
- **LinkedList** and **DoubleLinkedList** use opaque `List` types with internal node structures
- **Deque** uses an opaque `Deque` type built on `DoubleLinkedList`
- **ArrayList** uses an opaque `ArrayList` type with internal chunked array structure managed by `LinkedList`
- **HashMap** uses an opaque `HashMap` type with internal bucket array and hash function
- **Dictionary** uses an opaque `Dictionary` type with internal structure, supporting both integer and string keys
- Internal implementation details (nodes, list descriptors, hash buckets, array chunks) are not exposed
- Position-based access (`InsertAt`, `GetAt`, `SetAt`) replaces direct node manipulation or array access

### Type Safety

All collections use the common `Collections.ItemPtr` type, which ensures:
- Consistent interfaces across all collection types
- Type-safe operations with proper type guards when needed
- No module-specific item types that could cause confusion

Always use the provided procedures for manipulating collections to ensure safety and correctness.

## ArrayList Implementation Details

The ArrayList module provides dynamic array functionality while working within Oberon-07's fixed-size array constraints. It uses a chunked array approach:

- **Chunked Storage**: Items are stored in fixed-size chunks (64 items each) managed by a LinkedList
- **Performance Characteristics**:
  - O(1) append operations (amortized)
  - O(n/64) random access (where n is the index)
  - Automatic growth without memory reallocation of existing data
- **Memory Efficiency**: Only allocates chunks as needed, reducing memory waste
- **Cross-Chunk Access**: Seamless access across chunk boundaries with 0-based indexing
- **Suitable Use Cases**: When you need indexable access to a growing collection but don't know the final size in advance

## Operation Details

### Position-Based Operations (Linear Collections)

- **InsertAt(position, item)**: Inserts item at 0-based position, returns `TRUE` if successful (LinkedList, DoubleLinkedList)
- **GetAt(position, VAR result)**: Retrieves item at position, returns `TRUE` if successful and sets `result` (LinkedList, DoubleLinkedList, ArrayList)
- **SetAt(position, item)**: Updates item at position, returns `TRUE` if successful (ArrayList)
- **Append(item)**: Adds item to the end of the collection (LinkedList, DoubleLinkedList, ArrayList)
- **Clear()**: Removes all elements from the collection (LinkedList, DoubleLinkedList, Deque, ArrayList)

### Key-Based Operations (HashMap, Dictionary)

- **Put(key, value)**: Stores or updates the value associated with the key
- **PutString(key, value)**: Stores or updates the value associated with the string key (Dictionary and HashMap with string keys)
- **Get(key, VAR result)**: Retrieves value for the key, returns `TRUE` if found and sets `result`
- **GetString(key, VAR result)**: Retrieves value for the string key, returns `TRUE` if found and sets `result` (Dictionary and HashMap with string keys)
- **Contains(key)**: Returns `TRUE` if the key exists in the map/dictionary
- **ContainsString(key)**: Returns `TRUE` if the string key exists (Dictionary and HashMap with string keys)
- **Remove(key, VAR result)**: Removes key-value pair, returns `TRUE` if found and sets `result` to the removed value (HashMap)
- **Remove(key)**: Removes key-value pair by key (Dictionary)
- **RemoveString(key)**: Removes key-value pair by string key (Dictionary and HashMap with string keys)
- **Clear()**: Removes all key-value pairs from the map/dictionary (HashMap, Dictionary)

---

For detailed API documentation, see the respective `.def.html` files in the `docs/` directory.
