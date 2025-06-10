(** ExamplePathAndPathLists.Mod - Demonstrates using Path and PathLists modules together.

Copyright (C) 2025

Released under The 3-Clause BSD License.
*)

MODULE ExamplePathAndPathLists;

IMPORT Path, PathLists, Out;

VAR
    path, basePath, filename, extension: ARRAY Path.MAXLENGTH OF CHAR;
    pathList: PathLists.PathList;
    pathListString: ARRAY 1024 OF CHAR;
    success: BOOLEAN;
    pos: INTEGER;

(** Print a path with a label *)
PROCEDURE PrintPath(label: ARRAY OF CHAR; path: ARRAY OF CHAR);
BEGIN
    Out.String(label); Out.String(": '"); Out.String(path); Out.String("'"); Out.Ln
END PrintPath;

(** Print the contents of a PathList *)
PROCEDURE PrintPathList(label: ARRAY OF CHAR; pathList: PathLists.PathList);
VAR
    count: INTEGER;
    encoded: ARRAY 1024 OF CHAR;
    success: BOOLEAN;
BEGIN
    Out.String(label); Out.String(": ");
    count := PathLists.Length(pathList);
    Out.String("("); Out.Int(count, 0); Out.String(" paths) ");
    
    PathLists.Encode(pathList, ":", encoded, success);
    IF success THEN
        Out.String("'"); Out.String(encoded); Out.String("'")
    ELSE
        Out.String("(encoding failed)")
    END;
    Out.Ln
END PrintPathList;

BEGIN
    Out.String("=== Path and PathLists Example ==="); Out.Ln; Out.Ln;
    
    (* Set up path delimiters *)
    Path.SetDelimiter("/");
    Path.SetExtDelimiter(".");
    Out.String("Set path delimiter to '/' and extension delimiter to '.'"); Out.Ln; Out.Ln;
    
    (* Demonstrate Path module operations *)
    Out.String("--- Path Module Demonstrations ---"); Out.Ln;
    
    (* Build a path using Prepend and Append *)
    path := "";
    Path.Prepend("home", path, success);
    PrintPath("After prepending 'home'", path);
    
    Path.Append("user", path, success);
    PrintPath("After appending 'user'", path);
    
    Path.Append("documents", path, success);
    PrintPath("After appending 'documents'", path);
    
    Path.Append("project.txt", path, success);
    PrintPath("Complete path", path);
    Out.Ln;
    
    (* Extract components from the path *)
    Path.Basename(path, filename, success);
    PrintPath("Basename", filename);
    
    Path.Dirname(path, basePath, success);
    PrintPath("Dirname", basePath);
    
    Path.Ext(path, extension, success);
    PrintPath("Extension", extension);
    Out.Ln;
    
    (* Demonstrate PathLists module operations *)
    Out.String("--- PathLists Module Demonstrations ---"); Out.Ln;
    
    (* Create a new PathList and add some paths *)
    pathList := PathLists.New();
    Out.String("Created new PathList"); Out.Ln;
    
    PathLists.Append("/bin", pathList, success);
    Out.String("Added '/bin' - Success: ");
    IF success THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    
    PathLists.Append("/usr/bin", pathList, success);
    Out.String("Added '/usr/bin' - Success: ");
    IF success THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    
    PathLists.Append("/usr/local/bin", pathList, success);
    Out.String("Added '/usr/local/bin' - Success: ");
    IF success THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    
    PrintPathList("Current PathList", pathList);
    Out.Ln;
    
    (* Prepend a path *)
    PathLists.Prepend("/opt/bin", pathList, success);
    Out.String("Prepended '/opt/bin' - Success: ");
    IF success THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    PrintPathList("After prepend", pathList);
    Out.Ln;
    
    (* Find a path *)
    pos := PathLists.Find("/usr/bin", pathList);
    Out.String("Position of '/usr/bin': "); Out.Int(pos, 0); Out.Ln;
    
    pos := PathLists.Find("/nonexistent", pathList);
    Out.String("Position of '/nonexistent': "); Out.Int(pos, 0); Out.Ln;
    Out.Ln;
    
    (* Demonstrate encoding and decoding *)
    Out.String("--- Encoding and Decoding ---"); Out.Ln;
    PathLists.Encode(pathList, ":", pathListString, success);
    Out.String("Encoded PathList: '"); Out.String(pathListString); Out.String("'"); Out.Ln;
    Out.Ln;
    
    (* Cut a path *)
    PathLists.Cut("/usr/bin", pathList, success);
    Out.String("Removed '/usr/bin' - Success: ");
    IF success THEN Out.String("TRUE") ELSE Out.String("FALSE") END; Out.Ln;
    PrintPathList("After removal", pathList);
    Out.Ln;
    
    (* Demonstrate Apply operations *)
    Out.String("--- Apply Operations ---"); Out.Ln;
    pathListString := "/home/bin:/usr/sbin";
    Out.String("Starting with: '"); Out.String(pathListString); Out.String("'"); Out.Ln;
    
    success := PathLists.Apply("/usr/local/sbin", PathLists.APPEND, pathListString);
    Out.String("After APPEND '/usr/local/sbin': '"); Out.String(pathListString); Out.String("'"); Out.Ln;
    
    success := PathLists.Apply("/opt/sbin", PathLists.PREPEND, pathListString);
    Out.String("After PREPEND '/opt/sbin': '"); Out.String(pathListString); Out.String("'"); Out.Ln;
    
    success := PathLists.Apply("/usr/sbin", PathLists.CUT, pathListString);
    Out.String("After CUT '/usr/sbin': '"); Out.String(pathListString); Out.String("'"); Out.Ln;
    Out.Ln;
    
    (* Demonstrate Path and PathLists working together *)
    Out.String("--- Path and PathLists Integration ---"); Out.Ln;
    
    (* Build paths and add them to a PathList *)
    PathLists.Free(pathList);
    pathList := PathLists.New();
    
    (* Create some project paths *)
    path := "";
    Path.Prepend("project", path, success);
    Path.Append("src", path, success);
    PathLists.Append(path, pathList, success);
    
    path := "";
    Path.Prepend("project", path, success);
    Path.Append("lib", path, success);
    PathLists.Append(path, pathList, success);
    
    path := "";
    Path.Prepend("project", path, success);
    Path.Append("bin", path, success);
    PathLists.Append(path, pathList, success);
    
    PrintPathList("Project paths", pathList);
    Out.Ln;
    
    (* Clean up *)
    PathLists.Free(pathList);
    Out.String("PathList freed."); Out.Ln;
    Out.Ln;
    Out.String("=== Path and PathLists Example Complete ==="); Out.Ln
END ExamplePathAndPathLists.
