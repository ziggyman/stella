/****************************************************/
/* Andreas Ritter                                   */
/* aritter@aip.de                                   */
/* gcc-4.0                                          */
/* 09/03/06                                         */
/****************************************************

#include "azuricommon.h"

long countlines(const char fname[255])
{
#ifdef __DEBUG_AZURICOMMON__
  //  fprintf(logfile,"azuricommon.countlines: method started\n");
#endif
  FILE *ffile;
  long nelements;
  char oneword[255];
  char *line;

#ifdef __DEBUG_AZURICOMMON__
  printf("azuricommon.countlines: function started\n");
#endif
  ffile = fopen(fname, "r");
  if (ffile == NULL)
  {
    printf("azuricommon.countlines: Failed to open file fname (=<%s>)\n", fname);
    return 0;
  }
#ifdef __DEBUG_AZURICOMMON__
  printf("azuricommon.countlines: File fname(=<%s>) opened\n", fname);
#endif

  nelements = 0;
  // --- read file <fname> named <ffile>
  do
  {
    line = fgets(oneword, 255, ffile);
    if (line != NULL)
    {
#ifdef __DEBUG_AZURICOMMON__
      //      printf("azuricommon.countlines: oneword = <%s>\n", oneword);
#endif
      // --- count lines
      nelements++;
    }
  }
  while (line != NULL);
#ifdef __DEBUG_AZURICOMMON__
  printf("azuricommon.countlines: File fname(=<%s>) contains %d data lines\n",fname,nelements);
#endif
  // --- close input file
  fclose(ffile);
#ifdef __DEBUG_AZURICOMMON__
  printf("azuricommon.countlines: File fname (=<%s>) closed\n", fname);
#endif
  return nelements;
}

double calcintens(const double x1, const double x2, const double xn, const double y1, const double y2)
{
  double intensn = 0.;
  intensn = y1;
  intensn += ((y2 - y1) * (xn - x1)/(x2 - x1));
  return intensn;
}

double absd(double val)
{
  if (val >= 0)
    return val;
  return (0. - val);
}

/**
function int charrcat{CHar Array CAT}(char inoutarr[255]: inout, char *strtoapp: in, int OLDLENGTHofinoutarr: in)
Appends strtoapp at inoutarr[oldlength] and a '\0' behind and returns position of '\0'.
 **
int charrcat(char inoutarr[255], const char *strtoapp, int oldlength)
{
#ifdef __DEBUG_AZURICOMMON__
  printf("azuricommon.charcat: function started: intoutarr = %s, strtoapp = %s, oldlength =%d\n", inoutarr, strtoapp, oldlength);
#endif
  int newlength, i;
  newlength = oldlength;
  if (oldlength + strlen(strtoapp) > 255)
  {
#ifdef __DEBUG_AZURICOMMON__
    printf("azuricommon.charcat: oldlength(=%d) + strlen(strtoapp=%s)(=%d) > 255 => returning 0\n", oldlength, strtoapp, strlen(strtoapp));
#endif
    return 0;
  }
  for (i = 0; i < strlen(strtoapp); i++)
  {
    inoutarr[i+oldlength] = strtoapp[i];
//#ifdef __DEBUG_AZURICOMMON__
//    printf("azuricommon.charrcat: inoutarr = %s\n",inoutarr);
//#endif

  }
  inoutarr[oldlength + strlen(strtoapp)] = '\0';
  newlength += strlen(strtoapp);
  return newlength;
}

/**
function int charposincharr{CHARacter POSition IN CHar ARR}(char inarr[255]: in, char lookfor: in, int start: in)
Returns first position of character 'in' in 'inarr', beginning at position 'start', if found, else '-1'
 **
int charposincharrfrom(char inarr[255], const char lookfor, int start)
{
  int pos = start;
  do
  {
    if (inarr[pos] == '\0')
      return -1;
    if (inarr[pos] == lookfor)
    {
#ifdef __DEBUG_AZURICOMMON__
      printf("azuricommon.charposincharrfrom: inarr[pos=%d] == lookfor(=%c) returned TRUE\n", pos, lookfor);
#endif
      break;
    }
    pos++;
  }
  while (pos < 255);
  if (pos == 255)
    pos = -1;
#ifdef __DEBUG_AZURICOMMON__
  printf("azuricommon.charposincharrfrom: returning pos = %d\n", pos);
#endif
  return pos;
}

/**
function int charposincharr{CHARacter POSition IN CHar ARR}(char inarr[255]: in, char lookfor: in, int start: in)
Returns first position of character 'in' in 'inarr', if found, else '-1'
 **
int charposincharr(char inarr[255], const char lookfor)
{
  return charposincharrfrom(inarr, lookfor, 0);
}

/**
function int lastcharposincharr{LAST CHARacter POSition IN CHar ARR}(char inarr[255]: in, char lookfor: in)
Returns last position of character 'in' in 'inarr', if found, else '-1'
 **
int lastcharposincharr(char inarr[255], const char lookfor)
{
  int pos = 0;
  int lastpos = -1;
#ifdef __DEBUG_AZURICOMMON__
  printf("azuricommon.lastcharposincharr: function started\n");
#endif
  do
  {
    pos = charposincharrfrom(inarr, lookfor, pos+1);
#ifdef __DEBUG_AZURICOMMON__
    printf("azuricommon.lastcharposincharr: charposincharrfrom(..) returned pos=%d\n", pos);
#endif
    if (pos >= 0)
      lastpos = pos;
  }
  while (pos >= 0);
#ifdef __DEBUG_AZURICOMMON__
  printf("azuricommon.lastcharposincharr: returning lastpos = %d\n", lastpos);
#endif
  return lastpos;
}

int read2dfiletoarrays(const char* filename, double* warr, double* varr)
{

  FILE *fname;
  char *linea;
  long i, nelements;
  char oneword[200];
  
  // --- countlines
  nelements = countlines(filename);
#ifdef __DEBUG_AZURICOMMON__
  printf("azuricommon.read2dfiletoarrays: file %s contains %d data lines\n",filename,nelements);
#endif

  // --- open file <fname> with name <filename> for reading
  fname = fopen(filename, "r");
  if (fname == NULL)
  {
    printf("Failed to open file filename (=<%s>)\n", filename);
    return 0;
  }

  varr = (double*)malloc(sizeof(double) * nelements);
  if (varr == NULL)
  {
    printf("azuricommon.read2dfiletoarrays: NOT ENOUGH MEMORY FOR varr\n");
    return 0;
  }
  warr = (double*)malloc(sizeof(double) * nelements);
  if (warr == NULL)
  {
    printf("azuricommon.read2dfiletoarrays: NOT ENOUGH MEMORY FOR warr\n");
    return 0;
  }

  // --- read file <fname> named <filename> in <warray> and <varray>
  i = 0;
  do
  {
    linea = fgets(oneword, 200, fname);
    if (linea != NULL)
    {
#ifdef __DEBUG_AZURICOMMON__
      printf("azuricommon.read2dfiletoarrays: linea =<%s>\n", linea);
#endif
      warr[i] = atof(strtok(linea," "));
      varr[i] = atof(strtok(NULL," "));
#ifdef __DEBUG_AZURICOMMON__
      printf("azuricommon.read2dfiletoarrays: warr[%d]=%.7f, varr[%d]=%.7f\n", i, warr[i], i, varr[i]);
#endif
    }
    i++;
  }
  while (linea != NULL);
  // --- close input file
  fclose(fname);
#ifdef __DEBUG_AZURICOMMON__
  printf("azuricommon.read2dfiletoarrays: File filename (=<%s>) closed\n", filename);
#endif


  return 1;
}
*/
