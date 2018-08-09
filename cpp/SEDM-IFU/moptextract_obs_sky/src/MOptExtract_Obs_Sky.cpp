/*
author: Andreas Ritter
created: 13/01/2014
last edited: 13/01/2014
compiler: g++ 4.4
basis machine: Arch Linux
*/

#include "MOptExtract_Obs_Sky.h"

using namespace std;

int main(int argc, char *argv[])
{
  cout << "MGaussExtract_Obs_Sky::main: argc = " << argc << endl;
  if (argc < 6)
  {
    cout << "MGaussExtract_Obs_Sky::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: optextract <char[] @FitsFileName_XC_YC_RO_RS_In> <char[] DatabaseFileName_In> <char[] CS_A1_TextFiles_Coeffs_In> <double Gain> <double ReadOutNoise> <int OverSample> <int B_WithBackground[0,1]> <[double(min_sdev),double(max_sdev)]> <[double(max_mean_offset_left_of_aperture_trace),double(max_mean_offset_right_of_aperture_trace)]><double D_MaxRMS_In> <double D_WLen_Start> <double D_WLen_End> <double D_DWLen> <double TelescopeSurface> <char[] @ExposureTimes_In> [MAX_ITER_SIG=int] [ERR_IN=char[](@)] [AREA=[int(xmin),int(xmax),int(ymin),int(ymax)]] [APERTURES=char[](@)] [AP_DEF_IMAGE=char[](ApertureDefinitionImage)]" << endl;//"[, ERR_FROM_PROFILE_OUT=char[]])" << endl;
    // [ERR_OUT_2D=char[]] [ERR_OUT_EC=char[](@)] [SKY_OUT_EC=char[](@)] [SKY_OUT_2D=char[]] [SKY_ERR_OUT_EC=char[](@)] [PROFILE_OUT=char[](@)] [REC_FIT_OUT=char[](@)] [MASK_OUT=char[](@)]
    cout << "FitsFileName_XC_YC_RO_RS_In: <image to extract> <int XCenter> <int YCenter> <int Radius_Obs> <int Radius_Sky>" << endl;
    cout << "DatabaseFileName_In: aperture-definition file to use for extraction" << endl;
    cout << "CS_A1_TextFiles_Coeffs_In: filename containing list of coefficient files for dispersion correction" << endl;
    cout << "Gain: CCD gain" << endl;
    cout << "ReadOutNoise: CCD readout noise" << endl;
    cout << "OverSample: oversampling factor for slit function" << endl;
    cout << "B_WithBackground: 0: without background in GaussFit, 1: with constant background in GaussFit" << endl;
    cout << "[double(min_sdev), double(max_sdev)]: Limits for the standard deviation of the GaussFit" << endl;
    cout << "[double(max_mean_offset_left_of_aperture_trace), double(max_mean_offset_right_of_aperture_trace)]: Limits for the offset of the center of the GaussFit compared to the trace" << endl;
    cout << "D_MaxRMS_In: Maximum RMS for dispersion correction" << endl;
    cout << "D_WLen_Start: Starting wavelength for re-binning" << endl;
    cout << "D_WLen_End: Ending wavelength for re-binning" << endl;
    cout << "D_DWLen: wavelength step for re-binning" << endl;
    cout << "TelescopeSurface: effective telescope surface for flux calculation" << endl;
    cout << "ExposureTimes_In: data file containing the exposure times for each image in @FitsFileName_In" << endl;
    cout << "TELLURIC: 0 - none, 1 - Piskunov, 2 - LinFit" << endl;
    cout << "MAX_ITER_SF: maximum number of iterations calculating the slit function (spatial profile)" << endl;
    cout << "MAX_ITER_SKY: maximum number of iterations calculating the sky (TELLURIC = 2 only)" << endl;
    cout << "MAX_ITER_SIG: maximum number of iterations rejecting cosmic-ray hits" << endl;
    cout << "SWATH_WIDTH: width of swath (bin) for which an individual profile shall be calculated" << endl;
    cout << "SMOOTH_SF: Width of median SlitFunc smoothing" << endl;
    cout << "SMOOTH_SP: Width of median Spectrum/Blaze smoothing" << endl;
    cout << "WING_SMOOTH_FACTOR: Width of median SlitFunc-Wing smoothing" << endl;
    cout << "ERR_IN: input image containing the uncertainties in the pixel values of FitsFileName_In" << endl;
    cout << "ERR_OUT_2D: output uncertainty image - same as ERR_IN, but with detected cosmic-ray hits set to 10,000" << endl;
    cout << "ERR_OUT_EC: output file containing the uncertainties in the extracted spectra's pixel values" << endl;
    cout << "SKY_OUT_EC: output sky-only spectra (TELLURIC > 0 only)" << endl;
    cout << "SKY_OUT_2D: reconstructed sky-only image" << endl;
    cout << "SKY_ERR_OUT_EC: uncertainties in the calculated sky-only values" << endl;
    cout << "PROFILE_OUT: reconstructed image of the spatial profiles" << endl;
    cout << "IM_REC_OUT: reconstructed input image from the profile-fitting/extraction" << endl;
    cout << "SPFIT_OUT_EC: extracted spectra from linear fit of spatial profiles to input spectra with 3-sigma rejection (ignoring mask), with sky if TELLURIC>0, without sky if TELLURIC=0" << endl;
    cout << "REC_FIT_OUT: reconstructed input image for SPFIT_OUT_EC" << endl;
    cout << "MASK_OUT: output mask with detected cosmic-ray hits set to 0, good pixels set to 1" << endl;
    cout << "EC_FROM_PROFILE_OUT: extracted spectra from simply multiplying the input image with the profile image as weight and summing up" << endl;///SHALL I REJECT COSMIC-RAY HITS???????????????
    cout << "AREA: Area from which to extract spectra if center of aperture is in specified area" << endl;
    cout << "XCOR_PROF: How many cross-correlation runs from -1 pixel to +1 pixel compared to XCenter?" << endl;
    cout << "APERTURES: input filename containing a list of apertures to extract" << endl;
    cout << "AP_DEF_IMAGE: image used for tracing the spectra, now used to find the aperture offset in x" << endl;
    cout << "I_MAX_OFFSET: maximum aperture offset in x for cross-correlation (AP_DEF_IMAGE must be set, too)" << endl;
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

  firstIndex i;
  secondIndex j;
  
  int I_SwathWidth = 0;
  int I_MaxIterSF = 8;
  int I_MaxIterSky = 12;
  int I_MaxIterSig = 2;
  int I_SmoothSP = 1;
  int I_MaxOffset = 5;
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
  int I_OverSample = (int)(atoi((char*)argv[6]));
  CString CS_WithBackground((char*)(argv[7]));
  int I_WithBackground = 0.;
  if (!CS_WithBackground.AToI(I_WithBackground)){
    cout << "MExtractMPFitThreeGauss::main: ERROR: CS_WithBackground(=" << CS_WithBackground << ").AToI(I_WithBackground) returning FALSE" << endl;
    exit(EXIT_FAILURE);
  }
  bool B_XCor_2D = true;
  bool B_WithBackground = false;
  if (I_WithBackground == 1)
    B_WithBackground = true;
  CString CS_SDevLimits((char*)(argv[8]));
  CString CS_MeanLimits((char*)(argv[9]));
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
  double D_MaxRMS_In = (double)(atof((char*)argv[10]));
  cout << "MGaussExtract_Obs_Sky::main: D_MaxRMS_In set to " << D_MaxRMS_In << endl;
  double D_WLen_Start = (double)(atof((char*)argv[11]));
  cout << "MGaussExtract_Obs_Sky::main: D_WLen_Start set to " << D_WLen_Start << endl;
  double D_WLen_End = (double)(atof((char*)argv[12]));
  cout << "MGaussExtract_Obs_Sky::main: D_WLen_End set to " << D_WLen_End << endl;
  double D_DWLen = (double)(atof((char*)argv[13]));
  cout << "MGaussExtract_Obs_Sky::main: D_DWLen set to " << D_DWLen << endl;
  double D_ATel = (double)(atof((char*)argv[14]));
  cout << "MGaussExtract_Obs_Sky::main: D_ATel set to " << D_ATel << endl;
  char *P_CharArr_ExpTimes_In = (char*)argv[15];
  int I_Telluric=0;
  int I_XCorProf = 0;
  Array<int, 1> *P_I_A1_Apertures = new Array<int, 1>(1);
  (*P_I_A1_Apertures) = 0;
  bool B_AperturesSet = false;
  Array<CString, 1> CS_A1_TextFiles_Coeffs_In(1);

  /// read optional parameters
  for (int i = 16; i <= argc; i++){
    CS.Set((char*)argv[i]);
    cout << "MGaussExtract_Obs_Sky: Reading Parameter " << CS << endl;
    
    CS_comp.Set("TELLURIC");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        I_Telluric = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky::main: I_Telluric set to " << I_Telluric << endl;
      }
    }
    
    CS_comp.Set("MAX_ITER_SF");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        I_MaxIterSF = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky::main: I_MaxIterSF set to " << I_MaxIterSF << endl;
      }
    }
    
    CS_comp.Set("MAX_ITER_SKY");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        I_MaxIterSky = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky::main: I_MaxIterSky set to " << I_MaxIterSky << endl;
      }
    }
    
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
    
    CS_comp.Set("SWATH_WIDTH");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        I_SwathWidth = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky::main: I_SwathWidth set to " << I_SwathWidth << endl;
      }
    }
    
    CS_comp.Set("SMOOTH_SF");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        D_SmoothSF = (double)(atof(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky::main: D_SmoothSF set to " << D_SmoothSF << endl;
      }
    }
    
    CS_comp.Set("SMOOTH_SP");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        I_SmoothSP = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky::main: I_SmoothSP set to " << I_SmoothSP << endl;
      }
    }
    
    CS_comp.Set("WING_SMOOTH_FACTOR");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        D_WingSmoothFactor = (double)(atof(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky::main: D_WingSmoothFactor set to " << D_WingSmoothFactor << endl;
      }
    }
    
    CS_comp.Set("XCOR_PROF");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MGaussExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        delete(P_CS);
        P_CS = CS.SubString(CS_comp.GetLength()+1);
        I_XCorProf = (int)(atoi(P_CS->Get()));
        cout << "MGaussExtract_Obs_Sky::main: I_XCorProf set to " << I_XCorProf << endl;
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


    /**
    cout << "IM_REC_OUT: reconstructed input image from the profile-fitting/extraction" << endl;
    cout << "SPFIT_OUT_EC: extracted spectra from linear fit of spatial profiles to input spectra with 3-sigma rejection (ignoring mask), with sky if TELLURIC>0, without sky if TELLURIC=0" << endl;
     */
    
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

  Array<CString, 1> CS_A1_FitsFileNamesPlusDir(CS_A1_FitsFileNames_In.size());
  if (!CS_FitsFileName_In.AddNameAsDir(CS_A1_FitsFileNames_In, CS_A1_FitsFileNamesPlusDir)){
    cout << "MGaussExtract_Obs_Sky::main: ERROR: AddFirstPartAsDir(CS_A1_FitsFileNames_In, CS_A1_FitsFileNamesPlusDir) returned FALSE" << endl;
    return false;
  }
  cout << "MGaussExtract_Obs_Sky::main: CS_A1_FitsFileNamesPlusDir = " << CS_A1_FitsFileNamesPlusDir << endl;
//  exit(EXIT_FAILURE);

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
  cout << "MGaussExtract_Obs_Sky::main: D_A1_ExpTimes set to " << D_A1_ExpTimes << endl;
//  exit(EXIT_FAILURE);

  CString CS_FitsFileNameEcDR_Out;
  CString CS_FitsFileNameErrEcDR_Out;

  CString CS_DatabaseFileName_In;
  CS_DatabaseFileName_In.Set(P_CharArr_DB);

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

  CFits F_Image;
  CFits F_OutImage;
  CFits F_ErrImage;
  CFits F_ApDefImage;
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
  for (int i_file = 0; i_file < CS_A1_FitsFileNames_In.size(); i_file++){
    cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.SetFileName(" << CS_FitsFileName_In.Get() << ")" << endl;
    if (!F_Image.SetFileName(CS_A1_FitsFileNames_In(i_file)))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetFileName(" << CS_FitsFileName_In.Get() << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Set ReadOutNoise
    cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.Set_ReadOutNoise(" << D_ReadOutNoise << ")" << endl;
    if (!F_Image.Set_ReadOutNoise( D_ReadOutNoise ))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.Set_ReadOutNoise(" << D_ReadOutNoise << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Set Gain
    cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.Set_Gain(" << D_Gain << ")" << endl;
    if (!F_Image.Set_Gain( D_Gain ))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.Set_Gain(" << D_Gain << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    /// Set I_MaxIterSig
    cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.Set_MaxIterSig(" << I_MaxIterSig << ")" << endl;
    if (!F_Image.Set_MaxIterSig( I_MaxIterSig ))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.Set_MaxIterSig(" << I_MaxIterSig << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Read FitsFile
    cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.ReadArray()" << endl;
    if (!F_Image.ReadArray())
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.ReadArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    P_CS_ImageName_ApsRoot = CS_A1_FitsFileNamesPlusDir(i_file).SubString(0,CS_A1_FitsFileNamesPlusDir(i_file).StrPos(CString("/")));
    if (!P_CS_ImageName_ApsRoot->MkDir(*P_CS_ImageName_ApsRoot)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: MkDir(" << *P_CS_ImageName_ApsRoot << ") returned FALSE" << endl;
      return false;
    }
    else{
      cout << "MGaussExtract_Obs_Sky::main: MkDir(" << *P_CS_ImageName_ApsRoot << ") returned TRUE" << endl;
    }
    CString *P_CS_FileName = CS_A1_FitsFileNames_In(i_file).SubString(0,CS_A1_FitsFileNames_In(i_file).LastStrPos(CString("."))-1);
    P_CS_ImageName_ApsRoot->Add(*P_CS_FileName);
    delete(P_CS_FileName);
    CS_ImageName_ApsRoot.Set(*P_CS_ImageName_ApsRoot);
    delete(P_CS_ImageName_ApsRoot);

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
    CS_ImageName_ApsRoot.Add(CString("Ec"));
    cout << "MGaussExtract_Obs_Sky::main: CS_ImageName_ApsRoot = <" << CS_ImageName_ApsRoot << ">" << endl;
//    exit(EXIT_FAILURE);
//    delete(P_CS_ImageName_ApsRoot);

    F_Image.GetPixArray() = F_Image.GetPixArray() / F_Image.Get_Gain();

    /// Set DatabaseFileName_In
    cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.SetDatabaseFileName(" << CS_DatabaseFileName_In << ")" << endl;
    if (!F_Image.SetDatabaseFileName(CS_DatabaseFileName_In))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Read DatabaseFileName_In
    cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.ReadDatabaseEntry()" << endl;
    if (!F_Image.ReadDatabaseEntry())
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.ReadDatabaseEntry() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Calculate Trace Functions
    cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.CalcTraceFunctions()" << endl;
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
    cout << "MGaussExtract_Obs_Sky::main: D_A1_Center = " << D_A1_Center << endl;
    if (P_CS_ApDefImage_In->GetLength() > 2){
      F_ApDefImage.SetFileName(*P_CS_ApDefImage_In);
      F_ApDefImage.ReadArray();
      int I_Shift = 0;
      double D_ChiSquareMin = 0.;
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
          cout << "MGaussExtract_Obs_Sky::main: I_X0_ApDefImage = " << I_X0_ApDefImage << ", I_X1_ApDefImage = " << I_X1_ApDefImage << ", I_Y0_ApDefImage = " << I_Y0_ApDefImage << ", I_Y1_ApDefImage = " << I_Y1_ApDefImage << endl;
          Array<double, 2> D_A2_Area_ApDefImage(I_Y1_ApDefImage-I_Y0_ApDefImage+1, I_X1_ApDefImage-I_X0_ApDefImage+1);
          D_A2_Area_ApDefImage = F_ApDefImage.GetPixArray()(Range(I_Y0_ApDefImage, I_Y1_ApDefImage), Range(I_X0_ApDefImage, I_X1_ApDefImage));
          int I_X0_Image = I_X0_ApDefImage + I_MaxOffset;
          int I_X1_Image = I_X1_ApDefImage - I_MaxOffset;
          int I_Y0_Image = I_Y0_ApDefImage;// + 5;
          int I_Y1_Image = I_Y1_ApDefImage;// - 5;
          cout << "MGaussExtract_Obs_Sky::main: I_X0_Image = " << I_X0_Image << ", I_X1_Image = " << I_X1_Image << ", I_Y0_Image = " << I_Y0_Image << ", I_Y1_Image = " << I_Y1_Image << endl;
          Array<double, 2> D_A2_Area_Image(I_Y1_Image-I_Y0_Image+1, I_X1_Image-I_X0_Image+1);
          D_A2_Area_Image = F_Image.GetPixArray()(Range(I_Y0_Image, I_Y1_Image), Range(I_X0_Image, I_X1_Image));
          D_A2_Area_Image = D_A2_Area_Image * mean(D_A2_Area_ApDefImage) / mean(D_A2_Area_Image);
          int I_Shift_Y = 0;
          cout << "MGaussExtract_Obs_Sky::main: Starting CrossCorrelate2D" << endl;
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
          cout << "MGaussExtract_Obs_Sky::main: I_Shift_X = " << I_Shift << ", I_Shift_Y = " << I_Shift_Y << endl;
      }
      else{
        Array<double, 1> D_A1_Line_ApDefImage(F_ApDefImage.GetNCols());
        Array<double, 1> D_A1_Line_Image(F_Image.GetNCols());
        if (D_A1_Line_ApDefImage.size() != D_A1_Line_Image.size()){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: D_A1_Line_ApDefImage.size(=" << D_A1_Line_ApDefImage.size() << ") != D_A1_Line_Image.size(=" << D_A1_Line_Image.size() << ") => Returning FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        D_A1_Line_ApDefImage = F_ApDefImage.GetPixArray()(F_ApDefImage.GetNRows() / 2, Range::all());
        D_A1_Line_Image = F_Image.GetPixArray()(F_Image.GetNRows() / 2, Range::all());
        D_A1_Line_Image = D_A1_Line_Image * mean(D_A1_Line_ApDefImage) / mean(D_A1_Line_Image);
        if (!F_Image.CrossCorrelate(D_A1_Line_Image, 
                                    D_A1_Line_ApDefImage, 
                                    I_MaxOffset, 
                                    I_MaxOffset, 
                                    I_Shift, 
                                    D_ChiSquareMin)){
          cout << "MGaussExtract_Obs_Sky::main: ERROR: CrossCorrelate returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
      }
      cout << "MGaussExtract_Obs_Sky::main: I_Shift = " << I_Shift << ", D_ChiSquareMin = " << D_ChiSquareMin << endl;
//      exit(EXIT_FAILURE);
      F_Image.ShiftApertures(double(I_Shift));
      F_Image.SetDatabaseFileName("database/aptemp");
      F_Image.WriteDatabaseEntry();
//      F_Image.MarkCenters();
//      CString *P_CS_MarkCenters = CS_A1_FitsFileNames_In(i_file).SubString(0,CS_A1_FitsFileNames_In(i_file).LastStrPos(CString("."))-1);
//      P_CS_MarkCenters->Add(CString("_centers_shift.fits"));
//      F_Image.SetFileName(*P_CS_MarkCenters);
//      delete(P_CS_MarkCenters);
//      F_Image.WriteArray();
//      exit(EXIT_FAILURE);
    }
    
    if (CS_A2_FitsFileNames_In(i_file, I_Pos_RadObs).AToI() < 20){
      cout << "MGaussExtract_Obs_Sky::main: Starting FindNearestNeighbours(D_A1_Center = " << D_A1_Center << ", D_A2_ApertureCenters, " << CS_A2_FitsFileNames_In(i_file, 3).AToI() * 6 + 1 << ",...)" << endl;
      if (!F_Image.FindNearestNeighbours(D_A1_Center,
                                         D_A2_ApertureCenters,
                                         CS_A2_FitsFileNames_In(i_file, I_Pos_RadObs).AToI() * 6 + 1,
                                         D_A2_NearestNeighbours,
                                         I_A1_Apertures_Object)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.FindNearestNeighbours(D_A1_Center=" << D_A1_Center << ", D_A2_ApertureCenters, " << CS_A2_FitsFileNames_In(i_file, 3).AToI() * 6 + 1 << ", D_A2_NearestNeighbours, I_A1_Apertures_Object) returned FALSE" << endl;
        exit(EXIT_FAILURE);
      }
    }
    else{
      if (!F_Image.FindApsInCircle(CS_A2_FitsFileNames_In(i_file, 1).AToI(), CS_A2_FitsFileNames_In(i_file, 2).AToI(), CS_A2_FitsFileNames_In(i_file, I_Pos_RadObs).AToI(), I_A1_Apertures_Object)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: " << CS_A1_FitsFileNames_In(i_file) << ".FindApsInCircle(" << CS_A2_FitsFileNames_In(i_file, 1) << ", " << CS_A2_FitsFileNames_In(i_file, 2) << ", " << CS_A2_FitsFileNames_In(i_file, 3) << ") returned FALSE " << endl;
        exit(EXIT_FAILURE);
      }
    }
    cout << "MGaussExtract_Obs_Sky::main: I_A1_Apertures_Object = " << I_A1_Apertures_Object << endl;
    CString *P_CS_ObsList = CS_A1_FitsFileNames_In(i_file).SubString(0, CS_A1_FitsFileNames_In(i_file).LastCharPos('.')-1);
    P_CS_ObsList->Add("_apsObject.list");
    cout << "MGaussExtract_Obs_Sky::main: P_CS_ObsList set to <" << *P_CS_ObsList << ">" << endl;
    F_Image.WriteArrayToFile(I_A1_Apertures_Object, *P_CS_ObsList, CString("ascii"));
    delete(P_CS_ObsList);


    if (CS_A2_FitsFileNames_In(i_file, I_Pos_RadObs).AToI() < 20){
      Array<double, 2> D_A2_ApertureCenters(2,2);
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
      Array<double, 2> D_A2_NearestNeighbours(2,2);
      cout << "MGaussExtract_Obs_Sky::main: Starting FindNearestNeighbours(D_A1_Center = " << D_A1_Center << ", D_A2_ApertureCenters, " << CS_A2_FitsFileNames_In(i_file, 4).AToI() * 6 + 1 << ",...)" << endl;
      int I_Radius = CS_A2_FitsFileNames_In(i_file, I_Pos_RadSky).AToI();
      int I_NNeighbours = I_Radius * 6;
      do{
	I_Radius = I_Radius - 1;
	I_NNeighbours += I_Radius * 6;
      } while (I_Radius > 0);
      I_NNeighbours++;
      if (!F_Image.FindNearestNeighbours(D_A1_Center,
                                         D_A2_ApertureCenters,
                                         I_NNeighbours,
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
      if (!F_Image.FindApsInRing(CS_A2_FitsFileNames_In(i_file, 1).AToI(), CS_A2_FitsFileNames_In(i_file, 2).AToI(), CS_A2_FitsFileNames_In(i_file, 3).AToI(), CS_A2_FitsFileNames_In(i_file, I_Pos_RadSky).AToI(), I_A1_Apertures_Sky)){
        cout << "MGaussExtract_Obs_Sky::main: ERROR: " << CS_A1_FitsFileNames_In(i_file) << ".FindApsInRing(" << CS_A2_FitsFileNames_In(i_file, 1) << ", " << CS_A2_FitsFileNames_In(i_file, 2) << ", " << CS_A2_FitsFileNames_In(i_file, I_Pos_RadSky) << ", " << CS_A2_FitsFileNames_In(i_file, I_Pos_RadSky) << ") returned FALSE " << endl;
        exit(EXIT_FAILURE);
      }
    }
    cout << "MGaussExtract_Obs_Sky::main: I_A1_Apertures_Sky = " << I_A1_Apertures_Sky << endl;
    CString *P_CS_SkyList = CS_A1_FitsFileNames_In(i_file).SubString(0, CS_A1_FitsFileNames_In(i_file).LastCharPos('.')-1);
    P_CS_SkyList->Add("_apsSky.list");
    cout << "MGaussExtract_Obs_Sky::main: P_CS_SkyList set to <" << *P_CS_SkyList << ">" << endl;
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
    cout << "MGaussExtract_Obs_Sky::main: Starting F_Image.MkProfIm(): time = " << seconds << endl;

    Array<double, 1> *P_D_A1_XLow = F_Image.Get_XLow();
    Array<double, 1> *P_D_A1_XHigh = F_Image.Get_XHigh();
    Array<double, 1> *P_D_A1_YLow = F_Image.Get_YLow();
    Array<double, 1> *P_D_A1_YHigh = F_Image.Get_YHigh();
    Array<double, 1> *P_D_A1_YCenter = F_Image.Get_YCenter();
    Array<double, 2> *P_D_A2_XCenters = F_Image.Get_XCenters();
    int I_NPixCut_Left = 1;
    int I_NPixCut_Right = 1;
    
    for (int i_ap=0; i_ap<I_A1_AperturesToExtract.size(); i_ap++){
      Array<int, 2> I_A2_AperturesWithCrossTalk((*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap)) - (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)) + 1,5);
      I_A2_AperturesWithCrossTalk = -1;
        /// Find crosstalk areas for aperture
      for (int i_row=0; i_row<I_A2_AperturesWithCrossTalk.rows(); i_row++){
        int I_NXCorAps = 0;
        int I_XRow = (*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)) + i_row;
        double D_XLow = (*P_D_A2_XCenters)(I_A1_AperturesToExtract(i_ap), I_XRow) + (*P_D_A1_XLow)(I_A1_AperturesToExtract(i_ap));
        double D_XHigh = (*P_D_A2_XCenters)(I_A1_AperturesToExtract(i_ap), I_XRow) + (*P_D_A1_XHigh)(I_A1_AperturesToExtract(i_ap));
        for (int i_apx=0; i_apx<F_Image.Get_NApertures(); i_apx++){
            if (((*P_D_A1_YCenter)(i_apx) + (*P_D_A1_YLow)(i_apx) <= I_XRow) &&
                ((*P_D_A1_YCenter)(i_apx) + (*P_D_A1_YHigh)(i_apx) >= I_XRow)){
                if ((((*P_D_A2_XCenters)(i_apx, I_XRow) + (*P_D_A1_XLow)(i_apx) <= D_XLow) && 
                     ((*P_D_A2_XCenters)(i_apx, I_XRow) + (*P_D_A1_XHigh)(i_apx) >= D_XLow)) || 
                    (((*P_D_A2_XCenters)(i_apx, I_XRow) + (*P_D_A1_XLow)(i_apx) <= D_XHigh) && 
                     ((*P_D_A2_XCenters)(i_apx, I_XRow) + (*P_D_A1_XHigh)(i_apx) >= D_XHigh))){
                    I_A2_AperturesWithCrossTalk(i_row, I_NXCorAps) = i_apx;
                    I_NXCorAps++;
                    if (I_NXCorAps > 4){
                        cout << "MOptExtract_Obs_Sky: ERROR: More than 5 apertures with crosstalk found" << endl;
                        exit(EXIT_FAILURE);
                    }
                }
            }
        }
      }
      cout << "MOptExtract_Obs_Sky::main: I_A1_AperturesToExtract(" << i_ap << ") = " << I_A1_AperturesToExtract(i_ap) << ": I_A2_AperturesWithCrossTalk = " << I_A2_AperturesWithCrossTalk << endl;
      
      /// Create D_A2_Aperture and populate array
      Array<double, 1> D_A1_XCenters(F_Image.GetNRows());
      D_A1_XCenters = (*P_D_A2_XCenters)(I_A1_AperturesToExtract(i_ap), Range::all()) + 0.5;
      Array<int, 2> I_A2_MinCenMax(F_Image.GetNRows(), 3);
      I_A2_MinCenMax = 0;
      if (!F_Image.CalcMinCenMax(I_A1_AperturesToExtract(i_ap), I_A2_MinCenMax)){
	cout << "MOptExtract_Obs_Sky::main: ERROR: CalcMinCenMax(" << I_A1_AperturesToExtract(i_ap) << " returned FALSE" << endl;
	exit(EXIT_FAILURE);
      }
//  return false;
      
      int I_NXSF = I_A2_MinCenMax(0,2) - I_A2_MinCenMax(0,0) + 1;// - I_NPixCut_Left - I_NPixCut_Right;
      cout << "MOptExtract_Obs_Sky::main: I_NXSF = " << I_NXSF << endl;
      Array<double, 2> D_A2_Aperture((*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap)) - (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)) + 1, I_NXSF);
      Array<double, 2> D_A2_ErrIn(D_A2_Aperture.rows(), D_A2_Aperture.cols());
      for (int i_row=0; i_row<D_A2_Aperture.rows(); i_row++){
          int I_RowIm = (*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)) + i_row;
          cout << "I_A1_AperturesToExtract(" << i_ap << ") = " << I_A1_AperturesToExtract(i_ap) << ": i_row = " << i_row << ", I_RowIm = " << I_RowIm << endl;
          int I_ColImMin = (*P_D_A2_XCenters)(I_A1_AperturesToExtract(i_ap), I_RowIm) + (*P_D_A1_XLow)(I_A1_AperturesToExtract(i_ap));
          cout << "I_A1_AperturesToExtract(" << i_ap << ") = " << I_A1_AperturesToExtract(i_ap) << ": i_row = " << i_row << ", I_ColImMin = " << I_ColImMin << endl;
          int I_ColImMax = I_ColImMin + I_NXSF - 1;
          cout << "I_A1_AperturesToExtract(" << i_ap << ") = " << I_A1_AperturesToExtract(i_ap) << ": i_row = " << i_row << ", I_ColImMax = " << I_ColImMax << endl;
          D_A2_Aperture(i_row, Range::all()) = F_Image.GetPixArray()(I_RowIm, Range(I_ColImMin, I_ColImMax));
          cout << "MOptExtract_Obs_Sky::main: I_A1_AperturesToExtract(" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A2_Aperture(" << i_row << ", *) set to " << D_A2_Aperture(i_row, Range::all()) << endl;
          D_A2_ErrIn(i_row, Range::all()) = F_Image.GetErrArray()(I_RowIm, Range(I_ColImMin, I_ColImMax));
      }
      
      /// Create D_A2_ApertureSF and populate array
      
      /// Find rows without crosstalk
      Array<int, 1> I_A1_Where(I_A2_AperturesWithCrossTalk.rows());
      I_A1_Where = where(I_A2_AperturesWithCrossTalk(Range::all(), 1) < 0, 1, 0);
      int I_NGood = 0;
      Array<int, 1> *P_I_A1_Ind = F_Image.GetIndex(I_A1_Where, I_NGood);
      Array<double, 2> D_A2_ApertureSF(I_NGood, D_A2_Aperture.cols());
      Array<double, 2> D_A2_ErrInSF(I_NGood, D_A2_Aperture.cols());
      
      Array<double, 1> D_A1_XCenMXC(D_A2_Aperture.rows());
      D_A1_XCenMXC = D_A1_XCenters(Range((*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)), 
                                         (*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap))))
      - I_A2_MinCenMax(Range((*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)), 
                             (*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YHigh)(I_A1_AperturesToExtract(i_ap))),1);
      cout << "CFits::MkSlitFunc: D_A1_XCenMXC = " << D_A1_XCenMXC << endl;
      Array<double, 1> D_A1_XCenMXCSF(D_A2_ApertureSF.rows());
      D_A1_XCenMXCSF = 0.;
      
      for (int i_row=0; i_row<I_NGood; i_row++){
          D_A2_ApertureSF(i_row, Range::all()) = D_A2_Aperture((*P_I_A1_Ind)(i_row), Range::all());
          D_A2_ErrInSF(i_row, Range::all()) = D_A2_ErrIn((*P_I_A1_Ind)(i_row), Range::all());
          D_A1_XCenMXCSF(i_row) = D_A1_XCenMXC((*P_I_A1_Ind)(i_row));
      }
      cout << "MOptExtract_Obs_Sky::main: I_A1_AperturesToExtract(" << i_ap << ")=" << I_A1_AperturesToExtract(i_ap) << ": D_A2_ApertureSF set to " << D_A2_ApertureSF << endl;
      Array<double, 1> D_A1_SP(D_A2_ApertureSF.rows());
      D_A1_SP = 0.;
      Array<double, 2> D_A2_SFSM(D_A2_ApertureSF.rows(), D_A2_ApertureSF.cols());
      D_A2_SFSM = 0.;
      
      /// Set profile fitting parameters
      Array<CString, 1> cs_a1(23);
      void **args = (void**)malloc(sizeof(void*) * 23);
      int pppos = 0;
      
      cs_a1(pppos) = CString("TELLURIC");
      args[pppos] = &I_Telluric;
//      #ifdef __DEBUG_FITS_MKSLITFUNC__
        cout << "args[pppos=" << pppos << "] set to I_Telluric = " << *(int*)args[pppos] << endl;
//      #endif
      pppos++;
      
      Array<double, 1> D_A1_XCorProf_Out(F_Image.GetNRows());
      D_A1_XCorProf_Out = 0.;
      if (I_XCorProf > 0){
        cs_a1(pppos) = CString("XCOR_PROF");
        args[pppos] = &I_XCorProf;
//        #ifdef __DEBUG_FITS_MKSLITFUNC__
          cout << "args[pppos=" << pppos << "] set to I_XCorProf = " << *(int*)args[pppos] << endl;
//        #endif
        pppos++;

        cs_a1(pppos) = CString("XCOR_PROF_OUT");
        args[pppos] = &D_A1_XCorProf_Out;
        pppos++;
      }

      int I_Telluric = 2;      

      cs_a1(pppos) = CString("LAMBDA_SF");
      pppos++;

      cs_a1(pppos) = CString("LAMBDA_SP");
      pppos++;

      cs_a1(pppos) = CString("WING_SMOOTH_FACTOR");
      pppos++;

      cs_a1(pppos) = CString("XLOW");
      pppos++;

      cs_a1(pppos) = CString("SP_OUT");
      pppos++;

      cs_a1(pppos) = CString("STOP");
      pppos++;

      cs_a1(pppos) = CString("MASK");
      pppos++;

      if (I_Telluric > 1)
      {
        cs_a1(pppos) = CString("SKY");
        pppos++;
        cs_a1(pppos) = CString("SP_FIT");
        pppos++;
      }

      Array<double, 1> D_A1_Errors_SP_Out(1);

//      if (this->ErrorsRead){
      cs_a1(pppos) = CString("ERRORS");
      pppos++;
      cs_a1(pppos) = CString("ERRORS_OUT");
      pppos++;
      cs_a1(pppos) = CString("ERRORS_SP_OUT");
      pppos++;
      if (I_Telluric > 1)
      {
        cs_a1(pppos) = CString("ERR_SKY");
        pppos++;
      }
//    }
      #ifdef __DEBUG_FITS_MKSLITFUNC__
        cout << "CFits::MkSlitFunc: cs_a1 = " << cs_a1 << endl;
        cout << "CFits::MkSlitFunc: pppos = " << pppos << endl;
      #endif

      int I_Stop = 0;

      #ifdef __DEBUG_FITS_MKSLITFUNC__
        cout << "CFits::MkSlitFunc: cs_a1 set to " << cs_a1 << endl;
      #endif

      pppos = 0;
      if (I_Telluric > 0)
        pppos++;
      if (I_XCorProf > 0){
	pppos++;
	pppos++;
      }

      args[pppos] = &D_SmoothSF;
      cout << "MOptExtract_Obs_Sky::main: D_SmoothSF = " << D_SmoothSF << endl;
      pppos++;

      args[pppos] = &I_SmoothSP;
      cout << "MOptExtract_Obs_Sky::main: I_SmoothSP = " << I_SmoothSP << endl;
      pppos++;

      args[pppos] = &D_WingSmoothFactor;
      cout << "MOptExtract_Obs_Sky::main: D_WingSmoothFactor = " << D_WingSmoothFactor << endl;
      pppos++;


      double D_XLow = (*P_D_A1_XLow)(I_A1_AperturesToExtract(i_ap));
      cout << "MOptExtract_Obs_Sky::main: D_XLow = " << D_XLow << endl;
      args[pppos] = &D_XLow;
      pppos++;

      Array<double, 1> D_A1_SP_Out(D_A2_ApertureSF.rows());
      D_A1_SP_Out = 0.;
      args[pppos] = &D_A1_SP_Out;
      pppos++;

      I_Stop = 0;
//      if (I_IBin == 6)
//      I_Stop = 1;
//    I_Stop = 0;
      args[pppos] = &I_Stop;
      pppos++;

      Array<int, 2> I_A2_MaskSF(D_A2_ApertureSF.rows(), D_A2_ApertureSF.cols());
      Array<int, 2> I_A2_Mask(D_A2_Aperture.rows(), D_A2_Aperture.cols());
      I_A2_Mask = 1;
      I_A2_MaskSF = 1;
//      if (I_Telluric < 3){
//        I_A2_Mask_Temp = I_A2_Msk;
//      }
//      else{
//	I_A2_Mask_Temp.resize(I_A2_Mask_Tel.rows(), I_A2_Mask_Tel.cols());
//        I_A2_Mask_Temp = I_A2_Mask_Tel;
//      }
//      I_A2_Mask = I_A2_Mask_Temp;
//      I_A2_MaskApTemp.resize(I_A2_Mask.rows(), I_A2_Mask.cols());
//      I_A2_MaskApTemp = I_A2_Mask_Temp;
      cout << "MOptExtract_Obs_Sky::main: I_A2_MaskSF = " << I_A2_MaskSF << endl;
      args[pppos] = &I_A2_MaskSF;//_Temp;
      pppos++;

      Array<double, 1> D_A1_SkySF(D_A2_ApertureSF.rows());
      D_A1_SkySF = 0.;
      Array<double, 1> D_A1_Sky(D_A2_Aperture.rows());
      D_A1_Sky = 0.;
      Array<double, 1> D_A1_SPFitSF(D_A2_ApertureSF.rows());
      D_A1_SPFitSF = 0.;
      Array<double, 1> D_A1_SPFit(D_A2_Aperture.rows());
      D_A1_SPFit = 0.;
      if (I_Telluric > 1)
      {
        args[pppos] = &D_A1_SkySF;
        pppos++;
        args[pppos] = &D_A1_SPFit;
        pppos++;
      }

//      if (this->ErrorsRead){
      args[pppos] = &D_A2_ErrInSF;
      pppos++;

      Array<double, 1> D_A1_ErrOut(D_A2_Aperture.rows());
      D_A1_ErrOut = 0.;
      Array<double, 1> D_A1_ErrOutSF(D_A2_ApertureSF.rows());
      D_A1_ErrOutSF = 0.;
      args[pppos] = &D_A1_ErrOutSF;
      pppos++;

      Array<double, 1> D_A1_ErrOut_SP(D_A2_Aperture.rows());
      D_A1_ErrOut_SP = 0.;
      Array<double, 1> D_A1_ErrOutSF_SP(D_A2_ApertureSF.rows());
      D_A1_ErrOutSF_SP = 0.;
      args[pppos] = &D_A1_ErrOutSF_SP;
      pppos++;

      Array<double, 1> D_A1_ErrOut_Sky(D_A2_Aperture.rows());
      D_A1_ErrOut_Sky = 0.;
      Array<double, 1> D_A1_ErrOutSF_Sky(D_A2_ApertureSF.rows());
      D_A1_ErrOutSF_Sky = 0.;
      if (I_Telluric > 1)
      {
        args[pppos] = &D_A1_ErrOutSF_Sky;
        pppos++;
      }
//      }

      cs_a1(pppos) = CString("DEBUGFILES_SUFFIX");
      CString CS_SF_DebugFilesSuffix("_Ap");
      CString *P_CS_Num = CS_SF_DebugFilesSuffix.IToA(I_A1_AperturesToExtract(i_ap));
      CS_SF_DebugFilesSuffix.Add(*P_CS_Num);
      delete(P_CS_Num);
//      CS_SF_DebugFilesSuffix.Add(CString("_IRunTel"));
//      P_CS_Num = CS_SF_DebugFilesSuffix.IToA(I_Run_Tel);
//      CS_SF_DebugFilesSuffix.Add(*P_CS_Num);
      CS_SF_DebugFilesSuffix.Add(CString("_Tel"));
      P_CS_Num = CS_SF_DebugFilesSuffix.IToA(I_Telluric);
      CS_SF_DebugFilesSuffix.Add(*P_CS_Num);
      delete(P_CS_Num);
//      if (B_MaximaOnly)
//	CS_SF_DebugFilesSuffix.Add(CString("_MaxOnly"));
      args[pppos] = &CS_SF_DebugFilesSuffix;
      pppos++;
      
      cs_a1(pppos) = CString("SFO_OUT");
      Array<double, 1> D_A1_SFO_Out(2);
      D_A1_SFO_Out = 0.;
      args[pppos] = &D_A1_SFO_Out;
      
      cout << "MOptExtract_Obs_Sky::main: D_A2_ErrInSF = " << D_A2_ErrInSF << endl;
      
      if (!F_Image.SlitFunc(D_A2_ApertureSF,
                            I_A1_AperturesToExtract(i_ap),
                            D_A1_XCenMXCSF,
                            D_A1_SP,
                            D_A2_SFSM,
                            cs_a1,
                            args)){
        cout << "MOptExtract_Obs_Sky::main: I_A1_AperturesToExtract(" << i_ap << ") = " << I_A1_AperturesToExtract(i_ap) << ": ERROR: SlitFunc returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      cout << "MOptExtract_Obs_Sky::main: SlitFunc returned TRUE" << endl;
      cout << "MOptExtract_Obs_Sky::main: D_A1_SFO_Out = " << D_A1_SFO_Out << endl;
      for (int i_row=0; i_row<I_NGood; i_row++){
        I_A2_Mask((*P_I_A1_Ind)(i_row), Range::all()) = I_A2_MaskSF(i_row, Range::all());
      }
//      cout << "MOptExtract_Obs_Sky::main: Aperture " << I_A1_AperturesToExtract(i_ap) << ": I_A2_Mask = " << I_A2_Mask << endl;
//      exit(EXIT_FAILURE);
      
      int I_NPixSlitF = ((D_A2_Aperture.cols() + 1) * I_OverSample) + 1;
      if (I_NPixSlitF != D_A1_SFO_Out.size()){
        cout << "MOptExtract_Obs_Sky::main: ERROR: I_NPixSlitF=" << I_NPixSlitF << " != D_A1_SFO_Out.size()=" << D_A1_SFO_Out.size() << endl;
        exit(EXIT_FAILURE);
      }
      
      if (I_A2_AperturesWithCrossTalk.rows() != D_A2_Aperture.rows()){
        cout << "MOptExtract_Obs_Sky::main: ERROR: I_A2_AperturesWithCrossTalk.rows(=" << I_A2_AperturesWithCrossTalk.rows() << ") != D_A2_Aperture.rows(=" << D_A2_Aperture.rows() << ")" << endl;
        exit(EXIT_FAILURE);
      }
      Array<double, 1> D_A1_SF(D_A2_Aperture.cols());

      /// parameters for LinFitBevington      
      Array<CString, 1> CS_A1_Args_Fit(5);
      void **PP_Args_Fit = (void**)malloc(sizeof(void*) * 5);
      CS_A1_Args_Fit(0) = CString("MEASURE_ERRORS_IN");
      CS_A1_Args_Fit(1) = CString("REJECT_IN");
      CS_A1_Args_Fit(2) = CString("MASK_INOUT");
      CS_A1_Args_Fit(3) = CString("SIGMA_OUT");
      CS_A1_Args_Fit(4) = CString("YFIT_OUT");
      
      for (int i_row=0; i_row<D_A2_Aperture.rows(); i_row++){
        int I_Row = (*P_D_A1_YCenter)(I_A1_AperturesToExtract(i_ap)) + (*P_D_A1_YLow)(I_A1_AperturesToExtract(i_ap)) + i_row;
        /// Calculate profile for row
        if (!F_Image.CalcSF(I_A1_AperturesToExtract(i_ap),
                            I_Row,
                            D_A1_SFO_Out,
                            D_A1_SF)){
          cout << "MOptExtract_Obs_Sky::main: ERROR: CalcSF(" << I_A1_AperturesToExtract(i_ap) << ", " << I_Row << ", " << D_A1_SFO_Out << ", D_A1_SF) returned FALSE" << endl;
          exit(EXIT_FAILURE);
        }
        cout << "MOptExtract_Obs_Sky::main: aperture " << I_A1_AperturesToExtract(i_ap) << ": i_row " << i_row << ": I_Row = " << I_Row << ": D_A1_SF = " << D_A1_SF << endl;
        
        if (I_A2_AperturesWithCrossTalk(i_row, 1) >= 0){/// at least one other aperture cross talking
          int I_XTA_Ap = I_A2_AperturesWithCrossTalk(i_row, 1);
          Array<double, 1> D_A1_XTA_SF(D_A1_SF.size());
          D_A1_XTA_SF = 0.;
          if (!F_Image.CalcSF(I_XTA_Ap,
                              I_Row,
                              D_A1_SFO_Out,
                              D_A1_XTA_SF)){
            cout << "MOptExtract_Obs_Sky::main: ERROR: CalcSF(" << I_A2_AperturesWithCrossTalk(i_row, 1) << ", " << I_Row << ", " << D_A1_SFO_Out << ", D_A1_XTA_SF) returned FALSE" << endl;
            exit(EXIT_FAILURE);
          }
          cout << "MOptExtract_Obs_Sky::main: aperture " << I_A2_AperturesWithCrossTalk(i_row, 1) << ": i_row " << i_row << ": I_Row = " << I_Row << ": D_A1_XTA_SF = " << D_A1_XTA_SF << endl;
            
          if (I_A2_AperturesWithCrossTalk(i_row, 2) >= 0){/// at least two other apertures cross talking
            if (I_A2_AperturesWithCrossTalk(i_row, 3) >= 0){/// at least three other apertures cross talking
              cout << "MOptExtract_Obs_Sky::main: ERROR: more than 2 apertures cross-talking: I_A2_AperturesWithCrossTalk(i_row, *) = " << I_A2_AperturesWithCrossTalk(i_row, Range::all());
              exit(EXIT_FAILURE);
            }
            int I_XTB_Ap = I_A2_AperturesWithCrossTalk(i_row, 2);
            Array<double, 1> D_A1_XTB_SF(D_A1_SF.size());
            D_A1_XTB_SF = 0.;
            if (!F_Image.CalcSF(I_XTB_Ap,
                                I_Row,
                                D_A1_SFO_Out,
                                D_A1_XTA_SF)){
              cout << "MOptExtract_Obs_Sky::main: ERROR: CalcSF(" << I_A2_AperturesWithCrossTalk(i_row, 2) << ", " << I_Row << ", " << D_A1_SFO_Out << ", D_A1_XTA_SF) returned FALSE" << endl;
              exit(EXIT_FAILURE);
            }
            cout << "MOptExtract_Obs_Sky::main: aperture " << I_A2_AperturesWithCrossTalk(i_row, 2) << ": i_row " << i_row << ": I_Row = " << I_Row << ": D_A1_XTA_SF = " << D_A1_XTA_SF << endl;
          }
        }
        else{/// no crosstalk => normal extraction
          Array<double, 1> D_A1_CCD(D_A2_Aperture.cols());
          D_A1_CCD = D_A2_Aperture(i_row, Range::all());
          cout << "MOptExtract_Obs_Sky::main: Aperture " << I_A1_AperturesToExtract(i_ap) << ": i_row = " << i_row << ": I_Row = " << I_Row << ": D_A1_CCD = " << D_A1_CCD << endl;
          Array<int, 1> I_A1_Mask(I_A2_Mask.cols());
          I_A1_Mask = I_A2_Mask(i_row, Range::all());
          cout << "MOptExtract_Obs_Sky::main: Aperture " << I_A1_AperturesToExtract(i_ap) << ": i_row = " << i_row << ": I_Row = " << I_Row << ": I_A1_Mask = " << I_A1_Mask << endl;
          Array<double, 1> D_A1_ImTimesMask(D_A1_CCD.size());
          D_A1_ImTimesMask = D_A1_CCD * I_A1_Mask;
          cout << "MOptExtract_Obs_Sky::main: Aperture " << I_A1_AperturesToExtract(i_ap) << ": i_row = " << i_row << ": I_Row = " << I_Row << ": D_A1_ImTimesMask = " << D_A1_ImTimesMask << endl;
          Array<double, 1> D_A1_SFTimesMask(D_A1_CCD.size());
          D_A1_SFTimesMask = D_A1_SF * I_A1_Mask;
          cout << "MOptExtract_Obs_Sky::main: Aperture " << I_A1_AperturesToExtract(i_ap) << ": i_row = " << i_row << ": I_Row = " << I_Row << ": D_A1_SFTimesMask = " << D_A1_SFTimesMask << endl;
          PP_Args_Fit[2] = &I_A1_Mask;
          Array<double, 1> D_A1_Err(D_A1_CCD.size());
          D_A1_Err = D_A2_ErrIn(i_row, Range::all());
          cout << "MOptExtract_Obs_Sky::main: Aperture " << I_A1_AperturesToExtract(i_ap) << ": i_row = " << i_row << ": I_Row = " << I_Row << ": D_A1_Err = " << D_A1_Err << endl;
          PP_Args_Fit[0] = &D_A1_Err;
          double D_Reject = 4.;
          PP_Args_Fit[1] = &D_Reject;
          Array<double, 1> D_A1_Sigma_Out(2);
          D_A1_Sigma_Out = 0.;
          PP_Args_Fit[3] = &D_A1_Sigma_Out;
          Array<double, 1> D_A1_YFit_Out(D_A1_CCD.size());
          D_A1_YFit_Out = 0.;
          PP_Args_Fit[4] = &D_A1_YFit_Out;
          double D_MySP = 0.;
          double D_Sky = 1.;
          if (!F_Image.LinFitBevington(D_A1_ImTimesMask,
                                       D_A1_SFTimesMask,
                                       D_MySP,
                                       D_Sky,
                                       false,
                                       CS_A1_Args_Fit,
                                       PP_Args_Fit)){
            /// MEASURE_ERRORS_IN = Array<double,1>(D_A1_CCD_In.size)             : in
            /// REJECT_IN = double                                                : in
            /// MASK_INOUT = Array<int,1>(D_A1_CCD_In.size)                    : in/out
            /// SIGMA_OUT = Array<double,1>(2): [*,0]: sigma_sp, [*,1]: sigma_sky : out
            /// YFIT_OUT = Array<double, 1>(D_A1_CCD_In.size)                     : out
            cout << "MOptExtract_Obs_Sky::main: Aperture " << I_A1_AperturesToExtract(i_ap) << ": ERROR: LinFitBevington returned FALSE!" << endl;
            return false;
          }
          cout << "MOptExtract_Obs_Sky::main: Aperture " << I_A1_AperturesToExtract(i_ap) << ": i_row = " << i_row << ": I_Row = " << I_Row << ": D_MySP = " << D_MySP << ", D_Sky = " << D_Sky << ", D_A1_Sigma_Out = " << D_A1_Sigma_Out << ", D_A1_YFit_Out = " << D_A1_YFit_Out << endl;
          
        }
      }
      
      delete(P_D_A2_XCenters);
      delete(P_D_A1_XLow);
      delete(P_D_A1_XHigh);
      delete(P_D_A1_YCenter);
      delete(P_D_A1_YLow);
      delete(P_D_A1_YHigh);
      exit(EXIT_FAILURE);
    }
    
    seconds = time(NULL);
    cout << "MGaussExtract_Obs_Sky::main: MPFitThreeGaussExtract returned true at " << seconds << endl;

    /// Set CS_FitsFileName_In
    cout << "MGaussExtract_Obs_Sky::main: Starting F_OutImage.SetFileName(" << CS_A1_FitsFileNames_In(i_file) << ")" << endl;
    if (!F_OutImage.SetFileName(CS_A1_FitsFileNames_In(i_file)))
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName(" << CS_A1_FitsFileNames_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    F_ErrImage.SetFileName(CS_A1_FitsFileNames_In(i_file));

    ///Read FitsFile
    cout << "MGaussExtract_Obs_Sky::main: Starting F_OutImage.ReadArray()" << endl;
    if (!F_OutImage.ReadArray())
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.ReadArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    F_ErrImage.ReadArray();

    if (!F_OutImage.SetDatabaseFileName(CS_DatabaseFileName_In)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
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

    if (!F_ErrImage.SetDatabaseFileName(CS_DatabaseFileName_In)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.SetDatabaseFileName(" << CS_DatabaseFileName_In << ") returned FALSE!" << endl;
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
      cout << "MGaussExtract_Obs_Sky::main: Starting to write MaskOut" << endl;
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
    cout << "MGaussExtract_Obs_Sky::main: Starting F_OutImage.SetFileName(" << CS_FitsFileName_Out << ")" << endl;
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
    cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Write spectra to individual files" << endl;
    if (!F_OutImage.WriteApertures(CS_ImageName_ApsRoot, CS_A1_ApertureFitsFileNames, I_A1_AperturesToExtract)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteApertures() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    CString CS_ErrImageName_Aps_Root(" ");
    CS_ErrImageName_Aps_Root.Set(CS_ImageName_ApsRoot);
    CS_ErrImageName_Aps_Root.Add(CString("Err"));
    F_ErrImage.GetPixArray() = F_Image.GetErrorsEc();
    if (!F_ErrImage.WriteApertures(CS_ErrImageName_Aps_Root, CS_A1_ApertureFitsFileNamesErr, I_A1_AperturesToExtract)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.WriteApertures() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    CS_ErrImageName_Aps_Root.Set(CS_ImageName_ApsRoot);
    CS_ErrImageName_Aps_Root.Add(CString("Err"));
    F_ErrImage.GetPixArray() = F_Image.GetErrorsEcFit();
    if (!F_ErrImage.WriteApertures(CS_ErrImageName_Aps_Root, CS_A1_ApertureFitsFileNamesErr, I_A1_AperturesToExtract)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.WriteApertures() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

//    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
//      F_ErrImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetErrorsEc()((*P_I_A1_Apertures)(i_ap), Range::all());
//    F_ErrImage.GetPixArray() = F_Image.GetErrorsEcFit();
//    CString CS_ErrEc(" ");
//    CS_ErrEc.Set(CS_ImageName_ApsRoot);
//    CS_ErrEc.Add(CString("Err.fits"));
    if (!F_ErrImage.SetFileName(CS_ErrImage)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.SetFileName(" << CS_ErrImage << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.WriteArray()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_ErrImage.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Apply dispersion correction: creating list" << endl;
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

    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNamesErr, CString(".fits"), CString("D.text"), CS_A1_TextFiles_Err_EcD_Out)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: 1. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Apply dispersion correction: CS_A1_TextFiles_EcD_Out = " << CS_A1_TextFiles_EcD_Out << endl;
    CString CS_ErrTextFiles_EcD(" ");
    CS_ErrTextFiles_EcD.Set(CS_ErrImageName_Aps_Root);
    CS_ErrTextFiles_EcD.Add(CString("D_text.list"));

    CS_FitsFileName_In.WriteStrListToFile(CS_A1_TextFiles_Err_EcD_Out,CS_ErrTextFiles_EcD);

    cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Apply dispersion correction: Starting DispCorList" << endl;
    if (!F_OutImage.DispCorList(CS_A1_TextFiles_Coeffs_In, CS_A1_TextFiles_EcD_Out, D_MaxRMS_In, I_A1_AperturesToExtract)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: DispCorList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!F_ErrImage.DispCorList(CS_A1_TextFiles_Coeffs_In, CS_A1_TextFiles_Err_EcD_Out, D_MaxRMS_In, I_A1_AperturesToExtract)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: DispCorList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
//    exit(EXIT_FAILURE);
//    if (!F_OutImage.PhotonsToFlux(CS_A1_TextFiles_EcD_Out, CS_A1_TextFiles_EcDFlux_Out, , I_A1_AperturesToExtract)){
//      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: DispCorList returned FALSE!" << endl;
//      exit(EXIT_FAILURE);
//    }

    cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Rebin spectra: Creating File List" << endl;
    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNames, CString(".fits"), CString("DR.text"), CS_A1_TextFiles_EcDR_Out)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: 2. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CS_FitsFileName_In.StrReplaceInList(CS_A1_ApertureFitsFileNamesErr, CString(".fits"), CString("DR.text"), CS_A1_TextFiles_Err_EcDR_Out)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: 2. StrReplaceInList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Rebin spectra: CS_A1_TextFiles_EcDR_Out = " << CS_A1_TextFiles_EcDR_Out << endl;

    CS_FitsFileNameEcDR_Out.Set(CS_ImageName_ApsRoot);
    CS_FitsFileNameEcDR_Out.Add(CString("DR.fits"));
    cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Rebin spectra: Starting RebinTextList" << endl;
    if (!F_Image.RebinTextList(CS_A1_TextFiles_EcD_Out, CS_A1_TextFiles_EcDR_Out, CS_FitsFileNameEcDR_Out, D_WLen_Start, D_WLen_End, D_DWLen, true)){
      cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": ERROR: RebinTextList returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    CS_FitsFileNameErrEcDR_Out.Set(CS_ErrImageName_Aps_Root);
    CS_FitsFileNameErrEcDR_Out.Add(CString("DR.fits"));
    cout << "MGaussExtract_Obs_Sky::main: i_file = " << i_file << ": Rebin err spectra: Starting RebinTextList" << endl;
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
    for (int iaps=0; iaps<I_A1_Apertures_Object.size(); iaps++){
      D_A2_Spec_Obs(iaps, Range::all()) = CF_EcDR.GetPixArray()(iaps, Range::all());
      D_A2_Err_Obs(iaps, Range::all()) = CF_ErrEcDR.GetPixArray()(iaps, Range::all());
    }
//    cout << "MGaussExtract_Obs_Sky::main: D_A2_Spec_Obs = " << D_A2_Spec_Obs << endl;
    Array<double, 2> D_A2_Spec_Sky(I_A1_Apertures_Sky.size(), CF_EcDR.GetNCols());
    Array<double, 2> D_A2_Err_Sky(I_A1_Apertures_Sky.size(), CF_EcDR.GetNCols());
    int i_aps = 0;
    for (int iaps=I_A1_Apertures_Object.size(); iaps<I_A1_Apertures_Object.size()+I_A1_Apertures_Sky.size(); iaps++){
      D_A2_Spec_Sky(i_aps, Range::all()) = CF_EcDR.GetPixArray()(iaps, Range::all());
      D_A2_Err_Sky(i_aps, Range::all()) = CF_ErrEcDR.GetPixArray()(iaps, Range::all());
      i_aps++;
    }
//    cout << "MGaussExtract_Obs_Sky::main: D_A2_Spec_Sky = " << D_A2_Spec_Sky << endl;
    Array<double, 2> D_A1_Sky(1, D_A2_Spec_Obs.cols());
    D_A1_Sky = 0.;
    for (int ipix=0; ipix<D_A2_Spec_Obs.cols(); ipix++){
      D_A1_Sky(0, ipix) = CF_EcDR.Median(D_A2_Spec_Sky(Range::all(), ipix));
      D_A2_Spec_Obs(Range::all(), ipix) = D_A2_Spec_Obs(Range::all(), ipix) - D_A1_Sky(0, ipix);
    }
//    cout << "MGaussExtract_Obs_Sky::main: after sky subtraction: D_A2_Spec_Obs = " << D_A2_Spec_Obs << endl;
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

    Array<double, 2> D_A2_Spec_Obs_Flux(I_NElements, 2);
    D_A2_Spec_Obs_Flux = 0.;

    if (!CF_EcDR.PhotonsToFlux(D_A2_Spec_Obs, D_A1_ExpTimes(i_file), D_ATel, D_A2_Spec_Obs_Flux)){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: PhotonsToFlux(" << D_A2_Spec_Obs << ", " << D_A1_ExpTimes(i_file) << ", " << D_ATel << ", D_A2_Spec_Obs_Flux) returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    CS_Obs_Out.Set(CS_ImageName_ApsRoot);
    CS_Obs_Out.Add(CString("DR_Obs-Sky_Sum_Flux.text"));
    if (!CF_EcDR.WriteArrayToFile(D_A2_Spec_Obs_Flux, CS_Obs_Out, CString("ascii"))){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: WriteArrayToFile(" << D_A2_Spec_Obs_Flux << ", " << CS_Obs_Out << ", ascii) returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    /// Write RecFitOut 2D
//    if (P_CS_RecFitOut->GetLength() > 1){
      if (!F_Image.SetFileName(CS_A1_RecFitOut(i_file)))
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      cout << "MGaussExtract_Obs_Sky::main: Starting to write RecFitOut" << endl;
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
      cout << "MGaussExtract_Obs_Sky::main: Starting to write ProfileOut" << endl;
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
      cout << "MGaussExtract_Obs_Sky::main: Starting to write SkyArrOut" << endl;
      F_Image.GetPixArray() = F_Image.GetRecSkyArray();
      cout << "MGaussExtract_Obs_Sky::main: F_Image.GetRecSkyArray().rows() = " << F_Image.GetRecSkyArray().rows() << endl;
      cout << "MGaussExtract_Obs_Sky::main: F_Image.GetRecSkyArray().cols() = " << F_Image.GetRecSkyArray().cols() << endl;
      if (!F_Image.WriteArray())
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
//    }

    /// Write ErrOut 2D
    if (P_CS_ErrOut->GetLength() > 1){
      cout << "MGaussExtract_Obs_Sky::main: Writing F_Image.GetErrArray()" << endl;
      if (!F_Image.SetFileName(CS_A1_ErrOut(i_file)))
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      cout << "MGaussExtract_Obs_Sky::main: Starting to write ErrOut" << endl;
      cout << "MGaussExtract_Obs_Sky::main: F_Image.GetErrArray().rows() = " << F_Image.GetErrArray().rows() << endl;
      cout << "MGaussExtract_Obs_Sky::main: F_Image.GetErrArray().cols() = " << F_Image.GetErrArray().cols() << endl;
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
    cout << "MGaussExtract_Obs_Sky::main: Starting to write EcOut" << endl;
    F_OutImage.SetNRows(P_I_A1_Apertures->size());
    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
      F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetLastExtracted()((*P_I_A1_Apertures)(i_ap), Range::all());//.transpose(secondDim, firstDim);

  //cout << "MExctract: F_Image.GetSpec = " << F_Image.GetSpec() << endl;

  // Write Profile Image
/*  if (!F_OutImage.SetFileName(CS_FitsFileName_Out))
  {
    cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName(" << CS_FitsFileName_Out << ") returned FALSE!" << endl;
    exit(EXIT_FAILURE);
}*/
    cout << "MGaussExtract_Obs_Sky::main: Starting F_OutImage.WriteArray()" << endl;
    if (!F_OutImage.WriteArray())
    {
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }

    /// Write ErrOutEc 1D
    cout << "MGaussExtract_Obs_Sky::main: Writing F_Image.GetErrorsEc()" << endl;
    if (P_CS_ErrOutEc->GetLength() > 1)
    {
//      CS_A1_Args_ExtractFromProfile(1) = CString("");
//      if (!F_Image.ExtractErrors(CS_A1_Args_ExtractFromProfile, PP_Args_ExtractFromProfile))
//      {
//        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_Image.ExtractErrors() returned FALSE!" << endl;
//        exit(EXIT_FAILURE);
//      }
      if (!F_OutImage.SetFileName(CS_A1_ErrOutEc(i_file)))
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
      cout << "MGaussExtract_Obs_Sky::main: Starting to write ErrOutEc" << endl;
      for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
        F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetErrorsEc()((*P_I_A1_Apertures)(i_ap), Range::all());//.transpose(secondDim, firstDim);
      if (!F_OutImage.WriteArray())
      {
        cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
        exit(EXIT_FAILURE);
      }
    }

    /// Write SkyOut 1D
    if (!F_OutImage.SetFileName(CS_A1_SkyOut(i_file))){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.SetFileName() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MGaussExtract_Obs_Sky::main: Starting to write SkyOut" << endl;
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
    cout << "MGaussExtract_Obs_Sky::main: Starting to write SkyErrOut" << endl;
    for (int i_ap=0; i_ap<P_I_A1_Apertures->size(); i_ap++)
      F_OutImage.GetPixArray()(i_ap, Range::all()) = F_Image.GetSkyError()((*P_I_A1_Apertures)(i_ap), Range::all());//.transpose(secondDim, firstDim);
    if (!F_OutImage.WriteArray()){
      cout << "MGaussExtract_Obs_Sky::main: ERROR: F_OutImage.WriteArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
  }/// end for (i_file...)
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
