/*
author: Andreas Ritter
created: 20/06/2012
last edited: 20/06/2012
compiler: g++ 4.4
basis machine: Ubuntu Linux 10.04
*/

///TODO: parameter I_MininumApertureLength

#include "MFindAndTraceSlitAps.h"

using namespace std;

int main(int argc, char *argv[])
{
  cout << "MFindAndTraceSlitAps::main: argc = " << argc << endl;
  if (argc < 12){
    cout << "MFindAndTraceAps::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: findandtraceslitaps <char[] FitsFileName_In> <int I_NApertures_In> <double D_SignalThreshold_In> <int I_NSum_In> <int I_StepSize_In> <double D_SigmaReject_In> <double D_FWHM_In> <int I_PolyFitOrder_In> <double XLow_In> <double XHigh_In> <char[] DataBaseFileName_Out>" << endl;
    cout << "Parameter 1: char[] FitsFileName_In," << endl;
    cout << "Parameter 2: int I_NApertures_In - number of apertures to find and trace," << endl;
    cout << "Parameter 3: double D_SignalThreshold_In - All pixel values below this limit will be set to zero," << endl;
    cout << "Parameter 4: int I_NSum_In - number of CCD rows to average and remove CCD defects / cosmic ray hits," << endl;
    cout << "Parameter 5: int I_StepSize_In - step size for tracing the aperture," << endl;
    cout << "Parameter 6: double D_SigmaReject_In - sigma rejection threshold for rejecting CCD defects and cosmic ray hits," << endl;
    cout << "Parameter 7: double D_FWHM_In - FWHM of the assumed Gaussian spatial profile," << endl;
    cout << "Parameter 8: int PolyFitOrder_In - Polynomial fitting order for the trace functions," << endl;
    cout << "Parameter 9: double XLow_In - IRAF database parameter - object width left of center," << endl;
    cout << "Parameter 10: double XHigh_In - IRAF database parameter - object width right of center," << endl;
    cout << "Parameter 11: char[] DataBaseFileName_Out - name of database file (database/ap...)" << endl;
    exit(EXIT_FAILURE);
  }

  CString CS(" ");
  CString CS_comp(" ");
  CString *P_CS = new CString(" ");
  CString CS_FitsFileName_MinusScatter_Out(" ");
  CString CS_FitsFileName_Out(" ");
  CString CS_FitsFileName_CentersMarked_Out(" ");

  CString CS_FitsFileName_In((char*)argv[1]);
  int I_NApertures_In = (int)(atoi((char*)argv[2]));
  double D_Threshold_In = (double)(atof((char*)argv[3]));
  int I_NSum_In = (int)(atoi((char*)argv[4]));
  int I_Step_In = (int)(atoi((char*)argv[5]));
  double D_SigmaReject_In = (double)(atof((char*)argv[6]));
  double D_FWHM_In = (double)(atof((char*)argv[7]));
  int I_PolyFitOrder_In = (int)(atoi((char*)argv[8]));
  double D_XLow_In = (double)(atof((char*)argv[9]));
  double D_XHigh_In = (double)(atof((char*)argv[10]));
  CString CS_DBOut((char*)argv[11]);
  
  CFits CF_Image;
  if (!CF_Image.SetFileName(CS_FitsFileName_In)){
    cout << "MFindAndTraceSlitAps::main: ERROR: SetFileName(" << CS_FitsFileName_In << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  if (!CF_Image.ReadArray()){
    cout << "MFindAndTraceSlitAps::main: ERROR: ReadArray returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  if (!CF_Image.FindAndTraceApertures(I_NApertures_In,
                                      D_Threshold_In,
                                      I_NSum_In,
                                      I_Step_In,
                                      D_SigmaReject_In,
                                      D_FWHM_In,
                                      I_PolyFitOrder_In)){
    cout << "MFindAndTraceSlitAps::main: ERROR: FindAndTraceApertures returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<double, 1> D_A1_Temp(I_NApertures_In);
  D_A1_Temp = D_XHigh_In;
  if (!CF_Image.Set_XHigh(D_A1_Temp)){
    cout << "MFindAndTraceSlitAps::main: ERROR: Set_XHigh returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  if (!CF_Image.Set_XMax(D_A1_Temp)){
    cout << "MFindAndTraceSlitAps::main: ERROR: Set_XMax returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  D_A1_Temp = D_XLow_In;
  if (!CF_Image.Set_XLow(D_A1_Temp)){
    cout << "MFindAndTraceSlitAps::main: ERROR: Set_XLow returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  if (!CF_Image.Set_XMin(D_A1_Temp)){
    cout << "MFindAndTraceSlitAps::main: ERROR: Set_XMin returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  
  if (!CF_Image.SetDatabaseFileName(CS_DBOut)){
    cout << "MFindAndTraceSlitAps::main: ERROR: SetDatabaseFileName(" << CS_DBOut << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  CString *P_CS_DB_Path = CS_DBOut.SubString(0, CS_DBOut.LastStrPos(CString("/"))-1);
  cout << "MFindAndTraceAps::main: *P_CS_DB_Path = " << *P_CS_DB_Path << endl;
  if (!CS_DBOut.MkDir(*P_CS_DB_Path)){
    cout << "MFindAndTraceAps::main: ERROR: MkDir(" << *P_CS_DB_Path << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  delete(P_CS_DB_Path);
  if (!CF_Image.WriteDatabaseEntry()){
    cout << "MFindAndTraceSlitAps::main: ERROR: WriteDatabaseEntry returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  
  return EXIT_SUCCESS;
}
