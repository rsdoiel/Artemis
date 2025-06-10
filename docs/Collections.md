# Collections in Oberon-ML

This page gives a quick, practical overview of the collection modules in Oberon-ML. The goal is to make it easy to see what each module does, what operations are available, and how to use them in your own code. This is a work in progress, so details may change.

## What’s Here?

- **LinkedList**: Simple singly-linked list. Good for basic, linear data storage.
- **DoubleLinkedList**: Like LinkedList, but you can go both ways and remove from either end.
- **Deque**: Double-ended queue (built on DoubleLinkedList). Fast insert/remove at both ends.
- **ArrayList**: Dynamic array with index access. Uses chunked arrays for growth.
- **HashMap**: Hash table for fast key-value storage (integer keys).
- **Dictionary**: Key-value store that supports both integer and string keys.
- **Heap**: Binary heap for priority queues (customizable comparison).
- **HeapSort**: Heap-based sorting and utilities for ArrayList.
- **Stack**: LIFO stack (last-in, first-out), built on LinkedList.
- **Queue**: FIFO queue (first-in, first-out), built on LinkedList.

## API Basics

- All collections use `Collections.ItemPtr` as the universal item type.
- Most operations return a boolean to indicate success/failure.
- Similar operations (like `Append`, `GetAt`, `Count`) have the same names across modules.
- Key-value collections use the `CollectionKeys` module for key types and operations.

## Quick Feature Table

| LinkedList      | DoubleLinkedList         | Deque           | ArrayList       | HashMap         | Dictionary      | Heap            | HeapSort        | Stack           | Queue           |
|----------------|-------------------------|-----------------|-----------------|-----------------|----------------|-----------------|-----------------|-----------------|-----------------|
| New            | New                     | New             | New             | New             | New            | New             | SortInPlace     | New             | New             |
| -              | -                       | -               | -               | NewWithSize     | NewStringDict  | -               | Sort            | -               | -               |
| Free           | Free                    | Free            | Free            | Free            | Free           | Free            | IsSorted        | Free            | Free            |
| Append         | Append                  | Append          | Append          | Put             | Put, PutString | Insert          | FindKthSmallest | Push            | Enqueue         |
| -              | Prepend                 | Prepend         | -               | -               | -              | ExtractMin      | MergeSorted     | Pop             | Dequeue         |
| InsertAt       | InsertAt                | -               | -               | -               | -              | PeekMin         | -               | Top             | Front           |
| RemoveFirst    | RemoveFirst             | RemoveFirst     | -               | Remove          | Remove, RemoveString | -         | -               | -               | -               |
| -              | RemoveLast              | RemoveLast      | -               | -               | -              | -               | -               | -               | -               |
| GetAt          | GetAt                   | -               | GetAt           | Get             | Get, GetString | -               | -               | -               | -               |
| -              | -                       | -               | SetAt           | -               | -              | -               | -               | -               | -               |
| -              | Head                    | -               | -               | -               | -              | -               | -               | -               | -               |
| -              | Tail                    | -               | -               | -               | -              | -               | -               | -               | -               |
| Count          | Count                   | Count           | Count           | Count           | Count          | Count           | -               | Count           | Count           |
| IsEmpty        | IsEmpty                 | IsEmpty         | IsEmpty         | IsEmpty         | IsEmpty        | IsEmpty         | -               | IsEmpty         | IsEmpty         |
| Clear          | Clear                   | Clear           | Clear           | Clear           | Clear          | Clear           | -               | Clear           | Clear           |
| Foreach        | Foreach                 | Foreach         | Foreach         | Foreach         | Foreach        | Foreach         | -               | Foreach         | Foreach         |
| -              | -                       | -               | -               | Contains        | Contains, ContainsString | -       | -               | -               | -               |

## How to Use

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
    NEW(item); item.value := 42;
    LinkedList.Append(list, item);
    NEW(item); item.value := 10;
    success := LinkedList.InsertAt(list, 0, item);
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
    FOR i := 0 TO 99 DO
        NEW(item); item.value := i * 10;
        success := ArrayList.Append(list, item);
    END;
    success := ArrayList.GetAt(list, 50, result);
    IF success THEN
        (* Use result(MyItemPtr).value *)
    END;
    NEW(item); item.value := 999;
    success := ArrayList.SetAt(list, 25, item);
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
    map := HashMap.New();
    CollectionKeys.IntegerKeyOps(ops);
    map := HashMap.NewWithSize(32, ops);
    NEW(item); 
    item.name := "test";
    item.value := 42;
    HashMap.Put(map, 123, item);
    success := HashMap.Get(map, 123, result);
    IF success THEN
        (* Use result(MyItemPtr).value *)
    END;
    IF HashMap.Contains(map, 123) THEN
        (* Key is present *)
    END;
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
    dict := Dictionary.New();
    dict := Dictionary.NewStringDict();
    NEW(item); item.value := 42;
    Dictionary.Put(dict, 123, item);
    NEW(item); item.value := 99;
    Dictionary.PutString(dict, "foo", item);
    found := Dictionary.Get(dict, 123, result);
    IF found THEN
        (* Use result(MyItemPtr).value *)
    END;
    found := Dictionary.GetString(dict, "foo", result);
    IF found THEN
        (* Use result(MyItemPtr).value *)
    END;
    Dictionary.Remove(dict, 123);
    Dictionary.RemoveString(dict, "foo");
    Dictionary.Free(dict);
END.
```

### Stack Example

```oberon
IMPORT Stack, Collections, Out;

TYPE
    MyItem = RECORD (Collections.Item)
        value: INTEGER
    END;
    MyItemPtr = POINTER TO MyItem;

VAR 
    stack: Stack.Stack;
    item: MyItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    i: INTEGER;

BEGIN
    stack := Stack.New();
    FOR i := 1 TO 5 DO
        NEW(item); item.value := i * 10;
        Stack.Push(stack, item);
        Out.String("Pushed: "); Out.Int(item.value, 0); Out.Ln;
    END;
    success := Stack.Top(stack, result);
    IF success THEN
        Out.String("Top item: "); Out.Int(result(MyItemPtr).value, 0); Out.Ln;
    END;
    Out.String("Popping items: ");
    WHILE ~Stack.IsEmpty(stack) DO
        Stack.Pop(stack, result);
        IF result # NIL THEN
            Out.Int(result(MyItemPtr).value, 0); Out.String(" ");
        END;
    END;
    Out.Ln;
    Stack.Free(stack);
END.
```

### Queue Example

```oberon
IMPORT Queue, Collections, Out;

TYPE
    MyItem = RECORD (Collections.Item)
        value: INTEGER
    END;
    MyItemPtr = POINTER TO MyItem;

VAR 
    queue: Queue.Queue;
    item: MyItemPtr;
    result: Collections.ItemPtr;
    success: BOOLEAN;
    i: INTEGER;

BEGIN
    queue := Queue.New();
    FOR i := 1 TO 5 DO
        NEW(item); item.value := i * 10;
        Queue.Enqueue(queue, item);
        Out.String("Enqueued: "); Out.Int(item.value, 0); Out.Ln;
    END;
    success := Queue.Front(queue, result);
    IF success THEN
        Out.String("Front item: "); Out.Int(result(MyItemPtr).value, 0); Out.Ln;
    END;
    Out.String("Dequeuing items: ");
    WHILE ~Queue.IsEmpty(queue) DO
        Queue.Dequeue(queue, result);
        IF result # NIL THEN
            Out.Int(result(MyItemPtr).value, 0); Out.String(" ");
        END;
    END;
    Out.Ln;
    Queue.Free(queue);
END.
```

## How Keys Work

Key-value collections (like HashMap and Dictionary) use the `CollectionKeys` module to handle keys. This lets you use both integer and string keys, and makes it possible to add new key types later if needed.

```oberon
TYPE
    Key* = RECORD(Collections.Item) END;
    IntegerKey* = RECORD(Key) value*: INTEGER END;
    StringKey* = RECORD(Key) value*: ARRAY 256 OF CHAR END;
    KeyOps* = RECORD
        hash*: PROCEDURE(key: KeyPtr; size: INTEGER): INTEGER;
        equals*: PROCEDURE(key1, key2: KeyPtr): BOOLEAN
    END;
```

To use integer keys:

```oberon
VAR ops: CollectionKeys.KeyOps;
CollectionKeys.IntegerKeyOps(ops);
map := HashMap.NewWithSize(32, ops);
```

String keys work the same way, just use `StringKeyOps`.

## Wrapping Collections

Sometimes you want to store a whole collection as an item in another collection. The `CollectionWrappers` module lets you do this by wrapping, for example, a Dictionary as a `Collections.ItemPtr`.

```oberon
TYPE
    DictionaryWrapper* = RECORD(Collections.Item)
        dict*: Dictionary.Dictionary
    END;
```

## Notes

- All collections use opaque types, so you don’t see the internal details.
- Always use the provided procedures for safety and correctness.
- This API is still evolving, so expect changes.

For more details, see the generated API docs in `obncdoc/`.
