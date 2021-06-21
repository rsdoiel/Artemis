(* ETH Oberon, Copyright 1990-2003 Computer Systems Institute, ETH Zurich, CH-8092 Zurich.
Refer to the license.txt file provided with this distribution. *)

MODULE Files;	(* pjm *)

(* Native-compatible Files module based on OFS *)

IMPORT SYSTEM, OFS;

TYPE
	File* = OFS.File;
	Rider* = OFS.Rider;

	Bytes4 = ARRAY 4 OF SYSTEM.BYTE;
	Bytes8 = ARRAY 8 OF SYSTEM.BYTE;

(** Creates a new file with the specified name. *)
PROCEDURE New*(name: ARRAY OF CHAR): File;
BEGIN
	RETURN OFS.New(name)
END New;

(** Open an existing file. The same file descriptor is returned if a file is opened multiple times. *)
PROCEDURE Old*(name: ARRAY OF CHAR): File;
BEGIN
	RETURN OFS.Old(name)
END Old;

(** Register a file created with New in the directory, replacing the previous file in the 
directory with the same name. The file is automatically closed. *)
PROCEDURE Register*(f: File);
BEGIN
	OFS.Register(f)
END Register;

(** Flushes the changes made to a file to disk. Register will automatically Close a file. *)
PROCEDURE Close*(f: File);
BEGIN
	IF f # NIL THEN f.fs.Close(f) END
END Close;

(** Returns the current length of a file. *)
PROCEDURE Length*(f: File): LONGINT;
BEGIN
	RETURN f.fs.Length(f)
END Length;

(** Returns the time (t) and date (d) when a file was last modified. *)
PROCEDURE GetDate*(f: File; VAR t, d: LONGINT);
BEGIN
	f.fs.GetDate(f, t,d)
END GetDate;

(** Sets the modification time (t) and date (d) of a file. *)
PROCEDURE SetDate*(f: File; t, d: LONGINT);
BEGIN
	f.fs.SetDate(f, t,d)
END SetDate;

(** Positions a Rider at a certain position in a file. Multiple Riders can be positioned 
at different locations in a file. A Rider cannot be positioned beyond the end of a file. *)
PROCEDURE Set*(VAR r: Rider; f: File; pos: LONGINT);
BEGIN
	IF f # NIL THEN f.fs.Set(r, f, pos)
	ELSE r.hint := NIL; r.file := NIL; r.fs := NIL
	END
END Set;

(** Returns the offset of a Rider positioned on a file. *)
PROCEDURE Pos*(VAR r: Rider): LONGINT;
BEGIN
	RETURN r.fs.Pos(r)
END Pos;

(** Returns the File a Rider is based on. *)
PROCEDURE Base*(VAR r: Rider): File;
BEGIN
	RETURN r.file
END Base;

(** Read a byte from a file, advancing the Rider one byte further. R.eof indicates if the end 
of the file has been passed. *)
PROCEDURE Read*(VAR r: Rider; VAR x: SYSTEM.BYTE);
BEGIN
	r.fs.Read(r, x)
END Read;

(** Reads a sequence of length n bytes into the buffer x, advancing the Rider. Less bytes 
will be read when reading over the length of the file. r.res indicates the number of unread bytes. 
x must be big enough to hold n bytes. *)
PROCEDURE ReadBytes*(VAR r: Rider; VAR x: ARRAY OF SYSTEM.BYTE; n: LONGINT);
BEGIN
	r.fs.ReadBytes(r, x, n)
END ReadBytes;

(**
Portable routines to read the standard Oberon types.
*)

PROCEDURE ReadInt*(VAR r: Rider; VAR x: INTEGER);
VAR x0, x1: SHORTINT;
BEGIN
	r.fs.Read(r, x0); r.fs.Read(r, x1);
	x := LONG(x1) * 100H + LONG(x0) MOD 100H
END ReadInt;

PROCEDURE ReadLInt*(VAR r: Rider; VAR x: LONGINT);
BEGIN
	r.fs.ReadBytes(r, SYSTEM.VAL(Bytes4, x), 4)
END ReadLInt;

PROCEDURE ReadSet*(VAR r: Rider; VAR x: SET);
BEGIN
	r.fs.ReadBytes(r, SYSTEM.VAL(Bytes4, x), 4)
END ReadSet;

PROCEDURE ReadBool*(VAR r: Rider; VAR x: BOOLEAN);
VAR s: SHORTINT;
BEGIN
	r.fs.Read(r, s); x := s # 0
END ReadBool;

PROCEDURE ReadReal*(VAR r: Rider; VAR x: REAL);
BEGIN
	r.fs.ReadBytes(r, SYSTEM.VAL(Bytes4, x), 4)
END ReadReal;

PROCEDURE ReadLReal*(VAR r: Rider; VAR x: LONGREAL);
BEGIN
	r.fs.ReadBytes(r, SYSTEM.VAL(Bytes8, x), 8)
END ReadLReal;

PROCEDURE ReadString*(VAR r: Rider; VAR x: ARRAY OF CHAR);
VAR i: INTEGER; ch: CHAR;
BEGIN i := 0;
	LOOP
		r.fs.Read(r, ch); x[i] := ch; INC(i);
		IF ch = 0X THEN EXIT END;
		IF i = LEN(x) THEN x[i-1] := 0X;
			REPEAT r.fs.Read(r, ch) UNTIL ch = 0X;
			EXIT
		END
	END
END ReadString;

(** Reads a number in compressed variable length notation using the minimum amount of bytes. *)
PROCEDURE ReadNum*(VAR r: Rider; VAR x: LONGINT);
VAR ch: CHAR; n: INTEGER; y: LONGINT;
BEGIN
	n := 0; y := 0; r.fs.Read(r, ch);
	WHILE ch >= 80X DO INC(y, SYSTEM.LSH(LONG(ch) - 128, n)); INC(n, 7); r.fs.Read(r, ch) END;
	x := ASH(SYSTEM.LSH(LONG(ch), 25), n-25) + y
END ReadNum;

(** Writes a byte into the file at the Rider position, advancing the Rider by one. *)
PROCEDURE Write*(VAR r: Rider; x: SYSTEM.BYTE);
BEGIN
	r.fs.Write(r, x)
END Write;

(** Writes the buffer x containing n bytes into a file at the Rider position. *)
PROCEDURE WriteBytes*(VAR r: Rider; VAR x: ARRAY OF SYSTEM.BYTE; n: LONGINT);
BEGIN
	r.fs.WriteBytes(r, x, n)
END WriteBytes;

(**
Portable routines to write the standard Oberon types.
*)

PROCEDURE WriteInt*(VAR r: Rider; x: INTEGER);
BEGIN
	r.fs.Write(r, SHORT(x)); r.fs.Write(r, SHORT(x DIV 100H))
END WriteInt;

PROCEDURE WriteLInt*(VAR r: Rider; x: LONGINT);
BEGIN
	r.fs.WriteBytes(r, SYSTEM.VAL(Bytes4, x), 4)
END WriteLInt;

PROCEDURE WriteSet*(VAR r: Rider; x: SET);
BEGIN
	r.fs.WriteBytes(r, SYSTEM.VAL(Bytes4, x), 4)
END WriteSet;

PROCEDURE WriteBool*(VAR r: Rider; x: BOOLEAN);
BEGIN
	IF x THEN r.fs.Write(r, 1) ELSE r.fs.Write(r, 0) END
END WriteBool;

PROCEDURE WriteReal*(VAR r: Rider; x: REAL);
BEGIN
	r.fs.WriteBytes(r, SYSTEM.VAL(Bytes4, x), 4)
END WriteReal;

PROCEDURE WriteLReal*(VAR r: Rider; x: LONGREAL);
BEGIN
	r.fs.WriteBytes(r, SYSTEM.VAL(Bytes8, x), 8)
END WriteLReal;

PROCEDURE WriteString*(VAR r: Rider; x: ARRAY OF CHAR);
VAR i: INTEGER; ch: CHAR;
BEGIN
	i := 0;
	LOOP ch := x[i]; r.fs.Write(r, ch); INC(i);
		IF ch = 0X THEN EXIT END;
		IF i = LEN(x) THEN r.fs.Write(r, 0X); EXIT END
	END
END WriteString;

(** Writes a number in a compressed format. *)
PROCEDURE WriteNum*(VAR r: Rider; x: LONGINT);
BEGIN
	WHILE (x < - 64) OR (x > 63) DO r.fs.Write(r, CHR(x MOD 128 + 128)); x := x DIV 128 END;
	r.fs.Write(r, CHR(x MOD 128))
END WriteNum;

(** Deletes a file. res = 0 indicates success. *)
PROCEDURE Delete*(name: ARRAY OF CHAR; VAR res: INTEGER);
BEGIN
	OFS.Delete(name, res)
END Delete;

(** Renames a file. res = 0 indicates success. *)
PROCEDURE Rename*(old, new: ARRAY OF CHAR; VAR res: INTEGER);
BEGIN
	OFS.Rename(old, new, res)
END Rename;

(** Returns the full name of a file. *)
PROCEDURE GetName*(f: File; VAR name: ARRAY OF CHAR);
VAR fname: OFS.LocalName;
BEGIN
	f.fs.GetName(f, fname);
	OFS.JoinName(f.fs.prefix, fname, name)
END GetName;

END Files.

(** Remarks:

1. Oberon uses the little-endian byte ordering for exchanging files between different Oberon platforms.

2. Files are separate entities from directory entries. Files may be anonymous by having no name and not being registered in a
	directory. Files only become visible to other clients of the Files module by explicitly passing a File descriptor or by registering
	a file and then opening it from the other client. Deleting a file of which a file descriptor is still available, results in the file
	becoming anonymous. The deleted file may be re-registered at any time.

3. Files and their access mechanism (Riders) are separated. A file might have more than one rider operating on it at different
	offsets in the file.

4. The garbage collector will automatically close files when they are not required any more. File buffers will be discarded
	without flushing them to disk.  Use the Close procedure to update modified files on disk.

5. Relative and absolute filenames written in the directory syntax of the host operating system are used. By convention, Oberon
	filenames consists of the letters A..Z, a..z, 0..9, and ".". The directory separator is typically / or :. Oberon filenames are
	case sensitive. *)

