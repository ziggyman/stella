procedure sttrim (images)

##################################################
#                                                #
# This program unbins the STELLA echelle images. #
# outputs = *t.fits                              #
#                                                #
# Andreas Ritter, 11.12.2005                     #
#                                                #
##################################################

string images        = "@unbin.list"                  {prompt="List of images to trim"}
string newsizeim     = "bias0001.fits"                {prompt="Name of input image with the size of the new, unbinned image"}
string imsec         = "[2148,2052]"                 {prompt="Trim data section"}
#string logfile       = "logfile_sttrim.log"          {prompt="Name of log file"}
#string warningfile   = "warnings_sttrim.log"         {prompt="Name of warning file"}
#string errorfile     = "errors_sttrim.log"           {prompt="Name of error file"}
string *imagelist
#string *ccdlistlist

begin

  file   infile
  string in,out,ccdlistfile,xrange,yrange,line
  int    i,j,xrangeint,yrangeint

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
  print ("*                       unbin.cl                         *")
  print ("*                 (unbins input images)                  *")
  print ("*                                                        *")
  print ("**********************************************************")
#  print ("**********************************************************", >> logfile)
#  print ("*                                                        *", >> logfile)
#  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
#  print ("*                                                        *", >> logfile)
#  print ("*                       unbin.cl                         *", >> logfile)
#  print ("*                 (unbins input images)                  *", >> logfile)
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
      out = substr(in, 1, i-5)//"u.fits"
    else out = in//"t"

    if (access(out)){
     imdel(out,ver-)
     print(out//" deleted")
    }

    imcopy(input=newsizeim,
           output=out,
           ver-)

#    ccdlistfile = "ccdlist_"//in//".text"
#    ccdlist(images=in,
#            ccdtype="",
#            names-,
#            long-
#            ccdproc-, >> ccdlistfile)
#    if (access(ccdlistfile)){
#      cclistlist = ccdlistfile
#      while(fscan(ccdlistlist, line != EOF)){
    i = 1
    while(substr(imsec,i,i) != "["){
      i = i+1
    }
    i = i+1
    j = i
    xrange = ""
    while(substr(imsec,j,j) != ","){
      xrange = xrange//substr(imsec,j,j)
      j = j+1
    }
    xrangeint = int(xrange)
    print("unbin: xrange = "//xrange//", xrangeint = "//xrangeint)
    i = j+1
    yrange = ""
    while(substr(imsec,i,i) != "]"){
      yrange = yrange//substr(imsec,i,i)
      i = i+1
    }
    yrangeint = int(yrange)
    print("unbin: yrange = "//yrange//", yrangeint = "//yrangeint)
     
    print("processing "//in//", outfile = "//out)
    imcopy(input=in,output=out//"[1:"//xrangeint//",1:"//yrangeint//"]",ver-)
    imcopy(input=in,output=out//"["//(xrangeint+1)//":"//(2*xrangeint)//",1:"//yrangeint//"]",ver-)
    ccdlist(images=out,
            ccdtype="",
            names-,
            long-,
            ccdproc-)
    for (i=1;i<=xrangeint;i+=1){
      print("unbin: copying "//in//"["//i//",1:"//yrangeint//"] to "//out//"["//((2*i)-1)//",1:"//yrangeint//"]"
      imcopy(input=in//"["//i//",1:"//yrangeint//"]",
             output=out//"["//((2*i)-1)//",1:"//yrangeint//"]",ver-)
      print("unbin: copying "//in//"["//i//",1:"//yrangeint//"] to "//out//"["//(2*i)//",1:"//yrangeint//"]"
      imcopy(input=in//"["//i//",1:"//yrangeint//"]",
             output=out//"["//(2*i)//",1:"//yrangeint//"]",ver-)
    }

  }

# --- Aufraeumen
  delete (infile, ver-, >& "dev$null")
  imagelist = ""

end
