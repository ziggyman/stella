procedure sttrim (images)

#################################################
#                                               #
# This program trims the STELLA echelle images. #
# outputs = *t.fits                             #
#                                               #
# Andreas Ritter, 13.11.2001                    #
#                                               #
#################################################

string images        = "@trim.list"                  {prompt="List of images to trim"}
#string parameterfile = "scripts$parameterfile.prop"  {prompt="Parameterfile"}
string trimsec       = "[51:2098,*]"                 {prompt="Trim data section"}
#string logfile       = "logfile_sttrim.log"          {prompt="Name of log file"}
#string warningfile   = "warnings_sttrim.log"         {prompt="Name of warning file"}
#string errorfile     = "errors_sttrim.log"           {prompt="Name of error file"}
string *imagelist
string *parameterlist
string *timelist

begin

  file   infile
  string timefile = "time.txt"
  string tempdate,tempday,temptime
  string in
  string out
  int    i

# --- delete old logfiles
#  if (access(logfile))
#    delete(logfile, ver-)
#  if (access(warningfile))
#    delete(warningfile, ver-)
#  if (access(errorfile))
#    delete(errorfile, ver-)

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                      sttrim.cl                         *")
  print ("*                 (trims input images)                   *")
  print ("*                                                        *")
  print ("**********************************************************")
#  print ("**********************************************************", >> logfile)
#  print ("*                                                        *", >> logfile)
#  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
#  print ("*                                                        *", >> logfile)
#  print ("*                      sttrim.cl                         *", >> logfile)
#  print ("*                 (trims input images)                   *", >> logfile)
#  print ("*                                                        *", >> logfile)
#  print ("**********************************************************", >> logfile)

## --- read parameterfile
#  if (access(parameterfile)){
#    print ("sttrim: **************** reading parameterfile *******************")
#    if (loglevel > 2)
#      print ("sttrim: **************** reading parameterfile *******************", >> logfile)
#    
#    parameterlist = parameterfile
#
#    while (fscan (parameterlist, parameter, parametervalue) != EOF){
#
#      if (parameter == "strimsec"){
#        normalbiasmean = real(parametervalue)       
#        print ("stzero: Setting "//parameter//" to "//normalbiasmean)
#        if (loglevel > 2)
#          print ("stzero: Setting "//parameter//" to "//normalbiasmean, >> logfile)
#        found_normalbiasmean = YES
#      }
#      else if (parameter == "normalbiasmean"){
#      }
#    }#end while
#    if (!found_normalbiasmean){
#      print("stzero: WARNING: parameter normalbiasmean not found in parameterfile!!! -> using standard")
#      print("stzero: WARNING: parameter normalbiasmean not found in parameterfile!!! -> using standard", >> logfile)
#      print("stzero: WARNING: parameter normalbiasmean not found in parameterfile!!! -> using standard", >> warningfile)
#    }

# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  sections(images, option="root", > infile)
  imagelist = infile

# --- build output filename and trim inputimages
  #print ("**************************************************")
  while (fscan (imagelist, in) != EOF){
    #print("in = "//in)
    i = strlen(in)
    if (substr (in, i-4, i) == ".fits")
      out = substr(in, 1, i-5)//"t.fits"
    else out = in//"t"

    if (access(out)){
     imdel(out,ver-)
     print(out//" deleted")
    }    

    print("processing "//in//", outfile = "//out)
    imcopy(input=in//trimsec,output=out,ver-)

    if (access(out)){
      if (access(timefile))
        del(timefile, ver-)
      time(>> timefile)
      if (access(timefile)){
        timelist = timefile
        if (fscan(timelist,tempday,temptime,tempdate) != EOF){
          hedit(images=out,
                fields="STTRIM",
                value="sttrim: image trimmed "//tempdate//"T"//temptime,
                add+,
                addonly+,
                del-,
                ver-,
                show+,
                update+)
          hedit(images=out,
                fields="STTRIMSEC",
                value=trimsec,
                add+,
                addonly+,
                del-,
                ver-,
                show+,
                update+)
        }
      }
      else{
        print("sttrim: WARNING: timefile <"//timefile//"> not accessable!")
      }
    }
    else{
      print("sttrim: WARNING: outfile <"//out//"> not accessable!")
    }
  }

# --- Aufraeumen
  delete (infile, ver-, >& "dev$null")

end
