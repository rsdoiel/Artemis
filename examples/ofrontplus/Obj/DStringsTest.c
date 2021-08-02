/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"
#include "Tests.oh"
#include "DStrings.oh"
#include "Chars.oh"
#include "Out.oh"
#include "Strings.oh"
#include "extConvert.oh"


static Tests_TestSet DStringsTest_ts;


static void DStringsTest_ExpectedDString (DStrings_String expected, DStrings_String got, CHAR *msg, INTEGER msg__len, BOOLEAN *test);
static BOOLEAN DStringsTest_TestAppend (void);
static BOOLEAN DStringsTest_TestCap (void);
static BOOLEAN DStringsTest_TestCopy (void);
static BOOLEAN DStringsTest_TestDelete (void);
static BOOLEAN DStringsTest_TestExtract (void);
static BOOLEAN DStringsTest_TestInit (void);
static BOOLEAN DStringsTest_TestInsert (void);
static BOOLEAN DStringsTest_TestPos (void);
static BOOLEAN DStringsTest_TestReadProcs (void);
static BOOLEAN DStringsTest_TestReplace (void);
static BOOLEAN DStringsTest_TestRider (void);
static BOOLEAN DStringsTest_TestStartsWith (void);
static BOOLEAN DStringsTest_TestToChars (void);
static BOOLEAN DStringsTest_TestWriteProcs (void);
static void DStringsTest_displayString (DStrings_String str1, DStrings_String str2, CHAR *msg, INTEGER msg__len);


/*============================================================================*/

static void DStringsTest_displayString (DStrings_String str1, DStrings_String str2, CHAR *msg, INTEGER msg__len)
{
	INTEGER i, res;
	CHAR s1[1024], s2[1024];
	i = 0;
	while (i <= 1023) {
		s1[__X(i, 1024, (CHAR*)"DStringsTest", 4899)] = 0x00;
		s2[__X(i, 1024, (CHAR*)"DStringsTest", 4912)] = 0x00;
		i += 1;
	}
	DStrings_ToChars(str1, (void*)s1, 1024, &res);
	DStrings_ToChars(str2, (void*)s2, 1024, &res);
	String((CHAR*)"Expected \'", 11);
	String((void*)s1, 1024);
	String((CHAR*)"\', got \'", 9);
	String((void*)s2, 1024);
	String((CHAR*)"\' ", 3);
	String((void*)msg, msg__len);
	Ln();
}

static void DStringsTest_ExpectedDString (DStrings_String expected, DStrings_String got, CHAR *msg, INTEGER msg__len, BOOLEAN *test)
{
	if (DStrings_Equal(expected, got) == 0) {
		DStringsTest_displayString(expected, got, (void*)msg, msg__len);
		*test = 0;
	}
}

static BOOLEAN DStringsTest_TestInit (void)
{
	BOOLEAN test;
	DStrings_String str1 = NIL;
	DStrings_String str2 = NIL;
	DStrings_String str3 = NIL;
	INTEGER i;
	test = 1;
	DStrings_Init((CHAR*)"One Two Three", 14, &str1);
	i = DStrings_Length(str1);
	if (i != 13) {
		String((CHAR*)"Init failed, should have length of 13 for str1, got ", 53);
		Int(i, 1);
		Ln();
		test = 0;
	} else {
		DStrings_Init((CHAR*)"One Two Three", 14, &str2);
		if (DStrings_Equal(str1, str2) == 0) {
			test = 0;
			DStringsTest_displayString(str1, str2, (CHAR*)"expected equal strings", 23);
		} else {
			DStrings_Init((CHAR*)"One Four Five Six", 18, &str3);
			if (DStrings_Equal(str1, str3) == 1) {
				test = 0;
				DStringsTest_displayString(str1, str2, (CHAR*)"expected unequal strings", 25);
			}
		}
	}
	return test;
}

static BOOLEAN DStringsTest_TestToChars (void)
{
	BOOLEAN test;
	DStrings_String str = NIL;
	CHAR c;
	CHAR s[1024];
	INTEGER i, j, k, res;
	DStrings_Rider r = {0};
	test = 1;
	__MOVE("One Two Three", s, 14);
	i = Length((void*)s, 1024);
	DStrings_Init((void*)s, 1024, &str);
	j = DStrings_Length(str);
	if (i != j) {
		String((CHAR*)"Expected str length ", 21);
		Int(i, 1);
		String((CHAR*)", got ", 7);
		Int(j, 1);
		Ln();
		test = 0;
	} else {
		Chars_Clear((void*)s, 1024);
		k = Length((void*)s, 1024);
		if (k != 0) {
			String((CHAR*)"Expected to clear string s", 27);
			Ln();
			test = 0;
		}
		DStrings_ToChars(str, (void*)s, 1024, &res);
		if (res > 0) {
			String((CHAR*)"Expected all chars to get copied, ", 35);
			Int(res, 1);
			String((CHAR*)" not copied", 12);
			Ln();
			test = 0;
		}
		k = Length((void*)s, 1024);
		if (i != k) {
			String((CHAR*)"Expected copied string length ", 31);
			Int(i, 1);
			String((CHAR*)", got ", 7);
			Int(k, 1);
			Ln();
			test = 0;
		}
		i = 0;
		DStrings_Set(&r, DStrings_Rider__typ, str, 0);
		while (i < Length((void*)s, 1024) && test == 1) {
			c = DStrings_Get(&r, DStrings_Rider__typ);
			if (s[__X(i, 1024, (CHAR*)"DStringsTest", 27913)] != c) {
				String((CHAR*)"Expected char \'", 16);
				Char(s[__X(i, 1024, (CHAR*)"DStringsTest", 26676)]);
				String((CHAR*)"\', got ", 8);
				Char(c);
				String((CHAR*)" at position ", 14);
				Int(i, 1);
				Ln();
				test = 0;
			}
			i += 1;
		}
	}
	return test;
}

static BOOLEAN DStringsTest_TestRider (void)
{
	BOOLEAN test;
	DStrings_Rider r = {0};
	DStrings_String s = NIL;
	DStrings_String q = NIL;
	INTEGER i, j, k;
	CHAR c;
	CHAR t[256];
	test = 1;
	__MOVE("One Two Three Four Five", t, 24);
	DStrings_Init((CHAR*)"One Two Three Four Five", 24, &s);
	k = DStrings_Length(s);
	DStrings_Set(&r, DStrings_Rider__typ, s, 0);
	q = DStrings_Base(&r, DStrings_Rider__typ);
	if (s != q) {
		String((CHAR*)"Expected q to point to the same string as s", 44);
		test = 0;
	}
	i = 0;
	while (i < k) {
		c = DStrings_Peek(&r, DStrings_Rider__typ);
		j = r.pos;
		Tests_ExpectedInt(i, j, (CHAR*)"Peek r.pos", 11, &test);
		Tests_ExpectedChar(t[__X(i, 256, (CHAR*)"DStringsTest", 34607)], c, (CHAR*)"Peek r.pos", 11, &test);
		c = DStrings_Get(&r, DStrings_Rider__typ);
		j = r.pos;
		Tests_ExpectedChar(t[__X(i, 256, (CHAR*)"DStringsTest", 35118)], c, (CHAR*)"Get r.pos", 10, &test);
		Tests_ExpectedInt(i + 1, j, (CHAR*)"Get r.pos", 10, &test);
		i += 1;
	}
	DStrings_Init((CHAR*)"Eleven Twelve Thirteen Fourteen Fifteen", 40, &s);
	DStrings_Set(&r, DStrings_Rider__typ, s, 0);
	i = 0;
	while (i < k) {
		c = (CHAR)(i + 97);
		DStrings_Put(&r, DStrings_Rider__typ, c);
		Tests_ExpectedInt(i + 1, r.pos, (CHAR*)"Put, r.pos", 11, &test);
		i += 1;
	}
	DStrings_Set(&r, DStrings_Rider__typ, s, 0);
	i = 0;
	while (i < k) {
		c = DStrings_Get(&r, DStrings_Rider__typ);
		Tests_ExpectedChar(c, (CHAR)(i + 97), (CHAR*)"c := Get(r)", 12, &test);
		i += 1;
	}
	DStrings_Init((CHAR*)"", 1, &s);
	DStrings_Set(&r, DStrings_Rider__typ, s, 0);
	i = 0;
	while (i < k) {
		c = (CHAR)(i + 97);
		DStrings_Put(&r, DStrings_Rider__typ, c);
		Tests_ExpectedInt(i + 1, r.pos, (CHAR*)"Put, r.pos", 11, &test);
		i += 1;
	}
	DStrings_Set(&r, DStrings_Rider__typ, s, 0);
	i = 0;
	while (i < k) {
		c = DStrings_Get(&r, DStrings_Rider__typ);
		Tests_ExpectedChar(c, (CHAR)(i + 97), (CHAR*)"c := Get(r)", 12, &test);
		i += 1;
	}
	return test;
}

static BOOLEAN DStringsTest_TestCopy (void)
{
	BOOLEAN test;
	DStrings_String str1 = NIL;
	DStrings_String str2 = NIL;
	test = 1;
	DStrings_Init((CHAR*)"Twenty Thirty Fourty", 21, &str1);
	DStrings_Copy(str1, &str2);
	DStringsTest_ExpectedDString(str1, str2, (CHAR*)"Copy(str1,str2)", 16, &test);
	return test;
}

static BOOLEAN DStringsTest_TestInsert (void)
{
	BOOLEAN test;
	DStrings_String s1 = NIL;
	DStrings_String s2 = NIL;
	DStrings_String expected = NIL;
	test = 1;
	DStrings_Init((CHAR*)"one two three", 14, &expected);
	DStrings_Init((CHAR*)"two three", 10, &s1);
	DStrings_Init((CHAR*)"one ", 5, &s2);
	DStrings_Insert(s2, 0, &s1);
	DStringsTest_ExpectedDString(expected, s1, (CHAR*)"Insert(\'one \', 0, \'two three\')", 31, &test);
	DStrings_Init((CHAR*)"one three", 10, &s1);
	DStrings_Init((CHAR*)"two ", 5, &s2);
	DStrings_Insert(s2, 4, &s1);
	DStringsTest_ExpectedDString(expected, s1, (CHAR*)"Insert(\'two \', 4, \'one three\')", 31, &test);
	DStrings_Init((CHAR*)"one three", 10, &s1);
	DStrings_Init((CHAR*)" two", 5, &s2);
	DStrings_Insert(s2, 3, &s1);
	DStringsTest_ExpectedDString(expected, s1, (CHAR*)"Insert(\'two \', 3, \'one three\')", 31, &test);
	return test;
}

static BOOLEAN DStringsTest_TestAppend (void)
{
	BOOLEAN test;
	DStrings_String s1 = NIL;
	DStrings_String s2 = NIL;
	DStrings_String expected = NIL;
	test = 1;
	DStrings_Init((CHAR*)"one two three four", 19, &expected);
	DStrings_Init((CHAR*)"one two three ", 15, &s1);
	DStrings_Init((CHAR*)"four", 5, &s2);
	DStrings_Append(s2, &s1);
	DStringsTest_ExpectedDString(expected, s1, (CHAR*)"Append(\'four \', \'one two three\')", 33, &test);
	return test;
}

static BOOLEAN DStringsTest_TestDelete (void)
{
	BOOLEAN test;
	DStrings_String s1 = NIL;
	DStrings_String expected = NIL;
	test = 1;
	DStrings_Init((CHAR*)"two three four", 15, &expected);
	DStrings_Init((CHAR*)"one two three four", 19, &s1);
	DStrings_Delete(&s1, 0, 4);
	DStringsTest_ExpectedDString(expected, s1, (CHAR*)"Delete(\'one two three four\', 0, 4)", 35, &test);
	DStrings_Init((CHAR*)"one three four", 15, &expected);
	DStrings_Init((CHAR*)"one two three four", 19, &s1);
	DStrings_Delete(&s1, 4, 4);
	DStringsTest_ExpectedDString(expected, s1, (CHAR*)"Delete(\'one two three four\', 4, 4)", 35, &test);
	DStrings_Init((CHAR*)"one two three", 14, &expected);
	DStrings_Init((CHAR*)"one two three four", 19, &s1);
	DStrings_Delete(&s1, 13, 5);
	DStringsTest_ExpectedDString(expected, s1, (CHAR*)"Delete(\'one two three four\', 13, 5)", 36, &test);
	DStrings_Init((CHAR*)"one two three", 14, &expected);
	DStrings_Init((CHAR*)"one two three four", 19, &s1);
	DStrings_Delete(&s1, 13, 10);
	DStringsTest_ExpectedDString(expected, s1, (CHAR*)"Delete(\'one two three four\', 13, 10)", 37, &test);
	DStrings_Init((CHAR*)"one><three four", 16, &expected);
	DStrings_Init((CHAR*)"one>two<three four", 19, &s1);
	DStrings_Delete(&s1, 4, 3);
	DStringsTest_ExpectedDString(expected, s1, (CHAR*)"Delete(\'one>two<three four\', 4, 3)", 35, &test);
	return test;
}

static BOOLEAN DStringsTest_TestExtract (void)
{
	BOOLEAN test;
	DStrings_String s1 = NIL;
	DStrings_String s2 = NIL;
	DStrings_String expected = NIL;
	test = 1;
	DStrings_Init((CHAR*)"one two three", 14, &s1);
	DStrings_Init((CHAR*)"one", 4, &expected);
	DStrings_Extract(s1, 0, 3, &s2);
	DStringsTest_ExpectedDString(expected, s2, (CHAR*)"Extract(s1, 0, 3, s2)", 22, &test);
	DStrings_Init((CHAR*)"two", 4, &expected);
	DStrings_Extract(s1, 4, 3, &s2);
	DStringsTest_ExpectedDString(expected, s2, (CHAR*)"Extract(s1, 4, 3, s2)", 22, &test);
	DStrings_Init((CHAR*)"three", 6, &expected);
	DStrings_Extract(s1, 8, 12, &s2);
	DStringsTest_ExpectedDString(expected, s2, (CHAR*)"Extract(s1, 8, 12, s2)", 23, &test);
	return test;
}

static BOOLEAN DStringsTest_TestPos (void)
{
	BOOLEAN test;
	DStrings_String s1 = NIL;
	DStrings_String s2 = NIL;
	INTEGER expected, got;
	test = 1;
	DStrings_Init((CHAR*)"one two three", 14, &s1);
	DStrings_Init((CHAR*)"one", 4, &s2);
	got = DStrings_Pos(s2, s1, 0);
	expected = 0;
	Tests_ExpectedInt(expected, got, (CHAR*)"DStrings.Pos(\'one\',s1, 0)", 26, &test);
	expected = -1;
	got = DStrings_Pos(s2, s1, 4);
	Tests_ExpectedInt(expected, got, (CHAR*)"DStrings.Pos(\'one\',s1, 4)", 26, &test);
	DStrings_Init((CHAR*)"two", 4, &s2);
	expected = 4;
	got = DStrings_Pos(s2, s1, 0);
	Tests_ExpectedInt(expected, got, (CHAR*)"DStrings.Pos(\'two\',s1, 0)", 26, &test);
	expected = -1;
	got = DStrings_Pos(s2, s1, 6);
	Tests_ExpectedInt(expected, got, (CHAR*)"DStrings.Pos(\'two\',s1, 6)", 26, &test);
	return test;
}

static BOOLEAN DStringsTest_TestReplace (void)
{
	BOOLEAN test;
	DStrings_String source = NIL;
	DStrings_String dest = NIL;
	DStrings_String expected = NIL;
	test = 1;
	DStrings_Init((CHAR*)"222", 4, &source);
	DStrings_Init((CHAR*)"one two three", 14, &dest);
	DStrings_Init((CHAR*)"one 222 three", 14, &expected);
	DStrings_Replace(source, 4, &dest);
	DStringsTest_ExpectedDString(expected, dest, (CHAR*)"Replace(\'222\', 4, dest)", 24, &test);
	DStrings_Init((CHAR*)"111", 4, &source);
	DStrings_Init((CHAR*)"111 222 three", 14, &expected);
	DStrings_Replace(source, 0, &dest);
	DStringsTest_ExpectedDString(expected, dest, (CHAR*)"Replace(\'111\', 0, dest)", 24, &test);
	DStrings_Init((CHAR*)"33333", 6, &source);
	DStrings_Init((CHAR*)"111 222 33333", 14, &expected);
	DStrings_Replace(source, 8, &dest);
	DStringsTest_ExpectedDString(expected, dest, (CHAR*)"Replace(\'33333\', 8, dest)", 26, &test);
	return test;
}

static BOOLEAN DStringsTest_TestCap (void)
{
	BOOLEAN test;
	DStrings_String got = NIL;
	DStrings_String expected = NIL;
	test = 1;
	DStrings_Init((CHAR*)"AbCdE", 6, &got);
	DStrings_Init((CHAR*)"ABCDE", 6, &expected);
	DStrings_Cap(&got);
	DStringsTest_ExpectedDString(expected, got, (CHAR*)"Cap(\'AbCdE\')", 13, &test);
	return test;
}

static BOOLEAN DStringsTest_TestStartsWith (void)
{
	BOOLEAN test;
	DStrings_String prefix = NIL;
	DStrings_String source = NIL;
	BOOLEAN expected, got;
	test = 1;
	DStrings_Init((CHAR*)"one", 4, &prefix);
	DStrings_Init((CHAR*)"one two three", 14, &source);
	expected = 1;
	got = DStrings_StartsWith(prefix, source);
	Tests_ExpectedBool(expected, got, (CHAR*)"StartsWith(\'one\', \'one two three\')", 35, &test);
	expected = 0;
	DStrings_Init((CHAR*)"two", 4, &prefix);
	got = DStrings_StartsWith(prefix, source);
	Tests_ExpectedBool(expected, got, (CHAR*)"StartsWith(\'two\', \'one two three\')", 35, &test);
	return test;
}

static BOOLEAN DStringsTest_TestReadProcs (void)
{
	BOOLEAN test, ok, bt;
	CHAR b1;
	DStrings_Rider r1 = {0};
	DStrings_String expectS = NIL;
	DStrings_String s1 = NIL;
	DStrings_String s2 = NIL;
	CHAR expectC, c1;
	CHAR expectCS[256], cs[256];
	INTEGER expectI, i;
	SHORTREAL expectR, a;
	CHAR expectBytes[4], ba[4];
	SET expectSet, gotSet;
	test = 1;
	expectC = 'N';
	DStrings_Init((CHAR*)"No. 42, Pi is 3.145 real", 25, &s1);
	DStrings_Set(&r1, DStrings_Rider__typ, s1, 0);
	DStrings_Read(&r1, DStrings_Rider__typ, &b1);
	Tests_ExpectedChar(expectC, (CHAR)b1, (CHAR*)"Read(r1, b1) -> \'N\'", 20, &test);
	expectC = 'o';
	DStrings_ReadChar(&r1, DStrings_Rider__typ, &c1);
	Tests_ExpectedChar(expectC, c1, (CHAR*)"ReadChar(r1, c1) -> \'o\'", 24, &test);
	DStrings_ReadChar(&r1, DStrings_Rider__typ, &c1);
	expectI = 42;
	i = -1;
	DStrings_ReadInt(&r1, DStrings_Rider__typ, &i);
	Tests_ExpectedInt(expectI, i, (CHAR*)"ReadInt(r1, c1) -> 42", 22, &test);
	StringToReal((CHAR*)"3.145", 6, &expectR, &ok);
	a = (SHORTREAL)0;
	DStrings_ReadReal(&r1, DStrings_Rider__typ, &a);
	Tests_ExpectedReal(expectR, a, (CHAR*)"ReadReal(r1, a) -> 3.145", 25, &test);
	__MOVE(" real", expectCS, 6);
	DStrings_ReadString(&r1, DStrings_Rider__typ, (void*)cs, 256);
	Tests_ExpectedString((void*)expectCS, 256, (void*)cs, 256, (CHAR*)"ReadString(r1, cs) -> \' real\'", 30, &test);
	__MOVE("No. 42, Pi is 3.145 real", expectCS, 25);
	DStrings_Init((void*)expectCS, 256, &expectS);
	DStrings_Init((void*)expectCS, 256, &s1);
	DStrings_Init((CHAR*)"", 1, &s2);
	DStrings_Set(&r1, DStrings_Rider__typ, s1, 0);
	DStrings_ReadDString(&r1, DStrings_Rider__typ, &s2);
	DStringsTest_ExpectedDString(expectS, s2, (CHAR*)"ReadDString(r1, s) -> \'No. 42, Pi is 3.145 real\'", 49, &test);
	__MOVE("t f true false 1 0 T F TRUE FALSE True False", expectCS, 45);
	DStrings_Init((void*)expectCS, 256, &expectS);
	DStrings_Init((void*)expectCS, 256, &s1);
	DStrings_Set(&r1, DStrings_Rider__typ, s1, 0);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(1, bt, (CHAR*)"ReadBool(r, b) -> t", 20, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(0, bt, (CHAR*)"ReadBool(r, b) -> f", 20, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(1, bt, (CHAR*)"ReadBool(r, b) -> true", 23, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(0, bt, (CHAR*)"ReadBool(r, b) -> false", 24, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(1, bt, (CHAR*)"ReadBool(r, b) -> 1", 20, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(0, bt, (CHAR*)"ReadBool(r, b) -> 0", 20, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(1, bt, (CHAR*)"ReadBool(r, b) -> T", 20, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(0, bt, (CHAR*)"ReadBool(r, b) -> F", 20, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(1, bt, (CHAR*)"ReadBool(r, b) -> TRUE", 23, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(0, bt, (CHAR*)"ReadBool(r, b) -> FALSE", 24, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(1, bt, (CHAR*)"ReadBool(r, b) -> True", 23, &test);
	DStrings_ReadBool(&r1, DStrings_Rider__typ, &bt);
	Tests_ExpectedBool(0, bt, (CHAR*)"ReadBool(r, b) -> False", 24, &test);
	expectCS[0] = 0x01;
	expectCS[1] = 0x02;
	expectCS[2] = 0x03;
	expectCS[3] = 0x00;
	expectBytes[0] = 1;
	expectBytes[1] = 2;
	expectBytes[2] = 3;
	expectBytes[3] = 0;
	DStrings_Init((void*)expectCS, 256, &s1);
	DStrings_Set(&r1, DStrings_Rider__typ, s1, 0);
	DStrings_ReadBytes(&r1, DStrings_Rider__typ, (void*)ba, 4, 4);
	Tests_ExpectedBytes((void*)expectBytes, 4, (void*)ba, 4, 4, (CHAR*)"ReadBytes(r1, ba, 4) 1230", 26, &test);
	expectSet = 0x05dc;
	DStrings_Init((CHAR*)"{2,3,4,6,7,8,10}", 17, &s1);
	DStrings_Set(&r1, DStrings_Rider__typ, s1, 0);
	DStrings_ReadSet(&r1, DStrings_Rider__typ, &gotSet);
	Tests_ExpectedSet(expectSet, gotSet, (CHAR*)"ReadSet(r1, gotSet);", 21, &test);
	DStrings_Init((CHAR*)" 3.1459 ", 9, &s1);
	DStrings_Set(&r1, DStrings_Rider__typ, s1, 0);
	DStrings_ReadFixed(&r1, DStrings_Rider__typ, &a, 2);
	Tests_ExpectedReal(3.1400001, a, (CHAR*)"ReadFixed(r1, a, 2)", 20, &test);
	return test;
}

static BOOLEAN DStringsTest_TestWriteProcs (void)
{
	BOOLEAN test;
	DStrings_String expectDS = NIL;
	DStrings_String gotDS = NIL;
	DStrings_String src = NIL;
	CHAR a[256];
	CHAR b;
	CHAR c;
	DStrings_Rider W = {0};
	CHAR bytes[7];
	INTEGER i;
	SET set;
	CHAR expectS[256];
	test = 1;
	DStrings_Init((CHAR*)"X", 2, &expectDS);
	DStrings_Init((CHAR*)"", 1, &gotDS);
	DStrings_Set(&W, DStrings_Rider__typ, gotDS, 0);
	b = 88;
	c = 'Y';
	__MOVE("Z and other letters", a, 20);
	DStrings_Write(&W, DStrings_Rider__typ, b);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"Write(W, b)", 12, &test);
	DStrings_CopyChars((CHAR*)"XY", 3, &expectDS);
	DStrings_WriteChar(&W, DStrings_Rider__typ, c);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteChar(W, c)", 16, &test);
	DStrings_Init((CHAR*)"XYZ and other letters", 22, &expectDS);
	DStrings_WriteString(&W, DStrings_Rider__typ, (void*)a, 256);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteString(W, a)", 18, &test);
	DStrings_Init((CHAR*)"XYZ and other letters. Then the dinosaurs arrived. ", 52, &expectDS);
	DStrings_Init((CHAR*)". Then the dinosaurs arrived. ", 31, &src);
	DStrings_WriteDString(&W, DStrings_Rider__typ, src);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteDString(W, src)", 21, &test);
	DStrings_Init((CHAR*)"XYZ and other letters. Then the dinosaurs arrived. 1", 53, &expectDS);
	DStrings_WriteInt(&W, DStrings_Rider__typ, 1);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteInt(W, 1)", 15, &test);
	DStrings_Init((CHAR*)"XYZ and other letters. Then the dinosaurs arrived. 13.1459", 59, &expectDS);
	DStrings_WriteReal(&W, DStrings_Rider__typ, 3.1459);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteReal(W, 3.1459)", 21, &test);
	DStrings_Init((CHAR*)"3.14", 5, &expectDS);
	DStrings_Clear(&gotDS);
	DStrings_Set(&W, DStrings_Rider__typ, gotDS, 0);
	DStrings_WriteFixed(&W, DStrings_Rider__typ, 3.1459, 2);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteFixed(W, 3.1459, 2)", 25, &test);
	DStrings_Init((CHAR*)"true", 5, &expectDS);
	DStrings_Clear(&gotDS);
	DStrings_Set(&W, DStrings_Rider__typ, gotDS, 0);
	DStrings_WriteBool(&W, DStrings_Rider__typ, 1);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteBool(W, TRUE)", 19, &test);
	DStrings_Init((CHAR*)"false", 6, &expectDS);
	DStrings_Clear(&gotDS);
	DStrings_Set(&W, DStrings_Rider__typ, gotDS, 0);
	DStrings_WriteBool(&W, DStrings_Rider__typ, 0);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteBool(W, FALSE)", 20, &test);
	i = 0;
	while (i <= 6) {
		bytes[__X(i, 7, (CHAR*)"DStringsTest", 123420)] = 108 + i;
		i += 1;
	}
	DStrings_Init((CHAR*)"lmnopqr", 8, &expectDS);
	DStrings_Clear(&gotDS);
	DStrings_Set(&W, DStrings_Rider__typ, gotDS, 0);
	DStrings_WriteBytes(&W, DStrings_Rider__typ, (void*)bytes, 7, 7);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteBytes(W, bytes)", 21, &test);
	set = 0x0;
	DStrings_Init((CHAR*)"{}", 3, &expectDS);
	DStrings_Clear(&gotDS);
	DStrings_Set(&W, DStrings_Rider__typ, gotDS, 0);
	DStrings_WriteSet(&W, DStrings_Rider__typ, set);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteSet(W, set) {}", 20, &test);
	set = 0x02;
	DStrings_Init((CHAR*)"{1}", 4, &expectDS);
	DStrings_ToChars(expectDS, (void*)expectS, 256, &i);
	DStrings_Clear(&gotDS);
	DStrings_Set(&W, DStrings_Rider__typ, gotDS, 0);
	DStrings_WriteSet(&W, DStrings_Rider__typ, set);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteSet(W, set) {1}", 21, &test);
	set = 0x01800222;
	DStrings_Init((CHAR*)"{1,5,9,23,24}", 14, &expectDS);
	DStrings_Clear(&gotDS);
	DStrings_Set(&W, DStrings_Rider__typ, gotDS, 0);
	DStrings_WriteSet(&W, DStrings_Rider__typ, set);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteSet(W, set) {1,5,9,23,24}", 31, &test);
	set = 0x08ea;
	DStrings_Init((CHAR*)"{1,3,5..7,11}", 14, &expectDS);
	DStrings_Clear(&gotDS);
	DStrings_Set(&W, DStrings_Rider__typ, gotDS, 0);
	DStrings_WriteSet(&W, DStrings_Rider__typ, set);
	DStringsTest_ExpectedDString(expectDS, gotDS, (CHAR*)"WriteSet(W, set) {1,3,5..7,11}", 31, &test);
	return test;
}

static void EnumPtrs(void (*P)(void*))
{
	P(DStringsTest_ts);
}


export void *DStringsTest__init (void)
{
	__DEFMOD;
	__IMPORT(Chars__init);
	__IMPORT(extConvert__init);
	__IMPORT(DStrings__init);
	__IMPORT(Out__init);
	__IMPORT(Strings__init);
	__IMPORT(Tests__init);
	__REGMOD("DStringsTest", EnumPtrs);
/* BEGIN */
	Tests_Init(&DStringsTest_ts, (CHAR*)"Test DStrings", 14);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestInit);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestToChars);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestRider);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestCopy);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestInsert);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestAppend);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestDelete);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestExtract);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestPos);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestReplace);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestCap);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestStartsWith);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestReadProcs);
	Tests_Add(&DStringsTest_ts, DStringsTest_TestWriteProcs);
	__ASSERT(Tests_Run(DStringsTest_ts), 0, (CHAR*)"DStringsTest", 139283);
	__ENDMOD;
}
