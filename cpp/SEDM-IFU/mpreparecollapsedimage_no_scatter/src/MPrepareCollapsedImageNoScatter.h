/**
author: Andreas Ritter
created: 05/07/2013
last edited: 05/07/2013
compiler: g++ 4.8
basis machine: Arch Linux

TASK:
* estimate and subtract scattered light
* extract all spectra using simple-sum method
* wavelength-calibrated extracted spectra
* rebin to same dispersion
* collapse spectra to be read with IDL
*/

#ifndef __MPREPARECOLLAPSEDIMAGE_NO_SCATTER_H__
#define __MPREPARECOLLAPSEDIMAGE_NO_SCATTER_H__

#ifdef HAVE_CONFIG_H
  #include <config.h>
#endif

#include <iostream>
#include <cstdlib>
#include <time.h>

#include "../../../cfits/src/CAny.h"
#include "../../../cfits/src/CString.h"
#include "../../../cfits/src/CFits.h"
#include <mgl2/mgl.h>

using namespace std;

//template <class T>
//string to_string(T t, ios_base & (*f)(ios_base&));

int main(int argc, char *argv[]);
/// USAGE: identify char[] FitsFileName_Op1_In, char[] FitsFileName_Op2_In, char[] FitsFileName_Out
#endif
