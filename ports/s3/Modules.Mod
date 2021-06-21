(* ETH Oberon, Copyright 1990-2003 Computer Systems Institute, ETH Zurich, CH-8092 Zurich.
Refer to the license.txt file provided with this distribution. *)

MODULE Modules;	(** portable, except where noted *)	(* rc/mh/jm/tk/ard/rml/prk/pjm *)

(**
 The Modules module implements the dynamic module loader of the Oberon system. 
 It is responsible for loading and freeing modules.
*)

IMPORT Kernel, Files, SYSTEM;

CONST
	done = 0;
	fileNotFound = 1;
	invalidObjFile = 2;
	corruptedObjFile = 4;
	cmdNotFound = 5;
	moduleNotFound = 6;
	notEnoughSpace = 7;
	refCntNotZero = 8;
	cyclicImport = 9;
	incompImport = 16;

	ExtTabWordSize = 16;
	Tag0WordOffset = -2;
	Mth0WordOffset = Tag0WordOffset - ExtTabWordSize;

	ActiveTag = 0AFX;

TYPE
	Command* = Kernel.Proc;
	Module* = Kernel.Module;
	ModuleDesc* = Kernel.ModuleDesc;	(** non-portable *)
	ModuleName* = Kernel.Name;
	ADDRESS = LONGINT;

	ExportPtr = Kernel.ExportPtr;
	ExportDesc = Kernel.ExportDesc;
	Cmd = Kernel.Cmd;

VAR
	res*: INTEGER;	(** Error code for ThisMod and ThisCommand. res = 0 indicates success. *)
	resMsg*: ARRAY 256 OF CHAR;	(** Explanation of res, if res # 0 *)
	extension*: ARRAY 8 OF CHAR;	(** Extension of object files (non-portable) *)
	resMsgLen: LONGINT;
	
	(** The res codes are listed in the table below.
		done = 0;
		fileNotFound = 1
		invalidObjFile = 2
		corruptedObjFile = 4
		cmdNotFound = 5
		moduleNotFound = 6
		notEnoughSpace = 7
		refCntNotZero = 8
		cyclicImport = 9
		incompImport = 16
	*)
	imported, importing: ModuleName;	(* Specifies the modules involved in a key mismatch. *)
	disp: ARRAY 16 OF CHAR;
	trace: BOOLEAN;

TYPE
	Header = RECORD (* data in object file header *)
		nofEntries: INTEGER;
		nofCmds: INTEGER;
		nofPtrs: INTEGER;
		nofTds: INTEGER;
		nofImps: INTEGER;
		nofLinks: INTEGER;
		nofDataLinks: INTEGER;
		codeSize, dataSize, refSize, conSize: LONGINT;
	END;

	LinkTab = POINTER TO ARRAY OF RECORD
		mod, entry: CHAR;
		link: LONGINT
	END;

	DataLinkTab = POINTER TO ARRAY OF RECORD
		mod: CHAR;
		entry: INTEGER;
		nofFixups: INTEGER;
		offset: POINTER TO ARRAY OF LONGINT
	END;
	
CONST
	(* export/use section *)
	EUEnd = 0; EURecord = 1; EUobjScope = 0; EUrecScope = 1;  EUerrScope = -1;
	EUProcFlag = 80000000H; 
	
PROCEDURE LSW (x: LONGINT): LONGINT;
BEGIN (* least significant word (unsigned) *)
	RETURN SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, x) * {0..15})
END LSW;

PROCEDURE MSW (x: LONGINT): LONGINT;
BEGIN (* most significant word (unsigned) *)
	RETURN SYSTEM.LSH(x, -16)
END MSW;

PROCEDURE ReadUnsigned (VAR R: Files.Rider; VAR u: LONGINT);
	(* read unsigned, 16 bit, little endian value *)
	VAR low, high: CHAR;
BEGIN
	Files.Read(R, low); Files.Read(R, high);
	u := 256*LONG(ORD(high)) + ORD(low);
END ReadUnsigned;

(* Error Messages *)

PROCEDURE Ch(ch: CHAR);
BEGIN
	IF resMsgLen # LEN(resMsg)-1 THEN
		resMsg[resMsgLen] := ch; INC(resMsgLen); resMsg[resMsgLen] := 0X
	END
END Ch;

PROCEDURE Str(s: ARRAY OF CHAR);
VAR i: LONGINT;
BEGIN
	i := 0; WHILE s[i] # 0X DO Ch(s[i]); INC(i) END
END Str;

PROCEDURE Ln;
BEGIN
	Ch(0DX)
END Ln;

PROCEDURE Clear;
BEGIN
	resMsg[0] := 0X; resMsgLen := 0
END Clear;

PROCEDURE ErrMsg(res: INTEGER);
BEGIN
	IF res # 0 THEN
		Clear;  Str(importing);
		IF (res = fileNotFound) OR (res = moduleNotFound) THEN Str(" not found")
		ELSIF res = invalidObjFile THEN Str(" not an obj-file")
		ELSIF res = corruptedObjFile THEN Str(" corrupted obj file")
		ELSIF res = notEnoughSpace THEN Str(" not enough space")
		ELSIF res = refCntNotZero THEN Str(" reference count not zero")
		ELSIF res = cyclicImport THEN Str(" cyclic import")
		ELSIF res = incompImport THEN
			Str(" imports incompatible version of ");  Str(imported);
		ELSIF res = cmdNotFound THEN
			Clear;  Str(imported);  Ch(".");  Str(importing);
			Str(" command not found");  (* assumes importing = procedure name and imported = module name *)
		ELSE Str(" unknown error code")
		END;
		Kernel.WriteString("Modules: ");  Kernel.WriteString(resMsg);  Kernel.WriteLn
	END
END ErrMsg;

(** Returns a handle to an already loaded module. *)

PROCEDURE FindMod*(name: ARRAY OF CHAR): Module;
VAR m: Module;
BEGIN
	m := Kernel.modules;
	WHILE (m # NIL) & (m.name # name) DO m := m.next END;
	RETURN m
END FindMod;

(* ---- auxiliaries ---- *)

PROCEDURE And(x, y: LONGINT): LONGINT;
BEGIN
	RETURN SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, x) * SYSTEM.VAL(SET, y))
END And;

PROCEDURE ReadString(VAR R: Files.Rider; VAR string: ARRAY OF CHAR);
	VAR i: INTEGER; ch: CHAR;
BEGIN
	i := 0;
	LOOP
		Files.Read(R, ch);
		IF ch = 0X THEN string[i] := 0X; RETURN
		ELSIF ch > 7FX THEN string[i] := CHR(ORD(ch)-80H); string[i+1] := 0X; RETURN
		ELSE string[i] := ch; INC(i) END
	END
END ReadString;

(*---- module loading ---- *)

PROCEDURE ^Load (name: ARRAY OF CHAR; VAR m: Module);

PROCEDURE LoadModule (VAR R: Files.Rider; VAR m: Module);
	TYPE TDesc = POINTER TO RECORD word: ARRAY 32000 OF LONGINT END;
	VAR
		ch: CHAR;
		i, mno, j, symSize, e, k, t: LONGINT;
		imp: Module;
		body: Command; linkTab: LinkTab; dataLinks: DataLinkTab;
		head: Header;
		types: POINTER TO ARRAY OF RECORD
			initialized: BOOLEAN;
			tdesc: TDesc;
			entry, root, nofMeth, nofInhMeth, baseMod: INTEGER;
			baseEntry: LONGINT
		END;
		mods: POINTER TO ARRAY OF ModuleName;

	PROCEDURE FixupCall(code, link, fixval: LONGINT);
	VAR instr, nextlink, jmp: LONGINT;
	BEGIN
		REPEAT
			SYSTEM.GET(code + link, instr);
			nextlink := MSW(instr);
			SYSTEM.GET(code + link - 1, jmp);
			IF LSW(jmp) MOD 100H = 0E8H THEN
				SYSTEM.PUT(code + link, fixval - (code + link + 4)) (* + 4: to next instruction *)
			ELSE
				SYSTEM.PUT(code + link, fixval)
			END;
			link := nextlink
		UNTIL link = 0FFFFH
	END FixupCall;
	
	PROCEDURE FixupVar(code, link, fixval: LONGINT);
	VAR nofFixups: INTEGER; i, val: LONGINT;
	BEGIN
		nofFixups := dataLinks[link].nofFixups;
		i := 0;
		WHILE i < nofFixups DO
			SYSTEM.GET(code + dataLinks[link].offset[i], val);
			SYSTEM.PUT(code + dataLinks[link].offset[i], val + fixval);
			INC(i)
		END
	END FixupVar;
	
	PROCEDURE Fixup(m: Module; link: LinkTab);
		VAR i, val, offs: LONGINT;
			modNo, nofFixups: INTEGER;
			codebase: ADDRESS;
			Error: ARRAY 32 OF CHAR;  Num: LONGINT;
	BEGIN
		codebase := SYSTEM.ADR(m.code[0]);
		(* global variables *)
		modNo := ORD(dataLinks[0].mod); nofFixups := dataLinks[0].nofFixups;
		IF (head.nofDataLinks > 0) & (modNo = 0) THEN
			i := 0;
			WHILE i < nofFixups DO
				SYSTEM.GET(codebase + dataLinks[0].offset[i], val);
				SYSTEM.PUT(codebase + dataLinks[0].offset[i], val + m.sb);
				INC(i)
			END
		END;
		(* Kernel.NewRec, Kernel.NewSys, Kernel.NewArr, local Procedure assignments, case table and imported procedures *)
		i := 0;
		WHILE i < head.nofLinks DO
			IF ORD(link[i].mod) = 0 THEN
				(* Kernel.NewRec, Kernel.NewSys, Kernel.NewArr, local Procedure assignments, case table *)
				CASE ORD(link[i].entry) OF
					255:	(* case table fixup in constant area *)
						offs := link[i].link;
						WHILE offs # 0FFFFH DO
							SYSTEM.GET(m.sb + offs, val); SYSTEM.PUT(m.sb + offs, codebase + LSW(val));
							offs := MSW(val);
						END;
				|   254:	(* local procedure assignment *)
						offs := link[i].link;
						WHILE offs # 0FFFFH DO
							SYSTEM.GET(codebase + offs, val); SYSTEM.PUT(codebase + offs, m.entries[LSW(val)]);
							offs := MSW(val);
						END;
				|   253:	(* Kernel.NewRec *)
						offs := link[i].link;
						WHILE offs # 0FFFFH DO
							SYSTEM.GET(codebase + offs, val);
							SYSTEM.PUT(codebase + offs, Kernel.runtime[0] - (codebase + offs + 4));
							offs := MSW(val);
						END;
				|   252:	(* Kernel.NewSys *)
						offs := link[i].link;
						WHILE offs # 0FFFFH DO
							SYSTEM.GET(codebase + offs, val); SYSTEM.PUT(codebase + offs, Kernel.runtime[1] - (codebase + offs + 4));
							offs := MSW(val);
						END;
				|   251:	(* Kernel.NewArr *)
						offs := link[i].link;
						WHILE offs # 0FFFFH DO
							SYSTEM.GET(codebase + offs, val); SYSTEM.PUT(codebase + offs, Kernel.runtime[2] - (codebase + offs + 4));
							offs := MSW(val);
						END
(*
				|   250: offs := link[i].link;	(* Start(adr: LONGINT; priority, typ: SHORTINT; self: Object) *)
						WHILE offs # 0FFFFH DO
							SYSTEM.GET(codebase + offs, val); SYSTEM.PUT(codebase + offs, Kernel.ModuleData[3] - (codebase + offs + 4));
							offs := MSW(val);
						END
				|   249: offs := link[i].link; 	(* Passivate(adr, ebp: LONGINT) *)
						WHILE offs # 0FFFFH DO
							SYSTEM.GET(codebase + offs, val); SYSTEM.PUT(codebase + offs, Kernel.ModuleData[5] - (codebase + offs + 4));
							offs := MSW(val);
						END
				|   247: offs := link[i].link;	(* Lock *)
						WHILE offs # 0FFFFH DO
							SYSTEM.GET(codebase + offs, val); 
							SYSTEM.PUT(codebase + offs, Kernel.ModuleData[6] - (codebase + offs + 4));
							offs := MSW(val);
						END
				|   246: offs := link[i].link;	(* Unlock *)
						WHILE offs # 0FFFFH DO
							SYSTEM.GET(codebase + offs, val); SYSTEM.PUT(codebase + offs, Kernel.ModuleData[7] - (codebase + offs + 4));
							offs := MSW(val);
						END
*)
				ELSE
					Error := "Unsupported kernel procedure";
					Num := ORD(link[i].entry);
					HALT(98)	(* kernel procedure not supported *)
				END
			ELSE	(* imported procedure from module from *)
				HALT(99) (* this case should never occur *)
			END;
			INC(i)
		END
	END Fixup;
	
	PROCEDURE LoadExpBlock(VAR R: Files.Rider; M: Module);
		VAR struct, old: POINTER TO ARRAY OF LONGINT (*ExportPtr*); nofStr: LONGINT; exp: ExportPtr;
		
		PROCEDURE LoadScope(VAR scope: ExportDesc; level: INTEGER; adr: LONGINT);
			VAR no, no2: INTEGER; fp, off: LONGINT; 
		BEGIN
			Files.ReadBytes(R, scope.nofExp, 2); no := 0; no2 := 0;
			IF scope.nofExp # 0 THEN 
				NEW(scope.dsc, scope.nofExp);
				scope.dsc[0].adr := adr
			END;
			IF level = EUrecScope THEN
				INC(nofStr);
				IF nofStr = LEN(struct) THEN
					old := struct;
					NEW(struct, 2*nofStr);
					FOR off := 0 TO nofStr-1 DO struct[off] := old[off] END
				END;
				struct[nofStr] := SYSTEM.ADR(scope)
			END;
			Files.ReadNum(R, fp);
			WHILE fp#EUEnd DO
				IF fp=EURecord THEN Files.ReadNum(R, off);
					IF off < 0 THEN
						exp := SYSTEM.VAL(ExportPtr, struct[-off]);
						scope.dsc[no2].nofExp := exp.nofExp; scope.dsc[no2].dsc := exp.dsc; (* old type *)
					ELSE LoadScope(scope.dsc[no2], EUrecScope, off)
					END
				ELSE 
					IF level = EUobjScope THEN Files.ReadNum(R, scope.dsc[no].adr) END;
					scope.dsc[no].fp := fp; no2 := no; INC(no)
				END;
				Files.ReadNum(R, fp)
			END
		END LoadScope;
	
	BEGIN
		NEW(struct, 64);
		nofStr := 0; LoadScope(M.export, EUobjScope, 0)
	END LoadExpBlock;
	
	PROCEDURE CheckUseBlock(VAR R: Files.Rider; M: Module);
		VAR mod: Module; name: ModuleName; 
	
		PROCEDURE Err;
		BEGIN	
			IF res = 0 THEN COPY(mod.name, imported); res := incompImport; ErrMsg(res)
			ELSE Ch(9X) END
		END Err;
	
		PROCEDURE CheckScope(scope: ExportDesc; level: INTEGER);
			VAR fp, link, i, tdadr: LONGINT; tadr: ExportPtr; tmpErr: BOOLEAN;
		BEGIN tmpErr := (level = EUerrScope);
			i := 0;
			Files.ReadNum(R, fp);
			WHILE fp # EUEnd DO
				IF fp = EURecord THEN Files.ReadNum(R, link);
					IF tmpErr THEN CheckScope(scope.dsc[i], EUerrScope)
					ELSE
						IF scope.dsc[i].dsc # NIL THEN
							IF link # 0 THEN tadr := SYSTEM.VAL(ExportPtr, SYSTEM.ADR(scope.dsc[i].dsc[0]));
								SYSTEM.GET(mod.sb+tadr.adr, tdadr); SYSTEM.PUT(M.sb-link, tdadr)	(* tdadr at tadr[0] *)
							END
						END;
						CheckScope(scope.dsc[i], EUrecScope)
					END
				ELSE
					ReadString(R, name);
					IF level >= EUobjScope THEN tmpErr := FALSE;
						IF level = EUobjScope THEN Files.ReadNum(R, link) END;
						i := 0;
						WHILE (i < scope.nofExp) & (scope.dsc[i].fp # fp) DO INC(i) END;
						IF i >= scope.nofExp THEN Err; tmpErr := TRUE; Ln; Ch(9X);
							IF name = "@" THEN Str("RECORD ") 
							ELSE Str(name)
							END;
							Str(" incompatible");
							DEC(i)
						ELSIF (level = EUobjScope) & (link # 0) THEN
							IF And(link, EUProcFlag) = 0 THEN
								FixupVar(SYSTEM.ADR(M.code[0]), link, mod.sb+scope.dsc[i].adr)
							ELSE
								FixupCall(SYSTEM.ADR(M.code[0]), link-EUProcFlag, scope.dsc[i].adr+SYSTEM.ADR(mod.code[0]))
							END
						END
					END
				END;
				Files.ReadNum(R, fp)
			END
		END CheckScope;
	
	BEGIN ReadString(R, name);
		WHILE (name # "") & (res = 0) DO
			Load(name, mod);
			IF res = 0 THEN CheckScope(mod.export, EUobjScope) END;
			ReadString(R, name)
		END
	END CheckUseBlock;
	
	PROCEDURE Expect (tag: CHAR): BOOLEAN;
		VAR ch: CHAR;
	BEGIN Files.Read(R, ch);
		IF ch # tag THEN 
			res := corruptedObjFile; ErrMsg(res); RETURN FALSE
		ELSE RETURN TRUE
		END
	END Expect;
	
	PROCEDURE FindTDescAdr(M: Module; fp: LONGINT; VAR adr: LONGINT);
	VAR i: INTEGER;
	BEGIN
		i := 0;
		WHILE ( i < M.export.nofExp) & (M.export.dsc[i].fp # fp) DO INC(i) END;
		IF i < M.export.nofExp THEN adr := M.export.dsc[i].dsc[0].adr
		ELSE HALT(99)
		END
	END FindTDescAdr;
	
	PROCEDURE ReadTypes (VAR R: Files.Rider);
		VAR
			i, j, k, tdsize, recordSize: LONGINT;
			tdEntry, nofMethods, nofNewMeths, mthNo, nofPointers, root, entryNo: INTEGER;
			td: TDesc; 
			name: ModuleName; 
			ch: CHAR;
	BEGIN
		IF LEN(m.tdescs^) # 0 THEN
			NEW(types, LEN(m.tdescs^));
			FOR i := 0 TO LEN(m.tdescs^)-1 DO
				types[i].initialized := FALSE;
				Files.ReadLInt(R, recordSize);
				Files.ReadInt(R, tdEntry); types[i].entry := tdEntry;
				Files.ReadInt(R, types[i].baseMod);
				Files.ReadLInt(R, types[i].baseEntry);
				Files.ReadInt(R, nofMethods);
				types[i].nofMeth := nofMethods; Files.ReadInt(R, types[i].nofInhMeth);
				Files.ReadInt(R, nofNewMeths); Files.ReadInt(R, nofPointers);
				Files.ReadString(R, name);
				root := 13 (* fields tdsize..mdesc *) + nofMethods + ExtTabWordSize + 1 (* tag *);
				INC(root, (-root+2) MOD 4);	(* ADR(td.word[root]) MOD 16 = 8 ! *)
				types[i].root := root;
				tdsize := (root + 1 (* recsize *) + nofPointers + 1 (* sentinel *) )*4;
				SYSTEM.NEW(td, tdsize - 24 (* overhead of SysBlk header *) );
				DEC(SYSTEM.VAL(ADDRESS, td), 24);	(* overhead of SysBlk header *)
				types[i].tdesc := td;
				td.word[0] := tdsize;
				td.word[1] := -4; (* sentinel *)
				td.word[2] := SYSTEM.ADR(td.word[root]) (* self *);
				td.word[3] := 0; (* extlev *)
				k := SYSTEM.ADR(td.word[4]); j := 0;
				REPEAT ch := name[j]; SYSTEM.PUT(k, ch); INC(j); INC(k) UNTIL ch = 0X;
				td.word[12] := SYSTEM.ADR(m^); (* mdesc *)
				j := 0;
				WHILE j < nofNewMeths DO
					Files.ReadInt(R, mthNo); Files.ReadInt(R, entryNo);
					td.word[root + Mth0WordOffset - mthNo] := m.entries[entryNo];
					INC(j)
				END;
				ASSERT(SYSTEM.ADR(td.word[0]) # 0);
				td.word[root - 1] := SYSTEM.ADR(td.word[0]); (* tag of subobj *)
				td.word[root] := recordSize;
				SYSTEM.PUT(m.sb + tdEntry, SYSTEM.ADR(td.word[root]));
				m.tdescs[i] := SYSTEM.ADR(td.word[root]);
				j := 0;
				WHILE j < nofPointers DO Files.ReadLInt(R, td.word[root+1+j]); INC(j) END;
				td.word[root+1+nofPointers] := -(nofPointers+1)*4 (* sentinel *)
			END
		END
	END ReadTypes;

	PROCEDURE InitType (i: LONGINT);
		VAR t, baseType, tag, entry: LONGINT; extlev, n, root, baseModNo: INTEGER; td: TDesc; baseMod: Module;
	BEGIN
		IF ~types[i].initialized THEN
			td := types[i].tdesc; baseModNo := types[i].baseMod; extlev := 0; root := types[i].root;
			IF baseModNo # -1 THEN (* extended type *)
				IF baseModNo = 0 THEN (* base type in this module, initialize first! *)
				t := 0;
					WHILE (t < LEN(m^.tdescs^)) & (types[t].entry # types[i].baseEntry) DO INC(t) END;
					InitType(t)
				END;
				(* copy base type tags *)
				IF baseModNo > 0 THEN
					baseMod := m.imports[baseModNo-1];
					FindTDescAdr(baseMod, types[i].baseEntry, types[i].baseEntry);
				ELSE (* baseModNo = 0 *)
					baseMod := m
				END;
				SYSTEM.GET(baseMod.sb + types[i].baseEntry, baseType);
				SYSTEM.GET(baseType + Tag0WordOffset*4, tag);
				WHILE tag # 0 DO
					td.word[root + Tag0WordOffset - extlev] := tag;
					INC(extlev);
					SYSTEM.GET(baseType + (Tag0WordOffset - extlev)*4, tag);
				END;
				(* copy non-overwritten base methods *)
				n := types[i].nofInhMeth;
				WHILE n > 0 DO DEC(n);
					entry := td.word[root + Mth0WordOffset - n];
					IF entry = 0 THEN
						SYSTEM.GET(baseType + (Mth0WordOffset - n)*4, td.word[root + Mth0WordOffset - n])
					END
				END
			END;
			td.word[3] := extlev;
			td.word[root + Tag0WordOffset - extlev] := SYSTEM.ADR(td.word[root]); (* own type tag *)
			types[i].initialized := TRUE
		END
	END InitType;

	PROCEDURE InitTypes;
		VAR i: LONGINT;
	BEGIN i := 0;
		WHILE i < LEN(m.tdescs^) DO InitType(i); INC(i) END
	END InitTypes;

	PROCEDURE BuildModuleBlock (m: Module; h: Header);
		VAR t, size, gvarSize: LONGINT;
			arrPtr: POINTER TO RECORD a, b, c, len, data: LONGINT END;
	BEGIN		(* 43->35 *)
		size := 16 * ((h.nofEntries*4 + 35) DIV 16
			+ (h.nofCmds*SIZE(Cmd) + 35) DIV 16 + (h.nofPtrs*4 + 35) DIV 16 
			+ (h.nofTds*4 + 35) DIV 16 + ((h.nofImps)*4 + 35) DIV 16
			+ (h.dataSize + (-h.dataSize) MOD 8 + h.conSize + 35) DIV 16
			+ (h.codeSize + 35) DIV 16 + (h.refSize + 35) DIV 16);
			
		SYSTEM.NEW(arrPtr, size);
		SYSTEM.GET(SYSTEM.VAL(ADDRESS, arrPtr) - 4, t);

		SYSTEM.PUT(SYSTEM.ADR(m.entries), arrPtr);
		arrPtr.len := h.nofEntries;
		INC(SYSTEM.VAL(ADDRESS, arrPtr), LONG((h.nofEntries*4 + 35) DIV 16)*16);

		SYSTEM.PUT(SYSTEM.VAL(ADDRESS, arrPtr) - 4, t);
		SYSTEM.PUT(SYSTEM.ADR(m.cmds), arrPtr);
		arrPtr.len := h.nofCmds;
		INC(SYSTEM.VAL(ADDRESS, arrPtr), LONG((h.nofCmds*SIZE(Cmd) + 35) DIV 16)*16);

		SYSTEM.PUT(SYSTEM.VAL(ADDRESS, arrPtr) - 4, t);
		SYSTEM.PUT(SYSTEM.ADR(m.ptrTab), arrPtr);
		arrPtr.len := h.nofPtrs;
		INC(SYSTEM.VAL(ADDRESS, arrPtr), LONG((h.nofPtrs*4 + 35) DIV 16)*16);

		SYSTEM.PUT(SYSTEM.VAL(ADDRESS, arrPtr) - 4, t);
		SYSTEM.PUT(SYSTEM.ADR(m.tdescs), arrPtr);
		arrPtr.len := h.nofTds;
		INC(SYSTEM.VAL(ADDRESS, arrPtr), LONG((h.nofTds*4 + 35) DIV 16)*16);

		SYSTEM.PUT(SYSTEM.VAL(ADDRESS, arrPtr) - 4, t);
		SYSTEM.PUT(SYSTEM.ADR(m.imports), arrPtr);
		arrPtr.len := h.nofImps;
		INC(SYSTEM.VAL(ADDRESS, arrPtr), LONG(((h.nofImps)*4 + 35) DIV 16)*16);

		SYSTEM.PUT(SYSTEM.VAL(ADDRESS, arrPtr) - 4, t);
		SYSTEM.PUT(SYSTEM.ADR(m.data), arrPtr);
		gvarSize := h.dataSize + (-h.dataSize) MOD 8;
		m.sb := SYSTEM.ADR(arrPtr.data) + gvarSize;
		arrPtr.len := (gvarSize + h.conSize (*+ 3*));	(* >> +3 noetig ?? *)
		INC(SYSTEM.VAL(ADDRESS, arrPtr), ((gvarSize + h.conSize + 35) DIV 16)*16);

		SYSTEM.PUT(SYSTEM.VAL(ADDRESS, arrPtr) - 4, t);
		SYSTEM.PUT(SYSTEM.ADR(m.code), arrPtr);
		arrPtr.len := h.codeSize;
		INC(SYSTEM.VAL(ADDRESS, arrPtr), ((h.codeSize + 35) DIV 16)*16);

		SYSTEM.PUT(SYSTEM.VAL(ADDRESS, arrPtr) - 4, t);
		SYSTEM.PUT(SYSTEM.ADR(m.refs), arrPtr);
		arrPtr.len := h.refSize
	END BuildModuleBlock;

BEGIN (* LoadModule *)
	res := done;  Clear;
	NEW(m);
	m.init := FALSE; m.refcnt := 0; m.term := NIL;

	Files.ReadNum(R, symSize); Files.Set(R, Files.Base(R), Files.Pos(R)+symSize);
	(* HeaderBlk *)
	Files.ReadLInt(R, head.refSize); Files.ReadInt(R, head.nofEntries);
	Files.ReadInt(R, head.nofCmds);
	Files.ReadInt(R, head.nofPtrs); Files.ReadInt(R, head.nofTds); Files.ReadInt(R, head.nofImps);
	Files.ReadInt(R, head.nofDataLinks); Files.ReadInt(R, head.nofLinks);
	Files.ReadLInt(R, head.dataSize); ReadUnsigned(R, head.conSize); ReadUnsigned(R, head.codeSize);
	Files.ReadString(R, m.name);
	importing := m.name;
	(*NEW(m.import, DefMaxImport); NEW(m.struct, DefMaxStruct);
	NEW(m.reimp, DefMaxReimp);*)
	m.nofimp := -1;

	BuildModuleBlock(m, head);
	IF res # done THEN m := NIL; RETURN END;
	IF trace THEN
		Kernel.WriteHex(SYSTEM.ADR(m.code[0]), 8);  Kernel.WriteChar(" ");
		Kernel.WriteString(m.name);  Kernel.WriteLn
	END;

		(* EntryBlk *)
	IF ~Expect(082X) THEN RETURN END;
	i := 0; t := SYSTEM.ADR(m.code[0]);
	WHILE i < head.nofEntries DO ReadUnsigned(R, e); m.entries[i] := t + e; INC(i) END;
		(* CmdBlk *)
	IF ~Expect(083X) THEN RETURN END;
	i := 0;
	WHILE i < head.nofCmds DO
		Files.ReadString(R, m.cmds[i].name); ReadUnsigned(R, e);
		m.cmds[i].adr := t + e;
		INC(i)
	END;
		(* PtrBlk *)
	IF ~Expect(084X) THEN RETURN END;
	i := 0; t := m.sb;
	WHILE i < head.nofPtrs DO
		Files.ReadLInt(R, k);
		m.ptrTab[i] := t + k;
		INC(i)
	END;
		(* Import Block *)
	IF ~Expect(085X) THEN RETURN END;
	IF head.nofImps # 0 THEN
		NEW(mods, head.nofImps);
		mno := 0;
		WHILE (mno < head.nofImps) & (res = done) DO
			ReadString(R, mods[mno]);
			Load(mods[mno], imp);
			IF res # done THEN RETURN END;
			m.imports[mno] := imp; INC(mno)
		END
	END;
	COPY(m.name, importing);
		(* Data Link Block *)
	IF ~Expect(08DX) THEN RETURN END;
	IF head.nofDataLinks # 0 THEN
		NEW(dataLinks, head.nofDataLinks);
		FOR i := 0 TO head.nofDataLinks-1 DO
			Files.Read(R, dataLinks[i].mod);
			Files.ReadInt(R, dataLinks[i].entry);
			Files.ReadInt(R, dataLinks[i].nofFixups);
			IF dataLinks[i].nofFixups > 0 THEN
				NEW(dataLinks[i].offset, dataLinks[i].nofFixups);
				j := 0;
				WHILE j < dataLinks[i].nofFixups DO
					ReadUnsigned(R, dataLinks[i].offset[j]);
					INC(j)
				END
			ELSE dataLinks[i].offset := NIL
			END
		END
	END;
		(* Link Block *)
	IF ~Expect(086X) THEN RETURN END;
	IF head.nofLinks # 0 THEN
		NEW(linkTab, head.nofLinks);
		FOR i := 0 TO head.nofLinks-1 DO
			Files.Read(R, linkTab[i].mod); Files.Read(R, linkTab[i].entry); ReadUnsigned(R, linkTab[i].link)
		END
	END;
		(* Const Block *)
	IF ~Expect(087X) THEN RETURN END;
	i := 0; t := m.sb;
	WHILE i < head.conSize DO Files.Read(R, ch); SYSTEM.PUT(t, ch); INC(t); INC(i) END;
		(* Export Block *)
	IF ~Expect(088X) THEN RETURN END;
	LoadExpBlock(R, m);
		(* Code Block *)
	IF ~Expect(089X) THEN RETURN END;
	Files.ReadBytes(R, m.code^, head.codeSize);
		(* Use Block *)
	IF ~Expect(08AX) THEN RETURN END;
	CheckUseBlock(R, m);
	IF res # done THEN RETURN END;
		(* TypeBlk *)
	IF ~Expect(08BX) THEN RETURN END;
	ReadTypes(R);
	IF res # done THEN RETURN END;
		(* Reference Block *)
	IF ~Expect(08CX) THEN RETURN END;
	Files.ReadBytes(R, m.refs^, head.refSize);

	IF res = done THEN
		imp := FindMod(m.name);
		IF imp # NIL THEN (* cyclic load, we're done *) m := imp; RETURN END;
		WHILE mno > 0 DO DEC(mno); imp := m.imports[mno]; INC(imp.refcnt) END;
		SYSTEM.PUT (m.sb, SYSTEM.VAL (LONGINT, m));	(*SELF*)
		Fixup(m, linkTab);
		InitTypes;
		m.next := Kernel.modules; Kernel.modules := m;
		m.init := TRUE;
		SYSTEM.PUT(SYSTEM.ADR(body), SYSTEM.ADR(m.code[0]));
		body;
		res := done	(* body may contain failing call to Modules *)
	ELSE m := NIL
	END
END LoadModule;

PROCEDURE Load (name: ARRAY OF CHAR; VAR m: Module);
	VAR f: Files.File; R: Files.Rider; i, j: INTEGER; fname: ARRAY 64 OF CHAR; tag: CHAR;
BEGIN
	m := FindMod(name); res := done; Clear;
	IF m = NIL THEN
		i := 0;
		IF name = "Display" THEN
			WHILE disp[i] # 0X DO fname[i] := disp[i]; INC (i) END
		END;
		j := 0;
		WHILE name[j] # 0X DO fname[i] := name[j]; INC (i); INC (j) END;
		j := 0;  WHILE extension[j] # 0X DO fname[i] := extension[j]; INC (i); INC (j) END;
		fname[i] := 0X;
		f := Files.Old(fname);
		IF f = NIL THEN
			COPY(fname, importing); res := fileNotFound; ErrMsg(res);
			RETURN
		END;
		Files.Set(R, f, 0); Files.Read(R, tag);
		IF tag = 0BBX THEN
			Files.Read(R, tag);
			IF (tag = ActiveTag) THEN  LoadModule(R, m);
			ELSE COPY(name, importing); res := invalidObjFile; ErrMsg(res);
			END
		ELSE COPY(name, importing); res := invalidObjFile; ErrMsg(res);
		END
	ELSIF ~m.init THEN COPY(name, importing); res := cyclicImport; ErrMsg(res);
	END
END Load;

(** Returns a handle to an already loaded module, or if not loaded, loads the module and all its imported modules. *)

PROCEDURE ThisMod* (name: ARRAY OF CHAR): Module;
	VAR mod: Module;
BEGIN
	Load(name, mod);
	RETURN mod
END ThisMod;

(** Returns a procedure variable representing an exported command in a module. 
Calling this procedure executes the command. *)

PROCEDURE ThisCommand* (mod: Module; name: ARRAY OF CHAR): Command;
	VAR i: LONGINT;
BEGIN
	IF mod # NIL THEN
		i := LEN(mod.cmds);
		WHILE i > 0 DO DEC(i);
			IF mod.cmds[i].name = name THEN
				res := done;  Clear;
				RETURN SYSTEM.VAL(Command, mod.cmds[i].adr)
			END
		END;
		COPY(mod.name, imported);  COPY(name, importing); res := cmdNotFound; ErrMsg(res)
	END;
	RETURN NIL
END ThisCommand;

PROCEDURE Delete (m: Module);
	VAR m1: Module;
BEGIN
	m1 := Kernel.modules;
	IF m = m1 THEN
		Kernel.modules := m.next
	ELSE
		WHILE m1.next # m DO m1 := m1.next END;
		m1.next := m.next
	END
END Delete;

(** Free a module from memory. Only modules with no clients can be freed. The all flag requests that all imported modules should be freed too (i.e. a recursive call to Free). *)
PROCEDURE Free* (name: ARRAY OF CHAR; all: BOOLEAN);
	VAR m, m1: Module; i, j: LONGINT;
BEGIN
	res := done;  Clear;
	m := FindMod(name);
	IF m = NIL THEN COPY(name, importing); res := moduleNotFound; ErrMsg(res)
	ELSIF m.refcnt # 0 THEN importing := m.name; res := refCntNotZero; ErrMsg(res)
	ELSE
		Kernel.FinalizeModule(m);
		i := LEN(m.imports);
		WHILE i > 0 DO DEC(i); m1 := m.imports[i]; DEC(m1.refcnt) END;
		IF all THEN i := LEN(m.imports);
			WHILE i > 0  DO DEC(i); m1 := m.imports[i]; Free(m1.name, TRUE) END;
			res := done;  Clear
		END;
		Delete(m);
			(* now clear the module block *)
		i := SYSTEM.VAL(ADDRESS, m.entries);	(* start of module block *)
		SYSTEM.GET(i-4, j);	(* start of sysblk *)
		SYSTEM.GET(j, j);	(* size of sysblk *)
		j := i + j-24;	(* end of sysblk *)
		WHILE i < j DO SYSTEM.PUT32(i, 0CCCCCCCCH);  INC(i, 4) END	(* clear *)
	END
END Free;

(** InstallTermHandler - Install a procedure to execute when a module is freed. 
Never perform upcalls in the installed procedure! *)

PROCEDURE InstallTermHandler*(h: Kernel.Proc);
BEGIN
	Kernel.InstallTermHandler(h)
END InstallTermHandler;

BEGIN
	Kernel.GetConfig("ModExt", extension);
	IF extension = "" THEN extension := ".Obj" END;
	Kernel.GetConfig("TraceModules", disp);  trace := (disp[0] = "1");
	Kernel.GetConfig("Init", disp);
	IF disp = "9090" THEN
		disp := "Empty."	(* tracing *)
	ELSE
		Kernel.GetConfig("Display", disp)
	END
END Modules.

(** Remarks:

1. Oberon uses reference counting to determine how many clients of a module are loaded.
A module can only be freed when the reference count is 0.

2. The res codes are not the same numerically on all Oberon platforms. It is advisable to use
the resMsg as a correct indication of the error condition.

3. Module and command names are single words consisting of A to Z, a to z, and 0 to 9.
Names must not start with a digit.

4. Care should be taken freeing modules. Oberon cannot detect if a client has a procedure
variable still "pointing" at code in a freed module. Calling such a procedure can be
unpredictable at times, although the system generates a trap most of the time.
*)
