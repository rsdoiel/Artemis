MODULE T1;

IMPORT Out;

CONST
  OneChar = 36;

VAR
  ch : CHAR:

BEGIN ch := CHR(OneChar);
  Out.Char(ch); Out.Ln();
END T1.
