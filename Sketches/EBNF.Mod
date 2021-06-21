MODULE EBNF;

IMPORT Chars, Files, Out;

CONST
  version* = "0.0.0";

  IdLen = 32;
  ident = 0; literal = 2; lparen = 3; lbrak = 4; lbrace = 5; bar = 6; 
  eql = 7; rparen = 8; rbrak = 9; rbrace = 10; period = 11; other = 12;

TYPE
  Identifier = ARRAY IdLen OF CHAR;

VAR
  ch   : CHAR;
  sym  : INTEGER;
  lastpos : INTEGER;
  id : Identifier;
  R : Files.Rider;

PROCEDURE OpenReader*(name : ARRAY OF CHAR; pos : INTEGER);
  VAR fp : Files.File;
BEGIN
  fp := Files.Old(name);
  IF fp # NIL THEN
    Files.Set(R, fp, pos);
  END;
END OpenReader;

PROCEDURE GetChar*(VAR R : Files.Rider; VAR ch : CHAR);
BEGIN
  Files.ReadChar(R, ch);
END GetChar;

PROCEDURE error(n : INTEGER);
  VAR pos : INTEGER;
BEGIN pos := Files.Pos(R);
  IF pos > lastpos + 4 THEN (* avoid spurious error messages *)
    Out.String(" pos "); Out.Int(pos, 6);
    Out.String(" err "); Out.Int(n, 4); lastpos := pos;
    Out.String(" sym "); Out.Int(sym, 4); 
    Out.Ln;
  END
END error;

PROCEDURE GetSym*;
  VAR i : INTEGER;
BEGIN
  (* Skip whitespace *)
  WHILE (R.eof = FALSE) & Chars.IsSpace(ch) DO GetChar(R, ch); END;
  IF Chars.IsAlpha(ch) THEN
    Out.String("DEBUG sym = ident, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := ident; i := 0;
    REPEAT id[i] := ch; INC(i); GetChar(R, ch);
    UNTIL (Chars.IsAlpha(ch) = FALSE) OR (i = (IdLen - 1));
    id[i] := 0X
  ELSIF ch = 22X THEN (* quote *)
    Out.String("DEBUG sym = literal, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    GetChar(R, ch);
    sym := literal;
    i := 0;
    WHILE (ch # 22X) & (Chars.IsPrintable(ch) OR Chars.IsSpace(ch)) DO
      id[i] := ch;
      INC(i);
      GetChar(R, ch);
    END;
    IF ch < " " THEN error(1) END;
    id[i] := 0X;
    GetChar(R, ch);
  ELSIF ch = "=" THEN
    Out.String("DEBUG sym = equal, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := eql;
    GetChar(R, ch);
  ELSIF ch = "(" THEN
    Out.String("DEBUG sym = lparen, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := lparen;
    GetChar(R, ch);
  ELSIF ch = ")" THEN
    Out.String("DEBUG sym = rparen, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := rparen;
    GetChar(R, ch);
  ELSIF ch = "[" THEN
    Out.String("DEBUG sym = lbrak, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := lbrak;
    GetChar(R, ch);
  ELSIF ch = "]" THEN
    Out.String("DEBUG sym = rbrak, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := rbrak;
    GetChar(R, ch);
  ELSIF ch = "{" THEN
    Out.String("DEBUG sym = lbrace, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := lbrace;
    GetChar(R, ch);
  ELSIF ch = "}" THEN
    Out.String("DEBUG sym = rbrace, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := rbrace;
    GetChar(R, ch);
  ELSIF ch = "|" THEN
    Out.String("DEBUG sym = bar, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := bar;
    GetChar(R, ch);
  ELSIF ch = "." THEN
    Out.String("DEBUG sym = period, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := period;
    GetChar(R, ch);
  ELSE
    Out.String("DEBUG sym = other, ch = '");Out.Char(ch); Out.Char("'");Out.Ln;
    sym := other; 
    GetChar(R, ch);
  END;
END GetSym;

PROCEDURE record(id : Identifier; class : INTEGER);
BEGIN (*enter id in appropriate list of identifiers *)
  Out.String("Identifier: "); Out.String(id); Out.String("Class: "); Out.Int(class, 4); Out.Ln;
  (**FIXME need to create a AST like chain of records *)
END record;

PROCEDURE expression;

  PROCEDURE term;

    PROCEDURE factor;
    BEGIN
      Out.String("DEBUG start factor"); Out.Ln;
      IF sym = ident THEN record(id, 1); GetSym;
      ELSIF sym = literal THEN record(id, 0); GetSym;
      ELSIF sym = lparen THEN
        GetSym; expression;
        IF sym = rparen THEN GetSym ELSE error(2) END;
      ELSIF sym = lbrak THEN
        GetSym; expression;
        IF sym = rbrak THEN GetSym ELSE error(3) END;
      ELSIF sym = lbrace THEN 
        GetSym; expression;
        IF sym = rbrace THEN GetSym ELSE error(4) END;
      ELSE error(5)
      END;
      Out.String("DEBUG   end factor"); Out.Ln;
    END factor;
  
  BEGIN 
    Out.String("DEBUG start term"); Out.Ln;
    (* term*)
    factor;
    WHILE sym < bar DO factor END;
    Out.String("DEBUG   end term"); Out.Ln;
  END term;
  
BEGIN 
  (* expression *) 
  Out.String("DEBUG start expression"); Out.Ln;
  term;
  WHILE sym = bar DO GetSym; term END;
  Out.String("DEBUG   end expression"); Out.Ln;
END expression;

PROCEDURE production;
BEGIN 
  Out.String("DEBUG start production"); Out.Ln;
  (*sym = ident*) 
  record(id, 2); GetSym;
  IF sym = eql THEN GetSym; ELSE error(7) END;
  expression;
  IF sym = period THEN GetSym; ELSE error(8) END;
  Out.String("DEBUG end production"); Out.Ln;
END production;

PROCEDURE syntax;
BEGIN
  Out.String("DEBUG start syntax"); Out.Ln;
  WHILE sym = ident DO production; END;
  Out.String("DEBUG end   syntax"); Out.Ln;
END syntax;

PROCEDURE Compile*(name : ARRAY OF CHAR);
BEGIN
  Out.String("Compile ");Out.String(name); Out.Ln;
  lastpos := 0; ch := " ";
  OpenReader(name, 0); GetSym; syntax;
END Compile;

END EBNF.
