procedure stdivflat(Images,FlatImage)

##################################################################
#                                                                #
# NAME:             stdivflat.cl                                 #
# PURPOSE:          * divides the images in <Images> by the      #
#                     normalised Flat <FlatImage>                #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stdivflat(Images,FlatImage)                  #
# INPUTS:           Images: String                               #
#                     name of list containing names of           #
#                     images to divide by <FlatImage>:           #
#                       "objects_botz.list":                     #
#                         HD175640_botz.fits                     #
#                         ...                                    #
#                    FlatImage: String                           #
#                      name of normalised Flat                   #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     <Entry_in_images_Root>f.<ImType>           #
#                   Log Files:                                   # 
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      07.12.2001                                   #
# LAST EDITED:      18.04.2007                                   #
#                                                                #
##################################################################

string Images        = "@stdivflat.list"            {prompt="List of images to divide by flat"}
string FlatImage     = "normalizedFlat.fits"        {prompt="Flat field image"}
string ParameterFile = "scripts$parameterfile.prop" {prompt="Name of ParameterFile"}
string ImType        = "fits"                       {prompt="Image Type"}
bool   DelInput      = NO                           {prompt="Delete input images after processing?"}
int    LogLevel      = 3                            {prompt="level for writing LogFile"}
string LogFile       = "logfile_stdivflat.log"      {prompt="Name of log file"}
string WarningFile   = "warnings_stdivflat.log"     {prompt="Name of warning file"}
string ErrorFile     = "errors_stdivflat.log"       {prompt="Name of error file"}
string *P_ImageList
string *P_ParameterList
#string *timelist

begin

  file   InFile
  file   TimeFile = "time.txt"
  string tempday,temptime,tempdate,ListName
  string In,Out,Parameter,ParameterValue
  int    i
  bool   FoundLogLevel = NO
  bool   FoundImType   = NO

# --- delete old LogFiles
  if (access(LogFile))
    delete(LogFile, ver-)
  if (access(WarningFile))
    delete(WarningFile, ver-)
  if (access(ErrorFile))
    delete(ErrorFile, ver-)

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*            dividing images by normalizedFlat           *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*            dividing images by normalizedFlat           *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)


# --- read ParameterFile
  if (access(ParameterFile)){

    P_ParameterList = ParameterFile

    print ("stdivflat: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("stdivflat: **************** reading ParameterFile *******************", >> LogFile)

    while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){

#      if (Parameter != "#")
#        print ("stdivflat: ParameterFile: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

      if (Parameter == "log_level"){ 
        LogLevel = real(ParameterValue)
        print ("stdivflat: Setting "//Parameter//" to "//LogLevel)
        if (LogLevel > 2)
          print ("stdivflat: Setting "//Parameter//" to "//LogLevel, >> LogFile)
        FoundLogLevel = YES
      }
      else if (Parameter == "imtype"){ 
        ImType = ParameterValue
        print ("stdivflat: Setting "//Parameter//" to "//ImType)
        if (LogLevel > 2)
          print ("stdivflat: Setting "//Parameter//" to "//ImType, >> LogFile)
        FoundImType = YES
      }
    }
    if (!FoundLogLevel){
      print("stdivflat: WARNING: Parameter <log_level> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stdivflat: WARNING: Parameter <log_level> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stdivflat: WARNING: Parameter <log_level> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
    if (!FoundImType){
      print("stdivflat: WARNING: Parameter <imtype> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stdivflat: WARNING: Parameter <imtype> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stdivflat: WARNING: Parameter <imtype> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
  }
  else{
    print("stdivflat: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard parameters")
    print("stdivflat: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard parameters", >> LogFile)
    print("stdivflat: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard parameters", >> WarningFile)
  }

# --- Erzeugen von temporaeren Filenamen
  print("stdivflat: building temp-filenames")
  if (LogLevel > 2)
    print("stdivflat: building temp-filenames", >> LogFile)
  InFile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stdivflat: building lists from temp-files")
  if (LogLevel > 2)
    print("stdivflat: building lists from temp-files", >> LogFile)

  if (substr(Images,1,1) == "@")
    ListName = substr(Images,2,strlen(Images))
  else
    ListName = Images
  if (!access(ListName)){
    print("stdivflat: ERROR: "//ListName//" not found!!!")
    print("stdivflat: ERROR: "//ListName//" not found!!!", >> LogFile)
    print("stdivflat: ERROR: "//ListName//" not found!!!", >> ErrorFile)
    print("stdivflat: ERROR: "//ListName//" not found!!!", >> WarningFile)
# --- clean up
#   timelist = ""
    P_ParameterList = ""
    P_ImageList = ""
    delete(InFile, ver-, >& "dev$null")
    return
  }
  sections(Images, option="root", > InFile)
  P_ImageList = InFile
  
# --- build output filenames and divide by flat
  print("stdivflat: ******************* processing files *********************")
  if (LogLevel > 2)
    print("stdivflat: ******************* processing files *********************", >> LogFile)
  while (fscan (P_ImageList, In) != EOF){

#    print("stdivflat: In = "//In)
#    if (LogLevel > 1)
#      print("stdivflat: In = "//In, >> LogFile)

    i = strlen(In)
    if (substr (In, i-strlen(ImType), i) == "."//ImType)
      Out = substr(In, 1, i-strlen(ImType)-1)//"f."//ImType
    else Out = In//"f."//ImType

# --- delete old outfile
    if (access(Out)){
      imdel(Out, ver-)
      if (access(Out))
        del(Out,ver-)
      if (!access(Out)){
        print("stdivflat: old "//Out//" deleted")
        if (LogLevel > 2)
          print("stdivflat: old "//Out//" deleted", >> LogFile)
      }
      else{
        print("stdivflat: ERROR: cannot delete "//Out)
        print("stdivflat: ERROR: cannot delete "//Out, >> LogFile)
        print("stdivflat: ERROR: cannot delete "//Out, >> WarningFile)
        print("stdivflat: ERROR: cannot delete "//Out, >> ErrorFile)
# --- clean up
#        timelist = ""
        P_ParameterList = ""
        P_ImageList = ""
        delete(InFile, ver-, >& "dev$null")
        return
      }
    }
    
    print("stdivflat: processing "//In//", outfile = "//Out)
    if (LogLevel > 1)
      print("stdivflat: processing "//In//", outfile = "//Out, >> LogFile)

    if (!access(In)){
      print("stdivflat: ERROR: cannot access input file "//In//" => Returning")
      print("stdivflat: ERROR: cannot access input file "//In//" => Returning", >> LogFile)
      print("stdivflat: ERROR: cannot access input file "//In//" => Returning", >> ErrorFile)
      print("stdivflat: ERROR: cannot access input file "//In//" => Returning", >> WarningFile)
# --- clean up
#      timelist = ""
      P_ParameterList = ""
      P_ImageList = ""
      delete(InFile, ver-, >& "dev$null")
      return
    }
# --- set all negative values to zero
    imreplace(images    = In,
              value     = 0.,
              imaginary = 0.,
              lower     = INDEF,
              upper     = 0.,
              radius    = 0.)
#    fitsnozero(In)
# --- ccdproc flatcor+
#       ccdproc(images=In,
#               output=Out,
#               noproc-,
#               fixpix-,
#               overscan-,
#               trim-,
#               zerocor-,
#               darkcor-,
#               flatcor+,
#               illumco-,
#               fringec-,
#               readcor-,
#               scancor-,
#               readaxis="line",
#               minrepl=0.,
#               scantyp="shortscan",
#               nscan=1,
#               interac-,
#               flat=flat)

# --- divide images by normalized Flat
    imarith(operand1 = In,
            op       = "/",
            operand2 = FlatImage,
            result   = Out,
            title    = "",
            divzero  = 0.,
            hparams  = "",
            pixtype  = "",
            calctype = "",
            ver-,
            noact-)
    if (!access(Out)){
      print("stdivflat: ERROR: output file "//Out//" not accessable")
      print("stdivflat: ERROR: output file "//Out//" not accessable", >> LogFile)
      print("stdivflat: ERROR: output file "//Out//" not accessable", >> WarningFile)
      print("stdivflat: ERROR: output file "//Out//" not accessable", >> ErrorFile)
# --- clean up
#      timelist = ""
      P_ParameterList = ""
      P_ImageList = ""
      delete(InFile, ver-, >& "dev$null")
      return
    }
    if (DelInput)
      imdel(In, ver-)
    if (DelInput && access(In))
      del(In, ver-)
    imreplace(images    = Out,
              value     = 0.,
              imaginary = 0.,
              lower     = INDEF,
              upper     = 0.,
              radius    = 0.)
#    fitsnozero(Out)

    if (access(TimeFile))
      del(TimeFile, ver-)
    time(>> TimeFile)
    if (access(TimeFile)){
      P_ParameterList = TimeFile
      if (fscan(P_ParameterList,tempday,temptime,tempdate) != EOF){
        hedit(images = Out,
              fields = "STDIVFLA",
              value  = "divided by "//FlatImage//" "//tempdate//"T"//temptime,
              add+,
              addonly+,
              del-,
              ver-,
              show+,
              update+)
      }
    }
    else{
      print("stdivflat: WARNING: TimeFile <"//TimeFile//"> not accessable!")
      print("stdivflat: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
      print("stdivflat: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
    }

    print("stdivflat: "//Out//" ready")
    if (LogLevel > 1)
      print("stdivflat: "//Out//" ready", >> LogFile)
    print("-----------------------")
    print("-----------------------", >> LogFile)
  }

  if (access(TimeFile))
    del(TimeFile, ver-)
  time(>> TimeFile)
  if (access(TimeFile)){
    P_ParameterList = TimeFile
    if (fscan(P_ParameterList,tempday,temptime,tempdate) != EOF){
      print("stdivflat: stdivflat finished "//tempdate//"T"//temptime, >> LogFile)
    }
  }
  else{
    print("stdivflat: WARNING: TimeFile <"//TimeFile//"> not accessable!")
    print("stdivflat: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
    print("stdivflat: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
  }

# --- clean up
  P_ParameterList = ""
  P_ImageList = ""
#  timelist = ""
  delete (InFile, ver-, >& "dev$null")
end



