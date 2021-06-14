
static void uname_(char opt_, char dest_[], OBNC_INTEGER dest_len)
{
    FILE *in;
    char ch;
    int i;
    char cmd[9];

    /* Setup our POSIX command */
    cmd[0] = 'u'; cmd[1] = 'n'; cmd[2] = 'a';
    cmd[3] = 'm'; cmd[4] = 'e'; cmd[5] = ' '; 
    cmd[6] = '-'; cmd[7] = opt_;
    cmd[8] = '\x00';
    /* open a process and read stdout from a uname call */
    in = popen(cmd, "r");
    if (!in) return;
    /* for each character output by uname copy into our dest string */ 
    i = 0; dest_[i] = '\x00';
    while ( ((ch = fgetc(in)) != EOF) && (i < (dest_len - 1) ) ) {
        if ((ch == '\n') || (ch == '\r')) {
           dest_[i] = '\x00';  
           break;
        } else {
           dest_[i] = ch;
        }
        i = i + 1;
        dest_[i] = '\x00'; /* add a trailing NULL CHAR */
    }
    /* close our pipe and done */
    pclose(in);
}

