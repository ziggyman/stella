procedure stcrerefblaze (combinedFlat, normalizedFlat)

##################################################################
#                                                                #
# NAME:             stcrerefblaze.cl                             #
# PURPOSE:          * creates reference-Blaze file               #
#                                                                #
# CATEGORY:                                                      #
# CALLING SEQUENCE: stcrerefblaze,<parametertype parameter>      #
# INPUTS:           input file: 'parameter':                     #
#                    3740.80444335938      105783.50             #
#                                     .                          #
#                                     .                          #
#                                     .                          #
#                   outfile: String                              #
# OUTPUTS:          outfile:                                     #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# LAST EDITED:      24.04.2006                                   #
#                                                                #
################################################################## 

string combinedFlat   = "combinedFlat.fits"   {prompt="Name of combined Flat"}
string normalizedFlat = "normalizedFlat.fits" {prompt="Name of normalized Flat"}
string blaze_in       = "combinedFlat_blaze.fits" {prompt="Name of Blaze-function input file (fit-)"}
string blaze_out      = "combinedFlat_blaze.fits" {prompt="Name of Blaze-function output file"}
string parameterfile  = "scripts$parameterfiles/parameterfile.prop" {prompt="Name of Parameterfile"}
string imtype         = "fits"     {prompt="Image Type"}
bool   fit            = NO         {prompt="Fit Blaze function from combined Flat? If not the Blaze function from optextract(combinedFlat) is used. [YES|NO]"}
bool   divbyfilter    = YES        {prompt="Divide Blaze function by Flatfield-Filter function? (YES|NO)"}
string reffilterfunc  = "scripts$spectrographs/ses/flatfilter.text" {prompt="Flatfield-Filter function to divide Blaze function by"}
string observatory    = "Izana"    {prompt="Name of Observatory where spectra were taken"}
int    dispaxis       = 2          {prompt="Dispersion axis (1-horizontal 2-vertical)"}
string ihdate         = "DATE-OBS" {prompt="Image-header keyword for Date Of Observation"}
string ihtime         = ""         {prompt="Image-header keyword for Time Of Observation"}
string ihexptime      = "EXPTIME"  {prompt="Image-header keyword for Exposure Time"}
string ihepoch        = "OBJEQUIN" {prompt="Image-header keyword for Epoch"}
string ihjd           = "JD"       {prompt="Image-header keyword for Julian Date"}
string ihljd          = "LJD"      {prompt="Image-header keyword for Local Julian Date"}
bool   ihutdate       = YES        {prompt="Is observation date UT?"}
bool   ihuttime       = YES        {prompt="Is observation time UT?"}
real   readnoise      = 0.6        {prompt="Read out noise sigma (photons)"}
real   gain           = 3.4        {prompt="Photon gain (photons/data number)"}
int    nsubaps        = 1          {prompt="Number of subapertures per aperture"}
bool   slicer         = NO         {prompt="Does the instrument use an image slicer? [YES|NO]"}
real   ext_lsigma     = 2.3        {prompt="Lower rejection threshold for stextract"}
real   ext_usigma     = 2.3        {prompt="Upper rejection threshold for stextract"}
real   ext_saturation = INDEF      {prompt="Saturation level for stextract"}
real   fit_lsigma     = 2.3        {prompt="Lower rejection threshold for sfit"}
real   fit_usigma     = 2.3        {prompt="Upper rejection threshold for sfit"}
int    fit_niterate   = 3          {prompt="Number of rejection iterations"}
int    fit_naverage   = 3          {prompt="Number of points in sample averaging"}
string function      = "chebyshev" {prompt="SFit fitting function",
                                     enum="legendre|chebyshev|spline1|spline3"}
int    order          = 4          {prompt="SFit fitting function order"}
string instrument     = "echelle"  {prompt="Instrument (echelle|coude)",
                                     enum="echelle|coude"}
bool   interactive    = NO         {prompt="Set fitting parameters interactively? (YES | NO)"}
int    loglevel       = 3          {prompt="Level for writing logfile"}
string logfile        = "logfile_stcrerefblaze.log"  {prompt="Name of log file"}
string warningfile    = "warnings_stcrerefblaze.log" {prompt="Name of warning file"}
string errorfile      = "errors_stcrerefblaze.log"   {prompt="Name of error file"}
string logfile_stidentify = "logfile_stidentify.log" {prompt="Name of log file of stidentify task"}
string *parameterlist
string *templist

begin
  int    i,ordernum,Pos
  string OutFile,OutFile_n
  string ApNoStr = ""
  string HeaderText = ""
  string HeaderFile, DataHeaderFile, TextFile, FitsFile
#  string timefile = "time.txt"
#  string tempdate,tempday,temptime,in,out,errin,errout
  string parameter,parametervalue,tempimage,TempStr
  string format = "multispec"
  string ccdlistoutfile="outfile_ccdlist.text"
  string CombinedFlatNList="combinedFlat_n.list"
  string combinedFlat_n,combinedFlat_nEc,tempfits,templogfile
#  string tempref#="temprefBlaze."//imtype
  string refBlaze_d,refBlaze_f,refBlaze_fn,refBlaze_fn_text
  string refBlaze_dlist, refBlaze_d_textlist, refBlaze_fnd
  string refBlazelist
  string refBlaze_f_textlist
  string refBlaze_f_fitslist
  string logfile_writeaps = "logfile_writeaps.log"
  string warningfile_writeaps = "warningfile_writeaps.log"
  string errorfile_writeaps = "errorfile_writeaps.log"
  string logfile_stextract = "logfile_stextract.log"
  string warningfile_stextract = "warnings_stextract.log"
  string errorfile_stextract = "errors_stextract.log"
  string logfile_strefspec = "logfile_strefspec.log"
  string warningfile_strefspec = "warnings_strefspec.log"
  string errorfile_strefspec = "errors_strefspec.log"
  string logfile_stdispcor = "logfile_stdispcor.log"
  string warningfile_stdispcor = "warnings_stdispcor.log"
  string errorfile_stdispcor = "errors_stdispcor.log"
  string LogFile_staddheader = "logfile_staddheader.log"
  string WarningFile_staddheader = "warnings_staddheader.log"
  string ErrorFile_staddheader = "errors_staddheader.log"
  bool   found_imtype                 = NO
  bool   found_divbyfilter            = NO
  bool   found_reffilterfunc          = NO
  bool   found_observatory            = NO
  bool   found_instrument             = NO
  bool   found_dispaxis               = NO
  bool   found_readnoise              = NO
  bool   found_gain                   = NO
  bool   found_nsubaps                = NO
  bool   found_slicer                 = NO
  bool   found_fit                    = NO
  bool   found_ext_lsigma             = NO
  bool   found_ext_usigma             = NO
  bool   found_ext_saturation         = NO
  bool   found_fit_lsigma             = NO
  bool   found_fit_usigma             = NO
  bool   found_fit_naverage           = NO
  bool   found_fit_niterate           = NO
  bool   found_function               = NO
  bool   found_order                  = NO
  bool   found_interactive            = NO
  bool   found_ihdate                 = NO
  bool   found_ihtime                 = NO
  bool   found_ihexptime              = NO
  bool   found_ihepoch                = NO
  bool   found_ihjd                   = NO
  bool   found_ihljd                  = NO
  bool   found_ihutdate               = NO
  bool   found_ihuttime               = NO

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)
  if (access(warningfile))
    delete(warningfile, ver-)
  if (access(errorfile))
    delete(errorfile, ver-)

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*             creating reference Blaze file              *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("stcrerefblaze: combinedFlat = <"//combinedFlat//">")
  print ("stcrerefblaze: normalizedFlat = <"//normalizedFlat//">")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*             creating reference Blaze file              *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)
  print ("stcrerefblaze: combinedFlat = <"//combinedFlat//">", >> logfile)
  print ("stcrerefblaze: normalizedFlat = <"//normalizedFlat//">", >> logfile)

# --- read parameterfile
  if (access(parameterfile)){

    parameterlist = parameterfile

    print ("stcrerefblaze: **************** reading parameterfile *******************")
    if (loglevel > 2)
      print ("stcrerefblaze: **************** reading parameterfile *******************", >> logfile)

    while (fscan (parameterlist, parameter, parametervalue) != EOF){
      if (parameter == "blaze_divbyfilter"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          divbyfilter = YES
          print ("stcrerefblaze: Setting divbyfilter to YES")
          print ("stcrerefblaze: Setting divbyfilter to YES", >> logfile)
	}
	else{
	  divbyfilter = NO
          print ("stcrerefblaze: Setting divbyfilter to NO")
          print ("stcrerefblaze: Setting divbyfilter to NO", >> logfile)
	}
        found_divbyfilter = YES
      }
      else if (parameter == "blaze_fit"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          fit = YES
          print ("stcrerefblaze: Setting fit to YES")
          print ("stcrerefblaze: Setting fit to YES", >> logfile)
	}
	else{
	  fit = NO
          print ("stcrerefblaze: Setting fit to NO")
          print ("stcrerefblaze: Setting fit to NO", >> logfile)
	}
        found_fit = YES
      }
      else if (parameter == "imtype"){ 
        imtype = parametervalue
        print ("stcrerefblaze: Setting imtype to "//parametervalue)
        print ("stcrerefblaze: Setting imtype to "//parametervalue, >> logfile)
        found_imtype = YES
      }
      else if (parameter == "blaze_reffilterfunc"){ 
        reffilterfunc = parametervalue
        print ("stcrerefblaze: Setting reffilterfunc to "//parametervalue)
        print ("stcrerefblaze: Setting reffilterfunc to "//parametervalue, >> logfile)
        found_reffilterfunc = YES
      }
      else if (parameter == "observatory"){ 
        observatory = parametervalue
        print ("stcrerefblaze: Setting "//parameter//" to "//parametervalue)
        print ("stcrerefblaze: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_observatory = YES
      }
      else if (parameter == "setinst_instrument"){ 
        instrument = parametervalue
        if (instrument != "echelle")
          format = "onedspec"
        print ("stcrerefblaze: Setting "//parameter//" to "//parametervalue)
        print ("stcrerefblaze: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_instrument = YES
      }
      else if (parameter == "dispaxis"){ 
        dispaxis = int(parametervalue)
        print ("stcrerefblaze: Setting dispaxis to "//parametervalue)
        print ("stcrerefblaze: Setting dispaxis to "//parametervalue, >> logfile)
        found_dispaxis = YES
      }
      else if (parameter == "rdnoise"){ 
        readnoise = real(parametervalue)
        print ("stcrerefblaze: Setting readnoise to "//parametervalue)
        print ("stcrerefblaze: Setting readnoise to "//parametervalue, >> logfile)
        found_readnoise = YES
      }
      else if (parameter == "gain"){ 
        gain = real(parametervalue)
        print ("stcrerefblaze: Setting gain to "//parametervalue)
        print ("stcrerefblaze: Setting gain to "//parametervalue, >> logfile)
        found_gain = YES
      }
      else if (parameter == "ext_nsubaps"){ 
        nsubaps = int(parametervalue)
        print ("stcrerefblaze: Setting nsubaps to "//parametervalue)
        print ("stcrerefblaze: Setting nsubaps to "//parametervalue, >> logfile)
        found_nsubaps = YES
      }
      else if (parameter == "slicer"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          slicer = YES
          print ("stcrerefblaze: Setting slicer to YES")
          print ("stcrerefblaze: Setting slicer to YES", >> logfile)
	}
	else{
	  slicer = NO
          print ("stcrerefblaze: Setting slicer to NO")
          print ("stcrerefblaze: Setting slicer to NO", >> logfile)
	}
        found_slicer = YES
      }
      else if (parameter == "ext_lsigma"){ 
        ext_lsigma = real(parametervalue)
        print ("stcrerefblaze: Setting ext_lsigma to "//parametervalue)
        print ("stcrerefblaze: Setting ext_lsigma to "//parametervalue, >> logfile)
        found_ext_lsigma = YES
      }
      else if (parameter == "ext_usigma"){ 
        ext_usigma = real(parametervalue)
        print ("stcrerefblaze: Setting ext_usigma to "//parametervalue)
        print ("stcrerefblaze: Setting ext_usigma to "//parametervalue, >> logfile)
        found_ext_usigma = YES
      }
      else if (parameter == "ext_saturation"){ 
        ext_saturation = real(parametervalue)
        print ("stcrerefblaze: Setting ext_saturation to "//parametervalue)
        print ("stcrerefblaze: Setting ext_saturation to "//parametervalue, >> logfile)
        found_ext_saturation = YES
      }
      else if (parameter == "blaze_fit_naverage"){ 
        fit_naverage = int(parametervalue)
        print ("stcrerefblaze: Setting fit_naverage to "//parametervalue)
        print ("stcrerefblaze: Setting fit_naverage to "//parametervalue, >> logfile)
        found_fit_naverage = YES
      }
      else if (parameter == "blaze_fit_niterate"){ 
        fit_niterate = int(parametervalue)
        print ("stcrerefblaze: Setting fit_niterate to "//parametervalue)
        print ("stcrerefblaze: Setting fit_niterate to "//parametervalue, >> logfile)
        found_fit_niterate = YES
      }
      else if (parameter == "blaze_fit_lsigma"){ 
        fit_lsigma = real(parametervalue)
        print ("stcrerefblaze: Setting fit_lsigma to "//parametervalue)
        print ("stcrerefblaze: Setting fit_lsigma to "//parametervalue, >> logfile)
        found_fit_lsigma = YES
      }
      else if (parameter == "blaze_fit_usigma"){ 
        fit_usigma = real(parametervalue)
        print ("stcrerefblaze: Setting fit_usigma to "//parametervalue)
        print ("stcrerefblaze: Setting fit_usigma to "//parametervalue, >> logfile)
        found_fit_usigma = YES
      }
      else if (parameter == "nflat_flat_function"){ 
        function = parametervalue
        print ("stcrerefblaze: Setting function to "//parametervalue)
        print ("stcrerefblaze: Setting function to "//parametervalue, >> logfile)
        found_function = YES
      }
      else if (parameter == "blaze_fit_order"){ 
        order = int(parametervalue)
        print ("stcrerefblaze: Setting order to "//parametervalue)
        print ("stcrerefblaze: Setting order to "//parametervalue, >> logfile)
        found_order = YES
      }
      else if (parameter == "stprepare_ihdate"){ 
        ihdate = parametervalue
        print ("stcrerefblaze: Setting ihdate to "//parametervalue)
        print ("stcrerefblaze: Setting ihdate to "//parametervalue, >> logfile)
        found_ihdate = YES
      }
      else if (parameter == "stprepare_ihutc"){ 
        ihtime = parametervalue
        print ("stcrerefblaze: Setting ihtime to "//parametervalue)
        print ("stcrerefblaze: Setting ihtime to "//parametervalue, >> logfile)
        found_ihtime = YES
      }
      else if (parameter == "stprepare_ihexptime"){ 
        ihexptime = parametervalue
        print ("stcrerefblaze: Setting ihexptime to "//parametervalue)
        print ("stcrerefblaze: Setting ihexptime to "//parametervalue, >> logfile)
        found_ihexptime = YES
      }
      else if (parameter == "stprepare_ihepoch"){ 
        ihepoch = parametervalue
        print ("stcrerefblaze: Setting ihepoch to "//parametervalue)
        print ("stcrerefblaze: Setting ihepoch to "//parametervalue, >> logfile)
        found_ihepoch = YES
      }
      else if (parameter == "stprepare_ihjd"){ 
        ihjd = parametervalue
        print ("stcrerefblaze: Setting ihjd to "//parametervalue)
        print ("stcrerefblaze: Setting ihjd to "//parametervalue, >> logfile)
        found_ihjd = YES
      }
      else if (parameter == "stprepare_ihljd"){ 
        ihljd = parametervalue
        print ("stcrerefblaze: Setting ihljd to "//parametervalue)
        print ("stcrerefblaze: Setting ihljd to "//parametervalue, >> logfile)
        found_ihljd = YES
      }
      else if (parameter == "stprepare_ihutdate"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          ihutdate = YES
          print ("stcrerefblaze: Setting ihutdate to YES")
          print ("stcrerefblaze: Setting ihutdate to YES", >> logfile)
	}
	else{
	  ihutdate = NO
          print ("stcrerefblaze: Setting ihutdate to NO")
          print ("stcrerefblaze: Setting ihutdate to NO", >> logfile)
	}
        found_ihutdate = YES
      }
      else if (parameter == "stprepare_ihuttime"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          ihuttime = YES
          print ("stcrerefblaze: Setting ihuttime to YES")
          print ("stcrerefblaze: Setting ihuttime to YES", >> logfile)
	}
	else{
	  ihuttime = NO
          print ("stcrerefblaze: Setting ihuttime to NO")
          print ("stcrerefblaze: Setting ihuttime to NO", >> logfile)
	}
        found_ihuttime = YES
      }
#      else if (parameter == "calc_error_propagation"){
#        if (parametervalue == "YES" || parametervalue == "yes"){
#          doerrors = YES
#          print ("stcrerefblaze: Setting doerrors to YES")
#          if (loglevel > 2)
#            print ("stcrerefblaze: Setting doerrors to YES", >> logfile)
#	}
#	else{
#	  doerrors = NO
#          print ("stcrerefblaze: Setting doerrors to NO")
#          if (loglevel > 2)
#            print ("stcrerefblaze: Setting doerrors to NO", >> logfile)
#	}
#        found_calc_error_propagation = YES
#      }
      else if (parameter == "blaze_interactive"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          interactive = YES
          print ("stcrerefblaze: Setting interactive to YES")
          print ("stcrerefblaze: Setting interactive to YES", >> logfile)
	}
	else{
	  interactive = NO
          print ("stcrerefblaze: Setting interactive to NO")
          print ("stcrerefblaze: Setting interactive to NO", >> logfile)
	}
        found_interactive = YES
      }
    } #end while(fscan(parameterlist) != EOF)
    if (!found_fit){
      print("stcrerefblaze: WARNING: parameter blaze_fit not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter blaze_fit not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter blaze_fit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_imtype){
      print("stcrerefblaze: WARNING: parameter imtype not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter imtype not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter imtype not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_observatory){
      print("stcrerefblaze: WARNING: parameter observatory not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter observatory not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter observatory not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_instrument){
      print("stcrerefblaze: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_dispaxis){
      print("stcrerefblaze: WARNING: parameter dispaxis not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter dispaxis not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter dispaxis not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_divbyfilter){
      print("stcrerefblaze: WARNING: parameter blaze_divbyfilter not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter blaze_divbyfilter not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter blaze_divbyfilter not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_reffilterfunc){
      print("stcrerefblaze: WARNING: parameter blaze_reffilterfunc not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter blaze_reffilterfunc not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter blaze_reffilterfunc not found in parameterfile!!! -> using standard", >> warningfile)
    }
#    if (!found_calc_error_propagation){
#      print("stcrerefblaze: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard")
#      print("stcrerefblaze: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard", >> logfile)
#      print("stcrerefblaze: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard", >> warningfile)
#    }
    if (!found_order){
      print("stcrerefblaze: WARNING: parameter blaze_fit_order not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter blaze_fit_order not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter blaze_fit_order not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_function){
      print("stcrerefblaze: WARNING: parameter nflat_flat_function not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter nflat_flat_function not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter nflat_flat_function not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_gain){
      print("stcrerefblaze: WARNING: parameter gain not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter gain not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter gain not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_readnoise){
      print("stcrerefblaze: WARNING: parameter readnoise not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter readnoise not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter readnoise not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_nsubaps){
      print("stcrerefblaze: WARNING: parameter ext_nsubaps not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter ext_nsubaps not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter ext_nsubaps not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_slicer){
      print("stcrerefblaze: WARNING: parameter slicer not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter slicer not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter slicer not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ext_lsigma){
      print("stcrerefblaze: WARNING: parameter ext_lsigma not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter ext_lsigma not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter ext_lsigma not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ext_usigma){
      print("stcrerefblaze: WARNING: parameter ext_usigma not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter ext_usigma not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter ext_usigma not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ext_saturation){
      print("stcrerefblaze: WARNING: parameter ext_saturation not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter ext_saturation not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter ext_saturation not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_fit_lsigma){
      print("stcrerefblaze: WARNING: parameter blaze_fit_lsigma not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter blaze_fit_lsigma not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter blaze_fit_lsigma not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_fit_usigma){
      print("stcrerefblaze: WARNING: parameter blaze_fit_usigma not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter blaze_fit_usigma not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter blaze_fit_usigma not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_fit_naverage){
      print("stcrerefblaze: WARNING: parameter blaze_fit_naverage not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter blaze_fit_naverage not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter blaze_fit_naverage not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_fit_niterate){
      print("stcrerefblaze: WARNING: parameter blaze_fit_niterate not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter blaze_fit_niterate not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter blaze_fit_niterate not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ihdate){
      print("stcrerefblaze: WARNING: parameter stprepare_ihdate not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter stprepare_ihdate not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter stprepare_ihdate not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ihtime){
      print("stcrerefblaze: WARNING: parameter stprepare_ihtime not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter stprepare_ihtime not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter stprepare_ihtime not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ihexptime){
      print("stcrerefblaze: WARNING: parameter stprepare_ihexptime not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter stprepare_ihexptime not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter stprepare_ihexptime not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ihepoch){
      print("stcrerefblaze: WARNING: parameter stprepare_ihepoch not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter stprepare_ihepoch not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter stprepare_ihepoch not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ihjd){
      print("stcrerefblaze: WARNING: parameter stprepare_ihjd not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter stprepare_ihjd not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter stprepare_ihjd not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ihljd){
      print("stcrerefblaze: WARNING: parameter stprepare_ihljd not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter stprepare_ihljd not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter stprepare_ihljd not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ihutdate){
      print("stcrerefblaze: WARNING: parameter stprepare_ihutdate not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter stprepare_ihutdate not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter stprepare_ihutdate not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ihuttime){
      print("stcrerefblaze: WARNING: parameter stprepare_ihuttime not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter stprepare_ihuttime not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter stprepare_ihuttime not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_interactive){
      print("stcrerefblaze: WARNING: parameter blaze_interactive not found in parameterfile!!! -> using standard")
      print("stcrerefblaze: WARNING: parameter blaze_interactive not found in parameterfile!!! -> using standard", >> logfile)
      print("stcrerefblaze: WARNING: parameter blaze_interactive not found in parameterfile!!! -> using standard", >> warningfile)
    }
  }
  else{
    print("stcrerefblaze: WARNING: parameterfile not found!!! -> using standard parameters")
    print("stcrerefblaze: WARNING: parameterfile not found!!! -> using standard parameters", >> logfile)
    print("stcrerefblaze: WARNING: parameterfile not found!!! -> using standard parameters", >> warningfile)
  }

#  tempref="temprefBlaze."//imtype

# --- create refBlaze
  print("stcrerefblaze: Creating reference Blaze image")
  print("stcrerefblaze: Creating reference Blaze image", >> logfile)
  if (strlen(combinedFlat) < 5){
    print("stcrerefblaze: strlen(combinedFlat) = "//strlen(combinedFlat)//" => adding suffix <."//imtype//">")
    combinedFlat = combinedFlat//"."//imtype
  }
  if (substr(combinedFlat,strlen(combinedFlat)-strlen(imtype),strlen(combinedFlat)) != "."//imtype){
    print("stcrerefblaze: substr(combinedFlat,strlen(combinedFlat)-strlen(imtype),strlen(combinedFlat)) = "//substr(combinedFlat,strlen(combinedFlat)-strlen(imtype),strlen(combinedFlat))//" => adding suffix <."//imtype//">")
    combinedFlat = combinedFlat//"."//imtype
  }
  if (fit)
  {
    if (!access(combinedFlat)){
      print("stcrerefblaze: ERROR: "//combinedFlat//" not found!!!")
      print("stcrerefblaze: ERROR: "//combinedFlat//" not found!!!", >> logfile)
      print("stcrerefblaze: ERROR: "//combinedFlat//" not found!!!", >> errorfile)
      print("stcrerefblaze: ERROR: "//combinedFlat//" not found!!!", >> warningfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
    if (strlen(normalizedFlat) < strlen(imtype)+1)
      normalizedFlat = normalizedFlat//"."//imtype
    if (substr(normalizedFlat,strlen(normalizedFlat)-strlen(imtype),strlen(normalizedFlat)) != "."//imtype)
      normalizedFlat = normalizedFlat//"."//imtype
    if (!access(normalizedFlat)){
      print("stcrerefblaze: ERROR: "//normalizedFlat//" not found!!!")
      print("stcrerefblaze: ERROR: "//normalizedFlat//" not found!!!", >> logfile)
      print("stcrerefblaze: ERROR: "//normalizedFlat//" not found!!!", >> errorfile)
      print("stcrerefblaze: ERROR: "//normalizedFlat//" not found!!!", >> warningfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
    combinedFlat_n = substr(combinedFlat,1,strlen(combinedFlat)-strlen(imtype)-1)//"_n."//imtype
    if (access(combinedFlat_n))
      imdel(combinedFlat_n, ver-)
    if (access(combinedFlat_n))
      del(combinedFlat_n, ver-)
    print("stcrerefblaze: dividing combinedFlat <"//combinedFlat//"> by normalizedFlat <"//normalizedFlat//">")
    print("stcrerefblaze: dividing combinedFlat <"//combinedFlat//"> by normalizedFlat <"//normalizedFlat//">", >> logfile)
    imarith(operand1=combinedFlat,
            op="/",
            operand2=normalizedFlat,
            result=combinedFlat_n,
            title="normalized combined Flat",
            divzero=0.,
            hparams="",
            pixtype="real",
            calctype="real",
            ver-,
            noact-)
    if (!access(combinedFlat_n)){
      print("stcrerefblaze: ERROR: "//combinedFlat_n//" not found!!!")
      print("stcrerefblaze: ERROR: "//combinedFlat_n//" not found!!!", >> logfile)
      print("stcrerefblaze: ERROR: "//combinedFlat_n//" not found!!!", >> errorfile)
      print("stcrerefblaze: ERROR: "//combinedFlat_n//" not found!!!", >> warningfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
    print("stcrerefblaze: combinedFlat_n <"//combinedFlat_n//"> ready")
    print("stcrerefblaze: combinedFlat_n <"//combinedFlat_n//"> ready", >> logfile)
# --- extract normalized combined Flat
    print("stcrerefblaze: extracting combinedFlat_n")
    print("stcrerefblaze: extracting combinedFlat_n", >> logfile)
    if (access(CombinedFlatNList))
      del(CombinedFlatNList, ver-)
    print(combinedFlat_n, >> CombinedFlatNList)
    combinedFlat_nEc = substr(combinedFlat_n,1,strlastpos.pos-1)//"Ec."//imtype
    stextract(Images = "@"//CombinedFlatNList,
              Reference = substr(combinedFlat,1,strlen(combinedFlat)-strlen(imtype)-1),
              Calibs-,
              Objects-,
              ImType = imtype,
              Slicer = slicer,
              Interact-,
              ReCenter-,
              ReSize-,
              Edit-,
              Trace-,
              Clean-,
              ReadNoise = readnoise,
              Gain = gain,
              LSigma = ext_lsigma,
              USigma = ext_usigma,
              Extras-,
              BackGround = "none",
              Weights = "none",
              PFit = "fit1d",
              Saturation = ext_saturation,
              NSubAps = nsubaps,
              LogLevel = loglevel,
              Instrument = instrument,
              ParameterFile = "",
              DoErrors-,
              DelInput-,
              LogFile = logfile_stextract,
              WarningFile = warningfile_stextract,
              ErrorFile = errorfile_stextract)
    if (access(logfile_stextract))
      cat(logfile_stextract, >> logfile)
    if (access(warningfile_stextract))
      cat(warningfile_stextract, >> warningfile)
    if (access(errorfile_stextract)){
      cat(errorfile_stextract, >> errorfile)
      print("stcrerefblaze: ERROR: Task stextract returned ERROR => returning")
      print("stcrerefblaze: ERROR: Task stextract returned ERROR => returning", >> logfile)
      print("stcrerefblaze: ERROR: Task stextract returned ERROR => returning", >> warningfile)
      print("stcrerefblaze: ERROR: Task stextract returned ERROR => returning", >> errorfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
  }
# --- delete old files
  for (i=1; i<=nsubaps; i = i+1){
    if (fit)
    {
      if (nsubaps == 1){
        strlastpos(combinedFlat_n,".")
        if (instrument == "echelle"){
          combinedFlat_nEc = substr(combinedFlat_n,1,strlastpos.pos-1)//"Ec."//imtype
        }
        else{
          combinedFlat_nEc = substr(combinedFlat_n,1,strlastpos.pos-1)//"Ec.0001."//imtype
        }
      }
      else{
        ApNoStr = ""
        if (nsubaps > 99 && i < 100)
          ApNoStr = "0"
        if (nsubaps > 9 && i < 10)
          ApNoStr = ApNoStr//"0"
        ApNoStr = ApNoStr//i
        strlastpos(combinedFlat_n,".")
        if (instrument == "echelle")
          combinedFlat_nEc = substr(combinedFlat_n,1,strlastpos.pos-1)//"Ec"//ApNoStr//"."//imtype
        else
          combinedFlat_nEc = substr(combinedFlat_n,1,strlastpos.pos-1)//"Ec."//ApNoStr//"001."//imtype
      }
      if (!access(combinedFlat_nEc)){
        print("stcrerefblaze: ERROR: Cannot access combinedFlat_nEc = <"//combinedFlat_nEc//"> => returning")
        print("stcrerefblaze: ERROR: Cannot access combinedFlat_nEc = <"//combinedFlat_nEc//"> => returning", >> logfile)
        print("stcrerefblaze: ERROR: Cannot access combinedFlat_nEc = <"//combinedFlat_nEc//"> => returning", >> warningfile)
        print("stcrerefblaze: ERROR: Cannot access combinedFlat_nEc = <"//combinedFlat_nEc//"> => returning", >> errorfile)
# --- clean up
        parameterlist = ""
        templist = ""
        return
      }
      print("stcrerefblaze: combinedFlat_nEc <"//combinedFlat_nEc//"> ready")
      print("stcrerefblaze: combinedFlat_nEc <"//combinedFlat_nEc//"> ready", >> logfile)
# --- fit extracted normalized combined Flat
      print("stcrerefblaze: fitting extracted normalized combined Flat")
      print("stcrerefblaze: fitting extracted normalized combined Flat", >> logfile)
      TempStr = substr(combinedFlat_nEc,1,strlen(combinedFlat_nEc)-strlen(imtype)-1)
      OutFile           = "refBlaze_"//TempStr//"_fit."//imtype
      OutFile_n         = "refBlaze_"//TempStr//"_fitn."//imtype
      refBlaze_d        = "refBlaze_"//TempStr//"_fitnd."//imtype
      refBlaze_f        = "refBlaze_"//TempStr//"_fitndf."//imtype
      refBlaze_fn       = "refBlaze_"//TempStr//"_fitndfn."//imtype
      refBlaze_fn_text  = "refBlaze_"//TempStr//"_fitndfn.text"
    }# end if (fit)
    else
    {
      OutFile           = blaze_in
      strlastpos(blaze_in, ".")
      TempStr = substr(blaze_in,1,strlastpos.pos-1)
      OutFile_n         = TempStr//"_n."//imtype
      refBlaze_d        = TempStr//"_nd."//imtype
      refBlaze_f        = TempStr//"_ndf."//imtype
      refBlaze_fn       = TempStr//"_ndfn."//imtype
      refBlaze_fn_text  = TempStr//"_ndfn.text"
    }
    if (access(refBlaze_d))
      del(refBlaze_d, ver-)
    if (fit)
    {
      if (access(OutFile))
        del(OutFile, ver-)
# --- load onedspec package
      onedspec
      flpr
      sfit(input=combinedFlat_nEc,
           output=OutFile,
           ask+,
           lines="*",
           bands="1",
           type="fit",
           replace+,
           wavescale-,
           logscale-,
           override+,
           listonly-,
           logfiles=logfile,
           interactive=interactive,
           sample="*",
           naverage=fit_naverage,
           function=function,
           order=order,
           low_reject=fit_lsigma,
           high_reject=fit_usigma,
           niterate=fit_niterate,
           grow=1.,
           markrej-)
      if (!access(OutFile)){
        print("stcrerefblaze: ERROR: "//OutFile//" not found!!!")
        print("stcrerefblaze: ERROR: "//OutFile//" not found!!!", >> logfile)
        print("stcrerefblaze: ERROR: "//OutFile//" not found!!!", >> errorfile)
        print("stcrerefblaze: ERROR: "//OutFile//" not found!!!", >> warningfile)
# --- clean up
        parameterlist = ""
        templist = ""
        return
      }
      print("stcrerefblaze: OutFile <"//OutFile//"> ready")
      print("stcrerefblaze: OutFile <"//OutFile//"> ready", >> logfile)
    }
    ccdlist (OutFile)
# --- normalize
    print("stcrerefblaze: Normalizing OutFile <"//OutFile//">")
    print("stcrerefblaze: Normalizing OutFile <"//OutFile//">", >> logfile)
    getmax(OutFile)
    if (access(OutFile_n))
      del(OutFile_n, ver-)
    sarith(input1    = OutFile,
           op        = "/",
           input2    = getmax.max,
           output    = OutFile_n,
           w1        = INDEF,
           w2        = INDEF,
           apertures = "",
           bands     = "",
           beams     = "",
           apmodulus = 0,
           reverse-,
           ignoreaps-,
           format    = format,
           renumbe-,
           offset    = 0,
           clobber-,
           merge-,
           rebin-,
           errval    = 0.,
           ver-)
    if (!access(OutFile_n)){
      print("stcrerefblaze: ERROR: OutFile_n <"//OutFile_n//"> not accessable => returning")
      print("stcrerefblaze: ERROR: OutFile_n <"//OutFile_n//"> not accessable => returning", >> logfile)
      print("stcrerefblaze: ERROR: OutFile_n <"//OutFile_n//"> not accessable => returning", >> warningfile)
      print("stcrerefblaze: ERROR: OutFile_n <"//OutFile_n//"> not accessable => returning", >> errorfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
    
    print("stcrerefblaze: Starting setjd(OutFile_n=<"//OutFile_n//">)")
    print("stcrerefblaze: Starting setjd(OutFile_n=<"//OutFile_n//">)", >> logfile)
    setjd(images      = OutFile_n,
          observatory = observatory,
          date        = ihdate,
#            time="",#ihtime,
          exposure    = ihexptime,
          ra          = " ",
          dec         = " ",
          epoch       = ihepoch,
          jd          = ihjd,
          hjd         = " ",
          ljd         = ihljd,
          utdate      = ihutdate,
          uttime      = ihuttime,
          listonly-)
#      if (access(tempref))
#        delete(tempref, ver-)
#      imcopy(input=OutFile,
#             output=tempref,
#             ver-)

    strlastpos(OutFile_n, ".")
    refBlazelist = substr(OutFile_n, 1, strlastpos.pos)//"list"

    if (access(refBlazelist))
      del(refBlazelist, ver-)
    print(OutFile_n, >> refBlazelist)
    strlastpos(logfile_stidentify,".")
    templogfile = substr(logfile_stidentify,1,strlastpos.pos-1)//ApNoStr//substr(logfile_stidentify,strlastpos.pos,strlen(logfile_stidentify))
    print("stcrerefblaze: starting strefspec(images=@<"//refBlazelist//">)")
    print("stcrerefblaze: starting strefspec(images=@<"//refBlazelist//">)", >> logfile)
    strefspec(images = "@"//refBlazelist,
              logfile_stid = templogfile,
              parameterfile = parameterfile,
              loglevel = loglevel,
              logfile = logfile_strefspec,
              warningfile = warningfile_strefspec,
              errorfile = errorfile_strefspec)
    if (access(logfile_strefspec))
      cat(logfile_strefspec, >> logfile)
    if (access(warningfile_strefspec))
      cat(warningfile_strefspec, >> warningfile)
    if (access(errorfile_strefspec)){
      cat(errorfile_strefspec, >> errorfile)
      print("stcrerefblaze: ERROR: Task strefspec returned ERROR => returning")
      print("stcrerefblaze: ERROR: Task strefspec returned ERROR => returning", >> logfile)
      print("stcrerefblaze: ERROR: Task strefspec returned ERROR => returning", >> warningfile)
      print("stcrerefblaze: ERROR: Task strefspec returned ERROR => returning", >> errorfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
    print("stcrerefblaze: starting stdispcor(images=@<"//refBlazelist//">)")
    print("stcrerefblaze: starting stdispcor(images=@<"//refBlazelist//">)", >> logfile)
    stdispcor(images = "@"//refBlazelist,
              calibs-,
              errorimages = "",
              parameterfile = parameterfile,
              instrument = instrument,
	      linearize-,
	      log-,
	      flux-,
	      samedisp-,
	      global-,
	      ignoreaps-,
	      doerrors-,
	      delinput-,
	      loglevel = loglevel,
	      logfile = logfile_stdispcor,
	      warningfile = warningfile_stdispcor,
	      errorfile = errorfile_stdispcor)
    if (access(logfile_stdispcor))
      cat(logfile_stdispcor, >> logfile)
    if (access(warningfile_stdispcor))
      cat(warningfile_stdispcor, >> warningfile)
    if (access(errorfile_stdispcor)){
      cat(errorfile_stdispcor, >> errorfile)
      print("stcrerefblaze: ERROR: Task stdispcor returned ERROR => returning")
      print("stcrerefblaze: ERROR: Task stdispcor returned ERROR => returning", >> logfile)
      print("stcrerefblaze: ERROR: Task stdispcor returned ERROR => returning", >> warningfile)
      print("stcrerefblaze: ERROR: Task stdispcor returned ERROR => returning", >> errorfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
# --- write orders of OutFile_n and refBlaze_d
    print("stcrerefblaze: starting writeaps(OutFile_n = <"//OutFile_n//"> and refBlaze_d = <"//refBlaze_d//">)")
    print("stcrerefblaze: starting writeaps(OutFile_n = <"//OutFile_n//"> and refBlaze_d = <"//refBlaze_d//">)", >> logfile)
    writeaps(Input       = OutFile_n,
             DispAxis    = dispaxis,
	     Delimiter   = "_",
	     ImType      = imtype,
             WriteFits+,
	     WSpecText+,
	     WriteHeads+,
	     WriteLists+,
	     CreateDirs+,
	     LogLevel    = loglevel,
	     LogFile     = logfile_writeaps,
	     WarningFile = warningfile_writeaps,
	     ErrorFile   = errorfile_writeaps)
    if (access(logfile_writeaps))
      cat(logfile_writeaps, >> logfile)
    if (access(warningfile_writeaps))
      cat(warningfile_writeaps, >> warningfile)
    if (access(errorfile_writeaps)){
      cat(errorfile_writeaps, >> errorfile)
      jobs()
      wait()
      print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning")
      print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning", >> logfile)
      print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning", >> warningfile)
      print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning", >> errorfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
    strlastpos(OutFile_n, ".")
    HeaderFile = substr(OutFile_n, 1, strlastpos.pos-1)//"_head.text"
    if (!access(HeaderFile)){
      print("stcrerefblaze: ERROR: HeaderFile <"//HeaderFile//"> not accessable => returning")
      print("stcrerefblaze: ERROR: HeaderFile <"//HeaderFile//"> not accessable => returning", >> logfile)
      print("stcrerefblaze: ERROR: HeaderFile <"//HeaderFile//"> not accessable => returning", >> warningfile)
      print("stcrerefblaze: ERROR: HeaderFile <"//HeaderFile//"> not accessable => returning", >> errorfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
    refBlazelist = substr(OutFile_n,1,strlastpos.pos-1)//"_text.list"
    if (!access(refBlazelist)){
      print("stcrerefblaze: ERROR: refBlazelist <"//refBlazelist//"> not accessable => returning")
      print("stcrerefblaze: ERROR: refBlazelist <"//refBlazelist//"> not accessable => returning", >> logfile)
      print("stcrerefblaze: ERROR: refBlazelist <"//refBlazelist//"> not accessable => returning", >> warningfile)
      print("stcrerefblaze: ERROR: refBlazelist <"//refBlazelist//"> not accessable => returning", >> errorfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
    writeaps(Input=refBlaze_d,
             DispAxis=dispaxis,
             Delimiter="_",
             WriteFits+,
             WSpecText+,
             WriteHeads+,
             WriteLists+,
             CreateDirs+,
             LogLevel    = loglevel,
             LogFile     = logfile_writeaps,
             WarningFile = warningfile_writeaps,
             ErrorFile   = errorfile_writeaps)
    if (access(logfile_writeaps))
      cat(logfile_writeaps, >> logfile)
    if (access(warningfile_writeaps))
      cat(warningfile_writeaps, >> warningfile)
    if (access(errorfile_writeaps)){
      cat(errorfile_writeaps, >> errorfile)
      jobs()
      wait()
      print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning")
      print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning", >> logfile)
      print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning", >> warningfile)
      print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning", >> errorfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
    strlastpos(refBlaze_d, ".")
    refBlaze_dlist = substr(refBlaze_d,1,strlastpos.pos-1)//"_text.list"
    if (!access(refBlaze_dlist)){
      print("stcrerefblaze: ERROR: refBlaze_dlist <"//refBlaze_dlist//"> not accessable => returning")
      print("stcrerefblaze: ERROR: refBlaze_dlist <"//refBlaze_dlist//"> not accessable => returning", >> logfile)
      print("stcrerefblaze: ERROR: refBlaze_dlist <"//refBlaze_dlist//"> not accessable => returning", >> warningfile)
      print("stcrerefblaze: ERROR: refBlaze_dlist <"//refBlaze_dlist//"> not accessable => returning", >> errorfile)
# --- clean up
      parameterlist = ""
      templist = ""
      return
    }
    print("stcrerefblaze: refBlaze_dlist <"//refBlaze_dlist//"> ready")
    if (loglevel > 1)
      print("stcrerefblaze: refBlaze_dlist <"//refBlaze_dlist//"> ready", >> logfile)

# --- divide OutFile by reffilterfunc
    if (divbyfilter){
      if (!access(reffilterfunc)){
        print("stcrerefblaze: ERROR: "//reffilterfunc//" not found!!!")
        print("stcrerefblaze: ERROR: "//reffilterfunc//" not found!!!", >> logfile)
        print("stcrerefblaze: ERROR: "//reffilterfunc//" not found!!!", >> errorfile)
        print("stcrerefblaze: ERROR: "//reffilterfunc//" not found!!!", >> warningfile)
# --- clean up
        parameterlist = ""
        templist = ""
        return
      }
      if (i == 1){
        strlastpos(reffilterfunc,"/")
        if (access(substr(reffilterfunc, strlastpos.pos+1, strlen(reffilterfunc))))
          del (substr(reffilterfunc, strlastpos.pos+1, strlen(reffilterfunc)), ver-)
        copy(input=reffilterfunc,
             output="./",
             ver-)
        reffilterfunc = substr(reffilterfunc, strlastpos.pos+1, strlen(reffilterfunc))
      }
# --- start divblazebyflatfilter.c
      getpath()
      print("stcrerefblaze: Starting divblazebyflatfilter("//getpath.path//"/"//refBlaze_dlist//", "//getpath.path//"/"//refBlaze_dlist//", reffilterfunc = "//reffilterfunc)
      print("stcrerefblaze: Starting divblazebyflatfilter("//getpath.path//"/"//refBlaze_dlist//", "//getpath.path//"/"//refBlaze_dlist//", reffilterfunc = "//reffilterfunc, >> logfile)
      divblazebyflatfilter(getpath.path//"/"//refBlazelist, getpath.path//"/"//refBlaze_dlist, reffilterfunc)

# --- read divblazebyflatfilter output
      if (access(refBlaze_f))
        del(refBlaze_f, ver-)
      imcopy(input=OutFile_n,
             output=refBlaze_f,
             ver-)

      strlastpos(refBlaze_f,".")
      refBlaze_f_textlist = substr(refBlaze_f, 1, strlastpos.pos-1)//"_text.list"
      refBlaze_f_fitslist = substr(refBlaze_f, 1, strlastpos.pos-1)//"_fits.list"

      if (access(refBlaze_f_textlist))
        del(refBlaze_f_textlist, ver-)
      if (access(refBlaze_f_fitslist))
        del(refBlaze_f_fitslist, ver-)
      templist = refBlazelist
      while(fscan(templist,tempimage) != EOF){
        strlastpos(tempimage,".")
        Pos = strlastpos.pos
        if (Pos < 1)
          Pos = strlen(tempimage) + 1
        TextFile = substr(tempimage, 1, Pos-1)//"_f"
        FitsFile = TextFile//".fits"
        DataHeaderFile = TextFile//"+head.text"
        TextFile = TextFile//".text"
        if (access(DataHeaderFile))
          del(DataHeaderFile)
        cat(HeaderFile, >> DataHeaderFile)
        if (!access(TextFile)){
          print("stcrerefblaze: ERROR: TextFile <"//TextFile//"> not accessable => returning")
          print("stcrerefblaze: ERROR: TextFile <"//TextFile//"> not accessable => returning", >> logfile)
          print("stcrerefblaze: ERROR: TextFile <"//TextFile//"> not accessable => returning", >> warningfile)
          print("stcrerefblaze: ERROR: TextFile <"//TextFile//"> not accessable => returning", >> errorfile)
# --- clean up
          parameterlist = ""
          templist = ""
          return
        }
        print("", >> DataHeaderFile)
        cat(TextFile, >> DataHeaderFile)
        print(DataHeaderFile, >> refBlaze_f_textlist)
        print("stcrerefblaze: out file from divblazebyflatfilter = <"//TextFile//">")
        print(FitsFile, >> refBlaze_f_fitslist)
        if (access(FitsFile))
          del(FitsFile, ver-)
      }
#      hedit.images = ""
#      hedit.fields = ""
#      hedit.value = ""
      unlearn("hedit")
      print("stcrerefblaze: Starting rspectext(input=<"//getpath.path//"/"//refBlaze_f_textlist//">, output=<"//getpath.path//"/"//refBlaze_f_fitslist//">)")
      print("stcrerefblaze: Starting rspectext(input=<"//getpath.path//"/"//refBlaze_f_textlist//">, output=<"//getpath.path//"/"//refBlaze_f_fitslist//">)", >> logfile)
      rspectext(input="@"//refBlaze_f_textlist,
                output="@"//refBlaze_f_fitslist,
                title="reference Blaze function divided by flat filter function",
                flux-,
                dtype="interp")
      print("stcrerefblaze: rspectext ready")
      templist = refBlaze_f_fitslist
      ordernum = 0
      while(fscan(templist,tempimage) != EOF){
        ordernum = ordernum + 1
        imcopy(input=tempimage,
               output=refBlaze_f//"[*,"//ordernum//"]",
               ver-)
      }
      hedit(images=refBlaze_f,
            fields="STCREREFBLAZE",
            value="reference-filter function "//reffilterfunc,
            add+,
            addonly+,
            del-,
            ver-,
            show+,
            update+)
      print("stcrerefblaze: refBlaze_f <"//refBlaze_f//"> ready")
      if (loglevel > 2)
        print("stcrerefblaze: refBlaze_f <"//refBlaze_f//"> ready", >> logfile)

# --- normalize
      if (access(refBlaze_fn))
        del(refBlaze_fn, ver-)
      getmax(refBlaze_f)
      if (access(refBlaze_fn))
        del(refBlaze_fn, ver-)
      print("stcrerefblaze: starting sarith(input1=<"//refBlaze_f//">, op=/, input2=getmax.max=<"//getmax.max//">, output=refBlaze_fn=<"//refBlaze_fn//")")
      if (loglevel > 1)
        print("stcrerefblaze: starting sarith(input1=<"//refBlaze_f//">, op=/, input2=getmax.max=<"//getmax.max//">, output=refBlaze_fn=<"//refBlaze_fn//")", >> logfile)
      sarith(input1    = refBlaze_f,
             op        = "/",
             input2    = getmax.max,
             output    = refBlaze_fn,
             w1        = INDEF,
             w2        = INDEF,
             apertures = "",
             bands     = "",
             beams     = "",
             apmodulus = 0,
             reverse-,
             ignoreaps-,
             format    = format,
             renumbe-,
             offset    = 0,
             clobber-,
             merge-,
             rebin-,
             errval    = 0.,
             ver-)
      if (!access(refBlaze_fn)){
        print("stcrerefblaze: ERROR: refBlaze_fn <"//refBlaze_fn//"> not accessable => returning")
        print("stcrerefblaze: ERROR: refBlaze_fn <"//refBlaze_fn//"> not accessable => returning", >> logfile)
        print("stcrerefblaze: ERROR: refBlaze_fn <"//refBlaze_fn//"> not accessable => returning", >> warningfile)
        print("stcrerefblaze: ERROR: refBlaze_fn <"//refBlaze_fn//"> not accessable => returning", >> errorfile)
# --- clean up
        parameterlist = ""
        templist = ""
        return
      }
      print("stcrerefblaze: refBlaze_fn <"//refBlaze_fn//"> ready")

# --- correct refBlaze_fn for the dispersion
      
      strlastpos(refBlaze_fn, ".")
      refBlaze_fnd = substr(refBlaze_fn, 1, strlastpos.pos-1)//"d"//substr(refBlaze_fn, strlastpos.pos, strlen(refBlaze_fn))
      if (access(refBlaze_fnd))
        del(refBlaze_fnd, ver-)
      
#      imcopy(input  = refBlaze_fn, 
#             output = refBlaze_fnd,
#             ver-)
#      staddheader(Images = refBlaze_fn,
#                  Headers = HeaderFile,
#                  LogLevel = loglevel,
#                  LogFile = LogFile_staddheader,
#                  WarningFile = WarningFile_staddheader,
#                  ErrorFile = ErrorFile_staddheader)
#      if (access(LogFile_staddheader))
#        cat(LogFile_staddheader, >> logfile)
#      if (access(WarningFile_staddheader))
#        cat(WarningFile_staddheader, >> warningfile)
#      if (access(ErrorFile_staddheader)){
#        cat(ErrorFile_staddheader, >> errorfile)
#        jobs()
#        wait()
#        print("stcrerefblaze: ERROR: ErrorFile_staddheader <"//ErrorFile_staddheader//"> found! => Returning")
#        print("stcrerefblaze: ERROR: ErrorFile_staddheader <"//ErrorFile_staddheader//"> found! => Returning", >> logfile)
#        print("stcrerefblaze: ERROR: ErrorFile_staddheader <"//ErrorFile_staddheader//"> found! => Returning", >> warningfile)
#        print("stcrerefblaze: ERROR: ErrorFile_staddheader <"//ErrorFile_staddheader//"> found! => Returning", >> errorfile)
## --- clean up
#        parameterlist = ""
#        templist = ""
#        return
#      }
    
      print("stcrerefblaze: Starting setjd(refBlaze_fn=<"//refBlaze_fn//">)")
      print("stcrerefblaze: Starting setjd(refBlaze_fn=<"//refBlaze_fn//">)", >> logfile)
      setjd(images      = refBlaze_fn,
            observatory = observatory,
            date        = ihdate,
            exposure    = ihexptime,
            ra          = " ",
            dec         = " ",
            epoch       = ihepoch,
            jd          = ihjd,
            hjd         = " ",
            ljd         = ihljd,
            utdate      = ihutdate,
            uttime      = ihuttime,
            listonly-)

      strlastpos(refBlaze_fn, ".")
      refBlazelist = substr(refBlaze_fn, 1, strlastpos.pos)//"list"

      if (access(refBlazelist))
        del(refBlazelist, ver-)
      print(refBlaze_fn, >> refBlazelist)
      strlastpos(logfile_stidentify,".")
      templogfile = substr(logfile_stidentify,1,strlastpos.pos-1)//ApNoStr//substr(logfile_stidentify,strlastpos.pos,strlen(logfile_stidentify))
      print("stcrerefblaze: starting strefspec(images=@<"//refBlaze_dlist//">)")
      print("stcrerefblaze: starting strefspec(images=@<"//refBlaze_dlist//">)", >> logfile)
      strefspec(images = "@"//refBlazelist,
                logfile_stid = templogfile,
                parameterfile = parameterfile,
                loglevel = loglevel,
                logfile = logfile_strefspec,
                warningfile = warningfile_strefspec,
                errorfile = errorfile_strefspec)
      if (access(logfile_strefspec))
        cat(logfile_strefspec, >> logfile)
      if (access(warningfile_strefspec))
        cat(warningfile_strefspec, >> warningfile)
      if (access(errorfile_strefspec)){
        cat(errorfile_strefspec, >> errorfile)
        print("stcrerefblaze: ERROR: Task strefspec returned ERROR => returning")
        print("stcrerefblaze: ERROR: Task strefspec returned ERROR => returning", >> logfile)
        print("stcrerefblaze: ERROR: Task strefspec returned ERROR => returning", >> warningfile)
        print("stcrerefblaze: ERROR: Task strefspec returned ERROR => returning", >> errorfile)
# --- clean up
        parameterlist = ""
        templist = ""
        return
      }
      print("stcrerefblaze: starting stdispcor(images=@<"//refBlazelist//">)")
      print("stcrerefblaze: starting stdispcor(images=@<"//refBlazelist//">)", >> logfile)
      stdispcor(images = "@"//refBlazelist,
                calibs-,
                errorimages = "",
                parameterfile = "",
                instrument = instrument,
                linearize-,
                log-,
                flux-,
                samedisp-,
                global-,
                ignoreaps-,
                doerrors-,
                delinput-,
                loglevel = loglevel,
                logfile = logfile_stdispcor,
                warningfile = warningfile_stdispcor,
                errorfile = errorfile_stdispcor)
      if (access(logfile_stdispcor))
        cat(logfile_stdispcor, >> logfile)
      if (access(warningfile_stdispcor))
        cat(warningfile_stdispcor, >> warningfile)
      if (access(errorfile_stdispcor)){
        cat(errorfile_stdispcor, >> errorfile)
        print("stcrerefblaze: ERROR: Task stdispcor returned ERROR => returning")
        print("stcrerefblaze: ERROR: Task stdispcor returned ERROR => returning", >> logfile)
        print("stcrerefblaze: ERROR: Task stdispcor returned ERROR => returning", >> warningfile)
        print("stcrerefblaze: ERROR: Task stdispcor returned ERROR => returning", >> errorfile)
# --- clean up
        parameterlist = ""
        templist = ""
        return
      }
# --- write orders of refBlaze_fnd
      strlastpos(refBlaze_fn, ".")
      Pos = strlastpos.pos
      if (Pos == 0)
        Pos = strlen(refBlaze_fn) + 1
      refBlaze_fnd = substr(refBlaze_fn, 1, Pos-1)//"d"//substr(refBlaze_fn, Pos, strlen(refBlaze_fn))
      if (!access(refBlaze_fnd)){
        print("stcrerefblaze: ERROR: refBlaze_fnd <"//refBlaze_fnd//"> not found! => returning")
        print("stcrerefblaze: ERROR: refBlaze_fnd <"//refBlaze_fnd//"> not found! => returning", >> logfile)
        print("stcrerefblaze: ERROR: refBlaze_fnd <"//refBlaze_fnd//"> not found! => returning", >> warningfile)
        print("stcrerefblaze: ERROR: refBlaze_fnd <"//refBlaze_fnd//"> not found! => returning", >> errorfile)
# --- clean up
        parameterlist = ""
        templist = ""
        return
      }

      print("stcrerefblaze: starting writeaps(refBlaze_fnd = <"//refBlaze_fnd//">)")
      print("stcrerefblaze: starting writeaps(refBlaze_fnd = <"//refBlaze_fnd//">)", >> logfile)
      writeaps(Input       = refBlaze_fnd,
               DispAxis    = dispaxis,
               Delimiter   = "_",
	       ImType      = imtype,
               WriteFits+,
               WSpecText+,
               WriteHeads+,
               WriteLists+,
               CreateDirs+,
               LogLevel    = loglevel,
               LogFile     = logfile_writeaps,
               WarningFile = warningfile_writeaps,
               ErrorFile   = errorfile_writeaps)
      if (access(logfile_writeaps))
        cat(logfile_writeaps, >> logfile)
      if (access(warningfile_writeaps))
        cat(warningfile_writeaps, >> warningfile)
      if (access(errorfile_writeaps)){
        cat(errorfile_writeaps, >> errorfile)
        jobs()
        wait()
        print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning")
        print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning", >> logfile)
        print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning", >> warningfile)
        print("stcrerefblaze: ERROR: errorfile_writeaps <"//errorfile_writeaps//"> found! => Returning", >> errorfile)
# --- clean up
        parameterlist = ""
        templist = ""
        return
      }
      strlastpos(refBlaze_fnd, ".")
      refBlaze_d_textlist = substr(refBlaze_fnd,1,strlastpos.pos-1)//"_text.list"
      if (!access(refBlaze_d_textlist)){
        print("stcrerefblaze: ERROR: refBlaze_d_textlist <"//refBlaze_d_textlist//"> not accessable => returning")
        print("stcrerefblaze: ERROR: refBlaze_d_textlist <"//refBlaze_d_textlist//"> not accessable => returning", >> logfile)
        print("stcrerefblaze: ERROR: refBlaze_d_textlist <"//refBlaze_d_textlist//"> not accessable => returning", >> warningfile)
        print("stcrerefblaze: ERROR: refBlaze_d_textlist <"//refBlaze_d_textlist//"> not accessable => returning", >> errorfile)
# --- clean up
        parameterlist = ""
        templist = ""
        return
      }
      
      if (blaze_out != refBlaze_fnd)
      {
        if (access(blaze_out))
          del(blaze_out, ver-)
        imcopy(refBlaze_fnd,blaze_out,ver-)
      }
    }# --- end if (divbyfilter)
    else{
      refBlaze_fn = OutFile_n
      hedit(images=refBlaze_fn,
            fields="STCREREFBLAZE",
            value="no reference-filter function ",
            add+,
            addonly+,
            del-,
            ver-,
            show+,
            update+)
      if (blaze_out != refBlaze_fn)
      {
        if (access(blaze_out))
          del(blaze_out, ver-)
        imcopy(refBlaze_d,blaze_out,ver-)
      }
    }
  }# end for (i=1; i<=nsubaps; i = i+1){

# --- clean up
  parameterlist = ""
  templist = ""
end
