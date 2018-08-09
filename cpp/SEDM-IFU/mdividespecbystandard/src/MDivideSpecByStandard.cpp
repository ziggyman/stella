/*
author: Andreas Ritter
created: 05/08/2012
last edited: 05/08/2012
compiler: g++ 4.4
basis machine: Arch Linux
*/

#include "MDivideSpecByStandard.h"

using namespace std;

int main(int argc, char *argv[])
{
  cout << "MDivideSpecByStandard::main: argc = " << argc << endl;
  if (argc < 4)
  {
    cout << "MDivideSpecByStandard::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: dividespecbystandard <char[] [@]FitsFileName_Spec> <char[] [@]FitsFileName_Standard> <char[] [@]FitsFileName_Out>" << endl;
    exit(EXIT_FAILURE);
  }

  /// read input parameters to CStrings
  CString CS_Op1_In((char*)argv[1]);
  cout << "MDivideSpecByStandard::main: CS_Op1_In set to " << CS_Op1_In << endl;

  CString CS_Op2_In = (char*)argv[2];
  cout << "MDivideSpecByStandard::main: CS_Op2_In set to " << CS_Op2_In << endl;

  CString CS_Out = (char*)argv[3];
  cout << "MDivideSpecByStandard::main: CS_Out set to " << CS_Out << endl;

  CFits F_Image;
  
  Array<CString, 1> CS_A1_Obs(1);
  CS_A1_Obs = CS_Op1_In;
  Array<CString, 1> CS_A1_Std(1);
  CS_A1_Std = CS_Op2_In;
  Array<CString, 1> CS_A1_Out(1);
  CS_A1_Out = CS_Out;

  if (CS_Op1_In.IsList()){
      if (!CS_Op1_In.ReadFileLinesToStrArr(CS_Op1_In, CS_A1_Obs)){
          cout << "MDivideSpecByStandard::main: ERROR: ReadFileLinesToStrArr(" << CS_Op1_In << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
      }
      if (!CS_Op2_In.ReadFileLinesToStrArr(CS_Op2_In, CS_A1_Std)){
          cout << "MDivideSpecByStandard::main: ERROR: ReadFileLinesToStrArr(" << CS_Op2_In << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
      }
      if (!CS_Op1_In.ReadFileLinesToStrArr(CS_Out, CS_A1_Out)){
          cout << "MDivideSpecByStandard::main: ERROR: ReadFileLinesToStrArr(" << CS_Out << ") returned FALSE" << endl;
          exit(EXIT_FAILURE);
      }
      if (CS_A1_Obs.size() != CS_A1_Std.size()){
          cout << "MDivideSpecByStandards::main: ERROR: Input lists must have same length" << endl;
          exit(EXIT_FAILURE);
      }
      if (CS_A1_Obs.size() != CS_A1_Out.size()){
          cout << "MDivideSpecByStandards::main: ERROR: Input lists must have same length" << endl;
          exit(EXIT_FAILURE);
      }
  }
  Array<double, 2> D_A2_Spec1(2,2);
  
  for (int i_file=0; i_file<CS_A1_Obs.size(); i_file++){
    if (!CS_Out.ReadFileToDblArr(CS_A1_Obs(i_file),
                                 D_A2_Spec1,
                                 CString(" "))){
      cout << "MDivideSpecByStandard::main: ERROR: ReadFileToDblArr(" << CS_A1_Obs(i_file) << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    Array<double, 2> D_A2_Spec2(2,2);
    if (!CS_Out.ReadFileToDblArr(CS_A1_Std(i_file),
                                 D_A2_Spec2,
                                 CString(" "))){
      cout << "MDivideSpecByStandard::main: ERROR: ReadFileToDblArr(" << CS_A1_Std(i_file) << ") returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    Array<double, 1> D_A1_Stand_X(D_A2_Spec2.rows());
    D_A1_Stand_X = D_A2_Spec2(Range::all(), 0);
    Array<double, 1> D_A1_Stand_Y(D_A2_Spec2.rows());
    D_A1_Stand_Y = D_A2_Spec2(Range::all(), 1) / 1.e16;

    Array<double, 1> D_A1_X(D_A2_Spec1.rows());
    D_A1_X = D_A2_Spec1(Range::all(), 0);

    Array<double, 1> D_A1_Out(2);

    if (!F_Image.InterPol(D_A1_Stand_Y,
                          D_A1_Stand_X,
                          D_A1_X,
                          D_A1_Out)){
      cout << "MDivideSpecByStandard::main: ERROR: InterPol returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }

    D_A2_Spec2.resize(D_A1_X.size(),2);
    D_A2_Spec2(Range::all(), 0) = D_A1_X;
    D_A2_Spec2(Range::all(), 1) = D_A1_Out;

    cout << "D_A2_Spec1 = " << D_A2_Spec1 << endl;
    cout << "D_A2_Spec2 = " << D_A2_Spec2 << endl;
//    exit(EXIT_FAILURE);

    Array<double, 2> D_A2_SpecOut(D_A2_Spec1.rows(), 2);
    D_A2_SpecOut(Range::all(), 0) = D_A1_X;

    D_A2_SpecOut(Range::all(), 1) = D_A2_Spec1(Range::all(), 1) / D_A2_Spec2(Range::all(), 1);

    if (!F_Image.WriteArrayToFile(D_A2_SpecOut, CS_A1_Out(i_file), CString("ascii"))){
      cout << "MDivideSpecByStandard::main: ERROR: WriteArrayToFile returned FALSE" << endl;
      exit(EXIT_FAILURE);
    }
    D_A1_Out = D_A2_SpecOut(Range::all(),1);

#ifdef __WITH_PLOTS__
    mglGraph gr;
    mglData MGLData_X;
    MGLData_X.Link(D_A1_X.data(), D_A1_X.size(), 0, 0);
    mglData MGLData_Ratio;
    MGLData_Ratio.Link(D_A1_Out.data(), D_A1_Out.size(), 0, 0);

    gr.SetRanges(min(D_A1_X),max(D_A1_X),min(D_A1_Out),max(D_A1_Out));//+(max(*P_D_A1_WLen_Out) - min(*P_D_A1_WLen_Out)) / 4.5);
    gr.Axis();
    gr.Label('x',"Wavelength",0);
    gr.Label('y',"Throughput",0);
    gr.Plot(MGLData_X, MGLData_Ratio, "k");
//      gr.AddLegend("Fit", "r");

    gr.Box();
    gr.Legend();

    CString *P_CS_Temp = CS_A1_Obs(i_file).SubString(0,CS_A1_Obs(i_file).LastCharPos('.')-1);
    P_CS_Temp->Add(CString("_WLen_Throughput.png"));
    gr.WriteFrame(P_CS_Temp->Get());


    /// clean up
    delete(P_CS_Temp);
#endif
  }
  return EXIT_SUCCESS;
}

