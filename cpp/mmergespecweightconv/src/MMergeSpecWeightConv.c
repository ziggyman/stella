/*
author:        Andreas Ritter
created:       01/08/2007
last edited:   01/08/2007
compiler:      gcc 4.0
basis machine: Ubuntu Linux 6.06 LTS
*

#include "MMergeSpecWeightConv.h"

int main(int argc, char *argv[])
{
  char *tmpdatfilestr = "/home/azuri/spectra/ses/science20060704-0207_botzfxs_ec_bld_rb_text.list";
  char *tmperrfilestr = "/home/azuri/spectra/ses/science20060704-0207_botzfxs_ec_bld_rb_snr_text.list";
  char *tempstra;
  char ***filelist;
  char indatalist[250], inerrlist[250], tempchararr[255];
  char tempdirarr[255], dirarr[255], dataoutfilename[255], erroutfilename[255], filenamesuffix[255];
  char *line;
  char *tempstr;
  char  *slash = "/";
  char  *tempdir = "";
  char oneword[200];
  long i, j, length, dirlength, nextpos, startpos, dataoutfilelength, erroutfilelength;
  long overlapstartpos;
  long *nelements;
  int norders, pointpos, overlaplength,centerpos;
  FILE  *indatalistfile;
  FILE  *inerrlistfile;
  FILE  *fdataoutfile;
  FILE  *ferroutfile;
  double **wdataarr, **werrarr, **vdataarr, **verrarr, *newwarr, *newvdataarr;//, *convarr;
  double tempwave, dlambda, overlapcenter, convolution;// errij, erri1nextpos, dlambda;

  // --- check if input-file name is given
  if (argc<3)
  {
    printf("mergespecweightconv.main: NOT ENOUGH PARAMETERS SPECIFIED!\n");
    printf("mergespecweightconv.main: USAGE:\n");
    printf("mergespecweightconv.main: mergespecweightconv (char*)datafiles.list (char*)snrfiles.list\n");
    printf("\n datafiles.list:\n");
    printf("    science20060704-0207_botzfxs_ec_bld_001_rb.text\n");
    printf("    science20060704-0207_botzfxs_ec_bld_002_rb.text\n");
    printf("    ...\n");
    printf("\n snrfiles.list:\n");
    printf("    science20060704-0207_botzfxs_ec_bld_001_rb_snr.text\n");
    printf("    science20060704-0207_botzfxs_ec_bld_002_rb_snr.text\n");
    printf("    ...\n");
    printf(" PRE: *_rb.text are outfiles of fitsrebin\n");
    exit(0);
    /*   argv[1] = (char*)malloc(sizeof(char)*(strlen(tmpdatfilestr)+1));
    if (argv[1] == NULL)
    {
    printf("fits-rebin.main: NOT ENOUGH MEMORY FOR argv[1]\n");
    exit (EXIT_FAILURE);
  }
    strcpy(argv[1],tmpdatfilestr);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: argv[1] = %s\n",argv[1]);
#endif
    argv[2] = (char*)malloc(sizeof(char)*(strlen(tmperrfilestr)+1));
    if (argv[2] == NULL)
    {
    printf("fits-rebin.main: NOT ENOUGH MEMORY FOR argv[1]\n");
    exit (EXIT_FAILURE);
  }
    strcpy(argv[2],tmperrfilestr);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: argv[2] = %s\n",argv[2]);
#endif
    argc = 3;*/
/*  }
  indatalist[0] = '\0';
  inerrlist[0] = '\0';
  charrcat(indatalist, argv[1], 0);
  charrcat(inerrlist, argv[2], 0);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("fits-rebin.main: argc = %d\n",argc);
#endif

  norders = countlines(indatalist);
  if (norders != countlines(inerrlist))
  {
    printf("fits-rebin.main: INFILES DON'T HAVE SAME NUMBER OF ORDERS\n");
    exit (EXIT_FAILURE);
  }
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("fits-rebin.main: norders = %d\n",norders);
#endif

  nelements = (long*)malloc(sizeof(long) * norders);
  if (nelements == NULL)
  {
    printf("fits-rebin.main: NOT ENOUGH MEMORY FOR nelements\n");
    exit (EXIT_FAILURE);
  }

/*  convarr = (long*)malloc(sizeof(double) * norders);
  if (convarr == NULL)
  {
  printf("fits-rebin.main: NOT ENOUGH MEMORY FOR convarr\n");
  exit (EXIT_FAILURE);
}*/
/*
  filelist = (char***)malloc(sizeof(char**) * 2);
  if (filelist == NULL)
  {
    printf("fits-rebin.main: NOT ENOUGH MEMORY FOR filelist\n");
    exit (EXIT_FAILURE);
  }
  for (i=0; i<2; i++)
  {
    filelist[i] = (char**)malloc(sizeof(char*) * norders);
    if (filelist[i] == NULL)
    {
      printf("fits-rebin.main: NOT ENOUGH MEMORY FOR filelist\n");
      exit (EXIT_FAILURE);
    }
  }
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("fits-rebin.main: memory for filelist allocated\n");
#endif

  strcpy(tempchararr, indatalist);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: tempchararr = %s\n",tempchararr);
#endif
  tempstra = strtok(tempchararr,"/");
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: tempstra = %s\n",tempstra);
#endif

  strcpy(tempdirarr,slash);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: tempdirarr = %s\n",tempdirarr);
#endif
  length = 1;
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: length = %d\n",length);
#endif
  length = charrcat(tempdirarr, tempstra, length);
  strcpy(dirarr,slash);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: dirarr = %s\n",dirarr);
#endif
  dirlength = 1;
  while(tempstra != NULL)
  {
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main\n");
#endif
    length = charrcat(tempdirarr,slash,length);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: tempdirarr = <%s>, length = %d\n",tempdir,length);
#endif
    strcpy(tempchararr,tempstra);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: tempchararr = <%s>\n",tempchararr);
#endif
    tempstra = strtok(NULL,"/");
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: tempstra = <%s>\n",tempstra);
#endif
    if (tempstra != NULL)
{
  length = charrcat(tempdirarr,tempstra,length);
  dirlength = charrcat(dirarr,tempchararr,dirlength);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
      printf("mergespecweightconv.main: dir = <%s>, dirlength = %d\n",dirarr,dirlength);
#endif
      dirlength = charrcat(dirarr,slash,dirlength);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
      printf("mergespecweightconv.main: dirarr = <%s>, dirlength = %d\n",dirarr,dirlength);
#endif

}
    //      else
    //  break;
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: tempdirarr = <%s>\n",tempdirarr);
    printf("mergespecweightconv.main: dirarr = <%s>\n",dirarr);
    printf("mergespecweightconv.main: tempstra = <%s>\n",tempstra);
#endif

  }
  //    dirarr[dirlength] = '\0';//strncat(dir,dirarr,dirlength);
  //    dirlength++;
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: dirarr = <%s>, dirlength = %d ready\n",dirarr,dirlength);
#endif

  // --- read input datafiles to filelist
  // --- open file <indatalistfile> with name <indatalist> for reading
  indatalistfile = fopen(indatalist, "r");
  inerrlistfile = fopen(inerrlist, "r");
  if (indatalistfile == NULL)
{
  printf("mergespecweightconv.main: Failed to open file indatalist =(<%s>)\n", indatalist);
  exit (EXIT_FAILURE);
}
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: File indatalist =(<%s>) opened\n", indatalist);
#endif
  if (inerrlistfile == NULL)
{
  printf("mergespecweightconv.main: Failed to open file inerrlist =(<%s>)\n", inerrlist);
  exit (EXIT_FAILURE);
}
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: File inerrlist =(<%s>) opened\n", inerrlist);
#endif
  // --- read file <indatalistfile> named <indatalist> in <filelist[0]>
  for (i=0; i<norders; i++)
{
  filelist[0][i] = (char*)malloc(sizeof(char) * 255);
  if (filelist[0][i] == NULL)
  {
    printf("fits-rebin.main: NOT ENOUGH MEMORY FOR filelist\n");
    exit (EXIT_FAILURE);
  }
  filelist[1][i] = (char*)malloc(sizeof(char) * 255);
  if (filelist[1][i] == NULL)
  {
    printf("fits-rebin.main: NOT ENOUGH MEMORY FOR filelist\n");
    exit (EXIT_FAILURE);
  }
  filelist[0][i][0] = '\0';
  filelist[1][i][0] = '\0';
  dirlength = charrcat(filelist[0][i], dirarr, 0);
  charrcat(filelist[1][i], dirarr, 0);
    // --- read line of indatalist
  line = fgets(oneword, 200, indatalistfile);
  if (line == NULL)
  {
    printf("mergespecweightconv.main: Failed to read line %d of file indatalist =(<%s>)\n", i, indatalist);
    exit (EXIT_FAILURE);
  }
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: oneword No i=%d of file indatalist(=%s) = <%s>\n", i, indatalist, oneword);
#endif

    tempstr = strtok(line," \t\n");
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: tempstr = <%s>\n", tempstr);
#endif
    charrcat(filelist[0][i], tempstr, dirlength);

#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: filelist[0][%d] = <%s>\n", i, filelist[0][i]);
#endif
    // --- read line of inerrlist
    line = fgets(oneword, 200, inerrlistfile);
    if (line == NULL)
    {
      printf("mergespecweightconv.main: Failed to read line %d of file inerrlist =(<%s>)\n", i, inerrlist);
      exit (EXIT_FAILURE);
    }
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: oneword No i=%d of file inerrlist(=%s) = <%s>\n", i, inerrlist, oneword);
#endif

    tempstr = strtok(line," \t\n");
    charrcat(filelist[1][i], tempstr, dirlength);

#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: filelist[1][%d] = <%s>\n", i, filelist[1][i]);
#endif

}
  fclose(indatalistfile);
  fclose(inerrlistfile);

  // allocate memory for data arrays
  wdataarr = (double**)malloc(sizeof(double*) * norders);
  if (wdataarr == NULL)
{
  printf("fits-rebin.main: NOT ENOUGH MEMORY FOR wdataarr\n");
  exit (EXIT_FAILURE);
}
  werrarr = (double**)malloc(sizeof(double*) * norders);
  if (werrarr == NULL)
{
  printf("fits-rebin.main: NOT ENOUGH MEMORY FOR werrarr\n");
  exit (EXIT_FAILURE);
}
  vdataarr = (double**)malloc(sizeof(double*) * norders);
  if (vdataarr == NULL)
{
  printf("fits-rebin.main: NOT ENOUGH MEMORY FOR vdataarr\n");
  exit (EXIT_FAILURE);
}
  verrarr = (double**)malloc(sizeof(double*) * norders);
  if (verrarr == NULL)
{
  printf("fits-rebin.main: NOT ENOUGH MEMORY FOR verrarr\n");
  exit (EXIT_FAILURE);
}
  for (i = 0; i < norders; i++)
{
  nelements[i] = countlines(filelist[0][i]);
  if (nelements[i] != countlines(filelist[1][i]))
  {
    printf("fits-rebin.main: %s and %s don't have same number of elements! EXITING\n", filelist[0][i], filelist[1][i]);
    exit (EXIT_FAILURE);
  }
  wdataarr[i] = (double*)malloc(sizeof(double) * nelements[i]);
  if (wdataarr[i] == NULL)
  {
    printf("fits-rebin.main: NOT ENOUGH MEMORY FOR wdataarr[%d]\n", i);
    exit (EXIT_FAILURE);
  }
  werrarr[i] = (double*)malloc(sizeof(double) * nelements[i]);
  if (werrarr[i] == NULL)
  {
    printf("fits-rebin.main: NOT ENOUGH MEMORY FOR werrarr[%d]\n", i);
    exit (EXIT_FAILURE);
  }
  vdataarr[i] = (double*)malloc(sizeof(double) * nelements[i]);
  if (vdataarr[i] == NULL)
  {
    printf("fits-rebin.main: NOT ENOUGH MEMORY FOR vdataarr[%d]\n", i);
    exit (EXIT_FAILURE);
  }
  verrarr[i] = (double*)malloc(sizeof(double) * nelements[i]);
  if (verrarr[i] == NULL)
  {
    printf("fits-rebin.main: NOT ENOUGH MEMORY FOR verrarr[%d]\n", i);
    exit (EXIT_FAILURE);
  }
}

#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: Memory for data arrays allocated\n");
#endif

  // read data files to data arrays
  for (i = 0; i < norders; i++)
{
    //#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    //    printf("mergespecweightconv.main: i = %d\n", i);
    //#endif
  indatalistfile = fopen(filelist[0][i], "r");
  inerrlistfile = fopen(filelist[1][i], "r");
  if (indatalistfile == NULL)
  {
    printf("mergespecweightconv.main: Failed to open file filelist[0][%d] =(<%s>)\n", i, indatalist);
    exit (EXIT_FAILURE);
  }
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: File filelist[0][%d] =(<%s>) opened\n", i, filelist[0][i]);
#endif
    if (inerrlistfile == NULL)
{
  printf("mergespecweightconv.main: Failed to open file filelist[1][%d] =(<%s>)\n", i, filelist[1][i]);
  exit (EXIT_FAILURE);
}
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: File filelist[1][%d] =(<%s>) opened\n", i, filelist[1][i]);
#endif

    for (j = 0; j < nelements[i]; j++)
{
      //#ifdef __DEBUG_MERGESPECWEIGHTCONV__
      //      printf("mergespecweightconv.main: j = %d\n", j);
      //#endif
      // --- read line of indatalist
  line = fgets(oneword, 200, indatalistfile);
  if (line == NULL)
  {
    printf("mergespecweightconv.main: Failed to read line %d of file filelist[0][%d] =(<%s>)\n", j, i, filelist[0][i]);
    exit (EXIT_FAILURE);
  }
      //#ifdef __DEBUG_MERGESPECWEIGHTCONV__
      //      printf("mergespecweightconv.main: oneword No i=%d of file filelist[0][%d](=%s) = <%s>\n", j, i, filelist[0][i], oneword);
      //#endif
  wdataarr[i][j] = atof(strtok(line," "));
  vdataarr[i][j] = atof(strtok(NULL," "));

      // --- read line of inerrlist
  line = fgets(oneword, 200, inerrlistfile);
  if (line == NULL)
  {
    printf("mergespecweightconv.main: Failed to read line %d of file inerrlist =(<%s>)\n", i, inerrlist);
    exit (EXIT_FAILURE);
  }
      //#ifdef __DEBUG_MERGESPECWEIGHTCONV__
      //      printf("mergespecweightconv.main: oneword No i=%d of file inerrlist(=%s) = <%s>\n", i, inerrlist, oneword);
      //#endif

  werrarr[i][j] = atof(strtok(line," "));
  verrarr[i][j] = atof(strtok(NULL," "));
}
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: wdataarr[%d][%d] = %.7f\n", i, nelements[i]-1, wdataarr[i][nelements[i]-1]);
    printf("mergespecweightconv.main: vdataarr[%d][%d] = %.7f\n", i, nelements[i]-1, vdataarr[i][nelements[i]-1]);
    printf("mergespecweightconv.main: werrarr[%d][%d] = %.7f\n", i, nelements[i]-1, werrarr[i][nelements[i]-1]);
    printf("mergespecweightconv.main: verrarr[%d][%d] = %.7f\n", i, nelements[i]-1, verrarr[i][nelements[i]-1]);
#endif
    fclose(indatalistfile);
    fclose(inerrlistfile);
}

  // --- merge orders to single file
  // --- allocate memory for new arrays
  newwarr = (double*)malloc(sizeof(double));
  newvdataarr = (double*)malloc(sizeof(double));
  //newverrarr = (double*)malloc(sizeof(double));
  length = 0;
  // --- set first elements for new arrays
  tempwave = wdataarr[0][0];
  newwarr[0] = tempwave;
  //newverrarr[0] = verrarr[0][0];

  // --- reset starting position in overlapping region for next order
  startpos = 0;
  overlapstartpos = 0;

  // --- for every order
  for (i = 0; i < norders; i++)
{
    // --- reset position in overlapping region for next order
  nextpos = 0;
  overlaplength = 0;
  for (j = startpos; j < nelements[i]; j++)
  {
    length++;
      // --- reallocate memory for new arrays
    newwarr = (double*)realloc(newwarr, sizeof(double) * length);
    newvdataarr = (double*)realloc(newvdataarr, sizeof(double) * length);
      //newverrarr = (double*)realloc(newverrarr, sizeof(double) * length);
      // --- jump to position next to overlapping region
      //      do
      //      {
      //        tempwave = wdataarr[i][j];
      //        j++;
      //      }
      //      while ((tempwave < newwarr[length - 1]) && (j < nelements[i]));
      //      newwarr[length - 1] = tempwave;
    newwarr[length - 1] = wdataarr[i][j];

      //#ifdef __DEBUG_MERGESPECWEIGHTCONV__
      //      printf("mergespecweightconv.main: newwarr[%d] = %.7f\n", length -1, newwarr[length - 1]);
      //#endif

      // --- until 2nd last order
    if (i < norders - 1)
    {
        // --- inside overlapping region?
      if (wdataarr[i+1][nextpos] == newwarr[length - 1])
      {
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
          printf("mergespecweightconv.main: wdataarr[i=%d][j=%d] = %.7f, wdataarr[i+1=%d][nextpos=%d] = %.7f, newwarr[length-1=%d] = %.7f\n", i, j, wdataarr[i][j], i+1, nextpos, wdataarr[i+1][nextpos], length-1, newwarr[length - 1]);
          printf("mergespecweightconv.main: vdataarr[i=%d][j=%d] = %.7f, verrarr[i=%d][j=%d] = %.7f\n", i, j, vdataarr[i][j], i, j, verrarr[i][j]);
          printf("mergespecweightconv.main: vdataarr[i+1=%d][nextpos=%d] = %.7f, verrarr[i+1=%d][nextpos=%d] = %.7f\n", i+1, nextpos, vdataarr[i+1][nextpos], i+1, nextpos, verrarr[i+1][nextpos]);
#endif

          if (overlaplength == 0)
{
  overlapstartpos = j;
  overlaplength = nelements[i] - j;
  centerpos = j + (overlaplength / 2);
  overlapcenter = wdataarr[i][centerpos];
}

          // --- calculate convolution function
          if (newwarr[length - 1] < overlapcenter)
            convolution = (4. / pow(overlaplength,2)) * (j - overlapstartpos);
          else
            convolution = 1. - pow((j - overlapstartpos - overlaplength),2);
              
          // --- calculate new flux value by adding the snr-weighted flux values from both orders involved in overlapping region
          newvdataarr[length - 1] = vdataarr[i][j] * verrarr[i][j] * convolution;
          newvdataarr[length - 1] += vdataarr[i+1][nextpos] * verrarr[i+1][nextpos] * (1. - convolution);
          newvdataarr[length - 1] = newvdataarr[length - 1] / ((verrarr[i][j] * convolution) + (verrarr[i+1][nextpos] * (1. - convolution)));

          // --- calculate new error value using standard error-propagation laws
          // --- part of the first value
          /*errij = pow(vdataarr[i][j], 2) * verrarr[i+1][nextpos];
          errij += 2. * vdataarr[i][j] * vdataarr[i+1][nextpos] * verrarr[i][j];
          errij -= pow(vdataarr[i+1][nextpos], 2) * verrarr[i][j];
          errij = errij * verrarr[i+1][nextpos];
          errij = errij / pow(((vdataarr[i][j] * verrarr[i+1][nextpos]) + (vdataarr[i+1][nextpos] * verrarr[i][j])), 2);
          errij = absd(errij);// / pow(((vdataarr[i][j] * verrarr[i+1][nextpos]) + (vdataarr[i+1][nextpos] * verrarr[i][j])), 2);
          errij = errij * verrarr[i][j];
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
          printf("mergespecweightconv.main: errij = %.7f\n", errij);
#endif

          // --- part of the second value
          erri1nextpos = pow(vdataarr[i+1][nextpos], 2) * verrarr[i][j];
          erri1nextpos += 2. * vdataarr[i][j] * vdataarr[i+1][nextpos] * verrarr[i+1][nextpos];
          erri1nextpos -= pow(vdataarr[i][j], 2) * verrarr[i+1][nextpos];
          erri1nextpos = erri1nextpos * verrarr[i][j];
          erri1nextpos = absd(erri1nextpos / pow(((vdataarr[i][j] * verrarr[i+1][nextpos]) + (vdataarr[i+1][nextpos] * verrarr[i][j])), 2));
          erri1nextpos = erri1nextpos * verrarr[i+1][nextpos];
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
          printf("mergespecweightconv.main: erri1nextpos6 = %.7f\n", erri1nextpos);
#endif
          // --- add both parts
          newverrarr[length - 1] = errij + erri1nextpos;
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
          printf("mergespecweightconv.main: newverrarr[%d] = %.7f\n", length - 1, newverrarr[length - 1]);
#endif
          */

          /*          // --- shorter way
          newverrarr[length - 1] = 2. * vdataarr[i][j] * vdataarr[i+1][nextpos] * verrarr[i][j] * verrarr[i+1][nextpos] * (verrarr[i][j] + verrarr[i+1][nextpos]) / pow(((vdataarr[i][j] * verrarr[i+1][nextpos]) + (vdataarr[i+1][nextpos] * verrarr[i][j])), 2);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
          printf("mergespecweightconv.main: shorter-way newverrarr[%d] = %.7f\n", length - 1, newverrarr[length - 1]);
#endif
          */
/*          // --- increase nextpos by 1
          nextpos++;
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
          printf("mergespecweightconv.main: nextpos = %d\n", nextpos);
#endif

      } // end if (wdataarr[i+1][nextpos] == newwarr[length - 1])
      else
{
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
          printf("mergespecweightconv.main: nextpos = %d\n", nextpos);
          if (nextpos > 0)
          {
            printf("mergespecweightconv.main: no overlapping\n");
            printf("mergespecweightconv.main: wdataarr[i=%d][j=%d] = %.7f, wdataarr[i+1=%d][nextpos=%d] = %.7f, newwarr[length-1=%d] = %.7f\n", i, j, wdataarr[i][j], i+1, nextpos, wdataarr[i+1][nextpos], length-1, newwarr[length - 1]);
            printf("mergespecweightconv.main: vdataarr[i=%d][j=%d] = %.7f, verrarr[i=%d][j=%d] = %.7f\n", i, j, vdataarr[i][j], i, j, verrarr[i][j]);
          }
#endif
          newvdataarr[length - 1] = vdataarr[i][j];
          //newverrarr[length - 1] = verrarr[i][j];

          // --- fill gaps with zeros
          if (j == nelements[i] - 1)
          {
            dlambda = newwarr[length - 1] - newwarr[length - 2];
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
            printf("mergespecweightconv.main: dlambda = %.7f\n", dlambda);
#endif
            while(newwarr[length - 1] + dlambda < wdataarr[i+1][0])
{
  length++;
              // --- reallocate memory for new arrays
  newwarr = (double*)realloc(newwarr, sizeof(double) * length);
  newvdataarr = (double*)realloc(newvdataarr, sizeof(double) * length);
              //             newverrarr = (double*)realloc(newverrarr, sizeof(double) * length);
              //              newwarr[length - 1] = newwarr[length - 2] + dlambda;
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
              printf("mergespecweightconv.main: gap-newwarr[%d] = %.7f\n", length - 1, newwarr[length - 1]);
              printf("mergespecweightconv.main: wdataarr[%d][0] = %.7f\n", i+1, wdataarr[i+1][0]);
#endif
              newvdataarr[length - 1] = 0.;
              //              newverrarr[length - 1] = 0.;
}
          }
}
    } // end if (i < norders - 1)
    else// last order
{
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
        printf("mergespecweightconv.main: nextpos = %d\n", nextpos);
        if (nextpos > 0)
        {
          printf("mergespecweightconv.main: last order\n");
          printf("mergespecweightconv.main: wdataarr[i=%d][j=%d] = %.7f, wdataarr[i+1=%d][nextpos=%d] = %.7f, newwarr[length-1=%d] = %.7f\n", i, j, wdataarr[i][j], i+1, nextpos, wdataarr[i+1][nextpos], length-1, newwarr[length - 1]);
          printf("mergespecweightconv.main: vdataarr[i=%d][j=%d] = %.7f, verrarr[i=%d][j=%d] = %.7f\n", i, j, vdataarr[i][j], i, j, verrarr[i][j]);
        }
#endif
        // --- last order
        newvdataarr[length - 1] = vdataarr[i][j];
        //newverrarr[length - 1] = verrarr[i][j];
}
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
      printf("mergespecweightconv.main: newwarr[%d] = %.7f, newvdataarr[%d] = %.7f\n", length - 1, newwarr[length - 1], length - 1, newvdataarr[length - 1]);
#endif

  }// end for (j = startpos; j < nelements[i]; j++)
  startpos = nextpos;
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
    printf("mergespecweightconv.main: startpos nextorder = %d\n", startpos);
#endif
}// end for (i = 0; i < norders; i++)

  // --- write results to outfiles
  // --- build output-file names
  pointpos = lastcharposincharr(indatalist, '.');
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: pointpos(=lastcharposincharr(indatalist=%s)) = %d\n", indatalist, pointpos);
#endif
  if (pointpos == -1)
{
  printf("mergespecweightconv.main: pointpos == 0 => exiting\n");
  exit (EXIT_FAILURE);
}
  dataoutfilename[0] = '\0';
  // --- set dataoutfilename to indatalist until position of last point
  for (i = 0; i < pointpos; i++)
{
  dataoutfilename[i] = indatalist[i];
}
  dataoutfilename[i+1] = '\0';
  dataoutfilelength = i;

  // --- error image
  pointpos = lastcharposincharr(inerrlist, '.');
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: pointpos(=lastcharposincharr(inerrlist=%s)) = %d\n", inerrlist, pointpos);
#endif
  if (pointpos == -1)
{
  printf("mergespecweightconv.main: pointpos == -1 => exiting\n");
  exit (EXIT_FAILURE);
}
  /*erroutfilename[0] = '\0';
  // --- set dataoutfilename to indatalist until position of last point
  for (i = 0; i < pointpos; i++)
{
    erroutfilename[i] = inerrlist[i];
}
  erroutfilename[i+1] = '\0';

  erroutfilelength = i;*/
  // --- set filename suffix for output files to _m
/*  filenamesuffix[0] = '_';
  filenamesuffix[1] = 'm';
  filenamesuffix[2] = '.';
  filenamesuffix[3] = 't';
  filenamesuffix[4] = 'e';
  filenamesuffix[5] = 'x';
  filenamesuffix[6] = 't';
  filenamesuffix[7] = '\0';
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: starting charrcat(dataoutfilename = %s, filenamesuffix = %s, dataoutfilelength = %d)\n", dataoutfilename, filenamesuffix, dataoutfilelength);
#endif
  dataoutfilelength = charrcat(dataoutfilename, filenamesuffix, dataoutfilelength);
  if (dataoutfilelength == 0)
{
  printf("mergespecweightconv.main: charrcat(dataoutfilename, '_rb', dataoutfilelength) returned 0 => exiting\n");
  exit (EXIT_FAILURE);
}

#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: dataoutfilelength = %d, pointpos = %d\n", dataoutfilelength, pointpos);
  printf("mergespecweightconv.main: strlen(indatalist(=%s)) returned %d\n", indatalist, strlen(indatalist));
#endif

#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: dataoutfilename = <%s>\n", dataoutfilename);
#endif
  /*// --- erroutfile
  /*
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: starting charrcat(erroutfilename = %s, filenamesuffix = %s, i = %d)\n", erroutfilename, filenamesuffix, i);
#endif
  erroutfilelength = charrcat(erroutfilename, filenamesuffix, erroutfilelength);
  if (erroutfilelength == 0)
{
    printf("mergespecweightconv.main: charrcat(erroutfilename, filenamesuffix, erroutfilelength) returned 0 => exiting\n");
    exit (EXIT_FAILURE);
}
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: erroutfilename = <%s>\n", erroutfilename);
#endif*/

  // --- open fdataoutfile
/*  fdataoutfile = fopen(dataoutfilename, "w");
  if (fdataoutfile == NULL)
{
  printf("mergespecweightconv.main: Failed to open file dataoutfilename (=<%s>)\n", dataoutfilename);
  exit (EXIT_FAILURE);
}
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: dataoutfilename = <%s> opened\n", dataoutfilename);
  printf("mergespecweightconv.main: length - 1 = <%d>\n", length - 1);
#endif
  /* --- open ferroutfile
  ferroutfile = fopen(erroutfilename, "w");
  if (ferroutfile == NULL)
{
    printf("mergespecweightconv.main: Failed to open file erroutfilename (=<%s>)\n", erroutfilename);
    exit (EXIT_FAILURE);
}
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: erroutfilename = <%s> opened\n", erroutfilename);
#endif*/
/*  for (i = 0; i < length - 1; i++)
{
  if (i < 3)
  {
    printf("mergespecweightconv.main: writing outfiles: i = %d: newwarr[%d] = %.7f, newvdataarr[%d] = %.7f\n", i, i, newwarr[i], i, newvdataarr[i]);
      //printf("mergespecweightconv.main: writing outfiles: i = %d: newwarr[%d] = %.7f, newverrarr[%d] = %.7f\n", i, i, newwarr[i], i, newverrarr[i]);
  }
  fprintf(fdataoutfile, "%.8f %.7f\n", newwarr[i], newvdataarr[i]);
    //fprintf(ferroutfile, "%.8f %.7f\n", newwarr[i], newverrarr[i]);
}
  fclose(fdataoutfile);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: dataoutfilename = <%s> closed\n", dataoutfilename);
#endif
  /*fclose(ferroutfile);
#ifdef __DEBUG_MERGESPECWEIGHTCONV__
  printf("mergespecweightconv.main: erroutfilename = <%s> closed\n", erroutfilename);
#endif*/
/*
  printf("Hello, world!\n");

  return EXIT_SUCCESS;
}*/
