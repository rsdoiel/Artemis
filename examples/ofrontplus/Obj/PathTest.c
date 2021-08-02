/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"
#include "Tests.oh"
#include "Path.oh"
#include "Chars.oh"


static Tests_TestSet PathTest_ts;


static BOOLEAN PathTest_TestAppend (void);
static BOOLEAN PathTest_TestBasename (void);
static BOOLEAN PathTest_TestDirname (void);
static BOOLEAN PathTest_TestExt (void);
static BOOLEAN PathTest_TestMaxPath (void);
static BOOLEAN PathTest_TestPrepend (void);
static BOOLEAN PathTest_TestSetDelimiter (void);


/*============================================================================*/

static BOOLEAN PathTest_TestMaxPath (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedInt(1024, 1024, (CHAR*)"Current path maximum assumption", 32, &test);
	return test;
}

static BOOLEAN PathTest_TestSetDelimiter (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedChar('/', Path_delimiter, (CHAR*)"Checking default delimiter", 27, &test);
	Path_SetDelimiter(0x92);
	Tests_ExpectedChar(0x92, Path_delimiter, (CHAR*)"Checking set delimiter to \';\'", 30, &test);
	Path_SetDelimiter('/');
	Tests_ExpectedChar('/', Path_delimiter, (CHAR*)"Checking set delimiter to \':\'", 30, &test);
	return test;
}

static BOOLEAN PathTest_TestPrepend (void)
{
	BOOLEAN test, ok;
	CHAR a[1024];
	test = 1;
	a[0] = 0x00;
	Path_Prepend((CHAR*)"", 1, (void*)a, 1024, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"Path.Prepend(\'\', a) ok -> \'\'", 29, &test);
	Tests_ExpectedString((CHAR*)"", 1, (void*)a, 1024, (CHAR*)"Path.Prepend(\'\', a)", 20, &test);
	Path_Prepend((CHAR*)"/me", 4, (void*)a, 1024, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"Path.Prepend(\'/me\', a) ok -> /me", 33, &test);
	Tests_ExpectedString((CHAR*)"/me", 4, (void*)a, 1024, (CHAR*)"Path.Prepend(\'/me\', a)", 23, &test);
	Path_Prepend((CHAR*)"/home", 6, (void*)a, 1024, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"Path.Prepend(\'/home\', a) ok -> /home/me", 40, &test);
	Tests_ExpectedString((CHAR*)"/home/me", 9, (void*)a, 1024, (CHAR*)"Path.Prepend(\'home\', a)", 24, &test);
	return test;
}

static BOOLEAN PathTest_TestAppend (void)
{
	BOOLEAN test, ok;
	CHAR a[1024];
	test = 1;
	a[0] = 0x00;
	Path_Append((CHAR*)"", 1, (void*)a, 1024, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"Path.Append(\'\', a) ok -> \'\'", 28, &test);
	Tests_ExpectedString((CHAR*)"", 1, (void*)a, 1024, (CHAR*)"Path.Append(\'\', a)", 19, &test);
	Path_Append((CHAR*)"/", 2, (void*)a, 1024, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"Path.Append(\'/\', a) ok -> \'/\'", 30, &test);
	Tests_ExpectedString((CHAR*)"/", 2, (void*)a, 1024, (CHAR*)"Path.Append(\'/\', a)", 20, &test);
	Path_Append((CHAR*)"home", 5, (void*)a, 1024, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"Path.Append(\'home\', a) ok -> /home", 35, &test);
	Tests_ExpectedString((CHAR*)"/home", 6, (void*)a, 1024, (CHAR*)"Path.Append(\'home\', a)", 23, &test);
	Path_Append((CHAR*)"me", 3, (void*)a, 1024, &ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"Path.Append(\'\', a) ok -> /home/me", 34, &test);
	Tests_ExpectedString((CHAR*)"/home/me", 9, (void*)a, 1024, (CHAR*)"Path.Append(\'me\', a) ok -> /home/me", 36, &test);
	return test;
}

static BOOLEAN PathTest_TestBasename (void)
{
	BOOLEAN test, ok;
	CHAR a[1024], expected[1024], got[1024];
	test = 1;
	__MOVE("/home/me/.profile", a, 18);
	__MOVE(".profile", expected, 9);
	Path_Basename((void*)a, 1024, (void*)got, 1024, ok);
	Tests_ExpectedBool(1, ok, (CHAR*)"Basename(a, got, ok) ok -> \?", 29, &test);
	Tests_ExpectedString((CHAR*)".profile", 9, (void*)got, 1024, (CHAR*)"Path.Basename(a, got, ok)", 26, &test);
	return test;
}

static BOOLEAN PathTest_TestDirname (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedBool(1, 0, (CHAR*)"TestDirname() not implemented.", 31, &test);
	return test;
}

static BOOLEAN PathTest_TestExt (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedBool(1, 0, (CHAR*)"TestExt() not implemented.", 27, &test);
	return test;
}

static void EnumPtrs(void (*P)(void*))
{
	P(PathTest_ts);
}


export void *PathTest__init (void)
{
	__DEFMOD;
	__IMPORT(Chars__init);
	__IMPORT(Path__init);
	__IMPORT(Tests__init);
	__REGMOD("PathTest", EnumPtrs);
/* BEGIN */
	Tests_Init(&PathTest_ts, (CHAR*)"Test Path", 10);
	Tests_Add(&PathTest_ts, PathTest_TestMaxPath);
	Tests_Add(&PathTest_ts, PathTest_TestSetDelimiter);
	Tests_Add(&PathTest_ts, PathTest_TestPrepend);
	Tests_Add(&PathTest_ts, PathTest_TestAppend);
	Tests_Add(&PathTest_ts, PathTest_TestDirname);
	Tests_Add(&PathTest_ts, PathTest_TestBasename);
	Tests_Add(&PathTest_ts, PathTest_TestExt);
	__ASSERT(Tests_Run(PathTest_ts), 0, (CHAR*)"PathTest", 24085);
	__ENDMOD;
}
