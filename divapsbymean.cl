procedure divapsbymean()

#########################################################################
#                                                                       #
# NAME:                  divapsbymean                                   #
# PURPOSE:               * divides every order by its mean value        #
#                                                                       #
# CATEGORY:              data reduction                                 #
# CALLING SEQUENCE:      divapsbymean,<String image>                    #
# INPUTS:                input file: <image>:                           #
#                          regular FITS file                            #
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

string images = "image.fits"   {prompt="List of images to divide orders by their mean"}
string dispaxis = "1"          {prompt="Dispersion axis (1-horizontal, 2-vertical",
                                   enum="1|2"}
string *inputlist

begin
  string image,inorderstr,outorderstr,out,tempfits
  file   infile
  int    naps,npix,i
  real   mean

# --- Erzeugen von temporaeren Filenamen
  infile      = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("divapsbymean: building lists from temp-files")

  if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
   sections(images, option="root", > infile)
   inputlist = infile
  }
  else{
   if (substr(images,1,1) != "@"){
    print("divapsbymean: ERROR: "//images//" not found!!!")
   }
   else{
    print("divapsbymean: ERROR: "//substr(images,2,strlen(images))//" not found!!!")

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
    print("divapsbymean: out set to <"//out//">")
    if (access(out)){
      imdel(out, ver-)
      if (access(out))
        del(out,ver-)
      if (!access(out)){
        print("divapsbymean: old "//out//" deleted")
      }
      else{
        print("divapsbymean: ERROR: cannot delete "//out)
      }
    }
    countorders(image,
                dispaxis=dispaxis)
    naps = countorders.norders
    print("divapsbymean: <"//image//"> contains "//naps//" orders")
    countpix(image)
    npix = countpix.npixels
    print("divapsbymean: <"//image//"> contains "//npix//" orders")
# --- divide every order by its mean value
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
      stmean(image=inorderstr)
      mean = stmean.mean
      print("divapsbymean: mean of "//inorderstr//" = "//mean)
#      imcopy(input=image//"[*,1:1]",
#             output=out,
#             ver-)
#      print("imcopy ready")
      if (!access(out)){
        print("divapsbymean: ERROR: "//out//" not found!!!")
# --- clean up
        delete (infile, ver-, >& "dev$null")
        inputlist     = ""
        return
      }
      else
        print("divapsbymean: "//image//" copied to "//out)
      print("divapsbymean: dividing "//inorderstr//" by mean")
      imarith(operand1=inorderstr,
              op="/",
              operand2=mean,
              result=tempfits,
              title="",
              divzero=0.,
              hparams="",
              pixtype="real",
              calctype="real",
              ver-,
              noact-)
      print("divapsbymean: imarith ready")
      imcopy(input=tempfits,
             output=outorderstr,
             verbose-)
      print("divapsbymean: "//outorderstr//" ready")
    }
  }
  if (access(tempfits))
    del(tempfits, ver-)

# --- clean up
  delete (infile, ver-, >& "dev$null")
  inputlist     = ""
  return
end
