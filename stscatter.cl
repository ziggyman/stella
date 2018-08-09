procedure stscatter (images)

##################################################################
#                                                                #
# NAME:             stscatter.cl                                 #
# PURPOSE:          * subtracts the scattered light from the     #
#                     spectral images in <images> automatically  #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stscatter(images)                            #
# INPUTS:           images: String                               #
#                     name of list containing names of           #
#                     images subtract the scattered light from:  #
#                       "objects_botzfx.list":                   #
#                         HD175640_botzfx.fits                   #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     <Entry_in_Images_Root>s.fits               #
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

string images        = "@objects_botz.list"            {prompt="List of input images"}
string parameterfile = "scripts$parameterfile.prop"    {prompt="Parameter file"}
bool   subtract      = YES                             {prompt="Subtract scattered light?"}
string reference     = "refFlat"                       {prompt="Reference aperture-definition FITS file"}
string refscatter    = "refScatter_UVES_blue_437"      {prompt="Reference scattered-light image"}
bool   calib         = NO                              {prompt="Are input images Calib's?"}
bool   object        = YES                             {prompt="Are imput images Objects?"}
bool   interactive   = NO                              {prompt="Run task interactively?"}
bool   recenter      = YES                             {prompt="Recenter apertures?"}
bool   resize        = NO                              {prompt="Resize apertures?"}
bool   edit          = NO                              {prompt="Edit apertures?"}
bool   trace         = NO                              {prompt="Trace apertures?"}
bool   smooth        = YES                             {prompt="Smooth the cross-dispersion fits along the dispersion?"}
string instrument    = "echelle"                       {prompt="Instrument (echelle|coude)",
                                                           enum="echelle|coude"}
bool   slicer             = YES       {prompt="Does the instrument use an image slicer?"}
int    recenter_line      = INDEF     {prompt="Dispersion line for the recenter task"}
int    recenter_nsum        = 20      {prompt="Number of dispersion lines to sum or median during the recenter task"}
string recenter_aprecenter  = ""      {prompt="Apertures for recentering calculation"}
int    recenter_npeaks      = INDEF   {prompt="Select brightest peaks for recentering calculation"}
bool   recenter_shift       = YES     {prompt="Use average shift instead of recentering?"}
real   recenter_ddapcenterlimit = 2.  {prompt="Maximum difference between ycenter's"}
int    resize_line            = INDEF {prompt="Dispersion line for the resize task"}
int    resize_nsum            = 10    {prompt="Number of dispersion lines to sum or median during the resize task"}
real   resize_ylevel          = 0.05  {prompt="Resize ylevel"}
real   resize_obs_lower       = -24.  {prompt="Resize lower aperture limit for objects"}
real   resize_obs_upper       = 24.   {prompt="Resize upper aperture limit for objects"}
real   resize_flats_lower     = -24.  {prompt="Resize lower aperture limit for Flats"}
real   resize_flats_upper     = 24.   {prompt="Resize upper aperture limit for Flats"}
real   resize_obs_lowlimit    = -9.5  {prompt="Minimum lower aperture limit for objects"}
real   resize_obs_highlimit   = 15.   {prompt="Maximum upper aperture limit for objects"}
real   resize_flats_lowlimit  = -9.5  {prompt="Minimum lower aperture limit for Flats"}
real   resize_flats_highlimit = 15.   {prompt="Maximum upper aperture limit for Flats"}
real   resize_multlimit       = 0.75  {prompt="Multiply limit by this factor is limit is exceeded"}
bool   resize_bkg      = NO      {prompt="Subtract background in automatic width?"}
real   resize_r_grow   = 0.      {prompt="Grow limits by this factor"}
bool   resize_avglimit = NO      {prompt="Average limits over all apertures?"}
int    edit_line       = INDEF   {prompt="Dispersion line for the apedit task"}
int    edit_nsum       = 20      {prompt="Number of dispersion lines to sum or median during the edit task"}
real   recenter_width  = 40.     {prompt="Profile centering width"}
real   recenter_radius = 5.      {prompt="Profile centering radius"}
real   recenter_threshold = 100. {prompt="Detection threshold intensity for profile centering"}
string dispaxis        = "2"     {prompt="Dispersion axis (1-hor.,2-vert.)",
                                   enum="1|2"}
int    trace_line      = INDEF   {prompt="Starting dispersion line for tracing"}
int    trace_nsum      = 30      {prompt="Number of dispersion lines to sum for tracing"}
int    trace_step      = 5       {prompt="Tracing step"}
int    trace_nlost     = 10      {prompt="Number of consecutive times profile is lost before quitting"}
string trace_function  = "legendre" {prompt="Trace fitting function (cheb|leg|spline1|spline3)",
                                      enum="chebyshev|legendre|spline1|spline3"}
int    trace_order     = 4       {prompt="Trace fitting function order"}
string trace_sample    = "*"     {prompt="Trace sample regions"}
int    trace_naverage  = 1       {prompt="Trace average (pos) or median (neg)"}
int    trace_niterate  = 2       {prompt="Trace rejection iterations"}
real   trace_low_reject = 3.     {prompt="Trace lower rejection sigma"}
real   trace_high_reject = 3.    {prompt="Trace upper rejection sigma"}
real   trace_grow      = 0.      {prompt="Trace rejection growing radius"}
real   trace_yminlimit = -60.    {prompt="Minimum aperture position relative to center (pixels)"}
real   trace_ymaxlimit = 60.     {prompt="Maximum aperture position relative to center (pixels)"}
int    line            = INDEF   {prompt="Dispersion line"}
int    nsum            = 10      {prompt="Number of dispersion lines to sum (pos) or median (neg)"}
real   buffer          = 1.      {prompt="Buffer distance from apertures"}
string apscat1function = "chebyshev" {prompt="apscat1: Fitting function (legendre|chebyshev|spline1|spline3)",
                                       enum="legendre|chebyshev|spline1|spline3"}
int    apscat1order    = 1       {prompt="apscat1: Fitting function order"}
string apscat1sample   = "*"     {prompt="apscat1: Sample to fit"}
int    apscat1naverage = 1       {prompt="apscat1: Number of points to average (pos) or median (neg)"}
real   apscat1low_rej  = 4.5     {prompt="apscat1: Low sigma clipping rejection threshold"}
real   apscat1high_rej = 0.1     {prompt="apscat1: High sigma clipping rejection threshold"}
int    apscat1niterate = 9       {prompt="apscat1: Number of sigma clipping rejection iterations"}
real   apscat1grow     = 0.      {prompt="apscat1: Growing radius for rejected points (pixels)"}
string apscat2function = "spline3" {prompt="apscat2: Fitting function (legendre|chebyshev|spline1|spline3)",
                                     enum="legendre|chebyshev|spline1|spline3"}
int    apscat2order    = 4       {prompt="apscat2: Fitting function order"}
string apscat2sample   = "1:30 56:326 458:522 645:736 980:1070 1090:1180 1230:1380 1420:1820 1845:1930" {prompt="apscat2: Sample to fit"}
int    apscat2naverage = 1       {prompt="apscat2: Number of points to average (pos) or median (neg)"}
real   apscat2low_rej  = 4       {prompt="apscat2: Low sigma clipping rejection threshold"}
real   apscat2high_rej = 0.001   {prompt="apscat2: High sigma clipping rejection threshold"}
int    apscat2niterate = 4       {prompt="apscat2: Number of sigma clipping rejection iterations"}
real   apscat2grow     = 0.      {prompt="apscat2: Growing radius for rejected points (pixels)"}
real   maxerrmeanmult  = 0.1     {prompt="Mult mean by this factor to calc max stddev"}
bool   delinput        = NO      {prompt="Delete input images after processing?"}
int    loglevel        = 3       {prompt="Level for writing logfile"}
string logfile         = "logfile_stscatter.log"  {prompt="Name of log file"}
string warningfile     = "warnings_stscatter.log" {prompt="Name of warning file"}
string errorfile       = "errors_stscatter.log"   {prompt="Name of error file"}
string *inputlist
string *parameterlist
string *statlist
string *timelist

begin
  string echelle_logfile
  string tracelist              = "sttrace.list"
  string resizelist             = "stresize.list"
  string scatteredlightimage
  string parameter,parametervalue
  int    i
  file   infile
  string statsfile              = "stscatter_statistics.temp"
  string tempscatter            = "tempscatter.fits"
  string logfile_strecenter     = "logfile_strecenter.log"
  string warningfile_strecenter = "warnings_strecenter.log"
  string errorfile_strecenter   = "errors_strecenter.log"
  string timefile = "time.txt"
  string tempdate,tempday,temptime
  real   mean,stddev
  string in,out,refflat
  bool   found_subscatter              = NO
  bool   found_refscatter              = NO
  bool   found_sc_interactive          = NO
  bool   found_sc_recenter             = NO
  bool   found_sc_resize               = NO
  bool   found_sc_edit                 = NO
  bool   found_sc_trace                = NO
  bool   found_sc_smooth               = NO
  bool   found_instrument              = NO
  bool   found_slicer                  = NO
  bool   found_recenter_line        = NO
  bool   found_recenter_nsum        = NO
  bool   found_recenter_aprecenter  = NO
  bool   found_recenter_npeaks      = NO
  bool   found_recenter_shift       = NO
  bool   found_resize_line            = NO
  bool   found_resize_nsum            = NO
  bool   found_resize_ylevel          = NO
  bool   found_resize_obs_lower       = NO
  bool   found_resize_obs_upper       = NO
  bool   found_resize_flats_lower     = NO
  bool   found_resize_flats_upper     = NO
  bool   found_resize_obs_lowlimit    = NO
  bool   found_resize_obs_highlimit   = NO
  bool   found_resize_flats_lowlimit  = NO
  bool   found_resize_flats_highlimit = NO
  bool   found_resize_bkg             = NO
  bool   found_resize_r_grow          = NO
  bool   found_resize_avglimit        = NO
  bool   found_resize_multlimit       = NO
  bool   found_edit_line            = NO
  bool   found_edit_nsum            = NO
  bool   found_recenter_width           = NO
  bool   found_recenter_radius          = NO
  bool   found_recenter_threshold       = NO
  bool   found_dispaxis        = NO
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
  bool   found_sc_nsum                 = NO
  bool   found_sc_line                 = NO
  bool   found_sc_buffer               = NO
  bool   found_apscat1_function        = NO
  bool   found_apscat1_order           = NO
  bool   found_apscat1_sample          = NO
  bool   found_apscat1_naverage        = NO
  bool   found_apscat1_low_rej         = NO
  bool   found_apscat1_high_rej        = NO
  bool   found_apscat1_niterate        = NO
  bool   found_apscat1_grow            = NO
  bool   found_apscat2_function        = NO
  bool   found_apscat2_order           = NO
  bool   found_apscat2_sample          = NO
  bool   found_apscat2_naverage        = NO
  bool   found_apscat2_low_rej         = NO
  bool   found_apscat2_high_rej        = NO
  bool   found_apscat2_niterate        = NO
  bool   found_apscat2_grow            = NO
  bool   found_sc_maxerrmeanmult       = NO

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)
  if (access(warningfile))
    delete(warningfile, ver-)
  if (access(errorfile))
    delete(errorfile, ver-)

  echelle_logfile = imred.echelle.logfile
  print ("stscatter: echelle_logfile = "//echelle_logfile)
  imred.echelle.logfile = logfile

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*              substracting scattered light              *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*              substracting scattered light              *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- read parameterfile
  if (access(parameterfile)){

    parameterlist = parameterfile

    print ("stscatter: **************** reading parameterfile *******************")
    if (loglevel > 2)
      print ("stscatter: **************** reading parameterfile *******************", >> logfile)

    while (fscan (parameterlist, parameter, parametervalue) != EOF){

#      if (parameter != "#")
#        print ("stscatter: parameterfile: parameter="//parameter//" value="//parametervalue, >> logfile)

      if (parameter == "subscatter"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          subtract = YES
	  print ("stscatter: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          subtract = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
        }
        found_subscatter = YES
      }
      else if (parameter == "refscatter"){
        if (substr(parametervalue,1,1) == "(")
          refscatter = ""
        else
          refscatter = parametervalue
        print ("stscatter: Setting "//parameter//" to "//refscatter)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//refscatter, >> logfile)
        found_refscatter = YES
      }
      else if (parameter == "sc_interactive"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          interactive = YES
	  print ("stscatter: Setting "//parameter//" to YES")
	  if (loglevel > 2)
	    print ("stscatter: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          interactive = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if (loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
	}
        found_sc_interactive = YES
      }
      else if (parameter == "sc_recenter"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          recenter = YES
	  print ("stscatter: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          recenter = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
        }
        found_sc_recenter = YES
      }
      else if (parameter == "sc_resize"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          if (calib == NO){
  	    resize = YES
	    print ("stscatter: Setting "//parameter//" to YES")
	    if(loglevel > 2)
	      print ("stscatter: Setting "//parameter//" to YES", >> logfile)
	  }
	  else{
	    resize = NO
	    print ("stscatter: Setting "//parameter//" to NO")
	    if(loglevel > 2)
	      print ("stscatter: Setting "//parameter//" to NO", >> logfile)
	  }
	}
        else{
          resize = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
	}
        found_sc_resize = YES
      }
      else if (parameter == "sc_edit"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          edit = YES
	  print ("stscatter: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          edit = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
        }
        found_sc_edit = YES
      }
      else if (parameter == "sc_trace"){
        if (parametervalue == "YES" || parametervalue == "yes"){
	  if (calib == NO){
   	    trace = YES
	    print ("stscatter: Setting "//parameter//" to YES")
	    if(loglevel > 2)
              print ("stscatter: Setting "//parameter//" to YES", >> logfile)
	  }
	  else{
	    trace = NO
	    print ("stscatter: Setting "//parameter//" to NO")
	    if(loglevel > 2)
              print ("stscatter: Setting "//parameter//" to NO", >> logfile)
	  }
	}
        else{
          trace = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
	}
        found_sc_trace = YES
      }
      else if (parameter == "sc_smooth"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          smooth = YES
	  print ("stscatter: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          smooth = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
        }
        found_sc_smooth = YES
      }
      else if (parameter == "setinst_instrument"){
        if (parametervalue == "echelle" || parametervalue == "coude"){
          instrument = parametervalue
	  print ("stscatter: Setting "//parameter//" to "//instrument)
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to "//instrument, >> logfile)
        }
        else{
	  print ("stscatter: Warning: Parameter "//parameter//": parameter value "//parametervalue//" not valid")
	  if(loglevel > 2)
            print ("stscatter: Warning: Parameter "//parameter//": parameter value "//parametervalue//" not valid", >> logfile)
        }
        found_instrument = YES
      }
      else if (parameter == "slicer"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          slicer = YES
	  print ("stscatter: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          slicer = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
        }
        found_slicer = YES
      }
      else if (parameter == "recenter_line"){
        if (parametervalue == "INDEF")
          recenter_line = INDEF
        else
          recenter_line = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_recenter_line = YES
      }
      else if (parameter == "recenter_nsum"){
        recenter_nsum = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_recenter_nsum = YES
      }
      else if (parameter == "nflat_recenter_aprecenter"){
        if (parametervalue == "-")
	  recenter_aprecenter = ""
	else
          recenter_aprecenter = parametervalue
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_recenter_aprecenter = YES
      }
      else if (parameter == "recenter_npeaks"){
        if (parametervalue == "INDEF")
          recenter_npeaks = INDEF
        else
          recenter_npeaks = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_recenter_npeaks = YES
      }
      else if (parameter == "recenter_shift"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          recenter_shift = YES
	  print ("stscatter: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          recenter_shift = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
        }
        found_recenter_shift = YES
      }
      else if (parameter == "resize_line"){
        if (parametervalue == "INDEF")
          resize_line = INDEF
        else
          resize_line = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_resize_line = YES
      }
      else if (parameter == "resize_nsum"){
        resize_nsum = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_resize_nsum = YES
      }
      else if (parameter == "resize_ylevel" && calib == NO){
        if (parametervalue == "INDEF")
          resize_ylevel = INDEF
        else
          resize_ylevel = real(parametervalue)
        print ("stscatter: Setting resize_ylevel to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting resize_ylevel to "//parametervalue, >> logfile)
        found_resize_ylevel = YES
      }
      else if (parameter == "resize_obs_lower"){
        if (parametervalue == "INDEF")
          resize_obs_lower = INDEF
        else
          resize_obs_lower = real(parametervalue)
        print ("stscatter: Setting resize_obs_lower to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting resize_obs_lower to "//parametervalue, >> logfile)
        found_resize_obs_lower = YES
      }
      else if (parameter == "resize_obs_upper"){
        if (parametervalue == "INDEF")
          resize_obs_upper = INDEF
        else
          resize_obs_upper = real(parametervalue)
        print ("stscatter: Setting resize_obs_upper to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting resize_obs_upper to "//parametervalue, >> logfile)
        found_resize_obs_upper = YES
      }
      else if (parameter == "resize_flats_lower"){
        if (parametervalue == "INDEF")
          resize_flats_lower = INDEF
        else
          resize_flats_lower = real(parametervalue)
        print ("stscatter: Setting resize_flats_lower to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting resize_flats_lower to "//parametervalue, >> logfile)
        found_resize_flats_lower = YES
      }
      else if (parameter == "resize_flats_upper"){
        if (parametervalue == "INDEF")
          resize_flats_upper = INDEF
        else
          resize_flats_upper = real(parametervalue)
        print ("stscatter: Setting resize_flats_upper to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting resize_flats_upper to "//parametervalue, >> logfile)
        found_resize_flats_upper = YES
      }
      else if (parameter == "resize_obs_lowlimit"){
        if (parametervalue != "INDEF")
          resize_obs_lowlimit = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_resize_obs_lowlimit = YES
      }
      else if (parameter == "resize_obs_highlimit"){
        if (parametervalue != "INDEF")
          resize_obs_highlimit = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_resize_obs_highlimit = YES
      }
      else if (parameter == "resize_flats_lowlimit"){
        if (parametervalue != "INDEF")
          resize_flats_lowlimit = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_resize_flats_lowlimit = YES
      }
      else if (parameter == "resize_flats_highlimit"){
        if (parametervalue != "INDEF")
          resize_flats_highlimit = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_resize_flats_highlimit = YES
      }
      else if (parameter == "resize_multlimit"){
        if (parametervalue != "INDEF")
          resize_multlimit = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_resize_multlimit = YES
      }
      else if (parameter == "resize_bkg"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          resize_bkg = YES
	  print ("stscatter: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          resize_bkg = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
        }
        found_resize_bkg = YES
      }
      else if (parameter == "nflat_resize_r_grow"){
        resize_r_grow = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_resize_r_grow = YES
      }
      else if (parameter == "resize_avglimit"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          resize_avglimit = YES
	  print ("stscatter: Setting "//parameter//" to YES")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          resize_avglimit = NO
	  print ("stscatter: Setting "//parameter//" to NO")
	  if(loglevel > 2)
            print ("stscatter: Setting "//parameter//" to NO", >> logfile)
        }
        found_resize_avglimit = YES
      }
      else if (parameter == "edit_line"){
        if (parametervalue == "INDEF")
          edit_line = INDEF
        else
          edit_line = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_edit_line = YES
      }
      else if (parameter == "edit_nsum"){
        edit_nsum = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_edit_nsum = YES
      }
      else if (parameter == "recenter_width"){
        if (parametervalue == "INDEF")
          recenter_width = INDEF
        else
          recenter_width = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_recenter_width = YES
      }
      else if (parameter == "recenter_radius"){
        if (parametervalue == "INDEF")
          recenter_radius = INDEF
        else
          recenter_radius = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_recenter_radius = YES
      }
      else if (parameter == "recenter_threshold"){
        if (parametervalue == "INDEF")
          recenter_threshold = INDEF
        else
          recenter_threshold = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_recenter_threshold = YES
      }
      else if (parameter == "dispaxis"){
        dispaxis = parametervalue
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_dispaxis  = YES
      }
      else if (parameter == "trace_line"){
        if (parametervalue == "INDEF")
          trace_line = INDEF
        else
          trace_line = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_line  = YES
      }
      else if (parameter == "trace_nsum"){
        trace_nsum = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_nsum = YES
      }
      else if (parameter == "trace_step"){
        trace_step = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_step = YES
      }
      else if (parameter == "trace_nlost"){
        trace_nlost = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_nlost = YES
      }
      else if (parameter == "trace_function"){
        trace_function = parametervalue
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_function = YES
      }
      else if (parameter == "trace_order"){
        trace_order = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_order = YES
      }
      else if (parameter == "trace_sample"){
        trace_sample = parametervalue
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_sample = YES
      }
      else if (parameter == "trace_naverage"){
        trace_naverage = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_naverage = YES
      }
      else if (parameter == "trace_niterate"){
        trace_niterate = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_niterate = YES
      }
      else if (parameter == "trace_low_reject"){
        if (parametervalue == "INDEF")
          trace_low_reject = INDEF
        else
          trace_low_reject = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_low_reject = YES
      }
      else if (parameter == "trace_high_reject"){
        if (parametervalue == "INDEF")
          trace_high_reject = INDEF
        else
          trace_high_reject = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_high_reject = YES
      }
      else if (parameter == "trace_grow"){
        trace_grow = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_grow = YES
      }
      else if (parameter == "trace_yminlimit"){
        trace_yminlimit = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_yminlimit = YES
      }
      else if (parameter == "trace_ymaxlimit"){
        trace_ymaxlimit = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_trace_ymaxlimit = YES
      }
      else if (parameter == "sc_nsum"){
        nsum = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_sc_nsum = YES
      }
      else if (parameter == "sc_line"){
        if (parametervalue == "INDEF")
          line = INDEF
        else
          line = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_sc_line = YES
      }
      else if (parameter == "sc_buffer"){
        buffer = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_sc_buffer = YES
      }
      else if (parameter == "apscat1_function"){
        apscat1function = parametervalue
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat1_function = YES
      }
      else if (parameter == "apscat1_order"){
        apscat1order = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat1_order = YES
      }
      else if (parameter == "apscat1_sample"){
        apscat1sample = ""
        for (i = 1; i <= strlen(parametervalue); i+=1){
          if (substr(parametervalue,i,i) != ",")
            apscat1sample = apscat1sample//substr(parametervalue,i,i)
          else
            apscat1sample = apscat1sample//" "
        }
        print ("stscatter: Setting "//parameter//" to "//apscat1sample)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//apscat1sample, >> logfile)
        found_apscat1_sample = YES
      }
      else if (parameter == "apscat1_naverage"){
        apscat1naverage = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat1_naverage = YES
      }
      else if (parameter == "apscat1_low_rej"){
        if (parametervalue == "INDEF")
          apscat1low_rej = INDEF
        else
          apscat1low_rej = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat1_low_rej = YES
      }
      else if (parameter == "apscat1_high_rej"){
        if (parametervalue == "INDEF")
          apscat1high_rej = INDEF
        else
          apscat1high_rej = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat1_high_rej = YES
      }
      else if (parameter == "apscat1_niterate"){
        apscat1niterate = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat1_niterate = YES
      }
      else if (parameter == "apscat1_grow"){
        apscat1grow = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat1_grow = YES
      }
      else if (parameter == "apscat2_function"){
        apscat2function = parametervalue
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat2_function = YES
      }
      else if (parameter == "apscat2_order"){
        apscat2order = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat2_order = YES
      }
      else if (parameter == "apscat2_sample"){
        apscat2sample = ""
        for (i = 1; i <= strlen(parametervalue); i+=1){
          if (substr(parametervalue,i,i) != ",")
            apscat2sample = apscat2sample//substr(parametervalue,i,i)
          else
            apscat2sample = apscat2sample//" "
        }
        print ("stscatter: Setting "//parameter//" to "//apscat2sample)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//apscat2sample, >> logfile)
        found_apscat2_sample = YES
      }
      else if (parameter == "apscat2_naverage"){
        apscat2naverage = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat2_naverage = YES
      }
      else if (parameter == "apscat2_low_rej"){
        if (parametervalue == "INDEF")
          apscat2low_rej = INDEF
        else
          apscat2low_rej = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat2_low_rej = YES
      }
      else if (parameter == "apscat2_high_rej"){
        if (parametervalue == "INDEF")
          apscat2high_rej = INDEF
        else
          apscat2high_rej = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat2_high_rej = YES
      }
      else if (parameter == "apscat2_niterate"){
        apscat2niterate = int(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat2_niterate = YES
      }
      else if (parameter == "apscat2_grow"){
        apscat2grow = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apscat2_grow = YES
      }
      else if (parameter == "sc_maxerrmeanmult"){
        maxerrmeanmult = real(parametervalue)
        print ("stscatter: Setting "//parameter//" to "//parametervalue)
        if(loglevel > 2)
          print ("stscatter: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_sc_maxerrmeanmult = YES
      }
    }#end while
    if (!found_subscatter){
      print("stscatter: WARNING: parameter subscatter not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter subscatter not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter subscatter not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_refscatter){
      print("stscatter: WARNING: parameter refscatter not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter refscatter not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter refscatter not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_sc_interactive){
      print("stscatter: WARNING: parameter sc_interactive not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter sc_interactive not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter sc_interactive not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_sc_recenter){
      print("stscatter: WARNING: parameter sc_recenter not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter sc_recenter not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter sc_recenter not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_sc_resize){
      print("stscatter: WARNING: parameter sc_resize not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter sc_resize not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter sc_resize not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_sc_edit){
      print("stscatter: WARNING: parameter sc_edit not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter sc_edit not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter sc_edit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_sc_trace){
      print("stscatter: WARNING: parameter sc_trace not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter sc_trace not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter sc_trace not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_instrument){
      print("stscatter: WARNING: parameter instrument not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter instrument not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter instrument not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_slicer){
      print("stscatter: WARNING: parameter slicer not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter slicer not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter slicer not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_sc_smooth){
      print("stscatter: WARNING: parameter sc_smooth not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter sc_smooth not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter sc_smooth not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_recenter_line){
      print("stscatter: WARNING: parameter recenter_line not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter recenter_line not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter recenter_line not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_recenter_nsum){
      print("stscatter: WARNING: parameter recenter_nsum not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter recenter_nsum not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter recenter_nsum not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_recenter_aprecenter){
      print("stscatter: WARNING: parameter recenter_aprecenter not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter recenter_aprecenter not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter recenter_aprecenter not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_recenter_npeaks){
      print("stscatter: WARNING: parameter recenter_npeaks not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter recenter_npeaks not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter recenter_npeaks not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_recenter_shift){
      print("stscatter: WARNING: parameter recenter_shift not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter recenter_shift not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter recenter_shift not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_line){
      print("stscatter: WARNING: parameter resize_line not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_line not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_line not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_nsum){
      print("stscatter: WARNING: parameter resize_nsum not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_nsum not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_nsum not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_ylevel && !calib){
      print("stscatter: WARNING: parameter resize_ylevel not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_ylevel not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_ylevel not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_obs_lower){
      print("stscatter: WARNING: parameter resize_obs_lower not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_obs_lower not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_obs_lower not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_obs_upper){
      print("stscatter: WARNING: parameter resize_obs_upper not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_obs_upper not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_obs_upper not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_flats_lower){
      print("stscatter: WARNING: parameter resize_flats_lower not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_flats_lower not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_flats_lower not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_flats_upper){
      print("stscatter: WARNING: parameter resize_flats_upper not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_flats_upper not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_flats_upper not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_obs_lowlimit){
      print("stscatter: WARNING: parameter resize_obs_lowlimit not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_obs_lowlimit not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_obs_lowlimit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_obs_highlimit){
      print("stscatter: WARNING: parameter resize_obs_highlimit not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_obs_highlimit not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_obs_highlimit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_flats_lowlimit){
      print("stscatter: WARNING: parameter resize_flats_lowlimit not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_flats_lowlimit not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_flats_lowlimit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_flats_highlimit){
      print("stscatter: WARNING: parameter resize_flats_highlimit not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_flats_highlimit not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_flats_highlimit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_multlimit){
      print("stscatter: WARNING: parameter resize_multlimit not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_multlimit not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_multlimit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_bkg){
      print("stscatter: WARNING: parameter resize_bkg not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_bkg not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_bkg not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_r_grow){
      print("stscatter: WARNING: parameter resize_r_grow not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_r_grow not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_r_grow not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_resize_avglimit){
      print("stscatter: WARNING: parameter resize_avglimit not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter resize_avglimit not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter resize_avglimit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_edit_line){
      print("stscatter: WARNING: parameter edit_line not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter edit_line not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter edit_line not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_edit_nsum){
      print("stscatter: WARNING: parameter edit_nsum not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter edit_nsum not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter edit_nsum not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_recenter_width){
      print("stscatter: WARNING: parameter recenter_width not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter recenter_width not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter recenter_width not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_recenter_radius){
      print("stscatter: WARNING: parameter recenter_radius not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter recenter_radius not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter recenter_radius not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_recenter_threshold){
      print("stscatter: WARNING: parameter recenter_threshold not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter recenter_threshold not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter recenter_threshold not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_dispaxis){
      print("stscatter: WARNING: parameter dispaxis not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter dispaxis not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter dispaxis not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_line){
      print("stscatter: WARNING: parameter trace_line not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_line not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_line not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_nsum){
      print("stscatter: WARNING: parameter trace_nsum not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_nsum not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_nsum not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_step){
      print("stscatter: WARNING: parameter trace_step not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_step not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_step not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_nlost){
      print("stscatter: WARNING: parameter trace_nlost not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_nlost not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_nlost not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_function){
      print("stscatter: WARNING: parameter trace_function not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_function not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_function not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_order){
      print("stscatter: WARNING: parameter trace_order not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_order not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_order not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_sample){
      print("stscatter: WARNING: parameter trace_sample not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_sample not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_sample not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_naverage){
      print("stscatter: WARNING: parameter trace_naverage not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_naverage not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_naverage not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_niterate){
      print("stscatter: WARNING: parameter trace_niterate not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_niterate not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_niterate not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_low_reject){
      print("stscatter: WARNING: parameter trace_low_reject not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_low_reject not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_low_reject not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_high_reject){
      print("stscatter: WARNING: parameter trace_high_reject not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_high_reject not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_high_reject not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_grow){
      print("stscatter: WARNING: parameter trace_grow not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_grow not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_grow not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_yminlimit){
      print("stscatter: WARNING: parameter trace_yminlimit not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_yminlimit not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_yminlimit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_trace_ymaxlimit){
      print("stscatter: WARNING: parameter trace_ymaxlimit not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter trace_ymaxlimit not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter trace_ymaxlimit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_sc_nsum){
      print("stscatter: WARNING: parameter sc_nsum not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter sc_nsum not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter sc_nsum not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_sc_line){
      print("stscatter: WARNING: parameter sc_line not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter sc_line not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter sc_line not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_sc_buffer){
      print("stscatter: WARNING: parameter sc_buffer not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter sc_buffer not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter sc_buffer not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat1_function){
      print("stscatter: WARNING: parameter apscat1_function not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat1_function not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat1_function not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat1_order){
      print("stscatter: WARNING: parameter apscat1_order not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat1_order not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat1_order not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat1_sample){
      print("stscatter: WARNING: parameter apscat1_sample not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat1_sample not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat1_sample not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat1_naverage){
      print("stscatter: WARNING: parameter apscat1_naverage not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat1_naverage not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat1_naverage not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat1_low_rej){
      print("stscatter: WARNING: parameter apscat1_low_rej not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat1_low_rej not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat1_low_rej not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat1_high_rej){
      print("stscatter: WARNING: parameter apscat1_high_rej not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat1_high_rej not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat1_high_rej not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat1_niterate){
      print("stscatter: WARNING: parameter apscat1_niterate not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat1_niterate not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat1_niterate not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat1_grow){
      print("stscatter: WARNING: parameter apscat1_grow not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat1_grow not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat1_grow not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat2_function){
      print("stscatter: WARNING: parameter apscat2_function not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat2_function not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat2_function not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat2_order){
      print("stscatter: WARNING: parameter apscat2_order not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat2_order not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat2_order not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat2_sample){
      print("stscatter: WARNING: parameter apscat2_sample not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat2_sample not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat2_sample not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat2_naverage){
      print("stscatter: WARNING: parameter apscat2_naverage not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat2_naverage not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat2_naverage not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat2_low_rej){
      print("stscatter: WARNING: parameter apscat2_low_rej not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat2_low_rej not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat2_low_rej not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat2_high_rej){
      print("stscatter: WARNING: parameter apscat2_high_rej not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat2_high_rej not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat2_high_rej not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat2_niterate){
      print("stscatter: WARNING: parameter apscat2_niterate not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat2_niterate not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat2_niterate not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apscat2_grow){
      print("stscatter: WARNING: parameter apscat2_grow not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter apscat2_grow not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter apscat2_grow not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_sc_maxerrmeanmult){
      print("stscatter: WARNING: parameter sc_maxerrmeanmult not found in parameterfile!!! -> using standard")
      print("stscatter: WARNING: parameter sc_maxerrmeanmult not found in parameterfile!!! -> using standard", >> logfile)
      print("stscatter: WARNING: parameter sc_maxerrmeanmult not found in parameterfile!!! -> using standard", >> warningfile)
    }
  }
  else{
    print("stscatter: WARNING: parameterfile not found!!! -> using standard parameters")
    print("stscatter: WARNING: parameterfile not found!!! -> using standard parameters", >> logfile)
    print("stscatter: WARNING: parameterfile not found!!! -> using standard parameters", >> warningfile)
  }

# --- load neccesary packages
#  noao
#  imred
#  ccdred
#  echelle

# --- Erzeugen von temporaeren Filenamen
  print("stscatter: building temp-filenames")
  if (loglevel > 2)
    print("stscatter: building temp-filenames", >> logfile)
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stscatter: building lists from temp-files")
  if (loglevel > 2)
    print("stscatter: building lists from temp-files", >> logfile)

  if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
   sections(images, option="root", > infile)
   inputlist = infile
  }
  else{
   if (substr(images,1,1) != "@"){
    print("stscatter: ERROR: "//images//" not found!!!")
    print("stscatter: ERROR: "//images//" not found!!!", >> logfile)
    print("stscatter: ERROR: "//images//" not found!!!", >> errorfile)
    print("stscatter: ERROR: "//images//" not found!!!", >> warningfile)
   }
   else{
    print("stscatter: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
    print("stscatter: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> logfile)
    print("stscatter: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> errorfile)
    print("stscatter: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> warningfile)

   }

# --- clean up
   imred.echelle.logfile = echelle_logfile

   inputlist     = ""
   parameterlist = ""
   statlist      = ""
   timelist      = ""
   delete (infile, ver-, >& "dev$null")
   return
  }

# --- test if reference aperture definitions can be accessed
  print("stscatter: reference = "//reference)
  refflat = ""
  for(i=1;i<=strlen(reference);i=i+1){
    if (substr(reference,i,i) == "/")
      refflat = ""
    else
      refflat = refflat//substr(reference,i,i)
  }
  if (substr(refflat,strlen(refflat)-4,strlen(refflat)) == ".fits")
    refflat = substr(refflat,1,strlen(refflat)-5)
  print("stscatter: refflat = "//refflat)
  if (!access("database/ap"//refflat)){
    print("stscatter: ERROR: no refflat aperture definition for "//refflat//" found!!!")
    print("stscatter: ERROR: no refflat aperture definition for "//refflat//" found!!!", >> logfile)
    print("stscatter: ERROR: no refflat aperture definition for "//refflat//" found!!!", >> errorfile)
    print("stscatter: ERROR: no refflat aperture definition for "//refflat//" found!!!", >> warningfile)

# --- aufraeumen
    imred.echelle.logfile = echelle_logfile

    inputlist     = ""
    parameterlist = ""
    timelist      = ""
    delete (infile, ver-, >& "dev$null")

    return
  }

# --- setting parameters
  print("stscatter: setting parameters")
  if (loglevel > 2)
    print("stscatter: setting parameters", >> logfile)

  echelle.apscat1.function = apscat1function
  echelle.apscat1.order    = apscat1order
  echelle.apscat1.sample   = apscat1sample
  echelle.apscat1.naverage  = apscat1naverage
  echelle.apscat1.low_rej  = apscat1low_rej
  echelle.apscat1.high_rej = apscat1high_rej
  echelle.apscat1.niterate  = apscat1niterate
  echelle.apscat1.grow     = apscat1grow

  echelle.apscat2.function = apscat2function
  echelle.apscat2.order    = apscat2order
  echelle.apscat2.sample   = apscat2sample
  echelle.apscat2.naverage  = apscat2naverage
  echelle.apscat2.low_rej  = apscat2low_rej
  echelle.apscat2.high_rej = apscat2high_rej
  echelle.apscat2.niterate  = apscat2niterate
  echelle.apscat2.grow     = apscat2grow

  apdefault.lower       = resize_obs_lower
  apdefault.upper       = resize_obs_upper

  aprecenter.line       = recenter_line
  aprecenter.nsum       = recenter_nsum
  aprecenter.aprecenter = recenter_aprecenter
  aprecenter.npeaks     = recenter_npeaks
  aprecenter.shift      = recenter_shift

  apresize.line     = resize_line
  apresize.nsum     = resize_nsum
  if (slicer){
    resize_ylevel = INDEF
    apresize.ylevel = INDEF
  }
  apresize.ylevel = resize_ylevel
  apresize.peak   = YES
  if (object){
    apresize.llimit = resize_obs_lower
    apresize.ulimit = resize_obs_upper
  }
  else{
    apresize.llimit = resize_flats_lower
    apresize.ulimit = resize_flats_upper
  }
  apresize.bkg      = resize_bkg
  apresize.r_grow   = resize_r_grow
  apresize.avglimit = resize_avglimit

  apedit.line      = edit_line
  apedit.nsum      = edit_nsum
  apedit.width     = recenter_width
  apedit.radius    = recenter_radius
  apedit.threshold = recenter_threshold

# --- build output filenames and subtract scattered light
  print("stscatter: ******************* processing files *********************")
  if (loglevel > 2)
    print("stscatter: ******************* processing files *********************", >> logfile)

  while (fscan (inputlist, in) != EOF){

    print("stscatter: in = "//in)
    if (loglevel > 2)
      print("stscatter: in = "//in, >> logfile)

    scatteredlightimage = "scatter_"//in

    i = strlen(in)
    if (!calib && !object){
      if (substr (in, i-4, i) == ".fits")
        out = substr(in, 1, i-5)//"_s.fits"
      else out = in//"_s"
    }
    else{
      if (substr (in, i-4, i) == ".fits")
        out = substr(in, 1, i-5)//"s.fits"
      else out = in//"s"
    }

# --- delete old outfile
    if (access(out)){
      imdel(out, ver-)
      if (access(out))
        del(out,ver-)
      if (!access(out)){
        print("stscatter: old "//out//" deleted")
        if (loglevel > 2)
          print("stscatter: old "//out//" deleted", >> logfile)
      }
      else{
        print("stscatter: ERROR: cannot delete old "//out)
        print("stscatter: ERROR: cannot delete old "//out, >> logfile)
        print("stscatter: ERROR: cannot delete old "//out, >> warningfile)
        print("stscatter: ERROR: cannot delete old "//out, >> errorfile)
      }
    }

    if (access("scatter_"//in)){
     del("scatter_"//in,ver-)
     print("stscatter: old scatter_"//in//" deleted")
     if (loglevel > 2)
       print("stscatter: old scatter_"//in//" deleted", >> logfile)
    }

    print("stscatter: processing "//in//", outfile = "//out)
    if (loglevel > 1)
      print("stscatter: processing "//in//", outfile = "//out, >> logfile)

    if (access(in)){
      if (subtract){
        aprecenter.interact = interactive
        apresize.interact   = interactive
        print("stscatter: editing apertures for "//in)
        if (loglevel > 2)
          print("stscatter: editing apertures for "//in, >> logfile)
        apedit(input = in,
	       apertures = "",
	       reference = refflat,
	       interact = interactive,
	       find-,
	       recenter = recenter,
	       resize-,
	       edit = (edit || interactive),
	       line = edit_line,
	       nsum = edit_nsum,
	       width = recenter_width,
	       radius = recenter_radius,
	       threshold = recenter_threshold)
# --- recenter apertures
  if (recenter){
    if (access(logfile_strecenter))
      del(logfile_strecenter, ver-)
    if (access(warningfile_strecenter))
      del(warningfile_strecenter, ver-)
    if (access(errorfile_strecenter))
      del(errorfile_strecenter, ver-)
    strecenter(images          = in,
	       loglevel        = loglevel,
	       reference       = "",
               dispaxis        = dispaxis,
	       interactive     = interactive,
	       line            = recenter_line,
	       nsum            = recenter_nsum,
               aprecenter      = recenter_aprecenter,
               npeaks          = recenter_npeaks,
               shift           = recenter_shift,
               width           = recenter_width,
               radius          = recenter_radius,
               threshold       = recenter_threshold,
               ddapcenterlimit = recenter_ddapcenterlimit,
               instrument      = instrument,
	       logfile         = logfile_strecenter,
	       warningfile     = warningfile_strecenter,
	       errorfile       = errorfile_strecenter)
    if (access(logfile_strecenter))
      cat(logfile_strecenter, >> logfile)
    if (access(warningfile_strecenter))
      cat(warningfile_strecenter, >> warningfile)
    if (access(errorfile_strecenter)){
      cat(errorfile_strecenter, >> errorfile)
      print("stscatter: ERROR: strecenter returned with error => Returning")
      print("stscatter: ERROR: strecenter returned with error => Returning", >> logfile)
      print("stscatter: ERROR: strecenter returned with error => Returning", >> warningfile)
      print("stscatter: ERROR: strecenter returned with error => Returning", >> errorfile)
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
        if (resize){
          if (access(resizelist))
            delete(resizelist, ver-)
          print(in, >> resizelist)
# --- resize objects
	  if (object){
	    stresize(images = "@"//resizelist,
		     loglevel = loglevel,
		     reference = "",
		     interactive = interactive,
		     line = resize_line,
		     nsum = resize_nsum,
		     ylevel = resize_ylevel,
		     lowlimit = resize_obs_lower,
		     highlimit = resize_obs_upper,
		     aplowlimit = resize_obs_lowlimit,
		     aphighlimit = resize_obs_highlimit,
		     multlimit = resize_multlimit,
		     bkg = resize_bkg,
		     r_grow = resize_r_grow,
		     avglimit = resize_avglimit,
		     logfile = logfile,
		     warningfile = warningfile,
		     errorfile = errorfile)
	  }
# --- resize Flats and Calibs
	  else{
	    stresize(images = "@"//resizelist,
		     loglevel = loglevel,
		     reference = "",
		     interactive = interactive,
		     line = resize_line,
		     nsum = resize_nsum,
		     ylevel = resize_ylevel,
		     peak+,
		     lowlimit = resize_flats_lower,
		     highlimit = resize_flats_upper,
		     aplowlimit = resize_flats_lowlimit,
		     aphighlimit = resize_flats_highlimit,
		     multlimit = resize_multlimit,
		     bkg = resize_bkg,
		     r_grow = resize_r_grow,
		     avglimit = resize_avglimit,
		     logfile = logfile,
		     warningfile = warningfile,
		     errorfile = errorfile)
	  }
        }
        if (trace){
          if (access(tracelist))
            delete(tracelist, ver-)
          print(in, >> tracelist)
	  sttrace(images = "@"//tracelist,
	          loglevel = loglevel,
		  reference = "",
		  dispaxis = dispaxis,
		  interactive = interactive,
		  line = trace_line,
		  nsum = trace_nsum,
		  step = trace_step,
		  nlost = trace_nlost,
		  function = trace_function,
		  order = trace_order,
		  sample = trace_sample,
		  naverage = trace_naverage,
		  niterate = trace_niterate,
		  low_reject = trace_low_reject,
		  high_reject = trace_high_reject,
		  grow = trace_grow,
  	          yminlimit = trace_yminlimit,
	          ymaxlimit = trace_ymaxlimit,
		  logfile = logfile,
		  warningfile = warningfile,
		  errorfile = errorfile)
        }
# --- subtract scattered light
#      if (subtract){
        apscatter(input = in,
     	          output = out,
		  apertur = "",
		  scatter = scatteredlightimage,
		  reference = "",
		  interactive = interactive,
		  find-,
		  recenter-,
		  resize-,
		  edit = (edit && interactive),
		  trace-,
		  fittrace-,
		  subtrac+,
		  smooth = smooth,
		  fitscat = interactive,
		  fitsmoo = interactive,
		  line = line,
		  nsum = nsum,
		  buffer = buffer)
        if (access(timefile))
          del(timefile, ver-)
        time(>> timefile)
        if (access(timefile)){
          timelist = timefile
          if (fscan(timelist,tempday,temptime,tempdate) != EOF){
            hedit(images=out,
                  fields="STSCATTE",
                  value="scattered light subtracted "//tempdate//"T"//temptime,
                  add+,
                  addonly+,
                  del-,
                  ver-,
                  show+,
                  update+)
          }
        }
        else{
          print("stscatter: WARNING: timefile <"//timefile//"> not accessable!")
          print("stscatter: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
          print("stscatter: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
        }
      }
      else{
        imcopy(input=in,
               output=out)
        if (access(timefile))
          del(timefile, ver-)
        time(>> timefile)
        if (access(timefile)){
          timelist = timefile
          if (fscan(timelist,tempday,temptime,tempdate) != EOF){
            hedit(images=out,
                  fields="STSCATTE",
                  value="NO scattered light subtracted, input image copied "//tempdate//"T"//temptime,
                  add+,
                  addonly+,
                  del-,
                  ver-,
                  show+,
                  update+)
          }
        }
        else{
          print("stscatter: WARNING: timefile <"//timefile//"> not accessable!")
          print("stscatter: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
          print("stscatter: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
        }
      }
#
# Calib's are not recentered, resized und traced!!!
#


# --- set all negative values to zero
      if (access(out)){
        imreplace(images    = out,
                  value     = 0.,
                  imaginary = 0.,
                  lower     = INDEF,
                  upper     = 0.,
                  radius    = 0.)
#        fitsnozero(out)
        if (delinput)
          imdel(in, ver-)
        if (delinput && access(in))
          del(in, ver-)
        print("stscatter: "//out//" ready")
        if (loglevel > 2)
          print("stscatter: "//out//" ready", >> logfile)
      }
      else{
        print("stscatter: ERROR: cannot access "// out //"!")
        print("stscatter: ERROR: cannot access "// out //"!", >> logfile)
        print("stscatter: ERROR: cannot access "// out //"!", >> errorfile)
        print("stscatter: ERROR: cannot access "// out //"!", >> warningfile)
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

# --- check scattered-light image
      if (subtract){
        if (strlen(refscatter) > 1)
        {
          if (substr(refscatter,strlen(refscatter)-4,strlen(refscatter)) != ".fits")
	    refscatter = refscatter//".fits"
          if (access(refscatter)){
            print("stscatter: checking scattered-light images")
            if (loglevel > 2)
              print("stscatter: checking scattered-light images", >> logfile)
# --- divide scattered-light images by reference-scattered light image
            if (access(tempscatter))
	      delete(tempscatter, ver-)
            imarith(operand1 = scatteredlightimage,
		    op = "/",
	 	    operand2 = refscatter,
		    result = tempscatter,
		    title = "",
		    divzero = 0.,
		    hparams = "",
		    pixtype = "",
		    calctype = "",
		    verbose-,
		    noact-)
            if (!access(tempscatter)){
              print("stscatter: ERROR: "//tempscatter//" not accessable => Returning")
              print("stscatter: ERROR: "//tempscatter//" not accessable => Returning", >> logfile)
              print("stscatter: ERROR: "//tempscatter//" not accessable => Returning", >> warningfile)
              print("stscatter: ERROR: "//tempscatter//" not accessable => Returning", >> errorfile)
            }

# --- view image statistics
  # --- delete old statsfile
            print("stscatter: search for old statsfile")
	    if (loglevel > 2)
	      print("stscatter: search for old statsfile", >> logfile)
	    if (access(statsfile)){
	      delete (statsfile, ver-, >& "dev$null")
	      print("stscatter: old statsfile deleted!")
	      if (loglevel > 2)
	        print("stscatter: old statsfile deleted!", >> logfile)
  	    }
  # --- imstat
            print("stscatter: starting imstat")
	    if (loglevel > 2)
	      print("stscatter: starting imstat", >> logfile)
	    imstat(tempscatter,
		   format-,
		   fields="image,mean,stddev",
		   lower=INDEF,
		   upper=INDEF,
		   binwidt=0.1, >> statsfile)
            print("stscatter: imstat ready - statsfile = <"//statsfile//">")
            if (loglevel > 2)
              print("stscatter: imstat ready - statsfile = <"//statsfile//">", >> logfile)
#	  	 nclip=0,
  # --- Ausgabe
            if (access(statsfile)){
              statlist = statsfile
	      while (fscan (statlist, image, mean, stddev) != EOF){
  	        print("stscatter: "//image//": mean = "//mean//", stddev = "//stddev)
	        if (loglevel > 2)
	          print("stscatter: "//image//": mean = "//mean//", stddev = "//stddev, >> logfile)
	      }
              if (stddev > (mean * maxerrmeanmult)){
                print("stscatter: WARNING: "//scatteredlightimage//" exceeds maximum limit!")
                print("stscatter: WARNING: "//scatteredlightimage//" exceeds maximum limit!", >> logfile)
	        print("stscatter: WARNING: "//scatteredlightimage//" exceeds maximum limit!", >> warningfile)
	      }
            }
            else{
              print("stscatter: ERROR: cannot access statsfile <"// statsfile //">!")
              print("stscatter: ERROR: cannot access statsfile <"// statsfile //">!", >> logfile)
              print("stscatter: ERROR: cannot access statsfile <"// statsfile //">!", >> warningfile)
              print("stscatter: ERROR: cannot access statsfile <"// statsfile //">!", >> errorfile)
            }
          }
          else{
            print("stscatter: ERROR: cannot access "// refscatter //"!")
            print("stscatter: ERROR: cannot access "// refscatter //"!", >> logfile)
            print("stscatter: ERROR: cannot access "// refscatter //"!", >> warningfile)
            print("stscatter: ERROR: cannot access "// refscatter //"!", >> errorfile)
          }
        }
      }
      print("stscatter: -----------------------")
      print("stscatter: -----------------------", >> logfile)
    }
    else{
      print("stscatter: ERROR: cannot access "//in)
      print("stscatter: ERROR: cannot access "//in, >> logfile)
      print("stscatter: ERROR: cannot access "//in, >> errorfile)
      print("stscatter: ERROR: cannot access "//in, >> warningfile)
    }
  } # end of while(scan(inputlist))

  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("stscatter: stscatter finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("stscatter: WARNING: timefile <"//timefile//"> not accessable!")
    print("stscatter: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("stscatter: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- clean up
  imred.echelle.logfile = echelle_logfile

  inputlist     = ""
  parameterlist = ""
  statlist      = ""
  timelist      = ""
  delete (infile, ver-, >& "dev$null")

end
