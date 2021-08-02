/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"
#include "Chars.oh"
#include "extConvert.oh"
#include "Strings.oh"
#include "Out.oh"

typedef
	struct DStrings_StringDesc *DStrings_String;

typedef
	struct DStrings_Rider {
		DStrings_String start, cursor;
		INTEGER pos;
		BOOLEAN eot;
	} DStrings_Rider;

typedef
	struct DStrings_StringDesc {
		CHAR c;
		DStrings_String next;
	} DStrings_StringDesc;



export SYSTEM_ADRINT *DStrings_StringDesc__typ;
export SYSTEM_ADRINT *DStrings_Rider__typ;

export void DStrings_Append (DStrings_String extra, DStrings_String *dest);
export DStrings_String DStrings_Base (DStrings_Rider *r, SYSTEM_ADRINT *r__typ);
export void DStrings_Cap (DStrings_String *s);
export void DStrings_Clear (DStrings_String *dest);
export void DStrings_Copy (DStrings_String source, DStrings_String *dest);
export void DStrings_CopyChars (CHAR *source, INTEGER source__len, DStrings_String *dest);
export void DStrings_Delete (DStrings_String *s, INTEGER pos, INTEGER n);
export BOOLEAN DStrings_EndsWith (DStrings_String suffix, DStrings_String source);
export BOOLEAN DStrings_Equal (DStrings_String s1, DStrings_String s2);
export void DStrings_Extract (DStrings_String source, INTEGER pos, INTEGER n, DStrings_String *dest);
export CHAR DStrings_Get (DStrings_Rider *r, SYSTEM_ADRINT *r__typ);
export void DStrings_Init (CHAR *str, INTEGER str__len, DStrings_String *s);
export void DStrings_Insert (DStrings_String source, INTEGER pos, DStrings_String *dest);
export INTEGER DStrings_Length (DStrings_String s);
export CHAR DStrings_Peek (DStrings_Rider *r, SYSTEM_ADRINT *r__typ);
export INTEGER DStrings_Pos (DStrings_String pattern, DStrings_String source, INTEGER pos);
export void DStrings_Prune (DStrings_String *s);
export void DStrings_Put (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR c);
export void DStrings_Quote (CHAR leftQuote, CHAR rightQuote, DStrings_String *source);
export void DStrings_Read (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *value);
export void DStrings_ReadBool (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, BOOLEAN *value);
export void DStrings_ReadBytes (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *buf, INTEGER buf__len, INTEGER n);
export void DStrings_ReadChar (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *value);
export void DStrings_ReadDString (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, DStrings_String *dest);
export void DStrings_ReadFixed (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SHORTREAL *value, INTEGER n);
export void DStrings_ReadInt (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, INTEGER *value);
export void DStrings_ReadReal (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SHORTREAL *value);
export void DStrings_ReadSet (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SET *value);
export void DStrings_ReadString (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *dest, INTEGER dest__len);
export void DStrings_Replace (DStrings_String source, INTEGER pos, DStrings_String *dest);
export void DStrings_Set (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, DStrings_String s, INTEGER pos);
export BOOLEAN DStrings_StartsWith (DStrings_String prefix, DStrings_String source);
export void DStrings_ToChars (DStrings_String s, CHAR *str, INTEGER str__len, INTEGER *res);
export void DStrings_Trim (CHAR *cutset, INTEGER cutset__len, DStrings_String *source);
export void DStrings_TrimLeft (CHAR *cutset, INTEGER cutset__len, DStrings_String *source);
export void DStrings_TrimPrefix (DStrings_String prefix, DStrings_String *source);
export void DStrings_TrimRight (CHAR *cutset, INTEGER cutset__len, DStrings_String *source);
export void DStrings_TrimSpace (DStrings_String *source);
export void DStrings_TrimSpaceLeft (DStrings_String *source);
export void DStrings_TrimSpaceRight (DStrings_String *source);
export void DStrings_TrimString (DStrings_String cutString, DStrings_String *source);
export void DStrings_TrimSuffix (DStrings_String suffix, DStrings_String *source);
export void DStrings_Write (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR value);
export void DStrings_WriteBool (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, BOOLEAN value);
export void DStrings_WriteBytes (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *buf, INTEGER buf__len, INTEGER n);
export void DStrings_WriteChar (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR value);
export void DStrings_WriteDString (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, DStrings_String source);
export void DStrings_WriteFixed (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SHORTREAL value, INTEGER n);
export void DStrings_WriteInt (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, INTEGER value);
export void DStrings_WriteReal (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SHORTREAL value);
export void DStrings_WriteSet (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SET value);
export void DStrings_WriteString (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *value, INTEGER value__len);
static INTEGER DStrings_minimum (INTEGER a, INTEGER b);


/*============================================================================*/

static INTEGER DStrings_minimum (INTEGER a, INTEGER b)
{
	INTEGER res;
	if (a < b) {
		res = a;
	} else {
		res = b;
	}
	return res;
}

void DStrings_Init (CHAR *str, INTEGER str__len, DStrings_String *s)
{
	INTEGER i;
	DStrings_String cur = NIL;
	if (*s == NIL) {
		__NEW(*s, DStrings_StringDesc);
		(*s)->next = NIL;
	}
	(*s)->c = 0x00;
	cur = *s;
	i = 0;
	while (i < str__len && str[__X(i, str__len, (CHAR*)"DStrings", 21798)] != 0x00) {
		cur->c = str[__X(i, str__len, (CHAR*)"DStrings", 22035)];
		if (cur->next == NIL) {
			__NEW(cur->next, DStrings_StringDesc);
			cur->next->next = NIL;
			cur->next->c = 0x00;
		} else {
			cur->next->c = 0x00;
		}
		i += 1;
		cur = cur->next;
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_Set (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, DStrings_String s, INTEGER pos)
{
	(*r).start = s;
	(*r).cursor = s;
	(*r).pos = 0;
	while (((*r).cursor != NIL && (*r).cursor->c != 0x00) && (*r).pos < pos) {
		(*r).pos += 1;
		(*r).cursor = (*r).cursor->next;
	}
	(*r).eot = (*r).cursor == NIL || (*r).cursor->c == 0x00;
}

/*----------------------------------------------------------------------------*/
DStrings_String DStrings_Base (DStrings_Rider *r, SYSTEM_ADRINT *r__typ)
{
	return (*r).start;
}

/*----------------------------------------------------------------------------*/
CHAR DStrings_Peek (DStrings_Rider *r, SYSTEM_ADRINT *r__typ)
{
	CHAR c;
	if ((*r).cursor != NIL) {
		c = (*r).cursor->c;
	} else {
		c = 0x00;
	}
	return c;
}

/*----------------------------------------------------------------------------*/
CHAR DStrings_Get (DStrings_Rider *r, SYSTEM_ADRINT *r__typ)
{
	CHAR c;
	c = DStrings_Peek(&*r, r__typ);
	if ((*r).cursor != NIL) {
		(*r).cursor = (*r).cursor->next;
		(*r).pos += 1;
	}
	if ((*r).cursor == NIL || (*r).cursor->c == 0x00) {
		(*r).eot = 1;
	} else {
		(*r).eot = 0;
	}
	return c;
}

/*----------------------------------------------------------------------------*/
void DStrings_Put (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR c)
{
	if ((*r).cursor == NIL) {
		__NEW((*r).cursor, DStrings_StringDesc);
		(*r).pos = 0;
		(*r).cursor->next = NIL;
	}
	(*r).cursor->c = c;
	if ((*r).cursor->next == NIL) {
		__NEW((*r).cursor->next, DStrings_StringDesc);
		(*r).cursor->next->c = 0x00;
		(*r).cursor->next->next = NIL;
	}
	(*r).cursor = (*r).cursor->next;
	(*r).pos += 1;
	if ((*r).cursor == NIL || (*r).cursor->c == 0x00) {
		(*r).eot = 1;
	} else {
		(*r).eot = 0;
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_Copy (DStrings_String source, DStrings_String *dest)
{
	DStrings_Rider r = {0}, w = {0};
	CHAR c;
	if (*dest == NIL) {
		DStrings_Init((CHAR*)"", 1, &*dest);
	}
	DStrings_Set(&r, DStrings_Rider__typ, source, 0);
	DStrings_Set(&w, DStrings_Rider__typ, *dest, 0);
	c = DStrings_Get(&r, DStrings_Rider__typ);
	while (c != 0x00) {
		DStrings_Put(&w, DStrings_Rider__typ, c);
		c = DStrings_Get(&r, DStrings_Rider__typ);
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_CopyChars (CHAR *source, INTEGER source__len, DStrings_String *dest)
{
	DStrings_Rider w = {0};
	INTEGER i;
	if (*dest == NIL) {
		DStrings_Init((CHAR*)"", 1, &*dest);
	}
	DStrings_Set(&w, DStrings_Rider__typ, *dest, 0);
	i = 0;
	while (source[__X(i, source__len, (CHAR*)"DStrings", 52248)] != 0x00) {
		DStrings_Put(&w, DStrings_Rider__typ, source[__X(i, source__len, (CHAR*)"DStrings", 52501)]);
		i += 1;
	}
	DStrings_Put(&w, DStrings_Rider__typ, 0x00);
}

/*----------------------------------------------------------------------------*/
void DStrings_Clear (DStrings_String *dest)
{
	DStrings_String cur = NIL;
	cur = *dest;
	while (cur != NIL) {
		cur->c = 0x00;
		cur = cur->next;
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_Prune (DStrings_String *s)
{
	DStrings_String cur = NIL;
	cur = *s;
	while (cur != NIL && cur->c != 0x00) {
		cur = cur->next;
	}
	if (cur != NIL && cur->c == 0x00) {
		cur->next = NIL;
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_ToChars (DStrings_String s, CHAR *str, INTEGER str__len, INTEGER *res)
{
	INTEGER i;
	DStrings_String cur = NIL;
	i = 0;
	*res = 0;
	cur = s;
	while ((i < str__len && cur != NIL) && cur->c != 0x00) {
		str[__X(i, str__len, (CHAR*)"DStrings", 63251)] = cur->c;
		i += 1;
		cur = cur->next;
	}
	if (i < str__len) {
		str[__X(i, str__len, (CHAR*)"DStrings", 64272)] = 0x00;
	} else if (i >= str__len - 1) {
		i = str__len - 1;
		str[__X(i, str__len, (CHAR*)"DStrings", 65040)] = 0x00;
		while (cur != NIL && cur->c != 0x00) {
			cur = cur->next;
			*res += 1;
		}
	}
}

/*----------------------------------------------------------------------------*/
INTEGER DStrings_Length (DStrings_String s)
{
	INTEGER i;
	DStrings_String cur = NIL;
	cur = s;
	i = 0;
	while (cur != NIL && cur->c != 0x00) {
		cur = cur->next;
		i += 1;
	}
	return i;
}

/*----------------------------------------------------------------------------*/
static struct Insert__13 {
	struct Insert__13 *lnk;
} *Insert__13_s;

static DStrings_String __14 (DStrings_Rider *r, SYSTEM_ADRINT *r__typ);

static DStrings_String __14 (DStrings_Rider *r, SYSTEM_ADRINT *r__typ)
{
	return (*r).cursor;
}

void DStrings_Insert (DStrings_String source, INTEGER pos, DStrings_String *dest)
{
	DStrings_String src = NIL;
	DStrings_String prev = NIL;
	DStrings_String rest = NIL;
	DStrings_Rider w = {0};
	CHAR c;
	struct Insert__13 _s;
	_s.lnk = Insert__13_s;
	Insert__13_s = &_s;
	DStrings_Copy(source, &src);
	if (pos > 0) {
		DStrings_Set(&w, DStrings_Rider__typ, *dest, pos - 1);
		prev = __14(&w, DStrings_Rider__typ);
		c = DStrings_Get(&w, DStrings_Rider__typ);
		rest = __14(&w, DStrings_Rider__typ);
		prev->next = src;
		while (prev->next != NIL && prev->next->c != 0x00) {
			prev = prev->next;
		}
		prev->next = rest;
	} else {
		DStrings_Set(&w, DStrings_Rider__typ, *dest, 0);
		prev = src;
		rest = __14(&w, DStrings_Rider__typ);
		rest = *dest;
		*dest = src;
		while (prev->next != NIL && prev->next->c != 0x00) {
			prev = prev->next;
		}
		prev->next = rest;
	}
	Insert__13_s = _s.lnk;
}

/*----------------------------------------------------------------------------*/
void DStrings_Append (DStrings_String extra, DStrings_String *dest)
{
	DStrings_String src = NIL;
	DStrings_String cur = NIL;
	DStrings_Copy(extra, &src);
	cur = *dest;
	if (cur != NIL && cur->c != 0x00) {
		while (cur->next != NIL && cur->next->c != 0x00) {
			cur = cur->next;
		}
		cur->next = src;
	} else {
		*dest = src;
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_Delete (DStrings_String *s, INTEGER pos, INTEGER n)
{
	DStrings_String cur = NIL;
	DStrings_String cut = NIL;
	INTEGER i, j;
	__ASSERT(pos >= 0, 0, (CHAR*)"DStrings", 85522);
	__ASSERT(pos < DStrings_Length(*s), 0, (CHAR*)"DStrings", 85785);
	if (*s != NIL) {
		cur = *s;
		i = 0;
		while (i < pos - 1 && cur->next != NIL) {
			cur = cur->next;
			i += 1;
		}
		j = 0;
		cut = cur;
		while (j < n && cut->next != NIL) {
			cut = cut->next;
			j += 1;
		}
		if (pos == 0) {
			*s = cut;
		} else {
			cur->next = cut->next;
		}
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_Replace (DStrings_String source, INTEGER pos, DStrings_String *dest)
{
	DStrings_Delete(&*dest, pos, DStrings_Length(source));
	DStrings_Insert(source, pos, &*dest);
}

/*----------------------------------------------------------------------------*/
void DStrings_Extract (DStrings_String source, INTEGER pos, INTEGER n, DStrings_String *dest)
{
	DStrings_String cur = NIL;
	DStrings_String copy = NIL;
	INTEGER i;
	cur = source;
	i = 0;
	while (i < pos && cur != NIL) {
		cur = cur->next;
		i += 1;
	}
	i = 0;
	if (*dest == NIL) {
		__NEW(*dest, DStrings_StringDesc);
		(*dest)->next = NIL;
		(*dest)->c = 0x00;
	}
	copy = *dest;
	copy->c = 0x00;
	while ((i < n && cur != NIL) && cur->c != 0x00) {
		copy->c = cur->c;
		if (copy->next == NIL) {
			__NEW(copy->next, DStrings_StringDesc);
			copy->next->next = NIL;
		}
		copy->next->c = 0x00;
		cur = cur->next;
		copy = copy->next;
		i += 1;
	}
}

/*----------------------------------------------------------------------------*/
INTEGER DStrings_Pos (DStrings_String pattern, DStrings_String source, INTEGER pos)
{
	INTEGER is, res;
	DStrings_Rider pr = {0}, sr = {0};
	CHAR a, b;
	__ASSERT(pos >= 0, 0, (CHAR*)"DStrings", 101906);
	__ASSERT(pos < DStrings_Length(source), 0, (CHAR*)"DStrings", 102174);
	is = pos;
	res = -1;
	a = 'a';
	while (res == -1 && a != 0x00) {
		DStrings_Set(&sr, DStrings_Rider__typ, source, is);
		DStrings_Set(&pr, DStrings_Rider__typ, pattern, 0);
		a = DStrings_Get(&sr, DStrings_Rider__typ);
		b = DStrings_Get(&pr, DStrings_Rider__typ);
		while ((a == b && a != 0x00) && b != 0x00) {
			a = DStrings_Get(&sr, DStrings_Rider__typ);
			b = DStrings_Get(&pr, DStrings_Rider__typ);
		}
		if (b == 0x00) {
			res = is;
		}
		is += 1;
	}
	return res;
}

/*----------------------------------------------------------------------------*/
void DStrings_Cap (DStrings_String *s)
{
	DStrings_String cur = NIL;
	cur = *s;
	while (cur != NIL && cur->c != 0x00) {
		if (cur->c >= 'a' && cur->c <= 'z') {
			cur->c = (CHAR)((65 + (INTEGER)cur->c) - 97);
		}
		cur = cur->next;
	}
}

/*----------------------------------------------------------------------------*/
BOOLEAN DStrings_Equal (DStrings_String s1, DStrings_String s2)
{
	BOOLEAN res;
	DStrings_Rider r1 = {0}, r2 = {0};
	CHAR c1, c2;
	DStrings_Set(&r1, DStrings_Rider__typ, s1, 0);
	DStrings_Set(&r2, DStrings_Rider__typ, s2, 0);
	res = 1;
	while ((res && r1.eot == 0) && r2.eot == 0) {
		c1 = DStrings_Get(&r1, DStrings_Rider__typ);
		c2 = DStrings_Get(&r2, DStrings_Rider__typ);
		if (c1 != c2) {
			res = 0;
		}
	}
	return res;
}

/*----------------------------------------------------------------------------*/
BOOLEAN DStrings_StartsWith (DStrings_String prefix, DStrings_String source)
{
	BOOLEAN res;
	DStrings_Rider pr = {0}, sr = {0};
	CHAR a, b;
	res = 1;
	DStrings_Set(&pr, DStrings_Rider__typ, prefix, 0);
	DStrings_Set(&sr, DStrings_Rider__typ, source, 0);
	a = ' ';
	b = ' ';
	while ((res && a != 0x00) && a == b) {
		a = DStrings_Get(&pr, DStrings_Rider__typ);
		b = DStrings_Get(&sr, DStrings_Rider__typ);
		if (a != 0x00 && a != b) {
			res = 0;
		}
	}
	return res;
}

/*----------------------------------------------------------------------------*/
BOOLEAN DStrings_EndsWith (DStrings_String suffix, DStrings_String source)
{
	INTEGER l1, l2;
	DStrings_Rider r1 = {0}, r2 = {0};
	CHAR c1, c2;
	BOOLEAN res;
	res = 1;
	l1 = DStrings_Length(suffix);
	l2 = DStrings_Length(source);
	DStrings_Set(&r1, DStrings_Rider__typ, suffix, 0);
	DStrings_Set(&r2, DStrings_Rider__typ, source, l2 - l1);
	while ((res == 1 && c1 != 0x00) && c2 != 0x00) {
		c1 = DStrings_Get(&r1, DStrings_Rider__typ);
		c2 = DStrings_Get(&r2, DStrings_Rider__typ);
		if (c1 != c2) {
			res = 0;
		}
	}
	return res;
}

/*----------------------------------------------------------------------------*/
void DStrings_TrimPrefix (DStrings_String prefix, DStrings_String *source)
{
	INTEGER l;
	if (DStrings_StartsWith(prefix, *source)) {
		l = DStrings_Length(prefix);
		DStrings_Delete(&*source, 0, l);
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_TrimSuffix (DStrings_String suffix, DStrings_String *source)
{
	INTEGER l1, l2, pos;
	if (DStrings_EndsWith(suffix, *source)) {
		l1 = DStrings_Length(suffix);
		l2 = DStrings_Length(*source);
		pos = l2 - l1;
		DStrings_Delete(&*source, pos, l1);
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_TrimString (DStrings_String cutString, DStrings_String *source)
{
	DStrings_TrimPrefix(cutString, &*source);
	DStrings_TrimSuffix(cutString, &*source);
}

/*----------------------------------------------------------------------------*/
void DStrings_TrimLeft (CHAR *cutset, INTEGER cutset__len, DStrings_String *source)
{
	DStrings_Rider r = {0};
	CHAR c;
	INTEGER l;
	DStrings_Set(&r, DStrings_Rider__typ, *source, 0);
	l = 0;
	c = DStrings_Get(&r, DStrings_Rider__typ);
	while (c != 0x00 && Chars_InCharList(c, (void*)cutset, cutset__len)) {
		c = DStrings_Get(&r, DStrings_Rider__typ);
		l += 1;
	}
	if (l > 0) {
		DStrings_Delete(&*source, 0, l - 1);
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_TrimRight (CHAR *cutset, INTEGER cutset__len, DStrings_String *source)
{
	DStrings_Rider r = {0};
	CHAR c;
	INTEGER l, pos;
	BOOLEAN inList;
	DStrings_Set(&r, DStrings_Rider__typ, *source, 0);
	inList = 0;
	l = 0;
	pos = -1;
	c = DStrings_Get(&r, DStrings_Rider__typ);
	while (c != 0x00) {
		if (inList == 0 && Chars_InCharList(c, (void*)cutset, cutset__len)) {
			pos = l;
			inList = 1;
		} else if (Chars_InCharList(c, (void*)cutset, cutset__len) == 0) {
			pos = -1;
			inList = 0;
		}
		c = DStrings_Get(&r, DStrings_Rider__typ);
		l += 1;
	}
	if (pos != -1 && l > 0) {
		DStrings_Delete(&*source, pos, l - pos);
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_Trim (CHAR *cutset, INTEGER cutset__len, DStrings_String *source)
{
	DStrings_TrimLeft((void*)cutset, cutset__len, &*source);
	DStrings_TrimRight((void*)cutset, cutset__len, &*source);
}

/*----------------------------------------------------------------------------*/
void DStrings_TrimSpaceLeft (DStrings_String *source)
{
	DStrings_TrimLeft((void*)Chars_spaces, 6, &*source);
}

/*----------------------------------------------------------------------------*/
void DStrings_TrimSpaceRight (DStrings_String *source)
{
	DStrings_TrimRight((void*)Chars_spaces, 6, &*source);
}

/*----------------------------------------------------------------------------*/
void DStrings_TrimSpace (DStrings_String *source)
{
	DStrings_TrimLeft((void*)Chars_spaces, 6, &*source);
	DStrings_TrimRight((void*)Chars_spaces, 6, &*source);
}

/*----------------------------------------------------------------------------*/
void DStrings_Quote (CHAR leftQuote, CHAR rightQuote, DStrings_String *source)
{
	DStrings_String cur = NIL;
	__NEW(cur, DStrings_StringDesc);
	cur->c = leftQuote;
	cur->next = *source;
	*source = cur;
	while (cur->next != NIL && cur->c != 0x00) {
		cur = cur->next;
	}
	if (cur->c == 0x00) {
		cur->c = rightQuote;
	} else {
		__NEW(cur->next, DStrings_StringDesc);
		cur = cur->next;
		cur->next = NIL;
		cur->c = rightQuote;
	}
	if (cur->next == NIL) {
		__NEW(cur->next, DStrings_StringDesc);
		cur = cur->next;
		cur->c = 0x00;
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_Read (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *value)
{
	CHAR c;
	c = DStrings_Get(&*r, r__typ);
	*value = (INTEGER)c;
}

/*----------------------------------------------------------------------------*/
void DStrings_ReadChar (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *value)
{
	*value = DStrings_Get(&*r, r__typ);
}

/*----------------------------------------------------------------------------*/
void DStrings_ReadInt (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, INTEGER *value)
{
	CHAR buf[25];
	INTEGER i, j;
	CHAR c;
	BOOLEAN done;
	c = ' ';
	while (Chars_IsDigit(DStrings_Peek(&*r, r__typ)) == 0 && c != 0x00) {
		c = DStrings_Get(&*r, r__typ);
	}
	if (Chars_IsDigit(DStrings_Peek(&*r, r__typ))) {
		i = 0;
		buf[0] = 0x00;
		buf[24] = 0x00;
		while (Chars_IsDigit(DStrings_Peek(&*r, r__typ)) && i < 24) {
			buf[__X(i, 25, (CHAR*)"DStrings", 167702)] = DStrings_Get(&*r, r__typ);
			i += 1;
			buf[__X(i, 25, (CHAR*)"DStrings", 167962)] = 0x00;
		}
		StringToInt((void*)buf, 25, &j, &done);
		if (done) {
			*value = j;
		}
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_ReadReal (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SHORTREAL *value)
{
	INTEGER i, l;
	SHORTREAL res;
	CHAR c;
	CHAR s[256];
	BOOLEAN done;
	l = 256;
	i = 0;
	while (i <= 255) {
		s[__X(i, 256, (CHAR*)"DStrings", 171048)] = 0x00;
		i += 1;
	}
	i = 0;
	c = ' ';
	while (Chars_IsDigit(DStrings_Peek(&*r, r__typ)) == 0 && c != 0x00) {
		c = DStrings_Get(&*r, r__typ);
	}
	if (Chars_IsDigit(DStrings_Peek(&*r, r__typ))) {
		while (Chars_IsDigit(DStrings_Peek(&*r, r__typ)) && i < l) {
			s[__X(i, 256, (CHAR*)"DStrings", 173332)] = DStrings_Get(&*r, r__typ);
			i += 1;
			s[__X(i, 256, (CHAR*)"DStrings", 173352)] = 0x00;
		}
		if (DStrings_Peek(&*r, r__typ) == '.') {
			s[__X(i, 256, (CHAR*)"DStrings", 174356)] = DStrings_Get(&*r, r__typ);
			i += 1;
			while (Chars_IsDigit(DStrings_Peek(&*r, r__typ)) && i < l) {
				s[__X(i, 256, (CHAR*)"DStrings", 174870)] = DStrings_Get(&*r, r__typ);
				i += 1;
				s[__X(i, 256, (CHAR*)"DStrings", 175130)] = 0x00;
			}
			StringToReal((void*)s, 256, &res, &done);
			if (done) {
				*value = res;
			}
		}
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_ReadString (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *dest, INTEGER dest__len)
{
	INTEGER i, l;
	DStrings_String s = NIL;
	CHAR c;
	s = DStrings_Base(&*r, r__typ);
	i = 0;
	l = DStrings_minimum(DStrings_Length(s), dest__len);
	dest[__X(l, dest__len, (CHAR*)"DStrings", 179259)] = 0x00;
	do {
		c = DStrings_Get(&*r, r__typ);
		dest[__X(i, dest__len, (CHAR*)"DStrings", 179741)] = c;
		i += 1;
	} while (!(i >= l || c == 0x00));
}

/*----------------------------------------------------------------------------*/
void DStrings_ReadDString (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, DStrings_String *dest)
{
	INTEGER pos, l;
	DStrings_String s = NIL;
	pos = (*r).pos;
	s = DStrings_Base(&*r, r__typ);
	l = DStrings_Length(s);
	DStrings_Extract(s, pos, l - pos, &*dest);
}

/*----------------------------------------------------------------------------*/
void DStrings_ReadBool (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, BOOLEAN *value)
{
	CHAR c;
	INTEGER i;
	c = DStrings_Peek(&*r, r__typ);
	while (c == ' ' && c != 0x00) {
		c = DStrings_Get(&*r, r__typ);
	}
	if (Chars_InCharList(c, (CHAR*)"0fF", 4)) {
		c = DStrings_Get(&*r, r__typ);
		*value = 0;
		c = DStrings_Peek(&*r, r__typ);
		if (c == 'a' || c == 'A') {
			i = 0;
			while (i <= 4) {
				c = DStrings_Get(&*r, r__typ);
				i += 1;
			}
		}
	} else if (Chars_InCharList(c, (CHAR*)"1tT", 4)) {
		c = DStrings_Get(&*r, r__typ);
		*value = 1;
		c = DStrings_Peek(&*r, r__typ);
		if (c == 'r' || c == 'R') {
			i = 0;
			while (i <= 3) {
				c = DStrings_Get(&*r, r__typ);
				i += 1;
			}
		}
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_ReadBytes (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *buf, INTEGER buf__len, INTEGER n)
{
	INTEGER i, l;
	CHAR c;
	l = DStrings_minimum(n, buf__len - 1);
	i = 0;
	while (i <= l) {
		c = DStrings_Get(&*r, r__typ);
		buf[__X(i, buf__len, (CHAR*)"DStrings", 191521)] = (INTEGER)c;
		i += 1;
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_ReadSet (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SET *value)
{
	CHAR c;
	INTEGER i, j, k;
	c = DStrings_Peek(&*r, r__typ);
	while (c == ' ' && c != 0x00) {
		c = DStrings_Get(&*r, r__typ);
	}
	if (c == '{') {
		while (Chars_InCharList(c, (CHAR*)"{},. 123456890", 15) && c != 0x00) {
			if (Chars_InCharList(c, (CHAR*)"1234567890", 11)) {
				DStrings_ReadInt(&*r, r__typ, &i);
				*value |= __SETOF(i);
				c = DStrings_Get(&*r, r__typ);
			} else if (c == '.') {
				c = DStrings_Get(&*r, r__typ);
				if (c == '.') {
					DStrings_ReadInt(&*r, r__typ, &j);
					k = i + 1;
					while (k <= j) {
						*value |= __SETOF(k);
						k += 1;
					}
				}
				c = DStrings_Get(&*r, r__typ);
			} else if (c == '}') {
				c = 0x00;
			} else {
				c = DStrings_Get(&*r, r__typ);
			}
		}
	}
}

/*----------------------------------------------------------------------------*/
static struct ReadFixed__27 {
	struct ReadFixed__27 *lnk;
} *ReadFixed__27_s;

static SHORTREAL __28 (SHORTREAL r, INTEGER n);

static SHORTREAL __28 (SHORTREAL r, INTEGER n)
{
	INTEGER i;
	SHORTREAL res;
	n = __ABS(n);
	if (n == 0) {
		res = (SHORTREAL)1;
	} else if (n == 1) {
		res = r;
	} else {
		res = r;
		i = 2;
		while (i <= n) {
			res = res * r;
			i += 1;
		}
	}
	return res;
}

void DStrings_ReadFixed (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SHORTREAL *value, INTEGER n)
{
	CHAR tmp[64];
	CHAR c;
	INTEGER i, l, h, f;
	BOOLEAN ok;
	struct ReadFixed__27 _s;
	_s.lnk = ReadFixed__27_s;
	ReadFixed__27_s = &_s;
	c = DStrings_Peek(&*r, r__typ);
	while (c == ' ' && c != 0x00) {
		c = DStrings_Get(&*r, r__typ);
	}
	if (Chars_IsDigit(c)) {
		i = 0;
		l = 64;
		while (i < l && Chars_IsDigit(c)) {
			tmp[__X(i, 64, (CHAR*)"DStrings", 208145)] = c;
			c = DStrings_Get(&*r, r__typ);
			i += 1;
		}
		tmp[__X(i, 64, (CHAR*)"DStrings", 208912)] = 0x00;
		if (c == '.') {
			StringToInt((void*)tmp, 64, &h, &ok);
			c = DStrings_Get(&*r, r__typ);
			tmp[0] = 0x00;
			i = 0;
			while (i < l && Chars_IsDigit(c)) {
				tmp[__X(i, 64, (CHAR*)"DStrings", 210451)] = c;
				c = DStrings_Get(&*r, r__typ);
				i += 1;
			}
			tmp[__X(i, 64, (CHAR*)"DStrings", 211218)] = 0x00;
			tmp[__X(n, 64, (CHAR*)"DStrings", 211730)] = 0x00;
			StringToInt((void*)tmp, 64, &f, &ok);
			*value = (SHORTREAL)h + (SHORTREAL)f * __28(0.1, n);
		}
	}
	ReadFixed__27_s = _s.lnk;
}

/*----------------------------------------------------------------------------*/
void DStrings_Write (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR value)
{
	DStrings_Put(&*r, r__typ, (CHAR)value);
}

/*----------------------------------------------------------------------------*/
void DStrings_WriteChar (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR value)
{
	DStrings_Put(&*r, r__typ, value);
}

/*----------------------------------------------------------------------------*/
void DStrings_WriteString (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *value, INTEGER value__len)
{
	INTEGER i, l;
	l = Length((void*)value, value__len) - 1;
	i = 0;
	while (i <= l) {
		DStrings_Put(&*r, r__typ, value[__X(i, value__len, (CHAR*)"DStrings", 218132)]);
		i += 1;
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_WriteDString (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, DStrings_String source)
{
	CHAR c;
	DStrings_Rider s = {0};
	DStrings_Set(&s, DStrings_Rider__typ, source, 0);
	c = DStrings_Get(&*r, r__typ);
	while (c != 0x00) {
		DStrings_Put(&s, DStrings_Rider__typ, c);
		c = DStrings_Get(&*r, r__typ);
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_WriteInt (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, INTEGER value)
{
	BOOLEAN ok;
	CHAR buf[1024];
	Chars_IntToString(value, (void*)buf, 1024, &ok);
	if (ok) {
		DStrings_WriteString(&*r, r__typ, (void*)buf, 1024);
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_WriteReal (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SHORTREAL value)
{
	BOOLEAN ok;
	CHAR buf[1024];
	Chars_RealToString(value, (void*)buf, 1024, &ok);
	if (ok) {
		DStrings_WriteString(&*r, r__typ, (void*)buf, 1024);
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_WriteBool (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, BOOLEAN value)
{
	CHAR s[7];
	if (value) {
		__MOVE("true", s, 5);
	} else {
		__MOVE("false", s, 6);
	}
	DStrings_WriteString(&*r, r__typ, (void*)s, 7);
}

/*----------------------------------------------------------------------------*/
void DStrings_WriteBytes (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, CHAR *buf, INTEGER buf__len, INTEGER n)
{
	INTEGER l, i;
	l = DStrings_minimum(buf__len, n) - 1;
	i = 0;
	while (i <= l) {
		DStrings_Write(&*r, r__typ, buf[__X(i, buf__len, (CHAR*)"DStrings", 230181)]);
		i += 1;
	}
}

/*----------------------------------------------------------------------------*/
void DStrings_WriteSet (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SET value)
{
	INTEGER i, j;
	BOOLEAN comma;
	DStrings_WriteChar(&*r, r__typ, '{');
	comma = 0;
	i = 0;
	while (i <= 32) {
		if (__IN(i, value)) {
			if (comma) {
				DStrings_WriteString(&*r, r__typ, (CHAR*)",", 2);
			} else {
				comma = 1;
			}
			DStrings_WriteInt(&*r, r__typ, i);
			if ((i != 32 && __IN(i, value)) && __IN(i + 1, value)) {
				j = i;
				while ((j != 32 && __IN(j, value)) && __IN(j + 1, value)) {
					j += 1;
				}
				if (j > i + 1) {
					i = j;
					DStrings_WriteString(&*r, r__typ, (CHAR*)"..", 3);
					DStrings_WriteInt(&*r, r__typ, i);
				}
			}
		}
		i += 1;
	}
	DStrings_WriteChar(&*r, r__typ, '}');
}

/*----------------------------------------------------------------------------*/
void DStrings_WriteFixed (DStrings_Rider *r, SYSTEM_ADRINT *r__typ, SHORTREAL value, INTEGER n)
{
	CHAR tmp[64];
	BOOLEAN ok;
	Chars_FixedToString(value, n, (void*)tmp, 64, &ok);
	if (ok) {
		DStrings_WriteString(&*r, r__typ, (void*)tmp, 64);
	}
}

/*----------------------------------------------------------------------------*/
__TDESC(DStrings_StringDesc__desc, 2, 1) = {__TDFLDS("StringDesc", 8), {4, -8}};
__TDESC(DStrings_Rider__desc, 1, 2) = {__TDFLDS("Rider", 16), {0, 4, -12}};

export void *DStrings__init (void)
{
	__DEFMOD;
	__IMPORT(Chars__init);
	__IMPORT(extConvert__init);
	__IMPORT(Out__init);
	__IMPORT(Strings__init);
	__REGMOD("DStrings", 0);
	__INITYP(DStrings_StringDesc, DStrings_StringDesc, 0);
	__INITYP(DStrings_Rider, DStrings_Rider, 0);
/* BEGIN */
	String((CHAR*)"", 1);
	__ENDMOD;
}
