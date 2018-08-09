procedure emptylist(images)

#########################################################################
#                                                                       #
# NAME:                  empty                                          #
# PURPOSE:               * calculates ...                               #
#                                                                       #
# CATEGORY:                                                             #
# CALLING SEQUENCE:      empty,<String images>                          #
# INPUTS:                input file: 'images':                          #
#                         Bias.fits                                     #
#                         Flat.fits                                     #
#                                            .                          #
#                                            .                          #
# OUTPUTS:               outfile: String <image_root>_.fits             #
#                                                                       #
# IRAF VERSION:          2.11                                           #
#                                                                       #
# COPYRIGHT:             Andreas Ritter                                 #
# CONTACT:               aritter@aip.de                                 #
#                                                                       #
# LAST EDITED:           03.05.2006                                     #
#                                                                       #
#########################################################################

string images        = "images.list"                     {prompt="Name of input-image list"}
string parameterfile = "scripts$parameterfile.prop"      {prompt="parameterfile"}
int    loglevel      = 3                               {prompt="Level for writing logfile"}
string logfile       = "logfile_.log"                    {prompt="Name of log file"}
string warningfile   = "warnings_.log"                   {prompt="Name of warning file"}
string errorfile     = "errors_.log"                     {prompt="Name of error file"}
string *imagelist
string *parameterlist
string *timelist

begin
  file   infile
  string timefile = "time.txt"
  string tempdate,tempday,temptime,in,out,parameter,parametervalue
  string ccdlistoutfile="outfile_ccdlist.text"

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
  print ("*             assigning reference spectra                *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*             assigning reference spectra                *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- read parameterfile
  if (access(parameterfile)){

    parameterlist = parameterfile

    print ("strefspec: **************** reading parameterfile *******************")
    if (loglevel > 2)
      print ("strefspec: **************** reading parameterfile *******************", >> logfile)

    while (fscan (parameterlist, parameter, parametervalue) != EOF){

      if (parameter == "ref_select"){ 
        select = parametervalue
        print ("strefspec: Setting "//parameter//" to "//parametervalue)
        if (loglevel > 2)
          print ("strefspec: Setting "//parameter//" to "//parametervalue, >> logfile)
        found_ref_select = YES
      }
    } #end while(fscan(parameterlist) != EOF)
    if (!found_ref_select){
      print("strefspec: WARNING: parameter ref_select not found in parameterfile!!! -> using standard")
      print("strefspec: WARNING: parameter ref_select not found in parameterfile!!! -> using standard", >> logfile)
      print("strefspec: WARNING: parameter ref_select not found in parameterfile!!! -> using standard", >> warningfile)
    }
  }
  else{
    print("strefspec: WARNING: parameterfile not found!!! -> using standard parameters")
    print("strefspec: WARNING: parameterfile not found!!! -> using standard parameters", >> logfile)
    print("strefspec: WARNING: parameterfile not found!!! -> using standard parameters", >> warningfile)
  }
# --- assign reference spectra
  if ((substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
    infile = mktemp ("tmp")
    sections(images, option="root", > infile)
    imagelist = infile
    if ((substr(reference,1,1) == "@" && access(substr(reference,2,strlen(reference)))) || (substr(reference,1,1) != "@" && access(reference))){

      print("strefspec: starting refspec")
      if (loglevel > 2)
	print("strefspec: starting refspec", >> logfile)

      while (fscan (imagelist, in) != EOF){

        print("strefspec: processing "//in)
        if (loglevel > 2)
          print("strefspec: processing "//in, >> logfile)
        if (substr (in, i-4, i) == ".fits")
          out = substr(in, 1, i-5)//"_bl.fits"
        else out = in//"_bl"
        
# --- delete old outfile
        if (access(out)){
          imdel(out, ver-)
          if (access(out))
            del(out,ver-)
          if (!access(out)){
            print("stscatter: old "//out//" deleted")
            if (loglevel > 2)
              print("stscatter: old "//out//" deleted", >> logfile)
          }
          else{
            print("stscatter: ERROR: cannot delete old "//out)
            print("stscatter: ERROR: cannot delete old "//out, >> logfile)
            print("stscatter: ERROR: cannot delete old "//out, >> warningfile)
            print("stscatter: ERROR: cannot delete old "//out, >> errorfile)
          }
        }
        if (access(in)){


        }
        else{
          print("stscatter: ERROR: cannot access "//in)
          print("stscatter: ERROR: cannot access "//in, >> logfile)
          print("stscatter: ERROR: cannot access "//in, >> errorfile)
          print("stscatter: ERROR: cannot access "//in, >> warningfile)
        }

        if (access(timefile))
          del(timefile, ver-)
        time(>> timefile)
        if (access(timefile)){
          timelist = timefile
          if (fscan(timelist,tempday,temptime,tempdate) != EOF){
            hedit(images=in,
                  fields="STALL",
                  value="strefspec: reference wavelength calibration file assigned "//tempdate//"T"//temptime,
                  add+,
                  addonly+,
                  del-,
                  ver-,
                  show+,
                  update+)
          }
        }
        else{
          print("strefspec: WARNING: timefile <"//timefile//"> not accessable!")
          print("strefspec: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
          print("strefspec: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
        }

      }

    }
    else{
      if (substr(reference,1,1) != "@"){
        print("strefspec: ERROR: "//reference//" not found!!!")
        print("strefspec: ERROR: "//reference//" not found!!!", >> logfile)
        print("strefspec: ERROR: "//reference//" not found!!!", >> errorfile)
        print("strefspec: ERROR: "//reference//" not found!!!", >> warningfile)
      }
      else{
        print("strefspec: ERROR: "//substr(reference,2,strlen(reference))//" not found!!!")
        print("strefspec: ERROR: "//substr(reference,2,strlen(reference))//" not found!!!", >> logfile)
        print("strefspec: ERROR: "//substr(reference,2,strlen(reference))//" not found!!!", >> errorfile)
        print("strefspec: ERROR: "//substr(reference,2,strlen(reference))//" not found!!!", >> warningfile)
      }
    }
  }
  else{
    if (substr(images,1,1) != "@"){
      print("strefspec: ERROR: "//images//" not found!!!")
      print("strefspec: ERROR: "//images//" not found!!!", >> logfile)
      print("strefspec: ERROR: "//images//" not found!!!", >> errorfile)
      print("strefspec: ERROR: "//images//" not found!!!", >> warningfile)
    }
    else{
      print("strefspec: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
      print("strefspec: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> logfile)
      print("strefspec: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> errorfile)
      print("strefspec: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> warningfile)
    }
  }

  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("strefspec: strefspec finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("strefspec: WARNING: timefile <"//timefile//"> not accessable!")
    print("strefspec: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("strefspec: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- aufraeumen
  if (instrument == "echelle")
    echelle.logfile = bak_logfile
  else
    kpnocoude.logfile = bak_logfile
  parameterlist = ""
  imagelist     = ""
  timelist      = ""
end
