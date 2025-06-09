(** ExampleDictionary.Mod - Demonstrates using Dictionary for key-value storage.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE ExampleDictionary;

IMPORT Dictionary, Collections, Strings, Out;

TYPE
    PersonInfo = RECORD(Collections.Item)
        name: ARRAY 64 OF CHAR;
        age: INTEGER
    END;
    PersonInfoPtr = POINTER TO PersonInfo;

VAR
    intDict, stringDict: Dictionary.Dictionary;
    person: PersonInfoPtr;
    value: Collections.ItemPtr;
    found: BOOLEAN;

(** Create a new person info record *)
PROCEDURE NewPersonInfo(name: ARRAY OF CHAR; age: INTEGER): PersonInfoPtr;
VAR p: PersonInfoPtr;
BEGIN
    NEW(p);
    p.name[0] := 0X; (* Initialize as empty string *)
    Strings.Append(name, p.name);
    p.age := age;
    RETURN p
END NewPersonInfo;

BEGIN
    Out.String("=== Dictionary Example ==="); Out.Ln; Out.Ln;
    
    (* Create dictionaries *)
    intDict := Dictionary.New();
    stringDict := Dictionary.NewStringDict();
    
    (* Add some people using integer keys *)
    Out.String("Adding people with integer keys:"); Out.Ln;
    person := NewPersonInfo("Alice", 30);
    Dictionary.Put(intDict, 1001, person);
    Out.String("  ID 1001: Alice, Age 30"); Out.Ln;
    
    person := NewPersonInfo("Bob", 25);
    Dictionary.Put(intDict, 1002, person);
    Out.String("  ID 1002: Bob, Age 25"); Out.Ln;
    
    person := NewPersonInfo("Charlie", 35);
    Dictionary.Put(intDict, 1003, person);
    Out.String("  ID 1003: Charlie, Age 35"); Out.Ln;
    
    Out.Ln;
    Out.String("Integer dictionary count: ");
    Out.Int(Dictionary.Count(intDict), 0); Out.Ln;
    
    (* Add some people using string keys *)
    Out.Ln; Out.String("Adding people with string keys:"); Out.Ln;
    person := NewPersonInfo("Diana", 28);
    Dictionary.PutString(stringDict, "manager", person);
    Out.String("  Role 'manager': Diana, Age 28"); Out.Ln;
    
    person := NewPersonInfo("Eve", 32);
    Dictionary.PutString(stringDict, "developer", person);
    Out.String("  Role 'developer': Eve, Age 32"); Out.Ln;
    
    person := NewPersonInfo("Frank", 45);
    Dictionary.PutString(stringDict, "director", person);
    Out.String("  Role 'director': Frank, Age 45"); Out.Ln;
    
    Out.Ln;
    Out.String("String dictionary count: ");
    Out.Int(Dictionary.Count(stringDict), 0); Out.Ln;
    
    (* Lookup examples *)
    Out.Ln; Out.String("=== Lookup Examples ==="); Out.Ln;
    
    (* Integer key lookup *)
    found := Dictionary.Get(intDict, 1002, value);
    IF found THEN
        person := value(PersonInfoPtr);
        Out.String("Found ID 1002: ");
        Out.String(person.name);
        Out.String(", Age ");
        Out.Int(person.age, 0); Out.Ln
    ELSE
        Out.String("ID 1002 not found"); Out.Ln
    END;
    
    (* String key lookup *)
    found := Dictionary.GetString(stringDict, "developer", value);
    IF found THEN
        person := value(PersonInfoPtr);
        Out.String("Found role 'developer': ");
        Out.String(person.name);
        Out.String(", Age ");
        Out.Int(person.age, 0); Out.Ln
    ELSE
        Out.String("Role 'developer' not found"); Out.Ln
    END;
    
    (* Test non-existent keys *)
    Out.Ln; Out.String("Testing non-existent keys:"); Out.Ln;
    found := Dictionary.Get(intDict, 9999, value);
    Out.String("ID 9999 exists: ");
    IF found THEN Out.String("TRUE") ELSE Out.String("FALSE") END;
    Out.Ln;
    
    found := Dictionary.ContainsString(stringDict, "intern");
    Out.String("Role 'intern' exists: ");
    IF found THEN Out.String("TRUE") ELSE Out.String("FALSE") END;
    Out.Ln;
    
    (* Update example *)
    Out.Ln; Out.String("=== Update Example ==="); Out.Ln;
    person := NewPersonInfo("Alice Smith", 31);
    Dictionary.Put(intDict, 1001, person);  (* Update Alice's info *)
    
    found := Dictionary.Get(intDict, 1001, value);
    IF found THEN
        person := value(PersonInfoPtr);
        Out.String("Updated ID 1001: ");
        Out.String(person.name);
        Out.String(", Age ");
        Out.Int(person.age, 0); Out.Ln
    END;
    
    (* Remove example *)
    Out.Ln; Out.String("=== Remove Example ==="); Out.Ln;
    Out.String("Count before removal: ");
    Out.Int(Dictionary.Count(stringDict), 0); Out.Ln;
    
    found := Dictionary.RemoveString(stringDict, "manager");
    Out.String("Removed 'manager': ");
    IF found THEN Out.String("SUCCESS") ELSE Out.String("FAILED") END;
    Out.Ln;
    
    Out.String("Count after removal: ");
    Out.Int(Dictionary.Count(stringDict), 0); Out.Ln;
    
    (* Clear example *)
    Out.Ln; Out.String("=== Clear Example ==="); Out.Ln;
    Out.String("Integer dict count before clear: ");
    Out.Int(Dictionary.Count(intDict), 0); Out.Ln;
    
    Dictionary.Clear(intDict);
    
    Out.String("Integer dict count after clear: ");
    Out.Int(Dictionary.Count(intDict), 0); Out.Ln;
    Out.String("Is empty: ");
    IF Dictionary.IsEmpty(intDict) THEN Out.String("TRUE") ELSE Out.String("FALSE") END;
    Out.Ln;
    
    (* Clean up *)
    Dictionary.Free(intDict);
    Dictionary.Free(stringDict);
    
    Out.Ln; Out.String("=== Dictionary Example Complete ==="); Out.Ln
END ExampleDictionary.
