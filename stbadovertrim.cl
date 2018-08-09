procedure stbadovertrim (Images)
#,badpixelfile,biassec,trimsec,high_rej,low_rej,high_rej_flat)


##################################################################
#                                                                #
# NAME:             stbadovertrim                                #
# PURPOSE:          * rejects bad pixels, subtracts overscan and #
#                     trims the input images automatically       #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stbadovertrim(Images)                        #
# INPUTS:           images:                                      #
#                     either: name of single image:              #
#                               "HD175640.fits"                  #
#                     or: name of list containing names of       #
#                         images to trace:                       #
#                           "objects.list":                      #
#                             HD175640.fits                      #
#                             ...                                #
#                                                                #
# OUTPUTS:          output: -                                    #
#                   outfile: <name_of_infile_root>_bot.<ImType>  #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      12.11.2001                                   #
# LAST EDITED:      06.04.2007                                   #
#                                                                #
##################################################################

string Images        = "@badovertrim.list"                   {prompt="list of input images"}
bool   Objects       = YES                                   {prompt="Are input images Objects? (YES|NO)"}
bool   Bias          = NO                                    {prompt="Is input image combinedZero? (YES|NO)"}
string BiasErrImage  = "combinedZero_sig.fits"               {prompt="Name of Bias error image"}
string BadPixFile    = "scripts$fixpix_red_l_2148x2048.mask" {prompt="File containing the list of bad pixels"}
string ParameterFile = "scripts$parameterfile.prop"          {prompt="Parameter file"}
bool   SubtractOverscan = NO                                    {prompt="Subtract overscan? (YES|NO)"}
string ReadAxis      = "line"       {prompt="Read out axis (line|column)",
                                      enum="line|column"}
int    NumCCDs       = 1            {prompt="Number of CCDs"}
string BiasSec       = "[2110:2147,*]"     {prompt="Overscan strip image section"}
string CCDSec        = "[*,*]"      {prompt="CCD section"}
string TrimSec       = "[51:2098,10:1950]" {prompt="Trim data section"}
bool   Interactive   = NO           {prompt="Run task interactively?"}
string Function      = "chebyshev"  {prompt="Overscan fitting function",
                                      enum="legendre|chebyshev|spline1|spline3"}
int    Order         = 1            {prompt="Number of polynomial terms or spline pieces"}
string Sample        = "*"          {prompt="Sample points to fit"}
int    NAverage      = 1            {prompt="Number of sample points to combine"}
int    NIterate      = 5            {prompt="Number of rejection iterations"}
real   LowReject     = 5.           {prompt="Low sigma rejection factor"}
real   HighReject    = 0.4          {prompt="High sigma rejection factor non flats"}
real   HighRejectFlat = 0.01        {prompt="High sigma rejection factor flats"}
real   Grow          = 0.           {prompt="Rejection growing radius"}
string ImType        = "fits"       {prompt="Image type"}
bool   DoErrors      = YES          {prompt="Calculate error propagation? (YES | NO)"}
int    LogLevel      = 3            {prompt="Level for writing log file"}
string LogFile       = "logfile_stbadovertrim.log"  {prompt="Name of log file"}
string WarningFile   = "warnings_stbadovertrim.log" {prompt="Name of warning file"}
string ErrorFile     = "errors_stbadovertrim.log"   {prompt="Name of error file"}
int    Status        = 1
string *P_ImageList
string *P_StatList
string *P_ParameterList
string *P_TimeList

begin

  file   InFile
  string ccdred_LogFile,Image,Images_root,TempIn,TempOut,CCD_TempOut_b,CCD_TempOut_o,CCD_TempOut_t
  file   StatsFile
  string In,ErrIn,CCD_Out_b,CCD_Out_o,CCD_Out_t,ErrOut_b,ErrOut_o,ErrOut_t,Parameter,ParameterValue
  string TimeFile = "time.text"
  string LogFile_stsetmaskval="logfile_stsetmaskval.log"
  string WarningFile_stsetmaskval="warningfile_stsetmaskval.log"
  string ErrorFile_stsetmaskval="errorfile_stsetmaskval.log"
  string tempdate,tempday,temptime
  int    i,i_ccd,ImTypeLength,Length
  real   HighRejectTake,BadPixVal,BiasMean,BiasStdDev
  bool   Foundreadoutaxis                = NO
  bool   FoundBOTSubtractOverscan        = YES
  bool   FoundBOTBadPixFile              = NO
  bool   FoundBOTOverscan_Function       = NO
  bool   FoundNumber_of_CCDs             = NO
  bool   FoundCCDSec                     = NO
  bool   FoundBOTBiasSec                 = NO
  bool   FoundBOTTrimSec                 = NO
  bool   FoundBOTOverscan_Interactive    = NO
  bool   FoundBOTOverscan_Order          = NO
  bool   FoundBOTOverscan_Sample         = NO
  bool   FoundBOTOverscan_NAverage       = NO
  bool   FoundBOTOverscan_NIterate       = NO
  bool   FoundBOTOverscan_LowReject      = NO
  bool   FoundBOTOverscan_HighReject     = NO
  bool   FoundBOTOverscan_HighRejectFlat = NO
  bool   FoundBOTOverscan_Grow           = NO
  bool   FoundImType                     = NO

  Status = 1

# --- delete old LogFiles
  if (access(LogFile))
    delete(LogFile, ver-)
  if (access(WarningFile))
    delete(WarningFile, ver-)
  if (access(ErrorFile))
    delete(ErrorFile, ver-)

  ccdred_LogFile = ccdred.logfile
  print ("stbadovertrim: ccdred_LogFile = "//ccdred_LogFile)
  ccdred.logfile = LogFile

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*    substracting bad pixels and overscan and triming    *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*    substracting bad pixels and overscan and triming    *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)

  InFile    = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stbadovertrim: building lists from temp-files")
  if (LogLevel > 2)
    print("stbadovertrim: building lists from temp-files", >> LogFile)

  if (substr(Images,1,1) == "@")
    Images_root = substr(Images,2,strlen(Images))
  else
    Images_root = Images
  if (access(Images_root)){
    sections(Images, option="root", > InFile)
    P_ImageList = InFile
  }
  else{
    print("stbadovertrim: ERROR: "//Images_root//" not found!!!")
    print("stbadovertrim: ERROR: "//Images_root//" not found!!!", >> LogFile)
    print("stbadovertrim: ERROR: "//Images_root//" not found!!!", >> ErrorFile)
    print("stbadovertrim: ERROR: "//Images_root//" not found!!!", >> WarningFile)
#  --- clean up
    ccdred.logfile  = ccdred_LogFile
    P_TimeList      = ""
    P_StatList      = ""
    P_ParameterList = ""
    P_ImageList     = ""
    delete (InFile, ver-, >& "dev$null")
    delete (StatsFile, ver-, >& "dev$null")
    Status = 0
    return
  }

# --- read ParameterFile

# --- read number of CCDs
  if (access(ParameterFile)){

    P_ParameterList = ParameterFile

    print ("stbadovertrim: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("stbadovertrim: **************** reading ParameterFile *******************", >> LogFile)

    while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){

#      if (Parameter != "#")
#        print ("stbadovertrim: ParameterFile: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

      if (Parameter == "numccds"){
        NumCCDs = int(ParameterValue)
        print ("stbadovertrim: Setting "//Parameter//" to "//ParameterValue)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        FoundNumber_of_CCDs = YES
      }
      else if (Parameter == "imtype"){
        ImType = ParameterValue
        print ("stbadovertrim: Setting "//Parameter//" to "//ImType)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//ImType, >> LogFile)
        FoundImType = YES
      }
      else if (Parameter == "bot_badpixelfile"){
        BadPixFile = ParameterValue
        print ("stbadovertrim: Setting "//Parameter//" to "//ParameterValue)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        FoundBOTBadPixFile = YES
      }
      else if (Parameter == "bot_trimsec"){
        TrimSec = ParameterValue
        print ("stbadovertrim: Setting "//Parameter//" to "//TrimSec)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//TrimSec, >> LogFile)
        FoundBOTTrimSec = YES
      }
      else if (Parameter == "bot_subtract_overscan"){
        if (ParameterValue == "YES" || ParameterValue == "yes"){
          SubtractOverscan = YES
          print ("stbadovertrim: Setting SubtractOverscan to YES")
        }
        else{
          SubtractOverscan = NO
          print ("stbadovertrim: Setting SubtractOverscan to NO")
        }
        if (LogLevel > 2)
          print ("stbadovertrim: Setting SubtractOverscan to "//ParameterValue, >> LogFile)
        FoundBOTSubtractOverscan = YES
      }
      else if (Parameter == "bot_overscan_interactive"){
        if (ParameterValue == "YES" || ParameterValue == "yes"){
          Interactive = YES
          print ("stbadovertrim: Setting Interactive to YES")
        }
        else{
          Interactive = NO
          print ("stbadovertrim: Setting Interactive to NO")
        }
        if (LogLevel > 2)
          print ("stbadovertrim: Setting Interactive to "//ParameterValue, >> LogFile)
        FoundBOTOverscan_Interactive = YES
      }
      else if (Parameter == "bot_overscan_function"){
        Function = ParameterValue
        print ("stbadovertrim: Setting "//Parameter//" to "//Function)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//Function, >> LogFile)
        FoundBOTOverscan_Function = YES
      }
      else if (Parameter == "bot_overscan_order"){
        Order = real(ParameterValue)
        print ("stbadovertrim: Setting Order to "//Order)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting Order to "//Order, >> LogFile)
        FoundBOTOverscan_Order = YES
      }
      else if (Parameter == "bot_overscan_sample"){
        Sample = ParameterValue
        print ("stbadovertrim: Setting "//Parameter//" to "//Sample)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//Sample, >> LogFile)
        FoundBOTOverscan_Sample = YES
      }
      else if (Parameter == "readoutaxis"){
        ReadAxis = ParameterValue
        print ("stbadovertrim: Setting "//Parameter//" to "//ReadAxis)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//ReadAxis, >> LogFile)
        Foundreadoutaxis = YES
      }
      else if (Parameter == "bot_overscan_naverage"){
        NAverage = real(ParameterValue)
        print ("stbadovertrim: Setting "//Parameter//" to "//NAverage)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//NAverage, >> LogFile)
        FoundBOTOverscan_NAverage = YES
      }
      else if (Parameter == "bot_overscan_niterate"){
        NIterate = real(ParameterValue)
        print ("stbadovertrim: Setting "//Parameter//" to "//NIterate)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//NIterate, >> LogFile)
        FoundBOTOverscan_NIterate = YES
      }
      else if (Parameter == "bot_overscan_low_rej"){
        if (ParameterValue == "INDEF")
          LowReject = INDEF
        else
          LowReject = real(ParameterValue)
        print ("stbadovertrim: Setting "//Parameter//" to "//LowReject)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//LowReject, >> LogFile)
        FoundBOTOverscan_LowReject = YES
      }
      else if (Parameter == "bot_overscan_high_rej"){
        if (ParameterValue == "INDEF")
          HighReject = INDEF
        else
          HighReject = real(ParameterValue)
        print ("stbadovertrim: Setting "//Parameter//" to "//HighReject)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//HighReject, >> LogFile)
        FoundBOTOverscan_HighReject = YES
      }
      else if (Parameter == "bot_overscan_high_rej_flat"){
        if (ParameterValue == "INDEF")
          HighRejectFlat = INDEF
        else
          HighRejectFlat = real(ParameterValue)
        print ("stbadovertrim: Setting "//Parameter//" to "//HighRejectFlat)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//HighRejectFlat, >> LogFile)
        FoundBOTOverscan_HighRejectFlat = YES
      }
      else if (Parameter == "bot_overscan_grow"){
        Grow = real(ParameterValue)
        print ("stbadovertrim: Setting "//Parameter//" to "//Grow)
        if (LogLevel > 2)
          print ("stbadovertrim: Setting "//Parameter//" to "//Grow, >> LogFile)
        FoundBOTOverscan_Grow = YES
      }
#      else if (Parameter == "calc_error_propagation"){
#        if (ParameterValue == "YES" || ParameterValue == "yes"){
#          DoErrors = YES
#          print ("stbadovertrim: Setting DoErrors to YES")
#   }
#   else{
#     DoErrors = NO
#          print ("stbadovertrim: Setting DoErrors to NO")
#   }
#        if (LogLevel > 2)
#          print ("stbadovertrim: Setting DoErrors to "//ParameterValue, >> LogFile)
#        Foundcalc_error_propagation = YES
#      }
    }# --- end while(fscan P_ParameterList)
    if (!FoundNumber_of_CCDs){
      print("stbadovertrim: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1")
      print("stbadovertrim: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1", >> LogFile)
      print("stbadovertrim: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1", >> WarningFile)
      NumCCDs = 1
    }
    if (!FoundImType){
      print("stbadovertrim: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTSubtractOverscan){
      print("stbadovertrim: WARNING: Parameter bot_subtract_overscan not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_subtract_overscan not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_subtract_overscan not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTOverscan_HighReject){
      print("stbadovertrim: WARNING: Parameter bot_overscan_high_rej not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_overscan_high_rej not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_overscan_high_rej not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTOverscan_HighRejectFlat){
      print("stbadovertrim: WARNING: Parameter bot_overscan_high_rej_flat not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_overscan_high_rej_flat not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_overscan_high_rej_flat not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTOverscan_LowReject){
      print("stbadovertrim: WARNING: Parameter bot_overscan_low_rej not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_overscan_low_rej not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_overscan_low_rej not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTOverscan_NAverage){
      print("stbadovertrim: WARNING: Parameter bot_overscan_naverage not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_overscan_naverage not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_overscan_naverage not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTOverscan_NIterate){
      print("stbadovertrim: WARNING: Parameter bot_overscan_niterate not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_overscan_niterate not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_overscan_niterate not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTOverscan_Sample){
      print("stbadovertrim: WARNING: Parameter bot_overscan_sample not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_overscan_sample not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_overscan_sample not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTBadPixFile){
      print("stbadovertrim: WARNING: Parameter bot_badpixelfile not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_badpixelfile not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_badpixelfile not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTTrimSec){
      print("stbadovertrim: WARNING: Parameter bot_trimsec not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_trimsec not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_trimsec not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTOverscan_Function){
      print("stbadovertrim: WARNING: Parameter bot_overscan_function not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_overscan_function not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_overscan_function not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTOverscan_Order){
      print("stbadovertrim: WARNING: Parameter bot_overscan_order not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_overscan_order not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_overscan_order not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTOverscan_Grow){
      print("stbadovertrim: WARNING: Parameter bot_overscan_grow not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_overscan_grow not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_overscan_grow not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundBOTOverscan_Interactive){
      print("stbadovertrim: WARNING: Parameter bot_overscan_interactive not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter bot_overscan_interactive not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter bot_overscan_interactive not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
#    if (!Foundcalc_error_propagation){
#      print("stbadovertrim: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard")
#      print("stbadovertrim: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard", >> LogFile)
#      print("stbadovertrim: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard", >> WarningFile)
#    }
    if (!Foundreadoutaxis){
      print("stbadovertrim: WARNING: Parameter readoutaxis not found in ParameterFile!!! -> using standard")
      print("stbadovertrim: WARNING: Parameter readoutaxis not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stbadovertrim: WARNING: Parameter readoutaxis not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
  } else{
    NumCCDs = 1
    ImType = "fits"
  }

# --- build output filenames and process Images
  print("stbadovertrim: ******************* processing files *********************")
  if (LogLevel > 2)
    print("stbadovertrim: ******************* processing files *********************", >> LogFile)

  while (fscan (P_ImageList, In) != EOF){

    FoundCCDSec                     = NO
    FoundBOTBiasSec                 = NO

    print("stbadovertrim: In = "//In)
    if (LogLevel > 1)
      print("stbadovertrim: In = "//In, >> LogFile)

    Length = strlen(In)
    ImTypeLength = strlen(ImType)
    if (substr (In, Length - ImTypeLength, Length) != "."//ImType)
      In = In//"."//ImType
    CCD_Out_b = substr(In, 1, Length - ImTypeLength - 1)//"_b."//ImType
    CCD_Out_o = substr(In, 1, Length - ImTypeLength - 1)//"_bo."//ImType
    CCD_Out_t = substr(In, 1, Length - ImTypeLength - 1)//"_bot."//ImType
    if (DoErrors){
      if (Objects){
        ErrOut_o = substr(In, 1, Length - ImTypeLength - 1)//"_err_o."//ImType
        #CCD_ErrOut = substr(In, 1, Length - ImTypeLength - 1)//"_err_o_temp."//ImType
      }
      if (Bias){
        Length = strlen(BiasErrImage)
        if (substr(BiasErrImage, Length - ImTypeLength, Length) != "."//ImType)
          BiasErrImage = BiasErrImage//"."//ImType
        ErrOut_o = substr(BiasErrImage, 1, Length - ImTypeLength - 1)//"_o."//ImType
        #CCD_ErrOut = substr(BiasErrImage, 1, Length - ImTypeLength - 1)//"_o_temp."//ImType
      }
    }

# --- delete existing outfiles
    if (access(CCD_Out_b)){
      imdel(CCD_Out_b, ver-)
      if (access(CCD_Out_b))
        del(CCD_Out_b,ver-)
      if (!access(CCD_Out_b)){
        print("stbadovertrim: old "//CCD_Out_b//" deleted")
        if (LogLevel > 2)
          print("stbadovertrim: old "//CCD_Out_b//" deleted", >> LogFile)
      }
      else{
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_b)
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_b, >> LogFile)
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_b, >> WarningFile)
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_b, >> ErrorFile)
#  --- clean up
        ccdred.logfile = ccdred_LogFile
        P_ParameterList = ""
        P_ImageList = ""
        P_TimeList      = ""
        P_StatList      = ""
        delete (InFile, ver-, >& "dev$null")
        delete (StatsFile, ver-, >& "dev$null")
        Status = 0
        return
      }
    }
    if (access(CCD_Out_o)){
      imdel(CCD_Out_o, ver-)
      if (access(CCD_Out_o))
        del(CCD_Out_o,ver-)
      if (!access(CCD_Out_o)){
        print("stbadovertrim: old "//CCD_Out_o//" deleted")
        if (LogLevel > 2)
          print("stbadovertrim: old "//CCD_Out_o//" deleted", >> LogFile)
      }
      else{
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_o)
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_o, >> LogFile)
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_o, >> WarningFile)
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_o, >> ErrorFile)
#  --- clean up
        ccdred.logfile = ccdred_LogFile
        P_ParameterList = ""
        P_ImageList = ""
        P_TimeList      = ""
        P_StatList      = ""
        delete (InFile, ver-, >& "dev$null")
        delete (StatsFile, ver-, >& "dev$null")
        Status = 0
        return
      }
    }
    if (access(CCD_Out_t)){
      imdel(CCD_Out_t, ver-)
      if (access(CCD_Out_t))
        del(CCD_Out_t,ver-)
      if (!access(CCD_Out_t)){
        print("stbadovertrim: old "//CCD_Out_t//" deleted")
        if (LogLevel > 2)
          print("stbadovertrim: old "//CCD_Out_t//" deleted", >> LogFile)
      }
      else{
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_t)
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_t, >> LogFile)
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_t, >> WarningFile)
        print("stbadovertrim: ERROR: cannot delete "//CCD_Out_t, >> ErrorFile)
#  --- clean up
        ccdred.logfile = ccdred_LogFile
        P_ParameterList = ""
        P_ImageList = ""
        P_TimeList      = ""
        P_StatList      = ""
        delete (InFile, ver-, >& "dev$null")
        delete (StatsFile, ver-, >& "dev$null")
        Status = 0
        return
      }
    }

  # --- Read parameters and run program for each CCD
    for (i_ccd = 1; i_ccd <= NumCCDs; i_ccd += 1){
      if (access(ParameterFile)){

        P_ParameterList = ParameterFile

        print ("stbadovertrim: **************** reading ParameterFile *******************")
        if (LogLevel > 2)
          print ("stbadovertrim: **************** reading ParameterFile *******************", >> LogFile)

        while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){
    #      if (Parameter != "#")
    #        print ("stbadovertrim: ParameterFile: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

          if (Parameter == "bot_biassec_ccd"//i_ccd){
            BiasSec = ParameterValue
            print ("stbadovertrim: Setting "//Parameter//" to "//ParameterValue)
            if (LogLevel > 2)
              print ("stbadovertrim: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
            FoundBOTBiasSec = YES
          }
          else if (Parameter == "ccdsec_ccd"//i_ccd){
            CCDSec = ParameterValue
            print ("stbadovertrim: Setting "//Parameter//" to "//ParameterValue)
            if (LogLevel > 2)
              print ("stbadovertrim: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
            FoundCCDSec = YES
          }
        }# --- end while
        if (!FoundBOTBiasSec){
          print("stbadovertrim: WARNING: Parameter bot_biassec_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
          print("stbadovertrim: WARNING: Parameter bot_biassec_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
          print("stbadovertrim: WARNING: Parameter bot_biassec_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
        }
        if (!FoundCCDSec){
          print("stbadovertrim: WARNING: Parameter ccdsec_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
          print("stbadovertrim: WARNING: Parameter ccdsec_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
          print("stbadovertrim: WARNING: Parameter ccdsec_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
        }
      }# --- endif
      else{
        print("stbadovertrim: WARNING: ParameterFile not found!!! -> using standard Parameters")
        print("stbadovertrim: WARNING: ParameterFile not found!!! -> using standard Parameters", >> LogFile)
        print("stbadovertrim: WARNING: ParameterFile not found!!! -> using standard Parameters", >> WarningFile)
      }

    # --- Erzeugen von temporaeren Filenamen
      print("stbadovertrim: building temp-filenames")
      if (LogLevel > 2)
        print("stbadovertrim: building temp-filenames", >> LogFile)
      StatsFile = mktemp ("tmp")

    # --- test BadPixFile
      if (!access(BadPixFile)){
        print("stbadovertrim: ERROR: BadPixFile "//BadPixFile//" not found!!!")
        print("stbadovertrim: ERROR: BadPixFile "//BadPixFile//" not found!!!", >> LogFile)
        print("stbadovertrim: ERROR: BadPixFile "//BadPixFile//" not found!!!", >> ErrorFile)
        print("stbadovertrim: ERROR: BadPixFile "//BadPixFile//" not found!!!", >> WarningFile)
    #  --- clean up
        ccdred.logfile = ccdred_LogFile
        P_ParameterList = ""
        P_ImageList = ""
        P_TimeList      = ""
        P_StatList      = ""
        delete (InFile, ver-, >& "dev$null")
        delete (StatsFile, ver-, >& "dev$null")
        Status = 0
        return
      }


      if (substr(In, 1, 4) == "flat")
        HighRejectTake = HighRejectFlat
      else
        HighRejectTake = HighReject

      print("stbadovertrim: processing "//In//", Outfile = "//CCD_Out_t)
      if (LogLevel > 2)
        print("stbadovertrim: processing "//In//", Outfile = "//CCD_Out_t, >> LogFile)

      if (!access(In)){
        print("stbadovertrim: ERROR: cannot access "//In)
        print("stbadovertrim: ERROR: cannot access "//In, >> LogFile)
        print("stbadovertrim: ERROR: cannot access "//In, >> ErrorFile)
        print("stbadovertrim: ERROR: cannot access "//In, >> WarningFile)
  #  --- clean up
        ccdred.logfile = ccdred_LogFile
        P_ParameterList = ""
        P_ImageList = ""
        P_TimeList      = ""
        P_StatList      = ""
        delete (InFile, ver-, >& "dev$null")
        delete (StatsFile, ver-, >& "dev$null")
        Status = 0
        return
      }


      print("stbadovertrim: Starting ccdproc")
      if (LogLevel > 2)
        print("stbadovertrim: Starting ccdproc", >> LogFile)
      if (Interactive)
        print("stbadovertrim: Interactive = YES")
      print("stbadovertrim: In = <"//In//">")
      print("stbadovertrim: Out = <"//CCD_Out_b//">")
      print("stbadovertrim: SubtractOverscan = <"//SubtractOverscan//">")
      print("stbadovertrim: ReadAxis = <"//ReadAxis//">")
      print("stbadovertrim: BiasSec = <"//BiasSec//">")
      print("stbadovertrim: TrimSec = <"//TrimSec//">")
      print("stbadovertrim: BadPixFile = <"//BadPixFile//">")
      print("stbadovertrim: Interactive = <"//Interactive//">")
      print("stbadovertrim: Function = <"//Function//">")
      print("stbadovertrim: Order = <"//Order//">")
      print("stbadovertrim: Sample = <"//Sample//">")
      print("stbadovertrim: NAverage = <"//NAverage//">")
      print("stbadovertrim: NIterate = <"//NIterate//">")
      print("stbadovertrim: LowReject = <"//LowReject//">")
      print("stbadovertrim: HighReject = <"//HighReject//">")
      print("stbadovertrim: Grow = <"//Grow//">")
      if (i_ccd == 1){
        ccdproc(images   = In,
                output   = CCD_Out_b,
                ccdtype  = "",
                max_cac  = 0,
                noproc-,
                fixpix+,
                overscan-,
                trim-,
                zerocor-,
                darkcor-,
                flatcor-,
                illumco-,
                fringec-,
                readcor-,
                scancor-,
                readaxis = ReadAxis,
                biassec  = BiasSec,
                trimsec  = TrimSec,
                minrepl  = 0.,
                scantyp  = "shortscan",
                nscan    = 1,
                fixfile  = BadPixFile,
                interac  = Interactive,
                function = Function,
                order    = Order,
                sample   = Sample,
                naverag  = NAverage,
                niterat  = NIterate,
                low_rej  = LowReject,
                high_rej = HighRejectTake,
                grow     = Grow)
        print("stbadovertrim: bad pixels removed for "//In)
        print("stbadovertrim: bad pixels removed for "//In, >> logfile)
      }
      if (SubtractOverscan){
        if (NumCCDs > 1){
          Length = strlen(CCD_Out_b)
#          TempIn = substr(CCD_Out_b, 1, Length - ImTypeLength - 1)//CCDSec//"."//ImType
          CCD_TempOut_b = substr(CCD_Out_b, 1, Length - ImTypeLength - 1)//i_ccd//"."//ImType
          if (access(CCD_TempOut_b)){
            imdel(CCD_TempOut_b, ver-)
            if (access(CCD_TempOut_b))
              del(CCD_TempOut_b,ver-)
            if (!access(CCD_TempOut_b)){
              print("stbadovertrim: old "//CCD_TempOut_b//" deleted")
              if (LogLevel > 2)
                print("stbadovertrim: old "//CCD_TempOut_b//" deleted", >> LogFile)
            }
            else{
              print("stbadovertrim: ERROR: cannot delete "//CCD_TempOut_b)
              print("stbadovertrim: ERROR: cannot delete "//CCD_TempOut_b, >> LogFile)
              print("stbadovertrim: ERROR: cannot delete "//CCD_TempOut_b, >> WarningFile)
              print("stbadovertrim: ERROR: cannot delete "//CCD_TempOut_b, >> ErrorFile)
      #  --- clean up
              ccdred.logfile = ccdred_LogFile
              P_ParameterList = ""
              P_ImageList     = ""
              P_TimeList      = ""
              P_StatList      = ""
              delete (InFile, ver-, >& "dev$null")
              delete (StatsFile, ver-, >& "dev$null")
              Status = 0
              return
            }
          }
          imcopy(input   = CCD_Out_b//CCDSec,
                 output  = CCD_TempOut_b,
                 verbose-)
          print("stbadovertrim: copying "//CCD_Out_b//CCDSec//" to "//CCD_TempOut_b)
          hedit(images = CCD_TempOut_b,
                fields = "CCDSEC",
                value  = CCDSec,
                add-,
                addonly-,
                delete-,
                verify-,
                show+,
                update+)
          print("stbadovertrim: "//CCD_TempOut_b//" created")
          print("stbadovertrim: "//CCD_TempOut_b//" created", >> logfile)
          TempIn = CCD_TempOut_b
          CCD_TempOut_o = substr(CCD_TempOut_b, 1, Length - ImTypeLength - 1)//i_ccd//"o."//ImType
        } else{
          TempIn = CCD_Out_b
          CCD_TempOut_o = CCD_Out_o
        }
        if (access(CCD_TempOut_o)){
          imdelete(images = CCD_TempOut_o,
                   go_ahead+,
                   verify-)
        }
        ccdproc(images   = TempIn,
                output   = CCD_TempOut_o,
                ccdtype  = "",
                max_cac  = 0,
                noproc-,
                fixpix-,
                overscan=SubtractOverscan,
                trim-,
                zerocor-,
                darkcor-,
                flatcor-,
                illumco-,
                fringec-,
                readcor-,
                scancor-,
                readaxis = ReadAxis,
                biassec  = BiasSec,
                trimsec  = TrimSec,
                minrepl  = 0.,
                scantyp  = "shortscan",
                nscan    = 1,
                fixfile  = BadPixFile,
                interac  = Interactive,
                function = Function,
                order    = Order,
                sample   = Sample,
                naverag  = NAverage,
                niterat  = NIterate,
                low_rej  = LowReject,
                high_rej = HighRejectTake,
                grow     = Grow)
        if (NumCCDs > 1){
          if (i_ccd == 1){
            if (access(CCD_Out_o)){
              imdel(images = CCD_Out_o,
                    go_ahead+,
                    verify-)
            }
            imcopy(input = CCD_Out_b,
                  output = CCD_Out_o,
                  verbose-)
          }
          TempOut = CCD_Out_o//CCDSec
          imcopy(input = CCD_TempOut_o,
                output = TempOut,
                verbose-)
          imdel(images = CCD_TempOut_o,
                go_ahead+,
                verify-)
        }
      }
      else{
        if (access(CCD_Out_o)){
          imdelete(images = CCD_Out_o,
                   go_ahead+,
                   verify-)
        }
        imcopy(input = CCD_Out_b,
               output = CCD_Out_o,
               verbose-)
      }
      if (i_ccd == NumCCDs){
        if (access(CCD_Out_t)){
          imdelete(images = CCD_Out_t,
                   go_ahead+,
                   verify-)
        }
        ccdproc(images   = CCD_Out_o,
                output   = CCD_Out_t,
                ccdtype  = "",
                max_cac  = 0,
                noproc-,
                fixpix-,
                overscan-,
                trim+,
                zerocor-,
                darkcor-,
                flatcor-,
                illumco-,
                fringec-,
                readcor-,
                scancor-,
                readaxis = ReadAxis,
                biassec  = BiasSec,
                trimsec  = TrimSec,
                minrepl  = 0.,
                scantyp  = "shortscan",
                nscan    = 1,
                fixfile  = BadPixFile,
                interac  = Interactive,
                function = Function,
                order    = Order,
                sample   = Sample,
                naverag  = NAverage,
                niterat  = NIterate,
                low_rej  = LowReject,
                high_rej = HighRejectTake,
                grow     = Grow)
        print("stbadovertrim: ccdproc ready")
        if (LogLevel > 2)
          print("stbadovertrim: ccdproc ready", >> LogFile)
        if (!access(CCD_Out_t)){
          print("stbadovertrim: ERROR: "//CCD_Out_t//" not accessable")
          print("stbadovertrim: ERROR: "//CCD_Out_t//" not accessable", >> LogFile)
          print("stbadovertrim: ERROR: "//CCD_Out_t//" not accessable", >> WarningFile)
          print("stbadovertrim: ERROR: "//CCD_Out_t//" not accessable", >> ErrorFile)
    #  --- clean up
          ccdred.logfile = ccdred_LogFile
          P_ParameterList = ""
          P_TimeList      = ""
          P_ImageList = ""
          P_StatList      = ""
          delete (InFile, ver-, >& "dev$null")
          delete (StatsFile, ver-, >& "dev$null")
          Status = 0
          return
        }
        if (access(TimeFile))
          del(TimeFile, ver-)
        time(>> TimeFile)
        if (access(TimeFile)){
          P_TimeList = TimeFile
          if (fscan(P_TimeList,tempday,temptime,tempdate) != EOF){
            hedit(images = CCD_Out_t,
                  fields = "STBADOVE",
                  value  = "bad pixels rejected, overscan subtracted and trimmed "//tempdate//"T"//temptime,
                  add+,
                  addonly-,
                  del-,
                  ver-,
                  show+,
                  update+)
          }
        }
        else{
          print("stbadovertrim: WARNING: TimeFile <"//TimeFile//"> not accessable!")
          print("stbadovertrim: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
          print("stbadovertrim: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
        }
        print("stbadovertrim: "//CCD_Out_t//" ready")
        if (LogLevel > 1)
          print("stbadovertrim: "//CCD_Out_t//" ready", >> LogFile)
      }# --- end if (i_ccd == NumCCDs)
  # --- error propagation
      if ((Objects || Bias) && DoErrors){
        print("stbadovertrim: calculating overscan error")
        if (LogLevel > 1)
          print("stbadovertrim: calculating overscan error", >> LogFile)
        if (i_ccd == 1){
          print("stbadovertrim: ErrOut_o = "//ErrOut_o)
          if (access(ErrOut_o)){
            imdel(ErrOut_o, ver-)
            if (access(ErrOut_o))
              del(ErrOut_o,ver-)
            if (!access(ErrOut_o)){
              print("stbadovertrim: old "//ErrOut_o//" deleted")
              if (LogLevel > 2)
                print("stbadovertrim: old "//ErrOut_o//" deleted", >> LogFile)
            }
            else{
              print("stbadovertrim: ERROR: cannot delete "//ErrOut_o)
              print("stbadovertrim: ERROR: cannot delete "//ErrOut_o, >> LogFile)
              print("stbadovertrim: ERROR: cannot delete "//ErrOut_o, >> WarningFile)
              print("stbadovertrim: ERROR: cannot delete "//ErrOut_o, >> ErrorFile)
    #  --- clean up
              ccdred.logfile = ccdred_LogFile
              P_StatList      = ""
              P_ParameterList = ""
              P_TimeList      = ""
              P_ImageList = ""
              delete (InFile, ver-, >& "dev$null")
              delete (StatsFile, ver-, >& "dev$null")
              Status = 0
              return
            }
          }
#          if (access(CCD_ErrOut)){
#            imdel(CCD_ErrOut, ver-)
#            if (access(CCD_ErrOut))
#              del(CCD_ErrOut,ver-)
#            if (!access(CCD_ErrOut)){
#              print("stbadovertrim: old "//CCD_ErrOut//" deleted")
#              if (LogLevel > 2)
#                print("stbadovertrim: old "//CCD_ErrOut//" deleted", >> LogFile)
#            }
#            else{
#              print("stbadovertrim: ERROR: cannot delete "//CCD_ErrOut)
#              print("stbadovertrim: ERROR: cannot delete "//CCD_ErrOut, >> LogFile)
#              print("stbadovertrim: ERROR: cannot delete "//CCD_ErrOut, >> WarningFile)
#              print("stbadovertrim: ERROR: cannot delete "//CCD_ErrOut, >> ErrorFile)
#    #  --- clean up
#              ccdred.logfile = ccdred_LogFile
#              P_StatList      = ""
##              P_ParameterList = ""
#              P_TimeList      = ""
#              P_ImageList = ""
#              delete (InFile, ver-, >& "dev$null")
#              delete (StatsFile, ver-, >& "dev$null")
#              return
#            }
#          }
    # --- create error Image
          if (Objects){
            imcopy(input=In,
                  output=ErrOut_o,
                  ver-)
            imreplace(images    = ErrOut_o,
                      value     = 0.,
                      imaginary = 0.,
                      lower     = INDEF,
                      upper     = INDEF,
                      radius    = 0.)
          } else{
            imcopy(input = BiasErrImage,
                   output = ErrOut_o,
                   verbose-)
          }
        }# --- end if (i_ccd == 1)
        if (SubtractOverscan){
    # --- errors of overscan
    #  --- imstat BiasSec
          if (access(StatsFile))
            del(StatsFile, ver-)
          imstat(images   = CCD_TempOut_b//BiasSec,
                fields   = "image,mean,stddev",
                lower    = INDEF,
                upper    = INDEF,
                nclip    = NIterate,
                lsigma   = LowReject,
                usigma   = HighRejectTake,
                binwidth = 0.1,
                format-,
                cache-, >> StatsFile)
          if (!access(StatsFile)){
            print("stbadovertrim: ERROR: StatsFile not acessable!")
            print("stbadovertrim: ERROR: StatsFile not acessable!", >> LogFile)
            print("stbadovertrim: ERROR: StatsFile not acessable!", >> WarningFile)
            print("stbadovertrim: ERROR: StatsFile not acessable!", >> ErrorFile)
    #  --- clean up
            ccdred.logfile = ccdred_LogFile
            P_StatList      = ""
            P_ParameterList = ""
            P_TimeList      = ""
            P_ImageList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (StatsFile, ver-, >& "dev$null")
            Status = 0
            return
          }
    #  --- Ausgabe
          P_StatList = StatsFile
          if (fscan (P_StatList, Image, BiasMean, BiasStdDev) != EOF){
            print("stbadovertrim: DoErrors: "//Image//": overscan mean = "//BiasMean//", stddev = "//BiasStdDev)
            if (LogLevel > 2)
              print("stbadovertrim: DoErrors: "//Image//": overscan mean = "//BiasMean//", stddev = "//BiasStdDev, >> LogFile)
            if (Objects){
              if (!access(ErrOut_o)){
                print("stbadovertrim: ERROR: "//ErrOut_o//" not acessable!")
                print("stbadovertrim: ERROR: "//ErrOut_o//" not acessable!", >> LogFile)
                print("stbadovertrim: ERROR: "//ErrOut_o//" not acessable!", >> WarningFile)
                print("stbadovertrim: ERROR: "//ErrOut_o//" not acessable!", >> ErrorFile)
    #  --- clean up
                ccdred.logfile = ccdred_LogFile
                P_StatList      = ""
                P_ParameterList = ""
                P_TimeList      = ""
                P_ImageList = ""
                delete (InFile, ver-, >& "dev$null")
                delete (StatsFile, ver-, >& "dev$null")
                Status = 0
                return
              }
              if (access("temp.fits"))
                del("temp.fits, ver-")
              imarith(operand1 = ErrOut_o//CCDSec,
                      op       = "+",
                      operand2 = BiasStdDev,
                      result   = "temp.fits",
                      title    = "",
                      divzero  = 0.,
                      hparams  = "",
                      pixtype  = "real",
                      calctype = "real",
                      ver-,
                      noact-)
              imcopy(input = "temp.fits",
                     output = ErrOut_o//CCDSec,
                     verbose-)
              del("temp.fits")
            }# end if (Objects){
            else{
              if (!access(BiasErrImage)){
                print("stbadovertrim: ERROR: "//BiasErrImage//" not acessable!")
                print("stbadovertrim: ERROR: "//BiasErrImage//" not acessable!", >> LogFile)
                print("stbadovertrim: ERROR: "//BiasErrImage//" not acessable!", >> WarningFile)
                print("stbadovertrim: ERROR: "//BiasErrImage//" not acessable!", >> ErrorFile)
    #  --- clean up
                ccdred.logfile = ccdred_LogFile
                P_StatList      = ""
                P_ParameterList = ""
                P_TimeList      = ""
                P_ImageList = ""
                delete (InFile, ver-, >& "dev$null")
                delete (StatsFile, ver-, >& "dev$null")
                Status = 0
                return
              }
              imcopy(input = BiasErrImage,
                     output = ErrOut_o,
                     verbose-)
              if (access("temp.fits"))
                del("temp.fits", ver-)
              imarith(operand1 = BiasErrImage//CCDSec,
                      op       = "+",
                      operand2 = BiasStdDev,
                      result   = "temp.fits",
                      title    = "",
                      divzero  = 0.,
                      hparams  = "",
                      pixtype  = "real",
                      calctype = "real",
                      ver-,
                      noact-)
              imcopy(input = "temp.fits",
                     output = ErrOut_o//CCDSec,
                     verbose-)
              del("temp.fits", ver-)
            }# end else if (!Objects)
          }
        }# --- end if (SubtractOverscan)
        ErrIn  = ErrOut_o
        ErrOut_b = substr(ErrOut_o, 1, strlen(ErrOut_o)-strlen(ImType)-1)//"b."//ImType
        print("stbadovertrim: ErrOut_b = "//ErrOut_b)

        if (access(ErrOut_b)){
          imdel(ErrOut_b, ver-)
          if (access(ErrOut_b))
            del(ErrOut_b,ver-)
          if (!access(ErrOut_b)){
            print("stbadovertrim: old "//ErrOut_b//" deleted")
            if (LogLevel > 2)
              print("stbadovertrim: old "//ErrOut_b//" deleted", >> LogFile)
          }
          else{
            print("stbadovertrim: ERROR: cannot delete "//ErrOut_b)
            print("stbadovertrim: ERROR: cannot delete "//ErrOut_b, >> LogFile)
            print("stbadovertrim: ERROR: cannot delete "//ErrOut_b, >> WarningFile)
            print("stbadovertrim: ERROR: cannot delete "//ErrOut_b, >> ErrorFile)
  #  --- clean up
            ccdred.logfile = ccdred_LogFile
            P_StatList      = ""
            P_ParameterList = ""
            P_TimeList      = ""
            P_ImageList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (StatsFile, ver-, >& "dev$null")
            Status = 0
            return
          }
        }
        print("stbadovertrim: old ErrOut_b deleted")
        if (i_ccd == NumCCDs){
    # --- set bad pixels from BadPixFile to 10000.
          BadPixVal = 10000.
          print("stbadovertrim: setting bad pixel values to "//BadPixVal)
          imcopy(input=ErrIn,
                output=ErrOut_b,
                ver-)
          del(ErrIn, ver-)
          stsetmaskval(images      = ErrOut_b,
                      maskfile    = BadPixFile,
                      value       = BadPixVal,
                      loglevel    = LogLevel,
                      logfile     = LogFile_stsetmaskval,
                      warningfile = WarningFile_stsetmaskval,
                      errorfile   = ErrorFile_stsetmaskval)
          if (access(LogFile_stsetmaskval))
            cat(LogFile_stsetmaskval, >> LogFile)
          if (access(WarningFile_stsetmaskval))
            cat(WarningFile_stsetmaskval, >> WarningFile)
          if (access(ErrorFile_stsetmaskval)){
            cat(ErrorFile_stsetmaskval, >> ErrorFile)
            print("stbadovertrim: ERROR: ErrorFile_stsetmaskval <"//ErrorFile_stsetmaskval//"> found! => Returning")
            print("stbadovertrim: ERROR: ErrorFile_stsetmaskval <"//ErrorFile_stsetmaskval//"> found! => Returning", >> LogFile)
            print("stbadovertrim: ERROR: ErrorFile_stsetmaskval <"//ErrorFile_stsetmaskval//"> found! => Returning", >> WarningFile)
            print("stbadovertrim: ERROR: ErrorFile_stsetmaskval <"//ErrorFile_stsetmaskval//"> found! => Returning", >> ErrorFile)
    #  --- clean up
            ccdred.logfile = ccdred_LogFile
            P_StatList      = ""
            P_ParameterList = ""
            P_TimeList      = ""
            P_ImageList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (StatsFile, ver-, >& "dev$null")
            Status = 0
            return
          }

    #  --- trim error Images
          ErrIn  = ErrOut_b
          ErrOut_t = substr(ErrOut_b, 1, strlen(ErrOut_b)-strlen(ImType)-1)//"t."//ImType
          print("stbadovertrim: ErrOut_t = "//ErrOut_t)
          if (access(ErrOut_t)){
            imdel(ErrOut_t, ver-)
            if (access(ErrOut_t))
              del(ErrOut_t,ver-)
            if (!access(ErrOut_t)){
              print("stbadovertrim: old "//ErrOut_t//" deleted")
              if (LogLevel > 2)
                print("stbadovertrim: old "//ErrOut_t//" deleted", >> LogFile)
            }
            else{
              print("stbadovertrim: ERROR: cannot delete "//ErrOut_t)
              print("stbadovertrim: ERROR: cannot delete "//ErrOut_t, >> LogFile)
              print("stbadovertrim: ERROR: cannot delete "//ErrOut_t, >> WarningFile)
              print("stbadovertrim: ERROR: cannot delete "//ErrOut_t, >> ErrorFile)
    #  --- clean up
              ccdred.logfile = ccdred_LogFile
              P_StatList      = ""
              P_ParameterList = ""
              P_TimeList      = ""
              P_ImageList = ""
              delete (InFile, ver-, >& "dev$null")
              delete (StatsFile, ver-, >& "dev$null")
              Status = 0
              return
            }
          }
          print("stbadovertrim: old ErrOut_t deleted")
          if (!access(ErrIn)){
            print("stbadovertrim: ERROR: ErrIn (="//ErrIn//") not found!!!")
            print("stbadovertrim: ERROR: ErrIn (="//ErrIn//") not found!!!", >> LogFile)
            print("stbadovertrim: ERROR: ErrIn (="//ErrIn//") not found!!!", >> WarningFile)
            print("stbadovertrim: ERROR: ErrIn (="//ErrIn//") not found!!!", >> ErrorFile)
    #  --- clean up
            ccdred.logfile = ccdred_LogFile
            P_StatList      = ""
            P_ParameterList = ""
            P_TimeList      = ""
            P_ImageList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (StatsFile, ver-, >& "dev$null")
            Status = 0
            return
          }
          imcopy(input   = ErrIn//TrimSec,
                output  = ErrOut_t,
                verbose-)
          hedit(images = ErrOut_t,
              fields = "CCDSEC",
              value  = CCDSec,
              add-,
              addonly-,
              delete-,
              verify-,
              show+,
              update+)
#                ccdtype  = "",
  #                max_cac  = 0,
  #                noproc-,
  #                fixpix-,
  #                overscan-,
  #                trim+,
  #                zerocor-,
  #                darkcor-,
  #                flatcor-,
  #                illumco-,
  #                fringec-,
  #                readcor-,
  #                scancor-,
  #                readaxis = ReadAxis,
  #                biassec  = BiasSec,
  #                trimsec  = TrimSec,
  #                minrepl  = 0.,
  #                scantyp  = "shortscan",
  #                nscan=1,
  #                fixfile  = BadPixFile,
  #                interac  = Interactive,
  #                function = Function,
  #                order    = Order,
  #                sample   = Sample,
  #                naverag  = NAverage,
  #                niterat  = NIterate,
  #                low_rej  = LowReject,
  #                high_rej = HighRejectTake,
  #                grow     = Grow)
          if (access(ErrOut_t)){
            print("stbadovertrim: ErrOut_t (="//ErrOut_t//") ready")
            if (LogLevel > 2)
              print("stbadovertrim: ErrOut_t (="//ErrOut_t//") ready", >> LogFile)
            del(ErrIn, ver-)
          }
          else{
            print("stbadovertrim: ERROR: ErrOut_t (="//ErrOut_t//") not found!!!")
            print("stbadovertrim: ERROR: ErrOut_t (="//ErrOut_t//") not found!!!", >> LogFile)
            print("stbadovertrim: ERROR: ErrOut_t (="//ErrOut_t//") not found!!!", >> WarningFile)
            print("stbadovertrim: ERROR: ErrOut_t (="//ErrOut_t//") not found!!!", >> ErrorFile)
    #  --- clean up
            ccdred.logfile = ccdred_LogFile
            P_StatList      = ""
            P_ParameterList = ""
            P_TimeList      = ""
            P_ImageList = ""
            delete (InFile, ver-, >& "dev$null")
            delete (StatsFile, ver-, >& "dev$null")
            Status = 0
            return
          }
#          if(access(CCD_ErrOut_t))
#            del(CCD_ErrOut_t, ver-)
        }# --- end if (i_ccd == NumCCDs)
      }# --- end if ((Objects || Bias) && DoErrors)
      if (SubtractOverscan)
        del(CCD_TempOut_b, ver-)
      print("-----------------------")
      print("-----------------------", >> LogFile)

    }# --- end for each CCD
    del(CCD_Out_b, ver-)
    del(CCD_Out_o, ver-)
  }# --- end while(fscan(P_ImageList,...))
  if (access(TimeFile))
    del(TimeFile, ver-)
  time(>> TimeFile)
  if (access(TimeFile)){
    P_TimeList = TimeFile
    if (fscan(P_TimeList,tempday,temptime,tempdate) != EOF){
      print("stbadovertrim: stbadovertrim finished "//tempdate//"T"//temptime, >> LogFile)
    }
  }
  else{
    print("stbadovertrim: WARNING: TimeFile <"//TimeFile//"> not accessable!")
    print("stbadovertrim: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
    print("stbadovertrim: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
  }

# --- clean up
  ccdred.logfile = ccdred_LogFile
  P_StatList      = ""
  P_ParameterList = ""
  P_TimeList      = ""
  P_ImageList = ""
  delete (InFile, ver-, >& "dev$null")
  delete (StatsFile, ver-, >& "dev$null")

end
