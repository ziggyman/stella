procedure stzero (images)

#############################################################################
#                                                                           #
# This program trims and combines the single orders per image to one image  #
#                    and then to one single order                           #
#                                                                           #
#                     outputfile = image_tc.fits                            #
#                                                                           #
# Andreas Ritter, 10.09.2002                                                #
#                                                                           #
#############################################################################

string images               = "@fits_c.list"                {prompt="list of images to combine"}
int firstorder              = 1                             {prompt="first order to process"}
int lastorder               = 15                            {prompt="last order to process"}
string trimsec              = "[259:1811,1]"                {prompt="Trim data section"}
string firsttrimsec         = "[350:1811,1]"                {prompt="Trim data section of first order"}
string lasttrimsec          = "[350:1700,1]"                {prompt="Trim data section of last order"}
string combine              = "median"                      {prompt="Type of combine operation"}
string reject               = "ccdclip"                     {prompt="Type of rejection"}
real   rdnoise              = 3.69                          {prompt="Read out noise sigma (photons)"}
real   gain                 = 0.68                          {prompt="Photon gain (photons/data number)"}
int    loglevel                                             {prompt="level for writing logfile"}
#string parameterfile = "scripts$parameterfile.prop"         {prompt="parameterfile"}
string *obslist
string *scapinlist

begin

  string logfile       = "logfile.log"
  string obsfile
  string scapinfile
  int    i,aperture
  string in,trimin,trimout

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                    stscombine.cl                       *")
  print ("*    (trims and combines the single orders per image     *")
  print ("*              *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*                    stscombine.cl                       *", >> logfile)
  print ("*    (trims and combines the single orders per image     *", >> logfile)
  print ("*       to one image and then to one single order)       *", >> logfile)
  print ("**********************************************************", >> logfile)


# --- Erzeugen von temporaeren Filenamen
  print("stscombine: building temp-filenames")
  if (loglevel > 2)
    print("stscombine: building temp-filenames", >> logfile)
  scapinfile    = mktemp ("tmp")
  obsfile       = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stscombine: building lists from temp-files")
  if (loglevel > 2)
    print("stscombine: building lists from temp-files", >> logfile)

  if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
   sections(images, option="root", > obsfile)
   obslist = obsfile
  }
  else{
   if (substr(images,1,1) != "@"){
    print("stscombine: ERROR: "//images//" not found!!!")
    print("stscombine: ERROR: "//images//" not found!!!", >> logfile)
#    print("stscombine: ERROR: "//images//" not found!!!", >> errorfile)
#    print("stscombine: ERROR: "//images//" not found!!!", >> warningfile)
   }
   else{
    print("stscombine: ERROR: "//substr(images,2,strlen(biasimages))//" not found!!!")
    print("stscombine: ERROR: "//substr(images,2,strlen(biasimages))//" not found!!!", >> logfile)
#    print("stscombine: ERROR: "//substr(images,2,strlen(biasimages))//" not found!!!", >> errorfile)
#    print("stscombine: ERROR: "//substr(images,2,strlen(biasimages))//" not found!!!", >> warningfile)
   }
   return
  }

# --- build temporary lists
  print("scombine: ****************** building templists *****************", >> logfile)
#  if (access(obslist)){
   while (fscan(obslist,in) != EOF){
    print("stscombine: infile = "//in)
    if (access(in)){
     i = strlen(in)
     if (substr (in, i-4, i) == ".fits"){
       in = substr(in, 1, i-5)
     }
#     print("", > scapinfile)
     delete (obsfile, ver-, >& "dev$null")
     scapinfile    = mktemp ("tmp")
     for(aperture=firstorder;aperture<=lastorder;aperture=aperture+1){
      if (aperture < 10){
       if (aperture == firstorder){
        trimin = in//"_0"//aperture//"_c"//firsttrimsec
        trimout = in//"_0"//aperture//"_ct"       
       }
       else if (aperture == lastorder){
        trimin = in//"_0"//aperture//"_c"//lasttrimsec
        trimout = in//"_0"//aperture//"_ct"
       }
       else{
        trimin = in//"_0"//aperture//"_c"//trimsec
        trimout = in//"_0"//aperture//"_ct"
       }
      }
      else{
       if (aperture == firstorder){
        trimin = in//"_"//aperture//"_c"//firsttrimsec
        trimout = in//"_"//aperture//"_ct"       
       }
       else if (aperture == lastorder){
        trimin = in//"_"//aperture//"_c"//lasttrimsec
        trimout = in//"_"//aperture//"_ct"
       }
       else{
        trimin = in//"_"//aperture//"_c"//trimsec
        trimout = in//"_"//aperture//"_ct"
       }
      }
      if (access(trimout//".fits")){
       imdel(trimout, ver-)
       if (access(trimout//".fits"))
         delete(trimout//".fits")
       print("stscombine: old "//trimout//" deleted")
       if (loglevel > 2)
         print("stscombine: old "//trimout//" deleted", >> logfile)
      }
      print("stscombine: trimin="//trimin//", trimout="//trimout)
      imcopy(input=trimin,output=trimout,ver+)
      print(trimout, >> scapinfile) 
     }
#    scapinlist = scapinfile

# --- combine orders
     if (access(in//"_ct.fits")){
      imdel(in//"_ct.fits", ver-)
      if (access(in//"_ct.fits"))
        delete(in//"_ct.fits")
      print("stscombine: old "//in//"_ct.fits deleted")
      print("stscombine: old "//in//"_ct.fits deleted", >> logfile)
     }
     scombine(input="@"//scapinfile, output=in//"_ct", noutput="", logfile=logfile, apertures="", group="apertures", combine=combine, reject=reject, first-, w1=INDEF, w2=INDEF, dw=INDEF, nw=INDEF, log-, scale="none", zero="none", weight="none", sample="", lthreshold=INDEF, hthreshold=INDEF, nlow=0, nhigh=1, nkeep=1, mclip+, lsigma=3., hsigma=3., rdnoise=rdnoise, gain=gain, snoise=0., sigscale=0.1, pclip=-0.5, grow=0, blank=0.)

# --- combine images
     if (access(in//"_ctc.fits")){
      imdel(in//"_ctc.fits", ver-)
      if (access(in//"_ctc.fits"))
        delete(in//"_ctc.fits")
      print("stscombine: old "//in//"_ctc.fits deleted")
      print("stscombine: old "//in//"_ctc.fits deleted", >> logfile)
     }
     if (access(in//"_ct.fits")){
      scombine(input=in//"_ct", output=in//"_ctc", noutput="", logfile=logfile, apertures="", group="images", combine=combine, reject=reject, first-, w1=INDEF, w2=INDEF, dw=INDEF, nw=INDEF, log-, scale="none", zero="none", weight="none", sample="", lthreshold=INDEF, hthreshold=INDEF, nlow=0, nhigh=1, nkeep=1, mclip+, lsigma=3., hsigma=3., rdnoise=rdnoise, gain=gain, snoise=0., sigscale=0.1, pclip=-0.5, grow=0, blank=0.)
     }
     else{
      print("stscombine: ERROR: "//in//"_ct.fits not found")
      print("stscombine: ERROR: "//in//"_ct.fits not found", >> logfile)
      return
     }
    } # end for
    else{
     print("stscombine: ERROR: "//in//" not found!")
     print("stscombine: ERROR: "//in//" not found!", >> logfile)
    }
   } # end while
#  }
#  else{
#   print("stscombine: ERROR: obsfile not found!")
#   print("stscombine: ERROR: obsfile not found!", >> logfile)
#   return
#  }

# --- Aufraeumen
  delete (obsfile, ver-, >& "dev$null")
  obslist      = ""
  scapinlist      = ""
#  parameterlist = ""

end

