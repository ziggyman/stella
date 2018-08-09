/*
author: Andreas Ritter
created: 03/20/2007
last edited: 03/20/2007
compiler: g++ 4.0
basis machine: Ubuntu Linux 6.06
*

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <iostream>
#include <cstdlib>

#include "CFits.h"
#include "CString.h"

using namespace std;

int main(int argc, char *argv[])
    /// argv[0]: string: input_fits_file_name: in, string: input_database_file_name: in, string: output_fits_file_name: out, double: Gain: in, double: ReadOutNoise: in
{
  cout << "MMakeNormFlat::main: argc = " << argc << endl;
  if (argc < 6)
  {
    cout << "MMakeNormFlat::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: makenormflatprof(char[] FitsFileName_In, char[] DatabaseFileName_In, char[] FitsFileName_Out, double Gain, double ReadOutNoise)" << endl;
    exit(EXIT_FAILURE);
  }
  char *P_CharArr_In = (char*)argv[1];
  char *P_CharArr_DB = (char*)argv[2];
  char *P_CharArr_Out = (char*)argv[3];
  double D_Gain = (double)(atof((char*)argv[4]));
  cout << "MMakeNormFlat::main: D_Gain set to " << D_Gain << endl;
  double D_ReadOutNoise = (double)(atof((char*)argv[5]));
  cout << "MMakeNormFlat::main: D_ReadOutNoise set to " << D_ReadOutNoise << endl;
  
  CString CS_FitsFileName_In;
  CS_FitsFileName_In.Set(P_CharArr_In);
  CString CS_FitsFileName_Out;
  CS_FitsFileName_Out.Set(P_CharArr_Out);
  CString CS_DatabaseFileName_In;
  CS_DatabaseFileName_In.Set(P_CharArr_DB);

  CFits F_Image;
  if (!F_Image.SetFileName(CS_FitsFileName_In))
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.SetFileName(" << CS_FitsFileName_In.Get() << ") returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Set ReadOutNoise
  if (!F_Image.Set_ReadOutNoise( D_ReadOutNoise ))
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.Set_ReadOutNoise(" << D_ReadOutNoise << ") returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Set Gain
  if (!F_Image.Set_Gain( D_Gain ))
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.Set_Gain(" << D_Gain << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  ///
  if (!F_Image.Set_OverSample( 10 ))
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.Set_OverSample() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Read FitsFile
  if (!F_Image.ReadArray())
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.ReadArray() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Set DatabaseFileName_In
  if (!F_Image.SetDatabaseFileName(CS_DatabaseFileName_In))
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Read DatabaseFileName_In
  if (!F_Image.ReadDatabaseEntry())
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.ReadDatabaseEntry() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Calculate Trace Functions
  if (!F_Image.CalcTraceFunctions())
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.CalcTraceFunctions() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Calculate NormFlat Image
//  Array<CString, 1> CS_A1_Args(1);
//  CS_A1_Args(0) = CString("BLZ");
//  if (!F_Image.MkProfIm(CS_A1_Args))
//  {
//    cout << "MMakeNormFlat::main: ERROR: F_Image.MkProfIm() returned FALSE!" << endl;
//    exit(EXIT_FAILURE);
//  }
  if (!F_Image.MkNormFlatProf())
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.MkNormFlat() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Set CS_FitsFileName_Out
  if (!F_Image.SetFileName(CS_FitsFileName_Out))
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.SetFileName(" << CS_FitsFileName_Out << ") returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  F_Image.GetPixArray() = F_Image.GetProfArray();
  
  /// Write NormFlat Image
  if (!F_Image.WriteArray())
  {
    cout << "MMakeNormFlat::main: ERROR: F_Image.WriteArray() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }
  
  return EXIT_SUCCESS;
}
*/
