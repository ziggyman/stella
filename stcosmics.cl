procedure stcosmics (Images)

##################################################################
#                                                                #
# NAME:             stcosmics                                    #
# PURPOSE:          * This program rejects the cosmic-ray hits   #
#                     of the STELLA spectra automatically        #
#                                                                #
# CATEGORY:         Data reduction                               #
# CALLING SEQUENCE: stcosmics(Images)                            #
# INPUTS:           images:                                      #
#                     either: name of single image:              #
#                              "HD175640_botzf.fits"             #
#                     or: name of list containing names of       #
#                         images to trace:                       #
#                             "objects_botzf.list":              #
#                               HD175640_botzf.fits              #
#                               ...                              #
#                                                                #
# OUTPUTS:          output: -                                    #
#                   outfile: "<name_of_infile_root>x."//<ImType> #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      26.02.2002                                   #
# LAST EDITED:      02.04.2007                                   #
#                                                                #
##################################################################

string Images           = "@obs_botzf.list"        {prompt="List of images to reject cosmicrays"}
string ErrorImages      = "@stcosmics_err.list"    {prompt="List of error images"}
bool   RejectCosmics    = YES                      {prompt="Run crutil.cosmicrays task? [YES|NO]"}
string Task             = "lacosmic"               {prompt="Name of task to use [lacosmic|cosmicrays]",
                                                    enum="lacosmic|cosmicrays"}
real   CFluxRatio        = 8.                       {prompt="Cosmicrays: Flux ratio threshold (in percent)"}
real   CMultThreshold    = 4.5                      {prompt="Cosmicrays: Multiply stddev with this number to calc threshold"}
int    CWindow           = 7                        {prompt="Cosmicrays: Size of detection window"}
int    CGrow             = 0                        {prompt="Cosmicrays: Grow cosmic-ray hits by this number of pixels"}
bool   CInteractive      = YES                      {prompt="Cosmicrays: Examine parameters interactively? [YES|NO]"}
bool   CTreatAsBadPix    = YES                      {prompt="Cosmicrays: Treat found cosmic rays as bad pixels? [YES|NO]"}
int    LAC_XOrder        = 9                        {prompt="LACosmic: Order of object fit (0=no fit)"}
int    LAC_YOrder        = 5                        {prompt="LACosmic: Order of sky line fit (0=no fit)"}
real   LAC_SigClip       = 4.5                      {prompt="LACosmic: Detection limit for cosmic rays (sigma)"}
real   LAC_SigFrac       = 0.5                      {prompt="LACosmic: Fractional detection limit for neighbouring pixels"}
real   LAC_ObjLimit      = 1.                       {prompt="LACosmic: Contrast limit between CR and underlying object"}
int    NPasses          = 4                        {prompt="Cosmicrays: Number of detection passes"}
real   Gain             = 0.68                     {prompt="CCD Gain"}
real   RdNoise          = 3.6                      {prompt="CCD Readout Noise"}
string ReadAxis         = "line"                   {prompt="Cosmicrays: Read out axis (line|column)",
                                                     enum="line|column"}
string ImType           = "fits"                   {prompt="Image Type"}
bool   DoErrors         = YES                      {prompt="Calculate error propagation? [YES|NO]"}
bool   DelInput         = NO                       {prompt="Delete input Images after processing? [YES|NO]"}
int    LogLevel         = 3                        {prompt="Level for writing logfile"}
string LogFile          = "logfile_stcosmics.log"  {prompt="Name of log file"}
string WarningFile      = "warnings_stcosmics.log" {prompt="Name of warning file"}
string ErrorFile        = "errors_stcosmics.log"   {prompt="Name of error file"}
string ParameterFile    = "parameterfile.prop"     {prompt="Name of ParameterFile"}
string *P_InputList
string *P_ErrorList
string *P_ParameterList
string *P_StatList

begin

  file   LogFileImRed
  file   StatsFile,InFile,ErrFile
  file   TimeFile = "time.txt"
  string Image,Parameter,ParameterValue,Out,ListName
  string tempdate,tempday,temptime,ErrImage,ErrOut
  string mask = "cosmics.mask"
#  string LogFile_stsetmaskval="logfile_stsetmaskval.log"
#  string WarningFile_stsetmaskval="warningfile_stsetmaskval.log"
#  string ErrorFile_stsetmaskval="errorfile_stsetmaskval.log"
  real   Mean,StdDev
#,Threshold
  real   CosmicsErrVal = 10000.
  bool   FoundLACXOrder          = NO
  bool   FoundLACYOrder          = NO
  bool   FoundLACSigClip         = NO
  bool   FoundLACSigFrac         = NO
  bool   FoundLACObjLimit        = NO
  bool   FoundReadOutAxis        = NO
  bool   FoundRejectCosmicRays    = NO
  bool   FoundNPasses             = NO
  bool   FoundCosmicMultThreshold = NO
  bool   FoundCosmicFluxRatio     = NO
  bool   FoundCosmicWindow        = NO
  bool   FoundCosmicInteractive   = NO
  bool   FoundCosmicTreatAsBadPix = NO
  bool   FoundCosmicGrow          = NO
  bool   FoundImType              = NO
  bool   FoundGain                = NO
  bool   FoundRdNoise             = NO

# --- delete old LogFiles
  if (access(LogFile))
    delete(LogFile, ver-)
  if (access(WarningFile))
    delete(WarningFile, ver-)
  if (access(ErrorFile))
    delete(ErrorFile, ver-)

  LogFileImRed = imred.logfile
  print ("stflat: LogFileImRed = "//LogFileImRed)
  imred.logfile = LogFile

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                    stcosmics.cl                        *")
  print ("*                (rejects cosmicrays)                    *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*                    stcosmics.cl                        *", >> LogFile)
  print ("*                (rejects cosmicrays)                    *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)

# --- read ParameterFile
  if (access(ParameterFile)){

    P_ParameterList = ParameterFile

    print ("stcosmics: **************** reading "//ParameterFile//" *******************")
    if (LogLevel > 2)
      print ("stcosmics: **************** reading "//ParameterFile//" *******************", >> LogFile)

    while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){

#      if (Parameter != "#")
#        print ("stcosmics: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

  # --- read int values
      if (Parameter == "cosmic_lacosmic_xorder"){ 
        LAC_XOrder = int(ParameterValue)
        print ("stcosmics: Setting LAC_XOrder to "//LAC_XOrder)
        if(LogLevel > 2)
          print ("stcosmics: Setting LAC_XOrder to "//LAC_XOrder, >> LogFile)
        FoundLACXOrder = YES
      }
      else if (Parameter == "cosmic_lacosmic_yorder"){ 
        LAC_YOrder = int(ParameterValue)
        print ("stcosmics: Setting LAC_YOrder to "//LAC_YOrder)
        if(LogLevel > 2)
          print ("stcosmics: Setting LAC_YOrder to "//LAC_YOrder, >> LogFile)
        FoundLACYOrder = YES
      }
  # --- read real values
      else if (Parameter == "gain_ccd1"){ 
        Gain = real(ParameterValue)
        print ("stcosmics: Setting Gain to "//Gain)
        if(LogLevel > 2)
          print ("stcosmics: Setting Gain to "//Gain, >> LogFile)
        FoundGain = YES
      }
      else if (Parameter == "rdnoise_ccd1"){ 
        RdNoise = real(ParameterValue)
        print ("stcosmics: Setting RdNoise to "//RdNoise)
        if(LogLevel > 2)
          print ("stcosmics: Setting RdNoise to "//RdNoise, >> LogFile)
        FoundRdNoise = YES
      }
      else if (Parameter == "cosmic_lacosmic_sigclip"){ 
        LAC_SigClip = real(ParameterValue)
        print ("stcosmics: Setting LAC_SigClip to "//LAC_SigClip)
        if(LogLevel > 2)
          print ("stcosmics: Setting LAC_SigClip to "//LAC_SigClip, >> LogFile)
        FoundLACSigClip = YES
      }
      else if (Parameter == "cosmic_lacosmic_sigfrac"){ 
        LAC_SigFrac = real(ParameterValue)
        print ("stcosmics: Setting LAC_SigFrac to "//LAC_SigFrac)
        if(LogLevel > 2)
          print ("stcosmics: Setting LAC_SigFrac to "//LAC_SigFrac, >> LogFile)
        FoundLACSigFrac = YES
      }
      else if (Parameter == "cosmic_lacosmic_objlim"){ 
        LAC_ObjLimit = real(ParameterValue)
        print ("stcosmics: Setting LAC_ObjLimit to "//LAC_ObjLimit)
        if(LogLevel > 2)
          print ("stcosmics: Setting LAC_ObjLimit to "//LAC_ObjLimit, >> LogFile)
        FoundLACObjLimit = YES
      }
      else if (Parameter == "cosmic_cosmicrays_multthreshold"){ 
        CMultThreshold = real(ParameterValue)
        print ("stcosmics: Setting CMultThreshold to "//CMultThreshold)
        if(LogLevel > 2)
          print ("stcosmics: Setting CMultThreshold to "//CMultThreshold, >> LogFile)
        FoundCosmicMultThreshold = YES
      }
      else if (Parameter == "cosmic_cosmicrays_fluxratio"){ 
        CFluxRatio = real(ParameterValue)
        print ("stcosmics: Setting CFluxRatio to "//CFluxRatio)
        if(LogLevel > 2)
          print ("stcosmics: Setting CFluxRatio to "//CFluxRatio, >> LogFile)
        FoundCosmicFluxRatio = YES
      }
      else if (Parameter == "cosmic_npasses"){ 
        NPasses = int(ParameterValue)
        print ("stcosmics: Setting NPasses to "//NPasses)
        if(LogLevel > 2)
          print ("stcosmics: Setting NPasses to "//NPasses, >> LogFile)
        FoundCosmicNPasses = YES
      }
      else if (Parameter == "cosmic_cosmicrays_window"){ 
        CWindow = int(ParameterValue)
        print ("stcosmics: Setting CWindow to "//CWindow)
        if(LogLevel > 2)
          print ("stcosmics: Setting CWindow to "//CWindow, >> LogFile)
        FoundCosmicWindow = YES
      }
      else if (Parameter == "cosmic_cosmicrays_grow"){ 
        CGrow = int(ParameterValue)
        print ("stcosmics: Setting CGrow to "//CGrow)
        if(LogLevel > 2)
          print ("stcosmics: Setting CGrow to "//CGrow, >> LogFile)
        FoundCosmicGrow = YES
      }
# --- read bool values
      else if (Parameter == "reject_cosmicrays"){ 
        if (ParameterValue == "YES" || ParameterValue == "yes"){        
          RejectCosmics = YES
          print ("stcosmics: Setting RejectCosmics to YES")
          if(LogLevel > 2)
            print ("stcosmics: Setting RejectCosmics to YES", >> LogFile)
        }
        else{
          RejectCosmics = NO
          print ("stcosmics: Setting RejectCosmics to NO")
          if(LogLevel > 2)
            print ("stcosmics: Setting RejectCosmics to NO", >> LogFile)
        }
        FoundRejectCosmicRays = YES
      }
      else if (Parameter == "cosmic_cosmicrays_interactive"){ 
        if (ParameterValue == "YES" || ParameterValue == "yes"){        
         CInteractive = YES
         print ("stcosmics: Setting CInteractive to YES")
         if (LogLevel > 2)
           print ("stcosmics: Setting CInteractive to YES", >> LogFile)
        }
        else{
         CInteractive = NO
         print ("stcosmics: Setting CInteractive to NO")
         if (LogLevel > 2)
           print ("stcosmics: Setting CInteractive to NO", >> LogFile)
        }
        FoundCosmicInteractive = YES
      }
      else if (Parameter == "cosmic_cosmicrays_treatasbadpix"){ 
        if (ParameterValue == "YES" || ParameterValue == "yes"){        
          CTreatAsBadPix = YES
          print ("stcosmics: Setting CTreatAsBadPix to YES")
          if(LogLevel > 2)
            print ("stcosmics: Setting CTreatAsBadPix to YES", >> LogFile)
        }
        else{
          CTreatAsBadPix = NO
          print ("stcosmics: Setting CTreatAsBadPix to NO")
          if(LogLevel > 2)
            print ("stcosmics: Setting CTreatAsBadPix to NO", >> LogFile)
        }
        FoundCosmicTreatAsBadPix = YES
      }
# --- read string values
      else if (Parameter == "readoutaxis"){ 
        ReadAxis = ParameterValue
        print ("stcosmics: Setting "//Parameter//" to "//ReadAxis)
        if (LogLevel > 2)
          print ("stcosmics: Setting "//Parameter//" to "//ReadAxis, >> LogFile)
        FoundReadOutAxis = YES
      }
      else if (Parameter == "imtype"){ 
        ImType = ParameterValue
        print ("stcosmics: Setting ImType to "//ImType)
        if (LogLevel > 2)
          print ("stcosmics: Setting ImType to "//ImType, >> LogFile)
        FoundImType = YES
      }
    }
    if (Task == "lacosmic"){
      if (!FoundLACXOrder){
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_xorder not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_xorder not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_xorder not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!FoundLACYOrder){
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_yorder not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_yorder not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_yorder not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!FoundLACSigClip){
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_sigclip not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_sigclip not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_sigclip not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!FoundLACSigFrac){
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_sigfrac not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_sigfrac not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_sigfrac not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!FoundLACObjLimit){
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_objlim not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_objlim not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_lacosmic_objlim not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
    }
    if (Task == "cosmicrays"){
      if (!FoundCosmicMultThreshold){
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_multthreshold not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_multthreshold not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_multthreshold not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!FoundCosmicFluxRatio){
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_fluxratio not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_fluxratio not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_fluxratio not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!FoundCosmicWindow){
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_window not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_window not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_window not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!FoundCosmicInteractive){
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_interactive not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_interactive not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_interactive not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!FoundCosmicTreatAsBadPix){
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_treatasbadpix not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_treatasbadpix not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_treatasbadpix not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
      if (!FoundCosmicGrow){
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_grow not found in ParameterFile!!! -> using standard")
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_grow not found in ParameterFile!!! -> using standard", >> LogFile)
        print("stcosmics: WARNING: Parameter cosmic_cosmicrays_grow not found in ParameterFile!!! -> using standard", >> WarningFile)
      }
    }
    if (!FoundGain){
      print("stcosmics: WARNING: Parameter gain_ccd1 not found in ParameterFile!!! -> using standard")
      print("stcosmics: WARNING: Parameter gain_ccd1 not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stcosmics: WARNING: Parameter gain_ccd1 not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundRdNoise){
      print("stcosmics: WARNING: Parameter rdnoise_ccd1 not found in ParameterFile!!! -> using standard")
      print("stcosmics: WARNING: Parameter rdnoise_ccd1 not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stcosmics: WARNING: Parameter rdnoise_ccd1 not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundRejectCosmicRays){
      print("stcosmics: WARNING: Parameter reject_cosmicrays not found in ParameterFile!!! -> using standard")
      print("stcosmics: WARNING: Parameter reject_cosmicrays not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stcosmics: WARNING: Parameter reject_cosmicrays not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundNPasses){
      print("stcosmics: WARNING: Parameter cosmic_npasses not found in ParameterFile!!! -> using standard")
      print("stcosmics: WARNING: Parameter cosmic_npasses not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stcosmics: WARNING: Parameter cosmic_npasses not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundReadOutAxis){
      print("stcosmics: WARNING: Parameter readoutaxis not found in ParameterFile!!! -> using standard")
      print("stcosmics: WARNING: Parameter readoutaxis not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stcosmics: WARNING: Parameter readoutaxis not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundImType){
      print("stcosmics: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard")
      print("stcosmics: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stcosmics: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
  }
  else{
    print("stcosmics: WARNING: ParameterFile "//ParameterFile//" not found!!! -> using standard Parameters")
    print("stcosmics: WARNING: ParameterFile "//ParameterFile//" not found!!! -> using standard Parameters", >> LogFile)
    print("stcosmics: WARNING: ParameterFile "//ParameterFile//" not found!!! -> using standard Parameters", >> WarningFile)
  }

# --- Erzeugen von temporaeren Filenamen
  print("stcosmics: building temp-filenames")
  if (LogLevel > 2)
    print("stcosmics: building temp-filenames", >> LogFile)
  InFile    = mktemp ("tmp")
  ErrFile   = mktemp ("tmp")
  StatsFile  = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stcosmics: building lists from temp-files")
  if (LogLevel > 2)
    print("stcosmics: building lists from temp-files", >> LogFile)

  if (substr(Images,1,1) == "@")
    ListName = substr(Images,2,strlen(Images))
  else
    ListName = Images
  if (!access(ListName)){
    print("stcosmics: ERROR: "//ListName//" not found!!!")
    print("stcosmics: ERROR: "//ListName//" not found!!!", >> LogFile)
    print("stcosmics: ERROR: "//ListName//" not found!!!", >> ErrorFile)
    print("stcosmics: ERROR: "//ListName//" not found!!!", >> WarningFile)
# --- clean up
    imred.logfile = LogFileImRed
    delete (InFile, ver-, >& "dev$null")
    delete (ErrFile, ver-, >& "dev$null")
    delete (StatsFile, ver-, >& "dev$null")
    P_InputList     = ""
    P_ErrorList     = ""
    P_ParameterList = ""
#   timelist      = ""
    P_StatList      = ""
    return
  }
  sections(Images, option="root", > InFile)
  P_InputList = InFile
  if (DoErrors){
    if (substr(ErrorImages,1,1) == "@")
      ListName = substr(ErrorImages,2,strlen(ErrorImages))
    else
      ListName = ErrorImages
    if (!access(ListName)){
      print("stcosmics: ERROR: "//ListName//" not found!!!")
      print("stcosmics: ERROR: "//ListName//" not found!!!", >> LogFile)
      print("stcosmics: ERROR: "//ListName//" not found!!!", >> ErrorFile)
      print("stcosmics: ERROR: "//ListName//" not found!!!", >> WarningFile)
# --- clean up
      imred.logfile = LogFileImRed
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      delete (StatsFile, ver-, >& "dev$null")
      P_InputList     = ""
      P_ErrorList     = ""
      P_ParameterList = ""
#      timelist      = ""
      P_StatList      = ""
      return
    }
    sections(ErrorImages, option="root", > ErrFile)
    P_ErrorList = ErrFile
  }

  if (!RejectCosmics){
    while (fscan (P_InputList, Image) != EOF){

      if (substr(Image,strlen(Image)-strlen(ImType),strlen(Image)) != "."//ImType)
        Image = Image//"."//ImType
      if (!access(Image)){
        print("stcosmics: ERROR: Image <"//Image//"> not found!!!")
        print("stcosmics: ERROR: Image <"//Image//"> not found!!!", >> LogFile)
        print("stcosmics: ERROR: Image <"//Image//"> not found!!!", >> ErrorFile)
        print("stcosmics: ERROR: Image <"//Image//"> not found!!!", >> WarningFile)
# --- clean up
        imred.logfile = LogFileImRed
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        delete (StatsFile, ver-, >& "dev$null")
        P_InputList     = ""
        P_ErrorList     = ""
        P_ParameterList = ""
#      timelist      = ""
        P_StatList      = ""
        return
      }
      Out = substr(Image, 1, strlen(Image)-strlen(ImType)-1)//"x."//ImType

      if (access(Out)){
        imdel(Out, ver-)
        if (access(Out))
          del(Out,ver-)
        if (!access(Out)){
          print("stcosmics: old "//Out//" deleted")
          if (LogLevel > 2)
            print("stcosmics: old "//Out//" deleted", >> LogFile)
        }
        else{
          print("stcosmics: ERROR: cannot delete "//Out)
          print("stcosmics: ERROR: cannot delete "//Out, >> LogFile)
          print("stcosmics: ERROR: cannot delete "//Out, >> WarningFile)
          print("stcosmics: ERROR: cannot delete "//Out, >> ErrorFile)
        }
      }
 
      print("stcosmics: copying InFile="//Image//" to Outfile="//Out)
      if (LogLevel > 1)
        print("stcosmics: copying InFile="//Image//" to Outfile="//Out, >> LogFile)    

# --- rename (copy) input files
      imcopy(input=Image, output=Out)

      if (!access(Out)){
        print("stcosmics: ERROR: cannot access "//Out)
        print("stcosmics: ERROR: cannot access "//Out, >> LogFile)
        print("stcosmics: ERROR: cannot access "//Out, >> WarningFile)
        print("stcosmics: ERROR: cannot access "//Out, >> ErrorFile)
# --- clean up
        imred.logfile = LogFileImRed
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        delete (StatsFile, ver-, >& "dev$null")
        P_InputList     = ""
        P_ErrorList     = ""
        P_ParameterList = ""
#      timelist      = ""
        P_StatList      = ""
        return
      }
      if (DoErrors){
        mask = substr(Image, 1, strlen(Image)-5)//"_crmask."//ImType
        if (access(mask))
          del(mask, ver-)
        if (fscan (P_ErrorList, ErrImage) == EOF){
          print("stcosmics: ERROR: fscan P_ErrorList <"//ErrorImages//"> returned FALSE!")
          print("stcosmics: ERROR: fscan P_ErrorList <"//ErrorImages//"> returned FALSE!", >> LogFile)
          print("stcosmics: ERROR: fscan P_ErrorList <"//ErrorImages//"> returned FALSE!", >> WarningFile)
          print("stcosmics: ERROR: fscan P_ErrorList <"//ErrorImages//"> returned FALSE!", >> ErrorFile)
# --- clean up
          imred.logfile = LogFileImRed
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          delete (StatsFile, ver-, >& "dev$null")
          P_InputList     = ""
          P_ErrorList     = ""
          P_ParameterList = ""
#      timelist      = ""
          P_StatList      = ""
          return
        }
        i = strlen(ErrImage)
        if (substr (ErrImage, i-strlen(ImType), i) != "."//ImType)
          ErrImage = ErrImage//"."//ImType
        if (!access(ErrImage)){
          print("stcosmics: ERROR: cannot access ErrImage <"//ErrImage//">!")
          print("stcosmics: ERROR: cannot access ErrImage <"//ErrImage//">!", >> LogFile)
          print("stcosmics: ERROR: cannot access ErrImage <"//ErrImage//">!", >> WarningFile)
          print("stcosmics: ERROR: cannot access ErrImage <"//ErrImage//">!", >> ErrorFile)
# --- clean up
          imred.logfile = LogFileImRed
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          delete (StatsFile, ver-, >& "dev$null")
          P_InputList     = ""
          P_ErrorList     = ""
          P_ParameterList = ""
#      timelist      = ""
          P_StatList      = ""
          return
        }
        ErrOut = substr(ErrImage, 1, i-strlen(ImType)-1)//"x."//ImType
        if (access(ErrOut))
          del(ErrOut, ver-)
        imcopy(input=ErrImage,
               output=ErrOut,
               ver-)
        if (access(ErrOut)){
          print("stcosmics: ErrOut <"//ErrOut//"> ready")
          if (LogLevel > 2)
            print("stcosmics: ErrOut <"//ErrOut//"> ready", >> LogFile)
        }
        else{
          print("stcosmics: ERROR: cannot access ErrOut <"//ErrOut//">!")
          print("stcosmics: ERROR: cannot access ErrOut <"//ErrOut//">!", >> LogFile)
          print("stcosmics: ERROR: cannot access ErrOut <"//ErrOut//">!", >> WarningFile)
          print("stcosmics: ERROR: cannot access ErrOut <"//ErrOut//">!", >> ErrorFile)
# --- clean up
          imred.logfile = LogFileImRed
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          delete (StatsFile, ver-, >& "dev$null")
          P_InputList     = ""
          P_ErrorList     = ""
          P_ParameterList = ""
#      timelist      = ""
          P_StatList      = ""
          return
        }
      }# end if (DoErrors)
    }# end while (fscan (P_InputList, Image) != EOF){
  }# end if (!RejectCosmics)
  else{# Reject Cosmics
# --- view image statistics
    print("stcosmics: ***************** image statistics ******************")
    if (LogLevel > 2)
      print("stcosmics: ***************** image statistics ******************", >> LogFile)
    imstat(Images,format-, fields="image,mean,stddev",>StatsFile)
    P_StatList = StatsFile

    while (fscan (P_StatList, Image, Mean, StdDev) != EOF){
      print("stcosmics: "//Image//": Mean = "//Mean//", StdDev = "//StdDev)
      if (LogLevel > 2)
      print("stcosmics: "//Image//": Mean = "//Mean//", StdDev = "//StdDev, >> LogFile)
    }

# --- calculate FluxRatio and Threshold
    print("stcosmics: ***************** rejecting cosmicrays ********************")
    if (LogLevel > 2)
      print("stcosmics: ***************** rejecting cosmicrays ********************", >> LogFile)
  
    P_StatList = StatsFile

    while (fscan (P_StatList, Image, Mean, StdDev) != EOF){

      if (substr(Image,strlen(Image)-strlen(ImType),strlen(Image)) == "."//ImType)
        Out = substr(Image, 1, strlen(Image)-strlen(ImType)-1)//"x."//ImType
      else
      Out = Image//"x"

#    print("stcosmics: Outfile = "//Out)

      if (access(Out)){
        if (access(Out))
          del(Out,ver-)
        if (!access(Out)){
          print("stcosmics: old "//Out//" deleted")
          if (LogLevel > 2)
            print("stcosmics: old "//Out//" deleted", >> LogFile)
        }
        else{
          print("stcosmics: ERROR: cannot delete "//Out)
          print("stcosmics: ERROR: cannot delete "//Out, >> LogFile)
          print("stcosmics: ERROR: cannot delete "//Out, >> WarningFile)
          print("stcosmics: ERROR: cannot delete "//Out, >> ErrorFile)
# --- clean up
          imred.logfile = LogFileImRed
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          delete (StatsFile, ver-, >& "dev$null")
          P_InputList     = ""
          P_ErrorList     = ""
          P_ParameterList = ""
#      timelist      = ""
          P_StatList      = ""
          return
        }
      }
 
      print("stcosmics: InFile="//Image//", Outfile="//Out)
      if (LogLevel > 1)
        print("stcosmics: InFile="//Image//", Outfile="//Out, >> LogFile)    

      if (DoErrors){
        mask = substr(Image, 1, strlen(Image)-5)//"_crmask."//ImType
        if (access(mask))
          del(mask, ver-)
      }

# --- reject cosmicrays
      if (!access(Image)){
        print("stcosmics: ERROR: CANNOT ACCESS "//Image//"!!!")
        print("stcosmics: ERROR: CANNOT ACCESS "//Image//"!!!", >> LogFile)
        print("stcosmics: ERROR: CANNOT ACCESS "//Image//"!!!", >> ErrorFile)
        print("stcosmics: ERROR: CANNOT ACCESS "//Image//"!!!", >> WarningFile)
# --- clean up
        imred.logfile = LogFileImRed
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        delete (StatsFile, ver-, >& "dev$null")
        P_InputList     = ""
        P_ErrorList     = ""
        P_ParameterList = ""
#      timelist      = ""
        P_StatList      = ""
        return
      }
      flpr
      flpr
      if (Task == "cosmicrays"){
        cosmicrays(input     = Image, 
                   output    = Out, 
		   crmasks   = "",
		   threshold = CMultThreshold*StdDev, 
		   fluxratio = CFluxRatio, 
		   npasses   = NPasses, 
		   window    = CWindow, 
		   interac   = CInteractive, 
		   train-, 
		   objects   = "", 
		   savefil   = "", 
		   answer    = YES)
      }
      else if (Task == "lacosmic"){
	stsdas
	lacos_spec(input   = Image,
                   output  = Out,
                   outmask = "",
                   gain = Gain,
                   readn = RdNoise,
                   xorder = LAC_XOrder,
                   yorder = LAC_YOrder,
                   sigclip = LAC_SigClip,
                   sigfrac = LAC_SigFrac,
                   objlim = LAC_ObjLimit,
                   niter = NPasses,
                   verbose = YES,            
                   mode = "al")
      }
      if (!access(Out)){
        print("stcosmics: ERROR: CANNOT ACCESS "//Out//"!!!")
        print("stcosmics: ERROR: CANNOT ACCESS "//Out//"!!!", >> LogFile)
        print("stcosmics: ERROR: CANNOT ACCESS "//Out//"!!!", >> ErrorFile)
        print("stcosmics: ERROR: CANNOT ACCESS "//Out//"!!!", >> WarningFile)
# --- clean up
        imred.logfile = LogFileImRed
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        delete (StatsFile, ver-, >& "dev$null")
        P_InputList     = ""
        P_ErrorList     = ""
        P_ParameterList = ""
#      timelist      = ""
        P_StatList      = ""
        return
      }

      if (DoErrors){
        imarith(operand1 = Image,
                op       = "-",
		operand2 = Out,
		result   = mask,
		title    = "crmask",
		divzero  = 1.,
		hparams  = "",
		pixtype  = "real",
		calctype = "real",
		ver-,
		noact-)
        if (!access(mask)){
          print("stcosmics: ERROR: cannot access maskfile <"//mask//">!")
          print("stcosmics: ERROR: cannot access maskfile <"//mask//">!", >> LogFile)
          print("stcosmics: ERROR: cannot access maskfile <"//mask//">!", >> WarningFile)
          print("stcosmics: ERROR: cannot access maskfile <"//mask//">!", >> ErrorFile)
# --- clean up
          imred.logfile = LogFileImRed
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          delete (StatsFile, ver-, >& "dev$null")
          P_InputList     = ""
          P_ErrorList     = ""
          P_ParameterList = ""
#      timelist      = ""
          P_StatList      = ""
          return
        }
        imreplace(images    = mask,
                  value     = CosmicsErrVal,
		  imaginary = 0.,
		  lower     = 0.1,
		  upper     = INDEF,
		  radius    = Grow)
        if (fscan (P_ErrorList, ErrImage) == EOF){
          print("stcosmics: ERROR: fscan P_ErrorList <"//ErrorImages//"> returned FALSE!")
          print("stcosmics: ERROR: fscan P_ErrorList <"//ErrorImages//"> returned FALSE!", >> LogFile)
          print("stcosmics: ERROR: fscan P_ErrorList <"//ErrorImages//"> returned FALSE!", >> WarningFile)
          print("stcosmics: ERROR: fscan P_ErrorList <"//ErrorImages//"> returned FALSE!", >> ErrorFile)
# --- clean up
          imred.logfile = LogFileImRed
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          delete (StatsFile, ver-, >& "dev$null")
          P_InputList     = ""
          P_ErrorList     = ""
          P_ParameterList = ""
#      timelist      = ""
          P_StatList      = ""
          return
        }
        i = strlen(ErrImage)
        if (substr (ErrImage, i-strlen(ImType), i) != "."//ImType)
          ErrImage = ErrImage//"."//ImType
        if (!access(ErrImage)){
          print("stcosmics: ERROR: cannot access ErrImage <"//ErrImage//">!")
          print("stcosmics: ERROR: cannot access ErrImage <"//ErrImage//">!", >> LogFile)
          print("stcosmics: ERROR: cannot access ErrImage <"//ErrImage//">!", >> WarningFile)
          print("stcosmics: ERROR: cannot access ErrImage <"//ErrImage//">!", >> ErrorFile)
# --- clean up
          imred.logfile = LogFileImRed
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          delete (StatsFile, ver-, >& "dev$null")
          P_InputList     = ""
          P_ErrorList     = ""
          P_ParameterList = ""
#      timelist      = ""
          P_StatList      = ""
          return
        }

        ErrOut = substr(ErrImage, 1, i-strlen(ImType)-1)//"x."//ImType
        if (access(ErrOut))
          del(ErrOut, ver-)
        imarith(operand1 = ErrImage,
                op       = "+",
		operand2 = mask,
		result   = ErrOut,
		title    = "",
		divzero=0.,
		hparams  = "",
		pixtype  = "real",
		calctype = "real",
		ver-,
		noact-)
#            imcopy(input=ErrImage,
#                         output=ErrOut,
#                         ver-)
#                  stsetmaskval(images=ErrOut,
#                               maskfile=mask,
#                               value=CosmicsErrVal,
#                               loglevel=LogLevel,
#                               logfile=LogFile_stsetmaskval,
#                               warningfile=WarningFile_stsetmaskval,
#                               errorfile=ErrorFile_stsetmaskval)
#                  if (access(LogFile_stsetmaskval))
#                    cat(LogFile_stsetmaskval, >> LogFile)
#                  if (access(WarningFile_stsetmaskval))
#                    cat(WarningFile_stsetmaskval, >> WarningFile)
#                  if (access(ErrorFile_stsetmaskval))
#                    cat(ErrorFile_stsetmaskval, >> ErrorFile)
        if (access(ErrOut)){
          print("stcosmics: ErrOut <"//ErrOut//"> ready")
          if (LogLevel > 2)
            print("stcosmics: ErrOut <"//ErrOut//"> ready", >> LogFile)
        }
        else{
          print("stcosmics: ERROR: cannot access ErrOut <"//ErrOut//">!")
          print("stcosmics: ERROR: cannot access ErrOut <"//ErrOut//">!", >> LogFile)
          print("stcosmics: ERROR: cannot access ErrOut <"//ErrOut//">!", >> WarningFile)
          print("stcosmics: ERROR: cannot access ErrOut <"//ErrOut//">!", >> ErrorFile)
# --- clean up
          imred.logfile = LogFileImRed
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          delete (StatsFile, ver-, >& "dev$null")
          P_InputList     = ""
          P_ErrorList     = ""
          P_ParameterList = ""
#      timelist      = ""
          P_StatList      = ""
          return
        }
        if (Task == "cosmicrays"){
          if (TreatAsBadPix){
            del (Out, ver-)
            hedit(images = Image,
                  fields = "FIXPIX",
		  add-,
		  addon-,
		  del+,
		  ver-,
		  show+,
		  upda+)
            hedit(images = Image,
		  fields = "FIXFILE",
		  value  = mask,
		  add+,
		  addon-,
		  del-,
		  ver-,
		  show+,
		  upda+)
                
            ccdproc(images   = Image,
                    output   = Out,
		    ccdtype  = "", 
		    max_cac  = 0, 
		    noproc-,
		    fixpix+,
		    overscan-,
		    trim-,
		    zerocor-,
		    darkcor-,
		    flatcor-,
		    illumco-,
		    fringec-,
		    readcor-,
		    scancor-,
		    readaxis = ReadAxis,
		    minrepl  = 0.,
		    scantyp  = "shortscan",
		    nscan    = 1,
		    fixfile  = "image",
		    interac  = Interactive,
		    grow     = Grow)
          }
	}
      }

      if (access(TimeFile))
        del(TimeFile, ver-)
      time(>> TimeFile)
      if (access(TimeFile)){
        P_ParameterList = TimeFile
        if (fscan(P_ParameterList,tempday,temptime,tempdate) != EOF){
          hedit(images=Out,
                fields="STCOSMIC",
                value="cosmic rays rejected "//tempdate//"T"//temptime,
		add+,
		addonly-,
		del-,
		ver-,
		show+,
		update+)
        }
      }
      else{
        print("stcosmics: WARNING: TimeFile <"//TimeFile//"> not accessable!")
        print("stcosmics: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
        print("stcosmics: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
      }

      if (DelInput)
        imdel(Image, ver-)
      if (DelInput && access(Image))
        del(Image, ver-)

      print("stcosmics: <"//Out//"> ready")
      if (LogLevel > 1)
        print("stcosmics: <"//Out//"> ready", >> LogFile)
    }# end while (fscan(...))
  }# end else if (rejectCosmicRays)

  if (access(TimeFile))
    del(TimeFile, ver-)
  time(>> TimeFile)
  if (access(TimeFile)){
    P_ParameterList = TimeFile
    if (fscan(P_ParameterList,tempday,temptime,tempdate) != EOF){
      print("stcosmics: stcosmics finished "//tempdate//"T"//temptime)
      print("stcosmics: stcosmics finished "//tempdate//"T"//temptime, >> LogFile)
    }
  }
  else{
    print("stcosmics: WARNING: TimeFile <"//TimeFile//"> not accessable!")
    print("stcosmics: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
    print("stcosmics: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
  }

# --- clean up
  imred.logfile = LogFileImRed
  delete (StatsFile, ver-)
  delete (InFile, ver-, >& "dev$null")
  delete (ErrFile, ver-, >& "dev$null")
  P_InputList     = ""
  P_StatList      = ""
#  timelist      = ""
  P_ParameterList = ""
  P_ErrorList     = ""

end
