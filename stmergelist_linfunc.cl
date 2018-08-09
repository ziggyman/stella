procedure stmergelist (images)

#################################################################
#                                                               #
#      This program merges the spectra apertures for a list     #
#        of fits spectra without normalizing them before        #
#                                                               #
# Andreas Ritter, 20.08.2004                                    #
#                                                               #
# input: images "fits.list":                                    #
#         <image1.fits>                                         #
#         <image2.fits>                                         #
#            ...                                                #
#################################################################

string images        = "@fits.list"                {prompt="List of images to merge orders"}
string parameterfile = "scripts$parameterfiles/parameterfile_UVES_blue_437_2148x3000.prop" {prompt="Name of parameterfile"}
string logfile       = "logfile_stmergelist.log"   {prompt="Name of logfile"}
string warningfile   = "warnings_stmergelist.log"  {prompt="Name of warning file"}
string errorfile     = "errors_stmergelist.log"    {prompt="Name of error file"}
int    loglevel      = 3                           {prompt="Level for writing logfile [1-3]"}
string *filelist

begin
  string filename
  string logfile_stmerge     = "logfile_stmerge.log"
  string warningfile_stmerge = "warnings_stmerge.log"
  string errorfile_stmerge   = "errors_stmerge.log"
  file   obsfile

# --- delete old logfiles
  if (access(logfile))
    del(logfile, ver-)
  if (access(warningfile))
    del(warningfile, ver-)
  if (access(errorfile))
    del(errorfile, ver-)

  obsfile = mktemp ("tmp")

# --- Umwandeln der Liste von Frames in temporaeres File
  print("stmergelist: building lists from temp-files")
  if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
    sections(images, option="root", > obsfile)
    filelist = obsfile
  }
  else{
    if (substr(images,1,1) != "@"){
      print("stmergelist: ERROR: "//images//" not found!!!")
    }
    else{
      print("stmergelist: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
    }
# --- Aufraeumen
    delete (obsfile, ver-, >& "dev$null")
    filelist = ""
    return
  }

  while (fscan (filelist, filename) != EOF){
    if (access(filename)){
      print("stmergelist: starting stmerge("//filename//")")
      stmerge(image = filename,
              parameterfile = parameterfile,
              loglevel = loglevel,
              logfile = logfile_stmerge,
              warningfile = warningfile_stmerge,
              errorfile = errorfile_stmerge)
      if (access(logfile_stmerge))
        cat(logfile_stmerge, >> logfile)
      if (access(warningfile_stmerge))
        cat(warningfile_stmerge, >> warningfile)
      if (access(errorfile_stmerge))
        cat(errorfile_stmerge, >> errorfile)
    }
    else{
      print("stmergelist: ERROR: cannot access "//filename)
    }
  }

# --- Aufraeumen
  delete (obsfile, ver-, >& "dev$null")
  filelist = ""

end
