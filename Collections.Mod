(** Collections.mod - Base types for collection implementations.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE Collections;

(** 
  This module provides base types for the collection implementations.
  Types using the collections should extend these.
 *)

  TYPE
    Item* = RECORD
      (** Minimal universal base type *)
    END;
    ItemPtr* = POINTER TO Item;

    (** General visitor state, extend as needed. *)
    VisitorState* = RECORD END; 
    (* External iterator for the Collections supporting ForEach *)
    VisitProc* = PROCEDURE(item: ItemPtr; VAR state: VisitorState): BOOLEAN;

END Collections.