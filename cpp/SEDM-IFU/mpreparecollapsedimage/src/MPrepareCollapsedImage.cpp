/*
author: Andreas Ritter
created: 05/08/2012
last edited: 05/08/2012
compiler: g++ 4.4
basis machine: Arch Linux

TASK:
* estimate and subtract scattered light
* extract all spectra using simple-sum method
* wavelength-calibrate extracted spectra
* rebin to same dispersion
* collapse spectra to be read with IDL
*/

#include "MPrepareCollapsedImage.h"

using namespace std;

int main(int argc, char *argv[])
{
  cout << "MPrepareCollapsedImage::main: argc = " << argc << endl;
  if (argc < 11)
  {
    cout << "MPrepareCollapsedImage::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: preparecollapsedimage <char[] [@]ImageList_In> <char[] DatabaseFileName_In> <char[] RefWLenFileList_In> <int ScatterBoxSizeX_In> <int ScatterBoxSizeY_In> <double WLen_Start_In> <double WLen_End_In> <double DWLen_In> <double D_MaxRMS_In> <char[] FileList_Out>" << endl;
    exit(EXIT_FAILURE);
  }

  CString CS_ImageList_In((char*)argv[1]);
  cout << "MPrepareCollapsedImage::main: CS_ImageList_In set to " << CS_ImageList_In << endl;

  CString CS_DatabaseFileName_In((char*)argv[2]);

  CString CS_RefWLenFiles_In = (char*)argv[3];
  cout << "MPrepareCollapsedImage::main: CS_RefWLenFiles_In set to " << CS_RefWLenFiles_In << endl;

//  double D_RdNoise_In = *(double*)(argv[4]);
//  cout << "MPrepareCollapsedImage::main: D_RdNoise_In set to " << D_RdNoise_In << endl;

//  double D_Gain_In = *(double*)(argv[5]);
//  cout << "MPrepareCollapsedImage::main: D_Gain_In set to " << D_Gain_In << endl;

  int I_ScatterBoxSizeX_In = atoi((char*)argv[4]);
  cout << "MPrepareCollapsedImage::main: I_ScatterBoxSizeX_In set to " << I_ScatterBoxSizeX_In << endl;

  int I_ScatterBoxSizeY_In = atoi((char*)argv[5]);
  cout << "MPrepareCollapsedImage::main: I_ScatterBoxSizeY_In set to " << I_ScatterBoxSizeY_In << endl;

  double D_WLen_Start = (double)(atof((char*)argv[6]));
  cout << "MPrepareCollapsedImage::main: D_WLen_Start set to " << D_WLen_Start << endl;

  double D_WLen_End = (double)(atof((char*)argv[7]));
  cout << "MPrepareCollapsedImage::main: D_WLen_End set to " << D_WLen_End << endl;

  double D_DWLen = (double)(atof((char*)argv[8]));
  cout << "MPrepareCollapsedImage::main: D_DWLen set to " << D_DWLen << endl;

  double D_MaxRMS_In = (double)(atof((char*)argv[9]));
  cout << "MPrepareCollapsedImage::main: D_MaxRMS_In set to " << D_MaxRMS_In << endl;

  CString CS_FileList_Out((char*)argv[10]);
  Array<CString, 1> CS_A1_FileList_Out(1);

  /// read parameters
  Array<CString, 1> CS_A1_ImageList_In(1);
  CS_A1_ImageList_In(0) = CS_ImageList_In;

  Array<CString, 1> CS_A1_TextFiles_Coeffs_In(1);
  CS_A1_TextFiles_Coeffs_In(0) = CS_RefWLenFiles_In;

//  Array<CString, 1> CS_A1_Out(1);
//  CS_A1_Out(0) = CS_Out;


  CString CS_Comp("@");
  CString *P_CS_Temp = CS_ImageList_In.SubString(0,0);
  CString *P_CS_FN;
  if (P_CS_Temp->EqualValue(CS_Comp)){
    P_CS_FN = CS_ImageList_In.SubString(1);
        CS_ImageList_In.Set(*P_CS_FN);
    if (!CS_Comp.ReadFileLinesToStrArr(CS_ImageList_In, CS_A1_ImageList_In)){
      cout << "MPrepareCollapsedImage::main: ERROR: ReadFileLinesToStrArr(" << CS_ImageList_In << ") returned FALSE";
      exit(EXIT_FAILURE);
    }
    delete(P_CS_FN);
//    P_CS_FN = CS_RefWLenFiles_In.SubString(1);
//        CS_RefWLenFiles_In.Set(*P_CS_FN);
//    if (!CS_Comp.ReadFileLinesToStrArr(CS_RefWLenFiles_In, CS_A1_TextFiles_Coeffs_In)){
//      cout << "MPrepareCollapsedImage::main: ERROR: ReadFileLinesToStrArr(" << CS_RefWLenFiles_In << ") returned FALSE";
//      exit(EXIT_FAILURE);
//    }
//    delete(P_CS_FN);
//    P_CS_FN = CS_Out.SubString(1);
//    CS_Out.Set(*P_CS_FN);
//    if (!CS_Comp.ReadFileLinesToStrArr(CS_Out, CS_A1_Out)){
//      cout << "MPrepareCollapsedImage::main: ERROR: ReadFileLinesToStrArr(" << CS_Out << ") returned FALSE";
//      exit(EXIT_FAILURE);
//    }
//    delete(P_CS_FN);
  }

  CString CS_FileNameScatteredLight_Out(" ");
  CString CS_ImageName_s(" ");
  CString CS_ImageName_sEcSum(" ");
  CString CS_ImageName_err(" ");
  CString CS_TextFile_EcD(" ");
  CString CS_ApNum_X_Y_Sum(" ");
  Array<CString, 1> CS_A1_ImageNames_s(CS_A1_ImageList_In.size());
  CS_A1_ImageNames_s = CString(" ");
  Array<CString, 1> CS_A1_ImageNames_sEcSum(CS_A1_ImageList_In.size());
  CS_A1_ImageNames_sEcSum = CString(" ");
  CS_A1_FileList_Out.resize(CS_A1_ImageList_In.size());
  CS_A1_FileList_Out = CString(" ");
  Array<CString, 1> CS_A1_TextFiles_EcD_Out(1);
  Array<CString, 1> CS_A1_TextFiles_EcDR_Out(1);
  Array<CString, 1> CS_A1_ApertureFitsFileNames(1);
  CString CS_ImageName_ApsRoot(" ");
  CString CS_FitsFileName_EcDR_Out(" ");
  CFits F_Image;
//  CFits F_Image2;
  CString *P_CS_SubStringTemp;
  Array<double, 2> D_A2_ScatteredLight(2,2);
  D_A2_ScatteredLight = 0.;
  Array<double, 2> D_A2_Err(2,2);
  D_A2_Err = 0.;
  Array<double, 2> D_A2_Spectra(2,2);
  for (int i_file=0; i_file<CS_A1_ImageList_In.size(); i_file++){
    cout << "MPrepareCollapsedImage::main: Starting F_Image.SetFileName(" << CS_A1_ImageList_In(i_file) << ")" << endl;
    if (!F_Image.SetFileName(CS_A1_ImageList_In(i_file)))
    {
      cout << "MPrepareCollapsedImage::main: ERROR: F_Image.SetFileName(" << CS_A1_ImageList_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Read FitsFile
    cout << "MPrepareCollapsedImage::main: Starting F_Image.ReadArray()" << endl;
    if (!F_Image.ReadArray())
    {
      cout << "MPrepareCollapsedImage::main: ERROR: F_Image.ReadArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    ///Set DatabaseFileName and calculate trace functions
    if (!F_Image.SetDatabaseFileName(CS_DatabaseFileName_In)){
      cout << "MPrepareCollapsedImage::main: ERROR: F_Image.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_Image.ReadDatabaseEntry()){
      cout << "MPrepareCollapsedImage::main: ERROR: F_Image.ReadDatabaseEntry() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_Image.CalcTraceFunctions()){
      cout << "MPrepareCollapsedImage::main: ERROR: F_Image.CalcTraceFunctions() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    Array<double, 1> *P_D_A1_YHigh = F_Image.Get_YHigh();
    cout << "MPrepareCollapsedImage::main: 1. F_Image.GetYHigh() = " << *P_D_A1_YHigh << endl;
    delete(P_D_A1_YHigh);
//    exit(EXIT_FAILURE);

    P_CS_SubStringTemp = CS_A1_ImageList_In(i_file).SubString(0,CS_A1_ImageList_In(i_file).LastCharPos('.')-1);
    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": P_CS_SubStringTemp = <" << *P_CS_SubStringTemp << ">" << endl;

    CS_ImageName_s.Set(*P_CS_SubStringTemp);
    CS_ImageName_s.Add(CString("_s.fits"));
    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": CS_ImageName_s = <" << CS_ImageName_s << ">" << endl;

    CS_A1_ImageNames_s(i_file).Set(CS_ImageName_s);

    CS_FileNameScatteredLight_Out.Set(*P_CS_SubStringTemp);
    CS_FileNameScatteredLight_Out.Add(CString("_scatteredLight.fits"));

    CS_ImageName_err.Set(*P_CS_SubStringTemp);
    CS_ImageName_err.Add(CString("_err.fits"));

    CS_ImageName_sEcSum.Set(*P_CS_SubStringTemp);
    CS_ImageName_sEcSum.Add(CString("_sEcSum.fits"));
    CS_A1_ImageNames_sEcSum(i_file).Set(CS_ImageName_sEcSum);

    CS_ImageName_ApsRoot.Set(*P_CS_SubStringTemp);
    CS_ImageName_ApsRoot.Add(CString("_sEcSum"));

    CS_FitsFileName_EcDR_Out.Set(*P_CS_SubStringTemp);
    CS_FitsFileName_EcDR_Out.Add(CString("_sEcSumDR.fits"));

    CS_ApNum_X_Y_Sum.Set(*P_CS_SubStringTemp);
    CS_ApNum_X_Y_Sum.Add(CString("_sEcSumDR_ApNum_X_Y_Sum.dat"));
    delete(P_CS_SubStringTemp);

    /// Estimate scattered light
    if (!F_Image.EstScatterKriging((F_Image.GetNCols() / I_ScatterBoxSizeX_In) + 1, (F_Image.GetNRows() / I_ScatterBoxSizeY_In) + 1, D_A2_ScatteredLight)){
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: EstScatterKriging returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_Image.WriteFits(&D_A2_ScatteredLight, CS_FileNameScatteredLight_Out)){
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: WriteFits(D_A2_ScatteredLight, " << CS_FileNameScatteredLight_Out << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

//    P_D_A1_YHigh = F_Image.Get_YHigh();
//    cout << "MPrepareCollapsedImage::main: 2. F_Image.GetYHigh() = " << *P_D_A1_YHigh << endl;
//    delete(P_D_A1_YHigh);
//    exit(EXIT_FAILURE);

    F_Image.GetPixArray() -= D_A2_ScatteredLight;
    if (!F_Image.SetFileName(CS_ImageName_s)){
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: SetFileName(" << CS_ImageName_s << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_Image.WriteArray()){
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: WriteArray for scattered-light subtracted image returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    /// Create Error image
//    D_A2_Err.resize(D_A2_ScatteredLight.rows(), D_A2_ScatteredLight.cols());
//    if (D_A2_Err.rows() != D_A2_ScatteredLight.rows()){
//      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: D_A2_Err.rows(=" << D_A2_Err.rows() << ") != D_A2_ScatteredLight.rows(=" << D_A2_ScatteredLight.rows() << ")" << endl;
//      exit(EXIT_FAILURE);
//    }
 //   F_Image.GetPixArray() = sqrt(fabs((F_Image.GetPixArray())) / D_Gain + pow2(D_RdNoise));
    if (!F_Image.ExtractSimpleSum()){
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: ExtractSimpleSum() returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

//    P_D_A1_YHigh = F_Image.Get_YHigh();
//    cout << "MPrepareCollapsedImage::main: 2. F_Image.GetYHigh() = " << *P_D_A1_YHigh << endl;
//    delete(P_D_A1_YHigh);
//    exit(EXIT_FAILURE);


//    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Starting F_Image2.SetFileName(" << CS_A1_ImageList_In(i_file) << ")" << endl;
//    if (!F_Image2.SetFileName(CS_A1_ImageList_In(i_file)))
//    {
//      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.SetFileName(" << CS_A1_ImageList_In(i_file) << ") returned FALSE!" << endl;
//      exit(EXIT_FAILURE);
//    }

    /// Read FitsFile
//    cout << "MPrepareCollapsedImage::main: Starting F_Image2.ReadArray()" << endl;
//    if (!F_Image2.ReadArray())
//    {
//      cout << "MPrepareCollapsedImage::main: ERROR: F_Image2.ReadArray() returned FALSE!" << endl;
//      exit(EXIT_FAILURE);
//    }

//    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": F_Image2: SetDatabaseFileName" << endl;
//    if (!F_Image2.SetDatabaseFileName(CS_DatabaseFileName_In))
//    {
//      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
//      exit(EXIT_FAILURE);
//    }

//    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": F_Image2: Reading Trace Functions" << endl;
//    if (!F_Image2.ReadDatabaseEntry())
//    {
//      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.ReadDatabaseEntry returned FALSE!" << endl;
//      exit(EXIT_FAILURE);
//    }

//    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": F_Image2: Calculating Trace Functions" << endl;
//    if (!F_Image2.CalcTraceFunctions())
//    {
//      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.CalcTraceFunctions returned FALSE!" << endl;
//      exit(EXIT_FAILURE);
//    }


    D_A2_Spectra.resize(F_Image.Get_NApertures(), F_Image.GetNRows());
    D_A2_Spectra = F_Image.GetLastExtracted();

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Starting F_Image.SetFileName(" << CS_ImageName_sEcSum << ")" << endl;
    if (!F_Image.SetFileName(CS_ImageName_sEcSum))
    {
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image.SetFileName(" << CS_ImageName_sEcSum << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

//    P_D_A1_YHigh = F_Image2.Get_YHigh();
//    cout << "MPrepareCollapsedImage::main: 1. F_Image2.GetYHigh() = " << *P_D_A1_YHigh << endl;
//    delete(P_D_A1_YHigh);
//    exit(EXIT_FAILURE);

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": changing size of F_Image2 to (NApertures x NRows)" << endl;
    if (!F_Image.SetNCols(F_Image.GetNRows()))
    {
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.SetNCols(" << F_Image.GetNRows() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_Image.SetNRows(F_Image.Get_NApertures()))
    {
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.SetNRows(" << F_Image.Get_NApertures() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": populate PixArray with extracted spectra" << endl;
    F_Image.GetPixArray() = D_A2_Spectra;//.transpose(secondDim, firstDim);
    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": writing array" << endl;
    if (!F_Image.WriteArray())
    {
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

//    P_D_A1_YHigh = F_Image2.Get_YHigh();
//    cout << "MPrepareCollapsedImage::main: 2. F_Image2.GetYHigh() = " << *P_D_A1_YHigh << endl;
//    delete(P_D_A1_YHigh);
//    exit(EXIT_FAILURE);

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Write spectra to individual files" << endl;
    F_Image.WriteApertures(CS_ImageName_ApsRoot, CS_A1_ApertureFitsFileNames);

//    P_D_A1_YHigh = F_Image.Get_YHigh();
//    cout << "MPrepareCollapsedImage::main: 3. F_Image2.GetYHigh() = " << *P_D_A1_YHigh << endl;
//    delete(P_D_A1_YHigh);
//    exit(EXIT_FAILURE);

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Apply dispersion correction: creating list" << endl;
    if (!CS_Comp.StrReplaceInList(CS_A1_ApertureFitsFileNames, CString(".fits"), CString("D.text"), CS_A1_TextFiles_EcD_Out)){
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: 1. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Apply dispersion correction: CS_A1_TextFiles_EcD_Out = " << CS_A1_TextFiles_EcD_Out << endl;

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Apply dispersion correction: Starting DispCorList" << endl;
    if (!F_Image.DispCorList(CS_A1_TextFiles_Coeffs_In, CS_A1_TextFiles_EcD_Out, D_MaxRMS_In)){
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: DispCorList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Rebin spectra: Creating File List" << endl;
    if (!CS_Comp.StrReplaceInList(CS_A1_ApertureFitsFileNames, CString("D.text"), CString("DR.text"), CS_A1_TextFiles_EcDR_Out)){
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: 2. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Rebin spectra: CS_A1_TextFiles_EcDR_Out = " << CS_A1_TextFiles_EcDR_Out << endl;

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Rebin spectra: Starting RebinTextList" << endl;
    if (!F_Image.RebinTextList(CS_A1_TextFiles_EcD_Out, CS_A1_TextFiles_EcDR_Out, CS_FitsFileName_EcDR_Out, D_WLen_Start, D_WLen_End, D_DWLen)){
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: RebinTextList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Collapse spectra" << endl;
    if (!F_Image.CollapseSpectra(CS_A1_TextFiles_EcDR_Out, CS_ApNum_X_Y_Sum)){
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: CollapseSpectra returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    CS_A1_FileList_Out(i_file).Set(CS_ApNum_X_Y_Sum);
    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": CS_A1_FileList_Out(i_file) set to " << CS_A1_FileList_Out(i_file) << endl;

  }
  /// clean up

  return EXIT_SUCCESS;
}

