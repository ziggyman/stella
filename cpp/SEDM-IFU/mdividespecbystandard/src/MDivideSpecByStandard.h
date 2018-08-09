/*
author: Andreas Ritter
created: 05/08/2012
last edited: 05/08/2012
compiler: g++ 4.4
basis machine: Arch Linux
*/

#ifndef __MDIVIDESPECBYSTANDARD_H__
#define __MDIVIDESPECBYSTANDARD_H__

#define __WITH_PLOTS__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <iostream>
#include <cstdlib>
#include <time.h>
#ifdef __WITH_PLOTS__
  #include <mgl2/mgl.h>
#endif
#include "../../../cfits/src/CAny.h"
#include "../../../cfits/src/CString.h"
#include "../../../cfits/src/CFits.h"

using namespace std;

int main(int argc, char *argv[]);
/// USAGE: identify char[] FitsFileName_Op1_In, char[] FitsFileName_Op2_In, char[] FitsFileName_Out
#endif
