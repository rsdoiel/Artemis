/*
 * artClock.c provides an interface to C libraries used to implement artClock.m.
 *
 * Copyright (C) 2021 R. S. Doiel
 *
 * Released under The 3-Clause BSD License.
 * See https://opensource.org/licenses/BSD-3-Clause
 *
 */
#include <stdio.h>
#include <time.h>

void get_rtc_time(int *second_, int *minute_, int *hour_, int *day_, int *month_, int *year_, int *wDay_, int *yDay_, int *isDST_, int *utcOffset_, int *seconds_, int *nanoSeconds_, int *ok_)
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



void set_rtc_time(int second_, int minute_, int hour_, int day_, int month_, int year_, int wDay_, int yDay_, int isDST_, int utcOffset_, int *ok_)
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

