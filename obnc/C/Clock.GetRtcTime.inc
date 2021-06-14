static void GetRtcTime_(OBNC_INTEGER *second_, OBNC_INTEGER *minute_, OBNC_INTEGER *hour_, OBNC_INTEGER *day_, OBNC_INTEGER *month_, OBNC_INTEGER *year_, OBNC_INTEGER *wDay_, OBNC_INTEGER *yDay_, OBNC_INTEGER *isDST_, OBNC_INTEGER *utcOffset_, OBNC_INTEGER *seconds_, OBNC_INTEGER *nanoSeconds_, int *ok_)
{
  struct timespec now;
  struct tm *dt;

  *ok_ = 1; /* Assume clock_gettime() successful */
  if (clock_gettime(CLOCK_REALTIME, &now) == -1) {
    *ok_ = 0; /* clock_gettime() failed for some reason */
    perror("clock_gettime(CLOCK_REALTIME, &now) failed");
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
