@REM make.bat is a simple DOS batch file for building Artemis project under Windows 11.

@echo Removing stale executables.
@del *.exe

@echo Compiling CharsTest.Mod
call obnc CharsTest.Mod
@echo Compiling DStringsTest.Mod
call obnc DStringsTest.Mod
@echo Compiling JSONTest.Mod
call obnc JSONTest.Mod
@echo Compiling Obn2Test.Mod
call obnc Obn2Test.Mod
@echo Compiling PathListsTest.Mod
call obnc PathListsTest.Mod
@echo Compiling PathTest.Mod
call obnc PathTest.Mod
@echo Compiling ScannerTest.Mod
call obnc ScannerTest.Mod

@echo Running each test.
CharsTest.exe
DStringsTest.exe
JSONTest.exe
Obn2Test.exe
PathListsTest.exe
PathTest.exe
ScannerTest.exe
