#include <stdio.h>
#include <time.h>

/*
NOTES:

Nano to Milli second 1 milli seconds equals 1000000 nano seconds

*/

/* In ofront SetClock was skipped due to portability issues. I am
 * revisiting that in light of how C evolved.
 *
 * SetClock takes normalized year and month, i.e. If year 
 * the year and month at 2021, January the values you pass
 * to SetClock for year and month should be 2021 and 1.
 **/
void SetClock(int second, int minute, int hour, int day, int month, int year, int is_dst, int utc_offset) {
    struct timespec nt;
    struct tm tinfo;
    /* time_t now;
    now = time(NULL); 
    tinfo = localtime(&now); */

    tinfo.tm_year = year - 1900;
    tinfo.tm_mon = month - 1;
    tinfo.tm_mday = day;
    tinfo.tm_hour = hour;
    tinfo.tm_min = minute;
    tinfo.tm_sec = second;
    tinfo.tm_isdst = is_dst;
    tinfo.tm_gmtoff = utc_offset;
    /* What goes here?  stime is not avialable on macOS */
    nt.tv_sec = mktime(&tinfo);
    if (clock_settime(CLOCK_REALTIME, &nt) == -1) {
        perror("clock_settime(CLOCK_REALTIME, &nt) failed");
    }
}

/* modern way of getting time */
int GetClock() {
    int seconds;
    struct timespec now;

    seconds = 0;
    if (clock_gettime(CLOCK_REALTIME, &now) == -1) {
        perror("clock_gettime(CLOCK_REALTIME, now) failed");
    } else {
        /* now now.tv_sec can be combined with localtime() to
         * have a useful conversion of units from EPoch */
        seconds = now.tv_sec;
    }
    return seconds;
}    

/* Let's test out the different approaches */
int main(int argc, char *argv[]) {
    int seconds;
    struct tm *nt;
    struct timespec saved_time;
    time_t now;
    
    seconds = GetClock();
    printf("Get clock, in seconds %d\n", seconds);
    if (clock_gettime(CLOCK_REALTIME, &saved_time) != -1) {
        nt = localtime(&saved_time.tv_sec);
        /* Normalize year as SetClock expects */
        nt->tm_year = nt->tm_year + 1900; 
        /* Normalize month as SetClock expects */
        nt->tm_mon = nt->tm_mon + 1; 
        SetClock(nt->tm_sec, nt->tm_min, nt->tm_hour, nt->tm_mday, nt->tm_mon, nt->tm_year + 1, nt->tm_isdst, nt->tm_gmtoff);
        now = time(NULL);
        nt = localtime(&now);
        printf("%04d-%02d-%02d %02d:%02d:%02d\n", nt->tm_year + 1900, nt->tm_mon + 1, nt->tm_mday, nt->tm_hour, nt->tm_min, nt->tm_sec);
       if (clock_settime(CLOCK_REALTIME, &saved_time) == -1) {
           perror("Could not reset clock after test");
       }
    }
}
