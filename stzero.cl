procedure stzero (biasimages)

##################################################################
#                                                                #
# NAME:             stzero.cl                                    #
# PURPOSE:          * combines the Bias images automatically     #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stzero(biasimages)                           #
# INPUTS:           biasimages: String                           #
#                     name of list containing names of Bias      #
#                     images to combine:                         #
#                       "zeros.list":                            #
#                         bias_01.fits                           #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     combinedZero.fits                          #
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

string biasimages    = "@zeros.list"                 {prompt="List of bias images"}
string combinedzero  = "combinedZero.fits"           {prompt="Name of output image"}
string sigmaimage    = "combinedZero_sig.fits"       {prompt="Name of output sigma image"}
string parameterfile = "scripts$parameterfile.prop"  {prompt="Parameterfile"}
int    NumCCDs            = 1      {prompt="Number of CCDS for instrument"}
real   rdnoise            = 3.69   {prompt="ccdclip: Read out noise sigma (photons)"}
real   gain               = 0.68   {prompt="ccdclip: Photon gain (photons/data number)"}
real   snoise             = 0.     {prompt="ccdclip: Sensitivity noise (fraction)"}
real   normalbiasmean     = 220.5  {prompt="Normal bias mean"}
real   normalbiasstddev   = 450.3  {prompt="Normal bias stddev"}
real   maxmeanbiaserror   = 2.     {prompt="Maximum mean error for Zeros"}
real   maxstddevbiaserror = 3.     {prompt="Maximum stddev error for Zeros"}
string combine  = "average" {prompt="Type of combine operation",
                              enum="average|median"}
string reject   = "minmax"  {prompt="Type of rejection",
                              enum="none|minmax|ccdclip|crreject|sigclip|avsigclip|pclip"}
string offsets  = "none"    {prompt="Input image offsets",
                              enum="none|wcs|grid|<filename>"}
string scale    = "none"    {prompt="Multiplicative image scaling to be applied",
                              enum="none|mode|median|mean|exposure|@<file>|!<keyword>"}
string zero     = "none"    {prompt="Additive zero level image shifts to be applied",
                              enum="none|mode|median|mean|@<file>|!<keyword>"}
string weight   = "none"    {prompt="Weights to be applied during the final averaging",
                              enum="none|mode|median|mean|exposure|@<file>|!<keyword>"}
string ccdsec  = "[4:2000,10:2000]" {prompt="CCD section to use"}
string statsec  = "[4:2000,10:2000]" {prompt="Section of images to use in computing image statistics"}
real   lthreshold = INDEF   {prompt="Low rejection threshold"}
real   hthreshold = INDEF   {prompt="High rejection threshold"}
int    nlow     = 0      {prompt="minmax: Number of low pixels to be rejected"}
int    nhigh    = 1      {prompt="minmax: Number of high pixels to be rejected"}
int    nkeep    = 1      {prompt="clipping algorithms: Minimum to keep (pos) or maximum to reject (neg)"}
bool   mclip    = YES    {prompt="clipping algorithms: Use median in sigma clipping algorithms?"}
real   lsigma   = 3.     {prompt="clipping algorithms: Low and sigma clipping factors"}
real   hsigma   = 3.     {prompt="clipping algorithms: High sigma clipping factors"}
real   sigscale = 0.1    {prompt="clipping algorithms: Tolerance for sigma clipping scaling corrections"}
real   pclip    = -0.5   {prompt="clipping algorithms: Percentile clipping parameter"}
int    grow     = 0      {prompt="rejection algorithms: Radius (pixels) for 1D neighbor rejection"}
bool   doerrors = YES    {prompt="Calculate sigma image?"}
string ImType   = "fits" {prompt="Image type"}
bool   delinput = NO     {prompt="Delete input images after processing?"}
int    loglevel = 3.     {prompt="Level for writing logfile"}
string logfile     = "logfile_stzero.log"  {prompt="Name of log file"}
string warningfile = "warnings_stzero.log" {prompt="Name of warning file"}
string errorfile   = "errors_stzero.log"   {prompt="Name of error file"}
int    Status      = 1
string *biaslist
string *errorlist
string *statlist
string *parameterlist

begin
  string imred_logfile
  string ccdred_logfile
  string statsfile
  string goodbiasesfile    = "goodBiases.list"
#  string goodbiaseserrfile = "goodBiases_e.list"
  string timefile = "time.txt"
  file   biasfile,errfile
  string bias,image,errimage,biases,parameter,parametervalue,in,ccd_sigmaimage
  string tempday,temptime,tempdate,combinedzero_e,ccd_combinedzero,ccd_in
#  string temp_goodbiasesfile
  real   biasmean,biasstddev,errormean,errorstddev
  int    Length = 0
  int    ngood = 0
  int    i,iccd,i_while,pointpos,ImTypeLength
#  bool   found_calc_error_propagation = NO
  bool   found_numccds                = NO
  bool   found_normalbiasmean         = NO
  bool   found_normalbiasstddev       = NO
  bool   found_maxmeanbiaserror       = NO
  bool   found_maxstddevbiaserror     = NO
  bool   found_rdnoise                = NO
  bool   found_gain                   = NO
  bool   found_snoise                 = NO
  bool   found_zero_combine           = NO
  bool   found_zero_reject            = NO
  bool   found_zero_offsets           = NO
  bool   found_zero_scale             = NO
  bool   found_zero_zero              = NO
  bool   found_zero_weight            = NO
  bool   found_ccdsec                 = NO
  bool   found_zero_statsec           = NO
  bool   found_zero_lthreshold        = NO
  bool   found_zero_hthreshold        = NO
  bool   found_zero_nlow              = NO
  bool   found_zero_nhigh             = NO
  bool   found_zero_nkeep             = NO
  bool   found_zero_mclip             = NO
  bool   found_zero_lsigma            = NO
  bool   found_zero_hsigma            = NO
  bool   found_zero_sigscale          = NO
  bool   found_zero_pclip             = NO
  bool   found_zero_grow              = NO
  bool   FoundImType                  = NO

  Status = 1

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)
  if (access(warningfile))
    delete(warningfile, ver-)
  if (access(errorfile))
    delete(errorfile, ver-)

  imred_logfile = imred.logfile
  print ("stzero: imred_logfile = "//imred_logfile)
  imred.logfile = logfile

  ccdred_logfile = ccdred.logfile
  print ("stzero: ccdred_logfile = "//ccdred_logfile)
  ccdred.logfile = logfile

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                      stzero.cl                         *")
  print ("*    (combines all zero images to combinedZero.fits)     *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*                      stzero.cl                         *", >> logfile)
  print ("*    (combines all zero images to combinedZero.fits)     *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- delete output
  if (access(combinedzero)){
    imdel(combinedzero, ver-)
    if (access(combinedzero))
      del(combinedzero,ver-)
    if (!access(combinedzero)){
      print("stzero: old combinedZero.fits deleted")
      if (loglevel > 2)
        print("stzero: old combinedZero.fits deleted", >> logfile)
    }
    else{
      print("stzero: ERROR: cannot delete old combinedZero.fits")
      print("stzero: ERROR: cannot delete old combinedZero.fits", >> logfile)
      print("stzero: ERROR: cannot delete old combinedZero.fits", >> warningfile)
      print("stzero: ERROR: cannot delete old combinedZero.fits", >> errorfile)
    }
  }

# --- error propagation
  if (doerrors){
#  -- delete old sigmaimage
    if (access(sigmaimage)){
      imdel(sigmaimage, ver-)
      if (access(sigmaimage))
        del(sigmaimage,ver-)
      if (!access(sigmaimage)){
        print("stzero: old "//sigmaimage//" deleted")
        if (loglevel > 2)
          print("stzero: old "//sigmaimage//" deleted", >> logfile)
      }
      else{
        print("stzero: ERROR: cannot delete old "//sigmaimage)
        print("stzero: ERROR: cannot delete old "//sigmaimage, >> logfile)
        print("stzero: ERROR: cannot delete old "//sigmaimage, >> warningfile)
        print("stzero: ERROR: cannot delete old "//sigmaimage, >> errorfile)
      }
    }
  }#end if (doerrors)
  else{
    sigmaimage = ""
  }


# --- Erzeugen von temporaeren Filenamen
  print("stzero: building temp-filenames")
  if (loglevel > 2)
    print("stzero: building temp-filenames", >> logfile)
  biasfile    = mktemp ("tmp")
  errfile     = mktemp ("tmp")
  statsfile   = "tmp_statsfile.text"

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stzero: building lists from temp-files")
  if (loglevel > 2)
    print("stzero: building lists from temp-files", >> logfile)

  if ( (substr(biasimages,1,1) == "@" && access(substr(biasimages,2,strlen(biasimages)))) || (substr(biasimages,1,1) != "@" && access(biasimages))){
    sections(biasimages, option="root", > biasfile)
  }
  else{
    if (substr(biasimages,1,1) != "@"){
      print("stzero: ERROR: "//biasimages//" not found!!!")
      print("stzero: ERROR: "//biasimages//" not found!!!", >> logfile)
      print("stzero: ERROR: "//biasimages//" not found!!!", >> errorfile)
      print("stzero: ERROR: "//biasimages//" not found!!!", >> warningfile)
    }
    else{
      print("stzero: ERROR: "//substr(biasimages,2,strlen(biasimages))//" not found!!!")
      print("stzero: ERROR: "//substr(biasimages,2,strlen(biasimages))//" not found!!!", >> logfile)
      print("stzero: ERROR: "//substr(biasimages,2,strlen(biasimages))//" not found!!!", >> errorfile)
      print("stzero: ERROR: "//substr(biasimages,2,strlen(biasimages))//" not found!!!", >> warningfile)
    }

# --- clean up
    imred.logfile = imred_logfile
    ccdred.logfile = ccdred_logfile

    delete (biasfile, ver-, >& "dev$null")
    delete (errfile, ver-, >& "dev$null")
    biaslist      = ""
    errorlist     = ""
    statlist      = ""
    parameterlist = ""
    Status = 0
    return
  }

# --- read number of CCDs
  if (access(parameterfile)){
    print ("stzero: **************** reading parameterfile *******************")
    if (loglevel > 2)
      print ("stzero: **************** reading parameterfile *******************", >> logfile)

    parameterlist = parameterfile

    while (fscan (parameterlist, parameter, parametervalue) != EOF){
#      print("stzero: parameter = "//parameter//", parametervalue = "//parametervalue)

      if (parameter == "number_of_ccds"){
        NumCCDs = int(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_numccds = YES
      }
      else if (parameter == "imtype"){
        ImType = parametervalue
        print ("stzero: Setting "//parameter//" to "//ImType)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//ImType, >> logfile)
        FoundImType = YES
      }
      else if (parameter == "zero_combine"){
        combine = parametervalue
        print ("stzero: Setting "//parameter//" to "//combine)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//combine, >> logfile)
        found_zero_combine = YES
      }
      else if (parameter == "zero_reject"){
        reject = parametervalue
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_reject = YES
      }
      else if (parameter == "zero_offsets"){
        offsets = parametervalue
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_offsets = YES
      }
      else if (parameter == "zero_scale"){
        scale = parametervalue
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_scale = YES
      }
      else if (parameter == "zero_zero"){
        zero = parametervalue
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_zero = YES
      }
      else if (parameter == "zero_weight"){
        weight = parametervalue
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_weight = YES
      }
      else if (parameter == "zero_lthreshold"){
        if (parametervalue == "INDEF")
          lthreshold = INDEF
        else
          lthreshold = real(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_lthreshold = YES
      }
      else if (parameter == "zero_hthreshold"){
        if (parametervalue == "INDEF")
          hthreshold = INDEF
        else
          hthreshold = real(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_hthreshold = YES
      }
      else if (parameter == "zero_nlow"){
        nlow = int(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_nlow = YES
      }
      else if (parameter == "zero_nhigh"){
        nhigh = int(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_nhigh = YES
      }
      else if (parameter == "zero_nkeep"){
        nkeep = int(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_nkeep = YES
      }
      else if (parameter == "zero_mclip"){
        if (parametervalue == "YES" || parametervalue == "yes" || parametervalue == "Yes"){
          mclip = YES
          print ("stzero: Setting "//parameter//" to "//parametervalue)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
        else{
          mclip = NO
          print ("stzero: Setting "//parameter//" to "//parametervalue)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
        found_zero_mclip = YES
      }
      else if (parameter == "zero_lsigma"){
        lsigma = real(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_lsigma = YES
      }
      else if (parameter == "zero_hsigma"){
        hsigma = real(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_hsigma = YES
      }
      else if (parameter == "zero_sigscale"){
        sigscale = real(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_sigscale = YES
      }
      else if (parameter == "zero_pclip"){
        pclip = real(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_pclip = YES
      }
      else if (parameter == "zero_grow"){
        grow = int(parametervalue)
        print ("stzero: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stzero: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_zero_grow = YES
      }
    }
    if (!found_numccds){
      NumCCDs = 1
      print("stzero: WARNING: parameter numccds not found in parameterfile!!! -> using standard value 1")
      print("stzero: WARNING: parameter numccds not found in parameterfile!!! -> using standard value 1", >> logfile)
      print("stzero: WARNING: parameter numccds not found in parameterfile!!! -> using standard value 1", >> warningfile)
    }
    if (!FoundImType){
      print("stzero: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard")
      print("stzero: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> logfile)
      print("stzero: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_combine){
      print("stzero: WARNING: parameter zero_combine not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_combine not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_combine not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_reject){
      print("stzero: WARNING: parameter zero_reject not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_reject not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_reject not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_offsets){
      print("stzero: WARNING: parameter zero_offsets not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_offsets not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_offsets not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_scale){
      print("stzero: WARNING: parameter zero_scale not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_scale not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_scale not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_zero){
      print("stzero: WARNING: parameter zero_zero not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_zero not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_zero not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_weight){
      print("stzero: WARNING: parameter zero_weight not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_weight not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_weight not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_lthreshold){
      print("stzero: WARNING: parameter zero_lthreshold not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_lthreshold not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_lthreshold not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_hthreshold){
      print("stzero: WARNING: parameter zero_hthreshold not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_hthreshold not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_hthreshold not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_nlow){
      print("stzero: WARNING: parameter zero_nlow not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_nlow not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_nlow not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_nhigh){
      print("stzero: WARNING: parameter zero_nhigh not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_nhigh not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_nhigh not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_nkeep){
      print("stzero: WARNING: parameter zero_nkeep not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_nkeep not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_nkeep not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_mclip){
      print("stzero: WARNING: parameter zero_mclip not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_mclip not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_mclip not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_lsigma){
      print("stzero: WARNING: parameter zero_lsigma not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_lsigma not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_lsigma not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_hsigma){
      print("stzero: WARNING: parameter zero_hsigma not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_hsigma not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_hsigma not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_sigscale){
      print("stzero: WARNING: parameter zero_sigscale not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_sigscale not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_sigscale not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_pclip){
      print("stzero: WARNING: parameter zero_pclip not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_pclip not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_pclip not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_zero_grow){
      print("stzero: WARNING: parameter zero_grow not found in parameterfile!!! -> using standard")
      print("stzero: WARNING: parameter zero_grow not found in parameterfile!!! -> using standard", >> logfile)
      print("stzero: WARNING: parameter zero_grow not found in parameterfile!!! -> using standard", >> warningfile)
    }
  }# --- end if access(parameterfile)
  else{
    print("stzero: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters")
    print("stzero: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters", >> logfile)
    print("stzero: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters", >> warningfile)
  }

  if (NumCCDs == 1){
    ccd_combinedzero = combinedzero
    ccd_sigmaimage = sigmaimage
  }

  for (iccd = 1; iccd <= NumCCDs; iccd += 1){
    print("stzero: iccd = "//iccd)
    print("stzero: iccd = "//iccd, >> logfile)
    if (NumCCDs > 1){
      strpos(tempstring = combinedzero,
             substring  = "."//ImType)
      pointpos = strpos.pos
      if (pointpos > 1)
        ccd_combinedzero = substr(combinedzero, 1, pointpos-1)
      else
        ccd_combinedzero = combinedzero
      ccd_combinedzero = ccd_combinedzero//"_ccd"//iccd//"."//ImType

      if (access(ccd_combinedzero)){
        imdel(ccd_combinedzero, ver-)
        if (access(ccd_combinedzero))
          del(ccd_combinedzero,ver-)
        if (!access(ccd_combinedzero)){
          print("stzero: old "//ccd_combinedzero//" deleted")
          if (loglevel > 2)
            print("stzero: old "//ccd_combinedzero//" deleted", >> logfile)
        }
        else{
          print("stzero: ERROR: cannot delete old "//ccd_combinedzero)
          print("stzero: ERROR: cannot delete old "//ccd_combinedzero, >> logfile)
          print("stzero: ERROR: cannot delete old "//ccd_combinedzero, >> warningfile)
          print("stzero: ERROR: cannot delete old "//ccd_combinedzero, >> errorfile)
        }
      }
      if (doerrors){
        strpos(tempstring = sigmaimage,
              substring  = "."//ImType)
        pointpos = strpos.pos
        if (pointpos > 1)
          ccd_sigmaimage = substr(sigmaimage, 1, pointpos-1)
        else
          ccd_sigmaimage = sigmaimage
        ccd_sigmaimage = ccd_sigmaimage//"_ccd"//iccd//"."//ImType

        if (access(ccd_sigmaimage)){
          imdel(ccd_sigmaimage, ver-)
          if (access(ccd_sigmaimage))
            del(ccd_sigmaimage,ver-)
          if (!access(ccd_sigmaimage)){
            print("stzero: old "//ccd_sigmaimage//" deleted")
            if (loglevel > 2)
              print("stzero: old "//ccd_sigmaimage//" deleted", >> logfile)
          }
          else{
            print("stzero: ERROR: cannot delete old "//ccd_sigmaimage)
            print("stzero: ERROR: cannot delete old "//ccd_sigmaimage, >> logfile)
            print("stzero: ERROR: cannot delete old "//ccd_sigmaimage, >> warningfile)
            print("stzero: ERROR: cannot delete old "//ccd_sigmaimage, >> errorfile)
          }
        }
      }
    }

  # --- read parameterfile
    found_normalbiasmean         = NO
    found_normalbiasstddev       = NO
    found_maxmeanbiaserror       = NO
    found_maxstddevbiaserror     = NO
    found_rdnoise                = NO
    found_gain                   = NO
    found_snoise                 = NO
    found_ccdsec                 = NO
    found_zero_statsec           = NO
    if (access(parameterfile)){
      print ("stzero: **************** reading parameterfile *******************")
      if (loglevel > 2)
        print ("stzero: **************** reading parameterfile *******************", >> logfile)

      parameterlist = parameterfile

      while (fscan (parameterlist, parameter, parametervalue) != EOF){

  #      if (parameter != "#")
  #        print ("stzero: parameter="//parameter//" value="//parametervalue, >> logfile)

  #      if (parameter == "calc_error_propagation"){
  #        if (parametervalue == "YES" || parametervalue == "yes" || parametervalue == "Yes"){
  #          doerrors = YES
  #          print ("stzero: Setting doerrors to "//parametervalue)
  #          if (loglevel > 2)
  #            print ("stzero: Setting doerrors to "//parametervalue, >> logfile)
  #        }
  #        else{
  #          doerrors = NO
  #          print ("stzero: Setting doerrors to "//parametervalue)
  #          if (loglevel > 2)
  #            print ("stzero: Setting doerrors to "//parametervalue, >> logfile)
  #        }
  #        found_calc_error_propagation = YES
  #      }
        if (parameter == "normalbiasmean_ccd"//iccd){
          normalbiasmean = real(parametervalue)
          print ("stzero: Setting "//parameter//" to "//normalbiasmean)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//normalbiasmean, >> logfile)
          found_normalbiasmean = YES
        }
        else if (parameter == "normalbiasstddev_ccd"//iccd){
          normalbiasstddev = real(parametervalue)
          print ("stzero: Setting "//parameter//" to "//normalbiasstddev)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//normalbiasstddev, >> logfile)
          found_normalbiasstddev = YES
        }
        else if (parameter == "maxmeanbiaserror_ccd"//iccd){
          maxmeanbiaserror = real(parametervalue)
          print ("stzero: Setting "//parameter//" to "//maxmeanbiaserror)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//maxmeanbiaserror, >> logfile)
          found_maxmeanbiaserror = YES
        }
        else if (parameter == "maxstddevbiaserror_ccd"//iccd){
          maxstddevbiaserror = real(parametervalue)
          print ("stzero: Setting "//parameter//" to "//maxstddevbiaserror)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//maxstddevbiaserror, >> logfile)
          found_maxstddevbiaserror = YES
        }
        else if (parameter == "ccdsec_ccd"//iccd){
          if (substr(parametervalue,1,1) == "(" || substr(parametervalue,1,1) == "-"){
            ccdsec = ""
          }
          else{
            ccdsec = parametervalue
          }
          print ("stzero: Setting "//parameter//" to "//ccdsec)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//ccdsec, >> logfile)
          found_ccdsec = YES
        }
        else if (parameter == "rdnoise_ccd"//iccd){
          rdnoise = real(parametervalue)
          print ("stzero: Setting "//parameter//" to "//rdnoise)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//rdnoise, >> logfile)
          found_rdnoise = YES
        }
        else if (parameter == "gain_ccd"//iccd){
          gain = real(parametervalue)
          print ("stzero: Setting "//parameter//" to "//gain)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//gain, >> logfile)
          found_gain = YES
        }
        else if (parameter == "snoise_ccd"//iccd){
          snoise = real(parametervalue)
          print ("stzero: Setting "//parameter//" to "//snoise)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//snoise, >> logfile)
          found_snoise = YES
        }
        else if (parameter == "zero_statsec_ccd"//iccd){
          if (substr(parametervalue,1,1) == "(" || substr(parametervalue,1,1) == "-"){
            statsec = ""
          }
          else{
            statsec = parametervalue
          }
          print ("stzero: Setting "//parameter//" to "//statsec)
          if (loglevel > 2)
            print ("stzero: Setting "//parameter//" to "//statsec, >> logfile)
          found_zero_statsec = YES
        }
      }#end while
  #    if (!found_calc_error_propagation){
  #      print("stzero: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard")
  #      print("stzero: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard", >> logfile)
  #      print("stzero: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard", >> warningfile)
  #    }
      if (!found_normalbiasmean){
        print("stzero: WARNING: parameter normalbiasmean_ccd"//iccd//" not found in parameterfile!!! -> using standard")
        print("stzero: WARNING: parameter normalbiasmean_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> logfile)
        print("stzero: WARNING: parameter normalbiasmean_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> warningfile)
      }
      if (!found_normalbiasstddev){
        print("stzero: WARNING: parameter normalbiasstddev_ccd"//iccd//" not found in parameterfile!!! -> using standard")
        print("stzero: WARNING: parameter normalbiasstddev_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> logfile)
        print("stzero: WARNING: parameter normalbiasstddev_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> warningfile)
      }
      if (!found_maxmeanbiaserror){
        print("stzero: WARNING: parameter maxmeanbiaserror_ccd"//iccd//" not found in parameterfile!!! -> using standard")
        print("stzero: WARNING: parameter maxmeanbiaserror_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> logfile)
        print("stzero: WARNING: parameter maxmeanbiaserror_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> warningfile)
      }
      if (!found_maxstddevbiaserror){
        print("stzero: WARNING: parameter maxstddevbiaserror_ccd"//iccd//" not found in parameterfile!!! -> using standard")
        print("stzero: WARNING: parameter maxstddevbiaserror_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> logfile)
        print("stzero: WARNING: parameter maxstddevbiaserror_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> warningfile)
      }
      if (!found_ccdsec){
        print("stzero: WARNING: parameter ccdsec_ccd"//iccd//" not found in parameterfile!!! -> using standard")
        print("stzero: WARNING: parameter ccdsec_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> logfile)
        print("stzero: WARNING: parameter ccdsec_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> warningfile)
      }
      if (!found_rdnoise){
        print("stzero: WARNING: parameter rdnoise_ccd"//iccd//" not found in parameterfile!!! -> using standard")
        print("stzero: WARNING: parameter rdnoise_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> logfile)
        print("stzero: WARNING: parameter rdnoise_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> warningfile)
      }
      if (!found_gain){
        print("stzero: WARNING: parameter gain_ccd"//iccd//" not found in parameterfile!!! -> using standard")
        print("stzero: WARNING: parameter gain_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> logfile)
        print("stzero: WARNING: parameter gain_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> warningfile)
      }
      if (!found_snoise){
        print("stzero: WARNING: parameter snoise_ccd"//iccd//" not found in parameterfile!!! -> using standard")
        print("stzero: WARNING: parameter snoise_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> logfile)
        print("stzero: WARNING: parameter snoise_ccd"//iccd//" not found in parameterfile!!! -> using standard", >> warningfile)
      }
      if (!found_zero_statsec){
        print("stzero: WARNING: parameter zero_statsec not found in parameterfile!!! -> using standard")
        print("stzero: WARNING: parameter zero_statsec not found in parameterfile!!! -> using standard", >> logfile)
        print("stzero: WARNING: parameter zero_statsec not found in parameterfile!!! -> using standard", >> warningfile)
      }
    }# --- end if access(parameterfile)
    else{
      print("stzero: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters")
      print("stzero: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters", >> logfile)
      print("stzero: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters", >> warningfile)
    }

  # --- view image statistics
    print("stzero: ***************** image statistics ******************")
    if (loglevel > 2)
      print("stzero: ***************** image statistics ******************", >> logfile)
    # delete old statsfile
    print("stzero: search for old statsfile")
    if (loglevel > 2)
      print("stzero: search for old statsfile", >> logfile)
    if (access(statsfile)){
    delete (statsfile, ver-, >& "dev$null")
    print("stzero: old statsfile deleted!")
    if (loglevel > 2)
      print("stzero: old statsfile deleted!", >> logfile)
    }
    # imstat
    print("stzero: starting imstat")
    if (loglevel > 2)
      print("stzero: starting imstat", >> logfile)

    biaslist = biasfile
    i_while = 0
    while (fscan (biaslist, in) != EOF){
      i_while += 1
      if ((iccd == 1) && (i_while == 1) && (NumCCDs > 1)){
        imcopy(input  = in,
               output = combinedzero,
               verbose-)
        print("stzero: "//combinedzero//" created")
        print("stzero: "//combinedzero//" created", >> logfile)
        if (doerrors){
          imcopy(input  = in,
                 output = sigmaimage,
                 verbose-)
        }
      }

      if (access(in)){
        print("stzero: biasfile = "//in)
        if (loglevel > 2)
          print("stzero: biasfile = "//in, >> logfile)
        if (NumCCDs > 1){
          strpos(tempstring = in,
                substring  = "."//ImType)
          pointpos = strpos.pos
          if (pointpos > 1)
            ccd_in = substr(in, 1, pointpos-1)//"_ccd"//iccd//substr(in, pointpos, strlen(in))
          else
            ccd_in = in//"_ccd"//iccd//"."//ImType

          if (access(ccd_in)){
            imdel(ccd_in, ver-)
            if (access(ccd_in))
              del(ccd_in,ver-)
            if (!access(ccd_in)){
              print("stzero: old "//ccd_in//" deleted")
              if (loglevel > 2)
                print("stzero: old "//ccd_in//" deleted", >> logfile)
            }
            else{
              print("stzero: ERROR: cannot delete old "//ccd_in)
              print("stzero: ERROR: cannot delete old "//ccd_in, >> logfile)
              print("stzero: ERROR: cannot delete old "//ccd_in, >> warningfile)
              print("stzero: ERROR: cannot delete old "//ccd_in, >> errorfile)
            }
          }

          imcopy(input = in//ccdsec,
                 output = ccd_in,
                 verbose-)
        } else{
          ccd_in = in
        }
        imstat(images=ccd_in//statsec,
              fields="image,mean,stddev",
              lower=lthreshold,
              upper=hthreshold,
              lsigma=lsigma,
              usigma=hsigma,
              nclip=1,
              binwidt=sigscale,
              format-,
              cache-, >> statsfile)
        print("stzero: in after imstat = <"//ccd_in//">")
        print("stzero: in after imstat = <"//ccd_in//">", >> logfile)
        if (!access(statsfile)){
          print("stzero: ERROR: statsfile <"//statsfile//"> not found!!!")
          print("stzero: ERROR: statsfile <"//statsfile//"> not found!!!", >> logfile)
          print("stzero: ERROR: statsfile <"//statsfile//"> not found!!!", >> errorfile)
          print("stzero: ERROR: statsfile <"//statsfile//"> not found!!!", >> warningfile)

  # --- clean up
          imred.logfile = imred_logfile
          ccdred.logfile = ccdred_logfile

          delete (statsfile, ver-, >& "dev$null")
          delete (biasfile, ver-, >& "dev$null")
          delete (errfile, ver-, >& "dev$null")
          biaslist      = ""
          errorlist     = ""
          statlist      = ""
          parameterlist = ""
          Status = 0
          return
        }
      }
      else{
        print("stzero: WARNING: file "//in//" not found!")
        print("stzero: WARNING: file "//in//" not found!", >> logfile)
        print("stzero: WARNING: file "//in//" not found!", >> warningfile)
      }
    }
    # Ausgabe
    statlist = statsfile
    while (fscan (statlist, image, biasmean, biasstddev) != EOF){
      print("stzero: "//image//": biasmean = "//biasmean//", biasstddev = "//biasstddev)
      if (loglevel > 2)
        print("stzero: "//image//": biasmean = "//biasmean//", biasstddev = "//biasstddev, >> logfile)
    }

  # --- throw away bad biases
    print("stzero: ***************** Error calculation ********************")
    if (loglevel > 2)
      print("stzero: ***************** Error calculation ********************", >> logfile)
    biases = ""
    statlist = statsfile

    if (access(goodbiasesfile)){
      delete(goodbiasesfile, ver-)
      print("stzero: old goodbiasesfile deleted")
      if (loglevel > 2)
        print("stzero: old goodbiasesfile deleted", >> logfile)
    }
  #  if (doerrors){
  #    if (access(goodbiaseserrfile)){
  #      delete(goodbiaseserrfile, ver-)
  #      print("stzero: old goodbiaseserrfile deleted")
  #      if (loglevel > 2)
  #        print("stzero: old goodbiaseserrfile deleted", >> logfile)
  #    }
  #  }

    ngood = 0
    while (fscan (statlist, image, biasmean, biasstddev) != EOF){
      pointpos = 0
      strpos(tempstring = image,
             substr = "[")
      pointpos = strpos.pos

      if (pointpos > 0){
        image = substr(image,1,pointpos-1)
      }
  #    if (doerrors){
  #      if (fscan(errorlist, errimage) == EOF){
  #        print("stzero: ERROR: fscan("//errorimages//", errimage) returned EOF => returning!!!")
  #        print("stzero: ERROR: fscan("//errorimages//", errimage) returned EOF => returning!!!", >> logfile)
  #        print("stzero: ERROR: fscan("//errorimages//", errimage) returned EOF => returning!!!", >> warningfile)
  #        print("stzero: ERROR: fscan("//errorimages//", errimage) returned EOF => returning!!!", >> errorfile)
  ## --- clean up
  #        imred.logfile = imred_logfile
  #        ccdred.logfile = ccdred_logfile
  #
  #        delete (statsfile, ver-, >& "dev$null")
  #        delete (biasfile, ver-, >& "dev$null")
  #        delete (errfile, ver-, >& "dev$null")
  #        biaslist      = ""
  #        errorlist     = ""
  #        statlist      = ""
  #        parameterlist = ""
  #        return
  #
  #      }
  #    }
      errormean = abs(biasmean - normalbiasmean)
      if (errormean < maxmeanbiaserror){
        ngood += 1
        if (biases == "")
          biases = image
        else
          biases = biases//","//image
        print(image, >> goodbiasesfile)
  #      if (doerrors)
  #        print(errimage, >> goodbiaseserrfile)
        print("stzero: Mean of "//image//" (="//errormean//") within limits")
        if (loglevel > 1)
          print("stzero: Mean of"//image//" (="//errormean//") within limits", >> logfile)
  #      if (doerrors){
  #        if (ngood == 1){
  #          print("stzero: ngood == 1 => copying "//image//" to combinedzero_e")
  #          imcopy(input=image,
  #                 output=combinedzero_e,
  #                 ver-)
  #        }
  #        else{
  #          imarith(operand1=combinedzero_e,
  #                  op="+",
  #                  operand2=image,
  #                  result=combinedzero_e,
  #                  title="",
  #                  divzero=0.,
  #                  hparams="",
  #                  pixtype="real",
  #                  calctyp="real",
  #                  ver-,
  #                  noact-)
  #        }
  #      }
      }#end if (errormean < maxmeanbiaserror)
      else{
        print("stzero: WARNING: "//image//": wrong mean (="//biasmean//") => throwing away")
        print("stzero: WARNING: "//image//": wrong mean (="//biasmean//") => throwing away", >> logfile)
        print("stzero: WARNING: "//image//": wrong mean (="//biasmean//") => throwing away", >> warningfile)
      }

      errorstddev = abs(biasstddev - normalbiasstddev)
      if (errorstddev < maxstddevbiaserror){
        print("stzero: Stddev of "//image//" (="//errorstddev//") within limits")
        if (loglevel > 1)
          print("stzero: Stddev of "//image//" (="//errorstddev//") within limits", >> logfile)
      }
      else{
        print("stzero: WARNING: "//image//": wrong stddev")
        print("stzero: WARNING: "//image//": wrong stddev", >> logfile)
        print("stzero: WARNING: "//image//": wrong stddev", >> warningfile)
      }

    }  #end of while (fscan(statlist != EOF))

  ## --- divide combinedzero_e by ngood
  #  if (doerrors){
  #    imarith(operand1=combinedzero_e,
  #            op="/",
  #            operand2=ngood,
  #            result=combinedzero_e,
  #            title="",
  #            divzero=0.,
  #            hparams="",
  #            pixtype="real",
  #            calctyp="real",
  #            ver-,
  #            noact-)
  #  }

  # --- combine Biases
    print("stzero: ******************** zerocombine ********************")
    if (loglevel > 2)
      print("stzero: ******************** zerocombine ********************", >> logfile)

    if (biases != ""){
      # delete output
      if (access(ccd_combinedzero)){
        imdel(ccd_combinedzero, ver-)
        if (access(ccd_combinedzero))
          del(ccd_combinedzero,ver-)
        if (!access(ccd_combinedzero)){
          print("stzero: old "//ccd_combinedzero//" deleted")
          if (loglevel > 2)
            print("stzero: old "//ccd_combinedzero//" deleted", >> logfile)
        }
        else{
          print("stzero: ERROR: cannot delete old "//ccd_combinedzero)
          print("stzero: ERROR: cannot delete old "//ccd_combinedzero, >> logfile)
          print("stzero: ERROR: cannot delete old "//ccd_combinedzero, >> warningfile)
          print("stzero: ERROR: cannot delete old "//ccd_combinedzero, >> errorfile)

      # --- clean up
          imred.logfile = imred_logfile
          ccdred.logfile = ccdred_logfile

          delete (biasfile, ver-, >& "dev$null")
          delete (errfile, ver-, >& "dev$null")
          biaslist      = ""
          errorlist     = ""
          statlist      = ""
          parameterlist = ""
          Status = 0
          return
        }
      }

      # Combine the bias images.
      combine (input="@"//goodbiasesfile,
                output=ccd_combinedzero,
                plfile="",
                sigma=ccd_sigmaimage,
                ccdtype="",
                subsets-,
                delete-,
                combine=combine,
                reject=reject,
                project-,
                outtype="real",
                offsets=offsets,
                masktype="none",
                maskval=0.,
                blank=0.,
                scale=scale,
                zero=zero,
                weight=weight,
                statsec=statsec,
                lthreshold=lthreshold,
                hthreshold=hthreshold,
                nlow=nlow,
                nhigh=nhigh,
                nkeep=nkeep,
                mclip=mclip,
                lsigma=lsigma,
                hsigma=hsigma,
                rdnoise=rdnoise,
                gain=gain,
                snoise=snoise,
                sigscale=sigscale,
                pclip=pclip,
                grow=grow)
      if (NumCCDs > 1){
        imcopy(input  = ccd_combinedzero,
               output = combinedzero//ccdsec,
               verbose-)
        imdel(images = ccd_combinedzero,
              go_ahead+,
              verify-,
              default_action+)

        if (doerrors){
          imcopy(input  = ccd_sigmaimage,
                output = sigmaimage//ccdsec,
                verbose-)
          imdel(images = ccd_sigmaimage,
                go_ahead+,
                verify-,
                default_action+)
        }
      }

  #    zerocombine(input=biases,output=combinedzero,rdnoise=rdnoise,gain=gain,snoise=0.,combine="average",reject="minmax",process=NO,scale="none",nlow=0,nhigh=1,nkeep=1,mclip=YES,lsigma=3.,hsigma=3.,pclip=-0.5,blank=0.)
    }
    else{
      print("stzero: ERROR: CCD"//iccd//":  NO GOOD BIASES FOUND!!!")
      print("stzero: ERROR: CCD"//iccd//":  NO GOOD BIASES FOUND!!!", >> logfile)
      print("stzero: ERROR: CCD"//iccd//":  NO GOOD BIASES FOUND!!!", >> errorfile)
      print("stzero: ERROR: CCD"//iccd//":  NO GOOD BIASES FOUND!!!", >> warningfile)

  # --- clean up
      imred.logfile = imred_logfile
      ccdred.logfile = ccdred_logfile

      delete (biasfile, ver-, >& "dev$null")
      delete (errfile, ver-, >& "dev$null")
      biaslist      = ""
      errorlist     = ""
      statlist      = ""
      parameterlist = ""
      Status = 0
      return
    }
    if (NumCCDs > 1)
      del(ccd_in, ver-)
  }# end for each CCD
  if (access(combinedzero)){
    if (delinput)
      imdel(biasimages, ver-)
    if (delinput && access(image))
      del(biasimages, ver-)

    if (access(timefile))
      del(timefile, ver-)
    time(>> timefile)
    if (access(timefile)){
      statlist = timefile
      if (fscan(statlist,tempday,temptime,tempdate) != EOF){
#          print("stzero: tempday = "//tempday//", temptime = "//temptime//", tempdate = "//tempdate)
        hedit(images=combinedzero,
              fields="STALL",
              value="stzero finished "//tempdate//"T"//temptime,
              add+,
              addonly-,
              del-,
              ver-,
              show+,
              update+)
      }
    }
    else{
      print("stzero: WARNING: timefile <"//timefile//"> not accessable!")
      print("stzero: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
      print("stzero: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
    }

    print("stzero: combinedZero.fits ready")
    if (loglevel > 1)
      print("stzero: combinedZero.fits ready", >> logfile)
  }
  else{
    print("stzero: ERROR: combinedZero.fits not accessable")
    print("stzero: ERROR: combinedZero.fits not accessable", >> logfile)
    print("stzero: ERROR: combinedZero.fits not accessable", >> warningfile)
    print("stzero: ERROR: combinedZero.fits not accessable", >> errorfile)

# --- clean up
    imred.logfile = imred_logfile
    ccdred.logfile = ccdred_logfile

    delete (biasfile, ver-, >& "dev$null")
    delete (errfile, ver-, >& "dev$null")
    biaslist      = ""
    errorlist     = ""
    statlist      = ""
    parameterlist = ""
    Status = 0
    return
  }
  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    statlist = timefile
    if (fscan(statlist,tempday,temptime,tempdate) != EOF){
      print("stzero: stzero finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("stzero: WARNING: timefile <"//timefile//"> not accessable!")
    print("stzero: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("stzero: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- clean up
  imred.logfile = imred_logfile
  ccdred.logfile = ccdred_logfile

  delete (statsfile, ver-, >& "dev$null")
  delete (biasfile, ver-, >& "dev$null")
  delete (errfile, ver-, >& "dev$null")
  biaslist      = ""
  errorlist     = ""
  statlist      = ""
  parameterlist = ""

end
