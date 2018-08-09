procedure stdispcor(images)

##################################################################
#                                                                #
# NAME:             stdispcor.cl                                 #
# PURPOSE:          * automatic dispersion correction            #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stdispcor(images)                            #
# INPUTS:           images: String                               #
#                     name of list containing names of           #
#                     images to correct for the dispersion:      #
#                       "objects_botzfxsEcBl.list":              #
#                         HD175640_botzfxsEcBl.fits              #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     <Entry_in_images_Root>d.<imtype>           #
#                   Log Files:                                   # 
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      04.01.2002                                   #
# LAST EDITED:      18.04.2007                                   #
#                                                                #
##################################################################

string images        = "@dispcor.list"      {prompt="List of input images"}
bool   calibs        = NO                   {prompt="Are input images calibration files"}
string errorimages   = "@dispcor_e.list"    {prompt="List of error images"}
string parameterfile = "parameterfile.prop" {prompt="Name of parameterfile"}
string instrument    = "echelle"            {prompt="Instrument ID (echelle|coude)",
                                              enum="echelle|coude"}
bool   linearize     = YES    {prompt="Linearize (interpolate) spectra? [YES|NO]"}
bool   log           = NO     {prompt="Logarithmic wavelength scale? [YES|NO]"}
bool   flux          = NO     {prompt="Conserve flux? [YES|NO]"}
bool   samedisp      = NO     {prompt="Same dispersion in all apertures? [YES|NO]"}
bool   global        = NO     {prompt="Apply global defaults? [YES|NO]"}
bool   ignoreaps     = NO     {prompt="Ignore apertures? [YES|NO]"}
bool   doerrors      = YES    {prompt="Calculate error propagation? (YES | NO)"}
bool   delinput      = NO     {prompt="Delete input images after processing?"}
string imtype        = "fits" {prompt="Image type"}
int    loglevel      = 3      {prompt="level for writing logfile"}
string logfile       = "logfile_stdispcor.log"  {prompt="Name of log file"}
string warningfile   = "warnings_stdispcor.log" {prompt="Name of warning file"}
string errorfile     = "errors_stdispcor.log"   {prompt="Name of error file"}
string *parameterlist
string *inputlist
string *errorlist
string *timelist

begin

  string parameter,parametervalue
  file   infile,errfile
  string timefile = "time.txt"
  string tempdate,tempday,temptime
  string refspec = "0"
  string in,out,bak_logfile,errin,errout,snrimage,listname
  string stcalcsnr_in = "stcalcsnr_in.list"
  string stcalcsnr_errin = "stcalcsnrerr_in.list"
  string logfile_stcalcsnr     = "logfile_stcalcsnr.log"
  string warningfile_stcalcsnr = "warningfile_stcalcsnr.log"
  string errorfile_stcalcsnr   = "errorfile_stcalcsnr.log"
  bool   found_setinst_instrument      = NO
  bool   found_disp_linearize          = NO
  bool   found_disp_log                = NO
  bool   found_disp_flux               = NO
  bool   found_disp_samedisp           = NO
  bool   found_disp_global             = NO
  bool   found_disp_ignoreaps          = NO
#  bool   found_calc_error_propagation  = NO
  int    i

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)
  if (access(warningfile))
    delete(warningfile, ver-)
  if (access(errorfile))
    delete(errorfile, ver-)

# --- set logfiles
  if (instrument == "echelle"){
    bak_logfile = echelle.logfile
    echelle.logfile = logfile
  }
  else{
    bak_logfile = kpnocoude.logfile
    kpnocoude.logfile = logfile
  }

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                correcting dispersions                  *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*                correcting dispersion                   *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- read parameterfile
  if (access(parameterfile)){

    parameterlist = parameterfile

    print ("stdispcor: **************** reading parameterfile *******************")
    if (loglevel > 2)
      print ("stdispcor: **************** reading parameterfile *******************", >> logfile)

    while (fscan (parameterlist, parameter, parametervalue) != EOF){

      if (parameter == "setinst_instrument"){
        if (parametervalue == "echelle" || parametervalue == "coude"){
          instrument = parametervalue
          print ("stdispcor: Setting "//parameter//" to "//parametervalue)
          if (loglevel > 2)
            print ("stdispcor: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
        else{
          print ("stdispcor: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value")
          print ("stdispcor: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value", >> logfile)
          print ("stdispcor: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value", >> warningfile)
        }
        found_setinst_instrument = YES
      }
#      else if (parameter == "calc_error_propagation"){
#        if (parametervalue == "YES" || parametervalue == "yes"){
#          doerrors = YES
#          print ("stdispcor: Setting doerrors to YES")
#	}
#	else{
#	  doerrors = NO
#          print ("stdispcor: Setting doerrors to NO")
#	}
#        if (loglevel > 2)
#          print ("stdispcor: Setting doerrors to "//parametervalue, >> logfile)
#        found_calc_error_propagation = YES
#      }
      else if (parameter == "disp_linearize"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          linearize = YES
          print ("stdispcor: Setting linearize to YES")
	}
	else{
	  linearize = NO
          print ("stdispcor: Setting linearize to NO")
	}
        if (loglevel > 2)
          print ("stdispcor: Setting linearize to "//parametervalue, >> logfile)
        found_disp_linearize = YES
      }
      else if (parameter == "disp_log"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          log = YES
          print ("stdispcor: Setting log to YES")
	}
	else{
	  log = NO
          print ("stdispcor: Setting log to NO")
	}
        if (loglevel > 2)
          print ("stdispcor: Setting log to "//parametervalue, >> logfile)
        found_disp_log = YES
      }
      else if (parameter == "disp_flux"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          flux = YES
          print ("stdispcor: Setting flux to YES")
	}
	else{
	  flux = NO
          print ("stdispcor: Setting flux to NO")
	}
        if (loglevel > 2)
          print ("stdispcor: Setting flux to "//parametervalue, >> logfile)
        found_disp_flux = YES
      }
      else if (parameter == "disp_samedisp"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          samedisp = YES
          print ("stdispcor: Setting samedisp to YES")
	}
	else{
	  samedisp = NO
          print ("stdispcor: Setting samedisp to NO")
	}
        if (loglevel > 2)
          print ("stdispcor: Setting samedisp to "//parametervalue, >> logfile)
        found_disp_samedisp = YES
      }
      else if (parameter == "disp_global"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          global = YES
          print ("stdispcor: Setting global to YES")
	}
	else{
	  global = NO
          print ("stdispcor: Setting global to NO")
	}
        if (loglevel > 2)
          print ("stdispcor: Setting global to "//parametervalue, >> logfile)
        found_disp_global = YES
      }
      else if (parameter == "disp_ignoreaps"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          ignoreaps = YES
          print ("stdispcor: Setting ignoreaps to YES")
	}
	else{
	  ignoreaps = NO
          print ("stdispcor: Setting ignoreaps to NO")
	}
        if (loglevel > 2)
          print ("stdispcor: Setting ignoreaps to "//parametervalue, >> logfile)
        found_disp_ignoreaps = YES
      }
    } #end while(fscan(parameterlist) != EOF)
    if (!found_setinst_instrument){
      print("stdispcor: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard")
      print("stdispcor: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard", >> logfile)
      print("stdispcor: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard", >> warningfile)
    }
#    if (!found_calc_error_propagation){
#      print("stdispcor: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard")
#      print("stdispcor: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard", >> logfile)
#      print("stdispcor: WARNING: parameter calc_error_propagation not found in parameterfile!!! -> using standard", >> warningfile)
#    }
    if (!found_disp_linearize){
      print("stdispcor: WARNING: parameter disp_linearize not found in parameterfile!!! -> using standard")
      print("stdispcor: WARNING: parameter disp_linearize not found in parameterfile!!! -> using standard", >> logfile)
      print("stdispcor: WARNING: parameter disp_linearize not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_disp_log){
      print("stdispcor: WARNING: parameter disp_log not found in parameterfile!!! -> using standard")
      print("stdispcor: WARNING: parameter disp_log not found in parameterfile!!! -> using standard", >> logfile)
      print("stdispcor: WARNING: parameter disp_log not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_disp_flux){
      print("stdispcor: WARNING: parameter disp_flux not found in parameterfile!!! -> using standard")
      print("stdispcor: WARNING: parameter disp_flux not found in parameterfile!!! -> using standard", >> logfile)
      print("stdispcor: WARNING: parameter disp_flux not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_disp_samedisp){
      print("stdispcor: WARNING: parameter disp_samedisp not found in parameterfile!!! -> using standard")
      print("stdispcor: WARNING: parameter disp_samedisp not found in parameterfile!!! -> using standard", >> logfile)
      print("stdispcor: WARNING: parameter disp_samedisp not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_disp_global){
      print("stdispcor: WARNING: parameter disp_global not found in parameterfile!!! -> using standard")
      print("stdispcor: WARNING: parameter disp_global not found in parameterfile!!! -> using standard", >> logfile)
      print("stdispcor: WARNING: parameter disp_global not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_disp_ignoreaps){
      print("stdispcor: WARNING: parameter disp_ignoreaps not found in parameterfile!!! -> using standard")
      print("stdispcor: WARNING: parameter disp_ignoreaps not found in parameterfile!!! -> using standard", >> logfile)
      print("stdispcor: WARNING: parameter disp_ignoreaps not found in parameterfile!!! -> using standard", >> warningfile)
    }
  }
  else{
    print("stdispcor: WARNING: parameterfile <"//parameterfile//"> not found!!! -> using standard parameters")
    print("stdispcor: WARNING: parameterfile <"//parameterfile//"> not found!!! -> using standard parameters", >> logfile)
    print("stdispcor: WARNING: parameterfile <"//parameterfile//"> not found!!! -> using standard parameters", >> warningfile)
  }

# --- set doerrors to NO if calibs == YES
  if (calibs){
    doerrors = NO
    print ("stdispcor: Input images are calibration files => Setting doerrors to NO")
    if (loglevel > 2)
      print ("stdispcor: Setting doerrors to NO", >> logfile)
  }


# --- Erzeugen von temporaeren Filenamen
  print("stdispcor: building temp-filenames")
  if (loglevel > 2)
    print("stdispcor: building temp-filenames", >> logfile)
  infile  = mktemp ("tmp")
  errfile = mktemp ("tmp")
 
# --- Umwandeln der Listen von Frames in temporaere Files
  print("stdispcor: building lists from temp-files")
  if (loglevel > 2)
    print("stdispcor: building lists from temp-files", >> logfile)

  if (substr(images,1,1) == "@"){
    listname = substr(images,2,strlen(images))
  }
  else{
    listname = images
  }
  if (!access(listname)){
    print("stdispcor: ERROR: images <"//listname//"> not found!!!")
    print("stdispcor: ERROR: images <"//listname//"> not found!!!", >> logfile)
    print("stdispcor: ERROR: images <"//listname//"> not found!!!", >> errorfile)
    print("stdispcor: ERROR: images <"//listname//"> not found!!!", >> warningfile)
# --- clean up and return
    if (instrument == "echelle")
      echelle.logfile = bak_logfile
    else
      kpnocoude.logfile = bak_logfile
    inputlist     = ""
    errorlist     = ""
    timelist      = ""
    parameterlist = ""
    delete (infile, ver-, >& "dev$null")
    delete (errfile, ver-, >& "dev$null")
    return
  }
  sections(images, option="root", > infile)
  inputlist = infile

  if (doerrors){
    if (substr(errorimages,1,1) == "@"){
      listname = substr(errorimages,2,strlen(errorimages))
    }
    else
      listname = errorimages
    if (!access(listname)){
      print("stdispcor: ERROR: errorimages <"//listname//"> not found!!!")
      print("stdispcor: ERROR: errorimages <"//listname//"> not found!!!", >> logfile)
      print("stdispcor: ERROR: errorimages <"//listname//"> not found!!!", >> errorfile)
      print("stdispcor: ERROR: errorimages <"//listname//"> not found!!!", >> warningfile)
# --- clean up and return
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      inputlist     = ""
      errorlist     = ""
      timelist      = ""
      parameterlist = ""
      delete (infile, ver-, >& "dev$null")
      delete (errfile, ver-, >& "dev$null")
      return
    }
    sections(errorimages, option="root", > errfile)
    errorlist = errfile
  }

# --- build output filenames and correct dispersions
  print("stdispcor: ******************* processing files *********************")
  if (loglevel > 2)
    print("stdispcor: ******************* processing files *********************", >> logfile)

  while (fscan (inputlist, in) != EOF){

    print("stdispcor: in = "//in)
    if (loglevel > 2)
      print("stdispcor: in = "//in, >> logfile)

    i = strlen(in)
    if (substr (in, i-strlen(imtype), i) == "."//imtype)
      out = substr(in, 1, i-strlen(imtype)-1)//"d."//imtype
    else out = in//"d"

# --- delete old outfile
    if (access(out)){
      imdel(out, ver-)
      if (access(out))
        del(out,ver-)
      if (!access(out)){
        print("stdispcor: old "//out//" deleted")
        if (loglevel > 2)
          print("stdispcor: old "//out//" deleted", >> logfile)
      }
      else{
        print("stdispcor: ERROR: cannot delete "//out)
        print("stdispcor: ERROR: cannot delete "//out, >> logfile)
        print("stdispcor: ERROR: cannot delete "//out, >> warningfile)
        print("stdispcor: ERROR: cannot delete "//out, >> errorfile)
# --- clean up and return
        if (instrument == "echelle")
          echelle.logfile = bak_logfile
        else
          kpnocoude.logfile = bak_logfile
        inputlist     = ""
        errorlist     = ""
        timelist      = ""
        parameterlist = ""
        delete (infile, ver-, >& "dev$null")
        delete (errfile, ver-, >& "dev$null")
        return
      }
    }
    
    print("stdispcor: processing "//in//", outfile = "//out)
    if (loglevel > 1)
      print("stdispcor: processing "//in//", outfile = "//out, >> logfile)

    if (!access(in)){
      print("stdispcor: ERROR: cannot access "//in)
      print("stdispcor: ERROR: cannot access "//in, >> logfile)
      print("stdispcor: ERROR: cannot access "//in, >> errorfile)
      print("stdispcor: ERROR: cannot access "//in, >> warningfile)
# --- clean up and return
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      inputlist     = ""
      errorlist     = ""
      timelist      = ""
      parameterlist = ""
      delete (infile, ver-, >& "dev$null")
      delete (errfile, ver-, >& "dev$null")
      return
    }

    dispcor(input=in, 
            output=out, 
            lineari=linearize, 
            database="database", 
            table="", 
            w1=INDEF, 
            w2=INDEF, 
            dw=INDEF, 
            nw=INDEF, 
            log=log, 
            flux=flux, 
            samedis=samedisp, 
            global=global, 
            ignorea=ignoreaps, 
            confirm-, 
            listonl-, 
            verbose+, 
            logfile=logfile)

    if (!access(out)){
      print("stdispcor: ERROR: cannot access "//out)
      print("stdispcor: ERROR: cannot access "//out, >> logfile)
      print("stdispcor: ERROR: cannot access "//out, >> warningfile)
      print("stdispcor: ERROR: cannot access "//out, >> errorfile)
# --- clean up and return
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      inputlist     = ""
      errorlist     = ""
      timelist      = ""
      parameterlist = ""
      delete (infile, ver-, >& "dev$null")
      delete (errfile, ver-, >& "dev$null")
      return
    }

    if (access(timefile))
      del(timefile, ver-)
    time(>> timefile)
    if (access(timefile)){
      timelist = timefile
      if (fscan(timelist,tempday,temptime,tempdate) != EOF){
        hedit(images=out,
              fields="STDISPCO",
              value="dispersion corrected "//tempdate//"T"//temptime,
              add+,
              addonly-,
              del-,
              ver-,
              show+,
              update+)
      }
    }
    else{
      print("stdispcor: WARNING: timefile <"//timefile//"> not accessable!")
      print("stdispcor: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
      print("stdispcor: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
    }

# --- doerrors
    if (doerrors){
      if (fscan(errorlist,errin) != EOF){
        i = strlen(errin)
        if (substr (errin, i-strlen(imtype), i) != "."//imtype)
          errin = errin//".fits"
        if (!access(errin)){
          print("stdispcor: ERROR: cannot access errin <"//errin//">")
          print("stdispcor: ERROR: cannot access errin <"//errin//">", >> logfile)
          print("stdispcor: ERROR: cannot access errin <"//errin//">", >> warningfile)
          print("stdispcor: ERROR: cannot access errin <"//errin//">", >> errorfile)
# --- clean up and return
          if (instrument == "echelle")
            echelle.logfile = bak_logfile
          else
            kpnocoude.logfile = bak_logfile
          inputlist     = ""
          errorlist     = ""
          timelist      = ""
          parameterlist = ""
          delete (infile, ver-, >& "dev$null")
          delete (errfile, ver-, >& "dev$null")
          return
        }
        errout = substr(errin, 1, i-strlen(imtype)-1)//"d."//imtype
        if (access(errout))
          del(errout, ver-)
        imgets(in,"REFSPEC1")
        refspec=imgets.value
        print("stdispcor: <REFSPEC1> of in <"//in//"> is <"//refspec//">")
        if (refspec != "0"){
          print("stdispcor: setting Image-Header parameter <REFSPEC1> of errin <"//errin//"> to <"//refspec//">")
          if (loglevel > 1)
            print("stdispcor: setting Image-Header parameter <REFSPEC1> of errin <"//errin//"> to <"//refspec//">")
          hedit(images=errin,
                fields="REFSPEC1",
                value=refspec,
                add+,
                addonly+,
                del-,
                ver-,
                show+,
                update+)
        }
        imgets(in,"REFSPEC2")
        refspec = imgets.value
        print("stdispcor: <REFSPEC2> of in <"//in//"> is <"//refspec//">")
        if (refspec != "0"){
          print("stdispcor: setting Image-Header parameter <REFSPEC2> of errin <"//errin//"> to <"//refspec//">")
          if (loglevel > 1)
            print("stdispcor: setting Image-Header parameter <REFSPEC2> of errin <"//errin//"> to <"//refspec//">")
          hedit(images=errin,
                fields="REFSPEC2",
                value=refspec,
                add+,
                addonly+,
                del-,
                ver-,
                show+,
                update+)
        }
        dispcor(input=errin, 
                output=errout, 
                lineari=linearize, 
                database="database", 
                table="", 
                w1=INDEF, 
                w2=INDEF, 
                dw=INDEF, 
                nw=INDEF, 
                log=log, 
                flux=flux, 
                samedis=samedisp, 
                global=global, 
                ignorea=ignoreaps, 
                confirm-, 
                listonl-, 
                verbose+, 
                logfile=logfile)
        if (!access(errout)){
          print("stdispcor: ERROR: cannot access errout <"//errout//">")
          print("stdispcor: ERROR: cannot access errout <"//errout//">", >> logfile)
          print("stdispcor: ERROR: cannot access errout <"//errout//">", >> warningfile)
          print("stdispcor: ERROR: cannot access errout <"//errout//">", >> errorfile)
# --- clean up and return
          if (instrument == "echelle")
            echelle.logfile = bak_logfile
          else
            kpnocoude.logfile = bak_logfile
          inputlist     = ""
          errorlist     = ""
          timelist      = ""
          parameterlist = ""
          delete (infile, ver-, >& "dev$null")
          delete (errfile, ver-, >& "dev$null")
          return
        }
        if (access(timefile))
          del(timefile, ver-)
        time(>> timefile)
        if (access(timefile)){
          timelist = timefile
          if (fscan(timelist,tempday,temptime,tempdate) != EOF){
            hedit(images=errout,
                  fields="STALL",
                  value="stdispcor: dispersion corrected "//tempdate//"T"//temptime,
                  add+,
                  addonly-,
                  del-,
                  ver-,
                  show+,
                  update+)
          }
        }
        else{
          print("stdispcor: WARNING: timefile <"//timefile//"> not accessable!")
          print("stdispcor: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
          print("stdispcor: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
        }
        print("stdispcor: errout <"//errout//"> ready")
        if (loglevel > 2)
          print("stdispcor: errout <"//errout//"> ready", >> logfile)
# --- calc snr image
#        snrimage = substr(out, 1, strlen(out)-5)//"_snr.fits"
#        if (access(snrimage))
#          del(snrimage, ver-)
#        imarith(operand1=out,
#                op="/",
#                operand2=errout,
#                result=snrimage,
#                title="SNR image for "//out,
#                divzero=0.,
#                hparams="",
#                pixtype="real",
#                calctype="real",
#                ver-,
#                noact-)
#        if (access(snrimage)){
#          print("stdispcor: snrimage <"//snrimage//"> ready")
#          if (loglevel > 2)
#            print("stdispcor: snrimage <"//snrimage//"> ready", >> logfile)
#        }
#        else{
#          print("stdispcor: ERROR: cannot access snrimage <"//snrimage//">")
#          print("stdispcor: ERROR: cannot access snrimage <"//snrimage//">", >> logfile)
#          print("stdispcor: ERROR: cannot access snrimage <"//snrimage//">", >> warningfile)
#          print("stdispcor: ERROR: cannot access snrimage <"//snrimage//">", >> errorfile)
#        }
        if (access(stcalcsnr_in))
          del(stcalcsnr_in, ver-)
        if (access(stcalcsnr_errin))
          del(stcalcsnr_errin, ver-)
        print(out, >> stcalcsnr_in)
        print(errout, >> stcalcsnr_errin)
        stcalcsnr(Images      = "@"//stcalcsnr_in,
                  ErrorImages = "@"//stcalcsnr_errin,
                  ImType      = imtype,
                  LogLevel    = loglevel,
                  LogFile     = logfile_stcalcsnr,
                  WarningFile = warningfile_stcalcsnr,
                  ErrorFile   = errorfile_stcalcsnr)
        if (access(logfile_stcalcsnr))
          cat(logfile_stcalcsnr, >> logfile)
        if (access(warningfile_stcalcsnr))
          cat(warningfile_stcalcsnr, >> logfile)
        if (access(errorfile_stcalcsnr)){
          print("stdispcor: ERROR: stcalcsnr returned with error => Returning!")
          print("stdispcor: ERROR: stcalcsnr returned with error => Returning!", >> logfile)
          print("stdispcor: ERROR: stcalcsnr returned with error => Returning!", >> warningfile)
          print("stdispcor: ERROR: stcalcsnr returned with error => Returning!", >> errorfile)
# --- clean up and return
          if (instrument == "echelle")
            echelle.logfile = bak_logfile
          else
            kpnocoude.logfile = bak_logfile
          inputlist     = ""
          errorlist     = ""
          timelist      = ""
          parameterlist = ""
          delete (infile, ver-, >& "dev$null")
          delete (errfile, ver-, >& "dev$null")
          return
        }
      }# end if (fscan(errorlist, errin) != EOF)
      else{
        print("stdispcor: ERROR: fscan(errorimages=<"//errorimages//">, errin) returned FALSE!")
        print("stdispcor: ERROR: fscan(errorimages=<"//errorimages//">, errin) returned FALSE!", >> logfile)
        print("stdispcor: ERROR: fscan(errorimages=<"//errorimages//">, errin) returned FALSE!", >> warningfile)
        print("stdispcor: ERROR: fscan(errorimages=<"//errorimages//">, errin) returned FALSE!", >> errorfile)
# --- clean up and return
        if (instrument == "echelle")
          echelle.logfile = bak_logfile
        else
          kpnocoude.logfile = bak_logfile
        inputlist     = ""
        errorlist     = ""
        timelist      = ""
        parameterlist = ""
        delete (infile, ver-, >& "dev$null")
        delete (errfile, ver-, >& "dev$null")
        return
      }
    }# end if (doerrors)
    if (delinput)
      imdel(in, ver-)
    if (delinput && access(in))
      del(in, ver-)
    print("stdispcor: ----------- "//out//" ready ------------")
    if (loglevel > 1)
      print("stdispcor: ----------- "//out//" ready ------------", >> logfile)

  } # end of while(scan(inputlist))

  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("stdispcor: stdispcor finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("stdispcor: WARNING: timefile <"//timefile//"> not accessable!")
    print("stdispcor: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("stdispcor: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- clean up
  if (instrument == "echelle")
    echelle.logfile = bak_logfile
  else
    kpnocoude.logfile = bak_logfile
  inputlist     = ""
  errorlist     = ""
  parameterlist = ""
  timelist      = ""
  delete (infile, ver-, >& "dev$null")
  delete (errfile, ver-, >& "dev$null")

end
