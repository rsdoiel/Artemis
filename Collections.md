# Collections in Oberon-ML

This document describes the collection modules implemented in Oberon-ML: `LinkedList`, `DoubleLinkedList`, `Deque`, and `HashMap`. Each module provides a different type of collection with its own interface and use cases.

## Overview

- **LinkedList**: Singly-linked list for simple, linear data storage with position-based access.
- **DoubleLinkedList**: Doubly-linked list supporting bidirectional traversal and efficient insertions/removals at both ends.
- **Deque**: Double-ended queue built on `DoubleLinkedList`, supporting efficient insertion and removal at both ends.
- **HashMap**: Hash table with separate chaining for efficient key-value storage and retrieval.

## API Design Principles

The collections API follows modern software engineering principles:

1. **Information Hiding**: Internal structures (nodes, descriptors, buckets) are encapsulated and not exposed to client code.
2. **Position-Based Access**: Linear collections use 0-based indexing instead of exposing internal node references.
3. **Consistent Type System**: All collections use `Collections.ItemPtr` as the universal item type.
4. **Safe Error Handling**: Operations that can fail (like `GetAt`, `InsertAt`, `Get`) return boolean success indicators.
5. **Uniform Interfaces**: Similar operations across different collection types have consistent signatures.

## Supported Data Structures and Operations

| LinkedList      | DoubleLinkedList         | Deque           | HashMap         |
|----------------|-------------------------|-----------------|-----------------|
| New            | New                     | New             | New             |
| -              | -                       | -               | NewWithSize     |
| Free           | Free                    | Free            | Free            |
| Append         | Append                  | Append          | Put             |
| -              | Prepend                 | Prepend         | Get             |
| InsertAt       | InsertAt                | -               | Contains        |
| RemoveFirst    | RemoveFirst             | RemoveFirst     | Remove          |
| -              | RemoveLast              | RemoveLast      | -               |
| GetAt          | GetAt                   | -               | -               |
| -              | Head                    | -               | -               |
| -              | Tail                    | -               | -               |
| Count          | Count                   | Count           | Count           |
| IsEmpty        | IsEmpty                 | IsEmpty         | IsEmpty         |
| -              | -                       | -               | LoadFactor      |
| Foreach        | Foreach                 | Foreach         | Foreach         |

## Module Summaries

### LinkedList
- **Purpose:** Simple, efficient singly-linked list.
- **Key Procedures:**
  - `New`, `Free`, `Append`, `RemoveFirst`, `InsertAt`, `GetAt`, `Count`, `IsEmpty`, `Foreach`
- **Notes:** Position-based access with 0-based indexing. Only supports removal from the front.

### DoubleLinkedList
- **Purpose:** More flexible list with bidirectional links.
- **Key Procedures:**
  - `New`, `Free`, `Append`, `Prepend`, `InsertAt`, `RemoveFirst`, `RemoveLast`, `GetAt`, `Head`, `Tail`, `Count`, `IsEmpty`, `Foreach`
- **Notes:** Position-based insertion and access with 0-based indexing. Supports removal from both ends and efficient access to head/tail elements.

### Deque
- **Purpose:** Double-ended queue for efficient insertion/removal at both ends.
- **Key Procedures:**
  - `New`, `Free`, `Append`, `Prepend`, `RemoveFirst`, `RemoveLast`, `Count`, `IsEmpty`, `Foreach`
- **Notes:** Built on `DoubleLinkedList` for efficiency and code reuse.

### HashMap
- **Purpose:** Hash table for efficient key-value storage and retrieval.
- **Key Procedures:**
  - `New`, `NewWithSize`, `Free`, `Put`, `Get`, `Contains`, `Remove`, `Count`, `IsEmpty`, `LoadFactor`, `Foreach`
- **Key Types:**
  - `KeyValuePair`: Record type extending `Collections.Item` with `key` (INTEGER) and `value` (Collections.ItemPtr) fields
  - `NewKeyValuePair`: Constructor for creating key-value pairs
- **Notes:** Uses separate chaining with LinkedLists for collision resolution. Keys are INTEGER type. Fixed-size bucket array with configurable initial size.

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
- **HashMap** uses an opaque `HashMap` type with internal bucket array and hash function
- Internal implementation details (nodes, list descriptors, hash buckets) are not exposed
- Position-based access (`InsertAt`, `GetAt`) replaces direct node manipulation

### Type Safety

All collections use the common `Collections.ItemPtr` type, which ensures:
- Consistent interfaces across all collection types
- Type-safe operations with proper type guards when needed
- No module-specific item types that could cause confusion

Always use the provided procedures for manipulating collections to ensure safety and correctness.

## Operation Details

### Position-Based Operations (Linear Collections)

- **InsertAt(position, item)**: Inserts item at 0-based position, returns `TRUE` if successful
- **GetAt(position, VAR result)**: Retrieves item at position, returns `TRUE` if successful and sets `result`

### Key-Based Operations (HashMap)

- **Put(key, value)**: Stores or updates the value associated with the key
- **Get(key, VAR result)**: Retrieves value for the key, returns `TRUE` if found and sets `result`
- **Contains(key)**: Returns `TRUE` if the key exists in the map
- **Remove(key, VAR result)**: Removes key-value pair, returns `TRUE` if found and sets `result` to the removed value

### Access Operations (DoubleLinkedList only)

- **Head(VAR result)**: Gets first item, returns `TRUE` if list is not empty
- **Tail(VAR result)**: Gets last item, returns `TRUE` if list is not empty

### Removal Operations

- **RemoveFirst(VAR result)**: Removes first item, sets `result` to item (or `NIL` if empty)
- **RemoveLast(VAR result)**: Removes last item, sets `result` to item (or `NIL` if empty)

### Performance Monitoring (HashMap)

- **LoadFactor()**: Returns the current load factor (count/size ratio) as a REAL value for performance monitoring

### Notes on Error Handling

- Position-based operations validate bounds and return `FALSE` for invalid positions
- Access operations on empty collections return `FALSE` and set result to `NIL`
- Removal from empty collections sets result to `NIL` but does not signal error
- HashMap operations with non-existent keys return `FALSE` and set result to `NIL`

---

For detailed API documentation, see the respective `.def.html` files in the `docs/` directory.
