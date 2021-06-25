---
title: Ports, from Oberon-2 to Oberon-07
---

Oberon-2 to Oberon-07
=====================

In approaching bringing the full range of historic Oberon-2 modules
to Oberon-07 I found it useful to have a rather systematic approach.

Steps
-----

1. Review Oberon-2 code and flag (via comments)
    a. LOOP/EXIT replaced with WHILE, WHILE/ELSE, REPEAT/UNTIL, FOR/DO
    b. Convert RETURN to a single RETURN at end of functional procedure
    c. Refactor CASE is not used as a type guard
    d. Refactor any forward references
2. Refactor LOOP 
3. Refactor CASE statement
4. Refactor RETURN clauses
5. Refactor any forward references
6. Review and replace use of LONGINT, SHORTINT, LONGREAL
7. Update IMPORT, replace missing built-in with Obn2 equivalent


Review code and flag issues
---------------------------

Refactor LOOPS
--------------

Oberon-07 does away with LOOP while it does allow a WHILE with
an ELSE.  REPEAT/UNTIL and FOR are also available.

Refactor CASE
-------------

Refactor RETURN
---------------

Refactor forward references
---------------------------

Update IMPORT
-------------

Add `Obn2` to IMPORT line.  Replace missing Oberon-2 built-ins with
the `Obn2` equivallent.

Update SHORTINT, LONGINT, LONGREAL
----------------------------------



