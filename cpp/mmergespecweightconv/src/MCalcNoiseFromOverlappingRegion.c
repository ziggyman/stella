/*
author:        Andreas Ritter
created:       01/08/2007
last edited:   01/08/2007
compiler:      gcc 4.0
basis machine: Ubuntu Linux 6.06 LTS
*/

#include "MCalcNoiseFromOverlappingRegion.h"

int main(int argc, char *argv[])
{
  double *P_WaveArr, P_FluxArrA, P_FluxArrB;
  long starta, enda, endb;

  if (argc < 6)
  {
    printf("MCalcNoiseFromOverlappingRegion: ERROR: Not enough parameters specified => Returning");
    printf("MCalcNoiseFromOverlappingRegion: USAGE: calcnoisefromoverlappingregion(wavearr: Double Array, fluxarra: Double Array, fluxarrb: Double Array, starta: Long, enda: long, endb: Long))");
    exit(0);
  }

  P_WaveArr = (double*)argv[1];

  printf("MCalcNoiseFromOverlappingRegion: P_WaveArr[enda=%d] = <%.7f>\n", enda, P_WaveArr[enda]);

  
  printf("Hello, world!\n");

  return EXIT_SUCCESS;
}
