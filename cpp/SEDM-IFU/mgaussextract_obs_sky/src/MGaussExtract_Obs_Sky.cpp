/*
author: Andreas Ritter
created: 04/12/2007
last edited: 05/05/2007
compiler: g++ 4.0
basis machine: Ubuntu Linux 6.06
*/

///TODO: Calculate Uncertainties of extracted spectra
///TODO: check if a band is an absorption line. if not -> don't apply calculated PIX_SHIFTS
///TODO: include correction for airmass (atmospheric extinction)

#include "MGaussExtract_Obs_Sky.h"

using namespace std;

int main(int argc, char *argv[])
{
  cout << "MGaussExtract_Obs_Sky::main: argc = " << argc << endl;
  if (argc < 16)
  {
    cout << "MGaussExtract_Obs_Sky::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: optextract <char[] @FitsFileName_XC_YC_RO_RS_In> <char[] (@)DatabaseFileName_In> <char[] CS_A1_TextFiles_Coeffs_In> <double Gain> <double ReadOutNoise>  <int B_WithBackground[0,1]> <[double(min_sdev),double(max_sdev)]> <[double(max_mean_offset_left_of_aperture_trace),double(max_mean_offset_right_of_aperture_trace)]><double D_MaxRMS_In> <double D_WLen_Start> <double D_WLen_End> <double D_DWLen> <double TelescopeSurface> <int I_PixABandExpected> <char[] @ExposureTimes_In> [MAX_ITER_SIG=int] [ERR_IN=char[](@)] [AREA=[int(xmin),int(xmax),int(ymin),int(ymax)]] [APERTURES=char[](@)] [AP_DEF_IMAGE=char[](ApertureDefinitionImage)] [PIX_SHIFTS_IN=char[](PixelShiftsListFile_In)] [PIX_SHIFTS_OUT=char[](PixelShiftsListFile_Out)] [AIRMASSES_IN=char[](AirMassFile_In)] [ATMOS_EXTINCTION_IN=char[](AtmosphericExtinctionFile_In)] [THROUGHPUTS_IN=char[](ThroughputsFromStandardStars_In)] [THROUGHPUTS_JD_IN=char[](JulianDatesOfThroughputMeasurements_In)] [JULIAN_DATES_IN=char[](JulianDates_In)]" << endl;//"[, ERR_FROM_PROFILE_OUT=char[]])" << endl;
    // [ERR_OUT_2D=char[]] [ERR_OUT_EC=char[](@)] [SKY_OUT_EC=char[](@)] [SKY_OUT_2D=char[]] [SKY_ERR_OUT_EC=char[](@)] [PROFILE_OUT=char[](@)] [REC_FIT_OUT=char[](@)] [MASK_OUT=char[](@)]
    cout << "FitsFileName_XC_YC_RO_RS_In: <image to extract> <int XCenter> <int YCenter> <int Radius_Obs> <int Radius_Sky>" << endl;
    cout << "DatabaseFileName_In: aperture-definition file to use for extraction - either one file for all exposures or a list" << endl;
    cout << "CS_A1_TextFiles_Coeffs_In: filename containing list of coefficient files for dispersion correction" << endl;
    cout << "Gain: CCD gain (electrons per ADU)" << endl;
    cout << "ReadOutNoise: CCD readout noise" << endl;
    cout << "B_WithBackground: 0: without background in GaussFit, 1: with constant background in GaussFit" << endl;
    cout << "[double(min_sdev), double(max_sdev)]: Limits for the standard deviation of the GaussFit" << endl;
    cout << "[double(max_mean_offset_left_of_aperture_trace), double(max_mean_offset_right_of_aperture_trace)]: Limits for the offset of the center of the GaussFit compared to the trace" << endl;
    cout << "D_MaxRMS_In: Maximum RMS for dispersion correction" << endl;
    cout << "D_WLen_Start: Starting wavelength for re-binning" << endl;
    cout << "D_WLen_End: Ending wavelength for re-binning" << endl;
    cout << "D_DWLen: wavelength step for re-binning" << endl;
    cout << "TelescopeSurface: effective telescope surface for flux calculation" << endl;
    cout << "I_PixABandExpected: Pixel number where to expect to find the minimum of the A-Band" << endl;
    cout << "ExposureTimes_In: data file containing the exposure times for each image in @FitsFileName_In" << endl;
    cout << "MAX_ITER_SIG: maximum number of iterations rejecting cosmic-ray hits" << endl;
    cout << "ERR_IN: input image containing the uncertainties in the pixel values of FitsFileName_In" << endl;
//    cout << "ERR_OUT_2D: output uncertainty image - same as ERR_IN, but with detected cosmic-ray hits set to 10,000" << endl;
//    cout << "ERR_OUT_EC: output file containing the uncertainties in the extracted spectra's pixel values" << endl;
//    cout << "SKY_OUT_EC: output sky-only spectra (TELLURIC > 0 only)" << endl;
//    cout << "SKY_OUT_2D: reconstructed sky-only image" << endl;
//    cout << "SKY_ERR_OUT_EC: uncertainties in the calculated sky-only values" << endl;
//    cout << "PROFILE_OUT: reconstructed image of the spatial profiles" << endl;
//    cout << "REC_FIT_OUT: reconstructed input image for SPFIT_OUT_EC" << endl;
//    cout << "MASK_OUT: output mask with detected cosmic-ray hits set to 0, good pixels set to 1" << endl;
    cout << "AREA: Area from which to extract spectra if center of aperture is in specified area" << endl;
    cout << "APERTURES: input filename containing a list of apertures to extract" << endl;
    cout << "AP_DEF_IMAGE: image used for tracing the spectra, now used to find the aperture offset in x" << endl;
    cout << "I_MAX_OFFSET: maximum aperture offset in x for cross-correlation (AP_DEF_IMAGE must be set, too)" << endl;
    cout << "PIX_SHIFTS_IN: file containing double values for pixel shifts to apply to the object spectra when calibrating for the wavelength (<0: shift object spectra down, >0: shift object spectra up, 'c' to calculate)" << endl;
    cout << "PIX_SHIFTS_OUT: file containing double values for pixel shifts applied to the object spectra when calibrating for the wavelength (<0: shift object spectra down, >0: shift object spectra up)" << endl;
    cout << "AIRMASSES_IN: file containing the airmass for each file in FitsFileName_XC_YC_RO_RS_In" << endl;
    cout << "ATMOS_EXTINCTION_IN: file containing the atmospheric extinction table" << endl;
    cout << "THROUGHPUTS_IN: file containing list of Throughputs From Standard Stars" << endl;
    cout << "THROUGHPUTS_JD_IN: JulianDatesOfThroughputMeasurements_In" << endl;
    cout << "JULIAN_DATES_IN: Julian dates of object observations" << endl;
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
  CString *P_CS_ErrOut = new CString(" ");
  CString *P_CS_ErrOutEc = new CString(" ");
  CString *P_CS_SkyOut = new CString(" ");
  CString *P_CS_SkyArrOut = new CString(" ");
  CString *P_CS_SkyErrOut = new CString(" ");
  CString *P_CS_ImOut = new CString(" ");
  CString *P_CS_RecFitOut = new CString(" ");
  CString *P_CS_ProfileOut = new CString(" ");
  CString *P_CS_MaskOut = new CString(" ");
  CString *P_CS_SPFitOut = new CString(" ");
  CString *P_CS_EcFromProfileOut = new CString(" ");
  CString *P_CS_ErrFromProfileOut = new CString(" ");
  CString *P_CS_ApertureListIn = new CString(" ");
  CString *P_CS_ApDefImage_In = new CString(" ");

  int I_SwathWidth = 0;
  int I_MaxIterSF = 8;
  int I_MaxIterSky = 12;
  int I_MaxIterSig = 2;
  int I_SmoothSP = 1;
  int I_MaxOffset = 5;
  int I_FluxCalib_PolyFitDegree = 13;
  double D_SmoothSF = 1.;
  double D_WingSmoothFactor = 1.;
  char *P_CharArr_In = (char*)argv[1];
  char *P_CharArr_DB = (char*)argv[2];
  char *P_CharArr_Coeffs = (char*)argv[3];
//  char *P_CharArr_Out = (char*)argv[4];
  double D_Gain = (double)(atof((char*)argv[4]));
  cout << "MGaussExtract_Obs_Sky::main: D_Gain set to " << D_Gain << endl;
  double D_ReadOutNoise = (double)(atof((char*)argv[5]));
  cout << "MGaussExtract_Obs_Sky::main: D_ReadOutNoise set to " << D_ReadOutNoise << endl;
  CString CS_WithBackground((char*)(argv[6]));
  int I_WithBackground = 0.;
  if (!CS_WithBackground.AToI(I_WithBackground)){
    cout << "MExtractMPFitThreeGauss::main: ERROR: CS_WithBackground(=" << CS_WithBackground << ").AToI(I_WithBackground) returning FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  bool B_XCor_2D = true;
  bool B_WithBackground = false;
  if (I_WithBackground == 1)
    B_WithBackground = true;
  CString CS_SDevLimits((char*)(argv[7]));
  CString CS_MeanLimits((char*)(argv[8]));
  Array<double, 1> D_A1_SDevLimits(2);
  Array<double, 1> D_A1_MeanLimits(2);
  CString *P_CS_Temp = CS_SDevLimits.SubString(1,CS_SDevLimits.CharPos(',')-1);
  double D_Temp = 0.;
  if (!P_CS_Temp->AToD(D_Temp)){
    cout << "MExtractMPFitThreeGauss::main: ERROR: P_CS_Temp(=" << *P_CS_Temp << ")->AToD(D_Temp) returnedFALSE" << endl;
    exit(EXIT_FAILURE);
  }
  D_A1_SDevLimits(0) = D_Temp;
  delete(P_CS_Temp);
  P_CS_Temp = CS_SDevLimits.SubString(CS_SDevLimits.CharPos(',')+1,CS_SDevLimits.GetLength()-2);
  if (!P_CS_Temp->AToD(D_Temp)){
    cout << "MExtractMPFitThreeGauss::main: ERROR: P_CS_Temp(=" << *P_CS_Temp << ")->AToD(D_Temp) returnedFALSE" << endl;
    exit(EXIT_FAILURE);
  }
  D_A1_SDevLimits(1) = D_Temp;
  delete(P_CS_Temp);
  cout << "MExtractMPFitThreeGauss::main: D_A1_SDevLimits set to " << D_A1_SDevLimits << endl;

  P_CS_Temp = CS_MeanLimits.SubString(1,CS_MeanLimits.CharPos(',')-1);
  cout << "MGaussExtract_Obs_Sky::main: *P_CS_Temp = <" << *P_CS_Temp << ">" << endl;
  if (!P_CS_Temp->AToD(D_Temp)){
    cout << "MExtractMPFitThreeGauss::main: ERROR: P_CS_Temp(=" << *P_CS_Temp << ")->AToD(D_Temp) returnedFALSE" << endl;
    exit(EXIT_FAILURE);
  }
  D_A1_MeanLimits(0) = D_Temp;
  delete(P_CS_Temp);
  P_CS_Temp = CS_MeanLimits.SubString(CS_MeanLimits.CharPos(',')+1,CS_MeanLimits.GetLength()-2);
  cout << "MGaussExtract_Obs_Sky::main: *P_CS_Temp = <" << *P_CS_Temp << ">" << endl;
  if (!P_CS_Temp->AToD(D_Temp)){
    cout << "MExtractMPFitThreeGauss::main: ERROR: P_CS_Temp(=" << *P_CS_Temp << ")->AToD(D_Temp) returnedFALSE" << endl;
    exit(EXIT_FAILURE);
  }
  D_A1_MeanLimits(1) = D_Temp;
  delete(P_CS_Temp);
  cout << "MExtractMPFitThreeGauss::main: D_A1_MeanLimits set to " << D_A1_MeanLimits << endl;
  double D_MaxRMS_In = (double)(atof((char*)argv[9]));
  cout << "MGaussExtract_Obs_Sky::main: D_MaxRMS_In set to " << D_MaxRMS_In << endl;
  double D_WLen_Start = (double)(atof((char*)argv[10]));
  cout << "MGaussExtract_Obs_Sky::main: D_WLen_Start set to " << D_WLen_Start << endl;
  double D_WLen_End = (double)(atof((char*)argv[11]));
  cout << "MGaussExtract_Obs_Sky::main: D_WLen_End set to " << D_WLen_End << endl;
  double D_DWLen = (double)(atof((char*)argv[12]));
  cout << "MGaussExtract_Obs_Sky::main: D_DWLen set to " << D_DWLen << endl;
  double D_ATel = (double)(atof((char*)argv[13]));
  cout << "MGaussExtract_Obs_Sky::main: D_ATel set to " << D_ATel << endl;
  int I_PixABandExpected = (int)(atoi((char*)argv[14]));
  cout << "MGaussExtract_Obs_Sky::main: I_PixABandExpected set to " << I_PixABandExpected << endl;
  char *P_CharArr_ExpTimes_In = (char*)argv[15];
  int I_Telluric=0;
  int I_XCorProf = 0;
  Array<int, 1> *P_I_A1_Apertures = new Array<int, 1>(1);
  (*P_I_A1_Apertures) = 0;
  bool B_AperturesSet = false;
  Array<CString, 1> CS_A1_TextFiles_Coeffs_In(1);
  CString CS_PixShiftsList_In(" ");
  CString CS_PixShiftsList_Out(" ");
  CString CS_AirMassList_In(" ");
  CString CS_AtmosphericExtinction_In(" ");
  Array<double, 1> D_A1_PixShifts(1);
  Array<double, 1> D_A1_AirMasses(1);
  Array<double, 2> D_A2_AtmosphericExtinction(2,2);
  CString CS_ThroughputsList_In(" ");
  CString CS_ThroughputsJDList_In(" ");
  CString CS_JulianDates_In(" ");
  
  /// read optional parameters
  for (int i = 16; i <= argc; i++){
    CS.Set((char*)argv[i]);
    cout << "MGaussExtract_Obs_Sky: Reading Parameter " << CS << endl;

    CS_comp.Set("MAX_ITER_SIG");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        I_MaxIterSig = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky::main: I_MaxIterSig set to " << I_MaxIterSig << endl;
      }
    }

    /// AREA
    CS_comp.Set("AREA");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        CString cs_temp;
        cs_temp.Set(",");
        int i_pos_a = CS_comp.GetLength()+2;
        int i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        cout << "MGaussExtract_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MGaussExtract_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(0) = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky: I_A1_Area(0) set to " << I_A1_Area(0) << endl;

        i_pos_a = i_pos_b+1;
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        cout << "MGaussExtract_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MGaussExtract_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(1) = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky: I_A1_Area(1) set to " << I_A1_Area(1) << endl;

        i_pos_a = i_pos_b+1;
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        cout << "MGaussExtract_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MGaussExtract_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(2) = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky: I_A1_Area(2) set to " << I_A1_Area(2) << endl;

        i_pos_a = i_pos_b+1;
        cs_temp.Set("]");
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        if (i_pos_b < 0){
          cs_temp.Set(")");
          i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        }
        cout << "MGaussExtract_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MGaussExtract_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(3) = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky: I_A1_Area(3) set to " << I_A1_Area(3) << endl;

        CS_A1_Args(2) = CString("AREA");
        PP_Args[2] = &I_A1_Area;
        cout << "MGaussExtract_Obs_Sky::main: I_A1_Area set to " << I_A1_Area << endl;
      }
    }

    CS_comp.Set("AP_DEF_IMAGE");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_ApDefImage_In);
        P_CS_ApDefImage_In = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: ApDefImage_In set to " << *P_CS_ApDefImage_In << endl;
      }
    }

    CS_comp.Set("I_MAX_OFFSET");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        I_MaxOffset = P_CS->AToI();
        cout << "MGaussExtract_Obs_Sky::main: I_MaxOffset set to " << I_MaxOffset << endl;
      }
    }
    
    CS_comp.Set("PIX_SHIFTS_IN");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        CS_PixShiftsList_In.Set(*P_CS);
        cout << "MGaussExtract_Obs_Sky::main: CS_PixShiftsList_In to " << CS_PixShiftsList_In << endl;
      }
    }
    
    CS_comp.Set("PIX_SHIFTS_OUT");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        CS_PixShiftsList_Out.Set(*P_CS);
        cout << "MGaussExtract_Obs_Sky::main: CS_PixShiftsList_Out to " << CS_PixShiftsList_Out << endl;
      }
    }
    
    CS_comp.Set("AIRMASSES_IN");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        CS_AirMassList_In.Set(*P_CS);
        cout << "MGaussExtract_Obs_Sky::main: CS_AirMassList_In to " << CS_AirMassList_In << endl;
      }
    }
    
    CS_comp.Set("ATMOS_EXTINCTION_IN");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        CS_AtmosphericExtinction_In.Set(*P_CS);
        cout << "MGaussExtract_Obs_Sky::main: CS_AtmosphericExtinction_In to " << CS_AtmosphericExtinction_In << endl;
      }
    }
    
    CS_comp.Set("THROUGHPUTS_IN");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        CS_ThroughputsList_In.Set(*P_CS);
        cout << "MGaussExtract_Obs_Sky::main: CS_ThroughputsList_In to " << CS_ThroughputsList_In << endl;
      }
    }
    
    CS_comp.Set("THROUGHPUTS_JD_IN");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        CS_ThroughputsJDList_In.Set(*P_CS);
        cout << "MGaussExtract_Obs_Sky::main: CS_ThroughputsJDList_In to " << CS_ThroughputsJDList_In << endl;
      }
    }
    
    CS_comp.Set("JULIAN_DATES_IN");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        CS_JulianDates_In.Set(*P_CS);
        cout << "MGaussExtract_Obs_Sky::main: CS_JulianDates_In to " << CS_JulianDates_In << endl;
      }
    }
    
    /// 2D
    CS_comp.Set("ERR_IN");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_ErrIn);
        P_CS_ErrIn = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: ERR_IN set to " << *P_CS_ErrIn << endl;
      }
    }

    /// 2D
    CS_comp.Set("ERR_OUT_2D");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_ErrOut);
        P_CS_ErrOut = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: ERR_OUT_2D set to " << *P_CS_ErrOut << endl;
      }
    }

    /// 1D
    CS_comp.Set("ERR_OUT_EC");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_ErrOutEc);
        P_CS_ErrOutEc = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: ERR_OUT_EC set to " << *P_CS_ErrOut << endl;
      }
    }

    /// 1D
    CS_comp.Set("SKY_OUT_EC");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_SkyOut);
        P_CS_SkyOut = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: SKY_OUT_EC set to " << *P_CS_SkyOut << endl;
      }
    }

    /// 2D
    CS_comp.Set("SKY_OUT_2D");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_SkyArrOut);
        P_CS_SkyArrOut = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: SKY_OUT_2D set to " << *P_CS_SkyArrOut << endl;
      }
    }
    
    /// 1D
    CS_comp.Set("SKY_ERR_OUT_EC");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_SkyErrOut);
        P_CS_SkyErrOut = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: SKY_ERR_OUT_EC set to " << *P_CS_SkyErrOut << endl;
      }
    }

    /// 2D
    CS_comp.Set("REC_FIT_OUT");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_RecFitOut);
        P_CS_RecFitOut = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: REC_FIT_OUT set to " << *P_CS_RecFitOut << endl;
      }
    }

    /// 2D
    CS_comp.Set("PROFILE_OUT");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_ProfileOut);
        P_CS_ProfileOut = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: PROFILE_OUT set to " << *P_CS_ProfileOut << endl;
      }
    }

    /// 2D
    CS_comp.Set("MASK_OUT");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_MaskOut);
        P_CS_MaskOut = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: MASK_OUT set to " << *P_CS_MaskOut << endl;
      }
    }

    CS_comp.Set("APERTURES");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS_ApertureListIn);
        P_CS_ApertureListIn = CS.SubString(CS_comp.GetLength()+1);
        cout << "MGaussExtract_Obs_Sky::main: P_CS_ApertureListIn set to " << *P_CS_ApertureListIn << endl;
	B_AperturesSet = true;
	Array<CString, 1> CS_A1_AperturesToExtract(1);
	CS_A1_AperturesToExtract = CString(" ");
	if (!CS.ReadFileLinesToStrArr(*P_CS_ApertureListIn, CS_A1_AperturesToExtract)){
	  cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(" << *P_CS_ApertureListIn << ") returned FALSE" << endl;
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

  CFits F_Image;
  CFits F_OutImage;
  CFits F_ErrImage;
  CFits F_ApDefImage;
  time_t seconds;

  bool B_Lists = true;
  CString CS_FitsFileName_In;
  CS_FitsFileName_In.Set(P_CharArr_In);
  Array<CString, 2> CS_A2_FitsFileNames_In(2,2);
  Array<CString, 1> CS_A1_FitsFileNames_In(1);
  CS_A1_FitsFileNames_In(0) = CS_FitsFileName_In;
  if (!CS_FitsFileName_In.IsList()){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: " << CS_FitsFileName_In << " is not a list" << endl;
    exit(EXIT_FAILURE);
  }
  P_CS_Temp = CS_FitsFileName_In.SubString(1);
  if (!CS_FitsFileName_In.ReadFileToStrArr(*P_CS_Temp, CS_A2_FitsFileNames_In, CString(" "))){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(" << CS_FitsFileName_In << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  delete(P_CS_Temp);
  CS_A1_FitsFileNames_In.resize(CS_A2_FitsFileNames_In.rows());
  CS_A1_FitsFileNames_In = CS_A2_FitsFileNames_In(Range::all(), 0);

  D_A1_PixShifts.resize(CS_A1_FitsFileNames_In.size());
  D_A1_PixShifts = 0.;
  Array<CString, 1> CS_A1_PixShifts(1);
  if (CS_PixShiftsList_In.GetLength() > 2){
    if (!CS.ReadFileLinesToStrArr(CS_PixShiftsList_In, CS_A1_PixShifts)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(" << CS_PixShiftsList_In << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    D_A1_PixShifts.resize(CS_A1_PixShifts.size());
    for (int i_row=0; i_row < CS_A1_PixShifts.size(); i_row++){
      if (!CS_A1_PixShifts(i_row).AToD(D_A1_PixShifts(i_row))){
        #ifdef __DEBUG_MGAUSSEXTRACT__
          cout << "MGaussExtract_Obs_Sky::main: WARNING: CS_A1_PixShifts(i_row=" << i_row << ")=" << CS_A1_PixShifts(i_row) << ".AToD() returned FALSE" << endl;
        #endif
        if (!CS_A1_PixShifts(i_row).EqualValue(CString("c"))){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: CS_A1_PixShifts(i_row=" << i_row << ")=" << CS_A1_PixShifts(i_row) << ".AToD() returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
      }
    }
    if (D_A1_PixShifts.size() != CS_A1_FitsFileNames_In.size()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: D_A1_PixShifts.size(=" << D_A1_PixShifts.size() << ") != CS_A1_FitsFileNames_In.size(=" << CS_A1_FitsFileNames_In.size() << ")" << endl;
      exit(EXIT_FAILURE);
    }
  }
  
  D_A1_AirMasses.resize(CS_A1_FitsFileNames_In.size());
  D_A1_AirMasses = 0.;
  Array<CString, 1> CS_A1_AirMasses(1);
  if (CS_AirMassList_In.GetLength() > 2){
    if (!CS.ReadFileLinesToStrArr(CS_AirMassList_In, CS_A1_AirMasses)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(" << CS_AirMassList_In << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    D_A1_AirMasses.resize(CS_A1_AirMasses.size());
    for (int i_row=0; i_row < CS_A1_AirMasses.size(); i_row++){
      if (!CS_A1_AirMasses(i_row).AToD(D_A1_AirMasses(i_row))){
        cout << "MGaussExtract_Obs_Sky::main: WARNING: CS_A1_AirMasses(i_row=" << i_row << ")=" << CS_A1_AirMasses(i_row) << ".AToD() returned FALSE" << endl;
      }
    }
    if (D_A1_AirMasses.size() != CS_A1_FitsFileNames_In.size()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: D_A1_AirMasses.size(=" << D_A1_AirMasses.size() << ") != CS_A1_FitsFileNames_In.size(=" << CS_A1_FitsFileNames_In.size() << ")" << endl;
      exit(EXIT_FAILURE);
    }
  }
  
  if (((CS_AirMassList_In.GetLength() > 2) && (CS_AtmosphericExtinction_In.GetLength() <= 2)) 
    || ((CS_AirMassList_In.GetLength() <= 2) && (CS_AtmosphericExtinction_In.GetLength() > 2))){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: Both AIRMASSES_IN and ATMOS_EXTINCTION_IN must be given" << endl;
    exit(EXIT_FAILURE);
  }
  
  if (CS_AtmosphericExtinction_In.GetLength() > 2){
    if (!CS.ReadFileToDblArr(CS_AtmosphericExtinction_In, D_A2_AtmosphericExtinction, CString(" "))){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileToDblArr(" << CS_AtmosphericExtinction_In << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
  }
  
  if (((CS_ThroughputsList_In.GetLength() > 2) && (CS_ThroughputsJDList_In.GetLength() <= 2)) || ((CS_ThroughputsJDList_In.GetLength() > 2) && (CS_ThroughputsList_In.GetLength() <= 2))){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: Both THROUGHPUTS_IN and THROUGHPUTS_JD_IN must be given for flux calibration" << endl;
      exit(EXIT_FAILURE);
  }
  Array<CString, 1> CS_A1_ThroughputFiles(1);
  Array<CString, 1> CS_A1_ThroughputFiles_Out(1);
  Array<double, 1> D_A1_ThroughputJDs(1);
  Array<CString, 1> CS_A1_ThroughputJDs(1);
  D_A1_ThroughputJDs = -1.;
  Array<double, 3> D_A3_Throughputs(2,2,2); 
  Array<double, 3> D_A3_ThroughputsFit(2,2,2); 
  if (CS_ThroughputsList_In.GetLength() > 2){
    if (CS_JulianDates_In.GetLength() <= 2){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: Throughputs given but JULIAN_DATES_IN is not" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CS.ReadFileLinesToStrArr(CS_ThroughputsList_In, CS_A1_ThroughputFiles)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(CS_ThroughputsList_In=" << CS_ThroughputsList_In << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CS.ReadFileLinesToStrArr(CS_ThroughputsJDList_In, CS_A1_ThroughputJDs)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(CS_ThroughputsJDList_In=" << CS_ThroughputsJDList_In << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    if (CS_A1_ThroughputFiles.size() != CS_A1_ThroughputJDs.size()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: CS_A1_ThroughputFiles.size(=" << CS_A1_ThroughputFiles.size() << ") != CS_A1_ThroughputJDs.size(=" << CS_A1_ThroughputJDs.size() << ")" << endl;
      exit(EXIT_FAILURE);
    }
    D_A1_ThroughputJDs.resize(CS_A1_ThroughputJDs.size());
    for (int i_line=0; i_line < CS_A1_ThroughputJDs.size(); i_line++){
      if (!CS_A1_ThroughputJDs(i_line).AToD(D_A1_ThroughputJDs(i_line))){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: CS_A1_ThroughputJDs(" << i_line << ").AToD() returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
    }
    Array<double, 2> D_A2_OneThroughput(2,2);
    if (!CS.StrReplaceInList(CS_A1_ThroughputFiles, 
                             CString(".text"), 
                             CString("Fit.text"), 
                             CS_A1_ThroughputFiles_Out)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_ThroughputFiles) returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    Array<CString, 1> CS_A1_PolyFit_Args(1);
    CS_A1_PolyFit_Args(0) = CString("MEASURE_ERRORS");
    void **PP_ArgsPolyFit = (void**)malloc(sizeof(void*));
    int I_NLines = 0;
    for (int i_line=0; i_line < CS_A1_ThroughputJDs.size(); i_line++){
      if (!CS.ReadFileToDblArr(CS_A1_ThroughputFiles(i_line), D_A2_OneThroughput, CString(" "))){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileToDblArr(" << CS_A1_ThroughputFiles(i_line) << ") returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: D_A2_OneThroughput = " << D_A2_OneThroughput << endl;
      #endif
      if (i_line == 0){
        D_A3_Throughputs.resize(CS_A1_ThroughputFiles.size(), D_A2_OneThroughput.rows(), D_A2_OneThroughput.cols());
        D_A3_ThroughputsFit.resize(CS_A1_ThroughputFiles.size(), D_A2_OneThroughput.rows(), D_A2_OneThroughput.cols());
        I_NLines = D_A2_OneThroughput.rows();
        D_A3_Throughputs = 0.;
        D_A3_ThroughputsFit = 1.;
      }
      if (D_A2_OneThroughput.rows() < I_NLines){
        D_A3_Throughputs(i_line, Range(0,D_A2_OneThroughput.rows()-1), Range::all()) = D_A2_OneThroughput;
      }
      else{
        D_A3_Throughputs(i_line, Range::all(), Range::all()) = D_A2_OneThroughput(Range(0,I_NLines-1), Range::all());
      }
      Array<double, 1> *P_D_A1_Coeffs = new Array<double, 1>(I_FluxCalib_PolyFitDegree+1);
      (*P_D_A1_Coeffs) = 0.;
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: D_A2_OneThroughput = " << D_A2_OneThroughput << endl;
      #endif
      Array<int, 1> I_A1_NX(D_A2_OneThroughput.rows());
      I_A1_NX = where((D_A2_OneThroughput(Range::all(), 0) < 7415.) || (D_A2_OneThroughput(Range::all(), 0) > 7815.), 1, 0);
      int I_NX;
      Array<int, 1> *P_I_A1_IndNX = F_Image.GetIndex(I_A1_NX, I_NX);
      Array<double, 1> D_A1_X(I_NX);
      Array<double, 1> D_A1_Y(I_NX);
      for (int i_x=0; i_x<I_NX; i_x++){
        D_A1_X(i_x) = D_A2_OneThroughput((*P_I_A1_IndNX)(i_x), 0);
        D_A1_Y(i_x) = D_A2_OneThroughput((*P_I_A1_IndNX)(i_x), 1);
      }
//      cout << "D_A1_X = " << D_A1_X << endl;
//      cout << "D_A1_Y = " << D_A1_Y << endl;
//      exit(EXIT_FAILURE);
      Array<double, 1> D_A1_MeasureErrors(I_NX);
      D_A1_MeasureErrors = sqrt(fabs(D_A1_Y));
      D_A1_MeasureErrors = where(fabs(D_A1_MeasureErrors) < 0.000000001, 0.00001, D_A1_MeasureErrors);
      PP_ArgsPolyFit[0] = &D_A1_MeasureErrors;
      if (!F_Image.PolyFit(D_A1_X,
                           D_A1_Y,
                           I_FluxCalib_PolyFitDegree,
                           7.,
                           9.,
                           1,
                           CS_A1_PolyFit_Args,
                           PP_ArgsPolyFit,
                           P_D_A1_Coeffs)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: PolyFit returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: *P_D_A1_Coeffs = " << *P_D_A1_Coeffs << endl;
      #endif
      Array<double, 1> *P_D_A1_Throughput = F_Image.Poly(D_A2_OneThroughput(Range::all(), 0), *P_D_A1_Coeffs);
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: *P_D_A1_Throughput = " << *P_D_A1_Throughput << endl;
      #endif
      if (D_A2_OneThroughput.rows() < I_NLines){
        D_A3_ThroughputsFit(i_line, Range(0,D_A2_OneThroughput.rows()-1), 0) = D_A2_OneThroughput(Range::all(), 0);
        D_A3_ThroughputsFit(i_line, Range(0,D_A2_OneThroughput.rows()-1), 1) = (*P_D_A1_Throughput);
      }
      else{
        D_A3_ThroughputsFit(i_line, Range::all(), 0) = D_A2_OneThroughput(Range(0,I_NLines-1), 0);
        D_A3_ThroughputsFit(i_line, Range::all(), 1) = (*P_D_A1_Throughput)(Range(0,I_NLines-1));
      }
      delete(P_D_A1_Throughput);
      delete(P_D_A1_Coeffs);
      D_A2_OneThroughput(Range::all(), 1) = D_A3_ThroughputsFit(i_line, Range::all(), 1);
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: D_A2_OneThroughputFit = " << D_A2_OneThroughput << endl;
      #endif
      if (!F_Image.WriteArrayToFile(D_A2_OneThroughput, CS_A1_ThroughputFiles_Out(i_line), CString("ascii"))){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: WriteArrayToFile(ThroughputsFit) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: D_A3_ThroughputsFit(" << i_line << ",*,*) = " << D_A3_ThroughputsFit(i_line, Range::all(), Range::all()) << endl;
      #endif
    }
  }
//  exit(EXIT_FAILURE);
  
  Array<CString, 1> CS_A1_FitsFileNamesPlusDir(CS_A1_FitsFileNames_In.size());
  if (!CS_FitsFileName_In.AddNameAsDir(CS_A1_FitsFileNames_In, CS_A1_FitsFileNamesPlusDir)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: AddFirstPartAsDir(CS_A1_FitsFileNames_In, CS_A1_FitsFileNamesPlusDir) returned FALSE" << endl;
    return false;
  }
  #ifdef __DEBUG_MGAUSSEXTRACT__
    cout << "MGaussExtract_Obs_Sky::main: CS_A1_FitsFileNamesPlusDir = " << CS_A1_FitsFileNamesPlusDir << endl;
  #endif
//  exit(EXIT_FAILURE);

  Array<CString,1> CS_A1_JulianDates(1);
  Array<double, 1> D_A1_JulianDates(2);
  if (CS_JulianDates_In.GetLength() > 2){
    if (!CS.ReadFileLinesToStrArr(CS_JulianDates_In, CS_A1_JulianDates)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(CS_JulianDates_In=" << CS_JulianDates_In << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    D_A1_JulianDates.resize(CS_A1_JulianDates.size());
    for (int i_row=0; i_row<CS_A1_JulianDates.size(); i_row++){
      if (!CS_A1_JulianDates(i_row).AToD(D_A1_JulianDates(i_row))){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: CS_A1_JulianDates(" << i_row << ")(=" << CS_A1_JulianDates(i_row) << ").AToD() returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
    }
  }
  
  CString CS_TextFilesCoeffs_In;
  CS_TextFilesCoeffs_In.Set(P_CharArr_Coeffs);
  //if (!CS_TextFilesCoeffs_In.IsList()){
  //  cout << "MGaussExtract_Obs_Sky::main: ERROR: CS_TextFilesCoeffs_In(=" << CS_TextFilesCoeffs_In << ") is not a list" << endl;
  //  exit(EXIT_FAILURE);
  //}

  if (!CS_TextFilesCoeffs_In.ReadFileLinesToStrArr(CS_TextFilesCoeffs_In, CS_A1_TextFiles_Coeffs_In)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(" << CS_TextFilesCoeffs_In << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }

  CString CS_FileName_ExpTimes_In(P_CharArr_ExpTimes_In);
  Array<double, 2> D_A2_ExpTimes(CS_A1_FitsFileNames_In.size(), 1);
  if (!CS.ReadFileToDblArr(CS_FileName_ExpTimes_In, D_A2_ExpTimes, CString(" "))){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileToDblArr(" << CS_FileName_ExpTimes_In << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<double, 1> D_A1_ExpTimes(CS_A1_FitsFileNames_In.size());
  D_A1_ExpTimes = D_A2_ExpTimes(Range::all(), 0);
  #ifdef __DEBUG_MGAUSSEXTRACT__
    cout << "MGaussExtract_Obs_Sky::main: D_A1_ExpTimes set to " << D_A1_ExpTimes << endl;
  #endif
//  exit(EXIT_FAILURE);

  CString CS_FitsFileNameEcDR_Out;
  CString CS_FitsFileNameErrEcDR_Out;

  CString CS_DatabaseFileName_In;
  CS_DatabaseFileName_In.Set(P_CharArr_DB);
  Array<CString, 1> CS_A1_DBFileNames_In(CS_A1_FitsFileNames_In.size());
  CS_A1_DBFileNames_In = CS_DatabaseFileName_In;
  if (CS_DatabaseFileName_In.IsList()){
    CString *P_CS_DB = CS_DatabaseFileName_In.SubString(1);
    if (!CS_DatabaseFileName_In.ReadFileLinesToStrArr(CS_DatabaseFileName_In, CS_A1_DBFileNames_In)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: ReadFileLinesToStrArr(" << CS_DatabaseFileName_In << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    if (CS_A1_DBFileNames_In.size() != CS_A1_FitsFileNames_In.size()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: CS_A1_FitsFileNames_In.size(=" << CS_A1_FitsFileNames_In.size() << ") != CS_A1_DBFileNames_In.size(=" << CS_A1_DBFileNames_In.size() << ") => returning FALSE" << endl;
      exit(EXIT_FAILURE);
    }
  }

  Array<CString, 1> CS_A1_ErrIn(CS_A1_FitsFileNames_In.size());
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_err.fits"), CS_A1_ErrIn)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _err.fits, CS_A1_ErrIn) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }

  Array<CString, 1> CS_A1_ErrOut(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_errOut.fits"), CS_A1_ErrOut)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _errOut.fits, CS_A1_ErrOut) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }

  Array<CString, 1> CS_A1_ErrOutEc(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_errEc.fits"), CS_A1_ErrOutEc)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _errEc.fits, CS_A1_ErrOutEc) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<CString, 1> CS_A1_SkyOut(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_Sky.fits"), CS_A1_SkyOut)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _Sky.fits, CS_A1_SkyOut) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }

  Array<CString, 1> CS_A1_SkyArrOut(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_SkyArrOut.fits"), CS_A1_SkyArrOut)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _SkyArrOut.fits, CS_A1_SkyArrOut) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<CString, 1> CS_A1_SkyErrOut(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_errSky.fits"), CS_A1_SkyErrOut)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _errSky.fits, CS_A1_SkyErrOut) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<CString, 1> CS_A1_RecFitOut(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_Rec.fits"), CS_A1_RecFitOut)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _RecFit.fits, CS_A1_RecFitOut) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<CString, 1> CS_A1_ProfileOut(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_Prof.fits"), CS_A1_ProfileOut)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _Prof.fits, CS_A1_ProfileOut) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<CString, 1> CS_A1_MaskOut(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_MaskOut.fits"), CS_A1_MaskOut)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _MaskOut.fits, CS_A1_MaskOut) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  Array<CString, 1> CS_A1_SPFitOut(1);
  if (!CS_comp.StrReplaceInList(CS_A1_FitsFileNamesPlusDir, CString(".fits"), CString("_EcFit.fits"), CS_A1_SPFitOut)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: StrReplaceInList(CS_A1_FitsFileNamesPlusDir, .fits, _SpFit.fits, CS_A1_SPFitOut) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }

  Array<int, 1> I_A1_Apertures_Object(1);
  Array<int, 1> I_A1_Apertures_Sky(1);
  Array<int, 1> I_A1_AperturesToExtract(1);
  CString *P_CS_ImageName_ApsRoot;
  CString CS_ImageName_ApsRoot(" ");
  Array<CString, 1> CS_A1_ApertureFitsFileNames(1);
  Array<CString, 1> CS_A1_ApertureFitsFileNamesErr(1);
  Array<CString, 1> CS_A1_TextFiles_EcD_Out(1);
  //Array<CString, 1> CS_A1_TextFiles_EcDFlux_Out(1);
  Array<CString, 1> CS_A1_TextFiles_EcDR_Out(1);
  Array<CString, 1> CS_A1_TextFiles_Err_EcD_Out(1);
  Array<CString, 1> CS_A1_TextFiles_Err_EcDR_Out(1);
  Array<CString, 1> CS_A1_DBFileNames_Out(CS_A1_FitsFileNames_In.size());
  CS_A1_DBFileNames_Out = CS_A1_DBFileNames_In;
  CString CS_HTML("html/");
  if (!CS.MkDir(CS_HTML)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: MkDir(" << CS_HTML << ") returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  CString CS_HTML_FileName(CS_HTML);
  CS_HTML_FileName.Add(CString("index_plots.html"));
  ofstream *P_OFS_html = new ofstream(CS_HTML_FileName.Get());
  (*P_OFS_html) << "<html><body><center>" << endl;
  CString CS_PlotName("");
  for (int i_file = 0; i_file < CS_A1_FitsFileNames_In.size(); i_file++){
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.SetFileName(" << CS_A1_FitsFileNames_In(i_file) << ")" << endl;
    #endif
    if (!F_Image.SetFileName(CS_A1_FitsFileNames_In(i_file)))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetFileName(" << CS_A1_FitsFileNames_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Set ReadOutNoise
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.Set_ReadOutNoise(" << D_ReadOutNoise << ")" << endl;
    #endif
    if (!F_Image.Set_ReadOutNoise( D_ReadOutNoise ))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.Set_ReadOutNoise(" << D_ReadOutNoise << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Set Gain
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.Set_Gain(" << D_Gain << ")" << endl;
    #endif
    if (!F_Image.Set_Gain( D_Gain ))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.Set_Gain(" << D_Gain << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    /// Set I_MaxIterSig
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.Set_MaxIterSig(" << I_MaxIterSig << ")" << endl;
    #endif
    if (!F_Image.Set_MaxIterSig( I_MaxIterSig ))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.Set_MaxIterSig(" << I_MaxIterSig << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Read FitsFile
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.ReadArray()" << endl;
    #endif
    if (!F_Image.ReadArray())
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.ReadArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    P_CS_ImageName_ApsRoot = CS_A1_FitsFileNamesPlusDir(i_file).SubString(0,CS_A1_FitsFileNamesPlusDir(i_file).StrPos(CString("/")));
    if (!P_CS_ImageName_ApsRoot->MkDir(*P_CS_ImageName_ApsRoot)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: MkDir(" << *P_CS_ImageName_ApsRoot << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    else{
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: MkDir(" << *P_CS_ImageName_ApsRoot << ") returned TRUE" << endl;
      #endif
    }
    CString *P_CS_FileName = CS_A1_FitsFileNames_In(i_file).SubString(0,CS_A1_FitsFileNames_In(i_file).LastStrPos(CString("."))-1);
    P_CS_ImageName_ApsRoot->Add(*P_CS_FileName);
    delete(P_CS_FileName);
    CS_ImageName_ApsRoot.Set(*P_CS_ImageName_ApsRoot);
    delete(P_CS_ImageName_ApsRoot);

    /// Calculate Uncertainties
    F_OutImage.SetFileName(CS_A1_FitsFileNames_In(i_file));
    F_OutImage.ReadArray();
    F_OutImage.GetPixArray() = sqrt(fabs(F_Image.GetPixArray()) * D_Gain + pow2(D_ReadOutNoise));
    CString CS_ErrImage(" ");
    CS_ErrImage.Set(CS_ImageName_ApsRoot);
    CS_ErrImage.Add(CString("_err.fits"));
    F_OutImage.SetFileName(CS_ErrImage);
    F_OutImage.WriteArray();
    F_Image.SetErrFileName(CS_ErrImage);
    F_Image.ReadErrArray();
    CS_ImageName_ApsRoot.Add(CString("Ec"));
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: CS_ImageName_ApsRoot = <" << CS_ImageName_ApsRoot << ">" << endl;
    #endif
//    exit(EXIT_FAILURE);
//    delete(P_CS_ImageName_ApsRoot);

    F_Image.GetPixArray() = F_Image.GetPixArray() * F_Image.Get_Gain();

    /// Set DatabaseFileName_In
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.SetDatabaseFileName(" << CS_A1_DBFileNames_In(i_file) << ")" << endl;
    #endif
    if (!F_Image.SetDatabaseFileName(CS_A1_DBFileNames_In(i_file)))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetDatabaseFileName(" << CS_A1_DBFileNames_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Read DatabaseFileName_In
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.ReadDatabaseEntry()" << endl;
    #endif
    if (!F_Image.ReadDatabaseEntry())
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.ReadDatabaseEntry() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Calculate Trace Functions
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.CalcTraceFunctions()" << endl;
    #endif
    if (!F_Image.CalcTraceFunctions())
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.CalcTraceFunctions() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    int I_Pos_RadObs = 3;
    int I_Pos_RadSky = 4;
    Array<double, 1> D_A1_Center(2);
    Array<double, 2> D_A2_ApertureCenters(2,2);
    if (!F_Image.GetApertureCenters(D_A2_ApertureCenters)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.GetApertureCenters(D_A2_ApertureCenters) returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    Array<double, 2> D_A2_NearestNeighbours(2,2);
//    for (int i_a2_row = 0; i_a2_row<CS_A2_FitsFileNames_In.rows(); i_a2_row++){
//      for (int i_a2_col = 0; i_a2_col<CS_A2_FitsFileNames_In.cols(); i_a2_col++){
//        cout << "MGaussExtract_Obs_Sky::main: CS_A2_FitsFileNames_In(" << i_a2_row << ", " << i_a2_col << ") = <" << CS_A2_FitsFileNames_In(i_a2_row, i_a2_col) << "> length = " << CS_A2_FitsFileNames_In(i_a2_row, i_a2_col).GetLength() << endl;
//      }
//    }
//    exit(EXIT_FAILURE);
    if (CS_A2_FitsFileNames_In.cols() < 5){
      D_A1_Center(0) = D_A2_ApertureCenters(CS_A2_FitsFileNames_In(i_file, 1).AToI(), 0);
      D_A1_Center(1) = D_A2_ApertureCenters(CS_A2_FitsFileNames_In(i_file, 1).AToI(), 1);
      I_Pos_RadObs = 2;
      I_Pos_RadSky = 3;
    }
    else if (CS_A2_FitsFileNames_In(i_file,4).GetLength() == 0){
      D_A1_Center(0) = D_A2_ApertureCenters(CS_A2_FitsFileNames_In(i_file, 1).AToI(), 0);
      D_A1_Center(1) = D_A2_ApertureCenters(CS_A2_FitsFileNames_In(i_file, 1).AToI(), 1);
      I_Pos_RadObs = 2;
      I_Pos_RadSky = 3;
    }
    else{
      D_A1_Center(0) = CS_A2_FitsFileNames_In(i_file, 1).AToI();
      D_A1_Center(1) = CS_A2_FitsFileNames_In(i_file, 2).AToI();
      I_Pos_RadObs = 3;
      I_Pos_RadSky = 4;
    }
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: D_A1_Center = " << D_A1_Center << endl;
    #endif
    if (P_CS_ApDefImage_In->GetLength() > 2){
      F_ApDefImage.SetFileName(*P_CS_ApDefImage_In);
      F_ApDefImage.ReadArray();
      int I_Shift = 0;
      double D_ChiSquareMin = 0.;
      double D_Shift = 0.;
      if (B_XCor_2D){
        int I_X0_ApDefImage = D_A1_Center(0) - 200;
        if (I_X0_ApDefImage < 0)
            I_X0_ApDefImage = 0;
        int I_X1_ApDefImage = D_A1_Center(0) + 200;
        if (I_X1_ApDefImage >= F_ApDefImage.GetNCols())
            I_X1_ApDefImage = F_ApDefImage.GetNCols()-1;
        int I_Y0_ApDefImage = D_A1_Center(1) - 200;
        if (I_Y0_ApDefImage < 0)
            I_Y0_ApDefImage = 0;
        int I_Y1_ApDefImage = D_A1_Center(1) + 200;
        if (I_Y1_ApDefImage < 0)
            I_Y1_ApDefImage = 0;
        #ifdef __DEBUG_MGAUSSEXTRACT__
          cout << "MGaussExtract_Obs_Sky::main: I_X0_ApDefImage = " << I_X0_ApDefImage << ", I_X1_ApDefImage = " << I_X1_ApDefImage << ", I_Y0_ApDefImage = " << I_Y0_ApDefImage << ", I_Y1_ApDefImage = " << I_Y1_ApDefImage << endl;
        #endif
        Array<double, 2> D_A2_Area_ApDefImage(I_Y1_ApDefImage-I_Y0_ApDefImage+1, I_X1_ApDefImage-I_X0_ApDefImage+1);
        D_A2_Area_ApDefImage = F_ApDefImage.GetPixArray()(Range(I_Y0_ApDefImage, I_Y1_ApDefImage), Range(I_X0_ApDefImage, I_X1_ApDefImage));
        int I_X0_Image = I_X0_ApDefImage + I_MaxOffset;
        int I_X1_Image = I_X1_ApDefImage - I_MaxOffset;
        int I_Y0_Image = I_Y0_ApDefImage;// + 5;
        int I_Y1_Image = I_Y1_ApDefImage;// - 5;
        #ifdef __DEBUG_MGAUSSEXTRACT__
          cout << "MGaussExtract_Obs_Sky::main: I_X0_Image = " << I_X0_Image << ", I_X1_Image = " << I_X1_Image << ", I_Y0_Image = " << I_Y0_Image << ", I_Y1_Image = " << I_Y1_Image << endl;
        #endif
        Array<double, 2> D_A2_Area_Image(I_Y1_Image-I_Y0_Image+1, I_X1_Image-I_X0_Image+1);
        D_A2_Area_Image = F_Image.GetPixArray()(Range(I_Y0_Image, I_Y1_Image), Range(I_X0_Image, I_X1_Image));
        D_A2_Area_Image = D_A2_Area_Image * mean(D_A2_Area_ApDefImage) / mean(D_A2_Area_Image);
        int I_Shift_Y = 0;
        #ifdef __DEBUG_MGAUSSEXTRACT__
          cout << "MGaussExtract_Obs_Sky::main: Starting CrossCorrelate2D" << endl;
        #endif
        CString CS_FNameTemp("Area_Image.fits");
        F_Image.WriteFits(&D_A2_Area_Image, CS_FNameTemp);
        CS_FNameTemp.Set("Area_ApDefImage.fits");
        F_Image.WriteFits(&D_A2_Area_ApDefImage, CS_FNameTemp);
        if (!F_Image.CrossCorrelate2D(D_A2_Area_Image,
                                      D_A2_Area_ApDefImage,
                                      I_Shift,
                                      I_Shift_Y)){
          cout << "MGaussExtract_Obs_Sky: ERROR: CrossCorrelate2D returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        I_Shift = I_MaxOffset - I_Shift;
        D_Shift = double(I_Shift);
        #ifdef __DEBUG_MGAUSSEXTRACT__
          cout << "MGaussExtract_Obs_Sky::main: I_Shift_X = " << I_Shift << ", I_Shift_Y = " << I_Shift_Y << endl;
        #endif
      }
      else{
        Array<double, 1> D_A1_Line_ApDefImage(F_ApDefImage.GetNCols());
        Array<double, 1> D_A1_Line_Image(F_Image.GetNCols());
        if (D_A1_Line_ApDefImage.size() != D_A1_Line_Image.size()){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: D_A1_Line_ApDefImage.size(=" << D_A1_Line_ApDefImage.size() << ") != D_A1_Line_Image.size(=" << D_A1_Line_Image.size() << ") => Returning FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        D_A1_Line_ApDefImage = F_ApDefImage.GetPixArray()(D_A1_Center(0), Range::all());
        D_A1_Line_Image = F_Image.GetPixArray()(D_A1_Center(0), Range::all());
        D_A1_Line_Image = D_A1_Line_Image * mean(D_A1_Line_ApDefImage) / mean(D_A1_Line_Image);
        if (!F_Image.CrossCorrelate(D_A1_Line_Image, 
                                    D_A1_Line_ApDefImage, 
                                    I_MaxOffset, 
                                    I_MaxOffset, 
                                    D_Shift, 
                                    D_ChiSquareMin)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: CrossCorrelate returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: D_Shift = " << D_Shift << ", D_ChiSquareMin = " << D_ChiSquareMin << endl;
      #endif
//      exit(EXIT_FAILURE);
      F_Image.ShiftApertures(D_Shift);
      CString CS_DatabaseFileName_Temp("database/ap");
      CString *P_CS_DB_Temp = CS_A1_FitsFileNames_In(i_file).SubString(0,CS_A1_FitsFileNames_In(i_file).LastStrPos(CString("."))-1);
      CS_DatabaseFileName_Temp.Add(*P_CS_DB_Temp);
      delete(P_CS_DB_Temp);
      CS_A1_DBFileNames_Out(i_file).Set(CS_DatabaseFileName_Temp);
      CS_A1_DBFileNames_In(i_file).Set(CS_DatabaseFileName_Temp);
      F_Image.SetDatabaseFileName(CS_DatabaseFileName_Temp);
      F_Image.WriteDatabaseEntry();
      //      exit(EXIT_FAILURE);
    }
    Array<double, 2> D_A2_PixArray(F_Image.GetNRows(), F_Image.GetNCols());
    D_A2_PixArray = F_Image.GetPixArray();
    F_Image.MarkCenters();
    CString *P_CS_MarkCenters = CS_A1_FitsFileNames_In(i_file).SubString(0,CS_A1_FitsFileNames_In(i_file).LastStrPos(CString("."))-1);
    P_CS_MarkCenters->Add(CString("_centers_shift.fits"));
    F_Image.SetFileName(*P_CS_MarkCenters);
    delete(P_CS_MarkCenters);
    F_Image.WriteArray();
    
    F_Image.GetPixArray() = D_A2_PixArray;
    
    Array<int, 1> I_A1_AreaTemp(4);
    I_A1_AreaTemp(0) = I_A1_Area(0);
    I_A1_AreaTemp(1) = I_A1_Area(1);
    I_A1_AreaTemp(2) = I_A1_Area(2) - 127;
    if (I_A1_AreaTemp(2) < 0)
      I_A1_AreaTemp(2) = 0;
    I_A1_AreaTemp(3) = I_A1_Area(3) + 127;
    if (I_A1_AreaTemp(3) >= F_Image.GetNRows())
      I_A1_AreaTemp(3) = F_Image.GetNRows()-1;
    if (CS_A2_FitsFileNames_In(i_file, I_Pos_RadObs).AToI() < 20){
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: Starting FindNearestNeighbours(D_A1_Center = " << D_A1_Center << ", D_A2_ApertureCenters, " << CS_A2_FitsFileNames_In(i_file, 3).AToI() * 6 + 1 << ",...)" << endl;
      #endif
      if (!F_Image.FindNearestNeighbours(D_A1_Center,
                                         D_A2_ApertureCenters,
                                         CS_A2_FitsFileNames_In(i_file, I_Pos_RadObs).AToI() * 6 + 1,
                                         I_A1_AreaTemp,
                                         D_A2_NearestNeighbours,
                                         I_A1_Apertures_Object)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.FindNearestNeighbours(D_A1_Center=" << D_A1_Center << ", D_A2_ApertureCenters, " << CS_A2_FitsFileNames_In(i_file, 3).AToI() * 6 + 1 << ", D_A2_NearestNeighbours, I_A1_Apertures_Object) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
    }
    else{
      if (!F_Image.FindApsInCircle(CS_A2_FitsFileNames_In(i_file, 1).AToI(),
                                   CS_A2_FitsFileNames_In(i_file, 2).AToI(),
                                   CS_A2_FitsFileNames_In(i_file, I_Pos_RadObs).AToI(),
                                   I_A1_AreaTemp,
                                   I_A1_Apertures_Object)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: " << CS_A1_FitsFileNames_In(i_file) << ".FindApsInCircle(" << CS_A2_FitsFileNames_In(i_file, 1) << ", " << CS_A2_FitsFileNames_In(i_file, 2) << ", " << CS_A2_FitsFileNames_In(i_file, 3) << ") returned FALSE " << endl;
        exit(EXIT_FAILURE);
      }
    }
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: I_A1_Apertures_Object = " << I_A1_Apertures_Object << endl;
    #endif
    CString *P_CS_ObsList = CS_A1_FitsFileNames_In(i_file).SubString(0, CS_A1_FitsFileNames_In(i_file).LastCharPos('.')-1);
    P_CS_ObsList->Add("_apsObject.list");
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: P_CS_ObsList set to <" << *P_CS_ObsList << ">" << endl;
    #endif
    F_Image.WriteArrayToFile(I_A1_Apertures_Object, *P_CS_ObsList, CString("ascii"));
    delete(P_CS_ObsList);


    if (CS_A2_FitsFileNames_In(i_file, I_Pos_RadObs).AToI() < 20){
/*      Array<double, 2> D_A2_ApertureCenters(2,2);
      if (!F_Image.GetApertureCenters(D_A2_ApertureCenters)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.GetApertureCenters(D_A2_ApertureCenters) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      Array<double, 1> D_A1_Center(2);
      if (CS_A2_FitsFileNames_In.cols() < 5){
        D_A1_Center(0) = D_A2_ApertureCenters(CS_A2_FitsFileNames_In(i_file, 1).AToI(), 0);
        D_A1_Center(1) = D_A2_ApertureCenters(CS_A2_FitsFileNames_In(i_file, 1).AToI(), 1);
        I_Pos_RadObs = 2;
        I_Pos_RadSky = 3;
      }
      else{
        D_A1_Center(0) = CS_A2_FitsFileNames_In(i_file, 1).AToI();
        D_A1_Center(1) = CS_A2_FitsFileNames_In(i_file, 2).AToI();
      }
      Array<double, 2> D_A2_NearestNeighbours(2,2);*/
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: Starting FindNearestNeighbours(D_A1_Center = " << D_A1_Center << ", D_A2_ApertureCenters, " << CS_A2_FitsFileNames_In(i_file, 4).AToI() * 6 + 1 << ",...)" << endl;
      #endif
      int I_Radius = CS_A2_FitsFileNames_In(i_file, I_Pos_RadSky).AToI();
      int I_NNeighbours = I_Radius * 6;
      do{
	I_Radius = I_Radius - 1;
	I_NNeighbours += I_Radius * 6;
      } while (I_Radius > 0);
      I_NNeighbours++;
      cout << "MGaussExtract_Obs_Sky::main: I_NNeighbours = " << I_NNeighbours << endl;
      if (!F_Image.FindNearestNeighbours(D_A1_Center,
                                         D_A2_ApertureCenters,
                                         I_NNeighbours,
                                         I_A1_AreaTemp,
                                         D_A2_NearestNeighbours,
                                         I_A1_Apertures_Sky)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.FindNearestNeighbours(D_A1_Center=" << D_A1_Center << ", D_A2_ApertureCenters, " << CS_A2_FitsFileNames_In(i_file, 3).AToI() * 6 + 1 << ", D_A2_NearestNeighbours, I_A1_Apertures_Object) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      if (!F_Image.Remove_SubArrayFromArray(I_A1_Apertures_Sky, I_A1_Apertures_Object)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: Remove_SubArrayFromArray(I_A1_Apertures_Sky, I_A1_Apertures_Object) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
    }
    else{
      if (!F_Image.FindApsInRing(CS_A2_FitsFileNames_In(i_file, 1).AToI(),
                                 CS_A2_FitsFileNames_In(i_file, 2).AToI(),
                                 CS_A2_FitsFileNames_In(i_file, 3).AToI(),
                                 CS_A2_FitsFileNames_In(i_file, I_Pos_RadSky).AToI(),
                                 I_A1_AreaTemp,
                                 I_A1_Apertures_Sky)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: " << CS_A1_FitsFileNames_In(i_file) << ".FindApsInRing(" << CS_A2_FitsFileNames_In(i_file, 1) << ", " << CS_A2_FitsFileNames_In(i_file, 2) << ", " << CS_A2_FitsFileNames_In(i_file, I_Pos_RadSky) << ", " << CS_A2_FitsFileNames_In(i_file, I_Pos_RadSky) << ") returned FALSE " << endl;
        exit(EXIT_FAILURE);
      }
    }
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: I_A1_Apertures_Sky = " << I_A1_Apertures_Sky << endl;
    #endif
    CString *P_CS_SkyList = CS_A1_FitsFileNames_In(i_file).SubString(0, CS_A1_FitsFileNames_In(i_file).LastCharPos('.')-1);
    P_CS_SkyList->Add("_apsSky.list");
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: P_CS_SkyList set to <" << *P_CS_SkyList << ">" << endl;
    #endif
    F_Image.WriteArrayToFile(I_A1_Apertures_Sky, *P_CS_SkyList, CString("ascii"));
    delete(P_CS_SkyList);
//    exit(EXIT_FAILURE);

//  Array<double, 1> D_A1_YLow(1);
//  D_A1_YLow(0) = 1;
//  F_Image.Set_YLow(D_A1_YLow);

//    cout << "MGaussExtract_Obs_Sky::main: P_CS_ErrIn = " << *P_CS_ErrIn << ")" << endl;
//    if (P_CS_ErrIn->GetLength() > 1){
//    /// Set ErrFileName_In
//      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.SetErrFileName(" << CS_A1_ErrIn(i_file) << ")" << endl;
//      if (!F_Image.SetErrFileName(CS_A1_ErrIn(i_file)))
//      {
//        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetErrFileName(" << CS_A1_ErrIn(i_file) << ") returned FALSE!" << endl;
//        exit(EXIT_FAILURE);
//      }

      /// Read Error image
//      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.ReadErrArray()" << endl;
//      if (!F_Image.ReadErrArray())
//      {
//        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.ReadErrArray() returned FALSE!" << endl;
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
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.MkProfIm(): time = " << seconds << endl;
    #endif

    /// D_A1_SDevLimits_In(0) = minimum standard deviation of Gauss curve
    /// D_A1_SDevLimits_In(1) = maximum standard deviation of Gauss curve
    /// D_A1_MeanLimits_In(0) = maximum difference to the left of aperture center
    /// D_A1_MeanLimits_In(1) = maximum difference to the right of aperture center
    if (!F_Image.MPFitThreeGaussExtract(F_Image.GetPixArray(),
                                        D_A1_SDevLimits,
                                        D_A1_MeanLimits,
                                        B_WithBackground,
                                        CS_A1_Args,
                                        PP_Args)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.MPFitThreeGaussExtract() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    seconds = time(NULL) - seconds;
    cout << "MGaussExtract_Obs_Sky::main: MPFitThreeGaussExtract returned true after " << seconds << " seconds" << endl;

    /// Set CS_FitsFileName_In
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_OutImage.SetFileName(" << CS_A1_FitsFileNames_In(i_file) << ")" << endl;
    #endif
    if (!F_OutImage.SetFileName(CS_A1_FitsFileNames_In(i_file)))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName(" << CS_A1_FitsFileNames_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    F_ErrImage.SetFileName(CS_A1_FitsFileNames_In(i_file));

    ///Read FitsFile
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_OutImage.ReadArray()" << endl;
    #endif
    if (!F_OutImage.ReadArray())
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.ReadArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    F_ErrImage.ReadArray();

    if (!F_OutImage.SetDatabaseFileName(CS_A1_DBFileNames_In(i_file))){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetDatabaseFileName(" << CS_A1_DBFileNames_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_OutImage.ReadDatabaseEntry()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.ReadDatabaseEntry() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_OutImage.CalcTraceFunctions()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.CalcTraceFunctions() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    if (!F_ErrImage.SetDatabaseFileName(CS_A1_DBFileNames_In(i_file))){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.SetDatabaseFileName(" << CS_A1_DBFileNames_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.ReadDatabaseEntry()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.ReadDatabaseEntry() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.CalcTraceFunctions()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.CalcTraceFunctions() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }


    /// Write MaskOut 2D
//    if (P_CS_MaskOut->GetLength() > 1){
      if (!F_OutImage.SetFileName(CS_A1_MaskOut(i_file)))
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: Starting to write MaskOut" << endl;
      #endif
      Array<int, 2> I_A2_MaskArray(F_Image.GetNRows(), F_Image.GetNCols());
      I_A2_MaskArray = F_Image.GetMaskArray();
      Array<double, 2> D_A2_MaskArray(F_Image.GetNRows(), F_Image.GetNCols());
      D_A2_MaskArray = 1. * I_A2_MaskArray;
      F_OutImage.GetPixArray() = D_A2_MaskArray;
      if (!F_OutImage.WriteArray())
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
//    }

    CString CS_FitsFileName_Out(" ");
    CS_FitsFileName_Out.Set(CS_ImageName_ApsRoot);
    CS_FitsFileName_Out.Add(CString(".fits"));

    /// Set CS_FitsFileName_Out
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_OutImage.SetFileName(" << CS_FitsFileName_Out << ")" << endl;
    #endif
    if (!F_OutImage.SetFileName(CS_FitsFileName_Out))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName(" << CS_FitsFileName_Out << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// change size of F_OutImage to (NApertures x NRows)
    if (!F_OutImage.SetNCols(F_Image.GetNRows()))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetNCols(" << F_Image.GetNRows() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.SetNCols(F_Image.GetNRows()))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.SetNCols(" << F_Image.GetNRows() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

//    if (!F_OutImage.SetNRows(P_I_A1_Apertures->size()))
    if (!F_OutImage.SetNRows(F_Image.Get_NApertures()))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetNRows(" << F_Image.Get_NApertures() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
//    F_ErrImage.SetNRows(P_I_A1_Apertures->size());
    if (!F_ErrImage.SetNRows(F_Image.Get_NApertures()))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.SetNRows(" << F_Image.Get_NApertures() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

//    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
//      F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetSpec()((*P_I_A1_Apertures)(i_ap), Range::all());
    F_OutImage.GetPixArray() = F_Image.GetLastExtracted();
//    if (!F_OutImage.WriteArray()){
//      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
//      exit(EXIT_FAILURE);
//    }
        
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Write spectra to individual files" << endl;
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": I_A1_AperturesToExtract = " << I_A1_AperturesToExtract << endl;
    #endif
    if (!F_OutImage.WriteApertures(CS_ImageName_ApsRoot, CS_A1_ApertureFitsFileNames, I_A1_AperturesToExtract)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteApertures() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    int I_NInd = 0;
    Array<int, 1> I_A1_Index(1);
    Array<int, 1> *P_I_A1_IndexWhere = CS.Where(CS_A1_ApertureFitsFileNames, CString(" "));
    if (max(*P_I_A1_IndexWhere) > 0){
      if (!F_Image.GetIndex(*P_I_A1_IndexWhere, I_NInd, I_A1_Index)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: GetIndex(*P_I_A1_IndexWhere = " << *P_I_A1_IndexWhere << ", I_NInd = " << I_NInd << ", I_A1_Index) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: I_NInd = " << I_NInd << ": I_A1_Index = " << I_A1_Index << endl;
      #endif
      if (I_NInd > 0){
        if (!CS.RemoveElementsFromArray(CS_A1_ApertureFitsFileNames, I_A1_Index)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: RemoveElementsFromArray(CS_A1_ApertureFitsFileNames, I_A1_Index=" << I_A1_Index << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        Array<int, 1> I_A1_ApsToRemove(I_NInd);
        for (int i_el=0; i_el<I_NInd; i_el++){
          I_A1_ApsToRemove(i_el) = I_A1_AperturesToExtract(I_A1_Index(i_el));
        }
        if (!F_Image.Remove_SubArrayFromArray(I_A1_Apertures_Object, I_A1_ApsToRemove)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: Remove_SubArrayFromArray(I_A1_Apertures_Object, I_A1_ApsToRemove=" << I_A1_ApsToRemove << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        if (!F_Image.Remove_SubArrayFromArray(I_A1_Apertures_Sky, I_A1_ApsToRemove)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: Remove_SubArrayFromArray(I_A1_Apertures_Sky, I_A1_ApsToRemove=" << I_A1_ApsToRemove << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        if (!F_Image.Remove_ElementsFromArray(I_A1_AperturesToExtract, I_A1_Index)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: RemoveElementsFromArray(I_A1_AperturesToExtract, I_A1_Index=" << I_A1_Index << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: CS_A1_ApertureFitsFileNames = " << CS_A1_ApertureFitsFileNames << endl;
      #endif
    }  
    delete(P_I_A1_IndexWhere);
//    exit(EXIT_FAILURE);

    CString CS_ErrImageName_Aps_Root(" ");
    CS_ErrImageName_Aps_Root.Set(CS_ImageName_ApsRoot);
    CS_ErrImageName_Aps_Root.Add(CString("Err"));
    F_ErrImage.GetPixArray() = F_Image.GetErrorsEc();
    CString CS_ErrEc(" ");
    CS_ErrEc.Set(CS_ImageName_ApsRoot);
    CS_ErrEc.Add(CString("Err.fits"));
    if (!F_ErrImage.SetFileName(CS_ErrEc)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.SetFileName(" << CS_ErrEc << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.WriteArray()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.WriteApertures(CS_ErrImageName_Aps_Root, CS_A1_ApertureFitsFileNamesErr, I_A1_AperturesToExtract)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.WriteApertures() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: CS_A1_ApertureFitsFileNamesErr = " << CS_A1_ApertureFitsFileNamesErr << endl;
    #endif
    P_I_A1_IndexWhere = CS.Where(CS_A1_ApertureFitsFileNamesErr, CString(" "));
    if (max(*P_I_A1_IndexWhere) > 0){
      if (!F_Image.GetIndex(*P_I_A1_IndexWhere, I_NInd, I_A1_Index)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: 2. GetIndex(*P_I_A1_IndexWhere = " << *P_I_A1_IndexWhere << ", I_NInd = " << I_NInd << ", I_A1_Index) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: 2. I_NInd = " << I_NInd << ": I_A1_Index = " << I_A1_Index << endl;
      #endif
      if (I_NInd > 0){
        if (!CS.RemoveElementsFromArray(CS_A1_ApertureFitsFileNamesErr, I_A1_Index)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: RemoveElementsFromArray(CS_A1_ApertureFitsFileNamesErr, I_A1_Index=" << I_A1_Index << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        if (!CS.RemoveElementsFromArray(CS_A1_ApertureFitsFileNames, I_A1_Index)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: 2. RemoveElementsFromArray(CS_A1_ApertureFitsFileNames, I_A1_Index=" << I_A1_Index << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        Array<int, 1> I_A1_ApsToRemove(I_NInd);
        for (int i_el=0; i_el<I_NInd; i_el++){
          I_A1_ApsToRemove(i_el) = I_A1_AperturesToExtract(I_A1_Index(i_el));
        }
        if (!F_Image.Remove_SubArrayFromArray(I_A1_Apertures_Object, I_A1_ApsToRemove)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: Remove_SubArrayFromArray(I_A1_Apertures_Object, I_A1_ApsToRemove=" << I_A1_ApsToRemove << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        if (!F_Image.Remove_SubArrayFromArray(I_A1_Apertures_Sky, I_A1_ApsToRemove)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: Remove_SubArrayFromArray(I_A1_Apertures_Sky, I_A1_ApsToRemove=" << I_A1_ApsToRemove << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        if (!F_Image.Remove_ElementsFromArray(I_A1_AperturesToExtract, I_A1_Index)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: 2. RemoveElementsFromArray(I_A1_AperturesToExtract, I_A1_Index=" << I_A1_Index << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
      }
    }
    delete(P_I_A1_IndexWhere);
    if (CS_A1_ApertureFitsFileNames.size() != CS_A1_ApertureFitsFileNamesErr.size()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: CS_A1_ApertureFitsFileNames.size(=" << CS_A1_ApertureFitsFileNames.size() << ") != CS_A1_ApertureFitsFileNamesErr.size(=" << CS_A1_ApertureFitsFileNamesErr.size() << ")" << endl;
      exit(EXIT_FAILURE);
    }
    
/*    CS_ErrImageName_Aps_Root.Set(CS_ImageName_ApsRoot);
    CS_ErrImageName_Aps_Root.Add(CString("ErrFit"));
    F_ErrImage.GetPixArray() = F_Image.GetErrorsEcFit();
    if (!F_ErrImage.WriteApertures(CS_ErrImageName_Aps_Root, CS_A1_ApertureFitsFileNamesErr, I_A1_AperturesToExtract)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.WriteApertures() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    P_I_A1_IndexWhere = CS.Where(CS_A1_ApertureFitsFileNamesErr, CString(" "));
    if (max(*P_I_A1_IndexWhere) > 0){
      if (!F_Image.GetIndex(*P_I_A1_IndexWhere, I_NInd, I_A1_Index)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: 33. GetIndex(*P_I_A1_IndexWhere = " << *P_I_A1_IndexWhere << ", I_NInd = " << I_NInd << ", I_A1_Index) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      cout << "MGaussExtract_Obs_Sky::main: 3. I_NInd = " << I_NInd << ": I_A1_Index = " << I_A1_Index << endl;
      if (I_NInd > 0){
        if (!CS.RemoveElementsFromArray(CS_A1_ApertureFitsFileNamesErr, I_A1_Index)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: 2. RemoveElementsFromArray(CS_A1_ApertureFitsFileNamesErr, I_A1_Index=" << I_A1_Index << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
      }
    }
    delete(P_I_A1_IndexWhere);
    if (CS_A1_ApertureFitsFileNames.size() != CS_A1_ApertureFitsFileNamesErr.size()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: 2. CS_A1_ApertureFitsFileNames.size(=" << CS_A1_ApertureFitsFileNames.size() << ") != CS_A1_ApertureFitsFileNamesErr.size(=" << CS_A1_ApertureFitsFileNamesErr.size() << ")" << endl;
      exit(EXIT_FAILURE);
    }
  */  
//    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
//      F_ErrImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetErrorsEc()((*P_I_A1_Apertures)(i_ap), Range::all());
//    F_ErrImage.GetPixArray() = F_Image.GetErrorsEc();

    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Apply dispersion correction: creating list" << endl;
    #endif
    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNames, CString(".fits"), CString("D.text"), CS_A1_TextFiles_EcD_Out)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: 1. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    //if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNames, CString(".fits"), CString("D_Flux.text"), CS_A1_TextFiles_EcDFlux_Out)){
    //  cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: 1. StrReplaceInList returned FALSE!" << endl;
    //  exit(EXIT_FAILURE);
    //}
    CString CS_TextFiles_EcD(" ");
    CS_TextFiles_EcD.Set(CS_ImageName_ApsRoot);
    CS_TextFiles_EcD.Add(CString("D_text.list"));

    CS_FitsFileName_In.WriteStrListToFile(CS_A1_TextFiles_EcD_Out,CS_TextFiles_EcD);
//    for (int i_t = 0; i_t < CS_A1_TextFiles_EcD_Out.size(); i_t++){
//      cout << "MGaussExtract_Obs_Sky::main: CS_A1_ApertureFitsFileNames(" << i_t << ") = " << CS_A1_ApertureFitsFileNames(i_t) << endl;
//      cout << "MGaussExtract_Obs_Sky::main: CS_A1_TextFiles_EcD_Out(" << i_t << ") = " << CS_A1_TextFiles_EcD_Out(i_t) << endl;
//    }
//    exit(EXIT_FAILURE);

    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNamesErr, CString(".fits"), CString("D.text"), CS_A1_TextFiles_Err_EcD_Out)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: 1. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Apply dispersion correction: CS_A1_TextFiles_EcD_Out = " << CS_A1_TextFiles_EcD_Out << endl;
    #endif
    CString CS_ErrTextFiles_EcD(" ");
    CS_ErrTextFiles_EcD.Set(CS_ErrImageName_Aps_Root);
    CS_ErrTextFiles_EcD.Add(CString("D_text.list"));

    CS_FitsFileName_In.WriteStrListToFile(CS_A1_TextFiles_Err_EcD_Out,CS_ErrTextFiles_EcD);
    
    if ((fabs(D_A1_PixShifts(i_file)) < 0.000001) && CS_A1_PixShifts(i_file).EqualValue(CString("c"))){
      /// Find offset of A-band
      double D_WLen_ABand = 7615.;
      double D_X_Out = 0.;
      int I_ABand_StartPix = I_PixABandExpected - 10;
      int I_ABand_EndPix = I_PixABandExpected + 10;
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Trying to find offset for A-band" << endl;
      #endif
      Array<double, 1> *P_D_A1_YLow = F_Image.Get_YLow();
      Array<double, 1> *P_D_A1_YHigh = F_Image.Get_YHigh();
      Array<double, 1> *P_D_A1_YCenter = F_Image.Get_YCenter();
      Array<double, 2> D_A2_OutImage_PixArray(F_OutImage.GetNRows(), F_OutImage.GetNCols());
      D_A2_OutImage_PixArray = F_OutImage.GetPixArray();
      Array<double, 2> D_A2_OutImage_ErrArray(F_OutImage.GetNRows(), F_OutImage.GetNCols());
      D_A2_OutImage_ErrArray = F_Image.GetErrorsEc();
      Array<double, 1> D_A1_ABand_X(I_ABand_EndPix-I_ABand_StartPix + 1);
      Array<double, 1> D_A1_ABand_Y(I_ABand_EndPix-I_ABand_StartPix + 1);
      Array<double, 1> D_A1_ABand_Err(I_ABand_EndPix-I_ABand_StartPix + 1);
      double D_Const, D_Slope;
      Array<double, 2> D_A2_WLen_Photons(2,2);
      Array<int, 2> I_A2_ABand_Limited(3,2);
      Array<double, 2> D_A2_ABand_Limits(3,2);
      I_A2_ABand_Limited = 1;
      Array<double, 1> D_A1_ABand_Coeffs(3);
      D_A1_ABand_Coeffs = 0.;
      Array<double, 1> D_A1_ABand_ECoeffs(3);
      D_A1_ABand_ECoeffs = 0.;
      Array<double, 1> D_A1_ABand_Guess(3);
      Array<double, 1> D_A1_MeanValues(I_A1_AperturesToExtract.size());
      D_A1_MeanValues = 0.;
      for (int i_ap=0; i_ap<I_A1_AperturesToExtract.size(); i_ap++){
        #ifdef __DEBUG_MGAUSSEXTRACT__
          cout << "MGaussExtract_Obs_Sky::main: i_ap = " << i_ap << ": I_A1_AperturesToExtract(i_ap) = " << I_A1_AperturesToExtract(i_ap) << ": D_A2_OutImage_PixArray(I_A1_AperturesToExtract(i_ap), Range::aperture()) = " << D_A2_OutImage_PixArray(I_A1_AperturesToExtract(i_ap), Range((*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)),
                                                                      (*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap)))) << endl;
        #endif
        D_A1_MeanValues(i_ap) = mean(D_A2_OutImage_PixArray(I_A1_AperturesToExtract(i_ap), Range((*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)), 
              (*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap)))));
        #ifdef __DEBUG_MGAUSSEXTRACT__
          cout << "MGaussExtract_Obs_Sky::main: i_ap = " << i_ap << ": D_A1_MeanValues(i_ap) = " << D_A1_MeanValues(i_ap) << endl;
        #endif
  //      exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: D_A1_MeanValues = " << D_A1_MeanValues << endl;
      #endif
      for (int i_ap=0; i_ap<I_A1_AperturesToExtract.size(); i_ap++){
        if (fabs(mean(D_A2_OutImage_PixArray(I_A1_AperturesToExtract(i_ap), Range((*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)), 
          (*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap))))) - max(D_A1_MeanValues)) < 0.001){

          /// Find coeffs file
          bool B_FoundApNum = false;
          int I_CoeffFile = 0;
          Array<CString, 1> CS_A1_CoeffLines(1); 
          Array<double, 1> D_A1_WaveFitCoeffs(2);
          do{
            CString *P_CS_Tmp = CS.IToA(I_A1_AperturesToExtract(i_ap));
            //cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": P_CS_Tmp = " << *P_CS_Tmp << endl;
            CString *P_CS_Sub = CS_A1_TextFiles_Coeffs_In(I_CoeffFile).SubString(CS_A1_TextFiles_Coeffs_In(I_CoeffFile).LastStrPos(CString("_ap"))+3);
            if (P_CS_Sub->StrPos(*P_CS_Tmp) == 0){
              B_FoundApNum = true;
              if (!CS.ReadFileLinesToStrArr(CS_A1_TextFiles_Coeffs_In(I_CoeffFile), CS_A1_CoeffLines)){
                cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": ERROR: ReadFileLinesToStrArr(" << CS_A1_TextFiles_Coeffs_In(I_CoeffFile) << ") returned FALSE" << endl;
                exit(EXIT_FAILURE);
              }
              D_A1_WaveFitCoeffs.resize(CS_A1_CoeffLines.size()-1);
              for (int i_line=0; i_line<CS_A1_CoeffLines.size()-1; i_line++){
                if (!CS_A1_CoeffLines(i_line).AToD(D_A1_WaveFitCoeffs(i_line))){
                  cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": ERROR: CS_A1_CoeffLines(i_line=" << i_line << ")(=" << CS_A1_CoeffLines(i_line) << ").AToD(D_A1_WaveFitCoeffs(i_line)) returned FALSE" << endl;
                  exit(EXIT_FAILURE);
                }
              }
              #ifdef __DEBUG_MGAUSSEXTRACT__
                cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_WaveFitCoeffs = " << D_A1_WaveFitCoeffs << endl;
              #endif
            }
            else{
              I_CoeffFile++;
            }
            delete(P_CS_Tmp);
            delete(P_CS_Sub);
          } while (!B_FoundApNum);
//          cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": Reading CS_A1_TextFiles_EcD_Out(i_ap=" << i_ap << ") = " << CS_A1_TextFiles_EcD_Out(i_ap) << endl;
//          if (!F_Image.ReadFileToDblArr(CS_A1_TextFiles_EcD_Out(i_ap), D_A2_WLen_Photons, CString(" "))){
//            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": ERROR: ReadFileToDblArr(" << CS_A1_TextFiles_EcD_Out(i_ap) << ") returned FALSE" << endl;
//            exit(EXIT_FAILURE);
//          }
      
          Array<double, 1> D_A1_Ap((*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap)) - (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)) + 1);
          D_A1_Ap = D_A2_OutImage_PixArray(I_A1_AperturesToExtract(i_ap), Range((*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)),
                                                                              (*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap))));
          #ifdef __DEBUG_MGAUSSEXTRACT__
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_Ap = " << D_A1_Ap << endl;
          #endif
          Array<double, 1> D_A1_ErrAp((*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap)) - (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)) + 1);
          D_A1_ErrAp = D_A2_OutImage_ErrArray(I_A1_AperturesToExtract(i_ap), Range((*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)),
                                                                                 (*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap))));
          #ifdef __DEBUG_MGAUSSEXTRACT__
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_ErrAp = " << D_A1_ErrAp << endl;
          #endif
          Array<double, 1> *P_D_A1_X = F_Image.DIndGenArr((*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap)) - (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)));
          #ifdef __DEBUG_MGAUSSEXTRACT__
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": P_D_A1_X = " << *P_D_A1_X << endl;
          #endif
          
          /// Remove linear part:
          D_A1_ABand_X = (*P_D_A1_X)(Range(I_ABand_StartPix, I_ABand_EndPix));
          D_A1_ABand_Y = D_A1_Ap(Range(I_ABand_StartPix, I_ABand_EndPix));
          
          Array<double, 2> D_A2_Out(D_A1_ABand_X.size(), 2);
          D_A2_Out(Range::all(), 0) = D_A1_ABand_X;
          D_A2_Out(Range::all(), 1) = D_A1_ABand_Y;
          CString CS_Out(CS_A1_ApertureFitsFileNames(i_ap));
          CS_Out.Add(CString("_Aband_orig.dat"));
          F_Image.WriteArrayToFile(D_A2_Out, CS_Out, CString("ascii"));
          
          D_A1_ABand_Err = D_A1_ErrAp(Range(I_ABand_StartPix, I_ABand_EndPix));
          D_Slope = (D_A1_ABand_Y(D_A1_ABand_Y.size()-1) - D_A1_ABand_Y(0))
                  / (D_A1_ABand_X(D_A1_ABand_X.size()-1) - D_A1_ABand_X(0));
          D_Const = D_A1_ABand_Y(0) - (D_A1_ABand_X(0) * D_Slope);
          #ifdef __DEBUG_MGAUSSEXTRACT__
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_Slope = " << D_Slope << ", D_Const = " << D_Const << endl;
          #endif
          for (int i_pix=0; i_pix<D_A1_ABand_X.size(); i_pix++){
            D_A1_ABand_Y(i_pix) = D_A1_ABand_Y(i_pix) - ((D_Slope * D_A1_ABand_X(i_pix)) + D_Const);
          }
          CS_Out.Set(CS_A1_ApertureFitsFileNames(i_ap));
          CS_Out.Add(CString("_Aband_1st.dat"));
          D_A2_Out(Range::all(), 1) = D_A1_ABand_Y;
          F_Image.WriteArrayToFile(D_A2_Out, CS_Out, CString("ascii"));
          int I_MinIndex = (minIndex(D_A1_ABand_Y))(0);
          Array<double, 1> D_A1_ABand_X_Temp(7);
          Array<double, 1> D_A1_ABand_Y_Temp(7);
          Array<double, 1> D_A1_ABand_Err_Temp(7);
          D_A1_ABand_X_Temp = (*P_D_A1_X)(Range(I_ABand_StartPix+I_MinIndex-3, I_ABand_StartPix+I_MinIndex+3));
          D_A1_ABand_Y_Temp = D_A1_Ap(Range(I_ABand_StartPix+I_MinIndex-3, I_ABand_StartPix+I_MinIndex+3));
          D_A1_ABand_Err_Temp = D_A1_ErrAp(Range(I_ABand_StartPix+I_MinIndex-3, I_ABand_StartPix+I_MinIndex+3));
          D_A1_ABand_X.resize(D_A1_ABand_X_Temp.size());
          D_A1_ABand_Y.resize(D_A1_ABand_X_Temp.size());
          D_A1_ABand_Err.resize(D_A1_ABand_Err_Temp.size());
          D_A1_ABand_X = D_A1_ABand_X_Temp;
          D_A1_ABand_Y = D_A1_ABand_Y_Temp;
          D_A1_ABand_Err = D_A1_ABand_Err_Temp;
          
          D_A2_Out.resize(D_A1_ABand_X.size(), 2);
          D_A2_Out(Range::all(), 0) = D_A1_ABand_X;
          D_A2_Out(Range::all(), 1) = D_A1_ABand_Y;
          CS_Out.Set(CS_A1_ApertureFitsFileNames(i_ap));
          CS_Out.Add(CString("_Aband_7orig.dat"));
          F_Image.WriteArrayToFile(D_A2_Out, CS_Out, CString("ascii"));
          
          D_Slope = (D_A1_ABand_Y(D_A1_ABand_Y.size()-1) - D_A1_ABand_Y(0))
          / (D_A1_ABand_X(D_A1_ABand_X.size()-1) - D_A1_ABand_X(0));
          D_Const = D_A1_ABand_Y(0) - (D_A1_ABand_X(0) * D_Slope);
          #ifdef __DEBUG_MGAUSSEXTRACT__
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_Slope = " << D_Slope << ", D_Const = " << D_Const << endl;
          #endif
          for (int i_pix=0; i_pix<D_A1_ABand_X.size(); i_pix++){
            D_A1_ABand_Y(i_pix) = D_A1_ABand_Y(i_pix) - ((D_Slope * D_A1_ABand_X(i_pix)) + D_Const);
          }
          CS_Out.Set(CS_A1_ApertureFitsFileNames(i_ap));
          CS_Out.Add(CString("_Aband_2nd.dat"));
          D_A2_Out(Range::all(), 1) = D_A1_ABand_Y;
          F_Image.WriteArrayToFile(D_A2_Out, CS_Out, CString("ascii"));
          
          #ifdef __DEBUG_MGAUSSEXTRACT__
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_ABand_X = " << D_A1_ABand_X << endl;
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_ABand_Y = " << D_A1_ABand_Y << endl;
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_ABand_Err = " << D_A1_ABand_Err << endl;
          #endif
          /// Fit in pixel space
          D_A2_ABand_Limits(0,1) = 0.;///area/peak, centroid, sigma
          D_A2_ABand_Limits(0,0) = min(D_A1_ABand_Y) + (min(D_A1_ABand_Y)/2.);
          if (D_A2_ABand_Limits(0,1) < D_A2_ABand_Limits(0,0)){
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": ERROR: D_A2_ABand_Limits(0,1)=" << D_A2_ABand_Limits(0,1) << " < D_A2_ABand_Limits(0,0)=" << D_A2_ABand_Limits(0,0) << endl;
            exit(EXIT_FAILURE);
          }
          D_A2_ABand_Limits(1,0) = min(D_A1_ABand_X);
          D_A2_ABand_Limits(1,1) = max(D_A1_ABand_X);
          if (D_A2_ABand_Limits(1,1) < D_A2_ABand_Limits(1,0)){
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": ERROR: D_A2_ABand_Limits(1,1)=" << D_A2_ABand_Limits(1,1) << " < D_A2_ABand_Limits(1,0)=" << D_A2_ABand_Limits(1,0) << endl;
            exit(EXIT_FAILURE);
          }
          D_A2_ABand_Limits(2,0) = 0.9;
          D_A2_ABand_Limits(2,1) = 3.;
//      if (D_A2_ABand_Limits(2,1) < D_A2_ABand_Limits(2,0)){
//        cout << "MGaussExtract_Obs_Sky::main: ERROR: D_A2_ABand_Limits(2,1)=" << D_A2_ABand_Limits(2,1) << " < D_A2_ABand_Limits(2,0)=" << D_A2_ABand_Limits(2,0) << endl;
//        exit(EXIT_FAILURE);
//      }
          D_A1_ABand_Guess(0) = min(D_A1_ABand_Y);
          D_A1_ABand_Guess(1) = D_A1_ABand_X(minIndex(D_A1_ABand_Y));
          D_A1_ABand_Guess(2) = 1.4;
          #ifdef __DEBUG_MGAUSSEXTRACT__
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_ABand_X = " << D_A1_ABand_X << endl;
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_ABand_Y = " << D_A1_ABand_Y << endl;
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_ABand_Err = " << D_A1_ABand_Err << endl;
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_ABand_Guess = " << D_A1_ABand_Guess << endl;
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A2_ABand_Limits = " << D_A2_ABand_Limits << endl;
          #endif
          D_A1_ABand_Err = where(fabs(D_A1_ABand_Err) < 0.000001, 1., D_A1_ABand_Err);
          
          if (!MPFitGaussLim(D_A1_ABand_X,
                             D_A1_ABand_Y,
                             D_A1_ABand_Err,
                             D_A1_ABand_Guess,
                             I_A2_ABand_Limited,
                             D_A2_ABand_Limits,
                             false,
                             false,
                             D_A1_ABand_Coeffs,
                             D_A1_ABand_ECoeffs)){
            cout << "MGaussExtract_Obs_Sky::main: ERROR: MPFitGaussLim(ABand) returned FALSE" << endl;
            exit(EXIT_FAILURE);
          }
          #ifdef __DEBUG_MGAUSSEXTRACT__
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A1_ABand_Coeffs = " << D_A1_ABand_Coeffs << endl;
          #endif
          if (!F_Image.PolyRoot(D_A1_WaveFitCoeffs,
                                D_WLen_ABand,
                                D_A1_ABand_Coeffs(1),
                                1.,
                                0.1,
                                CString("Poly"),
                                D_X_Out)){
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": ERROR: PolyRoot returned FALSE" << endl;
            exit(EXIT_FAILURE);
          }
          #ifdef __DEBUG_MGAUSSEXTRACT__
            cout << "MGaussExtract_Obs_Sky::main: I_A1_AperturesToExtract(i_ap=" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_X_Out = " << D_X_Out << endl;
          #endif
          D_A1_PixShifts(i_file) = D_X_Out - D_A1_ABand_Coeffs(1);
//          exit(EXIT_FAILURE);
        }/// end if (fabs(mean(D_A2_OutImage_PixArray(I_A1_AperturesToExtract(i_ap), Range((*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)), 
        ///(*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap))))) - max(D_A1_MeanValues)) < 0.001){
      }/// end for (int i_ap=0; i_ap<I_A1_AperturesToExtract.size(); i_ap++){
      
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Apply dispersion correction: Starting DispCorList" << endl;
      #endif
      delete(P_D_A1_YCenter);
      delete(P_D_A1_YHigh);
      delete(P_D_A1_YLow);
    }/// end if ((fabs(D_A1_PixShifts(i_file)) < 0.000001) && CS_A1_PixShifts(i_file).EqualValue(CString("c"))){
    
    /// Apply wavelength calibration to all apertures of input image  
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Applying dispersion correction: Starting DispCorList" << endl;
    #endif
    if (!F_OutImage.DispCorList(CS_A1_TextFiles_Coeffs_In, CS_A1_TextFiles_EcD_Out, D_MaxRMS_In, D_A1_PixShifts(i_file), I_A1_AperturesToExtract)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: DispCorList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.DispCorList(CS_A1_TextFiles_Coeffs_In, CS_A1_TextFiles_Err_EcD_Out, D_MaxRMS_In, D_A1_PixShifts(i_file), I_A1_AperturesToExtract)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: DispCorList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    
//    exit(EXIT_FAILURE);
//    if (!F_OutImage.PhotonsToFlux(CS_A1_TextFiles_EcD_Out, CS_A1_TextFiles_EcDFlux_Out, , I_A1_AperturesToExtract)){
//      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: DispCorList returned FALSE!" << endl;
//      exit(EXIT_FAILURE);
//    }

    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Rebin spectra: Creating File List" << endl;
    #endif
    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNames, CString(".fits"), CString("DR.text"), CS_A1_TextFiles_EcDR_Out)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: 2. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNamesErr, CString(".fits"), CString("DR.text"), CS_A1_TextFiles_Err_EcDR_Out)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: 2. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Rebin spectra: CS_A1_TextFiles_EcDR_Out = " << CS_A1_TextFiles_EcDR_Out << endl;
    #endif

    CS_FitsFileNameEcDR_Out.Set(CS_ImageName_ApsRoot);
    CS_FitsFileNameEcDR_Out.Add(CString("DR.fits"));
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Rebin spectra: Starting RebinTextList" << endl;
    #endif
    if (!F_Image.RebinTextList(CS_A1_TextFiles_EcD_Out, CS_A1_TextFiles_EcDR_Out, CS_FitsFileNameEcDR_Out, D_WLen_Start, D_WLen_End, D_DWLen, true)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: RebinTextList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    CS_FitsFileNameErrEcDR_Out.Set(CS_ErrImageName_Aps_Root);
    CS_FitsFileNameErrEcDR_Out.Add(CString("DR.fits"));
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Rebin err spectra: Starting RebinTextList" << endl;
    #endif
    if (!F_Image.RebinTextList(CS_A1_TextFiles_Err_EcD_Out, CS_A1_TextFiles_Err_EcDR_Out, CS_FitsFileNameErrEcDR_Out, D_WLen_Start, D_WLen_End, D_DWLen, true)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: RebinTextList returned FALSE!" << endl;
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
      cout << "MGaussExtract_Obs_Sky::main: ERROR: CF_EcDR.SetFileName(" << CS_FitsFileNameEcDR_Out << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CF_ErrEcDR.SetFileName(CS_FitsFileNameErrEcDR_Out)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: CF_ErrEcDR.SetFileName(" << CS_FitsFileNameErrEcDR_Out << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CF_EcDR.ReadArray()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: " << CS_FitsFileName_In << ".ReadArray() returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CF_ErrEcDR.ReadArray()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: " << CS_FitsFileName_In << ".ReadArray() returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    Array<double, 2> D_A2_Spec_Obs(I_A1_Apertures_Object.size(), CF_EcDR.GetNCols());
    Array<double, 2> D_A2_Err_Obs(I_A1_Apertures_Object.size(), CF_EcDR.GetNCols());

    ofstream *P_OFS_HTMLOneFile;    
    CString CS_ObjectPlotNameFluxCalib(CS_HTML);
    if (CS_ThroughputsList_In.GetLength() > 2){
      CString CS_PlotDir(CS_HTML);
      CString *P_CS_PlotDir = CS_A1_TextFiles_EcDR_Out(0).SubString(0,CS_A1_TextFiles_EcDR_Out(0).LastStrPos(CString("/")));
      CS_PlotDir.Add(*P_CS_PlotDir);
      delete(P_CS_PlotDir);
      if (!CS.MkDir(CS_PlotDir)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: MkDir(" << CS_PlotDir << ") returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      CS_HTML_FileName.Set(CS_PlotDir);
      CS_HTML_FileName.Add(CString("index.html"));
      P_OFS_HTMLOneFile = new ofstream(CS_HTML_FileName.Get());
      (*P_OFS_HTMLOneFile) << "<html><body><center>" << endl;
      CString *P_CS_PlotName = CS_ImageName_ApsRoot.SubString(CS_ImageName_ApsRoot.LastStrPos(CString("/"))+1);
      CS_ObjectPlotNameFluxCalib.Add(CS_ImageName_ApsRoot);
      delete(P_CS_PlotName);
      CS_ObjectPlotNameFluxCalib.Add(CString("DR_Obs-Sky_Sum_Flux_AirMassCorr_FluxCalib.png"));
      P_CS_PlotName = CS_ObjectPlotNameFluxCalib.SubString(CS_PlotDir.StrPos(CString("/"))+1);
      P_CS_PlotDir = CS_PlotDir.SubString(CS_PlotDir.StrPos(CString("/"))+1);
      (*P_OFS_html) << "<a href=\"" << *P_CS_PlotDir << "index.html\"><br> " << *P_CS_PlotName << "<br><img src=\"" << *P_CS_PlotName << "\"></a><br><hr><br>" << endl;
      cout << "P_CS_PlotDir = <" << *P_CS_PlotDir << ">" << endl;
      cout << "P_CS_PlotName = <" << *P_CS_PlotName << ">" << endl;
      delete(P_CS_PlotName);
      delete(P_CS_PlotDir);
//      (*P_OFS_html) << "</center></body></html>" << endl;
//      delete(P_OFS_html);
//      exit(EXIT_FAILURE);
    }
    for (int iaps=0; iaps<I_A1_Apertures_Object.size(); iaps++){
      D_A2_Spec_Obs(iaps, Range::all()) = CF_EcDR.GetPixArray()(iaps, Range::all());
      D_A2_Err_Obs(iaps, Range::all()) = CF_ErrEcDR.GetPixArray()(iaps, Range::all());
      
      /// plot result
#ifdef __WITH_PLOTS__
      if (CS_ThroughputsList_In.GetLength() > 2){
        CS_PlotName.Set(CS_HTML);
        CString *P_CS_PlotName = CS_A1_TextFiles_EcDR_Out(iaps).SubString(0,CS_A1_TextFiles_EcDR_Out(iaps).LastStrPos(CString(".")));
        CS_PlotName.Add(*P_CS_PlotName);
        delete(P_CS_PlotName);
        CS_PlotName.Add(CString("png"));
        P_CS_PlotName = CS_PlotName.SubString(CS_PlotName.LastStrPos(CString("/"))+1);
        (*P_OFS_HTMLOneFile) << CS_PlotName << "<br><img src=\"" << *P_CS_PlotName << "\"><br><hr><br>" << endl;
        delete(P_CS_PlotName);
      
        mglData MGLData1_Lambda;// = new mglData(2);
        MGLData1_Lambda.Link(D_A1_Lambda.data(), D_A1_Lambda.size());
        mglData MGLData1_SpecObs;// = new mglData(2);
        Array<double, 1> D_A1_YTemp(D_A2_Spec_Obs.cols());
        D_A1_YTemp = where(D_A1_Lambda < 4000., 0, D_A2_Spec_Obs(iaps, Range::all()));
//        cout << "MGaussExtract_Obs_Sky::main: D_A1_YTemp = " << D_A1_YTemp << endl;
        MGLData1_SpecObs.Link(D_A2_Spec_Obs(iaps, Range::all()).data(), D_A2_Spec_Obs.cols());
        
        mglGraph gr;
        gr.SetRanges(min(D_A1_Lambda),max(D_A1_Lambda),0,max(D_A1_YTemp));
        gr.Axis();
        gr.Label('y',"Photon Counts (rebinned)",0);
        gr.Label('x',"Wavelength [Angstroms]",0);
        
        gr.Plot(MGLData1_Lambda, MGLData1_SpecObs, "g");
        gr.Box();
        gr.Legend();
        gr.WriteFrame(CS_PlotName.Get());
        cout << "MGaussExtract_Obs_Sky::main: plotting " << CS_PlotName << endl;
//        exit(EXIT_FAILURE);
      }
#endif
    }
//    cout << "MGaussExtract_Obs_Sky::main: D_A2_Spec_Obs = " << D_A2_Spec_Obs << endl;
    cout << "MGaussExtract_Obs_Sky::main: I_A1_Apertures_Object = " << I_A1_Apertures_Object << endl;
    cout << "MGaussExtract_Obs_Sky::main: I_A1_Apertures_Sky = " << I_A1_Apertures_Sky << endl;
    Array<double, 2> D_A2_Spec_Sky(I_A1_Apertures_Sky.size(), CF_EcDR.GetNCols());
    Array<double, 2> D_A2_Err_Sky(I_A1_Apertures_Sky.size(), CF_EcDR.GetNCols());
    int i_aps = 0;
    for (int iaps=I_A1_Apertures_Object.size(); iaps<I_A1_Apertures_Object.size()+I_A1_Apertures_Sky.size(); iaps++){
      D_A2_Spec_Sky(i_aps, Range::all()) = CF_EcDR.GetPixArray()(iaps, Range::all());
      D_A2_Err_Sky(i_aps, Range::all()) = CF_ErrEcDR.GetPixArray()(iaps, Range::all());
      i_aps++;
    }
    cout << "MGaussExtract_Obs_Sky::main: D_A2_Spec_Sky = " << D_A2_Spec_Sky << endl;
    Array<double, 2> D_A1_Sky(1, D_A2_Spec_Obs.cols());
    D_A1_Sky = 0.;
    for (int ipix=0; ipix<D_A2_Spec_Obs.cols(); ipix++){
      D_A1_Sky(0, ipix) = CF_EcDR.Median(D_A2_Spec_Sky(Range::all(), ipix));
      D_A2_Spec_Obs(Range::all(), ipix) = D_A2_Spec_Obs(Range::all(), ipix) - D_A1_Sky(0, ipix);
    }
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: after sky subtraction: I_A1_Apertures_Object = " << I_A1_Apertures_Object << endl;
      cout << "MGaussExtract_Obs_Sky::main: after sky subtraction: I_A1_Apertures_Sky = " << I_A1_Apertures_Sky << endl;
      cout << "MGaussExtract_Obs_Sky::main: after sky subtraction: I_A1_AperturesToExtract = " << I_A1_AperturesToExtract << endl;
      cout << "MGaussExtract_Obs_Sky::main: after sky subtraction: D_A2_Spec_Obs = " << D_A2_Spec_Obs << endl;
    #endif
    if (!CF_EcDR.SetNRows(D_A2_Spec_Obs.rows())){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: CF_EcDR.SetNRows(" << D_A2_Spec_Obs.rows() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);      
    }
    CF_EcDR.GetPixArray() = D_A2_Spec_Obs;
    CString CS_Obs_Out(" ");
    CS_Obs_Out.Set(CS_ImageName_ApsRoot);
    CS_Obs_Out.Add(CString("DR_Obs-Sky.fits"));
    CF_EcDR.SetFileName(CS_Obs_Out);
    CF_EcDR.WriteArray();

    if (!CF_EcDR.SetNRows(1)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: CF_EcDR.SetNRows(1) returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    CF_EcDR.GetPixArray() = D_A1_Sky;
    CString CS_Sky_Out(" ");
    CS_Sky_Out.Set(CS_ImageName_ApsRoot);
    CS_Sky_Out.Add(CString("DR_SkyMedian.fits"));
    CF_EcDR.SetFileName(CS_Sky_Out);
    CF_EcDR.WriteArray();

    Array<double, 2> D_A1_Obs(1, D_A2_Spec_Obs.cols());
    Array<double, 1> D_A1_Weights(D_A2_Spec_Obs.rows());
//    cout << "MGaussExtract_Obs_Sky::main: D_A2_Spec_Obs(60, *) = " << D_A2_Spec_Obs(60,Range::all()) << endl;
    for (int i_spec=0; i_spec<D_A1_Weights.size(); i_spec++){
      D_A1_Weights(i_spec) = sum(D_A2_Spec_Obs(i_spec, Range::all()));
      if (D_A1_Weights(i_spec) > 0.)
        D_A1_Weights(i_spec) = sqrt(D_A1_Weights(i_spec));
      else
        D_A1_Weights(i_spec) = 0.;
    }
//    double D_Sum_Weights = sum(D_A1_Weights);
//    D_A1_Weights /= D_Sum_Weights;
//    D_A1_Weights *= D_A2_Spec_Obs.cols();
//    cout << "MGaussExtract_Obs_Sky::main: D_A1_Weights = " << D_A1_Weights << endl;
//    cout << "MGaussExtract_Obs_Sky::main: D_Sum_Weights = " << D_Sum_Weights << endl;
    for (int ipix=0; ipix<D_A1_Obs.cols(); ipix++){
      D_A1_Obs(0, ipix) = sum(D_A2_Spec_Obs(Range::all(), ipix));
//      cout << "No weights: D_A1_Obs(" << ipix << ") = " << D_A1_Obs(0,ipix) << endl;
//      D_A1_Obs(0, ipix) = 0;
//      for (int i_spec=0; i_spec<D_A1_Weights.size(); i_spec++){
//        D_A1_Obs(0,ipix) += D_A1_Weights(i_spec) * D_A2_Spec_Obs(i_spec, ipix);
//      }
//      cout << "With weights: D_A1_Obs(" << ipix << ") = " << D_A1_Obs(0,ipix) << endl;
    }
//    exit(EXIT_FAILURE);
    CF_EcDR.GetPixArray() = D_A1_Obs;
    CS_Obs_Out.Set(CS_ImageName_ApsRoot);
    CS_Obs_Out.Add(CString("DR_Obs-Sky_Sum.fits"));
    CF_EcDR.SetFileName(CS_Obs_Out);
    CF_EcDR.WriteArray();
//    CF_EcDR.WriteArrayToFile(D_A1_Obs, )

    D_A2_Spec_Obs.resize(I_NElements, 2);
    D_A2_Spec_Obs(Range::all(), 0) = D_A1_Lambda;
    D_A2_Spec_Obs(Range::all(), 1) = D_A1_Obs(0, Range::all());
    if (D_A1_Lambda(0) > D_A1_Lambda(1)){
      if (!CF_EcDR.Reverse(D_A2_Spec_Obs)){
	cout << "MGaussExtract_Obs_Sky::main: ERROR: Reverse(D_A2_Spec_Obs) returned FALSE" << endl;
	exit(EXIT_FAILURE);
      }
    }
    CS_Obs_Out.Set(CS_ImageName_ApsRoot);
    CS_Obs_Out.Add(CString("DR_Obs-Sky_Sum.text"));
    CF_EcDR.WriteArrayToFile(D_A2_Spec_Obs, CS_Obs_Out, CString("ascii"));

    Array<double, 2> D_A2_Spec_Obs_Flux(D_A2_Spec_Obs.rows(), D_A2_Spec_Obs.cols());    
    if (!CF_EcDR.PhotonsToFlux(D_A2_Spec_Obs,
                               D_A1_ExpTimes(i_file),
                               D_ATel,
                               D_A2_Spec_Obs_Flux)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: PhotonsToFlux(" << D_A2_Spec_Obs << ", " << D_A1_ExpTimes(i_file) << ", " << D_ATel << ", D_A2_Spec_Obs_Flux) returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    CS_Obs_Out.Set(CS_ImageName_ApsRoot);
    CS_Obs_Out.Add(CString("DR_Obs-Sky_Sum_Flux.text"));
    if (!CF_EcDR.WriteArrayToFile(D_A2_Spec_Obs_Flux, CS_Obs_Out, CString("ascii"))){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: WriteArrayToFile(" << D_A2_Spec_Obs_Flux << ", " << CS_Obs_Out << ", ascii) returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    
    /// Correct for airmass (atmospheric extinction)
    Array<double, 2> D_A2_Spec_Obs_Flux_AirMassCorr(D_A2_Spec_Obs.rows(), D_A2_Spec_Obs.cols());
    if (CS_AirMassList_In.GetLength() > 2){
      if (!CF_EcDR.RemoveAtmosphericExtinction(D_A2_Spec_Obs_Flux,
                                               D_A1_AirMasses(i_file),
                                               D_A2_AtmosphericExtinction,
                                               D_A2_Spec_Obs_Flux_AirMassCorr)){
        cout << "MGaussExtract_Obs_Sky::main: i_file=" << i_file << ": ERROR: RemoveAtmosphericExtinction returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      CS_Obs_Out.Set(CS_ImageName_ApsRoot);
      CS_Obs_Out.Add(CString("DR_Obs-Sky_Sum_Flux_AirMassCorr.text"));
      if (!CF_EcDR.WriteArrayToFile(D_A2_Spec_Obs_Flux_AirMassCorr, CS_Obs_Out, CString("ascii"))){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: WriteArrayToFile(" << D_A2_Spec_Obs_Flux << ", " << CS_Obs_Out << ", ascii) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
    }
    
    ///Flux calibration
    int I_NearestJD = F_Image.FindNearestNeighbour(D_A1_JulianDates(i_file), D_A1_ThroughputJDs);
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Nearest Flux calibration star is number " << I_NearestJD << endl;
    #endif
    Array<double, 2> D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib(D_A2_Spec_Obs.rows(), D_A2_Spec_Obs.cols());
    D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib = D_A2_Spec_Obs_Flux_AirMassCorr;
    if (CS_ThroughputsJDList_In.GetLength() > 2){
      Array<double, 1> D_A1_Y2(D_A2_Spec_Obs_Flux_AirMassCorr.rows());
      Array<double, 1> D_A1_X2(D_A2_Spec_Obs_Flux_AirMassCorr.rows());
      D_A1_X2 = D_A2_Spec_Obs_Flux_AirMassCorr(Range::all(), 0);
      D_A1_Y2 = D_A2_Spec_Obs_Flux_AirMassCorr(Range::all(), 1);
      Array<double, 1> D_A1_Y1(D_A3_ThroughputsFit.cols());
      Array<double, 1> D_A1_X1(D_A3_ThroughputsFit.cols());
      if (B_UseThroughputFit){
        D_A1_X1 = D_A3_ThroughputsFit(I_NearestJD, Range::all(), 0);
        D_A1_Y1 = D_A3_ThroughputsFit(I_NearestJD, Range::all(), 1);
      }
      else{
        D_A1_X1 = D_A3_Throughputs(I_NearestJD, Range::all(), 0);
        D_A1_Y1 = D_A3_Throughputs(I_NearestJD, Range::all(), 1);
      }
      Array<double, 1> D_A1_Out(D_A1_X2.size());
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: throughput fit: D_A1_X1 = " << D_A1_X1 << endl;
        cout << "MGaussExtract_Obs_Sky::main: throughput fit: D_A1_Y1 = " << D_A1_Y1 << endl;
        cout << "MGaussExtract_Obs_Sky::main: throughput fit: D_A1_X2 = " << D_A1_X2 << endl;
      #endif
      if (!F_Image.InterPol(D_A1_Y1,
                            D_A1_X1,
                            D_A1_X2,
                            D_A1_Out)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: InterPol returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: interpolated throughput fit = " << D_A1_Out << endl;
      #endif
      D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib(Range::all(), 1) = D_A2_Spec_Obs_Flux_AirMassCorr(Range::all(), 1) / D_A1_Out;
      CS_Obs_Out.Set(CS_ImageName_ApsRoot);
      CS_Obs_Out.Add(CString("DR_Obs-Sky_Sum_Flux_AirMassCorr_FluxCalib.text"));
      if (!CF_EcDR.WriteArrayToFile(D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib, CS_Obs_Out, CString("ascii"))){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: WriteArrayToFile(" << D_A2_Spec_Obs_Flux << ", " << CS_Obs_Out << ", ascii) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
      
      ///plot spectrum
#ifdef __WITH_PLOTS__
      mglData MGLData1_Lambda;// = new mglData(2);
      Array<double, 1> D_A1_LambdaPlot(D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib.rows());
      Array<double, 1> D_A1_YPlot(D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib.rows());
      D_A1_LambdaPlot = D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib(Range::all(), 0);
      D_A1_YPlot = D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib(Range::all(), 1);
      MGLData1_Lambda.Link(D_A1_LambdaPlot.data(), D_A1_LambdaPlot.size());
      mglData MGLData1_SpecObs;// = new mglData(2);
      MGLData1_SpecObs.Link(D_A1_YPlot.data(), D_A1_YPlot.size());
      
      mglGraph gr;
      gr.SetRanges(min(D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib(Range::all(), 0)),max(D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib(Range::all(), 0)),0,max(D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib(Range::all(), 1)));
      cout << "MGaussExtract_Obs_Sky::main: D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib = " << D_A2_Spec_Obs_Flux_AirMassCorr_FluxCalib << endl;
      gr.Axis();
      gr.Label('y',"Calibrated Flux [erg/s/cm^2/A]",0);
      gr.Label('x',"Wavelength [Angstroms]",0);
      
      gr.Plot(MGLData1_Lambda, MGLData1_SpecObs, "g");
      gr.Box();
      gr.Legend();
      gr.WriteFrame(CS_ObjectPlotNameFluxCalib.Get());
      cout << "MGaussExtract_Obs_Sky::main: CS_ObjectPlotNameFluxCalib = <"  << CS_ObjectPlotNameFluxCalib << ">" << endl;
//      (*P_OFS_html) << "</center></body></html>" << endl;
//      delete(P_OFS_html);
//      exit(EXIT_FAILURE);
      //exit(EXIT_FAILURE);
#endif
    }/// end if (CS_ThroughputsJDList_In.GetLength() > 2)
    //exit(EXIT_FAILURE);
    
    /// Write RecFitOut 2D
//    if (P_CS_RecFitOut->GetLength() > 1){
      if (!F_Image.SetFileName(CS_A1_RecFitOut(i_file)))
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: Starting to write RecFitOut" << endl;
      #endif
      F_Image.GetPixArray() = F_Image.GetRecFitArray();
      if (!F_Image.WriteArray())
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
//    }

    /// Write ProfileOut 2D
//    if (P_CS_ProfileOut->GetLength() > 1){
      if (!F_Image.SetFileName(CS_A1_ProfileOut(i_file)))
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: Starting to write ProfileOut" << endl;
      #endif
      F_Image.GetPixArray() = F_Image.GetProfArray();
      if (!F_Image.WriteArray())
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
//    }

    ///Write MaskOut 2D
/*    if (P_CS_MaskOut->GetLength() > 1){
      if (!F_Image.SetFileName(CS_A1_MaskOut(i_file)))
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetFileName(" << CS_A1_MaskOut(i_file) << ") returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      cout << "MGaussExtract_Obs_Sky::main: Starting to write MaskOut" << endl;
      Array<int, 2> I_A2_MaskArray(F_Image.GetNRows(), F_Image.GetNCols());
      I_A2_MaskArray = F_Image.GetMaskArray();
      Array<double, 2> D_A2_MaskArray(F_Image.GetNRows(), F_Image.GetNCols());
      D_A2_MaskArray = 1. * I_A2_MaskArray;
      F_Image.GetPixArray() = D_A2_MaskArray;
      if (!F_Image.WriteArray())
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
    }*/

  /// Write SkyArrOut 2D
//    if (P_CS_SkyArrOut->GetLength() > 1){
      if (!F_Image.SetFileName(CS_A1_SkyArrOut(i_file)))
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: Starting to write SkyArrOut" << endl;
      #endif
      F_Image.GetPixArray() = F_Image.GetRecSkyArray();
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: F_Image.GetRecSkyArray().rows() = " << F_Image.GetRecSkyArray().rows() << endl;
        cout << "MGaussExtract_Obs_Sky::main: F_Image.GetRecSkyArray().cols() = " << F_Image.GetRecSkyArray().cols() << endl;
      #endif
      if (!F_Image.WriteArray()){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
//    }

    /// Write ErrOut 2D
    if (P_CS_ErrOut->GetLength() > 1){
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: Writing F_Image.GetErrArray()" << endl;
      #endif
      if (!F_Image.SetFileName(CS_A1_ErrOut(i_file))){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: Starting to write ErrOut" << endl;
        cout << "MGaussExtract_Obs_Sky::main: F_Image.GetErrArray().rows() = " << F_Image.GetErrArray().rows() << endl;
        cout << "MGaussExtract_Obs_Sky::main: F_Image.GetErrArray().cols() = " << F_Image.GetErrArray().cols() << endl;
      #endif
      F_Image.GetPixArray() = F_Image.GetErrArray();
      if (!F_Image.WriteArray())
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
    }

    /// Write aperture header information
    F_Image.WriteApHead(CString("aphead_")+CS_FitsFileName_In+CString(".head"));

    /// output extracted spectrum 1D
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting to write EcOut" << endl;
    #endif
    if (!F_OutImage.SetNRows(P_I_A1_Apertures->size())){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetNRows(" << F_Image.Get_NApertures() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
      F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetLastExtracted()((*P_I_A1_Apertures)(i_ap), Range::all());//.transpose(secondDim, firstDim);

  //cout << "MExctract: F_Image.GetSpec = " << F_Image.GetSpec() << endl;

  // Write Profile Image
/*  if (!F_OutImage.SetFileName(CS_FitsFileName_Out))
  {
    cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName(" << CS_FitsFileName_Out << ") returned FALSE!" << endl;
    exit(EXIT_FAILURE);
}*/
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting F_OutImage.WriteArray()" << endl;
    #endif
    if (!F_OutImage.WriteArray()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    
    ///Correct for AIRMASSES_IN
//    if (CS_AirMassList_In.GetLength() > 2){
      
//    }

    /// Write ErrOutEc 1D
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Writing F_Image.GetErrorsEc()" << endl;
    #endif
    if (P_CS_ErrOutEc->GetLength() > 1){
//      CS_A1_Args_ExtractFromProfile(1) = CString("");
//      if (!F_Image.ExtractErrors(CS_A1_Args_ExtractFromProfile, PP_Args_ExtractFromProfile))
//      {
//        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.ExtractErrors() returned FALSE!" << endl;
//        exit(EXIT_FAILURE);
//      }
      if (!F_OutImage.SetFileName(CS_A1_ErrOutEc(i_file))){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      #ifdef __DEBUG_MGAUSSEXTRACT__
        cout << "MGaussExtract_Obs_Sky::main: Starting to write ErrOutEc" << endl;
      #endif
      for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
        F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetErrorsEc()((*P_I_A1_Apertures)(i_ap), Range::all());//.transpose(secondDim, firstDim);
      if (!F_OutImage.WriteArray()){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
    }

    /// Write SkyOut 1D
    if (!F_OutImage.SetFileName(CS_A1_SkyOut(i_file))){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting to write SkyOut" << endl;
    #endif
    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
      F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetSkyFit()((*P_I_A1_Apertures)(i_ap), Range::all());//.transpose(secondDim, firstDim);
    if (!F_OutImage.WriteArray()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Write SkyErrOut 1D
    if (!F_OutImage.SetFileName(CS_A1_SkyErrOut(i_file))){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    #ifdef __DEBUG_MGAUSSEXTRACT__
      cout << "MGaussExtract_Obs_Sky::main: Starting to write SkyErrOut" << endl;
    #endif
    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
      F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetSkyError()((*P_I_A1_Apertures)(i_ap), Range::all());//.transpose(secondDim, firstDim);
    if (!F_OutImage.WriteArray()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
  }/// end for (i_file...)
  
  if (!CS.WriteStrListToFile(CS_A1_DBFileNames_Out, CString("db_filenames_out.list"))){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: WriteStrListToFile(" << CS_A1_DBFileNames_Out << ", db_filenames_out.list) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  
  if (!F_Image.WriteArrayToFile(D_A1_PixShifts, CS_PixShiftsList_Out, CString("ascii"))){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: WriteArrayToFile(D_A1_PixShifts, CS_PixShiftsList_Out, ascii) returned FALSE" << endl;
    exit(EXIT_FAILURE);
  }
/*  fitsfile *P_FitsFileIn;
  fitsfile *P_FitsFileOut;
  int bitpixA, bitpixB, hdunumA, hdunumB, nhdusA, nhdusB, hdutypeA, hdutypeB;
  int anynulA, anynulB, extendA, extendB, simpleA, simpleB;
  int naxisA, naxisB;
  long pcountA, pcountB, gcountA, gcountB;
  long naxesA[2], naxesB[2];
  long fpixelA, fpixelB, nelementsA, nelementsB;
  int      countA, countB, Status;
  double *p_ArrayA, *p_ArrayB;
  float nullvalA, nullvalB;
  char strbufA[256], strbufB[256];

  Status=0;
  fits_open_file(&P_FitsFileIn, CS_FitsFileName_In.Get(), READONLY, &Status);
  fits_read_imghdr(P_FitsFileIn, 2, &simpleA , &bitpixA, &naxisA, naxesA,
                   &pcountA, &gcountA, &extendA, &Status);
  if (Status !=0)
  {
    printf("CFits::ReadArray: Error %d opening file %s\n", Status, CS_FitsFileName_In.Get());
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  cout << "CFits::ReadArray: FitsFileName <" << CS_FitsFileName_In.Get() << "> opened" << endl;
  cout << "CFits::ReadArray: FitsFileName contains <" << naxesA[1]  << "> rows!!!!!!! and <" << naxesA[0] << "> columns!!!!!!!!! naxes = <" << naxesA << ">" << endl;

  fits_open_file(&P_FitsFileOut, CS_FitsFileName_Out.Get(), READWRITE, &Status);
//  fits_read_imghdr(P_FitsFileOut, 2, &simpleB , &bitpixB, &naxisB, naxesB,
//                   &pcountB, &gcountB, &extendB, &Status);
  if (Status !=0)
  {
    printf("CFits::ReadArray: Error %d opening file %s\n", Status, CS_FitsFileName_Out.Get());
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  cout << "CFits::ReadArray: FitsFileName <" << CS_FitsFileName_Out.Get() << "> opened" << endl;
//  cout << "CFits::ReadArray: FitsFileName contains <" << naxesB[1]  << "> rows!!!!!!! and <" << naxesB[0] << "> columns!!!!!!!!! naxes = <" << naxesB << ">" << endl;
  nhdusB = fits_get_num_hdus(P_FitsFileOut, &hdunumB, &Status);
  if (Status !=0)
  {
    cout << "CFits::ReadArray: Error " << Status << " reading hdunum" << endl;
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  cout << "MExctract::main: nhdusB = " << nhdusB << ", hdunumB = " << hdunumB << endl;

  fits_get_hdu_type(P_FitsFileOut, &hdutypeB, &Status);
  if (Status !=0)
  {
    cout << "CFits::ReadArray: Error " << Status << " reading hdutype" << endl;
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  cout << "MExctract::main: hdutypeB = " << hdutypeB << endl;

  fits_movabs_hdu(P_FitsFileOut, 1, &hdutypeB, &Status);
  if (Status !=0)
  {
    cout << "CFits::ReadArray: Error " << Status << " moving to hdunum 1 " << endl;
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  cout << "MExctract::main: moved to hdunum 1" << endl;

  char card[FLEN_CARD];
  int  nkeysA, nkeysB, ii;
  fits_get_hdrspace(P_FitsFileIn, &nkeysA, NULL, &Status);
  cout << "MExctract::main: nkeysA = " << nkeysA << endl;
  fits_get_hdrspace(P_FitsFileOut, &nkeysB, NULL, &Status);
  cout << "MExctract::main: nkeysB = " << nkeysB << endl;

  for (ii = 1; ii <= nkeysA; ii++)  {
    fits_read_record(P_FitsFileIn, ii, card, &Status);
    cout << card << endl;
    fits_write_record(P_FitsFileOut, card, &Status);
    if (Status !=0)
    {
      cout << "CFits::ReadArray: Error " << Status << " writing header" << endl;
      char* P_ErrMsg = new char[255];
      ffgerr(Status, P_ErrMsg);
      cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
      delete[] P_ErrMsg;
      return false;
    }
  }


/*  fits_copy_hdu(P_FitsFileIn, P_FitsFileOut, &Status);
  if (Status !=0)
  {
    cout << "CFits::ReadArray: Error " << Status << " copying header" << endl;
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  cout << "MExctract::main: Header copied" << endl;
  /*

  nhdusA = fits_get_num_hdus(P_FitsFileIn, &hdunumA, &Status);
  if (Status !=0)
  {
    cout << "CFits::ReadArray: Error " << Status << " reading hdunum" << endl;
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  cout << "MExctract::main: nhdusA = " << nhdusA << ", hdunumA = " << hdunumA << endl;

  fits_get_hdu_type(P_FitsFileIn, &hdutypeA, &Status);
  if (Status !=0)
  {
    cout << "CFits::ReadArray: Error " << Status << " reading hdutype" << endl;
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  cout << "MExctract::main: hdutypeA = " << hdutypeA << endl;

  fits_movabs_hdu(P_FitsFileIn, 1, &hdutypeA, &Status);
  if (Status !=0)
  {
    cout << "CFits::ReadArray: Error " << Status << " moving to hdunum 1 " << endl;
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  cout << "MExctract::main: moved to hdunum 1" << endl;

  fits_copy_file(P_FitsFileIn, P_FitsFileOut, 0, 1, 1, &Status);
  if (Status !=0)
  {
    cout << "CFits::ReadArray: Error " << Status << " copying header" << endl;
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  cout << "MExctract::main: Header copied" << endl;
  */
/*  fits_close_file(P_FitsFileIn, &Status);
  if (Status !=0)
  {
    cout << "CFits::ReadArray: Error " << Status << " closing file " << CS_FitsFileName_In.Get() << endl;
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }

  fits_close_file(P_FitsFileOut, &Status);
  if (Status !=0)
  {
    cout << "CFits::ReadArray: Error " << Status << " closing file " << CS_FitsFileName_Out.Get() << endl;
    char* P_ErrMsg = new char[255];
    ffgerr(Status, P_ErrMsg);
    cout << "CFits::ReadArray: <" << P_ErrMsg << "> => Returning FALSE" << endl;
    delete[] P_ErrMsg;
    return false;
  }
  */
  (*P_OFS_html) << "</center></body></html>" << endl;
  delete(P_OFS_html);
  delete(P_CS);
  delete(P_CS_ErrIn);
  delete(P_CS_ErrOut);
  delete(P_CS_SkyOut);
  delete(P_CS_SkyErrOut);
  delete(P_CS_ImOut);
  delete(P_CS_ProfileOut);
  delete(P_CS_ErrOutEc);
  delete(P_CS_SkyArrOut);
  delete(P_CS_MaskOut);
  delete(P_CS_SPFitOut);
  delete(P_CS_EcFromProfileOut);
  delete(P_CS_ErrFromProfileOut);
  delete(P_I_A1_Apertures);
  return EXIT_SUCCESS;
}
