/*
author: Andreas Ritter
created: 05/08/2012
last edited: 05/08/2012
compiler: g++ 4.4
basis machine: Arch Linux

TASK:
* extract all spectra using simple-sum method
* wavelength-calibrate extracted spectra
* rebin to same dispersion
* collapse spectra to be read with IDL
*/

#include "MPrepareCollapsedImageNoScatter.h"

//using namespace std;

template <class T>
string to_string(T t, ios_base & (*f)(ios_base&)){
  ostringstream oss;
  oss << f << t;
  return oss.str();
}

int main(int argc, char *argv[])
{



  bool B_DoCalculations = true;






  cout << "MPrepareCollapsedImage::main: argc = " << argc << endl;
  if (argc < 11)
  {
    cout << "MPrepareCollapsedImage::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: preparecollapsedimage <char[] [@]ImageList_In> <char[] DatabaseFileName_In> <char[] CoeffsFileList_In> <double Gain> <double WLen_Start_In> <double WLen_End_In> <double DWLen_In> <double D_MaxRMS_In> <char[] FileList_Out> <char[] Cornerfiles_List_Out> [AP_DEF_IMAGE=char[](ApertureDefinitionImage)]" << endl;
    cout << "Parameter 1: [@]ImageList_In: char[]: list of input fits files, 1 file per line" << endl;
    cout << "Parameter 2: DatabaseFileName_In: char[]: list of input fits files" << endl;
    cout << "Parameter 3: CoeffsFileList_In: char[]: list of files containing the coefficients of the wavelength fit for each aperture" << endl;
    cout << "      Each file looks something like this:" << endl;
    cout << "          3.61231165e+03" << endl;
    cout << "          -1.86351460e+00" << endl;
    cout << "          4.50888675e-01" << endl;
    cout << "          -4.65243253e-03" << endl;
    cout << "          2.13711822e-05" << endl;
    cout << "          -3.29238062e-08" << endl;
    cout << "          RMS 27.7915143 Ap 1017" << endl;
    cout << "Parameter 4: Gain: double: CCD Gain in e-/ADU" << endl;
    cout << "Parameter 5: WLen_Start_In: double: Reject wavelengths below this value" << endl;
    cout << "Parameter 6: WLen_End_In: double: Reject wavelengths above this value" << endl;
    cout << "Parameter 7: DWLen_In: double: Wavelength step" << endl;
    cout << "Parameter 8: D_MaxRMS_In: double: Reject apertures where the fit resulted in an RMS above this value" << endl;
    cout << "Parameter 9: FileList_Out: char[]: Output file list containing the final results to be created by the module" << endl;
    cout << "Parameter 10: Cornerfiles_List_Out: char[]: Output file list containing the coordinates of each hexagonal spaxel, file will be created by the module" << endl;
    
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

//  int I_ScatterBoxSizeX_In = atoi((char*)argv[4]);
//  cout << "MPrepareCollapsedImage::main: I_ScatterBoxSizeX_In set to " << I_ScatterBoxSizeX_In << endl;

//  int I_ScatterBoxSizeY_In = atoi((char*)argv[5]);
//  cout << "MPrepareCollapsedImage::main: I_ScatterBoxSizeY_In set to " << I_ScatterBoxSizeY_In << endl;

  double D_Gain = (double)(atof((char*)argv[4]));
  cout << "MPrepareCollapsedImage::main: D_Gain set to " << D_Gain << endl;

  double D_WLen_Start = (double)(atof((char*)argv[5]));
  cout << "MPrepareCollapsedImage::main: D_WLen_Start set to " << D_WLen_Start << endl;

  double D_WLen_End = (double)(atof((char*)argv[6]));
  cout << "MPrepareCollapsedImage::main: D_WLen_End set to " << D_WLen_End << endl;

  double D_DWLen = (double)(atof((char*)argv[7]));
  cout << "MPrepareCollapsedImage::main: D_DWLen set to " << D_DWLen << endl;

  double D_MaxRMS_In = (double)(atof((char*)argv[8]));
  cout << "MPrepareCollapsedImage::main: D_MaxRMS_In set to " << D_MaxRMS_In << endl;

  CString CS_FileList_Out((char*)argv[9]);
  CString CS_CornerList_Out((char*)argv[10]);
  Array<CString, 1> CS_A1_FileList_Out(1);
  CString *P_CS_ApDefImage_In = new CString(" ");
  CString CS_FName_ApertureCenters("apcenters.dat");

  CFits F_Image;
  CFits F_Image2;
  CFits F_ApDefImage;

  /// read parameters
  Array<CString, 1> CS_A1_ImageList_In(1);
  CS_A1_ImageList_In(0) = CS_ImageList_In;

  Array<CString, 1> CS_A1_TextFiles_Coeffs_In(1);
  if (!F_Image.ReadFileLinesToStrArr(CS_RefWLenFiles_In, CS_A1_TextFiles_Coeffs_In)){
    cout << "MPrepareCollapsedImage::main: ERROR: ReadFileLinesToStrArr(" << CS_RefWLenFiles_In << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }

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
  delete(P_CS_Temp);
  Array<CString, 2> CS_A2_FName_CenterX_CenterY_RadObj_RadSky(CS_A1_ImageList_In.size(), 5);
  CS_A2_FName_CenterX_CenterY_RadObj_RadSky(Range::all(), 0) = CS_A1_ImageList_In;
//  cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_ImageList_In = " << CS_A1_ImageList_In << endl;
//  cout << "MPrepareCollapsedImageNoScatter::main: CS_A2_FName_CenterX_CenterY_RadObj_RadSky = " << CS_A2_FName_CenterX_CenterY_RadObj_RadSky << endl;
//  exit(EXIT_FAILURE);


  CString CS(" ");
  /// read optional parameters
  for (int i = 11; i <= argc; i++){
    CS.Set((char*)argv[i]);
    cout << "MPrepareCollapsedImageNoScatter: Reading Parameter " << CS << endl;

    CS_Comp.Set("AP_DEF_IMAGE");
    if (CS.GetLength() > CS_Comp.GetLength()){
      P_CS_Temp = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MPrepareCollapsedImageNoScatter::main: *P_CS_Temp set to " << *P_CS_Temp << endl;
      if (P_CS_Temp->EqualValue(CS_Comp)){
        delete(P_CS_ApDefImage_In);
        P_CS_ApDefImage_In = CS.SubString(CS_Comp.GetLength()+1);
        cout << "MPrepareCollapsedImageNoScatter::main: ApDefImage_In set to " << *P_CS_ApDefImage_In << endl;
      }
    }
  }
  delete(P_CS_Temp);

  CString CS_FileNameScatteredLight_Out(" ");
  CString CS_ImageName(" ");
  CString CS_ImageName_EcSum(" ");
  CString CS_ImageName_err(" ");
  CString CS_TextFile_EcD(" ");
  CString CS_ApNum_X_Y_Sum(" ");
  Array<CString, 1> CS_A1_ImageNames(CS_A1_ImageList_In.size());
    CS_A1_ImageNames = CString(" ");
  Array<CString, 1> CS_A1_ImageNames_EcSum(CS_A1_ImageList_In.size());
    CS_A1_ImageNames_EcSum = CString(" ");
  CS_A1_FileList_Out.resize(CS_A1_ImageList_In.size());
  CS_A1_FileList_Out = CString(" ");
  Array<CString, 1> CS_A1_TextFiles_EcD_Out(1);
  Array<CString, 1> CS_A1_TextFiles_EcDR_Out(1);
  Array<CString, 1> CS_A1_ApertureFitsFileNames(1);
  CString CS_ImageName_ApsRoot(" ");
  CString CS_FitsFileName_EcDR_Out(" ");
  CString *P_CS_SubStringTemp;
  Array<double, 2> D_A2_Err(2,2);
  D_A2_Err = 0.;



if (B_DoCalculations){
  for (int i_file=0; i_file<CS_A1_ImageList_In.size(); i_file++){
    cout << "MPrepareCollapsedImage::main: i_file=" << i_file << ": Starting F_Image.SetFileName(" << CS_A1_ImageList_In(i_file) << ")" << endl;
    if (!F_Image.SetFileName(CS_A1_ImageList_In(i_file)))
    {
      cout << "MPrepareCollapsedImage::main: i_file=" << i_file << ": ERROR: F_Image.SetFileName(" << CS_A1_ImageList_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Read FitsFile
    cout << "MPrepareCollapsedImage::main: i_file=" << i_file << ": Starting F_Image.ReadArray()" << endl;
    if (!F_Image.ReadArray())
    {
      cout << "MPrepareCollapsedImage::main: i_file=" << i_file << ": ERROR: F_Image.ReadArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Convert ADUs to photons
    F_Image.GetPixArray() *= D_Gain;

    ///Set DatabaseFileName and calculate trace functions
    if (!F_Image.SetDatabaseFileName(CS_DatabaseFileName_In)){
      cout << "MPrepareCollapsedImage::main: i_file=" << i_file << ": ERROR: F_Image.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_Image.ReadDatabaseEntry()){
      cout << "MPrepareCollapsedImage::main: i_file=" << i_file << ": ERROR: F_Image.ReadDatabaseEntry() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_Image.CalcTraceFunctions()){
      cout << "MPrepareCollapsedImage::main: i_file=" << i_file << ": ERROR: F_Image.CalcTraceFunctions() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    int I_Shift = 0;
    double D_ChiSquareMin = 0.;
    if (P_CS_ApDefImage_In->GetLength() > 2){
      F_ApDefImage.SetFileName(*P_CS_ApDefImage_In);
      F_ApDefImage.ReadArray();
      Array<double, 1> D_A1_Line_ApDefImage(F_ApDefImage.GetNCols());
      Array<double, 1> D_A1_Line_Image(F_Image.GetNCols());
      if (D_A1_Line_ApDefImage.size() != D_A1_Line_Image.size()){
        cout << "MPrepareCollapseImage::main: i_file=" << i_file << ": ERROR: D_A1_Line_ApDefImage.size(=" << D_A1_Line_ApDefImage.size() << ") != D_A1_Line_Image.size(=" << D_A1_Line_Image.size() << ") => Returning FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      D_A1_Line_ApDefImage = F_ApDefImage.GetPixArray()(F_ApDefImage.GetNRows() / 2, Range::all());
      D_A1_Line_Image = F_Image.GetPixArray()(F_Image.GetNRows() / 2, Range::all());
      if (!F_Image.CrossCorrelate(D_A1_Line_Image, D_A1_Line_ApDefImage, 3, 3, I_Shift, D_ChiSquareMin)){
        cout << "MPrepareCollapseImage::main: i_file=" << i_file << ": ERROR: CrossCorrelate returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      cout << "MPrepareCollapseImage::main: i_file=" << i_file << ": I_Shift = " << I_Shift << endl;
      //      exit(EXIT_FAILURE);
      F_Image.ShiftApertures(double(I_Shift));
      //      F_Image.SetDatabaseFileName("database/aptemp");
      //      F_Image.WriteDatabaseEntry();
      //      F_Image.MarkCenters();
      //      F_Image.SetFileName("temp.fits");
      //      F_Image.WriteArray();
      //      exit(EXIT_FAILURE);
    }

    CString *P_CS_Path = CS_A1_ImageList_In(i_file).SubString(0,CS_A1_ImageList_In(i_file).LastCharPos('.')-1);
    if (!P_CS_Path->MkDir(*P_CS_Path)){
        cout << "MPrepareCollapsedImage::main: ERROR: MkDir(" << *P_CS_Path << ") returned FALSE" << endl;
        exit(EXIT_FAILURE);
    }
    P_CS_SubStringTemp = CS_A1_ImageList_In(i_file).SubString(0,CS_A1_ImageList_In(i_file).LastCharPos('.')-1);
    cout << "MPrepareCollapseImage::main: i_file=" << i_file << ": i_file = " << i_file << ": P_CS_SubStringTemp = <" << *P_CS_SubStringTemp << ">" << endl;

//        CS_ImageName.Set(*P_CS_SubStringTemp);
//        CS_ImageName.Add(CString(".fits"));
//    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": CS_ImageName_s = <" << CS_ImageName << ">" << endl;

    CS_A1_ImageNames(i_file).Set(CS_ImageName);

    CS_ImageName_err.Set(*P_CS_SubStringTemp);
    CS_ImageName_err.Add(CString("_err.fits"));

    CS_ImageName_EcSum.Set(*P_CS_Path);
    CS_ImageName_EcSum.Add(CString("/"));
    CS_ImageName_EcSum.Add(*P_CS_SubStringTemp);
    CS_ImageName_EcSum.Add(CString("_EcSum.fits"));
    CS_A1_ImageNames_EcSum(i_file).Set(CS_ImageName_EcSum);

    CS_ImageName_ApsRoot.Set(*P_CS_Path);
    CS_ImageName_ApsRoot.Add(CString("/"));
    CS_ImageName_ApsRoot.Add(*P_CS_SubStringTemp);
    CS_ImageName_ApsRoot.Add(CString("_EcSum"));

    CS_FitsFileName_EcDR_Out.Set(*P_CS_Path);
    CS_FitsFileName_EcDR_Out.Add(CString("/"));
    CS_FitsFileName_EcDR_Out.Add(*P_CS_SubStringTemp);
    CS_FitsFileName_EcDR_Out.Add(CString("_EcSumDR.fits"));

    CS_ApNum_X_Y_Sum.Set(*P_CS_Path);
    CS_ApNum_X_Y_Sum.Add(CString("/"));
    CS_ApNum_X_Y_Sum.Add(*P_CS_SubStringTemp);
    CS_ApNum_X_Y_Sum.Add(CString("_EcSumDR_ApNum_X_Y_Sum.dat"));
    delete(P_CS_Path);
    delete(P_CS_SubStringTemp);

    /// Estimate scattered light
//    if (!F_Image.EstScatterKriging((F_Image.GetNCols() / I_ScatterBoxSizeX_In) + 1, (F_Image.GetNRows() / I_ScatterBoxSizeY_In) + 1, D_A2_ScatteredLight)){
//      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: EstScatterKriging returned FALSE" << endl;
//      exit(EXIT_FAILURE);
//    }
//    if (!F_Image.WriteFits(&D_A2_ScatteredLight, CS_FileNameScatteredLight_Out)){
//      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: WriteFits(D_A2_ScatteredLight, " << CS_FileNameScatteredLight_Out << ") returned FALSE" << endl;
//      exit(EXIT_FAILURE);
//    }

//    F_Image.GetPixArray() -= D_A2_ScatteredLight;
//    if (!F_Image.SetFileName(CS_ImageName)){
//      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: SetFileName(" << CS_ImageName << ") returned FALSE" << endl;
//      exit(EXIT_FAILURE);
//    }
//    if (!F_Image.WriteArray()){
//      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: WriteArray for scattered-light subtracted image returned FALSE" << endl;
//      exit(EXIT_FAILURE);
//    }

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

    Array<double, 2> D_A2_Spectra(F_Image.Get_NApertures(), F_Image.GetNRows());
    D_A2_Spectra = F_Image.GetLastExtracted();

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Starting F_Image2.SetFileName(" << CS_ImageName_EcSum << ")" << endl;
    if (!F_Image.SetFileName(CS_ImageName_EcSum))
    {
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.SetFileName(" << CS_ImageName_EcSum << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    
    Array<double, 2> D_A2_XCenters(F_Image.Get_XCenters()->rows(), F_Image.Get_XCenters()->cols());
    D_A2_XCenters = (*(F_Image.Get_XCenters()));
    cout << "MPrepareCollapsedImageNoScatter::main: D_A2_XCenters has " << D_A2_XCenters.rows() << " rows and " << D_A2_XCenters.cols() << " cols" << endl;

/**    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": F_Image2: SetDatabaseFileName" << endl;
    if (!F_Image2.SetDatabaseFileName(CS_DatabaseFileName_In))
    {
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": F_Image2: Reading Trace Functions" << endl;
    if (!F_Image2.ReadDatabaseEntry())
    {
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.ReadDatabaseEntry returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": F_Image2: Calculating Trace Functions" << endl;
    if (!F_Image2.CalcTraceFunctions())
    {
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.CalcTraceFunctions returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
   **/
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
      cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": ERROR: F_Image2.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    
    cout << "MPrepareCollapsedImageNoScatter::main: i_file = " << i_file << ": F_Image.Get_XCenters()->rows() = " << F_Image.Get_XCenters()->rows() << ", F_Image.Get_XCenters()->cols() = " << F_Image.Get_XCenters()->cols() << endl;
    F_Image.Get_XCentersPointer()->resize(D_A2_XCenters.rows(), D_A2_XCenters.cols());
    cout << "MPrepareCollapsedImageNoScatter::main: i_file = " << i_file << ": F_Image.Get_XCenters()->rows() = " << F_Image.Get_XCenters()->rows() << ", F_Image.Get_XCenters()->cols() = " << F_Image.Get_XCenters()->cols() << endl;
    (*(F_Image.Get_XCentersPointer())) = D_A2_XCenters;

    cout << "MPrepareCollapsedImage::main: i_file = " << i_file << ": Write spectra to individual files" << endl;
    F_Image.WriteApertures(CS_ImageName_ApsRoot, CS_A1_ApertureFitsFileNames);

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
    if (!CS_Comp.StrReplaceInList(CS_A1_TextFiles_EcD_Out, CString("D.text"), CString("DR.text"), CS_A1_TextFiles_EcDR_Out)){
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

    if (i_file == 0){
      Array<CString, 1> CS_A1_CornerFiles(F_Image.Get_NApertures());
      Array<double, 3> D_A3_LensletCorners(2,2,2);
      if (!F_Image.CalculateLensletCorners(D_A3_LensletCorners)){
        cout << "MPrepareCollapsedImageNoScatter::main: ERROR: CalculateLensletCorners returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      CString CS_FileName_Corner_Root("corners_aperture");
      CString CS_FileName_Corner(" ");
      CString CS_Dat(".dat");
      CString *P_CS_ApNum;
      for (int i_ap=0; i_ap<F_Image.Get_NApertures(); i_ap++){
        CS_FileName_Corner.Set(CS_FileName_Corner_Root);
        P_CS_ApNum = CS_FileName_Corner.IToA(i_ap);
        CS_FileName_Corner.Add(*P_CS_ApNum);
        delete(P_CS_ApNum);
        CS_FileName_Corner.Add(CS_Dat);
        if (!F_Image.WriteArrayToFile(D_A3_LensletCorners(i_ap, Range::all(), Range::all()), CS_FileName_Corner, CString("ascii"))){
          cout << "MPrepareCollapsedImageNoScatter::main: ERROR: WriteArrayToFile(D_A3_LensletCorners(" << i_ap << ")) returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        CS_A1_CornerFiles(i_ap).Set(CS_FileName_Corner);
      }
      if (!CS_FileName_Corner.WriteStrListToFile(CS_A1_CornerFiles, CS_CornerList_Out)){
        cout << "MPrepareCollapsedImageNoScatter::main: ERROR: WriteStrListToFile(" << CS_CornerList_Out << ") returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }

      if (!F_Image.WriteApCenters(CS_FName_ApertureCenters)){
        cout << "MPrepareCollapsedImageNoScatter::main: ERROR: WriteApCenters returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
    }

  }
  /// clean up
  CS_Comp.WriteStrListToFile(CS_A1_FileList_Out, CS_FileList_Out);
}
else{
  if (!F_Image.ReadFileLinesToStrArr(CString("collapsed_files.list"), CS_A1_FileList_Out)){
    cout << "MPrepareCollapsedImageNoScatter::main: ERROR: ReadFileLinesToStrArr(collapsed_files) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
}









  ///Create Plot
//  str_path = strmid(strlist_collapsed_spectra_in, 0, strpos(strlist_collapsed_spectra_in,'/',/REVERSE_SEARCH)+1)
//  print,'str_path = <'+str_path+'>'

//  dblarr_centers = double(readfiletostrarr(str_filename_in,' '))
//  print,'dblarr_centers(0,*) = ',dblarr_centers(0,*)
  Array<double, 2> D_A2_ApertureCenters(2,2);
  if (!F_Image.ReadFileToDblArr(CS_FName_ApertureCenters, D_A2_ApertureCenters, CString(" "))){
    cout << "MPrepareCollapsedImageNoScatter::main: ERROR: F_Image.ReadFileToDblArr(" << CS_FName_ApertureCenters << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<double, 1> D_A1_ApertureCenters_X(D_A2_ApertureCenters.rows());
  Array<double, 1> D_A1_ApertureCenters_Y(D_A2_ApertureCenters.rows());
  D_A1_ApertureCenters_X = D_A2_ApertureCenters(Range::all(), 0);
  D_A1_ApertureCenters_Y = D_A2_ApertureCenters(Range::all(), 1);

//  strlist_spectra = readfilelinestoarr(strlist_collapsed_spectra_in)

  CString CS_HtmlFile("index_collapsed_spectra.html");
  ofstream *P_OFS_HtmlFile = new ofstream(CS_HtmlFile.Get());
  (*P_OFS_HtmlFile) << "<html><body><center>" << endl;
  CString *P_CS_TempA;

  //  strarr_corners_apertures = readfilelinestoarr(str_cornerlist_in)
  Array<CString, 1> CS_A1_CornerFileNames(1);
  if (!F_Image.ReadFileLinesToStrArr(CS_CornerList_Out, CS_A1_CornerFileNames)){
    cout << "MPrepareCollapsedImageNoScatter::main: ERROR: ReadFileLinesToStrArr(" << CS_CornerList_Out << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }

//  strarr_corners_aps = strarr(n_elements(strarr_corners_apertures))
  Array<CString, 1> CS_A1_Corners_Aps(CS_A1_CornerFileNames.size());
  for (int i=0; i<CS_A1_CornerFileNames.size(); i++){
    cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_CornerFileNames(" << i << ") = " << CS_A1_CornerFileNames(i) << endl;
    P_CS_Temp = CS_A1_CornerFileNames(i).SubString(16,CS_A1_CornerFileNames(i).CharPos('.')-1);
    CS_A1_Corners_Aps(i).Set(*P_CS_Temp);
    delete(P_CS_Temp);
    #ifdef __DEBUG_MPREPARE__
      cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_Corners_Aps(" << i << ") =  " << CS_A1_Corners_Aps(i) << endl;
    #endif
  }
//  exit(EXIT_FAILURE);
  #ifdef __DEBUG_MPREPARE__
    cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_CornerFileNames = " << CS_A1_CornerFileNames << endl;
    cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_CornerFileNames(0) = " << CS_A1_CornerFileNames(0) << endl;
  #endif
  int I_NInd = 0;

  Array<double, 1> *P_D_A1_DIndGen = F_Image.DIndGenArr(int(2048/20));
  Array<double, 1> D_A1_XInterp(P_D_A1_DIndGen->size());
  Array<double, 1> D_A1_YInterp(P_D_A1_DIndGen->size());
  D_A1_XInterp = (*P_D_A1_DIndGen) * 20. + 10.;
  D_A1_YInterp = D_A1_XInterp;
  delete(P_D_A1_DIndGen);
  Array<double, 2> D_A2_XYZ_Interp(D_A1_XInterp.size(), 3);
  D_A2_XYZ_Interp = 0.;
  Array<double, 1> D_A1_XGaussFit(D_A1_XInterp.size() * D_A1_YInterp.size());
  Array<double, 1> D_A1_YGaussFit(D_A1_XInterp.size() * D_A1_YInterp.size());
  Array<double, 1> D_A1_ZGaussFit(D_A1_XInterp.size() * D_A1_YInterp.size());
  Array<double, 1> D_A1_XGaussToFit(2);
  Array<double, 1> D_A1_YGaussToFit(2);
  Array<double, 1> D_A1_ZGaussToFit(2);
  for (int i=0; i<D_A1_YInterp.size(); i++){
    D_A1_YGaussFit(Range(i*D_A1_YInterp.size(), (i+1) * D_A1_YInterp.size() - 1)) = D_A1_YInterp;
    for (int j=0; j<D_A1_XInterp.size(); j++){
      D_A1_XGaussFit(i * D_A1_XInterp.size() + j) = D_A1_XInterp(i);
    }
  }
  #ifdef __DEBUG_MPREPARE__
    cout << "MPrepareCollapsedImageNoScatter::main: D_A1_XGaussFit = " << D_A1_XGaussFit << endl;
    cout << "MPrepareCollapsedImageNoScatter::main: D_A1_YGaussFit = " << D_A1_YGaussFit << endl;
  #endif
//  exit(EXIT_FAILURE);

  Array<double, 1> D_A1_Guess(5);
//  Array<int, 2> I_A1_Limited(5,2);
//  I_A1_Limited = 1;
  Array<double, 2> D_A2_Limits(5,2);
  D_A2_Limits = 0.;
  Array<double, 1> D_A1_Coeffs(5);
  Array<double, 1> D_A1_ECoeffs(5);

  for (int i_file=0; i_file<CS_A1_FileList_Out.size(); i_file++){
    Array<double, 2> D_A2_Collapsed_Spectra(2,2);
    if (!F_Image.ReadFileToDblArr(CS_A1_FileList_Out(i_file), D_A2_Collapsed_Spectra, CString(" "))){
      cout << "MPrepareCollapsedImageNoScatter::main: ERROR: F_Image.ReadFileToDblArr(CS_A1_FileList_Out(" << i_file << ")=" << CS_A1_FileList_Out(i_file) << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    Array<int, 1> I_A1_Ind(D_A2_Collapsed_Spectra.rows());
    I_A1_Ind = where(D_A2_Collapsed_Spectra(Range::all(), 3) > 1., 1, 0);
    Array<int, 1> *P_I_A1_Inds = F_Image.GetIndex(I_A1_Ind, I_NInd);
    if (I_NInd < 1){
      cout << "MPrepareCollapsedImageNoScatter::main: ERROR: I_NInd < 1" << endl;
      exit(EXIT_FAILURE);
    }
    Array<double, 2> D_A2_XYZ(I_NInd, 3);
    for (int i=0; i<I_NInd; i++){
      D_A2_XYZ(i, 0) = D_A2_Collapsed_Spectra((*P_I_A1_Inds)(i), 1);
      D_A2_XYZ(i, 1) = D_A2_Collapsed_Spectra((*P_I_A1_Inds)(i), 2);
//      cout << "MPrepareCollapsedImageNoScatter::main: D_A1_ApertureCenters_X(" << (*P_I_A1_Inds)(i) << ") = " << D_A1_ApertureCenters_X((*P_I_A1_Inds)(i)) << endl;
//      cout << "MPrepareCollapsedImageNoScatter::main: D_A2_Collapsed_Spectra(" << (*P_I_A1_Inds)(i) << ", 1) = " << D_A2_Collapsed_Spectra((*P_I_A1_Inds)(i), 1) << endl;
      D_A2_XYZ(i, 2) = D_A2_Collapsed_Spectra((*P_I_A1_Inds)(i), 3);
    }
//    exit(EXIT_FAILURE);
//    delete(P_I_A1_Inds);








    double D_SumMax = max(D_A2_XYZ(Range::all(), 2));
    int I_NNeighbours = 7;
    I_A1_Ind.resize(D_A2_XYZ.rows());
    I_A1_Ind = where(fabs(D_A2_XYZ(Range::all(), 2) - D_SumMax) < 1., 1, 0);
    Array<int, 1> *P_I_A1_Ind = F_Image.GetIndex(I_A1_Ind, I_NInd);
    Array<double, 1> D_A1_ReferencePoint(2);
    D_A1_ReferencePoint = D_A2_XYZ((*P_I_A1_Ind)(0), Range(0,1));
    Array<double, 2> D_A2_XY(D_A2_XYZ.rows(), 2);
    D_A2_XY = D_A2_XYZ(Range::all(), Range(0,1));
    Array<double, 2> D_A2_NearestNeighbours_Out(I_NNeighbours,2);
    Array<int, 1> I_A1_NearestNeighboursPos_Out(I_NNeighbours);
    cout << "MPrepareCollapsedImageNoScatter::main: D_A1_ReferencePoint = " << D_A1_ReferencePoint << endl;
    if (!F_Image.FindNearestNeighbours(D_A1_ReferencePoint,
                                       D_A2_XY,
                                       I_NNeighbours,
                                       D_A2_NearestNeighbours_Out,
                                       I_A1_NearestNeighboursPos_Out)){
      cout << "MPrepareCollapsedImageNoScatter::main: ERROR: FindNearestNeighbours returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MPrepareCollapsedImageNoScatter::main: D_A2_NearestNeighbours_Out = " << D_A2_NearestNeighbours_Out << endl;
    double D_Weight, D_SumWeights;
    Array<double, 1> D_A1_MaxPoint(2);
    D_A1_MaxPoint = 0.;
    D_SumWeights = 0.;
//    D_A1_ReferencePoint = D_A2_XYZ((*P_I_A1_Ind)(0), Range(0,1)) * D_A2_XYZ((*P_I_A1_Inds)(0), 2);
//    cout << "MPrepareCollapsedImageNoScatter::main: D_A1_ReferencePoint = " << D_A1_ReferencePoint << endl;
//    D_SumWeights = D_A2_XYZ((*P_I_A1_Ind)(0), 2);
//    cout << "MPrepareCollapsedImageNoScatter::main: D_SumWeights = " << D_SumWeights << endl;
    Array<double, 1> D_A1_MaxPointTemp(2);
//    D_A1_ReferencePointTemp = D_A1_ReferencePoint / D_SumWeights;
//    cout << "MPrepareCollapsedImageNoScatter::main: D_A1_ReferencePointTemp = " << D_A1_ReferencePointTemp << endl;
    for (int i_n=0; i_n<7; i_n++){
      D_Weight = D_A2_XYZ(I_A1_NearestNeighboursPos_Out(i_n), 2);
      D_A1_MaxPoint(0) += D_A2_XYZ(I_A1_NearestNeighboursPos_Out(i_n), 0) * D_Weight;
      D_A1_MaxPoint(1) += D_A2_XYZ(I_A1_NearestNeighboursPos_Out(i_n), 1) * D_Weight;
      D_SumWeights += D_Weight;
      D_A1_MaxPointTemp(0) = D_A1_MaxPoint(0) / D_SumWeights;
      D_A1_MaxPointTemp(1) = D_A1_MaxPoint(1) / D_SumWeights;
      cout << "MPrepareCollapsedImageNoScatter::main: i_n = " << i_n << ": D_A2_Collapsed_Spectra((*P_I_A1_Inds)(I_A1_NearestNeighboursPos_Out(i_n)=" << I_A1_NearestNeighboursPos_Out(i_n) << ") = " << (*P_I_A1_Inds)(I_A1_NearestNeighboursPos_Out(i_n)) << ", *) = " << D_A2_XY(I_A1_NearestNeighboursPos_Out(i_n), Range::all()) << endl;
      cout << "MPrepareCollapsedImageNoScatter::main: i_n = " << i_n << ": D_A2_XY(I_A1_NearestNeighboursPos_Out(i_n)=" << I_A1_NearestNeighboursPos_Out(i_n) << ", *) = " << D_A2_XY(I_A1_NearestNeighboursPos_Out(i_n), Range::all()) << endl;
      cout << "MPrepareCollapsedImageNoScatter::main: i_n = " << i_n << ": D_A2_XYZ(I_A1_NearestNeighboursPos_Out(i_n)=" << I_A1_NearestNeighboursPos_Out(i_n) << ", *) = " << D_A2_XYZ(I_A1_NearestNeighboursPos_Out(i_n), Range::all()) << endl;
      cout << "MPrepareCollapsedImageNoScatter::main: i_n = " << i_n << ": D_A1_MaxPoint = " << D_A1_MaxPoint << endl;
      cout << "MPrepareCollapsedImageNoScatter::main: i_n = " << i_n << ": D_Weight = " << D_Weight << endl;
      cout << "MPrepareCollapsedImageNoScatter::main: i_n = " << i_n << ": D_SumWeights = " << D_SumWeights << endl;
      cout << "MPrepareCollapsedImageNoScatter::main: i_n = " << i_n << ": D_A1_MaxPointTemp = " << D_A1_MaxPointTemp << endl;
    }
    D_A1_MaxPoint /= D_SumWeights;
    cout << "MPrepareCollapsedImageNoScatter::main: D_A1_MaxPoint = " << D_A1_MaxPoint << endl;
    delete(P_I_A1_Ind);

    double D_Mean = mean(D_A2_XYZ(Range::all(), 2));
    double D_Limit = 1. * D_Mean;
    cout << "MPrepareCollapsedImageNoScatter::main: D_Mean = " << D_Mean << endl;
    I_A1_Ind = where(D_A2_XYZ(Range::all(), 2) > D_Limit, 1, 0);
    cout << "MPrepareCollapsedImageNoScatter::main: I_A1_Ind = " << I_A1_Ind << endl;
    P_I_A1_Ind = F_Image.GetIndex(I_A1_Ind, I_NInd);
    Array<int, 1> I_A1_IndInd(P_I_A1_Ind->size());
    F_Image.GetSubArrCopy((*P_I_A1_Inds), (*P_I_A1_Ind), I_A1_IndInd);
    cout << "MPrepareCollapsedImageNoScatter:: I_A1_IndInd set to " << I_A1_IndInd << endl;
    Array<int, 1> I_A1_IndGood(I_A1_IndInd.size());
    I_A1_IndGood = 0;
    int I_NGood = 0;
    int I_NNeighboursGood = 0;
//    exit(EXIT_FAILURE);
    Array<int, 1> I_A1_IndNeighbours(I_NNeighbours);
    for (int i_l=0; i_l<I_NInd; i_l++){
      if (!F_Image.FindNearestNeighbours(D_A2_XYZ((*P_I_A1_Ind)(i_l), Range(0, 1)),
                                         D_A2_XY,
                                         I_NNeighbours,
                                         D_A2_NearestNeighbours_Out,
                                         I_A1_NearestNeighboursPos_Out)){
        cout << "MPrepareCollapsedImageNoScatter::main: ERROR: 2. FindNearestNeighbours returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      for (int i_n=1; i_n<I_NNeighbours; i_n++){
        if (I_A1_NearestNeighboursPos_Out(i_n) < 0 || I_A1_NearestNeighboursPos_Out(i_n) >= D_A2_XYZ.rows()){
          cout << "MPrepareCollapsedImageNoScatter::main: i_file=" << i_file << ": i_l=" << i_l << ": ERROR: I_A1_NearestNeighboursPos_Out(i_n=" << i_n << ") = " << I_A1_NearestNeighboursPos_Out(i_n) << " < 0 || I_A1_NearestNeighboursPos_Out(i_n) >= D_A2_XYZ.rows()=" << D_A2_XYZ.rows() << endl;
          cout << "MPrepareCollapsedImageNoScatter::main: I_A1_NearestNeighboursPos_Out = " << I_A1_NearestNeighboursPos_Out << endl;
          exit(EXIT_FAILURE);
        }
      }
      F_Image.GetSubArrCopy(*P_I_A1_Inds, I_A1_NearestNeighboursPos_Out, I_A1_IndNeighbours);
      cout << "MPrepareCollapsedImageNoScatter::main: D_A2_NearestNeighbours_Out = " << D_A2_NearestNeighbours_Out << endl;
      cout << "MPrepareCollapsedImageNoScatter::main: (*P_I_A1_Inds)(I_A1_NearestNeighboursPos_Out) = " << I_A1_IndNeighbours << endl;
      I_NNeighboursGood = 0;
      for (int i_n=1; i_n<I_NNeighbours; i_n++){
        if (D_A2_XYZ(I_A1_NearestNeighboursPos_Out(i_n), 2) > D_Limit){
          cout << "MPrepareCollapsedImageNoScatter::main: D_A2_XYZ(I_A1_NearestNeighboursPos_Out(i_n=" << i_n << ")=" << I_A1_NearestNeighboursPos_Out(i_n) << ", 2) = " << D_A2_XYZ(I_A1_NearestNeighboursPos_Out(i_n), 2) << " > D_Limit = " << D_Limit << endl;
          I_NNeighboursGood++;
          cout << "MPrepareCollapsedImageNoScatter::main: I_NNeighboursGood = " << I_NNeighboursGood << endl;
        }
        else{
          cout << "MPrepareCollapsedImageNoScatter::main: D_A2_XYZ(I_A1_NearestNeighboursPos_Out(i_n=" << i_n << ")=" << I_A1_NearestNeighboursPos_Out(i_n) << ", 2) = " << D_A2_XYZ(I_A1_NearestNeighboursPos_Out(i_n), 2) << " < D_Limit = " << D_Limit << endl;
        }
      }
      if (I_NNeighboursGood > 1){
        cout << "MPrepareCollapsedImageNoScatter::main: D_A2_XYZ(I_A1_IndInd(i_l=" << i_l << ") = " << (*P_I_A1_Ind)(i_l) << ", *) = " << D_A2_XYZ((*P_I_A1_Ind)(i_l), Range::all()) << ": I_NNeighboursGood = " << I_NNeighboursGood << endl;
        I_A1_IndGood(I_NGood) = (*P_I_A1_Ind)(i_l);
        cout << "MPrepareCollapsedImageNoScatter::main: I_A1_IndGood(I_NGood = " << I_NGood << ") = " << I_A1_IndGood(I_NGood) << endl;
        I_NGood++;
      }
    }
    Array<int, 1> I_A1_IndGoodFinal(I_NGood);
    I_A1_IndGoodFinal = I_A1_IndGood(Range(0, I_NGood-1));
    cout << "MPrepareCollapsedImageNoScatter::main: (*P_I_A1_Inds)(*P_I_A1_Ind) = " << I_A1_IndInd << endl;
    cout << "MPrepareCollapsedImageNoScatter::main: I_A1_IndGoodFinal = " << I_A1_IndGoodFinal << endl;
    double D_Dist, D_Dist_Max;
    D_Dist_Max = 0.;
    for (int i_n=0; i_n<I_NGood; i_n++){
      D_Dist = F_Image.Distance(D_A1_MaxPoint, D_A2_XYZ(I_A1_IndGoodFinal(i_n), Range(0,1)));
      cout << "MPrepareCollapsedImageNoScatter::main: i_n = " << i_n << ": (*P_I_A1_Inds)(I_A1_IndGoodFinal(i_n)) = " << (*P_I_A1_Inds)(I_A1_IndGoodFinal(i_n)) <<  ": D_Dist = " << D_Dist << endl;
      if (D_Dist > D_Dist_Max)
        D_Dist_Max = D_Dist;
    }
    cout << "MPrepareCollapsedImageNoScatter::main: D_Dist_Max = " << D_Dist_Max << endl;
    delete(P_I_A1_Inds);

    CString *P_CS_Num = CS_Comp.DToA(D_A1_MaxPoint(0), 1);
    CS_A2_FName_CenterX_CenterY_RadObj_RadSky(i_file, 1).Set(*P_CS_Num);
    delete(P_CS_Num);
    P_CS_Num = CS_Comp.DToA(D_A1_MaxPoint(1), 1);
    CS_A2_FName_CenterX_CenterY_RadObj_RadSky(i_file, 2).Set(*P_CS_Num);
    delete(P_CS_Num);
    P_CS_Num = CS_Comp.DToA(D_Dist_Max, 1);
    CS_A2_FName_CenterX_CenterY_RadObj_RadSky(i_file, 3).Set(*P_CS_Num);
    delete(P_CS_Num);
    P_CS_Num = CS_Comp.DToA(D_Dist_Max+100., 1);
    CS_A2_FName_CenterX_CenterY_RadObj_RadSky(i_file, 4).Set(*P_CS_Num);
    cout << "MPrepareCollapsedImageNoScatter::main: CS_A2_FName_CenterX_CenterY_RadObj_RadSky(i_file=" << i_file << ", *) set to " << CS_A2_FName_CenterX_CenterY_RadObj_RadSky(i_file, Range::all()) << endl;
//    exit(EXIT_FAILURE);







    Array<CString, 1> CS_A1_Collapsed_Spectra_Aps(D_A2_Collapsed_Spectra.rows());
    //cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_FileList_Out = " << CS_A1_FileList_Out << endl;
    for (int i=0; i<D_A2_Collapsed_Spectra.rows(); i++){
      P_CS_Temp = CS_Comp.IToA(int(D_A2_Collapsed_Spectra(i, 0)));
      CS_A1_Collapsed_Spectra_Aps(i) = *P_CS_Temp;
      delete(P_CS_Temp);
      cout << "MPrepareCollapsedImageNoScatter::main: D_A2_Collapsed_Spectra(" << i << ",0) = " << D_A2_Collapsed_Spectra(i,0) << ": CS_A1_Collapsed_Spectra_Aps(" << i << ") = " << CS_A1_Collapsed_Spectra_Aps(i) << endl;
      cout << "MPrepareCollapsedImageNoScatter::main: D_A2_Collapsed_Spectra(" << i << ",1) = " << D_A2_Collapsed_Spectra(i,1) << endl;
    }
    /*
    if (!F_Image.Rebin2D(D_A2_XYZ,///(NPoints, 3)
                         D_A1_XGaussFit,///(NPointsNew)
                         D_A1_YGaussFit,///(NPointsNew)
                         D_A2_XYZ_Interp,
                         3)){
      cout << "MPrepareCollapsedImageNoScatter::main: ERROR: Rebin2D returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    D_A1_ZGaussFit = D_A2_XYZ_Interp(Range::all(),2);
//    cout << "MPrepareCollapsedImageNoScatter::main: D_A1_ZGaussFit = " << D_A1_ZGaussFit << endl;
//    exit(EXIT_FAILURE);
    I_A1_Ind.resize(D_A1_XGaussFit.size());
    I_A1_Ind = where(fabs(D_A2_XYZ_Interp(Range::all(), 2) - max(D_A2_XYZ_Interp(Range::all(), 2))) < 1., 1, 0);
    P_I_A1_Inds = F_Image.GetIndex(I_A1_Ind, I_NInd);
    if (I_NInd < 0){
      cout << "MPrepareCollapsedImageNoScatter::main: ERROR: max: I_NInd = " << I_NInd << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MPrepareCollapsedImageNoScatter::main: max: *P_I_A1_Inds = " << *P_I_A1_Inds << endl;

    D_A2_Limits(0,1) = min(D_A2_XYZ_Interp(Range::all(), 2));
    D_A2_Limits(1,1) = D_A2_XYZ_Interp((*P_I_A1_Inds)(0), 2) - D_A2_Limits(0,1);
    D_A2_Limits(2,0) = D_A1_XGaussFit((*P_I_A1_Inds)(0)) - 40.;
    D_A2_Limits(2,1) = D_A1_XGaussFit((*P_I_A1_Inds)(0)) + 40.;
    D_A2_Limits(3,0) = D_A1_YGaussFit((*P_I_A1_Inds)(0)) - 40.;
    D_A2_Limits(3,1) = D_A1_YGaussFit((*P_I_A1_Inds)(0)) + 40.;
    D_A2_Limits(4,0) = 20.;
    D_A2_Limits(4,1) = 200.;

    D_A1_Guess(0) = F_Image.Median(D_A2_XYZ_Interp(Range::all(), 2));
    D_A1_Guess(1) = D_A2_XYZ_Interp((*P_I_A1_Inds)(0), 2);
    D_A1_Guess(2) = D_A1_XGaussFit((*P_I_A1_Inds)(0));
    D_A1_Guess(3) = D_A1_YGaussFit((*P_I_A1_Inds)(0));
    D_A1_Guess(4) = 70.;

    I_A1_Ind = where(sqrt(pow2(D_A1_XGaussFit - D_A1_Guess(2)) + pow2(D_A1_YGaussFit - D_A1_Guess(3))) < 3. * D_A1_Guess(4), 1, 0);
    delete(P_I_A1_Inds);
    P_I_A1_Inds = F_Image.GetIndex(I_A1_Ind, I_NInd);
    cout << "MPrepareCollapsedImageNoScatter::main: Gauss: *P_I_A1_Inds = " << *P_I_A1_Inds << endl;
    D_A1_XGaussToFit.resize(I_NInd);
    D_A1_YGaussToFit.resize(I_NInd);
    D_A1_ZGaussToFit.resize(I_NInd);
    int I_GaussPix = 0;
    for (int i_g=0; i_g<I_NInd; i_g++){
      D_A1_XGaussToFit(I_GaussPix) = D_A1_XGaussFit((*P_I_A1_Inds)(i_g));
      D_A1_YGaussToFit(I_GaussPix) = D_A1_YGaussFit((*P_I_A1_Inds)(i_g));
      D_A1_ZGaussToFit(I_GaussPix) = D_A1_ZGaussFit((*P_I_A1_Inds)(i_g));
    }
    delete(P_I_A1_Inds);

    cout << "MPrepareCollapsedImageNoScatter::main: Before Fit2DGaussianCB: D_A1_Guess = " << D_A1_Guess << endl;
    cout << "MPrepareCollapsedImageNoScatter::main: Before Fit2DGaussianCB: D_A2_Limits = " << D_A2_Limits << endl;
    if (!F_Image.Fit2DGaussianCB(D_A1_XGaussToFit,
                                 D_A1_YGaussToFit,
                                 D_A1_ZGaussToFit,
                                 D_A1_Guess,//(background, peak, mean_x, mean_y, sigma)
                                 D_A2_Limits,//(background, peak, mean_x, mean_y, sigma)
                                 D_A1_Coeffs)){
      cout << "MPrepareCollapsedImageNoScatter::main: ERROR: Fit2DGaussianCB returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MPrepareCollapsedImageNoScatter::main: After Fit2DGaussianCB: D_A1_Coeffs = " << D_A1_Coeffs << endl;
    exit(EXIT_FAILURE);




    //    size_col = size(dblarr_collapsed_spectra)
//    print,'size = ',size_col
//    cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_FileList_Out.size() = " << CS_A1_FileList_Out.size() << endl;
//    cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_Collapsed_Spectra_Aps = " << CS_A1_Collapsed_Spectra_Aps << endl;
//    exit(EXIT_FAILURE);

//    for (int i=0; i<D_A1_ApertureCenters_X.size(); i++){
//      if ((D_A1_ApertureCenters_X(i) > 600.) && (D_A1_ApertureCenters_X(i) < 700.)){
//        if ((D_A1_ApertureCenters_Y(i) > 500.) && (D_A1_ApertureCenters_Y(i) < 600.)){
//          cout << "MPrepareCollapsedImageNoScatter::main: problematic aperture: " << i << endl;
//        }
//      }
//    }
*/













    P_CS_Temp = CS_A1_FileList_Out(i_file).SubString(0,CS_A1_FileList_Out(i_file).LastCharPos('.'));
    CString CS_PlotName(*P_CS_Temp);
    delete(P_CS_Temp);
    CS_PlotName.Add(CString("png"));

    cout << "MPrepareCollapsedImageNoScatter::main: D_A2_Collapsed_Spectra = " << D_A2_Collapsed_Spectra << endl;
    cout << "MPrepareCollapsedImageNoScatter::main: D_A2_Collapsed_Spectra(*,3) = " << D_A2_Collapsed_Spectra(Range::all(),3) << endl;
    double D_Max = max(D_A2_Collapsed_Spectra(Range::all(),3));
    cout << "MPrepareCollapsedImageNoScatter::main: D_Max = " << D_Max << endl;
    double D_Median = F_Image.Median(D_A2_Collapsed_Spectra(Range::all(),3));
    cout << "MPrepareCollapsedImageNoScatter::main: D_Median = " << D_Median << endl;
    Array<int, 1> I_A1_IndArr(D_A2_Collapsed_Spectra.rows());
    I_A1_IndArr = where(D_A2_Collapsed_Spectra(Range::all(), 3) < D_Median, 1, 0);
    cout << "MPrepareCollapsedImageNoScatter::main: I_A1_IndArr = " << I_A1_IndArr << endl;
    P_I_A1_Ind = F_Image.GetIndex(I_A1_IndArr, I_NInd);
    if (I_NInd > 0){
      for (int i=0; i<P_I_A1_Ind->size(); i++){
        if (((*P_I_A1_Ind)(i) < 0) || ((*P_I_A1_Ind)(i) >= D_A2_Collapsed_Spectra.rows())){
          cout << "MPrepareCollapsedImageNoScatter::main: ERROR: ((*P_I_A1_Ind)(i=" << i << ") = " << (*P_I_A1_Ind)(i) << " < 0) || ((*P_I_A1_Ind)(i) >= D_A2_Collapsed_Spectra.rows()=" << D_A2_Collapsed_Spectra.rows() << ")" << endl;
          exit(EXIT_FAILURE);
        }
        D_A2_Collapsed_Spectra((*P_I_A1_Ind)(i),3) = D_Median;
      }
    }
    delete(P_I_A1_Ind);
    cout << "MPrepareCollapsedImageNoScatter::main: D_A2_Collapsed_Spectra(*,3) = " << D_A2_Collapsed_Spectra(Range::all(),3) << endl;

    double D_Min = min(D_A2_Collapsed_Spectra(Range::all(),3));
    cout << "MPrepareCollapsedImageNoScatter::main: D_Min = " << D_Min << endl;
    I_A1_IndArr = where(fabs(D_A2_Collapsed_Spectra(Range::all(), 3) - D_Max) < 10000., 1, 0);
    P_I_A1_Ind = F_Image.GetIndex(I_A1_IndArr, I_NInd);
    cout << "MPrepareCollapsedImageNoScatter::main: D_A2_Collapsed_Spectra((*P_I_A1_Ind)(0)=" << (*P_I_A1_Ind)(0) << ", *) = " << D_A2_Collapsed_Spectra((*P_I_A1_Ind)(0), Range::all()) << endl;
//    exit(EXIT_FAILURE);
    *P_OFS_HtmlFile << "<img src=\"" << CS_PlotName << "\"><br>" << CS_PlotName << "<br><hr>" << endl;

    mglGraph gr;
    mglData MGLData1_CentersX, MGLData1_CentersY;
    MGLData1_CentersX.Link(D_A1_ApertureCenters_X.data(), D_A1_ApertureCenters_X.size(), 0, 0);
    MGLData1_CentersY.Link(D_A1_ApertureCenters_Y.data(), D_A1_ApertureCenters_Y.size(), 0, 0);

    gr.SetSize(1900,1900);
    gr.SetRanges(0,2048,0,2048);
    gr.Axis();
    gr.Label('y',"Row Number",0);
    gr.Label('x',"Column Number",0);
    gr.Plot(MGLData1_CentersX, MGLData1_CentersY, "bo ");

//      plot,dblarr_centers(*,0),dblarr_centers(*,1),psym=2,symsize=0.1
//      oplot,[dblarr_centers(1016, 0), dblarr_centers(1016, 0)], [dblarr_centers(1016,1),dblarr_centers(1016,1)],psym=2, symsize=0.5
    for (int i=0; i<CS_A1_CornerFileNames.size(); i++){
//      P_CS_Temp =
      CString CS_iFile(CS_A1_CornerFileNames(i));
      cout << "MPrepareCollapsedImageNoScatter::main: CS_iFile = <" << CS_iFile << ">" << endl;
      Array<double, 2> D_A2_Corners(6,2);
      if (!F_Image.ReadFileToDblArr(CS_iFile, D_A2_Corners, CString(" "))){
        cout << "MPrepareCollapsedImageNoScatter::main: ERROR: ReadFileToDblArr(" << CS_iFile << ") returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      double D_Length = 0.;
      double D_MaxLength = 0.;
      Array<double, 1> D_A1_X(2);
      Array<double, 1> D_A1_Y(2);
      for (int j=0; j<D_A2_Corners.rows()-1; j++){
        D_Length = sqrt(pow2(D_A2_Corners(j+1,0) - D_A2_Corners(j,0)) + pow2(D_A2_Corners(j+1,1) - D_A2_Corners(j,1)));
        if (D_Length > D_MaxLength)
          D_MaxLength = D_Length;
        if (D_Length < 100.){
          D_A1_X(0) = D_A2_Corners(j,0);
          D_A1_X(1) = D_A2_Corners(j+1,0);
          D_A1_Y(0) = D_A2_Corners(j,1);
          D_A1_Y(1) = D_A2_Corners(j+1,1);
          mglData MGLData1_X, MGLData1_Y;
          MGLData1_X.Link(D_A1_X.data(), D_A1_X.size(), 0, 0);
          MGLData1_Y.Link(D_A1_Y.data(), D_A1_Y.size(), 0, 0);
          gr.Plot(MGLData1_X, MGLData1_Y, "b");
        }
      }
      D_Length = sqrt(pow2(D_A2_Corners(5,0) - D_A2_Corners(0,0)) + pow2(D_A2_Corners(5,1) - D_A2_Corners(0,1)));
      if (D_Length > D_MaxLength)
        D_MaxLength = D_Length;
      cout << "MPrepareCollapsedImage::main: D_MaxLength = " << D_MaxLength << endl;
      if (D_Length < 100){
        D_A1_X(0) = D_A2_Corners(5,0);
        if (D_A1_X(0) < 0.){
          cout << "MPrepareCollapsedImageNoScatter::main: ERROR: D_A1_X(0)=" << D_A1_X(0) << " < 0." << endl;
          exit(EXIT_FAILURE);
        }
        D_A1_X(1) = D_A2_Corners(0,0);
        if (D_A1_X(1) < 0.){
          cout << "MPrepareCollapsedImageNoScatter::main: ERROR: D_A1_X(1)=" << D_A1_X(1) << " < 0." << endl;
          exit(EXIT_FAILURE);
        }
        D_A1_Y(0) = D_A2_Corners(5,1);
        if (D_A1_Y(0) < 0.){
          cout << "MPrepareCollapsedImageNoScatter::main: ERROR: D_A1_Y(0)=" << D_A1_Y(0) << " < 0." << endl;
          exit(EXIT_FAILURE);
        }
        D_A1_Y(1) = D_A2_Corners(0,1);
        if (D_A1_Y(1) < 0.){
          cout << "MPrepareCollapsedImageNoScatter::main: ERROR: D_A1_Y(1)=" << D_A1_Y(1) << " < 0." << endl;
          exit(EXIT_FAILURE);
        }
        mglData MGLData1_X, MGLData1_Y;
        MGLData1_X.Link(D_A1_X.data(), D_A1_X.size(), 0, 0);
        MGLData1_Y.Link(D_A1_Y.data(), D_A1_Y.size(), 0, 0);
        gr.Plot(MGLData1_X, MGLData1_Y, "b");
      }
      Array<int, 1> I_A1_IndCollapsed(CS_A1_Collapsed_Spectra_Aps.size());
      I_A1_IndCollapsed = 0;
//      cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_Collapsed_Spectra_Aps = " << CS_A1_Collapsed_Spectra_Aps << endl;
//      cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_Corners_Aps(" << i << ") = " << CS_A1_Corners_Aps(i) << endl;
      for (int j=0; j<CS_A1_Collapsed_Spectra_Aps.size(); j++){
        if (CS_A1_Collapsed_Spectra_Aps(j).EqualValue(CS_A1_Corners_Aps(i))){
          I_A1_IndCollapsed(j) = 1;
//          cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_Collapsed_Spectra_Aps(" << j << ") = " << CS_A1_Collapsed_Spectra_Aps(j) << " == " << CS_A1_Corners_Aps(i) << endl;
        }
      }
//      exit(EXIT_FAILURE);
      P_I_A1_Ind = F_Image.GetIndex(I_A1_IndCollapsed, I_NInd);
      double D_Colour = 0;
      cout << "MPrepareCollapsedImage::main: *P_I_A1_Ind = " << *P_I_A1_Ind << endl;
      cout << "MPrepareCollapsedImage::main: I_NInd = " << I_NInd << endl;
      if ((I_NInd == 1) && ((*P_I_A1_Ind)(0) >= 0)){
        cout << "MPrepareCollapsedImageNoScatter::main: D_Min = " << D_Min << ", D_Max = " << D_Max << ": D_A2_Collapsed_Spectra((*P_I_A1_Ind)(0),3) = " << D_A2_Collapsed_Spectra((*P_I_A1_Ind)(0),3) << endl;
        D_Colour = 255 * (D_A2_Collapsed_Spectra((*P_I_A1_Ind)(0),3) - D_Min) / (D_Max - D_Min);
//        cout << "MPrepareCollapsedImageNoScatter::main: D_A2_Collapsed_Spectra((*P_I_A1_Ind)(0)=" << (*P_I_A1_Ind)(0) << ",3) = " << D_A2_Collapsed_Spectra((*P_I_A1_Ind)(0),3) << endl;
        cout << "MPrepareCollapsedImageNoScatter::main: D_Colour=" << D_Colour << endl;
//        cout << "MPrepareCollapsedImageNoScatter::main: i = " << i << ": D_A2_Corners = " << D_A2_Corners << endl;
//        cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_Corners_Aps(i) = " << CS_A1_Corners_Aps(i) << endl;
//        cout << "MPrepareCollapsedImageNoScatter::main: CS_A1_Collapsed_Spectra_Aps((*P_I_A1_Ind)(0)=" << (*P_I_A1_Ind)(0) << ") = " << CS_A1_Collapsed_Spectra_Aps((*P_I_A1_Ind)(0)) << endl;
        CString CS_Colour("{x");
//        D_Colour = 255.;
        CString CS_Temp(to_string<long>(long(D_Colour), hex));
        if (CS_Temp.GetLength() == 1)
          CS_Colour.Add(CString("0"));
        CS_Colour.Add(CS_Temp);
        if (CS_Temp.GetLength() == 1)
          CS_Colour.Add(CString("0"));
        CS_Colour.Add(CS_Temp);
        if (CS_Temp.GetLength() == 1)
          CS_Colour.Add(CString("0"));
        CS_Colour.Add(CS_Temp);
        CS_Colour.Add(CString("}"));
        cout << "MPrepareCollapsedImageNoScatter::main: i=" << i << ": CS_Colour = <" << CS_Colour << ">" << endl;
//        if (D_Colour > 100)
//          exit(EXIT_FAILURE);
          //        exit(EXIT_FAILURE);
        if (D_MaxLength < 100){
          for (int k=1; k<5; k++){
            //cout << "MPrepareCollapsedImageNoScatter::main: i_file=" << i_file << ": i=" << i << ": k=" << k << ": Plotting Face(" << D_A2_Corners(0,0) << ")" << endl;
//            mglColor.Set(D_Colour, D_Colour, D_Colour, 1);
            gr.Face(mglPoint(D_A2_Corners(0,0), D_A2_Corners(0,1)),
                    mglPoint(D_A2_Corners(0,0), D_A2_Corners(0,1)),
                    mglPoint(D_A2_Corners(k,0), D_A2_Corners(k,1)),
                    mglPoint(D_A2_Corners(k+1,0), D_A2_Corners(k+1,1)),CS_Colour.Get());
          }
//          polyfill,dblarr_corners(*,0),dblarr_corners(*,1),color=color
        }
        else{
          cout << "MPrepareCollapsedImageNoScatter::main: aperture " << CS_A1_Corners_Aps(i) << " not found in CS_A1_Collapsed_Spectra_Aps" << endl;
        }
//        oplot,[dblarr_centers(1016, 0), dblarr_centers(1016, 0)], [dblarr_centers(1016,1),dblarr_centers(1016,1)],psym=2, symsize=0.5,color=80
//        if strarr_corners_aps(i) eq '150' then begin
//          oplot,[dblarr_centers(1016, 0), dblarr_centers(1016, 0)], [dblarr_centers(1016,1),dblarr_centers(1016,1)],psym=2, symsize=0.5,color=80
//;          stop
//        endif
      }
      delete(P_I_A1_Ind);
    }

    CString CS_Print("o");
    /// plot object center
//    mglData MGLData1_CenterX, MGLData1_CenterY;
//    Array<double, 1> D_A1_ObsCenter_X(2);
//    D_A1_ObsCenter_X = D_A1_MaxPoint(0);
//    cout << "MPrepareCollapsedImageNoScatter::main: D_A1_ObsCenter_X = " << D_A1_ObsCenter_X << endl;
//    Array<double, 1> D_A1_ObsCenter_Y(2);
//    D_A1_ObsCenter_Y = D_A1_MaxPoint(1);
//    cout << "MPrepareCollapsedImageNoScatter::main: D_A1_ObsCenter_Y = " << D_A1_ObsCenter_Y << endl;
//    MGLData1_CenterX.Link(D_A1_ObsCenter_X.data(), D_A1_ObsCenter_X.size(), 0, 0);
//    MGLData1_CenterY.Link(D_A1_ObsCenter_Y.data(), D_A1_ObsCenter_Y.size(), 0, 0);
//    gr.Plot(MGLData1_CenterX, MGLData1_CenterY, "bo ");
    gr.Puts(mglPoint(D_A1_MaxPoint(0), D_A1_MaxPoint(1)),CS_Print.Get(),"b",-0.2);

    /// plot circle for object
    double phi;
    int I_NPt = 1000;
    mglData x(I_NPt), y(I_NPt);
    for (int i_p=0; i_p<I_NPt; i_p++){
      phi = 2. * D_PI * i_p / I_NPt;
      x.a[i_p] = D_Dist_Max * cos(phi) + D_A1_MaxPoint(0);
      y.a[i_p] = D_Dist_Max * sin(phi) + D_A1_MaxPoint(1);
      gr.Puts(mglPoint(x.a[i_p],y.a[i_p]),CS_Print.Get(),"Y",-0.2);
    }
    for (int i_p=0; i_p<I_NPt; i_p++){
      phi = 2. * D_PI * i_p / I_NPt;
      x.a[i_p] = (D_Dist_Max + 100.) * cos(phi) + D_A1_MaxPoint(0);
      y.a[i_p] = (D_Dist_Max + 100.) * sin(phi) + D_A1_MaxPoint(1);
      gr.Puts(mglPoint(x.a[i_p],y.a[i_p]),CS_Print.Get(),"r",-0.2);
    }
//    gr.Plot(x,y,"r");


    cout << "MPrepareCollapsedImageNoScatter::main: Printing Lenslet Numbers" << endl;
    for (int i=0; i<CS_A1_Corners_Aps.size(); i++){
      P_CS_Temp = CS_PlotName.IToA(i);
      CString CS_Puts("#r");
      CS_Puts.Add(*P_CS_Temp);
      delete(P_CS_Temp);
      gr.Puts(mglPoint(D_A2_ApertureCenters(i,0)+2,D_A2_ApertureCenters(i,1)+2),CS_Puts.Get(),"r",-0.2);//,charsize=0.3,color=100
    }



    cout << "MPrepareCollapsedImageNoScatter::main: Writing image" << endl;
    gr.Box();
    gr.WriteFrame(CS_PlotName.Get());
  }
  (*P_OFS_HtmlFile) << "</center></body></html>" << endl;

  if (!CS_Comp.WriteStrListToFile(CS_A2_FName_CenterX_CenterY_RadObj_RadSky, CString(" "), CString("fname_centerX_centerY_radO_radS.dat"))){
    cout << "MPrepareCollapsedImageNoScatter::main: ERROR: WriteStrListToFile(CS_A2_FName_CenterX_CenterY_RadObj_RadSky=" << CS_A2_FName_CenterX_CenterY_RadObj_RadSky << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }





  return EXIT_SUCCESS;
}

