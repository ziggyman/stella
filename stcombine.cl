procedure stcombine (Images)

##################################################################
#                                                                #
# NAME:             stcombine                                    #
# PURPOSE:          * combines the spectral subapertures         #
#                     automatically                              #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stcombine(Images)                            #
# INPUTS:           images:                                      #
#                     either: name of single file list:          #
#                               HD175640_botzfxsEcBldtRbM.list   #
#                     or: name of list containing names of       #
#                         images to trace:                       #
#                           objects_botzfxsEcBldtRbM_lists.list: #
#                             HD175640_botzfxsEcBldtRbM.list     #
#                             ...                                #
#                   HD175640_botzfxsEcBldtRbM.list:              #
#                     HD175640_botzfxsEc1BldtRbM.<imtype>        #
#                     HD175640_botzfxsEc2BldtRbM.<imtype>        #
#                     ...                                        #
#                                                                #
# OUTPUTS:          output: -                                    #
#                   outfile: <name_of_infile_root>com.<imtype>   #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      24.11.2006                                   #
# LAST EDITED:      02.04.2007                                   #
#                                                                #
##################################################################

string Images        = "@fits.list"   {prompt="List of images to combine"}
string ErrorImages   = "@fits_err.list" {prompt="List of error images to combine"}
string ParameterFile = "scripts$parameterfiles/parameterfile.prop" {prompt="Parameter file"}
bool   DoErrors      = YES            {prompt="Calculate error propagation? [YES|NO]"}
int    DispAxis      = 2              {prompt="1-horizontal, 2-vertical"}
string Combine       = "average"      {prompt="Type of combine operation",
                                         enum="average|median|sum"}
string Reject        = "avsigclip"    {prompt="Type of rejection",
                                         enum="none|minmax|ccdclip|crreject|sigclip|avsigclip|pclip"}
string Scale         = "none"         {prompt="Image scaling",
                                         enum="none|mode|median|mean|exposure|@<file>|!<keyword>"}
string Zero          = "none"         {prompt="Image zero point offset",
                                         enum="none|mode|median|mean|@<file>|!<keyword>"}
string Weight        = "mean"         {prompt="Image weights",
                                         enum="none|mode|median|mean|exposure|@<file>|!<keyword>"}
string Sample        = ""             {prompt="Wavelength sample regions for statistics"}
real   LThreshold    = INDEF          {prompt="Lower threshold"}
real   HThreshold    = INDEF          {prompt="Upper threshold"}
int    NLow          = 1              {prompt="minmax: Number of low pixels to reject"}
int    NHigh         = 1              {prompt="minmax: Number of high pixels to reject"}
int    NKeep         = 1              {prompt="Minimum to keep (pos) or maximum to reject (neg)"}
bool   MClip         = yes            {prompt="Use median in sigma clipping algorithms?"}
real   LSigma        = 3.             {prompt="Lower sigma clipping factor"}
real   HSigma        = 3.             {prompt="Upper sigma clipping factor"}
real   RdNoise       = 3.48           {prompt="ccdclip: CCD readout noise (electrons)"}
real   Gain          = 1.03           {prompt="ccdclip: CCD gain (electrons/DN)"}
real   SNoise        = 0.             {prompt="ccdclip: Sensitivity noise (fraction)"}
real   SigScale      = 0.1            {prompt="Tolerance for sigma clipping scaling correction"}
real   PClip         = -0.5           {prompt="pclip: Percentile clipping parameter"}
int    Grow          = 0              {prompt="Radius (pixels) for 1D neighbor rejection"}
real   Blank         = 0.             {prompt="Value if there are no pixels"}
string ImType        = "fits"         {prompt="Image type"}
int    LogLevel      = 3              {prompt="Level for writing LogFile"}
string LogFile       = "logfile.log"  {prompt="Name of log file"}
string WarningFile   = "warnings.log" {prompt="Name of warning file"}
string ErrorFile     = "errors.log"   {prompt="Name of error file"}
string *FileList
string *ErrFileList
string *ParameterList

begin
  string ErrFileName, ImstatFields, ImstatValue, CalcSNRList, CalcSNRErrList,ListName
  string FileName, OutFileName, newfilename, dumfilename, dumstring, Parameter, ParameterValue
  string LogFile_scombine = "logfile_scombine.log"
  string LogFile_imstat = "logfile_imstat.log"
  string LogFile_stcalcsnr = "logfile_stcalcsnr.log"
  string WarningFile_stcalcsnr = "warnings_stcalcsnr.log"
  string ErrorFile_stcalcsnr = "errors_stcalcsnr.log"
  string LogFile_writeaps = "logfile_writeaps.log"
  string WarningFile_writeaps = "warnings_writeaps.log"
  string ErrorFile_writeaps = "errors_writeaps.log"
  string Weights_scombine = "weights_scombine.text"
  int    i,j,run
  real   tempdbl
  file   obsfile,errfile
#  bool   InputIsList
#  bool   found_doerrors           = NO
  bool   FoundDispAxis            = NO
  bool   found_gain               = NO
  bool   found_rdnoise            = NO
  bool   found_snoise             = NO
  bool   found_combine_combine    = NO
  bool   found_combine_reject     = NO
  bool   found_combine_scale      = NO
  bool   found_combine_zero       = NO
  bool   found_combine_weight     = NO
  bool   found_combine_sample     = NO
  bool   found_combine_lthreshold = NO
  bool   found_combine_hthreshold = NO
  bool   found_combine_nlow       = NO
  bool   found_combine_nhigh      = NO
  bool   found_combine_nkeep      = NO
  bool   found_combine_mclip      = NO
  bool   found_combine_lsigma     = NO
  bool   found_combine_hsigma     = NO
  bool   found_combine_sigscale   = NO
  bool   found_combine_pclip      = NO
  bool   found_combine_grow       = NO
  bool   found_combine_blank      = NO
  bool   found_imtype             = NO

  obsfile = mktemp ("tmp")
  errfile = mktemp ("tmp")
  CalcSNRList = "calcsnr.list"
  CalcSNRErrList = "calcsnr_err.list"

# --- delete old LogFiles
  if (access(LogFile))
    delete(LogFile, ver-)
  if (access(WarningFile))
    delete(WarningFile, ver-)
  if (access(ErrorFile))
    delete(ErrorFile, ver-)

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*               combining sub apertures                  *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*               combining sub apertures                  *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)

  print("stcombine: Images = <"//Images//">")
  print("stcombine: Images = <"//Images//">", >> LogFile)

# --- read ParameterFile
  if (access(ParameterFile)){

    ParameterList = ParameterFile

    print ("stcombine: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("stcombine: **************** reading ParameterFile *******************", >> LogFile)

    while (fscan (ParameterList, Parameter, ParameterValue) != EOF){

      if (Parameter == "dispaxis"){ 
        if (ParameterValue == "1")
          DispAxis = 1
        else
          DispAxis = 2
        print ("stcombine: Setting DispAxis to "//DispAxis)
        print ("stcombine: Setting DispAxis to "//DispAxis, >> LogFile)
        FoundDispAxis = YES
      }
      else if (Parameter == "gain"){ 
        Gain = real(ParameterValue)
        print ("stcombine: Setting Gain to "//Gain)
        print ("stcombine: Setting Gain to "//Gain, >> LogFile)
        found_gain = YES
      }
#      else if (Parameter == "calc_error_propagation"){ 
#        if (ParameterValue == "YES" || ParameterValue == "yes" || ParameterValue == "Yes"){
#          DoErrors = YES
#          print ("stcombine: Setting DoErrors to YES")
#          print ("stcombine: Setting DoErrors to YES", >> LogFile)
#	}
#	else{
#	  DoErrors = NO
#          print ("stcombine: Setting DoErrors to NO")
#          print ("stcombine: Setting DoErrors to NO", >> LogFile)
#	}
#        found_doerrors = YES
#      }
      else if (Parameter == "rdnoise"){ 
        RdNoise = real(ParameterValue)
        print ("stcombine: Setting RdNoise to "//RdNoise)
        print ("stcombine: Setting RdNoise to "//RdNoise, >> LogFile)
        found_rdnoise = YES
      }
      else if (Parameter == "snoise"){ 
        SNoise = real(ParameterValue)
        print ("stcombine: Setting SNoise to "//SNoise)
        print ("stcombine: Setting SNoise to "//SNoise, >> LogFile)
        found_snoise = YES
      }
      else if (Parameter == "combine_combine"){ 
        Combine = ParameterValue
        print ("stcombine: Setting Combine to "//Combine)
        print ("stcombine: Setting Combine to "//Combine, >> LogFile)
        found_combine_combine = YES
      }
      else if (Parameter == "combine_reject"){ 
        Reject = ParameterValue
        print ("stcombine: Setting Reject to "//Reject)
        print ("stcombine: Setting Reject to "//Reject, >> LogFile)
        found_combine_reject = YES
      }
      else if (Parameter == "combine_scale"){ 
        Scale = ParameterValue
        print ("stcombine: Setting Scale to "//Scale)
        print ("stcombine: Setting Scale to "//Scale, >> LogFile)
        found_combine_scale = YES
      }
      else if (Parameter == "combine_zero"){ 
        Zero = ParameterValue
        print ("stcombine: Setting Zero to "//Zero)
        print ("stcombine: Setting Zero to "//Zero, >> LogFile)
        found_combine_zero = YES
      }
      else if (Parameter == "combine_weight"){ 
        Weight = ParameterValue
        print ("stcombine: Setting Weight to "//Weight)
        print ("stcombine: Setting Weight to "//Weight, >> LogFile)
        found_combine_weight = YES
      }
      else if (Parameter == "combine_sample"){ 
        if (substr(ParameterValue,1,1) == "(")
          Sample = ""
        else
          Sample = ParameterValue
        print ("stcombine: Setting Sample to "//Sample)
        print ("stcombine: Setting Sample to "//Sample, >> LogFile)
        found_combine_sample = YES
      }
      else if (Parameter == "combine_lthreshold"){ 
        LThreshold = real(ParameterValue)
        print ("stcombine: Setting LThreshold to "//LThreshold)
        print ("stcombine: Setting LThreshold to "//LThreshold, >> LogFile)
        found_combine_lthreshold = YES
      }
      else if (Parameter == "combine_hthreshold"){ 
        HThreshold = real(ParameterValue)
        print ("stcombine: Setting HThreshold to "//HThreshold)
        print ("stcombine: Setting HThreshold to "//HThreshold, >> LogFile)
        found_combine_hthreshold = YES
      }
      else if (Parameter == "combine_nlow"){ 
        NLow = int(ParameterValue)
        print ("stcombine: Setting NLow to "//NLow)
        print ("stcombine: Setting NLow to "//NLow, >> LogFile)
        found_combine_nlow = YES
      }
      else if (Parameter == "combine_nhigh"){ 
        NHigh = int(ParameterValue)
        print ("stcombine: Setting NHigh to "//NHigh)
        print ("stcombine: Setting NHigh to "//NHigh, >> LogFile)
        found_combine_nhigh = YES
      }
      else if (Parameter == "combine_nkeep"){ 
        NKeep = int(ParameterValue)
        print ("stcombine: Setting NKeep to "//NKeep)
        print ("stcombine: Setting NKeep to "//NKeep, >> LogFile)
        found_combine_nkeep = YES
      }
      else if (Parameter == "combine_mclip"){ 
        if (ParameterValue == "YES" || ParameterValue == "yes" || ParameterValue == "Yes"){
          MClip = YES
          print ("stcombine: Setting MClip to YES")
          print ("stcombine: Setting MClip to YES", >> LogFile)
	}
	else{
	  MClip = NO
          print ("stcombine: Setting MClip to NO")
          print ("stcombine: Setting MClip to NO", >> LogFile)
	}
        found_combine_mclip = YES
      }
      else if (Parameter == "combine_lsigma"){ 
        LSigma = real(ParameterValue)
        print ("stcombine: Setting LSigma to "//LSigma)
        print ("stcombine: Setting LSigma to "//LSigma, >> LogFile)
        found_combine_lsigma = YES
      }
      else if (Parameter == "combine_hsigma"){ 
        HSigma = real(ParameterValue)
        print ("stcombine: Setting HSigma to "//HSigma)
        print ("stcombine: Setting HSigma to "//HSigma, >> LogFile)
        found_combine_hsigma = YES
      }
      else if (Parameter == "combine_sigscale"){ 
        SigScale = real(ParameterValue)
        print ("stcombine: Setting SigScale to "//SigScale)
        print ("stcombine: Setting SigScale to "//SigScale, >> LogFile)
        found_combine_sigscale = YES
      }
      else if (Parameter == "combine_pclip"){ 
        PClip = real(ParameterValue)
        print ("stcombine: Setting PClip to "//PClip)
        print ("stcombine: Setting PClip to "//PClip, >> LogFile)
        found_combine_pclip = YES
      }
      else if (Parameter == "combine_grow"){ 
        Grow = int(ParameterValue)
        print ("stcombine: Setting Grow to "//Grow)
        print ("stcombine: Setting Grow to "//Grow, >> LogFile)
        found_combine_grow = YES
      }
      else if (Parameter == "combine_blank"){ 
        Blank = real(ParameterValue)
        print ("stcombine: Setting Blank to "//Blank)
        print ("stcombine: Setting Blank to "//Blank, >> LogFile)
        found_combine_blank = YES
      }
      else if (Parameter == "imtype"){ 
        ImType = ParameterValue
        print ("stcombine: Setting ImType to "//ImType)
        print ("stcombine: Setting ImType to "//ImType, >> LogFile)
        found_imtype = YES
      }
    } #end while(fscan(ParameterList) != EOF)
#    if (!found_doerrors){
#      print("stcombine: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard value (="//DoErrors//")")
#      print("stcombine: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard value (="//DoErrors//")", >> LogFile)
#      print("stcombine: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard value (="//DoErrors//")", >> WarningFile)
#    }
    if (!FoundDispAxis){
      print("stcombine: WARNING: Parameter dispaxis not found in ParameterFile!!! -> using standard value (="//DispAxis//")")
      print("stcombine: WARNING: Parameter dispaxis not found in ParameterFile!!! -> using standard value (="//DispAxis//")", >> LogFile)
      print("stcombine: WARNING: Parameter dispaxis not found in ParameterFile!!! -> using standard value (="//DispAxis//")", >> WarningFile)
    }
    if (!found_gain){
      print("stcombine: WARNING: Parameter gain not found in ParameterFile!!! -> using standard value (="//Gain//")")
      print("stcombine: WARNING: Parameter gain not found in ParameterFile!!! -> using standard value (="//Gain//")", >> LogFile)
      print("stcombine: WARNING: Parameter gain not found in ParameterFile!!! -> using standard value (="//Gain//")", >> WarningFile)
    }
    if (!found_rdnoise){
      print("stcombine: WARNING: Parameter rdnoise not found in ParameterFile!!! -> using standard value (="//RdNoise//")")
      print("stcombine: WARNING: Parameter rdnoise not found in ParameterFile!!! -> using standard value (="//RdNoise//")", >> LogFile)
      print("stcombine: WARNING: Parameter rdnoise not found in ParameterFile!!! -> using standard value (="//RdNoise//")", >> WarningFile)
    }
    if (!found_snoise){
      print("stcombine: WARNING: Parameter snoise not found in ParameterFile!!! -> using standard value (="//SNoise//")")
      print("stcombine: WARNING: Parameter snoise not found in ParameterFile!!! -> using standard value (="//SNoise//")", >> LogFile)
      print("stcombine: WARNING: Parameter snoise not found in ParameterFile!!! -> using standard value (="//SNoise//")", >> WarningFile)
    }
    if (!found_combine_combine){
      print("stcombine: WARNING: Parameter combine_combine not found in ParameterFile!!! -> using standard value (="//Combine//")")
      print("stcombine: WARNING: Parameter combine_combine not found in ParameterFile!!! -> using standard value (="//Combine//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_combine not found in ParameterFile!!! -> using standard value (="//Combine//")", >> WarningFile)
    }
    if (!found_combine_reject){
      print("stcombine: WARNING: Parameter combine_reject not found in ParameterFile!!! -> using standard value (="//Reject//")")
      print("stcombine: WARNING: Parameter combine_reject not found in ParameterFile!!! -> using standard value (="//Reject//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_reject not found in ParameterFile!!! -> using standard value (="//Reject//")", >> WarningFile)
    }
    if (!found_combine_scale){
      print("stcombine: WARNING: Parameter combine_scale not found in ParameterFile!!! -> using standard value (="//Scale//")")
      print("stcombine: WARNING: Parameter combine_scale not found in ParameterFile!!! -> using standard value (="//Scale//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_scale not found in ParameterFile!!! -> using standard value (="//Scale//")", >> WarningFile)
    }
    if (!found_combine_zero){
      print("stcombine: WARNING: Parameter combine_zero not found in ParameterFile!!! -> using standard value (="//Zero//")")
      print("stcombine: WARNING: Parameter combine_zero not found in ParameterFile!!! -> using standard value (="//Zero//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_zero not found in ParameterFile!!! -> using standard value (="//Zero//")", >> WarningFile)
    }
    if (!found_combine_weight){
      print("stcombine: WARNING: Parameter combine_weight not found in ParameterFile!!! -> using standard value (="//Weight//")")
      print("stcombine: WARNING: Parameter combine_weight not found in ParameterFile!!! -> using standard value (="//Weight//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_weight not found in ParameterFile!!! -> using standard value (="//Weight//")", >> WarningFile)
    }
    if (!found_combine_sample){
      print("stcombine: WARNING: Parameter combine_sample not found in ParameterFile!!! -> using standard value (="//Sample//")")
      print("stcombine: WARNING: Parameter combine_sample not found in ParameterFile!!! -> using standard value (="//Sample//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_sample not found in ParameterFile!!! -> using standard value (="//Sample//")", >> WarningFile)
    }
    if (!found_combine_lthreshold){
      print("stcombine: WARNING: Parameter combine_lthreshold not found in ParameterFile!!! -> using standard value (="//LThreshold//")")
      print("stcombine: WARNING: Parameter combine_lthreshold not found in ParameterFile!!! -> using standard value (="//LThreshold//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_lthreshold not found in ParameterFile!!! -> using standard value (="//LThreshold//")", >> WarningFile)
    }
    if (!found_combine_hthreshold){
      print("stcombine: WARNING: Parameter combine_hthreshold not found in ParameterFile!!! -> using standard value (="//HThreshold//")")
      print("stcombine: WARNING: Parameter combine_hthreshold not found in ParameterFile!!! -> using standard value (="//HThreshold//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_hthreshold not found in ParameterFile!!! -> using standard value (="//HThreshold//")", >> WarningFile)
    }
    if (!found_combine_nlow){
      print("stcombine: WARNING: Parameter combine_nlow not found in ParameterFile!!! -> using standard value (="//NLow//")")
      print("stcombine: WARNING: Parameter combine_nlow not found in ParameterFile!!! -> using standard value (="//NLow//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_nlow not found in ParameterFile!!! -> using standard value (="//NLow//")", >> WarningFile)
    }
    if (!found_combine_nhigh){
      print("stcombine: WARNING: Parameter combine_nhigh not found in ParameterFile!!! -> using standard value (="//NHigh//")")
      print("stcombine: WARNING: Parameter combine_nhigh not found in ParameterFile!!! -> using standard value (="//NHigh//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_nhigh not found in ParameterFile!!! -> using standard value (="//NHigh//")", >> WarningFile)
    }
    if (!found_combine_nkeep){
      print("stcombine: WARNING: Parameter combine_nkeep not found in ParameterFile!!! -> using standard value (="//NKeep//")")
      print("stcombine: WARNING: Parameter combine_nkeep not found in ParameterFile!!! -> using standard value (="//NKeep//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_nkeep not found in ParameterFile!!! -> using standard value (="//NKeep//")", >> WarningFile)
    }
    if (!found_combine_mclip){
      print("stcombine: WARNING: Parameter combine_mclip not found in ParameterFile!!! -> using standard value (="//MClip//")")
      print("stcombine: WARNING: Parameter combine_mclip not found in ParameterFile!!! -> using standard value (="//MClip//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_mclip not found in ParameterFile!!! -> using standard value (="//MClip//")", >> WarningFile)
    }
    if (!found_combine_lsigma){
      print("stcombine: WARNING: Parameter combine_lsigma not found in ParameterFile!!! -> using standard value (="//LSigma//")")
      print("stcombine: WARNING: Parameter combine_lsigma not found in ParameterFile!!! -> using standard value (="//LSigma//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_lsigma not found in ParameterFile!!! -> using standard value (="//LSigma//")", >> WarningFile)
    }
    if (!found_combine_hsigma){
      print("stcombine: WARNING: Parameter combine_hsigma not found in ParameterFile!!! -> using standard value (="//HSigma//")")
      print("stcombine: WARNING: Parameter combine_hsigma not found in ParameterFile!!! -> using standard value (="//HSigma//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_hsigma not found in ParameterFile!!! -> using standard value (="//HSigma//")", >> WarningFile)
    }
    if (!found_combine_sigscale){
      print("stcombine: WARNING: Parameter combine_sigscale not found in ParameterFile!!! -> using standard value (="//SigScale//")")
      print("stcombine: WARNING: Parameter combine_sigscale not found in ParameterFile!!! -> using standard value (="//SigScale//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_sigscale not found in ParameterFile!!! -> using standard value (="//SigScale//")", >> WarningFile)
    }
    if (!found_combine_pclip){
      print("stcombine: WARNING: Parameter combine_pclip not found in ParameterFile!!! -> using standard value (="//PClip//")")
      print("stcombine: WARNING: Parameter combine_pclip not found in ParameterFile!!! -> using standard value (="//PClip//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_pclip not found in ParameterFile!!! -> using standard value (="//PClip//")", >> WarningFile)
    }
    if (!found_combine_grow){
      print("stcombine: WARNING: Parameter combine_grow not found in ParameterFile!!! -> using standard value (="//Grow//")")
      print("stcombine: WARNING: Parameter combine_grow not found in ParameterFile!!! -> using standard value (="//Grow//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_grow not found in ParameterFile!!! -> using standard value (="//Grow//")", >> WarningFile)
    }
    if (!found_combine_blank){
      print("stcombine: WARNING: Parameter combine_blank not found in ParameterFile!!! -> using standard value (="//Blank//")")
      print("stcombine: WARNING: Parameter combine_blank not found in ParameterFile!!! -> using standard value (="//Blank//")", >> LogFile)
      print("stcombine: WARNING: Parameter combine_blank not found in ParameterFile!!! -> using standard value (="//Blank//")", >> WarningFile)
    }
    if (!found_imtype){
      print("stcombine: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard value (="//ImType//")")
      print("stcombine: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard value (="//ImType//")", >> LogFile)
      print("stcombine: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard value (="//ImType//")", >> WarningFile)
    }
  }# end if (access(ParameterFile))
  else{
    print("stcombine: WARNING: ParameterFile not found!!! -> using standard parameters")
    print("stcombine: WARNING: ParameterFile not found!!! -> using standard parameters", >> LogFile)
    print("stcombine: WARNING: ParameterFile not found!!! -> using standard parameters", >> WarningFile)
  }

# --- Umwandeln der Liste von Frames in temporaeres File
  print("stcombine: building lists from temp-files")
  if (substr(Images,1,1) == "@"){
    ListName = substr(Images,2,strlen(Images))
  }
  else
    ListName = Images
  if (!access(ListName)){
    print("stcombine: ERROR: "//ListName//" not found!!!")
    print("stcombine: ERROR: "//ListName//" not found!!!", >> LogFile)
    print("stcombine: ERROR: "//ListName//" not found!!!", >> WarningFile)
    print("stcombine: ERROR: "//ListName//" not found!!!", >> ErrorFile)

# --- clean up
    FileList = ""
    ErrFileList = ""
    delete(errfile, ver-, >& "dev$null")
    delete(obsfile, ver-, >& "dev$null")
    return
  }
  sections(Images, option="root", > obsfile)
  FileList = obsfile

  if (DoErrors){
    if (substr(ErrorImages,1,1) == "@"){
      ListName = substr(ErrorImages,2,strlen(ErrorImages))
    }
    else
      ListName = ErrorImages
    if (!access(ListName)){
      print("stcombine: ERROR: ErrorImages "//ListName//" not found!!!")
      print("stcombine: ERROR: ErrorImages "//ListName//" not found!!!", >> LogFile)
      print("stcombine: ERROR: ErrorImages "//ListName//" not found!!!", >> WarningFile)
      print("stcombine: ERROR: ErrorImages "//ListName//" not found!!!", >> ErrorFile)
# --- clean up
      FileList = ""
      ErrFileList = ""
      delete(errfile, ver-, >& "dev$null")
      delete(obsfile, ver-, >& "dev$null")
      return
    }
    sections(ErrorImages, option="root", > errfile)
    ErrFileList = errfile
  }

  while (fscan (FileList, FileName) != EOF){
    if (access(CalcSNRList))
      del(CalcSNRList, ver-)
    if (access(CalcSNRErrList))
      del(CalcSNRErrList, ver-)
    strlastpos(FileName, ".")
    OutFileName = substr(FileName, 1, strlastpos.pos-1)//"com."//ImType
    print("stcombine: FileName = <"//FileName//">, OutFileName = <"//OutFileName//">")
    print("stcombine: FileName = <"//FileName//">, OutFileName = <"//OutFileName//">", >> LogFile)
    if (!access(FileName)){
      print("stcombine: ERROR: FileName <"//FileName//"> not found! => Returning")
      print("stcombine: ERROR: FileName <"//FileName//"> not found! => Returning", >> LogFile)
      print("stcombine: ERROR: FileName <"//FileName//"> not found! => Returning", >> WarningFile)
      print("stcombine: ERROR: FileName <"//FileName//"> not found! => Returning", >> ErrorFile)
# --- clean up
      FileList = ""
      ErrFileList = ""
      delete(errfile, ver-, >& "dev$null")
      delete(obsfile, ver-, >& "dev$null")
      return
    }
    if (access(OutFileName))
      del(OutFileName, ver-)
    print(OutFileName, >> CalcSNRList)
    print("stcombine: starting scombine(FileName = <"//FileName//">")
    print("stcombine: starting scombine(FileName = <"//FileName//">", >> LogFile)
    scombine(input = "@"//FileName,
             output = OutFileName,
             noutput = "",
             logfile = LogFile_scombine,
             apertures = "",
             group = "apertures",
             combine = Combine,
             reject = Reject,
             first-,
             w1 = INDEF,
             w2 = INDEF,
             dw = INDEF,
             nw = INDEF,
             log-,
             scale = Scale,
             zero = Zero,
             weight = Weight,
             sample = Sample,
             lthreshold = LThreshold,
             hthreshold = HThreshold,
             nlow = NLow,
             nhigh = NHigh,
             nkeep = NKeep,
             mclip = MClip,
             lsigma = LSigma,
             hsigma = HSigma,
             rdnoise = RdNoise,
             gain = Gain,
             snoise = SNoise,
             sigscale = SigScale,
             pclip = PClip,
             grow = Grow,
             blank = Blank)
    if (access(LogFile_scombine)){
      cat(LogFile_scombine, >> logfile)
    }
    if (!access(OutFile)){
      print("stcombine: ERROR: OutFile of scombine <"//OutFile//"> not found => Returning!")
      print("stcombine: ERROR: OutFile of scombine <"//OutFile//"> not found => Returning!", >> LogFile)
      print("stcombine: ERROR: OutFile of scombine <"//OutFile//"> not found => Returning!", >> WarningFile)
      print("stcombine: ERROR: OutFile of scombine <"//OutFile//"> not found => Returning!", >> ErrorFile)
# --- clean up
      FileList = ""
      ErrFileList = ""
      delete(errfile, ver-, >& "dev$null")
      delete(obsfile, ver-, >& "dev$null")
      return
    }
    print("stcombine: OutFile = <"//OutFileName//"> ready", >> logfile)
    if (DoErrors){
      print("stcombine: Calculating Error Image")
      if (substr(Weight,1,1) == "!" || substr(Weight,1,1) == "@"){
        print("stcombine: Warning: Weight <"//Weight//"> not supported!")
        print("stcombine: Warning: Weight <"//Weight//"> not supported!", >> LogFile)
        print("stcombine: Warning: Weight <"//Weight//"> not supported!", >> WarningFile)
      }
      else{
        if (fscan (ErrFileList, ErrFileName) != EOF){
          if (access(LogFile_imstat))
            del(LogFile_imstat, ver-)
          if (Weight == "median")
            ImstatFields = "midpt"
          else
            ImstatFields = Weight
          print("stcombine: starting imstat(@"//FileName)
          if (LogLevel > 2)
            print("stcombine: starting imstat(@"//FileName, >> LogFile)
          imstat (images = "@"//FileName,
                  fields = ImstatFields,
                  lower = INDEF,
                  upper = INDEF,
                  nclip = 0,
                  lsigma = 3.,
                  usigma = 3.,
                  binwidt = 0.1,
                  format+,
                  cache-, >> LogFile_imstat)
          if (!access(LogFile_imstat)){
            print("stcombine: ERROR: cannot access LogFile_imstat <"//LogFile_imstat//">!!!")
            print("stcombine: ERROR: cannot access LogFile_imstat <"//LogFile_imstat//">!!!", >> LogFile)
            print("stcombine: ERROR: cannot access LogFile_imstat <"//LogFile_imstat//">!!!", >> WarningFile)
            print("stcombine: ERROR: cannot access LogFile_imstat <"//LogFile_imstat//">!!!", >> ErrorFile)

# --- clean up
            FileList = ""
            ErrFileList = ""
            delete(errfile, ver-, >& "dev$null")
            delete(obsfile, ver-, >& "dev$null")
            return
          }
          if (access(Weights_scombine))
            del(Weights_scombine, ver-)
          ParameterList = LogFile_imstat
          while(fscan(ParameterList,ImstatValue) != EOF){
            if (substr(ImstatValue,1,1) == "#"){
              if (fscan(ParameterList,ImstatValue) == EOF){
                print("stcombine: fscan ("//ErrorImages//") returned EOF!!!")
                print("stcombine: fscan ("//ErrorImages//") returned EOF!!!", >> LogFile)
                print("stcombine: fscan ("//ErrorImages//") returned EOF!!!", >> WarningFile)
                print("stcombine: fscan ("//ErrorImages//") returned EOF!!!", >> ErrorFile)

# --- clean up
                FileList = ""
                ErrFileList = ""
                delete(errfile, ver-, >& "dev$null")
                delete(obsfile, ver-, >& "dev$null")
                return
              }
            }
            print(ImstatValue, >> Weights_scombine)
          }# end while(fscan(ParameterList,ImstatValue) != EOF){
          strlastpos(ErrFileName, ".")
          OutFileName = substr(ErrFileName, 1, strlastpos.pos-1)//"com."//ImType
          print("stcombine: ErrFileName = <"//ErrFileName//">, OutFileName = <"//OutFileName//">")
          print("stcombine: ErrFileName = <"//ErrFileName//">, OutFileName = <"//OutFileName//">", >> logfile)
          if (!access(ErrFileName)){
            print("stcombine: ERROR: ErrFileName <"//ErrFileName//"> not found! => Returning")
            print("stcombine: ERROR: ErrFileName <"//ErrFileName//"> not found! => Returning", >> LogFile)
            print("stcombine: ERROR: ErrFileName <"//ErrFileName//"> not found! => Returning", >> WarningFile)
            print("stcombine: ERROR: ErrFileName <"//ErrFileName//"> not found! => Returning", >> ErrorFile)
# --- clean up
            FileList = ""
            ErrFileList = ""
            delete(errfile, ver-, >& "dev$null")
            delete(obsfile, ver-, >& "dev$null")
            return
          }
          if (access(OutFileName))
            del(OutFileName, ver-)
          print(OutFileName, >> CalcSNRErrList)
          print("stcombine: starting scombine(ErrFileName = <"//ErrFileName//">")
          print("stcombine: starting scombine(ErrFileName = <"//ErrFileName//">", >> LogFile)
          scombine(input = "@"//ErrFileName,
                   output = OutFileName,
                   noutput = "",
                   logfile = LogFile_scombine,
                   apertures = "",
                   group = "apertures",
                   combine = Combine,
                   reject = Reject,
                   first-,
                   w1 = INDEF,
                   w2 = INDEF,
                   dw = INDEF,
                   nw = INDEF,
                   log-,
                   scale = Scale,
                   zero = Zero,
                   weight = "@"//Weights_scombine,
                   sample = Sample,
                   lthreshold = LThreshold,
                   hthreshold = HThreshold,
                   nlow = NLow,
                   nhigh = NHigh,
                   nkeep = NKeep,
                   mclip = MClip,
                   lsigma = LSigma,
                   hsigma = HSigma,
                   rdnoise = RdNoise,
                   gain = Gain,
                   snoise = SNoise,
                   sigscale = SigScale,
                   pclip = PClip,
                   grow = Grow,
                   blank = Blank)
          if (access(LogFile_scombine)){
            cat(LogFile_scombine, >> logfile)
          }
          if (!access(OutFileName)){
            print("stcombine: ERROR: Error outFile of scombine <"//OutFileName//"> not found => Returning!")
            print("stcombine: ERROR: Error outFile of scombine <"//OutFileName//"> not found => Returning!", >> LogFile)
            print("stcombine: ERROR: Error outFile of scombine <"//OutFileName//"> not found => Returning!", >> WarningFile)
            print("stcombine: ERROR: Error outFile of scombine <"//OutFileName//"> not found => Returning!", >> ErrorFile)
# --- clean up
            FileList = ""
            ErrFileList = ""
            delete(errfile, ver-, >& "dev$null")
            delete(obsfile, ver-, >& "dev$null")
            return
          }
          print("stcombine: Error outFile = <"//OutFileName//"> ready", >> logfile)
        }# end if (fscan (ErrFileList, ErrFileName) != EOF){
        else{
          print("stcombine: fscan ("//ErrorImages//") returned EOF!!!")
          print("stcombine: fscan ("//ErrorImages//") returned EOF!!!", >> LogFile)
          print("stcombine: fscan ("//ErrorImages//") returned EOF!!!", >> WarningFile)
          print("stcombine: fscan ("//ErrorImages//") returned EOF!!!", >> ErrorFile)

# --- clean up
          FileList = ""
          ErrFileList = ""
          delete(errfile, ver-, >& "dev$null")
          delete(obsfile, ver-, >& "dev$null")
          return
        }
      }# end if (substr(Weight,1,1) != "!" && substr(Weight,1,1) != "@"){
# --- write output images as text files
      writeaps(Input       = "@"//CalcSNRList,
               DispAxis    = DispAxis,
               Delimiter   = "_",
               ImType      = ImType,
               WriteFits-,
               WSpecText+,
               WriteHeads-,
               WriteLists+,
               CreateDirs-,
               LogLevel    = LogLevel,
               LogFile     = LogFile_writeaps,
               WarningFile = WarningFile_writeaps,
               ErrorFile   = ErrorFile_writeaps)
      if (access(LogFile_writeaps))
        cat(LogFile_writeaps, >> LogFile)
      if (access(WarningFile_writeaps))
        cat(WarningFile_writeaps, >> WarningFile)
      if (access(ErrorFile_writeaps)){
        print("stcombine: ERROR: writeaps returned with error => Returning!")
        print("stcombine: ERROR: writeaps returned with error => Returning!", >> LogFile)
        print("stcombine: ERROR: writeaps returned with error => Returning!", >> WarningFile)
        print("stcombine: ERROR: writeaps returned with error => Returning!", >> ErrorFile)
# --- clean up
        StrList = ""
        TextFileList = ""
        delete(errfile, ver-, >& "dev$null")
        delete(obsfile, ver-, >& "dev$null")
        return
      }

# --- calculate snr image
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
      if (access(WarningFile_stcalcsnr)){
        cat(ErrorFile_stcalcsnr, >> ErrorFile)
        print("stcombine: ERROR: stcalcsnr returned an ERROR => Returning");
        print("stcombine: ERROR: stcalcsnr returned an ERROR => Returning", >> LogFile);
        print("stcombine: ERROR: stcalcsnr returned an ERROR => Returning", >> WarningFile);
        print("stcombine: ERROR: stcalcsnr returned an ERROR => Returning", >> ErrorFile);
# --- clean up
        StrList = ""
        TextFileList = ""
        delete(errfile, ver-, >& "dev$null")
        delete(obsfile, ver-, >& "dev$null")
        return
      }
    }# end if (DoErrors){
  }# end while (fscan (FileList, FileName) != EOF){

# --- clean up
  delete (obsfile, ver-, >& "dev$null")
  FileList = ""
  ErrFileList = ""
  delete(errfile, ver-, >& "dev$null")
  delete(obsfile, ver-, >& "dev$null")

end
