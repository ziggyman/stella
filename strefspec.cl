procedure strefspec(images,logfile_stidentify)

##################################################################
#                                                                #
# NAME:             strefspec.cl                                 #
# PURPOSE:          * assigns the good reference-wavelength-     #
#                     calibration images to the object spectra   #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: strefspec(images,logfile_stidentify)         #
# INPUTS:           images: String                               #
#                     name of list containing names of object    #
#                     spectra to assign the wavelength-calibs to:#
#                       "objects_botzfxsEcBl.list":              #
#                         HD175640_botzfxsEcBl.fits              #
#                         ...                                    #
#                                                                #
#                   logfile_stidentify: String                   #
#                     name of logfile from stidentify.cl         #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     same as input spectra in <images>          #
#                   Log Files:                                   #
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      02.01.2002                                   #
# LAST EDITED:      18.04.2007                                   #
#                                                                #
##################################################################

string images             = "@objects_botzsfx_ec.list" {prompt="List of object spectra"}
string logfile_stidentify = "logfile_stidentify.log"   {prompt="Logfile of stidentify task"}
int    minlines   = 2000      {prompt="Minimum number of identified lines"}
real   maxrms     = 0.003     {prompt="Maximum RMS of identified lines"}
string select     = "interp"  {prompt="Selection method for reference spectra",
                                enum="match|nearest|preceding|following|interp|average"}
string sort       = "jd"      {prompt="Sort key"}
string group      = "ljd"     {prompt="Group key"}
bool   forceset   = NO        {prompt="Force setting of specified file?"}
int    loglevel   = 3         {prompt="level for writing logfile"}
string instrument = "echelle" {prompt="Instrument (echelle|coude)",
                                enum="echelle|coude"}
string imtype   = "fits"      {prompt="Image type"}
string parameterfile = "scripts$parameterfile.prop" {prompt="parameterfile"}
string logfile       = "logfile_strefspec.log"      {prompt="Name of log file"}
string warningfile   = "warnings_strefspec.log"     {prompt="Name of warning file"}
string errorfile     = "errors_strefspec.log"       {prompt="Name of error file"}
string *imagelist
string *parameterlist
string *loglist
string *goodcallist
string *timelist

begin

  file   infile
  string bak_logfile,setfile
  string parameter,parametervalue,in
  string timefile = "time.txt"
  string tempdate,tempday,temptime
  string goodcalibsfile = "goodCalibs.list"
  string image,found,fitpixshift,usershift,zshift,rmsstr
  int    nlines
  real   rms
  bool   found_ref_minlines        = NO
  bool   found_ref_maxrms          = NO
  bool   found_ref_select          = NO
  bool   found_ref_sort            = NO
  bool   found_ref_group           = NO
  bool   found_setinst_instrument  = NO
  bool   found_ref_forceset        = NO
  bool   found_imtype              = NO

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)
  if (access(warningfile))
    delete(warningfile, ver-)
  if (access(errorfile))
    delete(errorfile, ver-)

# --- Erzeugen von temporaeren Filenamen

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*             assigning reference spectra                *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*             assigning reference spectra                *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- read parameterfile
  if (access(parameterfile)){

    parameterlist = parameterfile

    print ("strefspec: **************** reading parameterfile *******************")
    if (loglevel > 2)
      print ("strefspec: **************** reading parameterfile *******************", >> logfile)

    while (fscan (parameterlist, parameter, parametervalue) != EOF){

      if (parameter == "ref_minlines"){
        minlines = int(parametervalue)
        print ("strefspec: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("strefspec: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ref_minlines = YES
      }
      if (parameter == "ref_maxrms"){
        maxrms = real(parametervalue)
        print ("strefspec: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("strefspec: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ref_maxrms = YES
      }
      else if (parameter == "ref_select"){
        select = parametervalue
        print ("strefspec: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("strefspec: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ref_select = YES
      }
      else if (parameter == "ref_sort"){
        sort = parametervalue
        print ("strefspec: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("strefspec: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ref_sort = YES
      }
      else if (parameter == "ref_group"){
        group = parametervalue
        print ("strefspec: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("strefspec: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ref_group = YES
      }
      else if (parameter == "setinst_instrument"){
        if (parametervalue == "echelle" || parametervalue == "coude"){
          instrument = parametervalue
          print ("strefspec: Setting "//parameter//" to "//parametervalue)
          if (loglevel > 2)
            print ("strefspec: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
        else{
          print ("strefspec: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value")
          print ("strefspec: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value", >> logfile)
          print ("strefspec: WARNING: value of parameter setinst_instrument not equal to ECHELLE or COUDE -> using standard value", >> warningfile)
        }
        found_setinst_instrument = YES
      }
      else if (parameter == "ref_forceset"){
        if (parametervalue == "YES" || parametervalue == "yes"){
          forceset = YES
          print ("strefspec: Setting forceset to YES")
          if(loglevel > 2)
            print ("strefspec: Setting forceset to YES", >> logfile)
        }
        else{
          forceset = NO
          print ("strefspec: Setting forceset to NO")
          if(loglevel > 2)
            print ("strefspec: Setting forceset to NO", >> logfile)
        }
        found_ref_forceset = YES
      }
      else if (parameter == "imtype"){
        imtype = parametervalue
        print ("strefspec: Setting imtype to "//imtype)
        if (loglevel > 2)
          print ("strefspec: Setting imtype to "//imtype, >> logfile)
        found_imtype = YES
      }
    } #end while(fscan(parameterlist) != EOF)
    if (!found_ref_minlines){
      print("strefspec: WARNING: parameter ref_minlines not found in parameterfile!!! -> using standard")
      print("strefspec: WARNING: parameter ref_minlines not found in parameterfile!!! -> using standard", >> logfile)
      print("strefspec: WARNING: parameter ref_minlines not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ref_maxrms){
      print("strefspec: WARNING: parameter ref_maxrms not found in parameterfile!!! -> using standard")
      print("strefspec: WARNING: parameter ref_maxrms not found in parameterfile!!! -> using standard", >> logfile)
      print("strefspec: WARNING: parameter ref_maxrms not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ref_select){
      print("strefspec: WARNING: parameter ref_select not found in parameterfile!!! -> using standard")
      print("strefspec: WARNING: parameter ref_select not found in parameterfile!!! -> using standard", >> logfile)
      print("strefspec: WARNING: parameter ref_select not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ref_sort){
      print("strefspec: WARNING: parameter ref_sort not found in parameterfile!!! -> using standard")
      print("strefspec: WARNING: parameter ref_sort not found in parameterfile!!! -> using standard", >> logfile)
      print("strefspec: WARNING: parameter ref_sort not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ref_group){
      print("strefspec: WARNING: parameter ref_group not found in parameterfile!!! -> using standard")
      print("strefspec: WARNING: parameter ref_group not found in parameterfile!!! -> using standard", >> logfile)
      print("strefspec: WARNING: parameter ref_group not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_setinst_instrument){
      print("strefspec: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard")
      print("strefspec: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard", >> logfile)
      print("strefspec: WARNING: parameter setinst_instrument not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_ref_forceset){
      print("strefspec: WARNING: parameter ref_forceset not found in parameterfile!!! -> using standard")
      print("strefspec: WARNING: parameter ref_forceset not found in parameterfile!!! -> using standard", >> logfile)
      print("strefspec: WARNING: parameter ref_forceset not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_imtype){
      print("strefspec: WARNING: parameter imtype not found in parameterfile!!! -> using standard")
      print("strefspec: WARNING: parameter imtype not found in parameterfile!!! -> using standard", >> logfile)
      print("strefspec: WARNING: parameter imtype not found in parameterfile!!! -> using standard", >> warningfile)
    }
  }
  else{
    print("strefspec: WARNING: parameterfile not found!!! -> using standard parameters")
    print("strefspec: WARNING: parameterfile not found!!! -> using standard parameters", >> logfile)
    print("strefspec: WARNING: parameterfile not found!!! -> using standard parameters", >> warningfile)
  }

# --- set logfiles
  if (instrument == "echelle"){
    echelle
    bak_logfile = echelle.logfile
    echelle.logfile = logfile
  }
  else{
    kpnocoude
    bak_logfile = kpnocoude.logfile
    kpnocoude.logfile = logfile
  }

# --- throw away bad calibs
  print("strefspec: ***************** Error calculation ********************")
  if (loglevel > 2)
    print("strefspec: ***************** Error calculation ********************", >> logfile)
  print("strefspec: reading logfile_stidentify <"//logfile_stidentify//">")
  if (loglevel > 2)
    print("strefspec: reading logfile_stidentify <"//logfile_stidentify//">", >> logfile)
  loglist = logfile_stidentify

  if (access(goodcalibsfile)){
    delete(goodcalibsfile, ver-)
    print("strefspec: old goodcalibsfile deleted")
    if (loglevel > 2)
      print("strefspec: old goodcalibsfile deleted", >> logfile)
  }

  while (fscan (loglist, image, found, fitpixshift, usershift, zshift, rmsstr) != EOF){
    if (image == "Image"){
      if (found == "Found"){
        if (fscan (loglist, image, found, fitpixshift, usershift, zshift, rmsstr) != EOF){
          strpos(tempstring = found, substring = "/")
          found = substr(found, 1, strpos.pos-1)
          print("strefspec: "//image//": "//found//" lines found")
          nlines = int(found)
          if (nlines < minlines){
            print("strefspec: WARNING: Not enough lines found in image "//image//" => Throwing away!")
            print("strefspec: WARNING: Not enough lines found in image "//image//" => Throwing away!", >> logfile)
            print("strefspec: WARNING: Not enough lines found in image "//image//" => Throwing away!", >> warningfile)
          }
          else{
            rms = real(rmsstr)
            if (rms < maxrms){
              print(image//"."//imtype, >> goodcalibsfile)
            }
            else{
              print("strefspec: WARNING: RMS of image "//image//"(="//rms//" > "//maxrms//") to high => Throwing away!")
              print("strefspec: WARNING: RMS of image "//image//"(="//rms//" > "//maxrms//") to high => Throwing away!", >> logfile)
              print("strefspec: WARNING: RMS of image "//image//"(="//rms//" > "//maxrms//") to high => Throwing away!", >> warningfile)
            }
          }
        }
      }
    }
  }

# --- assign reference spectra
  if (substr(images,1,1) == "@")
    images = substr(images,2,strlen(images))
  if (!access(images)){
    print("strefspec: ERROR: "//images//" not found!!!")
    print("strefspec: ERROR: "//images//" not found!!!", >> logfile)
    print("strefspec: ERROR: "//images//" not found!!!", >> errorfile)
    print("strefspec: ERROR: "//images//" not found!!!", >> warningfile)
# --- clean up
    if (instrument == "echelle")
      echelle.logfile = bak_logfile
    else
      kpnocoude.logfile = bak_logfile
    parameterlist = ""
    imagelist     = ""
#    goodcallist   = ""
    timelist      = ""
  }
  infile = mktemp ("tmp")
  sections("@"//images, option="root", > infile)
  imagelist = infile
  if (!access(goodcalibsfile)){
    print("strefspec: ERROR: "//goodcalibsfile//" not found!!!")
    print("strefspec: ERROR: "//goodcalibsfile//" not found!!!", >> logfile)
    print("strefspec: ERROR: "//goodcalibsfile//" not found!!!", >> errorfile)
    print("strefspec: ERROR: "//goodcalibsfile//" not found!!!", >> warningfile)
# --- clean up
    if (instrument == "echelle")
      echelle.logfile = bak_logfile
    else
      kpnocoude.logfile = bak_logfile
    parameterlist = ""
    imagelist     = ""
#    goodcallist   = ""
    timelist      = ""
    del (infile, ver-, >& "dev$null")
  }

  # --- find first calibration file in goodcallist to assign if refspectra fails
  goodcallist = goodcalibsfile
  if (fscan(goodcallist, setfile) != EOF){
    print("strefspec: substr(setfile, strlen(setfile)-strlen(imtype), strlen(setfile)) = "//substr(setfile, strlen(setfile)-strlen(imtype), strlen(setfile)))
    print("strefspec: substr(setfile, strlen(setfile)-strlen(imtype), strlen(setfile)) = "//substr(setfile, strlen(setfile)-strlen(imtype), strlen(setfile)), >> logfile)
    if (substr(setfile, strlen(setfile)-strlen(imtype), strlen(setfile)) == "."//imtype){
      setfile = substr(setfile, 1, strlen(setfile)-strlen(imtype)-1)
    }
    goodcallist = ""
    print("strefspec: file to set if refspec fails = <"//setfile//">")
    if (loglevel > 2)
      print("strefspec: file to set if refspec fails = <"//setfile//">", >> logfile)
  }
  else{
    print("strefspec: ERROR: "//goodcalibsfile//" is empty!!!")
    print("strefspec: ERROR: "//goodcalibsfile//" is empty!!!", >> logfile)
    print("strefspec: ERROR: "//goodcalibsfile//" is empty!!!", >> errorfile)
    print("strefspec: ERROR: "//goodcalibsfile//" is empty!!!", >> warningfile)
# --- clean up
    if (instrument == "echelle")
      echelle.logfile = bak_logfile
    else
      kpnocoude.logfile = bak_logfile
    parameterlist = ""
    imagelist     = ""
e    timelist      = ""
    del (infile, ver-, >& "dev$null")
  }
  print("strefspec: starting refspec")
  if (loglevel > 2)
  print("strefspec: starting refspec", >> logfile)

  while (fscan (imagelist, in) != EOF){

    # --- delete previously assigned reference spectra
    print("strefspec: processing "//in)
    if (loglevel > 2)
      print("strefspec: processing "//in, >> logfile)
    imgets(in,"REFSPEC1")
    if (imgets.value != "0"){
      hedit(images=in,
            fields="REFSPEC1",
            value=setfile,
            add-,
            addonly-,
            del+,
            ver-,
            show+,
            update+)
    }
    flpr
    flpr
    jobs
    wait()

    # --- assign reference spectra
    print("strefspec: starting refspectra("//in//", @"//goodcalibsfile//",...")
    refspectra(input=in,
               reference="@"//goodcalibsfile,
               apertur="",
               refaps="",
               ignorea+,
               select=select,
               sort=sort,
               group=group,
               time-,
               override+,
               confirm-,
               assign+,
               logfile=logfile,
               verbose-,
               answer="YES")
    print("strefspec: refspectra ready")
    imgets(in,"REFSPEC1")
    if (imgets.value == "0"){
      print("strefspec: WARNING: No reference spectra found")
      print("strefspec: WARNING: No reference spectra found", >> logfile)
      print("strefspec: WARNING: No reference spectra found", >> warningfile)
      if (forceset){
        print("strefspec: Forcing setting of first reference spectrum")
        print("strefspec: Forcing setting of first reference spectrum", >> logfile)
        hedit(images=in,
              fields="REFSPEC1",
              value=setfile,
              add+,
              addonly-,
              del-,
              ver-,
              show+,
              update+)
      }
    }

    if (access(timefile))
      del(timefile, ver-)
    time(>> timefile)
    if (access(timefile)){
      timelist = timefile
      if (fscan(timelist,tempday,temptime,tempdate) != EOF){
        hedit(images=in,
              fields="STALL",
              value="strefspec: reference wavelength calibration file assigned "//tempdate//"T"//temptime,
              add+,
              addonly+,
              del-,
              ver-,
              show+,
              update+)
      }
    }
    else{
      print("strefspec: WARNING: timefile <"//timefile//"> not accessable!")
      print("strefspec: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
      print("strefspec: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
    }
  }

  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("strefspec: strefspec finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("strefspec: WARNING: timefile <"//timefile//"> not accessable!")
    print("strefspec: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("strefspec: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- clean up
  if (instrument == "echelle")
    echelle.logfile = bak_logfile
  else
    kpnocoude.logfile = bak_logfile
  parameterlist = ""
  imagelist     = ""
  timelist      = ""
  del (infile, ver-, >& "dev$null")

end
