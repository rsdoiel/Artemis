@ECHO OFF
IF EXIST Obj CD Obj
SET PATH=..\..\..\Target\Win32;%PATH%
SET OBERON=.;..\Mod
IF EXIST *.sym DEL *.sym >NUL

ofront+ -s7 -48 ^
  Math.Def Out.Def Strings.Def extConvert.Def Tests.Mod ^
  Chars.Mod DStrings.Mod Obn2.Mod Path.Mod PathLists.Mod ^
  CharsTest.Mod DStringsTest.Mod Obn2Test.Mod PathTest.Mod PathListsTest.Mod
IF errorlevel 1 PAUSE

FOR %%i IN (*.sym) DO MOVE /Y %%i ..\Sym >NUL
CD ..
