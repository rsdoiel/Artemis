(* ETH Oberon, Copyright 1990-2003 Computer Systems Institute, ETH Zurich, CH-8092 Zurich.
Refer to the license.txt file provided with this distribution. *)

MODULE OFS;	(** non-portable *)	(* pjm/bsm/be *)

(* Oberon file system base - Support for file system and volume implementations. *)

IMPORT SYSTEM, Kernel;

CONST
	ReadOnly* = 0; Removable* = 1; Boot* = 2;	(** Volume property flags *)
	
		(** Enumerate flags supported by OFS. *)
	EnumSize* = 0;	(** enable size parameter of EntryHandler. *)
	EnumTime* = 1;	(** enable time and data parameters of EntryHandler. *)
	EnumRecursive* = 2;	(** enumerate recursively into subdirectories. *)
	EnumStop* = 15;	(** stop enumeration (can be set in EntryHandler). *)
	EnumUserMin* = 16;	(** flags from EnumUserMin..EnumUserMax can be used by OFS clients. *)
	EnumUserMax* = 31;

		(** return values for a FileSystem's handler procedure *)
	Ok* = 0;
	Unsupported* = -1;

	Reserved = 32;		(* Blocks reserved for system on Boot volumes *)

	PreLength = 16;
	LocalLength = 128;
	FileNameLength = PreLength + LocalLength;
	
	Trace = FALSE;

TYPE
(** All record fields are read-only for users, and read-write for extenders. *)

	Address* = LONGINT;	(** Volume block address [1..size] *)
	
(** Volume is the base type of all volumes.  It provides operations on an abstract array of file system data blocks of blockSize bytes, numbered from 1 to size. *)

	AllocProc* = PROCEDURE (vol: Volume; hint: Address; VAR adr: Address);
	FreeMarkProc* = PROCEDURE (vol: Volume; adr: Address);
	MarkedProc* = PROCEDURE (vol: Volume; adr: Address): BOOLEAN;
	AvailableProc* = PROCEDURE (vol: Volume): LONGINT;
	GetPutProc* = PROCEDURE (vol: Volume; adr: Address; VAR blk: ARRAY OF SYSTEM.BYTE);
	FinalizeVolProc* = PROCEDURE (vol: Volume);
	SyncProc* = PROCEDURE(vol: Volume);

	Volume* = POINTER TO RECORD
		map: POINTER TO ARRAY OF SET;	(* Block allocation table *)
		used: LONGINT;	(* used blocks *)
		
		name*: ARRAY 32 OF CHAR;	(** descriptive name - e.g. for matching with Partitions.Show *)
		blockSize*: LONGINT;	(** block size in bytes *)
		size*: LONGINT;	(** size in blocks *)
		flags*: SET;	(** ReadOnly, Removable, Boot *)
		
		AllocBlock*: AllocProc;
		FreeBlock*, MarkBlock*: FreeMarkProc;
		Marked*: MarkedProc;
		Available*: AvailableProc;
		GetBlock*, PutBlock*: GetPutProc;
		Finalize*: FinalizeVolProc;
		Sync*: SyncProc;
	END;

	Prefix* = ARRAY PreLength OF CHAR;
	LocalName* = ARRAY LocalLength OF CHAR;
	FileName* = ARRAY FileNameLength OF CHAR;
	
	FileSystem* = POINTER TO FileSystemDesc;
	File* = POINTER TO FileDesc;
	Hint* = POINTER TO HintDesc;
	
	Rider* = RECORD
		eof*: BOOLEAN;	(** has end of file been passed *)
		res*: LONGINT;	(** leftover byte count for ReadBytes/WriteBytes *)
			(** private fields for implementors *)
		apos*, bpos*: LONGINT;
		hint*: Hint;
		file*: File;
		fs*: FileSystem
	END;
	
	FileDesc* = RECORD
		next[UNTRACED]: File;	(* list of all files, for garbage collection *)
			(** private fields for implementors *)
		key*: LONGINT;	(* unique id for registered file, never 0 *)
		fs*: FileSystem	(* file system containing file *)
	END;
	
	EntryHandler* = PROCEDURE (name: ARRAY OF CHAR; time, date, size: LONGINT; VAR flags: SET);

	FileKeyProc* = PROCEDURE (fs: FileSystem; name: ARRAY OF CHAR): LONGINT;
	NewOldProc* = PROCEDURE (fs: FileSystem; name: ARRAY OF CHAR): File;
	DeleteProc* = PROCEDURE (fs: FileSystem; name: ARRAY OF CHAR; VAR key: LONGINT; VAR res: INTEGER);
	RenameProc* = PROCEDURE (fs: FileSystem; old, new: ARRAY OF CHAR; VAR res: INTEGER);
	EnumerateProc* = PROCEDURE (fs: FileSystem; mask: ARRAY OF CHAR; VAR flags: SET; handler: EntryHandler);
	CloseProc* = PROCEDURE (f: File);
	RegisterProc* = PROCEDURE (f: File; VAR res: INTEGER);
	LengthProc* = PROCEDURE (f: File): LONGINT;
	GetDateProc* = PROCEDURE (f: File; VAR t, d: LONGINT);
	SetDateProc* = PROCEDURE (f: File; t, d: LONGINT);
	GetNameProc* = PROCEDURE (f: File; VAR name: ARRAY OF CHAR);
	SetProc* = PROCEDURE (VAR r: Rider; f: File; pos: LONGINT);
	PosProc* = PROCEDURE (VAR r: Rider): LONGINT;
	ReadProc* = PROCEDURE (VAR r: Rider; VAR x: SYSTEM.BYTE);
	WriteProc* = PROCEDURE (VAR r: Rider; x: SYSTEM.BYTE);
	ReadWriteBytesProc* = PROCEDURE (VAR r: Rider; VAR x: ARRAY OF SYSTEM.BYTE; n: LONGINT);
	FinalizeFSProc* = PROCEDURE (fs: FileSystem);
	PurgeProc* = PROCEDURE (fs: FileSystem; f: File);
	RegisteredProc* = PROCEDURE (fs: FileSystem; f: File): BOOLEAN;
	
	Message* = RECORD END;
	HandleProc* = PROCEDURE (fs: FileSystem; VAR msg: Message; VAR res: LONGINT);
	
	FileSystemDesc* = RECORD
		next: FileSystem;	(* file system search path *)
		link: FileSystem;	(* list of mounted file systems *)
		prefix*: Prefix;	(** mount prefix *)
		desc*: ARRAY 32 OF CHAR;	(** description of file system *)
		vol*: Volume;	(** underlying volume, if any (a boot FS must have a volume) *)
		FileKey*: FileKeyProc;
		New*, Old*: NewOldProc;
		Delete*: DeleteProc;
		Rename*: RenameProc;
		Enumerate*: EnumerateProc;
		Close*: CloseProc;
		Register*: RegisterProc;
		Length*: LengthProc;
		GetDate*: GetDateProc;
		SetDate*: SetDateProc;
		GetName*: GetNameProc;
		Set*: SetProc;
		Pos*: PosProc;
		Read*: ReadProc;
		Write*: WriteProc;
		ReadBytes*, WriteBytes*: ReadWriteBytesProc;
		Finalize*: FinalizeFSProc;
		Handle*: HandleProc;
		Purge*: PurgeProc;
		Registered*: RegisteredProc
	END;
	
	HintDesc* = RECORD END;
	
VAR
	par: ARRAY 256 OF CHAR;	(* Parameters for volume generators *)
	pos: LONGINT;	(* Read position within Par *)
	NewVol*: Volume;	(** Result of volume generators *)

	fsroot: FileSystem;	(* file system search path root *)
	fsmount: FileSystem;	(* list of known file systems *)
	froot: File;	(* list of known files, with dummy head *)

(** Predefined volume methods (need not be used). *)

PROCEDURE AllocBlock*(vol: Volume; hint: Address; VAR adr: Address);
BEGIN
	IF ReadOnly IN vol.flags THEN HALT(21) END;
	IF (Boot IN vol.flags) & (vol.size - vol.used <= Reserved) THEN HALT(20) END;
	ASSERT(hint >= 0);
	IF hint > vol.size THEN hint := 0 END;
	adr := hint+1;
	LOOP
		IF adr > vol.size THEN adr := 0 END;
		IF (adr MOD 32) IN vol.map[adr DIV 32] THEN
			INC(adr) (* Block in use *)
		ELSE
			INCL(vol.map[adr DIV 32], adr MOD 32);
			EXIT
		END;
		IF adr = hint THEN HALT(20) END
	END;
	INC(vol.used)
END AllocBlock;

PROCEDURE FreeBlock*(vol: Volume; adr: Address);
BEGIN
	IF (adr < 1) OR (adr > vol.size) THEN SYSTEM.HALT(15) END;
	IF ReadOnly IN vol.flags THEN HALT(21) END;
	EXCL(vol.map[adr DIV 32], adr MOD 32);
	DEC(vol.used)
END FreeBlock;

PROCEDURE MarkBlock*(vol: Volume; adr: Address);
BEGIN
	IF (adr < 1) OR (adr > vol.size) THEN SYSTEM.HALT(15) END;
	IF ReadOnly IN vol.flags THEN HALT(21) END;
	INCL(vol.map[adr DIV 32], adr MOD 32);
	INC(vol.used)
END MarkBlock;

PROCEDURE Marked*(vol: Volume; adr: Address): BOOLEAN;
BEGIN
	IF (adr < 1) OR (adr > vol.size) THEN SYSTEM.HALT(15) END;
	IF ReadOnly IN vol.flags THEN HALT(21) END;
	RETURN (adr MOD 32) IN vol.map[adr DIV 32]
END Marked;

PROCEDURE Available*(vol: Volume): LONGINT;
BEGIN
	RETURN vol.size-vol.used
END Available;

PROCEDURE Sync*(vol: Volume);
BEGIN
END Sync;

(** Init procedure for private data of above methods only.  vol.flags and vol.size must be set before. *)
PROCEDURE InitVol*(vol: Volume);
VAR maplen: LONGINT;
BEGIN
	IF ~(ReadOnly IN vol.flags) THEN
		maplen := (vol.size+1+31) DIV 32;
		NEW(vol.map, maplen);
		WHILE maplen > 0 DO DEC(maplen); vol.map[maplen] := {} END;
		INCL(vol.map[0], 0);	(* reserve sector 0 (illegal to use) *)
		vol.used := 0
	ELSE
		vol.used := vol.size
	END
END InitVol;

(** Finalize procedure for volumes. *)
PROCEDURE FinalizeVol*(vol: Volume);
BEGIN
	vol.map := NIL;
	vol.AllocBlock := NIL; vol.FreeBlock := NIL; vol.MarkBlock := NIL; vol.Marked := NIL;
	vol.Available := NIL; vol.GetBlock := NIL; vol.PutBlock := NIL; vol.Sync := NIL; 
	vol.Finalize := NIL
END FinalizeVol;

(** Command parameter support *)

(** Set parameter string for a volume generator *)
PROCEDURE SetPar*(str: ARRAY OF CHAR);
BEGIN
	COPY(str, par); pos := 0
END SetPar;

(** Read next character of parameter string. At the end (ch = 0X) the string is cleared *)
PROCEDURE ReadPar*(VAR ch: CHAR);
BEGIN
	ch := par[pos];
	IF ch = 0X THEN pos := 0; par[0] := 0X ELSE INC(pos) END
END ReadPar;

(** File name prefix support. *)

(** Split fullname = ( prefix ":" name ) into prefix and name *)
PROCEDURE SplitName*(fullname: ARRAY OF CHAR; VAR prefix, name: ARRAY OF CHAR);
VAR i, j: LONGINT;
BEGIN
	i := 0; WHILE (fullname[i] # ":") & (fullname[i] # 0X) DO INC(i) END;
	IF (fullname[i] # ":") OR (i >= LEN(prefix)) THEN
		COPY("", prefix); COPY(fullname, name);
	ELSE
		j := 0; WHILE j # i DO prefix[j] := fullname[j]; INC(j) END;
		prefix[j] := 0X;
		j := 0; REPEAT INC(i); name[j] := fullname[i]; INC(j) UNTIL fullname[i] = 0X
	END
END SplitName;

(** Join prefix and name to fullname = ( prefix ":" name ) *)
PROCEDURE JoinName*(prefix, name: ARRAY OF CHAR; VAR fullname: ARRAY OF CHAR);
VAR i, j: LONGINT;
BEGIN
	i := 0; WHILE prefix[i] # 0X DO fullname[i] := prefix[i]; INC(i) END;
	fullname[i] := ":"; INC(i);
	j := 0; WHILE name[j] # 0X DO fullname[i] := name[j]; INC(i); INC(j) END;
	fullname[i] := 0X
END JoinName;

(** File system list support. *)

PROCEDURE WriteFS(fs: FileSystem);
BEGIN
	IF Trace THEN
		IF fs.vol # NIL THEN Kernel.WriteString(fs.vol.name); Kernel.WriteChar(" ") END;
		Kernel.WriteString(fs.desc)
	END;
END WriteFS;

(** Add file system at end of list, with specified prefix, which must be unique. *)
PROCEDURE Add*(fs: FileSystem; prefix: ARRAY OF CHAR);
VAR p, c: FileSystem;
BEGIN
	IF Trace THEN
		Kernel.WriteString("OFS: Adding ");  WriteFS(fs);  Kernel.WriteLn
	END;
	COPY(prefix, fs.prefix);
	p := NIL; c := fsroot;
	WHILE c # NIL DO
		ASSERT((c # fs) & (c.prefix # fs.prefix));	(* duplicate insertion not allowed *)
		p := c; c := c.next
	END;
	IF p = NIL THEN fsroot := fs ELSE p.next := fs END;
	fs.next := NIL;
	fs.link := fsmount; fsmount := fs	(* push on mount list *)
END Add;

PROCEDURE DeleteFS(fs: FileSystem);
VAR p, c: FileSystem;
BEGIN
	p := NIL; c := fsroot;
	WHILE c # fs DO p := c; c := c.next END;	(* fs must be in list *)
	IF p = NIL THEN fsroot := c.next ELSE p.next := c.next END;
	c.next := NIL
END DeleteFS;

(** Promote fs to the start of the list. *)
PROCEDURE Promote*(fs: FileSystem);
BEGIN
	DeleteFS(fs); fs.next := fsroot; fsroot := fs
END Promote;

(** Remove the file system and finalize it. *)
PROCEDURE Remove*(fs: FileSystem);
VAR f: File; count: LONGINT; p, c: FileSystem;
BEGIN
	IF Trace THEN
		Kernel.WriteString("OFS: Removing ");  WriteFS(fs);  Kernel.WriteLn
	END;
	f := froot.next; count := 0;
	WHILE f # NIL DO
		IF f.fs = fs THEN INC(count); fs.Close(f); f.fs := NIL END;
		f := f.next
	END;
	IF count # 0 THEN
		Kernel.WriteString("OFS: "); Kernel.WriteInt(count, 1);
		Kernel.WriteString(" open files");
		IF fs.vol # NIL THEN
			Kernel.WriteString(" on "); Kernel.WriteString(fs.vol.name)
		END;
		Kernel.WriteLn
	END;
	fs.Finalize(fs); DeleteFS(fs);
	p := NIL; c := fsmount;
	WHILE c # fs DO p := c; c := c.link END;
	IF p = NIL THEN fsmount := c.link ELSE p.link := c.link END;
	c.link := NIL
END Remove;

(** Find file system with specified prefix. *)
PROCEDURE This*(prefix: ARRAY OF CHAR): FileSystem;
VAR fs: FileSystem;
BEGIN
	fs := fsroot; WHILE (fs # NIL) & (fs.prefix # prefix) DO fs := fs.next END;
	RETURN fs
END This;

(** Return first file system. *)
PROCEDURE First*(): FileSystem;
BEGIN
	RETURN fsroot
END First;

(** Return next file system. *)
PROCEDURE Next*(fs: FileSystem): FileSystem;
BEGIN
	RETURN fs.next
END Next;

(** File system auxillary procedures. *)

PROCEDURE Collect(f: PTR);
BEGIN 
	WITH f: File DO
		IF (f.fs # NIL) & (f.fs.Registered # NIL) & (f.fs.vol # NIL) THEN
			IF ~(ReadOnly IN f.fs.vol.flags) THEN
				IF ~f.fs.Registered(f.fs, f) THEN f.fs.Purge(f.fs, f) END;
			END
		END
	END
END Collect;

PROCEDURE FileCleanup(f: PTR);
VAR p, c: File;
BEGIN
	WITH f: File DO
		IF Trace THEN
			Kernel.WriteString("OFS: Cleanup "); Kernel.WriteInt(f.key, 1); 
			Kernel.WriteChar(" "); WriteFS(f.fs); Kernel.WriteLn
		END;
		p := froot; c := froot.next;
		WHILE c # NIL DO
			IF c = f THEN p.next := c.next ELSE p := c END;
			c := c.next
		END
	END
END FileCleanup;

(* Find file in open file list, or open and add it. *)
PROCEDURE Open(fs: FileSystem; VAR fname: ARRAY OF CHAR): File;
VAR f: File; key: LONGINT;
BEGIN
	f := NIL;
	IF (fs # NIL) & (fname # "") THEN
		key := fs.FileKey(fs, fname);
		IF key # 0 THEN
			f := froot.next;
			WHILE (f # NIL) & ((f.fs # fs) OR (f.key # key)) DO f := f.next END
		END;
		IF f = NIL THEN
			f := fs.Old(fs, fname);
			IF f # NIL THEN
				ASSERT(f.key # 0);	(* key must be set *)
				f.next := froot.next; froot.next := f;
				Kernel.RegisterObject(f, Collect, FALSE);
				Kernel.RegisterObject(f, FileCleanup, FALSE)
			END
		END
	END;
	RETURN f
END Open;

(** Open an existing file, searching through the mounted file system list if no prefix is specified. *)
PROCEDURE Old*(VAR name: ARRAY OF CHAR): File;
VAR fs: FileSystem; f: File; prefix: Prefix; fname: LocalName;
BEGIN
	f := NIL;
	SplitName(name, prefix, fname);
	IF prefix = "" THEN
		fs := First();
		WHILE (fs # NIL) & (f = NIL) DO
			f := Open(fs, fname); fs := Next(fs)
		END
	ELSE
		f := Open(This(prefix), fname)
	END;
	RETURN f
END Old;

(** Create a new file.  If no prefix is specified, create the file on the first file system in the mounted list.*)
PROCEDURE New*(VAR name: ARRAY OF CHAR): File;
VAR fs: FileSystem; f: File; prefix: Prefix; fname: LocalName;
BEGIN
	f := NIL; SplitName(name, prefix, fname);
	IF prefix = "" THEN
		fs := First();	(* use default file system *)
		IF fname = "" THEN	(* anonymous file on unspecified file system *)
			WHILE (fs # NIL) & ((fs.vol = NIL) OR (fs.vol.flags * {Boot,ReadOnly} # {Boot})) DO
				fs := Next(fs)	(* find a writable boot file system *)
			END;
			IF fs = NIL THEN fs := First() END	(* none found, relapse to default *)
		END
	ELSE
		fs := This(prefix)
	END;
	IF fs # NIL THEN
		IF (fs.vol = NIL) OR ~(ReadOnly IN fs.vol.flags) THEN
			f := fs.New(fs, fname);
			IF f # NIL THEN
				Kernel.RegisterObject(f, Collect, FALSE)
			END
		END
	END;
	RETURN f
END New;

(** Delete a file. res = 0 indicates success. *)
PROCEDURE Delete*(VAR name: ARRAY OF CHAR; VAR res: INTEGER);
VAR fs: FileSystem; p, c: File; key: LONGINT; prefix: Prefix; fname: LocalName;
BEGIN
	SplitName(name, prefix, fname);
	IF prefix = "" THEN fs := First() ELSE fs := This(prefix) END;
	IF fs # NIL THEN
		IF (fs.vol = NIL) OR ~(ReadOnly IN fs.vol.flags) THEN
			fs.Delete(fs, fname, key, res);
			IF key # 0 THEN
				p := froot; c := froot.next;
				WHILE c # NIL DO
					IF (c.fs = fs) & (c.key = key) THEN p.next := c.next ELSE p := c END;
					c := c.next
				END
			END
		ELSE
			res := 3	(* can not modify read-only volume *)
		END
	ELSE
		res := 2	(* file system not found *)
	END
END Delete;

(** Rename a file. res = 0 indicates success. *)
PROCEDURE Rename*(VAR old, new: ARRAY OF CHAR; VAR res: INTEGER);
VAR ofs, nfs: FileSystem; pold, pnew: Prefix; fold, fnew: LocalName;
BEGIN
	SplitName(old, pold, fold);
	SplitName(new, pnew, fnew);
	IF pold = "" THEN ofs := First() ELSE ofs := This(pold) END;
	IF pnew = "" THEN nfs := First() ELSE nfs := This(pnew) END;
	IF (nfs # NIL) & (ofs = nfs) THEN
		IF (nfs.vol = NIL) OR ~(ReadOnly IN nfs.vol.flags) THEN
			nfs.Rename(nfs, fold, fnew, res)
		ELSE
			res := 3	(* can not modify read-only volume *)
		END
	ELSE
		res := 2
	END
END Rename;

(** Register a file created with New in the directory, replacing the previous file in the directory with the same name. The file is automatically closed. *)
PROCEDURE Register*(f: File);
VAR res: INTEGER;
BEGIN
	IF f # NIL THEN
		f.fs.Register(f, res);
		IF res = 0 THEN	(* new file was registered *)
			ASSERT(f.key # 0);
			f.next := froot.next; froot.next := f;
			Kernel.RegisterObject(f, FileCleanup, FALSE)
		ELSE
			IF res = 1 THEN	(* file was registered already *)
				(* skip *)
			ELSE	(* error occured while registering *)
				SYSTEM.HALT(17)
			END
		END
	END
END Register;

(** Enumerates files matching mask by upcalling proc for every file.  If EnumSize flags is set, size parameter of proc upcall will be valid.  If EnumTime is set, time and date will be valid.  All flags are passed through to the upcall in the flags parameter. *)
PROCEDURE Enumerate*(VAR mask: ARRAY OF CHAR; VAR flags: SET; proc: EntryHandler);
VAR fs: FileSystem; prefix: Prefix; fmask: LocalName;
BEGIN
	SplitName(mask, prefix, fmask);
	IF prefix = "" THEN
		fs := First();
		WHILE fs # NIL DO
			EXCL(flags, EnumStop);
			fs.Enumerate(fs, fmask, flags, proc);
			fs := Next(fs)
		END
	ELSE
		fs := This(prefix);
		IF fs # NIL THEN fs.Enumerate(fs, fmask, flags, proc) END
	END
END Enumerate;

(** Find an open file.  Can also be used to see if a given file is open.  If it is not, then it is safe to purge its sectors when it is deleted or replaced (through rename). *)
PROCEDURE FindOpenFile*(fs: FileSystem; key: LONGINT): File;
VAR f: File;
BEGIN
	f := froot;
	REPEAT f := f.next UNTIL (f = NIL) OR ((f.key = key) & (f.fs = fs));
	RETURN f
END FindOpenFile;

(** Checks if a file system has open files. *)
PROCEDURE HasOpenFiles*(fs: FileSystem): BOOLEAN;
VAR f: File;
BEGIN
	f := froot;
	REPEAT f := f.next UNTIL (f = NIL) OR (f.fs = fs);
	RETURN f # NIL
END HasOpenFiles;

(** Help procedures. *)

(** Append first string to second string, truncating on overflow. *)
PROCEDURE AppendStr*(from: ARRAY OF CHAR;  VAR to: ARRAY OF CHAR);
VAR i, j, m: LONGINT;
BEGIN
	j := 0;  WHILE to[j] # 0X DO INC(j) END;
	m := LEN(to)-1;
	i := 0;  WHILE (from[i] # 0X) & (j # m) DO to[j] := from[i];  INC(i);  INC(j) END;
	to[j] := 0X
END AppendStr;

(** Append integer to string in ASCII format. *)
PROCEDURE AppendInt*(x: LONGINT;  VAR to: ARRAY OF CHAR);
VAR i, m: LONGINT;
BEGIN
	i := 0;  WHILE to[i] # 0X DO INC(i) END;
	IF x < 0 THEN to[i] := "-"; INC(i); x := -x END;
	IF x # 0 THEN
		m := 1000000000;
		WHILE x < m DO m := m DIV 10 END;
		REPEAT
			to[i] := CHR(48 + (x DIV m) MOD 10); INC(i);
			m := m DIV 10
		UNTIL m = 0
	ELSE
		to[i] := "0"; INC(i)
	END;
	to[i] := 0X
END AppendInt;

(* Clean up file systems when shutting down or unloading module.  File systems are cleaned up in reverse order of installation. *)
PROCEDURE FSCleanup;
BEGIN
	WHILE fsmount # NIL DO
		Remove(fsmount)
	END
END FSCleanup;

BEGIN
	pos := 0; par[0] := 0X;
	fsroot := NIL; fsmount := NIL;
	NEW(froot); froot.next := NIL;
	Kernel.InstallTermHandler(FSCleanup)
END OFS.

(**
	On-the-fly GC by bsm

	In order to be non-leaking, a file system must provide the following:
	- FileSystem.Purge -- to reclaim blocks of an open (being closed) file
	- FileSystem.Registered -- reports if a particular open file is registered in the file directory
	
	The following procedures need to be modified to purge file blocks when appropriate.
	- FileSystem.Register -- if an entry to a file, F, which is not open is replaced, purge F.
	- FileSystem.Rename -- same as register.
	- FileSystem.Delete -- if the entry being deleted refers to a file, F, which is not open, purge F.
	
	The procedure FindOpenFile may be used to see if a given file is open or not.
*)
