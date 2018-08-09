procedure stextract(Images,Reference,Calibs,Objects)

##################################################################
#                                                                #
# NAME:             stextract.cl                                 #
# PURPOSE:          * automatic aperture extraction              #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stextract(Images,Reference,Calibs,Objects)   #
# INPUTS:           Images: String                               #
#                     name of list containing names of           #
#                     images to extract:                         #
#                       "objects_botzfxs.list":                  #
#                         HD175640_botzfxs.fits                  #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     <Entry_in_images_Root>Ec.<ImType>          #
#                   Log Files:                                   #
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      14.12.2001                                   #
# LAST EDITED:      18.04.2007                                   #
#                                                                #
##################################################################

string Images          = "@calibs_botzf.list" {prompt="List of input images"}
string ErrorImages     = "@stsubzero_e.list"  {prompt="List of error images"}
string ParameterFile   = "parameterfile.prop" {prompt="parameterFile"}
string Reference       = "refFlat"            {prompt="Aperture reference image"}
string ImType      = "fits"               {prompt="Image type"}
bool   MkProfIm    = YES  {prompt="Create Profile Image? *Prof.fits"}
bool   MkRecIm     = YES  {prompt="Create Reconstructed Object Image? *Rec.fits"}
bool   MkRecFitIm     = YES  {prompt="Create Reconstructed Object Image from fitted spectrum? *RecFit.fits"}
bool   MkErrIm     = YES  {prompt="Create resulting Error Image? *_err.fits"}
bool   MkSkyRecIm  = YES  {prompt="Create Sky Image? *Sky.fits"}
bool   MkSPFitIm   = YES  {prompt="Create extracted Image of fit? *EcFit.fits"}
bool   MkSPFromProfIm = YES  {prompt="Create extracted spectrum from profile? *EcProf.fits"}
bool   MkMaskIm    = YES  {prompt="Create Mask Image? *Mask.fits"}
bool   Calibs      = NO  {prompt="Are images Calib's?"}
bool   Objects     = NO  {prompt="Are images Objects's?"}
bool   Slicer      = YES {prompt="Does the spectrograph use an image slicer?"}
string DispAxis    = "2" {prompt="Dispersion axis (1-hor.,2-vert.)",
                        enum="1|2"}
bool   Interactive = NO {prompt="Run task interactively?"}
bool   ReCenter    = NO  {prompt="Recenter apertures of objects?"}
bool   ReSize      = YES {prompt="Resize apertures?"}
bool   Edit        = NO  {prompt="Edit apertures?"}
bool   Trace       = NO  {prompt="Trace apertures?"}
bool   Clean       = YES {prompt="Detect and replace bad pixels?"}
int    RecenterLine            = INDEF {prompt="Starting dispersion line for recentering"}
int    RecenterNSum            = 30    {prompt="Number of dispersion lines to sum for recentering"}
string RecenterApertures       = ""    {prompt="Apertures to be recentered"}
real   RecenterNPeaks          = INDEF {prompt="Select brightest peaks for recenteting"}
bool   RecenterShift           = NO    {prompt="Use average shift instead of recentering?"}
real   RecenterThreshold       = 100.  {prompt="Detection threshold for profile centering"}
real   RecenterDDApCenterLimit = 2.    {prompt="Maximum difference between ycenter's"}
int    ResizeLine       = INDEF {prompt="Dispersion line for recentering"}
int    ResizeNSum       = 10    {prompt="Number of dispersion lines to sum or median"}
# --- with imageSlicer
real   ResizeLowLimit   = INDEF {prompt="Lower aperture limit relative to center"}
real   ResizeHighLimit  = INDEF {prompt="Upper aperture limit relative to center"}
# --- without imageSlicer:
real   ResizeYLevel     = 0.05  {prompt="Fraction of peak or intensity for automatic width"}
bool   ResizePeak       = YES   {prompt="Is ylevel a fraction of the peak?"}
bool   ResizeBackground = NO    {prompt="Subtract background in automatic width?"}
real   ResizeGrow       = 0.    {prompt="Grow limits by this factor"}
bool   ResizeAvgLimit   = NO    {prompt="Average limits over all apertures?"}
# --- test aperture limits of objects
real   ResizeApLowLimit = -25.5 {prompt="Minimum lower aperture limit (pixels)"}
real   ResizeApHighLimit = 25.5 {prompt="Maximum upper aperture limit (pixels)"}
real   ResizeMultLimit   = 0.75 {prompt="Multiply limit by this factor is limit is exceeded"}
int    trace_line       = INDEF {prompt="Starting dispersion line for tracing"}
int    trace_nsum       = 30    {prompt="Number of dispersion lines to sum for tracing"}
int    trace_step       = 5     {prompt="Tracing step"}
int    trace_nlost      = 10    {prompt="Number of consecutive times profile is lost before quitting"}
string trace_function   = "legendre" {prompt="Trace fitting function (cheb|leg|spline1|spline3)",
                                       enum="chebyshev|legendre|spline1|spline3"}
int    trace_order       = 4    {prompt="Trace fitting function order"}
string trace_sample      = "*"  {prompt="Trace sample regions"}
int    trace_naverage    = 1    {prompt="Trace average (pos) or median (neg)"}
int    trace_niterate    = 2    {prompt="Trace rejection iterations"}
real   trace_low_reject  = 3.   {prompt="Trace lower rejection sigma"}
real   trace_high_reject = 3.   {prompt="Trace upper rejection sigma"}
real   trace_grow        = 0.   {prompt="Trace rejection growing radius"}
real   trace_yminlimit   = -60. {prompt="Minimum aperture position relative to center (pixels)"}
real   trace_ymaxlimit   = 60.  {prompt="Maximum aperture position relative to center (pixels)"}
real   Width     = 16.   {prompt="Width of spectrum profiles"}
real   CenterRadius = 7. {prompt="Profile centering radius"}
int    NSum      = 100   {prompt="Number of dispersion lines to sum or median"}
real   ReadNoise = 3.69  {prompt="Read out noise sigma (photons)"}
real   Gain      = 0.68  {prompt="Photon gain (electrons/ADU)"}
int    IterSwathWidth = 300  {prompt="if ext_pfit == iterate: Swath width for profile iteration [int]"}
int    IterTelluric   = 2    {prompt="if ext_pfit == iterate: Subtract sky? [0: NO, 1: Piskunov, 2: Fit]"}
int    IterSfMaxIter  = 8    {prompt="if ext_pfit == iterate: Maximum number of Slit Function iterations [int]"}
int    IterSkyMaxIter = 12   {prompt="if ext_pfit == iterate: Maximum number of Sky iterations [int]"}
int    IterSigMaxIter = 2    {prompt="if ext_pfit == iterate: Number of Sigma rejection iterations [int]"}
real   LSigma    = 4.    {prompt="Lower rejection threshold"}
real   USigma    = 4.    {prompt="Upper rejection threshold"}
bool   Extras    = NO    {prompt="Extract sky, sigma, etc.?"}
string BackGround = "none"    {prompt="Background to subtract (none|average|fit)",
                                enum="none|average|fit"}
string Weights    = "none"    {prompt="Extraction weights (none|variance)",
                                enum="none|variance"}
string PFit       = "fit2d"   {prompt="Profile fitting algorithm to use with variance weighting or cleaning",
                                enum="fit1d|fit2d|iterate"}
int    SkyBox     = 1         {prompt="Box car smoothing length for sky"}
real   Saturation = INDEF     {prompt="Saturation level"}
int    NSubAps    = 1         {prompt="Number of subapertures per aperture"}
int    LogLevel   = 3         {prompt="level for writing logfile"}
string Instrument = "echelle" {prompt="Instrument (echelle|coude)",
                                enum="echelle|coude"}
bool   DoErrors   = YES       {prompt="Calculate error propagation? (YES | NO)"}
bool   DelInput   = NO        {prompt="Delete input images after processing?"}
string LogFile     = "logfile_stextract.log"  {prompt="Name of log file"}
string WarningFile = "warnings_stextract.log" {prompt="Name of warning file"}
string ErrorFile   = "errors_stextract.log"   {prompt="Name of error file"}
string *InputList
string *ErrorList
string *ParameterList
string *ApList
string *TimeList

begin

  string ApNoStr = ""
  string Format,TempFile,OptextractFile
  string Parameters_optextract = " "
  string bak_LogFile
  string headerfile = "temphead.text"
  string apheaderfile
  file   InFile,ErrFile
  int    iaperture,p,pp,sp,i,j,Pos,i_nruns,k
  real   DivisionThreshold = 10.
#  string calibapfile             = "database/apCalibs"
#  string obsapfile              = "database/apObs"
#  string refCalibs               = "Calibs"
#  string refObs                 = "Obs"
  string TimeFile = "time.txt"
  string FN_ProfileImOut, FN_RecImOut, FN_ErrOut, FN_MaskImOut, FN_SkyImOut, FN_SkyErrImOut, FN_SkyRecImOut
  string FN_SPFitOut, FN_RecFitOut, FN_SPFromProfOut
  string TempDay,TempDate,TempTime,ProfileImage,RatioImage,ErrFromProfileOut
  string ReferenceObject,RefObsStr,InRoot,ErrIn,ErrInRoot,OutName,ListName
  string Parameter,ParameterValue,ApFirst,ApSecond,ApThird,ApFourth,ApFith,ApSixt
  string In,Out,Tempref,TempOut,TempApFile,ObjectApFile,OutRoot,ErrOut,ErrOutRoot,ErrOutName,ErrImOut
  string LogFile_makeprofile = "logfile_makeprofile.log"
  string LogFile_strecenter = "logfile_strecenter.log"
  string WarningFile_strecenter = "warningfile_strecenter.log"
  string ErrorFile_strecenter = "errorfile_strecenter.log"
  string LogFile_stresize = "logfile_stresize.log"
  string WarningFile_stresize = "warningfile_stresize.log"
  string ErrorFile_stresize = "errorfile_stresize.log"
  string LogFile_sttrace = "logfile_sttrace.log"
  string WarningFile_sttrace = "warningfile_sttrace.log"
  string ErrorFile_sttrace = "errorfile_sttrace.log"
#,errOut_temp
  string tempRef,ProfileImageName,DatabaseFileName,TempString
  bool   TempReSize
  bool   found_dispaxis                 = NO
  bool   found_recenter_nsum            = NO
  bool   found_recenter_line            = NO
  bool   found_recenter_apertures       = NO
  bool   found_recenter_npeaks          = NO
  bool   found_recenter_shift           = NO
  bool   found_recenter_threshold       = NO
  bool   found_recenter_ddapcenterlimit = NO
  bool   found_resize_grow              = NO
  bool   found_resize_peak              = NO
  bool   found_resize_line              = NO
  bool   found_resize_nsum              = NO
  bool   found_resize_multlimit         = NO
  bool   found_resize_avglimit          = NO
  bool   found_setinst_instrument       = NO
  bool   found_imtype                   = NO
  bool   found_trace_line         = NO
  bool   found_trace_nsum         = NO
  bool   found_trace_step         = NO
  bool   found_trace_nlost        = NO
  bool   found_trace_function     = NO
  bool   found_trace_order        = NO
  bool   found_trace_sample       = NO
  bool   found_trace_naverage     = NO
  bool   found_trace_niterate     = NO
  bool   found_trace_low_reject   = NO
  bool   found_trace_high_reject  = NO
  bool   found_trace_grow         = NO
  bool   found_trace_yminlimit    = NO
  bool   found_trace_ymaxlimit    = NO
  bool   found_ext_nsum               = NO
  bool   found_resize_ylevel             = NO
  bool   found_recenter_width              = NO
  bool   found_recenter_radius       = NO
  bool   found_resize_lower              = NO
  bool   found_resize_calib_lower        = NO
  bool   found_resize_obs_lowlimit      = NO
  bool   found_resize_upper              = NO
  bool   found_resize_calib_upper        = NO
  bool   found_resize_obs_highlimit       = NO
  bool   found_ext_pfit               = NO
  bool   found_ext_lsigma             = NO
  bool   found_ext_usigma             = NO
  bool   found_rdnoise                = NO
  bool   found_gain                   = NO
#  bool   found_reference             = NO
  bool   found_slicer                 = NO
  bool   found_ext_interact           = NO
  bool   found_ext_recentercalibs     = NO
  bool   found_ext_recenterobs        = NO
  bool   found_ext_traceobs           = NO
  bool   found_ext_resizeobs          = NO
  bool   found_ext_resizecalibs       = NO
  bool   found_ext_edit               = NO
  bool   found_ext_clean              = NO
  bool   found_ext_extras             = NO
  bool   found_ext_background         = NO
  bool   found_ext_weights            = NO
  bool   found_ext_skybox             = NO
  bool   found_ext_saturation         = NO
  bool   found_ext_nsubaps            = NO
  bool   found_ext_iter_swath_width   = NO
  bool   found_ext_iter_sf_maxiter    = NO
  bool   found_ext_iter_sky_maxiter   = NO
  bool   found_ext_iter_sig_maxiter   = NO
  bool   found_ext_iter_MkProfIm      = NO
  bool   found_ext_iter_MkRecIm       = NO
  bool   found_ext_iter_MkRecFitIm    = NO
  bool   found_ext_iter_MkErrIm       = NO
  bool   found_ext_iter_MkSkyRecIm    = NO
  bool   found_ext_iter_MkMaskIm      = NO
  bool   found_ext_iter_MkSPFitIm     = NO
  bool   found_ext_iter_MkSPFromProfIm = NO
  bool   found_ext_iter_MkRECFitIm     = NO
  bool   found_ext_iter_telluric      = NO
#  bool   found_calc_error_propagation = NO

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
  print ("*                  extracting apertures                  *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*                  extracting apertures                  *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)

# --- read ParameterFile
  if (access(ParameterFile)){

    ParameterList = ParameterFile

    print ("stextract: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("stextract: **************** reading ParameterFile *******************", >> LogFile)

    while (fscan (ParameterList, Parameter, ParameterValue) != EOF){

#      if (Parameter != "#")
#        print ("stextract: ParameterFile: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

      if (Parameter == "setinst_instrument"){
        if (ParameterValue == "echelle"){
          Instrument = ParameterValue
          print ("stextract: Setting Instrument to "//ParameterValue)
          print ("stextract: Setting Instrument to "//ParameterValue, >> LogFile)
        }
        else if (ParameterValue == "coude"){
          Instrument = ParameterValue
          print ("stextract: Setting Instrument to "//ParameterValue)
          print ("stextract: Setting Instrument to "//ParameterValue, >> LogFile)
        }
        else{
          print ("stextract: WARNING: Parameter "//Parameter//" not found in ParameterFile")
          print ("stextract: WARNING: Parameter "//Parameter//" not found in ParameterFile", >> LogFile)
          print ("stextract: WARNING: Parameter "//Parameter//" not found in ParameterFile", >> WarningFile)
        }
        found_setinst_instrument = YES
      }
      else if (Parameter == "imtype"){
        ImType = ParameterValue
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_imtype = YES
      }
      else if (Parameter == "trace_line"){
        if (ParameterValue == "INDEF")
          trace_line = INDEF
        else
          trace_line = int(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_line  = YES
      }
      else if (Parameter == "trace_nsum"){
        trace_nsum = int(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_nsum = YES
      }
      else if (Parameter == "trace_step"){
        trace_step = int(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_step = YES
      }
      else if (Parameter == "trace_nlost"){
        trace_nlost = int(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_nlost = YES
      }
      else if (Parameter == "trace_function"){
        trace_function = ParameterValue
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_function = YES
      }
      else if (Parameter == "trace_order"){
        trace_order = int(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_order = YES
      }
      else if (Parameter == "trace_sample"){
        trace_sample = ParameterValue
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_sample = YES
      }
      else if (Parameter == "trace_naverage"){
        trace_naverage = int(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_naverage = YES
      }
      else if (Parameter == "trace_niterate"){
        trace_niterate = int(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_niterate = YES
      }
      else if (Parameter == "trace_low_reject"){
        if (ParameterValue == "INDEF")
          trace_low_reject = INDEF
        else
          trace_low_reject = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_low_reject = YES
      }
      else if (Parameter == "trace_high_reject"){
        if (ParameterValue == "INDEF")
          trace_high_reject = INDEF
        else
          trace_high_reject = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_high_reject = YES
      }
      else if (Parameter == "trace_grow"){
        trace_grow = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_grow = YES
      }
      else if (Parameter == "trace_yminlimit"){
        trace_yminlimit = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_yminlimit = YES
      }
      else if (Parameter == "trace_ymaxlimit"){
        trace_ymaxlimit = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_trace_ymaxlimit = YES
      }
      else if (Parameter == "ext_nsum"){
        NSum = int(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_nsum = YES
      }
      else if (Parameter == "resize_ylevel"){
        if (!Calibs){
          if (ParameterValue == "INDEF")
            ResizeYLevel = INDEF
          else
            ResizeYLevel = real(ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        }
        found_resize_ylevel = YES
      }
      else if (Parameter == "recenter_width"){
        Width = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_recenter_width = YES
      }
      else if (Parameter == "recenter_radius"){
        CenterRadius = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_recenter_radius = YES
      }
#      else if (Parameter == "recenter_threshold"){
#        CenterThreshold = real(ParameterValue)
#        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
#        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
#        found_recenter_threshold = YES
#      }
      else if (Parameter == "resize_obs_lower"){
        if (!Calibs){
          if (ParameterValue == "INDEF")
            ResizeLowLimit = INDEF
          else
            ResizeLowLimit = real(ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        }
        found_resize_lower = YES
      }
      else if (Parameter == "resize_obs_upper"){
        if (!Calibs){
          if (ParameterValue == "INDEF")
            ResizeHighLimit = INDEF
          else
            ResizeHighLimit = real(ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        }
        found_resize_upper = YES
      }
      else if (Parameter == "resize_calib_lower"){
        if (Calibs){
          ResizeYLevel = INDEF
          if (ParameterValue == "INDEF")
            ResizeLowLimit = INDEF
          else
            ResizeLowLimit = real(ParameterValue)
          print ("stextract: Setting ResizeLowLimit to "//ParameterValue)
          print ("stextract: Setting ResizeLowLimit to "//ParameterValue, >> LogFile)
        }
        found_resize_calib_lower = YES
      }
      else if (Parameter == "resize_calib_upper"){
        if (Calibs){
          ResizeYLevel = INDEF
          if (ParameterValue == "INDEF")
            ResizeHighLimit = INDEF
          else
            ResizeHighLimit = real(ParameterValue)
          print ("stextract: Setting ResizeHighLimit to "//ParameterValue)
          print ("stextract: Setting ResizeHighLimit to "//ParameterValue, >> LogFile)
        }
        found_resize_calib_upper = YES
      }
      else if (Parameter == "resize_obs_lowlimit"){
        ResizeApLowLimit = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_resize_obs_lowlimit = YES
      }
      else if (Parameter == "resize_obs_highlimit"){
        ResizeApHighLimit = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_resize_obs_highlimit = YES
      }
      else if (Parameter == "resize_apertures"){
        ResizeApertures = ParameterValue
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_resize_apertures = YES
      }
      else if (Parameter == "ext_lsigma"){
        LSigma = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_lsigma = YES
      }
      else if (Parameter == "ext_usigma"){
        USigma = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_usigma = YES
      }
      else if (Parameter == "rdnoise"){
        ReadNoise = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ReadNoise)
        print ("stextract: Setting "//Parameter//" to "//ReadNoise, >> LogFile)
        found_rdnoise = YES
      }
      else if (Parameter == "gain"){
        Gain = real(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//Gain)
        print ("stextract: Setting "//Parameter//" to "//Gain, >> LogFile)
        found_gain = YES
      }
      else if (Parameter == "ext_skybox"){
        if (ParameterValue == "INDEF"){
          SkyBox = INDEF
          print ("stextract: Setting "//Parameter//" to INDEF")
          print ("stextract: Setting "//Parameter//" to INDEF", >> LogFile)
        }
        else{
          SkyBox = int(ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//SkyBox)
          print ("stextract: Setting "//Parameter//" to "//SkyBox, >> LogFile)
        }
        found_ext_skybox = YES
      }
      else if (Parameter == "ext_saturation"){
        if (ParameterValue == "INDEF"){
          Saturation = INDEF
          print ("stextract: Setting Saturation to INDEF")
          print ("stextract: Setting Saturation to INDEF", >> LogFile)
        }
        else{
          Saturation = real(ParameterValue)
          print ("stextract: Setting Saturation to "//Saturation)
          print ("stextract: Setting Saturation to "//Saturation, >> LogFile)
        }
        found_ext_saturation = YES
      }
      else if (Parameter == "ext_nsubaps"){
        NSubAps = int(ParameterValue)
        print ("stextract: Setting NSubAps to "//NSubAps)
        print ("stextract: Setting NSubAps to "//NSubAps, >> LogFile)
        found_ext_nsubaps = YES
      }
      else if (Parameter == "ext_background"){
        BackGround = ParameterValue
        print ("stextract: Setting "//Parameter//" to "//BackGround)
        print ("stextract: Setting "//Parameter//" to "//BackGround, >> LogFile)
        found_ext_background = YES
      }
      else if (Parameter == "ext_weights"){
        Weights = ParameterValue
        print ("stextract: Setting "//Parameter//" to "//Weights)
        print ("stextract: Setting "//Parameter//" to "//Weights, >> LogFile)
        found_ext_weights = YES
      }
      else if (Parameter == "ext_pfit"){
        if (ParameterValue == "fit1d" || ParameterValue == "fit2d" || ParameterValue == "iterate"){
          PFit = ParameterValue
          print ("stextract: Setting "//Parameter//" to "//PFit)
          print ("stextract: Setting "//Parameter//" to "//PFit, >> LogFile)
          found_ext_pfit = YES
        }
        else{
          print ("stextract: WARNING: Parameter "//Parameter//" not valid!")
          print ("stextract: WARNING: Parameter "//Parameter//" not valid!", >> LogFile)
          print ("stextract: WARNING: Parameter "//Parameter//" not valid!", >> WarningFile)
        }
      }
  # --- read boolean values
      else if (Parameter == "slicer"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
	  Slicer = YES
	else
	  Slicer = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_slicer = YES
      }
      else if (Parameter == "ext_interact"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          Interactive = YES
	else
          Interactive = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_interact = YES
      }
      else if (Parameter == "ext_recentercalibs"){
        if (Calibs){
          if (ParameterValue == "YES" || ParameterValue == "yes")
            ReCenter = YES
	  else
            ReCenter = NO
          print ("stextract: Setting "//Parameter//" to "//ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        }
        found_ext_recentercalibs = YES
      }
      else if (Parameter == "ext_recenterobs"){
        if (!Calibs){
          if (ParameterValue == "YES" || ParameterValue == "yes")
            ReCenter = YES
	  else
            ReCenter = NO
          print ("stextract: Setting "//Parameter//" to "//ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        }
        found_ext_recenterobs = YES
      }
      else if (Parameter == "ext_traceobs"){
        if (!Calibs){
          if (ParameterValue == "YES" || ParameterValue == "yes")
            Trace = YES
	  else
            Trace = NO
          print ("stextract: Setting "//Parameter//" to "//ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        }
        found_ext_traceobs = YES
      }
      else if (Objects && Parameter == "ext_resizeobs"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          ReSize = YES
	else
          ReSize = NO
	TempReSize = ReSize
        print ("stextract: Setting ReSize to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_resizeobs = YES
      }
      else if (Parameter == "ext_resizecalibs"){
        if (Calibs){
          if (ParameterValue == "YES" || ParameterValue == "yes")
            ReSize = YES
	  else
            ReSize = NO
	  TempReSize = ReSize
          ResizeYLevel = INDEF
          print ("stextract: Setting ReSize to "//ParameterValue)
          print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        }
        found_ext_resizecalibs = YES
      }
      else if (Parameter == "ext_edit"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          Edit = YES
	else
          Edit = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_edit = YES
      }
      else if (Parameter == "ext_clean"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          Clean = YES
	else
          Clean = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_clean = YES
      }
      else if (Parameter == "ext_extras"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          Extras = YES
	else
          Extras = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_extras = YES
      }

      else if (Parameter == "dispaxis"){
        DispAxis = ParameterValue
        print ("stextract: Setting DispAxis to "//DispAxis)
        print ("stextract: Setting DispAxis to "//DispAxis, >> LogFile)
        found_dispaxis = YES
      }
      else if (Parameter == "recenter_nsum"){
        RecenterNSum = int(ParameterValue)
        print ("stextract: Setting RecenterNSum to "//RecenterNSum)
        print ("stextract: Setting RecenterNSum to "//RecenterNSum, >> LogFile)
        found_recenter_nsum = YES
      }
      else if (Parameter == "recenter_apertures"){
        if (ParameterValue == "-")
          RecenterApertures = ""
        else
          RecenterApertures = ParameterValue
        print ("stextract: Setting RecenterApertures to "//RecenterApertures)
        print ("stextract: Setting RecenterApertures to "//RecenterApertures, >> LogFile)
        found_recenter_apertures = YES
      }
      else if (Parameter == "recenter_line"){
        if (ParameterValue == "INDEF"){
          RecenterLine = INDEF
          print ("stextract: Setting RecenterLine to INDEF")
          print ("stextract: Setting RecenterLine to INDEF", >> LogFile)
        }
        else{
          RecenterLine = int(ParameterValue)
          print ("stextract: Setting RecenterLine to "//RecenterLine)
          print ("stextract: Setting RecenterLine to "//RecenterLine, >> LogFile)
        }
        found_recenter_line = YES
      }
      else if (Parameter == "recenter_npeaks"){
        if (ParameterValue == "INDEF"){
          RecenterNPeaks = INDEF
          print ("stextract: Setting RecenterNPeaks to INDEF")
          print ("stextract: Setting RecenterNPeaks to INDEF", >> LogFile)
        }
        else{
          RecenterNPeaks = real(ParameterValue)
          print ("stextract: Setting RecenterNPeaks to "//RecenterNPeaks)
          print ("stextract: Setting RecenterNPeaks to "//RecenterNPeaks, >> LogFile)
        }
        found_recenter_npeaks = YES
      }
      else if (Parameter == "recenter_shift"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          RecenterShift = YES
	else
          RecenterShift = NO
        print ("stextract: Setting RecenterShift to "//ParameterValue)
        print ("stextract: Setting RecenterShift to "//ParameterValue, >> LogFile)
        found_recenter_shift = YES
      }
      else if (Parameter == "recenter_threshold"){
        RecenterThreshold = real(ParameterValue)
        print ("stextract: Setting RecenterThreshold to "//RecenterThreshold)
        print ("stextract: Setting RecenterThreshold to "//RecenterThreshold, >> LogFile)
        found_recenter_threshold = YES
      }
      else if (Parameter == "recenter_ddapcenterlimit"){
        RecenterDDApCenterLimit = real(ParameterValue)
        print ("stextract: Setting RecenterDDApCenterLimit to "//RecenterDDApCenterLimit)
        print ("stextract: Setting RecenterDDApCenterLimit to "//RecenterDDApCenterLimit, >> LogFile)
        found_recenter_ddapcenterlimit = YES
      }
      else if (Parameter == "resize_grow"){
        ResizeGrow = real(ParameterValue)
        print ("stextract: Setting ResizeGrow to "//ResizeGrow)
        print ("stextract: Setting ResizeGrow to "//ResizeGrow, >> LogFile)
        found_resize_grow = YES
      }
      else if (Parameter == "resize_peak"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          ResizePeak = YES
	else
          ResizePeak = NO
        print ("stextract: Setting ResizePeak to "//ParameterValue)
        print ("stextract: Setting ResizePeak to "//ParameterValue, >> LogFile)
        found_resize_peak = YES
      }
      else if (Parameter == "resize_line"){
        if (ParameterValue == "INDEF")
          ResizeLine = INDEF
        else
          ResizeLine = int(ParameterValue)
        print ("stextract: Setting ResizeLine to "//ResizeLine)
        print ("stextract: Setting ResizeLine to "//ResizeLine, >> LogFile)
        found_resize_line = YES
      }
      else if (Parameter == "resize_nsum"){
        ResizeNSum = int(ParameterValue)
        print ("stextract: Setting ResizeNSum to "//ResizeNSum)
        print ("stextract: Setting ResizeNSum to "//ResizeNSum, >> LogFile)
        found_resize_nsum = YES
      }
      else if (Parameter == "resize_multlimit"){
        ResizeMultLimit = real(ParameterValue)
        print ("stextract: Setting ResizeMultLimit to "//ResizeMultLimit)
        print ("stextract: Setting ResizeMultLimit to "//ResizeMultLimit, >> LogFile)
        found_resize_multlimit = YES
      }
      else if (Parameter == "resize_avglimit"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          ResizeAvgLimit = YES
	else
          ResizeAvgLimit = NO
        print ("stextract: Setting ResizeAvgLimit to "//ParameterValue)
        print ("stextract: Setting ResizeAvgLimit to "//ParameterValue, >> LogFile)
        found_resize_avglimit = YES
      }
      else if (Parameter == "ext_iter_swath_width"){
        IterSwathWidth = int(ParameterValue)
        print ("stextract: Setting IterSwathWidth to "//IterSwathWidth)
        print ("stextract: Setting IterSwathWidth to "//IterSwathWidth, >> LogFile)
        found_ext_iter_swath_width = YES
      }
      else if (Parameter == "ext_iter_sf_maxiter"){
        IterSfMaxIter = int(ParameterValue)
        print ("stextract: Setting IterSfMaxIter to "//IterSfMaxIter)
        print ("stextract: Setting IterSfMaxIter to "//IterSfMaxIter, >> LogFile)
        found_ext_iter_sf_maxiter = YES
      }
      else if (Parameter == "ext_iter_sky_maxiter"){
        IterSkyMaxIter = int(ParameterValue)
        print ("stextract: Setting IterSkyMaxIter to "//IterSkyMaxIter)
        print ("stextract: Setting IterSkyMaxIter to "//IterSkyMaxIter, >> LogFile)
        found_ext_iter_sky_maxiter = YES
      }
      else if (Parameter == "ext_iter_sig_maxiter"){
        IterSigMaxIter = int(ParameterValue)
        print ("stextract: Setting IterSigMaxIter to "//IterSigMaxIter)
        print ("stextract: Setting IterSigMaxIter to "//IterSigMaxIter, >> LogFile)
        found_ext_iter_sig_maxiter = YES
      }
      else if (Parameter == "ext_iter_MkProfIm"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          MkProfIm = YES
        else
          MkProfIm = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_iter_MkProfIm = YES
      }
      else if (Parameter == "ext_iter_MkRecIm"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          MkRecIm = YES
        else
          MkRecIm = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_iter_MkRecIm = YES
      }
      else if (Parameter == "ext_iter_MkRecFitIm"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          MkRecFitIm = YES
        else
          MkRecFitIm = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_iter_MkRecFitIm = YES
      }
      else if (Parameter == "ext_iter_MkErrIm"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          MkErrIm = YES
        else
          MkErrIm = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_iter_MkErrIm = YES
      }
#      else if (Parameter == "ext_iter_MkSkyErrIm"){
#        if (ParameterValue == "YES" || ParameterValue == "yes")
#          MkSkyErrIm = YES
#        else
#          MkSkyErrIm = NO
#        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
#        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
#        found_ext_iter_MkSkyErrIm = YES
#      }
      else if (Parameter == "ext_iter_MkSkyRecIm"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          MkSkyRecIm = YES
        else
          MkSkyRecIm = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_iter_MkSkyRecIm = YES
      }
      else if (Parameter == "ext_iter_MkMaskIm"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          MkMaskIm = YES
        else
          MkMaskIm = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_iter_MkMaskIm = YES
      }
      else if (Parameter == "ext_iter_MkSPFitIm"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          MkSPFitIm = YES
        else
          MkSPFitIm = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_iter_MkSPFitIm = YES
      }
      else if (Parameter == "ext_iter_MkSPFromProfIm"){
        if (ParameterValue == "YES" || ParameterValue == "yes")
          MkSPFromProfIm = YES
        else
          MkSPFromProfIm = NO
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_iter_MkSPFromProfIm = YES
      }
      else if (Parameter == "ext_iter_telluric"){
        IterTelluric = int(ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue)
        print ("stextract: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        found_ext_iter_telluric = YES
      }


#      else if (Parameter == "calc_error_propagation"){
#        if (ParameterValue == "YES" || ParameterValue == "yes"){
#          DoErrors = YES
#          print ("stextract: Setting DoErrors to YES")
#	}
#	else{
#	  DoErrors = NO
#          print ("stextract: Setting DoErrors to NO")
#	}
#        print ("stextract: Setting DoErrors to "//ParameterValue, >> LogFile)
#        found_calc_error_propagation = YES
#      }
    } #end while(fscan(ParameterList) != EOF)
    if (!found_dispaxis){
      print("stextract: WARNING: Parameter dispaxis not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter dispaxis not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter dispaxis not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_recenter_nsum){
      print("stextract: WARNING: Parameter recenter_nsum not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter recenter_nsum not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter recenter_nsum not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_recenter_line){
      print("stextract: WARNING: Parameter recenter_line not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter recenter_line not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter recenter_line not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_recenter_npeaks){
      print("stextract: WARNING: Parameter recenter_npeaks not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter recenter_npeaks not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter recenter_npeaks not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_recenter_shift){
      print("stextract: WARNING: Parameter recenter_shift not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter recenter_shift not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter recenter_shift not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_recenter_threshold){
      print("stextract: WARNING: Parameter recenter_threshold not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter recenter_threshold not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter recenter_threshold not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_recenter_ddapcenterlimit){
      print("stextract: WARNING: Parameter recenter_ddapcenterlimit not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter recenter_ddapcenterlimit not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter recenter_ddapcenterlimit not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_recenter_apertures){
      print("stextract: WARNING: Parameter recenter_apertures not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter recenter_apertures not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter recenter_apertures not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_resize_grow){
      print("stextract: WARNING: Parameter resize_grow not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter resize_grow not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter resize_grow not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_resize_peak){
      print("stextract: WARNING: Parameter resize_peak not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter resize_peak not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter resize_peak not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_resize_line){
      print("stextract: WARNING: Parameter resize_line not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter resize_line not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter resize_line not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_resize_nsum){
      print("stextract: WARNING: Parameter resize_nsum not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter resize_nsum not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter resize_nsum not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_resize_multlimit){
      print("stextract: WARNING: Parameter resize_multlimit not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter resize_multlimit not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter resize_multlimit not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_resize_avglimit){
      print("stextract: WARNING: Parameter resize_avglimit not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter resize_avglimit not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter resize_avglimit not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_setinst_instrument){
      print("stextract: WARNING: Parameter setinst_instrument not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter setinst_instrument not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter setinst_instrument not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_imtype){
      print("stextract: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_line){
      print("stextract: WARNING: Parameter trace_line not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_line not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_line not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_nsum){
      print("stextract: WARNING: Parameter trace_nsum not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_nsum not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_nsum not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_step){
      print("stextract: WARNING: Parameter trace_step not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_step not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_step not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_nlost){
      print("stextract: WARNING: Parameter trace_nlost not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_nlost not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_nlost not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_function){
      print("stextract: WARNING: Parameter trace_function not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_function not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_function not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_order){
      print("stextract: WARNING: Parameter trace_order not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_order not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_order not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_sample){
      print("stextract: WARNING: Parameter trace_sample not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_sample not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_sample not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_naverage){
      print("stextract: WARNING: Parameter trace_naverage not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_naverage not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_naverage not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_niterate){
      print("stextract: WARNING: Parameter trace_niterate not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_niterate not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_niterate not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_low_reject){
      print("stextract: WARNING: Parameter trace_low_reject not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_low_reject not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_low_reject not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_high_reject){
      print("stextract: WARNING: Parameter trace_high_reject not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_high_reject not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_high_reject not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_grow){
      print("stextract: WARNING: Parameter trace_grow not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_grow not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_grow not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_yminlimit){
      print("stextract: WARNING: Parameter trace_yminlimit not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_yminlimit not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_yminlimit not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_trace_ymaxlimit){
      print("stextract: WARNING: Parameter trace_ymaxlimit not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter trace_ymaxlimit not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter trace_ymaxlimit not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_nsum){
      print("stextract: WARNING: Parameter ext_nsum not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_nsum not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_nsum not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_resize_ylevel){
      print("stextract: WARNING: Parameter resize_ylevel not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter resize_ylevel not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter resize_ylevel not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_recenter_width){
      print("stextract: WARNING: Parameter recenter_width not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter recenter_width not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter recenter_width not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_recenter_radius){
      print("stextract: WARNING: Parameter recenter_radius not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter recenter_radius not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter recenter_radius not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_recenter_threshold){
      print("stextract: WARNING: Parameter recenter_threshold not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter recenter_threshold not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter recenter_threshold not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_resize_lower){
      print("stextract: WARNING: Parameter resize_lower not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter resize_lower not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter resize_lower not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_resize_upper){
      print("stextract: WARNING: Parameter resize_upper not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter resize_upper not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter resize_upper not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_lsigma){
      print("stextract: WARNING: Parameter ext_lsigma not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_lsigma not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_lsigma not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_usigma){
      print("stextract: WARNING: Parameter ext_usigma not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_usigma not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_usigma not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_rdnoise){
      print("stextract: WARNING: Parameter rdnoise not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter rdnoise not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter rdnoise not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_gain){
      print("stextract: WARNING: Parameter gain not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter gain not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter gain not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_skybox){
      print("stextract: WARNING: Parameter ext_skybox not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_skybox not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_skybox not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_saturation){
      print("stextract: WARNING: Parameter ext_saturation not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_saturation not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_saturation not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_nsubaps){
      print("stextract: WARNING: Parameter ext_nsubaps not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_nsubaps not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_nsubaps not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_slicer){
      print("stextract: WARNING: Parameter slicer not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter slicer not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter slicer not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_interact){
      print("stextract: WARNING: Parameter ext_interact not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_interact not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_interact not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_edit){
      print("stextract: WARNING: Parameter ext_edit not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_edit not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_edit not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_clean){
      print("stextract: WARNING: Parameter ext_clean not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_clean not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_clean not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_extras){
      print("stextract: WARNING: Parameter ext_extras not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_extras not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_extras not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_background){
      print("stextract: WARNING: Parameter ext_background not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_background not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_background not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_weights){
      print("stextract: WARNING: Parameter ext_weights not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_weights not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_weights not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (!found_ext_pfit){
      print("stextract: WARNING: Parameter ext_pfit not found in ParameterFile!!! -> using standard value")
      print("stextract: WARNING: Parameter ext_pfit not found in ParameterFile!!! -> using standard value", >> LogFile)
      print("stextract: WARNING: Parameter ext_pfit not found in ParameterFile!!! -> using standard value", >> WarningFile)
    }
    if (Objects){
      if (!found_resize_obs_lowlimit){
        print("stextract: WARNING: Parameter resize_obs_lowlimit not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter resize_obs_lowlimit not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter resize_obs_lowlimit not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_resize_obs_highlimit){
        print("stextract: WARNING: Parameter resize_obs_highlimit not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter resize_obs_highlimit not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter resize_obs_highlimit not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_recenterobs){
        print("stextract: WARNING: Parameter ext_recenterobs not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_recenterobs not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_recenterobs not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_traceobs){
        print("stextract: WARNING: Parameter ext_traceobs not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_traceobs not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_traceobs not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_resizeobs){
        print("stextract: WARNING: Parameter ext_resizeobs not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_resizeobs not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_resizeobs not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_swath_width){
        print("stextract: WARNING: Parameter ext_iter_swath_width not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_swath_width not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_swath_width not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_sf_maxiter){
        print("stextract: WARNING: Parameter ext_iter_sf_maxiter not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_sf_maxiter not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_sf_maxiter not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_sky_maxiter){
        print("stextract: WARNING: Parameter ext_iter_sky_maxiter not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_sky_maxiter not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_sky_maxiter not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_sig_maxiter){
        print("stextract: WARNING: Parameter ext_iter_sig_maxiter not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_sig_maxiter not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_sig_maxiter not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_MkRecIm){
        print("stextract: WARNING: Parameter ext_iter_MkRecIm not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_MkRecIm not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_MkRecIm not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_MkRecFitIm){
        print("stextract: WARNING: Parameter ext_iter_MkRecFitIm not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_MkRecFitIm not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_MkRecFitIm not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_MkProfIm){
        print("stextract: WARNING: Parameter ext_iter_MkProfIm not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_MkProfIm not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_MkProfIm not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_MkErrIm){
        print("stextract: WARNING: Parameter ext_iter_MkErrIm not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_MkErrIm not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_MkErrIm not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
#      if (!found_ext_iter_MkSkyErrIm){
#        print("stextract: WARNING: Parameter ext_iter_MkSkyErrIm not found in ParameterFile!!! -> using standard value")
#        print("stextract: WARNING: Parameter ext_iter_MkSkyErrIm not found in ParameterFile!!! -> using standard value", >> LogFile)
#        print("stextract: WARNING: Parameter ext_iter_MkSkyErrIm not found in ParameterFile!!! -> using standard value", >> WarningFile)
#      }
      if (!found_ext_iter_MkSkyRecIm){
        print("stextract: WARNING: Parameter ext_iter_MkSkyRecIm not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_MkSkyRecIm not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_MkSkyRecIm not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_MkMaskIm){
        print("stextract: WARNING: Parameter ext_iter_MkMaskIm not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_MkMaskIm not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_MkMaskIm not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_MkSPFitIm){
        print("stextract: WARNING: Parameter ext_iter_MkSPFitIm not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_MkSPFitIm not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_MkSPFitIm not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_MkSPFromProfIm){
        print("stextract: WARNING: Parameter ext_iter_MkSPFromProfIm not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_MkSPFromProfIm not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_MkSPFromProfIm not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_iter_telluric){
        print("stextract: WARNING: Parameter ext_iter_telluric not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_iter_telluric not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_iter_telluric not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
#      if (!found_calc_error_propagation){
#        print("stextract: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard value")
#        print("stextract: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard value", >> LogFile)
#        print("stextract: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard value", >> WarningFile)
#      }
    }# end if (Objects)
    if (Calibs){
      if (!found_resize_calib_lower){
        print("stextract: WARNING: Parameter resize_calib_lower not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter resize_calib_lower not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter resize_calib_lower not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_resize_calib_upper){
        print("stextract: WARNING: Parameter resize_calib_upper not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter resize_calib_upper not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter resize_calib_upper not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (Calibs && !found_ext_recentercalibs){
        print("stextract: WARNING: Parameter ext_recentercalibs not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_recentercalibs not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_recentercalibs not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
      if (!found_ext_resizecalibs){
        print("stextract: WARNING: Parameter ext_resizecalibs not found in ParameterFile!!! -> using standard value")
        print("stextract: WARNING: Parameter ext_resizecalibs not found in ParameterFile!!! -> using standard value", >> LogFile)
        print("stextract: WARNING: Parameter ext_resizecalibs not found in ParameterFile!!! -> using standard value", >> WarningFile)
      }
    }# end if (Calibs)
  }# end if (access(ParameterFile)){
  else{
    print("stextract: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard Parameters")
    print("stextract: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard Parameters", >> LogFile)
    print("stextract: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard Parameters", >> WarningFile)
  }

# --- set LogFiles
  if (Instrument == "echelle"){
    bak_LogFile = echelle.logfile
    echelle.logfile = LogFile
  }
  else{
    bak_LogFile = kpnocoude.logfile
    kpnocoude.logfile = LogFile
  }

# --- set general Parameters
#  apnormalize.cennorm = YES
  if (Instrument == "echelle"){
    Format = "echelle"
    print ("stextract: Setting Format to "//Format)
    if (LogLevel > 2)
      print ("stextract: Setting Format to "//Format, >> LogFile)
  }
  else if (Instrument == "coude"){
    Format = "onedspec"
    print ("stextract: Setting Format to "//Format)
    if (LogLevel > 2)
      print ("stextract: Setting Format to "//Format, >> LogFile)
  }

# --- Erzeugen von temporaeren Filenamen
  print("stextract: building temp-filenames")
  if (LogLevel > 2)
    print("stextract: building temp-filenames", >> LogFile)
  InFile  = mktemp ("tmp")
  ErrFile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stextract: building lists from temp-files")
  if (LogLevel > 2)
    print("stextract: building lists from temp-files", >> LogFile)

  if (substr(Images,1,1) == "@")
    ListName = substr(Images,2,strlen(Images))
  else
    ListName = Images
  if (!access(ListName)){
    print("stextract: ERROR: Images <"//ListName//"> not found!!!")
    print("stextract: ERROR: Images <"//ListName//"> not found!!!", >> LogFile)
    print("stextract: ERROR: Images <"//ListName//"> not found!!!", >> ErrorFile)
    print("stextract: ERROR: Images <"//ListName//"> not found!!!", >> WarningFile)
# --- clean up
    if (Instrument == "echelle")
      echelle.logfile = bak_LogFile
    else
      kpnocoude.logfile = bak_LogFile
    InputList     = ""
    ParameterList = ""
    TimeList = ""
    delete (InFile, ver-)
    delete (ErrFile, ver-)
    return
  }# end if (!access(ListName))

  sections(Images, option="root", > InFile)
  InputList = InFile

  if (Objects && DoErrors){
    if (substr(ErrorImages,1,1) == "@")
      ListName = substr(ErrorImages,2,strlen(ErrorImages))
    else
      ListName = ErrorImages
    if (!access(ListName)){
      print("stextract: ERROR: ErrorImages <"//ListName//"> not found!!!")
      print("stextract: ERROR: ErrorImages <"//ListName//"> not found!!!", >> LogFile)
      print("stextract: ERROR: ErrorImages <"//ListName//"> not found!!!", >> ErrorFile)
      print("stextract: ERROR: ErrorImages <"//ListName//"> not found!!!", >> WarningFile)
# --- clean up
      if (Instrument == "echelle")
        echelle.logfile = bak_LogFile
      else
        kpnocoude.logfile = bak_LogFile
      InputList     = ""
      ParameterList = ""
      TimeList = ""
      delete (InFile, ver-)
      delete (ErrFile, ver-)
      return
    }# end if (!access(ErrorImages))
    sections(ErrorImages, option="root", > ErrFile)
    ErrorList = ErrFile
    print("stextract: ErrorImages <"//ErrorImages//"> read")
  }#end if (Objects && DoErrors)

# --- build Output filenames and extract infiles
  print("stextract: ******************* processing files *********************")
  if (LogLevel > 2)
    print("stextract: ******************* processing files *********************", >> LogFile)

  while (fscan (InputList, In) != EOF){

    print("stextract: In = "//In)
    if (LogLevel > 2)
      print("stextract: In = "//In, >> LogFile)

    i = strlen(In)
    if (substr (In, i-strlen(ImType), i) == "."//ImType){
      if (Format == "echelle"){
        if (NSubAps == 1)
          Out = substr(In, 1, i-strlen(ImType)-1)//"Ec."//ImType
        else{
          OutRoot = substr(In, 1, i-strlen(ImType)-1)//"Ec"
        }
      }
      else{
        if (NSubAps == 1)
          Out = substr(In, 1, i-strlen(ImType)-1)//"Ec.0001."//ImType
        else
          OutRoot = substr(In, 1, i-strlen(ImType)-1)//"Ec."
      }
    }# end if (substr (In, i-strlen(ImType), i) == "."//ImType){
    else{
      if (Format == "echelle"){
        if (NSubAps == 1)
          Out = In//"Ec."//ImType
        else
          OutRoot = In//"Ec"
      }
      else{
        if (NSubAps == 1)
          Out = In//"Ec.0001."//ImType
        else
          OutRoot = In//"Ec."
      }
    }# end if (substr (In, i-strlen(ImType), i) != "."//ImType){

# --- delete old OutFile
    if (NSubAps == 1){
      if (access(Out)){
        imdel(Out, ver-)
        if (access(Out))
          del(Out,ver-)
        if (!access(Out)){
          print("stextract: old "//Out//" deleted")
          if (LogLevel > 2)
            print("stextract: old "//Out//" deleted", >> LogFile)
        }
        else{
          print("stextract: ERROR: cannot delete "//Out)
          print("stextract: ERROR: cannot delete "//Out, >> LogFile)
          print("stextract: ERROR: cannot delete "//Out, >> WarningFile)
          print("stextract: ERROR: cannot delete "//Out, >> ErrorFile)
        }
      }
    }# end if (NSubAps == 1){
    else{
      for (i = 1; i <= NSubAps; i += 1){
        ApNoStr = ""
        if (NSubAps > 99 && i < 100)
          ApNoStr = "0"
        if (NSubAps > 9 && i < 10)
          ApNoStr = ApNoStr//"0"
        ApNoStr = ApNoStr//i
        if (Format == "echelle")
          Out = OutRoot//ApNoStr//"."//ImType
        else
          Out = OutRoot//ApNoStr//"001."//ImType
        if (access(Out)){
          imdel(Out, ver-)
          if (access(Out))
            del(Out,ver-)
          if (!access(Out)){
            print("stextract: old "//Out//" deleted")
            if (LogLevel > 2)
              print("stextract: old "//Out//" deleted", >> LogFile)
          }
          else{
            print("stextract: ERROR: cannot delete "//Out)
            print("stextract: ERROR: cannot delete "//Out, >> LogFile)
            print("stextract: ERROR: cannot delete "//Out, >> WarningFile)
            print("stextract: ERROR: cannot delete "//Out, >> ErrorFile)
          }
        }# end if (access(Out)){
      }# end for (i = 1; i <= NSubAps; i += 1){
    }# end if (NSubAps != 1){

    if (Objects && DoErrors){
      if (fscan (ErrorList, ErrIn) != EOF){

        print("stextract: ErrIn = "//ErrIn)
        if (LogLevel > 1)
          print("stextract: ErrIn = "//ErrIn, >> LogFile)

        i = strlen(ErrIn)
        if (substr (ErrIn, i-strlen(ImType), i) != "."//ImType)
          ErrIn = ErrIn//"."//ImType
#        errOut_temp = substr(ErrIn, 1, i-strlen(ImType)-1)//"Ec_temp."//ImType
        ErrInRoot = substr(ErrIn, 1, i-strlen(ImType)-1)
        ErrOutRoot = substr(ErrIn, 1, i-strlen(ImType)-1)//"Ec"
        ErrOut = ErrOutRoot//"."//ImType
#        ErrFromProfileOut = substr(ErrIn, 1, i-strlen(ImType)-1)//"Ec."//ImType
        ErrOutName = ErrOut
        ErrImOut = substr(ErrIn, 1, i-strlen(ImType)-1)//"_out."//ImType

#        if (access(errOut_temp)){
#          imdel(errOut_temp, ver-)
#          if (access(errOut_temp))
#            del(errOut_temp,ver-)
#          if (!access(errOut_temp)){
#            print("stextract: old "//errOut_temp//" deleted")
#            if (LogLevel > 2)
#              print("stextract: old "//errOut_temp//" deleted", >> LogFile)
#          }
#          else{
#            print("stextract: ERROR: cannot delete "//errOut_temp)
#            print("stextract: ERROR: cannot delete "//errOut_temp, >> LogFile)
#            print("stextract: ERROR: cannot delete "//errOut_temp, >> WarningFile)
#            print("stextract: ERROR: cannot delete "//errOut_temp, >> ErrorFile)
#          }
#        }
        if (NSubAps == 1){
          if (access(ErrOut)){
            imdel(ErrOut, ver-)
            if (access(ErrOut))
              del(ErrOut,ver-)
            if (!access(ErrOut)){
              print("stextract: old "//ErrOut//" deleted")
              if (LogLevel > 2)
                print("stextract: old "//ErrOut//" deleted", >> LogFile)
            }
            else{
              print("stextract: ERROR: cannot delete "//ErrOut)
              print("stextract: ERROR: cannot delete "//ErrOut, >> LogFile)
              print("stextract: ERROR: cannot delete "//ErrOut, >> WarningFile)
              print("stextract: ERROR: cannot delete "//ErrOut, >> ErrorFile)
            }
          }
        }# end if (NSubAps == 1){
        else{
          for (i = 1; i <= NSubAps; i += 1){
            ApNoStr = ""
            if (NSubAps > 99 && i < 100)
              ApNoStr = "0"
            if (NSubAps > 9 && i < 10)
              ApNoStr = ApNoStr//"0"
            ApNoStr = ApNoStr//i
            if (Format == "echelle")
              ErrOut = ErrOutRoot//ApNoStr//"."//ImType
            else
              ErrOut = ErrOutRoot//ApNoStr//"001."//ImType
            if (access(ErrOut)){
              imdel(ErrOut, ver-)
              if (access(ErrOut))
                del(ErrOut,ver-)
              if (!access(ErrOut)){
                print("stextract: old "//ErrOut//" deleted")
                if (LogLevel > 2)
                  print("stextract: old "//ErrOut//" deleted", >> LogFile)
              }
              else{
                print("stextract: ERROR: cannot delete "//ErrOut)
                print("stextract: ERROR: cannot delete "//ErrOut, >> LogFile)
                print("stextract: ERROR: cannot delete "//ErrOut, >> WarningFile)
                print("stextract: ERROR: cannot delete "//ErrOut, >> ErrorFile)
              }
            }# end if (access(ErrOut)){
          }# end for (i = 1; i <= NSubAps; i += 1){
        }# end if (NSubAps != 1){
      }# --- end if (fscan(ErrorList, ...))
      else{
        print("stextract: ERROR: fscan("//ErrorImages//", ErrIn) returned EOF!")
        print("stextract: ERROR: fscan("//ErrorImages//", ErrIn) returned EOF!", >> LogFile)
        print("stextract: ERROR: fscan("//ErrorImages//", ErrIn) returned EOF!", >> WarningFile)
        print("stextract: ERROR: fscan("//ErrorImages//", ErrIn) returned EOF!", >> ErrorFile)
      }
    }#end if (Objects && DoErrors)

    i = strlen(In)
    if (substr (In, i-strlen(ImType), i) == "."//ImType){
      OutName = substr(In, 1, i-strlen(ImType)-1)//"Ec."//ImType
    }
    else{
      OutName = In//"Ec."//ImType
    }
    print("stextract: processing "//In//", OutFile = "//OutName)
    if (LogLevel > 1)
      print("stextract: processing "//In//", OutFile = "//OutName, >> LogFile)

    apedit.interact=Interactive
    aprecenter.interact=Interactive
    apresize.interact=Interactive
    aptrace.interact=Interactive

    if (Slicer){
     if (LogLevel > 2)
       print("stextract: Slicer = YES, ResizeLowLimit = "//ResizeLowLimit//", ResizeHighLimit = "//ResizeHighLimit)
     apresize.llimit = ResizeLowLimit
     apresize.ulimit = ResizeHighLimit
     apresize.ylevel = INDEF
    }
    else{
     if (LogLevel > 2)
       print("stextract: Slicer = NO, ResizeYLevel = "//ResizeYLevel)
     apresize.llimit = ResizeLowLimit
     apresize.ulimit = ResizeHighLimit
     apresize.ylevel = ResizeYLevel
     apresize.peak   = YES
    }

    if (!access(In)){
      print("stextract: ERROR: cannot access input file "//In)
      print("stextract: ERROR: cannot access input file "//In, >> LogFile)
      print("stextract: ERROR: cannot access input file "//In, >> ErrorFile)
      print("stextract: ERROR: cannot access input file "//In, >> WarningFile)
# --- clean up
      if (Instrument == "echelle")
        echelle.logfile = bak_LogFile
      else
        kpnocoude.logfile = bak_LogFile
      InputList     = ""
      ParameterList = ""
      TimeList = ""
      delete (InFile, ver-)
      delete (ErrFile, ver-)
      return
    }# end if (!access(In)){
    if (Calibs){
      print("stextract: Reference = "//Reference)
    }
    else if (Objects){
      RefObsStr = ""
      for (j=1; j<=strlen(In); j+=1){
        if (substr(In,j,j) == "/")
          RefObsStr = ""
        else
          RefObsStr = RefObsStr//substr(In,j,j)
      }
      if (substr (RefObsStr, strlen(RefObsStr)-4, strlen(RefObsStr)) == "."//ImType){
        ReferenceObject = substr(RefObsStr,1,strlen(RefObsStr)-5)
      }
      else{
        ReferenceObject = RefObsStr
      }
      print("stextract: ReferenceObject = "//ReferenceObject)
      if (LogLevel > 2)
        print("stextract: ReferenceObject = "//ReferenceObject, >> LogFile)
    }# end else if (Objects)
    else{# --- neither calib nor object
      ReSize     = NO
      TempReSize = NO
    }
    print("stextract: Reference = "//Reference)
    if (LogLevel > 2)
      print("stextract: Reference = "//Reference, >> LogFile)

    if (!Objects){
      print("stextract: is not an object")
      apsum(input       = In,
            output      = OutName,
            apertur     = "",
            format      = Format,
            reference   = Reference,
            profile     = "",
            interactive = Interactive,
            find-,
            recenter    = ReCenter,
            resize      = ReSize,
            edit        = Edit,
            trace-,
            fittrace-,
            extract+,
            extras-,
            review-,
            line        = INDEF,
            nsum        = NSum,
            backgro     = "none",
            weights     = "none",
            pfit        = "fit1d",
            clean-,
            skybox      = 1,
            saturat     = Saturation,
            readnoise   = ReadNoise,
            gain        = Gain,
            lsigma      = LSigma,
            usigma      = USigma,
            nsubaps     = NSubAps)
    }# end if (!Objects){
# --- if Objects
    else{
      print("stextract: is object")
      if (LogLevel > 2)
        print("stextract: is object", >> LogFile)
      TempOut  = substr(Out,1,3)//"_temp."//ImType
      print("stextract: TempOut = "//TempOut)
      if (access(TempOut))
        del(TempOut, ver-)

      imcopy (In,TempOut)

      TempApFile = "database/ap"//substr(TempOut,1,strlen(TempOut)-5)
      print("stextract: TempApFile = "//TempApFile)
      if (LogLevel > 2)
        print("stextract: TempApFile = "//TempApFile, >> LogFile)
      if (access(TempApFile))
        del(TempApFile, ver-)

# --- check if resizing works
# --- ReCenter
      if (ReCenter){
        strecenter(images          = TempOut,
                   loglevel        = LogLevel,
		   reference       = Reference,
		   dispaxis        = DispAxis,
		   interactive     = Interactive,
		   line            = RecenterLine,
		   nsum            = RecenterNSum,
		   aprecenter      = RecenterApertures,
		   npeaks          = RecenterNPeaks,
		   shift           = RecenterShift,
		   width           = Width,
                   radius          = CenterRadius,
		   threshold       = RecenterThreshold,
		   ddapcenterlimit = RecenterDDApCenterLimit,
		   instrument      = Instrument,
		   logfile         = LogFile_strecenter,
		   warningfile     = WarningFile_strecenter,
		   errorfile       = ErrorFile_strecenter)
        if (access(LogFile_strecenter))
          cat(LogFile_strecenter, >> LogFile)
        if (access(WarningFile_strecenter))
          cat(WarningFile_strecenter, >> WarningFile)
        if (access(ErrorFile_strecenter)){
          cat(ErrorFile_strecenter, >> ErrorFile)
          print("stextract: ERROR: strecenter returned Error => Returning!")
          print("stextract: ERROR: strecenter returned Error => Returning!", >> LogFile)
          print("stextract: ERROR: strecenter returned Error => Returning!", >> WarningFile)
          print("stextract: ERROR: strecenter returned Error => Returning!", >> ErrorFile)
# --- clean up
          if (Instrument == "echelle")
            echelle.logfile = bak_LogFile
          else
            kpnocoude.logfile = bak_LogFile
          InputList     = ""
          ParameterList = ""
          TimeList = ""
          delete (InFile, ver-)
          delete (ErrFile, ver-)
          return
        }
#        apedit(input = TempOut,
#               aperture = "",
#               reference = Reference,
#               interact = Interactive,
#               find-,
#               recenter+,
#               resize-,
#               edit-,
#               line = INDEF,
#               nsum = 50,
#               width = Width,
#               radius = CenterRadius,
#               threshold = CenterThreshold)
      }
# --- ReSize
      if (ReSize){
        if (ReCenter)
          tempRef = ""
        else
          tempRef = Reference
        stresize(images      = TempOut,
                 loglevel    = LogLevel,
		 reference   = tempRef,
		 interactive = Interactive,
		 line        = ResizeLine,
		 nsum        = ResizeNSum,
		 lowlimit    = ResizeLowLimit,
		 highlimit   = ResizeHighLimit,
		 ylevel      = ResizeYLevel,
		 peak        = ResizePeak,
		 bkg         = ResizeBackground,
		 r_grow      = ResizeGrow,
		 avglimit    = ResizeAvgLimit,
		 aplowlimit  = ResizeApLowLimit,
		 aphighlimit = ResizeApHighLimit,
		 multlimit   = ResizeMultLimit,
		 instrument  = Instrument,
                 imtype      = ImType,
		 logfile     = LogFile_stresize,
		 warningfile = WarningFile_stresize,
		 errorfile   = ErrorFile_stresize)
#          apedit(input = TempOut,
#                 aperture = "",
#                 reference = tempRef,
#                 interact = Interactive,
#                 find-,
#                 recenter-,
#                 resize+,
#                 edit = Interactive,
#                 line = INDEF,
#                 nsum = 50,
#                 width = Width,
#                 radius = CenterRadius,
#                 threshold = CenterThreshold)
        if (access(LogFile_stresize))
          cat(LogFile_stresize, >> LogFile)
        if (access(WarningFile_stresize))
          cat(WarningFile_stresize, >> WarningFile)
        if (access(ErrorFile_stresize)){
          cat(ErrorFile_stresize, >> ErrorFile)
          print("stextract: ERROR: stresize returned Error => Returning!")
          print("stextract: ERROR: stresize returned Error => Returning!", >> LogFile)
          print("stextract: ERROR: stresize returned Error => Returning!", >> WarningFile)
          print("stextract: ERROR: stresize returned Error => Returning!", >> ErrorFile)
# --- clean up
          if (Instrument == "echelle")
            echelle.logfile = bak_LogFile
          else
            kpnocoude.logfile = bak_LogFile
          InputList     = ""
          ParameterList = ""
          TimeList = ""
          delete (InFile, ver-)
          delete (ErrFile, ver-)
          return
        }
      }# end if (ReSize)
      else{
        if (!ReCenter){
          apedit(input = TempOut,
                 aperture = "",
		 reference = Reference,
		 interact = Interactive,
		 find-,
		 recenter-,
		 resize-,
		 edit = Interactive,
		 line = INDEF,
		 nsum = 50,
		 width = Width,
		 radius = CenterRadius,
		 threshold = RecenterThreshold)
        }
      }# end if (!ReSize)
      if (Trace){
        sttrace(images      = TempOut,
                loglevel    = LogLevel,
                reference   = "",
                dispaxis    = DispAxis,
                interactive = Interactive,
                line        = trace_line,
                nsum        = trace_nsum,
                step        = trace_step,
                nlost       = trace_nlost,
                function    = trace_function,
                order       = trace_order,
                sample      = trace_sample,
                naverage    = trace_naverage,
                niterate    = trace_niterate,
                low_reject  = trace_low_reject,
                high_reject = trace_high_reject,
                grow        = trace_grow,
                yminlimit   = trace_yminlimit,
                ymaxlimit   = trace_ymaxlimit,
                instrument  = Instrument,
                logfile     = LogFile_sttrace,
                warningfile = WarningFile_sttrace,
                errorfile   = ErrorFile_sttrace)
        if (access(LogFile_sttrace))
          cat(LogFile_sttrace, >> LogFile)
        if (access(WarningFile_sttrace))
          cat(WarningFile_sttrace, >> WarningFile)
        if (access(ErrorFile_sttrace)){
          cat(ErrorFile_sttrace, >> ErrorFile)
          print("stextract: ERROR: sttrace returned Error => Returning!")
          print("stextract: ERROR: sttrace returned Error => Returning!", >> LogFile)
          print("stextract: ERROR: sttrace returned Error => Returning!", >> WarningFile)
          print("stextract: ERROR: sttrace returned Error => Returning!", >> ErrorFile)
# --- clean up
          if (Instrument == "echelle")
            echelle.logfile = bak_LogFile
          else
            kpnocoude.logfile = bak_LogFile
          InputList     = ""
          ParameterList = ""
          TimeList = ""
          delete (InFile, ver-)
          delete (ErrFile, ver-)
          return
        }

#        aptrace(input = TempOut,
#                aperture = "",
#                reference = "",
#                interact = Interactive,
#                find-,
#                recenter-,
#                resize-,
#                edit = Interactive,
#                trace+,
#                fittrace+,
#                line = trace_line,
#                nsum = trace_nsum,
#                step = trace_step,
#                nlost = trace_nlost,
#                function = trace_function,
#                order = trace_order,
#                sample = trace_sample,
#                naverage = trace_naverage,
#                niterate = trace_niterate,
#                low_rej = trace_low_reject,
#                high_rej = trace_high_reject,
#                grow = trace_grow)
      }# end if (Trace)

# --- check TempOut ApFile
      if (access(TempApFile)){
        ApList    = TempApFile
      }
      else{
        print("stextract: ERROR: cannot access "//TempApFile//"!!!")
        print("stextract: ERROR: cannot access "//TempApFile//"!!!", >> LogFile)
        print("stextract: ERROR: cannot access "//TempApFile//"!!!", >> WarningFile)
        print("stextract: ERROR: cannot access "//TempApFile//"!!!", >> ErrorFile)
# --- clean up
        if (Instrument == "echelle")
          echelle.logfile = bak_LogFile
        else
          kpnocoude.logfile = bak_LogFile
        InputList     = ""
        ParameterList = ""
        TimeList = ""
        delete (InFile, ver-)
        delete (ErrFile, ver-)
        return
      }# end if (!access(TempApFile)){

      strlastpos(In, "/")
      sp = strlastpos.pos
#      for (i=1; i<=strlen(In); i+=1){
#        if (substr(In,i,i) == "/")
#          sp = i
#      }
      ObjectApFile = ""
#      if (sp > 0)
#        ObjectApFile = substr(In,1,sp)
      ObjectApFile = "database/ap"
      pp = 0
      if (substr(In,strlen(In)-4,strlen(In)) == "."//ImType)
        pp = 5
      InRoot = ""
      for (p = sp+1; p <= strlen(In)-pp; p+=1){
        if (substr(In,p,p) == ":")
          InRoot = InRoot//"_"
        else
          InRoot = InRoot//substr(In,p,p)
      }
      ObjectApFile = ObjectApFile//InRoot
      print("stextract: ObjectApFile = "//ObjectApFile)
      if (LogLevel > 2)
        print("stextract: ObjectApFile = "//ObjectApFile, >> LogFile)
      if (access(ObjectApFile))
        del(ObjectApFile, ver-)

      ApFirst   = ""
      ApSecond  = ""
      ApThird   = ""
      ApFourth  = ""
      ApFith    = ""
      ApSixt    = ""

      while (fscan (ApList, ApFirst, ApSecond, ApThird, ApFourth, ApFith, ApSixt) != EOF){
        if (LogLevel > 2)
          print("stextract: "//TempApFile//": "//ApFirst//" "//ApSecond//" "//ApThird//" "//ApFourth//" "//ApFith//" "//ApSixt, >> LogFile)
# ---  begin	aperture refFlat 1 77.87693 1024.
        if (ApFirst == "begin"){
          print("stextract: "//TempApFile//": "//ApFirst//" "//ApSecond//" "//ApThird//" "//ApFourth//" "//ApFith//" "//ApSixt)
          iaperture = int(ApFourth)
          print(ApFirst//" "//ApSecond//" "//ReferenceObject//" "//ApFourth//" "//ApFith//" "//ApSixt, >> ObjectApFile)
        }
# --- image	refFlat
        else if (ApFirst == "image"){
          print(ApFirst//" "//ReferenceObject, >> ObjectApFile)
        }
# --- low	-29.35464 -1023.
        else if (ApFirst == "low"){
          print("stextract: "//TempApFile//": "//ApFirst//" "//ApSecond//" "//ApThird//" "//ApFourth//" "//ApFith//" "//ApSixt)
    # --- is low limit lower than ResizeApLowLimit?
          if (real(ApSecond) < ResizeApLowLimit){
            print(ApFirst//" "//ResizeApLowLimit/2.//" "//ApThird, >> ObjectApFile)
            print("stextract: WARNING: low limit for aperture "//iaperture//" was lower than "//ResizeApLowLimit//" => low set to ResizeApLowLimit/2.!")
            print("stextract: WARNING: low limit for aperture "//iaperture//" was lower than "//ResizeApLowLimit//" => low set to ResizeApLowLimit/2.!", >> LogFile)
            print("stextract: WARNING: low limit for aperture "//iaperture//" was lower than "//ResizeApLowLimit//" => low set to ResizeApLowLimit/2.!", >> WarningFile)
          }
          else{
            print(ApFirst//" "//ApSecond//" "//ApThird, >> ObjectApFile)
          }
        }
# --- high	30.08885 1024.
        else if (ApFirst == "high"){
          print("stextract: "//TempApFile//": "//ApFirst//" "//ApSecond//" "//ApThird//" "//ApFourth//" "//ApFith//" "//ApSixt)
    # --- is high limit greater than ResizeApHighLimit?
          if (real(ApSecond) > ResizeApHighLimit){
            print(ApFirst//" "//ResizeApHighLimit/2.//" "//ApThird, >> ObjectApFile)
            print("stextract: WARNING: high limit for aperture "//iaperture//" was greater than "//ResizeApHighLimit//" => high set to ResizeApHighLimit/2.!")
            print("stextract: WARNING: high limit for aperture "//iaperture//" was greater than "//ResizeApHighLimit//" => high set to ResizeApHighLimit/2.!", >> LogFile)
            print("stextract: WARNING: high limit for aperture "//iaperture//" was greater than "//ResizeApHighLimit//" => high set to ResizeApHighLimit/2.!", >> WarningFile)
          }
          else{
            print(ApFirst//" "//ApSecond//" "//ApThird, >> ObjectApFile)
          }
        }
        else{
          print(ApFirst//" "//ApSecond//" "//ApThird//" "//ApFourth//" "//ApFith//" "//ApSixt, >> ObjectApFile)
        }

        ApFirst  = ""
        ApSecond = ""
        ApThird  = ""
        ApFourth = ""
        ApFith   = ""
        ApSixt   = ""
      }# end while (fscan (ApList, ApFirst, ApSecond, ApThird, ApFourth, ApFith, ApSixt) != EOF){

# --- construct ProfileImage
# --- give ProfileImage a name
#      strlastpos(In, ".")
#      Pos = strlastpos.pos
#      if (Pos == 0)
#        Pos = strlen(In)+1
#      ProfileImage = substr(In,1,Pos-1)//"_prof"//substr(In,Pos,strlen(In))
#      if (access(ProfileImage))
#        del(ProfileImage, ver-)
#      apfit(input = In,
#            output = ProfileImage,
#	    fittype = "fit",
#	    apertures = "",
#	    references = "",
#	    interactive = Interactive,
#	    find-,
#	    recenter-,
#	    resize-,
#	    edit-,
#	    trace-,
#	    fittrace-,
#	    fit+,
#	    line = INDEF,
#	    nsum = NSum,
#	    threshold = DivisionThreshold,
#	    background = BackGround,
#	    pfit       = PFit,
#	    clean      = Clean,
#	    skybox     = SkyBox,
#	    saturation = Saturation,
#	    readnoise  = ReadNoise,
#	    gain       = Gain,
#	    lsigma     = LSigma,
#	    usigma     = USigma)
#
## --- construct RatioImage
## --- give RatioImage a name
#      strlastpos(In, ".")
#      Pos = strlastpos.pos
#      if (Pos == 0)
#        Pos = strlen(In)+1
#      RatioImage = substr(In,1,Pos-1)//"_ratio"//substr(In,Pos,strlen(In))
#      if (access(RatioImage))
#        del(RatioImage, ver-)
#      apfit(input = In,
#            output = RatioImage,
#	    fittype = "ratio",
#	    apertures = "",
#	    references = "",
#	    interactive = Interactive,
#	    find-,
#	    recenter-,
#	    resize-,
#	    edit-,
#	    trace-,
#	    fittrace-,
#	    fit+,
#	    line = INDEF,
#	    nsum = NSum,
#	    threshold  = DivisionThreshold,
#	    background = BackGround,
#	    pfit       = PFit,
#	    clean      = Clean,
#	    skybox     = SkyBox,
#	    saturation = Saturation,
#	    readnoise  = ReadNoise,
#	    gain       = Gain,
#	    lsigma     = LSigma,
#	    usigma     = USigma)
#
# --- extract apertures of input image <In> to <OutName>
      if (!Clean && Weights == "none" && PFit == "iterate")
        PFit = "fit1d"

      if ((Weights == "variance" || Clean) && PFit == "iterate"){
        DatabaseFileName = ObjectApFile
        OptextractFile = "scripts$tempexec"
        if (access(OptextractFile))
          del(OptextractFile, ver-)
        printf("optextract "//In//" "//DatabaseFileName//" "//OutName//" "//Gain//" "//ReadNoise//" ", >> OptextractFile)
        i = strlen(In)
        if (substr (In, i-strlen(ImType), i) == "."//ImType){
          In = substr(In, 1, i-strlen(ImType)-1)
        }
        printf(" SWATH_WIDTH="//IterSwathWidth, >> OptextractFile)
#        Parameters_optextract = "SWATH_WIDTH="//IterSwathWidth
#        if (fscan (ErrorList, ErrIn) == EOF){
#          print("stextract: ERROR: could not read name of error image")
#          return
#        }
        printf(" TELLURIC="//IterTelluric, >> OptextractFile)
        printf(" MAX_ITER_SF="//IterSfMaxIter, >> OptextractFile)
        printf(" MAX_ITER_SKY="//IterSkyMaxIter, >> OptextractFile)
        printf(" MAX_ITER_SIG="//IterSigMaxIter, >> OptextractFile)
        if (DoErrors){
          printf(" ERR_IN="//ErrIn, >> OptextractFile)
#          printf(" ERR_OUT_EC="//ErrOut, >> OptextractFile)
          printf(" ERR_FROM_PROFILE_OUT="//ErrOut, >> OptextractFile)
          if (MkErrIm){
            FN_ErrOut = ErrInRoot//"ItOut."//ImType
            printf(" ERR_OUT_2D="//FN_ErrOut, >> OptextractFile)
            if (access(FN_ErrOut))
              del(FN_ErrOut, ver-)
          }
        }
        if (MkProfIm){
          FN_ProfileImOut = In//"Prof."//ImType
          printf(" PROFILE_OUT="//FN_ProfileImOut, >> OptextractFile)
          if (access(FN_ProfileImOut))
            del(FN_ProfileImOut, ver-)
        }
        if (MkRecIm){
          FN_RecImOut = In//"Rec."//ImType
          printf(" IM_REC_OUT="//FN_RecImOut, >> OptextractFile)
          if (access(FN_RecImOut))
            del(FN_RecImOut, ver-)
        }
        if (MkMaskIm){
          FN_MaskImOut = In//"Mask."//ImType
          printf(" MASK_OUT="//FN_MaskImOut, >> OptextractFile)
          if (access(FN_MaskImOut))
            del(FN_MaskImOut, ver-)
        }
        if (IterTelluric > 0){
          FN_SkyImOut = In//"SkyEc."//ImType
          printf(" SKY_OUT_EC="//FN_SkyImOut, >> OptextractFile)
          if (access(FN_SkyImOut))
            del(FN_SkyImOut, ver-)

          FN_SkyErrImOut = In//"SkyErrEc."//ImType
          printf(" SKY_ERR_OUT_EC="//FN_SkyErrImOut, >> OptextractFile)
          if (access(FN_SkyErrImOut))
            del(FN_SkyErrImOut, ver-)

          if (MkSkyRecIm){
            FN_SkyRecImOut = In//"SkyRec."//ImType
            printf(" SKY_OUT_2D="//FN_SkyRecImOut, >> OptextractFile)
            if (access(FN_SkyRecImOut))
              del(FN_SkyRecImOut, ver-)
          }
          if (IterTelluric > 1){
            if (MkSPFitIm){
              FN_SPFitOut = In//"FitEc."//ImType
              printf(" SPFIT_OUT_EC="//FN_SPFitOut, >> OptextractFile)
              if (access(FN_SPFitOut))
                del(FN_SPFitOut, ver-)
            }
            if (MkRecFitIm){
              FN_RecFitOut = In//"RecFit."//ImType
              printf(" REC_FIT_OUT="//FN_RecFitOut, >> OptextractFile)
              if (access(FN_RecFitOut))
                del(FN_RecFitOut, ver-)
            }
          }
          if (MkSPFromProfIm){
            FN_SPFromProfOut = In//"EcProf."//ImType
            printf(" EC_FROM_PROFILE_OUT="//FN_SPFromProfOut, >> OptextractFile)
            if (access(FN_SPFromProfOut))
              del(FN_SPFromProfOut, ver-)
          }
        }
        printf("\n", >> OptextractFile)
        In = In//"."//ImType
        if (access(LogFile_makeprofile))
          del(LogFile_makeprofile, ver-)
        if (access(TimeFile))
          del(TimeFile, ver-)
        time(>> TimeFile)
        if (access(TimeFile)){
          TimeList = TimeFile
          if (fscan(TimeList,TempDay,TempTime,TempDate) != EOF){
            print("stextract: starting optextract("//In//","//DatabaseFileName//","//OutName//","//Gain//","//ReadNoise//",Parameters_optextract, >> LogFile_makeprofile): "//TempDate//"T"//TempTime)
            if (LogLevel > 1)
              print("stextract: starting optextract("//In//","//DatabaseFileName//","//OutName//","//Gain//","//ReadNoise//",Parameters_optextract, >> LogFile_makeprofile): "//TempDate//"T"//TempTime, >> LogFile)
          }
        }
        else{
          print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!")
          print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
          print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
        }
        if (access(headerfile))
          del(headerfile, ver-)
        imhead(In, imlist="*.fits", l+, u+, >> headerfile)
#        tempexec()
	#        optextract(In,DatabaseFileName,OutName,Gain,ReadNoise,Parameters_optextract, >> LogFile_makeprofile)
        TempFile = "pwd.out"
        pwd( >> TempFile)
        TimeList = TempFile
        if (fscan(TimeList, TempTime) == EOF){
          print("stextract: ERROR: Couldn't read "//TempFile)
          return
        }
        del(TimeFile, ver-)
	print("OptextractFile = <"//OptextractFile//">")
	chmod("a+x","~/stella/tempexec")
        tempexec()#>> LogFile_makeprofile)
	#        run_optextract(TempTime, LogFile_makeprofile)
        if (access(TimeFile))
          del(TimeFile, ver-)
        time(>> TimeFile)
        if (access(TimeFile)){
          TimeList = TimeFile
          if (fscan(TimeList,TempDay,TempTime,TempDate) != EOF){
            print("stextract: optextract("//In//","//DatabaseFileName//","//OutName//","//Gain//","//ReadNoise//", >> LogFile_makeprofile) finished: "//TempDate//"T"//TempTime)
            if (LogLevel > 1)
              print("stextract: optextract("//In//","//DatabaseFileName//","//OutName//","//Gain//","//ReadNoise//", >> LogFile_makeprofile) finished: "//TempDate//"T"//TempTime, >> LogFile)
          }
        }
        else{
          print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!")
          print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
          print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
        }
        cat(LogFile_makeprofile, >> LogFile)
        jobs
        wait()
        if (!access(OutName)){
          print("stextract: ERROR: Cannot access outfile "//OutName//" => Returning")
          print("stextract: ERROR: Cannot access outfile "//OutName//" => Returning", >> LogFile)
          print("stextract: ERROR: Cannot access outfile "//OutName//" => Returning", >> WarningFile)
          print("stextract: ERROR: Cannot access outfile "//OutName//" => Returning", >> ErrorFile)
# --- clean up
          if (Instrument == "echelle")
            echelle.logfile = bak_LogFile
          else
            kpnocoude.logfile = bak_LogFile
          InputList     = ""
          ParameterList = ""
          TimeList = ""
          delete (InFile, ver-)
          delete (ErrFile, ver-)
          return
        }
        i_nruns = 1;
        if (IterTelluric > 0){
          i_nruns = i_nruns + 2
          if (MkSPFitIm && IterTelluric > 1)
            i_nruns = i_nruns + 1
        }
        for (k=1;k<=i_nruns;k+=1){
          if (k == 1)
            TempString = OutName
          if (k == 2)
            TempString = FN_SkyImOut
          if (k == 3)
            TempString = FN_SkyErrImOut
          if (k == 4)
            TempString = FN_SPFitOut
          addheadertofitsfile(TempString, headerfile)
          apheaderfile = "aphead_"//In//".head"
          addheadertofitsfile(TempString, apheaderfile, 1)
          hedit(images=TempString,
                fields="WAT0_001",
                value = "system=equispec",
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="WAT1_001",
                value = "wtype=linear label=pixel",
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="WAT2_001",
                value = "wtype=linear",
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="CRPIX1",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="CRVAL1",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="CDELT1",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="CTYPE1",
                value = "PIXEL",
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="CRPIX2",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="CRVAL2",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="CDELT2",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="CTYPE2",
                value = "PIXEL",
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="CD1_1",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="CD2_2",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="LTM1_1",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="LTM2_2",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="LTV1",
                value = 0.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=TempString,
                fields="LTV2",
                value = 0.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)

#        print("stextract: starting makeprofile("//In//","//DatabaseFileName//","//ProfileImageName//","//Gain//","//ReadNoise//", >> LogFile_makeprofile)")
#        if (LogLevel > 1)
#        print("stextract: starting makeprofile("//In//","//DatabaseFileName//","//ProfileImageName//","//Gain//","//ReadNoise//", >> LogFile_makeprofile)", >> LogFile)
#        makeprofile(In,DatabaseFileName,ProfileImageName,Gain,ReadNoise)#, >> LogFile_makeprofile)
#        if (!access(ProfileImageName)){
#          print("stextract: ERROR: Cannot access ProfileImage "//ProfileImageName//" => Returning")
#          print("stextract: ERROR: Cannot access ProfileImage "//ProfileImageName//" => Returning", >> LogFile)
#          print("stextract: ERROR: Cannot access ProfileImage "//ProfileImageName//" => Returning", >> WarningFile)
#          print("stextract: ERROR: Cannot access ProfileImage "//ProfileImageName//" => Returning", >> ErrorFile)
## --- clean up
#          if (Instrument == "echelle")
#            echelle.logfile = bak_LogFile
#          else
#            kpnocoude.logfile = bak_LogFile
#          InputList     = ""
#          ParameterList = ""
#          TimeList = ""
#          delete (InFile, ver-)
#          delete (ErrFile, ver-)
#          return
#        }
#        apsum(input     = In,
#              output    = OutName,
#              apertur   = "",
#              format    = Format,
#              reference = ReferenceObject,
#              profile   = ProfileImageName,
#              interac   = Interactive,
#              find-,
#              recenter-,
#              resize-,
#              edit      = Interactive,
#              trace-,
#              fittrace+,
#              extract+,
#              extras    = Extras,
#              review-,
#              line      = INDEF,
#              nsum      = NSum,
#              backgro   = BackGround,
#              weights   = Weights,
#              pfit      = "fit1d",
#              clean     = Clean,
#              skybox    = SkyBox,
#              saturat   = Saturation,
#              readnoise = ReadNoise,
#              gain      = Gain,
#              lsigma    = LSigma,
#              usigma    = USigma,
#              nsubaps   = NSubAps)
        }
      }
      else{
        apsum(input     = In,
              output    = OutName,
              apertur   = "",
              format    = Format,
              reference = ReferenceObject,
              profile   = "",
              interac   = Interactive,
              find-,
              recenter-,
              resize-,
              edit      = Interactive,
              trace-,
              fittrace+,
              extract+,
              extras    = Extras,
              review-,
              line      = INDEF,
              nsum      = NSum,
              backgro   = BackGround,
              weights   = Weights,
              pfit      = PFit,
              clean     = Clean,
              skybox    = SkyBox,
              saturat   = Saturation,
              readnoise = ReadNoise,
              gain      = Gain,
              lsigma    = LSigma,
              usigma    = USigma,
              nsubaps   = NSubAps)
      }
# --- DoErrors
# --- TODO: calc_errors_from_profile for optimal extraction except of iterate
      if (DoErrors){
#        if ((Weights != "variance" && !Clean) &&
        if (PFit != "iterate"){
#  -- simple sum
          apsum(input = ErrIn,
                output = ErrOutName,
                apertur = "",
                format = Format,
                reference = InRoot,
                profile = "",
                interac-,
                find-,
                recenter-,
                resize-,
                edit-,
                trace-,
                fittrace+,
                extract+,
                extras-,
                review-,
                line=INDEF,
                nsum = NSum,
                backgro = BackGround,
                weights = "none",
                pfit = "fit1d",
                clean-,
                skybox = SkyBox,
                saturat = Saturation,
                readnoise = ReadNoise,
                gain = Gain,
                lsigma = LSigma,
                usigma = USigma,
                nsubaps = NSubAps)
          if (NSubAps == 1){
            if (Instrument == "echelle")
              ErrOut = ErrOutName
            else
              ErrOut = ErrOutRoot//".0001."//ImType
            if (access(ErrOut)){
              print("stextract: Error Output file "//ErrOut//" ready")
              if (LogLevel > 2)
                print("stextract: Error Output file "//ErrOut//" ready", >> LogFile)
            }
            else{
              print("stextract: ERROR: Error Output file "//ErrOut//" not accessable! => Returning")
              print("stextract: ERROR: Error Output file "//ErrOut//" not accessable! => Returning", >> LogFile)
              print("stextract: ERROR: Error Output file "//ErrOut//" not accessable! => Returning", >> WarningFile)
              print("stextract: ERROR: Error Output file "//ErrOut//" not accessable! => Returning", >> ErrorFile)
# --- clean up
              if (Instrument == "echelle")
                echelle.logfile = bak_LogFile
              else
                kpnocoude.logfile = bak_LogFile
              InputList     = ""
              ParameterList = ""
              TimeList = ""
              delete (InFile, ver-)
              delete (ErrFile, ver-)
              return
            }
          }# end if (NSubAps == 1){
          else{
            for (i = 1; i <= NSubAps; i += 1){
              ApNoStr = ""
              if (NSubAps > 99 && i < 100)
                ApNoStr = "0"
              if (NSubAps > 9 && i < 10)
                ApNoStr = ApNoStr//"0"
              ApNoStr = ApNoStr//i
              if (Format == "echelle")
                ErrOut = ErrOutRoot//ApNoStr//"."//ImType
              else
                ErrOut = ErrOutRoot//ApNoStr//"001."//ImType
              if (access(ErrOut)){
                print("stextract: Error Output file "//ErrOut//" ready")
                if (LogLevel > 2)
                  print("stextract: Error Output file "//ErrOut//" ready", >> LogFile)
              }
              else{
                print("stextract: ERROR: Error Output file "//ErrOut//" not accessable! => Returning")
                print("stextract: ERROR: Error Output file "//ErrOut//" not accessable! => Returning", >> LogFile)
                print("stextract: ERROR: Error Output file "//ErrOut//" not accessable! => Returning", >> WarningFile)
                print("stextract: ERROR: Error Output file "//ErrOut//" not accessable! => Returning", >> ErrorFile)
# --- clean up
                if (Instrument == "echelle")
                  echelle.logfile = bak_LogFile
                else
                  kpnocoude.logfile = bak_LogFile
                InputList     = ""
                ParameterList = ""
                TimeList = ""
                delete (InFile, ver-)
                delete (ErrFile, ver-)
                return
              }
            }# end for (i = 1; i <= NSubAps; i += 1){
          }# end if (NSubAps != 1){
        }#end if (!Clean && Weights == "none")
        #if (access(headerfile))
        #  del(headerfile, ver-)
        if (PFit == "iterate"){
        #  imhead(ErrOut, imlist="*.fits", l+, u+, >> headerfile)
          addheadertofitsfile(ErrOut, headerfile)
          addheadertofitsfile(ErrOut, apheaderfile, 1)
          hedit(images=ErrOut,
                fields="WAT0_001",
                value = "system=equispec",
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="WAT1_001",
                value = "wtype=linear label=pixel",
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="WAT2_001",
                value = "wtype=linear",
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="CRPIX1",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="CRVAL1",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="CDELT1",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="CTYPE1",
                value = "PIXEL",
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="CRPIX2",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="CRVAL2",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="CDELT2",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="CTYPE2",
                value = "PIXEL",
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="CD1_1",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="CD2_2",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="LTM1_1",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="LTM2_2",
                value = 1.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="LTV1",
                value = 0.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
          hedit(images=ErrOut,
                fields="LTV2",
                value = 0.,
                add+,
                addonly-,
                delete-,
                ver-,
                show+,
                update+)
        }
      }# end if (DoErrors)

      del(TempOut, ver-)
      del(TempApFile, ver-)
    }# --- end else if Objects

    for (i = 1; i <= NSubAps; i += 1){
      if (NSubAps > 2){
        ApNoStr = ""
        if (NSubAps > 99 && i < 100)
          ApNoStr = "0"
        if (NSubAps > 9 && i < 10)
          ApNoStr = ApNoStr//"0"
        ApNoStr = ApNoStr//i
        if (Format == "echelle")
          Out = OutRoot//ApNoStr//"."//ImType
        else
          Out = OutRoot//ApNoStr//"001."//ImType
      }# end if (NSubAps > 1)
      if (access(Out)){
        if (access(TimeFile))
          del(TimeFile, ver-)
        time(>> TimeFile)
        if (access(TimeFile)){
          TimeList = TimeFile
          if (fscan(TimeList,TempDay,TempTime,TempDate) != EOF){
            hedit(images=Out,
                  fields="STEXTRAC",
                  value="apertures extracted "//TempDate//"T"//TempTime,
                  add+,
                  addonly-,
                  del-,
                  ver-,
                  show+,
                  update+)
          }
        }
        else{
          print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!")
          print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
          print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
        }

        if (DelInput)
          imdel(In, ver-)
        if (DelInput && access(In))
          del(In, ver-)
        print("stextract: "//Out//" ready")
        if (LogLevel > 1)
          print("stextract: "//Out//" ready", >> LogFile)
      }# end if (access(Out)){
      else{
        print("stextract: ERROR: Output file "//Out//" not accessable! => Returning")
        print("stextract: ERROR: Output file "//Out//" not accessable! => Returning", >> LogFile)
        print("stextract: ERROR: Output file "//Out//" not accessable! => Returning", >> WarningFile)
        print("stextract: ERROR: Output file "//Out//" not accessable! => Returning", >> ErrorFile)
# --- clean up
        if (Instrument == "echelle")
          echelle.logfile = bak_LogFile
        else
          kpnocoude.logfile = bak_LogFile
        InputList     = ""
        ParameterList = ""
        TimeList = ""
        delete (InFile, ver-)
        delete (ErrFile, ver-)
        return
      }
    }# end (for i=1; i <= NSubAps; i++)
    print("stextract: -----------------------")
    print("stextract: -----------------------", >> LogFile)

  } # end of while(scan(InputList))

  if (access(TimeFile))
    del(TimeFile, ver-)
  time(>> TimeFile)
  if (access(TimeFile)){
    TimeList = TimeFile
    if (fscan(TimeList,TempDay,TempTime,TempDate) != EOF){
      print("stextract: stextract finished "//TempDate//"T"//TempTime, >> LogFile)
    }
  }
  else{
    print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!")
    print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
    print("stextract: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
  }

# --- clean up
  if (Instrument == "echelle")
    echelle.logfile = bak_LogFile
  else
    kpnocoude.logfile = bak_LogFile
  InputList     = ""
  ParameterList = ""
  ApList        = ""
  TimeList      = ""
  delete (InFile, ver-)
  delete (ErrFile, ver-)

end
