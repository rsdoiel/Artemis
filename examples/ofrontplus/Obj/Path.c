/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"
#include "Chars.oh"
#include "Out.oh"


export CHAR Path_delimiter;


export void Path_Append (CHAR *suffix, INTEGER suffix__len, CHAR *path, INTEGER path__len, BOOLEAN *success);
export void Path_Basename (CHAR *source, INTEGER source__len, CHAR *dest, INTEGER dest__len, BOOLEAN success);
export void Path_Prepend (CHAR *prefix, INTEGER prefix__len, CHAR *path, INTEGER path__len, BOOLEAN *success);
export void Path_SetDelimiter (CHAR c);


/*============================================================================*/

void Path_SetDelimiter (CHAR c)
{
	Path_delimiter = c;
}

/*----------------------------------------------------------------------------*/
void Path_Prepend (CHAR *prefix, INTEGER prefix__len, CHAR *path, INTEGER path__len, BOOLEAN *success)
{
	CHAR tmp[1024];
	INTEGER l1, l2;
	CHAR delim[2];
	*success = 0;
	tmp[0] = 0x00;
	delim[0] = Path_delimiter;
	delim[1] = 0x00;
	l1 = Chars_Length((void*)prefix, prefix__len);
	l2 = Chars_Length((void*)path, path__len);
	if ((l1 + l2) + 1 < 1024) {
		if (l1 > 0) {
			Chars_Copy((void*)prefix, prefix__len, (void*)tmp, 1024);
		}
		if ((l2 > 0 && Chars_EndsWith((void*)delim, 2, (void*)tmp, 1024) == 0) && Chars_StartsWith((void*)delim, 2, (void*)path, path__len) == 0) {
			Chars_AppendChar(Path_delimiter, (void*)tmp, 1024);
		}
		if (l2 > 0) {
			Chars_Append((void*)path, path__len, (void*)tmp, 1024);
		}
		if (Chars_Length((void*)tmp, 1024) > 0) {
			Chars_Copy((void*)tmp, 1024, (void*)path, path__len);
		}
		*success = 1;
	}
}

/*----------------------------------------------------------------------------*/
void Path_Append (CHAR *suffix, INTEGER suffix__len, CHAR *path, INTEGER path__len, BOOLEAN *success)
{
	INTEGER l1, l2;
	CHAR delim[2];
	*success = 0;
	l1 = Chars_Length((void*)suffix, suffix__len);
	l2 = Chars_Length((void*)path, path__len);
	delim[0] = Path_delimiter;
	delim[1] = 0x00;
	if ((l1 + l2) + 1 < path__len) {
		if (l1 > 0) {
			if (Chars_StartsWith((void*)delim, 2, (void*)suffix, suffix__len) == 0 && Chars_EndsWith((void*)delim, 2, (void*)path, path__len) == 0) {
				Chars_Append((void*)delim, 2, (void*)path, path__len);
			}
			Chars_Append((void*)suffix, suffix__len, (void*)path, path__len);
		}
		*success = 1;
	}
}

/*----------------------------------------------------------------------------*/
void Path_Basename (CHAR *source, INTEGER source__len, CHAR *dest, INTEGER dest__len, BOOLEAN success)
{
	INTEGER offset, l, i;
	CHAR c;
	l = Chars_Length((void*)source, source__len);
	success = l < dest__len;
	if (success) {
		dest[0] = 0x00;
		offset = -1;
		while (i > 0 && offset == -1) {
			if (c == Path_delimiter) {
				offset = i + 1;
			}
			i -= 1;
		}
		if (offset > -1 && offset < l) {
			l = l - offset;
			i = 0;
			while (i <= l) {
				dest[__X(i, dest__len, (CHAR*)"Path", 21033)] = source[__X(offset, source__len, (CHAR*)"Path", 21033)];
				offset += 1;
				i += 1;
			}
			dest[__X(l, dest__len, (CHAR*)"Path", 21785)] = 0x00;
		} else {
			Chars_Copy((void*)source, source__len, (void*)dest, dest__len);
		}
	}
}

/*----------------------------------------------------------------------------*/

export void *Path__init (void)
{
	__DEFMOD;
	__IMPORT(Chars__init);
	__IMPORT(Out__init);
	__REGMOD("Path", 0);
/* BEGIN */
	Path_SetDelimiter('/');
	__ENDMOD;
}
