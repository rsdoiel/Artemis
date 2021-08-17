/*
 * Unix.c provided an interface to C level libraries needed by Unix.Mod. 
 *
 * Copyright (C) 2021 R. S. Doiel
 *
 * Released under The 3-Clause BSD License.
 * See https://opensource.org/licenses/BSD-3-Clause
 *
 */

#include ".obnc/artUnix.h"
#include <obnc/OBNC.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define OBERON_SOURCE_FILENAME "artUnix.obn"

static char kernel_[24], architecture_[24];

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


void artUnix__Exit_(OBNC_INTEGER exitCode_)
{
  exit(exitCode_);
}


static OBNC_INTEGER minimum_(OBNC_INTEGER a_, OBNC_INTEGER b_)
{
	OBNC_INTEGER res_;

	if (a_ < b_) {
		res_ = a_;
	}
	else {
		res_ = b_;
	}
	return res_;
}


static void copyChars_(const char source_[], OBNC_INTEGER source_len, char dest_[], OBNC_INTEGER dest_len)
{
	OBNC_INTEGER i_, l_;

	l_ = minimum_(source_len, dest_len) - 2;
	if (l_ < 1) {
		l_ = 0;
	}
	i_ = 0;
	dest_[OBNC_IT(i_, dest_len, 49)] = '\x00';
	while ((i_ < l_) && (source_[OBNC_IT(i_, source_len, 50)] != '\x00')) {
		dest_[OBNC_IT(i_, dest_len, 51)] = source_[OBNC_IT(i_, source_len, 51)];
		OBNC_INC(i_);
	}
	dest_[OBNC_IT(i_, dest_len, 54)] = '\x00';
	OBNC_DEC(i_);
	if ((dest_[OBNC_IT(i_, dest_len, 55)] == '\x10') || (dest_[OBNC_IT(i_, dest_len, 55)] == '\x13')) {
		dest_[OBNC_IT(i_, dest_len, 56)] = '\x00';
	}
}


void artUnix__KernelName_(char dest_[], OBNC_INTEGER dest_len)
{

	if (kernel_[0] == '\x00') {
		uname_('s', kernel_, 24);
	}
	copyChars_(kernel_, 24, dest_, dest_len);
}


void artUnix__Architecture_(char dest_[], OBNC_INTEGER dest_len)
{

	if (architecture_[0] == '\x00') {
		uname_('m', architecture_, 24);
	}
	copyChars_(architecture_, 24, dest_, dest_len);
}


void artUnix__Init(void)
{
	static int initialized = 0;

	if (! initialized) {
		kernel_[0] = '\x00';
		architecture_[0] = '\x00';
		initialized = 1;
	}
}
