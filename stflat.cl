procedure stflat (FlatImages)

##################################################################
#                                                                #
# NAME:             stflat.cl                                    #
# PURPOSE:          * combines the Flat images automatically     #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stflat(FlatImages)                           #
# INPUTS:           FlatImages: String                           #
#                     name of list containing names of Flat      #
#                     images to combine:                         #
#                       "flats.list":                            #
#                         flat_01.fits                           #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     combinedFlat.fits                          #
#                   Log Files:                                   #
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      03.12.2001                                   #
# LAST EDITED:      18.04.2007                                   #
#                                                                #
##################################################################

string FlatImages       = "@flats_botzx.list"     {prompt="List of Flats to combine"}
string CombinedFlat     = "combinedFlat.fits"     {prompt="Name of output image"}
string SigmaImage       = "combinedFlat_sig.fits" {prompt="Name of output sigma image"}
string ParameterFile    = "parameterfile.prop"    {prompt="ParameterFile"}
string ImType           = "fits"       {prompt="Image type"}
int    NumCCDs          = 1            {prompt="Number of CCDs"}
string CCDSec           = "[*,*]"      {prompt="CCD section"}
real   RdNoise          = 3.69  {prompt="ccdclip: Read out noise sigma (photons)"}
real   Gain             = 0.68  {prompt="ccdclip: Photon gain (photons/data number)"}
real   SNoise           = 0.    {prompt="ccdclip: Sensitivity noise (fraction)"}
real   NormalFlatMean   = 4955. {prompt="Normal flat mean"}
real   MaxMeanFlatError = 10.   {prompt="Maximum mean error for Flats"}
string Combine = "average" {prompt="Type of combine operation",
                             enum="average|median"}
string Reject  = "ccdclip" {prompt="Type of rejection",
                             enum="none|minmax|ccdclip|crreject|sigclip|avsigclip|pclip"}
string Offsets = "none" {prompt="Input image offsets",
                          enum="none|wcs|grid|<filename>"}
string Scale   = "none" {prompt="Multiplicative image scaling to be applied",
                          enum="none|mode|median|mean|exposure|@<file>|!<keyword>"}
string Zero    = "none" {prompt="Additive zero level image shifts to be applied",
                          enum="none|mode|median|mean|@<file>|!<keyword>"}
string Weight  = "none" {prompt="Weights to be applied during the final averaging",
                          enum="none|mode|median|mean|exposure|@<file>|!<keyword>"}
string StatSec = ""   {prompt="Section of images to use in computing image statistics for scaling and weighting"}
real   LThreshold = INDEF  {prompt="Low rejection threshold"}
real   HThreshold = INDEF  {prompt="High rejection threshold"}
int    NLow    = 2    {prompt="minmax: Number of low pixels to be rejected"}
int    NHigh   = 3    {prompt="minmax: Number of high pixels to be rejected"}
int    NKeep   = 1    {prompt="clipping algorithms: Minimum to keep (pos) or maximum to reject (neg)"}
bool   MClip   = YES  {prompt="clipping algorithms: Use median in sigma clipping algorithms?"}
real   LSigma  = 3.   {prompt="clipping algorithms: Low and sigma clipping factors"}
real   HSigma  = 3.   {prompt="clipping algorithms: High sigma clipping factors"}
real   SigScale = 0.1 {prompt="clipping algorithms: Tolerance for sigma clipping scaling corrections"}
real   PClip   = -0.5 {prompt="clipping algorithms: Percentile clipping parameter"}
int    Grow    = 0    {prompt="rejection algorithms: Radius (pixels) for 1D neighbor rejection"}
bool   RejectWrongMeanFlats = YES {prompt="Reject flats with mean values outside allowed range?"}
bool   DoErrors = YES {prompt="Calculate sigma image?"}
bool   DelInput = NO  {prompt="Delete input images after processing?"}
int    LogLevel = 3   {prompt="Level for writing LogFile"}
string LogFile     = "logfile_stflat.log"  {prompt="Name of log file"}
string WarningFile = "warnings_stflat.log" {prompt="Name of warning file"}
string ErrorFile   = "errors_stflat.log"   {prompt="Name of error file"}
int    Status = 1
string *statlist
string *flatlist
string *parameterlist
string *timelist

begin

  real   averageofflatmean,stddevofflatmean
  string imred_LogFile
  string ccdred_LogFile
  int    flatstrlen,nflats,i_ccd,i_while,PointPos
  string goodflatsfile = "goodFlats.list"
  string timefile = "time.txt"
  string tempdate,tempday,temptime,CCD_Flat,CCD_CombinedFlat,CCD_SigmaImage
  file   flatfile
  string statsfile,flat,image,flats,parameter,parametervalue
  real   flatmean,flatstddev,errorflatmean,errorflatstddev
#  bool   found_calc_error_propagation = NO
  bool   found_NormalFlatMean         = NO
  bool   found_normalflatstddev       = NO
  bool   found_MaxMeanFlatError       = NO
  bool   found_maxstddevflaterror     = NO
  bool   FoundNumber_of_CCDs          = NO
  bool   FoundCCDSec                  = NO
  bool   found_RdNoise                = NO
  bool   found_Gain                   = NO
  bool   found_SNoise                 = NO
  bool   found_flat_rejects_wrong_mean_flats = NO
  bool   found_flat_Combine           = NO
  bool   found_flat_Reject            = NO
  bool   found_flat_Offsets           = NO
  bool   found_flat_Scale             = NO
  bool   found_flat_Zero              = NO
  bool   found_flat_Weight            = NO
  bool   found_flat_StatSec           = NO
  bool   found_flat_LThreshold        = NO
  bool   found_flat_HThreshold        = NO
  bool   found_flat_NLow              = NO
  bool   found_flat_NHigh             = NO
  bool   found_flat_NKeep             = NO
  bool   found_flat_MClip             = NO
  bool   found_flat_LSigma            = NO
  bool   found_flat_HSigma            = NO
  bool   found_flat_SigScale          = NO
  bool   found_flat_PClip             = NO
  bool   found_flat_Grow              = NO
  bool   FoundImType                  = NO

  Status = 1
  averageofflatmean   = 0.
  stddevofflatmean = 0.
  nflats        = 0

# --- delete old LogFiles
  if (access(LogFile))
    delete(LogFile, ver-)
  if (access(WarningFile))
    delete(WarningFile, ver-)
  if (access(ErrorFile))
    delete(ErrorFile, ver-)

  imred_LogFile = imred.logfile
  print ("stflat: imred_LogFile = "//imred_LogFile)
  imred.logfile = LogFile

  ccdred_LogFile = ccdred.logfile
  print ("stflat: ccdred_LogFile = "//ccdred_LogFile)
  ccdred.logfile = LogFile

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                      stflat.cl                         *")
  print ("*    (combines all flat images to combinedFlat.fits)     *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*                      stflat.cl                         *", >> LogFile)
  print ("*    (combines all flat images to combinedFlat.fits)     *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)

# --- delete output
  if (access(CombinedFlat)){
    imdel(CombinedFlat, ver-)
    if (access(CombinedFlat))
      del(CombinedFlat,ver-)
    if (!access(CombinedFlat)){
      print("stflat: old "//CombinedFlat//" deleted")
      if (LogLevel > 2)
        print("stflat: old "//CombinedFlat//" deleted", >> LogFile)
    }
    else{
      print("stflat: ERROR: cannot delete old "//CombinedFlat)
      print("stflat: ERROR: cannot delete old "//CombinedFlat, >> LogFile)
      print("stflat: ERROR: cannot delete old "//CombinedFlat, >> WarningFile)
      print("stflat: ERROR: cannot delete old "//CombinedFlat, >> ErrorFile)
    }
  }

# --- read ParameterFile
  if (access(ParameterFile)){

    parameterlist = ParameterFile

    print ("stflat: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("stflat: **************** reading ParameterFile *******************", >> LogFile)

    while (fscan (parameterlist, parameter, parametervalue) != EOF){

#      if (parameter != "#")
#        print ("stflat: parameter="//parameter//" value="//parametervalue, >> LogFile)
#
#            if (parameter == "calc_error_propagation"){
#        if (parametervalue == "YES" || parametervalue == "yes" || parametervalue == "Yes"){
#          DoErrors = YES
#          print ("stflat: Setting DoErrors to "//parametervalue)
#          if (LogLevel > 2)
#            print ("stflat: Setting DoErrors to "//parametervalue, >> LogFile)
#        }
#        else{
#          DoErrors = NO
#          print ("stflat: Setting DoErrors to "//parametervalue)
#          if (LogLevel > 2)
#            print ("stflat: Setting DoErrors to "//parametervalue, >> LogFile)
#        }
#        found_calc_error_propagation = YES
#      }
      if (parameter == "number_of_ccds"){
        NumCCDs = int(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        FoundNumber_of_CCDs = YES
      }
      else if (parameter == "imtype"){
        ImType = parametervalue
        print ("stflat: Setting "//parameter//" to "//ImType)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//ImType, >> LogFile)
        FoundImType = YES
      }
      else if (parameter == "flat_combine"){
        Combine = parametervalue
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_Combine = YES
      }
      else if (parameter == "flat_reject"){
        Reject = parametervalue
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_Reject = YES
      }
      else if (parameter == "flat_offsets"){
        Offsets = parametervalue
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_Offsets = YES
      }
      else if (parameter == "flat_scale"){
        Scale = parametervalue
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_Scale = YES
      }
      else if (parameter == "flat_zero"){
        Zero = parametervalue
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_Zero = YES
      }
      else if (parameter == "flat_weight"){
        Weight = parametervalue
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_Weight = YES
      }
      else if (parameter == "flat_lthreshold"){
        if (parametervalue == "INDEF")
          LThreshold = INDEF
        else
          LThreshold = real(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_LThreshold = YES
      }
      else if (parameter == "flat_hthreshold"){
        if (parametervalue == "INDEF")
          HThreshold = INDEF
        else
          HThreshold = real(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_HThreshold = YES
      }
      else if (parameter == "flat_nlow"){
        NLow = int(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_NLow = YES
      }
      else if (parameter == "flat_nhigh"){
        NHigh = int(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_NHigh = YES
      }
      else if (parameter == "flat_nkeep"){
        NKeep = int(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_NKeep = YES
      }
      else if (parameter == "flat_reject_wrong_mean_flats"){
        if (parametervalue == "YES" || parametervalue == "yes" || parametervalue == "Yes"){
          RejectWrongMeanFlats = YES
          print ("stflat: Setting "//parameter//" to "//parametervalue)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        }
        else{
          RejectWrongMeanFlats = NO
          print ("stflat: Setting "//parameter//" to "//parametervalue)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        }
        found_flat_rejects_wrong_mean_flats = YES
      }
      else if (parameter == "flat_mclip"){
        if (parametervalue == "YES" || parametervalue == "yes" || parametervalue == "Yes"){
          MClip = YES
          print ("stflat: Setting "//parameter//" to "//parametervalue)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        }
        else{
          MClip = NO
          print ("stflat: Setting "//parameter//" to "//parametervalue)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        }
        found_flat_MClip = YES
      }
      else if (parameter == "flat_lsigma"){
        LSigma = real(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_LSigma = YES
      }
      else if (parameter == "flat_hsigma"){
        HSigma = real(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_HSigma = YES
      }
      else if (parameter == "flat_sigscale"){
        SigScale = real(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_SigScale = YES
      }
      else if (parameter == "flat_pclip"){
        PClip = real(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_PClip = YES
      }
      else if (parameter == "flat_grow"){
        Grow = int(parametervalue)
        print ("stflat: Setting "//parameter//" to "//parametervalue)
        if (LogLevel > 2)
          print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
        found_flat_Grow = YES
      }
    }#end while
#    if (!found_calc_error_propagation){
#      print("stflat: WARNING: parameter calc_error_propagation not found in ParameterFile!!! -> using standard")
#      print("stflat: WARNING: parameter calc_error_propagation not found in ParameterFile!!! -> using standard", >> LogFile)
#      print("stflat: WARNING: parameter calc_error_propagation not found in ParameterFile!!! -> using standard", >> WarningFile)
#    }
    if (!FoundNumber_of_CCDs){
      print("stflat: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1")
      print("stflat: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1", >> LogFile)
      print("stflat: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1", >> WarningFile)
      NumCCDs = 1
    }
    if (!FoundImType){
      print("stflat: WARNING: parameter imtype not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter imtype not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter imtype not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_Combine){
      print("stflat: WARNING: parameter flat_combine not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_combine not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_combine not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_Reject){
      print("stflat: WARNING: parameter flat_reject not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_reject not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_reject not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_Offsets){
      print("stflat: WARNING: parameter flat_offsets not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_offsets not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_offsets not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_Scale){
      print("stflat: WARNING: parameter flat_scale not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_scale not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_scale not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_Zero){
      print("stflat: WARNING: parameter flat_zero not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_zero not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_zero not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_Weight){
      print("stflat: WARNING: parameter flat_weight not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_weight not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_weight not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_LThreshold){
      print("stflat: WARNING: parameter flat_lthreshold not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_lthreshold not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_lthreshold not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_HThreshold){
      print("stflat: WARNING: parameter flat_hthreshold not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_hthreshold not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_hthreshold not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_NLow){
      print("stflat: WARNING: parameter flat_nlow not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_nlow not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_nlow not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_NHigh){
      print("stflat: WARNING: parameter flat_nhigh not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_nhigh not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_nhigh not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_NKeep){
      print("stflat: WARNING: parameter flat_nkeep not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_nkeep not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_nkeep not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_MClip){
      print("stflat: WARNING: parameter flat_mclip not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_mclip not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_mclip not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_LSigma){
      print("stflat: WARNING: parameter flat_lsigma not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_lsigma not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_lsigma not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_HSigma){
      print("stflat: WARNING: parameter flat_hsigma not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_hsigma not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_hsigma not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_SigScale){
      print("stflat: WARNING: parameter flat_sigscale not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_sigscale not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_sigscale not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_PClip){
      print("stflat: WARNING: parameter flat_pclip not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_pclip not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_pclip not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_flat_Grow){
      print("stflat: WARNING: parameter flat_grow not found in ParameterFile!!! -> using standard")
      print("stflat: WARNING: parameter flat_grow not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stflat: WARNING: parameter flat_grow not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
  }
  else{
    print("stflat: WARNING: ParameterFile not found!!! -> using standard parameters")
    print("stflat: WARNING: ParameterFile not found!!! -> using standard parameters", >> LogFile)
    print("stflat: WARNING: ParameterFile not found!!! -> using standard parameters", >> WarningFile)
  }

# --- Erzeugen von temporaeren Filenamen
  if (LogLevel > 2)
    print("stflat: building temp-filenames", >> LogFile)
  flatfile    = mktemp ("tmp")
  statsfile   = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  if (LogLevel > 2)
    print("stflat: building lists from temp-files", >> LogFile)

  if ( (substr(FlatImages,1,1) == "@" && access(substr(FlatImages,2,strlen(FlatImages)))) || (substr(FlatImages,1,1) != "@" && access(FlatImages))){
   sections(FlatImages, option="root", > flatfile)
  }
  else{
    if (substr(FlatImages,1,1) != "@"){
      print("stflat: ERROR: "//FlatImages//" not found!!!")
      print("stflat: ERROR: "//FlatImages//" not found!!!", >> LogFile)
      print("stflat: ERROR: "//FlatImages//" not found!!!", >> ErrorFile)
      print("stflat: ERROR: "//FlatImages//" not found!!!", >> WarningFile)
    }
    else{
      print("stflat: ERROR: "//substr(FlatImages,2,strlen(FlatImages))//" not found!!!")
      print("stflat: ERROR: "//substr(FlatImages,2,strlen(FlatImages))//" not found!!!", >> LogFile)
      print("stflat: ERROR: "//substr(FlatImages,2,strlen(FlatImages))//" not found!!!", >> ErrorFile)
      print("stflat: ERROR: "//substr(FlatImages,2,strlen(FlatImages))//" not found!!!", >> WarningFile)
    }

# --- clean up
    imred.logfile = imred_LogFile
    ccdred.logfile = ccdred_LogFile

    delete (statsfile, ver-)
    delete (flatfile, ver-, >& "dev$null")
    flatlist      = ""
    statlist      = ""
    parameterlist = ""
    timelist      = ""
    Status = 0
    return
  }

# --- error propagation
  if (DoErrors){
#  -- delete old SigmaImage
    if (access(SigmaImage)){
      imdel(SigmaImage, ver-)
      if (access(SigmaImage))
        del(SigmaImage,ver-)
      if (!access(SigmaImage)){
        print("stflat: old "//SigmaImage//" deleted")
        if (LogLevel > 2)
          print("stflat: old "//SigmaImage//" deleted", >> LogFile)
      }
      else{
        print("stflat: ERROR: cannot delete old "//SigmaImage)
        print("stflat: ERROR: cannot delete old "//SigmaImage, >> LogFile)
        print("stflat: ERROR: cannot delete old "//SigmaImage, >> WarningFile)
        print("stflat: ERROR: cannot delete old "//SigmaImage, >> ErrorFile)
      }
    }
  }#end if (DoErrors)
  else{
    SigmaImage = ""
  }

  for (i_ccd = 1; i_ccd <= NumCCDs; i_ccd += 1){
  # --- read ParameterFile
    if (access(ParameterFile)){

      parameterlist = ParameterFile

      print ("stflat: **************** reading ParameterFile *******************")
      if (LogLevel > 2)
        print ("stflat: **************** reading ParameterFile *******************", >> LogFile)

      while (fscan (parameterlist, parameter, parametervalue) != EOF){
        if (parameter == "ccdsec_trimmed_ccd"//i_ccd){
          CCDSec = parametervalue
          print ("stflat: Setting "//parameter//" to "//parametervalue)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//parametervalue, >> LogFile)
          FoundCCDSec = YES
        }
        else if (parameter == "normalflatmean_ccd"//i_ccd){
          NormalFlatMean = real(parametervalue)
          print ("stflat: Setting "//parameter//" to "//NormalFlatMean)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//NormalFlatMean, >> LogFile)
          found_NormalFlatMean = YES
        }
        else if (parameter == "maxmeanflaterror_ccd"//i_ccd){
          MaxMeanFlatError = real(parametervalue)
          print ("stflat: Setting "//parameter//" to "//MaxMeanFlatError)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//MaxMeanFlatError, >> LogFile)
          found_MaxMeanFlatError = YES
        }
        else if (parameter == "rdnoise_ccd"//i_ccd){
          RdNoise = real(parametervalue)
          print ("stflat: Setting "//parameter//" to "//RdNoise)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//RdNoise, >> LogFile)
          found_RdNoise = YES
        }
        else if (parameter == "gain_ccd"//i_ccd){
          Gain = real(parametervalue)
          print ("stflat: Setting "//parameter//" to "//Gain)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//Gain, >> LogFile)
          found_Gain = YES
        }
        else if (parameter == "snoise_ccd"//i_ccd){
          SNoise = real(parametervalue)
          print ("stflat: Setting "//parameter//" to "//SNoise)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//SNoise, >> LogFile)
          found_SNoise = YES
        }
        else if (parameter == "flat_statsec_ccd"//i_ccd){
          if (parametervalue == "-"){
            StatSec = ""
          }
          else{
            StatSec = parametervalue
          }
          print ("stflat: Setting "//parameter//" to "//StatSec)
          if (LogLevel > 2)
            print ("stflat: Setting "//parameter//" to "//StatSec, >> LogFile)
          found_flat_StatSec = YES
        }
      }#end while
      if (!FoundCCDSec){
        print("stflat: WARNING: parameter ccdsec_trimmed_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
        print("stflat: WARNING: parameter ccdsec_trimmed_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stflat: WARNING: parameter ccdsec_trimmed_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!found_NormalFlatMean){
        print("stflat: WARNING: parameter normalflatmean_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
        print("stflat: WARNING: parameter normalflatmean_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stflat: WARNING: parameter normalflatmean_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!found_MaxMeanFlatError){
        print("stflat: WARNING: parameter maxmeanflaterror_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
        print("stflat: WARNING: parameter maxmeanflaterror_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stflat: WARNING: parameter maxmeanflaterror_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!found_RdNoise){
        print("stflat: WARNING: parameter rdnoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
        print("stflat: WARNING: parameter rdnoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stflat: WARNING: parameter rdnoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!found_Gain){
        print("stflat: WARNING: parameter gain_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
        print("stflat: WARNING: parameter gain_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stflat: WARNING: parameter gain_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!found_SNoise){
        print("stflat: WARNING: parameter snoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
        print("stflat: WARNING: parameter snoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stflat: WARNING: parameter snoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!found_flat_StatSec){
        print("stflat: WARNING: parameter flat_statsec_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
        print("stflat: WARNING: parameter flat_statsec_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stflat: WARNING: parameter flat_statsec_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
    }
    else{
      print("stflat: WARNING: ParameterFile not found!!! -> using standard parameters")
      print("stflat: WARNING: ParameterFile not found!!! -> using standard parameters", >> LogFile)
      print("stflat: WARNING: ParameterFile not found!!! -> using standard parameters", >> WarningFile)
    }
  # --- view image statistics and calculate mean of flats
    print("stflat: ***************** image statistics ******************")
    if (LogLevel > 2)
      print("stflat: ***************** image statistics ******************", >> LogFile)

    flatlist = flatfile
    if (access(statsfile))
      del(statsfile, ver-)
    i_while = 0
    while(fscan(flatlist, image) != EOF){
      i_while += 1
      if ((i_ccd == 1) && (i_while == 1)){
        imcopy(input = image,
               output = CombinedFlat,
               verbose+)
        if (DoErrors){
          imcopy(input = image,
                 output = SigmaImage,
                 verbose+)
        }
      }

      strpos(tempstring = CombinedFlat,
             substring  = "."//ImType)
      PointPos = strpos.pos
      if (PointPos > 1)
        CCD_CombinedFlat = substr(CombinedFlat,1,PointPos-1)
      else
        CCD_CombinedFlat = CombinedFlat
      CCD_CombinedFlat = CCD_CombinedFlat//"_ccd"//i_ccd//"."//ImType
      if (access(CCD_CombinedFlat))
        del(CCD_CombinedFlat, ver-)

      if (DoErrors){
        strpos(tempstring = SigmaImage,
              substring  = "."//ImType)
        PointPos = strpos.pos
        if (PointPos > 1)
          CCD_SigmaImage = substr(SigmaImage,1,PointPos-1)
        else
          CCD_SigmaImage = SigmaImage
        CCD_SigmaImage = CCD_SigmaImage//"_ccd"//i_ccd//"."//ImType
        if (access(CCD_SigmaImage))
          del(CCD_SigmaImage, ver-)
      }

      strpos(tempstring = image,
             substring  = "."//ImType)
      PointPos = strpos.pos
      if (PointPos > 1)
        CCD_Flat = substr(image,1,PointPos-1)
      else
        CCD_Flat = image
      CCD_Flat = CCD_Flat//"_ccd"//i_ccd//"."//ImType
      if (access(CCD_Flat))
        del(CCD_Flat, ver-)
      imcopy(input = image//CCDSec,
             output = CCD_Flat,
             verbose+)

      imstat(images = CCD_Flat,
             format-,
             fields="image,mean,stddev",
             >> statsfile)
    }

    statlist = statsfile
    while (fscan (statlist, image, flatmean, flatstddev) != EOF){
      averageofflatmean = averageofflatmean + flatmean
      nflats = nflats + 1
      print("stflat: "//image//": flatmean = "//flatmean//", flatstddev = "//flatstddev)
      if (LogLevel > 2)
        print("stflat: "//image//": flatmean = "//flatmean//", flatstddev = "//flatstddev, >> LogFile)
    }
    averageofflatmean = averageofflatmean / nflats
    print("stflat: Average of mean of Flat images = "//averageofflatmean)
    if (LogLevel > 2)
      print("stflat: Average of mean of Flat images = "//averageofflatmean, >> LogFile)

    if (abs(averageofflatmean - NormalFlatMean) > MaxMeanFlatError){
      print("stflat: WARNING: averageofflatmean not within limits!")
      print("stflat: WARNING: averageofflatmean not within limits!", >> LogFile)
      print("stflat: WARNING: averageofflatmean not within limits!", >> WarningFile)
    }

  # --- calculate stddev of flats
    statlist = statsfile
    while (fscan (statlist, image, flatmean, flatstddev) != EOF){
      errorflatmean = abs(averageofflatmean - flatmean)
      stddevofflatmean = stddevofflatmean + (errorflatmean * errorflatmean)
    }
    stddevofflatmean = sqrt(stddevofflatmean)
    print("stflat: Stddev of mean of Flat images = "//stddevofflatmean)
    if (LogLevel > 2)
      print("stflat: Stddev of mean of Flat images = "//stddevofflatmean, >> LogFile)

  # --- throw away bad flats
    print("stflat: ***************** Error calculation ********************")
    if (LogLevel > 2)
      print("stflat: ***************** Error calculation ********************", >> LogFile)
    flats = ""
    statlist = statsfile

    if (access(goodflatsfile)){
      delete(goodflatsfile, ver-)
      print("stflat: old goodflatsfile deleted")
      if (LogLevel > 2)
        print("stflat: old goodflatsfile deleted", >> LogFile)
    }

    while (fscan (statlist, image, flatmean, flatstddev) != EOF){
      if (RejectWrongMeanFlats)
        errorflatmean = abs(flatmean - NormalFlatMean)
      else
        errorflatmean = abs(flatmean - averageofflatmean)
      if ((!RejectWrongMeanFlats && errorflatmean < (2. * stddevofflatmean)) || (RejectWrongMeanFlats && errorflatmean < MaxMeanFlatError)){
        if (flats == "")
          flats = image
        else
          flats = flats//","//image
        print("stflat: Mean of "//image//" (="//flatmean//") within limits")
        if (LogLevel > 1)
          print("stflat: Mean of"//image//" (="//flatmean//") within limits", >> LogFile)
  #      errorflatstddev = abs(flatstddev - normalflatstddev)
  #      if (errorflatstddev < maxstddevflaterror){
  #        print("stflat: Stddev of "//image//" (="//errorflatstddev//") within limits")
  #        if (LogLevel > 1)
  #          print("stflat: Stddev of "//image//" (="//errorflatstddev//") within limits", >> LogFile)
        print(image, >> goodflatsfile)
  #      }
  #      else{
  #        print("stflat: WARNING: "//image//": wrong stddev => throwing away")
  #        print("stflat: WARNING: "//image//": wrong stddev => throwing away", >> LogFile)
  #        print("stflat: WARNING: "//image//": wrong stddev => throwing away", >> WarningFile)
  #      }
      }
      else{
        print("stflat: WARNING: "//image//": CCD "//i_ccd//": wrong mean => throwing away")
        print("stflat: WARNING: "//image//": CCD "//i_ccd//": wrong mean => throwing away", >> LogFile)
  #      print("stflat: ERROR: "//image//": wrong mean => throwing away", >> ErrorFile)
        print("stflat: WARNING: "//image//": CCD "//i_ccd//": wrong mean => throwing away", >> WarningFile)
      }
    }

  # --- combine flat field images
    print("stflat: ******************** flatcombine ********************")
    if (LogLevel > 2)
      print("stflat: ******************** flatcombine ********************", >> LogFile)
    if (flats != ""){
      combine (input     = "@"//goodflatsfile,
              output     = CCD_CombinedFlat,
              plfile     = "",
              sigma      = CCD_SigmaImage,
              ccdtype    = "",
              subsets-,
              delete-,
  #             clobber+,
              combine    = Combine,
              reject     = Reject,
              project-,
              outtype    = "real",
              offsets    = Offsets,
              masktype   = "none",
              maskval    = 0.,
              blank      = 1.,
              scale      = Scale,
              zero       = Zero,
              weight     = Weight,
              statsec    = StatSec,
              lthreshold = LThreshold,
              hthreshold = HThreshold,
              nlow       = NLow,
              nhigh      = NHigh,
              nkeep      = NKeep,
              mclip      = MClip,
              lsigma     = LSigma,
              hsigma     = HSigma,
              rdnoise    = RdNoise,
              gain       = Gain,
              snoise     = SNoise,
              sigscale   = SigScale,
              pclip      = PClip,
              grow       = Grow)

  #    flatcombine(input=flats,output=CombinedFlat,rdnoise=RdNoise,gain=Gain,snoise=0.,combine="average",reject="ccdclip",process-,subsets-,delete-,clobber-,scale="none",nlow=1000,nhigh=10,nkeep=1,mclip=YES,lsigma=3.,hsigma=3.,pclip=-0.5,blank=1.)
      imcopy(input = CCD_CombinedFlat,
             output = CombinedFlat//CCDSec,
             verbose+)
      del(CCD_CombinedFlat, ver-)
      del(flats, ver-)
      if (DoErrors){
        imcopy(input = CCD_SigmaImage,
               output = SigmaImage//CCDSec,
               verbose+)
        del(CCD_SigmaImage, ver-)
      }
    }
    else{
      print("stflat: ERROR: CCD "//i_ccd//": NO GOOD FLATS FOUND!!!")
      print("stflat: ERROR: CCD "//i_ccd//": NO GOOD FLATS FOUND!!!", >> LogFile)
      print("stflat: ERROR: CCD "//i_ccd//": NO GOOD FLATS FOUND!!!", >> ErrorFile)
      print("stflat: ERROR: CCD "//i_ccd//": NO GOOD FLATS FOUND!!!", >> WarningFile)
  # --- clean up
      imred.logfile = imred_LogFile
      ccdred.logfile = ccdred_LogFile

      delete (statsfile, ver-)
      delete (flatfile, ver-, >& "dev$null")
      flatlist      = ""
      statlist      = ""
      parameterlist = ""
      timelist      = ""
      Status = 0
      return
    }
  }# --- end for each CCD
  if (access(CombinedFlat)){
    if (DelInput)
      imdel(FlatImages, ver-)
    if (DelInput && access(image))
      del(FlatImages, ver-)

    if (access(timefile))
      del(timefile, ver-)
    time(>> timefile)
    if (access(timefile)){
      timelist = timefile
      if (fscan(timelist,tempday,temptime,tempdate) != EOF){
        hedit(images=CombinedFlat,
              fields="STFLAT",
              value="stflat finished "//tempdate//"T"//temptime,
              add+,
              addonly-,
              del-,
              ver-,
              show+,
              update+)
      }
    }
    else{
      print("stflat: WARNING: timefile <"//timefile//"> not accessable!")
      print("stflat: WARNING: timefile <"//timefile//"> not accessable!", >> LogFile)
      print("stflat: WARNING: timefile <"//timefile//"> not accessable!", >> WarningFile)
    }

    print("stflat: "//CombinedFlat//" ready")
    if (LogLevel > 1)
      print("stflat: "//CombinedFlat//" ready", >> LogFile)
  }
  else{
    print("stflat: ERROR: "//CombinedFlat//" not accessable")
    print("stflat: ERROR: "//CombinedFlat//" not accessable", >> LogFile)
    print("stflat: ERROR: "//CombinedFlat//" not accessable", >> WarningFile)
    print("stflat: ERROR: "//CombinedFlat//" not accessable", >> ErrorFile)
# --- clean up
    imred.logfile = imred_LogFile
    ccdred.logfile = ccdred_LogFile

    delete (statsfile, ver-)
    delete (flatfile, ver-, >& "dev$null")
    flatlist      = ""
    statlist      = ""
    parameterlist = ""
    timelist      = ""
    Status = 0
    return
  }

  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("stflat: stflat finished "//tempdate//"T"//temptime, >> LogFile)
    }
  }
  else{
    print("stflat: WARNING: timefile <"//timefile//"> not accessable!")
    print("stflat: WARNING: timefile <"//timefile//"> not accessable!", >> LogFile)
    print("stflat: WARNING: timefile <"//timefile//"> not accessable!", >> WarningFile)
  }

# --- clean up
  imred.logfile = imred_LogFile
  ccdred.logfile = ccdred_LogFile

  delete (statsfile, ver-)
  delete (flatfile, ver-, >& "dev$null")
  flatlist      = ""
  statlist      = ""
  parameterlist = ""
  timelist      = ""

end
