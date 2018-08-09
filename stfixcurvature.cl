procedure stfixcurvature(Images)

##################################################################
#                                                                #
# NAME:             stfixcurvature.cl                            #
# PURPOSE:          * fits the curvature of the spectral features#
#                     from image <RefImage> and corrects the     #
#                     <Images> for this curvature                #
#                   * at this stage replaces input images        #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stfixcurvature(Images,RefImage,RefCol)       #
# INPUTS:           Images: String                               #
#                     name of list containing names of           #
#                     images to correct for curvature of spectral#
#                     features:                                  #
#                       "objects_botzfxs.list":                  #
#                         HD175640_botz.fits                     #
#                         ...                                    #
#                   RefImage: String                             #
#                     name of file to calculate curvature from   #
#                     (normally a wavelength-calibration file)   #
#                   RefCol: Int                                  #
#                     column in RefImage to cross-correlate      #
#                     other columns in apertures to              #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     <Entry_in_images_Root>.<ImType>            #
#                   Log Files:                                   #
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      23.12.2011                                   #
# LAST EDITED:      23.12.2011                                   #
#                                                                #
##################################################################

string Images        = "@stfixcurvature.list"            {prompt="List of images to divide by flat"}
string RefImage      = "ThAr.fits"                       {prompt="Reference image to calculate curvature from"}
string Reference     = "scripts$reference_files/database/apRefFlat" {prompt="apreture definition reference file"}
string Apertures     = "*"                               {prompt="Apertures [*;1,2,4-7]"}
int    RefCol        = 1024                              {prompt="Reference column number in RefImage"}
string ParameterFile = "scripts$parameterfile.prop"      {prompt="Name of ParameterFile"}
string ImType        = "fits"                            {prompt="Image Type"}
int    MaxUp         = 50                                {prompt="Maximum number of rows to shift up in cross-correlation"}
int    MaxDown       = 50                                {prompt="Maximum number of rows to shift down in cross-correlation"}
int    Order         = 3                                 {prompt="Order of polynomial fit"}
bool   EditApertures = YES                               {prompt="Edit apertures interactively?"}
int    LogLevel      = 3                                 {prompt="level for writing LogFile"}
string LogFile       = "logfile_stfixcurvature.log"      {prompt="Name of log file"}
string WarningFile   = "warnings_stfixcurvature.log"     {prompt="Name of warning file"}
string ErrorFile     = "errors_stfixcurvature.log"       {prompt="Name of error file"}
string *P_ImageList
string *P_ParameterList
#bool   DelInput      = NO                                {prompt="Delete input images after processing?"}
#string *timelist

begin

  file   InFile
  file   TimeFile = "time.txt"
  string tempday,temptime,tempdate,ListName,RefImageDBFile,tempref
  string In,Out,Parameter,ParameterValue,RefImageRoot
  int    i
  bool   FoundLogLevel      = NO
  bool   FoundImType        = NO
  bool   FoundRefImage      = NO
  bool   FoundRefCol        = NO
  bool   FoundMaxUp         = NO
  bool   FoundMaxDown       = NO
  bool   FoundOrder         = NO
  bool   FoundReference     = NO
  bool   FoundEditApertures = NO
  bool   FoundApertures     = NO

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
  print ("*  correcting images for curvature of spectral features  *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*  correcting images for curvature of spectral features  *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)


# --- read ParameterFile
  if (access(ParameterFile)){

    P_ParameterList = ParameterFile

    print ("stfixcurvature: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("stfixcurvature: **************** reading ParameterFile *******************", >> LogFile)

    while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){

#      if (Parameter != "#")
#        print ("stfixcurvature: ParameterFile: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

      if (Parameter == "log_level"){
        LogLevel = real(ParameterValue)
        print ("stfixcurvature: Setting "//Parameter//" to "//LogLevel)
        if (LogLevel > 2)
          print ("stfixcurvature: Setting "//Parameter//" to "//LogLevel, >> LogFile)
        FoundLogLevel = YES
      }
      else if (Parameter == "reference"){
        Reference = ParameterValue
        print ("stfixcurvature: Setting "//Parameter//" to "//Reference)
        if (LogLevel > 2)
          print ("stfixcurvature: Setting "//Parameter//" to "//Reference, >> LogFile)
        FoundReference = YES
      }
      else if (Parameter == "stfixcurvature_apertures"){
        Apertures = ParameterValue
        print ("stfixcurvature: Setting "//Parameter//" to "//Apertures)
        if (LogLevel > 2)
          print ("stfixcurvature: Setting "//Parameter//" to "//Apertures, >> LogFile)
        FoundApertures = YES
      }
      else if (Parameter == "stfixcurvature_edit_apertures"){
        if (ParameterValue == "YES" || ParameterValue == "yes" || ParameterValue == "Yes"){
          EditApertures = YES
        }
        else{
          EditApertures = NO
        }
        print ("stfixcurvature: Setting "//Parameter//" to "//EditApertures)
        if (LogLevel > 2)
          print ("stfixcurvature: Setting "//Parameter//" to "//EditApertures, >> LogFile)
        FoundEditApertures = YES
      }
      else if (Parameter == "imtype"){
        ImType = ParameterValue
        print ("stfixcurvature: Setting "//Parameter//" to "//ImType)
        if (LogLevel > 2)
          print ("stfixcurvature: Setting "//Parameter//" to "//ImType, >> LogFile)
        FoundImType = YES
      }
      else if (Parameter == "stfixcurvature_reference_image"){
        RefImage = ParameterValue
        print ("stfixcurvature: Setting "//Parameter//" to "//RefImage)
        if (LogLevel > 2)
          print ("stfixcurvature: Setting "//Parameter//" to "//RefImage, >> LogFile)
        FoundRefImage = YES
      }
      else if (Parameter == "stfixcurvature_reference_column"){
        RefCol = int(ParameterValue)
        print ("stfixcurvature: Setting "//Parameter//" to "//RefCol)
        if (LogLevel > 2)
          print ("stfixcurvature: Setting "//Parameter//" to "//RefCol, >> LogFile)
        FoundRefCol = YES
      }
      else if (Parameter == "stfixcurvature_max_up"){
        MaxUp = int(ParameterValue)
        print ("stfixcurvature: Setting "//Parameter//" to "//MaxUp)
        if (LogLevel > 2)
          print ("stfixcurvature: Setting "//Parameter//" to "//MaxUp, >> LogFile)
        FoundMaxUp = YES
      }
      else if (Parameter == "stfixcurvature_max_down"){
        MaxDown = int(ParameterValue)
        print ("stfixcurvature: Setting "//Parameter//" to "//MaxDown)
        if (LogLevel > 2)
          print ("stfixcurvature: Setting "//Parameter//" to "//MaxDown, >> LogFile)
        FoundMaxDown = YES
      }
      else if (Parameter == "stfixcurvature_fit_order"){
        Order = int(ParameterValue)
        print ("stfixcurvature: Setting "//Parameter//" to "//Order)
        if (LogLevel > 2)
          print ("stfixcurvature: Setting "//Parameter//" to "//Order, >> LogFile)
        FoundOrder = YES
      }
    }
    if (!FoundLogLevel){
      print("stfixcurvature: WARNING: Parameter <log_level> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stfixcurvature: WARNING: Parameter <log_level> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stfixcurvature: WARNING: Parameter <log_level> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
    if (!FoundReference){
      print("stfixcurvature: WARNING: Parameter <reference> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stfixcurvature: WARNING: Parameter <reference> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stfixcurvature: WARNING: Parameter <reference> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
    if (!FoundApertures){
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_apertures> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_apertures> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_apertures> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
    if (!FoundEditApertures){
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_edit_apertures> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_edit_apertures> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_edit_apertures> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
    if (!FoundImType){
      print("stfixcurvature: WARNING: Parameter <imtype> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stfixcurvature: WARNING: Parameter <imtype> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stfixcurvature: WARNING: Parameter <imtype> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
    if (!FoundRefImage){
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_reference_image> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_reference_image> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_reference_image> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
    if (!FoundRefCol){
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_reference_column> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_reference_column> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_reference_column> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
    if (!FoundMaxUp){
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_max_up> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_max_up> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_max_up> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
    if (!FoundMaxDown){
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_max_down> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_max_down> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_max_down> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
    if (!FoundOrder){
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_fit_order> not found in ParameterFile <"//ParameterFile//">!!! -> using standard")
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_fit_order> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> LogFile)
      print("stfixcurvature: WARNING: Parameter <stfixcurvature_fit_order> not found in ParameterFile <"//ParameterFile//">!!! -> using standard", >> WarningFile)
    }
  }
  else{
    print("stfixcurvature: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard parameters")
    print("stfixcurvature: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard parameters", >> LogFile)
    print("stfixcurvature: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard parameters", >> WarningFile)
  }

# --- check for RefImage
  if (!access(RefImage)){
    print("stfixcurvature: ERROR: "//RefImage//" not found!!!")
    print("stfixcurvature: ERROR: "//RefImage//" not found!!!", >> LogFile)
    print("stfixcurvature: ERROR: "//RefImage//" not found!!!", >> ErrorFile)
    print("stfixcurvature: ERROR: "//RefImage//" not found!!!", >> WarningFile)
# --- clean up
#   timelist = ""
    P_ParameterList = ""
    P_ImageList = ""
    delete(InFile, ver-, >& "dev$null")
    return
  }
  if (!access(Reference)){
    print("stfixcurvatures: WARNING: aperture-reference file not found")
    print("stfixcurvatures: WARNING: aperture-reference file not found", >> LogFile)
    print("stfixcurvatures: WARNING: aperture-reference file not found", >> WarningFile)
  }

  strlastpos(Reference, "/")
  print("stfixcurvatures: Searching for database/"//substr(Reference, strlastpos.pos+1, strlen(Reference)))
  if (access("database/"//substr(Reference, strlastpos.pos+1, strlen(Reference))))
    del("database/"//substr(Reference, strlastpos.pos+1, strlen(Reference)), ver-)
  copy(Reference, "database/", ver-)

  RefImageDBFile = "database/ap"
  strlastpos(tempstring = RefImage,
             substring  = "/")
  strpos(tempstring = RefImage,
         substr = "."//ImType)
  if (strlastpos.pos < 1){
    if (strpos.pos < 1){
      RefImageDBFile = RefImageDBFile//RefImage
    }
    else{
      RefImageDBFile  = RefImageDBFile//substr(RefImage,1,strpos.pos-1)
    }
  }
  else{
    if (strpos.pos < 1){
      RefImageDBFile = RefImageDBFile//substr(RefImage,strlastpos.pos+1,strlen(RefImage))
    }
    else{
      RefImageDBFile = RefImageDBFile//substr(RefImage,strlastpos.pos+1,strpos.pos-1)
    }
  }
  if (access(RefImageDBFile)){
    del(RefImageDBFile, ver-)
  }
  print("stfixcurvatures: RefImageDBFile set to <"//RefImageDBFile//">")
  if (!access(RefImageDBFile) || EditApertures){
    if (!access(RefImageDBFile)){
      strlastpos(tempstring = Reference,
                 substring  = "/ap")
      tempref = substr(Reference,strlastpos.pos+3,strlen(Reference))
    }
    else{
      tempref = ""
    }
    if (Apertures == "*")
      Apertures = ""
    apedit(input = RefImage,
           apertures = Apertures,
           references = tempref,
           interactive = EditApertures,
           find-,
           recenter-,
           resize-,
           edit = EditApertures,
           line = INDEF,
           nsum = 20,
           width = 5.,
           radius = 3.,
           threshold = 100.)
  }








  strpos(RefImage,"."//ImType)
  if (strpos.pos > 1){
    RefImageRoot = substr(RefImage, 1, strlen(RefImage) - strlen(ImType) - 1)
    print("stfixcurvature: RefImageRoot set to <"//RefImageRoot//">")
  }
  else{
    RefImageRoot = RefImage
  }
  if (substr(Images,1,1) == "@")
    Images = substr(Images,2,strlen(Images))
  findcurvature(RefImage,"database/ap"//RefImageRoot,Images,RefCol,MaxUp,MaxDown,Order)
  return








# --- Erzeugen von temporaeren Filenamen
  print("stfixcurvature: building temp-filenames")
  if (LogLevel > 2)
    print("stfixcurvature: building temp-filenames", >> LogFile)
  InFile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stfixcurvature: building lists from temp-files")
  if (LogLevel > 2)
    print("stfixcurvature: building lists from temp-files", >> LogFile)

  if (substr(Images,1,1) == "@")
    ListName = substr(Images,2,strlen(Images))
  else
    ListName = Images
  if (!access(ListName)){
    print("stfixcurvature: ERROR: "//ListName//" not found!!!")
    print("stfixcurvature: ERROR: "//ListName//" not found!!!", >> LogFile)
    print("stfixcurvature: ERROR: "//ListName//" not found!!!", >> ErrorFile)
    print("stfixcurvature: ERROR: "//ListName//" not found!!!", >> WarningFile)
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
  print("stfixcurvature: ******************* processing files *********************")
  if (LogLevel > 2)
    print("stfixcurvature: ******************* processing files *********************", >> LogFile)
  while (fscan (P_ImageList, In) != EOF){

#    print("stfixcurvature: In = "//In)
#    if (LogLevel > 1)
#      print("stfixcurvature: In = "//In, >> LogFile)

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
        print("stfixcurvature: old "//Out//" deleted")
        if (LogLevel > 2)
          print("stfixcurvature: old "//Out//" deleted", >> LogFile)
      }
      else{
        print("stfixcurvature: ERROR: cannot delete "//Out)
        print("stfixcurvature: ERROR: cannot delete "//Out, >> LogFile)
        print("stfixcurvature: ERROR: cannot delete "//Out, >> WarningFile)
        print("stfixcurvature: ERROR: cannot delete "//Out, >> ErrorFile)
# --- clean up
#        timelist = ""
        P_ParameterList = ""
        P_ImageList = ""
        delete(InFile, ver-, >& "dev$null")
        return
      }
    }

    print("stfixcurvature: processing "//In//", outfile = "//Out)
    if (LogLevel > 1)
      print("stfixcurvature: processing "//In//", outfile = "//Out, >> LogFile)

    if (!access(In)){
      print("stfixcurvature: ERROR: cannot access input file "//In//" => Returning")
      print("stfixcurvature: ERROR: cannot access input file "//In//" => Returning", >> LogFile)
      print("stfixcurvature: ERROR: cannot access input file "//In//" => Returning", >> ErrorFile)
      print("stfixcurvature: ERROR: cannot access input file "//In//" => Returning", >> WarningFile)
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
      print("stfixcurvature: ERROR: output file "//Out//" not accessable")
      print("stfixcurvature: ERROR: output file "//Out//" not accessable", >> LogFile)
      print("stfixcurvature: ERROR: output file "//Out//" not accessable", >> WarningFile)
      print("stfixcurvature: ERROR: output file "//Out//" not accessable", >> ErrorFile)
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
      print("stfixcurvature: WARNING: TimeFile <"//TimeFile//"> not accessable!")
      print("stfixcurvature: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
      print("stfixcurvature: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
    }

    print("stfixcurvature: "//Out//" ready")
    if (LogLevel > 1)
      print("stfixcurvature: "//Out//" ready", >> LogFile)
    print("-----------------------")
    print("-----------------------", >> LogFile)
  }

  if (access(TimeFile))
    del(TimeFile, ver-)
  time(>> TimeFile)
  if (access(TimeFile)){
    P_ParameterList = TimeFile
    if (fscan(P_ParameterList,tempday,temptime,tempdate) != EOF){
      print("stfixcurvature: stfixcurvature finished "//tempdate//"T"//temptime, >> LogFile)
    }
  }
  else{
    print("stfixcurvature: WARNING: TimeFile <"//TimeFile//"> not accessable!")
    print("stfixcurvature: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
    print("stfixcurvature: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
  }

# --- clean up
  P_ParameterList = ""
  P_ImageList = ""
#  timelist = ""
  delete (InFile, ver-, >& "dev$null")
end
