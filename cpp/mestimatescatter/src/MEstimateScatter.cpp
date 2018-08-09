/*
author: Andreas Ritter
created: 03/20/2007
last edited: 03/20/2007
compiler: g++ 4.0
basis machine: Ubuntu Linux 6.06
*/

#include "MEstimateScatter.h"

int main(int argc, char *argv[])
{
  cout << "MEstimateScatter::main: argc = " << argc << endl;
  if (argc < 6)
  {
    cout << "MEstimateScatter::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: estimatescatter <char[] [@]FitsFileName_In> <char[] [@]ScatteredLightFitsFileName_Out> <int ClusterSizeX_In> <int ClusterSizeY_In> <double D_RdNoise_In> [AREA=[<int I_XMin>,<int I_XMax>,<int I_YMin>,<int I_YMax>]] [MEDIAN=1] [METHOD=<string method>] [IOPT=<int iopt>] [SMOOTH=<double smooth>]" << endl;
    cout << "Parameter 1: <char[] [@]FitsFileName_In>: FitsFile to calculate scattered light from" << endl;
    cout << "Parameter 2: <char[] [@]ScatteredLightFitsFileName_Out>: output file name containing scattered light image" << endl;
    cout << "Parameter 3: <int ClusterSizeX_In>: size of rectangles in x direction to split up FitsFileName_In and calculate one scattered light value for the center of each rectangle (cluster)" << endl;
    cout << "Parameter 4: <int ClusterSizeY_In>: size of rectangles in y direction to split up FitsFileName_In and calculate one scattered light value for the center of each rectangle (cluster)" << endl;
    cout << "Parameter 5: <double D_RdNoise_In>: RdNoise of detector" << endl; 
    cout << "Parameter 6 (optional): [AREA=[<int I_XMin>,<int I_XMax>,<int I_YMin>,<int I_YMax>]]: You can specify a rectangular area for which you want the scattered light calculated. The rest of the image will be set to zero" << endl;
    cout << "Parameter 7 (optional): [MEDIAN=1]: if set, take median value of each cluster for the scattered light, otherwise take the minimum value plus 3 RdNoise" << endl;
    cout << "Parameter 8 (optional): [METHOD=<string [Kriging, Spline]>]: Method of interpolation" << endl;
    cout << "Parameter 9 (optional): [IOPT=<int [-1,0]>]: Only for METHOD==Spline: On entry iopt must specify whether a weighted least-squares spline (IOPT=-1) or a smoothing spline (IOPT=0) must be determined." << endl;
    cout << "Parameter 10 (optional): [SMOOTH=<double s>=0.>]: Only for METHOD==Spline: on entry (in case IOPT==0) s must specify the smoothing factor. s >= 0" << endl;
    exit(EXIT_FAILURE);
  }
  CString CS_FitsFileName_In((char*)argv[1]);
  CString CS_FitsFileName_Out((char*)argv[2]);
  int I_ClusterSizeX = atoi((char*)argv[3]);
  cout << "MEstimateScatter: I_ClusterSizeX = " << I_ClusterSizeX << endl;
  int I_ClusterSizeY = atoi((char*)argv[4]);
  cout << "MEstimateScatter: I_ClusterSizeY = " << I_ClusterSizeY << endl;
  double D_RdNoise_In = double(atof((char*)argv[5]));
  
  Array<CString, 1> CS_A1_FitsFileNames_In(1);
  CS_A1_FitsFileNames_In = CS_FitsFileName_In;
  Array<CString, 1> CS_A1_FitsFileNames_Out(1);
  CS_A1_FitsFileNames_Out = CS_FitsFileName_Out;
  CString CS(" ");
  if (CS_FitsFileName_In.IsList()){
    if (!CS.ReadFileLinesToStrArr(CS_FitsFileName_In, CS_A1_FitsFileNames_In)){
      cout << "MEstimateScatter::main: ERROR: ReadFileLinesToStrArr(" << CS_FitsFileName_In << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CS_FitsFileName_Out.IsList()){
      cout << "MEstimateScatter::main: ERROR: " << CS_FitsFileName_In << " is list, but " << CS_FitsFileName_Out << " is not" << endl;
      exit(EXIT_FAILURE);
    }
    if (!CS.ReadFileLinesToStrArr(CS_FitsFileName_Out, CS_A1_FitsFileNames_Out)){
      cout << "MEstimateScatter::main: ERROR: ReadFileLinesToStrArr(" << CS_FitsFileName_Out << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
  }
  else{
    if (CS_FitsFileName_Out.IsList()){
      cout << "MEstimateScatter::main: ERROR: " << CS_FitsFileName_In << " is not a list, but " << CS_FitsFileName_Out << " is" << endl;
      exit(EXIT_FAILURE);
    }
  }
  
  Array<CString, 1> CS_A1_Args(5);
  CS_A1_Args = CString(" ");
  void **PP_Args = (void**)malloc(sizeof(void*) * 5);
  CS_A1_Args(2) = CString("METHOD");
  CS_A1_Args(3) = CString("IOPT");
  CS_A1_Args(4) = CString("SMOOTH");
  
  CString CS_comp(" ");
  CString *P_CS;
  Array<int, 1> I_A1_Area(4);
  bool B_Area_Set = false;
  bool B_Median_Set = false;
  CString CS_Method("Kriging");
  float smooth = 0.;
  int iopt = 0;
  for (int i_arg = 6; i_arg<=argc; i_arg++){
    CS.Set((char*)argv[i_arg]);
    
    CS_comp.Set("METHOD");
    if (CS.GetLength() > CS_comp.GetLength()){
      int cpos = CS.CharPos('=');
      if (cpos > 0){
        P_CS = CS.SubString(0,cpos-1);
        if (P_CS->EqualValue(CS_comp)){
          delete(P_CS);
          P_CS = CS.SubString(cpos+1);
          CS_Method.Set(*P_CS);
          delete(P_CS);
        }
      }
    }
    
    CS_comp.Set("IOPT");
    if (CS.GetLength() > CS_comp.GetLength()){
      int cpos = CS.CharPos('=');
      if (cpos > 0){
        P_CS = CS.SubString(0,cpos-1);
        if (P_CS->EqualValue(CS_comp)){
          delete(P_CS);
          P_CS = CS.SubString(cpos+1);
          iopt = P_CS->AToI();
          delete(P_CS);
        }
      }
    }
    
    CS_comp.Set("SMOOTH");
    if (CS.GetLength() > CS_comp.GetLength()){
      int cpos = CS.CharPos('=');
      if (cpos > 0){
        P_CS = CS.SubString(0,cpos-1);
        if (P_CS->EqualValue(CS_comp)){
          delete(P_CS);
          P_CS = CS.SubString(cpos+1);
          smooth = float(P_CS->AToD());
          delete(P_CS);
        }
      }
    }
    
    CS_comp.Set("MEDIAN");
    if (CS.GetLength() > CS_comp.GetLength()){
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MOptExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        B_Median_Set = true;
        CS_A1_Args(0) = CString("MEDIAN");
      }
      delete(P_CS);
    }
    CS_comp.Set("AREA");
    if (CS.GetLength() > CS_comp.GetLength()){
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      cout << "MOptExtract_Obs_Sky::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        B_Area_Set = true;
        CString cs_temp;
        cs_temp.Set(",");
        int i_pos_a = CS_comp.GetLength()+2;
        int i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        cout << "MOptExtract_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MOptExtract_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(0) = (int)(atoi(P_CS->Get()));
        cout << "MOptExtract_Obs_Sky: I_A1_Area(0) set to " << I_A1_Area(0) << endl;

        i_pos_a = i_pos_b+1;
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        cout << "MOptExtract_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MOptExtract_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(1) = (int)(atoi(P_CS->Get()));
        cout << "MOptExtract_Obs_Sky: I_A1_Area(1) set to " << I_A1_Area(1) << endl;

        i_pos_a = i_pos_b+1;
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        cout << "MOptExtract_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MOptExtract_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(2) = (int)(atoi(P_CS->Get()));
        cout << "MOptExtract_Obs_Sky: I_A1_Area(2) set to " << I_A1_Area(2) << endl;

        i_pos_a = i_pos_b+1;
        cs_temp.Set("]");
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        if (i_pos_b < 0){
          cs_temp.Set(")");
          i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        }
        cout << "MOptExtract_Obs_Sky: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        cout << "MOptExtract_Obs_Sky: P_CS set to " << *P_CS << endl;
        I_A1_Area(3) = (int)(atoi(P_CS->Get()));
        delete(P_CS);
        cout << "MOptExtract_Obs_Sky: I_A1_Area(3) set to " << I_A1_Area(3) << endl;

        CS_A1_Args(1) = CString("AREA");
        PP_Args[1] = &I_A1_Area;
        cout << "MOptExtract_Obs_Sky::main: I_A1_Area set to " << I_A1_Area << endl;
      }
    }
  }
  PP_Args[2] = &CS_Method;
  PP_Args[3] = &iopt;
  PP_Args[4] = &smooth;
  
  CFits F_Image;
  for (int i_file=0; i_file < CS_A1_FitsFileNames_In.size(); i_file++){
    if (!F_Image.SetFileName(CS_A1_FitsFileNames_In(i_file))){
      cout << "MEstimateScatter::main: ERROR: F_Image.SetFileName(" << CS_A1_FitsFileNames_In(i_file) << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MEstimateScatter::main: FileName <" << CS_A1_FitsFileNames_In(i_file) << "> set" << endl;

    /// set RdNoise
    if (!F_Image.Set_ReadOutNoise(D_RdNoise_In)){
      cout << "MEstimateScatter::main: ERROR: F_Image.Set_ReadOutNoise(" << D_RdNoise_In << ") returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    
    /// Read FitsFile
    if (!F_Image.ReadArray()){
      cout << "MEstimateScatter::main: ERROR: F_Image.ReadArray() returned FALSE!" << endl;
      exit(EXIT_FAILURE);
    }
    cout << "MEstimateScatter::main: F_Image: Array read" << endl;

    if (!B_Area_Set){
      I_A1_Area(0) = 0;
      I_A1_Area(1) = F_Image.GetNCols()-1;
      I_A1_Area(2) = 0;
      I_A1_Area(3) = F_Image.GetNRows()-1;
    }

    int I_NBoxesX = (I_A1_Area(1) - I_A1_Area(0) + 1) / (I_ClusterSizeX);
    int I_NBoxesY = (I_A1_Area(3) - I_A1_Area(2) + 1) / (I_ClusterSizeY);

    Array<double, 2> D_A2_ScatteredLight_Out(2,2);
    D_A2_ScatteredLight_Out = 0.;
    if (!F_Image.EstScatterKriging(I_NBoxesX, I_NBoxesY, D_A2_ScatteredLight_Out, CS_A1_Args, PP_Args)){
      cout << "MEstimateScatter::main: ERROR: F_Image.EstScatterKriging(" << I_NBoxesX << ", " << I_NBoxesY << ",...) returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    F_Image.WriteFits(&D_A2_ScatteredLight_Out, CS_A1_FitsFileNames_Out(i_file));
  }
  return EXIT_SUCCESS;
}
