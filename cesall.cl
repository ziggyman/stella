procedure stall (images)

#################################################################
#                                                               #
# This program reduces the STELLA-Echelle spectra automatically #
#                                                               #
# Andreas Ritter, 04.12.2001                                    #
#                                                               #
#################################################################

string images               = "@fits.list"                                {prompt="List of images to reduce"}
string parameterfile        = "scripts$parameterfiles/parameterfile_UVES_blue_346_2148x3000.prop" {prompt="Path and name of parameterfile"}
bool   dostzero             = YES                                         {prompt="Do stzero?"}
bool   dostbadovertrim      = YES                                         {prompt="Do stbadovertrim?"}
bool   dostsubzero          = YES                                         {prompt="Do stsubzero?"}
#bool   dostcosmics_flat     = YES                                         {prompt="Do stcosmics with flats?"}
bool   dostflat             = YES                                         {prompt="Do stflat?"}
bool   dostscatter          = YES                                         {prompt="Do stscatter?"}
bool   dostnflat            = YES                                         {prompt="Do stnflat?"}
bool   dostaddheader          = YES                                         {prompt="Do staddheader?"}
bool   dosetjd              = YES                                         {prompt="Do setjd?"}
bool   dostdivflat          = YES                                         {prompt="Do stdivflat?"}
bool   dostcosmics          = YES                                         {prompt="Do stcosmics?"}
bool   dohedit              = YES                                         {prompt="Do hedit?"}
bool   doextractthars       = YES                                         {prompt="Do extract thars?"}
bool   dostidentify         = YES                                         {prompt="Do stidentify?"}
bool   doextractobjects     = YES                                         {prompt="Do extract objects?"}
bool   dostrefspec          = YES                                         {prompt="Do strefspec?"}
bool   dostdispcor          = YES                                         {prompt="Do stdispcor?"}
bool   deleteoldlogfiles    = YES                                         {prompt="Delete old logfiles?"}

string *inimages
string *parameterlist

begin

  string observatory           = "STELLA"
  string reference             = "refFlat"
  string refapObs              = "Obs"
  string refapThars            = "Thars"
  string combinedzero          = "combinedZero.fits"
  string combinedflat          = "combinedFlat.fits"
  string combinedflat_s        = "combinedFlat_s.fits"
  string normalizedflat        = "normalizedFlat.fits"
  string logfile               = "logfile.log"
  string errorfile             = "errors.log"
  string warningfile           = "warnings.log"
  string badovertrimlist       = "stbadovertrim.list"
  string zerolist              = "zeros.list"
  string subzerolist           = "stsubzero.list"
  string cosmiclist            = "stcosmics.list"
  string flatlist              = "flats_botz.list"
  string subscattertharslist   = "thars_botz.list"
  string subscatterobjectslist = "objects_botz.list"
  string subscatterflatslist   = "combinedFlat.list"
  string divflatlist           = "stdivflat.list"
  string extracttharslist      = "thars_botzsf.list"
  string thars_ec_list         = "thars_botzsf_ec.list"
  string extractobjectslist    = "objects_botzsfx.list"
  string dispcorlist           = "objects_botzsfx_ec.list"
  string objects_ecd_list      = "objects_botzsfx_ecd.list"
  string parameter,parametervalue
  int    loglevel              = 3
  int    echelle_dispaxis      = 2   # vertical dispersion
  file   infile
  string in
  real   apdef_lower           = -22.
  real   apdef_upper           = 22.
  string apdef_apidtable       = ""
  string apdefb_function       = "chebyshev"
  int    apdefb_order          = 1
  int    apdefb_samplebuf      = 4
  string apdefb_sample         = "-25:-23,23:25"
  int    apdefb_naverage       = -3
  int    apdefb_niterate       = 2
  real   apdefb_low_reject     = 3.
  real   apdefb_high_reject    = 3.
  real   apdefb_grow           = 0.

  bool   imred_keeplog         = NO

  string ccdred_pixeltype      = "real real"
  bool   ccdred_verbose        = YES
  string ccdred_plotfile       = ""
  string ccdred_backup         = ""
  string ccdred_ssfile         = "subsets"
  string ccdred_graphic        = "stdgraph"
  string ccdred_cursor         = ""

  string setinst_instrument    = "echelle"
  string setinst_site          = "kpno"
  string setinst_dir           = "ccddb$"
  bool   setinst_review        = YES

  string echelle_extinct       = "onedstds$kpnoextinct.dat"
  string caldir                = "onedstds$spechayescal/"
  string echelle_interp        = "linear"
  int    echelle_nsum          = 1
  string echelle_database      = "database"
  bool   echelle_verbose       = YES
  string echelle_plotfile      = ""
  string echelle_records       = ""

  string onedspec_interp       = "poly5"

  bool   found_observatory           = NO
  bool   found_echelle_extinct       = NO
  bool   found_caldir        = NO
  bool   found_echelle_interp        = NO
  bool   found_echelle_dispaxis      = NO
  bool   found_echelle_nsum          = NO
  bool   found_ccdred_ssfile         = NO
  bool   found_ccdred_graphic        = NO
  bool   found_reference             = NO
  bool   found_loglevel              = NO
  bool   found_apdef_lower           = NO
  bool   found_apdef_upper           = NO
  bool   found_apdef_apidtable       = NO
  bool   found_apdefb_function       = NO
  bool   found_apdefb_order          = NO
  bool   found_apdefb_samplebuf      = NO
  bool   found_apdefb_naverage       = NO
  bool   found_apdefb_niterate       = NO
  bool   found_apdefb_low_reject     = NO
  bool   found_apdefb_high_reject    = NO
  bool   found_apdefb_grow           = NO
  bool   found_onedspec_interp       = NO

  print("****************************************************") 
  print("*                                                  *")
  print("*      Automatic data reduction for the STELLA     *")
  print("*                 ECHELLE spectra                  *")
  print("*                                                  *")
  print("*            Andreas Ritter, 07.12.2001            *")
  print("*                                                  *")
  print("****************************************************")

# --- delete logfiles
  if (deleteoldlogfiles){
    if (loglevel > 2 && (access(logfile) || access(errorfile) || access(warningfile)))
      print("stall: deleting old logfiles", >> logfile)
    if (access(logfile))
      delete(files=logfile,ver-)
    if (access("logfile"))
      delete(files="logfile",ver-)
    if (access(errorfile))
      delete(files=errorfile,ver-)
    if (access(warningfile))
      delete(files=warningfile,ver-)
  }

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
      if (parameter == "loglevel"){ 
        loglevel = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//loglevel)
        if (loglevel > 2){
          print ("stall: Setting "//parameter//" to "//loglevel, >> logfile)
        }
        found_loglevel = YES
      }
      else if (parameter == "observatory"){
        observatory = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_observatory = YES
      }
      else if (parameter == "echelle_extinct"){
        echelle_extinct = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_echelle_extinct = YES
      }
      else if (parameter == "caldir"){
        caldir = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_caldir = YES
      }
      else if (parameter == "echelle_interp"){
        echelle_interp = parametervalue
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_echelle_interp = YES
      }
      else if (parameter == "echelle_dispaxis"){ 
        echelle_dispaxis = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2){
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
        found_echelle_dispaxis = YES
      }
      else if (parameter == "echelle_nsum"){
        echelle_nsum = int(parametervalue)
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_echelle_nsum = YES
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
      else if (parameter == "ext_lower"){
        apdef_lower = real(parametervalue)
        print ("stall: Setting "//parameter//" to "//apdef_lower)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdef_lower, >> logfile)
        found_apdef_lower = YES
      }
      else if (parameter == "ext_upper"){
        apdef_upper = real(parametervalue)
        print ("stall: Setting "//parameter//" to "//apdef_upper)
        if (loglevel > 2)
          print ("stall: Setting "//parameter//" to "//apdef_upper, >> logfile)
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
    }
    if (!found_loglevel){
      print("stall: WARNING: parameter loglevel not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter loglevel not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter loglevel not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_observatory){
      print("stall: WARNING: parameter observatory not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter observatory not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter observatory not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_caldir){
      print("stall: WARNING: parameter caldir not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter caldir not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter caldir not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_echelle_extinct){
      print("stall: WARNING: parameter echelle_extinct not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter echelle_extinct not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter echelle_extinct not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_echelle_interp){
      print("stall: WARNING: parameter echelle_interp not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter echelle_interp not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter echelle_interp not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_echelle_dispaxis){
      print("stall: WARNING: parameter echelle_dispaxis not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter echelle_dispaxis not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter echelle_dispaxis not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_echelle_nsum){
      print("stall: WARNING: parameter echelle_nsum not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter echelle_nsum not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter echelle_nsum not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ccdred_ssfile){
      print("stall: WARNING: parameter ccdred_ssfile not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter ccdred_ssfile not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter ccdred_ssfile not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ccdred_graphic){
      print("stall: WARNING: parameter ccdred_graphic not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter ccdred_graphic not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter ccdred_graphic not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_onedspec_interp){
      print("stall: WARNING: parameter onedspec_interp not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter onedspec_interp not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter onedspec_interp not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_reference){
      print("stall: WARNING: parameter reference not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter reference not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter reference not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apdef_lower){
      print("stall: WARNING: parameter ext_lower not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter ext_lower not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter ext_lower not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apdef_upper){
      print("stall: WARNING: parameter ext_upper not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter ext_upper not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter ext_upper not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_apdef_apidtable){
      print("stall: WARNING: parameter apdef_apidtable not found in parameterfile!!! -> using standard")
      print("stall: WARNING: parameter apdef_apidtable not found in parameterfile!!! -> using standard", >> logfile)
      print("stall: WARNING: parameter apdef_apidtable not found in parameterfile!!! -> using standard", >> warningfile)
    }
#    if (!found_apdefb_function){
#      print("stall: WARNING: parameter apdefb_function not found in parameterfile!!! -> using standard")
#      print("stall: WARNING: parameter apdefb_function not found in parameterfile!!! -> using standard", >> logfile)
#      print("stall: WARNING: parameter apdefb_function not found in parameterfile!!! -> using standard", >> warningfile)
#    }
#    if (!found_apdefb_order){
#      print("stall: WARNING: parameter apdefb_order not found in parameterfile!!! -> using standard")
#      print("stall: WARNING: parameter apdefb_order not found in parameterfile!!! -> using standard", >> logfile)
#      print("stall: WARNING: parameter apdefb_order not found in parameterfile!!! -> using standard", >> warningfile)
#    }
#    if (!found_apdefb_samplebuf){
#      print("stall: WARNING: parameter apdefb_samplebuf not found in parameterfile!!! -> using standard")
#      print("stall: WARNING: parameter apdefb_samplebuf not found in parameterfile!!! -> using standard", >> logfile)
#      print("stall: WARNING: parameter apdefb_samplebuf not found in parameterfile!!! -> using standard", >> warningfile)
#    }
#    if (!found_apdefb_naverage){
#      print("stall: WARNING: parameter apdefb_naverage not found in parameterfile!!! -> using standard")
#      print("stall: WARNING: parameter apdefb_naverage not found in parameterfile!!! -> using standard", >> logfile)
#      print("stall: WARNING: parameter apdefb_naverage not found in parameterfile!!! -> using standard", >> warningfile)
#    }
#    if (!found_apdefb_niterate){
#      print("stall: WARNING: parameter apdefb_niterate not found in parameterfile!!! -> using standard")
#      print("stall: WARNING: parameter apdefb_niterate not found in parameterfile!!! -> using standard", >> logfile)
#      print("stall: WARNING: parameter apdefb_niterate not found in parameterfile!!! -> using standard", >> warningfile)
#    }
#    if (!found_apdefb_low_reject){
#      print("stall: WARNING: parameter apdefb_low_reject not found in parameterfile!!! -> using standard")
#      print("stall: WARNING: parameter apdefb_low_reject not found in parameterfile!!! -> using standard", >> logfile)
#      print("stall: WARNING: parameter apdefb_low_reject not found in parameterfile!!! -> using standard", >> warningfile)
#    }
#    if (!found_apdefb_high_reject){
#      print("stall: WARNING: parameter apdefb_high_reject not found in parameterfile!!! -> using standard")
#      print("stall: WARNING: parameter apdefb_high_reject not found in parameterfile!!! -> using standard", >> logfile)
#      print("stall: WARNING: parameter apdefb_high_reject not found in parameterfile!!! -> using standard", >> warningfile)
#    }
#    if (!found_apdefb_grow){
#      print("stall: WARNING: parameter apdefb_grow not found in parameterfile!!! -> using standard")
#      print("stall: WARNING: parameter apdefb_grow not found in parameterfile!!! -> using standard", >> logfile)
#      print("stall: WARNING: parameter apdefb_grow not found in parameterfile!!! -> using standard", >> warningfile)
#    }

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
  ccdred.setinstrument.query      = "echelle"

  imred.echelle.extinct = echelle_extinct
  imred.echelle.caldir  = caldir
  imred.echelle.observa = observatory
  imred.echelle.interp  = echelle_interp
  imred.echelle.dispaxi = echelle_dispaxis
  imred.echelle.nsum    = echelle_nsum
  imred.echelle.databas = echelle_database
  imred.echelle.verbose = echelle_verbose
  imred.echelle.logfile = logfile
  imred.echelle.plotfil = echelle_plotfile
  imred.echelle.records = echelle_records

  echelle.apdefault.lower         = apdef_lower
  echelle.apdefault.upper         = apdef_upper
  echelle.apdefault.apidtable     = apdef_apidtable
  echelle.apdefault.b_function    = apdefb_function
  echelle.apdefault.b_order       = apdefb_order
  echelle.apdefault.b_sample      = apdef_lower-apdefb_samplebuf//":"//apdef_lower//","//apdef_upper//":"//(apdef_upper+apdefb_samplebuf)
  print("stall: Setting apdefault.b_sample to "//echelle.apdefault.b_sample)
  if (loglevel > 2){
    print("stall: Setting apdefault.b_sample to "//echelle.apdefault.b_sample, >> logfile)
  }
  echelle.apdefault.b_naverage    = apdefb_naverage
  echelle.apdefault.b_niterate    = apdefb_niterate
  echelle.apdefault.b_low_reject  = apdefb_low_reject
  echelle.apdefault.b_high_reject = apdefb_high_reject
  echelle.apdefault.b_grow        = apdefb_grow

  noao.onedspec.observatory  = observatory
  noao.onedspec.caldir       = caldir
  noao.onedspec.interp       = onedspec_interp
  noao.onedspec.dispaxis     = echelle_dispaxis
  noao.onedspec.nsum         = echelle_nsum
  noao.onedspec.records      = echelle_records

# --- Erzeugen von temporaeren Filenamen
  print("stall: building temp-filenames")
  if (loglevel > 2)
    print("stall: building temp-filenames", >> logfile)
  infile       = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stall: building lists from temp-files")
  if (loglevel > 2)
    print("stall: building lists from temp-files", >> logfile)

  if ((substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
   sections(images, option="root", > infile)
   inimages = infile
  }
  else{
   if (substr(images,1,1) != "@"){
    print("stall: ERROR: "// images //" not found!!!")
    print("stall: ERROR: "// images //" not found!!!", >> logfile)
    print("stall: ERROR: "// images //" not found!!!", >> errorfile)
    print("stall: ERROR: "// images //" not found!!!", >> warningfile)
   }
   else{
    print("stall: ERROR: "//substr( images, 2, strlen( images ))//" not found!!!")
    print("stall: ERROR: "//substr( images, 2, strlen( images ))//" not found!!!", >> logfile)
    print("stall: ERROR: "//substr( images, 2, strlen( images ))//" not found!!!", >> errorfile)
    print("stall: ERROR: "//substr( images, 2, strlen( images ))//" not found!!!", >> warningfile)

   }
   return
  }

# --- delete old lists
  print("stall: deleting old lists")
  if ( loglevel > 2)
    print("stall: deleting old lists", >> logfile)
  if ( access( badovertrimlist ))
    delete(files=badovertrimlist, ver-)
  if ( access( zerolist ))
    delete(files=zerolist, ver-)
  if ( access( subzerolist ))
    delete(files=subzerolist, ver-)
  if ( access( cosmiclist ))
    delete(files=cosmiclist, ver-)
  if ( access( subscattertharslist ))
    delete(files=subscattertharslist, ver-)
  if ( access( subscatterobjectslist ))
    delete(files=subscatterobjectslist, ver-)
  if ( access( subscatterflatslist ))
    delete(files=subscatterflatslist, ver-)
  if ( access( flatlist ))
    delete(files=flatlist, ver-)
  if ( access( divflatlist ))
    delete(files=divflatlist, ver-)
  if ( access( extracttharslist ))
    delete(files=extracttharslist, ver-)
  if ( access( thars_ec_list ))
    delete(files=thars_ec_list, ver-)
  if ( access( extractobjectslist ))
    delete(files=extractobjectslist, ver-)
  if ( access( dispcorlist ))
    delete(files=dispcorlist, ver-)
  if ( access( objects_ecd_list ))
    delete(files=objects_ecd_list, ver-)

# --- build new lists
  print("stall: building new lists")
  if (loglevel > 2)
    print("stall: building new lists", >> logfile)
  print(combinedzero, >> badovertrimlist)
  print(combinedzero," >> badovertrimlist", >> logfile)
  print( combinedflat, >> subscatterflatslist)
  print( "combinedflat, >> subscatterflatslist", >> logfile)
  while ( fscan( inimages, in ) != EOF){
    if (loglevel > 2)
      print("stall: in = "// in)
  # --- flats
    if ( substr(in, 1, 4) == "flat" || substr(in, 1, 4) == "Flat" || substr(in, 1, 9) == "LAMP-FLAT" || substr(in, 1, 8) == "LAMPFLAT"){
      print(in, >> badovertrimlist)
      print(in," >> badovertrimlist", >> logfile)
      if ( substr(in, strlen(in)-4, strlen(in)) == ".fits"){
        print( substr(in, 1, strlen(in)-5)//"_bot.fits", >> subzerolist)
        print( substr(in, 1, strlen(in)-5)//"_bot.fits >> subzerolist", >> logfile)
        print( substr(in, 1, strlen(in)-5)//"_botz.fits", >> flatlist)
        print( substr(in, 1, strlen(in)-5)//"_botz.fits >> flatlist", >> logfile)
      }
      else{
        print(in//"_bot", >> subzerolist)
        print(in//"_bot >> subzerolist", >> logfile)
        print(in//"_botz", >> subscatterobjectslist)
        print(in//"_botz >> subscatterobjectslist", >> logfile)
      }
    }
  # --- biases
    else if (substr(in, 1, 4) == "bias" || substr(in, 1, 4) == "Bias" || substr(in, 1, 4) == "BIAS"){
      print(in, >> zerolist)
      print(in," >> zerolist", >> logfile)
    }
  # --- thars
    else if (substr(in, 1, 4) == "thar" || substr(in, 1, 4) == "Thar" || substr(in, 1, 4) == "ThAr" || substr(in, 1, 9) == "LAMP-WAVE" || substr(in, 1, 8) == "LAMPWAVE" || substr(in, 1, 7) == "refThAr" || substr(in, 1, 7) == "refThar"){
      print(in, >> badovertrimlist)
      print(in," >> badovertrimlist", >> logfile)
      if (substr(in,strlen(in)-4,strlen(in)) == ".fits"){
        print(substr(in, 1, strlen(in)-5)//"_bot.fits", >> subzerolist)
        print(substr(in, 1, strlen(in)-5)//"_bot.fits >> subzerolist", >> logfile)
        print(substr(in, 1, strlen(in)-5)//"_botz.fits", >> subscattertharslist)
        print(substr(in, 1, strlen(in)-5)//"_botz.fits >> subscattertharslist", >> logfile)
        print(substr(in, 1, strlen(in)-5)//"_botzs.fits", >> divflatlist)
        print(substr(in, 1, strlen(in)-5)//"_botzs.fits >> divflatlist", >> logfile)
        print(substr(in, 1, strlen(in)-5)//"_botzsf.fits", >> extracttharslist)
        print(substr(in, 1, strlen(in)-5)//"_botzsf.fits >> extracttharslist", >> logfile)
        print(substr(in, 1, strlen(in)-5)//"_botzsf_ec.fits", >> thars_ec_list)
        print(substr(in, 1, strlen(in)-5)//"_botzsf_ec.fits >> thars_ec_list", >> logfile)
      }
      else{
        print(in//"_bot", >> subzerolist)
        print(in//"_bot >> subzerolist", >> logfile)
        print(in//"_botz", >> subscattertharslist)
        print(in//"_botz >> subscattertharslist", >> logfile)
        print(in//"_botzs", >> divflatlist)
        print(in//"_botzs >> divflatlist", >> logfile)
        print(in//"_botzsf", >> tharslist)
        print(in//"_botzsf >> tharslist", >> logfile)
      }
    }
  # --- objects
    else{   # objects
      print(in, >> badovertrimlist)
      print(in," >> badovertrimlist", >> logfile)
      if (substr(in, strlen(in)-4, strlen(in)) == ".fits"){
        print(substr(in, 1, strlen(in)-5)//"_bot.fits",    >> subzerolist)
        print(substr(in, 1, strlen(in)-5)//"_bot.fits    >> subzerolist", >> logfile)
        print(substr(in, 1, strlen(in)-5)//"_botz.fits",  >> subscatterobjectslist)
        print(substr(in, 1, strlen(in)-5)//"_botz.fits  >> subscatterobjectslist", >> logfile)
        print(substr(in, 1, strlen(in)-5)//"_botzs.fits", >> divflatlist)
        print(substr(in, 1, strlen(in)-5)//"_botzs.fits >> divflat_list", >> logfile)
        print(substr(in, 1, strlen(in)-5)//"_botzsf.fits",   >> cosmiclist)
        print(substr(in, 1, strlen(in)-5)//"_botzsf.fits   >> cosmiclist", >> logfile)
        print(substr(in, 1, strlen(in)-5)//"_botzsfx.fits", >> extractobjectslist)
        print(substr(in, 1, strlen(in)-5)//"_botzsfx.fits >> extractobjectslist", >> logfile)
        print(substr(in, 1, strlen(in)-5)//"_botzsfx_ec.fits", >> dispcorlist)
        print(substr(in, 1, strlen(in)-5)//"_botzsfx_ec.fits >> dispcorlist", >> logfile)
        print(substr(in, 1, strlen(in)-5)//"_botzsfx_ecd.fits", >> objects_ecd_list)
        print(substr(in, 1, strlen(in)-5)//"_botzsfx_ecd.fits >> objects_ecd_list", >> logfile)
      }
      else{
        print(in//"_bot", >> subzerolist)
        print(in//"_bot >> subzerolist", >> logfile)
        print(in//"_botz", >> subscatterobjectslist)
        print(in//"_botz >> subscatterobjectslist", >> logfile)
        print(in//"_botzs", >> divflatlist)
        print(in//"_botzs >> divflatlist", >> logfile)
        print(in//"_botzsf", >> cosmiclist)
        print(in//"_botzsf >> cosmiclist", >> logfile)
        print(in//"_botzsfx", >> extractobjectslist)
        print(in//"_botzsfx >> extractobjectslist", >> logfile)
        print(in//"_botzsfx_ec", >> dispcorlist)
        print(in//"_botzsfx_ec >> dispcorlist", >> logfile)
        print(in//"_botzsfx_ecd", >> objects_ecd_list)
        print(in//"_botzsfx_ecd >> objects_ecd_list", >> logfile)
      }
    }
  }

# --- writing aperture-definition tables for objects and ThAr's
  if (access("database/ap"//reference)){
    print("stall: running stwriteapfiles")
    print("stall: running stwriteapfiles", >> logfile)

    stwriteapfiles(reference=reference, refObs=refapObs, refThars=refapThars, loglevel=loglevel, parameterfile = parameterfile)
  }
  else{
    print("stall: ERROR: cannot access database/ap"//reference//"!")
    print("stall: ERROR: cannot access database/ap"//reference//"!", >> logfile)
    print("stall: ERROR: cannot access database/ap"//reference//"!", >> warningfile)
    print("stall: ERROR: cannot access database/ap"//reference//"!", >> errorfile)
  }

# --- processing images

# --- stzero
  if (dostzero){
    print("stall: running stzero")
    print("stall: running stzero", >> logfile)

    stzero(biasima="@"//zerolist, 
           combinedzero=combinedzero, 
	   loglevel=loglevel, 
	   parameterfile = parameterfile)
    if (access(combinedzero)){
      print("stall: stzero ready")
      print("stall: stzero ready", >> logfile)
    }
    else{
      print("stall: ERROR: cannot access "//combinedzero//"!")
      print("stall: ERROR: cannot access "//combinedzero//"!", >> logfile)
      print("stall: ERROR: cannot access "//combinedzero//"!", >> warningfile)
      print("stall: ERROR: cannot access "//combinedzero//"!", >> errorfile)
    }
  }

# --- stbadovertrim
  if (dostbadovertrim){
    print("stall: running stbadovertrim")
    print("stall: running stbadovertrim", >> logfile)
    if (access(badovertrimlist)){
      stbadovertrim(images="@"//badovertrimlist, 
		    loglevel=loglevel, 
		    parameterfile = parameterfile)
      print("stall: stbadovertrim ready")
      print("stall: stbadovertrim ready", >> logfile)
    }
    else{
      print("stall: ERROR: cannot access "//badovertrimlist//"!")
      print("stall: ERROR: cannot access "//badovertrimlist//"!", >> logfile)
      print("stall: ERROR: cannot access "//badovertrimlist//"!", >> warningfile)
      print("stall: ERROR: cannot access "//badovertrimlist//"!", >> errorfile)
    }
  }

# --- stsubzero
  if (dostsubzero){
    print("stall: running stsubzero")
    print("stall: running stsubzero", >> logfile)
    if (access(subzerolist)){
      stsubzero(inimages="@"//subzerolist, 
		loglevel=loglevel, 
		parameterfile = parameterfile)
      print("stall: stsubzero ready")
      print("stall: stsubzero ready", >> logfile)
    }
    else{
      print("stall: ERROR: cannot access "//subzerolist//"!")
      print("stall: ERROR: cannot access "//subzerolist//"!", >> logfile)
      print("stall: ERROR: cannot access "//subzerolist//"!", >> warningfile)
      print("stall: ERROR: cannot access "//subzerolist//"!", >> errorfile)
    }
  }

# --- stflat
  if (dostflat){
    print("stall: running stflat")
    print("stall: running stflat", >> logfile)
    if (access(flatlist)){
      stflat(flatimages="@"//flatlist, 
	     combinedflat=combinedflat, 
	     loglevel=loglevel, 
	     parameterfile = parameterfile)
      if (access( combinedflat )){
        print("stall: "// combinedflat //" ready")
        print("stall: "// combinedflat //" ready", >> logfile)
      }
      else{
        print("stall: ERROR: cannot access "// combinedflat //"!")
        print("stall: ERROR: cannot access "// combinedflat //"!", >> logfile)
        print("stall: ERROR: cannot access "// combinedflat //"!", >> warningfile)
        print("stall: ERROR: cannot access "// combinedflat //"!", >> errorfile)
      }
    }
    else{
      print("stall: ERROR: cannot access "//flatlist//"!")
      print("stall: ERROR: cannot access "//flatlist//"!", >> logfile)
      print("stall: ERROR: cannot access "//flatlist//"!", >> warningfile)
      print("stall: ERROR: cannot access "//flatlist//"!", >> errorfile)
    }
  }

# --- scattered light
  if (dostscatter){
    print("stall: running stscatter for objects")
    print("stall: running stscatter for objects", >> logfile)
    if (access(subscatterobjectslist)){
      stscatter(images = "@"//subscatterobjectslist, 
		reference = refapObs, 
		thar-, 
		object+,
		loglevel=loglevel, 
		parameterfile = parameterfile)
    }
    else{
      print("stall: ERROR: cannot access "// subscatterobjectslist //"!")
      print("stall: ERROR: cannot access "// subscatterobjectslist //"!", >> logfile)
      print("stall: ERROR: cannot access "// subscatterobjectslist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// subscatterobjectslist //"!", >> warningfile)  
    }
    print("stall: running stscatter for flats")
    print("stall: running stscatter for flats", >> logfile)
    if (access(subscatterflatslist)){
      stscatter(images = "@"//subscatterflatslist, 
		reference = reference, 
		thar-, 
		object-,
		loglevel=loglevel, 
		parameterfile = parameterfile)
    }
    else{
      print("stall: ERROR: cannot access "// subscatterflatslist //"!")
      print("stall: ERROR: cannot access "// subscatterflatslist //"!", >> logfile)
      print("stall: ERROR: cannot access "// subscatterflatslist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// subscatterflatslist //"!", >> warningfile)  
    }
    print("stall: running stscatter for thars")
    print("stall: running stscatter for thars", >> logfile)
    if (access(subscattertharslist)){
      stscatter(images = "@"//subscattertharslist, 
		reference = refapThars, 
		thar+, 
		object-, 
		loglevel=loglevel, 
		parameterfile = parameterfile)
    }
    else{
      print("stall: ERROR: cannot access "// subscattertharslist //"!")
      print("stall: ERROR: cannot access "// subscattertharslist //"!", >> logfile)
      print("stall: ERROR: cannot access "// subscattertharslist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// subscattertharslist //"!", >> warningfile)  
    }
  }

# --- stnflat
  if (dostnflat){
    if (access( combinedflat_s )){
      print("stall: running stnflat")
      print("stall: running stnflat", >> logfile)
      stnflat(input=combinedflat_s, 
	      loglevel=loglevel, 
	      parameterfile = parameterfile)
      if (access( normalizedflat )){
        print("stall: "// normalizedflat //" ready")
        print("stall: "// normalizedflat //" ready", >> logfile)
      }
      else{
        print("stall: ERROR: cannot access "// normalizedflat //"!")
        print("stall: ERROR: cannot access "// normalizedflat //"!", >> logfile)
        print("stall: ERROR: cannot access "// normalizedflat //"!", >> warningfile)
        print("stall: ERROR: cannot access "// normalizedflat //"!", >> errorfile)
      }
    }
    else{
      print("stall: ERROR: cannot access "// combinedflat_s //"!")
      print("stall: ERROR: cannot access "// combinedflat_s //"!", >> logfile)
      print("stall: ERROR: cannot access "// combinedflat_s //"!", >> warningfile)
      print("stall: ERROR: cannot access "// combinedflat_s //"!", >> errorfile)
      return
    }
  }
 
  if (access( divflatlist )){

# --- staddheader
    if (dostaddheader){
      staddheader(inimages="@"//divflatlist, 
		  oldfieldname="RA   ", 
		  newfieldname="RA_HMS", 
		  firststringnr=43, 
		  firstcharnottotake=" ", 
		  show+, 
		  update+)
      staddheader(inimages="@"//divflatlist, 
	          oldfieldname="RA   ", 
		  newfieldname="RA_HMS", 
		  firststringnr=43, 
		  firstcharnottotake=" ", 
		  show+, 
		  update+)
      staddheader(inimages="@"//divflatlist, 
		  oldfieldname="DEC  ", 
		  newfieldname="DEC_HMS", 
		  firststringnr=43, 
		  firstcharnottotake=" ", 
		  show+, 
		  update+)
      staddheader(inimages="@"//divflatlist, 
		  oldfieldname="DEC  ", 
		  newfieldname="DEC_HMS", 
		  firststringnr=43, 
		  firstcharnottotake=" ", 
		  show+, 
		  update+)
      staddheader(inimages="@"//divflatlist, 
		  oldfieldname="UTC  ", 
		  newfieldname="UTC_HMS", 
		  firststringnr=43, 
		  firstcharnottotake=" ", 
		  show+, 
		  update+)
      staddheader(inimages="@"//divflatlist, 
		  oldfieldname="UTC  ", 
		  newfieldname="UTC_HMS", 
		  firststringnr=43, 
		  firstcharnottotake=" ", 
		  show+, 
		  update+)
    }

# --- setjd
    if (dosetjd){
      setjd(images="@"//divflatlist, 
	    observa="vlt2", 
	    date="DATE-OBS", 
	    time="UTC", 
	    exposur="EXPTIME", 
	    ra="RA_HMS", 
	    dec="DEC_HMS", 
	    epoch="EQUINOX", 
	    jd="JD", 
	    hjd="HJD", 
	    ljd="LJD", 
	    utdate+, 
	    uttime+, 
	    listonly-)
      print("stdivflat: Julian Date set")
      if (loglevel > 2)
        print("stall: Julian Date set", >> logfile)
    } 

# --- stdivflat (+fitsnozero)
    if (dostdivflat){
      print("stall: running stdivflat")
      print("stall: running stdivflat", >> logfile)
      if (access( normalizedflat )){
        stdivflat(inimages="@"//divflatlist, 
		  loglevel=loglevel, 
		  parameterfile = parameterfile)
      }
      else{
        print("stall: ERROR: cannot access "// normalizedflat //"!")
        print("stall: ERROR: cannot access "// normalizedflat //"!", >> logfile)
        print("stall: ERROR: cannot access "// normalizedflat //"!", >> errorfile)
        print("stall: ERROR: cannot access "// normalizedflat //"!", >> warningfile)  
      }
    }
  }
  else{
    print("stall: ERROR: cannot access "// divflatlist //"!")
    print("stall: ERROR: cannot access "// divflatlist //"!", >> logfile)
    print("stall: ERROR: cannot access "// divflatlist //"!", >> errorfile)
    print("stall: ERROR: cannot access "// divflatlist //"!", >> warningfile)  
  }

# --- cosmicrays
  if (dostcosmics){
    print("stall: running stcosmics")
    print("stall: running stcosmics", >> logfile)
    if (access(cosmiclist)){
      stcosmics(images = "@"//cosmiclist, 
		loglevel=loglevel, 
		parameterfile=parameterfile)
    }
    else{
      print("stall: ERROR: cannot access "// cosmiclist //"!")
      print("stall: ERROR: cannot access "// cosmiclist //"!", >> logfile)
      print("stall: ERROR: cannot access "// cosmiclist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// cosmiclist //"!", >> warningfile)  
    }
  }

# --- hedit

  if (dohedit){
    # --- objects
    print("stall: running hedit (objects)")
    print("stall: running hedit (objects)", >> logfile)
    if (access(extractobjectslist)){
      hedit(images = "@"//extractobjectslist, 
	    fields = "IMAGETYPE", 
	    value = "object", 
	    add+, 
	    delete-, 
	    ver-, 
	    show+, 
	    update+)
    }
    else{
      print("stall: ERROR: cannot access "// extractobjectslist //"!")
      print("stall: ERROR: cannot access "// extractobjectslist //"!", >> logfile)
      print("stall: ERROR: cannot access "// extractobjectslist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// extractobjectslist //"!", >> warningfile)  
    }

    # --- thars
    print("stall: running hedit (thars)")
    print("stall: running hedit (thars)", >> logfile)
    if (access(extracttharslist)){
      hedit(images = "@"//extracttharslist, 
	    fields = "IMAGETYPE", 
	    value = "comp", 
	    add+, 
	    delete-, 
	    ver-, 
	    show+, 
	    update+)
    }
    else{
      print("stall: ERROR: cannot access "// extracttharslist //"!")
      print("stall: ERROR: cannot access "// extracttharslist //"!", >> logfile)
      print("stall: ERROR: cannot access "// extracttharslist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// extracttharslist //"!", >> warningfile)  
    }
  }

# --- extract thars
  if (doextractthars){
    print("stall: extracting thars")
    print("stall: extracting thars", >> logfile)
    if (access(extracttharslist)){
      stextract(images="@"//extracttharslist, 
		reference=refapThars, 
		thar+, 
		object-, 
		loglevel=loglevel, 
		parameterfile = parameterfile)
    }
    else{
      print("stall: ERROR: cannot access "// extracttharslist //"!")
      print("stall: ERROR: cannot access "// extracttharslist //"!", >> logfile)
      print("stall: ERROR: cannot access "// extracttharslist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// extracttharslist //"!", >> warningfile)  
    }
  }

# --- identify thars
  if (dostidentify){
    print("stall: reidentifying thars")
    print("stall: reidentifying thars", >> logfile)
    if (access(thars_ec_list)){
      stidentify(images="@"//thars_ec_list, 
	         loglevel=loglevel, 
		 parameterfile = parameterfile)
    }
    else{
      print("stall: ERROR: cannot access "// thars_ec_list //"!")
      print("stall: ERROR: cannot access "// thars_ec_list //"!", >> logfile)
      print("stall: ERROR: cannot access "// thars_ec_list //"!", >> errorfile)
      print("stall: ERROR: cannot access "// thars_ec_list //"!", >> warningfile)  
    }
  }

# --- extract objects
  if (doextractobjects){
    print("stall: extracting objects")
    print("stall: extracting objects", >> logfile)
    if (access(extractobjectslist)){
      stextract(images="@"//extractobjectslist, 
		reference=refapObs, 
		thar-, 
		object+, 
		loglevel=loglevel, 
		parameterfile = parameterfile)
    }
    else{
      print("stall: ERROR: cannot access "// extractobjectslist //"!")
      print("stall: ERROR: cannot access "// extractobjectslist //"!", >> logfile)
      print("stall: ERROR: cannot access "// extractobjectslist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// extractobjectslist //"!", >> warningfile)  
    }
  }

# --- assign reference spectra
  if (dostrefspec){
    print("stall: assigning reference spectra to objects")
    print("stall: assigning reference spectra to objects", >> logfile)
    if (access(dispcorlist)){
      if (access(thars_ec_list)){
        strefspec(images="@"//dispcorlist, 
		  reference="@"//thars_ec_list, 
		  loglevel=loglevel, 
		  parameterfile = parameterfile)
      }
      else{
        print("stall: ERROR: cannot access "// thars_ec_list //"!")
        print("stall: ERROR: cannot access "// thars_ec_list //"!", >> logfile)
        print("stall: ERROR: cannot access "// thars_ec_list //"!", >> errorfile)
        print("stall: ERROR: cannot access "// thars_ec_list //"!", >> warningfile)  
      }
    }
    else{
      print("stall: ERROR: cannot access "// dispcorlist //"!")
      print("stall: ERROR: cannot access "// dispcorlist //"!", >> logfile)
      print("stall: ERROR: cannot access "// dispcorlist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// dispcorlist //"!", >> warningfile)  
    }
  }

# --- dispcor
  if (dostdispcor){
    print("stall: correcting dispersion of object images")
    print("stall: correcting dispersion of object images", >> logfile)
    if (access(dispcorlist)){
      stdispcor(input="@"//dispcorlist, 
		loglevel=loglevel)
    }
    else{
      print("stall: ERROR: cannot access "// dispcorlist //"!")
      print("stall: ERROR: cannot access "// dispcorlist //"!", >> logfile)
      print("stall: ERROR: cannot access "// dispcorlist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// dispcorlist //"!", >> warningfile)  
    }
  }

# --- aufraeumen
  inimages = ""
  delete (infile, ver-, >& "dev$null")

end
