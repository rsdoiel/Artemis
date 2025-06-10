(* Example: Using IniConfigTokenizer to read tokens from an INI file *)

MODULE ExampleTokenizer;

IMPORT IniConfigTokenizer, Files, Out;

VAR
    file: Files.File;
    tokenizer: IniConfigTokenizer.Tokenizer;
    token: IniConfigTokenizer.Token;

BEGIN
    file := Files.Old("test.ini");  (* Open an existing INI file *)
    IF file # NIL THEN
        IniConfigTokenizer.Init(tokenizer, file);
        WHILE ~IniConfigTokenizer.AtEof(tokenizer) DO
            IniConfigTokenizer.NextToken(tokenizer, token);
            CASE token.type OF
                IniConfigTokenizer.SectionToken:
                    Out.String("Section: "); Out.String(token.value); Out.Ln
                | IniConfigTokenizer.KeyToken:
                    Out.String("Key: "); Out.String(token.value); Out.Ln;
                    IniConfigTokenizer.GetValue(tokenizer, token);
                    IF token.type = IniConfigTokenizer.ValueToken THEN
                        Out.String("  Value: "); Out.String(token.value); Out.Ln
                    END
                | IniConfigTokenizer.CommentToken:
                    Out.String("Comment"); Out.Ln
                | IniConfigTokenizer.ErrorToken:
                    Out.String("Error on line "); Out.Int(token.line, 0); Out.Ln
            END
        END;
        Files.Close(file)
    ELSE
        Out.String("Could not open example.ini"); Out.Ln
    END
    END ExampleTokenizer.