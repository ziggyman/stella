/***************************************************************************
 * addon.h is part of Math Graphic Library
 * Copyright (C) 2007-2012 Alexey Balakin <mathgl.abalakin@gmail.ru>       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 3 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#ifndef _MGL_ADDON_H_
#define _MGL_ADDON_H_
//-----------------------------------------------------------------------------
#include "mgl2/define.h"
#ifdef __cplusplus
//-----------------------------------------------------------------------------
/// Get integer power of x
dual MGL_EXPORT mgl_ipowc(dual x,int n);
/// Get exp(i*a)
dual MGL_EXPORT mgl_expi(dual a);
/// Get exp(i*a)
dual MGL_EXPORT mgl_expi(double a);

/// Explicit scheme for 1 step of axial diffraction
bool MGL_EXPORT mgl_difr_axial(dual *a, int n, dual q, int Border,dual *b, dual *d, int kk, double di);
/// Explicit scheme for 1 step of plane diffraction
bool MGL_EXPORT mgl_difr_grid(dual *a,int n,dual q,int Border,dual *b,dual *d,int kk);
//-----------------------------------------------------------------------------
extern "C" {
#endif
/// Set seed for random numbers
void MGL_EXPORT mgl_srnd(long seed);
/// Get random number
double MGL_EXPORT mgl_rnd();
/// Get integer power of x
double MGL_EXPORT mgl_ipow(double x,int n);

/// Get random number with Gaussian distribution
double MGL_EXPORT mgl_gauss_rnd();
/// Fill frequencies for FFT
void MGL_EXPORT mgl_fft_freq(double *freq,long nn);

/// Remove double spaces from the string
void MGL_EXPORT mgl_strcls(char *str);
/// Get position of substring or return -1 if not found
int MGL_EXPORT mgl_strpos(const char *str,char *fnd);
/// Get position of symbol or return -1 if not found
int MGL_EXPORT mgl_chrpos(const char *str,char fnd);

/// Get uncommented string from file (NOTE: it is not thread safe!!!)
MGL_EXPORT char *mgl_fgetstr(FILE *fp);
/// Get parameters from uncommented strings of file (NOTE: it is not thread safe!!!)
void MGL_EXPORT mgl_fgetpar(FILE *fp, const char *str, ...);
/// Check if symbol denote true
int MGL_EXPORT mgl_istrue(char ch);
/// Print test message
void MGL_EXPORT mgl_test(const char *str, ...);
/// Print info message
void MGL_EXPORT mgl_info(const char *str, ...);
/// Locate next data block (block started by -----)
MGL_EXPORT FILE *mgl_next_data(const char *fname,int p);

#ifdef __cplusplus
}
#endif
#endif
