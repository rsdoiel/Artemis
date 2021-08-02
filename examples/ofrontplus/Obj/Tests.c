/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"
#include "Out.oh"

typedef
	BOOLEAN (*Tests_TestProc)(void);

typedef
	struct Tests_TestSetDesc *Tests_TestSet;

typedef
	struct Tests_TestSetDesc {
		CHAR title[1024];
		Tests_TestProc fn;
		Tests_TestSet next;
	} Tests_TestSetDesc;



export SYSTEM_ADRINT *Tests_TestSetDesc__typ;

export void Tests_Add (Tests_TestSet *ts, Tests_TestProc fn);
export void Tests_DisplayString (CHAR *msg, INTEGER msg__len, CHAR *source, INTEGER source__len);
export void Tests_ExpectedBool (BOOLEAN expected, BOOLEAN got, CHAR *msg, INTEGER msg__len, BOOLEAN *test);
export void Tests_ExpectedBytes (CHAR *expected, INTEGER expected__len, CHAR *got, INTEGER got__len, INTEGER n, CHAR *msg, INTEGER msg__len, BOOLEAN *test);
export void Tests_ExpectedChar (CHAR expected, CHAR got, CHAR *msg, INTEGER msg__len, BOOLEAN *test);
export void Tests_ExpectedInt (INTEGER expected, INTEGER got, CHAR *msg, INTEGER msg__len, BOOLEAN *test);
export void Tests_ExpectedReal (SHORTREAL expected, SHORTREAL got, CHAR *msg, INTEGER msg__len, BOOLEAN *test);
export void Tests_ExpectedSet (SET expected, SET got, CHAR *msg, INTEGER msg__len, BOOLEAN *test);
export void Tests_ExpectedString (CHAR *s1, INTEGER s1__len, CHAR *s2, INTEGER s2__len, CHAR *msg, INTEGER msg__len, BOOLEAN *test);
export void Tests_Init (Tests_TestSet *ts, CHAR *title, INTEGER title__len);
static INTEGER Tests_Length (CHAR *source, INTEGER source__len);
export BOOLEAN Tests_Run (Tests_TestSet ts);
export void Tests_ShowTitle (CHAR *s, INTEGER s__len);
export void Tests_Summarize (CHAR *title, INTEGER title__len, INTEGER successes, INTEGER errors);
export void Tests_Test (Tests_TestProc fn, INTEGER *success, INTEGER *errors);
static void Tests_displaySet (SET s);
static void Tests_displayStrings (CHAR *s1, INTEGER s1__len, CHAR *s2, INTEGER s2__len, CHAR *msg, INTEGER msg__len);


/*============================================================================*/

static INTEGER Tests_Length (CHAR *source, INTEGER source__len)
{
	INTEGER i, l;
	i = 0;
	l = source__len;
	while (i < l && source[__X(i, source__len, (CHAR*)"Tests", 8994)] != 0x00) {
		i += 1;
	}
	return i;
}

void Tests_DisplayString (CHAR *msg, INTEGER msg__len, CHAR *source, INTEGER source__len)
{
	String((void*)msg, msg__len);
	String((CHAR*)" \'", 3);
	String((void*)source, source__len);
	String((CHAR*)"\'", 2);
	Ln();
}

/*----------------------------------------------------------------------------*/
static void Tests_displayStrings (CHAR *s1, INTEGER s1__len, CHAR *s2, INTEGER s2__len, CHAR *msg, INTEGER msg__len)
{
	String((CHAR*)"Expected \'", 11);
	String((void*)s1, s1__len);
	String((CHAR*)"\', got \'", 9);
	String((void*)s2, s2__len);
	String((CHAR*)"\' ", 3);
	String((void*)msg, msg__len);
	Ln();
}

void Tests_ExpectedInt (INTEGER expected, INTEGER got, CHAR *msg, INTEGER msg__len, BOOLEAN *test)
{
	if (expected != got) {
		String((CHAR*)"Expected ", 10);
		Int(expected, 1);
		String((CHAR*)", got ", 7);
		Int(got, 1);
		String((CHAR*)" ", 2);
		String((void*)msg, msg__len);
		Ln();
		*test = 0;
	}
}

/*----------------------------------------------------------------------------*/
void Tests_ExpectedReal (SHORTREAL expected, SHORTREAL got, CHAR *msg, INTEGER msg__len, BOOLEAN *test)
{
	if (expected != got) {
		String((CHAR*)"Expected ", 10);
		Real(expected, 1);
		String((CHAR*)", got ", 7);
		Real(got, 1);
		String((CHAR*)" ", 2);
		String((void*)msg, msg__len);
		Ln();
		*test = 0;
	}
}

/*----------------------------------------------------------------------------*/
void Tests_ExpectedString (CHAR *s1, INTEGER s1__len, CHAR *s2, INTEGER s2__len, CHAR *msg, INTEGER msg__len, BOOLEAN *test)
{
	INTEGER i, lengthS1, lengthS2;
	BOOLEAN ok;
	ok = 1;
	lengthS1 = Tests_Length((void*)s1, s1__len);
	lengthS2 = Tests_Length((void*)s2, s2__len);
	if (lengthS1 != lengthS2) {
		Tests_displayStrings((void*)s1, s1__len, (void*)s2, s2__len, (void*)msg, msg__len);
		*test = 0;
	} else {
		i = 0;
		ok = 1;
		while (ok && i < lengthS1) {
			if (s1[__X(i, s1__len, (CHAR*)"Tests", 24329)] != s2[__X(i, s2__len, (CHAR*)"Tests", 24329)]) {
				Tests_displayStrings((void*)msg, msg__len, (void*)s1, s1__len, (void*)s2, s2__len);
				*test = 0;
				ok = 0;
			}
			i += 1;
		}
	}
}

/*----------------------------------------------------------------------------*/
void Tests_ExpectedChar (CHAR expected, CHAR got, CHAR *msg, INTEGER msg__len, BOOLEAN *test)
{
	if (expected != got) {
		*test = 0;
		String((CHAR*)"Expected \'", 11);
		Char(expected);
		String((CHAR*)"\', got \'", 9);
		Char(got);
		String((CHAR*)"\' ", 3);
		String((void*)msg, msg__len);
		Ln();
	}
}

/*----------------------------------------------------------------------------*/
static struct ExpectedBool__3 {
	struct ExpectedBool__3 *lnk;
} *ExpectedBool__3_s;

static void __4 (BOOLEAN val);

static void __4 (BOOLEAN val)
{
	if (val) {
		String((CHAR*)"TRUE", 5);
	} else {
		String((CHAR*)"FALSE", 6);
	}
}

void Tests_ExpectedBool (BOOLEAN expected, BOOLEAN got, CHAR *msg, INTEGER msg__len, BOOLEAN *test)
{
	struct ExpectedBool__3 _s;
	_s.lnk = ExpectedBool__3_s;
	ExpectedBool__3_s = &_s;
	if ((expected == 1 && got == 0) || (expected == 0 && got == 1)) {
		String((CHAR*)"Expected ", 10);
		__4(expected);
		String((CHAR*)", got ", 7);
		__4(got);
		String((CHAR*)" ", 2);
		String((void*)msg, msg__len);
		Ln();
		*test = 0;
	}
	ExpectedBool__3_s = _s.lnk;
}

/*----------------------------------------------------------------------------*/
static struct ExpectedBytes__6 {
	struct ExpectedBytes__6 *lnk;
} *ExpectedBytes__6_s;

static INTEGER __7 (INTEGER a, INTEGER b);

static INTEGER __7 (INTEGER a, INTEGER b)
{
	INTEGER res;
	if (a < b) {
		res = a;
	} else {
		res = b;
	}
	return res;
}

void Tests_ExpectedBytes (CHAR *expected, INTEGER expected__len, CHAR *got, INTEGER got__len, INTEGER n, CHAR *msg, INTEGER msg__len, BOOLEAN *test)
{
	INTEGER i, l;
	struct ExpectedBytes__6 _s;
	_s.lnk = ExpectedBytes__6_s;
	ExpectedBytes__6_s = &_s;
	l = __7(expected__len, got__len);
	if (n <= l) {
		i = 0;
		while (*test && i < n - 1) {
			if (expected[__X(i, expected__len, (CHAR*)"Tests", 46601)] != got[__X(i, got__len, (CHAR*)"Tests", 46601)]) {
				*test = 0;
				String((CHAR*)"Expected (pos: ", 16);
				Int(i, 1);
				String((CHAR*)") ", 3);
				Int(expected[__X(i, expected__len, (CHAR*)"Tests", 45855)], 1);
				String((CHAR*)", got ", 7);
				Int(got[__X(i, got__len, (CHAR*)"Tests", 45895)], 1);
				String((CHAR*)" ", 2);
				String((void*)msg, msg__len);
				Ln();
			}
			i += 1;
		}
	} else {
		*test = 0;
		String((CHAR*)"Expected length N (", 20);
		Int(n, 1);
		String((CHAR*)"), got length (", 16);
		Int(l, 1);
		String((CHAR*)") ", 3);
		String((void*)msg, msg__len);
		Ln();
	}
	ExpectedBytes__6_s = _s.lnk;
}

/*----------------------------------------------------------------------------*/
static void Tests_displaySet (SET s)
{
	INTEGER i;
	Char('{');
	i = 0;
	while (i <= 31) {
		if (i > 0) {
			String((CHAR*)", ", 3);
		}
		Int(i, 1);
		i += 1;
	}
	Char('}');
}

void Tests_ExpectedSet (SET expected, SET got, CHAR *msg, INTEGER msg__len, BOOLEAN *test)
{
	if (expected == got) {
		String((CHAR*)"Expected set ", 14);
		Tests_displaySet(expected);
		String((CHAR*)" got ", 6);
		Tests_displaySet(got);
		String((CHAR*)" ", 2);
		String((void*)msg, msg__len);
		Ln();
		*test = 0;
	}
}

/*----------------------------------------------------------------------------*/
void Tests_ShowTitle (CHAR *s, INTEGER s__len)
{
	INTEGER i, l;
	l = Tests_Length((void*)s, s__len) - 1;
	Ln();
	String((void*)s, s__len);
	Ln();
	i = 0;
	while (i <= l) {
		String((CHAR*)"=", 2);
		i += 1;
	}
	Ln();
}

/*----------------------------------------------------------------------------*/
void Tests_Test (Tests_TestProc fn, INTEGER *success, INTEGER *errors)
{
	if ((*fn)()) {
		*success = *success + 1;
	} else {
		*errors = *errors + 1;
	}
}

/*----------------------------------------------------------------------------*/
void Tests_Summarize (CHAR *title, INTEGER title__len, INTEGER successes, INTEGER errors)
{
	if (errors > 0) {
		Ln();
		String((CHAR*)"Success: ", 10);
		Int(successes, 5);
		Ln();
		String((CHAR*)" Errors: ", 10);
		Int(errors, 5);
		Ln();
		String((CHAR*)"-------------------------------------------", 44);
		Ln();
		String((CHAR*)"  Total: ", 10);
		Int(successes + errors, 5);
		Ln();
		Ln();
		String((void*)title, title__len);
		String((CHAR*)" failed.", 9);
		Ln();
		__HALT(0, (CHAR*)"Tests", 64529);
	} else {
		String((CHAR*)"OK, ", 5);
		String((void*)title, title__len);
		Ln();
	}
}

/*----------------------------------------------------------------------------*/
void Tests_Init (Tests_TestSet *ts, CHAR *title, INTEGER title__len)
{
	if (*ts == NIL) {
		__NEW(*ts, Tests_TestSetDesc);
	}
	__STRCOPY(title, (*ts)->title, __MIN(1024, title__len), (CHAR*)"Tests", 67603);
	(*ts)->fn = NIL;
	(*ts)->next = NIL;
}

/*----------------------------------------------------------------------------*/
void Tests_Add (Tests_TestSet *ts, Tests_TestProc fn)
{
	Tests_TestSet cur = NIL;
	cur = *ts;
	if (cur->fn != NIL) {
		while (cur->next != NIL) {
			cur = cur->next;
		}
		__NEW(cur->next, Tests_TestSetDesc);
		cur = cur->next;
	}
	cur->fn = fn;
	cur->next = NIL;
}

/*----------------------------------------------------------------------------*/
BOOLEAN Tests_Run (Tests_TestSet ts)
{
	CHAR title[1024];
	INTEGER i, successes, errors;
	BOOLEAN ok, result;
	successes = 0;
	errors = 0;
	i = 0;
	while (i <= 1023) {
		title[__X(i, 1024, (CHAR*)"Tests", 74267)] = ts->title[__X(i, 1024, (CHAR*)"Tests", 74267)];
		i += 1;
	}
	ok = 1;
	while (ts != NIL) {
		if (ts->fn != NIL) {
			result = (*ts->fn)();
			if (result) {
				successes += 1;
			} else {
				errors += 1;
				ok = 0;
			}
		}
		ts = ts->next;
	}
	if (ok) {
		String((CHAR*)"OK, ", 5);
		String((void*)title, 1024);
		Ln();
	} else {
		Tests_ShowTitle((void*)title, 1024);
		Tests_Summarize((void*)title, 1024, successes, errors);
	}
	return ok;
}

/*----------------------------------------------------------------------------*/
__TDESC(Tests_TestSetDesc__desc, 2, 1) = {__TDFLDS("TestSetDesc", 1032), {1028, -8}};

export void *Tests__init (void)
{
	__DEFMOD;
	__IMPORT(Out__init);
	__REGMOD("Tests", 0);
	__INITYP(Tests_TestSetDesc, Tests_TestSetDesc, 0);
/* BEGIN */
	__ENDMOD;
}
