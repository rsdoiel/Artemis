/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"
#include "Tests.oh"


static Tests_TestSet Obn2Test_ts;


static BOOLEAN Obn2Test_TestMinMax (void);
static BOOLEAN Obn2Test_TestShifts (void);


/*============================================================================*/

static BOOLEAN Obn2Test_TestMinMax (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedBool(1, 0, (CHAR*)"TestMinMax() not implemented.", 30, &test);
	return test;
}

static BOOLEAN Obn2Test_TestShifts (void)
{
	BOOLEAN test;
	test = 1;
	Tests_ExpectedBool(1, 0, (CHAR*)"TestShifts() not implemented.", 30, &test);
	return test;
}

static void EnumPtrs(void (*P)(void*))
{
	P(Obn2Test_ts);
}


export void *Obn2Test__init (void)
{
	__DEFMOD;
	__IMPORT(Tests__init);
	__REGMOD("Obn2Test", EnumPtrs);
/* BEGIN */
	Tests_Init(&Obn2Test_ts, (CHAR*)"Obn2", 5);
	Tests_Add(&Obn2Test_ts, Obn2Test_TestMinMax);
	Tests_Add(&Obn2Test_ts, Obn2Test_TestShifts);
	__ASSERT(Tests_Run(Obn2Test_ts), 0, (CHAR*)"Obn2Test", 8467);
	__ENDMOD;
}
