procedure stidentify(images)

##################################################################
#                                                                #
# NAME:             stidentify.cl                                #
# PURPOSE:          * automatic reidentification of the          #
#                     wavelength-calibration spectra             #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stidentify(images)                           #
# INPUTS:           images: String                               #
#                     name of list containing names of           #
#                     images to reidentify:                      #
#                       "calibs_botzfEc.list":                   #
#                         calib_01_botzfEc.fits                  #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     database/ec<input_image_name_Root>         #
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

string images        = "@calibs_botzfEc.list" {prompt="List of calibs to identify"}
string instrument    = "echelle"              {prompt="Instrument ID",
                                                enum="echelle|coude"}
string refCalib      = "refCalib_identified"  {prompt="Reference spectrum"}
string coordlist     = "linelists$thar.dat"  {prompt="Line-list file"}
real   shift         = INDEF  {prompt="Shift to add to reference features (pixels)"}
real   search        = 5.     {prompt="Search radius if shift is set to INDEF"}
real   cradius       = 5.     {prompt="Centering radius"}
real   threshold     = 10000. {prompt="Feature threshold for centering"}
bool   refit         = YES    {prompt="Refit coordinate function?"}
bool   interactive   = NO     {prompt="Run task interactively?"}
string database      = "database" {prompt="Database where reference spectrum can be found"}
bool   plotresiduals = YES    {prompt="Plot residuals to files?"}
int    loglevel      = 3      {prompt="level for writing logfile"}
string parameterfile = "parameterfile.prop"      {prompt="parameterfile"}
string logfile       = "logfile_stidentify.log"  {prompt="Name of log file"}
string warningfile   = "warnings_stidentify.log" {prompt="Name of warning file"}
string errorfile     = "errors_stidentify.log"   {prompt="Name of error file"}
string *inputlist
string *parameterlist
string *timelist

begin

  string bak_logfile
  string parameter,parametervalue,refwave,refstring
  file   infile
  string in,out,listname
  string timefile = "time.txt"
  string plotfile = ""
  string tempdate,tempday,temptime
  bool   found_setinst_instrument    = NO
  bool   found_ident_coordlist       = NO
  bool   found_ident_shift           = NO
  bool   found_ident_search          = NO
  bool   found_ident_cradius         = NO
  bool   found_ident_threshold       = NO
#  bool   found_ident_match           = NO
  bool   found_refCalib              = NO
  bool   found_ident_interactive     = NO
  bool   found_database              = NO
  bool   found_ident_refit           = NO
  bool   found_ident_plot_residuals  = NO
#  bool   found_ident_logfiles       = NO
#  bool   found_plot_residuals        = NO

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
  print ("*               identifying Calib-Spectra                 *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*               identifying Calib-Spectra                 *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- read parameterfile
  if (access(parameterfile)){

    parameterlist = parameterfile

    print ("stidentify: **************** reading parameterfile *******************")
    if (loglevel > 2)
      print ("stidentify: **************** reading parameterfile *******************", >> logfile)

    while (fscan (parameterlist, parameter, parametervalue) != EOF){

#      if (parameter != "#")
#        print ("stidentify: parameterfile: parameter="//parameter//" value="//parametervalue, >> logfile)

      if (parameter == "setinst_instrument"){
        if (parametervalue == "echelle" || parametervalue == "coude"){
          instrument = parametervalue
          print ("stidentify: Setting "//parameter//" to "//parametervalue)
#          if (loglevel > 2)
            print ("stidentify: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
        else{
          print ("stidentify: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value")
          print ("stidentify: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value", >> logfile)
          print ("stidentify: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value", >> warningfile)
        }
        found_setinst_instrument = YES
      }
      else if (parameter == "ident_coordlist"){ 
        coordlist = parametervalue
        print ("stidentify: Setting coordlist to "//parametervalue)
#        if (loglevel > 2)
          print ("stidentify: Setting coordlist to "//parametervalue, >> logfile)
        found_ident_coordlist = YES
      }
      else if (parameter == "ident_shift"){ 
        if (parametervalue == "INDEF"){
          shift = INDEF
          print ("stidentify: Setting "//parameter//" to INDEF")
#        if (loglevel > 2)
          print ("stidentify: Setting "//parameter//" to INDEF", >> logfile)
        }
        else{
          shift = real(parametervalue)
          print ("stidentify: Setting "//parameter//" to "//shift)
#        if (loglevel > 2)
          print ("stidentify: Setting "//parameter//" to "//shift, >> logfile)
        }
        found_ident_shift = YES
      }
      else if (parameter == "ident_search"){ 
        search = real(parametervalue)
        print ("stidentify: Setting "//parameter//" to "//parametervalue)
#        if (loglevel > 2)
          print ("stidentify: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ident_search = YES
      }
      else if (parameter == "ident_cradius"){ 
        cradius = real(parametervalue)
        print ("stidentify: Setting "//parameter//" to "//parametervalue)
#        if (loglevel > 2)
          print ("stidentify: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ident_cradius = YES
      }
      else if (parameter == "ident_threshold"){ 
        threshold = real(parametervalue)
        print ("stidentify: Setting "//parameter//" to "//parametervalue)
#        if (loglevel > 2)
          print ("stidentify: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ident_threshold = YES
      }
#      else if (parameter == "ident_match"){ 
#        match = real(parametervalue)
#        print ("stidentify: Setting "//parameter//" to "//match)
##        if (loglevel > 2)
#          print ("stidentify: Setting "//parameter//" to "//match, >> logfile)
#        found_ident_match = YES
#      }
      else if (parameter == "ident_refit"){ 
        if (parametervalue == "yes" || parametervalue == "Yes" || parametervalue == "YES"){
          refit = YES
          print ("stidentify: Setting "//parameter//" to YES")
          print ("stidentify: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          refit = NO
          print ("stidentify: Setting "//parameter//" to NO")
          print ("stidentify: Setting "//parameter//" to NO", >> logfile)
        }
        found_ident_refit = YES
      }
      else if (parameter == "refCalib"){
        refCalib = parametervalue
        print ("stidentify: Setting "//parameter//" to "//parametervalue)
#        if (loglevel > 2)
          print ("stidentify: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_refCalib = YES
      }
      else if (parameter == "ident_interactive"){
        if (parametervalue == "yes" || parametervalue == "Yes" || parametervalue == "YES"){
          interactive = YES
          print ("stidentify: Setting "//parameter//" to YES")
#          if (loglevel > 2)
            print ("stidentify: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          interactive = NO
          print ("stidentify: Setting interactive to NO")
#          if (loglevel > 2)
            print ("stidentify: Setting interactive to NO", >> logfile)
        }
        found_ident_interactive = YES
      }
      else if (parameter == "database"){
        database = parametervalue
        print ("stidentify: Setting "//parameter//" to "//parametervalue)
#        if (loglevel > 2)
          print ("stidentify: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_database = YES
      }
      else if (parameter == "ident_plot_residuals"){
        if (parametervalue == "yes" || parametervalue == "Yes" || parametervalue == "YES"){
          plotresiduals = YES
          print ("stidentify: Setting "//parameter//" to YES")
#          if (loglevel > 2)
            print ("stidentify: Setting "//parameter//" to YES", >> logfile)
        }
        else{
          plotresiduals = NO
          print ("stidentify: Setting "//parameter//" to NO")
#          if (loglevel > 2)
            print ("stidentify: Setting "//parameter//" to NO", >> logfile)
        }
        found_ident_plot_residuals = YES
      }
#      else if (parameter == "ident_logfiles"){
#        logfiles = parametervalue
#        print ("stidentify: Setting "//parameter//" to "//parametervalue)
#        if (loglevel > 2)
#          print ("stidentify: Setting "//parameter//" to "//parametervalue, >> logfile)
#        found_ident_logfiles = YES
#      }
    } #end while(fscan(parameterlist) != EOF)
    if (!found_setinst_instrument){
      print("stidentify: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ident_coordlist){
      print("stidentify: WARNING: parameter ident_coordlist not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter ident_coordlist not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter ident_coordlist not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ident_shift){
      print("stidentify: WARNING: parameter ident_shift not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter ident_shift not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter ident_shift not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ident_search){
      print("stidentify: WARNING: parameter ident_search not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter ident_search not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter ident_search not found in parameterfile!!! -> using standard", >> warningfile)
    }
#    if (!found_ident_match){
#      print("stidentify: WARNING: parameter ident_match not found in parameterfile!!! -> using standard")
#      print("stidentify: WARNING: parameter ident_match not found in parameterfile!!! -> using standard", >> logfile)
#      print("stidentify: WARNING: parameter ident_match not found in parameterfile!!! -> using standard", >> warningfile)
#    }
    if (!found_ident_cradius){
      print("stidentify: WARNING: parameter ident_cradius not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter ident_cradius not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter ident_cradius not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ident_threshold){
      print("stidentify: WARNING: parameter ident_threshold not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter ident_threshold not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter ident_threshold not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ident_refit){
      print("stidentify: WARNING: parameter ident_refit not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter ident_refit not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter ident_refit not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_refCalib){
      print("stidentify: WARNING: parameter refCalib not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter refCalib not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter refCalib not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ident_interactive){
      print("stidentify: WARNING: parameter ident_interactive not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter ident_interactive not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter ident_interactive not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_database){
      print("stidentify: WARNING: parameter database not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter database not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter database not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ident_plot_residuals){
      print("stidentify: WARNING: parameter ident_plot_residuals not found in parameterfile!!! -> using standard")
      print("stidentify: WARNING: parameter ident_plot_residuals not found in parameterfile!!! -> using standard", >> logfile)
      print("stidentify: WARNING: parameter ident_plot_residuals not found in parameterfile!!! -> using standard", >> warningfile)
    }
#    if (!found_ident_logfiles){
#      print("stidentify: WARNING: parameter ident_logfiles not found in parameterfile!!! -> using standard")
#      print("stidentify: WARNING: parameter ident_logfiles not found in parameterfile!!! -> using standard", >> logfile)
#      print("stidentify: WARNING: parameter ident_logfiles not found in parameterfile!!! -> using standard", >> warningfile)
#    }
  }
  else{
    print("stidentify: WARNING: parameterfile not found!!! -> using standard parameters")
    print("stidentify: WARNING: parameterfile not found!!! -> using standard parameters", >> logfile)
    print("stidentify: WARNING: parameterfile not found!!! -> using standard parameters", >> warningfile)
  }

# --- set logfiles
  if (instrument == "echelle"){
    bak_logfile = echelle.logfile
    echelle.logfile = logfile
  }
  else{
    bak_logfile = kpnocoude.logfile
    kpnocoude.logfile = logfile
  }

# --- Erzeugen von temporaeren Filenamen
  print("stidentify: building temp-filenames")
  if (loglevel > 2)
    print("stidentify: building temp-filenames", >> logfile)
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stidentify: building lists from temp-files")
  if (loglevel > 2)
    print("stidentify: building lists from temp-files", >> logfile)

  if (substr(images,1,1) == "@")
    listname = substr(images,2,strlen(images))
  else
    listname = images
  if (access(listname)){
    sections("@"//listname, option="root", > infile)
    inputlist = infile
  }
  else{
    print("stidentify: ERROR: "//images//" not found!!!")
    print("stidentify: ERROR: "//images//" not found!!!", >> logfile)
    print("stidentify: ERROR: "//images//" not found!!!", >> errorfile)
    print("stidentify: ERROR: "//images//" not found!!!", >> warningfile)

# --- clean up
    if (instrument == "echelle")
      echelle.logfile = bak_logfile
    else
      kpnocoude.logfile = bak_logfile
    inputlist     = ""
    parameterlist = ""
    timelist      = ""
    delete (infile, ver-, >& "dev$null")
    return
  }

# --- copy refCalib to database
  refwave = ""
  refstring = ""
  if (substr(refCalib,strlen(refCalib)-4,strlen(refCalib)) == ".fits")
    refCalib = substr(refCalib,1,strlen(refCalib)-5)
  for(i=1;i<=strlen(refCalib);i=i+1){
    if (substr(refCalib,i,i) == "/")
      refstring = ""
    else
      refstring = refstring//substr(refCalib,i,i)
  }
  if (access(refCalib)){
    if (access(database//"/"//refstring))
      del(database//"/"//refstring, ver-)
    copy(in=refCalib,
         out=database,
         ver-)
    print("stidentify: "//refCalib//" copied to "//database)
    if (loglevel > 2)
      print("stidentify: "//refCalib//" copied to "//database, >> logfile)
  }
  refwave = refstring
  if (substr(refwave,1,2) == "ec" || substr(refwave,1,2) == "id")
    refwave = substr(refwave,3,strlen(refwave))
  print("stidentify: refwave = "//refwave)
  if (loglevel > 2)
    print("stidentify: refwave = "//refwave, >> logfile)

# --- reidentify calibs
  print("stidentify: ******************* processing files *********************")
  if (loglevel > 2)
    print("stidentify: ******************* processing files *********************", >> logfile)

  while (fscan (inputlist, in) != EOF){

    print("stidentify: processing "//in)
    if (loglevel > 1)
      print("stidentify: processing "//in, >> logfile)

    if (!access(in)){
      print("stidentify: ERROR: cannot access "//in)
      print("stidentify: ERROR: cannot access "//in, >> logfile)
      print("stidentify: ERROR: cannot access "//in, >> errorfile)
      print("stidentify: ERROR: cannot access "//in, >> warningfile)
# --- clean up
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      inputlist     = ""
      parameterlist = ""
      timelist      = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
# --- echelle
    if (instrument == "echelle"){
      if (!access("database/ec"//refwave)){
        print("stidentify: ERROR: cannot access database/ec"//refwave)
        print("stidentify: ERROR: cannot access database/ec"//refwave, >> logfile)
        print("stidentify: ERROR: cannot access database/ec"//refwave, >> warningfile)
        print("stidentify: ERROR: cannot access database/ec"//refwave, >> errorfile)
# --- clean up
        if (instrument == "echelle")
          echelle.logfile = bak_logfile
        else
          kpnocoude.logfile = bak_logfile
        inputlist     = ""
        parameterlist = ""
        timelist      = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
      flpr
      ecreidentify(images=in, 
                   reference=refwave, 
                   shift=shift, 
                   cradius=cradius, 
                   threshold=threshold, 
                   refit=refit, 
                   database=database, 
                   logfile=logfile)
      print("stidentify: ----------- ready ------------")
      if (loglevel > 2)
        print("stidentify: ----------- ready ------------", >> logfile)
#        }
    }#end if (instrument == "echelle"){
    else{
# --- coude
      if (!access(database//"/id"//refwave)){
        print("stidentify: ERROR: cannot access database/id"//refwave)
        print("stidentify: ERROR: cannot access database/id"//refwave, >> logfile)
        print("stidentify: ERROR: cannot access database/id"//refwave, >> warningfile)
        print("stidentify: ERROR: cannot access database/id"//refwave, >> errorfile)
# --- clean up
        if (instrument == "echelle")
          echelle.logfile = bak_logfile
        else
          kpnocoude.logfile = bak_logfile
        inputlist     = ""
        parameterlist = ""
        timelist      = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
#        for (i=0-search; i<=search; i=i+1){
#          shift = i
      if (plotresiduals){
        strlastpos(in,'.')
        plotfile = substr(in,1,strlastpos.pos)//"res"
      }
      flpr
      reidentify(images = in,
                 reference = refwave,
                 interac = interactive,
                 section = "middle line",
                 newaps-,
                 overrid+,
                 refit = refit,
                 trace-,
                 nsum = 10,
                 shift = shift,
                 search = search,
                 cradius = cradius,
                 threshold = threshold,
                 addfeat-,
                  coordli = coordlist,
#                   match = match,
#                   maxfeat = maxfeatures,
#                   minsep = minsep,
                 database = database,
                 logfile = logfile,
                 plotfil = plotfile,
                 verbose-,
                 graphic = "stdgraph",
                 cursor = "",
                 answer = "YES",
                 crval = INDEF,
                 cdelt = INDEF)
      print("stidentify: ----------- ready ------------")
      if (loglevel > 2)
        print("stidentify: ----------- ready ------------", >> logfile)
    }# end if (instrument != "echelle"){

    if (access(timefile))
      del(timefile, ver-)
    time(>> timefile)
    if (access(timefile)){
      timelist = timefile
      if (fscan(timelist,tempday,temptime,tempdate) != EOF){
        hedit(images=in,
              fields="STALL",
              value="stidentify: wavelength calibrated "//tempdate//"T"//temptime,
              add+,
              addonly+,
              del-,
              ver-,
              show+,
              update+)
      }
    }
    else{
      print("stidentify: WARNING: timefile <"//timefile//"> not accessable!")
      print("stidentify: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
      print("stidentify: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
    }

  } # end of while(scan(inputlist))

  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("stidentify: stidentify finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("stidentify: WARNING: timefile <"//timefile//"> not accessable!")
    print("stidentify: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("stidentify: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- clean up
  if (instrument == "echelle")
    echelle.logfile = bak_logfile
  else
    kpnocoude.logfile = bak_logfile
  inputlist     = ""
  parameterlist = ""
  timelist      = ""
  delete (infile, ver-, >& "dev$null")

end
