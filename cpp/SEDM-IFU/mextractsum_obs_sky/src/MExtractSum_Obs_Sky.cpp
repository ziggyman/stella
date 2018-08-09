/*
author: Andreas Ritter
created: 04/12/2007
last edited: 05/05/2007
compiler: g++ 4.0
basis machine: Ubuntu Linux 6.06
*/

#include "MExtractSum_Obs_Sky.h"

using namespace std;

int main(int argc, char *argv[])
{
/**
  D_A1_X.resize(5);
  D_A1_X(0) = 0.;
  D_A1_X(1) = 1.;
  D_A1_X(2) = 2.;
  D_A1_X(3) = 3.;
  D_A1_X(4) = 4.;

  D_A1_Y.resize(5);
  D_A1_Y(0) = 1.;
  D_A1_Y(1) = 1.;
  D_A1_Y(2) = 1.;
  D_A1_Y(3) = 1.;
  D_A1_Y(4) = 1.;

  D_A1_U(0) = 1.1;
  D_A1_U(1) = 1.9;
  cout << endl << endl << "D_A1_U = " << D_A1_U << endl;
  if (!CF.InterPol(D_A1_Y, D_A1_X, D_A1_U, &D_A1_Out, true)){
    cout << "MExtractSum_Obs_Sky::main: ERROR: 2. InterPol returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  cout << "MExtractSum_Obs_Sky::main: D_A1_U = " << D_A1_U << endl;
  cout << "MExtractSum_Obs_Sky::main: D_A1_Out = " << D_A1_Out << endl;

  D_A1_U(0) = -1.1;
  D_A1_U(1) = -0.2;
  cout << endl << endl << "D_A1_U = " << D_A1_U << endl;
  if (!CF.InterPol(D_A1_Y, D_A1_X, D_A1_U, &D_A1_Out, true)){
    cout << "MExtractSum_Obs_Sky::main: ERROR: 3. InterPol returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  cout << "MExtractSum_Obs_Sky::main: D_A1_U = " << D_A1_U << endl;
  cout << "MExtractSum_Obs_Sky::main: D_A1_Obs = " << D_A1_Out << endl;

  D_A1_U(0) = -0.5;
  D_A1_U(1) = 1.9;
  cout << endl << endl << "D_A1_U = " << D_A1_U << endl;
  if (!CF.InterPol(D_A1_Y, D_A1_X, D_A1_U, &D_A1_Out, true)){
    cout << "MExtractSum_Obs_Sky::main: ERROR: 4. InterPol returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  cout << "MExtractSum_Obs_Sky::main: D_A1_U = " << D_A1_U << endl;
  cout << "MExtractSum_Obs_Sky::main: D_A1_Out = " << D_A1_Out << endl;

  D_A1_U(0) = 3.1;
  D_A1_U(1) = 4.9;
  cout << endl << endl << "D_A1_U = " << D_A1_U << endl;
  if (!CF.InterPol(D_A1_Y, D_A1_X, D_A1_U, &D_A1_Out, true)){
    cout << "MExtractSum_Obs_Sky::main: ERROR: 5. InterPol returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  cout << "MExtractSum_Obs_Sky::main: D_A1_U = " << D_A1_U << endl;
  cout << "MExtractSum_Obs_Sky::main: D_A1_Out = " << D_A1_Out << endl;

  D_A1_U(0) = 4.1;
  D_A1_U(1) = 4.9;
  cout << endl << endl << "D_A1_U = " << D_A1_U << endl;
  if (!CF.InterPol(D_A1_Y, D_A1_X, D_A1_U, &D_A1_Out, true)){
    cout << "MExtractSum_Obs_Sky::main: ERROR: 6. InterPol returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  cout << "MExtractSum_Obs_Sky::main: D_A1_U = " << D_A1_U << endl;
  cout << "MExtractSum_Obs_Sky::main: D_A1_Out = " << D_A1_Out << endl;

//  exit(EXIT_FAILURE);
**/
  cout << "MExtractSum_Obs_Sky::main: argc = " << argc << endl;
  if (argc < 6)
  {
    cout << "MExtractSum_Obs_Sky::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: sedm_extractsum_obs_sky <char[] @FitsFileList_In> <char[] DatabaseFileName_In> <char[] CS_A1_TextFiles_Coeffs_In> <double Gain> <double ReadOutNoise> <double D_MaxRMS_In> <double D_WLen_Start> <double D_WLen_End> <double D_DWLen> <double TelescopeSurface> <char[] @ExposureTimes_In> [ERR_IN=char[](@)] [ERR_OUT_EC=char[](@)] [MASK_OUT=char[](@)] [AREA=[int(xmin),int(xmax),int(ymin),int(ymax)]] [APERTURES=char[](@)]" << endl;//"[, ERR_FROM_PROFILE_OUT=char[]])" << endl;
    cout << "FitsFileList_In: <image to extract> <int XCenter> <int YCenter> <int Radius_Obs> <int Radius_Sky>" << endl;
    cout << "DatabaseFileName_In: aperture-definition file to use for extraction" << endl;
    cout << "CS_A1_TextFiles_Coeffs_In: filename containing list of coefficient files for dispersion correction" << endl;
    cout << "Gain: CCD gain" << endl;
    cout << "ReadOutNoise: CCD readout noise" << endl;
    cout << "D_MaxRMS_In: Maximum RMS for dispersion correction" << endl;
    cout << "D_WLen_Start: Starting wavelength for re-binning" << endl;
    cout << "D_WLen_End: Ending wavelength for re-binning" << endl;
    cout << "D_DWLen: wavelength step for re-binning" << endl;
    cout << "TelescopeSurface: effective telescope surface for flux calculation" << endl;
    cout << "ExposureTimes_In: data file containing the exposure times for each image in @FitsFileName_In" << endl;
    cout << "ERR_IN: input image containing the uncertainties in the pixel values of FitsFileName_In" << endl;
    cout << "ERR_OUT_EC: output file containing the uncertainties in the extracted spectra's pixel values" << endl;
    cout << "MASK_OUT: output mask with detected cosmic-ray hits set to 0, good pixels set to 1" << endl;
    cout << "AREA: Area from which to extract spectra if center of aperture is in specified area" << endl;
    cout << "APERTURES: input filename containing a list of apertures to extract" << endl;
//    cout << "ERR_FROM_PROFILE_OUT: uncertainties of extracted spectra from EC_FROM_PROFILE_OUT (EC_FROM_PROFILE_OUT must be set as well)" << endl;
    exit(EXIT_FAILURE);
  }

/*  double D_D1 = 34.;
  double D_D2 = 34.;
  cout << "D_D1 - D_D2 = " << D_D1 - D_D2 << endl;
  if (D_D1 == D_D2)
    cout << "D_D1 == D_D2" << endl;
  cout << "abs(D_D1 - D_D2) = " << abs(D_D1 - D_D2) << endl;
  cout << "fabs(D_D1 - D_D2) = " << fabs(D_D1 - D_D2) << endl;
  exit(EXIT_FAILURE);
*/
  Array<int, 1> I_A1_Area(4);
  Array<CString, 1> CS_A1_Args(8);
  CS_A1_Args = CString("\0");
  void **PP_Args;
  PP_Args = (void**)malloc(sizeof(void*) * 8);
  CString CS(" ");
  CString CS_comp(" ");
  CString *P_CS = new CString(" ");
  CString *P_CS_ErrIn = new CString(" ");
  CString *P_CS_ErrOutEc = new CString(" ");
  CString *P_CS_MaskOut = new CString(" ");
  CString *P_CS_ApertureListIn = new CString(" ");

  int I_SwathWidth = 0;
  char *P_CharArr_In = (char*)argv[1];
  char *P_CharArr_DB = (char*)argv[2];
  char *P_CharArr_Coeffs = (char*)argv[3];
//  char *P_CharArr_Out = (char*)argv[4];
  double D_Gain = (double)(atof((char*)argv[4]));
  cout << "MExtractSum_Obs_Sky::main: D_Gain set to " << D_Gain << endl;
  double D_ReadOutNoise = (double)(atof((char*)argv[5]));
  cout << "MExtractSum_Obs_Sky::main: D_ReadOutNoise set to " << D_ReadOutNoise << endl;
  double D_MaxRMS_In = (double)(atof((char*)argv[6]));
  cout << "MExtractSum_Obs_Sky::main: D_MaxRMS_In set to " << D_MaxRMS_In << endl;
  double D_WLen_Start = (double)(atof((char*)argv[7]));
  cout << "MExtractSum_Obs_Sky::main: D_WLen_Start set to " << D_WLen_Start << endl;
  double D_WLen_End = (double)(atof((char*)argv[8]));
  cout << "MExtractSum_Obs_Sky::main: D_WLen_End set to " << D_WLen_End << endl;
  double D_DWLen = (double)(atof((char*)argv[9]));
  cout << "MExtractSum_Obs_Sky::main: D_DWLen set to " << D_DWLen << endl;
  double D_ATel = (double)(atof((char*)argv[10]));
  cout << "MExtractSum_Obs_Sky::main: D_ATel set to " << D_ATel << endl;
  char *P_CharArr_ExpTimes_In = (char*)argv[11];
  Array<int, 1> *P_I_A1_Apertures = new Array<int, 1>(1);
  (*P_I_A1_Apertures) = 0;
  bool B_AperturesSet = false;
  Array<CString, 1> CS_A1_TextFiles_Coeffs_In(1);

  /// read optional parameters
  for (int i = 12; i <= argc; i++){
    CS.Set((char*)argv[i]);
    cout << "MExtractSum_Obs_Sky: Reading Parameter " << CS << endl;
    /// AREA
    CS_comp.Set("AREA");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MExtractSum_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        CString cs_temp;
        cs_temp.Set(",");
        int i_pos_a = CS_comp.GetLength()+2;
        int i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        cout << "MExtractSum_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MExtractSum_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(0) = (int)(atoi(P_CS->Get()));
        cout << "MExtractSum_Obs_Sky: I_A1_Area(0) set to " << I_A1_Area(0) << endl;

        i_pos_a = i_pos_b+1;
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        cout << "MExtractSum_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MExtractSum_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(1) = (int)(atoi(P_CS->Get()));
        cout << "MExtractSum_Obs_Sky: I_A1_Area(1) set to " << I_A1_Area(1) << endl;

        i_pos_a = i_pos_b+1;
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        cout << "MExtractSum_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MExtractSum_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(2) = (int)(atoi(P_CS->Get()));
        cout << "MExtractSum_Obs_Sky: I_A1_Area(2) set to " << I_A1_Area(2) << endl;

        i_pos_a = i_pos_b+1;
        cs_temp.Set("]");
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        if (i_pos_b < 0){
          cs_temp.Set(")");
          i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        }
        cout << "MExtractSum_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MExtractSum_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(3) = (int)(atoi(P_CS->Get()));
        cout << "MExtractSum_Obs_Sky: I_A1_Area(3) set to " << I_A1_Area(3) << endl;

        CS_A1_Args(2) = CString("AREA");
        PP_Args[2] = &I_A1_Area;
        cout << "MExtractSum_Obs_Sky::main: I_A1_Area set to " << I_A1_Area << endl;
      }
    }

    /// 2D
    CS_comp.Set("ERR_IN");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MExtractSum_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_ErrIn);
        P_CS_ErrIn = CS.SubString(CS_comp.GetLength()+1);
        cout << "MExtractSum_Obs_Sky::main: ERR_IN set to " << *P_CS_ErrIn << endl;
      }
    }

    /// 1D
    CS_comp.Set("ERR_OUT_EC");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MExtractSum_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_ErrOutEc);
        P_CS_ErrOutEc = CS.SubString(CS_comp.GetLength()+1);
        cout << "MExtractSum_Obs_Sky::main: ERR_OUT_EC set to " << *P_CS_ErrOutEc << endl;
      }
    }
    CS_comp.Set("APERTURES");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MExtractSum_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_ApertureListIn);
        P_CS_ApertureListIn = CS.SubString(CS_comp.GetLength()+1);
        cout << "MExtractSum_Obs_Sky::main: P_CS_ApertureListIn set to " << *P_CS_ApertureListIn << endl;
	B_AperturesSet = true;
	Array<CString, 1> CS_A1_AperturesToExtract(1);
	CS_A1_AperturesToExtract = CString(" ");
	if (!CS.ReadFileLinesToStrArr(*P_CS_ApertureListIn, CS_A1_AperturesToExtract)){
	  cout << "MExtractSum_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(" << *P_CS_ApertureListIn << ") returned FALSE" << endl;
	  exit(EXIT_FAILURE);
	}
	P_I_A1_Apertures->resize(CS_A1_AperturesToExtract.size());
	for (int i_ap=0; i_ap < CS_A1_AperturesToExtract.size(); i_ap++)
	  (*P_I_A1_Apertures)(i_ap) = CS_A1_AperturesToExtract(i_ap).AToI();
        CS_A1_Args(7) = CString("APERTURES");
        PP_Args[7] = P_I_A1_Apertures;
      }
    }
  }

//  return false;
  time_t seconds;
//  if (argc == 8)
//  {
//    I_SwathWidth = (int)(atoi((char*)argv[7]));
//    cout << "MExtractSum_Obs_Sky::main: I_SwathWidth set to " << I_SwathWidth << endl;

  bool B_Lists = true;
  CString CS_FitsFileName_In;
  CS_FitsFileName_In.Set(P_CharArr_In);
  Array<CString, 2> CS_A2_FitsFileNames_In(2,2);
  Array<CString, 1> CS_A1_FitsFileNames_In(1);
  CS_A1_FitsFileNames_In(0) = CS_FitsFileName_In;
  if (!CS_FitsFileName_In.IsList()){
    cout << "MExtractSum_Obs_Sky::main: ERROR: " << CS_FitsFileName_In << " is not a list" << endl;
    exit(EXIT_FAILURE);
  }
  CString *P_CS_Temp = CS_FitsFileName_In.SubString(1);
  if (!CS_FitsFileName_In.ReadFileToStrArr(*P_CS_Temp, CS_A2_FitsFileNames_In, CString(" "))){
    cout << "MExtractSum_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(" << CS_FitsFileName_In << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  delete(P_CS_Temp);
  CS_A1_FitsFileNames_In.resize(CS_A2_FitsFileNames_In.rows());
  CS_A1_FitsFileNames_In = CS_A2_FitsFileNames_In(Range::all(), 0);

  Array<CString, 1> CS_A1_FitsFileNamesPlusDir(CS_A1_FitsFileNames_In.size());
  if (!CS_FitsFileName_In.AddNameAsDir(CS_A1_FitsFileNames_In, CS_A1_FitsFileNamesPlusDir)){
    cout << "MExtractSum_Obs_Sky::main: ERROR: AddFirstPartAsDir(CS_A1_FitsFileNames_In, CS_A1_FitsFileNamesPlusDir) returned FALSE" << endl;
    return false;
  }
  cout << "MExtractSum_Obs_Sky::main: CS_A1_FitsFileNamesPlusDir = " << CS_A1_FitsFileNamesPlusDir << endl;
//  exit(EXIT_FAILURE);

  CString CS_TextFilesCoeffs_In;
  CS_TextFilesCoeffs_In.Set(P_CharArr_Coeffs);
  if (CS_TextFilesCoeffs_In.IsList()){
    P_CS_Temp = CS_TextFilesCoeffs_In.SubString(1);
    CS_TextFilesCoeffs_In.Set(*P_CS_Temp);
    delete(P_CS_Temp);
  }

  if (!CS_TextFilesCoeffs_In.ReadFileLinesToStrArr(CS_TextFilesCoeffs_In, CS_A1_TextFiles_Coeffs_In)){
    cout << "MExtractSum_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(" << CS_TextFilesCoeffs_In << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }

  CString CS_FileName_ExpTimes_In(P_CharArr_ExpTimes_In);
  CString *P_CS_ExpTimes = CS_FileName_ExpTimes_In.SubString(1);
  Array<double, 2> D_A2_ExpTimes(CS_A1_FitsFileNames_In.size(), 1);
  if (!CS.ReadFileToDblArr(*P_CS_ExpTimes, D_A2_ExpTimes, CString(" "))){
    cout << "MExtractSum_Obs_Sky::main: ERROR: ReadFileToDblArr(" << CS_FileName_ExpTimes_In << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  delete(P_CS_ExpTimes);
  Array<double, 1> D_A1_ExpTimes(CS_A1_FitsFileNames_In.size());
  D_A1_ExpTimes = D_A2_ExpTimes(Range::all(), 0);
  cout << "MExtractSum_Obs_Sky::main: D_A1_ExpTimes set to " << D_A1_ExpTimes << endl;
//  exit(EXIT_FAILURE);

  CString CS_FitsFileNameEcDR_Out;
  CString CS_FitsFileNameErrEcDR_Out;

  CString CS_DatabaseFileName_In;
  CS_DatabaseFileName_In.Set(P_CharArr_DB);

  Array<CString, 1> CS_A1_ErrIn(CS_A1_FitsFileNames_In.size());
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_err.fits"), CS_A1_ErrIn)){
    cout << "MExtractSum_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _err.fits, CS_A1_ErrIn) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<CString, 1> CS_A1_ErrOutEc(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_errEc.fits"), CS_A1_ErrOutEc)){
    cout << "MExtractSum_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _errEc.fits, CS_A1_ErrOutEc) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<CString, 1> CS_A1_MaskOut(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_MaskOut.fits"), CS_A1_MaskOut)){
    cout << "MExtractSum_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _MaskOut.fits, CS_A1_MaskOut) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  CFits F_Image;
  CFits F_OutImage;
  CFits F_ErrImage;
  Array<int, 1> I_A1_Apertures_Object(1);
  Array<int, 1> I_A1_Apertures_Sky(1);
  Array<int, 1> I_A1_AperturesToExtract(1);
  CString *P_CS_ImageName_ApsRoot;
  CString CS_ImageName_ApsRoot(" ");
  Array<CString, 1> CS_A1_ApertureFitsFileNames(1);
  Array<CString, 1> CS_A1_ApertureFitsFileNamesErr(1);
  Array<CString, 1> CS_A1_TextFiles_EcD_Out(1);
  Array<CString, 1> CS_A1_TextFiles_EcDFlux_Out(1);
  Array<CString, 1> CS_A1_TextFiles_EcDR_Out(1);
  Array<CString, 1> CS_A1_TextFiles_Err_EcD_Out(1);
  Array<CString, 1> CS_A1_TextFiles_Err_EcDR_Out(1);
  for (int i_file = 0; i_file < CS_A1_FitsFileNames_In.size(); i_file++){
    cout << "MExtractSum_Obs_Sky::main: Starting F_Image.SetFileName(" << CS_FitsFileName_In.Get() << ")" << endl;
    if (!F_Image.SetFileName(CS_A1_FitsFileNames_In(i_file)))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.SetFileName(" << CS_FitsFileName_In.Get() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Set ReadOutNoise
    cout << "MExtractSum_Obs_Sky::main: Starting F_Image.Set_ReadOutNoise(" << D_ReadOutNoise << ")" << endl;
    if (!F_Image.Set_ReadOutNoise( D_ReadOutNoise ))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.Set_ReadOutNoise(" << D_ReadOutNoise << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Set Gain
    cout << "MExtractSum_Obs_Sky::main: Starting F_Image.Set_Gain(" << D_Gain << ")" << endl;
    if (!F_Image.Set_Gain( D_Gain ))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.Set_Gain(" << D_Gain << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    /// Read FitsFile
    cout << "MExtractSum_Obs_Sky::main: Starting F_Image.ReadArray()" << endl;
    if (!F_Image.ReadArray())
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.ReadArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    P_CS_ImageName_ApsRoot = CS_A1_FitsFileNamesPlusDir(i_file).SubString(0,CS_A1_FitsFileNamesPlusDir(i_file).StrPos(CString("/")));
    if (!P_CS_ImageName_ApsRoot->MkDir(*P_CS_ImageName_ApsRoot)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: MkDir(" << *P_CS_ImageName_ApsRoot << ") returned FALSE" << endl;
      return false;
    }
    else{
      cout << "MExtractSum_Obs_Sky::main: MkDir(" << *P_CS_ImageName_ApsRoot << ") returned TRUE" << endl;
    }
    CString *P_CS_FileName = CS_A1_FitsFileNames_In(i_file).SubString(0,CS_A1_FitsFileNames_In(i_file).LastStrPos(CString("."))-1);
    P_CS_ImageName_ApsRoot->Add(*P_CS_FileName);
    delete(P_CS_FileName);
    CS_ImageName_ApsRoot.Set(*P_CS_ImageName_ApsRoot);
    delete(P_CS_ImageName_ApsRoot);

//    exit(EXIT_FAILURE);

    /// Calculate Uncertainties
    F_OutImage.SetFileName(CS_A1_FitsFileNames_In(i_file));
    F_OutImage.ReadArray();
    F_OutImage.GetPixArray() = sqrt(fabs(F_Image.GetPixArray()) / D_Gain + pow2(D_ReadOutNoise));
    CString CS_ErrImage(" ");
    CS_ErrImage.Set(CS_ImageName_ApsRoot);
    CS_ErrImage.Add(CString("_err.fits"));
    F_OutImage.SetFileName(CS_ErrImage);
    F_OutImage.WriteArray();
    F_Image.SetErrFileName(CS_ErrImage);
    F_Image.ReadErrArray();
    CS_ImageName_ApsRoot.Add(CString("EcSum"));
    cout << "MExtractSum_Obs_Sky::main: CS_ImageName_ApsRoot = <" << CS_ImageName_ApsRoot << ">" << endl;
//    exit(EXIT_FAILURE);
//    delete(P_CS_ImageName_ApsRoot);

    F_Image.GetPixArray() = F_Image.GetPixArray() / F_Image.Get_Gain();

    /// Set DatabaseFileName_In
    cout << "MExtractSum_Obs_Sky::main: Starting F_Image.SetDatabaseFileName(" << CS_DatabaseFileName_In << ")" << endl;
    if (!F_Image.SetDatabaseFileName(CS_DatabaseFileName_In))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Read DatabaseFileName_In
    cout << "MExtractSum_Obs_Sky::main: Starting F_Image.ReadDatabaseEntry()" << endl;
    if (!F_Image.ReadDatabaseEntry())
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.ReadDatabaseEntry() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Calculate Trace Functions
    cout << "MExtractSum_Obs_Sky::main: Starting F_Image.CalcTraceFunctions()" << endl;
    if (!F_Image.CalcTraceFunctions())
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.CalcTraceFunctions() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    if (!F_Image.FindApsInCircle(CS_A2_FitsFileNames_In(i_file, 1).AToI(), CS_A2_FitsFileNames_In(i_file, 2).AToI(), CS_A2_FitsFileNames_In(i_file, 3).AToI(), I_A1_Apertures_Object)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: " << CS_A1_FitsFileNames_In(i_file) << ".FindApsInCircle(" << CS_A2_FitsFileNames_In(i_file, 1) << ", " << CS_A2_FitsFileNames_In(i_file, 2) << ", " << CS_A2_FitsFileNames_In(i_file, 3) << ") returned FALSE " << endl;
      exit(EXIT_FAILURE);
    }
    CString *P_CS_ObsList = CS_A1_FitsFileNames_In(i_file).SubString(0, CS_A1_FitsFileNames_In(i_file).LastCharPos('.')-1);
    P_CS_ObsList->Add("_apsObject.list");
    cout << "MExtractSum_Obs_Sky::main: P_CS_ObsList set to <" << *P_CS_ObsList << ">" << endl;
    F_Image.WriteArrayToFile(I_A1_Apertures_Object, *P_CS_ObsList, CString("ascii"));
    delete(P_CS_ObsList);

    if (!F_Image.FindApsInRing(CS_A2_FitsFileNames_In(i_file, 1).AToI(), CS_A2_FitsFileNames_In(i_file, 2).AToI(), CS_A2_FitsFileNames_In(i_file, 3).AToI(), CS_A2_FitsFileNames_In(i_file, 4).AToI(), I_A1_Apertures_Sky)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: " << CS_A1_FitsFileNames_In(i_file) << ".FindApsInRing(" << CS_A2_FitsFileNames_In(i_file, 1) << ", " << CS_A2_FitsFileNames_In(i_file, 2) << ", " << CS_A2_FitsFileNames_In(i_file, 3) << ", " << CS_A2_FitsFileNames_In(i_file, 4) << ") returned FALSE " << endl;
      exit(EXIT_FAILURE);
    }
    CString *P_CS_SkyList = CS_A1_FitsFileNames_In(i_file).SubString(0, CS_A1_FitsFileNames_In(i_file).LastCharPos('.')-1);
    P_CS_SkyList->Add("_apsSky.list");
    cout << "MExtractSum_Obs_Sky::main: P_CS_SkyList set to <" << *P_CS_SkyList << ">" << endl;
    F_Image.WriteArrayToFile(I_A1_Apertures_Sky, *P_CS_SkyList, CString("ascii"));
    delete(P_CS_SkyList);
//    exit(EXIT_FAILURE);

//  Array<double, 1> D_A1_YLow(1);
//  D_A1_YLow(0) = 1;
//  F_Image.Set_YLow(D_A1_YLow);

//    cout << "MExtractSum_Obs_Sky::main: P_CS_ErrIn = " << *P_CS_ErrIn << ")" << endl;
//    if (P_CS_ErrIn->GetLength() > 1){
//    /// Set ErrFileName_In
//      cout << "MExtractSum_Obs_Sky::main: Starting F_Image.SetErrFileName(" << CS_A1_ErrIn(i_file) << ")" << endl;
//      if (!F_Image.SetErrFileName(CS_A1_ErrIn(i_file)))
//      {
//        cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.SetErrFileName(" << CS_A1_ErrIn(i_file) << ") returned FALSE!" << endl;
//        exit(EXIT_FAILURE);
//      }

      /// Read Error image
//      cout << "MExtractSum_Obs_Sky::main: Starting F_Image.ReadErrArray()" << endl;
//      if (!F_Image.ReadErrArray())
//      {
//        cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.ReadErrArray() returned FALSE!" << endl;
//        exit(EXIT_FAILURE);
//      }
//    }


    /// Write aperture header information
    F_Image.WriteApHead(CString("aphead_")+CS_FitsFileName_In+CString(".head"));

    if (!B_AperturesSet){
//      delete(P_I_A1_Apertures);
      I_A1_AperturesToExtract.resize(I_A1_Apertures_Object.size() + I_A1_Apertures_Sky.size());
      I_A1_AperturesToExtract(Range(0,I_A1_Apertures_Object.size()-1)) = I_A1_Apertures_Object;
      I_A1_AperturesToExtract(Range(I_A1_Apertures_Object.size(), I_A1_Apertures_Object.size() + I_A1_Apertures_Sky.size()-1)) = I_A1_Apertures_Sky;
      P_I_A1_Apertures->resize(I_A1_AperturesToExtract.size());
      (*P_I_A1_Apertures) = I_A1_AperturesToExtract;
      CS_A1_Args(7) = CString("APERTURES");
      PP_Args[7] = P_I_A1_Apertures;
    }

    /// Calculate Profile Image
    seconds = time(NULL);
    cout << "MExtractSum_Obs_Sky::main: Starting F_Image.ExtractSimpleSum(): time = " << seconds << endl;

    if (!F_Image.ExtractSimpleSum(CS_A1_Args, PP_Args))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.ExtractSimpleSum() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    seconds = time(NULL);
    cout << "MExtractSum_Obs_Sky::main: ExtractSimpleSum returned true at " << seconds << endl;

    /// Set CS_FitsFileName_In
    cout << "MExtractSum_Obs_Sky::main: Starting F_OutImage.SetFileName(" << CS_A1_FitsFileNames_In(i_file) << ")" << endl;
    if (!F_OutImage.SetFileName(CS_A1_FitsFileNames_In(i_file)))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.SetFileName(" << CS_A1_FitsFileNames_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.SetFileName(CS_A1_FitsFileNames_In(i_file)))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.SetFileName(" << CS_A1_FitsFileNames_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    ///Read FitsFile
    cout << "MExtractSum_Obs_Sky::main: Starting F_OutImage.ReadArray()" << endl;
    if (!F_OutImage.ReadArray())
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.ReadArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.ReadArray())
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.ReadArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    if (!F_OutImage.SetDatabaseFileName(CS_DatabaseFileName_In)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_OutImage.ReadDatabaseEntry()){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.ReadDatabaseEntry() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_OutImage.CalcTraceFunctions()){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.CalcTraceFunctions() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    if (!F_ErrImage.SetDatabaseFileName(CS_DatabaseFileName_In)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.ReadDatabaseEntry()){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.ReadDatabaseEntry() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.CalcTraceFunctions()){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.CalcTraceFunctions() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }


    /// Write MaskOut 2D
//    if (P_CS_MaskOut->GetLength() > 1){
      if (!F_OutImage.SetFileName(CS_A1_MaskOut(i_file)))
      {
        cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      cout << "MExtractSum_Obs_Sky::main: Starting to write MaskOut" << endl;
      Array<int, 2> I_A2_MaskArray(F_Image.GetNRows(), F_Image.GetNCols());
      I_A2_MaskArray = F_Image.GetMaskArray();
      Array<double, 2> D_A2_MaskArray(F_Image.GetNRows(), F_Image.GetNCols());
      D_A2_MaskArray = 1. * I_A2_MaskArray;
      F_OutImage.GetPixArray() = D_A2_MaskArray;
      if (!F_OutImage.WriteArray())
      {
        cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
//    }

    CString CS_FitsFileName_Out(" ");
    CS_FitsFileName_Out.Set(CS_ImageName_ApsRoot);
    CS_FitsFileName_Out.Add(CString(".fits"));

    /// Set CS_FitsFileName_Out
    cout << "MExtractSum_Obs_Sky::main: Starting F_OutImage.SetFileName(" << CS_FitsFileName_Out << ")" << endl;
    if (!F_OutImage.SetFileName(CS_FitsFileName_Out))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.SetFileName(" << CS_FitsFileName_Out << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// change size of F_OutImage to (NApertures x NRows)
    if (!F_OutImage.SetNCols(F_Image.GetNRows()))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.SetNCols(" << F_Image.GetNRows() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.SetNCols(F_Image.GetNRows()))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.SetNCols(" << F_Image.GetNRows() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

//    if (!F_OutImage.SetNRows(P_I_A1_Apertures->size()))
    if (!F_OutImage.SetNRows(F_Image.Get_NApertures()))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.SetNRows(" << F_Image.Get_NApertures() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
//    F_ErrImage.SetNRows(P_I_A1_Apertures->size());
    if (!F_ErrImage.SetNRows(F_Image.Get_NApertures()))
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.SetNRows(" << F_Image.Get_NApertures() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

//    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
//      F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetSpec()((*P_I_A1_Apertures)(i_ap), Range::all());
    F_OutImage.GetPixArray() = F_Image.GetLastExtracted();
    if (!F_OutImage.WriteArray()){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": Write spectra to individual files" << endl;
    if (!F_OutImage.WriteApertures(CS_ImageName_ApsRoot, CS_A1_ApertureFitsFileNames, I_A1_AperturesToExtract)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.WriteApertures() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    CString CS_ErrImageName_Aps_Root(" ");
    CS_ErrImageName_Aps_Root.Set(CS_ImageName_ApsRoot);
    CS_ErrImageName_Aps_Root.Add(CString("Err"));
    F_ErrImage.GetPixArray() = F_Image.GetErrorsEc();
    if (!F_ErrImage.WriteApertures(CS_ErrImageName_Aps_Root, CS_A1_ApertureFitsFileNamesErr, I_A1_AperturesToExtract)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.WriteApertures() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    CS_ErrImageName_Aps_Root.Set(CS_ImageName_ApsRoot);
    CS_ErrImageName_Aps_Root.Add(CString("Err"));
/*    F_ErrImage.GetPixArray() = F_Image.GetErrorsEcFit();
    if (!F_ErrImage.WriteApertures(CS_ErrImageName_Aps_Root, CS_A1_ApertureFitsFileNamesErr, I_A1_AperturesToExtract)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.WriteApertures() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
*/
//    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
//      F_ErrImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetErrorsEc()((*P_I_A1_Apertures)(i_ap), Range::all());
//    F_ErrImage.GetPixArray() = F_Image.GetErrorsEcFit();
//    CString CS_ErrEc(" ");
//    CS_ErrEc.Set(CS_ImageName_ApsRoot);
//    CS_ErrEc.Add(CString("Err.fits"));
    if (!F_ErrImage.SetFileName(CS_ErrImage)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.SetFileName(" << CS_ErrImage << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.WriteArray()){
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_ErrImage.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": Apply dispersion correction: creating list" << endl;
    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNames, CString(".fits"), CString("D.text"), CS_A1_TextFiles_EcD_Out)){
      cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": ERROR: 1. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNames, CString(".fits"), CString("D_Flux.text"), CS_A1_TextFiles_EcDFlux_Out)){
      cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": ERROR: 1. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    CString CS_TextFiles_EcD(" ");
    CS_TextFiles_EcD.Set(CS_ImageName_ApsRoot);
    CS_TextFiles_EcD.Add(CString("D_text.list"));

    CS_FitsFileName_In.WriteStrListToFile(CS_A1_TextFiles_EcD_Out,CS_TextFiles_EcD);

    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNamesErr, CString(".fits"), CString("D.text"), CS_A1_TextFiles_Err_EcD_Out)){
      cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": ERROR: 1. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": Apply dispersion correction: CS_A1_TextFiles_EcD_Out = " << CS_A1_TextFiles_EcD_Out << endl;
    CString CS_ErrTextFiles_EcD(" ");
    CS_ErrTextFiles_EcD.Set(CS_ErrImageName_Aps_Root);
    CS_ErrTextFiles_EcD.Add(CString("D_text.list"));

    CS_FitsFileName_In.WriteStrListToFile(CS_A1_TextFiles_Err_EcD_Out,CS_ErrTextFiles_EcD);

    cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": Apply dispersion correction: Starting DispCorList" << endl;
    if (!F_OutImage.DispCorList(CS_A1_TextFiles_Coeffs_In, CS_A1_TextFiles_EcD_Out, D_MaxRMS_In, I_A1_AperturesToExtract)){
      cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": ERROR: DispCorList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.DispCorList(CS_A1_TextFiles_Coeffs_In, CS_A1_TextFiles_Err_EcD_Out, D_MaxRMS_In, I_A1_AperturesToExtract)){
      cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": ERROR: DispCorList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
//    exit(EXIT_FAILURE);
//    if (!F_OutImage.PhotonsToFlux(CS_A1_TextFiles_EcD_Out, CS_A1_TextFiles_EcDFlux_Out, , I_A1_AperturesToExtract)){
//      cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": ERROR: DispCorList returned FALSE!" << endl;
//      exit(EXIT_FAILURE);
//    }

    cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": Rebin spectra: Creating File List" << endl;
    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNames, CString(".fits"), CString("DR.text"), CS_A1_TextFiles_EcDR_Out)){
      cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": ERROR: 2. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNamesErr, CString(".fits"), CString("DR.text"), CS_A1_TextFiles_Err_EcDR_Out)){
      cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": ERROR: 2. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": Rebin spectra: CS_A1_TextFiles_EcDR_Out = " << CS_A1_TextFiles_EcDR_Out << endl;

    CS_FitsFileNameEcDR_Out.Set(CS_ImageName_ApsRoot);
    CS_FitsFileNameEcDR_Out.Add(CString("DR.fits"));
    cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": Rebin spectra: Starting RebinTextList" << endl;
    if (!F_Image.RebinTextList(CS_A1_TextFiles_EcD_Out, CS_A1_TextFiles_EcDR_Out, CS_FitsFileNameEcDR_Out, D_WLen_Start, D_WLen_End, D_DWLen, true)){
      cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": ERROR: RebinTextList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    CS_FitsFileNameErrEcDR_Out.Set(CS_ErrImageName_Aps_Root);
    CS_FitsFileNameErrEcDR_Out.Add(CString("DR.fits"));
    cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": Rebin err spectra: Starting RebinTextList" << endl;
    if (!F_Image.RebinTextList(CS_A1_TextFiles_Err_EcD_Out, CS_A1_TextFiles_Err_EcDR_Out, CS_FitsFileNameErrEcDR_Out, D_WLen_Start, D_WLen_End, D_DWLen, true)){
      cout << "MExtractSum_Obs_Sky::main: i_file = " << i_file << ": ERROR: RebinTextList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    int I_NElements = int((D_WLen_End - D_WLen_Start) / D_DWLen);
    Array<double, 1> D_A1_Lambda(I_NElements);
    D_A1_Lambda(0) = D_WLen_Start;
    for (int i_pix=1; i_pix<I_NElements; i_pix++)
      D_A1_Lambda(i_pix) = D_A1_Lambda(i_pix-1) + D_DWLen;

    CFits CF_EcDR;
    CFits CF_ErrEcDR;
    if (!CF_EcDR.SetFileName(CS_FitsFileNameEcDR_Out)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: CF_EcDR.SetFileName(" << CS_FitsFileNameEcDR_Out << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CF_ErrEcDR.SetFileName(CS_FitsFileNameErrEcDR_Out)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: CF_ErrEcDR.SetFileName(" << CS_FitsFileNameErrEcDR_Out << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CF_EcDR.ReadArray()){
      cout << "MExtractSum_Obs_Sky::main: ERROR: " << CS_FitsFileName_In << ".ReadArray() returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CF_ErrEcDR.ReadArray()){
      cout << "MExtractSum_Obs_Sky::main: ERROR: " << CS_FitsFileName_In << ".ReadArray() returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    Array<double, 2> D_A2_Spec_Obs(I_A1_Apertures_Object.size(), CF_EcDR.GetNCols());
    Array<double, 2> D_A2_Err_Obs(I_A1_Apertures_Object.size(), CF_EcDR.GetNCols());
    for (int iaps=0; iaps<I_A1_Apertures_Object.size(); iaps++){
      D_A2_Spec_Obs(iaps, Range::all()) = CF_EcDR.GetPixArray()(iaps, Range::all());
      D_A2_Err_Obs(iaps, Range::all()) = CF_ErrEcDR.GetPixArray()(iaps, Range::all());
    }
    cout << "MExtractSum_Obs_Sky::main: D_A2_Spec_Obs = " << D_A2_Spec_Obs << endl;
    Array<double, 2> D_A2_Spec_Sky(I_A1_Apertures_Sky.size(), CF_EcDR.GetNCols());
    Array<double, 2> D_A2_Err_Sky(I_A1_Apertures_Sky.size(), CF_EcDR.GetNCols());
    int i_aps = 0;
    for (int iaps=I_A1_Apertures_Object.size(); iaps<I_A1_Apertures_Object.size()+I_A1_Apertures_Sky.size(); iaps++){
      D_A2_Spec_Sky(i_aps, Range::all()) = CF_EcDR.GetPixArray()(iaps, Range::all());
      D_A2_Err_Sky(i_aps, Range::all()) = CF_ErrEcDR.GetPixArray()(iaps, Range::all());
      i_aps++;
    }
    cout << "MExtractSum_Obs_Sky::main: D_A2_Spec_Sky = " << D_A2_Spec_Sky << endl;
    Array<double, 2> D_A1_Sky(1, D_A2_Spec_Obs.cols());
    D_A1_Sky = 0.;
    for (int ipix=0; ipix<D_A2_Spec_Obs.cols(); ipix++){
      D_A1_Sky(0, ipix) = CF_EcDR.Median(D_A2_Spec_Sky(Range::all(), ipix));
      D_A2_Spec_Obs(Range::all(), ipix) = D_A2_Spec_Obs(Range::all(), ipix) - D_A1_Sky(0, ipix);
    }
    CF_EcDR.SetNRows(D_A2_Spec_Obs.rows());
    CF_EcDR.GetPixArray() = D_A2_Spec_Obs;
    CString CS_Obs_Out(" ");
    CS_Obs_Out.Set(CS_ImageName_ApsRoot);
    CS_Obs_Out.Add(CString("DR_Obs-Sky.fits"));
    CF_EcDR.SetFileName(CS_Obs_Out);
    CF_EcDR.WriteArray();

    CF_EcDR.SetNRows(1);
    CF_EcDR.GetPixArray() = D_A1_Sky;
    CString CS_Sky_Out(" ");
    CS_Sky_Out.Set(CS_ImageName_ApsRoot);
    CS_Sky_Out.Add(CString("DR_SkyMedian.fits"));
    CF_EcDR.SetFileName(CS_Sky_Out);
    CF_EcDR.WriteArray();

    Array<double, 2> D_A1_Obs(1, D_A2_Spec_Obs.cols());
    for (int ipix=0; ipix<D_A1_Obs.size(); ipix++)
      D_A1_Obs(0, ipix) = sum(D_A2_Spec_Obs(Range::all(), ipix));
    CF_EcDR.GetPixArray() = D_A1_Obs;
    CS_Obs_Out.Set(CS_ImageName_ApsRoot);
    CS_Obs_Out.Add(CString("DR_ObsSum.fits"));
    CF_EcDR.SetFileName(CS_Obs_Out);
    CF_EcDR.WriteArray();
//    CF_EcDR.WriteArrayToFile(D_A1_Obs, )

    D_A2_Spec_Obs.resize(I_NElements, 2);
    D_A2_Spec_Obs(Range::all(), 0) = D_A1_Lambda;
    D_A2_Spec_Obs(Range::all(), 1) = D_A1_Obs(0, Range::all());
    if (D_A1_Lambda(0) > D_A1_Lambda(1)){
      if (!CF_EcDR.Reverse(D_A2_Spec_Obs)){
	cout << "MExtractSum_Obs_Sky::main: ERROR: Reverse(D_A2_Spec_Obs) returned FALSE" << endl;
	exit(EXIT_FAILURE);
      }
    }

    Array<double, 2> D_A2_Spec_Obs_Flux(I_NElements, 2);
    D_A2_Spec_Obs_Flux = 0.;

    if (!CF_EcDR.PhotonsToFlux(D_A2_Spec_Obs, D_A1_ExpTimes(i_file), D_ATel, D_A2_Spec_Obs_Flux)){
      cout << "MExtractSum_Obs_Sky::main: ERROR: PhotonsToFlux(" << D_A2_Spec_Obs << ", " << D_A1_ExpTimes(i_file) << ", " << D_ATel << ", D_A2_Spec_Obs_Flux) returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    CS_Obs_Out.Set(CS_ImageName_ApsRoot);
    CS_Obs_Out.Add(CString("DR_ObsSum_Flux.text"));
    if (!CF_EcDR.WriteArrayToFile(D_A2_Spec_Obs_Flux, CS_Obs_Out, CString("ascii"))){
      cout << "MExtractSum_Obs_Sky::main: ERROR: WriteArrayToFile(" << D_A2_Spec_Obs_Flux << ", " << CS_Obs_Out << ", ascii) returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    /// Write aperture header information
    F_Image.WriteApHead(CString("aphead_")+CS_FitsFileName_In+CString(".head"));

    // Create ErrOutEc
//  if (P_CS_ErrFromProfileOut->GetLength() > 1){// || P_CS_ErrOutEc->GetLength() > 1){
//    cout << "MExtractSum_Obs_Sky::main: Starting F_Image.ExtractErrors()" << endl;
//    if (!F_Image.ExtractErrors())
//    {
//      cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.ExtractErrors() returned FALSE!" << endl;
//      exit(EXIT_FAILURE);
//    }
//    F_OutImage.GetPixArray() = F_Image.GetErrorsEc();
//    F_OutImage.SetFileName(*P_CS_ErrOutEc);
//    F_OutImage.WriteArray();
//  }

    /// output extracted spectrum 1D
    cout << "MExtractSum_Obs_Sky::main: Starting to write EcOut" << endl;
    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
      F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetSpec()((*P_I_A1_Apertures)(i_ap), Range::all());//.transpose(secondDim, firstDim);
    cout << "MExtractSum_Obs_Sky::main: Starting F_OutImage.WriteArray()" << endl;
    if (!F_OutImage.WriteArray())
    {
      cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Write ErrOutEc 1D
    cout << "MExtractSum_Obs_Sky::main: Writing F_Image.GetErrorsEc()" << endl;
    if (P_CS_ErrOutEc->GetLength() > 1)
    {
//      CS_A1_Args_ExtractFromProfile(1) = CString("");
//      if (!F_Image.ExtractErrors(CS_A1_Args_ExtractFromProfile, PP_Args_ExtractFromProfile))
//      {
//        cout << "MExtractSum_Obs_Sky::main: ERROR: F_Image.ExtractErrors() returned FALSE!" << endl;
//        exit(EXIT_FAILURE);
//      }
      if (!F_OutImage.SetFileName(CS_A1_ErrOutEc(i_file)))
      {
        cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      cout << "MExtractSum_Obs_Sky::main: Starting to write ErrOutEc" << endl;
      for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
        F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetErrorsEc()((*P_I_A1_Apertures)(i_ap), Range::all());//.transpose(secondDim, firstDim);
      if (!F_OutImage.WriteArray())
      {
        cout << "MExtractSum_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
    }

    exit(EXIT_FAILURE);
  }/// end for (i_file...)
  delete(P_CS);
  delete(P_CS_ErrIn);
  delete(P_CS_ErrOutEc);
  delete(P_CS_MaskOut);
  delete(P_I_A1_Apertures);
  return EXIT_SUCCESS;
}
