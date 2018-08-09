procedure stwriteapfiles (Reference)

#############################################################################
#                                                                           #
# This program writes the aperture definition files for obs- and caliboffset #
#                       to the database directory                           #
#                                                                           #
#               outputs = database/apObs, database/apCalibs                  #
#                                                                           #
# Andreas Ritter, 24.11.2003                                                #
#                                                                           #
#############################################################################

string Reference     = "refFlat"   {prompt="Reference aperture-definition file"}
string RefObs        = "Obs"       {prompt="Aperture-definition table outfile for objects"}
string RefCalibs      = "Calibs"     {prompt="Aperture-definition table outfile for Calib's"}
real   ObsApOffset   = 8.          {prompt="Aperture offset for objects with respect to refapimage"}
real   CalibApOffset  = 0.          {prompt="Aperture offset for Calib's with respect to refapimage"}
string ImType        = "fits"      {prompt="Image Type"}
int    LogLevel      = 3           {prompt="Level for writing LogFiles"}
string ParameterFile = "scripts$parameterfile.prop"     {prompt="parameterfile"}
string LogFile       = "logfile_stwriteapfiles.log"     {prompt="Name of log file"}
string WarningFile   = "warnings_stwriteapfiles.log"    {prompt="Name of warning file"}
string ErrorFile     = "errors_stwriteapfiles.log"      {prompt="Name of error file"}
string *P_ApList
string *P_ParameterList

begin

  string ApFirst,ApSecond,ApThird,ApFourth,ApFith,ApSixt,Parameter,ParameterValue
  string RefFlat       = ""
  string tempString    = ""
  string RefFile       = "database/"
  string ObsOut        = "database/ap"
  string CalibsOut      = "database/ap"

  bool   FoundObsApOffset   = NO
  bool   FoundCalibApOffset = NO
  bool   FoundReference     = NO
  bool   FoundImType        = NO

# --- delete old LogFiles
  if (access(LogFile))
    delete(LogFile, ver-)
  if (access(WarningFile))
    delete(WarningFile, ver-)
  if (access(ErrorFile))
    delete(ErrorFile, ver-)

# --- read ParameterFile
  if (access(ParameterFile)){

    P_ParameterList = ParameterFile

    print ("stwriteapfiles: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("stwriteapfiles: **************** reading ParameterFile *******************", >> LogFile)

    while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){

#      if (Parameter != "#")
#        print ("stwriteapfiles: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

      if (Parameter == "obsapoffset"){
        ObsApOffset = real(ParameterValue)       
        print ("stwriteapfiles: Setting "//Parameter//" to "//ObsApOffset)
        if (LogLevel > 2)
          print ("stwriteapfiles: Setting "//Parameter//" to "//ObsApOffset, >> LogFile)
        FoundObsApOffset = YES
      }
      else if (Parameter == "calibapoffset"){ 
        CalibApOffset = real(ParameterValue)
        print ("stwriteapfiles: Setting "//Parameter//" to "//CalibApOffset)
        if (LogLevel > 2)
          print ("stwriteapfiles: Setting "//Parameter//" to "//CalibApOffset, >> LogFile)
        FoundCalibApOffset = YES
      }
      else if (Parameter == "reference"){ 
        Reference = ParameterValue
        print ("stwriteapfiles: Setting "//Parameter//" to "//Reference)
        if (LogLevel > 2)
          print ("stwriteapfiles: Setting "//Parameter//" to "//Reference, >> LogFile)
        FoundReference = YES
      }
      else if (Parameter == "imtype"){ 
        ImType = ParameterValue
        print ("stwriteapfiles: Setting "//Parameter//" to "//ImType)
        if (LogLevel > 2)
          print ("stwriteapfiles: Setting "//Parameter//" to "//ImType, >> LogFile)
        FoundImType = YES
      }
    }#end while
    if (!FoundObsApOffset){
      print("stwriteapfiles: WARNING: Parameter obsapoffset not found in ParameterFile!!! -> using standard")
      print("stwriteapfiles: WARNING: Parameter obsapoffset not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stwriteapfiles: WARNING: Parameter obsapoffset not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundCalibApOffset){
      print("stwriteapfiles: WARNING: Parameter calibapoffset not found in ParameterFile!!! -> using standard")
      print("stwriteapfiles: WARNING: Parameter calibapoffset not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stwriteapfiles: WARNING: Parameter calibapoffset not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundReference){
      print("stwriteapfiles: WARNING: Parameter reference not found in ParameterFile!!! -> using standard")
      print("stwriteapfiles: WARNING: Parameter reference not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stwriteapfiles: WARNING: Parameter reference not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundImType){
      print("stwriteapfiles: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard")
      print("stwriteapfiles: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stwriteapfiles: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
  }
  else{
    print("stwriteapfiles: WARNING: ParameterFile not found!!! -> using standard Parameters")
    print("stwriteapfiles: WARNING: ParameterFile not found!!! -> using standard Parameters", >> LogFile)
    print("stwriteapfiles: WARNING: ParameterFile not found!!! -> using standard Parameters", >> WarningFile)
  }

  RefFlat = ""
  tempString = ""
  for(i=1;i<=strlen(Reference);i=i+1){
    if (substr(Reference,i,i) == "/")
      tempString = ""
    else
      tempString = tempString//substr(Reference,i,i)
  }
  RefFlat = tempString
  if (substr(RefFlat,strlen(RefFlat)-strlen(ImType),strlen(RefFlat)) == "."//ImType)
    RefFlat = substr(RefFlat,1,strlen(RefFlat)-strlen(ImType)-1)

  RefFile  = RefFile//RefFlat
  ObsOut   = ObsOut//RefObs
  CalibsOut = CalibsOut//RefCalibs
#--- change aperture definition for calibs and for objects
  if (access(RefFile)){
    if (LogLevel > 1){
      print("stwriteapfiles: writing calibApFile and obsApFile", >> LogFile)
      print("stwriteapfiles: CalibApOffset = "//CalibApOffset//", ObsApOffset = "//ObsApOffset, >> LogFile)
    }
    if (access(CalibsOut)){
      del(CalibsOut, ver-)
    }
    if (access(ObsOut)){
      del(ObsOut, ver-)
    }
    P_ApList   = RefFile
    ApFirst  = ""
    ApSecond = ""
    ApThird  = ""
    ApFourth = ""
    ApFith   = ""
    ApSixt   = ""
    print("stwriteapfiles: CalibApOffset = "//CalibApOffset)
    print("stwriteapfiles: ObsApOffset  = "//ObsApOffset)
    while (fscan (P_ApList, ApFirst, ApSecond, ApThird, ApFourth, ApFith, ApSixt) != EOF){

      if (ApFirst == "begin"){
#        print("stwriteapfiles: ApFirst = "//ApFirst//", ApSecond = "//ApSecond//", ApThird = "//ApThird//", ApFourth = "//ApFourth//", ApFith = "//ApFith//", ApSixt = "//ApSixt)
#        print("stwriteapfiles: center("//ApFourth//") = "//real(ApFith) + CalibApOffset)
	print(ApFirst//" "//ApSecond//" "//RefCalibs//" "//ApFourth//" "//real(ApFith) + CalibApOffset//" "//ApSixt, >> CalibsOut)
	print(ApFirst//" "//ApSecond//" "//RefObs//" "//ApFourth//" "//real(ApFith) + ObsApOffset//" "//ApSixt, >> ObsOut)
      }
      else if (ApFirst == "image"){
	print(ApFirst//" "//RefCalibs, >> CalibsOut)        
	print(ApFirst//" "//RefObs, >> ObsOut)        
      }
      else if (ApFirst == "center"){
	print(ApFirst//" "//real(ApSecond) + CalibApOffset//" "//ApThird, >> CalibsOut)
	print(ApFirst//" "//real(ApSecond) + ObsApOffset //" "//ApThird, >> ObsOut)
      }
      else if (ApFirst == "low"){
#        print("stwriteapfiles: "//ApFirst//" "//ApSecond//" "//ApThird//" "//ApFourth//" "//ApFith//" "//ApSixt)
	print(ApFirst//" "//ApSecond//" "//ApThird, >> CalibsOut)        
	print(ApFirst//" "//ApSecond//" "//ApThird, >> ObsOut)        
      }
      else if (ApFirst == "high"){
#        print("stwriteapfiles: "//ApFirst//" "//ApSecond//" "//ApThird//" "//ApFourth//" "//ApFith//" "//ApSixt)
	print(ApFirst//" "//ApSecond//" "//ApThird, >> CalibsOut)        
	print(ApFirst//" "//ApSecond//" "//ApThird, >> ObsOut)        
      }
      else{
	print(ApFirst//" "//ApSecond//" "//ApThird//" "//ApFourth//" "//ApFith//" "//ApSixt, >> CalibsOut)
	print(ApFirst//" "//ApSecond//" "//ApThird//" "//ApFourth//" "//ApFith//" "//ApSixt, >> ObsOut)
      }

      ApFirst  = ""
      ApSecond = ""
      ApThird  = ""
      ApFourth = ""
      ApFith   = ""
      ApSixt   = ""
    }
  }
  else{
    print("stwriteapfiles: ERROR: file database/ap"//Reference//" not found!")
    print("stwriteapfiles: ERROR: file database/ap"//Reference//" not found!", >> LogFile)
    print("stwriteapfiles: ERROR: file database/ap"//Reference//" not found!", >> WarningFile)
    print("stwriteapfiles: ERROR: file database/ap"//Reference//" not found!", >> ErrorFile)
  }

# --- aufraeumen
  P_ParameterList = ""
  P_ApList = ""
end
