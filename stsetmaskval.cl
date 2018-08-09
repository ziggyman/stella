procedure stsetmaskval (images)

################################################################################ 
#                                                                              #
# This program sets the pixel areas from the mask file to the specified value. #
#                                                                              #
#                                output = input                                #
#                                                                              #
# Andreas Ritter, 01.03.2006                                                   #
#                                                                              #
################################################################################

string images        = "@badovertrim.list"          {prompt="List of input images"}
string maskfile      = "maskfile.text"              {prompt="Name of pixel-mask file"}
real   value         = 10000.                       {prompt="Value to set"}
int    loglevel      = 3                            {prompt="Level for writing log file"}
string logfile       = "logfile_stsetmaskval.log"   {prompt="Name of log file"}
string warningfile   = "warnings_stsetmaskval.log"  {prompt="Name of warning file"}
string errorfile     = "errors_stsetmaskval.log"    {prompt="Name of error file"}
string *imagelist
string *pixellist
string *timelist
begin

  file   infile
  string in
  string timefile = "time.text"
  string tempdate,tempday,temptime
  int    x1,x2,y1,y2

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)
  if (access(warningfile))
    delete(warningfile, ver-)
  if (access(errorfile))
    delete(errorfile, ver-)
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*          setting values of pixels in mask               *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*          setting values of pixels in mask              *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

  infile    = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stsetmaskval: building lists from temp-files")
  if (loglevel > 2)
    print("stsetmaskval: building lists from temp-files", >> logfile)

  if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
    sections(images, option="root", > infile)
    imagelist = infile
  }
  else{
    if (substr(images,1,1) != "@"){
      print("stsetmaskval: ERROR: "//images//" not found!!!")
      print("stsetmaskval: ERROR: "//images//" not found!!!", >> logfile)
      print("stsetmaskval: ERROR: "//images//" not found!!!", >> errorfile)
      print("stsetmaskval: ERROR: "//images//" not found!!!", >> warningfile)
    }
    else{
      print("stsetmaskval: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
      print("stsetmaskval: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> logfile)
      print("stsetmaskval: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> errorfile)
      print("stsetmaskval: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> warningfile)
    }
#  --- clean up
    imagelist = ""
    delete (infile, ver-, >& "dev$null")
    return
  }

# --- process images
  print("stsetmaskval: ******************* processing files *********************")
  if (loglevel > 2)
    print("stsetmaskval: ******************* processing files *********************", >> logfile)

  while (fscan (imagelist, in) != EOF){

    print("stsetmaskval: in = "//in)
    if (loglevel > 1)
      print("stsetmaskval: in = "//in, >> logfile)

# --- set bad pixels from badpixelfile to 10000.
    print("stsetmaskval: setting bad pixel values to "//value)
    pixellist = maskfile
    while(fscan(pixellist,x1,x2,y1,y2) != EOF){
      imreplace(images=in//"["//x1//":"//x2//","//y1//":"//y2//"]",
                value=value,
                imaginary=0.,
                lower=INDEF,
                upper=INDEF,
                radius=0.)
    }

    if (access(timefile))
      del(timefile, ver-)
    time(>> timefile)
    if (access(timefile)){
      timelist = timefile
      if (fscan(timelist,tempday,temptime,tempdate) != EOF){
        hedit(images=in,
              fields="STALL",
              value="stsetmaskval: pixels from "//maskfile//" set to "//value//" "//tempdate//"T"//temptime,
              add+,
              addonly-,
              del-,
              ver-,
              show+,
              update+)
      }
    }
    else{
      print("stsetmaskval: WARNING: timefile <"//timefile//"> not accessable!")
      print("stsetmaskval: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
      print("stsetmaskval: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
    }
    print("stsetmaskval: "//in//" ready")
    if (loglevel > 1)
      print("stsetmaskval: "//in//" ready", >> logfile)
  }
  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("stsetmaskval: stsetmaskval finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("stsetmaskval: WARNING: timefile <"//timefile//"> not accessable!")
    print("stsetmaskval: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("stsetmaskval: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- clean up
  imagelist = ""
  delete (infile, ver-, >& "dev$null")

end
