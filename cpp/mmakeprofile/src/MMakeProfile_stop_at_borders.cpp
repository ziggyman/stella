/*
author: Andreas Ritter
created: 01/12/2007
last edited: 01/12/2007
compiler: g++ 4.0
basis machine: Ubuntu Linux 6.06
*/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <iostream>
#include <cstdlib>

#include "../../cfits/src/CFits.h"
#include "../../cfits/src/CString.h"

using namespace std;

int main(int argc, char *argv[])
{
  cout << "MMakeProfile::main: argc = " << argc << endl;
  if (argc < 6)
  {
    cout << "MMakeProfile::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: makeprofile(char[] FitsFileName_In, char[] DatabaseFileName_In, char[] FitsFileName_Out, double Gain, double ReadOutNoise)" << endl;
    exit(EXIT_FAILURE);
  }
  char *P_CharArr_In = (char*)argv[1];
  char *P_CharArr_DB = (char*)argv[2];
  char *P_CharArr_Out = (char*)argv[3];
  double D_Gain = (double)(atof((char*)argv[4]));
  cout << "MMakeProfile::main: D_Gain set to " << D_Gain << endl;
  double D_ReadOutNoise = (double)(atof((char*)argv[5]));
  cout << "MMakeProfile::main: D_ReadOutNoise set to " << D_ReadOutNoise << endl;
  
  CString CS_FitsFileName_In;
  CS_FitsFileName_In.Set(P_CharArr_In);
  CString CS_FitsFileName_Out;
  CS_FitsFileName_Out.Set(P_CharArr_Out);
  CString CS_DatabaseFileName_In;
  CS_DatabaseFileName_In.Set(P_CharArr_DB);

  CFits F_Image;
  cout << "MMakeProfile::main: Starting F_Image.SetFileName(" << CS_FitsFileName_In.Get() << ")" << endl;
  if (!F_Image.SetFileName(CS_FitsFileName_In))
  {
    cout << "MMakeProfile::main: ERROR: F_Image.SetFileName(" << CS_FitsFileName_In.Get() << ") returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Set ReadOutNoise
  cout << "MMakeProfile::main: Starting F_Image.Set_ReadOutNoise(" << D_ReadOutNoise << ")" << endl;
  if (!F_Image.Set_ReadOutNoise( D_ReadOutNoise ))
  {
    cout << "MMakeProfile::main: ERROR: F_Image.Set_ReadOutNoise(" << D_ReadOutNoise << ") returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Set Gain
  cout << "MMakeProfile::main: Starting F_Image.Set_Gain(" << D_Gain << ")" << endl;
  if (!F_Image.Set_Gain( D_Gain ))
  {
    cout << "MMakeProfile::main: ERROR: F_Image.Set_Gain(" << D_Gain << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  ///
  cout << "MMakeProfile::main: Starting F_Image.Set_OverSample()" << endl;
  if (!F_Image.Set_OverSample( 10 ))
  {
    cout << "MMakeProfile::main: ERROR: F_Image.Set_OverSample() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Read FitsFile
  cout << "MMakeProfile::main: Starting F_Image.ReadArray()" << endl;
  if (!F_Image.ReadArray())
  {
    cout << "MMakeProfile::main: ERROR: F_Image.ReadArray() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Set DatabaseFileName_In
  cout << "MMakeProfile::main: Starting F_Image.SetDatabaseFileName(" << CS_DatabaseFileName_In << ")" << endl;
  if (!F_Image.SetDatabaseFileName(CS_DatabaseFileName_In))
  {
    cout << "MMakeProfile::main: ERROR: F_Image.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Read DatabaseFileName_In
  cout << "MMakeProfile::main: Starting F_Image.ReadDatabaseEntry()" << endl;
  if (!F_Image.ReadDatabaseEntry())
  {
    cout << "MMakeProfile::main: ERROR: F_Image.ReadDatabaseEntry() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Calculate Trace Functions
  cout << "MMakeProfile::main: Starting F_Image.CalcTraceFunctions()" << endl;
  if (!F_Image.CalcTraceFunctions())
  {
    cout << "MMakeProfile::main: ERROR: F_Image.CalcTraceFunctions() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Calculate Profile Image
  cout << "MMakeProfile::main: Starting F_Image.MkProfIm()" << endl;
  if (!F_Image.MkProfIm())
  {
    cout << "MMakeProfile::main: ERROR: F_Image.MkProfIm() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  /// Set CS_FitsFileName_Out
  cout << "MMakeProfile::main: Starting F_Image.SetFileName(" << CS_FitsFileName_Out << ")" << endl;
  if (!F_Image.SetFileName(CS_FitsFileName_Out))
  {
    cout << "MMakeProfile::main: ERROR: F_Image.SetFileName(" << CS_FitsFileName_Out << ") returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }

  F_Image.GetPixArray() = F_Image.GetProfArray();
  
  /// Write Profile Image
  cout << "MMakeProfile::main: Starting F_Image.WriteArray()" << endl;
  if (!F_Image.WriteArray())
  {
    cout << "MMakeProfile::main: ERROR: F_Image.WriteArray() returned FALSE!" << endl;
    exit(EXIT_FAILURE);
  }
  
  return EXIT_SUCCESS;
}
