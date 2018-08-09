procedure stmerge (image)

###################################################################################################################
#                                                                                                                 #
#       This program merges the spectra apertures without                                                         #
#                     normalizing them before                                                                     #
#                                                                                                                 #
# Andreas Ritter, 20.08.2004                                                                                      #
#                                                                                                                 #
# input: image "file.fits":                                                                                       #
#                                                                                                                 #
# lastorder:                                                                                                      #
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++                                                   #
# I                             I          oldoverlap         I                                                   #
# oldlambdastart                lambdastartpos                lambdaend                                           #
#                               I npixmean I       I npixmean I                                                   #
#                               I  meanba  I       I  meanbb  I                                                   #
# this order:                   I          I       I          I                                                   #
#                                     I                 I                                                         #
#                                     lambdaa           lambdas                                                   #
#                               ++++++++++++++++++++++++++++++++++++++++++++++...++++++++++++++++++++             #
#                               I           overlap           I                   I                 I             #
#                               lambdastart                   lambdaendpos        I   2 * npixmean  lambdaenda    #
#                               I npixmean I       I npixmean I                   I     meanend     I             #
#                               I  meanaa  I       I  meanab  I                            I                      #
#                               I                    I                                     lambdae                #
#                               I    2 * npixmean    I                                                            #
#                               I      meanstart     I                                                            #
#                                                                                                                 #
# strategy: * write orders to text files                                                                          #
#           * i>0: read textfiles(i-1) first time                                                                 #
#                   + find 'lambdaend'                                                                            #
#           *      read textfiles(i) first time                                                                   #
#                   + find 'lambdastart','lambdaendpos'                                                           #
#                   + write 'overlapfile'                                                                         #
#                   + write 'meanaafile','meanabfile'                                                             #
#           *      read textfiles(i-1) second time                                                                #
#                   + find 'lambdastartpos'                                                                       #
#                   + write 'oldoverlapfile'                                                                      #
#                   + write 'meanbafile'                                                                          #
#                   + write 'meanbbfile'                                                                          #
#           *      calculate linear function to make mean??'s equal                                               #
#           *      check, if end of this order is lower than meanbb                                               #
#                   - yes -> multiply rest of this order (from lambdaendpos) by quadratic                         #
#                            function to make end equal to meanbb                                                 #
###################################################################################################################

string image         = "file.fits"             {prompt="Images to merge orders"}
string parameterfile = "scripts$parameterfiles/parameterfile_UVES_blue_437_2148x3000.prop" {prompt="Name of parameterfile"}
int    dispaxis      = 2                       {prompt="1-horizontal, 2-vertical"}
int    npixmean      = 20                      {prompt="# of pixels from border to calculate mean"}
real   rdnoise       = 3.9                     {prompt="CCD readout noise"}
real   gain          = 0.49                    {prompt="CCD gain"}
real   snoise        = 0.                      {prompt="CCD sensitivity noise"}
string trimsecapa    = "[700:2000]"            {prompt="Trim section first aperture"}
string trimsecapb    = "[500:2100]"            {prompt="Trim section second aperture"}
string trimsecapy    = "[200:2340]"            {prompt="Trim section second last aperture"}
string trimsecapz    = "[200:2000]"            {prompt="Trim section last aperture"}
string combine       = "average"               {prompt="Type of combine operation",
                                                 enum="average|median|sum"}
string reject        = "avsigclip"             {prompt="Type of rejection",
                                                 enum="none|minmax|ccdclip|crreject|sigclip|avsigclip|pclip"}
real   lthreshold    = INDEF                   {prompt="Lower threshold"}
real   hthreshold    = INDEF                   {prompt="Upper threshold"}
int    nlow          = 1                       {prompt="minmax: Number of low pixels to reject"}
int    nhigh         = 1                       {prompt="minmax: Number of high pixels to reject"}
int    nkeep         = 1                       {prompt="Minimum to keep (pos) or maximum to reject (neg)"}
bool   mclip         = YES                     {prompt="Use median in sigma clipping algorithms?"}
real   lsigma        = 3.                      {prompt="Lower sigma clipping factor"}
real   hsigma        = 3.                      {prompt="Upper sigma clipping factor"}
real   sigscale      = 0.1                     {prompt="Tolerance for sigma clipping scaling corrections"}
real   pclip         = -0.5                    {prompt="pclip: Percentile clipping parameter"}
int    grow          = 0                       {prompt="Radius (pixels) for 1D neighbor rejection"}
real   blank         = 0.                      {prompt="Value if there are no pixels"}
real   multfirstap   = 0.                      {prompt="Multiply first order by this factor times lambda (0 for no scaling)"}
real   msigma        = 2.                      {prompt="Factor to multiply sigma with to reject deviant pixels"}
string logfile       = "logfile_stmerge.log"   {prompt="Name of logfile"}
string warningfile   = "warnings_stmerge.log"  {prompt="Name of warning file"}
string errorfile     = "errors_stmerge.log"    {prompt="Name of error file"}
int    loglevel      = 3                       {prompt="Level for writing logfile [1-3]"}
string *strlist
string *textfilelist

begin
  bool   temprun           = YES
  string ccdlistfilename   = "ccdlist.out"
  string overlapfile       = "overlap.text"
  string oldoverlapfile    = "oldoverlap.text"
  string meanaafile        = "meanaa.text"
  string meanabfile        = "meanab.text"
  string meanbafile        = "meanba.text"
  string meanbbfile        = "meanbb.text"
  string meanendfile       = "meanend.text"
  string meanoutfile       = ""
  string meanstartfile     = "meanstart.text"
  string lasttextfileline  = "lasttextfileline.text"
  string firsttextfileline = "firsttextfileline.text"
  string neworders         = "neworders.list"
  string neworder          = ""
  string newordertest      = ""
  string tocombinelist     = "tocombine.list"
  string fitsfilelist      = "fits_new.list"
  string tempfile          = "tempfile.text"
  string tempfilea         = "tempfilea.text"
  string newline,trimsec,tempstr,parameter,parametervalue
  string trimbastr,trimbbstr,trimyastr,trimybstr
  string line,lambdastr,fluxstr,lasttextfile,textfilenamet
  string tempfits,tempimage
  string textfiles,textfilename,output,fitsfiles,fitsfilename
  int    nlines,nwords,nchars,dumi
  int    pointpos,i,j,run,norders,npix,npixthis,lambdastartpos,lambdaendpos
  int    nfile,meanrun,npixold,trimba,trimbb,trimya,trimyb,trima,trimb,irun
  int    ngood,npixrej,npixmeanorig
  int    maxchars = 62
  real   meanap,dtempdbl
  real   tempdbl,meanaa,meanab,meanba,meanbb,oldmeanaa,oldmeanab,oldmeanba,oldmeanbb
  real   lambda,flux,lastlambda,lambdastart,lambdaend,funcm,funcn,faca,facb,dlambda
  real   lambdaI,sumsqrs,sum,sigma,tmpreal,meanend,meanstart,meanm,fcont,fca,fcb,fza
  real   lambdaa,lambdab,lambdam,divisor,f_lambda,funcsqrn,funcsqrm,meanstartnew,fz
  real   meanendnew,lambdas,lambdae,fa,fb,fc,lambdaaa,lambdaab,lambdaba,lambdabb
  real   fluxmin,fluxminpos,cosa,cosb,lambda_z_a,f_lambda_old,lambdaenda
  real   PI = 3.141592653589793
  bool   orders_do_overlap = NO
  bool   lambdastrread = NO
  bool   founddd = NO
  bool   found_dispaxis          = NO
  bool   found_rdnoise           = NO
  bool   found_gain              = NO
  bool   found_snoise            = NO
  bool   found_merge_npixmean    = NO
  bool   found_merge_trimsecapa  = NO
  bool   found_merge_trimsecapb  = NO
  bool   found_merge_trimsecapy  = NO
  bool   found_merge_trimsecapz  = NO
  bool   found_merge_combine     = NO
  bool   found_merge_reject      = NO
  bool   found_merge_lthreshold  = NO
  bool   found_merge_hthreshold  = NO
  bool   found_merge_nlow        = NO
  bool   found_merge_nhigh       = NO
  bool   found_merge_nkeep       = NO
  bool   found_merge_mclip       = NO
  bool   found_merge_lsigma      = NO
  bool   found_merge_hsigma      = NO
  bool   found_merge_sigscale    = NO
  bool   found_merge_pclip       = NO
  bool   found_merge_grow        = NO
  bool   found_merge_blank       = NO
  bool   found_merge_multfirstap = NO
  bool   found_merge_msigma      = NO

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                      stmerge.cl                        *")
  print ("*       (merges the orders of the input fits files)      *")
  print ("*                                                        *")
  print ("**********************************************************")

  language
  onedspec

# --- delete old logfiles
  if (access(logfile))
    del(logfile, ver-)
  if (access(warningfile))
    del(warningfile, ver-)
  if (access(errorfile))
    del(errorfile, ver-)

# --- read parameterfile
  if (access(parameterfile)){
    textfilelist = parameterfile
    while(fscan(textfilelist,parameter,parametervalue) != EOF){
      if (parameter == "dispaxis"){
        dispaxis = int(parametervalue)
        found_dispaxis = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "rdnoise"){
        rdnoise = real(parametervalue)
        found_rdnoise = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "gain"){
        gain = real(parametervalue)
        found_gain = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "snoise"){
        snoise = real(parametervalue)
        found_snoise = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_npixmean"){
        npixmean = int(parametervalue)
        found_merge_npixmean = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_trimsecapa"){
        trimsecapa = parametervalue
        found_merge_trimsecapa = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_trimsecapb"){
        trimsecapb = parametervalue
        found_merge_trimsecapb = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_trimsecapy"){
        trimsecapy = parametervalue
        found_merge_trimsecapy = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_trimsecapz"){
        trimsecapz = parametervalue
        found_merge_trimsecapz = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_combine"){
        combine = parametervalue
        found_merge_combine = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_reject"){
        reject = parametervalue
        found_merge_reject = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_lthreshold"){
        if (parametervalue == "INDEF")
          lthreshold = INDEF
        else
          lthreshold = real(parametervalue)
        found_merge_lthreshold = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_hthreshold"){
        if (parametervalue == "INDEF")
          hthreshold = INDEF
        else
          hthreshold = real(parametervalue)
        found_merge_hthreshold = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_nlow"){
        if (parametervalue == "INDEF")
          nlow = INDEF
        else
          nlow = int(parametervalue)
        found_merge_nlow = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_nhigh"){
        if (parametervalue == "INDEF")
          nhigh = INDEF
        else
          nhigh = int(parametervalue)
        found_merge_nhigh = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_nkeep"){
        if (parametervalue == "INDEF")
          nkeep = INDEF
        else
          nkeep = int(parametervalue)
        found_merge_nkeep = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_mclip"){
        if (parametervalue == "YES" || parametervalue == "yes")
          mclip = YES
        else
          mclip = NO
        found_merge_mclip = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_lsigma"){
        if (parametervalue == "INDEF")
          lsigma = INDEF
        else
          lsigma = real(parametervalue)
        found_merge_lsigma = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_hsigma"){
        if (parametervalue == "INDEF")
          hsigma = INDEF
        else
          hsigma = real(parametervalue)
        found_merge_hsigma = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_sigscale"){
        if (parametervalue == "INDEF")
          sigscale = INDEF
        else
          sigscale = real(parametervalue)
        found_merge_sigscale = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_pclip"){
        if (parametervalue == "INDEF")
          pclip = INDEF
        else
          pclip = real(parametervalue)
        found_merge_pclip = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_grow"){
        if (parametervalue == "INDEF")
          grow = INDEF
        else
          grow = int(parametervalue)
        found_merge_grow = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_blank"){
        if (parametervalue == "INDEF")
          blank = INDEF
        else
          blank = real(parametervalue)
        found_merge_blank = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_multfirstap"){
        if (parametervalue == "INDEF")
          multfirstap = INDEF
        else
          multfirstap = real(parametervalue)
        found_merge_multfirstap = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "merge_msigma"){
        if (parametervalue == "INDEF")
          msigma = 1.
        else
          msigma = real(parametervalue)
        found_merge_msigma = YES
        print("stmerge: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print("stmerge: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
    }
    if (!found_dispaxis){
      print("stmerge: WARNING: parameter 'dispaxis' not found in "//parameterfile//"!!! -> using standard value (="//dispaxis//")")
      print("stmerge: WARNING: parameter 'dispaxis' not found in "//parameterfile//"!!! -> using standard value (="//dispaxis//")", >> logfile)
      print("stmerge: WARNING: parameter 'dispaxis' not found in "//parameterfile//"!!! -> using standard value (="//dispaxis//")", >> warningfile)
    }
    if (!found_rdnoise){
      print("stmerge: WARNING: parameter 'rdnoise' not found in "//parameterfile//"!!! -> using standard value (="//rdnoise//")")
      print("stmerge: WARNING: parameter 'rdnoise' not found in "//parameterfile//"!!! -> using standard value (="//rdnoise//")", >> logfile)
      print("stmerge: WARNING: parameter 'rdnoise' not found in "//parameterfile//"!!! -> using standard value (="//rdnoise//")", >> warningfile)
    }
    if (!found_gain){
      print("stmerge: WARNING: parameter 'gain' not found in "//parameterfile//"!!! -> using standard value (="//gain//")")
      print("stmerge: WARNING: parameter 'gain' not found in "//parameterfile//"!!! -> using standard value (="//gain//")", >> logfile)
      print("stmerge: WARNING: parameter 'gain' not found in "//parameterfile//"!!! -> using standard value (="//gain//")", >> warningfile)
    }
    if (!found_snoise){
      print("stmerge: WARNING: parameter 'snoise' not found in "//parameterfile//"!!! -> using standard value (="//snoise//")")
      print("stmerge: WARNING: parameter 'snoise' not found in "//parameterfile//"!!! -> using standard value (="//snoise//")", >> logfile)
      print("stmerge: WARNING: parameter 'snoise' not found in "//parameterfile//"!!! -> using standard value (="//snoise//")", >> warningfile)
    }
    if (!found_merge_npixmean){
      print("stmerge: WARNING: parameter 'merge_npixmean' not found in "//parameterfile//"!!! -> using standard value (="//npixmean//")")
      print("stmerge: WARNING: parameter 'merge_npixmean' not found in "//parameterfile//"!!! -> using standard value (="//npixmean//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_npixmean' not found in "//parameterfile//"!!! -> using standard value (="//npixmean//")", >> warningfile)
    }
    if (!found_merge_trimsecapa){
      print("stmerge: WARNING: parameter 'merge_trimsecapa' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapa//")")
      print("stmerge: WARNING: parameter 'merge_trimsecapa' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapa//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_trimsecapa' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapa//")", >> warningfile)
    }
    if (!found_merge_trimsecapb){
      print("stmerge: WARNING: parameter 'merge_trimsecapb' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapb//")")
      print("stmerge: WARNING: parameter 'merge_trimsecapb' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapb//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_trimsecapb' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapb//")", >> warningfile)
    }
    if (!found_merge_trimsecapy){
      print("stmerge: WARNING: parameter 'merge_trimsecapy' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapy//")")
      print("stmerge: WARNING: parameter 'merge_trimsecapy' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapy//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_trimsecapy' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapy//")", >> warningfile)
    }
    if (!found_merge_trimsecapz){
      print("stmerge: WARNING: parameter 'merge_trimsecapz' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapz//")")
      print("stmerge: WARNING: parameter 'merge_trimsecapz' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapz//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_trimsecapz' not found in "//parameterfile//"!!! -> using standard value (="//trimsecapz//")", >> warningfile)
    }
    if (!found_merge_combine){
      print("stmerge: WARNING: parameter 'merge_combine' not found in "//parameterfile//"!!! -> using standard value (="//combine//")")
      print("stmerge: WARNING: parameter 'merge_combine' not found in "//parameterfile//"!!! -> using standard value (="//combine//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_combine' not found in "//parameterfile//"!!! -> using standard value (="//combine//")", >> warningfile)
    }
    if (!found_merge_reject){
      print("stmerge: WARNING: parameter 'merge_reject' not found in "//parameterfile//"!!! -> using standard value (="//reject//")")
      print("stmerge: WARNING: parameter 'merge_reject' not found in "//parameterfile//"!!! -> using standard value (="//reject//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_reject' not found in "//parameterfile//"!!! -> using standard value (="//reject//")", >> warningfile)
    }
    if (!found_merge_lthreshold){
      parametervalue = ''//lthreshold
      print("stmerge: WARNING: parameter 'merge_lthreshold' not found in "//parameterfile//"!!! -> using standard value (="//parametervalue//")")
      print("stmerge: WARNING: parameter 'merge_lthreshold' not found in "//parameterfile//"!!! -> using standard value (="//parametervalue//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_lthreshold' not found in "//parameterfile//"!!! -> using standard value (="//parametervalue//")", >> warningfile)
    }
    if (!found_merge_hthreshold){
      parametervalue = ''//hthreshold
      print("stmerge: WARNING: parameter 'merge_hthreshold' not found in "//parameterfile//"!!! -> using standard value (="//parametervalue//")")
      print("stmerge: WARNING: parameter 'merge_hthreshold' not found in "//parameterfile//"!!! -> using standard value (="//parametervalue//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_hthreshold' not found in "//parameterfile//"!!! -> using standard value (="//parametervalue//")", >> warningfile)
    }
    if (!found_merge_nlow){
      print("stmerge: WARNING: parameter 'merge_nlow' not found in "//parameterfile//"!!! -> using standard value (="//nlow//")")
      print("stmerge: WARNING: parameter 'merge_nlow' not found in "//parameterfile//"!!! -> using standard value (="//nlow//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_nlow' not found in "//parameterfile//"!!! -> using standard value (="//nlow//")", >> warningfile)
    }
    if (!found_merge_nhigh){
      print("stmerge: WARNING: parameter 'merge_nhigh' not found in "//parameterfile//"!!! -> using standard value (="//nhigh//")")
      print("stmerge: WARNING: parameter 'merge_nhigh' not found in "//parameterfile//"!!! -> using standard value (="//nhigh//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_nhigh' not found in "//parameterfile//"!!! -> using standard value (="//nhigh//")", >> warningfile)
    }
    if (!found_merge_nkeep){
      print("stmerge: WARNING: parameter 'merge_nkeep' not found in "//parameterfile//"!!! -> using standard value (="//nkeep//")")
      print("stmerge: WARNING: parameter 'merge_nkeep' not found in "//parameterfile//"!!! -> using standard value (="//nkeep//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_nkeep' not found in "//parameterfile//"!!! -> using standard value (="//nkeep//")", >> warningfile)
    }
    if (!found_merge_mclip){
      if (mclip){
        print("stmerge: WARNING: parameter 'merge_mclip' not found in "//parameterfile//"!!! -> using standard value (=YES)")
        print("stmerge: WARNING: parameter 'merge_mclip' not found in "//parameterfile//"!!! -> using standard value (=YES)", >> logfile)
        print("stmerge: WARNING: parameter 'merge_mclip' not found in "//parameterfile//"!!! -> using standard value (=YES)", >> warningfile)
      } 
      else{
        print("stmerge: WARNING: parameter 'merge_mclip' not found in "//parameterfile//"!!! -> using standard value (=NO)")
        print("stmerge: WARNING: parameter 'merge_mclip' not found in "//parameterfile//"!!! -> using standard value (=NO)", >> logfile)
        print("stmerge: WARNING: parameter 'merge_mclip' not found in "//parameterfile//"!!! -> using standard value (=NO)", >> warningfile)
      } 
    }
    if (!found_merge_lsigma){
      print("stmerge: WARNING: parameter 'merge_lsigma' not found in "//parameterfile//"!!! -> using standard value (="//lsigma//")")
      print("stmerge: WARNING: parameter 'merge_lsigma' not found in "//parameterfile//"!!! -> using standard value (="//lsigma//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_lsigma' not found in "//parameterfile//"!!! -> using standard value (="//lsigma//")", >> warningfile)
    }
    if (!found_merge_hsigma){
      print("stmerge: WARNING: parameter 'merge_hsigma' not found in "//parameterfile//"!!! -> using standard value (="//hsigma//")")
      print("stmerge: WARNING: parameter 'merge_hsigma' not found in "//parameterfile//"!!! -> using standard value (="//hsigma//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_hsigma' not found in "//parameterfile//"!!! -> using standard value (="//hsigma//")", >> warningfile)
    }
    if (!found_merge_sigscale){
      print("stmerge: WARNING: parameter 'merge_sigscale' not found in "//parameterfile//"!!! -> using standard value (="//sigscale//")")
      print("stmerge: WARNING: parameter 'merge_sigscale' not found in "//parameterfile//"!!! -> using standard value (="//sigscale//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_sigscale' not found in "//parameterfile//"!!! -> using standard value (="//sigscale//")", >> warningfile)
    }
    if (!found_merge_pclip){
      print("stmerge: WARNING: parameter 'merge_pclip' not found in "//parameterfile//"!!! -> using standard value (="//pclip//")")
      print("stmerge: WARNING: parameter 'merge_pclip' not found in "//parameterfile//"!!! -> using standard value (="//pclip//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_pclip' not found in "//parameterfile//"!!! -> using standard value (="//pclip//")", >> warningfile)
    }
    if (!found_merge_grow){
      print("stmerge: WARNING: parameter 'merge_grow' not found in "//parameterfile//"!!! -> using standard value (="//grow//")")
      print("stmerge: WARNING: parameter 'merge_grow' not found in "//parameterfile//"!!! -> using standard value (="//grow//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_grow' not found in "//parameterfile//"!!! -> using standard value (="//grow//")", >> warningfile)
    }
    if (!found_merge_blank){
      print("stmerge: WARNING: parameter 'merge_blank' not found in "//parameterfile//"!!! -> using standard value (="//blank//")")
      print("stmerge: WARNING: parameter 'merge_blank' not found in "//parameterfile//"!!! -> using standard value (="//blank//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_blank' not found in "//parameterfile//"!!! -> using standard value (="//blank//")", >> warningfile)
    }
    if (!found_merge_multfirstap){
      print("stmerge: WARNING: parameter 'merge_multfirstap' not found in "//parameterfile//"!!! -> using standard value (="//multfirstap//")")
      print("stmerge: WARNING: parameter 'merge_multfirstap' not found in "//parameterfile//"!!! -> using standard value (="//multfirstap//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_multfirstap' not found in "//parameterfile//"!!! -> using standard value (="//multfirstap//")", >> warningfile)
    }
    if (!found_merge_msigma){
      print("stmerge: WARNING: parameter 'merge_msigma' not found in "//parameterfile//"!!! -> using standard value (="//msigma//")")
      print("stmerge: WARNING: parameter 'merge_msigma' not found in "//parameterfile//"!!! -> using standard value (="//msigma//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_msigma' not found in "//parameterfile//"!!! -> using standard value (="//msigma//")", >> warningfile)
    }
  }

# --- test if image is accessable
  if (!access(image)){
    print("stmerge: ERROR: cannot access image "//image);
    print("stmerge: ERROR: cannot access image "//image, >> logfile);
    print("stmerge: ERROR: cannot access image "//image, >> warningfile);
    print("stmerge: ERROR: cannot access image "//image, >> errorfile);
    strlist = ""
    textfilelist = ""
    return
  }
  npixmeanorig = npixmean

# --- copy image to "temp.fits"
  tempfits = ""
  for (i=1;i<=(strlen(image)-4);i+=1){
    if (substr(image,i,i+3) == "_bot")
      i = strlen(image)
    else
      tempfits = tempfits//substr(image,i,i)
  }
  if (strlen(tempfits) > maxchars)
    tempfits = substr(tempfits, 1, maxchars)
  tempfits = tempfits//"_m.fits"
  print("stmerge: tempfits = "//tempfits)
  print("stmerge: tempfits = "//tempfits, >> logfile)
  if (access(tempfits))
    del(tempfits, ver-) 
  imcopy(image,tempfits)

# --- count number of orders
  if (access(ccdlistfilename))
    del(ccdlistfilename, ver-)
  ccdlist(tempfits, >> ccdlistfilename)
  if ( access(ccdlistfilename) ){
    strlist = ccdlistfilename
    while (fscan (strlist, line) != EOF){
# --- count npix and norders
      pointpos = 0
      while (substr(line,pointpos,pointpos) != "[")
        pointpos = pointpos+1
      pointpos = pointpos+1
      i = pointpos
      while (substr(line,i,i) != ",")
        i = i+1
      i = i-1
      if (dispaxis == 2){
        npix = int(substr(line,pointpos,i))
        print("stmerge: npix = "//npix)
	if (loglevel > 2)
          print("stmerge: npix = "//npix, >> logfile)
      }
      else{
        norders = int(substr(line,pointpos,i))
        print("stmerge: norders = "//norders)
	if (loglevel > 2)
          print("stmerge: norders = "//norders, >> logfile)
      }
      pointpos = 0
      while (substr(line,pointpos,pointpos) != ",")
        pointpos = pointpos+1
      pointpos = pointpos+1
      i = pointpos
      while (substr(line,i,i) != "]")
        i = i+1
      i = i-1
      if (dispaxis == 2){
        norders = int(substr(line,pointpos,i))
        print("stmerge: norders = "//norders)
	if (loglevel > 2)
          print("stmerge: norders = "//norders, >> logfile)
      }
      else{
        npix = int(substr(line,pointpos,i))
        print("stmerge: npix = "//npix)
	if (loglevel > 2)
          print("stmerge: npix = "//npix, >> logfile)
      }
    }
  }
  else{
    print("stmerge: ERROR: cannot access ccdlistfilename "//ccdlistfilename)
    print("stmerge: ERROR: cannot access ccdlistfilename "//ccdlistfilename, >> logfile)
    print("stmerge: ERROR: cannot access ccdlistfilename "//ccdlistfilename, >> warningfile)
    print("stmerge: ERROR: cannot access ccdlistfilename "//ccdlistfilename, >> errorfile)
  }
  del(ccdlistfilename, ver-)

# --- write orders to text files
  print("stmerge: starting writeaps")
  if (loglevel > 2)
    print("stmerge: starting writeaps", >> logfile)

  writeaps(input = tempfits,
           nraps1 = 1,
           nraps2 = norders,
           dispaxis = dispaxis,
           wspectext+) 
  print("stmerge: writeaps ready")
  if (loglevel > 2)
    print("stmerge: writeaps ready", >> logfile)

## --- trim apertures
  # --- read fits-file list
  fitsfiles = substr(tempfits,1,strlen(tempfits)-5)//"_fits.list"
  if (!access(fitsfiles)){
    print("stmerge: ERROR: fitsfiles "//fitsfiles//" not accessable!!!")
    print("stmerge: ERROR: fitsfiles "//fitsfiles//" not accessable!!!", >> logfile)
    print("stmerge: ERROR: fitsfiles "//fitsfiles//" not accessable!!!", >> warningfile)
    print("stmerge: ERROR: fitsfiles "//fitsfiles//" not accessable!!!", >> errorfile)
    strlist = ""
    textfilelist = ""
    return
  }

# --- read text-file list
  textfiles = substr(tempfits,1,strlen(tempfits)-5)//"_text.list"
  if (!access(textfiles)){
    print("stmerge: ERROR: textfiles "//textfiles//" not accessable!!!")
    print("stmerge: ERROR: textfiles "//textfiles//" not accessable!!!", >> logfile)
    print("stmerge: ERROR: textfiles "//textfiles//" not accessable!!!", >> warningfile)
    print("stmerge: ERROR: textfiles "//textfiles//" not accessable!!!", >> errorfile)
    strlist = ""
    textfilelist = ""
    return
  }

  jobs
  wait()

# --- check if 1st order has minimum lambda
  textfilelist = textfiles
  nfile = 0
  while (fscan(textfilelist, textfilename) != EOF){
    nfile += 1
    if (nfile == 1 || nfile == 2){
      if (access(textfilename)){
        tail(textfilename, nlines=1, >> textfilename//"_lastline_temp")
        head(textfilename, nlines=1, >> textfilename//"_firstline_temp")
        wait()
        strlist = textfilename//"_firstline_temp"
        while(fscan(strlist,lambdastr,fluxstr) != EOF){
          if (nfile == 1)
            lambdaaa = real(lambdastr)
          else
            lambdaba = real(lambdastr)
        }
        strlist = textfilename//"_lastline_temp"
        while(fscan(strlist,lambdastr,fluxstr) != EOF){
          if (nfile == 1)
            lambdaab = real(lambdastr)
          else
            lambdabb = real(lambdastr)
        }
        del(textfilename//"_lastline_temp", ver-)
        del(textfilename//"_firstline_temp", ver-)
      }
    }
  }

  if (lambdaaa > lambdaba){
# --- revert order of lists 'textfiles' and 'fitsfiles'
    revertfilelines(textfiles)
    revertfilelines(fitsfiles)
  }

  textfilelist = textfiles
  lasttextfile = ""
  lambda = 0.
  lambdastart = 0.
  lambdaend = 0.
  lambdaendpos = 0
  lambdastartpos = 0
  nfile = 0
# --- read textfilelist
  while(fscan(textfilelist,textfilename) != EOF){
    print("stmerge: textfilename = "//textfilename)
    if (loglevel > 2)
      print("stmerge: textfilename = "//textfilename, >> logfile)
    if (access(textfilename)){
      nfile += 1
# --- trim orders
      textfilenamet = substr(textfilename,1,strlen(textfilename)-5)//"t.text"
      if (access(textfilenamet))
        del(textfilenamet, ver-)
      trimbastr = ""
      trimbbstr = ""
      trimyastr = ""
      trimybstr = ""
      trima  = 0.
      trimb  = 0.
      if (nfile == 1 || nfile == norders){
        if (nfile == 1)
          trimsec = trimsecapa
        else if (nfile == norders)
          trimsec = trimsecapz

        founddd = NO
        for (i=1;i<=strlen(trimsec);i+=1){
          tempstr = substr(trimsec,i,i)
          if (tempstr != "[" && tempstr != "]"){
            if (tempstr == ":")
              founddd = YES
            else{
              if (founddd)
                trimbbstr = trimbbstr//tempstr
              else
                trimbastr = trimbastr//tempstr
            }
          }
        }
        print("stmerge: trimbastr = "//trimbastr)
        print("stmerge: trimbbstr = "//trimbbstr)
	if (loglevel > 2){
          print("stmerge: trimbastr = "//trimbastr, >> logfile)
          print("stmerge: trimbbstr = "//trimbbstr, >> logfile)
	}
        trima = int(trimbastr)
	trimb = int(trimbbstr)
      }# end if (nfile == 1 || nfile == norders)
      else{
# --- read trimb?
        founddd = NO
        for (i=1;i<=strlen(trimsecapb);i+=1){
          tempstr = substr(trimsecapb,i,i)
          if (tempstr != "[" && tempstr != "]"){
            if (tempstr == ":")
              founddd = YES
            else{
              if (founddd)
                trimbbstr = trimbbstr//tempstr
              else
                trimbastr = trimbastr//tempstr
            }
          }
        }
# --- read trimy?
        founddd = NO
        for (i=1;i<=strlen(trimsecapy);i+=1){
          tempstr = substr(trimsecapy,i,i)
          if (tempstr != "[" && tempstr != "]"){
            if (tempstr == ":")
              founddd = YES
            else{
              if (founddd)
                trimybstr = trimybstr//tempstr
              else
                trimyastr = trimyastr//tempstr
            }
          }
        }
        print("stmerge: trimbastr = "//trimbastr)
        print("stmerge: trimbbstr = "//trimbbstr)
        print("stmerge: trimyastr = "//trimyastr)
        print("stmerge: trimybstr = "//trimybstr)
	if (loglevel > 3){
          print("stmerge: trimbastr = "//trimbastr, >> logfile)
          print("stmerge: trimbbstr = "//trimbbstr, >> logfile)
          print("stmerge: trimyastr = "//trimyastr, >> logfile)
          print("stmerge: trimybstr = "//trimybstr, >> logfile)
	}
        trimba = int(trimbastr)
        trimbb = int(trimbbstr)
        trimya = int(trimyastr)
        trimyb = int(trimybstr)
        trima = trimba + ((trimya-trimba)*(nfile-2)/(norders-2))
        trimb = trimbb + ((trimyb-trimbb)*(nfile-2)/(norders-2))
      }# end else if (!(nfile == 1 || nfile == norders))
      print("stmerge: order "//nfile//": trimsec = ["//trima//":"//trimb//"]")
      if (loglevel > 2)
        print("stmerge: order "//nfile//": trimsec = ["//trima//":"//trimb//"]", >> logfile)

      jobs
      wait()
      tail(textfilename, nlines=npix-trima, >> textfilename//"_temp")
      wait()
      head(textfilename//"_temp", nlines=trimb-trima, >> textfilenamet)
      wait()
      del(textfilename//"_temp", ver-)
      textfilename = textfilenamet
      npixthis = trimb-trima

# --- write firsttextfileline
      if (access(firsttextfileline)){
        del(firsttextfileline, ver-)
        print("stmerge: old firsttextfileline deleted")
      }
      head(textfilename, nlines=1, >> firsttextfileline)
      jobs
      wait()
      #print("stmerge: firsttextfileline = ")
      #less(firsttextfileline)
      if (access(firsttextfileline)){
        strlist = firsttextfileline
        while (fscan(strlist, lambdastr, fluxstr) != EOF){
          lambdastart = real(lambdastr)
        }
      }
      else{
        print("stmerge: ERROR: cannot access firsttextfileline <"//firsttextfileline//">")
        print("stmerge: ERROR: cannot access firsttextfileline <"//firsttextfileline//">", >> logfile)
        print("stmerge: ERROR: cannot access firsttextfileline <"//firsttextfileline//">", >> warningfile)
        print("stmerge: ERROR: cannot access firsttextfileline <"//firsttextfileline//">", >> errorfile)
      } 
      print("stmerge: lambdastart = "//lambdastart)
      if (loglevel > 2)
        print("stmerge: lambdastart = "//lambdastart, >> logfile)

# --- find lambdastartpos and lambdaendpos
      if (nfile == 1){
        neworder = substr(textfilename,1,strlen(textfilename)-5)//"_new.text"
        fitsfilename = substr(neworder,1,strlen(neworder)-5)//".fits"
        if (access(neworder))
          del(neworder, ver-)
        if (access(fitsfilelist))
          del(fitsfilelist, ver-)
        print(fitsfilename, >> fitsfilelist)
        if (access(tocombinelist))
          del(tocombinelist, ver-)
        print(fitsfilename, >> tocombinelist)
        if (access(neworders))
          del(neworders, ver-)

# --- calculate meanstart and meanend
        if (access(meanstartfile)){
          del(meanstartfile, ver-)
          print("stmerge: old meanstartfile deleted")
        }
        print("stmerge: npixmean = "//npixmean)
        head(textfilename,
             nlines = 2 * npixmean, >> meanstartfile)
        if (access(meanendfile)){
          del(meanendfile, ver-)
          print("stmerge: old meanendfile deleted")
        }
        tail(textfilename,
             nlines = 2 * npixmean, >> meanendfile)
        wait()

# --- meanstart
        if (access(meanstartfile)){
          calcmean(filename=meanstartfile,
                   ncols=2,
                   col=2,
                   msigma=msigma,
                   logfile=logfile,
                   warningfile=warningfile,
                   errorfile=errorfile,
                   loglevel=loglevel,
                   deloldlog-)
          meanoutfile = meanstartfile//"_mean_rms.dat"
          if (!access(meanoutfile)){
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
            return
          }
          strlist = meanoutfile
          while(fscan(strlist, parameter, parametervalue) != EOF){
            if (parameter == "mean"){
              meanstart = real(parametervalue)
              if (meanstart < (1. / (10000000000000.*10000000000000)) && meanstart > (0.-(1. / (10000000000000.*10000000000000))))
                meanstart = 1.
            }
            else if (parameter == "rms")
              sigma = real(parametervalue)
            else if (parameter == "pixels_rejected")
              npixrej = real(parametervalue)
          }
          print("stmerge: meanstart = "//meanstart//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	  if (loglevel > 2)
            print("stmerge: meanstart = "//meanstart//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
# --- lambdaa
          calcmean(filename=meanstartfile,
                   ncols=2,
                   col=1,
                   msigma=msigma,
                   logfile=logfile,
                   warningfile=warningfile,
                   errorfile=errorfile,
                   loglevel=loglevel,
                   deloldlog-)
          meanoutfile = meanstartfile//"_mean_rms.dat"
          if (!access(meanoutfile)){
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
            return
          }
          strlist = meanoutfile
          while(fscan(strlist, parameter, parametervalue) != EOF){
            if (parameter == "mean"){
              lambdaa = real(parametervalue)
              if (lambdaa < 0.0000000000001 && lambdaa > -0.0000000000001)
                lambdaa = 1.
            }
            else if (parameter == "rms")
              sigma = real(parametervalue)
            else if (parameter == "pixels_rejected")
              npixrej = real(parametervalue)
          }
          print("stmerge: lambdaa = "//lambdaa//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	  if (loglevel > 2)
            print("stmerge: lambdaa = "//lambdaa//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
        }
        else{
          print("stmerge: ERROR: cannot access meanstartfile <"//meanstartfile//">")
          print("stmerge: ERROR: cannot access meanstartfile <"//meanstartfile//">", >> logfile)
          print("stmerge: ERROR: cannot access meanstartfile <"//meanstartfile//">", >> warningfile)
          print("stmerge: ERROR: cannot access meanstartfile <"//meanstartfile//">", >> errorfile)
        }
# --- meanend
        if (access(meanendfile)){
          calcmean(filename=meanendfile,
                   ncols=2,
                   col=2,
                   msigma=msigma,
                   logfile=logfile,
                   warningfile=warningfile,
                   errorfile=errorfile,
                   loglevel=loglevel,
                   deloldlog-)
          meanoutfile = meanendfile//"_mean_rms.dat"
          if (!access(meanoutfile)){
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
            return
          }
          strlist = meanoutfile
          while(fscan(strlist, parameter, parametervalue) != EOF){
            if (parameter == "mean"){
              meanend = real(parametervalue)
              if (meanend < (1. / (10000000000000.*10000000000000)) && meanend > (0.-(1. / (10000000000000.*10000000000000))))
                meanend = 1.
            }
            else if (parameter == "rms")
              sigma = real(parametervalue)
            else if (parameter == "pixels_rejected")
              npixrej = real(parametervalue)
          }
          print("stmerge: meanend = "//meanend//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	  if (loglevel > 2)
            print("stmerge: meanend = "//meanend//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)

# --- lambdab
          calcmean(filename=meanendfile,
                   ncols=2,
                   col=1,
                   msigma=msigma,
                   logfile=logfile,
                   warningfile=warningfile,
                   errorfile=errorfile,
                   loglevel=loglevel,
                   deloldlog-)
          meanoutfile = meanendfile//"_mean_rms.dat"
          if (!access(meanoutfile)){
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
            print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
            return
          }
          strlist = meanoutfile
          while(fscan(strlist, parameter, parametervalue) != EOF){
            if (parameter == "mean"){
              lambdab = real(parametervalue)
              if (lambdab < 0.0000000000001 && lambdab > -0.0000000000001)
                lambdab = 1.
            }
            else if (parameter == "rms")
              sigma = real(parametervalue)
            else if (parameter == "pixels_rejected")
              npixrej = real(parametervalue)
          }
          print("stmerge: lambdab = "//lambdab//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	  if (loglevel > 2)
            print("stmerge: lambdab = "//lambdab//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
        }
        else{
          print("stmerge: ERROR: cannot access meanendfile <"//meanendfile//">")
          print("stmerge: ERROR: cannot access meanendfile <"//meanendfile//">", >> logfile)
          print("stmerge: ERROR: cannot access meanendfile <"//meanendfile//">", >> warningfile)
          print("stmerge: ERROR: cannot access meanendfile <"//meanendfile//">", >> errorfile)
        }

# --- find square function to set continuum
#     f(lambda) = funcm*(lambda-lambdaa)^2 + funcn*(lambda-lambdaa) + meanstart
#     flux_new  = flux_old / f(lambda)
        lambdam = lambdaa + ((lambdab - lambdaa) / 2.)
        meanm   = meanstart + ((meanend - meanstart) / 3.)
        print("stmerge: lambdam = "//lambdam//", meanm = "//meanm)

        funcn   = (meanend - meanstart) / 3.
        dlambda = lambdab - lambdaa
        print("stmerge: lambdab = "//lambdab//", lambdaa = "//lambdaa//", dlambda = lambdab - lambdaa = "//dlambda)
        divisor = dlambda * dlambda
        print("stmerge: divisor = "//divisor)
        dlambda = lambdam - lambdaa
        print("stmerge: dlambda = "//dlambda)
	funcn   -= (meanend - meanstart) * dlambda * dlambda / (divisor)
        print("stmerge: funcn = "//funcn)
        dlambda = lambdam - lambdaa
        print("stmerge: dlambda = "//dlambda)
        divisor = dlambda - ((dlambda * dlambda) / (lambdab - lambdaa))
        print("stmerge: divisor = "//divisor)
        funcn   = funcn / divisor
        print("stmerge: funcn = "//funcn)

        funcm   = meanend - meanstart - (funcn * (lambdab - lambdaa))
        funcm   = funcm / ((lambdab - lambdaa) * (lambdab - lambdaa))
        print("stmerge: funcm = "//funcm)

        strlist = textfilename
#        funcm = multfirstap
	irun = 0
        while(fscan(strlist, lambdastr, fluxstr) != EOF){
          lambda = real(lambdastr)
          flux   = real(fluxstr)
          if (lambda > lambdaa){
            f_lambda = funcm * (lambda - lambdaa) * (lambda - lambdaa)
            f_lambda += funcn * (lambda - lambdaa)
            f_lambda += meanstart
            flux   = flux / f_lambda
          }
          else{
            flux = flux / meanstart
          }
          newline = lambda
          newline = newline//" "//flux
          print(newline, >> neworder)
	  irun = irun + 1
        }
        print(neworder, >> neworders)
      }#end if (nfile == 1)
      else{
# --- write lasttextfileline
        if (access(lasttextfileline))
          del(lasttextfileline, ver-)
        tail(textfilename,
             nlines=1, >> lasttextfileline)
        wait()
        if (access(lasttextfileline)){
          strlist = lasttextfileline
          if (fscan(strlist, lambdastr, fluxstr) != EOF){
            lambdaenda = real(lambdastr)
	    print("stmerge: lambdaenda = "//lambdaenda)
	    if (loglevel > 2)
              print("stmerge: lambdaenda = "//lambdaenda, >> logfile)
          }
        }
        else{
          print("stmerge: ERROR: cannot access lasttextfileline <"//lasttextfileline//">")
          print("stmerge: ERROR: cannot access lasttextfileline <"//lasttextfileline//">", >> logfile)
          print("stmerge: ERROR: cannot access lasttextfileline <"//lasttextfileline//">", >> warningfile)
          print("stmerge: ERROR: cannot access lasttextfileline <"//lasttextfileline//">", >> errorfile)
        } 
        if (access(lasttextfile)){
          orders_do_overlap = YES
  # --- lambdastartpos
          strlist = lasttextfile
          run = 0
          while (fscan(strlist, lambdastr, fluxstr) != EOF){
            run+=1
            lastlambda = lambda
            lambda = real(lambdastr)
            if ((lastlambda < lambdastart) && (lambda >= lambdastart))
              lambdastartpos = run
          }
	  if (lambdastartpos == 1)
            orders_do_overlap = NO

	  print("stmerge: last point of last order has lambda = "//lastlambda)
	  if (loglevel > 2)
  	    print("stmerge: last point of last order has lambda = "//lastlambda, >> logfile)
          print("stmerge: lambdastartpos = "//lambdastartpos)

  # --- lambdaendpos
          strlist = textfilename
          run = 0
          lambda = 1000000000000.
          lambdaendpos = 0
          while (fscan(strlist, lambdastr, fluxstr) != EOF){
            if (run == 0){
	      print("stmerge: first point of actual order has lambda = "//lambdastr)
	      if (loglevel > 2)
  	        print("stmerge: first point of actual order has lambda = "//lambdastr, >> logfile)
	    }
	    lastlambda = lambda
            lambda = real(lambdastr)
            if ((lastlambda <= lambdaend) && (lambda > lambdaend)){
              lambdaendpos = run
              print("stmerge: lambda = "//lambda//", lastlambda = "//lastlambda//", lambdaend = "//lambdaend//", lambdaendpos = "//lambdaendpos)
              print("stmerge: lambda = "//lambda//", lastlambda = "//lastlambda//", lambdaend = "//lambdaend//", lambdaendpos = "//lambdaendpos, >> logfile)
            }
            run+=1
          }
	  if (lambdaendpos == 0)
            orders_do_overlap = NO

	  if (!orders_do_overlap){
	    print("stmerge: WARNING!!! Orders do not overlap!!!")
	    print("stmerge: WARNING!!! Orders do not overlap!!!", >> logfile)
	    print("stmerge: WARNING!!! Orders do not overlap!!!", >> warningfile)
	  }
          else{
            if (npixmean > lambdaendpos){
              npixmean = lambdaendpos / 3.
              print("stmerge: WARNING: overlapping region has less than npixmean pixels -> correcting npixmean to "//npixmean)
              print("stmerge: WARNING: overlapping region has less than npixmean pixels -> correcting npixmean to "//npixmean, >> logfile)
              print("stmerge: WARNING: overlapping region has less than npixmean pixels -> correcting npixmean to "//npixmean, >> warningfile)
            }
          }

          print("stmerge: lambdaend = "//lambdaend//",  lambdaendpos = "//lambdaendpos)
	  if (loglevel > 2)
            print("stmerge: lambdaend = "//lambdaend//",  lambdaendpos = "//lambdaendpos, >> logfile)

# --- write meanstart- and meanend files
          if (access(meanstartfile))
            del(meanstartfile, ver-)
          if (access(meanendfile))
            del(meanendfile, ver-)
          if (access(oldoverlapfile))
            del(oldoverlapfile, ver-)
          if (access(overlapfile))
            del(overlapfile, ver-)
          if (access(meanbafile))
            del(meanbafile, ver-)
          if (access(meanbbfile))
            del(meanbbfile, ver-)
          if (access(meanaafile))
            del(meanaafile, ver-)
          if (access(meanabfile))
            del(meanabfile, ver-)

          if (access(tempfile))
            del(tempfile, ver-)
          head(textfilename,
               nlines = lambdaendpos + npixmean, >> tempfile)
          wait()
          tail(tempfile,
               nlines = 2 * npixmean, >> meanstartfile)
          tail(textfilename,
               nlines = 2*npixmean, >> meanendfile)
          wait()

          neworder = substr(textfilename,1,strlen(textfilename)-5)//"_new.text"
          if (access(neworder))
            del(neworder, ver-)
          print(neworder, >> neworders)
          fitsfilename = substr(neworder,1,strlen(neworder)-5)//".fits"
          if (access(fitsfilename))
            del(fitsfilename, ver-)
          print(fitsfilename, >> tocombinelist)
          print(fitsfilename, >> fitsfilelist)

          if (orders_do_overlap){
# --- write overlapfiles
            tail(lasttextfile,
                 nlines = npixold-lambdastartpos, >> oldoverlapfile)
            head(textfilename,
                 nlines = lambdaendpos, >> overlapfile)
            wait()
# --- write mean??files
            head(oldoverlapfile,
                 nlines = npixmean, >> meanbafile)
            tail(oldoverlapfile,
                 nlines = npixmean, >> meanbbfile)
            head(overlapfile,
                 nlines = npixmean, >> meanaafile)
            tail(overlapfile,
                 nlines = npixmean, >> meanabfile)
            wait()

# --- calculate mean??'s
  # --- meanba
            if (access(meanbafile)){
              calcmean(filename=meanbafile,
                       ncols=2,
                       col=2,
                       msigma=msigma,
                       logfile=logfile,
                       warningfile=warningfile,
                       errorfile=errorfile,
                       loglevel=loglevel,
                       deloldlog-)
              meanoutfile = meanbafile//"_mean_rms.dat"
              if (!access(meanoutfile)){
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
                return
              }
              strlist = meanoutfile
              while(fscan(strlist, parameter, parametervalue) != EOF){
                if (parameter == "mean"){
                  meanba = real(parametervalue)
                  if (meanba < (1. / (10000000000000.*10000000000000)) && meanba > (0.-(1. / (10000000000000.*10000000000000))))
                    meanba = 1.
                }
                else if (parameter == "rms")
                  sigma = real(parametervalue)
                else if (parameter == "pixels_rejected")
                  npixrej = real(parametervalue)
              }
              print("stmerge: meanba = "//meanba//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	      if (loglevel > 2)
                print("stmerge: meanba = "//meanba//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
            }
            else{
              print("stmerge: ERROR: cannot access meanbafile <"//meanbafile//">")
              print("stmerge: ERROR: cannot access meanbafile <"//meanbafile//">", >> logfile)
              print("stmerge: ERROR: cannot access meanbafile <"//meanbafile//">", >> warningfile)
              print("stmerge: ERROR: cannot access meanbafile <"//meanbafile//">", >> errorfile)
            }
  # --- meanbb
            if (access(meanbbfile)){
              calcmean(filename=meanbbfile,
                       ncols=2,
                       col=2,
                       msigma=msigma,
                       logfile=logfile,
                       warningfile=warningfile,
                       errorfile=errorfile,
                       loglevel=loglevel,
                       deloldlog-)
              meanoutfile = meanbbfile//"_mean_rms.dat"
              if (!access(meanoutfile)){
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
                return
              }
              strlist = meanoutfile
              while(fscan(strlist, parameter, parametervalue) != EOF){
                if (parameter == "mean"){
                  meanbb = real(parametervalue)
                  if (meanbb < (1. / (10000000000000.*10000000000000)) && meanbb > (0.-(1. / (10000000000000.*10000000000000))))
                    meanbb = 1.
                }
                else if (parameter == "rms")
                  sigma = real(parametervalue)
                else if (parameter == "pixels_rejected")
                  npixrej = real(parametervalue)
              }
              print("stmerge: meanbb = "//meanbb//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	      if (loglevel > 2)
                print("stmerge: meanbb = "//meanbb//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
            }
            else{
              print("stmerge: ERROR: cannot access meanbbfile <"//meanbbfile//">")
              print("stmerge: ERROR: cannot access meanbbfile <"//meanbbfile//">", >> logfile)
              print("stmerge: ERROR: cannot access meanbbfile <"//meanbbfile//">", >> warningfile)
              print("stmerge: ERROR: cannot access meanbbfile <"//meanbbfile//">", >> errorfile)
            }
# --- meanaa
            if (access(meanaafile)){
              calcmean(filename=meanaafile,
                       ncols=2,
                       col=2,
                       msigma=msigma,
                       logfile=logfile,
                       warningfile=warningfile,
                       errorfile=errorfile,
                       loglevel=loglevel,
                       deloldlog-)
              meanoutfile = meanaafile//"_mean_rms.dat"
              if (!access(meanoutfile)){
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
                return
              }
              strlist = meanoutfile
              while(fscan(strlist, parameter, parametervalue) != EOF){
                if (parameter == "mean"){
                  meanaa = real(parametervalue)
                  if (meanaa < (1. / (10000000000000.*10000000000000)) && meanaa > (0.-(1. / (10000000000000.*10000000000000))))
                    meanaa = 1.
                }
                else if (parameter == "rms")
                  sigma = real(parametervalue)
                else if (parameter == "pixels_rejected")
                  npixrej = real(parametervalue)
              }
              print("stmerge: meanaa = "//meanaa//", sigma = "//sigma//", "//npixrej//" pixels rejected")
              if (loglevel > 2)
                print("stmerge: meanaa = "//meanaa//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
# --- lambdaa
              calcmean(filename=meanaafile,
                       ncols=2,
                       col=1,
                       msigma=msigma,
                       logfile=logfile,
                       warningfile=warningfile,
                       errorfile=errorfile,
                       loglevel=loglevel,
                       deloldlog-)
              meanoutfile = meanaafile//"_mean_rms.dat"
              if (!access(meanoutfile)){
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
                return
              }
              strlist = meanoutfile
              while(fscan(strlist, parameter, parametervalue) != EOF){
                if (parameter == "mean"){
                  lambdaa = real(parametervalue)
                  if (lambdaa < 0.000000000001 && lambdaa > -0.000000000001)
                    lambdaa = 1.
                }
                else if (parameter == "rms")
                  sigma = real(parametervalue)
                else if (parameter == "pixels_rejected")
                  npixrej = real(parametervalue)
              }
              print("stmerge: lambdaa = "//lambdaa//", sigma = "//sigma//", "//npixrej//" pixels rejected")
              if (loglevel > 2)
                print("stmerge: lambdaa = "//lambdaa//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
            }
            else{
              print("stmerge: ERROR: cannot access meanaafile <"//meanaafile//">")
              print("stmerge: ERROR: cannot access meanaafile <"//meanaafile//">", >> logfile)
              print("stmerge: ERROR: cannot access meanaafile <"//meanaafile//">", >> warningfile)
              print("stmerge: ERROR: cannot access meanaafile <"//meanaafile//">", >> errorfile)
            }
# --- meanab
            if (access(meanabfile)){
              calcmean(filename=meanabfile,
                       ncols=2,
                       col=2,
                       msigma=msigma,
                       logfile=logfile,
                       warningfile=warningfile,
                       errorfile=errorfile,
                       loglevel=loglevel,
                       deloldlog-)
              meanoutfile = meanabfile//"_mean_rms.dat"
              if (!access(meanoutfile)){
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
                return
              }
              strlist = meanoutfile
              while(fscan(strlist, parameter, parametervalue) != EOF){
                if (parameter == "mean"){
                  meanab = real(parametervalue)
                  if (meanab < (1. / (10000000000000.*10000000000000)) && meanab > (0.-(1. / (10000000000000.*10000000000000))))
                    meanab = 1.
                }
                else if (parameter == "rms")
                  sigma = real(parametervalue)
                else if (parameter == "pixels_rejected")
                  npixrej = real(parametervalue)
              }
              print("stmerge: meanab = "//meanab//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	      if (loglevel > 2)
                print("stmerge: meanab = "//meanab//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
# --- lambdas
              calcmean(filename=meanabfile,
                       ncols=2,
                       col=1,
                       msigma=msigma,
                       logfile=logfile,
                       warningfile=warningfile,
                       errorfile=errorfile,
                       loglevel=loglevel,
                       deloldlog-)
              meanoutfile = meanabfile//"_mean_rms.dat"
              if (!access(meanoutfile)){
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
                return
              }
              strlist = meanoutfile
              while(fscan(strlist, parameter, parametervalue) != EOF){
                if (parameter == "mean"){
                  lambdas = real(parametervalue)
                  if (lambdas < 0.0000000000001 && lambdas > -0.0000000000001)
                    lambdas = 1.
                }
                else if (parameter == "rms")
                  sigma = real(parametervalue)
                else if (parameter == "pixels_rejected")
                  npixrej = real(parametervalue)
              }
              print("stmerge: lambdas = "//lambdas//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	      if (loglevel > 2)
                print("stmerge: lambdas = "//lambdas//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
            }
            else{
              print("stmerge: ERROR: cannot access meanabfile <"//meanabfile//">")
              print("stmerge: ERROR: cannot access meanabfile <"//meanabfile//">", >> logfile)
              print("stmerge: ERROR: cannot access meanabfile <"//meanabfile//">", >> warningfile)
              print("stmerge: ERROR: cannot access meanaafile <"//meanaafile//">", >> errorfile)
            }
# --- meanstart
            if (access(meanstartfile)){
              calcmean(filename=meanstartfile,
                       ncols=2,
                       col=2,
                       msigma=msigma,
                       logfile=logfile,
                       warningfile=warningfile,
                       errorfile=errorfile,
                       loglevel=loglevel,
                       deloldlog-)
              meanoutfile = meanstartfile//"_mean_rms.dat"
              if (!access(meanoutfile)){
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
                return
              }
              strlist = meanoutfile
              while(fscan(strlist, parameter, parametervalue) != EOF){
                if (parameter == "mean"){
                  meanstart = real(parametervalue)
                  if (meanstart < (1. / (10000000000000.*10000000000000)) && meanstart > (0.-(1. / (10000000000000.*10000000000000))))
                    meanstart = 1.
                }
                else if (parameter == "rms")
                  sigma = real(parametervalue)
                else if (parameter == "pixels_rejected")
                  npixrej = real(parametervalue)
              }
              print("stmerge: meanstart = "//meanstart//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	      if (loglevel > 2)
                print("stmerge: meanstart = "//meanstart//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
            }
            else{
              print("stmerge: ERROR: cannot access meanstartfile <"//meanstartfile//">")
              print("stmerge: ERROR: cannot access meanstartfile <"//meanstartfile//">", >> logfile)
              print("stmerge: ERROR: cannot access meanstartfile <"//meanstartfile//">", >> warningfile)
              print("stmerge: ERROR: cannot access meanstartfile <"//meanstartfile//">", >> errorfile)
            }
  # --- meanend
            if (access(meanendfile)){
              calcmean(filename=meanendfile,
                       ncols=2,
                       col=2,
                       msigma=msigma,
                       logfile=logfile,
                       warningfile=warningfile,
                       errorfile=errorfile,
                       loglevel=loglevel,
                       deloldlog-)
              meanoutfile = meanendfile//"_mean_rms.dat"
              if (!access(meanoutfile)){
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
                return
              }
              strlist = meanoutfile
              while(fscan(strlist, parameter, parametervalue) != EOF){
                if (parameter == "mean"){
                  meanend = real(parametervalue)
                  if (meanend < (1. / (10000000000000.*10000000000000)) && meanend > (0.-(1. / (10000000000000.*10000000000000))))
                    meanend = 1.
                }
                else if (parameter == "rms")
                  sigma = real(parametervalue)
                else if (parameter == "pixels_rejected")
                  npixrej = real(parametervalue)
              }
              print("stmerge: meanend = "//meanend//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	      if (loglevel > 2)
                print("stmerge: meanend = "//meanend//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
# --- lambdae
              calcmean(filename=meanendfile,
                       ncols=2,
                       col=1,
                       msigma=msigma,
                       logfile=logfile,
                       warningfile=warningfile,
                       errorfile=errorfile,
                       loglevel=loglevel,
                       deloldlog-)
              meanoutfile = meanendfile//"_mean_rms.dat"
              if (!access(meanoutfile)){
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
                print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
                return
              }
              strlist = meanoutfile
              while(fscan(strlist, parameter, parametervalue) != EOF){
                if (parameter == "mean"){
                  lambdae = real(parametervalue)
                  if (lambdae < 0.0000000000001 && lambdae > -0.0000000000001)
                    lambdae = 1.
                }
                else if (parameter == "rms")
                  sigma = real(parametervalue)
                else if (parameter == "pixels_rejected")
                  npixrej = real(parametervalue)
              }
              print("stmerge: lambdae = "//lambdae//", sigma = "//sigma//", "//npixrej//" pixels rejected")
	      if (loglevel > 2)
                print("stmerge: lambdae = "//lambdae//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)
            }
            else{
              print("stmerge: ERROR: cannot access meanendfile <"//meanendfile//">")
              print("stmerge: ERROR: cannot access meanendfile <"//meanendfile//">", >> logfile)
              print("stmerge: ERROR: cannot access meanendfile <"//meanendfile//">", >> warningfile)
              print("stmerge: ERROR: cannot access meanendfile <"//meanendfile//">", >> errorfile)
            }

# --- calculate f(lambda)=fa*(lambda-lambdas)^2 + fb(lambda-lambdas) + fc
# --- so that meanend / f(lambda) == 1., meanba / f(lambda) == meanaa, meanbb / f(lambda) == meanab
            fc = meanab / meanbb
            print("stmerge: fc = "//fc)
            if (loglevel > 2)
              print("stmerge: fc = "//fc, >> logfile)
          
            fb = ((meanaa / meanba) - fc) / (lambdaa - lambdas)
            print("stmerge: fb = "//fb)
            if (loglevel > 2)
              print("stmerge: fb = "//fb, >> logfile)

            fa = (meanend - (fb * (lambdae - lambdas)) - fc) / ((lambdae - lambdas) * (lambdae - lambdas))
            print("stmerge: fa = "//fa)
            if (loglevel > 2)
              print("stmerge: fa = "//fa, >> logfile)

# --- check if f(lambda) goes below 0.
            fluxmin = meanaa
            fluxminpos = lambdaa
            f_lambda_old = 0.
            lambda_z_a = 0.
            temprun = YES
            tempdbl = lambdas
            dtempdbl = (lambdae - lambdas) / 10000.
            dumi = 0
            while(temprun){
              f_lambda = (fb * (tempdbl - lambdas)) + fc
              if (f_lambda < fluxmin){
                fluxmin = f_lambda
                fluxminpos = tempdbl
              }
              if (f_lambda <= 0. && f_lambda_old > 0.){
                lambda_z_a = tempdbl
                temprun = NO
              }
              f_lambda_old = f_lambda
              tempdbl += dtempdbl
              if (tempdbl > lambdaenda)
                temprun = NO
              dumi = dumi + 1
              if (dumi > 100000){
                print("stmerge: WARNING: tempdbl(="//tempdbl//") does not go higher than lambdaenda(="//lambdaenda//") [dtempdbl="//dtempdbl//", lambdae="//lambdae//", lambdas="//lambdas//"] => BREAKING while loop!!! (dumi="//dumi//")")
                temprun = NO
              }
            }
            if (fluxmin <= 0.){
              print("stmerge: WARNING: fluxmin (="//fluxmin//") < 0.! (fluxminpos = "//fluxminpos//") => lambda_z_a = "//lambda_z_a//", textfilename="//textfilename)
              print("stmerge: WARNING: fluxmin (="//fluxmin//") < 0.! (fluxminpos = "//fluxminpos//") => lambda_z_a = "//lambda_z_a//", textfilename="//textfilename, >> logfile)
              print("stmerge: WARNING: fluxmin (="//fluxmin//") < 0.! (fluxminpos = "//fluxminpos//") => lambda_z_a = "//lambda_z_a//", textfilename="//textfilename, >> warningfile)
              if (lambdas > lambda_z_a){
                lambda_z_a = lambda_z_a + (2. * (lambdas - lambda_z_a))
                print("stmerge: WARNING: lambdas = "//lambdas//" > lambda_z_a!!! Setting lambda_z_a to "//lambda_z_a)
                print("stmerge: WARNING: lambdas = "//lambdas//" > lambda_z_a!!! Setting lambda_z_a to "//lambda_z_a, >> logfile)
                print("stmerge: WARNING: lambdas = "//lambdas//" > lambda_z_a!!! Setting lambda_z_a to "//lambda_z_a, >> warningfile)
              }
            }            
            else{
              lambda_z_a = lambdas + ((lambdae - lambdas) / 2.)
            }
            
            fza = 1. / (lambdas - lambda_z_a)
            fca = (meanend - meanab) / (lambdae - lambdas)
            fcb = meanab
            print("stmerge: fza = "//fza//", fca = "//fca//", fcb = "//fcb)
            print("stmerge: fza = "//fza//", fca = "//fca//", fcb = "//fcb, >> logfile)

# --- multiply textfilename by function
            strlist = textfilename
            while(fscan(strlist, lambdastr, fluxstr) != EOF){
              lambda = real(lambdastr)
              flux   = real(fluxstr)
              f_lambda = (fb * (lambda - lambdas)) + fc
              if (lambda > lambdas){
                if (fluxmin <= 0.){
                  fcont = fca * (lambda - lambdas) + fcb
                  fz    = (fza * (lambda - lambdas)) + 1.
                  if (lambda < lambda_z_a) 
                    f_lambda = (f_lambda * fz) + (fcont * (1. - fz))
                  else{
                    f_lambda = fcont
                  }
                }
                else{
                  f_lambda += (fa * (lambda - lambdas) * (lambda - lambdas))
                }
              }
              if (f_lambda < 0.){
                print("stmerge: WARNING: f_lambda < 0.(filename = "//textfilename//") lambda = "//lambda//", f_lambda = "//f_lambda//"!!!")
                print("stmerge: WARNING: f_lambda < 0.(filename = "//textfilename//") lambda = "//lambda//", f_lambda = "//f_lambda//"!!!", >> logfile)
                print("stmerge: WARNING: f_lambda < 0.(filename = "//textfilename//") lambda = "//lambda//", f_lambda = "//f_lambda//"!!!", >> warningfile)
              }
              flux   = flux / f_lambda
              newline = lambda
              newline = newline//" "//flux
              print(newline, >> neworder)
            }
          }#end if (orders_do_overlap)
          else{
# --- calculate mean of whole order
            calcmean(filename=textfilename,
                     ncols=2,
                     col=2,
                     msigma=msigma,
                     logfile=logfile,
                     warningfile=warningfile,
                     errorfile=errorfile,
                     loglevel=loglevel,
                     deloldlog-)
            meanoutfile = textfilename//"_mean_rms.dat"
            if (!access(meanoutfile)){
              print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> logfile)
              print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> warningfile)
              print("stmerge: ERROR: meanoutfile '"//meanoutfile//"' not accessable => returning", >> errorfile)
              return
            }
            strlist = meanoutfile
            while(fscan(strlist, parameter, parametervalue) != EOF){
              if (parameter == "mean"){
                meanap = real(parametervalue)
                if (meanap < (1. / (10000000000000.*10000000000000)) && meanap > (0.-(1. / (10000000000000.*10000000000000))))
                  meanap = 1.
              }
              else if (parameter == "rms")
                sigma = real(parametervalue)
              else if (parameter == "pixels_rejected")
                npixrej = real(parametervalue)
            }
            print("stmerge: meanap = "//meanap//", sigma = "//sigma//", "//npixrej//" pixels rejected")
            if (loglevel > 2)
              print("stmerge: meanap = "//meanap//", sigma = "//sigma//", "//npixrej//" pixels rejected", >> logfile)

# --- divide order by mean value
            strlist = textfilename
            while(fscan(strlist, lambdastr, fluxstr) != EOF){
              lambda = real(lambdastr)
              flux   = real(fluxstr)
              flux   = flux / meanap
              newline = lambda
              newline = newline//" "//flux
              print(newline, >> neworder)
            }
          }
        }# end if (access(lasttextfile))
        else{
          print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">")
          print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">", >> logfile)
          print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">", >> warningfile)
          print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">", >> errorfile)
        }
      } # end else if (nfile > 1)

# --- write lasttextfileline
      if (access(lasttextfileline))
        del(lasttextfileline, ver-)
      tail(textfilename,
           nlines=1, >> lasttextfileline)
      wait()
      if (access(lasttextfileline)){
        strlist = lasttextfileline
        if (fscan(strlist, lambdastr, fluxstr) != EOF){
          lambdaend = real(lambdastr)
	  print("stmerge: lambdaend = "//lambdaend)
	  if (loglevel > 2)
            print("stmerge: lambdaend = "//lambdaend, >> logfile)
        }
      }
      else{
        print("stmerge: ERROR: cannot access lasttextfileline <"//lasttextfileline//">")
        print("stmerge: ERROR: cannot access lasttextfileline <"//lasttextfileline//">", >> logfile)
        print("stmerge: ERROR: cannot access lasttextfileline <"//lasttextfileline//">", >> warningfile)
        print("stmerge: ERROR: cannot access lasttextfileline <"//lasttextfileline//">", >> errorfile)
      } 
    }# end (if (access(textfilename)))
    else{
      print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">")
      print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">", >> logfile)
      print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">", >> warningfile)
      print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">", >> errorfile)
    } 
    lasttextfile = neworder
    npixold = npixthis
    npixmean = npixmeanorig
  }# end of while(fscan(textfilelist...

# --- convert new text files to fits
  print("stmerge: converting text files back to fits files")
  if (loglevel > 2)
    print("stmerge: converting text files back to fits files", >> logfile)
  strlist = fitsfilelist
  while (fscan(strlist, fitsfilename) != EOF){
    if (access(fitsfilename))
      del(fitsfilename, ver-)
  }
  print("stmerge: starting rspectext(input=@"//neworders//", output= @"//fitsfilelist//", title=<>, flux-, dtype=interp, crval1=INDEF, cdelt1=INDEF)")
  if (loglevel > 2)
    print("stmerge: starting rspectext(input=@"//neworders//", output= @"//fitsfilelist//", title=<>, flux-, dtype=interp, crval1=INDEF, cdelt1=INDEF)", >> logfile)
  onedspec.rspectext(input = "@"//neworders,
            output = "@"//fitsfilelist,
            title = "",
	    flux-,
	    dtype = "interp",
            crval1 = INDEF,
            cdelt1 = INDEF)

  if (substr(image,strlen(image)-4,strlen(image)) == ".fits")
    output = substr(image,1,strlen(image)-5)//"_merged.fits"
  else
    output = image//"_merged.fits"
  if (access(output))
    del(output, ver-)

# --- combine orders
  print("stmerge: combining orders")
  if (loglevel > 2)
    print("stmerge: combining orders", >> logfile)
  onedspec.scombine(input = "@"//tocombinelist,
           output = output,
	   noutput = "",
           logfile = "STDOUT",
	   aperture = "",
           group = "apertures",
           combine = "median",
	   reject = "avsigclip",
           first-,
           w1 = INDEF,
           w2 = INDEF,
           dw = INDEF,
           nw = INDEF,
	   log-,
	   scale = "none",
           zero = "none",
           weight = "none",
	   sample = "",
	   lthresh = INDEF,
           hthresh = INDEF,
	   nlow = 0,
	   nhigh = 0,
	   nkeep = 1,
	   mclip+,
	   lsigma = 3.,
	   hsigma = 3.,
	   rdnoise = rdnoise,
	   gain = gain,
	   snoise = snoise,
	   sigscal = 0.1,
           pclip = -0.5,
	   grow = 0,
	   blank = 0.)

  if (access(output)){
    print("stmerge: "//output//" ready")
    print("stmerge: "//output//" ready", >> logfile)
  }
  else{
    print("stmerge: ERROR! "//output//" not accessable")
    print("stmerge: ERROR! "//output//" not accessable", >> logfile)
    print("stmerge: ERROR! "//output//" not accessable", >> warningfile)
    print("stmerge: ERROR! "//output//" not accessable", >> errorfile)
  }

# --- Aufraeumen
  imdel(tempfits, ver-)
  del("@"//fitsfiles, ver-)
  del("@"//textfiles, ver-)
  del(fitsfiles, ver-)
  del(textfiles, ver-)
  if (access(firsttextfileline))
    del(firsttextfileline, ver-)
  if (access(oldoverlapfile))
    del(oldoverlapfile, ver-)
  if (access(overlapfile))
    del(overlapfile, ver-)
  if (access(meanaafile))
    del(meanaafile, ver-)
  if (access(meanabfile))
    del(meanabfile, ver-)
  if (access(meanbafile))
    del(meanbafile, ver-)
  if (access(meanbbfile))
    del(meanbbfile, ver-)
  if (access(tempfile))
    del(tempfile, ver-)
  if (access(tempfilea))
    del(tempfilea, ver-)
  del(lasttextfileline, ver-)
  strlist = ""
  textfilelist = ""

end
