/**
 * extConvert.c provides the C implementation of primatives
 * that are used in extConvert.m
 */

#include <stdlib.h>
#include <stdio.h>

void conv_int_to_string(int i, char *s, int l) {
  snprintf(s, l, "%d", i);
}

void conv_real_to_string(float r, char *s, int l) {
  snprintf(s, l, "%f", r);
}

void conv_real_to_exp_string(float r, char *s, int l) {
  snprintf(s, l, "%e", r);
}

void conv_string_to_int(char *s, int *i) {
    *i = atoi(s);
}

void conv_string_to_real(char *s, float *r) {
    *r = atof(s);
}
