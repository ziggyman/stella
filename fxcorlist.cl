procedure fxcorlist(input,template)

#################################################################
#                                                               #
#     This program calculates heliocentric radial velocities    #
#                  for a list of inputspectra                   #
#                                                               #
#    Andreas Ritter, 24.05.2002                                 #
#                                                               #
#################################################################

string input                                           {prompt="List of input spectra"}
string template                                        {prompt="Template spectra"}
string output      = "fxcor_RXJ_l.txt"                 {prompt="Root spool filename for output"}
string observatory = "vlt2"                            {prompt="Observatory where images were taken"}
string osample     = "6370-6500"                       {prompt="Object regions to be correlated ('*' => all)"}
string rsample     = "6370-6500"                       {prompt="Template regions to be correlated"}
real   weights     = 1.                                {prompt="Power defining fitting weights"}
int    window      = 100                               {prompt="Size of window in the correlation plot"}
int    width       = 50                                {prompt="Width of fitting region in pixels"}
real   maxwidth    = 100.                              {prompt="Maximum width for fit"}
real   minwidth    = 3.                                {prompt="Minimum width for fit"}
real   height      = 0.                                {prompt="Starting height of fit"}
bool   peak        = NO                                {prompt="Is height relative to ccf peak?"}
bool   update      = YES                               {prompt="Update image header?"}
bool   interactive = YES                               {prompt="Run task interactively?"}

#int    loglevel                                        {prompt="level for writing logfile"}
#string *parameterlist
string *inputlist


begin

#  string parameterfile       = "scripts$parameterfile.prop"
#  string logfile             = "logfile.log"
#  string errorfile           = "errors.log"
#  string warningfile         = "warnings.log"
#  string parameter,parametervalue
  file   infile
#  file   tempfile
  string in

#  print ("**********************************************************")
#  print ("*                                                        *")
#  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
#  print ("*                                                        *")
#  print ("*                correcting dispersions                  *")
#  print ("*                                                        *")
#  print ("**********************************************************")
#  print ("**********************************************************", >> logfile)
#  print ("*                                                        *", >> logfile)
#  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
#  print ("*                                                        *", >> logfile)
#  print ("*                correcting dispersion                   *", >> logfile)
#  print ("*                                                        *", >> logfile)
#  print ("**********************************************************", >> logfile)

rv

keywpars.ra      = "RA_HMS"
keywpars.dec     = "DEC_HMS"
keywpars.ut      = "UTC"
keywpars.utmiddl = "UTMIDDLE"
keywpars.exptime = "EXPTIME"
keywpars.epoch   = "EQUINOX"
keywpars.date_ob = "DATE-OBS"
keywpars.hjd     = "HJD"
keywpars.mjd_obs = "MJD-OBS"
keywpars.vobs    = "VOBS"
keywpars.vrel    = "VREL"
keywpars.vhelio  = "VHELIO"
keywpars.vlsr    = "VLSR"
keywpars.vsun    = "VSUN"
keywpars.mode    = "h"

if (access(output//".txt")){
  delete(output//".txt",ver-)
}

# --- read parameterfile
#  if (access(parameterfile)){

#    parameterlist = parameterfile

#    print ("stdispcor: **************** reading parameterfile *******************")
#    if (loglevel > 2)
#      print ("stdispcor: **************** reading parameterfile *******************", >> logfile)

#    while (fscan (parameterlist, parameter, parametervalue) != EOF){

#      if (parameter == "loglevel"){ 
#        loglevel = real(parametervalue)
#        print ("stdispcor: Setting "//parameter//" to "//parametervalue)
#        print ("stdispcor: Setting "//parameter//" to "//parametervalue, >> logfile)
#      }
#    } #end while(fscan(parameterlist) != EOF)
#  }
#  else{
#    print("stdispcor: WARNING: parameterfile not found!!! -> using standard parameters")
#    print("stdispcor: WARNING: parameterfile not found!!! -> using standard parameters", >> logfile)
#    print("stdispcor: WARNING: parameterfile not found!!! -> using standard parameters", >> warningfile)
#  }

# --- Erzeugen von temporaeren Filenamen
  print("fxcorlist: building temp-filenames")
#  if (loglevel > 2)
#    print("fxcorlist: building temp-filenames", >> logfile)
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("fxcorlist: building lists from temp-files")
#  if (loglevel > 2)
#    print("stdispcor: building lists from temp-files", >> logfile)

  if ((substr(input,1,1) == "@" && access(substr(input,2,strlen(input)))) || (substr(input,1,1) != "@" && access(input))){
    sections(input, option="root", > infile)
    inputlist = infile
  }
  else{
    if (substr(input,1,1) != "@"){
      print("stdispcor: ERROR: "//input//" not found!!!")
#      print("stdispcor: ERROR: "//input//" not found!!!", >> logfile)
#      print("stdispcor: ERROR: "//input//" not found!!!", >> errorfile)
#      print("stdispcor: ERROR: "//input//" not found!!!", >> warningfile)
    }
    else{
      print("stdispcor: ERROR: "//substr(input,2,strlen(input))//" not found!!!")
#      print("stdispcor: ERROR: "//substr(input,2,strlen(input))//" not found!!!", >> logfile)
#      print("stdispcor: ERROR: "//substr(input,2,strlen(input))//" not found!!!", >> errorfile)
#      print("stdispcor: ERROR: "//substr(input,2,strlen(input))//" not found!!!", >> warningfile)
    }
# --- aufraeumen
    inputlist     = ""
    delete (infile, ver-, >& "dev$null")
    return
  }

# --- build output filenames and correct dispersions
  print("fxcorlist: ******************* processing files *********************")
#  if (loglevel > 2)
#    print("stdispcor: ******************* processing files *********************", >> logfile)

  while (fscan (inputlist, in) != EOF){

    print("fxcorlist: in = "//in)
#    if (loglevel > 2)
#      print("stdispcor: in = "//in, >> logfile)

    i = strlen(in)
#    if (substr (in, i-4, i) == ".fits")
#      out = substr(in, 1, i-5)//"d.fits"
#    else out = in//"d"

#    if (access(out)){
#      imdel(out,ver-)
#      print("stdispcor: old "//out//" deleted")
#      if (loglevel > 2)
#        print("stdispcor: old "//out//" deleted", >> logfile)
#    }
    
#    print("fxcorlist: processing "//in)
#    if (loglevel > 1)
#      print("stdispcor: processing "//in//", outfile = "//out, >> logfile)

    if (access(in)){

      fxcor(objects=in, 
	    templates=template, 
	    osample=osample, 
	    rsample=rsample, 
	    apertures="*", 
	    cursor="", 
	    continuum="both", 
	    filter="none", 
	    rebin="smallest", 
	    pixcor-, 
	    apodize=0.2, 
	    function="gaussian", 
	    width=width, 
	    height=height, 
	    peak=peak, 
	    minwidth=minwidth, 
	    maxwidth=maxwidth, 
	    weights=weights, 
	    background=0., 
	    window=window, 
	    wincenter=INDEF, 
	    output=output, 
	    verbose="txtonly", 
	    imupdate-, 
	    graphics="stdgraph", 
	    interactive+, 
	    autowrite+, 
	    autodraw+, 
	    ccftype="image", 
	    observatory=observatory, 
	    continpars="", 
	    filtpars="")

      print("fxcorlist: ----------- "//in//" ready ------------")
#      if (loglevel > 1)
#        print("stdispcor: ----------- "//in//" ready ------------", >> logfile)
    }
    else{
      print("stdispcor: ERROR: cannot access "//in)
#      print("stdispcor: ERROR: cannot access "//in, >> logfile)
#      print("stdispcor: ERROR: cannot access "//in, >> errorfile)
#      print("stdispcor: ERROR: cannot access "//in, >> warningfile)
    }
  } # end of while(scan(inputlist))

# --- aufraeumen
  inputlist     = ""
#  parameterlist = ""
  delete (infile, ver-, >& "dev$null")

end




