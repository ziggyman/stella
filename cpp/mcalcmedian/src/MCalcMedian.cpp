/*
author: Andreas Ritter
created: 05/08/2012
last edited: 05/08/2012
compiler: g++ 4.4
basis machine: Arch Linux
*/

#include "MCalcMedian.h"

using namespace std;

int main(int argc, char *argv[])
{
  cout << "MCalcMedian::main: argc = " << argc << endl;
  if (argc < 2)
  {
    cout << "MCalcMedian::main: ERROR: Not enough parameters specified!" << endl;
    cout << "USAGE: calcmedian <char[] [@]FitsFileName_In> [AREA=[xmin,xmax,ymin,ymax]]" << endl;
    exit(EXIT_FAILURE);
  }

  CString CS_FitsFileName_In((char*)argv[1]);
  //cout << "MCalcMedian::main: CS_FitsFileName_In set to " << CS_FitsFileName_In << endl;

  /// AREA
  CString CS_comp(" ");
  CString CS(" ");
  CString *P_CS;
  Array<int, 1> I_A1_Area(4);
  I_A1_Area = 0;
  bool B_AreaSet = false;
  if (argc > 2){
    CS.Set((char*)argv[2]);
    CS_comp.Set("AREA");
    if (CS.GetLength() > CS_comp.GetLength()){
      delete(P_CS);
      P_CS = CS.SubString(0,CS.CharPos('=')-1);
      //cout << "MCalcMedian::main: *P_CS set to " << *P_CS << endl;
      if (P_CS->EqualValue(CS_comp)){
        CString cs_temp;
        cs_temp.Set(",");
        int i_pos_a = CS_comp.GetLength()+2;
        int i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        //cout << "MCalcMedian: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        //cout << "MCalcMedian: P_CS set to " << *P_CS << endl;
        I_A1_Area(0) = (int)(atoi(P_CS->Get()));
        //cout << "MCalcMedian: I_A1_Area(0) set to " << I_A1_Area(0) << endl;
      
        i_pos_a = i_pos_b+1;
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        //cout << "MCalcMedian: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        //cout << "MCalcMedian: P_CS set to " << *P_CS << endl;
        I_A1_Area(1) = (int)(atoi(P_CS->Get()));
        //cout << "MCalcMedian: I_A1_Area(1) set to " << I_A1_Area(1) << endl;
      
        i_pos_a = i_pos_b+1;
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        //cout << "MCalcMedian: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        //cout << "MCalcMedian: P_CS set to " << *P_CS << endl;
        I_A1_Area(2) = (int)(atoi(P_CS->Get()));
        //cout << "MCalcMedian: I_A1_Area(2) set to " << I_A1_Area(2) << endl;
      
        i_pos_a = i_pos_b+1;
        cs_temp.Set("]");
        i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        if (i_pos_b < 0){
          cs_temp.Set(")");
          i_pos_b = CS.StrPosFrom(cs_temp.GetPChar(),i_pos_a+1);
        }
        //cout << "MCalcMedian: i_pos_a set to " << i_pos_a << ", i_pos_b set to " << i_pos_b << endl;
        delete(P_CS);
        P_CS = CS.SubString(i_pos_a,i_pos_b-1);
        //cout << "MCalcMedian: P_CS set to " << *P_CS << endl;
        I_A1_Area(3) = (int)(atoi(P_CS->Get()));
        //cout << "MCalcMedian: I_A1_Area(3) set to " << I_A1_Area(3) << endl;
        
        B_AreaSet = true;
      }
    }
  }
  
  CFits CF;
  CF.SetFileName(CS_FitsFileName_In);
  CF.ReadArray();
  if (!B_AreaSet){
    I_A1_Area(0) = 0;///xmin
    I_A1_Area(1) = CF.GetNCols()-1;///xmax
    I_A1_Area(2) = 0;///ymin
    I_A1_Area(3) = CF.GetNRows()-1;///ymax
  }

//  cout << "CF.GetPixArray()(Range(" << I_A1_Area(2) << "," << I_A1_Area(3) << "), Range(" << I_A1_Area(0) << "," << I_A1_Area(1) << ")) = " << CF.GetPixArray()(Range(I_A1_Area(2), I_A1_Area(3)), Range(I_A1_Area(0), I_A1_Area(1))) << endl;
  double D_Median =  CF.Median(CF.GetPixArray()(Range(I_A1_Area(2), I_A1_Area(3)), Range(I_A1_Area(0), I_A1_Area(1))), false);
  
  FILE *fp = fopen("calcmedian.out","wt");
  fprintf(fp, "%.3f\n", D_Median);
  fclose(fp);

  /// clean up

  return EXIT_SUCCESS;
}

