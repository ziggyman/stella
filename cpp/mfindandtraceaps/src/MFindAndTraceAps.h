/*
author: Andreas Ritter
created: 04/12/2007
last edited: 05/05/2007
compiler: g++ 4.0
basis machine: Ubuntu Linux 6.06
*/

#ifndef __MFINDANDTRACEAPS_H__
#define __MFINDANDTRACEAPS_H__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <iostream>
#include <cstdlib>
#include <time.h>

#include "../../cfits/src/CAny.h"
#include "../../cfits/src/CString.h"
#include "../../cfits/src/CFits.h"

using namespace std;

int main(int argc, char *argv[]);
/// USAGE: findandtraceaps(
/// Parameter 1: char[] FitsFileName_In
/// Parameter 2: int CentralSize_X_In to fit reference scattered light (Set to any number if scattered-light subtraction is not desired)
/// Parameter 3: int CentralSize_Y_In to fit reference scattered light (Set to any number if scattered-light subtraction is not desired)
/// Parameter 4: double SaturationLevel_In
/// Parameter 5: double SignalThreshold_In - pixel values below this value will be set to zero
/// Parameter 6: double ApertureFWHM_In - FWHM of the assumed Gaussian spatial profile
/// Parameter 7: int NTermsGaussFit_In (3-6) - 3: fit mean, sigma, center; 4: 3+constant background; 5: 4 plus background slope
/// Parameter 8: int PolyFitOrder_In - Polynomial fitting order for the trace functions
/// Parameter 9: int NLost_In - number of consecutive times the profile is lost before breaking up the trace
/// Parameter 10: double XLow_In - IRAF database parameter - object width left of center
/// Parameter 11: double XMin_In - IRAF database parameter - background width left of center
/// Parameter 12: double XHigh_In - IRAF database parameter - object width right of center
/// Parameter 13: double XMax_In - IRAF database parameter - background width right of center
/// Parameter 14: int MinLength_In - minimum length of a trace to count as aperture
/// Parameter 15: int MaxLength_In - maximum length of a trace before breaking up the trace
/// Parameter 16: int ExtendAps_Up - number of pixels to extend a trace upwards - set to 0 for no extension
/// Parameter 17: int ApertureLength_Down - aperture length downwards after applying ExtendAps_Up - set to 0 for no extension
/// Parameter 18: char[] DataBaseFileName_Out - name of database file (database/ap...)
/// Parameter 19: [FitsFileName_RefScatter_In=(char[] ReferenceScatteredLightImage_In)]
/// Parameter 20: [FitsFileName_MinusScatter_Out=(char[] FitsFileName_MinusScatter_Out)]
/// Parameter 21: [FitsFileName_Out=(char[] FitsFileName_Out) - Quality control file with all found apertures set to zero]
/// Parameter 22: [FitsFileName_CentersMarked_Out=(char[] FitsFileName_CentersMarked_Out) - Quality control file with all traces set to zero]
#endif
