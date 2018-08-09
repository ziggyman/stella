procedure temporary (image)

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
#int *npixlist
string *strlist
string *textfilelist

begin

  string ccdlistfilename   = "ccdlist.out"
  string overlapfile       = "overlap.text"
  string oldoverlapfile    = "oldoverlap.text"
  string meanaafile        = "meanaa.text"
  string meanabfile        = "meanab.text"
  string meanbafile        = "meanba.text"
  string meanbbfile        = "meanbb.text"
  string meanendfile       = "meanend.text"
  string meanstartfile     = "meanstart.text"
  string lasttextfileline  = "lasttextfileline.text"
  string firsttextfileline = "firsttextfileline.text"
  string neworders         = "neworders.list"
  string neworder          = ""
  string tocombinelist     = "tocombine.list"
  string fitsfilelist      = "fits_new.list"
  string newline,trimsec,tempstr,parameter,parametervalue
  string trimbastr,trimbbstr,trimyastr,trimybstr
  string line,lambdastr,fluxstr,lasttextfile,textfilenamet
  string tempfits,tempimage
  string textfiles,textfilename,output,fitsfiles,fitsfilename
  int    pointpos,i,j,run,norders,npix,npixthis,lambdastartpos,lambdaendpos
  int    nfile,meanrun,npixold,trimba,trimbb,trimya,trimyb,trima,trimb,irun
  int    ngood,npixrej
  int    maxchars = 62
  real   tempdbl,meanaa,meanab,meanba,meanbb,oldmeanaa,oldmeanab,oldmeanba,oldmeanbb
  real   lambda,flux,lastlambda,lambdastart,lambdaend,funcm,funcn,faca,facb,dlambda
  real   lambdaI,sumsqrs,sum,variance,sigma,tmpreal,meanend,meanstart
  real   lambdaa,lambdab,lambdam
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
      print("stmerge: WARNING: parameter 'merge_lthreshold' not found in "//parameterfile//"!!! -> using standard value (="//lthreshold//")")
      print("stmerge: WARNING: parameter 'merge_lthreshold' not found in "//parameterfile//"!!! -> using standard value (="//lthreshold//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_lthreshold' not found in "//parameterfile//"!!! -> using standard value (="//lthreshold//")", >> warningfile)
    }
    if (!found_merge_hthreshold){
      print("stmerge: WARNING: parameter 'merge_hthreshold' not found in "//parameterfile//"!!! -> using standard value (="//hthreshold//")")
      print("stmerge: WARNING: parameter 'merge_hthreshold' not found in "//parameterfile//"!!! -> using standard value (="//hthreshold//")", >> logfile)
      print("stmerge: WARNING: parameter 'merge_hthreshold' not found in "//parameterfile//"!!! -> using standard value (="//hthreshold//")", >> warningfile)
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
      }
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
      }
      print("stmerge: order "//nfile//": trimsec = ["//trima//":"//trimb//"]")
      if (loglevel > 2)
        print("stmerge: order "//nfile//": trimsec = ["//trima//":"//trimb//"]", >> logfile)

      jobs
      wait()
      tail(textfilename, nlines=npix-trima, >> textfilename//"_temp")
      head(textfilename//"_temp", nlines=trimb-trima, >> textfilenamet)
      del(textfilename//"_temp", ver-)
      textfilename = textfilenamet
      npixthis = trimb-trima

# --- write firsttextfileline
      if (access(firsttextfileline))
        del(firsttextfileline, ver-)
#      print("stmerge: old firsttextfileline deleted")
      head(textfilename, nlines=1, >> firsttextfileline)
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

    }# end (if (access(textfilename)))
    else{
      print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">")
      print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">", >> logfile)
      print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">", >> warningfile)
      print("stmerge: ERROR: cannot access lasttextfile <"//lasttextfile//">", >> errorfile)
    } 
    lasttextfile = neworder
    npixold = npixthis

  }# end of while(fscan(textfilelist...

# --- convert new text files to fits

end