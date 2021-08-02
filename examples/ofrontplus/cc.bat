@ECHO OFF
IF NOT "%XDev%"=="" SET PATH=%XDev%\WinDev\Bin\MinGW\bin
IF EXIST Obj CD Obj

SET CC=gcc.exe -m32 -fPIC -Os -g0 -fno-exceptions -ffunction-sections -c
SET AR=ar.exe -rc ..\Artemis.a
IF EXIST ..\Artemis.a DEL ..\Artemis.a

%CC% Tests.c ^
  Chars.c DStrings.c Obn2.c Path.c PathLists.c ^
  CharsTest.c DStringsTest.c Obn2Test.c PathTest.c PathListsTest.c
IF errorlevel 1 PAUSE

%AR% Tests.o ^
  Chars.o DStrings.o Obn2.o Path.o PathLists.o ^
  CharsTest.o DStringsTest.o Obn2Test.o PathTest.o PathListsTest.o

DEL /Q *.o
