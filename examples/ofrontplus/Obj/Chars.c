/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"
#include "Math.oh"


export CHAR Chars_spaces[6];
export CHAR Chars_punctuation[33];


export void Chars_Append (CHAR *source, INTEGER source__len, CHAR *dest, INTEGER dest__len);
export void Chars_AppendChar (CHAR c, CHAR *dest, INTEGER dest__len);
export void Chars_BoolToString (BOOLEAN val, CHAR *dest, INTEGER dest__len);
export void Chars_Cap (CHAR *source, INTEGER source__len);
export CHAR Chars_CapChar (CHAR source);
export void Chars_Clear (CHAR *a, INTEGER a__len);
export void Chars_Copy (CHAR *source, INTEGER source__len, CHAR *dest, INTEGER dest__len);
export void Chars_Delete (CHAR *source, INTEGER source__len, INTEGER pos, INTEGER n);
export BOOLEAN Chars_EndsWith (CHAR *suffix, INTEGER suffix__len, CHAR *source, INTEGER source__len);
export BOOLEAN Chars_Equal (CHAR *a, INTEGER a__len, CHAR *b, INTEGER b__len);
export void Chars_Extract (CHAR *source, INTEGER source__len, INTEGER pos, INTEGER n, CHAR *dest, INTEGER dest__len);
export void Chars_FixedToString (SHORTREAL value, INTEGER n, CHAR *dest, INTEGER dest__len, BOOLEAN *ok);
export BOOLEAN Chars_InCharList (CHAR c, CHAR *list, INTEGER list__len);
export BOOLEAN Chars_InRange (CHAR c, CHAR lower, CHAR upper);
export void Chars_Insert (CHAR *source, INTEGER source__len, INTEGER pos, CHAR *dest, INTEGER dest__len);
export void Chars_InsertChar (CHAR c, INTEGER pos, CHAR *dest, INTEGER dest__len);
export void Chars_IntToString (INTEGER value, CHAR *dest, INTEGER dest__len, BOOLEAN *ok);
export BOOLEAN Chars_IsAlpha (CHAR c);
export BOOLEAN Chars_IsAlphaNum (CHAR c);
export BOOLEAN Chars_IsDigit (CHAR c);
export BOOLEAN Chars_IsLower (CHAR c);
export BOOLEAN Chars_IsPrintable (CHAR c);
export BOOLEAN Chars_IsPunctuation (CHAR c);
export BOOLEAN Chars_IsSpace (CHAR c);
export BOOLEAN Chars_IsUpper (CHAR c);
export void Chars_LeftPad (CHAR pad, INTEGER width, CHAR *dest, INTEGER dest__len);
export INTEGER Chars_Length (CHAR *source, INTEGER source__len);
export void Chars_Pad (CHAR pad, INTEGER width, CHAR *dest, INTEGER dest__len);
export CHAR Chars_Pop (CHAR *source, INTEGER source__len);
export INTEGER Chars_Pos (CHAR *pattern, INTEGER pattern__len, CHAR *source, INTEGER source__len, INTEGER pos);
export void Chars_Quote (CHAR leftQuote, CHAR rightQuote, CHAR *dest, INTEGER dest__len);
export void Chars_RealToString (SHORTREAL r, CHAR *dest, INTEGER dest__len, BOOLEAN *ok);
export void Chars_Replace (CHAR *source, INTEGER source__len, INTEGER pos, CHAR *dest, INTEGER dest__len);
export void Chars_RightPad (CHAR pad, INTEGER width, CHAR *dest, INTEGER dest__len);
export void Chars_SetToString (SET set, CHAR *dest, INTEGER dest__len);
export CHAR Chars_Shift (CHAR *source, INTEGER source__len);
export BOOLEAN Chars_StartsWith (CHAR *prefix, INTEGER prefix__len, CHAR *source, INTEGER source__len);
export void Chars_Trim (CHAR *cutset, INTEGER cutset__len, CHAR *source, INTEGER source__len);
export void Chars_TrimLeft (CHAR *cutset, INTEGER cutset__len, CHAR *source, INTEGER source__len);
export void Chars_TrimLeftSpace (CHAR *source, INTEGER source__len);
export void Chars_TrimPrefix (CHAR *prefix, INTEGER prefix__len, CHAR *source, INTEGER source__len);
export void Chars_TrimRight (CHAR *cutset, INTEGER cutset__len, CHAR *source, INTEGER source__len);
export void Chars_TrimRightSpace (CHAR *source, INTEGER source__len);
export void Chars_TrimSpace (CHAR *source, INTEGER source__len);
export void Chars_TrimString (CHAR *cutString, INTEGER cutString__len, CHAR *source, INTEGER source__len);
export void Chars_TrimSuffix (CHAR *suffix, INTEGER suffix__len, CHAR *source, INTEGER source__len);
static void Chars_flip (CHAR *dest, INTEGER dest__len);
static INTEGER Chars_length (CHAR *source, INTEGER source__len);
static INTEGER Chars_minimum (INTEGER a, INTEGER b);


/*============================================================================*/

static INTEGER Chars_minimum (INTEGER a, INTEGER b)
{
	INTEGER res;
	if (a < b) {
		res = a;
	} else {
		res = b;
	}
	return res;
}

static INTEGER Chars_length (CHAR *source, INTEGER source__len)
{
	INTEGER res;
	res = 0;
	while (res < source__len && source[__X(res, source__len, (CHAR*)"Chars", 22064)] != 0x00) {
		res += 1;
	}
	return res;
}

static void Chars_flip (CHAR *dest, INTEGER dest__len)
{
	INTEGER start, end;
	CHAR ch;
	start = 0;
	end = Chars_length((void*)dest, dest__len) - 1;
	while (start < end) {
		ch = dest[__X(start, dest__len, (CHAR*)"Chars", 24597)];
		dest[__X(start, dest__len, (CHAR*)"Chars", 24860)] = dest[__X(end, dest__len, (CHAR*)"Chars", 24860)];
		dest[__X(end, dest__len, (CHAR*)"Chars", 25107)] = ch;
		start += 1;
		end -= 1;
	}
}

BOOLEAN Chars_InRange (CHAR c, CHAR lower, CHAR upper)
{
	BOOLEAN inrange;
	if ((INTEGER)c >= (INTEGER)lower && (INTEGER)c <= (INTEGER)upper) {
		inrange = 1;
	} else {
		inrange = 0;
	}
	return inrange;
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_InCharList (CHAR c, CHAR *list, INTEGER list__len)
{
	BOOLEAN inList;
	INTEGER i;
	inList = 0;
	i = 0;
	while ((inList == 0 && i < list__len) && list[__X(i, list__len, (CHAR*)"Chars", 32827)] != 0x00) {
		if (c == list[__X(i, list__len, (CHAR*)"Chars", 33543)]) {
			inList = 1;
		}
		i += 1;
	}
	return inList;
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_IsUpper (CHAR c)
{
	BOOLEAN isUpper;
	if (Chars_InRange(c, 'A', 'Z')) {
		isUpper = 1;
	} else {
		isUpper = 0;
	}
	return isUpper;
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_IsLower (CHAR c)
{
	BOOLEAN isLower;
	if (Chars_InRange(c, 'a', 'z')) {
		isLower = 1;
	} else {
		isLower = 0;
	}
	return isLower;
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_IsDigit (CHAR c)
{
	return Chars_InCharList(c, (CHAR*)"0123456789", 11);
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_IsAlpha (CHAR c)
{
	BOOLEAN isAlpha;
	if (Chars_IsUpper(c) || Chars_IsLower(c)) {
		isAlpha = 1;
	} else {
		isAlpha = 0;
	}
	return isAlpha;
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_IsAlphaNum (CHAR c)
{
	BOOLEAN isAlphaNum;
	if (Chars_IsAlpha(c) || Chars_IsDigit(c)) {
		isAlphaNum = 1;
	} else {
		isAlphaNum = 0;
	}
	return isAlphaNum;
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_IsSpace (CHAR c)
{
	return Chars_InCharList(c, (void*)Chars_spaces, 6);
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_IsPunctuation (CHAR c)
{
	return Chars_InCharList(c, (void*)Chars_punctuation, 33);
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_IsPrintable (CHAR c)
{
	return c >= '2';
}

/*----------------------------------------------------------------------------*/
INTEGER Chars_Length (CHAR *source, INTEGER source__len)
{
	return Chars_length((void*)source, source__len);
}

/*----------------------------------------------------------------------------*/
void Chars_Insert (CHAR *source, INTEGER source__len, INTEGER pos, CHAR *dest, INTEGER dest__len)
{
	INTEGER sourceLength, sourceSize, destLength, destSize, newLength, i, offset;
	sourceLength = Chars_Length((void*)source, source__len);
	sourceSize = source__len;
	destLength = Chars_Length((void*)dest, dest__len);
	destSize = dest__len;
	__ASSERT(pos >= 0, 0, (CHAR*)"Chars", 59410);
	__ASSERT(pos <= destLength, 0, (CHAR*)"Chars", 59675);
	newLength = Chars_minimum(destLength + sourceLength, destSize);
	dest[__X(newLength, dest__len, (CHAR*)"Chars", 60183)] = 0x00;
	i = newLength - 1;
	offset = i - sourceLength;
	while (i >= pos + sourceLength) {
		dest[__X(i, dest__len, (CHAR*)"Chars", 61467)] = dest[__X(offset, dest__len, (CHAR*)"Chars", 61467)];
		i -= 1;
		offset -= 1;
	}
	i = 0;
	offset = pos;
	while (i < sourceLength && offset < destSize) {
		dest[__X(offset, dest__len, (CHAR*)"Chars", 63005)] = source[__X(i, source__len, (CHAR*)"Chars", 63005)];
		i += 1;
		offset += 1;
	}
}

/*----------------------------------------------------------------------------*/
void Chars_Append (CHAR *source, INTEGER source__len, CHAR *dest, INTEGER dest__len)
{
	INTEGER i, j;
	i = 0;
	while (i < dest__len && dest[__X(i, dest__len, (CHAR*)"Chars", 66088)] != 0x00) {
		i += 1;
	}
	j = 0;
	while (i < dest__len && j < Chars_Length((void*)source, source__len)) {
		dest[__X(i, dest__len, (CHAR*)"Chars", 66840)] = source[__X(j, source__len, (CHAR*)"Chars", 66840)];
		i += 1;
		j += 1;
	}
	while (i < dest__len) {
		dest[__X(i, dest__len, (CHAR*)"Chars", 67622)] = 0x00;
		i += 1;
	}
}

/*----------------------------------------------------------------------------*/
void Chars_Delete (CHAR *source, INTEGER source__len, INTEGER pos, INTEGER n)
{
	INTEGER i, n1, sourceLength, newLength, offset;
	sourceLength = Chars_Length((void*)source, source__len);
	__ASSERT(pos >= 0, 0, (CHAR*)"Chars", 69906);
	__ASSERT(pos <= sourceLength, 0, (CHAR*)"Chars", 70173);
	__ASSERT(n >= 0, 0, (CHAR*)"Chars", 70416);
	n1 = Chars_minimum(n, sourceLength - pos);
	newLength = sourceLength - n1;
	i = pos;
	offset = i + n1;
	while (i < sourceLength - n1) {
		source[__X(i, source__len, (CHAR*)"Chars", 71711)] = source[__X(offset, source__len, (CHAR*)"Chars", 71711)];
		i += 1;
		offset += 1;
	}
	source[__X(newLength, source__len, (CHAR*)"Chars", 72473)] = 0x00;
}

/*----------------------------------------------------------------------------*/
void Chars_Replace (CHAR *source, INTEGER source__len, INTEGER pos, CHAR *dest, INTEGER dest__len)
{
	Chars_Delete((void*)dest, dest__len, pos, Chars_Length((void*)source, source__len));
	Chars_Insert((void*)source, source__len, pos, (void*)dest, dest__len);
}

/*----------------------------------------------------------------------------*/
void Chars_Extract (CHAR *source, INTEGER source__len, INTEGER pos, INTEGER n, CHAR *dest, INTEGER dest__len)
{
	INTEGER copyCount, sourceLength, destEnd, i, offset;
	sourceLength = Chars_Length((void*)source, source__len);
	destEnd = dest__len - 1;
	__ASSERT(pos >= 0, 0, (CHAR*)"Chars", 77842);
	__ASSERT(pos <= sourceLength, 0, (CHAR*)"Chars", 78109);
	copyCount = Chars_minimum(n, Chars_minimum(sourceLength - pos, destEnd));
	offset = pos;
	i = 0;
	while (i < copyCount && offset < destEnd) {
		dest[__X(i, dest__len, (CHAR*)"Chars", 79133)] = source[__X(offset, source__len, (CHAR*)"Chars", 79133)];
		i += 1;
		offset += 1;
	}
	i = copyCount;
	while (i <= destEnd) {
		dest[__X(i, dest__len, (CHAR*)"Chars", 80145)] = 0x00;
		i += 1;
	}
}

/*----------------------------------------------------------------------------*/
INTEGER Chars_Pos (CHAR *pattern, INTEGER pattern__len, CHAR *source, INTEGER source__len, INTEGER pos)
{
	INTEGER res, sourceLength, patternLength, i, j, offset;
	sourceLength = Chars_Length((void*)source, source__len);
	patternLength = Chars_Length((void*)pattern, pattern__len);
	__ASSERT(pos >= 0, 0, (CHAR*)"Chars", 83218);
	__ASSERT(pos <= sourceLength, 0, (CHAR*)"Chars", 83485);
	res = -1;
	if (patternLength <= sourceLength) {
		offset = pos;
		while (offset < sourceLength - patternLength && res == -1) {
			i = 0;
			j = offset;
			res = offset;
			while (((j < sourceLength && i < patternLength) && pattern[__X(i, pattern__len, (CHAR*)"Chars", 85091)] != 0x00) && source[__X(j, source__len, (CHAR*)"Chars", 85091)] == pattern[__X(i, pattern__len, (CHAR*)"Chars", 85091)]) {
				offset += 1;
				i += 1;
			}
			if (pattern[__X(i, pattern__len, (CHAR*)"Chars", 86281)] != 0x00) {
				res = -1;
			}
			offset += 1;
		}
	}
	return res;
}

/*----------------------------------------------------------------------------*/
void Chars_Cap (CHAR *source, INTEGER source__len)
{
	INTEGER i, sourceLength;
	sourceLength = Chars_Length((void*)source, source__len);
	i = 0;
	while (i <= sourceLength - 1) {
		if (Chars_IsLower(source[__X(i, source__len, (CHAR*)"Chars", 90375)])) {
			source[__X(i, source__len, (CHAR*)"Chars", 90174)] = (CHAR)((65 + (INTEGER)source[__X(i, source__len, (CHAR*)"Chars", 90174)]) - 97);
		}
		i += 1;
	}
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_Equal (CHAR *a, INTEGER a__len, CHAR *b, INTEGER b__len)
{
	BOOLEAN isSame;
	INTEGER i;
	isSame = Chars_Length((void*)a, a__len) == Chars_Length((void*)b, b__len);
	i = 0;
	while (isSame && i < Chars_Length((void*)a, a__len)) {
		if (a[__X(i, a__len, (CHAR*)"Chars", 94215)] != b[__X(i, b__len, (CHAR*)"Chars", 94215)]) {
			isSame = 0;
		}
		i += 1;
	}
	return isSame;
}

/*----------------------------------------------------------------------------*/
void Chars_RightPad (CHAR pad, INTEGER width, CHAR *dest, INTEGER dest__len)
{
	INTEGER i, p;
	CHAR padding[2];
	__ASSERT(width < dest__len, 0, (CHAR*)"Chars", 97819);
	padding[0] = pad;
	padding[1] = 0x00;
	p = (width - Chars_Length((void*)dest, dest__len)) - 1;
	if (p > 0) {
		i = 0;
		while (i <= p) {
			Chars_Append((void*)padding, 2, (void*)dest, dest__len);
			i += 1;
		}
	}
}

/*----------------------------------------------------------------------------*/
void Chars_LeftPad (CHAR pad, INTEGER width, CHAR *dest, INTEGER dest__len)
{
	INTEGER i, p;
	CHAR padding[2];
	__ASSERT(width < dest__len, 0, (CHAR*)"Chars", 101403);
	padding[0] = pad;
	padding[1] = 0x00;
	p = (width - Chars_Length((void*)dest, dest__len)) - 1;
	if (p > 0) {
		i = 0;
		while (i <= p) {
			Chars_Insert((void*)padding, 2, 0, (void*)dest, dest__len);
			i += 1;
		}
	}
}

/*----------------------------------------------------------------------------*/
void Chars_Pad (CHAR pad, INTEGER width, CHAR *dest, INTEGER dest__len)
{
	INTEGER i, p;
	CHAR padding[2];
	__ASSERT(width < dest__len, 0, (CHAR*)"Chars", 105243);
	padding[0] = pad;
	padding[1] = 0x00;
	p = __ASHR(width - Chars_Length((void*)dest, dest__len), 1, INTEGER) - 1;
	if (p > 0) {
		i = 0;
		while (i <= p) {
			Chars_Insert((void*)padding, 2, 0, (void*)dest, dest__len);
			Chars_Append((void*)padding, 2, (void*)dest, dest__len);
			i += 1;
		}
	}
}

/*----------------------------------------------------------------------------*/
CHAR Chars_CapChar (CHAR source)
{
	CHAR c;
	c = source;
	if (source >= 'a' && source <= 'z') {
		c = (CHAR)((65 + (INTEGER)source) - 97);
	}
	return c;
}

/*----------------------------------------------------------------------------*/
void Chars_InsertChar (CHAR c, INTEGER pos, CHAR *dest, INTEGER dest__len)
{
	CHAR ch[2];
	ch[0] = c;
	ch[1] = 0x00;
	Chars_Insert((void*)ch, 2, pos, (void*)dest, dest__len);
}

/*----------------------------------------------------------------------------*/
void Chars_AppendChar (CHAR c, CHAR *dest, INTEGER dest__len)
{
	CHAR ch[2];
	ch[0] = c;
	ch[1] = 0x00;
	Chars_Append((void*)ch, 2, (void*)dest, dest__len);
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_StartsWith (CHAR *prefix, INTEGER prefix__len, CHAR *source, INTEGER source__len)
{
	BOOLEAN startsWith;
	INTEGER i;
	startsWith = 0;
	if (Chars_Length((void*)prefix, prefix__len) <= Chars_Length((void*)source, source__len)) {
		startsWith = 1;
		i = 0;
		while (i < Chars_Length((void*)prefix, prefix__len) && startsWith) {
			if (prefix[__X(i, prefix__len, (CHAR*)"Chars", 118287)] != source[__X(i, source__len, (CHAR*)"Chars", 118287)]) {
				startsWith = 0;
			}
			i += 1;
		}
	}
	return startsWith;
}

/*----------------------------------------------------------------------------*/
BOOLEAN Chars_EndsWith (CHAR *suffix, INTEGER suffix__len, CHAR *source, INTEGER source__len)
{
	BOOLEAN endsWith;
	INTEGER i, j;
	endsWith = 0;
	if (Chars_Length((void*)suffix, suffix__len) <= Chars_Length((void*)source, source__len)) {
		endsWith = 1;
		i = 0;
		j = Chars_Length((void*)source, source__len) - Chars_Length((void*)suffix, suffix__len);
		while (i < Chars_Length((void*)suffix, suffix__len) && endsWith) {
			if (suffix[__X(i, suffix__len, (CHAR*)"Chars", 123407)] != source[__X(j, source__len, (CHAR*)"Chars", 123407)]) {
				endsWith = 0;
			}
			i += 1;
			j = j + 1;
		}
	}
	return endsWith;
}

/*----------------------------------------------------------------------------*/
void Chars_Copy (CHAR *source, INTEGER source__len, CHAR *dest, INTEGER dest__len)
{
	INTEGER i, ls, ld;
	ld = dest__len - 1;
	ls = Chars_Length((void*)source, source__len);
	i = 0;
	while (i <= ld) {
		if (i < ls) {
			dest[__X(i, dest__len, (CHAR*)"Chars", 128026)] = source[__X(i, source__len, (CHAR*)"Chars", 128026)];
		} else {
			dest[__X(i, dest__len, (CHAR*)"Chars", 128531)] = 0x00;
		}
		i += 1;
	}
}

/*----------------------------------------------------------------------------*/
void Chars_Clear (CHAR *a, INTEGER a__len)
{
	INTEGER i;
	i = 0;
	while (i <= a__len - 1) {
		a[__X(i, a__len, (CHAR*)"Chars", 131086)] = 0x00;
		i += 1;
	}
}

/*----------------------------------------------------------------------------*/
CHAR Chars_Shift (CHAR *source, INTEGER source__len)
{
	INTEGER i, last;
	CHAR c;
	i = 0;
	c = source[__X(i, source__len, (CHAR*)"Chars", 133650)];
	Chars_Delete((void*)source, source__len, 0, 1);
	last = Chars_Length((void*)source, source__len) - 1;
	i = last;
	while (i <= source__len - 1) {
		source[__X(i, source__len, (CHAR*)"Chars", 134679)] = 0x00;
		i += 1;
	}
	return c;
}

/*----------------------------------------------------------------------------*/
CHAR Chars_Pop (CHAR *source, INTEGER source__len)
{
	INTEGER i, last;
	CHAR c;
	i = 0;
	last = source__len;
	while (i < last && source[__X(i, source__len, (CHAR*)"Chars", 138021)] != 0x00) {
		i += 1;
	}
	if (i > 0) {
		i -= 1;
	} else {
		i = 0;
	}
	c = source[__X(i, source__len, (CHAR*)"Chars", 139536)];
	while (i < last) {
		source[__X(i, source__len, (CHAR*)"Chars", 140051)] = 0x00;
		i += 1;
	}
	return c;
}

/*----------------------------------------------------------------------------*/
void Chars_TrimLeft (CHAR *cutset, INTEGER cutset__len, CHAR *source, INTEGER source__len)
{
	INTEGER i;
	i = 0;
	while (i < source__len && Chars_InCharList(source[__X(i, source__len, (CHAR*)"Chars", 143419)], (void*)cutset, cutset__len)) {
		i += 1;
	}
	if (i > 0) {
		Chars_Delete((void*)source, source__len, 0, i);
	}
}

/*----------------------------------------------------------------------------*/
void Chars_TrimRight (CHAR *cutset, INTEGER cutset__len, CHAR *source, INTEGER source__len)
{
	INTEGER i, l;
	l = Chars_Length((void*)source, source__len);
	i = l - 1;
	while (i > 0 && Chars_InCharList(source[__X(i, source__len, (CHAR*)"Chars", 147503)], (void*)cutset, cutset__len)) {
		i -= 1;
	}
	Chars_Delete((void*)source, source__len, i + 1, l - i);
}

/*----------------------------------------------------------------------------*/
void Chars_Trim (CHAR *cutset, INTEGER cutset__len, CHAR *source, INTEGER source__len)
{
	Chars_TrimLeft((void*)cutset, cutset__len, (void*)source, source__len);
	Chars_TrimRight((void*)cutset, cutset__len, (void*)source, source__len);
}

/*----------------------------------------------------------------------------*/
void Chars_TrimLeftSpace (CHAR *source, INTEGER source__len)
{
	Chars_TrimLeft((void*)Chars_spaces, 6, (void*)source, source__len);
}

/*----------------------------------------------------------------------------*/
void Chars_TrimRightSpace (CHAR *source, INTEGER source__len)
{
	Chars_TrimRight((void*)Chars_spaces, 6, (void*)source, source__len);
}

/*----------------------------------------------------------------------------*/
void Chars_TrimSpace (CHAR *source, INTEGER source__len)
{
	Chars_TrimLeft((void*)Chars_spaces, 6, (void*)source, source__len);
	Chars_TrimRight((void*)Chars_spaces, 6, (void*)source, source__len);
}

/*----------------------------------------------------------------------------*/
void Chars_TrimPrefix (CHAR *prefix, INTEGER prefix__len, CHAR *source, INTEGER source__len)
{
	INTEGER l;
	if (Chars_StartsWith((void*)prefix, prefix__len, (void*)source, source__len)) {
		l = Chars_Length((void*)prefix, prefix__len);
		Chars_Delete((void*)source, source__len, 0, l);
	}
}

/*----------------------------------------------------------------------------*/
void Chars_TrimSuffix (CHAR *suffix, INTEGER suffix__len, CHAR *source, INTEGER source__len)
{
	INTEGER i, l;
	if (Chars_EndsWith((void*)suffix, suffix__len, (void*)source, source__len)) {
		l = Chars_Length((void*)source, source__len) - 1;
		i = (l - Chars_Length((void*)suffix, suffix__len)) + 1;
		while (i <= l) {
			source[__X(i, source__len, (CHAR*)"Chars", 160789)] = 0x00;
			i += 1;
		}
	}
}

/*----------------------------------------------------------------------------*/
void Chars_TrimString (CHAR *cutString, INTEGER cutString__len, CHAR *source, INTEGER source__len)
{
	Chars_TrimPrefix((void*)cutString, cutString__len, (void*)source, source__len);
	Chars_TrimSuffix((void*)cutString, cutString__len, (void*)source, source__len);
}

/*----------------------------------------------------------------------------*/
void Chars_Quote (CHAR leftQuote, CHAR rightQuote, CHAR *dest, INTEGER dest__len)
{
	CHAR lq[2], rq[2];
	lq[0] = leftQuote;
	lq[1] = 0x00;
	rq[0] = rightQuote;
	rq[1] = 0x00;
	Chars_Insert((void*)lq, 2, 0, (void*)dest, dest__len);
	Chars_Append((void*)rq, 2, (void*)dest, dest__len);
}

/*----------------------------------------------------------------------------*/
void Chars_IntToString (INTEGER value, CHAR *dest, INTEGER dest__len, BOOLEAN *ok)
{
	INTEGER x, i, m;
	*ok = 1;
	dest[0] = 0x00;
	i = 0;
	x = value;
	if (value == 0) {
		dest[0] = '0';
		dest[__X(1, dest__len, (CHAR*)"Chars", 169761)] = 0x00;
	} else {
		i = 0;
		if (value < 0) {
			dest[0] = '-';
			i += 1;
			x = __ABS(value);
		} else {
			x = value;
		}
		while (*ok && x != 0) {
			m = __MOD(x, 10);
			x = __DIV(x, 10);
			if (m <= 9) {
				dest[__X(i, dest__len, (CHAR*)"Chars", 173311)] = (CHAR)(m + 48);
			} else {
				dest[__X(i, dest__len, (CHAR*)"Chars", 173359)] = (CHAR)((m - 10) + 97);
			}
			i += 1;
			if (i >= dest__len) {
				*ok = 0;
			}
		}
		dest[__X(i, dest__len, (CHAR*)"Chars", 174865)] = 0x00;
		Chars_flip((void*)dest, dest__len);
	}
}

/*----------------------------------------------------------------------------*/
static struct RealToString__34 {
	struct RealToString__34 *lnk;
} *RealToString__34_s;

static void __35 (SHORTREAL r, INTEGER *h, INTEGER *m);

static void __35 (SHORTREAL r, INTEGER *h, INTEGER *m)
{
	SHORTREAL frac;
	*h = (INTEGER)__ENTIER(r);
	frac = r - (SHORTREAL)*h;
	if (frac != (SHORTREAL)0) {
		if (frac < (SHORTREAL)0) {
			frac = frac * (SHORTREAL)-1;
		}
		frac = frac * power((SHORTREAL)10, (SHORTREAL)10);
		*m = (INTEGER)__ENTIER(frac);
	} else {
		*m = 0;
	}
}

void Chars_RealToString (SHORTREAL r, CHAR *dest, INTEGER dest__len, BOOLEAN *ok)
{
	CHAR tmp[256];
	BOOLEAN ok2;
	INTEGER i, m;
	struct RealToString__34 _s;
	_s.lnk = RealToString__34_s;
	RealToString__34_s = &_s;
	dest[0] = 0x00;
	tmp[0] = 0x00;
	__35(r, &i, &m);
	Chars_IntToString(i, (void*)dest, dest__len, &*ok);
	Chars_Append((CHAR*)".", 2, (void*)dest, dest__len);
	Chars_IntToString(m, (void*)tmp, 256, &ok2);
	Chars_TrimRight((CHAR*)"0", 2, (void*)tmp, 256);
	Chars_Append((void*)tmp, 256, (void*)dest, dest__len);
	*ok = *ok && ok2;
	RealToString__34_s = _s.lnk;
}

/*----------------------------------------------------------------------------*/
static struct FixedToString__12 {
	struct FixedToString__12 *lnk;
} *FixedToString__12_s;

static void __13 (SHORTREAL r, INTEGER n, INTEGER *i, INTEGER *m);

static void __13 (SHORTREAL r, INTEGER n, INTEGER *i, INTEGER *m)
{
	SHORTREAL a, b;
	a = (SHORTREAL)((INTEGER)__ENTIER(r));
	b = (r - a) * power((SHORTREAL)10, (SHORTREAL)n);
	*i = (INTEGER)__ENTIER(r);
	*m = (INTEGER)__ENTIER(b);
}

void Chars_FixedToString (SHORTREAL value, INTEGER n, CHAR *dest, INTEGER dest__len, BOOLEAN *ok)
{
	INTEGER i, m;
	CHAR tmp[256];
	BOOLEAN ok1, ok2;
	struct FixedToString__12 _s;
	_s.lnk = FixedToString__12_s;
	FixedToString__12_s = &_s;
	__13(value, n, &i, &m);
	dest[0] = 0x00;
	tmp[0] = 0x00;
	Chars_IntToString(i, (void*)tmp, 256, &ok1);
	Chars_Append((void*)tmp, 256, (void*)dest, dest__len);
	Chars_Append((CHAR*)".", 2, (void*)dest, dest__len);
	Chars_IntToString(m, (void*)tmp, 256, &ok2);
	Chars_Append((void*)tmp, 256, (void*)dest, dest__len);
	*ok = ok1 && ok2;
	FixedToString__12_s = _s.lnk;
}

/*----------------------------------------------------------------------------*/
void Chars_SetToString (SET set, CHAR *dest, INTEGER dest__len)
{
	INTEGER i, j;
	BOOLEAN comma;
	CHAR s[3];
	BOOLEAN ok;
	Chars_Copy((CHAR*)"{", 2, (void*)dest, dest__len);
	i = 0;
	comma = 0;
	while (i <= 31) {
		if (__IN(i, set)) {
			if (comma) {
				Chars_Append((CHAR*)",", 2, (void*)dest, dest__len);
			} else {
				comma = 1;
			}
			Chars_IntToString(i, (void*)s, 3, &ok);
			Chars_Append((void*)s, 3, (void*)dest, dest__len);
			if (i != 31 && __IN(i + 1, set)) {
				j = i;
				while ((j != 31 && __IN(j, set)) && __IN(j + 1, set)) {
					j += 1;
				}
				if (j > i + 1) {
					i = j;
					Chars_Append((CHAR*)"..", 3, (void*)dest, dest__len);
					Chars_IntToString(i, (void*)s, 3, &ok);
					Chars_Append((void*)s, 3, (void*)dest, dest__len);
				}
			}
		}
		i += 1;
	}
	Chars_Append((CHAR*)"}", 2, (void*)dest, dest__len);
}

/*----------------------------------------------------------------------------*/
void Chars_BoolToString (BOOLEAN val, CHAR *dest, INTEGER dest__len)
{
	__ASSERT(dest__len >= 6, 0, (CHAR*)"Chars", 203544);
	if (val) {
		Chars_Copy((CHAR*)"true", 5, (void*)dest, dest__len);
	} else {
		Chars_Copy((CHAR*)"false", 6, (void*)dest, dest__len);
	}
}

/*----------------------------------------------------------------------------*/

export void *Chars__init (void)
{
	__DEFMOD;
	__IMPORT(Math__init);
	__REGMOD("Chars", 0);
/* BEGIN */
	Chars_spaces[0] = ' ';
	Chars_spaces[1] = 0x09;
	Chars_spaces[2] = 0x10;
	Chars_spaces[3] = 0x11;
	Chars_spaces[4] = 0x13;
	Chars_spaces[5] = 0x00;
	Chars_punctuation[0] = '`';
	Chars_punctuation[1] = '~';
	Chars_punctuation[2] = '!';
	Chars_punctuation[3] = '@';
	Chars_punctuation[4] = '#';
	Chars_punctuation[5] = '$';
	Chars_punctuation[6] = '%';
	Chars_punctuation[7] = '^';
	Chars_punctuation[8] = '&';
	Chars_punctuation[9] = '*';
	Chars_punctuation[10] = '(';
	Chars_punctuation[11] = ')';
	Chars_punctuation[12] = '_';
	Chars_punctuation[13] = '-';
	Chars_punctuation[14] = '+';
	Chars_punctuation[15] = '=';
	Chars_punctuation[16] = '{';
	Chars_punctuation[17] = '[';
	Chars_punctuation[18] = '}';
	Chars_punctuation[19] = ']';
	Chars_punctuation[20] = '|';
	Chars_punctuation[21] = '\\';
	Chars_punctuation[22] = ':';
	Chars_punctuation[23] = ';';
	Chars_punctuation[24] = '4';
	Chars_punctuation[25] = '\'';
	Chars_punctuation[26] = '<';
	Chars_punctuation[27] = ',';
	Chars_punctuation[28] = '>';
	Chars_punctuation[29] = '.';
	Chars_punctuation[30] = '\?';
	Chars_punctuation[31] = '/';
	Chars_punctuation[32] = 0x00;
	__ENDMOD;
}
