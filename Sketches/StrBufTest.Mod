(** StringTestBuffer.Mod implements tests for the StrBuf Module.

Copyright (C) 2021 R. S. Doiel <rsdoiel@gmail.com> This Source Code Form is subject to the terms of the Mozilla PublicLicense, v. 2.0. If a copy of the MPL was not distributed with thisfile, You can obtain one at http://mozilla.org/MPL/2.0/. *)
MODULE StrBufTest;

IMPORT T := Tests;

VAR 
  title : ARRAY 1024 OF CHAR;
  success, errors : INTEGER;

PROCEDURE TestReadProcs() : BOOLEAN;
  VAR test : BOOLEAN;
BEGIN test := TRUE;
  T.ExpectedBool(FALSE, test, "TestReadProcs() not implemented.", test);
  RETURN test
END TestReadProcs;

PROCEDURE TestWriteProcs() : BOOLEAN;
  VAR test : BOOLEAN;
BEGIN test := TRUE;
  T.ExpectedBool(FALSE, test, "TestWriteProcs() not implemented.", test);
  RETURN test
END TestWriteProcs;

BEGIN
  title := "StrBuf";
  success := 0;
  errors := 0;
  T.ShowTitle(title);
  T.Test(TestReadProcs, success, errors);
  T.Test(TestWriteProcs, success, errors);
  T.Summarize(title, success, errors);
END StrBufTest.

StrBufTest
================

Tests the StrBuf module.

