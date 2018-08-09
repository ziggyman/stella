procedure nozero(inimages)

############################################################
#                                                          #
#  This program sets all pixel values below zero to zero   #
#                                                          #
#                                                          #
# Andreas Ritter, 23.07.02                                 #
#                                                          #
############################################################

string inimages = "@nozero.list"         {prompt="list of images to divide by flat"}
#string flat     = "normalizedFlat.fits"  {prompt="flat field"}
#int    loglevel                          {prompt="level for writing logfile"}
#string parameterfile = "scripts$parameterfile.prop" {prompt="parameterfile"}
string *imagelist
#string *parameterlist

#task $fits-nozero = "$foreign"

begin

  file   infile
  string in,out,outs
#,parameter,parametervalue
  string logfile       = "logfile"
#  string errorfile     = "errors.log"
#  string warningfile   = "warnings.log"
  int    i

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*         setting all values below zero to zero          *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*         setting all values below zero to zero          *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)


# --- read parameterfile
#  if (access(parameterfile)){

#    parameterlist = parameterfile

#    print ("stdivflat: **************** reading parameterfile *******************")
#    if (loglevel > 2)
#      print ("stdivflat: **************** reading parameterfile *******************", >> logfile)

#    while (fscan (parameterlist, parameter, parametervalue) != EOF){

#      if (parameter != "#")
#        print ("stdivflat: parameterfile: parameter="//parameter//" value="//parametervalue, >> logfile)

  # --- read real values
#      if (parameter == "loglevel"){ 
#        loglevel = real(parametervalue)
#        print ("stdivflat: Setting "//parameter//" to "//loglevel)
#        if (loglevel > 2)
#          print ("stdivflat: Setting "//parameter//" to "//loglevel, >> logfile)
#      }
  # --- read nonreal values
#    }
#  }
#  else{
#    print("stdivflat: WARNING: parameterfile not found!!! -> using standard parameters")
#    print("stdivflat: WARNING: parameterfile not found!!! -> using standard parameters", >> logfile)
#    print("stdivflat: WARNING: parameterfile not found!!! -> using standard parameters", >> warningfile)
#  }

# --- Erzeugen von temporaeren Filenamen
  print("nozero: building temp-filenames")
#  if (loglevel > 2)
    print("stdivflat: building temp-filenames", >> logfile)
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("nozero: building lists from temp-files")
#  if (loglevel > 2)
    print("nozero: building lists from temp-files", >> logfile)

  if ((substr(inimages,1,1) == "@" && access(substr(inimages,2,strlen(inimages)))) || (substr(inimages,1,1) != "@" && access(inimages))){
    sections(inimages, option="root", > infile)
    imagelist = infile
  }
  else{
   if (substr(inimages,1,1) != "@"){
    print("nozero: ERROR: "//inimages//" not found!!!")
    print("nozero: ERROR: "//inimages//" not found!!!", >> logfile)
    print("nozero: ERROR: "//inimages//" not found!!!", >> errorfile)
    print("nozero: ERROR: "//inimages//" not found!!!", >> warningfile)
   }
   else{
    print("nozero: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
    print("nozero: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!", >> logfile)
    print("nozero: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!", >> errorfile)
    print("nozero: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!", >> warningfile)
   }
   return
  }
  
# --- build output filenames and set all pixels below zero to zero
  print("nozero: ******************* processing files *********************")
#  if (loglevel > 2)
    print("nozero: ******************* processing files *********************", >> logfile)
  while (fscan (imagelist, in) != EOF){

#    print("nozero: in = "//in)
#    if (loglevel > 1)
#      print("nozero: in = "//in, >> logfile)

#    i = strlen(in)
#    if (substr (in, i-4, i) == ".fits")
#      out = substr(in, 1, i-5)//"f.fits"
#    else out = in//"f"

#    if (access(out)){
#     imdel(out, ver-)
#     print("nozero: old "//out//" deleted")
#     if (loglevel > 2)
#       print("nozero: old "//out//" deleted", >> logfile)
#    }
    
    print("nozero: processing "//in)
#    if (loglevel > 1)
      print("nozero: processing "//in, >> logfile)

    if (access(in)){
# --- setjd
#      setjd(images=in, observa="stella", date="date-obs", time="utc", exposur="exptime", ra="ra", dec="dec", epoch="equinox", jd="jd", hjd="hjd", ljd="ljd", utdate+, uttime+, listonly-)
#      print("nozero: Julian Date set")
#      if (loglevel > 2)
#        print("nozero: Julian Date set", >> logfile)

# --- fitsnozero
       fitsnozero(in)
# --- ccdproc flatcor+
#       ccdproc(images=in,output=out,noproc-,fixpix-,overscan-,trim-,zerocor-,darkcor-,flatcor+,illumco-,fringec-,readcor-,scancor-,readaxis="line",minrepl=0.,scantyp="shortscan",nscan=1,interac-,flat="normalizedFlat.fits")
#       if (access(out)){
#         fitsnozero(out)
#         print("nozero: "//out//" ready")
#         if (loglevel > 1)
#           print("nozero: "//out//" ready", >> logfile)
#       }
#       else{
#         print("nozero: ERROR: "//out//" not accessable")
#         print("nozero: ERROR: "//out//" not accessable", >> logfile)
#         print("nozero: ERROR: "//out//" not accessable", >> warningfile)
#         print("nozero: ERROR: "//out//" not accessable", >> errorfile)
#       }
#       print("-----------------------")
#       print("-----------------------", >> logfile)
    }
    else{
      print("nozero: ERROR: cannot access "//in)
      print("nozero: ERROR: cannot access "//in, >> logfile)
      print("nozero: ERROR: cannot access "//in, >> errorfile)
      print("nozero: ERROR: cannot access "//in, >> warningfile)
    }
  }

# --- Aufraeumen
#  parameterlist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")

end



