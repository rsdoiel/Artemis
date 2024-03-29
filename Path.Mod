MODULE Path;

IMPORT Chars;

CONST
    (** Maximum path length *)
    MAXLENGTH* = 1024;

VAR
    delimiter* : CHAR;
    extDelimiter* : CHAR;

(** SetDelimiter used for parsing paths *)
PROCEDURE SetDelimiter*(c : CHAR);
BEGIN delimiter := c;
END SetDelimiter;

(** SetExtDelimiter used for delimiting a filename extension, e.g. .txt *)
PROCEDURE SetExtDelimiter*(c : CHAR);
BEGIN extDelimiter := c;
END SetExtDelimiter;


(** Prepend insert the path fragement into the path adding
the delimiter appropriately.

NOTE: Prepend is limited by the temporary path used in assembling data.
If the length of the prefix and path is too long then success will be
set to FALSE and path will remain unchanged. *)
PROCEDURE Prepend*(prefix : ARRAY OF CHAR; VAR path : ARRAY OF CHAR; VAR success : BOOLEAN);
    VAR tmp : ARRAY MAXLENGTH OF CHAR; l1, l2 : INTEGER; delim : ARRAY 2 OF CHAR;
BEGIN success := FALSE; 
    tmp[0] := 0X; delim[0] := delimiter; delim[1] := 0X;
    l1 := Chars.Length(prefix); l2 := Chars.Length(path);
    IF (l1 + l2 + 1) < MAXLENGTH THEN
        IF l1 > 0 THEN
            Chars.Copy(prefix, tmp);
        END;
        IF (l2 > 0) & (Chars.EndsWith(delim, tmp) = FALSE) & (Chars.StartsWith(delim, path) = FALSE) THEN
            Chars.AppendChar(delimiter, tmp);
        END;
        IF (l2 > 0) THEN
            Chars.Append(path, tmp);
        END;
        IF Chars.Length(tmp) > 0 THEN
            Chars.Copy(tmp, path);
        END;
        success := TRUE;
    END;
END Prepend;

(** Append appends the path fragment onto the path adding a delimiter appropriately.

NOTE: The size of path limits how long the suffix can be. If it is too long then
path remains unchanged and success is set to FALSE. *)
PROCEDURE Append*(suffix : ARRAY OF CHAR; VAR path : ARRAY OF CHAR; VAR success : BOOLEAN);
    VAR l1, l2 : INTEGER; delim : ARRAY 2 OF CHAR;
BEGIN success := FALSE;
    l1 := Chars.Length(suffix); l2 := Chars.Length(path);
    delim[0] := delimiter; delim[1] := 0X;
    IF (l1 + l2 + 1) < LEN(path) THEN
        IF l1 > 0 THEN
            IF (Chars.StartsWith(delim, suffix) = FALSE) & (Chars.EndsWith(delim, path) = FALSE) THEN
                Chars.Append(delim, path);
            END;
            Chars.Append(suffix, path);
        END;
        success := TRUE;
    END;
END Append;

(** Basename scans source and writes the last path segment to dest based on the path delimiter set *)
PROCEDURE Basename*(source : ARRAY OF CHAR; VAR dest : ARRAY OF CHAR; success : BOOLEAN);
    VAR offset, l, i : INTEGER; c : CHAR; 
BEGIN l := Chars.Length(source); 
    success := l < LEN(dest);
    IF success THEN
        dest[0] := 0X; offset := -1; i := l - 1;
        WHILE (i > 0) & (offset = -1) DO
            c := source[i];
            IF c = delimiter THEN
                offset := i + 1;
            END;
            DEC(i);
        END;
        IF (offset > -1) & (offset < l) THEN
            l := l - offset;
            FOR i := 0 TO l DO
                dest[i] := source[offset];
                INC(offset);
            END;
            dest[l] := 0X;
        ELSE
            Chars.Copy(source, dest);
        END;
    END;
END Basename;

(** Dirname scans source and writes the all but the last path segment to dest based on the path delimiter set *)
PROCEDURE Dirname*(source : ARRAY OF CHAR; VAR dest : ARRAY OF CHAR; success : BOOLEAN);
    VAR endset, l, i : INTEGER; c : CHAR; 
BEGIN l := Chars.Length(source); 
    success := l < LEN(dest);
    IF success THEN
        dest[0] := 0X; endset := -1; i := l - 1;
        WHILE (i > 0) & (endset = -1) DO
            c := source[i];
            IF c = delimiter THEN
                endset := i + 1;
            END;
            DEC(i);
        END;
        IF (endset > -1) & (endset < l) THEN
            FOR i := 0 TO (endset - 1) DO
                dest[i] := source[i];
            END;
            dest[endset] := 0X;
            c := dest[endset-1];
            IF c = delimiter THEN
               dest[endset - 1] := 0X;
            END;
        ELSE
            Chars.Copy(source, dest);
        END;
    END;
END Dirname;

(** Ext scans source and writes the file extension to dest based on the extDelimiter set *)
PROCEDURE Ext*(source : ARRAY OF CHAR; VAR dest : ARRAY OF CHAR; success : BOOLEAN);
    VAR offset, l, i : INTEGER; c : CHAR; 
BEGIN l := Chars.Length(source); 
    success := l < LEN(dest);
    IF success THEN
        dest[0] := 0X; offset := -1; i := l - 1;
        WHILE (i > 0) & (offset = -1) DO
            c := source[i];
            IF c = extDelimiter THEN
                offset := i;
            END;
            DEC(i);
        END;
        IF (offset > -1) & (offset < l) THEN
            l := l - offset;
            FOR i := 0 TO l DO
                dest[i] := source[offset];
                INC(offset);
            END;
            dest[l] := 0X;
        ELSE
            Chars.Copy(source, dest);
        END;
    END;
END Ext;



BEGIN SetDelimiter(Chars.SLASH);
  SetExtDelimiter(Chars.PERIOD);
END Path.
