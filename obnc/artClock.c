/*
 * Clock.c provides an interface to the C level libraries needed Clock.Mod.
 *
 * Copyright (C) 2021 R. S. Doiel
 *
 * Released under The 3-Clause BSD License.
 * See https://opensource.org/licenses/BSD-3-Clause
 *
 */

#include ".obnc/artClock.h"
#include <obnc/OBNC.h>
#include <stdio.h>
#include <time.h>

#define OBERON_SOURCE_FILENAME "artClock.obn"

const int artClock__ClockDesc_id;
const int *const artClock__ClockDesc_ids[1] = {&artClock__ClockDesc_id};
const OBNC_Td artClock__ClockDesc_td = {artClock__ClockDesc_ids, 1};

artClock__Clock_ artClock__clock_;

static int clockError_;

static void GetRtcTime_(OBNC_INTEGER *second_, OBNC_INTEGER *minute_, OBNC_INTEGER *hour_, OBNC_INTEGER *day_, OBNC_INTEGER *month_, OBNC_INTEGER *year_, OBNC_INTEGER *wDay_, OBNC_INTEGER *yDay_, OBNC_INTEGER *isDST_, OBNC_INTEGER *utcOffset_, OBNC_INTEGER *seconds_, OBNC_INTEGER *nanoSeconds_, int *ok_)
{
  struct timespec now;
  struct tm *dt;

  *ok_ = 1; /* Assume clock_gettime() successful */
  if (clock_gettime(CLOCK_REALTIME, &now) == -1) {
    perror("clock_gettime(CLOCK_REALTIME, &now) failed");
    *ok_ = 0; /* clock_gettime() failed for some reason */
  } else {
    *seconds_ = now.tv_sec;
    *nanoSeconds_ = now.tv_nsec;
    dt = localtime(&now.tv_sec);
    *second_ = dt->tm_sec;
    *minute_ = dt->tm_min;
    *hour_ = dt->tm_hour;
    *day_ = dt->tm_mday;
    *month_ = dt->tm_mon + 1; /* We want 1 to 12 rather than 0 to 11 */
    *year_ = dt->tm_year + 1900; /* Normalize to current year */
    *wDay_ = dt->tm_wday;
    *yDay_ = dt->tm_yday;
    *isDST_ = dt->tm_isdst;
    *utcOffset_ = dt->tm_gmtoff;
  }
}


static void SetRtcTime_(OBNC_INTEGER second_, OBNC_INTEGER minute_, OBNC_INTEGER hour_, OBNC_INTEGER day_, OBNC_INTEGER month_, OBNC_INTEGER year_, OBNC_INTEGER wDay_, OBNC_INTEGER yDay_, OBNC_INTEGER isDST_, OBNC_INTEGER utcOffset_, int *ok_)
{
  struct timespec nt;
  struct tm dt;

  dt.tm_sec = second_;
  dt.tm_min = minute_;
  dt.tm_hour = hour_;
  dt.tm_mday = day_; 
  dt.tm_mon = (month_ - 1); /* de-normalize to 0 to 11 from 1 to 12 */
  dt.tm_year = (year_ - 1900); /* adjust year to reflect POSIX value */
  dt.tm_wday = wDay_;
  dt.tm_yday = yDay_;
/* NOTE: tm_idst and tm_gmtoff are not ISO C or POSIX, they come from
   BSD and GNU systems. They appear to be available on macOS */
  dt.tm_isdst = isDST_;
  dt.tm_gmtoff = utcOffset_;
/* NOTE: You must have root permissions for clock_settime() to work */
  nt.tv_sec = mktime(&dt);
  if (clock_settime(CLOCK_REALTIME, &nt) == -1) {
    perror("clock_settime(CLOCK_REALTIME, &nt) failed");
    *ok_ = 0;
  } else {
    *ok_ = 1;
  }
}


void artClock__Copy_(artClock__Clock_ source_, artClock__Clock_ *dest_)
{

	(*OBNC_PT((*dest_), 76)).seconds_ = (*OBNC_PT(source_, 76)).seconds_;
	(*OBNC_PT((*dest_), 77)).nanoSeconds_ = (*OBNC_PT(source_, 77)).nanoSeconds_;
	(*OBNC_PT((*dest_), 78)).second_ = (*OBNC_PT(source_, 78)).second_;
	(*OBNC_PT((*dest_), 79)).minute_ = (*OBNC_PT(source_, 79)).minute_;
	(*OBNC_PT((*dest_), 80)).hour_ = (*OBNC_PT(source_, 80)).hour_;
	(*OBNC_PT((*dest_), 81)).day_ = (*OBNC_PT(source_, 81)).day_;
	(*OBNC_PT((*dest_), 82)).month_ = (*OBNC_PT(source_, 82)).month_;
	(*OBNC_PT((*dest_), 83)).year_ = (*OBNC_PT(source_, 83)).year_;
	(*OBNC_PT((*dest_), 84)).wDay_ = (*OBNC_PT(source_, 84)).wDay_;
	(*OBNC_PT((*dest_), 85)).yDay_ = (*OBNC_PT(source_, 85)).yDay_;
	(*OBNC_PT((*dest_), 86)).isDST_ = (*OBNC_PT(source_, 86)).isDST_;
	(*OBNC_PT((*dest_), 87)).utcOffset_ = (*OBNC_PT(source_, 87)).utcOffset_;
}


void artClock__Update_(void)
{
	OBNC_INTEGER second_, minute_, hour_, day_, month_, year_, wDay_, yDay_, isDST_, utcOffset_, seconds_, nanoSeconds_;
	int ok_;

	GetRtcTime_(&second_, &minute_, &hour_, &day_, &month_, &year_, &wDay_, &yDay_, &isDST_, &utcOffset_, &seconds_, &nanoSeconds_, &ok_);
	if (artClock__clock_ == 0) {
		OBNC_NEW(artClock__clock_, &artClock__ClockDesc_td, struct artClock__ClockDesc_Heap, OBNC_ATOMIC_NOINIT_ALLOC);
	}
	clockError_ = ! ok_;
	if (ok_) {
		(*OBNC_PT(artClock__clock_, 107)).seconds_ = seconds_;
		(*OBNC_PT(artClock__clock_, 108)).nanoSeconds_ = nanoSeconds_;
		(*OBNC_PT(artClock__clock_, 109)).year_ = year_;
		(*OBNC_PT(artClock__clock_, 110)).month_ = month_;
		(*OBNC_PT(artClock__clock_, 111)).day_ = day_;
		(*OBNC_PT(artClock__clock_, 112)).hour_ = hour_;
		(*OBNC_PT(artClock__clock_, 113)).minute_ = minute_;
		(*OBNC_PT(artClock__clock_, 114)).second_ = second_;
		(*OBNC_PT(artClock__clock_, 115)).wDay_ = wDay_;
		(*OBNC_PT(artClock__clock_, 116)).yDay_ = yDay_;
		(*OBNC_PT(artClock__clock_, 117)).isDST_ = isDST_;
		(*OBNC_PT(artClock__clock_, 118)).utcOffset_ = utcOffset_;
	}
}


void artClock__Get_(artClock__Clock_ *c_)
{

	artClock__Update_();
	if ((*c_) == 0) {
		OBNC_NEW((*c_), &artClock__ClockDesc_td, struct artClock__ClockDesc_Heap, OBNC_ATOMIC_NOINIT_ALLOC);
	}
	artClock__Copy_(artClock__clock_, &(*c_));
}


void artClock__Set_(artClock__Clock_ c_, int *ok_)
{

	SetRtcTime_((*OBNC_PT(c_, 147)).second_, (*OBNC_PT(c_, 147)).minute_, (*OBNC_PT(c_, 147)).hour_, (*OBNC_PT(c_, 147)).day_, (*OBNC_PT(c_, 147)).month_, (*OBNC_PT(c_, 147)).year_, (*OBNC_PT(c_, 147)).wDay_, (*OBNC_PT(c_, 147)).yDay_, (*OBNC_PT(c_, 147)).isDST_, (*OBNC_PT(c_, 147)).utcOffset_, &(*ok_));
	if ((*ok_)) {
		artClock__Copy_(c_, &artClock__clock_);
	}
}


void artClock__Init(void)
{
	static int initialized = 0;

	if (! initialized) {
		artClock__Update_();
		initialized = 1;
	}
}
