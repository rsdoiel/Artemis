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
     perror("clock_gettime(CLOCK_REALTIME, &nt) failed");
    *ok_ = 0;
  } else {
    *ok_ = 1;
  }
}
