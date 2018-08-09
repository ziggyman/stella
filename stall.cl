procedure stall (images)

##################################################################
#                                                                #
# NAME:             stall.cl                                     #
# PURPOSE:          * Master script of the STELLA data-reduction #
#                     pipeline                                   #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stall(images)                                #
# INPUTS:           images: String                               #
#                     name of filelist containing all raw images #
#                                                                #
# OUTPUTS:          outfiles: ...                                #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      04.12.2001                                   #
# LAST EDITED:      02.04.2007                                   #
#                                                                #
##################################################################

string images            = "@to_reduce.list"  {prompt="List of images to reduce"}
string parameterfile     = "scripts$parameterfiles/parameterfile_SES_2148x2052.prop" {prompt="Path and name of parameterfile"}
bool   docalibs          = YES  {prompt="Process calibration files?"}
bool   dostprepare       = YES  {prompt="Execute stprepare task?"}
bool   dostzero          = YES  {prompt="Execute stzero task?"}
bool   dostbadovertrim   = YES  {prompt="Execute stbadovertrim task?"}
bool   dostsubzero       = YES  {prompt="Execute stsubzero task?"}
bool   dostflat          = YES  {prompt="Execute stflat task?"}
bool   dostnflat         = YES  {prompt="Execute stnflat task?"}
bool   dostdivflat       = YES  {prompt="Execute stdivflat task?"}
bool   dostcosmics       = YES  {prompt="Execute stcosmics task?"}
bool   dostscatter       = YES  {prompt="Execute stscatter task?"}
bool   dostfixcurvature  = YES  {prompt="Execute stfixcurvature task?"}
bool   doextractcalibs   = YES  {prompt="Execute extract calibs task?"}
bool   dostidentify      = YES  {prompt="Execute stidentify task?"}
bool   doextractobjects  = YES  {prompt="Execute extract objects task?"}
bool   dostblaze         = YES  {prompt="Execute stblaze task?"}
bool   dostrefspec       = YES  {prompt="Execute strefspec task?"}
bool   dostdispcor       = YES  {prompt="Execute stdispcor task?"}
bool   dosttrimaps       = YES  {prompt="Execute sttrimaps task?"}
bool   dostmerge         = YES  {prompt="Execute stmerge task?"}
bool   dostcombine       = YES  {prompt="Execute stcombine task?"}
bool   dostcontinuum     = YES  {prompt="Execute stcontinuum task?"}
bool   delinputfiles     = NO   {prompt="Delete input files?"}
bool   deleteoldlogfiles = YES  {prompt="Delete old logfiles?"}
bool   cleanup           = NO   {prompt="Clean up directory if reduction process was successfull?"}
string *inimages
string *parameterlist
string *timelist

begin

#  bool   dostmerge = NO
  bool   firstcalib,firstobs
  bool   nflat_subscatter = NO
  string ApNoStr
  string observatory,reference,imnameroot,refBlaze_list
  string refapObs,refapCalibs,refBlaze,refBlaze_n,refBlaze_nd,refBlaze_t_fits_list,refBlaze_temp
  string combinedzero,combinedzero_bot,combinedzero_e,combinedzero_sig,combinedzero_sig_obt
  string combinedflat,combinedflat_s,combinedflat_e,combinedflat_sig
  string normalizedflat,normalizedflat_e,templogfile,tempwarningfile,temperrorfile
  string timefile
  string trimmed_ap_text_lists_list
  string trimmed_ap_err_text_lists_list
  string blazed_trimmed_ap_text_lists_list
  string blazed_trimmed_ap_err_text_lists_list
  string blazed_trimmed_ap_fits_lists_list
  string blazed_trimmed_ap_err_fits_lists_list
  string to_merge_list
  string to_merge_err_list
  string logfile_bak,warningfile_bak,errorfile_bak,parameterfile_bak
  string logfile,warningfile,errorfile
  string logfile_stcreerr,warningfile_stcreerr,errorfile_stcreerr
  string logfile_stprepare,warningfile_stprepare,errorfile_stprepare
  string logfile_stzero,warningfile_stzero,errorfile_stzero
  string logfile_stbadovertrim,warningfile_stbadovertrim,errorfile_stbadovertrim
  string logfile_stsubzero,warningfile_stsubzero,errorfile_stsubzero
  string logfile_stflat,warningfile_stflat,errorfile_stflat
  string logfile_stscatter,warningfile_stscatter,errorfile_stscatter
  string logfile_stnflat,warningfile_stnflat,errorfile_stnflat
  string logfile_stdivflat,warningfile_stdivflat,errorfile_stdivflat
  string logfile_stcosmics,warningfile_stcosmics,errorfile_stcosmics
  string logfile_stfixcurvature,warningfile_stfixcurvature,errorfile_stfixcurvature
  string logfile_stextract,warningfile_stextract,errorfile_stextract
  string logfile_stidentify,warningfile_stidentify,errorfile_stidentify
  string logfile_stcrerefblaze,warningfile_stcrerefblaze,errorfile_stcrerefblaze
  string logfile_stblaze,warningfile_stblaze,errorfile_stblaze
  string logfile_strefspec,warningfile_strefspec,errorfile_strefspec
  string logfile_stdispcor,warningfile_stdispcor,errorfile_stdispcor
  string logfile_sttrimaps,warningfile_sttrimaps,errorfile_sttrimaps
  string logfile_stmergelist,warningfile_stmergelist,errorfile_stmergelist
  string logfile_stcombine,warningfile_stcombine,errorfile_stcombine
  string logfile_stcontinuum,warningfile_stcontinuum,errorfile_stcontinuum
  string objects_list
  string objects_bot_list
  string objects_bot_errlist
  string calibs_list
  string flats_list
  string combinedzerolist
  string zerolist
  string zeroerrlist
  string subzerolist
  string objects_botzf_list
  string cosmicerrlist
  string flatlist
  string flaterrlist
  string subscattercalibslist
  string subscatterobjectslist
  string subscatterflatslist
  string divflatlist
  string extractcalibslist
#  string extractcalibserrlist
  string calibsEc_list
  string objects_botzfxs_list
  string objects_botzfxs_err_list
  string blazelist
  string blazeerrlist
  string tempblazelist
  string tempblazeerrlist
  string dispcor_list
  string dispcor_err_list
  string objects_botzfxsEc_list
  string objects_botzfxsEc_err_list
  string objects_botzfxsEcBl_list
  string objects_botzfxsEcBl_err_list
  string tempdispcor_list
  string tempdispcor_err_list
#  string calcsnrlist
#  string calcsnrerrlist
  string objects_botzfxsEcd_list
  string objects_botzfxsEcd_err_list
  string objects_botzfxsEcdt_list
  string objects_botzfxsEcdt_err_list
  string objects_botzfxsEcBld_list
  string objects_botzfxsEcBld_err_list
  string objects_botzfxsEcdc_list
  string objects_botzfxsEcdc_err_list
  string objects_botzfxsEcBldc_list
  string objects_botzfxsEcBldc_err_list
  string objects_botzfxsEcd_m_list
  string objects_botzfxsEcd_m_err_list
  string objects_botzfxsEcBldt_rb_m_list
  string objects_botzfxsEcBldt_rb_m_err_list
  string objects_botzfxsEcBldt_rb_mc_list
  string objects_botzfxsEcBldt_rb_mc_err_list
  string fix_curvature_list
  string combine_list
  string combine_err_list
  string parameter,parametervalue,refflat,refstring
  string tempobslista="tempobs_a.list"
  string tempobserrlista="tempobserr_a.list"
  string tempinfile,templist,temperrlist,tempobslist,tempobserrlist,tempfile
  int    loglevel
  int    dispaxis
  int    Pos
  file   infile
  string in, inname
  string imtype
  real   apdef_lower
  real   apdef_upper
  string apdef_apidtable
  string apdefb_function
  int    apdefb_order
  int    apdefb_samplebuf
  string apdefb_sample
  int    apdefb_naverage
  int    apdefb_niterate
  real   apdefb_low_reject
  real   apdefb_high_reject
  real   apdefb_grow

  bool   doerrors
  bool   imred_keeplog

  string ccdred_pixeltype
  bool   ccdred_verbose
  string ccdred_plotfile
  string ccdred_backup
  string ccdred_ssfile
  string ccdred_graphic
  string ccdred_cursor

  string setinst_instrument
  string setinst_site
  string setinst_dir
  bool   setinst_review

  int    ext_nsubaps

  string extinct
  string caldir
  string interp
  int    nsum
  string database
  bool   verbose
  string plotfile
  string records

  string onedspec_interp

  int    i,j,slashpos,lastpointpos
  string daystring,timestring,datestring
  string directory
  string blazeflat

  bool ext_clean
  string ext_weights
  string ext_pfit

  int ext_iter_telluric
#  bool ext_iter_MkSkyErrIm
  bool ext_iter_MkSPFitIm
  bool spectral_features_tilted

  bool   oldlogsdeleted
  bool   blaze_divbyfilter
  bool   found_observatory
  bool   found_setinst_instrument
  bool   found_imtype
  bool   found_spectral_features_tilted
  bool   found_extinct
  bool   found_caldir
  bool   found_interp
  bool   found_dispaxis
  bool   found_nsum
  bool   found_ccdred_ssfile
  bool   found_ccdred_graphic
  bool   found_reference
  bool   found_log_level
  bool   found_apdef_lower
  bool   found_apdef_upper
  bool   found_apdef_apidtable
  bool   found_apdefb_function
  bool   found_apdefb_order
  bool   found_apdefb_sample
  bool   found_apdefb_samplebuf
  bool   found_apdefb_naverage
  bool   found_apdefb_niterate
  bool   found_apdefb_low_reject
  bool   found_apdefb_high_reject
  bool   found_apdefb_grow
  bool   found_calc_error_propagation
  bool   found_nflat_subscatter
  bool   found_onedspec_interp
  bool   found_ext_nsubaps
  bool   found_blaze_divbyfilter
  bool   found_ext_clean
  bool   found_ext_weights
  bool   found_ext_pfit
  bool   found_ext_iter_telluric
#  bool   found_ext_iter_MkSkyErrIm
  bool   found_ext_iter_MkSPFitIm

  blazed_trimmed_ap_text_lists_list = "tempasgwaefwe.list"
  blazed_trimmed_ap_err_text_lists_list = "tempasgwaefwe.list"
  blazed_trimmed_ap_fits_lists_list = "tempasgwaefwe.list"
  blazed_trimmed_ap_err_fits_lists_list = "tempasgwaefwe.list"
  to_merge_list         = "to_merge.list"
  to_merge_err_list     = "to_merge_err.list"
  firstcalib            = YES
  firstobs              = YES
  ApNoStr               = ""
  observatory           = "STELLA"
  reference             = "refFlat"
  refapObs              = "Obs"
  refapCalibs            = "Calibs"
  timefile              = "time.text"
  logfile               = "logfile.log"
  errorfile             = "errors.log"
  warningfile           = "warnings.log"
  logfile_stcreerr             = "logfile_stcreerr.log"
  warningfile_stcreerr         = "warnings_stcreerr.log"
  errorfile_stcreerr           = "errors_stcreerr.log"
  logfile_stprepare            = "logfile_stprepare.log"
  warningfile_stprepare        = "warnings_stprepare.log"
  errorfile_stprepare          = "errors_stprepare.log"
  logfile_stzero               = "logfile_stzero.log"
  warningfile_stzero           = "warnings_stzero.log"
  errorfile_stzero             = "errors_stzero.log"
  logfile_stbadovertrim        = "logfile_stbadovertrim.log"
  warningfile_stbadovertrim    = "warnings_stbadovertrim.log"
  errorfile_stbadovertrim      = "errors_stbadovertrim.log"
  logfile_stsubzero            = "logfile_stsubzero.log"
  warningfile_stsubzero        = "warnings_stsubzero.log"
  errorfile_stsubzero          = "errors_stsubzero.log"
  logfile_stflat               = "logfile_stflat.log"
  warningfile_stflat           = "warnings_stflat.log"
  errorfile_stflat             = "errors_stflat.log"
  logfile_stscatter            = "logfile_stscatter.log"
  warningfile_stscatter        = "warnings_stscatter.log"
  errorfile_stscatter          = "errors_stscatter.log"
  logfile_stnflat              = "logfile_stnflat.log"
  warningfile_stnflat          = "warnings_stnflat.log"
  errorfile_stnflat            = "errors_stnflat.log"
  logfile_stdivflat            = "logfile_stdivflat.log"
  warningfile_stdivflat        = "warnings_stdivflat.log"
  errorfile_stdivflat          = "errors_stdivflat.log"
  logfile_stcosmics            = "logfile_stcosmics.log"
  warningfile_stcosmics        = "warnings_stcosmics.log"
  errorfile_stcosmics          = "errors_stcosmics.log"
  logfile_stfixcurvature       = "logfile_fixcurvature.log"
  warningfile_stfixcurvature   = "warnings_fixcurvature.log"
  errorfile_stfixcurvature     = "errors_stextract.log"
  logfile_stextract            = "logfile_stextract.log"
  warningfile_stextract        = "warnings_stextract.log"
  errorfile_stextract          = "errors_stextract.log"
  logfile_stidentify           = "logfile_stidentify.log"
  warningfile_stidentify       = "warnings_stidentify.log"
  errorfile_stidentify         = "errors_stidentify.log"
  logfile_stcrerefblaze        = "logfile_stcrerefblaze.log"
  warningfile_stcrerefblaze    = "warnings_stcrerefblaze.log"
  errorfile_stcrerefblaze      = "errors_stcrerefblaze.log"
  logfile_stblaze              = "logfile_stblaze.log"
  warningfile_stblaze          = "warnings_stblaze.log"
  errorfile_stblaze            = "errors_stblaze.log"
  logfile_strefspec            = "logfile_strefspec.log"
  warningfile_strefspec        = "warnings_strefspec.log"
  errorfile_strefspec          = "errors_strefspec.log"
  logfile_stdispcor            = "logfile_stdispcor.log"
  warningfile_stdispcor        = "warnings_stdispcor.log"
  errorfile_stdispcor          = "errors_stdispcor.log"
  logfile_sttrimaps            = "logfile_sttrimaps.log"
  warningfile_sttrimaps        = "warnings_sttrimaps.log"
  errorfile_sttrimaps          = "errors_sttrimaps.log"
#  logfile_stcalcsnr            = "logfile_stcalcsnr.log"
#  warningfile_stcalcsnr        = "warnings_stcalcsnr.log"
#  errorfile_stcalcsnr          = "errors_stcalcsnr.log"
  logfile_stmergelist          = "logfile_stmergelist.log"
  warningfile_stmergelist      = "warnings_stmergelist.log"
  errorfile_stmergelist        = "errors_stmergelist.log"
  logfile_stcombine            = "logfile_stcombine.log"
  warningfile_stcombine        = "warnings_stcombine.log"
  errorfile_stcombine          = "errors_stcombine.log"
  logfile_stcontinuum          = "logfile_stcontinuum.log"
  warningfile_stcontinuum      = "warnings_stcontinuum.log"
  errorfile_stcontinuum        = "errors_stcontinuum.log"
  refBlaze_list         = "refBlaze.list"
  objects_list          = "objects.list"
  objects_bot_list      = "objects_bot.list"
  objects_bot_errlist      = "objects_bot_err.list"
  calibs_list           = "calibs.list"
  flats_list            = "flats.list"
#  badovertrimlist       = "stbadovertrim.list"
#  badovertrimerrlist    = "stbadovertrim_e.list"
  combinedzerolist      = "combinedZero.list"
  zerolist              = "zeros.list"
  zeroerrlist           = "zeros_e.list"
  subzerolist           = "stsubzero.list"
#  subzeroerrlist        = "stsubzero_e.list"
  cosmicerrlist         = "stcosmics_e.list"
  flatlist              = "flats_botz.list"
  flaterrlist           = "flats_botz_e.list"
  subscattercalibslist   = "calibs_botzf.list"
  subscatterobjectslist = "objects_botz.list"
  subscatterflatslist   = "combinedFlat.list"
  divflatlist           = "stdivflat.list"
#  divflaterrlist        = "stdivflat_e.list"
  extractcalibslist     = "calibs_botzfs.list"
#  extractcalibserrlist  = "calibs_botzfs_e.list"
  calibsEc_list        = "calibs_botzfsEc.list"
  objects_botzf_list   = "objects_botzf.list"
  objects_botzfxs_list     = "objects_botzfxs.list"
  objects_botzfxs_err_list = "objects_botzfxs_e.list"
  fix_curvature_list    = "to_fix_curvature.list"
  blazelist             = "objects_botzfxsEcBlaze.list"
  blazeerrlist          = "objects_botzfxsEc_eBlaze.list"
  dispcor_list          = "stdispcor_objects.list"
  dispcor_err_list      = "stdispcor_objects_e.list"
  objects_botzfxsEc_list        = "objects_botzfxsEc.list"
  objects_botzfxsEc_err_list    = "objects_botzfxsEc_e.list"
  objects_botzfxsEcBl_list     = "objects_botzfxsEcBl.list"
  objects_botzfxsEcBl_err_list = "objects_botzfxsEcBl_e.list"
#  merge_list            = "objects_botzfxsEcd.list"
#  merge_err_list        = "objects_botzfxsEcd_e.list"
  objects_botzfxsEcd_list        = "objects_botzfxsEcd.list"
  objects_botzfxsEcd_err_list    = "objects_botzfxsEcd_e.list"
  objects_botzfxsEcdt_list       = "objects_botzfxsEcdt.list"
  objects_botzfxsEcdt_err_list   = "objects_botzfxsEcdt_e.list"
  objects_botzfxsEcBld_list     = "objects_botzfxsEcBld.list"
  objects_botzfxsEcBld_err_list = "objects_botzfxsEcBld_e.list"
  objects_botzfxsEcdc_list        = "objects_botzfxsEcdc.list"
  objects_botzfxsEcdc_err_list    = "objects_botzfxsEcdc_e.list"
  objects_botzfxsEcBldc_list     = "objects_botzfxsEcBldc.list"
  objects_botzfxsEcBldc_err_list = "objects_botzfxsEcBldc_e.list"
  combine_list           = "stcombine.list"
  combine_err_list        = "stcombine_e.list"
  objects_botzfxsEcd_m_list        = "objects_botzfxsEcd_m.list"
  objects_botzfxsEcd_m_err_list    = "objects_botzfxsEcd_m_e.list"
  objects_botzfxsEcBldt_rb_m_list     = "objects_botzfxsEcBldt_rb_m.list"
  objects_botzfxsEcBldt_rb_m_err_list = "objects_botzfxsEcBldt_rb_m_e.list"
  objects_botzfxsEcBldt_rb_mc_list     = "objects_botzfxsEcBldt_rb_mc.list"
  objects_botzfxsEcBldt_rb_mc_err_list = "objects_botzfxsEcBldt_rb_mc_e.list"
  tempinfile            = "temp.list"
  loglevel              = 3
  dispaxis              = 2   # vertical dispersion
  imtype                = "fits"
  apdef_lower           = -22.
  apdef_upper           = 22.
  apdef_apidtable       = ""
  apdefb_function       = "chebyshev"
  apdefb_order          = 1
  apdefb_samplebuf      = 4
  apdefb_sample         = "-25:-23,23:25"
  apdefb_naverage       = -3
  apdefb_niterate       = 2
  apdefb_low_reject     = 3.
  apdefb_high_reject    = 3.
  apdefb_grow           = 0.

  doerrors              = YES
  imred_keeplog         = NO

  ccdred_pixeltype      = "real real"
  ccdred_verbose        = YES
  ccdred_plotfile       = ""
  ccdred_backup         = ""
  ccdred_ssfile         = "subsets"
  ccdred_graphic        = "stdgraph"
  ccdred_cursor         = ""

  setinst_instrument    = "echelle"
  setinst_site          = "kpno"
  setinst_dir           = "ccddb$"
  setinst_review        = YES

  ext_nsubaps           = 1

  extinct               = "onedstds$kpnoextinct.dat"
  caldir                = "onedstds$spechayescal/"
  interp        = "linear"
  nsum          = 1
  database      = "database"
  verbose       = YES
  plotfile      = ""
  records       = ""

  onedspec_interp       = "poly5"
  directory     = ""

  ext_clean = YES
  ext_weights = "variance"
  ext_pfit = "iterate"

  ext_iter_telluric = 0
#  ext_iter_MkSkyErrIm = NO
  ext_iter_MkSPFitIm = NO
  spectral_features_tilted = NO

  oldlogsdeleted                 = NO
  blaze_divbyfilter              = NO
  found_observatory              = NO
  found_setinst_instrument       = NO
  found_imtype                   = NO
  found_spectral_features_tilted = NO
  found_extinct                  = NO
  found_caldir                   = NO
  found_interp                   = NO
  found_dispaxis                 = NO
  found_nsum                     = NO
  found_ccdred_ssfile            = NO
  found_ccdred_graphic           = NO
  found_reference                = NO
  found_log_level                = NO
  found_apdef_lower              = NO
  found_apdef_upper              = NO
  found_apdef_apidtable          = NO
  found_apdefb_function          = NO
  found_apdefb_order             = NO
  found_apdefb_sample            = NO
  found_apdefb_samplebuf         = NO
  found_apdefb_naverage          = NO
  found_apdefb_niterate          = NO
  found_apdefb_low_reject        = NO
  found_apdefb_high_reject       = NO
  found_apdefb_grow              = NO
  found_calc_error_propagation   = NO
  found_nflat_subscatter         = NO
  found_onedspec_interp          = NO
  found_ext_nsubaps              = NO
  found_blaze_divbyfilter        = NO
  found_ext_clean                = NO
  found_ext_weights              = NO
  found_ext_pfit                 = NO
  found_ext_iter_telluric        = NO
#  found_ext_iter_MkSkyErrIm      = NO
  found_ext_iter_MkSPFitIm       = NO

  print("****************************************************")
  print("*                                                  *")
  print("*      Automatic data reduction for the STELLA     *")
  print("*                 ECHELLE spectra                  *")
  print("*                                                  *")
  print("*            Andreas Ritter, 07.12.2001            *")
  print("*                                                  *")
  print("****************************************************")

# --- load neccesary packages
  noao
  imred
  ccdred
  onedspec

# --- delete logfiles
  if (deleteoldlogfiles){
#    if (loglevel > 2 && (access(logfile) || access(errorfile) || access(warningfile)))
#      print("stall: deleting old logfiles", >> logfile)
    if (access(logfile))
      delete(files=logfile,ver-)
    if (access("logfile"))
      delete(files="logfile",ver-)
    if (access(errorfile))
      delete(files=errorfile,ver-)
    if (access(warningfile))
      delete(files=warningfile,ver-)
    print("stall: Old logfiles deleted")
    if (loglevel > 2){
      print("stall: Old logfiles deleted", >> logfile)
    }
  }
  if (access(refBlaze_list))
    del(refBlaze_list, ver-)

  print("****************************************************")
  print("*                                                  *")
  print("*      Automatic data reduction for the STELLA     *")
  print("*                 ECHELLE spectra                  *")
  print("*                                                  *")
  print("*                  stall started                   *")
  print("*                                                  *")
  print("****************************************************")

  time (>> logfile)

# --- read parameterfile
  if (access(parameterfile)){

    parameterlist = parameterfile

    print ("stall: **************** reading "//parameterfile//" *******************")
    if (loglevel > 2){
      print ("stall: **************** reading "//parameterfile//" *******************", >> logfile)
    }

    while (fscan (parameterlist, parameter, parametervalue) != EOF){
      if (parameter == "log_level"){
        loglevel = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//loglevel)
        if (loglevel > 2){
          print ("stall: Setting "//parameter//" to "//loglevel, >> logfile)
        }
        found_log_level = YES
      }
      else if (parameter == "observatory"){
        observatory = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_observatory = YES
        set observatory=observatory
      }
      else if (parameter == "setinst_instrument"){
        if (parametervalue == "echelle" || parametervalue == "coude"){
          setinst_instrument = parametervalue
          print ("stall: Setting "//parameter//" to "//parametervalue)
          if (loglevel > 2)
            print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
        else{
          print ("stall: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value")
          print ("stall: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value", >> logfile)
          print ("stall: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value", >> warningfile)
        }
        found_setinst_instrument = YES
      }
      else if (parameter == "imtype"){
        imtype = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_imtype = YES
      }
      else if (parameter == "spectral_features_tilted"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          spectral_features_tilted = YES
          print ("stall: Setting spectral_features_tilted to YES")
          if(loglevel > 2)
            print ("stall: Setting spectral_features_tilted to YES", >> logfile)
        }
        else{
          spectral_features_tilted = NO
          print ("stall: Setting spectral_features_tilted to NO")
          if(loglevel > 2)
            print ("stall: Setting spectral_features_tilted to NO", >> logfile)
        }
        found_spectral_features_tilted = YES
      }
      else if (parameter == "extinct"){
        extinct = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extinct = YES
      }
      else if (parameter == "caldir"){
        caldir = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_caldir = YES
      }
      else if (parameter == "interp"){
        interp = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_interp = YES
      }
      else if (parameter == "dispaxis"){
        dispaxis = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2){
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
        found_dispaxis = YES
      }
      else if (parameter == "nsum"){
        nsum = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_nsum = YES
      }
      else if (parameter == "ccdred_ssfile"){
        ccdred_ssfile = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ccdred_ssfile = YES
      }
      else if (parameter == "ccdred_graphic"){
        ccdred_graphic = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ccdred_graphic = YES
      }
      else if (parameter == "onedspec_interp"){
        onedspec_interp = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_onedspec_interp = YES
      }
      else if (parameter == "reference"){
        reference = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_reference = YES
      }
      else if (parameter == "ext_nsubaps"){
        ext_nsubaps = int(parametervalue)
        print ("stall: Setting ext_nsubaps to "//ext_nsubaps)
        if (loglevel > 2)
          print ("stall: Setting ext_nsubaps to "//ext_nsubaps, >> logfile)
        found_ext_nsubaps = YES
      }
      else if (parameter == "resize_obs_lower"){
        apdef_lower = real(parametervalue)
        print ("stall: Setting apdef_lower (=resize_obs_lower) to "//apdef_lower)
        if (loglevel > 2)
          print ("stall: Setting apdef_lower (=resize_obs_lower) to "//apdef_lower, >> logfile)
        found_apdef_lower = YES
      }
      else if (parameter == "resize_obs_upper"){
        apdef_upper = real(parametervalue)
        print ("stall: Setting apdef_upper (=resize_obs_upper) to "//apdef_upper)
        if (loglevel > 2)
          print ("stall: Setting apdef_upper (=resize_obs_upper) to "//apdef_upper, >> logfile)
        found_apdef_upper = YES
      }
      else if (parameter == "apdefb_low_reject"){
        apdefb_low_reject = real(parametervalue)
        print ("stall: Setting "//parameter//" to "//apdefb_low_reject)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdefb_low_reject, >> logfile)
        found_apdefb_low_reject = YES
      }
      else if (parameter == "apdefb_high_reject"){
        apdefb_high_reject = real(parametervalue)
        print ("stall: Setting "//parameter//" to "//apdefb_high_reject)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdefb_high_reject, >> logfile)
        found_apdefb_high_reject = YES
      }
      else if (parameter == "apdefb_grow"){
        apdefb_grow = real(parametervalue)
        print ("stall: Setting "//parameter//" to "//apdefb_grow)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdefb_grow, >> logfile)
        found_apdefb_grow = YES
      }
      else if (parameter == "apdef_apidtable"){
        if (parametervalue == "-")
          apdef_apidtable = ""
        else
          apdef_apidtable = parametervalue
        print ("stall: Setting "//parameter//" to "//apdef_apidtable)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdef_apidtable, >> logfile)
        found_apdef_apidtable = YES
      }
      else if (parameter == "apdefb_function"){
        apdefb_function = parametervalue
        print ("stall: Setting "//parameter//" to "//apdefb_function)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdefb_function, >> logfile)
        found_apdefb_function = YES
      }
      else if (parameter == "apdefb_sample"){
        apdefb_sample = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_apdefb_sample = YES
      }
      else if (parameter == "apdefb_samplebuf"){
        apdefb_samplebuf = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//apdefb_samplebuf)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdefb_samplebuf, >> logfile)
        found_apdefb_samplebuf = YES
      }
      else if (parameter == "apdefb_order"){
        apdefb_order = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//apdefb_order)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdefb_order, >> logfile)
        found_apdefb_order = YES
      }
      else if (parameter == "apdefb_naverage"){
        apdefb_naverage = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//apdefb_naverage)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdefb_naverage, >> logfile)
        found_apdefb_naverage = YES
      }
      else if (parameter == "apdefb_niterate"){
        apdefb_niterate = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//apdefb_niterate)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdefb_niterate, >> logfile)
        found_apdefb_niterate = YES
      }
      else if (parameter == "calc_error_propagation"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          doerrors = YES
          print ("stall: Setting doerrors to YES")
          if(loglevel > 2)
            print ("stall: Setting doerrors to YES", >> logfile)
        }
        else{
          doerrors = NO
          print ("stall: Setting doerrors to NO")
          if(loglevel > 2)
            print ("stall: Setting doerrors to NO", >> logfile)
        }
        found_calc_error_propagation = YES
      }
      else if (parameter == "nflat_subscatter"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          nflat_subscatter = YES
          print ("stall: Setting nflat_subscatter to YES")
          if(loglevel > 2)
            print ("stall: Setting nflat_subscatter to YES", >> logfile)
        }
        else{
          nflat_subscatter = NO
          print ("stall: Setting nflat_subscatter to NO")
          if(loglevel > 2)
            print ("stall: Setting flat_subscatter to NO", >> logfile)
        }
        found_nflat_subscatter = YES
      }
      else if (parameter == "blaze_divbyfilter"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          blaze_divbyfilter = YES
          print ("stall: Setting blaze_divbyfilter to YES")
          if(loglevel > 2)
            print ("stall: Setting blaze_divbyfilter to YES", >> logfile)
        }
        else{
          blaze_divbyfilter = NO
          print ("stall: Setting blaze_divbyfilter to NO")
          if(loglevel > 2)
            print ("stall: Setting blaze_divbyfilter to NO", >> logfile)
        }
        found_blaze_divbyfilter = YES
      }
      else if (parameter == "ext_clean"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          ext_clean = YES
          print ("stall: Setting ext_clean to YES")
          if(loglevel > 2)
            print ("stall: Setting ext_clean to YES", >> logfile)
        }
        else{
          ext_clean = NO
          print ("stall: Setting ext_clean to NO")
          if(loglevel > 2)
            print ("stall: Setting ext_clean to NO", >> logfile)
        }
        found_ext_clean = YES
      }
      else if (parameter == "ext_weights"){
        ext_weights = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ext_weights = YES
      }
      else if (parameter == "ext_pfit"){
        ext_pfit = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ext_pfit = YES
      }
      else if (parameter == "ext_iter_telluric"){
        ext_iter_telluric = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//ext_iter_telluric)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//ext_iter_telluric, >> logfile)
        found_ext_iter_telluric = YES
      }
#      else if (parameter == "ext_iter_MkSkyErrIm"){
#        if (parametervalue == "YES" || parametervalue == "yes"){
#          ext_iter_MkSkyErrIm = YES
#          print ("stall: Setting ext_iter_MkSkyErrIm to YES")
#          if(loglevel > 2)
#            print ("stall: Setting ext_iter_MkSkyErrIm to YES", >> logfile)
#        }
#        else{
#          ext_iter_MkSkyErrIm = NO
#          print ("stall: Setting ext_iter_MkSkyErrIm to NO")
#          if(loglevel > 2)
#            print ("stall: Setting ext_iter_MkSkyErrIm to NO", >> logfile)
#        }
#        found_ext_iter_MkSkyErrIm = YES
#      }
      else if (parameter == "ext_iter_MkSPFitIm"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          ext_iter_MkSPFitIm = YES
          print ("stall: Setting ext_iter_MkSPFitIm to YES")
          if(loglevel > 2)
            print ("stall: Setting ext_iter_MkSPFitIm to YES", >> logfile)
        }
        else{
          ext_iter_MkSPFitIm = NO
          print ("stall: Setting ext_iter_MkSPFitIm to NO")
          if(loglevel > 2)
            print ("stall: Setting ext_iter_MkSPFitIm to NO", >> logfile)
        }
        found_ext_iter_MkSPFitIm = YES
      }
    }
    if (!found_calc_error_propagation){
      print("stall: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_log_level){
      print("stall: WARNING: parameter log_level not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter log_level not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter log_level not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_observatory){
      print("stall: WARNING: parameter observatory not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter observatory not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter observatory not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_setinst_instrument){
      print("stall: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_imtype){
      print("stall: WARNING: parameter imtype not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter imtype not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter imtype not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_spectral_features_tilted){
      print("stall: WARNING: parameter spectral_features_tilted not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter spectral_features_tilted not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter spectral_features_tilted not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_caldir){
      print("stall: WARNING: parameter caldir not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter caldir not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter caldir not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_extinct){
      print("stall: WARNING: parameter extinct not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter extinct not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter extinct not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_interp){
      print("stall: WARNING: parameter interp not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter interp not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter interp not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_dispaxis){
      print("stall: WARNING: parameter dispaxis not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter dispaxis not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter dispaxis not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_nsum){
      print("stall: WARNING: parameter nsum not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter nsum not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter nsum not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_ccdred_ssfile){
      print("stall: WARNING: parameter ccdred_ssfile not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter ccdred_ssfile not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter ccdred_ssfile not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_ccdred_graphic){
      print("stall: WARNING: parameter ccdred_graphic not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter ccdred_graphic not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter ccdred_graphic not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_onedspec_interp){
      print("stall: WARNING: parameter onedspec_interp not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter onedspec_interp not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter onedspec_interp not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_reference){
      print("stall: WARNING: parameter reference not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter reference not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter reference not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_ext_nsubaps){
      print("stall: WARNING: parameter ext_nsubaps not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter ext_nsubaps not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter ext_nsubaps not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_apdef_lower){
      print("stall: WARNING: parameter ext_lower not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter ext_lower not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter ext_lower not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_apdef_upper){
      print("stall: WARNING: parameter ext_upper not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter ext_upper not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter ext_upper not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_apdef_apidtable){
      print("stall: WARNING: parameter apdef_apidtable not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter apdef_apidtable not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter apdef_apidtable not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_nflat_subscatter){
      print("stall: WARNING: parameter nflat_subscatter not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter nflat_subscatter not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter nflat_subscatter not found in parameterfile!!! -> using standard value", >> warningfile)
    }
#    if (!found_apdefb_function){
#      print("stall: WARNING: parameter apdefb_function not found in parameterfile!!! -> using standard value")
#      print("stall: WARNING: parameter apdefb_function not found in parameterfile!!! -> using standard value", >> logfile)
#      print("stall: WARNING: parameter apdefb_function not found in parameterfile!!! -> using standard value", >> warningfile)
#    }
#    if (!found_apdefb_order){
#      print("stall: WARNING: parameter apdefb_order not found in parameterfile!!! -> using standard value")
#      print("stall: WARNING: parameter apdefb_order not found in parameterfile!!! -> using standard value", >> logfile)
#      print("stall: WARNING: parameter apdefb_order not found in parameterfile!!! -> using standard value", >> warningfile)
#    }
#    if (!found_apdefb_sample){
#      print("stall: WARNING: parameter apdefb_sample not found in parameterfile!!! -> using standard value")
#      print("stall: WARNING: parameter apdefb_sample not found in parameterfile!!! -> using standard value", >> logfile)
#      print("stall: WARNING: parameter apdefb_sample not found in parameterfile!!! -> using standard value", >> warningfile)
#    }
#    if (!found_apdefb_samplebuf){
#      print("stall: WARNING: parameter apdefb_samplebuf not found in parameterfile!!! -> using standard value")
#      print("stall: WARNING: parameter apdefb_samplebuf not found in parameterfile!!! -> using standard value", >> logfile)
#      print("stall: WARNING: parameter apdefb_samplebuf not found in parameterfile!!! -> using standard value", >> warningfile)
#    }
#    if (!found_apdefb_naverage){
#      print("stall: WARNING: parameter apdefb_naverage not found in parameterfile!!! -> using standard value")
#      print("stall: WARNING: parameter apdefb_naverage not found in parameterfile!!! -> using standard value", >> logfile)
#      print("stall: WARNING: parameter apdefb_naverage not found in parameterfile!!! -> using standard value", >> warningfile)
#    }
#    if (!found_apdefb_niterate){
#      print("stall: WARNING: parameter apdefb_niterate not found in parameterfile!!! -> using standard value")
#      print("stall: WARNING: parameter apdefb_niterate not found in parameterfile!!! -> using standard value", >> logfile)
#      print("stall: WARNING: parameter apdefb_niterate not found in parameterfile!!! -> using standard value", >> warningfile)
#    }
#    if (!found_apdefb_low_reject){
#      print("stall: WARNING: parameter apdefb_low_reject not found in parameterfile!!! -> using standard value")
#      print("stall: WARNING: parameter apdefb_low_reject not found in parameterfile!!! -> using standard value", >> logfile)
#      print("stall: WARNING: parameter apdefb_low_reject not found in parameterfile!!! -> using standard value", >> warningfile)
#    }
#    if (!found_apdefb_high_reject){
#      print("stall: WARNING: parameter apdefb_high_reject not found in parameterfile!!! -> using standard value")
#      print("stall: WARNING: parameter apdefb_high_reject not found in parameterfile!!! -> using standard value", >> logfile)
#      print("stall: WARNING: parameter apdefb_high_reject not found in parameterfile!!! -> using standard value", >> warningfile)
#    }
#    if (!found_apdefb_grow){
#      print("stall: WARNING: parameter apdefb_grow not found in parameterfile!!! -> using standard value")
#      print("stall: WARNING: parameter apdefb_grow not found in parameterfile!!! -> using standard value", >> logfile)
#      print("stall: WARNING: parameter apdefb_grow not found in parameterfile!!! -> using standard value", >> warningfile)
#    }
    if (!found_blaze_divbyfilter){
      print("stall: WARNING: parameter blaze_divbyfilter not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter blaze_divbyfilter not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter blaze_divbyfilter not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_ext_clean){
      print("stall: WARNING: parameter ext_clean not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter ext_clean not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter ext_clean not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_ext_weights){
      print("stall: WARNING: parameter ext_weights not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter ext_weights not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter ext_weights not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_ext_pfit){
      print("stall: WARNING: parameter ext_pfit not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter ext_pfit not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter ext_pfit not found in parameterfile!!! -> using standard value", >> warningfile)
    }
    if (!found_ext_iter_telluric){
      print("stall: WARNING: parameter ext_iter_telluric not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter ext_iter_telluric not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter ext_iter_telluric not found in parameterfile!!! -> using standard value", >> warningfile)
    }
#    if (!found_ext_iter_MkSkyErrIm){
#      print("stall: WARNING: parameter ext_iter_MkSkyErrIm not found in parameterfile!!! -> using standard value")
#      print("stall: WARNING: parameter ext_iter_MkSkyErrIm not found in parameterfile!!! -> using standard value", >> logfile)
#      print("stall: WARNING: parameter ext_iter_MkSkyErrIm not found in parameterfile!!! -> using standard value", >> warningfile)
#    }
    if (!found_ext_iter_MkSPFitIm){
      print("stall: WARNING: parameter ext_iter_MkSPFitIm not found in parameterfile!!! -> using standard value")
      print("stall: WARNING: parameter ext_iter_MkSPFitIm not found in parameterfile!!! -> using standard value", >> logfile)
      print("stall: WARNING: parameter ext_iter_MkSPFitIm not found in parameterfile!!! -> using standard value", >> warningfile)
    }

    print ("stall: **********************************************")
    if (loglevel > 2){
      print ("stall: **********************************************", >> logfile)
    }

  }
  else{
    print("stall: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters")
    print("stall: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters", >> logfile)
    print("stall: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters", >> warningfile)
  }

  if (dostmerge){
    doerrors = YES
    dostblaze = YES
  }

  combinedzero          = "combinedZero."//imtype
  combinedzero_bot      = "combinedZero_bot."//imtype
  combinedzero_e        = "combinedZero_e."//imtype
  combinedzero_sig      = "combinedZero_sig."//imtype
  combinedzero_sig_obt  = "combinedZero_sig_obt."//imtype
  combinedflat          = "combinedFlat."//imtype
  combinedflat_e        = "combinedFlat_e."//imtype
  combinedflat_s        = "combinedFlat_s."//imtype
  combinedflat_sig      = "combinedFlat_sig."//imtype
  normalizedflat        = "normalizedFlat."//imtype
  normalizedflat_e      = "normalizedFlat_e."//imtype

# --- set standard parameters
  if (loglevel > 2)
    print("stall: Setting standard parameters", >> logfile)

  noao.imred.keeplog  = imred_keeplog
  noao.imred.logfile  = logfile

  imred.ccdred.pixelty  = ccdred_pixeltype
  imred.ccdred.verbose  = ccdred_verbose
  imred.ccdred.logfile  = logfile
  imred.ccdred.plotfil  = ccdred_plotfile
  imred.ccdred.backup   = ccdred_backup
  imred.ccdred.instrum  = setinst_dir//setinst_site//"/"//setinst_instrument//".dat"
  imred.ccdred.ssfile   = ccdred_ssfile
  imred.ccdred.graphic  = ccdred_graphic
  imred.ccdred.cursor   = ccdred_cursor

  ccdred.setinstrument.instrument = setinst_instrument
  ccdred.setinstrument.site       = setinst_site
  ccdred.setinstrument.directo    = setinst_dir
  ccdred.setinstrument.review     = setinst_review
  ccdred.setinstrument.query      = setinst_instrument

  if (setinst_instrument == "echelle"){
    echelle
    imred.echelle.extinct = extinct
    imred.echelle.caldir  = caldir
    imred.echelle.observa = observatory
    imred.echelle.interp  = interp
    imred.echelle.dispaxi = dispaxis
    imred.echelle.nsum    = nsum
    imred.echelle.databas = database
    imred.echelle.verbose = verbose
    imred.echelle.logfile = logfile
    imred.echelle.plotfil = plotfile
    imred.echelle.records = records
  }
  else{
    kpnocoude
    kpnocoude.extinct = extinct
    kpnocoude.caldir  = caldir
    kpnocoude.observa = observatory
    kpnocoude.interp  = interp
    kpnocoude.dispaxi = dispaxis
    kpnocoude.nsum    = nsum
    kpnocoude.databas = database
    kpnocoude.verbose = verbose
    kpnocoude.logfile = logfile
    kpnocoude.plotfil = plotfile
    kpnocoude.records = records
  }
  apdefault.lower         = apdef_lower
  apdefault.upper         = apdef_upper
  apdefault.apidtable     = apdef_apidtable
  apdefault.b_function    = apdefb_function
  apdefault.b_order       = apdefb_order
  apdefault.b_sample      = apdefb_sample
#apdef_lower-apdefb_samplebuf//":"//apdef_lower//","//apdef_upper//":"//(apdef_upper+apdefb_samplebuf)
  print("stall: Setting apdefault.b_sample to "//apdefault.b_sample)
  if (loglevel > 2){
    print("stall: Setting apdefault.b_sample to "//apdefault.b_sample, >> logfile)
  }
  apdefault.b_naverage    = apdefb_naverage
  apdefault.b_niterate    = apdefb_niterate
  apdefault.b_low_reject  = apdefb_low_reject
  apdefault.b_high_reject = apdefb_high_reject
  apdefault.b_grow        = apdefb_grow

  noao.onedspec.observatory  = observatory
  noao.onedspec.caldir       = caldir
  noao.onedspec.interp       = onedspec_interp
  noao.onedspec.dispaxis     = dispaxis
  noao.onedspec.nsum         = nsum
  noao.onedspec.records      = records

  keep

# --- Erzeugen von temporaeren Filenamen
  print("stall: building temp-filenames")
  if (loglevel > 2)
    print("stall: building temp-filenames", >> logfile)
  infile       = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stall: building lists from temp-files")
  if (loglevel > 2)
    print("stall: building lists from temp-files", >> logfile)

  if (substr(images,1,1) == "@")
    images = substr(images,2,strlen(images))
  if (!access(images)){
    print("stall: ERROR: images <"// images //"> not found!!!")
    print("stall: ERROR: images <"// images //"> not found!!!", >> logfile)
    print("stall: ERROR: images <"// images //"> not found!!!", >> errorfile)
    print("stall: ERROR: images <"// images //"> not found!!!", >> warningfile)
# --- clean up
    inimages = ""
    delete (infile, ver-, >& "dev$null")
    return
  }
  sections("@"//images, option="root", > infile)
  inimages = infile

# --- build new lists
  print("stall: building new lists")
  if (loglevel > 2)
    print("stall: building new lists", >> logfile)
  while ( fscan( inimages, in ) != EOF){
    if (!access(in)){
      print("stall : WARNING: Cannot access input image <"//in//">")
      print("stall : WARNING: Cannot access input image <"//in//">", >> logfile)
      print("stall : WARNING: Cannot access input image <"//in//">", >> warningfile)
    }
    slashpos = 0
    for (j=1;j<strlen(in);j+=1){
      if (substr(in,j,j) == "/")
        slashpos = j
    }
    if (slashpos > 0){
      if (access(tempinfile))
        del(tempinfile, ver-)
      print(substr(in,slashpos+1,strlen(in)))
      print(substr(in,slashpos+1,strlen(in)), >> tempinfile)
    }
  }
  inimages = infile
  while ( fscan( inimages, in ) != EOF){
    if (loglevel > 2)
      print("stall: in = "// in)
  # --- flats
    slashpos = 0
    for (j=1;j<strlen(in);j+=1){
      if (substr(in,j,j) == "/")
        slashpos = j
    }
    if (directory == ""){
      if (slashpos > 0){
        directory = substr(in,1,slashpos)
        print("stall: changing directory to "//directory)
        if (loglevel > 2)
          print("stall: changing directory to "//directory, >> logfile)
        if (access(directory//images))
          del(directory//images, ver-)
        copy(in=tempinfile, output=directory//images, ver-)
        if (access(directory//logfile))
          del(directory//logfile, ver-)
        copy(in=logfile, output=directory//logfile, ver-)
        if (access(directory//warningfile))
          del(directory//warningfile)
        if (access(warningfile)){
          copy(in=warningfile, out=directory//warningfile, ver-)
          del(warningfile, ver-)
        }
        if (access(directory//errorfile))
          del(directory//errorfile, ver-)
        if (access(errorfile)){
          copy(in=errorfile, out=directory//errorfile, ver-)
          del(errorfile, ver-)
# --- clean up
          inimages = ""
          delete (infile, ver-, >& "dev$null")
          return
        }
        chdir (directory)
        if (loglevel > 2){
          print("stall: directory changed to ", >> logfile)
          pwd(, >> logfile)
        }
      }
    }
    if (!oldlogsdeleted){
# --- delete old lists
      print("stall: deleting old lists")
      if ( loglevel > 2)
        print("stall: deleting old lists", >> logfile)
      if ( access( objects_list ))
        delete(files=objects_list, ver-)
      if ( access( objects_bot_list ))
        delete(files=objects_bot_list, ver-)
      if ( access( objects_bot_errlist ))
        delete(files=objects_bot_errlist, ver-)
      if ( access( calibs_list ))
        delete(files=calibs_list, ver-)
      if ( access( combinedzerolist ))
        delete(files=combinedzerolist, ver-)
      if (docalibs){
        print(combinedzero, >> combinedzerolist)
        print("stall: writing "//combinedzero//" to combinedzerolist "//combinedzerolist, >> logfile)
      }
      if ( access( flats_list ))
        delete(files=flats_list, ver-)
      if ( access( zerolist ))
        delete(files=zerolist, ver-)
      if ( access( zeroerrlist ))
        delete(files=zeroerrlist, ver-)
      if ( access( subzerolist ))
        delete(files=subzerolist, ver-)
      if ( access( objects_botzf_list ))
        delete(files=objects_botzf_list, ver-)
      if ( access( cosmicerrlist ))
        delete(files=cosmicerrlist, ver-)
      if ( access( subscattercalibslist ))
        delete(files=subscattercalibslist, ver-)
      if ( access( subscatterobjectslist ))
        delete(files=subscatterobjectslist, ver-)
      if ( access( subscatterflatslist ))
        delete(files=subscatterflatslist, ver-)
      if (docalibs){
        print(combinedflat, >> subscatterflatslist)
        print("stall : writing "//combinedflat//" to subscatterflatslist "//subscatterflatslist, >> logfile)
      }
      if ( access( flatlist ))
        delete(files=flatlist, ver-)
      if ( access( flaterrlist ))
        delete(files=flaterrlist, ver-)
      if ( access( divflatlist ))
        delete(files=divflatlist, ver-)
      if ( access( extractcalibslist ))
        delete(files=extractcalibslist, ver-)
#      if ( access( extractcalibserrlist ))
#        delete(files=extractcalibserrlist, ver-)
      if ( access( to_merge_list )){
        delete(files=to_merge_list, ver-)
        print("stall: old to_merge_list <"//to_merge_list//"> deleted")
        print("stall: old to_merge_list <"//to_merge_list//"> deleted", >> logfile)
      }
      if ( access( to_merge_err_list ))
        delete(files=to_merge_err_list, ver-)
      if ( access( fix_curvature_list ))
        delete(files=fix_curvature_list, ver-)
      if ( access( calibsEc_list ))
        delete(files=calibsEc_list, ver-)
      if ( access( objects_botzfxs_list ))
        delete(files=objects_botzfxs_list, ver-)
      if ( access( objects_botzfxs_err_list ))
        delete(files=objects_botzfxs_err_list, ver-)
      if ( access( objects_botzfxsEc_list ))
        delete(files=objects_botzfxsEc_list, ver-)
      if ( access( objects_botzfxsEc_err_list ))
        delete(files=objects_botzfxsEc_err_list, ver-)
      if ( access( objects_botzfxsEcd_list ))
        delete(files=objects_botzfxsEcd_list, ver-)
      if ( access( objects_botzfxsEcd_err_list ))
        delete(files=objects_botzfxsEcd_err_list, ver-)
      if ( access( objects_botzfxsEcdc_list ))
        delete(files=objects_botzfxsEcdc_list, ver-)
      if ( access( objects_botzfxsEcdc_err_list ))
        delete(files=objects_botzfxsEcdc_err_list, ver-)
      if ( access( dispcor_list ))
        delete(files=dispcor_list, ver-)
      if ( access( dispcor_err_list ))
        delete(files=dispcor_err_list, ver-)
      if ( access( blazelist ))
        delete(files=blazelist, ver-)
      if ( access( blazeerrlist ))
        delete(files=blazeerrlist, ver-)
      if ( access( objects_botzfxsEcBl_list ))
        delete(files=objects_botzfxsEcBl_list, ver-)
      if ( access( objects_botzfxsEcBl_err_list ))
        delete(files=objects_botzfxsEcBl_err_list, ver-)
      if ( access( objects_botzfxsEcBld_list ))
        delete(files=objects_botzfxsEcBld_list, ver-)
      if ( access( objects_botzfxsEcBld_err_list ))
        delete(files=objects_botzfxsEcBld_err_list, ver-)
      if ( access( objects_botzfxsEcBldc_list ))
        delete(files=objects_botzfxsEcBldc_list, ver-)
      if ( access( objects_botzfxsEcBldc_err_list ))
        delete(files=objects_botzfxsEcBldc_err_list, ver-)
      if ( access( objects_botzfxsEcd_m_list ))
        delete(files=objects_botzfxsEcd_m_list, ver-)
      if ( access( objects_botzfxsEcd_m_err_list ))
        delete(files=objects_botzfxsEcd_m_err_list, ver-)
      if ( access( objects_botzfxsEcBldt_rb_m_list ))
        delete(files=objects_botzfxsEcBldt_rb_m_list, ver-)
      if ( access( objects_botzfxsEcBldt_rb_m_err_list ))
        delete(files=objects_botzfxsEcBldt_rb_m_err_list, ver-)
      if ( access( objects_botzfxsEcBldt_rb_mc_list ))
        delete(files=objects_botzfxsEcBldt_rb_mc_list, ver-)
      if ( access( objects_botzfxsEcBldt_rb_mc_err_list ))
        delete(files=objects_botzfxsEcBldt_rb_mc_err_list, ver-)
      if ( access( combine_list ))
        delete(files=combine_list, ver-)
      if ( access( combine_err_list ))
        delete(files=combine_err_list, ver-)
      if ( access( objects_botzfxsEcdt_list ))
        delete(files=objects_botzfxsEcdt_list, ver-)
      if ( access( objects_botzfxsEcdt_err_list ))
        delete(files=objects_botzfxsEcdt_err_list, ver-)
      oldlogsdeleted = YES
    }
    print("stall: in = "//in//", strlen(in)="//strlen(in)//", slashpos="//slashpos)
    if (loglevel > 2)
      print("stall: in = "//in//", strlen(in)="//strlen(in)//", slashpos="//slashpos, >> logfile)
    inname = substr(in,slashpos+1,strlen(in))
#-slashpos)
    print("stall: inname = "// inname)
    if (loglevel > 2)
      print("stall: inname = "// inname, >> logfile)
    strlastpos(inname, ".")
    lastpointpos = strlastpos.pos
    if (lastpointpos == 0)
      lastpointpos = strlen(inname)+1
    imnameroot = substr(inname, 1, lastpointpos-1)

    if ( substr(inname, 1, 4) == "flat" || substr(inname, 1, 4) == "Flat" || substr(inname, 1, 4) == "FLAT" || substr(inname, 1, 9) == "LAMP-FLAT" || substr(inname, 1, 8) == "LAMPFLAT" || substr(inname, 1, 7) == "skyflat" || substr(inname, 1, 7) == "Qtzflat"){
      if (docalibs){
        print(inname, >> flats_list)
        print("stall: writing "//inname//" >> flats_list", >> logfile)
        print(imnameroot//"_bot."//imtype, >> subzerolist)
        print("stall: writing "//imnameroot//"_bot."//imtype//" to "//subzerolist, >> logfile)
        print(imnameroot//"_botz."//imtype, >> flatlist)
        print("stall: writing "//imnameroot//"_botz."//imtype//" to "//flatlist, >> logfile)
      }
    }
  # --- biases
    else if (substr(inname, 1, 4) == "bias" || substr(inname, 1, 4) == "Bias" || substr(inname, 1, 4) == "BIAS"){
      if (docalibs){
        print(inname, >> zerolist)
        print(inname," >> zerolist", >> logfile)
        print(imnameroot//"_e."//imtype, >> zeroerrlist)
        print("stall: writing "//imnameroot//"_e."//imtype//" to "//zeroerrlist, >> logfile)
      }
    }
  # --- calibs
    else if (substr(inname,1,4)=="thar" || substr(inname,1,4)=="Thar" || substr(inname,1,4)=="ThAr" || substr(inname,1,4)=="THAR" || substr(inname,1,9)=="LAMP-WAVE" || substr(inname,1,9)=="LAMP_WAVE" || substr(inname,1,8)=="LAMPWAVE" || substr(inname,1,7)=="refThAr" || substr(inname,1,7)=="refThar" || substr(inname,1,5)=="calib" || substr(inname,1,5)=="Calib" || substr(inname,1,5)=="CALIB" || substr(inname,1,4)=="WAVE" || substr(inname,1,3)=="arc" || substr(inname,1,4)=="NeAr"){
      if (docalibs){
        print(inname, >> calibs_list)
        print("stall: writing "//inname//" to "//calibs_list, >> logfile)
        print(imnameroot//"_bot."//imtype, >> subzerolist)
        print("stall: writing "//imnameroot//"_bot."//imtype//" to "//subzerolist, >> logfile)
        print(imnameroot//"_botzf."//imtype, >> subscattercalibslist)
        print("stall: writing "//imnameroot//"_botzf."//imtype//" to "//subscattercalibslist, >> logfile)
        print(imnameroot//"_botz."//imtype, >> divflatlist)
        print("stall: writing "//imnameroot//"_botz."//imtype//" to "//divflatlist, >> logfile)
        print(imnameroot//"_botzfs."//imtype, >> fix_curvature_list)
        print("stall: writing "//imnameroot//"_botzfs."//imtype//" to "//fix_curvature_list, >> logfile)
        print(imnameroot//"_botzfs."//imtype, >> extractcalibslist)
        print("stall: writing "//imnameroot//"_botzfs."//imtype//" to "//extractcalibslist, >> logfile)
        print(imnameroot//"_botzfsEc."//imtype, >> calibsEc_list)
        print("stall: writing "//imnameroot//"_botzfsEc."//imtype//" to "//calibsEc_list, >> logfile)
        if (setinst_instrument == "echelle"){
          if (ext_nsubaps != 1){
            for (i = 1; i <= ext_nsubaps; i += 1){
              ApNoStr = ""
              if (ext_nsubaps > 99 && i < 100)
                ApNoStr = "0"
              if (ext_nsubaps > 9 && i < 10)
                ApNoStr = ApNoStr//"0"
              ApNoStr = ApNoStr//i
              strlastpos(calibsEc_list,".")
              templist = substr(calibsEc_list,1,strlastpos.pos-1)//ApNoStr//".list"
              if (firstcalib && access(templist))
                del(templist, ver-)
              print(imnameroot//"_botzfsEc"//ApNoStr//"."//imtype, >> templist)
              print("stall: writing "//imnameroot//"_botzfsEc"//ApNoStr//"."//imtype//" to "//templist, >> logfile)
            }
          }
        }# end if (setinst_instrument == "echelle")
        else{
          if (ext_nsubaps == 1){
            print(imnameroot//"_botzfsEc.0001."//imtype, >> calibsEc_list)
            print("stall: writing "//imnameroot//"_botzfsEc.0001."//imtype//" to "//calibsEc_list, >> logfile)
          }
          else{
            for (i = 1; i <= ext_nsubaps; i += 1){
              ApNoStr = ""
              if (ext_nsubaps > 99 && i < 100)
                ApNoStr = "0"
              if (ext_nsubaps > 9 && i < 10)
                ApNoStr = ApNoStr//"0"
              ApNoStr = ApNoStr//i
              print(imnameroot//"_botzfsEc."//ApNoStr//"001."//imtype, >> calibsEc_list)
              print("stall: writing "//imnameroot//"_botzfsEc."//ApNoStr//"001."//imtype//" to "//calibsEc_list, >> logfile)
              strlastpos(calibsEc_list,".")
              templist = substr(calibsEc_list,1,strlastpos.pos-1)//ApNoStr//".list"
              if (firstcalib && access(templist))
                del(templist, ver-)
              print(imnameroot//"_botzfsEc."//ApNoStr//"001."//imtype, >> templist)
              print("stall: writing "//imnameroot//"_botzfsEc."//ApNoStr//"001."//imtype//" to "//templist, >> logfile)
            }
          }
        }# end if (setinst_instrument != "echelle"){
        firstcalib = NO
      }
    }
  # --- objects
    else{   # objects
      print(inname, >> objects_list)
      print("stall: writing "//inname//" to "//objects_list, >> logfile)
      print(substr(inname, 1, strlastpos.pos-1)//"_bot."//imtype, >> objects_bot_list)
      print("stall: writing "//imnameroot//"_bot."//imtype//" to "//objects_bot_list, >> logfile)
      print(imnameroot//"_err_obt."//imtype, >> objects_bot_errlist)
      print("stall: writing "//imnameroot//"_err_obt."//imtype//" to "//objects_bot_errlist, >> logfile)
      print(imnameroot//"_botzfx."//imtype,  >> subscatterobjectslist)
      print("stall: writing "//imnameroot//"_botzfx."//imtype//" to "//subscatterobjectslist, >> logfile)
      print(imnameroot//"_botz."//imtype, >> divflatlist)
      print("stall: writing "//imnameroot//"_botz."//imtype//" to "//divflatlist, >> logfile)
      print(imnameroot//"_botzf."//imtype,   >> objects_botzf_list)
      print("stall: writing "//imnameroot//"_botzf."//imtype//" to "//objects_botzf_list, >> logfile)
      print(imnameroot//"_err_obtz."//imtype,   >> cosmicerrlist)
      print("stall: writing "//imnameroot//"_err_obtz."//imtype//" to "//cosmicerrlist, >> logfile)
      print(imnameroot//"_botzfxs."//imtype, >> fix_curvature_list)
      print("stall: writing "//imnameroot//"_botzfxs."//imtype//" to "//fix_curvature_list, >> logfile)
      print(imnameroot//"_botzfxs."//imtype, >> objects_botzfxs_list)
      print("stall: writing "//imnameroot//"_botzfxs."//imtype//" to "//objects_botzfxs_list, >> logfile)
      print(imnameroot//"_err_obtzx."//imtype, >> fix_curvature_list)
      print("stall: writing "//imnameroot//"_err_botzx."//imtype//" to "//fix_curvature_list, >> logfile)
      print(imnameroot//"_err_obtzx."//imtype, >> objects_botzfxs_err_list)
      print("stall: writing "//imnameroot//"_err_botzx."//imtype//" to "//objects_botzfxs_err_list, >> logfile)
      print(imnameroot//"_botzfxsEc."//imtype, >> blazelist)
      print("stall: writing "//imnameroot//"_botzfxsEc."//imtype//" to "//blazelist, >> logfile)
      print(imnameroot//"_err_obtzxEc."//imtype, >> blazeerrlist)
      print("stall: writing "//imnameroot//"_err_obtzxEc."//imtype//" to "//blazeerrlist, >> logfile)
      print(imnameroot//"_botzfxsEc."//imtype, >> dispcor_list)
      print("stall: writing "//imnameroot//"_botzfxsEc."//imtype//" to "//dispcor_list, >> logfile)
      print(imnameroot//"_err_obtzxEc."//imtype, >> dispcor_err_list)
      print("stall: writing "//imnameroot//"_err_obtzxEc."//imtype//" to "//dispcor_err_list, >> logfile)
      print(imnameroot//"_botzfxsEc."//imtype, >> objects_botzfxsEc_list)
      print("stall: writing "//imnameroot//"_botzfxsEc."//imtype//" to "//objects_botzfxsEc_list, >> logfile)
      print(imnameroot//"_err_obtzxEc."//imtype, >> objects_botzfxsEc_err_list)
      print("stall: writing "//imnameroot//"_err_obtzxEc."//imtype//" to "//objects_botzfxsEc_err_list, >> logfile)
      print(imnameroot//"_botzfxsEcBl."//imtype, >> dispcor_list)
      print("stall: writing "//imnameroot//"_botzfxsEcBl."//imtype//" to "//dispcor_list, >> logfile)
      print(imnameroot//"_err_obtzxEcBl."//imtype, >> dispcor_err_list)
      print("stall: writing "//imnameroot//"_err_obtzxEcBl."//imtype//" to "//dispcor_err_list, >> logfile)
      print(imnameroot//"_botzfxsEcBl."//imtype, >> objects_botzfxsEcBl_list)
      print("stall: writing "//imnameroot//"_botzfxsEcBl."//imtype//" to "//objects_botzfxsEcBl_list, >> logfile)
      print(imnameroot//"_err_obtzxEcBl."//imtype, >> objects_botzfxsEcBl_err_list)
      print("stall: writing "//imnameroot//"_err_obtzxEcBl."//imtype//" to "//objects_botzfxsEcBl_err_list, >> logfile)
      if ((ext_clean || ext_weights=="variance") && ext_pfit=="iterate" && ext_iter_telluric > 0){
        print(imnameroot//"_botzfxsSkyEc."//imtype, >> blazelist)
        print("stall: writing "//imnameroot//"_botzfxsSkyEc."//imtype//" to "//blazelist, >> logfile)
        print(imnameroot//"_botzfxsSkyEc."//imtype, >> dispcor_list)
        print("stall: writing "//imnameroot//"_botzfxsSkyEc."//imtype//" to "//dispcor_list, >> logfile)
        print(imnameroot//"_botzfxsSkyEc."//imtype, >> objects_botzfxsEc_list)
        print("stall: writing "//imnameroot//"_botzfxsSkyEc."//imtype//" to "//objects_botzfxsEc_list, >> logfile)
        print(imnameroot//"_botzfxsSkyEcBl."//imtype, >> dispcor_list)
        print("stall: writing "//imnameroot//"_botzfxsSkyEcBl."//imtype//" to "//dispcor_list, >> logfile)
        print(imnameroot//"_botzfxsSkyEcBl."//imtype, >> objects_botzfxsEcBl_list)
        print("stall: writing "//imnameroot//"_botzfxsSkyEcBl."//imtype//" to "//objects_botzfxsEcBl_list, >> logfile)
#        if (ext_iter_MkSkyErrIm){
          print(imnameroot//"_botzfxsSkyErrEc."//imtype, >> blazeerrlist)
          print("stall: writing "//imnameroot//"_botzfxsSkyErrEc."//imtype//" to "//blazeerrlist, >> logfile)
          print(imnameroot//"_botzfxsSkyErrEc."//imtype, >> dispcor_err_list)
          print("stall: writing "//imnameroot//"_botzfxsSkyErrEc."//imtype//" to "//dispcor_err_list, >> logfile)
          print(imnameroot//"_botzfxsSkyErrEc."//imtype, >> objects_botzfxsEc_err_list)
          print("stall: writing "//imnameroot//"_botzfxsSkyErrEc."//imtype//" to "//objects_botzfxsEc_err_list, >> logfile)
          print(imnameroot//"_botzfxsSkyErrEcBl."//imtype, >> dispcor_err_list)
          print("stall: writing "//imnameroot//"_botzfxsSkyErrEcBl."//imtype//" to "//dispcor_err_list, >> logfile)
          print(imnameroot//"_botzfxsSkyErrEcBl."//imtype, >> objects_botzfxsEcBl_err_list)
          print("stall: writing "//imnameroot//"_botzfxsSkyErrEcBl."//imtype//" to "//objects_botzfxsEcBl_err_list, >> logfile)
#        }
        if (ext_iter_MkSPFitIm){
          print(imnameroot//"_botzfxsFitEc."//imtype, >> blazelist)
          print("stall: writing "//imnameroot//"_botzfxsFitEc."//imtype//" to "//blazelist, >> logfile)
          print(imnameroot//"_botzfxsFitEc."//imtype, >> dispcor_list)
          print("stall: writing "//imnameroot//"_botzfxsFitEc."//imtype//" to "//dispcor_list, >> logfile)
          print(imnameroot//"_botzfxsFitEc."//imtype, >> objects_botzfxsEc_list)
          print("stall: writing "//imnameroot//"_botzfxsFitEc."//imtype//" to "//objects_botzfxsEc_list, >> logfile)
          print(imnameroot//"_err_obtzxEc."//imtype, >> blazeerrlist)
          print("stall: writing "//imnameroot//"_err_obtzxEc."//imtype//" to "//blazeerrlist, >> logfile)
          print(imnameroot//"_botzfxsFitEcBl."//imtype, >> dispcor_list)
          print("stall: writing "//imnameroot//"_botzfxsFitEcBl."//imtype//" to "//dispcor_list, >> logfile)
          print(imnameroot//"_botzfxsFitEcBl."//imtype, >> objects_botzfxsEcBl_list)
          print("stall: writing "//imnameroot//"_botzfxsFitEcBl."//imtype//" to "//objects_botzfxsEcBl_list, >> logfile)
          print(imnameroot//"_err_obtzxEc."//imtype, >> dispcor_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEc."//imtype//" to "//dispcor_err_list, >> logfile)
          print(imnameroot//"_err_obtzxEc."//imtype, >> objects_botzfxsEc_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEc."//imtype//" to "//objects_botzfxsEc_err_list, >> logfile)
          print(imnameroot//"_err_obtzxEcBl."//imtype, >> dispcor_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEcBl."//imtype//" to "//dispcor_err_list, >> logfile)
          print(imnameroot//"_err_obtzxEcBl."//imtype, >> objects_botzfxsEcBl_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEcBl."//imtype//" to "//objects_botzfxsEcBl_err_list, >> logfile)
        }
      }
      if (setinst_instrument == "echelle"){
        if (ext_nsubaps == 1){
          print(imnameroot//"_botzfxsEcd."//imtype, >> objects_botzfxsEcd_list)
          print("stall: writing "//imnameroot//"_botzfxsEcd."//imtype//" to "//objects_botzfxsEcd_list, >> logfile)
          print(imnameroot//"_err_obtzxEcd."//imtype, >> objects_botzfxsEcd_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEcd."//imtype//" to "//objects_botzfxsEcd_err_list, >> logfile)
          print(imnameroot//"_botzfxsEcdt."//imtype, >> objects_botzfxsEcdt_list)
          print("stall: writing "//imnameroot//"_botzfxsEcdt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
          print(imnameroot//"_botzfxsEcBld."//imtype, >> objects_botzfxsEcBld_list)
          print("stall: writing "//imnameroot//"_botzfxsEcBld."//imtype//" to "//objects_botzfxsEcBld_list, >> logfile)
          print(imnameroot//"_err_obtzxEcBld."//imtype, >> objects_botzfxsEcBld_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEcBld."//imtype//" to "//objects_botzfxsEcBld_err_list, >> logfile)
          print(imnameroot//"_botzfxsEcBldt."//imtype, >> objects_botzfxsEcdt_list)
          print("stall: writing "//imnameroot//"_botzfxsEcBldt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
          print(imnameroot//"_botzfxsEcBldtRbM."//imtype, >> objects_botzfxsEcBldt_rb_m_list)
          print("stall: writing "//imnameroot//"_botzfxsEcBldtRbM."//imtype//" to "//objects_botzfxsEcBldt_rb_m_list, >> logfile)
          print(imnameroot//"_err_obtzxEcBldtRbM."//imtype, >> objects_botzfxsEcBldt_rb_m_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEcBldtRbM."//imtype//" to "//objects_botzfxsEcBldt_rb_m_err_list, >> logfile)
          if ((ext_clean || ext_weights=="variance") && ext_pfit=="iterate" && ext_iter_telluric > 0){
            print(imnameroot//"_botzfxsSkyEcd."//imtype, >> objects_botzfxsEcd_list)
            print("stall: writing "//imnameroot//"_botzfxsSkyEcd."//imtype//" to "//objects_botzfxsEcd_list, >> logfile)
            print(imnameroot//"_botzfxsSkyEcdt."//imtype, >> objects_botzfxsEcdt_list)
            print("stall: writing "//imnameroot//"_botzfxsSkyEcdt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
            print(imnameroot//"_botzfxsSkyEcBld."//imtype, >> objects_botzfxsEcBld_list)
            print("stall: writing "//imnameroot//"_botzfxsSkyEcBld."//imtype//" to "//objects_botzfxsEcBld_list, >> logfile)
            print(imnameroot//"_botzfxsSkyEcBldt."//imtype, >> objects_botzfxsEcdt_list)
            print("stall: writing "//imnameroot//"_botzfxsSkyEcBldt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
            print(imnameroot//"_botzfxsSkyEcBldtRbM."//imtype, >> objects_botzfxsEcBldt_rb_m_list)
            print("stall: writing "//imnameroot//"_botzfxsSkyEcBldtRbM."//imtype//" to "//objects_botzfxsEcBldt_rb_m_list, >> logfile)
#            if (ext_iter_MkSkyErrIm){
              print(imnameroot//"_botzfxsSkyErrEcd."//imtype, >> objects_botzfxsEcd_err_list)
              print("stall: writing "//imnameroot//"_botzfxsSkyErrEcd."//imtype//" to "//objects_botzfxsEcd_err_list, >> logfile)
              print(imnameroot//"_botzfxsSkyErrEcBld."//imtype, >> objects_botzfxsEcBld_err_list)
              print("stall: writing "//imnameroot//"_botzfxsSkyErrEcBld."//imtype//" to "//objects_botzfxsEcBld_err_list, >> logfile)
              print(imnameroot//"_botzfxsSkyErrEcBldtRbM."//imtype, >> objects_botzfxsEcBldt_rb_m_err_list)
              print("stall: writing "//imnameroot//"_botzfxsSkyErrEcBldtRbM."//imtype//" to "//objects_botzfxsEcBldt_rb_m_err_list, >> logfile)
#            }
            if (ext_iter_MkSPFitIm){
              print(imnameroot//"_botzfxsFitEcd."//imtype, >> objects_botzfxsEcd_list)
              print("stall: writing "//imnameroot//"_botzfxsFitEcd."//imtype//" to "//objects_botzfxsEcd_list, >> logfile)
              print(imnameroot//"_err_obtzxEcd."//imtype, >> objects_botzfxsEcd_err_list)
              print("stall: writing "//imnameroot//"_err_obtzxEcd."//imtype//" to "//objects_botzfxsEcd_err_list, >> logfile)
              print(imnameroot//"_botzfxsFitEcdt."//imtype, >> objects_botzfxsEcdt_list)
              print("stall: writing "//imnameroot//"_botzfxsFitEcdt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
              print(imnameroot//"_botzfxsFitEcBld."//imtype, >> objects_botzfxsEcBld_list)
              print("stall: writing "//imnameroot//"_botzfxsFitEcBld."//imtype//" to "//objects_botzfxsEcBld_list, >> logfile)
              print(imnameroot//"_err_obtzxEcBld."//imtype, >> objects_botzfxsEcBld_err_list)
              print("stall: writing "//imnameroot//"_err_obtzxEcBld."//imtype//" to "//objects_botzfxsEcBld_err_list, >> logfile)
              print(imnameroot//"_botzfxsFitEcBldt."//imtype, >> objects_botzfxsEcdt_list)
              print("stall: writing "//imnameroot//"_botzfxsFitEcBldt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
              print(imnameroot//"_botzfxsFitEcBldtRbM."//imtype, >> objects_botzfxsEcBldt_rb_m_list)
              print("stall: writing "//imnameroot//"_botzfxsFitEcBldtRbM."//imtype//" to "//objects_botzfxsEcBldt_rb_m_list, >> logfile)
              print(imnameroot//"_err_obtzxEcBldtRbM."//imtype, >> objects_botzfxsEcBldt_rb_m_err_list)
              print("stall: writing "//imnameroot//"_err_obtzxEcBldtRbM."//imtype//" to "//objects_botzfxsEcBldt_rb_m_err_list, >> logfile)
            }
          }
        }# end if (ext_nsubaps == 1){
        else{
          tempobslist = imnameroot//"_botzfxsEcBldtRbM.list"
          print(tempobslist, >> combine_list)
          print("stall: writing "//tempobslist//" to "//combine_list, >> logfile)
          if (access(tempobslist))
            del(tempobslist, ver-)
          tempobserrlist = imnameroot//"_err_obtzxEcBldtRbM.list"
          print(tempobserrlist, >> combine_err_list)
          print("stall: writing "//tempobserrlist//" to "//combine_err_list, >> logfile)
          if (access(tempobserrlist))
            del(tempobserrlist, ver-)
          if (dostcontinuum){
            tempobslista = imnameroot//"_botzfxsEcBldtnRbM.list"
            print(tempobslista, >> combine_list)
            print("stall: writing "//tempobslista//" to "//combine_list, >> logfile)
            if (access(tempobslista))
              del(tempobslista, ver-)
            tempobserrlista = imnameroot//"_err_obtzxEcBldtnRbM.list"
            print(tempobserrlista, >> combine_err_list)
            print("stall: writing "//tempobserrlista//" to "//combine_err_list, >> logfile)
            if (access(tempobserrlista))
              del(tempobserrlista, ver-)
          }
          for (i = 1; i <= ext_nsubaps; i += 1){
            ApNoStr = ""
            if (ext_nsubaps > 99 && i < 100)
              ApNoStr = "0"
            if (ext_nsubaps > 9 && i < 10)
              ApNoStr = ApNoStr//"0"
            ApNoStr = ApNoStr//i
            strlastpos(dispcor_list,".")
            templist = substr(dispcor_list,1,strlastpos.pos-1)//ApNoStr//".list"
            if (firstobs && access(templist))
              del(templist, ver-)
            strlastpos(dispcor_err_list,".")
            temperrlist = substr(dispcor_err_list,1,strlastpos.pos-1)//ApNoStr//".list"
            if (firstobs && access(temperrlist))
              del(temperrlist, ver-)
            print(imnameroot//"_botzfxsEc"//ApNoStr//"."//imtype, >> templist)
            print("stall: writing "//imnameroot//"_botzfxsEc"//ApNoStr//"."//imtype//" to "//templist, >> logfile)
            print(imnameroot//"_err_obtzxEc"//ApNoStr//"."//imtype, >> temperrlist)
            print("stall: writing "//imnameroot//"_err_obtzxEc"//ApNoStr//"."//imtype//" to "//temperrlist, >> logfile)
            print(imnameroot//"_botzfxsEc"//ApNoStr//"d."//imtype, >> objects_botzfxsEcd_list)
            print("stall: writing "//imnameroot//"_botzfxsEc"//ApNoStr//"d."//imtype//" to "//objects_botzfxsEcd_list, >> logfile)
            print(imnameroot//"_err_obtzxEc"//ApNoStr//"d."//imtype, >> objects_botzfxsEcd_err_list)
            print("stall: writing "//imnameroot//"_err_obtzxEc"//ApNoStr//"d."//imtype//" to "//objects_botzfxsEcd_err_list, >> logfile)
            print(imnameroot//"_botzfxsEc"//ApNoStr//"BldtRbM."//imtype, >> tempobslist)
            print("stall: writing "//imnameroot//"_botzfxsEc"//ApNoStr//"BldtRbM."//imtype//" to "//tempobslist, >> logfile)
            print(imnameroot//"_err_obtzxEc"//ApNoStr//"BldtRbM."//imtype, >> tempobserrlist)
            print("stall: writing "//imnameroot//"_err_obtzxEc"//ApNoStr//"BldtRbM."//imtype//" to "//tempobserrlist, >> logfile)
            print(imnameroot//"_botzfxsEc"//ApNoStr//"BldtnRbM."//imtype, >> tempobslista)
            print("stall: writing "//imnameroot//"_botzfxsEc"//ApNoStr//"BldtnRbM."//imtype//" to "//tempobslista, >> logfile)
            print(imnameroot//"_err_obtzxEc"//ApNoStr//"BldtnRbM."//imtype, >> tempobserrlista)
            print("stall: writing "//imnameroot//"_err_obtzxEc"//ApNoStr//"BldtnRbM."//imtype//" to "//tempobserrlista, >> logfile)
            print(imnameroot//"_botzfxsEc"//ApNoStr//"dt."//imtype, >> objects_botzfxsEcdt_list)
            print("stall: writing "//imnameroot//"_botzfxsEc"//ApNoStr//"dt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
            print(imnameroot//"_botzfxsEc"//ApNoStr//"Bld."//imtype, >> objects_botzfxsEcBld_list)
            print("stall: writing "//imnameroot//"_botzfxsEc"//ApNoStr//"Bld."//imtype//" to "//objects_botzfxsEcBld_list, >> logfile)
            print(imnameroot//"_err_obtzxEc"//ApNoStr//"Bld."//imtype, >> objects_botzfxsEcBld_err_list)
            print("stall: writing "//imnameroot//"_err_obtzxEc"//ApNoStr//"Bld."//imtype//" to "//objects_botzfxsEcBld_err_list, >> logfile)
            print(imnameroot//"_botzfxsEc"//ApNoStr//"Bldt."//imtype, >> objects_botzfxsEcdt_list)
            print("stall: writing "//imnameroot//"_botzfxsEc"//ApNoStr//"Bldt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
          }# end for (i = 1; i <= ext_nsubaps; i += 1){
          print(imnameroot//"_botzfxsEcBldtRbMcom."//imtype, >> objects_botzfxsEcBldt_rb_mc_list)
          print("stall: writing "//imnameroot//"_botzfxsEcBldtRbMcom."//imtype//" to "//objects_botzfxsEcBldt_rb_mc_list, >> logfile)
          print(imnameroot//"_err_obtzxEcBldtRbMcom."//imtype, >> objects_botzfxsEcBldt_rb_mc_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEcBldtRbMcom."//imtype//" to "//objects_botzfxsEcBldt_rb_mc_err_list, >> logfile)
        }# end if (ext_nsubaps != 1){
      }# end if (setinst_instrument == "echelle"){
      else{
        if (ext_nsubaps == 1){

          print(imnameroot//"_botzfxsEc.0001d."//imtype, >> objects_botzfxsEcd_list)
          print("stall: writing "//imnameroot//"_botzfxsEc.0001d."//imtype//" to "//objects_botzfxsEcd_list, >> logfile)
          print(imnameroot//"_err_obtzxEc.0001d."//imtype, >> objects_botzfxsEcd_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEc.0001d."//imtype//" to "//objects_botzfxsEcd_err_list, >> logfile)
          print(imnameroot//"_botzfxsEc.0001dt."//imtype, >> objects_botzfxsEcdt_list)
          print("stall: writing "//imnameroot//"_botzfxsEc.0001dt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
          print(imnameroot//"_botzfxsEc.0001Bld."//imtype, >> objects_botzfxsEcBld_list)
          print("stall: writing "//imnameroot//"_botzfxsEc.0001Bld."//imtype//" to "//objects_botzfxsEcBld_list, >> logfile)
          print(imnameroot//"_err_obtzxEc.0001Bld."//imtype, >> objects_botzfxsEcBld_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEc.0001Bld."//imtype//" to "//objects_botzfxsEcBld_err_list, >> logfile)
          print(imnameroot//"_botzfxsEc.0001BldtRbM."//imtype, >> objects_botzfxsEcBldt_rb_m_list)
          print("stall: writing "//imnameroot//"_botzfxsEc.0001BldtRbM."//imtype//" to "//objects_botzfxsEcBldt_rb_m_list, >> logfile)
          print(imnameroot//"_err_obtzxEc.0001BldtRbM."//imtype, >> objects_botzfxsEcBldt_rb_m_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEc.0001BldtRbM."//imtype//" to "//objects_botzfxsEcBldt_rb_m_err_list, >> logfile)
          print(imnameroot//"_botzfxsEc.0001Bldt."//imtype, >> objects_botzfxsEcdt_list)
          print("stall: writing "//imnameroot//"_botzfxsEc.0001Bldt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
        }# end if (ext_nsubaps == 1){
        else{
          templist = imnameroot//"_botzfxsEcBldtRbM.list"
          print(templist, >> combine_list)
          print("stall: writing "//templist//" to "//combine_list, >> logfile)
          if (access(templist))
            del(templist, ver-)
          temperrlist = imnameroot//"_err_obtzxEcBldtRbM.list"
          print(temperrlist, >> combine_err_list)
          print("stall: writing "//temperrlist//" to "//combine_err_list, >> logfile)
          if (access(temperrlist))
            del(temperrlist, ver-)
          tempobslista = imnameroot//"_botzfxsEcBldtnRbM.list"
          print(tempobslista, >> combine_list)
          print("stall: writing "//tempobslista//" to "//combine_list, >> logfile)
          if (access(tempobslista))
            del(tempobslista, ver-)
          tempobserrlista = imnameroot//"_err_obtzxEcBldtnRbM.list"
          print(tempobserrlista, >> combine_err_list)
          print("stall: writing "//tempobserrlista//" to "//combine_err_list, >> logfile)
          if (access(tempobserrlista))
            del(tempobserrlista, ver-)
          for (i = 1; i <= ext_nsubaps; i += 1){
            ApNoStr = ""
            if (ext_nsubaps > 99 && i < 100)
              ApNoStr = "0"
            if (ext_nsubaps > 9 && i < 10)
              ApNoStr = ApNoStr//"0"
            ApNoStr = ApNoStr//i
            strlastpos(dispcor_list,".")
            templist = substr(dispcor_list,1,strlastpos.pos-1)//ApNoStr//".list"
            if (firstobs && access(templist))
              del(templist, ver-)
            strlastpos(dispcor_err_list,".")
            temperrlist = substr(dispcor_err_list,1,strlastpos.pos-1)//ApNoStr//".list"
            if (firstobs && access(temperrlist))
              del(temperrlist, ver-)
            print(imnameroot//"_botzfxsEc."//ApNoStr//"001."//imtype, >> templist)
            print("stall: writing "//imnameroot//"_botzfxsEc."//ApNoStr//"001."//imtype//" to "//templist, >> logfile)
            print(imnameroot//"_err_obtzxEc."//ApNoStr//"001."//imtype, >> temperrlist)
            print("stall: writing "//imnameroot//"_err_obtzxEc."//ApNoStr//"001."//imtype//" to "//temperrlist, >> logfile)
            print(imnameroot//"_botzfxsEc."//ApNoStr//"001d."//imtype, >> objects_botzfxsEcd_list)
            print("stall: writing "//imnameroot//"_botzfxsEc."//ApNoStr//"001d."//imtype//" to "//objects_botzfxsEcd_list, >> logfile)
            print(imnameroot//"_err_obtzxEc."//ApNoStr//"001d."//imtype, >> objects_botzfxsEcd_err_list)
            print("stall: writing "//imnameroot//"_err_obtzxEc."//ApNoStr//"001d."//imtype//" to "//objects_botzfxsEcd_err_list, >> logfile)
            print(imnameroot//"_botzfxsEc."//ApNoStr//"001BldtRbM."//imtype, >> templist)
            print("stall: writing "//imnameroot//"_botzfxsEc."//ApNoStr//"001BldtRbM."//imtype//" to "//templist, >> logfile)
            print(imnameroot//"_err_obtzxEc."//ApNoStr//"001BldtRbM."//imtype, >> temperrlist)
            print("stall: writing "//imnameroot//"_err_obtzxEc."//ApNoStr//"001BldtRbM."//imtype//" to "//temperrlist, >> logfile)
            print(imnameroot//"_botzfxsEc."//ApNoStr//"001BldtnRbM."//imtype, >> tempobslista)
            print("stall: writing "//imnameroot//"_botzfxsEc."//ApNoStr//"001BldtnRbM."//imtype//" to "//tempobslista, >> logfile)
            print(imnameroot//"_err_obtzxEc."//ApNoStr//"001BldtnRbM."//imtype, >> tempobserrlista)
            print("stall: writing "//imnameroot//"_err_obtzxEc."//ApNoStr//"001BldtnRbM."//imtype//" to "//tempobserrlista, >> logfile)
            print(imnameroot//"_botzfxsEc."//ApNoStr//"001dt."//imtype, >> objects_botzfxsEcdt_list)
            print("stall: writing "//imnameroot//"_botzfxsEc."//ApNoStr//"001dt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
            print(imnameroot//"_botzfxsEc."//ApNoStr//"001Bld."//imtype, >> objects_botzfxsEcBld_list)
            print("stall: writing "//imnameroot//"_botzfxsEc."//ApNoStr//"001Bld."//imtype//" to "//objects_botzfxsEcBld_list, >> logfile)
            print(imnameroot//"_err_obtzxEc."//ApNoStr//"001Bld."//imtype, >> objects_botzfxsEcBld_err_list)
            print("stall: writing "//imnameroot//"_err_obtzxEc."//ApNoStr//"001Bld."//imtype//" to "//objects_botzfxsEcBld_err_list, >> logfile)
            print(imnameroot//"_botzfxsEc."//ApNoStr//"001Bldt."//imtype, >> objects_botzfxsEcdt_list)
            print("stall: writing "//imnameroot//"_botzfxsEc."//ApNoStr//"001Bldt."//imtype//" to "//objects_botzfxsEcdt_list, >> logfile)
          }# end for (i = 1; i <= ext_nsubaps; i += 1){
          print(imnameroot//"_botzfxsEcBldtRbMcom."//imtype, >> objects_botzfxsEcBldt_rb_mc_list)
          print("stall: writing "//imnameroot//"_botzfxsEcBldtRbMcom."//imtype//" to "//objects_botzfxsEcBldt_rb_mc_list, >> logfile)
          print(imnameroot//"_err_obtzxEcBldtRbMcom."//imtype, >> objects_botzfxsEcBldt_rb_mc_err_list)
          print("stall: writing "//imnameroot//"_err_obtzxEcBldtRbMcom."//imtype//" to "//objects_botzfxsEcBldt_rb_mc_err_list, >> logfile)
        }# end if (ext_nsubaps != 1){
      }# end if (setinst_instrument != "echelle"){
      firstobs = NO
    }# end else if (objects)
  }# end while ( fscan( inimages, in ) != EOF){

# --- processing images
  refflat = ""
  refstring = ""
  print("stall: reference = "//reference)
  for(i=1;i<=strlen(reference);i=i+1){
    if (substr(reference,i,i) == "/")
      refstring = ""
    else
      refstring = refstring//substr(reference,i,i)
  }
  refflat = refstring
  if (substr(refflat,1,2) == "ap")
    refflat = substr(refflat,3,strlen(refflat))
  if (substr(refflat,strlen(refflat)-strlen(imtype),strlen(refflat)) == "."//imtype)
    refflat = substr(refflat,1,strlen(refflat)-5)
  print("stall: refflat = "//refflat, >> logfile)

# --- stprepare
  if (dostprepare){
    print("stall: running stprepare")
    print("stall: running stprepare", >> logfile)

    stprepare(ObjectsList   = "@"//objects_list,
	      CalibsList    = "@"//calibs_list,
              DoCalibs      = docalibs,
	      RefApObs      = refapObs,
	      RefApCalibs   = refapCalibs,
	      LogLevel      = loglevel,
	      ParameterFile = parameterfile,
	      LogFile       = logfile_stprepare,
	      WarningFile   = warningfile_stprepare,
	      ErrorFile     = errorfile_stprepare)
    if (access(logfile_stprepare))
      cat(logfile_stprepare, >> logfile)
    if (access(warningfile_stprepare))
      cat(warningfile_stprepare, >> warningfile)
    if (access(errorfile_stprepare)){
      cat(errorfile_stprepare, >> errorfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
  }

  flpr

# --- stzero
  if (docalibs){
    if (dostzero){
      print("stall: running stzero")
      print("stall: running stzero", >> logfile)

      stzero(biasimages    = "@"//zerolist,
             combinedzero  = combinedzero,
	     sigmaimage    = combinedzero_sig,
             loglevel      = loglevel,
             doerrors      = doerrors,
	     parameterfile = parameterfile,
	     delinput-,
	     logfile       = logfile_stzero,
	     warningfile   = warningfile_stzero,
	     errorfile     = errorfile_stzero)
      if (access(logfile_stzero))
        cat(logfile_stzero, >> logfile)
      if (access(warningfile_stzero))
        cat(warningfile_stzero, >> warningfile)
      if (access(errorfile_stzero)){
        cat(errorfile_stzero, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      if (stzero.Status == 0){
        print("stall: ERROR: stzero returned with error")
        print("stall: ERROR: stzero returned with error", >> logfile)
        print("stall: ERROR: stzero returned with error", >> warningfile)
        print("stall: ERROR: stzero returned with error", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }
    if (access(combinedzero)){
      print("stall: "//combinedzero//" ready")
      print("stall: "//combinedzero//" ready", >> logfile)
    }
    else{
      print("stall: ERROR: cannot access combinedzero <"//combinedzero//">!")
      print("stall: ERROR: cannot access combinedzero <"//combinedzero//">!", >> logfile)
      print("stall: ERROR: cannot access combinedzero <"//combinedzero//">!", >> warningfile)
      print("stall: ERROR: cannot access combinedzero <"//combinedzero//">!", >> errorfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    if (doerrors){
      if (access(combinedzero_sig)){
        print("stall: "//combinedzero_sig//" ready")
        print("stall: "//combinedzero_sig//" ready", >> logfile)
      }
      else{
        print("stall: ERROR: cannot access combinedzero_sig <"//combinedzero_sig//">!")
        print("stall: ERROR: cannot access combinedzero_sig <"//combinedzero_sig//">!", >> logfile)
        print("stall: ERROR: cannot access combinedzero_sig <"//combinedzero_sig//">!", >> warningfile)
        print("stall: ERROR: cannot access combinedzero_sig <"//combinedzero_sig//">!", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }
  }

  flpr

# --- stbadovertrim
  if (dostbadovertrim){
    print("stall: running stbadovertrim")
    print("stall: running stbadovertrim", >> logfile)
    if (!access(objects_list)){
      print("stall: WARNING: cannot access objects_list <"//objects_list//">!")
      print("stall: WARNING: cannot access objects_list <"//objects_list//">!", >> logfile)
      print("stall: WARNING: cannot access objects_list <"//objects_list//">!", >> warningfile)
#      print("stall: ERROR: cannot access objects_list <"//objects_list//">!", >> errorfile)
## --- clean up
#      inimages = ""
#      delete (infile, ver-, >& "dev$null")
#      return
    }
    if (access(objects_list)){
      stbadovertrim(Images        = "@"//objects_list,
                    Objects+,
                    Bias-,
                    LogLevel      = loglevel,
                    DoErrors      = doerrors,
                    ParameterFile = parameterfile,
                    LogFile       = logfile_stbadovertrim,
                    WarningFile   = warningfile_stbadovertrim,
                    ErrorFile     = errorfile_stbadovertrim)
      print("stall: stbadovertrim ready")
      if (access(logfile_stbadovertrim))
        cat(logfile_stbadovertrim, >> logfile)
      if (access(warningfile_stbadovertrim))
        cat(warningfile_stbadovertrim, >> warningfile)
      if (access(errorfile_stbadovertrim)){
        cat(errorfile_stbadovertrim, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      if (stbadovertrim.Status == 0){
        print("stall: ERROR: stbadovertrim returned with error")
        print("stall: ERROR: stbadovertrim returned with error", >> logfile)
        print("stall: ERROR: stbadovertrim returned with error", >> warningfile)
        print("stall: ERROR: stbadovertrim returned with error", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      print("stall: stbadovertrim ready")
      print("stall: stbadovertrim ready", >> logfile)
    }
    if (docalibs){
      if (!access(flats_list)){
        print("stall: ERROR: cannot access flats_list <"//flats_list//">!")
        print("stall: ERROR: cannot access flats_list <"//flats_list//">!", >> logfile)
        print("stall: ERROR: cannot access flats_list <"//flats_list//">!", >> warningfile)
        print("stall: ERROR: cannot access flats_list <"//flats_list//">!", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      stbadovertrim(Images        = "@"//flats_list,
                    Objects-,
                    Bias-,
                    LogLevel      = loglevel,
                    DoErrors      = doerrors,
                    ParameterFile = parameterfile,
                    LogFile       = logfile_stbadovertrim,
                    WarningFile   = warningfile_stbadovertrim,
                    ErrorFile     = errorfile_stbadovertrim)
      print("stall: stbadovertrim for flats ready")
      if (access(logfile_stbadovertrim))
        cat(logfile_stbadovertrim, >> logfile)
      if (access(warningfile_stbadovertrim))
        cat(warningfile_stbadovertrim, >> warningfile)
      if (access(errorfile_stbadovertrim)){
        cat(errorfile_stbadovertrim, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      if (stbadovertrim.Status == 0){
        print("stall: ERROR: stbadovertrim returned with error")
        print("stall: ERROR: stbadovertrim returned with error", >> logfile)
        print("stall: ERROR: stbadovertrim returned with error", >> warningfile)
        print("stall: ERROR: stbadovertrim returned with error", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      print("stall: stbadovertrim for flats ready")
      print("stall: stbadovertrim for flats sready", >> logfile)
      if (!access(calibs_list)){
        print("stall: ERROR: cannot access calibs_list <"//calibs_list//">!")
        print("stall: ERROR: cannot access calibs_list <"//calibs_list//">!", >> logfile)
        print("stall: ERROR: cannot access calibs_list <"//calibs_list//">!", >> warningfile)
        print("stall: ERROR: cannot access calibs_list <"//calibs_list//">!", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      stbadovertrim(Images        = "@"//calibs_list,
                    Objects-,
                    Bias-,
                    LogLevel      = loglevel,
                    DoErrors      = doerrors,
                    ParameterFile = parameterfile,
                    LogFile       = logfile_stbadovertrim,
                    WarningFile   = warningfile_stbadovertrim,
                    ErrorFile     = errorfile_stbadovertrim)
      print("stall: stbadovertrim for calibs ready")
      if (access(logfile_stbadovertrim))
        cat(logfile_stbadovertrim, >> logfile)
      if (access(warningfile_stbadovertrim))
        cat(warningfile_stbadovertrim, >> warningfile)
      if (access(errorfile_stbadovertrim)){
        cat(errorfile_stbadovertrim, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      if (stbadovertrim.Status == 0){
        print("stall: ERROR: stbadovertrim returned with error")
        print("stall: ERROR: stbadovertrim returned with error", >> logfile)
        print("stall: ERROR: stbadovertrim returned with error", >> warningfile)
        print("stall: ERROR: stbadovertrim returned with error", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      print("stall: stbadovertrim for calibs ready")
      print("stall: stbadovertrim for calib sready", >> logfile)
    }# end if (docalibs)
    if (!access(combinedzerolist)){
      print("stall: ERROR: cannot access combinedzerolist <"//combinedzerolist//">!")
      print("stall: ERROR: cannot access combinedzerolist <"//combinedzerolist//">!", >> logfile)
      print("stall: ERROR: cannot access combinedzerolist <"//combinedzerolist//">!", >> warningfile)
      print("stall: ERROR: cannot access combinedzerolist <"//combinedzerolist//">!", >> errorfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    if (docalibs){
      stbadovertrim(Images        = "@"//combinedzerolist,
                    Objects-,
                    Bias+,
                    BiasErrImage  = combinedzero_sig,
                    LogLevel      = loglevel,
                    DoErrors      = doerrors,
                    ParameterFile = parameterfile,
                    LogFile       = logfile_stbadovertrim,
                    WarningFile   = warningfile_stbadovertrim,
                    ErrorFile     = errorfile_stbadovertrim)
      print("stall: stbadovertrim for combinedZero ready")
      print("stall: stbadovertrim for combinedZero ready", >> logfile)
      if (access(logfile_stbadovertrim))
        cat(logfile_stbadovertrim, >> logfile)
      if (access(warningfile_stbadovertrim))
        cat(warningfile_stbadovertrim, >> warningfile)
      if (access(errorfile_stbadovertrim)){
        cat(errorfile_stbadovertrim, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      if (stbadovertrim.Status == 0){
        print("stall: ERROR: stbadovertrim returned with error")
        print("stall: ERROR: stbadovertrim returned with error", >> logfile)
        print("stall: ERROR: stbadovertrim returned with error", >> warningfile)
        print("stall: ERROR: stbadovertrim returned with error", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }
    print("stall: stbadovertrim ready")
    print("stall: stbadovertrim ready", >> logfile)
  }

  flpr

# --- stsubzero
  if (dostsubzero){
    print("stall: running stsubzero")
    print("stall: running stsubzero", >> logfile)
#  -- objects
    if (!access(objects_bot_list)){
      print("stall: WARNING: cannot access objects_bot_list <"//objects_bot_list//">!")
      print("stall: WARNING: cannot access objects_bot_list <"//objects_bot_list//">!", >> logfile)
      print("stall: WARNING: cannot access objects_bot_list <"//objects_bot_list//">!", >> warningfile)
#      print("stall: ERROR: cannot access objects_bot_list <"//objects_bot_list//">!", >> errorfile)
## --- clean up
#      inimages = ""
#      delete (infile, ver-, >& "dev$null")
#      return
    }
    else
    {
      stsubzero(Images        = "@"//objects_bot_list,
                Objects+,
                ErrorImages   = "@"//objects_bot_errlist,
                CombinedZero  = combinedzero_bot,
                ZeroErrImage  = combinedzero_sig_obt,
                DelInput      = delinputfiles,
                LogLevel      = loglevel,
                DoErrors      = doerrors,
                ParameterFile = parameterfile,
                LogFile       = logfile_stsubzero,
                WarningFile   = warningfile_stsubzero,
                ErrorFile     = errorfile_stsubzero)
      if (access(logfile_stsubzero))
        cat(logfile_stsubzero, >> logfile)
      if (access(warningfile_stsubzero))
        cat(warningfile_stsubzero, >> warningfile)
      if (access(errorfile_stsubzero)){
        cat(errorfile_stsubzero, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      if (stsubzero.Status == 0){
        print("stall: ERROR: stsubzero returned with error")
        print("stall: ERROR: stsubzero returned with error", >> logfile)
        print("stall: ERROR: stsubzero returned with error", >> warningfile)
        print("stall: ERROR: stsubzero returned with error", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      print("stall: stsubzero ready")
      print("stall: stsubzero ready", >> logfile)
    }
#  -- non objects
    if (docalibs){
      if (!access(subzerolist)){
        print("stall: ERROR: cannot access subzerolist <"//subzerolist//">!")
        print("stall: ERROR: cannot access subzerolist <"//subzerolist//">!", >> logfile)
        print("stall: ERROR: cannot access subzerolist <"//subzerolist//">!", >> warningfile)
        print("stall: ERROR: cannot access subzerolist <"//subzerolist//">!", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      stsubzero(Images      = "@"//subzerolist,
                Objects-,
                ErrorImages   = "",
                CombinedZero  = combinedzero_bot,
                ZeroErrImage  = combinedzero_sig_obt,
                DelInput      = delinputfiles,
                LogLevel      = loglevel,
                DoErrors      = doerrors,
                ParameterFile = parameterfile,
                LogFile       = logfile_stsubzero,
                WarningFile   = warningfile_stsubzero,
                ErrorFile     = errorfile_stsubzero)
      if (access(logfile_stsubzero))
        cat(logfile_stsubzero, >> logfile)
      if (access(warningfile_stsubzero))
        cat(warningfile_stsubzero, >> warningfile)
      if (access(errorfile_stsubzero)){
        cat(errorfile_stsubzero, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      if (stsubzero.Status == 0){
        print("stall: ERROR: stsubzero returned with error")
        print("stall: ERROR: stsubzero returned with error", >> logfile)
        print("stall: ERROR: stsubzero returned with error", >> warningfile)
        print("stall: ERROR: stsubzero returned with error", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }
    print("stall: stsubzero ready")
    print("stall: stsubzero ready", >> logfile)
  }

  flpr

# --- stflat
  if (docalibs){
    if (dostflat){
      print("stall: running stflat")
      print("stall: running stflat", >> logfile)
      if (!access(flatlist)){
        print("stall: ERROR: cannot access flatlist <"//flatlist//">!")
        print("stall: ERROR: cannot access flatlist <"//flatlist//">!", >> logfile)
        print("stall: ERROR: cannot access flatlist <"//flatlist//">!", >> warningfile)
        print("stall: ERROR: cannot access flatlist <"//flatlist//">!", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      stflat(FlatImages    = "@"//flatlist,
             CombinedFlat  = combinedflat,
             SigmaImage    = combinedflat_sig,
             DelInput      = delinputfiles,
             LogLevel      = loglevel,
             DoErrors      = doerrors,
             ParameterFile = parameterfile,
             LogFile       = logfile_stflat,
             WarningFile   = warningfile_stflat,
             ErrorFile     = errorfile_stflat)
      if (access(logfile_stflat))
        cat(logfile_stflat, >> logfile)
      if (access(warningfile_stflat))
        cat(warningfile_stflat, >> warningfile)
      if (access(errorfile_stflat)){
        cat(errorfile_stflat, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      if (stflat.Status == 0){
        print("stall: ERROR: stflat returned with error")
        print("stall: ERROR: stflat returned with error", >> logfile)
        print("stall: ERROR: stflat returned with error", >> warningfile)
        print("stall: ERROR: stflat returned with error", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }# end if (docalibs)
    if (access( combinedflat )){
      print("stall: "// combinedflat //" ready")
      print("stall: "// combinedflat //" ready", >> logfile)
    }
    else{
      print("stall: ERROR: cannot access combinedflat <"// combinedflat //">!")
      print("stall: ERROR: cannot access combinedflat <"// combinedflat //">!", >> logfile)
      print("stall: ERROR: cannot access combinedflat <"// combinedflat //">!", >> warningfile)
      print("stall: ERROR: cannot access combinedflat <"// combinedflat //">!", >> errorfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    if (doerrors){
      if (access(combinedflat_sig)){
        print("stall: "//combinedflat_sig//" ready")
        print("stall: "//combinedflat_sig//" ready", >> logfile)
      }
      else{
        print("stall: ERROR: cannot access combinedflat_sig <"//combinedflat_sig//">!")
        print("stall: ERROR: cannot access combinedflat_sig <"//combinedflat_sig//">!", >> logfile)
        print("stall: ERROR: cannot access combinedflat_sig <"//combinedflat_sig//">!", >> warningfile)
        print("stall: ERROR: cannot access combinedflat_sig <"//combinedflat_sig//">!", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }
  }

  flpr

# --- stnflat




######################################################################





  refBlaze = "combinedFlat_blaze.fits"
  if (docalibs){
    if (dostnflat){
      if (!access( combinedflat )){
        print("stall: ERROR: cannot access combinedflat <"// combinedflat //">!")
        print("stall: ERROR: cannot access combinedflat <"// combinedflat //">!", >> logfile)
        print("stall: ERROR: cannot access combinedflat <"// combinedflat //">!", >> warningfile)
        print("stall: ERROR: cannot access combinedflat <"// combinedflat //">!", >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      if (nflat_subscatter){
        print("stall: running stscatter for combinedFlat")
        print("stall: running stscatter for combinedFlat", >> logfile)

# --- load echelle package
        if (setinst_instrument == "kpnocoude")
          echelle
        stscatter(images        = "@"//subscatterflatslist,
                  reference     = refflat,
                  calib-,
                  object-,
                  delinput      = delinputfiles,
                  loglevel      = loglevel,
                  parameterfile = parameterfile,
                  logfile       = logfile_stscatter,
                  warningfile   = warningfile_stscatter,
                  errorfile     = errorfile_stscatter)
        if (access(logfile_stscatter))
          cat(logfile_stscatter, >> logfile)
        if (access(warningfile_stscatter))
          cat(warningfile_stscatter, >> warningfile)
        if (access(errorfile_stscatter)){
          cat(errorfile_stscatter, >> errorfile)
# --- clean up
          inimages = ""
          delete (infile, ver-, >& "dev$null")
          return
        }
        flpr
        if (access( combinedflat_s )){
          print("stall: "// combinedflat_s //" ready")
          print("stall: "// combinedflat_s //" ready", >> logfile)
        }
        else{
          print("stall: ERROR: cannot access combinedflat_s <"// combinedflat_s //">!")
          print("stall: ERROR: cannot access combinedflat_s <"// combinedflat_s //">!", >> logfile)
          print("stall: ERROR: cannot access combinedflat_s <"// combinedflat_s //">!", >> warningfile)
          print("stall: ERROR: cannot access combinedflat_s <"// combinedflat_s //">!", >> errorfile)
# --- clean up
          inimages = ""
          delete (infile, ver-, >& "dev$null")
          return
        }
      }
      else
        combinedflat_s = combinedflat
      print("stall: running stnflat")
      print("stall: running stnflat", >> logfile)
      stnflat(Input          = combinedflat_s,
              NormalizedFlat = normalizedflat,
              BlazeOut       = refBlaze,
              delInput       = delinputfiles,
              ParameterFile  = parameterfile,
              loglevel       = loglevel,
              logfile        = logfile_stnflat,
              warningfile    = warningfile_stnflat,
              errorfile      = errorfile_stnflat)
      if (access(logfile_stnflat))
        cat(logfile_stnflat, >> logfile)
      if (access(warningfile_stnflat))
        cat(warningfile_stnflat, >> warningfile)
      if (access(errorfile_stnflat)){
        cat(errorfile_stnflat, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }# end if (dostnflat)
  }# end if (docalibs)
  if (access( normalizedflat )){
    print("stall: "// normalizedflat //" ready")
    print("stall: "// normalizedflat //" ready", >> logfile)
  }
  else{
    print("stall: ERROR: cannot access normalizedflat <"// normalizedflat //">!")
    print("stall: ERROR: cannot access normalizedflat <"// normalizedflat //">!", >> logfile)
    print("stall: ERROR: cannot access normalizedflat <"// normalizedflat //">!", >> warningfile)
    print("stall: ERROR: cannot access normalizedflat <"// normalizedflat //">!", >> errorfile)
# --- clean up
    inimages = ""
    delete (infile, ver-, >& "dev$null")
    return
  }

  flpr

# --- stdivflat
  if (dostdivflat){
    if (!access( divflatlist )){
      print("stall: ERROR: cannot access divflatlist <"// divflatlist //">!")
      print("stall: ERROR: cannot access divflatlist <"// divflatlist //">!", >> logfile)
      print("stall: ERROR: cannot access divflatlist <"// divflatlist //">!", >> errorfile)
      print("stall: ERROR: cannot access divflatlist <"// divflatlist //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    print("stall: running stdivflat")
    print("stall: running stdivflat", >> logfile)
    if (!access( normalizedflat )){
      print("stall: ERROR: cannot access normalizedflat <"// normalizedflat //">!")
      print("stall: ERROR: cannot access normalizedflat <"// normalizedflat //">!", >> logfile)
      print("stall: ERROR: cannot access normalizedflat <"// normalizedflat //">!", >> errorfile)
      print("stall: ERROR: cannot access normalizedflat <"// normalizedflat //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    stdivflat(Images        = "@"//divflatlist,
              FlatImage     = normalizedflat,
              DelInput      = delinputfiles,
              LogLevel      = loglevel,
              ParameterFile = parameterfile,
              LogFile       = logfile_stdivflat,
              WarningFile   = warningfile_stdivflat,
              ErrorFile     = errorfile_stdivflat)
    if (access(logfile_stdivflat))
      cat(logfile_stdivflat, >> logfile)
    if (access(warningfile_stdivflat))
      cat(warningfile_stdivflat, >> warningfile)
    if (access(errorfile_stdivflat)){
      cat(errorfile_stdivflat, >> errorfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
  }

  flpr

# --- cosmicrays
  if (dostcosmics){
    print("stall: running stcosmics")
    print("stall: running stcosmics", >> logfile)
    if (!access(objects_botzf_list)){
      print("stall: WARNING: cannot access objects_botzf_list <"// objects_botzf_list //">!")
      print("stall: WARNING: cannot access objects_botzf_list <"// objects_botzf_list //">!", >> logfile)
      print("stall: WARNING: cannot access objects_botzf_list <"// objects_botzf_list //">!", >> errorfile)
#      print("stall: ERROR: cannot access objects_botzf_list <"// objects_botzf_list //">!", >> warningfile)
## --- clean up
#      inimages = ""
#      delete (infile, ver-, >& "dev$null")
#      return
    }
    else
    {
      stcosmics(Images        = "@"//objects_botzf_list,
                ErrorImages   = "@"//cosmicerrlist,
                DelInput      = delinputfiles,
                LogLevel      = loglevel,
                DoErrors      = doerrors,
                ParameterFile = parameterfile,
                LogFile       = logfile_stcosmics,
                WarningFile   = warningfile_stcosmics,
                ErrorFile     = errorfile_stcosmics)
      if (access(logfile_stcosmics))
        cat(logfile_stcosmics, >> logfile)
      if (access(warningfile_stcosmics))
        cat(warningfile_stcosmics, >> warningfile)
      if (access(errorfile_stcosmics)){
        cat(errorfile_stcosmics, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }
  }

  flpr

# --- scattered light
  if (dostscatter){
    print("stall: running stscatter for objects")
    print("stall: running stscatter for objects", >> logfile)

# --- load echelle package
    if (setinst_instrument == "kpnocoude")
      echelle
    if (!access(subscatterobjectslist)){
      print("stall: WARNING: cannot access subscatterobjectslist <"// subscatterobjectslist //">!")
      print("stall: WARNING: cannot access subscatterobjectslist <"// subscatterobjectslist //">!", >> logfile)
      print("stall: WARNING: cannot access subscatterobjectslist <"// subscatterobjectslist //">!", >> warningfile)
#      print("stall: WARNING: cannot access subscatterobjectslist <"// subscatterobjectslist //">!", >> errorfile)
## --- clean up
#      inimages = ""
#      delete (infile, ver-, >& "dev$null")
#      return
    }
    else
    {
      stscatter(images        = "@"//subscatterobjectslist,
                reference     = refapObs,
                calib-,
                object+,
                delinput      = delinputfiles,
                loglevel      = loglevel,
                parameterfile = parameterfile,
                logfile       = logfile_stscatter,
                warningfile   = warningfile_stscatter,
                errorfile     = errorfile_stscatter)
      if (access(logfile_stscatter))
        cat(logfile_stscatter, >> logfile)
      if (access(warningfile_stscatter))
        cat(warningfile_stscatter, >> warningfile)
      if (access(errorfile_stscatter)){
        cat(errorfile_stscatter, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }
    flpr

    if (docalibs){
      print("stall: running stscatter for calibs")
      print("stall: running stscatter for calibs", >> logfile)

      if (!access(subscattercalibslist)){
        print("stall: ERROR: cannot access subscattercalibslist <"// subscattercalibslist //">!")
        print("stall: ERROR: cannot access subscattercalibslist <"// subscattercalibslist //">!", >> logfile)
        print("stall: ERROR: cannot access subscattercalibslist <"// subscattercalibslist //">!", >> errorfile)
        print("stall: ERROR: cannot access subscattercalibslist <"// subscattercalibslist //">!", >> warningfile)
      }
      stscatter(images        = "@"//subscattercalibslist,
                reference     = refapCalibs,
                calib+,
                object-,
                delinput      = delinputfiles,
                loglevel      = loglevel,
                parameterfile = parameterfile,
                logfile       = logfile_stscatter,
                warningfile   = warningfile_stscatter,
                errorfile     = errorfile_stscatter)
      if (access(logfile_stscatter))
        cat(logfile_stscatter, >> logfile)
      if (access(warningfile_stscatter))
        cat(warningfile_stscatter, >> warningfile)
      if (access(errorfile_stscatter)){
        cat(errorfile_stscatter, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }# end if (docalibs)
# --- reload kpnocoude package
    if (setinst_instrument == "kpnocoude")
      kpnocoude
  }

  flpr

# --- spectral features tilted? YES: find curvature and interpolate spectra
  if (spectral_features_tilted && dostfixcurvature){
    stfixcurvature(Images = fix_curvature_list,
                   ParameterFile = parameterfile,
                   LogLevel = loglevel,
                   LogFile = logfile_stfixcurvature,
                   WarningFile = warningfile_stfixcurvature,
                   ErrorFile   = errorfile_stfixcurvature)
    if (access(logfile_stfixcurvature))
      cat(logfile_stfixcurvature, >> logfile)
    if (access(warningfile_stfixcurvature))
      cat(warningfile_stfixcurvature, >> warningfile)
    if (access(errorfile_stfixcurvature)){
      cat(errorfile_stfixcurvature, >> errorfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
  }

# --- extract calibs
  if (docalibs){
    if (doextractcalibs){
      print("stall: extracting calibs")
      print("stall: extracting calibs", >> logfile)
      if (!access(extractcalibslist)){
        print("stall: ERROR: cannot access extractcalibslist <"// extractcalibslist //">!")
        print("stall: ERROR: cannot access extractcalibslist <"// extractcalibslist //">!", >> logfile)
        print("stall: ERROR: cannot access extractcalibslist <"// extractcalibslist //">!", >> errorfile)
        print("stall: ERROR: cannot access extractcalibslist <"// extractcalibslist //">!", >> warningfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      stextract(Images        = "@"//extractcalibslist,
                Reference     = refapCalibs,
                Calib+,
                Object-,
                DelInput-,
                LogLevel      = loglevel,
                DoErrors      = doerrors,
                ParameterFile = parameterfile,
                LogFile       = logfile_stextract,
                WarningFile   = warningfile_stextract,
                ErrorFile     = errorfile_stextract)
      if (access(logfile_stextract))
        cat(logfile_stextract, >> logfile)
      if (access(warningfile_stextract))
        cat(warningfile_stextract, >> warningfile)
      if (access(errorfile_stextract)){
        cat(errorfile_stextract, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }

    flpr

# --- identify calibs
    if (dostidentify){
      print("stall: reidentifying calibs")
      print("stall: reidentifying calibs", >> logfile)
      if (!access(calibsEc_list)){
        print("stall: ERROR: cannot access calibsEc_list <"// calibsEc_list //">!")
        print("stall: ERROR: cannot access calibsEc_list <"// calibsEc_list //">!", >> logfile)
        print("stall: ERROR: cannot access calibsEc_list <"// calibsEc_list //">!", >> errorfile)
        print("stall: ERROR: cannot access calibsEc_list <"// calibsEc_list //">!", >> warningfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      for (i=1; i<= ext_nsubaps; i = i+1){
        if (ext_nsubaps == 1){
          ApNoStr = ""
          templist = calibsEc_list
        }
        else{
          ApNoStr = ""
          if (ext_nsubaps > 99 && i < 100)
            ApNoStr = "0"
          if (ext_nsubaps > 9 && i < 10)
            ApNoStr = ApNoStr//"0"
          ApNoStr = ApNoStr//i
          strlastpos(calibsEc_list,".")
          templist = substr(calibsEc_list,1,strlastpos.pos-1)//ApNoStr//".list"
          if (access(templist))
            del(templist, ver-)
          print("stall: calibsEc_list = <"//calibsEc_list//">")
          if (loglevel > 2)
            print("stall: calibsEc_list = <"//calibsEc_list//">", >> logfile)
          parameterlist = calibsEc_list
          while(fscan(parameterlist, tempfile) != EOF){
            strlastpos(tempfile, "Ec")
            if (setinst_instrument == "echelle"){
              tempfile = substr(tempfile,1,strlastpos.pos+1)//ApNoStr//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
            }
            else{
              tempfile = substr(tempfile,1,strlastpos.pos+1)//"."//ApNoStr//"001"//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
            }
            print(tempfile, >> templist)
          }# end while(fscan(parameterlist, tempfile) != EOF){
        }# end if (ext_nsubaps != 1)
        strlastpos(logfile_stidentify,".")
        templogfile = substr(logfile_stidentify,1,strlastpos.pos-1)//ApNoStr//substr(logfile_stidentify,strlastpos.pos,strlen(logfile_stidentify))
        strlastpos(warningfile_stidentify,".")
        tempwarningfile = substr(warningfile_stidentify,1,strlastpos.pos-1)//ApNoStr//substr(warningfile_stidentify,strlastpos.pos,strlen(warningfile_stidentify))
        strlastpos(errorfile_stidentify,".")
        temperrorfile = substr(errorfile_stidentify,1,strlastpos.pos-1)//ApNoStr//substr(errorfile_stidentify,strlastpos.pos,strlen(errorfile_stidentify))
        print("stall: templist = <"//templist//">")
        if (loglevel > 2)
          print("stall: templist = <"//templist//">")
        print("stall: templogfile = <"//templogfile//">")
        if (loglevel > 2)
          print("stall: templogfile = <"//templogfile//">")
        print("stall: tempwarningfile = <"//tempwarningfile//">")
        if (loglevel > 2)
          print("stall: tempwarningfile = <"//tempwarningfile//">")
        print("stall: temperrorfile = <"//temperrorfile//">")
        if (loglevel > 2)
          print("stall: temperrorfile = <"//temperrorfile//">")
        stidentify(images        = "@"//templist,
                   loglevel      = loglevel,
                   parameterfile = parameterfile,
                   logfile       = templogfile,
                   warningfile   = tempwarningfile,
                   errorfile     = temperrorfile)
        if (access(templogfile))
          cat(templogfile, >> logfile)
        if (access(tempwarningfile))
          cat(tempwarningfile, >> warningfile)
        if (access(temperrorfile)){
          cat(temperrorfile, >> errorfile)
# --- clean up
          inimages = ""
          delete (infile, ver-, >& "dev$null")
          return
        }# end if (access(temperrorfile)){
      }# end for (i=1; i<= ext_nsubaps; i = i+1){
    }# end if (dostidentify)
  }# end if (docalibs)
  flpr

# --- extract objects
  if (doextractobjects){
    print("stall: extracting objects")
    print("stall: extracting objects", >> logfile)
    if (!access(objects_botzfxs_list)){
      print("stall: WARNING: cannot access objects_botzfxs_list <"// objects_botzfxs_list //">!")
      print("stall: WARNING: cannot access objects_botzfxs_list <"// objects_botzfxs_list //">!", >> logfile)
      print("stall: WARNING: cannot access objects_botzfxs_list <"// objects_botzfxs_list //">!", >> warningfile)
#      print("stall: WARNING: cannot access objects_botzfxs_list <"// objects_botzfxs_list //">!", >> errorfile)
## --- clean up
#      inimages = ""
#      delete (infile, ver-, >& "dev$null")
#      return
    }
    else
    {
      stextract(Images        = "@"//objects_botzfxs_list,
                ErrorImages   = "@"//objects_botzfxs_err_list,
                Reference     = refapObs,
                Calib-,
                Object+,
                DelInput-,
                LogLevel      = loglevel,
                DoErrors      = doerrors,
                ParameterFile = parameterfile,
                LogFile       = logfile_stextract,
                WarningFile   = warningfile_stextract,
                ErrorFile     = errorfile_stextract)
      if (access(logfile_stextract))
        cat(logfile_stextract, >> logfile)
      if (access(warningfile_stextract))
        cat(warningfile_stextract, >> warningfile)
      if (access(errorfile_stextract)){
        cat(errorfile_stextract, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }
  }

  flpr

# --- take out Blaze function
  if (dostblaze){
    if (nflat_subscatter){
    }
    else
      combinedflat_s = combinedflat
    blazeflat=combinedflat_s
    print("stall: blazeflat = <"//blazeflat//">")
    if (!access(blazeflat)){
      print("stall: ERROR: cannot access blazeflat <"// blazeflat //">!")
      print("stall: ERROR: cannot access blazeflat <"// blazeflat //">!", >> logfile)
      print("stall: ERROR: cannot access blazeflat <"// blazeflat //">!", >> errorfile)
      print("stall: ERROR: cannot access blazeflat <"// blazeflat //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
# --- stcrerefblaze
    strlastpos(refBlaze,".")
    refBlaze_n = substr(refBlaze,1,strlastpos.pos-1)//"_n"//substr(refBlaze,strlastpos.pos,strlen(refBlaze))
    refBlaze_nd = substr(refBlaze,1,strlastpos.pos-1)//"_nd"
    if (blaze_divbyfilter)
    {
      refBlaze_nd = refBlaze_nd//"fnd"
    }
    refBlaze_nd = refBlaze_nd//substr(refBlaze,strlastpos.pos,strlen(refBlaze))
    if (docalibs){
      print("stall: creating refBlaze_nd")
      print("stall: creating refBlaze_nd", >> logfile)
      if (access(refBlaze_nd))
        del(refBlaze_nd, ver-)
      stcrerefblaze(combinedFlat       = blazeflat,
                    normalizedFlat     = normalizedflat,
                    blaze_in           = refBlaze,
                    blaze_out          = refBlaze_nd,
                    parameterfile      = parameterfile,
                    loglevel           = loglevel,
                    logfile            = logfile_stcrerefblaze,
                    warningfile        = warningfile_stcrerefblaze,
                    errorfile          = errorfile_stcrerefblaze,
                    logfile_stidentify = logfile_stidentify)
      if (access(logfile_stcrerefblaze))
        cat(logfile_stcrerefblaze, >> logfile)
      if (access(warningfile_stcrerefblaze))
        cat(warningfile_stcrerefblaze, >> warningfile)
      if (access(errorfile_stcrerefblaze)){
        cat(errorfile_stcrerefblaze, >> errorfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }# end if (docalibs)
# --- stblaze
    if (!access(objects_botzfxs_list)){
      print("stall: WARNING: cannot access objects_botzfxs_list <"// objects_botzfxs_list //">!")
      print("stall: WARNING: cannot access objects_botzfxs_list <"// objects_botzfxs_list //">!", >> logfile)
      print("stall: WARNING: cannot access objects_botzfxs_list <"// objects_botzfxs_list //">!", >> errorfile)
#      print("stall: WARNING: cannot access objects_botzfxs_list <"// objects_botzfxs_list //">!", >> warningfile)
## --- clean up
#      inimages = ""
#      delete (infile, ver-, >& "dev$null")
#      return
    }
      print("stall: dividing objects by refBlaze")
      print("stall: dividing objects by refBlaze", >> logfile)
      for (i = 1; i <= ext_nsubaps; i += 1){
        if (ext_nsubaps == 1){
          print("stall: ext_nsubaps == 1")
          ApNoStr = "1"
          if (setinst_instrument == "echelle"){
            refBlaze = refBlaze_nd
#            refBlaze = refBlaze_nd#"refBlaze_"//substr(blazeflat,1,strlen(blazeflat)-strlen(imtype)-1)//"_nEc_fitnd."//imtype
          }
          else{
            refBlaze = substr(refBlaze_nd,1,strlen(refBlaze_nd)-strlen(imtype)-1)//".0001."//imtype
#            refBlaze = substr(refBlaze_nd,1,strlen(refBlaze_nd)-strlen(imtype)-1)//".0001."//imtype#"refBlaze_"//substr(blazeflat,1,strlen(blazeflat)-strlen(imtype)-1)//"_nEc.0001_fitnd."//imtype
          }
        }# end if (ext_nsubaps == 1)
        else{
          print("stall: ext_nsubaps == "//ext_nsubaps)
          ApNoStr = ""
          if (ext_nsubaps > 99 && i < 100)
            ApNoStr = "0"
          if (ext_nsubaps > 9 && i < 10)
            ApNoStr = ApNoStr//"0"
          ApNoStr = ApNoStr//i
          if (setinst_instrument == "echelle"){
            refBlaze = "refBlaze_"//substr(combinedflat,1,strlen(combinedflat)-strlen(imtype)-1)//"_nEc"//ApNoStr//"_fitnd."//imtype
          }
          else{
            refBlaze = "refBlaze_"//substr(combinedflat,1,strlen(combinedflat)-strlen(imtype)-1)//"_nEc."//ApNoStr//"001_fitnd."//imtype
          }
          if (blaze_divbyfilter){
            strlastpos(refBlaze, ".")
            refBlaze = substr(refBlaze, 1, strlastpos.pos-1)//"fnd"//substr(refBlaze, strlastpos.pos, strlen(refBlaze))
          }
        }# end if (ext_nsubaps != 1)
        print("stall: refBlaze = <"//refBlaze//">")
#        return





        if (loglevel > 2)
          print("stall: refBlaze = <"//refBlaze//">", >> logfile)
        print(refBlaze, >> refBlaze_list)
        strlastpos(blazelist,".")
        tempblazelist = substr(blazelist,1,strlastpos.pos-1)//ApNoStr//".list"
        print("stall: tempblazelist = <"//tempblazelist//">")
        if (loglevel > 2)
          print("stall: tempblazelist = <"//tempblazelist//">", >> logfile)
        if (access(tempblazelist))
          del(tempblazelist, ver-)
        strlastpos(blazeerrlist,".")
        tempblazeerrlist = substr(blazeerrlist,1,strlastpos.pos-1)//ApNoStr//".list"
        print("stall: tempblazeerrlist = <"//tempblazeerrlist//">")
        if (loglevel > 2)
          print("stall: tempblazeerrlist = <"//tempblazeerrlist//">", >> logfile)
        if (access(tempblazeerrlist))
          del(tempblazeerrlist, ver-)
        print("stall: blazelist = <"//blazelist//">")
        if (loglevel > 2)
          print("stall: blazelist = <"//blazelist//">", >> logfile)
        parameterlist=blazelist
        while(fscan(parameterlist, tempfile) != EOF){
          if (ext_nsubaps == 1){
            if (setinst_instrument != "echelle"){
              strlastpos(tempfile,"Ec")
              tempfile = substr(tempfile,1,strlastpos.pos+1)//".0001"//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
            }
          }# end if (ext_nsubaps == 1)
          else{
            if (setinst_instrument == "echelle"){
              strlastpos(tempfile,"Ec")
              tempfile = substr(tempfile,1,strlastpos.pos+1)//ApNoStr//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
            }
            else{
              strlastpos(tempfile,"Ec")
              tempfile = substr(tempfile,1,strlastpos.pos+1)//"."//ApNoStr//"001"//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
            }
          }# end if (ext_nsubaps != 1)
          print(tempfile, >> tempblazelist)
        }
        parameterlist=blazeerrlist
        while(fscan(parameterlist, tempfile) != EOF){
          if (ext_nsubaps == 1){
            if (setinst_instrument != "echelle"){
              strlastpos(tempfile,"Ec")
              tempfile = substr(tempfile,1,strlastpos.pos+1)//".0001"//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
            }
          }# end if (ext_nsubaps == 1)
          else{
            if (setinst_instrument == "echelle"){
              strlastpos(tempfile,"Ec")
              tempfile = substr(tempfile,1,strlastpos.pos+1)//ApNoStr//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
            }
            else{
              strlastpos(tempfile,"Ec")
              tempfile = substr(tempfile,1,strlastpos.pos+1)//"."//ApNoStr//"001"//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
            }
          }# end if (ext_nsubaps != 1)
          print(tempfile, >> tempblazeerrlist)
        }

#        return
        if (blaze_divbyfilter){
          refBlaze_temp = refBlaze
        }
        else{
          strlastpos(combinedflat_s,".")
          refBlaze_temp = "refBlaze_"//substr(combinedflat_s,1,strlastpos.pos-1)//"_nEc_fitn."//imtype
        }
        print("stall: refBlaze = "//refBlaze)

        stblaze(Images        = "@"//tempblazelist,
                RefBlaze      = refBlaze_temp,
                ErrorImages   = "@"//tempblazeerrlist,
                LogLevel      = loglevel,
                DoErrors      = doerrors,
                ParameterFile = parameterfile,
                LogFile       = logfile_stblaze,
                WarningFile   = warningfile_stblaze,
                ErrorFile     = errorfile_stblaze)
        if (access(logfile_stblaze))
          cat(logfile_stblaze, >> logfile)
        if (access(warningfile_stblaze))
          cat(warningfile_stblaze, >> warningfile)
        if (access(errorfile_stblaze)){
          cat(errorfile_stblaze, >> errorfile)
# --- clean up
          inimages = ""
          delete (infile, ver-, >& "dev$null")
          return
        }
      }# end for (i = 1; i <= ext_nsubaps; i += 1){
  }# end if (dostblaze){

# --- assign reference spectra
  if (dostrefspec){
    print("stall: assigning reference spectra to objects")
    print("stall: assigning reference spectra to objects", >> logfile)
    if (!access(dispcor_list)){
      print("stall: WARNING: cannot access dispcor_list <"// dispcor_list //">!")
      print("stall: WARNING: cannot access dispcor_list <"// dispcor_list //">!", >> logfile)
      print("stall: WARNING: cannot access dispcor_list <"// dispcor_list //">!", >> warningfile)
#      print("stall: WARNING: cannot access dispcor_list <"// dispcor_list //">!", >> errorfile)
## --- clean up
#      inimages = ""
#      delete (infile, ver-, >& "dev$null")
#      return
    }
    else
    {
#    if (!access(calibsEc_list)){
#      print("stall: ERROR: cannot access "// calibsEc_list //"!")
#      print("stall: ERROR: cannot access "// calibsEc_list //"!", >> logfile)
#      print("stall: ERROR: cannot access "// calibsEc_list //"!", >> errorfile)
#      print("stall: ERROR: cannot access "// calibsEc_list //"!", >> warningfile)
## --- clean up
#      inimages = ""
#      delete (infile, ver-, >& "dev$null")
#      return
#    }

      for (i = 1; i <= ext_nsubaps; i += 1){
        if (ext_nsubaps == 1){
          ApNoStr = ""
          tempdispcor_list = dispcor_list
          tempdispcor_err_list = dispcor_err_list
        }
        else{
          ApNoStr = ""
          if (ext_nsubaps > 99 && i < 100)
            ApNoStr = "0"
          if (ext_nsubaps > 9 && i < 10)
            ApNoStr = ApNoStr//"0"
          ApNoStr = ApNoStr//i
          strlastpos(dispcor_list,".")
          tempdispcor_list = substr(dispcor_list,1,strlastpos.pos-1)//ApNoStr//substr(dispcor_list,strlastpos.pos,strlen(dispcor_list))
          if (access(tempdispcor_list))
            del(tempdispcor_list, ver-)
          strlastpos(dispcor_err_list,".")
          tempdispcor_err_list = substr(dispcor_err_list,1,strlastpos.pos-1)//ApNoStr//substr(dispcor_err_list,strlastpos.pos,strlen(dispcor_err_list))
          if (access(tempdispcor_err_list))
            del(tempdispcor_err_list, ver-)
          parameterlist=dispcor_list
          while(fscan(parameterlist, tempfile) != EOF){
            if (ext_nsubaps == 1){
              if (setinst_instrument != "echelle"){
                strlastpos(tempfile,"Ec")
                tempfile = substr(tempfile,1,strlastpos.pos+1)//".0001"//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
              }
            }# end if (ext_nsubaps == 1)
            else{
              if (setinst_instrument == "echelle"){
                strlastpos(tempfile,"Ec")
                tempfile = substr(tempfile,1,strlastpos.pos+1)//ApNoStr//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
              }
              else{
                strlastpos(tempfile,"Ec")
                tempfile = substr(tempfile,1,strlastpos.pos+1)//"."//ApNoStr//"001"//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
              }
            }# end if (ext_nsubaps != 1)
            print(tempfile, >> tempdispcor_list)
          }
          parameterlist=dispcor_err_list
          while(fscan(parameterlist, tempfile) != EOF){
            if (ext_nsubaps == 1){
              if (setinst_instrument != "echelle"){
                strlastpos(tempfile,"Ec")
                tempfile = substr(tempfile,1,strlastpos.pos+1)//".0001"//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
              }
            }# end if (ext_nsubaps == 1)
            else{
              if (setinst_instrument == "echelle"){
                strlastpos(tempfile,"Ec")
                tempfile = substr(tempfile,1,strlastpos.pos+1)//ApNoStr//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
              }
              else{
                strlastpos(tempfile,"Ec")
                tempfile = substr(tempfile,1,strlastpos.pos+1)//"."//ApNoStr//"001"//substr(tempfile,strlastpos.pos+2,strlen(tempfile))
              }
            }# end if (ext_nsubaps != 1)
            print(tempfile, >> tempdispcor_err_list)
          }
        }# end if (ext_nsubaps != 1){
        strlastpos(logfile_stidentify,".")
        templogfile = substr(logfile_stidentify,1,strlastpos.pos-1)//ApNoStr//substr(logfile_stidentify,strlastpos.pos,strlen(logfile_stidentify))
        print("stall: tempdispcor_list = <"//tempdispcor_list//">")
        if (loglevel > 2)
          print("stall: tempdispcor_list = <"//tempdispcor_list//">", >> logfile)
        print("stall: templogfile = <"//templogfile//">")
        if (loglevel > 2)
          print("stall: templogfile = <"//templogfile//">", >> logfile)

        strefspec(images             = "@"//tempdispcor_list,
                  logfile_stidentify = templogfile,
                  loglevel           = loglevel,
                  parameterfile      = parameterfile,
                  logfile            = logfile_strefspec,
                  warningfile        = warningfile_strefspec,
                  errorfile          = errorfile_strefspec)
        if (access(logfile_strefspec))
          cat(logfile_strefspec, >> logfile)
        if (access(warningfile_strefspec))
          cat(warningfile_strefspec, >> warningfile)
        if (access(errorfile_strefspec)){
          cat(errorfile_strefspec, >> errorfile)
# --- clean up
          inimages = ""
          delete (infile, ver-, >& "dev$null")
          return
        }
      }# end for (i = 1; i <= ext_nsubaps; i += 1){
    }
  }# end if (dostrefspec){

  flpr

# --- dispcor
  if (dostdispcor){
    if (!access(calibsEc_list)){
      print("stall: ERROR: cannot access dispcor_list <"// dispcor_list //">!")
      print("stall: ERROR: cannot access dispcor_list <"// dispcor_list //">!", >> logfile)
      print("stall: ERROR: cannot access dispcor_list <"// dispcor_list //">!", >> errorfile)
      print("stall: ERROR: cannot access dispcor_list <"// dispcor_list //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    for (i = 1; i <= ext_nsubaps; i += 1){
      ApNoStr = ""
      if (ext_nsubaps > 99 && i < 100)
        ApNoStr = "0"
      if (ext_nsubaps > 9 && i < 10)
        ApNoStr = ApNoStr//"0"
      ApNoStr = ApNoStr//i
      if (ext_nsubaps == 1)
        ApNoStr = ""
      strlastpos(calibsEc_list,".")
      templist = substr(calibsEc_list,1,strlastpos.pos-1)//ApNoStr//".list"
      if (!access(templist)){
        print("stall: ERROR: cannot access templist <"// templist //">!")
        print("stall: ERROR: cannot access templist <"// templist //">!", >> logfile)
        print("stall: ERROR: cannot access templist <"// templist //">!", >> errorfile)
        print("stall: ERROR: cannot access templist <"// templist //">!", >> warningfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
#      stdispcor(images="@"//templist,
      if (docalibs){
        print("stall: correcting dispersion of calibration images")
        print("stall: correcting dispersion of calibration images", >> logfile)
        stdispcor(images        = "@goodCalibs.list",
                  calibs+,
                  delinput      = delinputfiles,
                  parameterfile = parameterfile,
                  loglevel      = loglevel,
                  logfile       = logfile_stdispcor,
                  warningfile   = warningfile_stdispcor,
                  errorfile     = errorfile_stdispcor)
        if (access(logfile_stdispcor))
          cat(logfile_stdispcor, >> logfile)
        if (access(warningfile_stdispcor))
          cat(warningfile_stdispcor, >> warningfile)
        if (access(errorfile_stdispcor)){
          cat(errorfile_stdispcor, >> errorfile)
# --- clean up
          inimages = ""
          delete (infile, ver-, >& "dev$null")
          return
        }
      }# end if (docalibs)
# --- clean up
      if (cleanup){
        print("stall: cleaning up")
        if (loglevel > 2)
          print("stall: cleaning up", >> logfile)
        imdel("@"//objects_bot_list, ver-)
        imdel ("@"//objects_bot_errlist, ver-)
        imdel ("@"//combinedzerolist, ver-)
        imdel ("@"//subzerolist, ver-)
        imdel ("@"//objects_botzf_list, ver-)
        imdel ("@"//cosmicerrlist, ver-)
        imdel ("@"//flatlist, ver-)
        imdel ("@"//subscattercalibslist, ver-)
        imdel ("@"//subscatterobjectslist, ver-)
        imdel ("@"//subscatterflatslist, ver-)
        imdel ("@"//divflatlist, ver-)
        imdel ("@"//objects_botzfxs_list, ver-)
        imdel ("@"//objects_botzfxs_err_list, ver-)
        imdel ("@"//extractcalibslist, ver-)
        print("stall: clean up ready")
        if (loglevel > 2)
          print("stall: clean up ready", >> logfile)
      }
      # --- object spectra
      print("stall: correcting dispersion of object images, dispcor_list = <"//dispcor_list//">")
      print("stall: correcting dispersion of object images, dispcor_list = <"//dispcor_list//">", >> logfile)
      strlastpos(dispcor_list,".")
      tempdispcor_list = substr(dispcor_list,1,strlastpos.pos-1)//ApNoStr//substr(dispcor_list,strlastpos.pos,strlen(dispcor_list))
      if (!access(tempdispcor_list)){
        print("stall: ERROR: cannot access tempdispcor_list <"// tempdispcor_list //">!")
        print("stall: ERROR: cannot access tempdispcor_list <"// tempdispcor_list //">!", >> logfile)
        print("stall: ERROR: cannot access tempdispcor_list <"// tempdispcor_list //">!", >> errorfile)
        print("stall: ERROR: cannot access tempdispcor_list <"// tempdispcor_list //">!", >> warningfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      strlastpos(dispcor_err_list,".")
      tempdispcor_err_list = substr(dispcor_err_list,1,strlastpos.pos-1)//ApNoStr//substr(dispcor_err_list,strlastpos.pos,strlen(dispcor_err_list))
      if (!access(tempdispcor_list)){
        print("stall: WARNING: cannot access tempdispcor_list <"// tempdispcor_list //">!")
        print("stall: WARNING: cannot access tempdispcor_list <"// tempdispcor_list //">!", >> logfile)
        print("stall: WARNING: cannot access tempdispcor_list <"// tempdispcor_list //">!", >> warningfile)
#        print("stall: WARNING: cannot access tempdispcor_list <"// tempdispcor_list //">!", >> errorfile)
## --- clean up
#        inimages = ""
#        delete (infile, ver-, >& "dev$null")
#        return
      }
      else
      {
        stdispcor(images        = "@"//tempdispcor_list,
                  calibs-,
                  errorimages   = "@"//tempdispcor_err_list,
                  delinput      = delinputfiles,
                  parameterfile = parameterfile,
                  loglevel      = loglevel,
                  doerrors      = doerrors,
                  logfile       = logfile_stdispcor,
                  warningfile   = warningfile_stdispcor,
                  errorfile     = errorfile_stdispcor)
        if (access(logfile_stdispcor))
          cat(logfile_stdispcor, >> logfile)
        if (access(warningfile_stdispcor))
          cat(warningfile_stdispcor, >> warningfile)
        if (access(errorfile_stdispcor)){
          cat(errorfile_stdispcor, >> errorfile)
# --- clean up
          inimages = ""
          delete (infile, ver-, >& "dev$null")
          return
        }
      }

# --- clean up
      if (cleanup){
        print("stall: cleaning up")
        if (loglevel > 2)
          print("stall: cleaning up", >> logfile)
        imdel("@"//objects_bot_list, ver-)
        imdel ("@"//objects_bot_errlist, ver-)
#      string badovertrimlist
#      string badovertrimerrlist, ver-)
        imdel ("@"//combinedzerolist, ver-)
        imdel ("@"//subzerolist, ver-)
#        imdel ("@"//subzeroerrlist, ver-)
        imdel ("@"//objects_botzf_list, ver-)
        imdel ("@"//cosmicerrlist, ver-)
        imdel ("@"//flatlist, ver-)
        imdel ("@"//subscattercalibslist, ver-)
        imdel ("@"//subscatterobjectslist, ver-)
        imdel ("@"//subscatterflatslist, ver-)
        imdel ("@"//divflatlist, ver-)
        imdel ("@"//objects_botzfxs_list, ver-)
        imdel ("@"//objects_botzfxs_err_list, ver-)
        imdel ("@"//extractcalibslist, ver-)
#        imdel ("@"//divflaterrlist, ver-)
        print("stall: clean up ready")
        if (loglevel > 2)
          print("stall: clean up ready", >> logfile)
      }
    }
  }

  flpr

## --- calcsnr
#  if (doerrors){
#    print("stall: calculating Signal-to-Noise images")
#    print("stall: calculating Signal-to-Noise images", >> logfile)
#    if (access(calcsnrlist)){
#      if (access(calcsnrerrlist)){
#        stcalcsnr(images="@"//calcsnrlist,
#                  errorimages="@"//calcsnrerrlist,
#		  loglevel=loglevel,
#		  logfile = logfile_stcalcsnr,
#		  warningfile = warningfile_stcalcsnr,
#		  errorfile = errorfile_stcalcsnr)
#        if (access(logfile_stcalcsnr))
#          cat(logfile_stcalcsnr, >> logfile)
#        if (access(warningfile_stcalcsnr))
#          cat(warningfile_stcalcsnr, >> warningfile)
#        if (access(errorfile_stcalcsnr))
#          cat(errorfile_stcalcsnr, >> errorfile)
#      }
#      else{
#        print("stall: ERROR: cannot access "// calcsnrerrlist //"!")
#        print("stall: ERROR: cannot access "// calcsnrerrlist //"!", >> logfile)
#        print("stall: ERROR: cannot access "// calcsnrerrlist //"!", >> errorfile)
#        print("stall: ERROR: cannot access "// calcsnrerrlist //"!", >> warningfile)
#      }
#    }
#    else{
#      print("stall: ERROR: cannot access "// calcsnrlist //"!")
#      print("stall: ERROR: cannot access "// calcsnrlist //"!", >> logfile)
#      print("stall: ERROR: cannot access "// calcsnrlist //"!", >> errorfile)
#      print("stall: ERROR: cannot access "// calcsnrlist //"!", >> warningfile)
#    }
#  }

  flpr
# --- sttrimaps
  if (dostcontinuum && !dostmerge){
    print("stall: Execution of task stmerge required for execution of stmerge => Setting dostmerge to YES")
    print("stall: Execution of task stmerge required for execution of stmerge => Setting dostmerge to YES", >> logfile)
    dostmerge = YES
  }
  if (dostmerge && !dosttrimaps){
    print("stall: Execution of task sttrimaps required for execution of stmerge => Setting dosttrimaps to YES")
    print("stall: Execution of task sttrimaps required for execution of stmerge => Setting dosttrimaps to YES", >> logfile)
    dosttrimaps = YES
  }
  if (dosttrimaps){
    print("stall: Trimming orders of object images")
    print("stall: Trimming orders of object images", >> logfile)
    for (i = 1; i<6; i=i+1){
      if (i == 1)
        templist = objects_botzfxsEcd_list
      else if (i == 2)
        templist = objects_botzfxsEcd_err_list
      else if (i == 3)
        templist = objects_botzfxsEcBld_list
      else if (i == 4)
        templist = objects_botzfxsEcBld_err_list
      else{
        templist = refBlaze_list
      }
      if (!access(templist)){
        print("stall: ERROR: cannot access templist <"// templist //">!")
        print("stall: ERROR: cannot access templist <"// templist //">!", >> logfile)
        print("stall: ERROR: cannot access templist <"// templist //">!", >> errorfile)
        print("stall: ERROR: cannot access templist <"// templist //">!", >> warningfile)
# --- clean up
        inimages = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      if (i < 5 || dostblaze){
        sttrimaps(Images        = "@"//templist,
		  ParameterFile = parameterfile,
		  LogLevel      = loglevel,
		  LogFile       = logfile_sttrimaps,
		  WarningFile   = warningfile_sttrimaps,
		  ErrorFile     = errorfile_sttrimaps)
        if (access(logfile_sttrimaps))
          cat(logfile_sttrimaps, >> logfile)
        if (access(warningfile_sttrimaps))
          cat(warningfile_sttrimaps, >> warningfile)
        if (access(errorfile_sttrimaps)){
          cat(errorfile_sttrimaps, >> errorfile)
# --- clean up
          inimages = ""
          delete (infile, ver-, >& "dev$null")
          return
        }
      }
      if (i == 1){
        trimmed_ap_text_lists_list = sttrimaps.ApTextFileLists
        print("stall: setting trimmed_ap_text_lists_list to sttrimaps.ApTextFileLists=<"//trimmed_ap_text_lists_list//">")
        if (loglevel > 2)
          print("stall: setting trimmed_ap_text_lists_list to sttrimaps.ApTextFileLists=<"//trimmed_ap_text_lists_list//">", >> logfile)
      }
      else if (i == 2){
        trimmed_ap_err_text_lists_list = sttrimaps.ApTextFileLists
        print("stall: setting trimmed_ap_err_text_lists_list to sttrimaps.ApTextFileLists=<"//trimmed_ap_err_text_lists_list//">")
        if (loglevel > 2)
          print("stall: setting trimmed_ap_err_text_lists_list to sttrimaps.ApTextFileLists=<"//trimmed_ap_err_text_lists_list//">", >> logfile)
      }
      else if (i == 3){
        blazed_trimmed_ap_fits_lists_list = sttrimaps.ApFitsFileLists
        print("stall: setting blazed_trimmed_ap_fits_lists_list to sttrimaps.ApFitsFileLists=<"//blazed_trimmed_ap_fits_lists_list//">")
        if (loglevel > 2)
          print("stall: setting blazed_trimmed_ap_fits_lists_list to sttrimaps.ApFitsFileLists=<"//blazed_trimmed_ap_fits_lists_list//">", >> logfile)
        blazed_trimmed_ap_text_lists_list = sttrimaps.ApTextFileLists
        print("stall: setting blazed_trimmed_ap_text_lists_list to sttrimaps.ApTextFileLists=<"//blazed_trimmed_ap_text_lists_list//">")
        if (loglevel > 2)
          print("stall: setting blazed_trimmed_ap_text_lists_list to sttrimaps.ApTextFileLists=<"//blazed_trimmed_ap_text_lists_list//">", >> logfile)
      }
      else if (i == 4){
        blazed_trimmed_ap_err_fits_lists_list = sttrimaps.ApFitsFileLists
        print("stall: setting blazed_trimmed_ap_err_fits_lists_list to sttrimaps.ApFitsFileLists=<"//blazed_trimmed_ap_err_fits_lists_list//">")
        if (loglevel > 2)
          print("stall: setting blazed_trimmed_ap_err_fits_lists_list to sttrimaps.ApFitsFileLists=<"//blazed_trimmed_ap_err_fits_lists_list//">", >> logfile)
        blazed_trimmed_ap_err_text_lists_list = sttrimaps.ApTextFileLists
        print("stall: setting blazed_trimmed_ap_err_text_lists_list to sttrimaps.ApTextFileLists=<"//blazed_trimmed_ap_err_text_lists_list//">")
        if (loglevel > 2)
          print("stall: setting blazed_trimmed_ap_err_text_lists_list to sttrimaps.ApTextFileLists=<"//blazed_trimmed_ap_err_text_lists_list//">", >> logfile)
      }
      else{
        if (dostblaze){
          refBlaze_t_fits_list = sttrimaps.ApFitsFileLists
          print("stall: setting refBlaze_t_fits_list to sttrimaps.ApTextFileLists=<"//refBlaze_t_fits_list//">")
          if (loglevel > 2)
            print("stall: setting refBlaze_t_fits_list to sttrimaps.ApTextFileLists=<"//refBlaze_t_fits_list//">", >> logfile)
          if (!access(refBlaze_t_fits_list)){
            print("stall: ERROR: refBlaze_t_fits_list <"//refBlaze_t_fits_list//"> not found! => Returning")
            print("stall: ERROR: refBlaze_t_fits_list <"//refBlaze_t_fits_list//"> not found! => Returning", >> logfile)
            print("stall: ERROR: refBlaze_t_fits_list <"//refBlaze_t_fits_list//"> not found! => Returning", >> warningfile)
            print("stall: ERROR: refBlaze_t_fits_list <"//refBlaze_t_fits_list//"> not found! => Returning", >> errorfile)
# --- clean up
            inimages = ""
            delete (infile, ver-, >& "dev$null")
            return
          }
          parameterlist = refBlaze_t_fits_list
          if (fscan(parameterlist, tempfile) == EOF){
            print("stall: ERROR: fscan(refBlaze_t_fits_list <"//refBlaze_t_fits_list//">) returned EOF! => Returning")
            print("stall: ERROR: fscan(refBlaze_t_fits_list <"//refBlaze_t_fits_list//">) returned EOF! => Returning", >> logfile)
            print("stall: ERROR: fscan(refBlaze_t_fits_list <"//refBlaze_t_fits_list//">) returned EOF! => Returning", >> warningfile)
            print("stall: ERROR: fscan(refBlaze_t_fits_list <"//refBlaze_t_fits_list//">) returned EOF! => Returning", >> errorfile)
# --- clean up
            inimages = ""
            delete (infile, ver-, >& "dev$null")
            return
          }
          if (!access(tempfile)){
            print("stall: ERROR: tempfile <"//tempfile//"> not found! => Returning")
            print("stall: ERROR: tempfile <"//tempfile//"> not found! => Returning", >> logfile)
            print("stall: ERROR: tempfile <"//tempfile//"> not found! => Returning", >> warningfile)
            print("stall: ERROR: tempfile <"//tempfile//"> not found! => Returning", >> errorfile)
# --- clean up
            inimages = ""
            delete (infile, ver-, >& "dev$null")
            return
          }
          refBlaze_t_fits_list = tempfile
          print("stall: setting refBlaze_t_fits_list to content of sttrimaps.ApTextFileLists <"//refBlaze_t_fits_list//">")
          if (loglevel > 2)
            print("stall: setting refBlaze_t_fits_list to content of sttrimaps.ApTextFileLists <"//refBlaze_t_fits_list//">", >> logfile)
        }# end if (dostblaze)
      }# end if (i == 5)
    }# end for (i = 1; i<6; i=i+1){
  }# end if (dosttrimaps){

# --- set continuum
  if (dostcontinuum){
    print("stall: Setting continuum for orders of object images")
    print("stall: Setting continuum for orders of object images", >> logfile)
    if (!access(blazed_trimmed_ap_fits_lists_list)){
      print("stall: ERROR: cannot access blazed_trimmed_ap_fits_lists_list <"// blazed_trimmed_ap_fits_lists_list //">!")
      print("stall: ERROR: cannot access blazed_trimmed_ap_fits_lists_list <"// blazed_trimmed_ap_fits_lists_list //">!", >> logfile)
      print("stall: ERROR: cannot access blazed_trimmed_ap_fits_lists_list <"// blazed_trimmed_ap_fits_lists_list //">!", >> errorfile)
      print("stall: ERROR: cannot access blazed_trimmed_ap_fits_lists_list <"// blazed_trimmed_ap_fits_lists_list //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    if (!access(blazed_trimmed_ap_err_fits_lists_list)){
      print("stall: ERROR: cannot access blazed_trimmed_ap_err_fits_lists_list <"// blazed_trimmed_ap_err_fits_lists_list //">!")
      print("stall: ERROR: cannot access blazed_trimmed_ap_err_fits_lists_list <"// blazed_trimmed_ap_err_fits_lists_list //">!", >> logfile)
      print("stall: ERROR: cannot access blazed_trimmed_ap_err_fits_lists_list <"// blazed_trimmed_ap_err_fits_lists_list //">!", >> errorfile)
      print("stall: ERROR: cannot access blazed_trimmed_ap_err_fits_lists_list <"// blazed_trimmed_ap_err_fits_lists_list //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    stcontinuum(Images        = "@"//blazed_trimmed_ap_fits_lists_list,
                ErrorImages   = "@"//blazed_trimmed_ap_err_fits_lists_list,
                ParameterFile = parameterfile,
                Mode          = "orders",
                LogLevel      = loglevel,
                DoErrors      = doerrors,
                LogFile       = logfile_stcontinuum,
                WarningFile   = warningfile_stcontinuum,
                ErrorFile     = errorfile_stcontinuum)
    if (access(logfile_stcontinuum))
      cat(logfile_stcontinuum, >> logfile)
    if (access(warningfile_stcontinuum))
      cat(warningfile_stcontinuum, >> warningfile)
    if (access(errorfile_stcontinuum)){
      cat(errorfile_stcontinuum, >> errorfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
  }

  flpr

# --- merge
  if (dostmerge){
    print("stall: merging orders of object images")
    print("stall: merging orders of object images", >> logfile)
    if (!access(blazed_trimmed_ap_text_lists_list)){
      print("stall: ERROR: cannot access blazed_trimmed_ap_text_lists_list <"// blazed_trimmed_ap_text_lists_list //">!")
      print("stall: ERROR: cannot access blazed_trimmed_ap_text_lists_list <"// blazed_trimmed_ap_text_lists_list //">!", >> logfile)
      print("stall: ERROR: cannot access blazed_trimmed_ap_text_lists_list <"// blazed_trimmed_ap_text_lists_list //">!", >> errorfile)
      print("stall: ERROR: cannot access blazed_trimmed_ap_text_lists_list <"// blazed_trimmed_ap_text_lists_list //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    if (!access(blazed_trimmed_ap_err_text_lists_list)){
      print("stall: ERROR: cannot access blazed_trimmed_ap_err_text_lists_list <"// blazed_trimmed_ap_err_text_lists_list //">!")
      print("stall: ERROR: cannot access blazed_trimmed_ap_err_text_lists_list <"// blazed_trimmed_ap_err_text_lists_list //">!", >> logfile)
      print("stall: ERROR: cannot access blazed_trimmed_ap_err_text_lists_list <"// blazed_trimmed_ap_err_text_lists_list //">!", >> errorfile)
      print("stall: ERROR: cannot access blazed_trimmed_ap_err_text_lists_list <"// blazed_trimmed_ap_err_text_lists_list //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    cat(blazed_trimmed_ap_fits_lists_list, >> to_merge_list)
    cat(blazed_trimmed_ap_err_fits_lists_list, >> to_merge_err_list)
    parameterlist = blazed_trimmed_ap_fits_lists_list
    while(fscan(parameterlist, tempinfile) != EOF){
      strlastpos(tempinfile, "_"//imtype)
      Pos = strlastpos.pos
      if (Pos == 0){
        strlastpos(tempinfile, ".")
        Pos = strlastpos.pos
      }
      if (Pos == 0)
        Pos = strlen(tempinfile)+1
      tempfile = substr(tempinfile,1,Pos-1)//"n.list"#//substr(tempinfile,Pos,strlen(tempinfile))
      if (dostcontinuum)
        print(tempfile, >> to_merge_list)
    }
    parameterlist = blazed_trimmed_ap_err_fits_lists_list
    while(fscan(parameterlist, tempinfile) != EOF){
      strlastpos(tempinfile, "_"//imtype)
      Pos = strlastpos.pos
      if (Pos == 0){
        strlastpos(tempinfile, ".")
        Pos = strlastpos.pos
      }
      if (Pos == 0)
        Pos = strlen(tempinfile)+1
      tempfile = substr(tempinfile,1,Pos-1)//"n.list"#//substr(tempinfile,Pos,strlen(tempinfile))
      if (dostcontinuum)
        print(tempfile, >> to_merge_err_list)
    }
    stmergelist(Images         = "@"//to_merge_list,
                ErrImages      = "@"//to_merge_err_list,
                WeightFitsList = refBlaze_t_fits_list,
                ParameterFile  = parameterfile,
                LogLevel       = loglevel,
                LogFile        = logfile_stmergelist,
                WarningFile    = warningfile_stmergelist,
                ErrorFile      = errorfile_stmergelist)
    if (access(logfile_stmergelist))
      cat(logfile_stmergelist, >> logfile)
    if (access(warningfile_stmergelist))
      cat(warningfile_stmergelist, >> warningfile)
    if (access(errorfile_stmergelist)){
      cat(errorfile_stmergelist, >> errorfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
  }

  flpr

# --- combine subapertures
  if (ext_nsubaps > 1 && dostcombine){
    print("stall: Combining sub apertures of object images")
    print("stall: Combining sub apertures of object images", >> logfile)
    if (!access(combine_list)){
      print("stall: ERROR: cannot access combine_list <"// combine_list //">!")
      print("stall: ERROR: cannot access combine_list <"// combine_list //">!", >> logfile)
      print("stall: ERROR: cannot access combine_list <"// combine_list //">!", >> errorfile)
      print("stall: ERROR: cannot access combine_list <"// combine_list //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    if (doerrors && !access(combine_err_list)){
      print("stall: ERROR: cannot access combine_err_list <"// combine_err_list //">!")
      print("stall: ERROR: cannot access combine_err_list <"// combine_err_list //">!", >> logfile)
      print("stall: ERROR: cannot access combine_err_list <"// combine_err_list //">!", >> errorfile)
      print("stall: ERROR: cannot access combine_err_list <"// combine_err_list //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    stcombine(Images        = "@"//combine_list,
              ErrorImages   = "@"//combine_err_list,
              ParameterFile = parameterfile,
              LogLevel      = loglevel,
              DoErrors      = doerrors,
              LogFile       = logfile_stcombine,
              WarningFile   = warningfile_stcombine,
              ErrorFile     = errorfile_stcombine)
    if (access(logfile_stcombine))
      cat(logfile_stcombine, >> logfile)
    if (access(warningfile_stcombine))
      cat(warningfile_stcombine, >> warningfile)
    if (access(errorfile_stcombine)){
      cat(errorfile_stcombine, >> errorfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
  }

  flpr

# --- set continuum
  if (dostcontinuum){
    print("stall: Setting continuum of object images")
    print("stall: Setting continuum of object images", >> logfile)
    if (ext_nsubaps > 1){
      templist    = objects_botzfxsEcBldt_rb_mc_list
      temperrlist = objects_botzfxsEcBldt_rb_mc_err_list
    }
    else{
#      strlastpos(blazed_trimmed_ap_text_lists_list,"t_")
      templist    = objects_botzfxsEcBldt_rb_m_list
      temperrlist = objects_botzfxsEcBldt_rb_m_err_list
#substr(blazed_trimmed_ap_err_text_lists_list,1,strlastpos.pos)//"m"//substr(blazed_trimmed_ap_err_text_lists_list,strlastpos.pos+1,strlen(blazed_trimmed_ap_err_text_lists_list))#
    }
    if (!access(templist)){
      print("stall: ERROR: cannot access input list <"// templist //">!")
      print("stall: ERROR: cannot access input list <"// templist //">!", >> logfile)
      print("stall: ERROR: cannot access input list <"// templist //">!", >> errorfile)
      print("stall: ERROR: cannot access input list <"// templist //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    if (doerrors && !access(temperrlist)){
      print("stall: ERROR: cannot access input errfile list <"// temperrlist //">!")
      print("stall: ERROR: cannot access input errfile list <"// temperrlist //">!", >> logfile)
      print("stall: ERROR: cannot access input errfile list <"// temperrlist //">!", >> errorfile)
      print("stall: ERROR: cannot access input errfile list <"// temperrlist //">!", >> warningfile)
# --- clean up
      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    stcontinuum(Images        = "@"//templist,
                ErrorImages   = "@"//temperrlist,
                ParameterFile = parameterfile,
                Mode          = "single",
                LogLevel      = loglevel,
                DoErrors      = doerrors,
                LogFile       = logfile_stcontinuum,
                WarningFile   = warningfile_stcontinuum,
                ErrorFile     = errorfile_stcontinuum)
    if (access(logfile_stcontinuum))
      cat(logfile_stcontinuum, >> logfile)
    if (access(warningfile_stcontinuum))
      cat(warningfile_stcontinuum, >> warningfile)
    if (access(errorfile_stcontinuum)){
      cat(errorfile_stcontinuum, >> errorfile)
# --- clean up      inimages = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
  }#end if (dostcontinuum)

# --- give logfiles an unique name
  if (access(timefile))
    del(timefile, ver-)
  time (>> timefile)
  if (access(timefile)){
    timelist = timefile
    while(fscan(timelist,daystring,timestring,datestring) != EOF){
      print("stall: daystring = "//daystring//", timestring = "//timestring//", datestring = "//datestring)
    }
    strlastpos(logfile,".")
    logfile_bak     = substr(logfile,1,strlastpos.pos-1)//"_"
    strlastpos(warningfile,".")
    warningfile_bak = substr(warningfile,1,strlastpos.pos-1)//"_"
    strlastpos(errorfile,".")
    errorfile_bak   = substr(errorfile,1,strlastpos.pos-1)//"_"
    strlastpos(parameterfile,".")
    parameterfile_bak = substr(parameterfile,1,strlastpos.pos-1)//"_"
    strlastpos(parameterfile_bak,"/")
    parameterfile_bak = substr(parameterfile_bak,strlastpos.pos+1,strlen(parameterfile_bak))
    for (i=1;i<=strlen(timestring);i+=1){
      if (substr(timestring,i,i) == ":" || substr(timestring,i,i) == " "){
        logfile_bak     = logfile_bak//"-"
        warningfile_bak = warningfile_bak//"-"
        errorfile_bak   = errorfile_bak//"-"
	parameterfile_bak = parameterfile_bak//"-"
      }
      else{
        logfile_bak     = logfile_bak//substr(timestring,i,i)
        warningfile_bak = warningfile_bak//substr(timestring,i,i)
        errorfile_bak   = errorfile_bak//substr(timestring,i,i)
	parameterfile_bak = parameterfile_bak//substr(timestring,i,i)
      }
    }
    logfile_bak     = logfile_bak//"_"//datestring
    warningfile_bak = warningfile_bak//"_"//datestring
    errorfile_bak   = errorfile_bak//"_"//datestring
    parameterfile_bak = parameterfile_bak//"_"//datestring
  }
  else{
    logfile_bak     = logfile_bak//".bak"
    warningfile_bak = warningfile_bak//".bak"
    errorfile_bak   = errorfile_bak//".bak"
    parameterfile_bak = parameterfile_bak//".bak"
  }
  logfile_bak     = logfile_bak//".log"
  warningfile_bak = warningfile_bak//".log"
  errorfile_bak   = errorfile_bak//".log"
  parameterfile_bak = parameterfile_bak//".prop"

  print("stall: copying logfiles")
  if (loglevel > 2)
    print("stall: copying logfiles", >> logfile)
  if (access(logfile))
    copy(in=logfile,
	 out=logfile_bak,
	 ver-)
  if (access(warningfile))
    copy(in=warningfile,
	 out=warningfile_bak,
	 ver-)
  if (access(errorfile))
    copy(in=errorfile,
	 out=errorfile_bak,
	 ver-)

  if (access(parameterfile))
    copy(in=parameterfile,
	 out=parameterfile_bak,
	 ver-)
  print("stall: READY")
  print("stall: READY", >> logfile)
  print("stall: READY", >> logfile_bak)

# --- clean up
  inimages = ""
  delete (infile, ver-, >& "dev$null")

end
