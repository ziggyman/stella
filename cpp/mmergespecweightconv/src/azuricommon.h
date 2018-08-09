/****************************************************/
/* Andreas Ritter                                   */
/* aritter@aip.de                                   */
/* gcc-4.0                                          */
/* 09/03/06                                         */
/****************************************************
#ifndef __AZURI_COMMON__
#define __AZURI_COMMON__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#ifdef __DEBUG__
#define __DEBUG_AZURICOMMON__
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

extern float truncf(float x);
extern float roundf(float x);

#define _ISOC99_SOURCE

long countlines(const char fname[255]);
double calcintens(const double x1, const double x2, const double xn, const double y1, const double y2);
double absd(double val);
int charrcat(char inoutarr[255], const char *strtoapp, int oldlength);
int charposincharrfrom(char inarr[255], const char lookfor, int start);
int charposincharr(char inarr[255], const char lookfor);
int lastcharposincharr(char inarr[255], const char lookfor);
int read2dfiletoarrays(const char* filename, double* warr, double* varr);
#endif
*/
