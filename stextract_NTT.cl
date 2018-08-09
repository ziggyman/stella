procedure stextract(images)

#################################################################
#                                                               #
#     This program extracts the apertures for the STELLA-       #
#                Echelle spectra automatically                  #
#                                                               #
#     Andreas Ritter, 14.12.2001                                #
#                                                               #
#################################################################

string images    = "@thars_botzf.list" {prompt="List of input images"}
string reference = "refFlat"           {prompt="Aperture reference image"}
bool   slicer    = YES                 {prompt="Does the spectrograph use an image slicer?"}
bool   interact  = NO                  {prompt="Run task interactively?"}
bool   recenter  = NO                  {prompt="Recenter apertures?"}
bool   resize    = YES                 {prompt="Resize apertures?"}
bool   edit      = NO                  {prompt="Edit apertures?"}
bool   trace     = NO                  {prompt="Trace apertures?"}
bool   clean     = YES                 {prompt="Detect and replace bad pixels?"}

#ohne slicer:
real   ylevel    = 0.2                 {prompt="Ylevel for resize apertures in percent (without slicer)"}
#mit slicer
real   lower     = -20.                {prompt="Lower limit for apertures (with slicer)"}
real   upper     = 22.                 {prompt="Upper limit for apertures (with slicer)"}

int    nsum      = 100                 {prompt="Number of dispersion lines to sum or median"}
real   rdnoise   = 3.69                {prompt="Read out noise sigma (photons)"}
real   gain      = 0.68                {prompt="Photon gain (photons/data number)"}
real   lsigma    = 4.                  {prompt="Lower rejection threshold"}
real   usigma    = 4.                  {prompt="Upper rejection threshold"}
int    loglevel                        {prompt="level for writing logfile"}
string parameterfile = "scripts$parameterfile.prop" {prompt="parameterfile"}
string *inputlist
string *parameterlist

begin

  string logfile             = "logfile.log"
  string errorfile           = "errors.log"
  string warningfile         = "warnings.log"
  string parameter,parametervalue
  file   infile
  string in,out

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                  extracting apertures                  *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*                  extracting apertures                  *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- read parameterfile
  if (access(parameterfile)){

    parameterlist = parameterfile

    print ("stextract: **************** reading parameterfile *******************")
    if (loglevel > 2)
      print ("stextract: **************** reading parameterfile *******************", >> logfile)

    while (fscan (parameterlist, parameter, parametervalue) != EOF){

#      if (parameter != "#")
#        print ("stextract: parameterfile: parameter="//parameter//" value="//parametervalue, >> logfile)

  # --- read real values
      if (parameter == "extnsum"){ 
        nsum = int(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "extylevel"){ 
        ylevel = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "extlower"){ 
        lower = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "extupper"){ 
        upper = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "extlsigma"){ 
        lsigma = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "extusigma"){ 
        usigma = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "rdnoise"){ 
        rdnoise = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//rdnoise)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//rdnoise, >> logfile)
      }
      else if (parameter == "gain"){ 
        gain = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//gain)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//gain, >> logfile)
      }
  # --- read nonreal values
      else if (parameter == "reference"){
#        reference = parametervalue
        reference = "" #nur fuer heute!!!
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "slicer"){
        if (parametervalue == "YES" || parametervalue == "yes")
	  slicer = YES
	else
	  slicer = NO
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "extinteract"){
        if (parametervalue == "YES" || parametervalue == "yes")
          interact = YES
	else
          interact = NO
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "extrecenter"){
        if (parametervalue == "YES" || parametervalue == "yes")
          recenter = YES
	else
          recenter = NO
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "extresize"){
        if (parametervalue == "YES" || parametervalue == "yes")
          resize = YES
	else
          resize = NO
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
      else if (parameter == "extedit"){
        if (parametervalue == "YES" || parametervalue == "yes")
          edit = YES
	else
          edit = NO
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
      }
    } #end while(fscan(parameterlist) != EOF)
  }
  else{
    print("stextract: WARNING: parameterfile not found!!! -> using standard parameters")
    print("stextract: WARNING: parameterfile not found!!! -> using standard parameters", >> logfile)
    print("stextract: WARNING: parameterfile not found!!! -> using standard parameters", >> warningfile)
  }

# --- Erzeugen von temporaeren Filenamen
  print("stextract: building temp-filenames")
  if (loglevel > 2)
    print("stextract: building temp-filenames", >> logfile)
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stextract: building lists from temp-files")
  if (loglevel > 2)
    print("stextract: building lists from temp-files", >> logfile)

  if ((substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
    sections(images, option="root", > infile)
    inputlist = infile
  }
  else{
    if (substr(images,1,1) != "@"){
      print("stextract: ERROR: "//images//" not found!!!")
      print("stextract: ERROR: "//images//" not found!!!", >> logfile)
      print("stextract: ERROR: "//images//" not found!!!", >> errorfile)
      print("stextract: ERROR: "//images//" not found!!!", >> warningfile)
    }
    else{
      print("stextract: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
      print("stextract: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> logfile)
      print("stextract: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> errorfile)
      print("stextract: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> warningfile)
    }
# --- aufraeumen
    inputlist     = ""
    parameterlist = ""
    delete (infile, ver-, >& "dev$null")
    return
  }

# --- build output filenames and subtract scattered light
  print("stextract: ******************* processing files *********************")
  if (loglevel > 2)
    print("stextract: ******************* processing files *********************", >> logfile)

  while (fscan (inputlist, in) != EOF){

    print("stextract: in = "//in)
    if (loglevel > 2)
      print("stextract: in = "//in, >> logfile)

    i = strlen(in)
    if (substr (in, i-4, i) == ".fits")
      out = substr(in, 1, i-5)//"_ec.fits"
    else out = in//"_ec"

    if (access(out)){
      imdel(out,ver-)
      print("stextract: old "//out//" deleted")
      if (loglevel > 2)
        print("stextract: old "//out//" deleted", >> logfile)
    }
    
    print("stextract: processing "//in//", outfile = "//out)
    if (loglevel > 1)
      print("stextract: processing "//in//", outfile = "//out, >> logfile)

#    print("stextract: lower = "//lower//", upper = "//upper)

    if (slicer){
     if (loglevel > 2)
       print("stextract: slicer = YES, lower = "//lower//", upper = "//upper)
     apresize.llimit = lower
     apresize.ulimit = upper
     apresize.ylevel = INDEF
    }
    else{
     if (loglevel > 2)
       print("stextract: slicer = NO, ylevel = "//ylevel)
     apresize.llimit = INDEF
     apresize.ulimit = INDEF
     apresize.ylevel = ylevel
     apresize.peak = YES
    }

    if (access(in)){
      reference = substr(in,1,strlen(in)-6)
      print("stextract: reference = "//reference)
      apsum(input = in, output = out, apertur = "", format = "echelle", reference = reference, profile = "", interac = interact, find-, recenter = recenter, resize = resize, edit = edit, trace-, fittrace-, extract+, extras-, review-, line=INDEF, nsum = nsum, backgro = "none", weights = "none", pfit="fit1d", clean+, skybox=1, saturat=INDEF, readnoise = rdnoise, gain = gain, lsigma = lsigma, usigma = usigma, nsubaps = 1)

      print("stextract: -----------------------")
      print("stextract: -----------------------", >> logfile)
    }
    else{
      print("stextract: ERROR: cannot access "//in)
      print("stextract: ERROR: cannot access "//in, >> logfile)
      print("stextract: ERROR: cannot access "//in, >> errorfile)
      print("stextract: ERROR: cannot access "//in, >> warningfile)
    }
  } # end of while(scan(inputlist))

# --- aufraeumen
  inputlist     = ""
  parameterlist = ""
  delete (infile, ver-, >& "dev$null")

end







