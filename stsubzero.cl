procedure stsubzero (Images)

##################################################################
#                                                                #
# NAME:             stsubzero.cl                                 #
# PURPOSE:          * subtracts the combined master bias from    #
#                     the spectral images in Images              #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stsubzero(Images)                            #
# INPUTS:           Images: String                               #
#                     name of list containing names of           #
#                     images subtract the master bias from:      #
#                       "non-zeros.list":                        #
#                         flat_01.fits                           #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     <Entry_in_Images_Root>z.<ImType>           #
#                   Log Files:                                   #
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      12.11.2001                                   #
# LAST EDITED:      18.04.2007                                   #
#                                                                #
##################################################################

string Images             = "@stsubzero.list"            {prompt="List of images to subtract Zero"}
bool   Objects            = YES                          {prompt="Are Images Objects? (YES|NO)"}
string ErrorImages        = "@stsubzero_e.list"          {prompt="List of error images"}
string CombinedZero       = "combinedZero_bot.fits"      {prompt="Combined Zero after stbadovertrim"}
string ZeroErrImage       = "combinedZero_sig_bot.fits"  {prompt="Combined-Zero Error image"}
string ParameterFile      = "scripts$parameterfile.prop" {prompt="Parameterfile"}
string ImType             = "fits"                       {prompt="Image Type"}
int    NumCCDs            = 1                            {prompt="Number of CCDs"}
string CCDSec            = "[*,*]"                      {prompt="CCD section for computing biaslevel"}
bool   SubtractBiasMean   = YES                          {prompt="Subtract mean of CombinedZero?"}
bool   ReadCor            = NO                           {prompt="!sub_mean: Convert zero level image to readout correction?"}
string ReadAxis           = "line"                       {prompt="ReadCor: Read out axis (line|column)",
                                                              enum="line|column"}
bool   DoErrors           = YES                          {prompt="Calculate error propagation? (YES | NO)"}
bool   DelInput           = NO                           {prompt="Delete input images after processing?"}
int    LogLevel           = 3                            {prompt="Level for writing LogFile"}
string LogFile            = "logfile_stsubzero.log"      {prompt="Name of log file"}
string WarningFile        = "warnings_stsubzero.log"     {prompt="Name of warning file"}
string ErrorFile          = "errors_stsubzero.log"       {prompt="Name of error file"}
int    Status             = 1
string *P_InputList
string *P_ErrorList
string *P_StatList
string *P_ParameterList
string *P_TimeList

begin
# --- define variables
  string LogFileImred,LogFileCcdred
  string StatsFile,TimeFile,CreErrList,ListName
  string tempdate,tempday,temptime
  real   BiasMean,BiasStdDev
  int    i,i_ccd
  file   InFile,ErrFile
  string In,Out,Image,ErrIn,ErrOut,ErrOutTemp,Parameter,ParameterValue,TempOut
  string LogFileStCreErr,WarningFileStCreErr,ErrorFileStCreErr
  bool   FoundSubtractBiasMean
  bool   FoundSubZeroReadCor
  bool   FoundReadAxis
  bool   FoundNumCCDs
  bool   FoundCCDSec
  bool   FoundImType
#  bool   Foundcalc_error_propagation

# --- init variables
  StatsFile = "combinedZero_statistics.text"
  TimeFile  = "time.txt"
  CreErrList = "stcreerr.list"
  LogFileStCreErr = "logfile_stcreerr.log"
  WarningFileStCreErr = "warningfile_stcreerr.log"
  ErrorFileStCreErr = "errorfile_stcreerr.log"
  FoundSubtractBiasMean       = NO
  FoundSubZeroReadCor         = NO
  FoundReadAxis               = NO
  FoundNumCCDs                = NO
  FoundImType                 = NO
#  Foundcalc_error_propagation  = NO

  Status = 1

# --- delete old LogFiles
  if (access(LogFile))
    delete(LogFile, ver-)
  if (access(WarningFile))
    delete(WarningFile, ver-)
  if (access(ErrorFile))
    delete(ErrorFile, ver-)

  LogFileImred = imred.logfile
  print ("stsubzero: LogFileImred = "//LogFileImred)
  imred.logfile = LogFile

  LogFileCcdred = ccdred.logfile
  print ("stsubzero: LogFileCcdred = "//LogFileCcdred)
  ccdred.logfile = LogFile

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*              subtracting combined Zero                 *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*              subtracting combined Zero                 *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)

# --- read number of CCDs
  if (access(ParameterFile)){

    P_ParameterList = ParameterFile

    print ("stsubzero: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("stsubzero: **************** reading ParameterFile *******************", >> LogFile)

    while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){

#      if (Parameter != "#")
#        print ("stsubzero: ParameterFile: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

      if (Parameter == "numccds"){
        NumCCDs = int(ParameterValue)
        print ("stsubzero: Setting "//Parameter//" to "//ParameterValue)
        if (LogLevel > 2)
          print ("stsubzero: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        FoundNumCCDs = YES
      }
      else if (Parameter == "imtype"){
        ImType = ParameterValue
        print ("stsubzero: Setting "//Parameter//" to "//ImType)
        if (LogLevel > 2)
          print ("stsubzero: Setting "//Parameter//" to "//ImType, >> LogFile)
        FoundImType = YES
      }
      else if (Parameter == "subtract_biasmean"){
        if (ParameterValue == "YES" || ParameterValue == "yes"){
          SubtractBiasMean = YES
          print ("stsubzero: Setting "//Parameter//" to YES")
          if(LogLevel > 2)
            print ("stsubzero: Setting "//Parameter//" to YES", >> LogFile)
        }
        else{
          SubtractBiasMean = NO
          print ("stsubzero: Setting "//Parameter//" to NO")
          if(LogLevel > 2)
            print ("stsubzero: Setting "//Parameter//" to NO", >> LogFile)
        }
        FoundSubtractBiasMean = YES
      }
      else if (Parameter == "subzero_readcor"){
        if (ParameterValue == "YES" || ParameterValue == "yes"){
          ReadCor = YES
          print ("stsubzero: Setting "//Parameter//" to YES")
          if(LogLevel > 2)
            print ("stsubzero: Setting "//Parameter//" to YES", >> LogFile)
        }
        else{
          ReadCor = NO
          print ("stsubzero: Setting "//Parameter//" to NO")
          if(LogLevel > 2)
            print ("stsubzero: Setting "//Parameter//" to NO", >> LogFile)
        }
        FoundSubZeroReadCor = YES
      }
      else if (Parameter == "readoutaxis"){
        ReadAxis = ParameterValue
        print ("stsubzero: Setting "//Parameter//" to "//ParameterValue)
        if(LogLevel > 2)
          print ("stsubzero: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        FoundReadAxis = YES
      }
#      else if (Parameter == "calc_error_propagation"){
#        if (ParameterValue == "YES" || ParameterValue == "yes"){
#          DoErrors = YES
#          print ("stsubzero: Setting DoErrors to YES")
#       }
#       else{
#         DoErrors = NO
#          print ("stsubzero: Setting DoErrors to NO")
#       }
#        if (LogLevel > 2)
#          print ("stsubzero: Setting DoErrors to "//ParameterValue, >> LogFile)
#        Foundcalc_error_propagation = YES
#      }
    }# --- end while(fscan P_ParameterList)
    if (!FoundNumCCDs){
      print("stsubzero: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1")
      print("stsubzero: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1", >> LogFile)
      print("stsubzero: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1", >> WarningFile)
      NumCCDs = 1
    }
    if (!FoundImType){
      print("stsubzero: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard")
      print("stsubzero: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stsubzero: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundSubtractBiasMean){
      print("stsubzero: WARNING: Parameter subtract_biasmean not found in ParameterFile!!! -> using standard")
      print("stsubzero: WARNING: Parameter subtract_biasmean not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stsubzero: WARNING: Parameter subtract_biasmean not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundSubZeroReadCor){
      print("stsubzero: WARNING: Parameter subzero_readcor not found in ParameterFile!!! -> using standard")
      print("stsubzero: WARNING: Parameter subzero_readcor not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stsubzero: WARNING: Parameter subzero_readcor not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundReadAxis){
      print("stsubzero: WARNING: Parameter readoutaxis not found in ParameterFile!!! -> using standard")
      print("stsubzero: WARNING: Parameter readoutaxis not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stsubzero: WARNING: Parameter readoutaxis not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
#    if (!Foundcalc_error_propagation){
#      print("stsubzero: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard")
#      print("stsubzero: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard", >> LogFile)
#      print("stsubzero: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard", >> WarningFile)
#    }
  } else{
    print("stsubzero: WARNING: Parameter file not found!!! -> using standard values")
    print("stsubzero: WARNING: Parameter file not found!!! -> using standard values", >> LogFile)
    print("stsubzero: WARNING: Parameter file not found!!! -> using standard values", >> WarningFile)
#    NumCCDs = 1
#    ImType = "fits"
  }

# --- Erzeugen von temporaeren Filenamen
  print("stsubzero: building temp-filenames")
  if (LogLevel > 2)
    print("stsubzero: building temp-filenames", >> LogFile)
  InFile  = mktemp ("tmp")
  ErrFile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stsubzero: building lists from temp-files")
  if (LogLevel > 1)
    print("stsubzero: building lists from temp-files", >> LogFile)

  if (substr(Images,1,1) == "@")
    ListName = substr(Images, 2, strlen(Images))
  else
    ListName = Images
  if (!access(ListName)){
    print("stsubzero: ERROR: "//ListName//" not found!!!")
    print("stsubzero: ERROR: "//ListName//" not found!!!", >> LogFile)
    print("stsubzero: ERROR: "//ListName//" not found!!!", >> ErrorFile)
    print("stsubzero: ERROR: "//ListName//" not found!!!", >> WarningFile)
# --- Clean Up
    imred.logfile = LogFileImred
    ccdred.logfile = LogFileCcdred

    P_InputList = ""
    P_ErrorList = ""
    P_ParameterList = ""
    P_StatList = ""
    P_TimeList = ""
    delete (InFile, ver-, >& "dev$null")
    delete (ErrFile, ver-, >& "dev$null")
    Status = 0
    return
  }
  sections(Images, option="root", > InFile)
  if (Objects && DoErrors){
    if (substr(ErrorImages,1,1) == "@")
      ListName = substr(ErrorImages,2,strlen(ErrorImages))
    else
      ListName = ErrorImages
    if (!access(ListName)){
      print("stsubzero: ERROR: "//ListName//" not found!!!")
      print("stsubzero: ERROR: "//ListName//" not found!!!", >> LogFile)
      print("stsubzero: ERROR: "//ListName//" not found!!!", >> ErrorFile)
      print("stsubzero: ERROR: "//ListName//" not found!!!", >> WarningFile)
# --- Clean Up
      imred.logfile = LogFileImred
      ccdred.logfile = LogFileCcdred

      P_InputList = ""
      P_ErrorList = ""
      P_ParameterList = ""
      P_StatList = ""
      P_TimeList = ""
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      Status = 0
      return
    }
    sections(ErrorImages, option="root", > ErrFile)
  }#end if (Objects && DoErrors)

  P_InputList = InFile
  if (Objects && DoErrors)
    P_ErrorList = ErrFile
  while (fscan (P_InputList, In) != EOF){

    print("stsubzero: In = "//In)
    if (LogLevel > 1)
      print("stsubzero: In = "//In, >> LogFile)

    i = strlen(In)
    if (substr (In, i-strlen(ImType), i) != "."//ImType)
      In = In//"."//ImType
    if (!access(In)){
      print("stsubzero: ERROR: cannot access In <"//In//">!")
      print("stsubzero: ERROR: cannot access In <"//In//">!", >> LogFile)
      print("stsubzero: ERROR: cannot access In <"//In//">!", >> ErrorFile)
      print("stsubzero: ERROR: cannot access In <"//In//">!", >> WarningFile)
# --- Clean Up
      imred.logfile = LogFileImred
      ccdred.logfile = LogFileCcdred
      P_InputList = ""
      P_ParameterList = ""
      P_StatList = ""
      P_TimeList = ""
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      Status = 0
      return
    }
    Out = substr(In, 1, i-strlen(ImType)-1)//"z."//ImType
    TempOut = substr(In, 1, i-strlen(ImType)-1)//"z_temp."//ImType

    if (access(Out)){
      imdel(Out, ver-)
      if (access(Out))
        del(Out,ver-)
      if (!access(Out)){
        print("stsubzero: old "//Out//" deleted")
        if (LogLevel > 2)
          print("stsubzero: old "//Out//" deleted", >> LogFile)
      }
      else{
        print("stsubzero: ERROR: cannot delete "//Out)
        print("stsubzero: ERROR: cannot delete "//Out, >> LogFile)
        print("stsubzero: ERROR: cannot delete "//Out, >> WarningFile)
        print("stsubzero: ERROR: cannot delete "//Out, >> ErrorFile)
# --- Clean Up
        imred.logfile = LogFileImred
        ccdred.logfile = LogFileCcdred
        P_InputList = ""
        P_ParameterList = ""
        P_StatList = ""
        P_TimeList = ""
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        Status = 0
        return
      }
    }
#    if (NumCCDs > 1){
      imcopy(input = In,
              output = Out,
              verbose-)
#    }
    if (Objects && DoErrors){
      if (fscan (P_ErrorList, ErrIn) == EOF){
        print("stsubzero: ERROR: fscan("//ErrorImages//", ErrIn) returned EOF!")
        print("stsubzero: ERROR: fscan("//ErrorImages//", ErrIn) returned EOF!", >> LogFile)
        print("stsubzero: ERROR: fscan("//ErrorImages//", ErrIn) returned EOF!", >> WarningFile)
        print("stsubzero: ERROR: fscan("//ErrorImages//", ErrIn) returned EOF!", >> ErrorFile)
# --- Clean Up
        imred.logfile = LogFileImred
        ccdred.logfile = LogFileCcdred
        P_InputList = ""
        P_ParameterList = ""
        P_StatList = ""
        P_TimeList = ""
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        Status = 0
        return
      }

      print("stsubzero: ErrIn = "//ErrIn)
      if (LogLevel > 1)
        print("stsubzero: ErrIn = "//ErrIn, >> LogFile)
      i = strlen(ErrIn)
      if (substr (ErrIn, i-strlen(ImType), i) != "."//ImType)
        ErrIn = ErrIn//"."//ImType
      ErrOutTemp = substr(ErrIn, 1, i-strlen(ImType)-1)//"z_temp."//ImType
      ErrOut = substr(ErrIn, 1, i-strlen(ImType)-1)//"z."//ImType
      if (access(ErrOut))
        imdel(ErrOut, ver-)
      if (access(ErrOut)){
        del(ErrOut,ver-)
        if (!access(ErrOut)){
          print("stsubzero: old "//ErrOut//" deleted")
          if (LogLevel > 2)
            print("stsubzero: old "//ErrOut//" deleted", >> LogFile)
        }
        else{
          print("stsubzero: ERROR: cannot delete "//ErrOut)
          print("stsubzero: ERROR: cannot delete "//ErrOut, >> LogFile)
          print("stsubzero: ERROR: cannot delete "//ErrOut, >> WarningFile)
          print("stsubzero: ERROR: cannot delete "//ErrOut, >> ErrorFile)
# --- Clean Up
          imred.logfile = LogFileImred
          ccdred.logfile = LogFileCcdred
          P_InputList = ""
          P_ParameterList = ""
          P_StatList = ""
          P_TimeList = ""
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          Status = 0
          return
        }
      }
      if (NumCCDs > 1){
        imcopy(input = ErrIn,
                output = ErrOut,
                verbose-)
      }
    }#end if (Objects && DoErrors)

    for (i_ccd = 1; i_ccd <= NumCCDs; i_ccd += 1){

  # --- read ParameterFile
      if (access(ParameterFile)){

        FoundCCDSec  = NO

        P_ParameterList = ParameterFile

        print ("stsubzero: **************** reading ParameterFile *******************")
        if (LogLevel > 2)
          print ("stsubzero: **************** reading ParameterFile *******************", >> LogFile)

        while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){

    #      if (Parameter != "#")
    #        print ("stsubzero: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

          if (Parameter == "ccdsec_trimmed_ccd"//i_ccd){
            CCDSec = ParameterValue
            print ("stsubzero: Setting "//Parameter//" to "//ParameterValue)
            if (LogLevel > 2)
              print ("stsubzero: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
            FoundCCDSec = YES
          }
        }# --- end while
        if (!FoundCCDSec){
          print("stsubzero: WARNING: Parameter ccdsec_trimmed_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
          print("stsubzero: WARNING: Parameter ccdsec_trimmed_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
          print("stsubzero: WARNING: Parameter ccdsec_trimmed_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
        }
      }
      else{
        print("stsubzero: WARNING: ParameterFile not found!!! -> using standard parameters")
        print("stsubzero: WARNING: ParameterFile not found!!! -> using standard parameters", >> LogFile)
        print("stsubzero: WARNING: ParameterFile not found!!! -> using standard parameters", >> WarningFile)
      }

      if (SubtractBiasMean){
    # --- view image statistics
        print("stsubzero: ***************** image statistics of combined Zero ******************")
        if (LogLevel > 2)
          print("stsubzero: ***************** image statistics of combined Zero ******************", >> LogFile)
      # --- delete old StatsFile
        print("stsubzero: search for old StatsFile")
        if (LogLevel > 2)
          print("stsubzero: search for old StatsFile", >> LogFile)
        if (access(StatsFile)){
          delete (StatsFile, ver-, >& "dev$null")
          print("stsubzero: old StatsFile deleted!")
          if (LogLevel > 2)
            print("stsubzero: old StatsFile deleted!", >> LogFile)
        }
      # --- imstat
        print("stsubzero: starting imstat")
        if (LogLevel > 2)
          print("stsubzero: starting imstat", >> LogFile)
        if (!access(CombinedZero)){
          print("stsubzero: ERROR: file "//CombinedZero//" not found!")
          print("stsubzero: ERROR: file "//CombinedZero//" not found!", >> LogFile)
          print("stsubzero: ERROR: file "//CombinedZero//" not found!", >> WarningFile)
          print("stsubzero: ERROR: file "//CombinedZero//" not found!", >> ErrorFile)
      # --- Clean Up
          imred.logfile = LogFileImred
          ccdred.logfile = LogFileCcdred
          P_InputList = ""
          P_ParameterList = ""
          P_StatList = ""
          P_TimeList = ""
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          Status = 0
          return
        }
        print("stsubzero: CombinedZero = "//CombinedZero)
        if (LogLevel > 2)
          print("stsubzero: CombinedZero = "//CombinedZero, >> LogFile)
        imstat(CombinedZero//CCDSec,
              format-,
              fields="image,mean,stddev",
              lower=INDEF,
              upper=INDEF,
              binwidt=0.1, >> StatsFile)
      # --- Ausgabe
        P_StatList = StatsFile
        while (fscan (P_StatList, Image, BiasMean, BiasStdDev) != EOF){
          print("stsubzero: "//Image//": BiasMean = "//BiasMean//", BiasStdDev = "//BiasStdDev)
          if (LogLevel > 2)
            print("stsubzero: "//Image//": BiasMean = "//BiasMean//", BiasStdDev = "//BiasStdDev, >> LogFile)
        }
      }#end if (SubtractBiasMean)

    # --- build Output filenames and subtract overscan
      print("stsubzero: ******************* processing files *********************")
      if (LogLevel > 2)
        print("stsubzero: ******************* processing files *********************", >> LogFile)

      print("stsubzero: processing CCD Number "//i_ccd//": "//In//", outfile = "//Out)
      if (LogLevel > 1)
        print("stsubzero: processing CCD Number "//i_ccd//": "//In//", outfile = "//Out, >> LogFile)

      if (access(TempOut)){
        imdel(TempOut, ver-)
        if (access(TempOut))
          del(TempOut,ver-)
        if (!access(TempOut)){
          print("stsubzero: old "//TempOut//" deleted")
          if (LogLevel > 2)
            print("stsubzero: old "//TempOut//" deleted", >> LogFile)
        }
        else{
          print("stsubzero: ERROR: cannot delete "//TempOut)
          print("stsubzero: ERROR: cannot delete "//TempOut, >> LogFile)
          print("stsubzero: ERROR: cannot delete "//TempOut, >> WarningFile)
          print("stsubzero: ERROR: cannot delete "//TempOut, >> ErrorFile)
  # --- Clean Up
          imred.logfile = LogFileImred
          ccdred.logfile = LogFileCcdred
          P_InputList = ""
          P_ParameterList = ""
          P_StatList = ""
          P_TimeList = ""
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          Status = 0
          return
        }
      }
      if (Objects && DoErrors){
        if (access(ErrOutTemp))
          imdel(ErrOutTemp, ver-)
        if (access(ErrOutTemp)){
            del(ErrOutTemp,ver-)
          if (!access(ErrOutTemp)){
            print("stsubzero: old "//ErrOutTemp//" deleted")
            if (LogLevel > 2)
              print("stsubzero: old "//ErrOutTemp//" deleted", >> LogFile)
          }
          else{
            print("stsubzero: ERROR: cannot delete "//ErrOutTemp)
            print("stsubzero: ERROR: cannot delete "//ErrOutTemp, >> LogFile)
            print("stsubzero: ERROR: cannot delete "//ErrOutTemp, >> WarningFile)
            print("stsubzero: ERROR: cannot delete "//ErrOutTemp, >> ErrorFile)
  # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }
        }
      }# --- end if (Objects && DoErrors)
      if (!SubtractBiasMean){
        ccdproc(images=In//CCDSec,
                output=TempOut,
                ccdtype="",
                max_cache=0,
                noproc-,
                fixpix-,
                overscan-,
                trim-,
                zerocor+,
                darkcor-,
                flatcor-,
                illumco-,
                fringec-,
                readcor=ReadCor,
                scancor-,
                zero=CombinedZero//CCDSec,
                readaxis=ReadAxis,
                minrepl=1.,
                scantyp="shortscan",
                nscan=1)
        imcopy(input = TempOut,
               output = Out//CCDSec,
               verbose+)
        del(TempOut, ver-)
        if (Objects && DoErrors && (i_ccd == 1)){
          print("stsubzero: DoErrors")
          if (LogLevel > 2)
            print("stsubzero: DoErrors", >> LogFile)
          if (!access(ErrIn)){
            print("stsubzero: ERROR: cannot access ErrIn = "//ErrIn)
            print("stsubzero: ERROR: cannot access ErrIn = "//ErrIn, >> LogFile)
            print("stsubzero: ERROR: cannot access ErrIn = "//ErrIn, >> ErrorFile)
            print("stsubzero: ERROR: cannot access ErrIn = "//ErrIn, >> WarningFile)
  # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }
          if (!access(ZeroErrImage)){
            print("stsubzero: ERROR: cannot access ZeroErrImage = "//ZeroErrImage)
            print("stsubzero: ERROR: cannot access ZeroErrImage = "//ZeroErrImage, >> LogFile)
            print("stsubzero: ERROR: cannot access ZeroErrImage = "//ZeroErrImage, >> ErrorFile)
            print("stsubzero: ERROR: cannot access ZeroErrImage = "//ZeroErrImage, >> WarningFile)
  # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }

          imarith(operand1=ErrIn,
                  op="+",
                  operand2=ZeroErrImage,
                  result=ErrOutTemp,
                  title="",
                  hparams="",
                  pixtype="real",
                  calctype="real",
                  ver-,
                  noact-)
          if (!access(ErrOutTemp)){
            print("stsubzero: ERROR: cannot access ErrOutTemp = "//ErrOutTemp)
            print("stsubzero: ERROR: cannot access ErrOutTemp = "//ErrOutTemp, >> LogFile)
            print("stsubzero: ERROR: cannot access ErrOutTemp = "//ErrOutTemp, >> ErrorFile)
            print("stsubzero: ERROR: cannot access ErrOutTemp = "//ErrOutTemp, >> WarningFile)
  # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }
          print("stsubzero: ErrOutTemp <"//ErrOutTemp//"> ready")
          if (LogLevel > 2)
            print("stsubzero: ErrOutTemp <"//ErrOutTemp//"> ready", >> LogFile)
        }# --- end if (Objects && DoErrors && (i_ccd == 1))
      }# --- end if (!SubtractBiasMean)
      else{
        del(TempOut, ver-)
  # --- subtract mean of CombinedZero
        imarith(operand1=In//CCDSec,
                op="-",
                operand2=real(BiasMean),
                result=TempOut,
                title="",
                hparams="",
                pixtype="real",
                calctype="real",
                ver-,
                noact-)
        imcopy(input = TempOut,
               output = Out//CCDSec,
               verbose+)
        del(TempOut, ver-)
        if (Objects && DoErrors){
          print("stsubzero: DoErrors")
          if (LogLevel > 2)
            print("stsubzero: DoErrors", >> LogFile)
          if (!access(ErrIn)){
            print("stsubzero: ERROR: cannot access ErrIn = "//ErrIn)
            print("stsubzero: ERROR: cannot access ErrIn = "//ErrIn, >> LogFile)
            print("stsubzero: ERROR: cannot access ErrIn = "//ErrIn, >> ErrorFile)
            print("stsubzero: ERROR: cannot access ErrIn = "//ErrIn, >> WarningFile)
  # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }

          if (!access(ZeroErrImage)){
            print("stsubzero: ERROR: cannot access ZeroErrImage = "//ZeroErrImage)
            print("stsubzero: ERROR: cannot access ZeroErrImage = "//ZeroErrImage, >> LogFile)
            print("stsubzero: ERROR: cannot access ZeroErrImage = "//ZeroErrImage, >> ErrorFile)
            print("stsubzero: ERROR: cannot access ZeroErrImage = "//ZeroErrImage, >> WarningFile)
  # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }
          imarith(operand1=ErrIn//CCDSec,
                  op="+",
                  operand2=real(BiasStdDev),
                  result=ErrOutTemp,
                  title="",
                  hparams="",
                  pixtype="real",
                  calctype="real",
                  ver-,
                  noact-)
          if (!access(ErrOutTemp)){
            print("stsubzero: ERROR: cannot access ErrOutTemp = "//ErrOutTemp)
            print("stsubzero: ERROR: cannot access ErrOutTemp = "//ErrOutTemp, >> LogFile)
            print("stsubzero: ERROR: cannot access ErrOutTemp = "//ErrOutTemp, >> ErrorFile)
            print("stsubzero: ERROR: cannot access ErrOutTemp = "//ErrOutTemp, >> WarningFile)
  # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }
          print("stsubzero: ErrOutTemp <"//ErrOutTemp//"> ready")
          if (LogLevel > 2)
            print("stsubzero: ErrOutTemp <"//ErrOutTemp//"> ready", >> LogFile)
        }# --- end if (Objects && DoErrors)
      }
      if (i_ccd == NumCCDs){
        if (!access(Out)){
          print("stsubzero: ERROR: cannot access Out <"//Out//">!")
          print("stsubzero: ERROR: cannot access Out <"//Out//">!", >> LogFile)
          print("stsubzero: ERROR: cannot access Out <"//Out//">!", >> WarningFile)
          print("stsubzero: ERROR: cannot access Out <"//Out//">!", >> ErrorFile)
    # --- Clean Up
          imred.logfile = LogFileImred
          ccdred.logfile = LogFileCcdred
          P_InputList = ""
          P_ParameterList = ""
          P_StatList = ""
          P_TimeList = ""
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          Status = 0
          return
        }
        if (DelInput)
          imdel(In, ver-)
        if (DelInput && access(In))
          del(In, ver-)

        if (access(TimeFile))
          del(TimeFile, ver-)
        time(>> TimeFile)
        if (access(TimeFile)){
          P_TimeList = TimeFile
          if (fscan(P_TimeList,tempday,temptime,tempdate) != EOF){
            hedit(images=Out,
                  fields="STSUBZER",
                  value=CombinedZero//" subtracted "//tempdate//"T"//temptime,
                  add+,
                  addonly-,
                  del-,
                  ver-,
                  show+,
                  update+)
          }
        }
        else{
          print("stsubzero: WARNING: TimeFile <"//TimeFile//"> not accessable!")
          print("stsubzero: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
          print("stsubzero: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
        }

        print("stsubzero: "//Out//" ready")
        if (LogLevel > 1)
          print("stsubzero: "//Out//" ready", >> LogFile)
    # --- DoErrors
    #  -- create error estimation file
        if (Objects && DoErrors){
          if (access(CreErrList))
            del(CreErrList, ver-)
          print(Out, >> CreErrList)
          if (!access(CreErrList)){
    # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }
          stcreerr(Images="@"//CreErrList,
                  ParameterFile=ParameterFile,
                  LogLevel=LogLevel,
                  LogFile=LogFileStCreErr,
                  WarningFile=WarningFileStCreErr,
                  ErrorFile=ErrorFileStCreErr)
          if (access(LogFileStCreErr))
            cat(LogFileStCreErr, >> LogFile)
          if (access(WarningFileStCreErr))
            cat(WarningFileStCreErr, >> WarningFile)
          if (access(ErrorFileStCreErr))
            cat(ErrorFileStCreErr, >> ErrorFile)
          if (stcreerr.Status == 0){
            print("stsubzero: ERROR: stcreerr returned FALSE => returning")
            print("stsubzero: ERROR: stcreerr returned FALSE => returning", >> LogFile)
            print("stsubzero: ERROR: stcreerr returned FALSE => returning", >> WarningFile)
            print("stsubzero: ERROR: stcreerr returned FALSE => returning", >> ErrorFile)
    # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }
    #  -- add error estimation file to ErrOutTemp
          ErrIn = substr(Out, 1, strlen(Out)-strlen(ImType)-1)//"_e."//ImType
          if (!access(ErrIn)){
            print("stsubzero: ERROR: cannot access ErrIn <"//ErrIn//">!")
            print("stsubzero: ERROR: cannot access ErrIn <"//ErrIn//">!", >> LogFile)
            print("stsubzero: ERROR: cannot access ErrIn <"//ErrIn//">!", >> WarningFile)
            prInt("stsubzero: ERROR: cannot access ErrIn <"//errin//">!", >> ErrorFile)
    # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }
          imarith(operand1=ErrIn,
                  op="+",
                  operand2=ErrOutTemp,
                  result=ErrOut,
                  title="",
                  divzero=0.,
                  hparams="",
                  pixtype="real",
                  calctype="real",
                  ver-,
                  noact-)
          if (!access(ErrOut)){
            print("stsubzero: ERROR: cannot access ErrOut <"//ErrOut//">!")
            print("stsubzero: ERROR: cannot access ErrOut <"//ErrOut//">!", >> LogFile)
            print("stsubzero: ERROR: cannot access ErrOut <"//ErrOut//">!", >> WarningFile)
            print("stsubzero: ERROR: cannot access ErrOut <"//ErrOut//">!", >> ErrorFile)
    # --- Clean Up
            imred.logfile = LogFileImred
            ccdred.logfile = LogFileCcdred
            P_InputList = ""
            P_ParameterList = ""
            P_StatList = ""
            P_TimeList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (ErrFile, ver-, >& "dev$null")
            Status = 0
            return
          }
          print("stsubzero: ErrOut <"//ErrOut//"> ready")
          if (LogLevel > 2)
            print("stsubzero: ErrOut <"//ErrOut//"> ready", >> LogFile)
          del(ErrOutTemp, ver-)
          del(ErrIn, ver-)
        }
        print("stsubzero: -----------------------")
        print("stsubzero: -----------------------", >> LogFile)
      }# --- end if(i_ccd == NumCCDs)
    }# --- end for each CCD
  }# --- end of while(scan(P_InputList))

  if (access(TimeFile))
    del(TimeFile, ver-)
  time(>> TimeFile)
  if (access(TimeFile)){
    P_TimeList = TimeFile
    if (fscan(P_TimeList,tempday,temptime,tempdate) != EOF){
      print("stsubzero: stsubzero finished "//tempdate//"T"//temptime, >> LogFile)
    }
  }
  else{
    print("stsubzero: WARNING: TimeFile <"//TimeFile//"> not accessable!")
    print("stsubzero: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
    print("stsubzero: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
  }

# --- Clean Up
  imred.logfile = LogFileImred
  ccdred.logfile = LogFileCcdred
  P_InputList = ""
  P_ParameterList = ""
  P_StatList = ""
  P_TimeList = ""
  delete (InFile, ver-, >& "dev$null")
  delete (ErrFile, ver-, >& "dev$null")

end
