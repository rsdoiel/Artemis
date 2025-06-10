(* CollectionWrappers.Mod - Wrappers for storing collections as generic items

Copyright (C) 2025

Released under The 3-Clause BSD License.
Author: Artemis Project
*)

MODULE CollectionWrappers;

IMPORT Collections, Dictionary;

TYPE
    (** Wrapper for Dictionary.Dictionary as a Collections.Item *)
    DictionaryWrapper* = RECORD(Collections.Item)
        dict*: Dictionary.Dictionary
    END;
    DictionaryWrapperPtr* = POINTER TO DictionaryWrapper;

(** Create a new dictionary wrapper *)
PROCEDURE NewDictionaryWrapper*(dict: Dictionary.Dictionary): Collections.ItemPtr;
VAR wrapper: DictionaryWrapperPtr; result: Collections.ItemPtr;
BEGIN
    NEW(wrapper);
    wrapper.dict := dict;
    result := wrapper;
    RETURN result
END NewDictionaryWrapper;

END CollectionWrappers.
