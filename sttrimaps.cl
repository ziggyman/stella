procedure sttrimaps (Images)

##################################################################
#                                                                #
# NAME:             sttrimaps.cl                                 #
# PURPOSE:          * trims the individual apertures of the      #
#                     extracted spectra automatically            #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: sttrimaps(Images)                            #
# INPUTS:           Input: String                                #
#                     name of list containing names of filenames #
#                     of the individual orders to trim:          #
#                       "objects_botzfxsEcBl.list":              #
#                         HD175640_botzfxsEcBl.fits              #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     <Entry_of_Images_Root>t.fits               #
#                                   ...                          #
#                   Log Files:                                   #
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      13.11.2001                                   #
# LAST EDITED:      16.04.2007                                   #
#                                                                #
##################################################################

string Images         = "@trim.list"                  {prompt="List of images to trim"}
string ParameterFile  = "scripts$parameterfile.prop"  {prompt="Parameterfile"}
int    DispAxis       = 2                             {prompt="1-horizontal, 2-vertical"}
int    FirstGapBefore = 76                            {prompt="First gap is before order no.."}
string TrimSecApA     = "[700:2000]"                  {prompt="Trim section first aperture"}
string TrimSecApB     = "[500:2100]"                  {prompt="Trim section second aperture"}
string TrimSecApM     = "[500:2100]"                  {prompt="Trim section of aperture before gap"}
string TrimSecApN     = "[500:2100]"                  {prompt="Trim section of aperture behind gap"}
string TrimSecApY     = "[200:2340]"                  {prompt="Trim section second last aperture"}
string TrimSecApZ     = "[200:2000]"                  {prompt="Trim section last aperture"}
string ImType         = "fits"                        {prompt="Image Type"}
int    LogLevel       = 3                             {prompt="Level for writing LogFile"}
string LogFile        = "logfile_sttrimaps.log"       {prompt="Name of log file"}
string WarningFile    = "warnings_sttrimaps.log"      {prompt="Name of warning file"}
string ErrorFile      = "errors_sttrimaps.log"        {prompt="Name of error file"}
string ApFitsFileLists
string ApTextFileLists
string *P_ImageList
string *P_TextFileList
string *P_TempList
string *P_TimeList

begin

  file   InFile,TimeFile,TempFileList,TempFileName
  string TrimSec,TempStr,ListName
  string TrimSecApABak, TrimSecApBBak, TrimSecApMBak, TrimSecApNBak, TrimSecApYBak, TrimSecApZBak
  string Parameter,ParameterValue
  string TrimBAStr,TrimBBStr,TrimYAStr,TrimYBStr
  string LambdaStr,FluxStr
  string TextFiles,TextFilesT,TempTextFilesT,TextFileName,TextFileNameT
  string FitsFiles,FitsFilesT,ParamTemp
  string tempdate,tempday,temptime
  string In,Out,ApIn,ApFilesList
  string LogFile_countorders = "logfile_countorders.log"
  string LogFile_countpix = "logfile_countpix.log"
  string LogFile_writeaps     = "logfile_writeaps.log"
  string WarningFile_writeaps = "warnings_writeaps.log"
  string ErrorFile_writeaps   = "errors_writeaps.log"
  int    NOrders,NPix,Pos
  int    NFile,TrimBA,TrimBB,TrimYA,TrimYB,TrimA,TrimB
  real   LambdaAA,LambdaAB,LambdaBA,LambdaBB
  int    i
  bool   TrimSecsSwapped = NO
  bool   FoundDispAxis          = NO
  bool   FoundFirstGapBefore    = NO
  bool   FoundTrimSecApA        = NO
  bool   FoundTrimSecApB        = NO
  bool   FoundTrimSecApM        = NO
  bool   FoundTrimSecApN        = NO
  bool   FoundTrimSecApY        = NO
  bool   FoundTrimSecApZ        = NO
  bool   FoundImType            = NO
  bool   IsFileList             = NO

# --- delete old logfiles
  if (access(LogFile))
    delete(LogFile, ver-)
  if (access(WarningFile))
    delete(WarningFile, ver-)
  if (access(ErrorFile))
    delete(ErrorFile, ver-)

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                      sttrimaps.cl                      *")
  print ("*          (trims apertures of input images)             *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("sttrimaps: Images = <"//Images//">")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*                      sttrimaps.cl                      *", >> LogFile)
  print ("*          (trims apertures of input images)             *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)
  print ("sttrimaps: Images = <"//Images//">", >> LogFile)

# --- read ParameterFile
  if (access(ParameterFile)){
    print ("sttrimaps: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("sttrimaps: **************** reading ParameterFile *******************", >> LogFile)

    P_TextFileList = ParameterFile

    while (fscan (P_TextFileList, Parameter, ParameterValue) != EOF){
      if (Parameter == "dispaxis"){
        DispAxis = int(ParameterValue)
        FoundDispAxis = YES
        print("sttrimaps: Setting DispAxis to "//DispAxis)
        print("sttrimaps: Setting DispAxis to "//DispAxis, >> LogFile)
      }
      else if (Parameter == "trimaps_firstgapbefore"){
        FirstGapBefore = int(ParameterValue)
        FoundFirstGapBefore = YES
        print("sttrimaps: Setting FirstGapBefore to "//FirstGapBefore)
        print("sttrimaps: Setting FirstGapBefore to "//FirstGapBefore, >> LogFile)
      }
      else if (Parameter == "trimaps_trimsecapa"){
        TrimSecApA = ParameterValue
        FoundTrimSecApA = YES
        print("sttrimaps: Setting TrimSecApA to "//TrimSecApA)
        print("sttrimaps: Setting TrimSecApA to "//TrimSecApA, >> LogFile)
      }
      else if (Parameter == "trimaps_trimsecapb"){
        TrimSecApB = ParameterValue
        FoundTrimSecApB = YES
        print("sttrimaps: Setting TrimSecApB to "//TrimSecApB)
        print("sttrimaps: Setting TrimSecApB to "//TrimSecApB, >> LogFile)
      }
      else if (Parameter == "trimaps_trimsecapm"){
        TrimSecApM = ParameterValue
        FoundTrimSecApM = YES
        print("sttrimaps: Setting TrimSecApM to "//TrimSecApM)
        print("sttrimaps: Setting TrimSecApM to "//TrimSecApM, >> LogFile)
      }
      else if (Parameter == "trimaps_trimsecapn"){
        TrimSecApN = ParameterValue
        FoundTrimSecApN = YES
        print("sttrimaps: Setting TrimSecApN to "//TrimSecApN)
        print("sttrimaps: Setting TrimSecApN to "//TrimSecApN, >> LogFile)
      }
      else if (Parameter == "trimaps_trimsecapy"){
        TrimSecApY = ParameterValue
        FoundTrimSecApY = YES
        print("sttrimaps: Setting TrimSecApY to "//TrimSecApY)
        print("sttrimaps: Setting TrimSecApY to "//TrimSecApY, >> LogFile)
      }
      else if (Parameter == "trimaps_trimsecapz"){
        TrimSecApZ = ParameterValue
        FoundTrimSecApZ = YES
        print("sttrimaps: Setting TrimSecApZ to "//TrimSecApZ)
        print("sttrimaps: Setting TrimSecApZ to "//TrimSecApZ, >> LogFile)
      }
      else if (Parameter == "imtype"){
        ImType = ParameterValue
        FoundImType = YES
        print("sttrimaps: Setting ImType to "//ImType)
        print("sttrimaps: Setting ImType to "//ImType, >> LogFile)
      }
    }#end while
    if (!FoundDispAxis){
      print("sttrimaps: WARNING: Parameter 'dispaxis' not found in "//ParameterFile//"!!! -> using standard value (="//DispAxis//")")
      print("sttrimaps: WARNING: Parameter 'dispaxis' not found in "//ParameterFile//"!!! -> using standard value (="//DispAxis//")", >> LogFile)
      print("sttrimaps: WARNING: Parameter 'dispaxis' not found in "//ParameterFile//"!!! -> using standard value (="//DispAxis//")", >> WarningFile)
    }
    if (!FoundFirstGapBefore){
      print("sttrimaps: WARNING: Parameter 'trimaps_firstgapbefore' not found in "//ParameterFile//"!!! -> using standard value (="//FirstGapBefore//")")
      print("sttrimaps: WARNING: Parameter 'trimaps_firstgapbefore' not found in "//ParameterFile//"!!! -> using standard value (="//FirstGapBefore//")", >> LogFile)
      print("sttrimaps: WARNING: Parameter 'trimaps_firstgapbefore' not found in "//ParameterFile//"!!! -> using standard value (="//FirstGapBefore//")", >> WarningFile)
    }
    if (!FoundTrimSecApA){
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapa' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApA//")")
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapa' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApA//")", >> LogFile)
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapa' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApA//")", >> WarningFile)
    }
    if (!FoundTrimSecApB){
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapb' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApB//")")
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapb' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApB//")", >> LogFile)
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapb' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApB//")", >> WarningFile)
    }
    if (!FoundTrimSecApM){
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapm' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApM//")")
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapm' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApM//")", >> LogFile)
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapm' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApM//")", >> WarningFile)
    }
    if (!FoundTrimSecApN){
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapn' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApN//")")
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapn' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApN//")", >> LogFile)
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapn' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApN//")", >> WarningFile)
    }
    if (!FoundTrimSecApY){
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapy' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApY//")")
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapy' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApY//")", >> LogFile)
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapy' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApY//")", >> WarningFile)
    }
    if (!FoundTrimSecApZ){
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapz' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApZ//")")
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapz' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApZ//")", >> LogFile)
      print("sttrimaps: WARNING: Parameter 'trimaps_trimsecapz' not found in "//ParameterFile//"!!! -> using standard value (="//TrimSecApZ//")", >> WarningFile)
    }
    if (!FoundImType){
      print("sttrimaps: WARNING: Parameter 'imtype' not found in "//ParameterFile//"!!! -> using standard value (="//imtype//")")
      print("sttrimaps: WARNING: Parameter 'imtype' not found in "//ParameterFile//"!!! -> using standard value (="//imtype//")", >> LogFile)
      print("sttrimaps: WARNING: Parameter 'imtype' not found in "//ParameterFile//"!!! -> using standard value (="//imtype//")", >> WarningFile)
    }
    print("sttrimaps: ParameterFile <"//ParameterFile//"> read")
    if (LogLevel > 2)
      print("sttrimaps: ParameterFile <"//ParameterFile//"> read", >> LogFile)
  }
  else{
    print("sttrimaps: Warning: ParameterFile <"//ParameterFile//"> not found! => Using standard parameter values!")
    print("sttrimaps: Warning: ParameterFile <"//ParameterFile//"> not found! => Using standard parameter values!", >> LogFile)
    print("sttrimaps: Warning: ParameterFile <"//ParameterFile//"> not found! => Using standard parameter values!", >> WarningFile)
  }

  TrimSecApABak = TrimSecApA
  TrimSecApBBak = TrimSecApB
  TrimSecApMBak = TrimSecApM
  TrimSecApNBak = TrimSecApN
  TrimSecApYBak = TrimSecApY
  TrimSecApZBak = TrimSecApZ

# --- Erzeugen von temporaeren Filenamen
  InFile = mktemp ("tmp")
  TimeFile = mktemp ("tmp")
  TempFileList = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  if (substr(Images,1,1) == "@"){
    ListName = substr(Images,2,strlen(Images))
    IsFileList = YES
  }
  else{
    ListName = Images
    IsFileList = NO
  }
  if (!access(ListName)){
    print("sttrimaps: ERROR: Images <"//ListName//"> not found! => Returning")
    print("sttrimaps: ERROR: Images <"//ListName//"> not found! => Returning", >> LogFile)
    print("sttrimaps: ERROR: Images <"//ListName//"> not found! => Returning", >> WarningFile)
    print("sttrimaps: ERROR: Images <"//ListName//"> not found! => Returning", >> ErrorFile)
# --- clean up
    delete (InFile, ver-, >& "dev$null")
    delete (TimeFile, ver-, >& "dev$null")
    delete (TempFileList, ver-, >& "dev$null")
    P_ImageList    = ""
    P_TimeList     = ""
    P_TempList     = ""
    P_TextFileList = ""
    return
  }
# --- output lists
  print("sttrimaps: ListName = <"//ListName//">")
  print("sttrimaps: ListName = <"//ListName//">", >> LogFile)
  strlastpos(ListName,".")
  if (strlastpos.pos < 1)
    ApFitsFileLists = ListName
  else
    ApFitsFileLists = substr(ListName,1,strlastpos.pos-1)
  ApTextFileLists = ApFitsFileLists
  ApFitsFileLists = ApFitsFileLists//"t_fits_lists.list"
  if (access(ApFitsFileLists))
    del(ApFitsFileLists, ver-)
  ApTextFileLists = ApTextFileLists//"t_text_lists.list"
  if (access(ApTextFileLists))
    del(ApTextFileLists, ver-)

  if (IsFileList)
    cat(ListName, >> TempFileList)
  else
    print(ListName, >> TempFileList)
  if (!access(TempFileList)){
    print("sttrimaps: ERROR: TempFileList <"//TempFileList//"> not found! => Returning")
    print("sttrimaps: ERROR: TempFileList <"//TempFileList//"> not found! => Returning", >> LogFile)
    print("sttrimaps: ERROR: TempFileList <"//TempFileList//"> not found! => Returning", >> WarningFile)
    print("sttrimaps: ERROR: TempFileList <"//TempFileList//"> not found! => Returning", >> ErrorFile)
# --- clean up
    delete (InFile, ver-, >& "dev$null")
    delete (TimeFile, ver-, >& "dev$null")
    delete (TempFileList, ver-, >& "dev$null")
    P_ImageList    = ""
    P_TimeList     = ""
    P_TempList     = ""
    P_TextFileList = ""
    return
  }

  print("sttrimaps: Reading TempFileList <"//TempFileList//">")
  sections("@"//TempFileList, option="root", > InFile)
  print ("**************************************************")
  P_ImageList = InFile

# --- build output filename and trim inputimages
  print ("**************************************************")
  while (fscan(P_ImageList, In) != EOF){
    print("sttrimaps: processing In = <"//In//">")
    print("sttrimaps: processing In = <"//In//">", >> LogFile)

# --- reset TrimSecs

    TrimSecApA = TrimSecApABak
    TrimSecApB = TrimSecApBBak
    TrimSecApM = TrimSecApMBak
    TrimSecApN = TrimSecApNBak
    TrimSecApY = TrimSecApYBak
    TrimSecApZ = TrimSecApZBak

# --- count number of orders
    flpr
    countorders(image    = In,
                dispaxis = DispAxis,
	        logfile  = LogFile_countorders)
    NOrders = countorders.norders
    print("sttrimaps: NOrders = "//NOrders)
    if (access(LogFile_countorders))
      cat(LogFile_countorders, >> LogFile)
    print("sttrimaps: In <"//In//"> countains "//NOrders//" orders")
    if (LogLevel > 2){
      print("sttrimaps: In <"//In//"> countains "//NOrders//" orders", >> LogFile)
    }

# --- count number of pixels
    flpr
    countpix(image = In, dispaxis = DispAxis, logfile = LogFile_countpix)
    NPix = countpix.npixels
    if (access(LogFile_countpix))
      cat(LogFile_countpix, >> LogFile)
    print("sttrimaps: In <"//In//"> countains "//NPix//" pixels per order")
    if (LogLevel > 2){
      print("sttrimaps: In <"//In//"> countains "//NPix//" pixels per order", >> LogFile)
    }

# --- write orders of In to text files
    print("sttrimaps: starting writeaps")
    if (LogLevel > 2)
      print("sttrimaps: starting writeaps", >> LogFile)

    flpr
    writeaps(Input       = In,
             DispAxis    = DispAxis,
             Delimiter   = "_",
             ImType      = ImType,
             WriteFits+,
             WSpecText+,
             WriteHeads+,
             WriteLists+,
             CreateDirs+,
             LogLevel    = LogLevel,
             LogFile     = LogFile_writeaps,
             WarningFile = WarningFile_writeaps,
             ErrorFile   = ErrorFile_writeaps)
    print("sttrimaps: writeaps ready")
    if (LogLevel > 2)
      print("sttrimaps: writeaps ready", >> LogFile)
    if (access(LogFile_writeaps))
      cat(LogFile_writeaps, >> LogFile)
    if (access(WarningFile_writeaps))
      cat(WarningFile_writeaps, >> WarningFile)
    if (access(ErrorFile_writeaps)){
      cat(ErrorFile_writeaps, >> ErrorFile)
      print("sttrimaps: ERROR: ErrorFile_writeaps <"//ErrorFile_writeaps//"> found! => Returning")
      print("sttrimaps: ERROR: ErrorFile_writeaps <"//ErrorFile_writeaps//"> found! => Returning", >> Logfile)
      print("sttrimaps: ERROR: ErrorFile_writeaps <"//ErrorFile_writeaps//"> found! => Returning", >> WarningFile)
      print("sttrimaps: ERROR: ErrorFile_writeaps <"//ErrorFile_writeaps//"> found! => Returning", >> ErrorFile)
# --- clean up
      delete (InFile, ver-, >& "dev$null")
      delete (TimeFile, ver-, >& "dev$null")
      delete (TempFileList, ver-, >& "dev$null")
      P_ImageList    = ""
      P_TimeList     = ""
      P_TempList     = ""
      P_TextFileList = ""
      return
    }

  # --- read fits-file list
    FitsFiles = writeaps.FitsOutList
    if (!access(FitsFiles)){
      print("sttrimaps: ERROR: FitsFiles "//FitsFiles//" not accessable!!!")
      print("sttrimaps: ERROR: FitsFiles "//FitsFiles//" not accessable!!!", >> LogFile)
      print("sttrimaps: ERROR: FitsFiles "//FitsFiles//" not accessable!!!", >> WarningFile)
      print("sttrimaps: ERROR: FitsFiles "//FitsFiles//" not accessable!!!", >> ErrorFile)
# --- clean up
      delete (InFile, ver-, >& "dev$null")
      delete (TimeFile, ver-, >& "dev$null")
      delete (TempFileList, ver-, >& "dev$null")
      P_ImageList    = ""
      P_TimeList     = ""
      P_TempList     = ""
      P_TextFileList = ""
      return
    }
    strlastpos(FitsFiles,"_fits")
    Pos = strlastpos.pos
    if (Pos < 1){
      strlastpos(FitsFiles, ".")
      Pos = strlastpos.pos
    }
    if (Pos < 1)
      Pos = strlen(FitsFiles) + 1
    FitsFilesT = substr(FitsFiles,1,Pos-1)//"t"//substr(FitsFiles,Pos,strlen(FitsFiles))
    if (access(FitsFilesT))
      del(FitsFilesT, ver-)
    print("sttrimaps: Appending FitsFilesT <"//FitsFilesT//"> to ApFitsFileList <"//ApFitsFileList//">")
    if (LogLevel > 2)
      print("sttrimaps: Appending FitsFilesT <"//FitsFilesT//"> to ApFitsFileList <"//ApFitsFileList//">", >> LogFile)
    print(FitsFilesT, >> ApFitsFileList)

# --- read text-file list
    TextFiles = writeaps.TextOutList
    if (!access(TextFiles)){
      print("sttrimaps: ERROR: TextFiles "//TextFiles//" not accessable!!!")
      print("sttrimaps: ERROR: TextFiles "//TextFiles//" not accessable!!!", >> LogFile)
      print("sttrimaps: ERROR: TextFiles "//TextFiles//" not accessable!!!", >> WarningFile)
      print("sttrimaps: ERROR: TextFiles "//TextFiles//" not accessable!!!", >> ErrorFile)
# --- clean up
      delete (InFile, ver-, >& "dev$null")
      delete (TimeFile, ver-, >& "dev$null")
      delete (TempFileList, ver-, >& "dev$null")
      P_ImageList    = ""
      P_TimeList     = ""
      P_TempList     = ""
      P_TextFileList = ""
      return
    }
    strlastpos(TextFiles,"_text")
    Pos = strlastpos.pos
    if (Pos < 1){
      strlastpos(TextFiles, ".")
      Pos = strlastpos.pos
    }
    if (Pos < 1)
      Pos = strlen(TextFiles) + 1
    TextFilesT = substr(TextFiles,1,Pos-1)//"t"//substr(TextFiles,Pos,strlen(TextFiles))
    print("sttrimaps: Appending TextFilesT <"//TextFilesT//"> to ApTextFileList <"//ApTextFileList//">")
    if (LogLevel > 2)
      print("sttrimaps: Appending TextFilesT <"//TextFilesT//"> to ApTextFileList <"//ApTextFileList//">", >> LogFile)

    print(TextFilesT, >> ApTextFileList)
    if (access(TextFilesT))
      del(TextFilesT, ver-)

    jobs
    wait()
## --- trim apertures

## --- check if 1st order has minimum lambda
    if (!TrimSecsSwapped){
      P_TextFileList = TextFiles
      NFile = 0
      while (fscan(P_TextFileList, TextFileName) != EOF){
        NFile += 1
        if (NFile == 1 || NFile == 2){
          if (access(TextFileName)){
            tail(TextFileName, nlines=1, >> TextFileName//"_lastline_temp")
            head(TextFileName, nlines=1, >> TextFileName//"_firstline_temp")
            wait()
            TempFileName = TextFileName//"_firstline_temp"
            if (!access(TempFileName)){
              print("sttrimaps: ERROR: "//TempFileName//" not found! => Returning")
              print("sttrimaps: ERROR: "//TempFileName//" not found! => Returning", >> LogFile)
              print("sttrimaps: ERROR: "//TempFileName//" not found! => Returning", >> WarningFile)
              print("sttrimaps: ERROR: "//TempFileName//" not found! => Returning", >> ErrorFile)
# --- clean up
              delete (InFile, ver-, >& "dev$null")
              delete (TimeFile, ver-, >& "dev$null")
              delete (TempFileList, ver-, >& "dev$null")
              P_ImageList    = ""
              P_TimeList     = ""
              P_TempList     = ""
              P_TextFileList = ""
              return
            }
            P_TempList = TempFileName
            while(fscan(P_TempList,LambdaStr,FluxStr) != EOF){
              if (NFile == 1)
                LambdaAA = real(LambdaStr)
              else
                LambdaBA = real(LambdaStr)
            }
            del(TempFileName, ver-)

            TempFileName = TextFileName//"_lastline_temp"
            if (!access(TempFileName)){
              print("sttrimaps: ERROR: "//TempFileName//" not found! => Returning")
              print("sttrimaps: ERROR: "//TempFileName//" not found! => Returning", >> LogFile)
              print("sttrimaps: ERROR: "//TempFileName//" not found! => Returning", >> WarningFile)
              print("sttrimaps: ERROR: "//TempFileName//" not found! => Returning", >> ErrorFile)
# --- clean up
              delete (InFile, ver-, >& "dev$null")
              delete (TimeFile, ver-, >& "dev$null")
              delete (TempFileList, ver-, >& "dev$null")
              P_ImageList    = ""
              P_TimeList     = ""
              P_TempList     = ""
              P_TextFileList = ""
              return
            }
            P_TempList = TempFileName
            while(fscan(P_TempList,LambdaStr,FluxStr) != EOF){
              if (NFile == 1)
                LambdaAB = real(LambdaStr)
              else
                LambdaBB = real(LambdaStr)
            }
            del(TempFileName, ver-)
          }
        }# end if (NFile == 1 || NFile == 2){
      }# end while (fscan(P_TextFileList, TextFileName) != EOF){

      if (LambdaAA > LambdaBA){
        # --- TrimSecApA <=> TrimSecApZ
        TempStr = TrimSecApA
        TrimSecApA = TrimSecApZ
        TrimSecApZ = TempStr

        # --- TrimSecApN <=> TrimSecApM
        TempStr = TrimSecApN
        TrimSecApN = TrimSecApM
        TrimSecApM = TempStr

        # --- TrimSecApB <=> TrimSecApY
        TempStr = TrimSecApB
        TrimSecApB = TrimSecApY
        TrimSecApY = TempStr

        if (FirstGapBefore > 0)
          FirstGapBefore = NOrders - FirstGapBefore
        print("sttrimaps: Lambda of first order is greater than lambda of last order => TrimSec's switched")
        if (LogLevel > 2)
          print("sttrimaps: Lambda of first order is greater than lambda of last order => TrimSec's switched", >> LogFile)
      }
      if (FirstGapBefore == 0){
        TrimSecApM = TrimSecApY
        TrimSecApN = TrimSecApB
      }
      TrimSecsSwapped = YES

      TrimSecApABak = TrimSecApA
      TrimSecApBBak = TrimSecApB
      TrimSecApMBak = TrimSecApM
      TrimSecApNBak = TrimSecApN
      TrimSecApYBak = TrimSecApY
      TrimSecApZBak = TrimSecApZ
    }
#    TrimSecApYBak = TrimSecApY

    NFile = 0
    TempTextFilesT = TextFilesT
    P_TextFileList = FitsFiles
    P_TempList = TextFiles
    while(fscan(P_TextFileList, ApIn) != EOF){
      NFile = NFile+1
      if (substr (ApIn, strlen(ApIn)-strlen(ImType),strlen(ApIn)) != "."//ImType)
        ApIn = ApIn//"."//ImType
      if (!access(ApIn)){
        print("sttrimaps: ERROR: ApIn <"//ApIn//"> not found! => Returning")
        print("sttrimaps: ERROR: ApIn <"//ApIn//"> not found! => Returning", >> LogFile)
        print("sttrimaps: ERROR: ApIn <"//ApIn//"> not found! => Returning", >> WarningFile)
        print("sttrimaps: ERROR: ApIn <"//ApIn//"> not found! => Returning", >> ErrorFile)
# --- clean up
        delete (InFile, ver-, >& "dev$null")
        delete (TimeFile, ver-, >& "dev$null")
        delete (TempFileList, ver-, >& "dev$null")
        P_ImageList    = ""
        P_TimeList     = ""
        P_TempList     = ""
        P_TextFileList = ""
        return
      }
      strlastpos(ApIn, "_fits")
      if (strlastpos.pos == 0)
        strlastpos(ApIn, ".")
      Out = substr(ApIn, 1, strlastpos.pos-1)//"t."//ImType
#      Out = substr(ApIn, 1, strlen(ApIn)-strlen(ImType)-1)//"t."//ImType
      print("sttrimaps: Processing order no "//NFile//": ApIn <"//ApIn//">, Out = <"//Out//">")
      print("sttrimaps: Processing order no "//NFile//": ApIn <"//ApIn//">, Out = <"//Out//">", >> LogFile)
      if (access(Out)){
        del(Out,ver-)
        print("sttrimaps: old Out "//Out//" deleted")
      }
      print(Out, >> FitsFilesT)

      TrimBAStr = ""
      TrimBBStr = ""
      TrimYAStr = ""
      TrimYBStr = ""
      TrimA  = 0.
      TrimB  = 0.
      if (NFile == 1 || NFile == NOrders){
        if (NFile == 1)
          TrimSec = TrimSecApA
        else
          TrimSec = TrimSecApZ
      }# end if (NFile == 1 || NFile == NOrders)
      else{
        if (NFile < FirstGapBefore){
          TrimSecApY = TrimSecApM
        }
        else{
          TrimSecApB = TrimSecApN
          TrimSecApY = TrimSecApYBak
        }
# --- read TrimB
        strpos(TrimSecApB,":")
        TrimBAStr = substr(TrimSecApB,2,strpos.pos-1)
        TrimBBStr = substr(TrimSecApB,strpos.pos+1,strlen(TrimSecApB)-1)
        print("sttrimaps: TrimBAStr = "//TrimBAStr)
        print("sttrimaps: TrimBBStr = "//TrimBBStr)
        if (LogLevel > 2){
          print("sttrimaps: TrimBAStr = "//TrimBAStr, >> LogFile)
          print("sttrimaps: TrimBBStr = "//TrimBBStr, >> LogFile)
        }
# --- read trimy
        strpos(TrimSecApY,":")
        TrimYAStr = substr(TrimSecApY,2,strpos.pos-1)
        TrimYBStr = substr(TrimSecApY,strpos.pos+1,strlen(TrimSecApY)-1)
        print("sttrimaps: TrimYAStr = "//TrimYAStr)
        print("sttrimaps: TrimYBStr = "//TrimYBStr)
        if (LogLevel > 2){
          print("sttrimaps: TrimYAStr = "//TrimYAStr, >> LogFile)
          print("sttrimaps: TrimYBStr = "//TrimYBStr, >> LogFile)
        }
        TrimBA = int(TrimBAStr)
        TrimBB = int(TrimBBStr)
        TrimYA = int(TrimYAStr)
        TrimYB = int(TrimYBStr)
        if (FirstGapBefore == 0){
          TrimA = TrimBA + ((TrimYA-TrimBA)*(NFile-2)/(NOrders-2))
          TrimB = TrimBB + ((TrimYB-TrimBB)*(NFile-2)/(NOrders-2))
        }
        else{
          if (NFile < FirstGapBefore){
            TrimA = TrimBA + ((TrimYA-TrimBA)*(NFile-2)/(FirstGapBefore-3))
            TrimB = TrimBB + ((TrimYB-TrimBB)*(NFile-2)/(FirstGapBefore-3))
          }
          else{
            TrimA = TrimBA + ((TrimYA-TrimBA)*(NFile-FirstGapBefore)/(NOrders-FirstGapBefore-1))
            TrimB = TrimBB + ((TrimYB-TrimBB)*(NFile-FirstGapBefore)/(NOrders-FirstGapBefore-1))
          }
        }
        TrimSec = "["//TrimA//":"//TrimB//"]"
      }# end else if (!(NFile == 1 || NFile == NOrders))
      print("sttrimaps: order "//NFile//": TrimSec = "//TrimSec)
      if (LogLevel > 2)
        print("sttrimaps: order "//NFile//": TrimSec = "//TrimSec, >> LogFile)

      ParamTemp = ApIn//TrimSec
      imcopy(input=ParamTemp,
             output=Out,
             ver-)

      if (!access(Out)){
        print("sttrimaps: ERROR: Outfile <"//Out//"> not accessable! => Returning")
        print("sttrimaps: ERROR: Outfile <"//Out//"> not accessable! => Returning", >> LogFile)
        print("sttrimaps: ERROR: Outfile <"//Out//"> not accessable! => Returning", >> WarningFile)
        print("sttrimaps: ERROR: Outfile <"//Out//"> not accessable! => Returning", >> ErrorFile)
# --- clean up
        delete (InFile, ver-, >& "dev$null")
        delete (TimeFile, ver-, >& "dev$null")
        delete (TempFileList, ver-, >& "dev$null")
        P_ImageList    = ""
        P_TimeList     = ""
        P_TempList     = ""
        P_TextFileList = ""
        return
      }
      else
        print("sttrimaps: "//Out//" ready")
      if (access(TimeFile))
        del(TimeFile, ver-)
      time(>> TimeFile)
      if (access(TimeFile)){
        P_TimeList = TimeFile
        if (fscan(P_TimeList,tempday,temptime,tempdate) != EOF){
          hedit(images=Out,
                fields="STTRIMAPS",
                value="sttrimaps: image trimmed "//tempdate//"T"//temptime,
                add+,
                addonly+,
                del-,
                ver-,
                show+,
                update+)
          hedit(images=Out,
                fields="STTRIMAPSSEC",
                value=TrimSec,
                add+,
                addonly+,
                del-,
                ver-,
                show+,
                update+)
        }# end if (fscan(P_TimeList,tempday,temptime,tempdate) != EOF){
      }# end if (access(TimeFile)){
      else{
        print("sttrimaps: WARNING: TimeFile <"//TimeFile//"> not accessable!")
        print("sttrimaps: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
        print("sttrimaps: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
      }
# --- read P_TempList
      if (fscan(P_TempList,TextFileName) == EOF){
        print("sttrimaps: ERROR: TextFileName <"//TextFileName//"> not found! => Returning!")
        print("sttrimaps: ERROR: TextFileName <"//TextFileName//"> not found! => Returning!", >> LogFile)
        print("sttrimaps: ERROR: TextFileName <"//TextFileName//"> not found! => Returning!", >> WarningFile)
        print("sttrimaps: ERROR: TextFileName <"//TextFileName//"> not found! => Returning!", >> ErrorFile)
# --- clean up
        delete (InFile, ver-, >& "dev$null")
        delete (TimeFile, ver-, >& "dev$null")
        delete (TempFileList, ver-, >& "dev$null")
        P_ImageList    = ""
        P_TimeList     = ""
        P_TempList     = ""
        P_TextFileList = ""
        return
      }
      print("sttrimaps: TextFileName = "//TextFileName)
      if (LogLevel > 2)
        print("sttrimaps: TextFileName = "//TextFileName, >> LogFile)
      if (!access(TextFileName)){
        print("sttrimaps: ERROR: TextFileName <"//TextFileName//"> not found! => Returning!")
        print("sttrimaps: ERROR: TextFileName <"//TextFileName//"> not found! => Returning!", >> LogFile)
        print("sttrimaps: ERROR: TextFileName <"//TextFileName//"> not found! => Returning!", >> WarningFile)
        print("sttrimaps: ERROR: TextFileName <"//TextFileName//"> not found! => Returning!", >> ErrorFile)
# --- clean up
        delete (InFile, ver-, >& "dev$null")
        delete (TimeFile, ver-, >& "dev$null")
        delete (TempFileList, ver-, >& "dev$null")
        P_ImageList    = ""
        P_TimeList     = ""
        P_TempList     = ""
        P_TextFileList = ""
        return
      }
# --- trim orders
      strlastpos(TextFileName,"_text")
      if (strlastpos.pos == 0)
        strlastpos(TextFileName, ".")
      TextFileNameT = substr(TextFileName,1,strlastpos.pos-1)//"t"//substr(TextFileName,strlastpos.pos,strlen(TextFileName))
      print("sttrimaps: Processing order no "//NFile//": TextFileName=<"//TextFileName//">, Output = TextFileNameT=<"//TextFileNameT//">")
      if (LogLevel > 2)
        print("sttrimaps: Processing order no "//NFile//": TextFileName=<"//TextFileName//">, Output = TextFileNameT=<"//TextFileNameT//">", >> LogFile)
      if (access(TextFileNameT))
        del(TextFileNameT, ver-)
      strpos(TrimSec,":")
      TrimBAStr = substr(TrimSec,2,strpos.pos-1)
      TrimBBStr = substr(TrimSec,strpos.pos+1,strlen(TrimSec)-1)
      print("sttrimaps: TrimBAStr = "//TrimBAStr)
      print("sttrimaps: TrimBBStr = "//TrimBBStr)
      if (LogLevel > 2){
        print("sttrimaps: TrimBAStr = "//TrimBAStr, >> LogFile)
        print("sttrimaps: TrimBBStr = "//TrimBBStr, >> LogFile)
      }
      TrimA = int(TrimBAStr)
      TrimB = int(TrimBBStr)
      print("sttrimaps: order "//NFile//": TrimSec = ["//TrimA//":"//TrimB//"]")
      if (LogLevel > 2)
        print("sttrimaps: order "//NFile//": TrimSec = ["//TrimA//":"//TrimB//"]", >> LogFile)

      jobs
      wait()
      tail(TextFileName, nlines=NPix-TrimA+1, >> TextFileName//"_temp")
      wait()
      head(TextFileName//"_temp", nlines=TrimB-TrimA+1, >> TextFileNameT)
      wait()

      print(TextFileNameT, >> TempTextFilesT)

      del(TextFileName//"_temp", ver-)
      print("sttrimaps: OutFile <"//TextFileName//"> ready")
      if (LogLevel > 2)
        print("sttrimaps: OutFile <"//TextFileName//"> ready", >> LogFile)
    }# end while(fscan(P_TextFileList, ApIn) != EOF){

  }# end while (fscan (P_ImageList, In) != EOF){

#  if (IsFileList)
#    Images = "@"//Images
# --- clean up
  delete (InFile, ver-, >& "dev$null")
  delete (TimeFile, ver-, >& "dev$null")
  delete (TempFileList, ver-, >& "dev$null")
  P_ImageList    = ""
  P_TimeList     = ""
  P_TempList     = ""
  P_TextFileList = ""
  return

end
