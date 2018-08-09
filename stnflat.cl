procedure stnflat (Input)

##################################################################
#                                                                #
# NAME:             stnflat.cl                                   #
# PURPOSE:          * normalises the combined master Flat by     #
#                     fitting the two-dimensional profile and    #
#                     leaves only the pixel-to-pixel sensitivity #
#                     variations                                 #
#                   * all pixels between the apertures are set   #
#                     to unity                                   #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stnflat(Input)                               #
# INPUTS:           Input: String                                #
#                     name of combined master Flat               #
#                     images to combine:                         #
#                       "combinedFlat.fits"                      #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     <NormalizedFlat>                           #
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

string Input          = "combinedFlat.fits"          {prompt="Flatfield image to normalize"}
string NormalizedFlat = "normalizedFlat.fits"        {prompt="Name of output image"}
string BlazeOut       = "combinedFlat_blaze.fits"    {prompt="Name of Blaze-function output file (pfit=iterate)"}
string ParameterFile  = "/home/azuri/stella/parameterfiles/parameterfile_WiFeS_red.prop"         {prompt="Name of ParameterFile"}
string Reference      = "refFlat"                    {prompt="Reference image"}
bool   Interactive = YES    {prompt="Flatten apertures interactively?"}
bool   DoRecenter  = YES    {prompt="Recenter apertures?"}
bool   DoResize    = NO     {prompt="Resize apertures?"}
bool   DoTrace     = NO     {prompt="Trace apertures?"}
bool   Slicer      = YES    {prompt="Does the instrument use an image slicer?"}
real   RdNoise     = 3.69   {prompt="Read out noise sigma (photons)"}
real   Gain        = 0.68   {prompt="Photon gain (photons/data number)"}
int    NMedian     = 20     {prompt="Number of pixels to medianfilter Blaze function"}
real   MinSNR      = 80.    {prompt="Minimum SNR to normalize"}
int    SwathWidth  = 300    {prompt="Swath width (0 to calculate)"}
int    recenter_line            = INDEF     {prompt="Dispersion line for the recenter task"}
int    recenter_nsum            = 20        {prompt="Number of dispersion lines to sum or median during the recenter task"}
string recenter_aprecenter      = ""        {prompt="Apertures for recentering calculation"}
int    recenter_npeaks          = INDEF     {prompt="Select brightest peaks for recentering calculation"}
bool   recenter_shift           = YES       {prompt="Use average shift instead of recentering?"}
real   recenter_ddapcenterlimit = 2.        {prompt="Maximum difference between ycenter's"}
int    resize_line              = INDEF {prompt="Dispersion line for the resize task"}
int    resize_nsum              = 10    {prompt="Number of dispersion lines to sum or median during the resize task"}
real   resize_ylevel            = 0.05  {prompt="Resize ylevel"}
real   resize_flats_lowlimit    = INDEF {prompt="Resize lower aperture limit for Flats"}
real   resize_flats_highlimit   = INDEF {prompt="Resize upper aperture limit for Flats"}
real   resize_flats_aplowlimit  = -9.5  {prompt="Minimum lower aperture limit for Flats"}
real   resize_flats_aphighlimit = 15.   {prompt="Maximum upper aperture limit for Flats"}
real   resize_multlimit         = 0.75  {prompt="Multiply limit by this factor is limit is exceeded"}
bool   resize_bkg               = NO    {prompt="Subtract background in automatic width?"}
real   resize_r_grow            = 0.    {prompt="Grow limits by this factor"}
bool   resize_avglimit          = NO    {prompt="Average limits over all apertures?"}
int    check_line      = INDEF {prompt="Dispersion line for the apcheck task"}
int    check_nsum      = 20    {prompt="Number of dispersion lines to sum or median during the check task"}
real   check_width     = 40.   {prompt="Profile centering width"}
real   check_radius    = 5.    {prompt="Profile centering radius"}
real   check_threshold = 100.  {prompt="Detection threshold intensity for profile centering"}
string dispaxis = "2"         {prompt="Dispersion axis (1-hor.,2-vert.)",
                                                          enum="1|2"}
int    trace_line     = INDEF {prompt="Starting dispersion line for tracing"}
int    trace_nsum     = 30    {prompt="Number of dispersion lines to sum for tracing"}
int    trace_step     = 5     {prompt="Tracing step"}
int    trace_nlost    = 10    {prompt="Number of consecutive times profile is lost before quitting"}
string trace_function = "legendre" {prompt="Trace fitting function (cheb|leg|spline1|spline3)",
                                     enum="chebyshev|legendre|spline1|spline3"}
int    trace_order    = 4     {prompt="Trace fitting function order"}
string trace_sample   = "*"   {prompt="Trace sample regions"}
int    trace_naverage = 1     {prompt="Trace average (pos) or median (neg)"}
int    trace_niterate = 2     {prompt="Trace rejection iterations"}
real   trace_low_reject  = 3. {prompt="Trace lower rejection sigma"}
real   trace_high_reject = 3. {prompt="Trace upper rejection sigma"}
real   trace_grow        = 0. {prompt="Trace rejection growing radius"}
real   trace_yminlimit   = -60.  {prompt="Minimum aperture position relative to center (pixels)"}
real   trace_ymaxlimit   = 60.   {prompt="Maximum aperture position relative to center (pixels)"}
real   flat_line       = INDEF   {prompt="Dispersion line for flattening spectra"}
int    flat_nsum       = 100     {prompt="Number of dispersion lines to sum or median"}
real   flat_threshold  = 1.      {prompt="Threshold for flattening spectra"}
string flat_pfit       = "fit1d" {prompt="Profile fitting type (fit1d|fit2d|iterate)",
                                   enum="fit1d|fit2d|iterate"}
bool   flat_clean      = YES     {prompt="Detect and replace bad pixels?"}
real   flat_saturation = INDEF   {prompt="Saturation level for flat"}
real   flat_lsigma     = 3.      {prompt="Lower rejection threshold for flattening spectra"}
real   flat_usigma     = 3.      {prompt="Upper rejection threshold for flattening spectra"}
string flat_function   = "cheb"  {prompt="Fitting function for normalization spectra",
                                   enum="chebyshev|legendre|spline1|spline3"}
int    flat_order      = 1       {prompt="Fitting function order for flattening spectra"}
string flat_sample = "1700:2300" {prompt="Sample regions for flattening spectra"}
int    flat_naverage     = 1     {prompt="Use average or median for flattening spectra"}
int    flat_niterate     = 5     {prompt="Number of rejection iterations for flattening spectra"}
real   flat_low_reject   = 0.    {prompt="Lower rejection sigma for flattening spectra"}
real   flat_high_reject  = 5.    {prompt="Upper rejection sigma for flattening spectra"}
real   flat_grow         = 0.    {prompt="Rejection growing radius for flattening spectra"}
string instrument     = "echelle" {prompt="Instrument (echelle|coude)",
                                    enum="echelle|coude"}
bool   delInput          = NO    {prompt="Delete input images after processing?"}
int    loglevel          = 3     {prompt="Level for writing logfile"}
string logfile     = "logfile_stnflat.log"  {prompt="Name of log file"}
string warningfile = "warnings_stnflat.log" {prompt="Name of warning file"}
string errorfile   = "errors_stnflat.log"   {prompt="Name of error file"}
string *parameterlist
string *timelist

begin

  real   ylevel,flats_lowlimit,flats_highlimit
  string bak_logfile,bak_logfile_apextract,databasefilename,format
  string logfile_strecenter          = "logfile_strecenter.log"
  string warningfile_strecenter      = "warnings_strecenter.log"
  string errorfile_strecenter        = "errors_strecenter.log"
  string logfile_stresize            = "logfile_stresize.log"
  string warningfile_stresize        = "warnings_stresize.log"
  string errorfile_stresize          = "errors_stresize.log"
  string logfile_sttrace            = "logfile_sttrace.log"
  string warningfile_sttrace        = "warnings_sttrace.log"
  string errorfile_sttrace          = "errors_sttrace.log"

  string tracelist     = "sttrace.list"
  string recenterlist  = "strecenter.list"
  string resizelist    = "stresize.list"
  string timefile = "time.txt"
  string tempday,tempdate,temptime
  string parameter,parametervalue,refflat,refstring
  bool   found_Reference                    = NO
  bool   found_nflat_Interactive            = NO
  bool   found_nflat_DoRecenter               = NO
  bool   found_nflat_DoResize                 = NO
#  bool   found_nflat_DoEdit                   = NO
  bool   found_nflat_DoTrace                  = NO
  bool   found_RdNoise                      = NO
  bool   found_Gain                         = NO
  bool   found_NMedian                      = NO
  bool   found_MinSNR                       = NO
  bool   found_SwathWidth                   = NO
  bool   found_Slicer                       = NO
  bool   found_nflat_recenter_line          = NO
  bool   found_nflat_recenter_nsum          = NO
  bool   found_nflat_recenter_aprecenter    = NO
  bool   found_nflat_recenter_npeaks        = NO
  bool   found_nflat_recenter_shift         = NO
  bool   found_nflat_recenter_ddapcenterlimit = NO
  bool   found_nflat_resize_line            = NO
  bool   found_nflat_resize_nsum            = NO
  bool   found_nflat_resize_ylevel          = NO
  bool   found_nflat_resize_flats_lower     = NO
  bool   found_nflat_resize_flats_upper     = NO
  bool   found_nflat_resize_flats_lowlimit  = NO
  bool   found_nflat_resize_flats_highlimit = NO
  bool   found_nflat_resize_bkg             = NO
  bool   found_nflat_resize_r_grow          = NO
  bool   found_nflat_resize_avglimit        = NO
  bool   found_nflat_resize_multlimit       = NO
  bool   found_nflat_check_line            = NO
  bool   found_nflat_check_nsum            = NO
  bool   found_nflat_check_width           = NO
  bool   found_nflat_check_radius          = NO
  bool   found_nflat_check_threshold       = NO
  bool   found_dispaxis           = NO
  bool   found_trace_line           = NO
  bool   found_trace_nsum           = NO
  bool   found_trace_step           = NO
  bool   found_trace_nlost          = NO
  bool   found_trace_function       = NO
  bool   found_trace_order          = NO
  bool   found_trace_sample         = NO
  bool   found_trace_naverage       = NO
  bool   found_trace_niterate       = NO
  bool   found_trace_low_reject     = NO
  bool   found_trace_high_reject    = NO
  bool   found_trace_grow           = NO
  bool   found_trace_yminlimit      = NO
  bool   found_trace_ymaxlimit      = NO
  bool   found_nflat_flat_line            = NO
  bool   found_nflat_flat_nsum            = NO
  bool   found_nflat_flat_threshold       = NO
  bool   found_nflat_flat_pfit            = NO
  bool   found_nflat_flat_clean           = NO
  bool   found_nflat_flat_saturation      = NO
  bool   found_nflat_flat_lsigma          = NO
  bool   found_nflat_flat_usigma          = NO
  bool   found_nflat_flat_function        = NO
  bool   found_nflat_flat_order           = NO
  bool   found_nflat_flat_sample          = NO
  bool   found_nflat_flat_naverage        = NO
  bool   found_nflat_flat_niterate        = NO
  bool   found_nflat_flat_low_reject      = NO
  bool   found_nflat_flat_high_reject     = NO
  bool   found_nflat_flat_grow            = NO
  bool   found_setinst_instrument         = NO

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)
  if (access(warningfile))
    delete(warningfile, ver-)
  if (access(errorfile))
    delete(errorfile, ver-)

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                      stnflat.cl                        *")
  print ("*      (normalizes combinedFlat.fits automatically)      *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*                      stnflat.cl                        *", >> logfile)
  print ("*      (normalizes combinedFlat.fits automatically)      *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- read ParameterFile
  if (access(ParameterFile)){
    print ("stnflat: **************** reading ParameterFile *******************")
    if (loglevel > 2)
      print ("stnflat: **************** reading ParameterFile *******************", >> logfile)

    parameterlist = ParameterFile

    while (fscan (parameterlist, parameter, parametervalue) != EOF){

#      if (parameter != "#")
#        print ("stnflat: parameter="//parameter//" value="//parametervalue, >> logfile)

      if (parameter == "reference"){
        Reference = parametervalue
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_Reference = YES
      }
      else if (parameter == "nflat_interactive"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          Interactive = YES
          print ("stnflat: Setting "//parameter//" to YES")
          if (loglevel > 2)
            print ("stnflat: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          Interactive = NO
          print ("stnflat: Setting "//parameter//" to NO")
          if (loglevel > 2)
            print ("stnflat: Setting "//parameter//" to NO", >> logfile)
        }
        found_nflat_Interactive = YES
      }
      else if (parameter == "rdnoise"){
        RdNoise = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//RdNoise)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//RdNoise, >> logfile)
        found_RdNoise = YES
      }
      else if (parameter == "gain"){
        Gain = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//Gain)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//Gain, >> logfile)
        found_Gain = YES
      }
      else if (parameter == "nflat_flat_nmedian"){
        NMedian = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//NMedian)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//NMedian, >> logfile)
        found_NMedian = YES
      }
      else if (parameter == "nflat_flat_minsnr"){
        MinSNR = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//MinSNR)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//MinSNR, >> logfile)
        found_MinSNR = YES
      }
      else if (parameter == "nflat_flat_swathwidth"){
        SwathWidth = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//SwathWidth)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//SwathWidth, >> logfile)
        found_SwathWidth = YES
      }
      else if (parameter == "nflat_recenter"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          DoRecenter = YES
	  print ("stnflat: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          DoRecenter = NO
	  print ("stnflat: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to NO", >> logfile)
        }
        found_nflat_DoRecenter = YES
      }
      else if (parameter == "nflat_resize"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          DoResize = YES
	  print ("stnflat: Setting "//parameter//" to YES")
	  if(loglevel > 2)
	    print ("stnflat: Setting "//parameter//" to YES", >> logfile)
	}
        else{
          DoResize = NO
	  print ("stnflat: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to NO", >> logfile)
	}
        found_nflat_DoResize = YES
      }
#      else if (parameter == "nflat_check"){
#        if (parametervalue == "YES" || parametervalue == "yes"){
#          DoEdit = YES
#	  print ("stnflat: Setting "//parameter//" to YES")
#	  if(loglevel > 2)
#            print ("stnflat: Setting "//parameter//" to YES", >> logfile)
#        }
#        else{
#          DoEdit = NO
#	  print ("stnflat: Setting "//parameter//" to NO")
#	  if(loglevel > 2)
#            print ("stnflat: Setting "//parameter//" to NO", >> logfile)
#        }
#        found_nflat_DoEdit = YES
#      }
      else if (parameter == "nflat_trace"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          DoTrace = YES
	  print ("stnflat: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to YES", >> logfile)
	}
        else{
          DoTrace = NO
	  print ("stnflat: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to NO", >> logfile)
	}
        found_nflat_DoTrace = YES
      }
      else if (parameter == "slicer"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          Slicer = YES
	  print ("stnflat: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          Slicer = NO
	  print ("stnflat: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to NO", >> logfile)
        }
        found_Slicer = YES
      }
      else if (parameter == "nflat_recenter_line"){
        if (parametervalue == "INDEF"){
          recenter_line = INDEF
          print ("stnflat: Setting "//parameter//" to INDEF")
          if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to INDEF", >> logfile)
        }
        else{
          recenter_line = int(parametervalue)
          print ("stnflat: Setting "//parameter//" to "//parametervalue)
          if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
        found_nflat_recenter_line = YES
      }
      else if (parameter == "nflat_recenter_nsum"){
        recenter_nsum = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_recenter_nsum = YES
      }
      else if (parameter == "nflat_recenter_aprecenter"){
        if (parametervalue == "-")
	  recenter_aprecenter = ""
	else
          recenter_aprecenter = parametervalue
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_recenter_aprecenter = YES
      }
      else if (parameter == "nflat_recenter_npeaks"){
        if (parametervalue == "INDEF")
          recenter_npeaks = INDEF
        else
          recenter_npeaks = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_recenter_npeaks = YES
      }
      else if (parameter == "nflat_recenter_shift"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          recenter_shift = YES
	  print ("stnflat: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          recenter_shift = NO
	  print ("stnflat: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to NO", >> logfile)
        }
        found_nflat_recenter_shift = YES
      }
      else if (parameter == "nflat_recenter_ddapcenterlimit"){
        recenter_ddapcenterlimit = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//recenter_ddapcenterlimit)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//recenter_ddapcenterlimit, >> logfile)
        found_nflat_recenter_ddapcenterlimit = YES
      }
      else if (parameter == "nflat_resize_line"){
        if (parametervalue == "INDEF")
          resize_line = INDEF
        else
          resize_line = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_resize_line = YES
      }
      else if (parameter == "nflat_resize_nsum"){
        resize_nsum = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_resize_nsum = YES
      }
      else if (parameter == "nflat_resize_ylevel"){
        if (parametervalue == "INDEF")
          resize_ylevel = INDEF
        else
          resize_ylevel = real(parametervalue)
        print ("stnflat: Setting nflat_resize_ylevel to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting nflat_resize_ylevel to "//parametervalue, >> logfile)
        found_nflat_resize_ylevel = YES
      }
      else if (parameter == "nflat_resize_flats_lower"){
        if (parametervalue == "INDEF")
          resize_flats_lowlimit = INDEF
        else
          resize_flats_lowlimit = real(parametervalue)
        print ("stnflat: Setting nflat_resize_flats_lowlimit to "//resize_flats_lowlimit)
        if(loglevel > 2)
          print ("stnflat: Setting nflat_resize_flats_lowlimit to "//resize_flats_lowlimit, >> logfile)
        found_nflat_resize_flats_lower = YES
      }
      else if (parameter == "nflat_resize_flats_upper"){
        if (parametervalue == "INDEF")
          resize_flats_highlimit = INDEF
        else
          resize_flats_highlimit = real(parametervalue)
        print ("stnflat: Setting nflat_resize_flats_highlimit to "//resize_flats_highlimit)
        if(loglevel > 2)
          print ("stnflat: Setting nflat_resize_flats_highlimit to "//resize_flats_highlimit, >> logfile)
        found_nflat_resize_flats_upper = YES
      }
      else if (parameter == "nflat_resize_flats_lowlimit"){
        if (parametervalue == "INDEF")
          resize_flats_aplowlimit = INDEF
        else
          resize_flats_aplowlimit = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//resize_flats_aplowlimit)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//resize_flats_aplowlimit, >> logfile)
        found_nflat_resize_flats_lowlimit = YES
      }
      else if (parameter == "nflat_resize_flats_highlimit"){
        if (parametervalue == "INDEF")
          resize_flats_aphighlimit = INDEF
        else
          resize_flats_aphighlimit = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//resize_flats_aphighlimit)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//resize_flats_aphighlimit, >> logfile)
        found_nflat_resize_flats_highlimit = YES
      }
      else if (parameter == "nflat_resize_multlimit"){
        if (parametervalue == "INDEF")
          resize_multlimit = INDEF
        else
          resize_multlimit = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_resize_multlimit = YES
      }
      else if (parameter == "nflat_resize_bkg"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          resize_bkg = YES
	  print ("stnflat: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          resize_bkg = NO
	  print ("stnflat: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to NO", >> logfile)
        }
        found_nflat_resize_bkg = YES
      }
      else if (parameter == "nflat_resize_r_grow"){
        resize_r_grow = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_resize_r_grow = YES
      }
      else if (parameter == "nflat_resize_avglimit"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          resize_avglimit = YES
	  print ("stnflat: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          resize_avglimit = NO
	  print ("stnflat: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stnflat: Setting "//parameter//" to NO", >> logfile)
        }
        found_nflat_resize_avglimit = YES
      }
      else if (parameter == "nflat_edit_line"){
        if (parametervalue == "INDEF")
          check_line = INDEF
        else
          check_line = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_check_line = YES
      }
      else if (parameter == "nflat_edit_nsum"){
        check_nsum = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_check_nsum = YES
      }
      else if (parameter == "nflat_edit_width"){
        if (parametervalue == "INDEF")
          check_width = INDEF
        else
          check_width = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_check_width = YES
      }
      else if (parameter == "nflat_edit_radius"){
        if (parametervalue == "INDEF")
          check_radius = INDEF
        else
          check_radius = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_check_radius = YES
      }
      else if (parameter == "nflat_edit_threshold"){
        if (parametervalue == "INDEF")
          check_threshold = INDEF
        else
          check_threshold = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_check_threshold = YES
      }
      else if (parameter == "dispaxis"){
        dispaxis = parametervalue
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_dispaxis  = YES
      }
      else if (parameter == "trace_line"){
        if (parametervalue == "INDEF")
          trace_line = INDEF
        else
          trace_line = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_line  = YES
      }
      else if (parameter == "trace_nsum"){
        trace_nsum = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_nsum = YES
      }
      else if (parameter == "trace_step"){
        trace_step = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_step = YES
      }
      else if (parameter == "trace_nlost"){
        trace_nlost = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_nlost = YES
      }
      else if (parameter == "trace_function"){
        trace_function = parametervalue
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_function = YES
      }
      else if (parameter == "trace_order"){
        trace_order = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_order = YES
      }
      else if (parameter == "trace_sample"){
        trace_sample = parametervalue
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_sample = YES
      }
      else if (parameter == "trace_naverage"){
        trace_naverage = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_naverage = YES
      }
      else if (parameter == "trace_niterate"){
        trace_niterate = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_niterate = YES
      }
      else if (parameter == "trace_low_reject"){
        if (parametervalue == "INDEF")
          trace_low_reject = INDEF
        else
          trace_low_reject = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_low_reject = YES
      }
      else if (parameter == "trace_high_reject"){
        if (parametervalue == "INDEF")
          trace_high_reject = INDEF
        else
          trace_high_reject = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_high_reject = YES
      }
      else if (parameter == "trace_grow"){
        trace_grow = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_grow = YES
      }
      else if (parameter == "trace_yminlimit"){
        trace_yminlimit = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_yminlimit = YES
      }
      else if (parameter == "trace_ymaxlimit"){
        trace_ymaxlimit = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_ymaxlimit = YES
      }
      else if (parameter == "nflat_flat_line"){
        if (parametervalue == "INDEF"){
          flat_line = INDEF
          print ("stnflat: Setting "//parameter//" to INDEF")
          if (loglevel > 2)
            print ("stnflat: Setting "//parameter//" to INDEF", >> logfile)
        }
        else{
          flat_line = int(parametervalue)
          print ("stnflat: Setting "//parameter//" to "//flat_line)
          if (loglevel > 2)
            print ("stnflat: Setting "//parameter//" to "//flat_line, >> logfile)
        }
        found_nflat_flat_line = YES
      }
      else if (parameter == "nflat_flat_nsum"){
        flat_nsum = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//flat_nsum)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//flat_nsum, >> logfile)
        found_nflat_flat_nsum = YES
      }
      else if (parameter == "nflat_flat_threshold"){
        flat_threshold = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//flat_threshold)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//flat_threshold, >> logfile)
        found_nflat_flat_threshold = YES
      }
      else if (parameter == "nflat_flat_pfit"){
        if (parametervalue == "fit1d" || parametervalue == "fit2d" || parametervalue == "iterate"){
          flat_pfit = parametervalue
          print ("stnflat: setting "//parameter//" to "//flat_pfit)
          if (loglevel > 2)
            print ("stnflat: setting "//parameter//" to "//flat_pfit, >> logfile)
        }
        else{
          print ("nflat: WARNING: nflat_pfit: parametervalue ("//parametervalue//") not equal to fit1d, fit2d, or iterate!!! -> using standard parametervalue ("//flat_pfit//")")
          print ("nflat: WARNING: nflat_pfit: parametervalue ("//parametervalue//") not equal to fit1d, fit2d, or iterate!!! -> using standard parametervalue ("//flat_pfit//")", >> logfile)
          print ("nflat: WARNING: nflat_pfit: parametervalue ("//parametervalue//") not equal to fit1d, fit2d, or iterate!!! -> using standard parametervalue ("//flat_pfit//")", >> warningfile)
        }
        found_nflat_flat_pfit = YES
      }
      else if (parameter == "blaze_fit"){
        if (parametervalue == "NO" || parametervalue == "no"){
          flat_pfit = "iterate"
          print ("stnflat: blaze_fit == NO => Setting flat_pfit to iterate")
          if (loglevel > 2)
            print ("stnflat: blaze_fit == NO => Setting flat_pfit to iterate", >> logfile)
        }
      }
      else if (parameter == "nflat_flat_clean"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          flat_clean = YES
          print ("stnflat: Setting "//parameter//" to YES")
          if (loglevel > 2)
            print ("stnflat: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          flat_clean = NO
          print ("stnflat: Setting "//parameter//" to NO")
          if (loglevel > 2)
            print ("stnflat: Setting "//parameter//" to NO", >> logfile)
        }
        found_nflat_flat_clean = YES
      }
      else if (parameter == "nflat_flat_saturation"){
        if (parametervalue == "INDEF"){
          flat_saturation = INDEF
          print ("stnflat: Setting "//parameter//" to INDEF")
          if (loglevel > 2)
            print ("stnflat: Setting "//parameter//" to INDEF", >> logfile)
        }
        else{
          flat_saturation = real(parametervalue)
          print ("stnflat: Setting "//parameter//" to "//flat_saturation)
          if (loglevel > 2)
            print ("stnflat: Setting "//parameter//" to "//flat_saturation, >> logfile)
        }
        found_nflat_flat_saturation = YES
      }
      else if (parameter == "nflat_flat_lsigma"){
        flat_lsigma = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//flat_lsigma)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//flat_lsigma, >> logfile)
        found_nflat_flat_lsigma = YES
      }
      else if (parameter == "nflat_flat_usigma"){
        flat_usigma = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//flat_usigma)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//flat_usigma, >> logfile)
        found_nflat_flat_usigma = YES
      }
      else if (parameter == "nflat_flat_function"){
        flat_function = parametervalue
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_flat_function = YES
      }
      else if (parameter == "nflat_flat_order"){
        flat_order = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//flat_order)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//flat_order, >> logfile)
        found_nflat_flat_order = YES
      }
      else if (parameter == "nflat_flat_sample"){
        flat_sample = parametervalue
        print ("stnflat: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nflat_flat_sample = YES
      }
      else if (parameter == "nflat_flat_naverage"){
        flat_naverage = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//flat_naverage)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//flat_naverage, >> logfile)
        found_nflat_flat_naverage = YES
      }
      else if (parameter == "nflat_flat_niterate"){
        flat_niterate = int(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//flat_niterate)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//flat_niterate, >> logfile)
        found_nflat_flat_niterate = YES
      }
      else if (parameter == "nflat_flat_low_reject"){
        if (parametervalue == "INDEF")
          flat_low_reject = INDEF
        else
          flat_low_reject = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//flat_low_reject)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//flat_low_reject, >> logfile)
        found_nflat_flat_low_reject = YES
      }
      else if (parameter == "nflat_flat_high_reject"){
        if (parametervalue == "INDEF")
          flat_high_reject = INDEF
        else
          flat_high_reject = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//flat_high_reject)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//flat_high_reject, >> logfile)
        found_nflat_flat_high_reject = YES
      }
      else if (parameter == "nflat_flat_grow"){
        flat_grow = real(parametervalue)
        print ("stnflat: Setting "//parameter//" to "//flat_grow)
        if (loglevel > 2)
          print ("stnflat: Setting "//parameter//" to "//flat_grow, >> logfile)
        found_nflat_flat_grow = YES
      }
      else if (parameter == "setinst_instrument"){
        if (parametervalue == "echelle" || parametervalue == "coude"){
          instrument = parametervalue
          print ("stnflat: Setting "//parameter//" to "//parametervalue)
          if (loglevel > 2)
            print ("stnflat: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
        else{
          print ("stnflat: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value")
          print ("stnflat: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value", >> logfile)
          print ("stnflat: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value", >> warningfile)
        }
        found_setinst_instrument = YES
      }
    }#end while
    if (!found_Reference){
      print("stnflat: WARNING: parameter reference not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter reference not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter reference not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_Interactive){
      print("stnflat: WARNING: parameter nflat_interactive not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_interactive not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_interactive not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_RdNoise){
      print("stnflat: WARNING: parameter rdnoise not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter rdnoise not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter rdnoise not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_Gain){
      print("stnflat: WARNING: parameter gain not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter gain not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter gain not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_NMedian){
      print("stnflat: WARNING: parameter nflat_flat_nmedian not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_nmedian not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_nmedian not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_MinSNR){
      print("stnflat: WARNING: parameter nflat_flat_minsnr not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_minsnr not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_minsnr not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_SwathWidth){
      print("stnflat: WARNING: parameter nflat_flat_swathwidth not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_swathwidth not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_swathwidth not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_DoRecenter){
      print("stnflat: WARNING: parameter nflat_recenter not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_recenter not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_recenter not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_DoResize){
      print("stnflat: WARNING: parameter nflat_resize not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize not found in ParameterFile!!! -> using standard", >> warningfile)
    }
#    if (!found_nflat_DoEdit){
#      print("stnflat: WARNING: parameter nflat_edit not found in ParameterFile!!! -> using standard")
#      print("stnflat: WARNING: parameter nflat_edit not found in ParameterFile!!! -> using standard", >> logfile)
#      print("stnflat: WARNING: parameter nflat_edit not found in ParameterFile!!! -> using standard", >> warningfile)
#    }
    if (!found_nflat_DoTrace){
      print("stnflat: WARNING: parameter nflat_trace not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_trace not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_trace not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_Slicer){
      print("stnflat: WARNING: parameter slicer not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter slicer not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter slicer not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_recenter_line){
      print("stnflat: WARNING: parameter nflat_recenter_line not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_recenter_line not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_recenter_line not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_recenter_nsum){
      print("stnflat: WARNING: parameter nflat_recenter_nsum not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_recenter_nsum not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_recenter_nsum not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_recenter_aprecenter){
      print("stnflat: WARNING: parameter nflat_recenter_aprecenter not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_recenter_aprecenter not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_recenter_aprecenter not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_recenter_npeaks){
      print("stnflat: WARNING: parameter nflat_recenter_npeaks not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_recenter_npeaks not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_recenter_npeaks not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_recenter_shift){
      print("stnflat: WARNING: parameter nflat_recenter_shift not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_recenter_shift not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_recenter_shift not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_recenter_ddapcenterlimit){
      print("stnflat: WARNING: parameter nflat_recenter_ddapcenterlimit not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_recenter_ddapcenterlimit not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_recenter_ddapcenterlimit not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_line){
      print("stnflat: WARNING: parameter nflat_resize_line not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_line not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_line not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_nsum){
      print("stnflat: WARNING: parameter nflat_resize_nsum not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_nsum not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_nsum not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_ylevel){
      print("stnflat: WARNING: parameter nflat_resize_ylevel not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_ylevel not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_ylevel not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_flats_lower){
      print("stnflat: WARNING: parameter nflat_resize_flats_lower not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_flats_lower not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_flats_lower not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_flats_upper){
      print("stnflat: WARNING: parameter nflat_resize_flats_upper not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_flats_upper not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_flats_upper not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_flats_lowlimit){
      print("stnflat: WARNING: parameter nflat_resize_flats_lowlimit not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_flats_lowlimit not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_flats_lowlimit not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_flats_highlimit){
      print("stnflat: WARNING: parameter nflat_resize_flats_highlimit not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_flats_highlimit not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_flats_highlimit not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_multlimit){
      print("stnflat: WARNING: parameter nflat_resize_multlimit not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_multlimit not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_multlimit not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_bkg){
      print("stnflat: WARNING: parameter nflat_resize_bkg not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_bkg not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_bkg not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_r_grow){
      print("stnflat: WARNING: parameter nflat_resize_r_grow not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_r_grow not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_r_grow not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_resize_avglimit){
      print("stnflat: WARNING: parameter nflat_resize_avglimit not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_resize_avglimit not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_resize_avglimit not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_check_line){
      print("stnflat: WARNING: parameter nflat_edit_line not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_edit_line not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_edit_line not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_check_nsum){
      print("stnflat: WARNING: parameter nflat_edit_nsum not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_edit_nsum not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_edit_nsum not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_check_width){
      print("stnflat: WARNING: parameter nflat_edit_width not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_edit_width not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_edit_width not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_check_radius){
      print("stnflat: WARNING: parameter nflat_edit_radius not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_edit_radius not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_edit_radius not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_check_threshold){
      print("stnflat: WARNING: parameter nflat_edit_threshold not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_edit_threshold not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_edit_threshold not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_dispaxis){
      print("stnflat: WARNING: parameter dispaxis not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter dispaxis not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter dispaxis not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_line){
      print("stnflat: WARNING: parameter trace_line not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_line not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_line not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_nsum){
      print("stnflat: WARNING: parameter trace_nsum not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_nsum not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_nsum not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_step){
      print("stnflat: WARNING: parameter trace_step not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_step not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_step not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_nlost){
      print("stnflat: WARNING: parameter trace_nlost not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_nlost not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_nlost not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_function){
      print("stnflat: WARNING: parameter trace_function not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_function not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_function not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_order){
      print("stnflat: WARNING: parameter trace_order not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_order not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_order not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_sample){
      print("stnflat: WARNING: parameter trace_sample not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_sample not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_sample not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_naverage){
      print("stnflat: WARNING: parameter trace_naverage not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_naverage not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_naverage not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_niterate){
      print("stnflat: WARNING: parameter trace_niterate not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_niterate not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_niterate not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_low_reject){
      print("stnflat: WARNING: parameter trace_low_reject not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_low_reject not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_low_reject not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_high_reject){
      print("stnflat: WARNING: parameter trace_high_reject not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_high_reject not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_high_reject not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_grow){
      print("stnflat: WARNING: parameter trace_grow not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_grow not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_grow not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_yminlimit){
      print("stnflat: WARNING: parameter trace_yminlimit not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_yminlimit not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_yminlimit not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_ymaxlimit){
      print("stnflat: WARNING: parameter trace_ymaxlimit not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter trace_ymaxlimit not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter trace_ymaxlimit not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_line){
      print("stnflat: WARNING: parameter nflat_flat_line not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_line not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_line not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_nsum){
      print("stnflat: WARNING: parameter nflat_nsum not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_nsum not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_nsum not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_threshold){
      print("stnflat: WARNING: parameter nflat_flat_threshold not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_threshold not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_threshold not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_pfit){
      print("stnflat: WARNING: parameter nflat_pfit not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_pfit not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_pfit not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_clean){
      print("stnflat: WARNING: parameter nflat_flat_clean not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_clean not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_clean not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_saturation){
      print("stnflat: WARNING: parameter nflat_flat_saturation not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_saturation not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_saturation not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_lsigma){
      print("stnflat: WARNING: parameter nflat_flat_lsigma not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_lsigma not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_lsigma not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_usigma){
      print("stnflat: WARNING: parameter nflat_flat_usigma not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_usigma not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_usigma not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_function){
      print("stnflat: WARNING: parameter nflat_flat_function not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_function not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_function not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_order){
      print("stnflat: WARNING: parameter nflat_flat_order not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_order not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_order not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_sample){
      print("stnflat: WARNING: parameter nflat_flat_sample not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_sample not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_sample not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_naverage){
      print("stnflat: WARNING: parameter nflat_flat_naverage not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_naverage not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_naverage not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_niterate){
      print("stnflat: WARNING: parameter nflat_flat_niterate not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_niterate not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_niterate not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_low_reject){
      print("stnflat: WARNING: parameter nflat_flat_low_reject not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_low_reject not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_low_reject not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_high_reject){
      print("stnflat: WARNING: parameter nflat_flat_high_reject not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_high_reject not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_high_reject not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_nflat_flat_grow){
      print("stnflat: WARNING: parameter nflat_flat_grow not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter nflat_flat_grow not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter nflat_flat_grow not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_setinst_instrument){
      print("stnflat: WARNING: parameter setinst_instrument not found in ParameterFile!!! -> using standard")
      print("stnflat: WARNING: parameter setinst_instrument not found in ParameterFile!!! -> using standard", >> logfile)
      print("stnflat: WARNING: parameter setinst_instrument not found in ParameterFile!!! -> using standard", >> warningfile)
    }
  }
  else{
    print("stnflat: WARNING: ParameterFile not found!!! -> using standard parameters")
    print("stnflat: WARNING: ParameterFile not found!!! -> using standard parameters", >> logfile)
    print("stnflat: WARNING: ParameterFile not found!!! -> using standard parameters", >> warningfile)
  }

# --- set logfile
  if (instrument == "echelle"){
    echelle
    bak_logfile = echelle.logfile
    echelle.logfile = logfile
    print ("stnflat: package 'echelle' loaded")
    format = "echelle"
  }
  else{
    kpnocoude
    bak_logfile = kpnocoude.logfile
    kpnocoude.logfile = logfile
    print ("stnflat: package 'kpnocoude' loaded")
    print ("stnflat: bak_logfile = "//bak_logfile)
    format = "onedspec"
  }
  twodspec
  apextract
  bak_logfile_apextract = apextract.logfile
  apextract.logfile = logfile
  print ("stnflat: package 'twodspec.apextract' loaded")

#  print("stnflat: substr(Reference,strlen(Reference)-4,strlen(Reference)) == "//substr(Reference,strlen(Reference)-4,strlen(Reference)))
#  print("stnflat: substr(Reference,1,strlen(Reference)-5) = "//substr(Reference,1,strlen(Reference)-5))

  refflat = ""
#  refwave = ""
  refstring = ""
  for(i=1;i<=strlen(Reference);i=i+1){
    if (substr(Reference,i,i) == "/")
      refstring = ""
    else
      refstring = refstring//substr(Reference,i,i)
  }
  refflat = refstring
  if (substr(refflat,1,2) == "ap")
    refflat = substr(refflat,3,strlen(refflat))
  if (substr(refflat,strlen(refflat)-4,strlen(refflat)) == ".fits")
    refflat = substr(refflat,1,strlen(refflat)-5)
  if (!access("database/ap"//refflat)){
    print("stnflat: ERROR: no reference aperture definition for "//refflat//" found!!!")
    print("stnflat: ERROR: no reference aperture definition for "//refflat//" found!!!", >> logfile)
    print("stnflat: ERROR: no reference aperture definition for "//refflat//" found!!!", >> errorfile)
    print("stnflat: ERROR: no reference aperture definition for "//refflat//" found!!!", >> warningfile)
# --- clean up
    if (instrument == "echelle")
      echelle.logfile = bak_logfile
    else
      kpnocoude.logfile = bak_logfile
    apextract.logfile = bak_logfile_apextract

    parameterlist = ""
    timelist = ""

    return
  }

# --- delete output
  if (access(NormalizedFlat)){
    imdel(NormalizedFlat, ver-)
    if (access(NormalizedFlat))
      del(NormalizedFlat,ver-)
    if (!access(NormalizedFlat)){
      print("stnflat: old "//NormalizedFlat//" deleted")
      if (loglevel > 2)
        print("stnflat: old "//NormalizedFlat//" deleted", >> logfile)
    }
    else{
      print("stnflat: ERROR: cannot delete "//NormalizedFlat)
      print("stnflat: ERROR: cannot delete "//NormalizedFlat, >> logfile)
      print("stnflat: ERROR: cannot delete "//NormalizedFlat, >> warningfile)
      print("stnflat: ERROR: cannot delete "//NormalizedFlat, >> errorfile)
# --- clean up
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      apextract.logfile = bak_logfile_apextract

      parameterlist = ""
      timelist = ""

      return
    }
  }

# --- set parameters
  if (loglevel > 2)
    print("stnflat: setting apresize parameters", >> logfile)

  apdefault.lower       = resize_flats_lowlimit
  apdefault.upper       = resize_flats_highlimit

  aprecenter.line       = recenter_line
  aprecenter.nsum       = recenter_nsum
  aprecenter.aprecenter = recenter_aprecenter
  aprecenter.npeaks     = recenter_npeaks
  aprecenter.shift      = recenter_shift

#  apresize.line     = resize_line
#  apresize.nsum     = resize_nsum
  if (Slicer){
    ylevel = INDEF
    flats_lowlimit = resize_flats_lowlimit
    flats_highlimit = resize_flats_highlimit
  }
  else{
    ylevel = resize_ylevel
    flats_lowlimit = resize_flats_lowlimit
    flats_highlimit = resize_flats_highlimit
  }
#  apresize.ylevel   = resize_ylevel
#  apresize.peak     = YES
#  apresize.llimit   = resize_flats_lowlimit
#  apresize.ulimit   = resize_flats_highlimit
#  apresize.bkg      = resize_bkg
#  apresize.r_grow   = resize_r_grow
#  apresize.avglimit = resize_avglimit

  apedit.line      = check_line
  apedit.nsum      = check_nsum
  apedit.width     = check_width
  apedit.radius    = check_radius
  apedit.threshold = check_threshold

# --- assign reference aperture-data to combinedFlat
  aprecenter.interact = Interactive
  apresize.interact   = Interactive
  aptrace.interactive = Interactive

  if (!access(Input)){
    print("stnflat: ERROR: cannot access "//Input)
    print("stnflat: ERROR: cannot access "//Input, >> logfile)
    print("stnflat: ERROR: cannot access "//Input, >> warningfile)
    print("stnflat: ERROR: cannot access "//Input, >> errorfile)
# --- clean up
    if (instrument == "echelle")
      echelle.logfile = bak_logfile
    else
      kpnocoude.logfile = bak_logfile
    apextract.logfile = bak_logfile_apextract

    parameterlist = ""
    timelist = ""

    return
  }
  apedit(input       = Input,
	 apertur     = "",
	 reference   = refflat,
	 interactive = Interactive,
	 find-,
	 recenter-,
	 resize-,
	 edit        = Interactive)

# --- recenter apertures
  if (DoRecenter){
    if (access(recenterlist))
      delete(recenterlist, ver-)
    print(Input, >> recenterlist)
    strecenter(images          = "@"//recenterlist,
	       loglevel        = loglevel,
	       reference       = "",
               dispaxis        = dispaxis,
	       interactive     = Interactive,
	       line            = recenter_line,
	       nsum            = recenter_nsum,
               aprecenter      = recenter_aprecenter,
               npeaks          = recenter_npeaks,
               shift           = recenter_shift,
               width           = check_width,
               radius          = check_radius,
               threshold       = check_threshold,
               ddapcenterlimit = recenter_ddapcenterlimit,
               instrument      = instrument,
	       logfile         = logfile_strecenter,
	       warningfile     = warningfile_strecenter,
	       errorfile       = errorfile_strecenter,
               instrument      = instrument)
    if (access(logfile_strecenter))
      cat(logfile_strecenter, >> logfile)
    if (access(warningfile_strecenter))
      cat(warningfile_strecenter, >> warningfile)
    if (access(errorfile_strecenter)){
      cat(errorfile_strecenter, >> errorfile)
      print("stnflat: ERROR: strecenter returned with error => Returning")
      print("stnflat: ERROR: strecenter returned with error => Returning", >> logfile)
      print("stnflat: ERROR: strecenter returned with error => Returning", >> warningfile)
      print("stnflat: ERROR: strecenter returned with error => Returning", >> errorfile)
# --- clean up
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      apextract.logfile = bak_logfile_apextract

      parameterlist = ""
      timelist = ""

      return
    }
  }
# --- resize apertures
  if (DoResize){
    if (access(resizelist))
      delete(resizelist, ver-)
    print(Input, >> resizelist)
    stresize(images      = "@"//resizelist,
	     loglevel    = loglevel,
	     reference   = "",
	     interactive = Interactive,
	     line        = resize_line,
	     nsum        = resize_nsum,
	     ylevel      = ylevel,
	     lowlimit    = flats_lowlimit,
	     highlimit   = flats_highlimit,
	     aplowlimit  = resize_flats_aplowlimit,
	     aphighlimit = resize_flats_aphighlimit,
	     multlimit   = resize_multlimit,
	     bkg         = resize_bkg,
	     r_grow      = resize_r_grow,
	     avglimit    = resize_avglimit,
	     logfile     = logfile_stresize,
	     warningfile = warningfile_stresize,
	     errorfile   = errorfile_stresize,
	     instrument  = instrument)
    if (access(logfile_stresize))
      cat(logfile_stresize, >> logfile)
    if (access(warningfile_stresize))
      cat(warningfile_stresize, >> warningfile)
    if (access(errorfile_stresize)){
      cat(errorfile_stresize, >> errorfile)
      print("stnflat: ERROR: stresize returned with error => Returning")
      print("stnflat: ERROR: stresize returned with error => Returning", >> logfile)
      print("stnflat: ERROR: stresize returned with error => Returning", >> warningfile)
      print("stnflat: ERROR: stresize returned with error => Returning", >> errorfile)
# --- clean up
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      apextract.logfile = bak_logfile_apextract

      parameterlist = ""
      timelist = ""

      return
    }
  }
# --- trace apertures
  if (DoTrace){
    if (access(tracelist))
      delete(tracelist, ver-)
    print(Input, >> tracelist)
    sttrace(images      = "@"//tracelist,
	    loglevel    = loglevel,
	    reference   = "",
	    dispaxis    = dispaxis,
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
	    logfile     = logfile_sttrace,
	    warningfile = warningfile_sttrace,
	    errorfile   = errorfile_sttrace,
            instrument  = instrument)
    if (access(logfile_sttrace))
      cat(logfile_sttrace, >> logfile)
    if (access(warningfile_sttrace))
      cat(warningfile_sttrace, >> warningfile)
    if (access(errorfile_sttrace)){
      cat(errorfile_sttrace, >> errorfile)
      print("stnflat: ERROR: sttrace returned with error => Returning")
      print("stnflat: ERROR: sttrace returned with error => Returning", >> logfile)
      print("stnflat: ERROR: sttrace returned with error => Returning", >> warningfile)
      print("stnflat: ERROR: sttrace returned with error => Returning", >> errorfile)
# --- clean up
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      apextract.logfile = bak_logfile_apextract

      parameterlist = ""
      timelist = ""

      return
    }
    print("stnflat: apertures for "//Input//" traced")
    if (loglevel > 2)
      print("stnflat: apertures for "//Input//" traced", >> logfile)
  }

  if (flat_pfit == "fit1d" || flat_pfit == "fit2d")
  {
# --- normalize flat
    apflatten(input     = Input,
              output    = NormalizedFlat,
              apertur   = "",
              reference = "",
              interac   = Interactive,
              find-,
              recenter-,
              resize-,
              edit-,
              trace-,
              fittrac-,
              flatten+,
              fitspec   = Interactive,
              line      = flat_line,
              nsum      = flat_nsum,
              threshold = flat_threshold,
              pfit      = flat_pfit,
              clean     = flat_clean,
              saturat   = flat_saturation,
              readnoise = RdNoise,
              gain      = Gain,
              lsigma    = flat_lsigma,
              usigma    = flat_usigma,
              function  = flat_function,
              order     = flat_order,
              sample    = flat_sample,
              naverag   = flat_naverage,
              niterat   = flat_niterate,
              low_rej   = flat_low_reject,
              high_rej  = flat_high_reject,
              grow      = flat_grow)
  }
  else
  {
  # --- optimal extraction algorithm from Valenti / Piskunov
    if (access(BlazeOut))
      delete(BlazeOut, ver-)
    # extract combinedflat to get image header for BlazeOut
      apsum(input       = Input,
            output      = BlazeOut,
            apertur     = "",
            format      = format,
            reference   = "",
            profile     = "",
            interactive-,
            find-,
            recenter-,
            resize-,
            edit-,
            trace-,
            fittrace-,
            extract+,
            extras-,
            review-,
            line        = INDEF,
            nsum        = 10,
            backgro     = "none",
            weights     = "none",
            pfit        = "fit1d",
            clean-,
            skybox      = 1,
            saturat     = INDEF,
            readnoise   = RdNoise,
            gain        = Gain,
            lsigma      = 3.,
            usigma      = 3.,
            nsubaps     = 1)
    strlastpos(Input, ".")
    databasefilename = "database/ap"//substr(Input, 1, strlastpos.pos-1)
    if (!access(databasefilename))
    {
      print("stnflat: ERROR: Cannot access databasefilename <"//databasefilename//"> => Returning!")
      print("stnflat: ERROR: Cannot access databasefilename <"//databasefilename//"> => Returning!", >> logfile)
      print("stnflat: ERROR: Cannot access databasefilename <"//databasefilename//"> => Returning!", >> warningfile)
      print("stnflat: ERROR: Cannot access databasefilename <"//databasefilename//"> => Returning!", >> errorfile)
# --- clean up
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      apextract.logfile = bak_logfile_apextract
      parameterlist = ""
      timelist = ""
      return
    }
    if (SwathWidth == 0)
      makenormflat(Input,databasefilename,NormalizedFlat,BlazeOut,Gain,RdNoise,NMedian,MinSNR)
    else
      makenormflat(Input,databasefilename,NormalizedFlat,BlazeOut,Gain,RdNoise,NMedian,MinSNR,SwathWidth)
    if (!access(BlazeOut))
    {
      print("stnflat: ERROR: Cannot access BlazeOut <"//BlazeOut//"> => Returning!")
      print("stnflat: ERROR: Cannot access BlazeOut <"//BlazeOut//"> => Returning!", >> logfile)
      print("stnflat: ERROR: Cannot access BlazeOut <"//BlazeOut//"> => Returning!", >> warningfile)
      print("stnflat: ERROR: Cannot access BlazeOut <"//BlazeOut//"> => Returning!", >> errorfile)
# --- clean up
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      apextract.logfile = bak_logfile_apextract
      parameterlist = ""
      timelist = ""
      return
    }
#    imdivide(numerator   = Input,
#             denominator = combinedFlat_prof,
#             result      = NormalizedFlat,
#             title       = "*",
#             constant    = 1.,
#             rescale     = "norescale",
#             mean        = "1",
#             verbose-)
  }
  if (!access(NormalizedFlat)){
    print("stnflat: ERROR: "//NormalizedFlat//" not accessable => Returning")
    print("stnflat: ERROR: "//NormalizedFlat//" not accessable => Returning", >> logfile)
    print("stnflat: ERROR: "//NormalizedFlat//" not accessable => Returning", >> warningfile)
    print("stnflat: ERROR: "//NormalizedFlat//" not accessable => Returning", >> errorfile)
# --- clean up
    if (instrument == "echelle")
      echelle.logfile = bak_logfile
    else
      kpnocoude.logfile = bak_logfile
    apextract.logfile = bak_logfile_apextract

    parameterlist = ""
    timelist = ""

    return
  }
  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      hedit(images=NormalizedFlat,
            fields="STALL",
            value="stnflat finished "//tempdate//"T"//temptime,
            add+,
            addonly+,
            del-,
            ver-,
            show+,
            update+)
    }
  }
  else{
    print("stnflat: WARNING: timefile <"//timefile//"> not accessable!")
    print("stnflat: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("stnflat: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }
  print("stnflat: "//NormalizedFlat//" ready")
  if (loglevel > 2)
    print("stnflat: "//NormalizedFlat//" ready", >> logfile)

  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("stnflat: stnflat finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("stnflat: WARNING: timefile <"//timefile//"> not accessable!")
    print("stnflat: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("stnflat: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- clean up
  if (instrument == "echelle")
    echelle.logfile = bak_logfile
  else
    kpnocoude.logfile = bak_logfile
  apextract.logfile = bak_logfile_apextract
  parameterlist = ""
  timelist = ""

end
