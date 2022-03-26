MODULE JSON;

IMPORT Chars;

CONST
  NullType* = 0;
  BooleanType* = 1;
  NumberType* = 2;
  StringType* = 3;
  ArrayType* = 4;
  ObjectType* = 5;

TYPE
   (* Self services as an interface to JSON types,
      all JSON types extend it. *)
   Self* = RECORD 
            type: INTEGER
          END;

   Boolean* = POINTER TO BooleanDesc;
   BooleanDesc = RECORD (Self)
                   value: BOOLEAN
                 END;

   Number* = POINTER TO NumberDesc;
   NumberDesc* = RECORD (Self)
                   value : REAL;
                   NaN : BOOLEAN
                 END;

  String* = POINTER TO StringDesc;
  StringDesc* = RECORD (Self)
                  value : CHAR;
                  next : String
                END;

  List* = POINTER TO ListDesc;
  ListDesc* = RECORD (Self)
                value : Self;
                next: List
              END;

  Object* = POINTER TO ObjectDesc;
  ObjectDesc* = RECORD (Self)
                  key : String;
                  value: Self;
                  next : Object
                END;

(* Base methods available to all JSON types via Self type definition *)
PROCEDURE IsNull*(o : Self) : BOOLEAN;
BEGIN
  RETURN (o.type = NullType)
END IsNull;

(* IsType compares a JSON object agaist a type constant. Returns TRUE
   if they match or FALSE otherwise *)
PROCEDURE IsType*(o : Self; checkType : INTEGER) : BOOLEAN;
  RETURN (o.type = checkType)
END IsType;

(* TypeName exams a type setting the value of the typeName array of char *)
PROCEDURE TypeName*(o : Self; VAR typeName : ARRAY OF CHAR);
BEGIN
  Chars.Clear(typeName);
  IF o.type = NullType THEN
    typeName := "null";
  ELSIF o.type = BooleanType THEN
    typeName := "boolean";
  ELSIF o.type = NumberType THEN
    typeName := "number";
  ELSIF o.type = StringType THEN
    typeName := "string";
  ELSIF o.type = ArrayType THEN
    typeName := "array";
  ELSIF o.type = ObjectType THEN
    typeName := "object";
  ELSE
    typeName := "undefined";
  END;
END TypeName;

END JSON.
