(** DictionaryTest.mod - Unit tests for Dictionary.mod.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE DictionaryTest;

IMPORT Dictionary, Collections, Tests;

TYPE
    TestItem = RECORD(Collections.Item)
        value: INTEGER
    END;
    TestItemPtr = POINTER TO TestItem;

    TestVisitorState = RECORD(Dictionary.DictVisitorState)
        sum: INTEGER;
        count: INTEGER
    END;

VAR
    ts: Tests.TestSet;

(** Create a new test item *)
PROCEDURE NewTestItem(value: INTEGER): TestItemPtr;
VAR item: TestItemPtr;
BEGIN
    NEW(item);
    item.value := value;
    RETURN item
END NewTestItem;

(** Visitor procedure for testing iteration with integer keys *)
PROCEDURE IntKeyVisitor(key: INTEGER; value: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
VAR testItem: TestItemPtr;
BEGIN
    testItem := value(TestItemPtr);
    state(TestVisitorState).sum := state(TestVisitorState).sum + testItem.value;
    INC(state(TestVisitorState).count);
    RETURN TRUE
END IntKeyVisitor;

(** Visitor procedure for testing iteration with string keys *)
PROCEDURE StringKeyVisitor(key: ARRAY OF CHAR; value: Collections.ItemPtr; VAR state: Collections.VisitorState): BOOLEAN;
VAR testItem: TestItemPtr;
BEGIN
    testItem := value(TestItemPtr);
    state(TestVisitorState).sum := state(TestVisitorState).sum + testItem.value;
    INC(state(TestVisitorState).count);
    RETURN TRUE
END StringKeyVisitor;

PROCEDURE TestNewAndFree*(): BOOLEAN;
VAR dict: Dictionary.Dictionary; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dict := Dictionary.New();
    Tests.ExpectedBool(TRUE, dict # NIL, "Dictionary.New should return non-nil", pass);
    Tests.ExpectedBool(TRUE, Dictionary.IsEmpty(dict), "New dictionary should be empty", pass);
    Tests.ExpectedInt(0, Dictionary.Count(dict), "New dictionary should have count 0", pass);
    Dictionary.Free(dict);
    Tests.ExpectedBool(TRUE, dict = NIL, "Dictionary.Free should set dict to NIL", pass);
    RETURN pass
END TestNewAndFree;

PROCEDURE TestPutAndGet*(): BOOLEAN;
VAR dict: Dictionary.Dictionary; item1, item2, item3, retrieved: TestItemPtr; value: Collections.ItemPtr; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dict := Dictionary.New();
    item1 := NewTestItem(100);
    item2 := NewTestItem(200);
    item3 := NewTestItem(300);
    Dictionary.Put(dict, 1, item1);
    Dictionary.Put(dict, 2, item2);
    Dictionary.Put(dict, 3, item3);
    Tests.ExpectedInt(3, Dictionary.Count(dict), "Count should be 3 after 3 puts", pass);
    Tests.ExpectedBool(FALSE, Dictionary.IsEmpty(dict), "Dictionary should not be empty", pass);
    IF Dictionary.Get(dict, 1, value) THEN
        retrieved := value(TestItemPtr);
        Tests.ExpectedInt(100, retrieved.value, "Get key 1 should return item with value 100", pass)
    ELSE
        Tests.ExpectedBool(TRUE, FALSE, "Get key 1 should succeed", pass)
    END;
    IF Dictionary.Get(dict, 2, value) THEN
        retrieved := value(TestItemPtr);
        Tests.ExpectedInt(200, retrieved.value, "Get key 2 should return item with value 200", pass)
    ELSE
        Tests.ExpectedBool(TRUE, FALSE, "Get key 2 should succeed", pass)
    END;
    IF Dictionary.Get(dict, 3, value) THEN
        retrieved := value(TestItemPtr);
        Tests.ExpectedInt(300, retrieved.value, "Get key 3 should return item with value 300", pass)
    ELSE
        Tests.ExpectedBool(TRUE, FALSE, "Get key 3 should succeed", pass)
    END;
    Tests.ExpectedBool(FALSE, Dictionary.Get(dict, 999, value), "Get non-existent key should return FALSE", pass);
    Dictionary.Free(dict);
    RETURN pass
END TestPutAndGet;

PROCEDURE TestUpdateExistingKey*(): BOOLEAN;
VAR dict: Dictionary.Dictionary; item1, item2, retrieved: TestItemPtr; value: Collections.ItemPtr; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dict := Dictionary.New();
    item1 := NewTestItem(100);
    item2 := NewTestItem(999);
    Dictionary.Put(dict, 42, item1);
    Tests.ExpectedInt(1, Dictionary.Count(dict), "Count should be 1 after first put", pass);
    Dictionary.Put(dict, 42, item2);
    Tests.ExpectedInt(1, Dictionary.Count(dict), "Count should still be 1 after update", pass);
    IF Dictionary.Get(dict, 42, value) THEN
        retrieved := value(TestItemPtr);
        Tests.ExpectedInt(999, retrieved.value, "Updated value should be 999", pass)
    ELSE
        Tests.ExpectedBool(TRUE, FALSE, "Get after update should succeed", pass)
    END;
    Dictionary.Free(dict);
    RETURN pass
END TestUpdateExistingKey;

PROCEDURE TestContains*(): BOOLEAN;
VAR dict: Dictionary.Dictionary; item1: TestItemPtr; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dict := Dictionary.New();
    item1 := NewTestItem(100);
    Tests.ExpectedBool(FALSE, Dictionary.Contains(dict, 1), "Contains should return FALSE for non-existent key", pass);
    Dictionary.Put(dict, 1, item1);
    Tests.ExpectedBool(TRUE, Dictionary.Contains(dict, 1), "Contains should return TRUE for existing key", pass);
    Tests.ExpectedBool(FALSE, Dictionary.Contains(dict, 2), "Contains should return FALSE for different key", pass);
    Dictionary.Free(dict);
    RETURN pass
END TestContains;

PROCEDURE TestRemove*(): BOOLEAN;
VAR dict: Dictionary.Dictionary; item1, item2: TestItemPtr; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dict := Dictionary.New();
    item1 := NewTestItem(100);
    item2 := NewTestItem(200);
    Dictionary.Put(dict, 1, item1);
    Dictionary.Put(dict, 2, item2);
    Tests.ExpectedInt(2, Dictionary.Count(dict), "Count should be 2 after puts", pass);
    Tests.ExpectedBool(TRUE, Dictionary.Remove(dict, 1), "Remove existing key should return TRUE", pass);
    Tests.ExpectedInt(1, Dictionary.Count(dict), "Count should be 1 after remove", pass);
    Tests.ExpectedBool(FALSE, Dictionary.Contains(dict, 1), "Removed key should not exist", pass);
    Tests.ExpectedBool(TRUE, Dictionary.Contains(dict, 2), "Other key should still exist", pass);
    Tests.ExpectedBool(FALSE, Dictionary.Remove(dict, 999), "Remove non-existent key should return FALSE", pass);
    Tests.ExpectedInt(1, Dictionary.Count(dict), "Count should be unchanged", pass);
    Tests.ExpectedBool(TRUE, Dictionary.Remove(dict, 2), "Remove last key should return TRUE", pass);
    Tests.ExpectedInt(0, Dictionary.Count(dict), "Count should be 0 after removing all", pass);
    Tests.ExpectedBool(TRUE, Dictionary.IsEmpty(dict), "Dictionary should be empty after removing all", pass);
    Dictionary.Free(dict);
    RETURN pass
END TestRemove;

PROCEDURE TestForeach*(): BOOLEAN;
VAR dict: Dictionary.Dictionary; item1, item2, item3: TestItemPtr; state: TestVisitorState; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dict := Dictionary.New();
    item1 := NewTestItem(10);
    item2 := NewTestItem(20);
    item3 := NewTestItem(30);
    Dictionary.Put(dict, 1, item1);
    Dictionary.Put(dict, 2, item2);
    Dictionary.Put(dict, 3, item3);
    state.sum := 0;
    state.count := 0;
    Dictionary.ForeachInt(dict, IntKeyVisitor, state);
    Tests.ExpectedInt(60, state.sum, "Sum of all values should be 60", pass);
    Tests.ExpectedInt(3, state.count, "Should visit 3 items", pass);
    Dictionary.Free(dict);
    RETURN pass
END TestForeach;

PROCEDURE TestClear*(): BOOLEAN;
VAR dict: Dictionary.Dictionary; value: Collections.ItemPtr; pass, found: BOOLEAN; i: INTEGER;
BEGIN
    pass := TRUE;
    dict := Dictionary.New();
    FOR i := 1 TO 5 DO Dictionary.Put(dict, i, NewTestItem(i * 10)) END;
    IF Dictionary.Count(dict) # 5 THEN pass := FALSE END;
    IF Dictionary.IsEmpty(dict) THEN pass := FALSE END;
    Dictionary.Clear(dict);
    IF Dictionary.Count(dict) # 0 THEN pass := FALSE END;
    IF ~Dictionary.IsEmpty(dict) THEN pass := FALSE END;
    FOR i := 1 TO 5 DO
        found := Dictionary.Get(dict, i, value);
        IF found OR (value # NIL) THEN pass := FALSE END
    END;
    Dictionary.Put(dict, 42, NewTestItem(123));
    IF Dictionary.Count(dict) # 1 THEN pass := FALSE END;
    found := Dictionary.Get(dict, 42, value);
    IF ~found OR (value = NIL) THEN pass := FALSE END;
    IF value(TestItemPtr).value # 123 THEN pass := FALSE END;
    Dictionary.Clear(dict);
    IF Dictionary.Count(dict) # 0 THEN pass := FALSE END;
    IF ~Dictionary.IsEmpty(dict) THEN pass := FALSE END;
    Dictionary.Free(dict);
    RETURN pass
END TestClear;

(* String key tests *)
PROCEDURE TestStringKeys*(): BOOLEAN;
VAR dict: Dictionary.Dictionary; value: Collections.ItemPtr; item: TestItemPtr; success: BOOLEAN; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dict := Dictionary.NewStringDict();
    Tests.ExpectedInt(0, Dictionary.Count(dict), "New string dict should be empty", pass);
    Tests.ExpectedBool(TRUE, Dictionary.IsEmpty(dict), "New string dict should report as empty", pass);
    item := NewTestItem(42);
    Dictionary.PutString(dict, "hello", item);
    item := NewTestItem(100);
    Dictionary.PutString(dict, "world", item);
    item := NewTestItem(7);
    Dictionary.PutString(dict, "test", item);
    Tests.ExpectedInt(3, Dictionary.Count(dict), "String dict should contain 3 items", pass);
    success := Dictionary.GetString(dict, "hello", value);
    Tests.ExpectedBool(TRUE, success, "Should find 'hello' key", pass);
    IF success THEN
        item := value(TestItemPtr);
        Tests.ExpectedInt(42, item.value, "'hello' should map to 42", pass)
    END;
    success := Dictionary.GetString(dict, "world", value);
    Tests.ExpectedBool(TRUE, success, "Should find 'world' key", pass);
    IF success THEN
        item := value(TestItemPtr);
        Tests.ExpectedInt(100, item.value, "'world' should map to 100", pass)
    END;
    Tests.ExpectedBool(TRUE, Dictionary.ContainsString(dict, "test"), "Should contain 'test' key", pass);
    Tests.ExpectedBool(FALSE, Dictionary.ContainsString(dict, "missing"), "Should not contain 'missing' key", pass);
    item := NewTestItem(999);
    Dictionary.PutString(dict, "hello", item);
    success := Dictionary.GetString(dict, "hello", value);
    Tests.ExpectedBool(TRUE, success, "Should still find 'hello' key after update", pass);
    IF success THEN
        item := value(TestItemPtr);
        Tests.ExpectedInt(999, item.value, "'hello' should now map to 999", pass)
    END;
    Tests.ExpectedInt(3, Dictionary.Count(dict), "Count should still be 3 after update", pass);
    success := Dictionary.RemoveString(dict, "world");
    Tests.ExpectedBool(TRUE, success, "Should successfully remove 'world' key", pass);
    Tests.ExpectedBool(FALSE, Dictionary.ContainsString(dict, "world"), "Should not contain 'world' key after removal", pass);
    Tests.ExpectedInt(2, Dictionary.Count(dict), "Count should be 2 after removal", pass);
    success := Dictionary.RemoveString(dict, "missing");
    Tests.ExpectedBool(FALSE, success, "Should not successfully remove non-existent key", pass);
    Dictionary.Free(dict);
    RETURN pass
END TestStringKeys;

PROCEDURE TestStringForeach*(): BOOLEAN;
VAR dict: Dictionary.Dictionary; item1, item2, item3: TestItemPtr; state: TestVisitorState; pass: BOOLEAN;
BEGIN
    pass := TRUE;
    dict := Dictionary.NewStringDict();
    item1 := NewTestItem(10);
    item2 := NewTestItem(20);
    item3 := NewTestItem(30);
    Dictionary.PutString(dict, "first", item1);
    Dictionary.PutString(dict, "second", item2);
    Dictionary.PutString(dict, "third", item3);
    state.sum := 0;
    state.count := 0;
    Dictionary.ForeachString(dict, StringKeyVisitor, state);
    Tests.ExpectedInt(60, state.sum, "Sum of values should be 60", pass);
    Tests.ExpectedInt(3, state.count, "Should visit 3 items", pass);
    Dictionary.Free(dict);
    RETURN pass
END TestStringForeach;

BEGIN
    Tests.Init(ts, "Dictionary Tests");
    Tests.Add(ts, TestNewAndFree);
    Tests.Add(ts, TestPutAndGet);
    Tests.Add(ts, TestUpdateExistingKey);
    Tests.Add(ts, TestContains);
    Tests.Add(ts, TestRemove);
    Tests.Add(ts, TestForeach);
    Tests.Add(ts, TestClear);
    Tests.Add(ts, TestStringKeys);
    Tests.Add(ts, TestStringForeach);
    ASSERT(Tests.Run(ts))
END DictionaryTest.
