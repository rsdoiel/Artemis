/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"
#include "Chars.oh"
#include "Out.oh"
#include "Tests.oh"


static Tests_TestSet CharsTest_ts;


static void CharsTest_DisplayStrings (CHAR *msg, INTEGER msg__len, CHAR *s1, INTEGER s1__len, CHAR *s2, INTEGER s2__len);
static BOOLEAN CharsTest_TestAppend (void);
static BOOLEAN CharsTest_TestAppendChar (void);
static BOOLEAN CharsTest_TestBoolToString (void);
static BOOLEAN CharsTest_TestCap (void);
static BOOLEAN CharsTest_TestDelete (void);
static BOOLEAN CharsTest_TestEqual (void);
static BOOLEAN CharsTest_TestExtract (void);
static BOOLEAN CharsTest_TestFixedToString (void);
static BOOLEAN CharsTest_TestInsert (void);
static BOOLEAN CharsTest_TestInsertChar (void);
static BOOLEAN CharsTest_TestIntToString (void);
static BOOLEAN CharsTest_TestIsX (void);
static BOOLEAN CharsTest_TestLength (void);
static BOOLEAN CharsTest_TestPadding (void);
static BOOLEAN CharsTest_TestRealToString (void);
static BOOLEAN CharsTest_TestReplace (void);
static BOOLEAN CharsTest_TestSetToString (void);
static BOOLEAN CharsTest_TestTrim (void);
static BOOLEAN CharsTest_TestWith (void);


/*============================================================================*/

static BOOLEAN CharsTest_TestLength (void)
{
	BOOLEAN test;
	CHAR a[1024], b[1024];
	test = 1;
	__MOVE("abc", a, 4);
	Tests_ExpectedInt(3, Chars_Length((void*)a, 1024), (CHAR*)"a = \'abc\' should be length 3", 29, &test);
	__MOVE("defghi", b, 7);
	Tests_ExpectedInt(6, Chars_Length((void*)b, 1024), (CHAR*)"b = \'defghi\' should be length 6", 32, &test);
	a[0] = 0x00;
	Tests_ExpectedInt(0, Chars_Length((void*)a, 1024), (CHAR*)"a = \'\' should be zero", 22, &test);
	return test;
}

static BOOLEAN CharsTest_TestInsert (void)
{
	BOOLEAN test;
	CHAR s1[1024], s2[1024], expected[1024];
	test = 1;
	__MOVE("one two three", expected, 14);
	__MOVE("two three", s1, 10);
	__MOVE("one ", s2, 5);
	Chars_Insert((void*)s2, 1024, 0, (void*)s1, 1024);
	Tests_ExpectedString((void*)expected, 1024, (void*)s1, 1024, (CHAR*)"Insert(\'one \', 0, \'two three\')", 31, &test);
	Chars_Clear((void*)s1, 1024);
	Chars_Clear((void*)s2, 1024);
	__MOVE("one three", s1, 10);
	__MOVE("two ", s2, 5);
	Chars_Insert((void*)s2, 1024, 4, (void*)s1, 1024);
	Tests_ExpectedString((void*)expected, 1024, (void*)s1, 1024, (CHAR*)"Insert(\'two \', 4, \'one three\')", 31, &test);
	Chars_Clear((void*)s1, 1024);
	Chars_Clear((void*)s2, 1024);
	__MOVE("one three", s1, 10);
	__MOVE(" two", s2, 5);
	Chars_Insert((void*)s2, 1024, 3, (void*)s1, 1024);
	Tests_ExpectedString((void*)expected, 1024, (void*)s1, 1024, (CHAR*)"Insert(\'two \', 3, \'one three\')", 31, &test);
	return test;
}

static BOOLEAN CharsTest_TestAppend (void)
{
	CHAR c[1024], s[1024];
	BOOLEAN test;
	test = 1;
	Chars_Clear((void*)c, 1024);
	Chars_Clear((void*)s, 1024);
	__MOVE("3", c, 2);
	__MOVE("2", s, 2);
	Chars_Append((void*)c, 1024, (void*)s, 1024);
	Tests_ExpectedString((CHAR*)"23", 3, (void*)s, 1024, (CHAR*)"Expected A return TRUE, FALSE", 30, &test);
	Tests_ExpectedInt(2, Chars_Length((void*)s, 1024), (CHAR*)"Expected length 2 for string ", 30, &test);
	return test;
}

static BOOLEAN CharsTest_TestDelete (void)
{
	BOOLEAN test;
	CHAR s1[1024], expected[1024];
	test = 1;
	Chars_Clear((void*)expected, 1024);
	Chars_Clear((void*)s1, 1024);
	__MOVE("two three four", expected, 15);
	__MOVE("one two three four", s1, 19);
	Chars_Delete((void*)s1, 1024, 0, 4);
	Tests_ExpectedString((void*)expected, 1024, (void*)s1, 1024, (CHAR*)"Delete(\'one two three four\', 0, 4)", 35, &test);
	Chars_Clear((void*)expected, 1024);
	Chars_Clear((void*)s1, 1024);
	__MOVE("one three four", expected, 15);
	__MOVE("one two three four", s1, 19);
	Chars_Delete((void*)s1, 1024, 4, 4);
	Tests_ExpectedString((void*)expected, 1024, (void*)s1, 1024, (CHAR*)"Delete(\'one two three four\', 4, 4)", 35, &test);
	Chars_Clear((void*)expected, 1024);
	Chars_Clear((void*)s1, 1024);
	__MOVE("one two three", expected, 14);
	__MOVE("one two three four", s1, 19);
	Chars_Delete((void*)s1, 1024, 13, 5);
	Tests_ExpectedString((void*)expected, 1024, (void*)s1, 1024, (CHAR*)"Delete(\'one two three four\', 13, 5)", 36, &test);
	Chars_Clear((void*)expected, 1024);
	Chars_Clear((void*)s1, 1024);
	__MOVE("one two three", expected, 14);
	__MOVE("one two three four", s1, 19);
	Chars_Delete((void*)s1, 1024, 13, 10);
	Tests_ExpectedString((void*)expected, 1024, (void*)s1, 1024, (CHAR*)"Delete(\'one two three four\', 13, 10)", 37, &test);
	Chars_Clear((void*)expected, 1024);
	Chars_Clear((void*)s1, 1024);
	__MOVE("one><three four", expected, 16);
	__MOVE("one>two<three four", s1, 19);
	Chars_Delete((void*)s1, 1024, 4, 3);
	Tests_ExpectedString((void*)expected, 1024, (void*)s1, 1024, (CHAR*)"Delete(\'one>two<three four\', 4, 3)", 35, &test);
	return test;
}

static BOOLEAN CharsTest_TestReplace (void)
{
	BOOLEAN test;
	CHAR source[1024], dest[1024], expected[1024];
	test = 1;
	Chars_Clear((void*)expected, 1024);
	Chars_Clear((void*)source, 1024);
	Chars_Clear((void*)dest, 1024);
	__MOVE("one 222 three", expected, 14);
	__MOVE("222", source, 4);
	__MOVE("one two three", dest, 14);
	Chars_Replace((void*)source, 1024, 4, (void*)dest, 1024);
	Tests_ExpectedString((void*)expected, 1024, (void*)dest, 1024, (CHAR*)"Replace(\'222\', 4, dest)", 24, &test);
	Chars_Clear((void*)expected, 1024);
	Chars_Clear((void*)source, 1024);
	__MOVE("111 222 three", expected, 14);
	__MOVE("111", source, 4);
	Chars_Replace((void*)source, 1024, 0, (void*)dest, 1024);
	Tests_ExpectedString((void*)expected, 1024, (void*)dest, 1024, (CHAR*)"Replace(\'111\', 0, dest)", 24, &test);
	Chars_Clear((void*)expected, 1024);
	Chars_Clear((void*)source, 1024);
	__MOVE("111 222 33333", expected, 14);
	__MOVE("33333", source, 6);
	Chars_Replace((void*)source, 1024, 8, (void*)dest, 1024);
	Tests_ExpectedString((void*)expected, 1024, (void*)dest, 1024, (CHAR*)"Replace(\'33333\', 8, dest)", 26, &test);
	return test;
}

static BOOLEAN CharsTest_TestCap (void)
{
	BOOLEAN test;
	CHAR got[1024], expected[1024];
	test = 1;
	__MOVE("ABCDE", expected, 6);
	__MOVE("AbCdE", got, 6);
	Chars_Cap((void*)got, 1024);
	Tests_ExpectedString((void*)expected, 1024, (void*)got, 1024, (CHAR*)"Cap(\'AbCdE\')", 13, &test);
	return test;
}

static BOOLEAN CharsTest_TestExtract (void)
{
	BOOLEAN test;
	CHAR s1[1024], s2[1024], expected[1024];
	test = 1;
	__MOVE("one", expected, 4);
	__MOVE("one two three", s1, 14);
	Chars_Extract((void*)s1, 1024, 0, 3, (void*)s2, 1024);
	Tests_ExpectedString((void*)expected, 1024, (void*)s2, 1024, (CHAR*)"Extract(s1, 0, 3, s2)", 22, &test);
	__MOVE("two", expected, 4);
	Chars_Extract((void*)s1, 1024, 4, 3, (void*)s2, 1024);
	Tests_ExpectedString((void*)expected, 1024, (void*)s2, 1024, (CHAR*)"Extract(s1, 4, 3, s2)", 22, &test);
	__MOVE("three", expected, 6);
	Chars_Extract((void*)s1, 1024, 8, 12, (void*)s2, 1024);
	Tests_ExpectedString((void*)expected, 1024, (void*)s2, 1024, (CHAR*)"Extract(s1, 8, 12, s2)", 23, &test);
	return test;
}

static BOOLEAN CharsTest_TestIsX (void)
{
	BOOLEAN test, expected, got;
	test = 1;
	expected = 1;
	got = Chars_IsAlpha('T');
	Tests_ExpectedBool(expected, got, (CHAR*)"IsAlpha(T)", 11, &test);
	got = Chars_IsPrintable('T');
	Tests_ExpectedBool(expected, got, (CHAR*)"IsPrintable(T)", 15, &test);
	expected = 0;
	got = Chars_IsPrintable(0x13);
	Tests_ExpectedBool(expected, got, (CHAR*)"IsPrintable(13X)", 17, &test);
	return test;
}

static BOOLEAN CharsTest_TestEqual (void)
{
	BOOLEAN test, testVal;
	CHAR s1[1024], s2[1024];
	test = 1;
	Chars_Clear((void*)s1, 1024);
	Chars_Clear((void*)s2, 1024);
	__MOVE("One Two Three", s1, 14);
	__MOVE("One Two Three", s2, 14);
	testVal = Chars_Equal((void*)s1, 1024, (void*)s2, 1024);
	Tests_ExpectedBool(1, testVal, (CHAR*)"Chars.Equal(\'One Two Three\', \'One Two Three\')", 46, &test);
	Chars_Clear((void*)s2, 1024);
	__MOVE("two three four", s2, 15);
	testVal = Chars_Equal((void*)s1, 1024, (void*)s2, 1024);
	Tests_ExpectedBool(0, testVal, (CHAR*)"Chars.Equal(\'One Two Three\', \'two three four\')", 47, &test);
	return test;
}

static BOOLEAN CharsTest_TestAppendChar (void)
{
	CHAR c;
	CHAR expectS[32], gotS[32];
	BOOLEAN test;
	test = 1;
	Chars_Clear((void*)expectS, 32);
	Chars_Clear((void*)gotS, 32);
	c = '5';
	Chars_Copy((CHAR*)"test5", 6, (void*)expectS, 32);
	Chars_Copy((CHAR*)"test", 5, (void*)gotS, 32);
	Chars_AppendChar(c, (void*)gotS, 32);
	Tests_ExpectedString((void*)expectS, 32, (void*)gotS, 32, (CHAR*)"AppendChar(c, gotS) 5", 22, &test);
	return test;
}

static BOOLEAN CharsTest_TestInsertChar (void)
{
	CHAR c;
	CHAR expectS[32], gotS[32];
	BOOLEAN test;
	test = 1;
	Chars_Clear((void*)expectS, 32);
	Chars_Clear((void*)gotS, 32);
	c = '0';
	Chars_Copy((CHAR*)"0test5", 7, (void*)expectS, 32);
	Chars_Copy((CHAR*)"test5", 6, (void*)gotS, 32);
	Chars_InsertChar(c, 0, (void*)gotS, 32);
	Tests_ExpectedString((void*)expectS, 32, (void*)gotS, 32, (CHAR*)"InsertChar(c, 0, gotS) 0", 25, &test);
	return test;
}

static void CharsTest_DisplayStrings (CHAR *msg, INTEGER msg__len, CHAR *s1, INTEGER s1__len, CHAR *s2, INTEGER s2__len)
{
	String((void*)msg, msg__len);
	String((CHAR*)" \'", 3);
	String((void*)s1, s1__len);
	String((CHAR*)"\', \'", 5);
	String((void*)s2, s2__len);
	String((CHAR*)"\'", 2);
	Ln();
}

static BOOLEAN CharsTest_TestWith (void)
{
	BOOLEAN test;
	CHAR prefix[1024], suffix[1024], src[1024];
	test = 1;
	Chars_Clear((void*)prefix, 1024);
	Chars_Clear((void*)src, 1024);
	Chars_Clear((void*)suffix, 1024);
	__MOVE("define(", prefix, 8);
	__MOVE(");", suffix, 3);
	__MOVE("define(OS, \'Linux\');", src, 21);
	if (Chars_StartsWith((void*)prefix, 1024, (void*)src, 1024) != 1) {
		CharsTest_DisplayStrings((CHAR*)"Expected StartsWith() to be TRUE for prefix/src, ", 50, (void*)prefix, 1024, (void*)src, 1024);
		test = 0;
	}
	if (Chars_EndsWith((void*)suffix, 1024, (void*)src, 1024) != 1) {
		CharsTest_DisplayStrings((CHAR*)"Expected EndsWith() to be TRUE for suffix/src, ", 48, (void*)suffix, 1024, (void*)src, 1024);
		test = 0;
	}
	Chars_Clear((void*)src, 1024);
	__MOVE("This is a silly string and message.", src, 36);
	if (Chars_StartsWith((void*)prefix, 1024, (void*)src, 1024) != 0) {
		CharsTest_DisplayStrings((CHAR*)"Expected StartsWith() to be FALSE for prefix/src, ", 51, (void*)prefix, 1024, (void*)src, 1024);
		test = 0;
	}
	if (Chars_EndsWith((void*)suffix, 1024, (void*)src, 1024) != 0) {
		CharsTest_DisplayStrings((CHAR*)"Expected EndsWith() to be FALSE for prefix/src, ", 49, (void*)suffix, 1024, (void*)src, 1024);
		test = 0;
	}
	return test;
}

static BOOLEAN CharsTest_TestTrim (void)
{
	BOOLEAN test;
	CHAR prefix[1024], suffix[1024], src[1024], expected[1024];
	test = 1;
	Chars_Clear((void*)prefix, 1024);
	Chars_Clear((void*)src, 1024);
	Chars_Clear((void*)suffix, 1024);
	Chars_Clear((void*)expected, 1024);
	__MOVE("define(", prefix, 8);
	__MOVE(");", suffix, 3);
	__MOVE("define(OS, \'Linux\');", src, 21);
	Chars_TrimPrefix((void*)prefix, 1024, (void*)src, 1024);
	if (Chars_Equal((void*)src, 1024, (CHAR*)"OS, \'Linux\');", 14) != 1) {
		CharsTest_DisplayStrings((CHAR*)"Expected TrimPrefix() failed for prefix/src, ", 46, (void*)prefix, 1024, (void*)src, 1024);
		test = 0;
	}
	Chars_TrimSuffix((void*)suffix, 1024, (void*)src, 1024);
	if (Chars_Equal((void*)src, 1024, (CHAR*)"OS, \'Linux\'", 12) != 1) {
		CharsTest_DisplayStrings((CHAR*)"Expected TrimSuffix() failed for suffix/src, ", 46, (void*)suffix, 1024, (void*)src, 1024);
		test = 0;
	}
	Chars_Clear((void*)src, 1024);
	Chars_Clear((void*)expected, 1024);
	__MOVE("This is a silly string and message.", expected, 36);
	__MOVE("This is a silly string and message.", src, 36);
	Chars_TrimPrefix((void*)prefix, 1024, (void*)src, 1024);
	if (Chars_Equal((void*)src, 1024, (void*)expected, 1024) != 1) {
		CharsTest_DisplayStrings((CHAR*)"Expected TrimPrefix(\'define(\', ...) failed for expected/src, ", 62, (void*)expected, 1024, (void*)src, 1024);
		test = 0;
	}
	Chars_TrimSuffix((void*)suffix, 1024, (void*)src, 1024);
	if (Chars_Equal((void*)src, 1024, (void*)expected, 1024) != 1) {
		CharsTest_DisplayStrings((CHAR*)"Expected TrimSuffix(\');\', ...) failed for expected/src, ", 57, (void*)expected, 1024, (void*)src, 1024);
		test = 0;
	}
	Chars_Clear((void*)src, 1024);
	Chars_Clear((void*)expected, 1024);
	__MOVE("Hello World", expected, 12);
	__MOVE("     Hello World            ", src, 29);
	Chars_TrimSpace((void*)src, 1024);
	if (__STRCMP(src, expected) != 0) {
		CharsTest_DisplayStrings((CHAR*)"Expected trim space: ", 22, (void*)expected, 1024, (void*)src, 1024);
	}
	return test;
}

static BOOLEAN CharsTest_TestPadding (void)
{
	BOOLEAN test;
	CHAR expectS[256], gotS[256];
	test = 1;
	__MOVE("^^^^Fred", expectS, 9);
	__MOVE("Fred", gotS, 5);
	Chars_LeftPad('^', 8, (void*)gotS, 256);
	Tests_ExpectedString((void*)expectS, 256, (void*)gotS, 256, (CHAR*)"LeftPad(\'^\', 8, gotS)", 22, &test);
	__MOVE("^^^^Fred----", expectS, 13);
	Chars_RightPad('-', 12, (void*)gotS, 256);
	Tests_ExpectedString((void*)expectS, 256, (void*)gotS, 256, (CHAR*)"Right(\'-\', 8, gotS)", 20, &test);
	__MOVE("Fred", gotS, 5);
	__MOVE("....Fred....", expectS, 13);
	Chars_Pad('.', 12, (void*)gotS, 256);
	Tests_ExpectedString((void*)expectS, 256, (void*)gotS, 256, (CHAR*)"Pad(\'.\', 8, gotS)", 18, &test);
	return test;
}

static BOOLEAN CharsTest_TestIntToString (void)
{
	BOOLEAN test, ok;
	INTEGER i;
	CHAR expectS[1024], gotS[1024];
	test = 1;
	i = 0;
	__MOVE("0", expectS, 2);
	gotS[0] = 0x00;
	Chars_IntToString(i, (void*)gotS, 1024, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"IntToString(0, gotS, ok) ok", 28, &test);
	Tests_ExpectedString((void*)expectS, 1024, (void*)gotS, 1024, (CHAR*)"IntToString(0, gotS, ok) string", 32, &test);
	i = 42;
	__MOVE("42", expectS, 3);
	gotS[0] = 0x00;
	Chars_IntToString(i, (void*)gotS, 1024, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"IntToString(42, gotS, ok) ok", 29, &test);
	Tests_ExpectedString((void*)expectS, 1024, (void*)gotS, 1024, (CHAR*)"IntToString(42, gotS, ok) string", 33, &test);
	i = 1459000000;
	__MOVE("1459000000", expectS, 11);
	gotS[0] = 0x00;
	Chars_IntToString(i, (void*)gotS, 1024, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"IntToString(1459000000, gotS, ok) ok", 37, &test);
	Tests_ExpectedString((void*)expectS, 1024, (void*)gotS, 1024, (CHAR*)"IntToString(1459000000, gotS, ok) string", 41, &test);
	return test;
}

static BOOLEAN CharsTest_TestRealToString (void)
{
	BOOLEAN test, ok;
	SHORTREAL r;
	CHAR expectS[256], gotS[256];
	test = 1;
	r = 3.1459;
	__MOVE("3.1459", expectS, 7);
	gotS[0] = 0x00;
	Chars_RealToString(r, (void*)gotS, 256, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"ReadToString(3.1459, gotS, ok) ok", 34, &test);
	Tests_ExpectedString((void*)expectS, 256, (void*)gotS, 256, (CHAR*)"RealToString(3.1459, gotS, ok) string", 38, &test);
	return test;
}

static BOOLEAN CharsTest_TestFixedToString (void)
{
	BOOLEAN test, ok;
	SHORTREAL r;
	CHAR expectS[256], gotS[256];
	test = 1;
	r = 3.1459;
	__MOVE("3.14", expectS, 5);
	gotS[0] = 0x00;
	Chars_RealToString(r, (void*)gotS, 256, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"FixedToString(3.1459, 2, gotS, ok) ok", 38, &test);
	return test;
}

static BOOLEAN CharsTest_TestSetToString (void)
{
	BOOLEAN test;
	SET set;
	CHAR expected[256], got[256];
	test = 1;
	set = 0x08ea;
	__MOVE("{1,3,5..7,11}", expected, 14);
	Chars_SetToString(set, (void*)got, 256);
	Tests_ExpectedString((void*)expected, 256, (void*)got, 256, (CHAR*)"SetToString({1,3,5..7,11}, got)", 32, &test);
	set = 0x0;
	__MOVE("{}", expected, 3);
	Chars_SetToString(set, (void*)got, 256);
	Tests_ExpectedString((void*)expected, 256, (void*)got, 256, (CHAR*)"SetToString({}, got)", 21, &test);
	set = 0x01;
	__MOVE("{0}", expected, 4);
	Chars_SetToString(set, (void*)got, 256);
	Tests_ExpectedString((void*)expected, 256, (void*)got, 256, (CHAR*)"SetToString({0}, got)", 22, &test);
	set = 0x086a;
	__MOVE("{1,3,5,6,11}", expected, 13);
	Chars_SetToString(set, (void*)got, 256);
	Tests_ExpectedString((void*)expected, 256, (void*)got, 256, (CHAR*)"SetToString({1,3,5,6,11}, got)", 31, &test);
	return test;
}

static BOOLEAN CharsTest_TestBoolToString (void)
{
	BOOLEAN test;
	CHAR expectS[256], gotS[256];
	test = 1;
	__MOVE("true", expectS, 5);
	Chars_BoolToString(1, (void*)gotS, 256);
	Tests_ExpectedString((void*)expectS, 256, (void*)gotS, 256, (CHAR*)"BoolToString(TRUE, gotS)", 25, &test);
	__MOVE("false", expectS, 6);
	Chars_BoolToString(0, (void*)gotS, 256);
	Tests_ExpectedString((void*)expectS, 256, (void*)gotS, 256, (CHAR*)"BoolToString(FALSE, gotS)", 26, &test);
	return test;
}

static void EnumPtrs(void (*P)(void*))
{
	P(CharsTest_ts);
}


export void *CharsTest__init (void)
{
	__DEFMOD;
	__IMPORT(Chars__init);
	__IMPORT(Out__init);
	__IMPORT(Tests__init);
	__REGMOD("CharsTest", EnumPtrs);
/* BEGIN */
	Tests_Init(&CharsTest_ts, (CHAR*)"Test Chars", 11);
	Tests_Add(&CharsTest_ts, CharsTest_TestLength);
	Tests_Add(&CharsTest_ts, CharsTest_TestInsert);
	Tests_Add(&CharsTest_ts, CharsTest_TestAppend);
	Tests_Add(&CharsTest_ts, CharsTest_TestDelete);
	Tests_Add(&CharsTest_ts, CharsTest_TestReplace);
	Tests_Add(&CharsTest_ts, CharsTest_TestExtract);
	Tests_Add(&CharsTest_ts, CharsTest_TestCap);
	Tests_Add(&CharsTest_ts, CharsTest_TestEqual);
	Tests_Add(&CharsTest_ts, CharsTest_TestAppendChar);
	Tests_Add(&CharsTest_ts, CharsTest_TestInsertChar);
	Tests_Add(&CharsTest_ts, CharsTest_TestWith);
	Tests_Add(&CharsTest_ts, CharsTest_TestTrim);
	Tests_Add(&CharsTest_ts, CharsTest_TestIsX);
	Tests_Add(&CharsTest_ts, CharsTest_TestPadding);
	Tests_Add(&CharsTest_ts, CharsTest_TestIntToString);
	Tests_Add(&CharsTest_ts, CharsTest_TestRealToString);
	Tests_Add(&CharsTest_ts, CharsTest_TestFixedToString);
	Tests_Add(&CharsTest_ts, CharsTest_TestSetToString);
	Tests_Add(&CharsTest_ts, CharsTest_TestBoolToString);
	__ASSERT(Tests_Run(CharsTest_ts), 0, (CHAR*)"CharsTest", 110357);
	__ENDMOD;
}
