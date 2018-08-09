procedure soall (images)

#################################################################
#                                                               #
# This program reduces the STELLA-Echelle spectra automatically #
#                                                               #
# Andreas Ritter, 04.12.2001                                    #
#                                                               #
#################################################################

string images               = "@fits.list"                                {prompt="list of images to reduce"}
string parameterfile        = "scripts$parameterfiles/parameterfile.prop" {prompt="Path and name of parameterfile"}
#bool   dostzero             = YES                                         {prompt="Do stzero?"}
bool   dostbadovertrim      = YES                                         {prompt="Do stbadovertrim?"}
#bool   dostsubzero          = YES                                         {prompt="Do stsubzero?"}
bool   dostflat             = YES                                         {prompt="Do stflat?"}
bool   dostnflat            = YES                                         {prompt="Do stnflat?"}
bool   doaddheader          = YES                                         {prompt="Do addheader?"}
bool   dosetjd              = YES                                         {prompt="Do setjd?"}
bool   dostdivflat          = YES                                         {prompt="Do stdivflat?"}
bool   dohedit              = YES                                         {prompt="Do hedit?"}
bool   dostscatter          = YES                                         {prompt="Do stscatter?"}
bool   dostcosmics          = YES                                         {prompt="Do stcosmics?"}
bool   doextractthars       = YES                                         {prompt="Do extract thars?"}
bool   dostidentify         = YES                                         {prompt="Do stidentify?"}
bool   doextractobjects     = YES                                         {prompt="Do extract objects?"}
bool   dostrefspec          = YES                                         {prompt="Do strefspec?"}
bool   dostdispcor          = YES                                         {prompt="Do stdispcor?"}

string *inimages
string *parameterlist

begin

  bool   subscatter          = YES
#  string combinedzero        = "combinedZero.fits"
  string combinedflat        = "combinedFlat_botz.fits"
  string normalizedflat      = "normalizedFlat.fits"
  string logfile             = "logfile.log"
  string errorfile           = "errors.log"
  string warningfile         = "warnings.log"
  string flatlist            = "flats_bot.list"
  string zerolist            = "zeros.list"
  string badovertrimlist     = "stbadovertrim.list"
  string tharslist           = "thars_botf.list"
  string thars_botf_ec_list  = "thars_botf_ec.list"
#  string subzerolist         = "stsubzero.list"
  string divflatlist         = "stdivflat.list"
  string objects_botf_list   = "objects_botf.list"
  string objects_botfs_list  = "objects_botfs.list"
  string objects_x_list      
  string objects_ec_list
  string objects_ecd_list
  string parameter,parametervalue
  int loglevel               = 3
  int echelledispaxis        = 2   # vertical dispersion
  file infile
  string in

  print("****************************************************") 
  print("*                                                  *")
  print("*      Automatic data reduction for the STELLA     *")
  print("*                 ECHELLE spectra                  *")
  print("*                                                  *")
  print("*            Andreas Ritter, 07.12.2001            *")
  print("*                                                  *")
  print("****************************************************")

  time (>> logfile)

  if (access(parameterfile)){

    parameterlist = parameterfile

    print ("stall: **************** reading "//parameterfile//" *******************")
    if (loglevel > 2){
      print ("stall: **************** reading "//parameterfile//" *******************", >> logfile)
    }

    while (fscan (parameterlist, parameter, parametervalue) != EOF){
      if (parameter == "loglevel"){ 
        loglevel = real(parametervalue)
        print ("stall: Setting "//parameter//" to "//loglevel)
        if (loglevel > 2){
          print ("stall: Setting "//parameter//" to "//loglevel, >> logfile)
        }
      }
      else if (parameter == "subscatter"){ 
        if (parametervalue == "YES" || parametervalue == "yes"){
          subscatter = YES
          print ("stall: Setting "//parameter//" to YES")
          if (loglevel > 2){
            print ("stall: Setting "//parameter//" to YES", >> logfile)
          }
        }
        else{
          subscatter = NO
          print ("stall: Setting "//parameter//" to NO")
          if (loglevel > 2){
            print ("stall: Setting "//parameter//" to NO", >> logfile)
          }
        }
      }
      else if (parameter == "echelledispaxis"){ 
        echelledispaxis = real(parametervalue)
        print ("stall: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2){
          print ("stall: Setting "//parameter//" to "//parametervalue, >> logfile)
        }
      }
    }
  }
  else{
    print("stall: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters")
    print("stall: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters", >> logfile)
    print("stall: WARNING: parameterfile "//parameterfile//" not found!!! -> using standard parameters", >> warningfile)
  }


# --- set standard parameters
  if (loglevel > 2)
    print("stall: setting standard parameters", >> logfile)
  echelle.dispaxis = echelledispaxis
  ccdred.logfile   = logfile

# --- delete logfiles
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

# --- if subscatter
  if (!subscatter){
    if (loglevel > 2)
      print("stall: subscatter = NO", >> logfile)
    objects_x_list   = "objects_botfx.list"
    objects_ec_list  = "objects_botfx_ec.list"
    objects_ecd_list = "objects_botfx_ecd.list"
  }
  else{
    if (loglevel > 2)
      print("stall: subscatter = NO", >> logfile)
    objects_botfs_list  = "objects_botfs.list"
    objects_x_list      = "objects_botfsx.list"
    objects_ec_list     = "objects_botfsx_ec.list"
    objects_ecd_list    = "objects_botfsx_ecd.list"
    print("objects_botfs_list = "//objects_botfs_list)
    if (loglevel > 2){
      print("objects_botfs_list = "//objects_botfs_list, >> logfile)
    }
  }
  print("objects_x_list = "//objects_x_list)
  print("objects_ec_list = "//objects_ec_list)
  print("objects_ecd_list = "//objects_ecd_list)
  if (loglevel > 2){
    print("objects_x_list = "//objects_x_list, >> logfile)
    print("objects_ec_list = "//objects_ec_list, >> logfile)
    print("objects_ecd_list = "//objects_ecd_list, >> logfile)
  }

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
  if ( access( flatlist ))
    delete(files=flatlist, ver-)
  if ( access( zerolist ))
    delete(files=zerolist, ver-)
  if ( access( badovertrimlist ))
    delete(files=badovertrimlist, ver-)
  if ( access( tharslist ))
    delete(files=tharslist, ver-)
  if ( access( thars_botf_ec_list ))
    delete(files=thars_botf_ec_list, ver-)
#  if ( access( subzerolist ))
#    delete(files=subzerolist, ver-)
  if ( access( divflatlist ))
    delete(files=divflatlist, ver-)
  if ( access( objects_botf_list ))
    delete(files=objects_botf_list, ver-)
  if ( subscatter && access( objects_botfs_list ))
    delete(files=objects_botfs_list, ver-)
  if ( access( objects_x_list ))
    delete(files=objects_x_list, ver-)
  if ( access( objects_ec_list ))
    delete(files=objects_ec_list, ver-)
  if ( access( objects_ecd_list ))
    delete(files=objects_ecd_list, ver-)

# --- build new lists
  print("stall: building new lists")
  if (loglevel > 2)
    print("stall: building new lists", >> logfile)
#  print(combinedzero, >> badovertrimlist)
  while ( fscan( inimages, in ) != EOF){
    if (loglevel > 2)
      print("stall: in = "// in)
  # --- flats
    if ( substr(in, 1, 4) == "flat" || substr(in, 1, 4) == "Flat"){
      print(in, >> badovertrimlist)
      if ( substr(in, strlen(in)-4, strlen(in)) == ".fits"){
#        print( substr(in, 1, strlen(in)-5)//"_bot.fits", >> subzerolist)
        print( substr(in, 1, strlen(in)-5)//"_bot.fits", >> flatlist)
      }
      else{
#        print(in//"_bot", >> subzerolist)
        print(in//"_botz", >> flatlist)
      }
    }
  # --- biases
    else if (substr(in, 1, 4) == "bias" || substr(in, 1, 4) == "Bias"){
      print(in, >> zerolist)
    }
  # --- thars
    else if (substr(in, 1, 4) == "thar" || substr(in, 1, 4) == "Thar" || substr(in, 1, 4) == "ThAr"){
      print(in, >> badovertrimlist)
      if (substr(in,strlen(in)-4,strlen(in)) == ".fits"){
#        print(substr(in, 1, strlen(in)-5)//"_bot.fits", >> subzerolist)
        print(substr(in, 1, strlen(in)-5)//"_bot.fits", >> divflatlist)
        print(substr(in, 1, strlen(in)-5)//"_botf.fits", >> tharslist)
        print(substr(in, 1, strlen(in)-5)//"_botf_ec.fits", >> thars_botf_ec_list)
      }
      else{
#        print(in//"_bot", >> subzerolist)
        print(in//"_bot", >> divflatlist)
        print(in//"_botf", >> tharslist)
      }
    }
  # --- objects
    else{   # objects
      print(in, >> badovertrimlist)
      if (substr(in, strlen(in)-4, strlen(in)) == ".fits"){
#        print(substr(in, 1, strlen(in)-5)//"_bot.fits",    >> subzerolist)
        print(substr(in, 1, strlen(in)-5)//"_bot.fits",   >> divflatlist)
        print(substr(in, 1, strlen(in)-5)//"_botf.fits",  >> objects_botf_list)
        if (subscatter){
          print(substr(in, 1, strlen(in)-5)//"_botfs.fits", >> objects_botfs_list)
          print(substr(in, 1, strlen(in)-5)//"_botfsx.fits", >> objects_x_list)
          print(substr(in, 1, strlen(in)-5)//"_botfsx_ec.fits", >> objects_ec_list)
          print(substr(in, 1, strlen(in)-5)//"_botfsx_ecd.fits", >> objects_ecd_list)
        }
        else{
          print(substr(in, 1, strlen(in)-5)//"_botfx.fits", >> objects_x_list)
          print(substr(in, 1, strlen(in)-5)//"_botfx_ec.fits", >> objects_ec_list)
          print(substr(in, 1, strlen(in)-5)//"_botfx_ecd.fits", >> objects_ecd_list)
        }
      }
      else{
#        print(in//"_bot", >> subzerolist)
        print(in//"_bot", >> divflatlist)
        print(in//"_botf", >> objects_botzf_list)
        if (subscatter){
          print(in//"_botfs", >> objects_botzfs_list)
          print(in//"_botfsx", >> objects_x_list)
          print(in//"_botfsx_ec", >> objects_ec_list)
          print(in//"_botfsx_ecd", >> objects_ecd_list)
        }
        else{
          print(in//"_botfx", >> objects_x_list)
          print(in//"_botfx_ec", >> objects_ec_list)
          print(in//"_botfx_ecd", >> objects_ecd_list)
        }
      }
    }
  }

# --- processing images

# --- stzero
#  if (dostzero){
#    print("stall: running stzero")
#    print("stall: running stzero", >> logfile)

#    stzero(biasima="@"//zerolist, loglevel=loglevel, parameterfile = parameterfile)
#    if (access(combinedzero)){
#      print("stall: stzero ready")
#      print("stall: stzero ready", >> logfile)
#    }
#    else{
#      print("stall: ERROR: cannot access "//combinedzero//"!")
#      print("stall: ERROR: cannot access "//combinedzero//"!", >> logfile)
#      print("stall: ERROR: cannot access "//combinedzero//"!", >> warningfile)
#      print("stall: ERROR: cannot access "//combinedzero//"!", >> errorfile)
#    }
#  }

# --- stbadovertrim
  if (dostbadovertrim){
    print("stall: running stbadovertrim")
    print("stall: running stbadovertrim", >> logfile)
    if (access(badovertrimlist)){
      stbadovertrim(images="@"//badovertrimlist, loglevel=loglevel, parameterfile = parameterfile)
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
#  if (dostsubzero){
#    print("stall: running stsubzero")
#    print("stall: running stsubzero", >> logfile)
#    if (access(subzerolist)){
#      stsubzero(inimages="@"//subzerolist, loglevel=loglevel)
#      print("stall: stsubzero ready")
#      print("stall: stsubzero ready", >> logfile)
#    }
#    else{
#      print("stall: ERROR: cannot access "//subzerolist//"!")
#      print("stall: ERROR: cannot access "//subzerolist//"!", >> logfile)
#      print("stall: ERROR: cannot access "//subzerolist//"!", >> warningfile)
#      print("stall: ERROR: cannot access "//subzerolist//"!", >> errorfile)
#    }
#  }

# --- stflat
  if (dostflat){
    print("stall: running stflat")
    print("stall: running stflat", >> logfile)
    if (access(flatlist)){
      stflat(flatimages="@"//flatlist, combinedflat=combinedflat, loglevel=loglevel, parameterfile = parameterfile)
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

# --- stnflat
  if (dostnflat){
    if (access( combinedflat )){
      print("stall: running stnflat")
      print("stall: running stnflat", >> logfile)
      stnflat(input=combinedflat, loglevel=loglevel, parameterfile = parameterfile)
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
      print("stall: ERROR: cannot access "// combinedflat //"!")
      print("stall: ERROR: cannot access "// combinedflat //"!", >> logfile)
      print("stall: ERROR: cannot access "// combinedflat //"!", >> warningfile)
      print("stall: ERROR: cannot access "// combinedflat //"!", >> errorfile)
      return
    }
  }
 
  if (access( divflatlist )){

# --- addheader
    if (doaddheader){
      addheader(inimages="@"//divflatlist, oldfieldname="RA   ", newfieldname="RA_HMS", firststringnr=43, firstcharnottotake=" ", show+, update+)
      addheader(inimages="@"//divflatlist, oldfieldname="RA   ", newfieldname="RA_HMS", firststringnr=43, firstcharnottotake=" ", show+, update+)
      addheader(inimages="@"//divflatlist, oldfieldname="DEC  ", newfieldname="DEC_HMS", firststringnr=43, firstcharnottotake=" ", show+, update+)
      addheader(inimages="@"//divflatlist, oldfieldname="DEC  ", newfieldname="DEC_HMS", firststringnr=43, firstcharnottotake=" ", show+, update+)
    }

# --- setjd
    if (dosetjd){
      setjd(images="@"//divflatlist, observa="vlt2", date="DATE-OBS", time="UT-OBS", exposur="EXPTIME", ra="RA", dec="DEC", epoch="EQUINOX", jd="JD-OBS", hjd="HJD-OBS", ljd="LJD", utdate+, uttime+, listonly-)
      print("stdivflat: Julian Date set")
      if (loglevel > 2)
        print("stall: Julian Date set", >> logfile)
    } 

# --- stdivflat (+fitsnozero)
    if (dostdivflat){
      print("stall: running stdivflat")
      print("stall: running stdivflat", >> logfile)
      if (access( normalizedflat )){
        stdivflat(inimages="@"//divflatlist, loglevel=loglevel, parameterfile = parameterfile)
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

# --- hedit

  if (dohedit){
    # --- objects
    print("stall: running hedit (objects)")
    print("stall: running hedit (objects)", >> logfile)
    if (access(objects_botf_list)){
      hedit(images = "@"//objects_botf_list, fields = "IMAGETYPE", value = "object", add+, delete-, ver-, show+, update+)
    }
    else{
      print("stall: ERROR: cannot access "// objects_botf_list //"!")
      print("stall: ERROR: cannot access "// objects_botf_list //"!", >> logfile)
      print("stall: ERROR: cannot access "// objects_botf_list //"!", >> errorfile)
      print("stall: ERROR: cannot access "// objects_botf_list //"!", >> warningfile)  
    }

    # --- thars
    print("stall: running hedit (thars)")
    print("stall: running hedit (thars)", >> logfile)
    if (access(tharslist)){
      hedit(images = "@"//tharslist, fields = "IMAGETYPE", value = "comp", add+, delete-, ver-, show+, update+)
    }
    else{
      print("stall: ERROR: cannot access "// tharslist //"!")
      print("stall: ERROR: cannot access "// tharslist //"!", >> logfile)
      print("stall: ERROR: cannot access "// tharslist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// tharslist //"!", >> warningfile)  
    }
  }

# --- scattered light
  if (dostscatter){
    if (subscatter){
      print("stall: running stscatter")
      print("stall: running stscatter", >> logfile)
      if (access(objects_botf_list)){
        stscatter(images = "@"//objects_botf_list, loglevel=loglevel, parameterfile = parameterfile)
      }
      else{
        print("stall: ERROR: cannot access "// objects_botf_list //"!")
        print("stall: ERROR: cannot access "// objects_botf_list //"!", >> logfile)
        print("stall: ERROR: cannot access "// objects_botf_list //"!", >> errorfile)
        print("stall: ERROR: cannot access "// objects_botf_list //"!", >> warningfile)  
      }
    }
  }

# --- cosmicrays
  if (dostcosmics){
    print("stall: running stcosmics")
    print("stall: running stcosmics", >> logfile)
    if (subscatter){
      if (access(objects_botfs_list)){
        stcosmics(images = "@"//objects_botfs_list, loglevel=loglevel, parameterfile=parameterfile)
      }
      else{
        print("stall: ERROR: cannot access "// objects_botfs_list //"!")
        print("stall: ERROR: cannot access "// objects_botfs_list //"!", >> logfile)
        print("stall: ERROR: cannot access "// objects_botfs_list //"!", >> errorfile)
        print("stall: ERROR: cannot access "// objects_botfs_list //"!", >> warningfile)  
      }
    }
    else{  # no scattered light substraction before
      if (access(objects_botf_list)){
        stcosmics(images = "@"//objects_botf_list, loglevel=loglevel, parameterfile=parameterfile)
      }
      else{
        print("stall: ERROR: cannot access "// objects_botf_list //"!")
        print("stall: ERROR: cannot access "// objects_botf_list //"!", >> logfile)
        print("stall: ERROR: cannot access "// objects_botf_list //"!", >> errorfile)
        print("stall: ERROR: cannot access "// objects_botf_list //"!", >> warningfile)  
      }
    }
  }

# --- extract thars
  if (doextractthars){
    print("stall: extracting thars")
    print("stall: extracting thars", >> logfile)
    if (access(tharslist)){
      stextract(images="@"//tharslist, thar+, loglevel=loglevel, parameterfile = parameterfile)
    }
    else{
      print("stall: ERROR: cannot access "// tharslist //"!")
      print("stall: ERROR: cannot access "// tharslist //"!", >> logfile)
      print("stall: ERROR: cannot access "// tharslist //"!", >> errorfile)
      print("stall: ERROR: cannot access "// tharslist //"!", >> warningfile)  
    }
  }

# --- identify thars
  if (dostidentify){
    print("stall: reidentifying thars")
    print("stall: reidentifying thars", >> logfile)
    if (access(thars_botf_ec_list)){
      stidentify(images="@"//thars_botf_ec_list, loglevel=loglevel, parameterfile = parameterfile)
    }
    else{
      print("stall: ERROR: cannot access "// thars_botf_ec_list //"!")
      print("stall: ERROR: cannot access "// thars_botf_ec_list //"!", >> logfile)
      print("stall: ERROR: cannot access "// thars_botf_ec_list //"!", >> errorfile)
      print("stall: ERROR: cannot access "// thars_botf_ec_list //"!", >> warningfile)  
    }
  }

# --- extract objects
  if (doextractobjects){
    print("stall: extracting objects")
    print("stall: extracting objects", >> logfile)
    if (access(objects_x_list)){
      stextract(images="@"//objects_x_list, thar-, loglevel=loglevel, parameterfile = parameterfile)
    }
    else{
      print("stall: ERROR: cannot access "// objects_x_list //"!")
      print("stall: ERROR: cannot access "// objects_x_list //"!", >> logfile)
      print("stall: ERROR: cannot access "// objects_x_list //"!", >> errorfile)
      print("stall: ERROR: cannot access "// objects_x_list //"!", >> warningfile)  
    }
  }

# --- assign reference spectra
  if (dostrefspec){
    print("stall: assigning reference spectra to objects")
    print("stall: assigning reference spectra to objects", >> logfile)
    if (access(objects_ec_list)){
      if (access(thars_botf_ec_list)){
        strefspec(images="@"//objects_ec_list, reference="@"//thars_botf_ec_list, loglevel=loglevel, parameterfile = parameterfile)
      }
      else{
        print("stall: ERROR: cannot access "// thars_botf_ec_list //"!")
        print("stall: ERROR: cannot access "// thars_botf_ec_list //"!", >> logfile)
        print("stall: ERROR: cannot access "// thars_botf_ec_list //"!", >> errorfile)
        print("stall: ERROR: cannot access "// thars_botf_ec_list //"!", >> warningfile)  
      }
    }
    else{
      print("stall: ERROR: cannot access "// objects_ec_list //"!")
      print("stall: ERROR: cannot access "// objects_ec_list //"!", >> logfile)
      print("stall: ERROR: cannot access "// objects_ec_list //"!", >> errorfile)
      print("stall: ERROR: cannot access "// objects_ec_list //"!", >> warningfile)  
    }
  }

# --- dispcor
  if (dostdispcor){
    print("stall: correcting dispersion of object images")
    print("stall: correcting dispersion of object images", >> logfile)
    if (access(objects_ec_list)){
      stdispcor(input="@"//objects_ec_list, loglevel=loglevel)
    }
    else{
      print("stall: ERROR: cannot access "// objects_ec_list //"!")
      print("stall: ERROR: cannot access "// objects_ec_list //"!", >> logfile)
      print("stall: ERROR: cannot access "// objects_ec_list //"!", >> errorfile)
      print("stall: ERROR: cannot access "// objects_ec_list //"!", >> warningfile)  
    }
  }

# --- aufraeumen
  inimages = ""
  delete (infile, ver-, >& "dev$null")

end
