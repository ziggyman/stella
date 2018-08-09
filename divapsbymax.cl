procedure divapsbymax()

#########################################################################
#                                                                       #
# NAME:                  divapsbymax                                   #
# PURPOSE:               * divides every order by its max value        #
#                                                                       #
# CATEGORY:              data reduction                                 #
# CALLING SEQUENCE:      divapsbymax,<String image>                    #
# INPUTS:                input file: <image>:                           #
#                          regular FITS file (1D)                       #
# OUTPUTS:               outfile: <image-root>_dbm.fits                 #
#                                                                       #
# IRAF VERSION:          2.11                                           #
#                                                                       #
# COPYRIGHT:             Andreas Ritter                                 #
# CONTACT:               aritter@aip.de                                 #
#                                                                       #
# LAST EDITED:           25.04.2006                                     #
#                                                                       #
#########################################################################

string images = "image.fits"   {prompt="List of images to divide orders by their max"}
string dispaxis = "1"          {prompt="Dispersion axis (1-horizontal, 2-vertical",
                                   enum="1|2"}
string *inputlist

begin
  string image,inorderstr,outorderstr,out,tempfits
  file   infile
  int    naps,npix,i
  real   max

# --- Erzeugen von temporaeren Filenamen
  infile      = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("divapsbymax: building lists from temp-files")

  if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
   sections(images, option="root", > infile)
   inputlist = infile
  }
  else{
   if (substr(images,1,1) != "@"){
    print("divapsbymax: ERROR: "//images//" not found!!!")
   }
   else{
    print("divapsbymax: ERROR: "//substr(images,2,strlen(images))//" not found!!!")

   }
# --- clean up
   delete (infile, ver-, >& "dev$null")
   inputlist     = ""
   return
  }

# --- read inputlist
  while(fscan(inputlist, image) != EOF){
    if (substr(image,strlen(image)-4,strlen(image)) != ".fits")
      image = image//".fits"
    out = substr(image, 1, strlen(image)-5)//"_dbm.fits"
    print("divapsbymax: out set to <"//out//">")
    if (access(out)){
      imdel(out, ver-)
      if (access(out))
        del(out,ver-)
      if (!access(out)){
        print("divapsbymax: old "//out//" deleted")
      }
      else{
        print("divapsbymax: ERROR: cannot delete "//out)
      }
    }
    countorders(image,
                dispaxis=dispaxis)
    naps = countorders.norders
    print("divapsbymax: <"//image//"> contains "//naps//" orders")
    countpix(image)
    npix = countpix.npixels
    print("divapsbymax: <"//image//"> contains "//npix//" orders")
# --- divide every order by its max value
      imcopy(input=image,
             output=out,
             ver-)
      print("imcopy ready")
    for (i=1;i<=naps;i+=1){
      tempfits = "temp.fits"
      if (access(tempfits))
        del(tempfits, ver-)
      inorderstr  = image//"[*,"//i//":"//i//"]"
      outorderstr = out//"[*,"//i//":"//i//"]"
      getmax(image=inorderstr)
      max = getmax.max
      print("divapsbymax: max of "//inorderstr//" = "//max)
#      imcopy(input=image//"[*,1:1]",
#             output=out,
#             ver-)
#      print("imcopy ready")
      if (!access(out)){
        print("divapsbymax: ERROR: "//out//" not found!!!")
# --- clean up
        delete (infile, ver-, >& "dev$null")
        inputlist     = ""
        return
      }
      else
        print("divapsbymax: "//image//" copied to "//out)
      print("divapsbymax: dividing "//inorderstr//" by max")
      imarith(operand1=inorderstr,
              op="/",
              operand2=max,
              result=tempfits,
              title="",
              divzero=0.,
              hparams="",
              pixtype="real",
              calctype="real",
              ver-,
              noact-)
      print("divapsbymax: imarith ready")
      imcopy(input=tempfits,
             output=outorderstr,
             verbose-)
      print("divapsbymax: "//outorderstr//" ready")
    }
  }
  if (access(tempfits))
    del(tempfits, ver-)

# --- clean up
  delete (infile, ver-, >& "dev$null")
  inputlist     = ""
  return
end
