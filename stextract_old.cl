procedure stextract(images)

#################################################################
#                                                               #
#     This program extracts the apertures for the STELLA-       #
#                Echelle spectra automatically                  #
#                                                               #
#     Andreas Ritter, 14.12.2001                                #
#                                                               #
#################################################################

string images       = "@thars_botzf.list" {prompt="List of input images"}
string reference    = "refFlat"           {prompt="Aperture reference image"}
bool   thar         = NO                  {prompt="Are images ThAr's?"}
bool   object       = NO                  {prompt="Are images Objects's?"}
real   tharapoffset = -1.8                {prompt="Offset for aperture definition table with respect to refFlat"}
real   obsapoffset  = 6.1                 {prompt="Offset for aperture definition table with respect to refFlat"}
bool   slicer       = YES                 {prompt="Does the spectrograph use an image slicer?"}
bool   interact     = NO                  {prompt="Run task interactively?"}
bool   recenter     = NO                  {prompt="Recenter apertures?"}
bool   resize       = YES                 {prompt="Resize apertures?"}
bool   edit         = NO                  {prompt="Edit apertures?"}
bool   trace        = NO                  {prompt="Trace apertures?"}
bool   clean        = YES                 {prompt="Detect and replace bad pixels?"}

#without imageslicer:
real   ylevel    = 0.2                 {prompt="Ylevel for resize apertures in percent (without slicer)"}
#with imageslicer
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
string *aplist

begin

  string logfile             = "logfile.log"
  string errorfile           = "errors.log"
  string warningfile         = "warnings.log"
  string tharapfile          = "database/apThars"
  string obsapfile           = "database/apObs"
  string refThars            = "Thars"
  string refObs              = "Obs"
  string parameter,parametervalue,apfirst,apsecond,apthird,apfourth,apfith,apsixt
  file   infile
  string in,out,tempref
  bool   tempresize
  bool   found_extnsum         = NO
  bool   found_extylevel       = NO
  bool   found_extlower        = NO
  bool   found_extupper        = NO
  bool   found_extlsigma       = NO
  bool   found_extusigma       = NO
  bool   found_rdnoise         = NO
  bool   found_gain            = NO
  bool   found_exttharapoffset = NO
  bool   found_extobsapoffset  = NO
  bool   found_reference       = NO
  bool   found_slicer          = NO
  bool   found_extinteract     = NO
  bool   found_extrecenter     = NO
  bool   found_extresize       = NO
  bool   found_extresizeobs    = NO
  bool   found_extedit         = NO

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
        found_extnsum = YES
      }
      else if (parameter == "extylevel"){ 
        ylevel = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extylevel = YES
      }
      else if (parameter == "extlower"){ 
        lower = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extlower = YES
      }
      else if (parameter == "extupper"){ 
        upper = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extupper = YES
      }
      else if (parameter == "extlsigma"){ 
        lsigma = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extlsigma = YES
      }
      else if (parameter == "extusigma"){ 
        usigma = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extusigma = YES
      }
      else if (parameter == "rdnoise"){ 
        rdnoise = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//rdnoise)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//rdnoise, >> logfile)
        found_rdnoise = YES
      }
      else if (parameter == "gain"){ 
        gain = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//gain)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//gain, >> logfile)
        found_gain = YES
      }
      else if (parameter == "exttharapoffset"){
        tharapoffset = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//tharapoffset)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//tharapoffset, >> logfile)
        found_exttharapoffset = YES
      }
      else if (parameter == "extobsapoffset"){
        obsapoffset = real(parametervalue)
        print ("stextract: Setting "//parameter//" to "//obsapoffset)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//obsapoffset, >> logfile)
        found_extobsapoffset = YES
      }
  # --- read nonreal values
      else if (parameter == "reference"){
        reference = parametervalue
        tempref = reference
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_reference = YES
      }
      else if (parameter == "slicer"){
        if (parametervalue == "YES" || parametervalue == "yes")
	  slicer = YES
	else
	  slicer = NO
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_slicer = YES
      }
      else if (parameter == "extinteract"){
        if (parametervalue == "YES" || parametervalue == "yes")
          interact = YES
	else
          interact = NO
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extinteract = YES
      }
      else if (parameter == "extrecenter"){
        if (parametervalue == "YES" || parametervalue == "yes")
          recenter = YES
	else
          recenter = NO
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extrecenter = YES
      }
      else if (!object && parameter == "extresize"){
        if (parametervalue == "YES" || parametervalue == "yes")
          resize = YES
	else
          resize = NO
	tempresize = resize
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extresize = YES
      }
      else if (object && parameter == "extresizeobs"){
        if (parametervalue == "YES" || parametervalue == "yes")
          resize = YES
	else
          resize = NO
	tempresize = resize
        print ("stextract: Setting resize to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extresize = YES
      }
      else if (parameter == "extedit"){
        if (parametervalue == "YES" || parametervalue == "yes")
          edit = YES
	else
          edit = NO
        print ("stextract: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("stextract: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_extedit = YES
      }
    } #end while(fscan(parameterlist) != EOF)
    if (!found_extnsum){
      print("stextract: WARNING: parameter extnsum not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extnsum not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extnsum not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_extylevel){
      print("stextract: WARNING: parameter extylevel not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extylevel not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extylevel not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_extlower){
      print("stextract: WARNING: parameter extlower not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extlower not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extlower not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_extupper){
      print("stextract: WARNING: parameter extupper not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extupper not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extupper not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_extlsigma){
      print("stextract: WARNING: parameter extlsigma not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extlsigma not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extlsigma not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_extusigma){
      print("stextract: WARNING: parameter extusigma not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extusigma not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extusigma not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_rdnoise){
      print("stextract: WARNING: parameter rdnoise not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter rdnoise not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter rdnoise not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_gain){
      print("stextract: WARNING: parameter gain not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter gain not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter gain not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_exttharapoffset){
      print("stextract: WARNING: parameter exttharapoffset not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter exttharapoffset not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter exttharapoffset not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_extobsapoffset){
      print("stextract: WARNING: parameter extobsapoffset not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extobsapoffset not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extobsapoffset not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_reference){
      print("stextract: WARNING: parameter reference not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter reference not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter reference not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_slicer){
      print("stextract: WARNING: parameter slicer not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter slicer not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter slicer not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_extinteract){
      print("stextract: WARNING: parameter extinteract not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extinteract not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extinteract not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_extrecenter){
      print("stextract: WARNING: parameter extrecenter not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extrecenter not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extrecenter not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_extresize){
      print("stextract: WARNING: parameter extresize not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extresize not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extresize not found in parameterfile!!! -> using standard", >> warningfile)
    }
    if (!found_extedit){
      print("stextract: WARNING: parameter extedit not found in parameterfile!!! -> using standard")
      print("stextract: WARNING: parameter extedit not found in parameterfile!!! -> using standard", >> logfile)
      print("stextract: WARNING: parameter extedit not found in parameterfile!!! -> using standard", >> warningfile)
    }
  }
  else{
    print("stextract: WARNING: parameterfile not found!!! -> using standard parameters")
    print("stextract: WARNING: parameterfile not found!!! -> using standard parameters", >> logfile)
    print("stextract: WARNING: parameterfile not found!!! -> using standard parameters", >> warningfile)
  }

#--- change aperture definition for thars
  if (access("database/ap"//reference)){
    if (loglevel > 1)
      print("stextract: writing tharapfile and obsapfile", >> logfile)
    if (access(tharapfile)){
      del(tharapfile, ver-)
    }
    if (access(obsapfile)){
      del(obsapfile, ver-)
    }
    aplist   = "database/ap"//reference
    apfirst  = ""
    apsecond = ""
    apthird  = ""
    apfourth = ""
    apfith   = ""
    apsixt   = ""
    print("stextract: tharapoffset = "//tharapoffset)
    print("stextract: obsapoffset  = "//obsapoffset)
    while (fscan (aplist, apfirst, apsecond, apthird, apfourth, apfith, apsixt) != EOF){

      if (apfirst == "begin"){
#        print("stextract: apfirst = "//apfirst//", apsecond = "//apsecond//", apthird = "//apthird//", apfourth = "//apfourth//", apfith = "//apfith//", apsixt = "//apsixt)
        print("stextract: center("//apfourth//") = "//real(apfith) + tharapoffset)
	print(apfirst//" "//apsecond//" "//refThars//" "//apfourth//" "//real(apfith) + tharapoffset//" "//apsixt, >> tharapfile)
	print(apfirst//" "//apsecond//" "//refObs//" "//apfourth//" "//real(apfith) + obsapoffset//" "//apsixt, >> obsapfile)
      }
      else if (apfirst == "image"){
	print(apfirst//" "//refThars, >> tharapfile)        
	print(apfirst//" "//refObs, >> obsapfile)        
      }
      else if (apfirst == "center"){
	print(apfirst//" "//real(apsecond) + tharapoffset//" "//apthird, >> tharapfile)
	print(apfirst//" "//real(apsecond) + obsapoffset //" "//apthird, >> obsapfile)
      }
      else if (apfirst == "low"){
        print("stextract: "//apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt)
	print(apfirst//" "//apsecond//" "//apthird, >> tharapfile)        
	print(apfirst//" "//apsecond//" "//apthird, >> obsapfile)        
      }
      else if (apfirst == "high"){
        print("stextract: "//apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt)
	print(apfirst//" "//apsecond//" "//apthird, >> tharapfile)        
	print(apfirst//" "//apsecond//" "//apthird, >> obsapfile)        
      }
      else{
	print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> tharapfile)
	print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> obsapfile)
      }

      apfirst  = ""
      apsecond = ""
      apthird  = ""
      apfourth = ""
      apfith   = ""
      apsixt   = ""
    }
  }
  else{
    print("stextract: WARNING: file database/ap"//reference//" not found!")
    print("stextract: WARNING: file database/ap"//reference//" not found!", >> logfile)
    print("stextract: WARNING: file database/ap"//reference//" not found!", >> warningfile)
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

# --- build output filenames and extract infiles
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

# --- delete old outfile
    if (access(out)){
      imdel(out, ver-)
      if (access(out))
        del(out,ver-)
      if (!access(out)){
        print("stextract: old "//out//" deleted")
        if (loglevel > 2)
          print("stextract: old "//out//" deleted", >> logfile)
      }
      else{
        print("stextract: ERROR: cannot delete "//out)
        print("stextract: ERROR: cannot delete "//out, >> logfile)
        print("stextract: ERROR: cannot delete "//out, >> warningfile)
        print("stextract: ERROR: cannot delete "//out, >> errorfile)
      }
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
     apresize.peak   = YES
    }

    if (access(in)){
      if (thar){
	reference = refThars
	resize = NO
      }
      else if (object){
	reference = refObs
      }
      else{
	reference = tempref
	resize = tempresize
      }
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







