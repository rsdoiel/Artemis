/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"
#include "Chars.oh"
#include "Path.oh"

typedef
	struct PathLists_PathListDesc *PathLists_PathList;

typedef
	struct PathLists_PathListDesc {
		CHAR part[1024];
		PathLists_PathList next;
	} PathLists_PathListDesc;


static CHAR PathLists_delimiter;

export SYSTEM_ADRINT *PathLists_PathListDesc__typ;

export void PathLists_Append (CHAR *path, INTEGER path__len, PathLists_PathList *pathList, BOOLEAN *success);
export BOOLEAN PathLists_Apply (CHAR *path, INTEGER path__len, INTEGER operation, CHAR *pathListString, INTEGER pathListString__len);
export void PathLists_Cut (CHAR *path, INTEGER path__len, PathLists_PathList *pathList, BOOLEAN *success);
export void PathLists_Decode (CHAR *pathListString, INTEGER pathListString__len, PathLists_PathList *pathList, BOOLEAN success);
export void PathLists_Encode (PathLists_PathList pathList, CHAR delimiter, CHAR *pathListString, INTEGER pathListString__len, BOOLEAN *success);
export INTEGER PathLists_Find (CHAR *path, INTEGER path__len, PathLists_PathList pathList);
export INTEGER PathLists_Length (PathLists_PathList pathList);
export void PathLists_Prepend (CHAR *path, INTEGER path__len, PathLists_PathList *pathList, BOOLEAN *success);
static void PathLists_SetDelimiter (CHAR c);


/*============================================================================*/

INTEGER PathLists_Length (PathLists_PathList pathList)
{
	INTEGER res;
	PathLists_PathList cur = NIL;
	res = 0;
	cur = pathList;
	while (cur != NIL) {
		res += 1;
		cur = cur->next;
	}
	return res;
}

/*----------------------------------------------------------------------------*/
INTEGER PathLists_Find (CHAR *path, INTEGER path__len, PathLists_PathList pathList)
{
	INTEGER res, pos;
	PathLists_PathList cur = NIL;
	res = -1;
	pos = 0;
	cur = pathList;
	while (cur != NIL && res == -1) {
		if (Chars_Equal((void*)cur->part, 1024, (void*)path, path__len)) {
			res = pos;
		}
		pos += 1;
		cur = cur->next;
	}
	return res;
}

/*----------------------------------------------------------------------------*/
void PathLists_Prepend (CHAR *path, INTEGER path__len, PathLists_PathList *pathList, BOOLEAN *success)
{
	*success = 0;
}

/*----------------------------------------------------------------------------*/
void PathLists_Append (CHAR *path, INTEGER path__len, PathLists_PathList *pathList, BOOLEAN *success)
{
	*success = 0;
}

/*----------------------------------------------------------------------------*/
void PathLists_Cut (CHAR *path, INTEGER path__len, PathLists_PathList *pathList, BOOLEAN *success)
{
	*success = 0;
}

/*----------------------------------------------------------------------------*/
static void PathLists_SetDelimiter (CHAR c)
{
	PathLists_delimiter = c;
}

void PathLists_Encode (PathLists_PathList pathList, CHAR delimiter, CHAR *pathListString, INTEGER pathListString__len, BOOLEAN *success)
{
	*success = 0;
}

/*----------------------------------------------------------------------------*/
void PathLists_Decode (CHAR *pathListString, INTEGER pathListString__len, PathLists_PathList *pathList, BOOLEAN success)
{
	success = 0;
}

/*----------------------------------------------------------------------------*/
BOOLEAN PathLists_Apply (CHAR *path, INTEGER path__len, INTEGER operation, CHAR *pathListString, INTEGER pathListString__len)
{
	BOOLEAN success;
	PathLists_PathList pathList = NIL;
	PathLists_Decode((void*)pathListString, pathListString__len, &pathList, success);
	if (success) {
		if (operation == 1) {
			PathLists_Prepend((void*)path, path__len, &pathList, &success);
		} else if (operation == 2) {
			PathLists_Append((void*)path, path__len, &pathList, &success);
		} else if (operation == 3) {
			PathLists_Cut((void*)path, path__len, &pathList, &success);
		}
	}
	return success;
}

/*----------------------------------------------------------------------------*/
__TDESC(PathLists_PathListDesc__desc, 2, 1) = {__TDFLDS("PathListDesc", 1028), {1024, -8}};

export void *PathLists__init (void)
{
	__DEFMOD;
	__IMPORT(Chars__init);
	__IMPORT(Path__init);
	__REGMOD("PathLists", 0);
	__INITYP(PathLists_PathListDesc, PathLists_PathListDesc, 0);
/* BEGIN */
	PathLists_SetDelimiter(':');
	__ENDMOD;
}
