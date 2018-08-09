procedure stcalcsnr (Images,ErrorImages)

###################################################################
#                                                                 #
#  This program creates the signal-to-noise file for the STELLA   #
#                    spectra automatically                        #
#                                                                 #
#                 output = <inimage>_snr.fits                     #
#                                                                 #
#      Andreas Ritter, 09.03.2006                                 #
#                                                                 #
###################################################################

string Images           = "@images.list"           {prompt="List of images to reject cosmicrays"}
string ErrorImages      = "@errors.list"           {prompt="List of images to reject cosmicrays"}
string ImType           = "fits"                   {prompt="Image type"}
int    LogLevel         = 3                         {prompt="Log level for writing logfile (1-3)"}
string LogFile          = "logfile_stcalcsnr.log"   {prompt="Name of log file"}
string WarningFile      = "warnings_stcalcsnr.log"  {prompt="Name of warning file"}
string ErrorFile        = "errors_stcalcsnr.log"    {prompt="Name of error file"}
string OutFileList                                  {prompt="Output parameter: List of output files"}
string *InputList
string *ErrorList

begin

  file   InFile,ErrFile
  string Image,ErrorImage,Out,ListName
  int    Pos

# --- delete old LogFiles
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
  print ("*                    stcalcsnr.cl                        *")
  print ("*               (calculate snr images)                   *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("stcalcsnr: Images = <"//Images//">")
  print ("stcalcsnr: ErrorImages = <"//ErrorImages//">")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*                    stcalcsnr.cl                        *", >> LogFile)
  print ("*               (calculate snr images)                   *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)
  print ("stcalcsnr: Images = <"//Images//">", >> LogFile)
  print ("stcalcsnr: ErrorImages = <"//ErrorImages//">", >> LogFile)

# --- Erzeugen von temporaeren Filenamen
  print("stcalcsnr: **************** building temp-filenames")
  if (LogLevel > 2)
    print("stcalcsnr: building temp-filenames", >> LogFile)
  InFile      = mktemp ("tmp")
  ErrFile   = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stcalcsnr: building lists from temp-files")
  if (LogLevel > 2)
    print("stcalcsnr: building lists from temp-files", >> LogFile)

  if (substr(Images,1,1) == "@"){
    ListName =substr(Images,2,strlen(Images))
  }
  else
    ListName = Images
  if (!access(ListName)){
    print("stcalcsnr: ERROR: "//ListName//" not found!!!")
    print("stcalcsnr: ERROR: "//ListName//" not found!!!", >> LogFile)
    print("stcalcsnr: ERROR: "//ListName//" not found!!!", >> ErrorFile)
    print("stcalcsnr: ERROR: "//ListName//" not found!!!", >> WarningFile)
# --- clean up
    delete (InFile, ver-, >& "dev$null")
    delete (ErrFile, ver-, >& "dev$null")
    InputList  = ""
    ErrorList  = ""
    return
  }

# --- create OutFileList
  strlastpos(ListName, ".")
  Pos = strlastpos.pos
  if (Pos == 0)
    Pos = strlen(ListName) + 1
  OutFileList = substr(ListName, 1, strlastpos.pos-1)//"_snr"//substr(ListName, strlastpos.pos, strlen(ListName))
  if (access(OutFileList))
    del(OutFileList, ver-)

# --- associate Images to InputList
  sections(Images, option="root", > InFile)
  InputList = InFile

  if ( substr(ErrorImages,1,1) == "@"){
    ListName = substr(ErrorImages,2,strlen(ErrorImages))
  }
  else
    ListName = ErrorImages
  if (!access(ListName)){
    print("stcalcsnr: ERROR: "//ListName//" not found!!!")
    print("stcalcsnr: ERROR: "//ListName//" not found!!!", >> LogFile)
    print("stcalcsnr: ERROR: "//ListName//" not found!!!", >> ErrorFile)
    print("stcalcsnr: ERROR: "//ListName//" not found!!!", >> WarningFile)
# --- clean up
    delete (InFile, ver-, >& "dev$null")
    delete (ErrFile, ver-, >& "dev$null")
    InputList  = ""
    ErrorList  = ""
    return
  }

  sections(ErrorImages, option="root", > ErrFile)
  ErrorList = ErrFile

  while (fscan (InputList, Image) != EOF){

    if (substr(Image,strlen(Image)-strlen(ImType)+1,strlen(Image)) != ImType)
      Image = Image//"."//ImType
    strlastpos(Image,".")
    Out = substr(Image, 1, strlastpos.pos-1)//"_snr."//ImType

    if (access(Out)){
      imdel(Out, ver-)
      if (access(Out))
        del(Out,ver-)
      if (!access(Out)){
        print("stcalcsnr: old "//Out//" deleted")
        if (LogLevel > 2)
          print("stcalcsnr: old "//Out//" deleted", >> LogFile)
      }
      else{
        print("stcalcsnr: ERROR: cannot delete "//Out)
        print("stcalcsnr: ERROR: cannot delete "//Out, >> LogFile)
        print("stcalcsnr: ERROR: cannot delete "//Out, >> WarningFile)
        print("stcalcsnr: ERROR: cannot delete "//Out, >> ErrorFile)
      }
    }# end if (access(Out))
    if (!access(Image)){
      print("stcalcsnr: ERROR: Image <"//Image//"> not found!!!")
      print("stcalcsnr: ERROR: Image <"//Image//"> not found!!!", >> LogFile)
      print("stcalcsnr: ERROR: Image <"//Image//"> not found!!!", >> ErrorFile)
      print("stcalcsnr: ERROR: Image <"//Image//"> not found!!!", >> WarningFile)
# --- clean up
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      InputList  = ""
      ErrorList  = ""
      return
    }
    if (fscan(ErrorList,ErrorImage) == EOF){
      print("stcalcsnr: ERROR: fscan(ErrorImages=<"//ErrorImages//">, ...) returned FALSE!!!")
      print("stcalcsnr: ERROR: fscan(ErrorImages=<"//ErrorImages//">, ...) returned FALSE!!!", >> LogFile)
      print("stcalcsnr: ERROR: fscan(ErrorImages=<"//ErrorImages//">, ...) returned FALSE!!!", >> ErrorFile)
      print("stcalcsnr: ERROR: fscan(ErrorImages=<"//ErrorImages//">, ...) returned FALSE!!!", >> WarningFile)
# --- clean up
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      InputList  = ""
      ErrorList  = ""
      return
    }
    if (!access(ErrorImage)){
      print("stcalcsnr: ERROR: ErrorImage <"//ErrorImage//"> not found!!!")
      print("stcalcsnr: ERROR: ErrorImage <"//ErrorImage//"> not found!!!", >> LogFile)
      print("stcalcsnr: ERROR: ErrorImage <"//ErrorImage//"> not found!!!", >> ErrorFile)
      print("stcalcsnr: ERROR: ErrorImage <"//ErrorImage//"> not found!!!", >> WarningFile)
# --- clean up
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      InputList  = ""
      ErrorList  = ""
      return
    }
    imarith(operand1=Image,
            op="/",
            operand2=ErrorImage,
            result=Out,
            title="SNR image",
            divzero=0.,
            hparams="",
            pixtype="real",
            calctype="real",
            ver-,
            noact-)
    if (!access(Out)){
      print("stcalcsnr: ERROR: Out <"//Out//"> not found!!!")
      print("stcalcsnr: ERROR: Out <"//Out//"> not found!!!", >> LogFile)
      print("stcalcsnr: ERROR: Out <"//Out//"> not found!!!", >> WarningFile)
      print("stcalcsnr: ERROR: Out <"//Out//"> not found!!!", >> ErrorFile)
# --- clean up
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      InputList  = ""
      ErrorList  = ""
      return
    }
    print("stcalcsnr: Out <"//Out//"> ready")
    if (LogLevel > 2)
      print("stcalcsnr: Out <"//Out//"> ready", >> LogFile)
    print(Out, >> OutFileList)
  }#end while(fscan(InputList,...))
# --- clean up
  delete (InFile, ver-, >& "dev$null")
  delete (ErrFile, ver-, >& "dev$null")
  InputList  = ""
  ErrorList  = ""
  return
end
