/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"
#include "PathLists.oh"
#include "Tests.oh"


static Tests_TestSet PathListsTest_ts;


static BOOLEAN PathListsTest_TestAppend (void);
static BOOLEAN PathListsTest_TestApply (void);
static BOOLEAN PathListsTest_TestCut (void);
static BOOLEAN PathListsTest_TestEncodeDecode (void);
static BOOLEAN PathListsTest_TestLengthSetDelimiterFind (void);
static BOOLEAN PathListsTest_TestPrepend (void);


/*============================================================================*/

static BOOLEAN PathListsTest_TestEncodeDecode (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedBool(1, 0, (CHAR*)"TestEncodeDecode() not implemented", 35, &test);
	return test;
}

static BOOLEAN PathListsTest_TestLengthSetDelimiterFind (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedBool(1, 0, (CHAR*)"TestLengthSetDelimiterFind() not implemented.", 46, &test);
	return test;
}

static BOOLEAN PathListsTest_TestPrepend (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedBool(1, 0, (CHAR*)"TestPrepend() not implemented.", 31, &test);
	return test;
}

static BOOLEAN PathListsTest_TestAppend (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedBool(1, 0, (CHAR*)"TestAppend() not implemented. ", 31, &test);
	return test;
}

static BOOLEAN PathListsTest_TestCut (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedBool(1, 0, (CHAR*)"TestCut() not implemented. ", 28, &test);
	return test;
}

static BOOLEAN PathListsTest_TestApply (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedBool(1, 0, (CHAR*)"TestApply() not implemented.", 29, &test);
	return test;
}

static void EnumPtrs(void (*P)(void*))
{
	P(PathListsTest_ts);
}


export void *PathListsTest__init (void)
{
	__DEFMOD;
	__IMPORT(PathLists__init);
	__IMPORT(Tests__init);
	__REGMOD("PathListsTest", EnumPtrs);
/* BEGIN */
	Tests_Init(&PathListsTest_ts, (CHAR*)"Test PathLists", 15);
	Tests_Add(&PathListsTest_ts, PathListsTest_TestEncodeDecode);
	Tests_Add(&PathListsTest_ts, PathListsTest_TestLengthSetDelimiterFind);
	Tests_Add(&PathListsTest_ts, PathListsTest_TestPrepend);
	Tests_Add(&PathListsTest_ts, PathListsTest_TestAppend);
	Tests_Add(&PathListsTest_ts, PathListsTest_TestCut);
	Tests_Add(&PathListsTest_ts, PathListsTest_TestApply);
	__ASSERT(Tests_Run(PathListsTest_ts), 0, (CHAR*)"PathListsTest", 14613);
	__ENDMOD;
}
