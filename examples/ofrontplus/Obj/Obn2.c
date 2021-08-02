/* Ofront+ 1.0 -s7 -48 */
#include "SYSTEM.oh"




export INTEGER Obn2_ASH (INTEGER x, INTEGER n);
static INTEGER Obn2_ENTIER (SHORTREAL r);
static void Obn2_HALT (void);
export INTEGER Obn2_MAX (INTEGER x, INTEGER y);
static INTEGER Obn2_MIN (INTEGER x, INTEGER y);
static INTEGER Obn2_ROT (INTEGER x, INTEGER n);


/*============================================================================*/

INTEGER Obn2_ASH (INTEGER x, INTEGER n)
{
	INTEGER res;
	if (n > 0) {
		res = __LSHL(x, n, INTEGER);
	} else {
		res = __ASHR(x, n, INTEGER);
	}
	return res;
}

/*----------------------------------------------------------------------------*/
INTEGER Obn2_MAX (INTEGER x, INTEGER y)
{
	INTEGER res;
	if (x > y) {
		res = x;
	} else {
		res = y;
	}
	return res;
}

/*----------------------------------------------------------------------------*/
static INTEGER Obn2_MIN (INTEGER x, INTEGER y)
{
	INTEGER res;
	if (x < y) {
		res = x;
	} else {
		res = y;
	}
	return res;
}

static INTEGER Obn2_ENTIER (SHORTREAL r)
{
	return (INTEGER)__ENTIER(r);
}

static void Obn2_HALT (void)
{
	__HALT(0, (CHAR*)"Obn2", 15375);
}

static INTEGER Obn2_ROT (INTEGER x, INTEGER n)
{
	return __ROTR(x, n, INTEGER);
}


export void *Obn2__init (void)
{
	__DEFMOD;
	__REGMOD("Obn2", 0);
/* BEGIN */
	__ENDMOD;
}
