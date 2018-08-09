procedure stmerge (ApsImFitsList, ApsErrFitsList, ApsWeightFitsList)

#################################################################
#                                                               #
# NAME:             stmerge                                     #
# PURPOSE:          * merges the individual spectral orders     #
#                     automatically                             #
#                                                               #
# CATEGORY:         Data reduction                              #
# CALLING SEQUENCE: stmerge(ApsImFitsList, ApsErrFitsList,      #
#                           ApsWeightFitsList)                  #
# INPUTS:           ApsImFitsList:                              #
#                     HD175640/HD175640_botzfxsEcBld_01t.fits   #
#                     HD175640/HD175640_botzfxsEcBld_02t.fits   #
#                     HD175640/HD175640_botzfxsEcBld_03t.fits   #
#                     ...                                       #
#                   ApsErrFitsList:                             #
#                     HD175640/HD175640_err_obtzxEcBld_01t.fits #
#                     HD175640/HD175640_err_obtzxEcBld_02t.fits #
#                     HD175640/HD175640_err_obtzxEcBld_03t.fits #
#                     ...                                       #
#                   ApsWeightFitsList:                          #
#                     refBlaze/refBlaze_nEc_fitnd_01t.fits      #
#                     refBlaze/refBlaze_nEc_fitnd_02t.fits      #
#                     refBlaze/refBlaze_nEc_fitnd_03t.fits      #
#                     ...                                       #
# OUTPUTS:          output: -                                   #
#                   outfile: "<old_imagename_root>M."<ImType>   #
#                                                               #
# IRAF VERSION:     2.11                                        #
#                                                               #
# COPYRIGHT:        Andreas Ritter                              #
# CONTACT:          aritter@aip.de                              #
#                                                               #
# CREATED    :      24.10.2006                                  #
# LAST EDITED:      02.04.2007                                  #
#                                                               #
#################################################################

string ApsImFitsList     = "file_fits.list"        {prompt="Fits file list of orders of image to merge"}
string ApsErrFitsList    = "errfile_fits.list"     {prompt="Fits file list of orders of error image for weighting"}
string ApsWeightFitsList = "refBlaze_combinedFlat_n_ec_fitnd_fits.list" {prompt="Name of weighting image"}
string ParameterFile     = "scripts$parameterfiles/parameterfile_SES_2148x2052.prop" {prompt="Name of ParameterFile"}
int    DispAxis          = 2                       {prompt="1-horizontal, 2-vertical"}
real   Oversampling      = 1.2                     {prompt="Oversampling factor for greatest dlambda"}
string ImType            = "fits"                  {prompt="Image Type"}
string LogFile           = "logfile_stmerge.log"   {prompt="Name of LogFile"}
string WarningFile       = "warnings_stmerge.log"  {prompt="Name of warning file"}
string ErrorFile         = "errors_stmerge.log"    {prompt="Name of error file"}
int    LogLevel          = 3                       {prompt="Level for writing LogFile [1-3]"}
string Output            = "out_t.fits"            {prompt="Name of output fits file"}
string ErrOutput         = "out_err_t.fits"        {prompt="Name of output fits error file"}
string *P_StrList
string *P_FileList

begin
  string ApsImTextList,ApsErrTextList,ApsImSNRFitsList,ApsImSNRFitFitsList,ApsImSNRFitTextList
  string ApsImRBTextList,ApsErrRBTextList,ApsImSNRFitRBTextList,ApsWeightTextList,ApsWeightRBTextList
  string FitsRebinList,FitsMergeList,FitsMergeErrTextList,FitsMergeErrFitsList,CalcSNRList
  string FitsMergeErrFitTextList,FitsMergeErrFitFitsList,FitsMergeErrFitRBTextList
  string CalcSNRErrList,HeaderFile,TempSNRList,HeaderInput, HeaderErrFile
  string Parameter,ParameterValue,DumImage,Title,WaveA,ValA
  string ErrTextFiles,ErrFitsFiles,TempFile,TempList,TempListName
  string TextFilesT,ErrTextFilesT,TempTextFilesT,TempTextList,TempTextListName
  string TextFiles,FileName,Input,ErrInput,TextFile
  string SNROutput,FitsFiles, TempHeaderFile, TmpHeaderFile
#, HeaderList, HeaderErrList, TempHeaderList
  string LogFile_rebintextfiles = "logfile_rebintextfiles.log"
  string LogFile_fitsmerge = "logfile_fitsmerge.log"
  string LogFile_countorders = "logfile_countorders.log"
  string LogFile_countpix = "logfile_countpix.log"
  string LogFile_writeaps = "logfile_writeaps.log"
  string WarningFile_writeaps = "warnings_writeaps.log"
  string ErrorFile_writeaps = "errors_writeaps.log"
  string LogFile_stcalcsnr = "logfile_stcalcsnr.log"
  string WarningFile_stcalcsnr = "warnings_stcalcsnr.log"
  string ErrorFile_stcalcsnr = "errors_stcalcsnr.log"
  string LogFile_staddheader = "logfile_staddheader.log"
  string WarningFile_staddheader = "warnings_staddheader.log"
  string ErrorFile_staddheader = "errors_staddheader.log"
  string LogFile_removedisplinesfromheader = "logfile_removedisplinesfromheader.log"
  string WarningFile_removedisplinesfromheader = "warnings_removedisplinesfromheader.log"
  string ErrorFile_removedisplinesfromheader = "errors_removedisplinesfromheader.log"
  string LogFile_sfit = "logfile_sfit.log"
  string LogFile_addheadertofitsfile = "logfile_addheadertofitsfile.log"
  int    i,j,k,Pos, Run, NMid
  real   CRValA,CDeltA
  bool   FoundImType              = NO
  bool   FoundDispAxis            = NO
  bool   FoundOversampling        = NO

# --- delete old LogFiles
  if (access(LogFile))
    del(LogFile, ver-)
  if (access(WarningFile))
    del(WarningFile, ver-)
  if (access(ErrorFile))
    del(ErrorFile, ver-)

  HeaderErrFile = "agwegwe"
  HeaderFile = "asgagnowegw"

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                      stmerge.cl                        *")
  print ("*       (merges the orders of the input fits files)      *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*                      stmerge.cl                        *", >> LogFile)
  print ("*       (merges the orders of the input fits files)      *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)
  print ("stmerge: ApsImFitsList = <"//ApsImFitsList//">")
  print ("stmerge: ApsErrFitsList = <"//ApsErrFitsList//">")
  print ("stmerge: ApsWeightFitsList = <"//ApsWeightFitsList//">")
  print ("stmerge: ApsImFitsList = <"//ApsImFitsList//">", >> LogFile)
  print ("stmerge: ApsErrFitsList = <"//ApsErrFitsList//">", >> LogFile)
  print ("stmerge: ApsWeightFitsList = <"//ApsWeightFitsList//">", >> LogFile)

  language
  onedspec

# --- read ParameterFile
  if (access(ParameterFile)){
    P_FileList = ParameterFile
    while(fscan(P_FileList,Parameter,ParameterValue) != EOF){
      if (Parameter == "imtype"){
        ImType = ParameterValue
        print("stmerge: Setting ImType to "//ImType)
        print("stmerge: Setting ImType to "//ImType, >> LogFile)
        FoundImType = YES
      }
      else if (Parameter == "dispaxis"){ 
        DispAxis = real(ParameterValue)
        print ("stmerge: Setting DispAxis to "//ParameterValue)
        print ("stmerge: Setting DispAxis to "//ParameterValue, >> logfile)
        FoundDispAxis = YES
      }
      else if (Parameter == "merge_rebin_oversampling"){ 
        Oversampling = real(ParameterValue)
        print ("stmerge: Setting Oversampling to "//ParameterValue)
        print ("stmerge: Setting Oversampling to "//ParameterValue, >> logfile)
        FoundOversampling = YES
      }
    }
    if (!FoundImType){
      print("stmerge: WARNING: Parameter 'imtype' not found in "//ParameterFile//"!!! -> using standard value (="//imtype//")")
      print("stmerge: WARNING: Parameter 'imtype' not found in "//ParameterFile//"!!! -> using standard value (="//imtype//")", >> LogFile)
      print("stmerge: WARNING: Parameter 'imtype' not found in "//ParameterFile//"!!! -> using standard value (="//imtype//")", >> WarningFile)
    }
#    if (!FoundFitNAverage){
#      print("stmerge: WARNING: Parameter 'blaze_fit_naverage' not found in "//ParameterFile//"!!! -> using standard value (="//NAverage//")")
#      print("stmerge: WARNING: Parameter 'blaze_fit_naverage' not found in "//ParameterFile//"!!! -> using standard value (="//NAverage//")", >> LogFile)
#      print("stmerge: WARNING: Parameter 'blaze_fit_naverage' not found in "//ParameterFile//"!!! -> using standard value (="//NAverage//")", >> WarningFile)
#    }
#    if (!FoundFitNIterate){
#      print("stmerge: WARNING: Parameter 'blaze_fit_niterate' not found in "//ParameterFile//"!!! -> using standard value (="//NIterate//")")
#      print("stmerge: WARNING: Parameter 'blaze_fit_niterate' not found in "//ParameterFile//"!!! -> using standard value (="//NIterate//")", >> LogFile)
#      print("stmerge: WARNING: Parameter 'blaze_fit_niterate' not found in "//ParameterFile//"!!! -> using standard value (="//NIterate//")", >> WarningFile)
#    }
#    if (!FoundFitLSigma){
#      print("stmerge: WARNING: Parameter 'blaze_fit_lsigma' not found in "//ParameterFile//"!!! -> using standard value (="//LSigma//")")
#      print("stmerge: WARNING: Parameter 'blaze_fit_lsigma' not found in "//ParameterFile//"!!! -> using standard value (="//LSigma//")", >> LogFile)
#      print("stmerge: WARNING: Parameter 'blaze_fit_lsigma' not found in "//ParameterFile//"!!! -> using standard value (="//LSigma//")", >> WarningFile)
#    }
#    if (!FoundFitUSigma){
#      print("stmerge: WARNING: Parameter 'blaze_fit_usigma' not found in "//ParameterFile//"!!! -> using standard value (="//USigma//")")
#      print("stmerge: WARNING: Parameter 'blaze_fit_usigma' not found in "//ParameterFile//"!!! -> using standard value (="//USigma//")", >> LogFile)
#      print("stmerge: WARNING: Parameter 'blaze_fit_usigma' not found in "//ParameterFile//"!!! -> using standard value (="//USigma//")", >> WarningFile)
#    }
#    if (!FoundOrder){
#      print("stmerge: WARNING: Parameter 'blaze_fit_order' not found in "//ParameterFile//"!!! -> using standard value (="//Order//")")
#      print("stmerge: WARNING: Parameter 'blaze_fit_order' not found in "//ParameterFile//"!!! -> using standard value (="//Order//")", >> LogFile)
#      print("stmerge: WARNING: Parameter 'blaze_fit_order' not found in "//ParameterFile//"!!! -> using standard value (="//Order//")", >> WarningFile)
#    }
#    if (!FoundFunction){
#      print("stmerge: WARNING: Parameter 'nflat_flat_function' not found in "//ParameterFile//"!!! -> using standard value (="//Function//")")
#      print("stmerge: WARNING: Parameter 'nflat_flat_function' not found in "//ParameterFile//"!!! -> using standard value (="//Function//")", >> LogFile)
#      print("stmerge: WARNING: Parameter 'nflat_flat_function' not found in "//ParameterFile//"!!! -> using standard value (="//Function//")", >> WarningFile)
#    }
#    if (!FoundMergeFitInteractive){
#      print("stmerge: WARNING: Parameter 'merge_fit_interactive' not found in "//ParameterFile//"!!! -> using standard value (="//Interactive//")")
#      print("stmerge: WARNING: Parameter 'merge_fit_interactive' not found in "//ParameterFile//"!!! -> using standard value (="//Interactive//")", >> LogFile)
#      print("stmerge: WARNING: Parameter 'merge_fit_interactive' not found in "//ParameterFile//"!!! -> using standard value (="//Interactive//")", >> WarningFile)
#    }
    if (!FoundDispAxis){
      print("stmerge: WARNING: Parameter 'dispaxis' not found in "//ParameterFile//"!!! -> using standard value (="//DispAxis//")")
      print("stmerge: WARNING: Parameter 'dispaxis' not found in "//ParameterFile//"!!! -> using standard value (="//DispAxis//")", >> LogFile)
      print("stmerge: WARNING: Parameter 'dispaxis' not found in "//ParameterFile//"!!! -> using standard value (="//DispAxis//")", >> WarningFile)
    }
    if (!FoundOversampling){
      print("stmerge: WARNING: Parameter 'merge_rebin_oversampling' not found in "//ParameterFile//"!!! -> using standard value (="//Oversampling//")")
      print("stmerge: WARNING: Parameter 'merge_rebin_oversampling' not found in "//ParameterFile//"!!! -> using standard value (="//Oversampling//")", >> LogFile)
      print("stmerge: WARNING: Parameter 'merge_rebin_oversampling' not found in "//ParameterFile//"!!! -> using standard value (="//Oversampling//")", >> WarningFile)
    }
    print("stmerge: ParameterFile <"//ParameterFile//"> read")
    if (LogLevel > 2)
      print("stmerge: ParameterFile <"//ParameterFile//"> read", >> LogFile)
  }

# --- load package "onedspec"
  onedspec

## --- build temp files
#  HeaderList = mktemp("tmp")
#  HeaderErrList = mktemp("tmp")

# --- Create text files from ApsImFitsList
  for (i = 1; i < 4; i = i+1){
    if (i == 1){
      TempListName = "ApsImFitsList"
      TempList = ApsImFitsList
      TempTextListName = "ApsImTextList"
#      TempTextList = ApsImTextList
#      TempHeaderList = HeaderList
    }
    else if (i == 2){
      TempListName = "ApsErrFitsList"
      TempList = ApsErrFitsList
      TempTextListName = "ApsErrTextList"
#      TempTextList = ApsErrTextList
#      TempHeaderList = HeaderErrList
    }
    if (i == 3){
      TempListName = "ApsWeightFitsList"
      TempList = ApsWeightFitsList
      TempTextListName = "ApsWeightTextList"
#      TempTextList = ApsWeightTextList
    }
# --- test if TempList is accessable
    if (!access(TempList)){
      print("stmerge: ERROR: cannot access "//TempListName//" <"//TempList//">! => Returning")
      print("stmerge: ERROR: cannot access "//TempListName//" <"//TempList//">! => Returning", >> LogFile)
      print("stmerge: ERROR: cannot access "//TempListName//" <"//TempList//">! => Returning", >> WarningFile)
      print("stmerge: ERROR: cannot access "//TempListName//" <"//TempList//">! => Returning", >> ErrorFile)
# --- clean up
#      del(HeaderList, ver-)
#      del(HeaderErrList, ver-)
      P_StrList = ""
      P_FileList = ""
      return
    }
    print("stmerge: "//TempListName//" <"//TempList//"> found")
    if (LogLevel > 2)
      print("stmerge: "//TempListName//" <"//TempList//"> found", >> LogFile)
    strlastpos(TempList, "_"//ImType)
    Pos = strlastpos.pos
    if (Pos < 1){
      strlastpos(TempList, ".")
      Pos = strlastpos.pos
    }
    if (Pos < 1)
      Pos = strlen(TempList) + 1
    TempTextList = substr(TempList, 1, Pos - 1)//"_text.list"
    if (access(TempTextList))
      del(TempTextList, ver-)
    print("stmerge: "//TempTextListName//" = <"//TempTextList//">")
    if (LogLevel > 2)
      print("stmerge: "//TempTextListName//" = <"//TempTextList//">", >> LogFile)
    print("stmerge: Reading "//TempListName//" = <"//TempList//">")
    if (LogLevel > 2)
      print("stmerge: Reading "//TempListName//" = <"//TempList//">", >> LogFile)
    Run = 0
    P_StrList = TempList
    while(fscan(P_StrList, TempFile) != EOF){
      Run = Run + 1
      if (!access(TempFile)){
        print("stmerge: ERROR: TempFile <"//TempFile//"> not found! => Returning!")
        print("stmerge: ERROR: TempFile <"//TempFile//"> not found! => Returning!", >> LogFile)
        print("stmerge: ERROR: TempFile <"//TempFile//"> not found! => Returning!", >> WarningFile)
        print("stmerge: ERROR: TempFile <"//TempFile//"> not found! => Returning!", >> ErrorFile)
# --- clean up
#        del(HeaderList, ver-)
#        del(HeaderErrList, ver-)
        P_StrList = ""
        P_FileList = ""
        return
      }
      strlastpos(TempFile, "."//ImType)
      if (access(strlastpos.logfile))
        cat(strlastpos.logfile, >> LogFile)
      Pos = strlastpos.pos
      print("stmerge: strlastpos(TempFile="//TempFile//", '."//ImType//"' returned "//Pos)
      if (LogLevel > 2)
        print("stmerge: strlastpos(TempFile="//TempFile//", '."//ImType//"' returned "//Pos, >> LogFile)
      if (Pos == 0)
        Pos = strlen(TempFile) + 1
      if (i < 3){
        if (Run == 1){
# --- write image header to HeaderFile
          if (i == 1){
            HeaderFile = substr(TempFile, 1, Pos-1)//"_head.text"
            TempHeaderFile = HeaderFile
          }
          else{
            HeaderErrFile = substr(TempFile, 1, Pos-1)//"_head.text"
            TempHeaderFile = HeaderErrFile
          }
#          print(HeaderFile, >> TempHeaderList)
          if (access(TempHeaderFile))
            del(TempHeaderFile, ver-)
          imheader(TempFile,
                   imlist = "*."//ImType,
                   longheader+,
                   userfields+, >> TempHeaderFile)
          if (!access(TempHeaderFile)){
            print("stmerge: ERROR: Cannot access TempHeaderFile <"//TempHeaderFile//"> => Returning!")
            print("stmerge: ERROR: Cannot access TempHeaderFile <"//TempHeaderFile//"> => Returning!", >> LogFile)
            print("stmerge: ERROR: Cannot access TempHeaderFile <"//TempHeaderFile//"> => Returning!", >> WarningFile)
            print("stmerge: ERROR: Cannot access TempHeaderFile <"//TempHeaderFile//"> => Returning!", >> ErrorFile)
# --- clean up
#            del(HeaderList, ver-)
#            del(HeaderErrList, ver-)
            P_StrList = ""
            P_FileList = ""
            return
          }
          if (access(LogFile_removedisplinesfromheader))
            del(LogFile_removedisplinesfromheader, ver-)
          removedisplinesfromheader(TempHeaderFile, >> LogFile_removedisplinesfromheader)#,
          if (access(LogFile_removedisplinesfromheader))
            cat(LogFile_removedisplinesfromheader, >> LogFile)
          TmpHeaderFile = TempHeaderFile//".new"
          if (!access(TmpHeaderFile)){
            print("stmerge: ERROR: Cannot access TmpHeaderFile <"//TmpHeaderFile//"> => Returning!")
            print("stmerge: ERROR: Cannot access TmpHeaderFile <"//TmpHeaderFile//"> => Returning!", >> LogFile)
            print("stmerge: ERROR: Cannot access TmpHeaderFile <"//TmpHeaderFile//"> => Returning!", >> WarningFile)
            print("stmerge: ERROR: Cannot access TmpHeaderFile <"//TmpHeaderFile//"> => Returning!", >> ErrorFile)
# --- clean up
#            del(HeaderList, ver-)
#            del(HeaderErrList, ver-)
            P_StrList = ""
            P_FileList = ""
            return
          }
          del(TempHeaderFile, ver-)
          copy(input  = TmpHeaderFile,
               output = TempHeaderFile,
               ver-)
          del(TmpHeaderFile, ver-)

        }# enf if (Run == 1)
      }# end if (i < 3)

# --- create text files from spectra
      TextFile = substr(TempFile, 1, Pos-1)//".text"
      if (access(TextFile))
        del(TextFile, ver-)
      wspectext(input = TempFile,
                output = TextFile,
                header-,
                wformat = "")
      if (!access(TextFile)){
        print("stmerge: ERROR: TextFile <"//TextFile//"> not found! => Returning!")
        print("stmerge: ERROR: TextFile <"//TextFile//"> not found! => Returning!", >> LogFile)
        print("stmerge: ERROR: TextFile <"//TextFile//"> not found! => Returning!", >> WarninigFile)
        print("stmerge: ERROR: TextFile <"//TextFile//"> not found! => Returning!", >> ErrorFile)
# --- clean up
#        del(HeaderList, ver-)
#        del(HeaderErrList, ver-)
        P_StrList = ""
        P_FileList = ""
        return
      }
      print("stmerge: Appending TextFile <"//TextFile//"> to "//TempTextListName//" <"//TempTextList//">")
      if (LogLevel > 2)
        print("stmerge: Appending TextFile <"//TextFile//"> to "//TempTextListName//" <"//TempTextList//">", >> LogFile)
      print(TextFile, >> TempTextList)
    }# end while(fscan(P_StrList, TempFile) != EOF){
    if (i == 1){
      ApsImTextList = TempTextList
    }
    else if (i == 2){
      ApsErrTextList = TempTextList
    }
    else{
      ApsWeightTextList = TempTextList
    }
  }
  

# --- write sigma spectra as text files
#  print("stmerge: starting writeaps(@ApsErrFitsList = <"//ApsErrFitsList//">)")
#  print("stmerge: starting writeaps(@ApsErrFitsList = <"//ApsErrFitsList//">)", >> LogFile)
#    print("stmerge: Appending TextFile <"//TextFile//"> to ApsImTextList <"//ApsImTextList//">")
#  writeaps(Input       = "@"//ApsErrFitsList,
#           DispAxis    = DispAxis,
#           Delimiter   = "_",
#           ImType      = ImType,
#           WSpecText+,
#           WriteHeads+,
#           WriteLists+,
#           CreateDirs-,
#           LogLevel    = LogLevel,
#           LogFile     = LogFile_writeaps,
#           WarningFile = WarningFile_writeaps,
#           ErrorFile   = ErrorFile_writeaps)
#  if (access(LogFile_writeaps))
#    cat(LogFile_writeaps, >> LogFile)
#  if (access(WarningFile_writeaps))
#    cat(WarningFile_writeaps, >> WarningFile)
#  if (access(ErrorFile_writeaps)){
#    print("stmerge: ERROR: writeaps returned error => Returning!")
#    print("stmerge: ERROR: writeaps returned error => Returning!", >> LogFile)
#    print("stmerge: ERROR: writeaps returned error => Returning!", >> WarningFile)
#    print("stmerge: ERROR: writeaps returned error => Returning!", >> ErrorFile)
## --- clean up
#    P_StrList = ""
#    P_FileList = ""
#    return
#  }
#  ApsErrTextList = writeaps.TextOutList
#  P_StrList = ApsErrTextList
#  if (fscan(P_StrList, TempFile) == EOF){
#    print("stmerge: ERROR: fscan(ApsErrTextList=<"//ApsErrTextList//">) returned EOF => Returning!")
#    print("stmerge: ERROR: fscan(ApsErrTextList=<"//ApsErrTextList//">) returned EOF => Returning!", >> LogFile)
#    print("stmerge: ERROR: fscan(ApsErrTextList=<"//ApsErrTextList//">) returned EOF => Returning!", >> WarningFile)
#    print("stmerge: ERROR: fscan(ApsErrTextList=<"//ApsErrTextList//">) returned EOF => Returning!", >> ErrorFile)
## --- clean up
#    P_StrList = ""
#    P_FileList = ""
#    return
#  }
#  ApsErrTextList = TempFile
#  print("stmerge: ApsErrTextList = <"//ApsErrTextList//">")
#  print("stmerge: ApsErrTextList = <"//ApsErrTextList//">", >> LogFile)

# --- write weighting spectra as text files
#  print("stmerge: starting writeaps(@ApsWeightFitsList = <"//ApsWeightFitsList//">)")
#  print("stmerge: starting writeaps(@ApsWeightFitsList = <"//ApsWeightFitsList//">)", >> LogFile)
#  writeaps(Input       = "@"//ApsWeightFitsList,
#           DispAxis    = DispAxis,
#           Delimiter   = "_",
#           ImType      = ImType,
#           WSpecText+,
#           WriteHeads+,
#           WriteLists+,
#           CreateDirs-,
#           LogLevel    = LogLevel,
#           LogFile     = LogFile_writeaps,
#           WarningFile = WarningFile_writeaps,
#           ErrorFile   = ErrorFile_writeaps)
#  if (access(LogFile_writeaps))
#    cat(LogFile_writeaps, >> LogFile)
#  if (access(WarningFile_writeaps))
#    cat(WarningFile_writeaps, >> WarningFile)
#  if (access(ErrorFile_writeaps)){
#    print("stmerge: ERROR: writeaps returned error => Returning!")
#    print("stmerge: ERROR: writeaps returned error => Returning!", >> LogFile)
#    print("stmerge: ERROR: writeaps returned error => Returning!", >> WarningFile)
#    print("stmerge: ERROR: writeaps returned error => Returning!", >> ErrorFile)
## --- clean up
#    P_StrList = ""
#    P_FileList = ""
#    return
#  }
#  ApsWeightTextList = writeaps.TextOutList
#  print("stmerge: ApsWeightTextList set to <"//ApsWeightTextList//">")
#  if (LogLevel > 2)
#    print("stmerge: ApsWeightTextList set to <"//ApsWeightTextList//">", >> LogFile)
#  P_StrList = ApsWeightTextList
#  if (fscan(P_StrList, TempFile) == EOF){
#    print("stmerge: ERROR: fscan(ApsWeightTextList=<"//ApsWeightTextList//">) returned EOF => Returning!")
#    print("stmerge: ERROR: fscan(ApsWeightTextList=<"//ApsWeightTextList//">) returned EOF => Returning!", >> LogFile)
#    print("stmerge: ERROR: fscan(ApsWeightTextList=<"//ApsWeightTextList//">) returned EOF => Returning!", >> WarningFile)
#    print("stmerge: ERROR: fscan(ApsWeightTextList=<"//ApsWeightTextList//">) returned EOF => Returning!", >> ErrorFile)
## --- clean up
#    P_StrList = ""
#    P_FileList = ""
#    return
#  }
#  ApsWeightTextList = TempFile
#  print("stmerge: ApsWeightTextList now set to <"//ApsWeightTextList//">")
#  if (LogLevel > 2)
#    print("stmerge: ApsWeightTextList now set to <"//ApsWeightTextList//">", >> LogFile)

# --- start rebintextfiles
  FitsRebinList = "rebintextfiles.list"
  if (access(FitsRebinList))
    del(FitsRebinList, ver-)
  print(ApsImTextList, >> FitsRebinList)
  print(ApsErrTextList, >> FitsRebinList)
#  print(ApsImSNRFitTextList, >> FitsRebinList)
  print(ApsWeightTextList, >> FitsRebinList)
  flpr
  if (access(LogFile_rebintextfiles))
    del(LogFile_rebintextfiles, ver-)
  getpath()
  print("stmerge: Starting rebintextfiles("//getpath.path//"/"//FitsRebinList//", "//Oversampling//")")
  if (LogLevel > 2)
    print("stmerge: Starting rebintextfiles("//getpath.path//"/"//FitsRebinList//", "//Oversampling//")", >> LogFile)
  rebintextfiles(getpath.path//"/"//FitsRebinList, Oversampling, >> LogFile_rebintextfiles)
  if (access(LogFile_rebintextfiles))
    cat(LogFile_rebintextfiles, >> LogFile)

  jobs
  wait()

# --- write rebintextfiles outfiles to FitsMergeList
#  -- image text files
  strlastpos(ApsImTextList, "_text")
  Pos = strlastpos.pos
  if (Pos == 0){
    strlastpos(ApsImTextList, ".")
    Pos = strlastpos.pos
  }
  if (Pos == 0)
    Pos = strlen(ApsImTextList) + 1
  ApsImRBTextList = substr(ApsImTextList, 1, Pos-1)//"Rb_text.list"
  if (access(ApsImRBTextList))
    del(ApsImRBTextList, ver-)
  P_FileList = ApsImTextList
  while(fscan(P_FileList, FileName) != EOF){
    flpr
    strlastpos(FileName, "_text")
    if (strlastpos.pos == 0)
      strlastpos(FileName, ".")
    Pos = strlastpos.pos
    if (Pos == 0)
      Pos = strlen(FileName) + 1
    Output = substr(FileName, 1, Pos-1)//"_rb.text"#//substr(FileName, Pos, strlen(FileName))
    if (!access(Output)){
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning")
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> LogFile)
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> WarningFile)
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> ErrorFile)
# --- clean up
#      del(HeaderList, ver-)
#      del(HeaderErrList, ver-)
      P_StrList = ""
      P_FileList = ""
      return
    }
    print("stmerge: output of rebintextfiles = <"//Output//">")
    print("stmerge: output of rebintextfiles = <"//Output//">", >> LogFile)
    print(Output, >> ApsImRBTextList)
  }

  flpr
#  -- error text files
  strlastpos(ApsErrTextList, "_text")
  if (strlastpos.pos == 0)
    strlastpos(ApsErrTextList, ".")
  Pos = strlastpos.pos
  if (Pos == 0)
    Pos = strlen(ApsErrTextList) + 1
  ApsErrRBTextList = substr(ApsErrTextList, 1, Pos-1)//"Rb_text.list"
  if (access(ApsErrRBTextList))
    del(ApsErrRBTextList, ver-)
  P_FileList = ApsErrTextList
  while(fscan(P_FileList, FileName) != EOF){
    flpr
    strlastpos(FileName, "_text")
    if (strlastpos.pos == 0)
      strlastpos(FileName, ".")
    Pos = strlastpos.pos
    if (Pos == 0)
      Pos = strlen(FileName) + 1
    Output = substr(FileName, 1, Pos-1)//"_rb.text"#//substr(FileName, Pos, strlen(FileName))
    if (!access(Output)){
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning")
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> LogFile)
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> WarningFile)
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> ErrorFile)
# --- clean up
#      del(HeaderList, ver-)
#      del(HeaderErrList, ver-)
      P_StrList = ""
      P_FileList = ""
      return
    }
    print("stmerge: output of rebintextfiles = <"//Output//">")
    print("stmerge: output of rebintextfiles = <"//Output//">", >> LogFile)
    print(Output, >> ApsErrRBTextList)
  }

  flpr

##  -- fit snr text files
#  strlastpos(ApsSNRFitTextList, "_text")
#  if (strlastpos.pos == 0)
#    strlastpos(ApsSNRFitTextList, ".")
#  Pos = strlastpos.pos
#  if (Pos == 0)
#    Pos = strlen(ApsSNRFitTextList) + 1
#  ApsSNRFitRBTextList = substr(ApsSNRFitTextList, 1, Pos-1)//"Rb_text.list"
#  if (access(ApsSNRFitRBTextList))
#    del(ApsSNRFitRBTextList, ver-)
#  P_FileList = ApsSNRFitTextList
#  while(fscan(P_FileList, FileName) != EOF){
#    flpr
#    strlastpos(FileName, "_text")
#    if (strlastpos.pos == 0)
#      strlastpos(FileName, ".")
#    Pos = strlastpos.pos
#    if (Pos == 0)
#      Pos = strlen(FileName) + 1
#    Output = substr(FileName, 1, Pos-1)//"_rb.text"#//substr(FileName, Pos, strlen(FileName))
#    if (!access(Output)){
#      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning")
#      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> LogFile)
#      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> WarningFile)
#      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> ErrorFile)
## --- clean up
#      P_StrList = ""
#      P_FileList = ""
#      return
#    }
#    print("stmerge: output of rebintextfiles = <"//Output//">")
#    print("stmerge: output of rebintextfiles = <"//Output//">", >> LogFile)
#    print(Output, >> ApsSNRFitRBTextList)
#  }

#  -- weight text files
  strlastpos(ApsWeightTextList, "_text")
  if (strlastpos.pos == 0)
    strlastpos(ApsWeightTextList, ".")
  Pos = strlastpos.pos
  if (Pos == 0)
    Pos = strlen(ApsWeightTextList) + 1
  ApsWeightRBTextList = substr(ApsWeightTextList, 1, Pos-1)//"Rb_text.list"
  print("stmerge: ApsWeightRBTextList = <"//ApsWeightRBTextList//">")
  if (LogLevel > 2)
    print("stmerge: ApsWeightRBTextList = <"//ApsWeightRBTextList//">", >> LogFile)
  if (access(ApsWeightRBTextList))
    del(ApsWeightRBTextList, ver-)
  P_FileList = ApsWeightTextList
  while(fscan(P_FileList, FileName) != EOF){
    print("stmerge: FileName read from ApsWeightRBTextList: <"//FileName//">")
    if (LogLevel > 2)
      print("stmerge: FileName read from ApsWeightRBTextList: <"//FileName//">", >> LogFile)
    flpr
    strlastpos(FileName, "_text")
    if (strlastpos.pos == 0)
      strlastpos(FileName, ".")
    Pos = strlastpos.pos
    if (Pos == 0)
      Pos = strlen(FileName) + 1
    Output = substr(FileName, 1, Pos-1)//"_rb.text"#//substr(FileName, Pos, strlen(FileName))
    if (!access(Output)){
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning")
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> LogFile)
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> WarningFile)
      print("stmerge: ERROR: cannot access output of rebintextfiles <"//Output//">! => Returning", >> ErrorFile)
# --- clean up
#      del(HeaderList, ver-)
#      del(HeaderErrList, ver-)
      P_StrList = ""
      P_FileList = ""
      return
    }
    print("stmerge: writing output of rebintextfiles = <"//Output//"> to ApsWeightRBTextList <"//ApsWeightRBTextList//">")
    print("stmerge: writing output of rebintextfiles = <"//Output//"> to ApsWeightRBTextList <"//ApsWeightRBTextList//">", >> LogFile)
    print(Output, >> ApsWeightRBTextList)
  }

  jobs
  wait

  flpr

# --- starting mergeimsnr
  flpr
  if (access(LogFile_fitsmerge))
    del(LogFile_fitsmerge, ver-)
  getpath()
  flpr
#  print("stmerge: starting mergespecweight("//getpath.path//"/"//ApsImRBTextList//", "//getpath.path//"/"//ApsWeightRBTextList)
#  if (LogLevel > 2)
#    print("stmerge: starting mergespecweight("//getpath.path//"/"//ApsImRBTextList//", "// getpath.path//"/"//ApsWeightRBTextList, >> LogFile)
##  fitsmerge(getpath.path//"/"//FitsMergeList, getpath.path//"/"//FitsMergeErrFitRBTextList, >> LogFile_fitsmerge)
##  -- object spectra
#  mergespecweight(getpath.path//"/"//ApsImRBTextList, getpath.path//"/"//ApsWeightRBTextList, >> LogFile_fitsmerge)
#  if (access(LogFile_fitsmerge)){
#    cat(LogFile_fitsmerge, >> LogFile)
#    del(LogFile_fitsmerge, ver-)
#  }
  strlastpos(ApsImRBTextList, ".")
  Pos = strlastpos.pos
  if (Pos == 0)
    Pos = strlen(ApsImRBTextList) + 1
  Input = substr(ApsImRBTextList, 1, Pos-1)//"_m.text"
#  if (!access(Input)){
#    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning")
#    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> LogFile)
#    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> WarningFile)
#    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> ErrorFile)
## --- clean up
##    del(HeaderList, ver-)
##    del(HeaderErrList, ver-)
#    P_StrList = ""
#    P_FileList = ""
#    return
#  }
  print("stmerge: starting mergespecweightconv("//getpath.path//"/"//ApsImRBTextList//", "//getpath.path//"/"//ApsWeightRBTextList)
  if (LogLevel > 2)
    print("stmerge: starting mergespecweightconv("//getpath.path//"/"//ApsImRBTextList//", "//getpath.path//"/"//ApsWeightRBTextList, >> LogFile)
  mergespecweightconv(getpath.path//"/"//ApsImRBTextList, getpath.path//"/"//ApsWeightRBTextList, >> LogFile_fitsmerge)
  if (access(LogFile_fitsmerge)){
    cat(LogFile_fitsmerge, >> LogFile)
    del(LogFile_fitsmerge, ver-)
  }
  if (!access(Input)){
    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning")
    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> LogFile)
    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> WarningFile)
    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> ErrorFile)
# --- clean up
#    del(HeaderList, ver-)
#    del(HeaderErrList, ver-)
    P_StrList = ""
    P_FileList = ""
    return
  }
#  -- sigma spectra
#  fitsmerge(getpath.path//"/"//FitsMergeErrTextList, getpath.path//"/"//FitsMergeErrFitRBTextList, >> LogFile_fitsmerge)
#  print("stmerge: starting mergespecweightconv("//getpath.path//"/"//ApsErrRBTextList//", "//getpath.path//"/"//ApsWeightRBTextList)
#  if (LogLevel > 2)
#    print("stmerge: starting mergespecweightconv("//getpath.path//"/"//ApsErrRBTextList//", "//getpath.path//"/"//ApsWeightRBTextList, >> LogFile)
#  mergespecweightconv(getpath.path//"/"//ApsErrRBTextList, getpath.path//"/"//ApsWeightRBTextList, >> LogFile_fitsmerge)
#  if (access(LogFile_fitsmerge)){
#    cat(LogFile_fitsmerge, >> LogFile)
#    del(LogFile_fitsmerge, ver-)
#  }
#  strlastpos(ApsErrRBTextList, ".")
#  Pos = strlastpos.pos
#  if (Pos == 0)
#    Pos = strlen(ApsErrRBTextList) + 1
#  Input = substr(ApsErrRBTextList, 1, Pos-1)//"_m.text"
#  if (!access(Input)){
#    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning")
#    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> LogFile)
#    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> WarningFile)
#    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> ErrorFile)
## --- clean up
##    del(HeaderList, ver-)
##    del(HeaderErrList, ver-)
#    P_StrList = ""
#    P_FileList = ""
#    return
#  }
  print("stmerge: starting mergespecweightconv("//getpath.path//"/"//ApsErrRBTextList, getpath.path//"/"//ApsWeightRBTextList)
  if (LogLevel > 2)
    print("stmerge: starting mergespecweightconv("//getpath.path//"/"//ApsErrRBTextList, getpath.path//"/"//ApsWeightRBTextList, >> LogFile)
  mergespecweightconv(getpath.path//"/"//ApsErrRBTextList, getpath.path//"/"//ApsWeightRBTextList, >> LogFile_fitsmerge)
  if (access(LogFile_fitsmerge)){
    cat(LogFile_fitsmerge, >> LogFile)

# --- first read fits file without header and then add header keywords
  }
  if (!access(Input)){
    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning")
    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> LogFile)
    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> WarningFile)
    print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> ErrorFile)
# --- clean up
    P_StrList = ""
    P_FileList = ""
    return
  }
  print("stmerge: fitsmerge ready")
  if (LogLevel > 2)
    print("stmerge: fitsmerge ready", >> LogFile)

  print("stmerge: waiting for jobs to finish")
  if (LogLevel > 2)
    print("stmerge: waiting for jobs to finish", >> LogFile)
  jobs
  wait()
  print("stmerge: going ahead")
  if (LogLevel > 2)
    print("stmerge: going ahead", >> LogFile)

# --- read text files to fits files
  CalcSNRList = "calcsnr.list"
  CalcSNRErrList = "calcsnr_err.list"
  if (access(CalcSNRList))
    del (CalcSNRList, ver-)
  if (access(CalcSNRErrList))
    del (CalcSNRErrList, ver-)
  print("stmerge: CalcSNRList = "//CalcSNRList)
  if (LogLevel > 2)
    print("stmerge: CalcSNRList = "//CalcSNRList, >> LogFile)
  print("stmerge: CalcSNRErrList = "//CalcSNRErrList)
  if (LogLevel > 2)
    print("stmerge: CalcSNRErrList = "//CalcSNRErrList, >> LogFile)

# --- read object spectra
  for(i=1; i<=2; i=i+1){
    if (i == 1){
      TempHeaderFile = HeaderFile
      strlastpos(ApsImRBTextList, ".")
      Pos = strlastpos.pos
      if (Pos == 0)
        Pos = strlen(ApsImRBTextList) + 1
      Input = substr(ApsImRBTextList, 1, Pos-1)//"_m.text"
      strlastpos(ApsImRBTextList, "_text")
      if (strlastpos.pos == 0)
        strlastpos(ApsImRBTextList, ".")
      Pos = strlastpos.pos
      if (Pos == 0)
        Pos = strlen(ApsImRBTextList) + 1
      Output = substr(ApsImRBTextList, 1, Pos-1)//"M."//ImType
      Title = substr(ApsImRBTextList, 1, Pos-1)//" merged"
# --- look for headerfile
#      strlastpos(ApsImRBTextList, "d")
#      if (strlastpos.pos == 0)
#        strlastpos(ApsImRBTextList, ".")
#      Pos = strlastpos.pos-1
#      if (Pos == 0)
#        Pos = strlen(ApsImRBTextList)
      P_FileList = ApsImFitsList
      if (fscan(P_FileList, FitsFile) == EOF){
        print("stmerge: ERROR: fscan(ApsImFitsList, FitsFile) returned EOF! => Returning")
        print("stmerge: ERROR: fscan(ApsImFitsList, FitsFile) returned EOF! => Returning", >> LogFile)
        print("stmerge: ERROR: fscan(ApsImFitsList, FitsFile) returned EOF! => Returning", >> WarningFile)
        print("stmerge: ERROR: fscan(ApsImFitsList, FitsFile) returned EOF! => Returning", >> ErrorFile)
# --- clean up
#        del(HeaderList, ver-)
#        del(HeaderErrList, ver-)
        P_StrList = ""
        P_FileList = ""
        return
      }
    }
    else{
#      P_FileList = HeaderErrList
      TempHeaderFile = HeaderErrFile
      strlastpos(ApsErrRBTextList, ".")
      Pos = strlastpos.pos
      if (Pos == 0)
        Pos = strlen(ApsErrRBTextList) + 1
      Input = substr(ApsErrRBTextList, 1, Pos-1)//"_m.text"
      Title = substr(ApsErrRBTextList, 1, Pos-1)//" merged"

      strlastpos(ApsErrRBTextList, "_text")
      Pos = strlastpos.pos
      if (Pos == 0){
        strlastpos(ApsErrRBTextList, ".")
        Pos = strlastpos.pos
      }
      if (Pos == 0)
        Pos = strlen(ApsErrRBTextList) + 1

      Output = substr(ApsErrRBTextList, 1, Pos-1)//"M."//ImType
# --- look for headerfile
      P_FileList = ApsErrFitsList
      if (fscan(P_FileList, FitsFile) == EOF){
        print("stmerge: ERROR: fscan(ApsErrFitsList, FitsFile) returned EOF! => Returning")
        print("stmerge: ERROR: fscan(ApsErrFitsList, FitsFile) returned EOF! => Returning", >> LogFile)
        print("stmerge: ERROR: fscan(ApsErrFitsList, FitsFile) returned EOF! => Returning", >> WarningFile)
        print("stmerge: ERROR: fscan(ApsErrFitsList, FitsFile) returned EOF! => Returning", >> ErrorFile)
# --- clean up
#        del(HeaderList, ver-)
#        del(HeaderErrList, ver-)
        P_StrList = ""
        P_FileList = ""
        return
      }
    }
    print("stmerge: rspectext.(err)input = "//Input)
    if (LogLevel > 2)
      print("stmerge: rspectext.(err)input = "//Input, >> LogFile)
    print("stmerge: rspectext.(err)output = "//Output)
    if (LogLevel > 2)
      print("stmerge: rspectext.(err)output = "//Output, >> LogFile)
    if (!access(Input)){
      print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning")
      print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> LogFile)
      print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> WarningFile)
      print("stmerge: ERROR: Input for rspectext <"//Input//"> not found! => Returning", >> ErrorFile)
# --- clean up
#      del(HeaderList, ver-)
#      del(HeaderErrList, ver-)
      P_StrList = ""
      P_FileList = ""
      return
    }
    print("stmerge: rspectext.input = "//Input)
    if (LogLevel > 2)
      print("stmerge: rspectext.input = "//Input, >> LogFile)
    print("stmerge: rspectext.output = "//Output)
    if (LogLevel > 2)
      print("stmerge: rspectext.output = "//Output, >> LogFile)
    if (access(Output))
      del(Output, ver-)

    P_FileList = Input
    CRValA = 0.
    CDeltA = 0.
    NMid = 50
    for (k=1;k<=NMid;k=k+1)
    {
      if (fscan(P_FileList, WaveA, ValA) == EOF){
        print("stmerge: ERROR: fscan(Input="//Input//") returned EOF => Returning FALSE")
        print("stmerge: ERROR: fscan(Input="//Input//") returned EOF => Returning FALSE", >> LogFile)
        print("stmerge: ERROR: fscan(Input="//Input//") returned EOF => Returning FALSE", >> WarningFile)
        print("stmerge: ERROR: fscan(Input="//Input//") returned EOF => Returning FALSE", >> ErrorFile)
# --- clean up
        P_StrList = ""
        P_FileList = ""
        return
      }
      print("stmerge: WaveA = "//WaveA//", ValA = "//ValA)
      if (LogLevel > 1)
        print("stmerge: WaveA = "//WaveA//", ValA = "//ValA, >> LogFile)
      if (k==1)
        CRValA = real(WaveA)
      CDeltA = real(WaveA)
    }
    CDeltA = (CDeltA - CRValA) / (real(NMid) - 1.)
    round(CDeltA * 10000000.)
    CDeltA = round.Rounded / 10000000.
    jobs
    wait()
    flpr
    print("stmerge: CRValA = "//CRValA//", CDeltA = "//CDeltA)
    if (LogLevel > 1)
      print("stmerge: CRValA = "//CRValA//", CDeltA = "//CDeltA, >> LogFile)
    onedspec
    unlearn("hedit")
    flpr
    print("stmerge: starting rspectext(Input=<"//Input//">)")
    if (LogLevel > 2)
      print("stmerge: starting rspectext(Input=<"//Input//">)", >> LogFile)
    rspectext(input  = Input,
              output = Output,
              title  = Title,
              flux-,
              dtype  = "linear",
              crval1 = CRValA,
              cdelt1 = CDeltA)
    jobs
    wait()
    flpr
    if (!access(Output)){
      print("stmerge: ERROR: cannot access respectext Output <"//Output//">! => Returning")
      print("stmerge: ERROR: cannot access respectext Output <"//Output//">! => Returning", >> LogFile)
      print("stmerge: ERROR: cannot access respectext Output <"//Output//">! => Returning", >> WarningFile)
      print("stmerge: ERROR: cannot access respectext Output <"//Output//">! => Returning", >> ErrorFile)
# --- clean up
#      del(HeaderList, ver-)
#      del(HeaderErrList, ver-)
      P_StrList = ""
      P_FileList = ""
      return
    }
    print("stmerge: rspectext.Output <"//Output//"> ready")
    if (LogLevel > 2)
      print("stmerge: rspectext.Output <"//Output//"> ready", >> LogFile)
    if (i == 1){
      print(Output, >> CalcSNRList)
      jobs
      wait()
      flpr
      if (!access(CalcSNRList)){
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning")
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> LogFile)
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> WarningFile)
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> ErrorFile)
# --- clean up
        P_StrList = ""
        P_FileList = ""
        return
      }
      print("stmerge: CalcSNRList <"//CalcSNRList//">ready")
    }
    else{
      print(Output, >> CalcSNRErrList)
      jobs
      wait()
      flpr
      if (!access(CalcSNRErrList)){
        print("stmerge: ERROR: cannot access CalcSNRErrList <"//CalcSNRErrList//">! => Returning")
        print("stmerge: ERROR: cannot access CalcSNRErrList <"//CalcSNRErrList//">! => Returning", >> LogFile)
        print("stmerge: ERROR: cannot access CalcSNRErrList <"//CalcSNRErrList//">! => Returning", >> WarningFile)
        print("stmerge: ERROR: cannot access CalcSNRErrList <"//CalcSNRErrList//">! => Returning", >> ErrorFile)
# --- clean up
        P_StrList = ""
        P_FileList = ""
        return
      }
    }

    if (access(TempHeaderFile)){
      print("stmerge: TempHeaderFile <"//TempHeaderFile//"> found => appending Input <"//Input//"> to TempHeaderFile")
      if (LogLevel > 2)
        print("stmerge: TempHeaderFile <"//TempHeaderFile//"> found => appending Input <"//Input//"> to TempHeaderFile", >> LogFile)
#      strlastpos(TempHeaderFile, "_head")
#      Pos = strlastpos.pos
#      HeaderInput = substr(TempHeaderFile, 1, Pos - 1)//"+"//substr(TempHeaderFile, Pos + 1, strlen(TempHeaderFile))
#      if (access(HeaderInput))
#        del(HeaderInput, ver-)
# --- writing HeaderFile and DataFile to HeaderInput
      if (access(LogFile_addheadertofitsfile))
        del(LogFile_addheadertofitsfile, ver-)
      if (!access(CalcSNRList)){
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning")
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> LogFile)
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> WarningFile)
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> ErrorFile)
# --- clean up
        P_StrList = ""
        P_FileList = ""
        return
      }
      print("stmerge: CalcSNRList <"//CalcSNRList//">ready")
      flpr
      addheadertofitsfile(Output, TempHeaderFile, >> LogFile_addheadertofitsfile)
      jobs
      wait()
      flpr
      if (access(LogFile_addheadertofitsfile))
        cat(LogFile_addheadertofitsfile, >> LogFile)
      ccdlist(Output)
      ccdlist(Output, >> LogFile)
      if (!access(CalcSNRList)){
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning")
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> LogFile)
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> WarningFile)
        print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> ErrorFile)
# --- clean up
        P_StrList = ""
        P_FileList = ""
        return
      }
      print("stmerge: CalcSNRList <"//CalcSNRList//">ready")

#      print("END", >> HeaderInput)
#      print("", >> HeaderInput)
#      print("", >> HeaderInput)
#      print("", >> HeaderInput)
#      cat (Input, >> HeaderInput)
#      Input = HeaderInput
    }
    else{
      print("stmerge: Warning: TempHeaderFile <"//TempHeaderFile//"> not found!")
      print("stmerge: Warning: TempHeaderFile <"//TempHeaderFile//"> not found!", >> LogFile)
      print("stmerge: Warning: TempHeaderFile <"//TempHeaderFile//"> not found!", >> WarningFile)
    }
    jobs
    wait()
    flpr
    if (!access(CalcSNRList)){
      print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning")
      print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> LogFile)
      print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> WarningFile)
      print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> ErrorFile)
# --- clean up
      P_StrList = ""
      P_FileList = ""
      return
    }
    print("stmerge: CalcSNRList <"//CalcSNRList//">ready")
  }# end for(i=1; i<=2; i=i+1)

# --- calculate snr image
  if (!access(CalcSNRList)){
    print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning")
    print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> LogFile)
    print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> WarningFile)
    print("stmerge: ERROR: cannot access CalcSNRList <"//CalcSNRList//">! => Returning", >> ErrorFile)
# --- clean up
#    del(HeaderList, ver-)
#    del(HeaderErrList, ver-)
    P_StrList = ""
    P_FileList = ""
    return
  }
  if (!access(CalcSNRErrList)){
    print("stmerge: ERROR: cannot access CalcSNRErrList <"//CalcSNRErrList//">! => Returning")
    print("stmerge: ERROR: cannot access CalcSNRErrList <"//CalcSNRErrList//">! => Returning", >> LogFile)
    print("stmerge: ERROR: cannot access CalcSNRErrList <"//CalcSNRErrList//">! => Returning", >> WarningFile)
    print("stmerge: ERROR: cannot access CalcSNRErrList <"//CalcSNRErrList//">! => Returning", >> ErrorFile)
# --- clean up
#    del(HeaderList, ver-)
#    del(HeaderErrList, ver-)
    P_StrList = ""
    P_FileList = ""
    return
  }
  jobs
  wait()
  flpr
  stcalcsnr(Images = "@"//CalcSNRList,
            ErrorImages = "@"//CalcSNRErrList,
            ImType = ImType,
            LogLevel = LogLevel,
            LogFile = LogFile_stcalcsnr,
            WarningFile = WarningFile_stcalcsnr,
            ErrorFile = ErrorFile_stcalcsnr)
  if (access(LogFile_stcalcsnr))
    cat(LogFile_stcalcsnr, >> LogFile)
  if (access(WarningFile_stcalcsnr))
    cat(WarningFile_stcalcsnr, >> WarningFile)
  if (access(ErrorFile_stcalcsnr)){
    cat(ErrorFile_stcalcsnr, >> ErrorFile)
    print("stmerge: ERROR: stcalcsnr returned an ERROR => Returning")
    print("stmerge: ERROR: stcalcsnr returned an ERROR => Returning", >> LogFile)
    print("stmerge: ERROR: stcalcsnr returned an ERROR => Returning", >> WarningFile)
    print("stmerge: ERROR: stcalcsnr returned an ERROR => Returning", >> ErrorFile)
# --- clean up
#    del(HeaderList, ver-)
#    del(HeaderErrList, ver-)
    P_StrList = ""
    P_FileList = ""
    return
  }
  jobs
  wait()
  flpr
            
  print("stmerge: READY")
  print("stmerge: READY", >> LogFile)

# --- clean up
#  del(HeaderList, ver-)
#  del(HeaderErrList, ver-)
  P_StrList = ""
  P_FileList = ""

end
