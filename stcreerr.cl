procedure stcreerr (Images)

###################################################################
#                                                                 #
#    This program creates the photon-noise file for the STELLA    #
#                    spectra automatically                        #
#                                                                 #
# output = sqrt((input(after overscan and zero subtraction)       #
#                / Gain) + (RdNoise^2))                           #
#                                                                 #
#                      output = *_e.fits                          #
#                                                                 #
#      Andreas Ritter, 26.01.2006                                 #
#                                                                 #
###################################################################

string Images           = "@tocreateerrfile.list"       {prompt="List of images to create error images from"}
string ParameterFile    = "scripts$parameterfiles/parameterfile.prop"          {prompt="Name of parameterfile"}
int    NumCCDs          = 1                             {prompt="Number of CCDs"}
string CCDSec           = "[*,*]"                       {prompt="CCD section"}
real   RdNoise          = 6.0                           {prompt="CCD readout noise"}
real   SNoise           = 0.                            {prompt="CCD sensitivity noise"}
real   Gain             = 1.0                           {prompt="CCD gain"}
string ImType           = "fits"                        {prompt="Image type"}
int    LogLevel         = 3                             {prompt="Level for writing LogFile"}
string LogFile          = "logfile_stcreerr.log"        {prompt="Name of log file"}
string WarningFile      = "warnings_stcreerr.log"       {prompt="Name of warning file"}
string ErrorFile        = "errors_stcreerr.log"         {prompt="Name of error file"}
int    Status           = 1
string *P_InputList
string *P_ParameterList
string *P_TimeList

begin
  file   InFile
  int    i_ccd
  string Image,Parameter,ParameterValue,Out,ListName
  string TimeFile  = "time.txt"
  string TempFile  = "temp.fits"
  string TempFileA = "tempa.fits"
  string tempdate,tempday,temptime
  bool   FoundRdNoise        = NO
  bool   FoundSNoise         = NO
  bool   FoundGain           = NO
  bool   FoundImType         = NO
  bool   FoundCCDSec         = NO
  bool   FoundNumber_of_CCDs = NO

  Status = 1

# --- delete old logfiles
  if (access(LogFile))
    delete(LogFile, ver-)
  if (access(WarningFile))
    delete(WarningFile, ver-)
  if (access(ErrorFile))
    delete(ErrorFile, ver-)

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                    stcreerr.cl                         *")
  print ("*               (create error images)                    *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*                    stcreerr.cl                         *", >> LogFile)
  print ("*               (create error images)                    *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)

# --- read ParameterFile
  if (access(ParameterFile)){

    P_ParameterList = ParameterFile

    print ("stcreerr: **************** reading "//ParameterFile//" *******************")
    if (LogLevel > 2)
      print ("stcreerr: **************** reading "//ParameterFile//" *******************", >> LogFile)

    while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){

#      if (Parameter != "#")
#        print ("stcreerr: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

  # --- read real values
      if (Parameter == "number_of_ccds"){
        NumCCDs = int(ParameterValue)
        print ("stcreerr: Setting "//Parameter//" to "//ParameterValue)
        if (LogLevel > 2)
          print ("stcreerr: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
        FoundNumber_of_CCDs = YES
      }
      else if (Parameter == "imtype"){
        ImType = ParameterValue
        print ("stcreerr: Setting ImType to "//ImType)
        if(LogLevel > 2)
          print ("stcreerr: Setting ImType to "//ImType, >> LogFile)
        FoundImType = YES
      }
    }
    if (!FoundNumber_of_CCDs){
      print("stcreerr: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1")
      print("stcreerr: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1", >> LogFile)
      print("stcreerr: WARNING: Parameter number_of_ccds not found in ParameterFile!!! -> using standard value 1", >> WarningFile)
      NumCCDs = 1
    }
    if (!FoundImType){
      print("stcreerr: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard value (="//ImType//")")
      print("stcreerr: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard value (="//ImType//")", >> LogFile)
      print("stcreerr: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard value (="//ImType//")", >> WarningFile)
    }
  }
  else{
    print("stcreerr: WARNING: ParameterFile "//ParameterFile//" not found!!! -> using standard Parameters")
    print("stcreerr: WARNING: ParameterFile "//ParameterFile//" not found!!! -> using standard Parameters", >> LogFile)
    print("stcreerr: WARNING: ParameterFile "//ParameterFile//" not found!!! -> using standard Parameters", >> WarningFile)
  }

# --- Erzeugen von temporaeren Filenamen
  print("stcreerr: **************** building temp-filenames")
  if (LogLevel > 2)
    print("stcreerr: building temp-filenames", >> LogFile)
  InFile      = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stcreerr: building lists from temp-files")
  if (LogLevel > 2)
    print("stcreerr: building lists from temp-files", >> LogFile)

  if (substr(Images,1,1) == "@")
    ListName = substr(Images,2,strlen(Images))
  else
    ListName = Images
  if (!access(ListName)){
    print("stcreerr: ERROR: "//ListName//" not found!!!")
    print("stcreerr: ERROR: "//ListName//" not found!!!", >> LogFile)
    print("stcreerr: ERROR: "//ListName//" not found!!!", >> ErrorFile)
    print("stcreerr: ERROR: "//ListName//" not found!!!", >> WarningFile)
# --- clean up
    if (access(TempFile)){
      imdel(TempFile, ver-)
      if (access(TempFile))
        del(TempFile, ver-)
    }
    if (access(TempFileA)){
      imdel(TempFileA, ver-)
      if (access(TempFileA))
        del(TempFileA, ver-)
    }
    delete (InFile, ver-, >& "dev$null")
    P_InputList     = ""
    P_ParameterList = ""
    P_TimeList      = ""
    Status = 0
    return
  }

  sections(Images, option="root", > InFile)
  P_InputList = InFile

  while (fscan (P_InputList, Image) != EOF){

    if (substr(Image,strlen(Image)-strlen(ImType),strlen(Image)) != "."//ImType)
      Image = Image//"."//ImType
    Out = substr(Image, 1, strlen(Image)-strlen(ImType)-1)//"_e."//ImType

    if (access(Out)){
      imdel(Out, ver-)
      if (access(Out))
        del(Out,ver-)
      if (!access(Out)){
        print("stcreerr: old "//Out//" deleted")
        if (LogLevel > 2)
          print("stcreerr: old "//Out//" deleted", >> LogFile)
      }
      else{
        print("stcreerr: ERROR: cannot delete "//Out)
        print("stcreerr: ERROR: cannot delete "//Out, >> LogFile)
        print("stcreerr: ERROR: cannot delete "//Out, >> WarningFile)
        print("stcreerr: ERROR: cannot delete "//Out, >> ErrorFile)
# --- clean up
        if (access(TempFile)){
          imdel(TempFile, ver-)
          if (access(TempFile))
            del(TempFile, ver-)
        }
        if (access(TempFileA)){
          imdel(TempFileA, ver-)
          if (access(TempFileA))
            del(TempFileA, ver-)
        }
        delete (InFile, ver-, >& "dev$null")
        P_InputList     = ""
        P_ParameterList = ""
        P_TimeList      = ""
        Status = 0
        return
      }
    }
    imcopy(input = Image,
           output = Out,
           verbose+)

    for(i_ccd = 1; i_ccd <= NumCCDs; i_ccd += 1){
  # --- read ParameterFile
      if (access(ParameterFile)){

        P_ParameterList = ParameterFile

        print ("stcreerr: **************** reading "//ParameterFile//" *******************")
        if (LogLevel > 2)
          print ("stcreerr: **************** reading "//ParameterFile//" *******************", >> LogFile)

        while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){

    #      if (Parameter != "#")
    #        print ("stcreerr: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

      # --- read real values
          if (Parameter == "rdnoise_ccd"//i_ccd){
            RdNoise = real(ParameterValue)
            print ("stcreerr: Setting RdNoise to "//RdNoise)
            if(LogLevel > 2)
              print ("stcreerr: Setting RdNoise to "//RdNoise, >> LogFile)
            FoundRdNoise = YES
          }
          else if (Parameter == "snoise_ccd"//i_ccd){
            SNoise = real(ParameterValue)
            print ("stcreerr: Setting SNoise to "//SNoise)
            if(LogLevel > 2)
              print ("stcreerr: Setting SNoise to "//SNoise, >> LogFile)
            FoundSNoise = YES
          }
          else if (Parameter == "gain_ccd"//i_ccd){
            Gain = real(ParameterValue)
            print ("stcreerr: Setting Gain to "//Gain)
            if(LogLevel > 2)
              print ("stcreerr: Setting Gain to "//Gain, >> LogFile)
            FoundGain = YES
          }
          else if (Parameter == "ccdsec_trimmed_ccd"//i_ccd){
            CCDSec = ParameterValue
            print ("stcreerr: Setting "//Parameter//" to "//ParameterValue)
            if (LogLevel > 2)
              print ("stcreerr: Setting "//Parameter//" to "//ParameterValue, >> LogFile)
            FoundCCDSec = YES
          }
        }
        if (!FoundRdNoise){
          print("stcreerr: WARNING: Parameter rdnoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard value (="//RdNoise//")")
          print("stcreerr: WARNING: Parameter rdnoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard value (="//RdNoise//")", >> LogFile)
          print("stcreerr: WARNING: Parameter rdnoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard value (="//RdNoise//")", >> WarningFile)
        }
        if (!FoundSNoise){
          print("stcreerr: WARNING: Parameter snoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard value (="//SNoise//")")
          print("stcreerr: WARNING: Parameter snoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard value (="//SNoise//")", >> LogFile)
          print("stcreerr: WARNING: Parameter snoise_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard value (="//SNoise//")", >> WarningFile)
        }
        if (!FoundGain){
          print("stcreerr: WARNING: Parameter gain_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard value (="//Gain//")")
          print("stcreerr: WARNING: Parameter gain_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard value (="//Gain//")", >> LogFile)
          print("stcreerr: WARNING: Parameter gain_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard value (="//Gain//")", >> WarningFile)
        }
        if (!FoundCCDSec){
          print("stcreerr: WARNING: Parameter ccdsec_trimmed_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard")
          print("stcreerr: WARNING: Parameter ccdsec_trimmed_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> LogFile)
          print("stcreerr: WARNING: Parameter ccdsec_trimmed_ccd"//i_ccd//" not found in ParameterFile!!! -> using standard", >> WarningFile)
        }
      }
      else{
        print("stcreerr: WARNING: ParameterFile "//ParameterFile//" not found!!! -> using standard Parameters")
        print("stcreerr: WARNING: ParameterFile "//ParameterFile//" not found!!! -> using standard Parameters", >> LogFile)
        print("stcreerr: WARNING: ParameterFile "//ParameterFile//" not found!!! -> using standard Parameters", >> WarningFile)
      }

      if (access(TempFile)){
        imdel(TempFile, ver-)
        if (access(TempFile))
          del(TempFile, ver-)
      }
      if (access(TempFileA)){
        imdel(TempFileA, ver-)
        if (access(TempFileA))
          del(TempFileA, ver-)
      }

      print("stcreerr: Calculating system noise and writing to Outfile="//Out)
      if (LogLevel > 1)
        print("stcreerr: Calculating system noise and writing to Outfile="//Out, >> LogFile)

  # --- Calculate photon-noise file
  #  -- multiply Image with Gain
      imarith(operand1=Image//CCDSec,
              op="/",
              operand2=Gain,
              result=TempFile,
              title="",
              divzero=0.,
              hparams="",
              pixtype="real",
              calctype="real",
              ver-,
              noact-)
      if (!access(TempFile)){
        print("stcreerr: ERROR: cannot access TempFile "//TempFile)
        print("stcreerr: ERROR: cannot access TempFile "//TempFile, >> LogFile)
        print("stcreerr: ERROR: cannot access TempFile "//TempFile, >> WarningFile)
        print("stcreerr: ERROR: cannot access TempFile "//TempFile, >> ErrorFile)
  # --- clean up
        if (access(TempFile)){
          imdel(TempFile, ver-)
          if (access(TempFile))
            del(TempFile, ver-)
        }
        if (access(TempFileA)){
          imdel(TempFileA, ver-)
          if (access(TempFileA))
            del(TempFileA, ver-)
        }
        delete (InFile, ver-, >& "dev$null")
        P_InputList     = ""
        P_ParameterList = ""
        P_TimeList      = ""
        Status = 0
        return
      }
      print("stcreerr: TempFile <"//TempFile//"> ready")
      if (LogLevel > 1)
        print("stcreerr: TempFile <"//TempFile//"> ready", >> LogFile)
  #  -- add readout noise to resultand Image
      imarith(operand1=TempFile,
              op="+",
              operand2=RdNoise*RdNoise,
              result=TempFileA,
              title="sigma image",
              divzero=0.,
              hparams="",
              pixtype="real",
              calctype="real",
              ver-,
              noact-)
      if (!access(TempFileA)){
        print("stcreerr: ERROR: cannot access TempFileA "//TempFileA)
        print("stcreerr: ERROR: cannot access TempFileA "//TempFileA, >> LogFile)
        print("stcreerr: ERROR: cannot access TempFileA "//TempFileA, >> WarningFile)
        print("stcreerr: ERROR: cannot access TempFileA "//TempFileA, >> ErrorFile)
  # --- clean up
        if (access(TempFile)){
          imdel(TempFile, ver-)
          if (access(TempFile))
            del(TempFile, ver-)
        }
        if (access(TempFileA)){
          imdel(TempFileA, ver-)
          if (access(TempFileA))
            del(TempFileA, ver-)
        }
        delete (InFile, ver-, >& "dev$null")
        P_InputList     = ""
        P_ParameterList = ""
        P_TimeList      = ""
        Status = 0
        return
      }
      print("stcreerr: TempFileA <"//TempFileA//"> ready")
      if (LogLevel > 1)
        print("stcreerr: TempFileA <"//TempFileA//"> ready", >> LogFile)
      imcopy(input = TempFileA,
             output = Out//CCDSec,
             verbose+)
      del(TempFile, ver-)
      del(TempFileA, ver-)
    }# --- end for each CCD
# --- take squareroot
    imfunction(input=Out,
               output=Out,
               function="sqrt",
               ver-)

    if (!access(Out)){
      print("stcreerr: ERROR: cannot access "//Out)
      print("stcreerr: ERROR: cannot access "//Out, >> LogFile)
      print("stcreerr: ERROR: cannot access "//Out, >> WarningFile)
      print("stcreerr: ERROR: cannot access "//Out, >> ErrorFile)
# --- clean up
      if (access(TempFile)){
        imdel(TempFile, ver-)
        if (access(TempFile))
          del(TempFile, ver-)
      }
      if (access(TempFileA)){
        imdel(TempFileA, ver-)
        if (access(TempFileA))
          del(TempFileA, ver-)
      }
      delete (InFile, ver-, >& "dev$null")
      P_InputList     = ""
      P_ParameterList = ""
      P_TimeList      = ""
      Status = 0
      return
    }
    print("stcreerr: Out <"//Out//"> ready")
    if (LogLevel > 1)
      print("stcreerr: Out <"//Out//"> ready", >> LogFile)
  }

  if (access(TimeFile))
    del(TimeFile, ver-)
  time(>> TimeFile)
  if (access(TimeFile)){
    P_TimeList = TimeFile
    if (fscan(P_TimeList,tempday,temptime,tempdate) != EOF){
      print("stcreerr: stcreerr finished "//tempdate//"T"//temptime)
      print("stcreerr: stcreerr finished "//tempdate//"T"//temptime, >> LogFile)
    }
  }
  else{
    print("stcreerr: WARNING: TimeFile <"//TimeFile//"> not accessable!")
    print("stcreerr: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
    print("stcreerr: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
  }

# --- clean up
  delete (InFile, ver-, >& "dev$null")
  P_InputList     = ""
  P_TimeList      = ""
  P_ParameterList = ""

end
