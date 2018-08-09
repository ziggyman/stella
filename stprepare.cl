procedure stprepare (ObjectsList, CalibsList)

##################################################################
#                                                                #
# NAME:             stprepare.cl                                 #
# PURPOSE:          * prepares the raw input images for the      #
#                     reduction process by the STELLA pipeline   #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stprepare(ObjectsList, CalibsList)           #
# INPUTS:           ObjectsList: String                          #
#                     name of list containing names of           #
#                     Object images to prepare:                  #
#                       "objects.list":                          #
#                         HD175640.fits                          #
#                         ...                                    #
#                   CalibsList: String                           #
#                     name of list containing names of           #
#                     wavelength-calibration images to prepare:  #
#                       "thars.list":                            #
#                         calib01.fits                           #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     same as input files                        #
#                   Log Files:                                   #
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      24.11.2003                                   #
# LAST EDITED:      18.04.2007                                   #
#                                                                #
##################################################################

string ObjectsList = "@objects.list" {prompt="List of Object files"}
string CalibsList  = "@calibs.list"  {prompt="List of Calib files"}
bool   DoCalibs    = YES             {prompt="Process calibration files?"}
string Observatory = "eso"           {prompt="Obs-ID"}
string Reference   = "refFlat"       {prompt="Reference flatfield image containing reference aperture definitions."}
string RefCalib    = "refCalib"      {prompt="Reference Calib containing reference dispersion informations."}
string RefApObs    = "Obs"           {prompt="Name of aperture-definition file to produce for OBJECTS (database/ap...)"}
string RefApCalibs = "Calibs"        {prompt="Name of aperture-definition file to produce for Calib'S (database/ap...)"}
string ImType      = "fits"          {prompt="Image type"}
int    LogLevel    = 3               {prompt="Level for writing logfiles"}
string IHDate      = "DATE-OBS"      {prompt="Image-header keyword for Date Of Observation"}
string IHUTC       = "UTC"           {prompt="Image-header keyword for Universal Time"}
string IHExpTime   = "EXPTIME"       {prompt="Image-header keyword for Exposure Time"}
string IHRA        = "RA"            {prompt="Image-header keyword for Rectascension"}
string IHDec       = "DEC"           {prompt="Image-header keyword for Declination"}
string IHEpoch     = "EQUINOX"       {prompt="Image-header keyword for Epoch"}
string IHJD        = "JD"            {prompt="Image-header keyword for Julian Date"}
string IHHJD       = "HJD"           {prompt="Image-header keyword for Heliocentric Julian Date"}
string IHLJD       = "LJD"           {prompt="Image-header keyword for Local Julian Date"}
string ParameterFile = "parameterfile.prop"   {prompt="ParameterFile"}
string LogFile     = "logfile_stprepare.log"  {prompt="Name of log file"}
string WarningFile = "warnings_stprepare.log" {prompt="Name of warning file"}
string ErrorFile   = "errors_stprepare.log"   {prompt="Name of error file"}
string *P_ParameterList

begin

  int    i
  int    NLinesList, NLinesSetJDLogFile
  string Parameter,ParameterValue,InImage
  string RefFlat,tempstring,RA_Str,Dec_Str
#  string RefWave
  string EditHeader = "editheader.cmds"
  string LogFile_stwriteapfiles       = "logfile_stwriteapfiles.log"
  string WarningFile_stwriteapfiles   = "warnings_stwriteapfiles.log"
  string ErrorFile_stwriteapfiles     = "errors_stwriteapfiles.log"
#  string logfile_staddheader          = "logfile_staddheader.log"
#  string WarningFile_staddheader      = "warnings_staddheader.log"
#  string ErrorFile_staddheader        = "errors_staddheader.log"
  string LogFile_setjd                = "logfile_setjd.log"

  bool   FoundObservatory                  = NO
  bool   FoundReference                    = NO
  bool   FoundRefCalib                      = NO
#  bool   Foundcalc_error_propagation       = NO
#  bool   FoundStprepare_FirstStrNo      = NO
#  bool   FoundStprepare_FirstCharNotToTake = NO
  bool   FoundStprepare_IHDate             = NO
  bool   FoundStprepare_IHUTC              = NO
#  bool   FoundStprepare_IHObject           = NO
  bool   FoundStprepare_IHExpTime          = NO
  bool   FoundStprepare_IHRA               = NO
  bool   FoundStprepare_IHDec              = NO
  bool   FoundStprepare_IHEpoch            = NO
  bool   FoundStprepare_IHJD               = NO
  bool   FoundStprepare_IHHJD              = NO
  bool   FoundStprepare_IHLJD              = NO
  bool   FoundImType                       = NO

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

    print ("stprepare: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("stprepare: **************** reading ParameterFile *******************", >> LogFile)

    while (fscan (P_ParameterList, Parameter, ParameterValue) != EOF){

#      if (Parameter != "#")
#        print ("stprepare: Parameter="//Parameter//" value="//ParameterValue, >> LogFile)

      if (Parameter == "observatory"){
        strpos(ParameterValue,"(")
        if (strpos.pos == 1)
          Observatory = ""
        else
          Observatory = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//Observatory)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//Observatory, >> LogFile)
        FoundObservatory = YES
      }
      else if (Parameter == "reference"){
        Reference = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//Reference)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//Reference, >> LogFile)
        FoundReference = YES
      }
      else if (Parameter == "refCalib"){
        RefCalib = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//RefCalib)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//RefCalib, >> LogFile)
        FoundRefCalib = YES
      }
#      else if (Parameter == "stprepare_firststringnr"){
#        FirstStrNo = real(ParameterValue)
#        print ("stprepare: Setting "//Parameter//" to "//FirstStrNo)
#        if (LogLevel > 2)
#          print ("stprepare: Setting "//Parameter//" to "//FirstStrNo, >> LogFile)
#        FoundStprepare_FirstStrNo = YES
#      }
#      else if (Parameter == "stprepare_firstcharnottotake"){
#        if (strlen(ParameterValue) == 1){
#          FirstCharNotToTake = ParameterValue
#        }
#        else{
#          FirstCharNotToTake = " "
#        }
#        print ("stprepare: Setting "//Parameter//" to '"//FirstCharNotToTake//"'")
#        if (LogLevel > 2)
#          print ("stprepare: Setting "//Parameter//" to '"//FirstCharNotToTake//"'", >> LogFile)
#        FoundStprepare_FirstCharNotToTake = YES
#      }
      else if (Parameter == "stprepare_ihdate"){
        IHDate = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//IHDate)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//IHDate, >> LogFile)
        FoundStprepare_IHDate = YES
      }
      else if (Parameter == "stprepare_ihutc"){
        strpos(ParameterValue,"(")
        if (strpos.pos == 1)
          IHUTC = ""
        else
        IHUTC = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//IHUTC)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//IHUTC, >> LogFile)
        FoundStprepare_IHUTC = YES
      }
      else if (Parameter == "imtype"){
        ImType = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//ImType)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//ImType, >> LogFile)
        FoundImType = YES
      }
      else if (Parameter == "stprepare_ihexptime"){
        strpos(ParameterValue,"(")
        if (strpos.pos == 1)
          IHExpTime = ""
        else
          IHExpTime = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//IHExpTime)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//IHExpTime, >> LogFile)
        FoundStprepare_IHExpTime = YES
      }
      else if (Parameter == "stprepare_ihra"){
        strpos(ParameterValue,"(")
        if (strpos.pos == 1)
          IHRA = ""
        else
          IHRA = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//IHRA)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//IHRA, >> LogFile)
        FoundStprepare_IHRA = YES
      }
      else if (Parameter == "stprepare_ihdec"){
        strpos(ParameterValue,"(")
        if (strpos.pos == 1)
          IHDec = ""
        else
          IHDec = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//IHDec)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//IHDec, >> LogFile)
        FoundStprepare_IHDec = YES
      }
      else if (Parameter == "stprepare_ihepoch"){
        strpos(ParameterValue,"(")
        if (strpos.pos == 1)
          IHEpoch = ""
        else
          IHEpoch = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//IHEpoch)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//IHEpoch, >> LogFile)
        FoundStprepare_IHEpoch = YES
      }
      else if (Parameter == "stprepare_ihjd"){
        IHJD = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//IHJD)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//IHJD, >> LogFile)
        FoundStprepare_IHJD = YES
      }
      else if (Parameter == "stprepare_ihhjd"){
        strpos(ParameterValue,"(")
        if (strpos.pos == 1)
          IHHJD = ""
        else
          IHHJD = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//IHHJD)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//IHHJD, >> LogFile)
        FoundStprepare_IHHJD = YES
      }
      else if (Parameter == "stprepare_ihljd"){
        IHLJD = ParameterValue
        print ("stprepare: Setting "//Parameter//" to "//IHLJD)
        if (LogLevel > 2)
          print ("stprepare: Setting "//Parameter//" to "//IHLJD, >> LogFile)
        FoundStprepare_IHLJD = YES
      }
#      else if (Parameter == "calc_error_propagation"){
#        if (ParameterValue == "YES" || ParameterValue == "yes"){
#          doerrors = YES
#	  print ("stprepare: Setting doerrors (="//Parameter//") to YES")
#	  if(LogLevel > 2)
#            print ("stprepare: Setting doerrors (="//Parameter//") to YES", >> LogFile)
#        }
#        else{
#          doerrors = NO
#	  print ("stprepare: Setting doerrors (="//Parameter//") to NO")
#	  if(LogLevel > 2)
#            print ("stprepare: Setting doerrors (="//Parameter//") to NO", >> LogFile)
#        }
#        Foundcalc_error_propagation = YES
#      }

    }#end while
#    if (!Foundcalc_error_propagation){
#      print("stprepare: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard")
#      print("stprepare: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard", >> LogFile)
#      print("stprepare: WARNING: Parameter calc_error_propagation not found in ParameterFile!!! -> using standard", >> WarningFile)
#    }
    if (!FoundObservatory){
      print("stprepare: WARNING: Parameter observatory not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter observatory not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter observatory not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundReference){
      print("stprepare: WARNING: Parameter reference not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter reference not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter reference not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundRefCalib){
      print("stprepare: WARNING: Parameter refCalib not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter refCalib not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter refCalib not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
#    if (!FoundStprepare_FirstStrNo){
#      print("stprepare: WARNING: Parameter stprepare_firststringnr not found in ParameterFile!!! -> using standard")
#      print("stprepare: WARNING: Parameter stprepare_firststringnr not found in ParameterFile!!! -> using standard", >> LogFile)
#      print("stprepare: WARNING: Parameter stprepare_firststringnr not found in ParameterFile!!! -> using standard", >> WarningFile)
#    }
#    if (!FoundStprepare_FirstCharNotToTake){
#      print("stprepare: WARNING: Parameter stprepare_firstcharnottotake not found in ParameterFile!!! -> using standard")
#      print("stprepare: WARNING: Parameter stprepare_firstcharnottotake not found in ParameterFile!!! -> using standard", >> LogFile)
#      print("stprepare: WARNING: Parameter stprepare_firstcharnottotake not found in ParameterFile!!! -> using standard", >> WarningFile)
#    }
    if (!FoundStprepare_IHDate){
      print("stprepare: WARNING: Parameter stprepare_ihdate not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter stprepare_ihdate not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter stprepare_ihdate not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundStprepare_IHUTC){
      print("stprepare: WARNING: Parameter stprepare_ihutc not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter stprepare_ihutc not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter stprepare_ihutc not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundImType){
      print("stprepare: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundStprepare_IHExpTime){
      print("stprepare: WARNING: Parameter stprepare_IHExpTime not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter stprepare_IHExpTime not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter stprepare_IHExpTime not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundStprepare_IHRA){
      print("stprepare: WARNING: Parameter stprepare_ihra not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter stprepare_ihra not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter stprepare_ihra not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundStprepare_IHDec){
      print("stprepare: WARNING: Parameter stprepare_ihdec not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter stprepare_ihdec not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter stprepare_ihdec not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundStprepare_IHEpoch){
      print("stprepare: WARNING: Parameter stprepare_ihepoch not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter stprepare_ihepoch not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter stprepare_ihepoch not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundStprepare_IHJD){
      print("stprepare: WARNING: Parameter stprepare_ihjd not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter stprepare_ihjd not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter stprepare_ihjd not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundStprepare_IHHJD){
      print("stprepare: WARNING: Parameter stprepare_ihhjd not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter stprepare_ihhjd not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter stprepare_ihhjd not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!FoundStprepare_IHLJD){
      print("stprepare: WARNING: Parameter stprepare_ihljd not found in ParameterFile!!! -> using standard")
      print("stprepare: WARNING: Parameter stprepare_ihljd not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stprepare: WARNING: Parameter stprepare_ihljd not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
  }
  else{
    print("stprepare: WARNING: ParameterFile not found!!! -> using standard Parameters")
    print("stprepare: WARNING: ParameterFile not found!!! -> using standard Parameters", >> LogFile)
    print("stprepare: WARNING: ParameterFile not found!!! -> using standard Parameters", >> WarningFile)
  }

# --- copy aperture-data and identification-table Reference to database directory
  if (!access("database"))
    mkdir(newdir="database")
  RefFlat = ""
#  RefWave = ""
  tempstring = ""
  for(i=1;i<=strlen(Reference);i=i+1){
    if (substr(Reference,i,i) == "/")
      tempstring = ""
    else
      tempstring = tempstring//substr(Reference,i,i)
  }
  RefFlat = tempstring
  if (substr(RefFlat,strlen(RefFlat)-strlen(ImType),strlen(RefFlat)) == "."//ImType)
    RefFlat = substr(RefFlat,1,strlen(RefFlat)-strlen(ImType)-1)
  if (substr(Reference,1,9) != "database/" && ((strlen(tempstring) + 9) != strlen(Reference))){
    if (access("database/"//tempstring))
      del(files="database/"//tempstring,ver-)
    copy(input=Reference,
         output="database/",
         ver-)
  }
  tempstring = ""
  for(i=1;i<=strlen(RefCalib);i=i+1){
    if (substr(RefCalib,i,i) == "/")
      tempstring = ""
    else
      tempstring = tempstring//substr(RefCalib,i,i)
  }
#  RefWave = tempstring
#  if (substr(RefWave,strlen(RefWave)-strlen(ImType),strlen(RefWave)) == "."//ImType)
#    RefWave = substr(RefWave,1,strlen(RefWave)-strlen(ImType)-1)
  if (substr(RefCalib,1,9) != "database/" && ((strlen(tempstring) + 9) != strlen(RefCalib))){
    if (access("database/"//tempstring))
      del(files="database/"//tempstring,ver-)
    copy(input=RefCalib,
         output="database/",
         ver-)
  }

# --- writing aperture-definition tables for objects and Calib's
  if (access("database/"//RefFlat)){
    print("stprepare: running stwriteapfiles")
    print("stprepare: running stwriteapfiles", >> LogFile)

    stwriteapfiles(Reference=RefFlat,
		   RefObs=RefApObs,
		   RefCalibs=RefApCalibs,
		   LogLevel=LogLevel,
		   ParameterFile = ParameterFile,
		   LogFile = LogFile_stwriteapfiles,
		   WarningFile = WarningFile_stwriteapfiles,
		   ErrorFile = ErrorFile_stwriteapfiles)
    if (access(LogFile_stwriteapfiles))
      cat(LogFile_stwriteapfiles, >> LogFile)
    if (access(WarningFile_stwriteapfiles))
      cat(WarningFile_stwriteapfiles, >> WarningFile)
    if (access(ErrorFile_stwriteapfiles))
      cat(ErrorFile_stwriteapfiles, >> ErrorFile)
  }
  else{
    print("stprepare: ERROR: cannot access database/ap"//RefFlat//"!")
    print("stprepare: ERROR: cannot access database/ap"//RefFlat//"!", >> LogFile)
    print("stprepare: ERROR: cannot access database/ap"//RefFlat//"!", >> WarningFile)
    print("stprepare: ERROR: cannot access database/ap"//RefFlat//"!", >> ErrorFile)
  }

#  if (substr(allfits_list,1,1) == "@")
#    allfits_list = substr(allfits_list,2,strlen(allfits_list))
  if (substr(ObjectsList,1,1) == "@")
    ObjectsList = substr(ObjectsList,2,strlen(ObjectsList))
  if (substr(CalibsList,1,1) == "@")
    CalibsList = substr(CalibsList,2,strlen(CalibsList))
  print("stprepare: ObjectsList = "//ObjectsList//", CalibsList = "//CalibsList)

# --- asthedit
  if (!access(ObjectsList)){
    print("stprepare: ERROR: cannot access ObjectsList (="//ObjectsList//") => returning")
    print("stprepare: ERROR: cannot access ObjectsList (="//ObjectsList//") => returning", >> LogFile)
    print("stprepare: ERROR: cannot access ObjectsList (="//ObjectsList//") => returning", >> WarningFile)
    print("stprepare: ERROR: cannot access ObjectsList (="//ObjectsList//") => returning", >> ErrorFile)
# --- clean up
    P_ParameterList = ""
    return
  }
#    staddheader(inimages="@"//ObjectsList,
#	        oldfieldname=IHDec,
#	        newfieldname="DEC_DMS",
#	        firststringnr=FirstStrNo,
#	        firstcharnottotake=FirstCharNotToTake,
#	        show+,
#	        update+,
#                loglevel = LogLevel,
#                logfile = LogFile_staddheader,
#                warningfile = WarningFile_staddheader,
#                errorfile = ErrorFile_staddheader)
#    if (access(LogFile_staddheader))
#      cat(LogFile_staddheader, >> LogFile)
#    if (access(WarningFile_staddheader))
#      cat(WarningFile_staddheader, >> WarningFile)
#    if (access(ErrorFile_staddheader)){
#      cat(ErrorFile_staddheader, >> ErrorFile)
## --- clean up
#      P_ParameterList = ""
#      return
#    }
# --- check for header keywords
  P_ParameterList = ObjectsList
  while(fscan(P_ParameterList, InImage) != EOF){
    imgets(InImage,IHDate)
    if (imgets.value == "0"){
      print("stprepare: ERROR: Image-header keyword IHDate (="//IHDate//") not found in file "//InImage//" => returning")
      print("stprepare: ERROR: Image-header keyword IHDate (="//IHDate//") not found in file "//InImage//" => returning", >> LogFile)
      print("stprepare: ERROR: Image-header keyword IHDate (="//IHDate//") not found in file "//InImage//" => returning", >> WarningFile)
      print("stprepare: ERROR: Image-header keyword IHDate (="//IHDate//") not found in file "//InImage//" => returning", >> ErrorFile)
# --- clean up
      P_ParameterList = ""
      return
    }
    strpos(imgets.value,"T")
    if (strpos.pos == 0){
      imgets(InImage,IHUTC)
      if (IHUTC != ""){
       if (imgets.value == "0"){
        print("stprepare: ERROR: Image-header keyword IHUTC (="//IHUTC//") not found in file "//InImage//" => returning")
        print("stprepare: ERROR: Image-header keyword IHUTC (="//IHUTC//") not found in file "//InImage//" => returning", >> LogFile)
        print("stprepare: ERROR: Image-header keyword IHUTC (="//IHUTC//") not found in file "//InImage//" => returning", >> WarningFile)
        print("stprepare: ERROR: Image-header keyword IHUTC (="//IHUTC//") not found in file "//InImage//" => returning", >> ErrorFile)
# --- clean up
        P_ParameterList = ""
        return
       }
      }
    }
    imgets(InImage,IHExpTime)
    if (IHExpTime != ""){
     if (imgets.value == "0"){
      print("stprepare: ERROR: Image-header keyword IHExpTime (="//IHExpTime//") not found in file "//InImage//" => returning")
      print("stprepare: ERROR: Image-header keyword IHExpTime (="//IHExpTime//") not found in file "//InImage//" => returning", >> LogFile)
      print("stprepare: ERROR: Image-header keyword IHExpTime (="//IHExpTime//") not found in file "//InImage//" => returning", >> WarningFile)
      print("stprepare: ERROR: Image-header keyword IHExpTime (="//IHExpTime//") not found in file "//InImage//" => returning", >> ErrorFile)
# --- clean up
      P_ParameterList = ""
      return
     }
    }
    imgets(InImage,IHRA)
    if (IHRA != ""){
     if (imgets.value == "0"){
      print("stprepare: ERROR: Image-header keyword IHRA (="//IHRA//") not found in file "//InImage//" => returning")
      print("stprepare: ERROR: Image-header keyword IHRA (="//IHRA//") not found in file "//InImage//" => returning", >> LogFile)
      print("stprepare: ERROR: Image-header keyword IHRA (="//IHRA//") not found in file "//InImage//" => returning", >> WarningFile)
      print("stprepare: ERROR: Image-header keyword IHRA (="//IHRA//") not found in file "//InImage//" => returning", >> ErrorFile)
# --- clean up
      P_ParameterList = ""
      return
     }
    }
    imgets(InImage,IHDec)
    if (IHDec != ""){
     if (imgets.value == "0"){
      print("stprepare: ERROR: Image-header keyword IHDec (="//IHDec//") not found in file "//InImage//" => returning")
      print("stprepare: ERROR: Image-header keyword IHDec (="//IHDec//") not found in file "//InImage//" => returning", >> LogFile)
      print("stprepare: ERROR: Image-header keyword IHDec (="//IHDec//") not found in file "//InImage//" => returning", >> WarningFile)
      print("stprepare: ERROR: Image-header keyword IHDec (="//IHDec//") not found in file "//InImage//" => returning", >> ErrorFile)
# --- clean up
      P_ParameterList = ""
      return
     }
    }
    imgets(InImage,IHEpoch)
    if (IHEpoch != ""){
     if (imgets.value == "0"){
      print("stprepare: ERROR: Image-header keyword IHEpoch (="//IHEpoch//") not found in file "//InImage//" => returning")
      print("stprepare: ERROR: Image-header keyword IHEpoch (="//IHEpoch//") not found in file "//InImage//" => returning", >> LogFile)
      print("stprepare: ERROR: Image-header keyword IHEpoch (="//IHEpoch//") not found in file "//InImage//" => returning", >> WarningFile)
      print("stprepare: ERROR: Image-header keyword IHEpoch (="//IHEpoch//") not found in file "//InImage//" => returning", >> ErrorFile)
# --- clean up
      P_ParameterList = ""
      return
     }
    }
  }
  astutil
  if (access(EditHeader))
    del(EditHeader, ver-)
  if (IHRA != "")
    print("RA_HMS", >> EditHeader)
  if (IHDec != "")
    print("DEC_DMS", >> EditHeader)
  if (IHRA != "")
    print("RA_HMS = \" \"", >> EditHeader)
  if (IHDec != "")
    print("DEC_DMS = \" \"", >> EditHeader)
  if (IHRA != "")
    print("RA_HMS = sexstr(@\'"//IHRA//"\'/15)", >> EditHeader)
  if (IHDec != "")
    print("DEC_DMS = sexstr(@\'"//IHDec//"\')", >> EditHeader)
  if (IHRA != "" || IHDec != ""){
    print("quit", >> EditHeader)
    asthedit(images = "@"//ObjectsList,
             commands = EditHeader,
             table = "",
             colnames = "",
             prompt = "asthedit> ",
             update+,
             ver-,
             oldstyle-)
  }
# --- setjd

  if (access(LogFile_setjd))
    del(LogFile_setjd, ver-)
  if (IHRA != "")
    RA_Str = "RA_HMS"
  else
    RA_Str = ""
  if (IHDec != "")
    Dec_Str = "RA_HMS"
  else
    Dec_Str = ""
  setjd(images="@"//ObjectsList,
        observatory=Observatory,
        date=IHDate,
        time=IHUTC,
        exposure=IHExpTime,
        ra=RA_Str,
        dec=Dec_Str,
        epoch=IHEpoch,
        jd=IHJD,
        hjd=IHHJD,
        ljd=IHLJD,
        utdate+,
        uttime+,
        listonly-, >> LogFile_setjd)
  if (!access(LogFile_setjd)){
    print("stprepare: ERROR: cannot access LogFile_setjd (="//LogFile_setjd//")")
    print("stprepare: ERROR: cannot access LogFile_setjd (="//LogFile_setjd//")", >> LogFile)
    print("stprepare: ERROR: cannot access LogFile_setjd (="//LogFile_setjd//")", >> WarningFile)
    print("stprepare: ERROR: cannot access LogFile_setjd (="//LogFile_setjd//")", >> ErrorFile)
# --- clean up
    P_ParameterList = ""
    return
  }
  cat(LogFile_setjd, >> LogFile)
  jobs()
  wait()
  cntlines(ObjectsList)
  NLinesList = cntlines.nlines
  cntlines(LogFile_setjd)
  NLinesSetJDLogFile = cntlines.nlines
  if (NLinesList + 3 != NLinesSetJDLogFile){
    print("stprepare: ERROR: Julian Date not set for all input objects =! returning")
    print("stprepare: ERROR: Julian Date not set for all input objects =! returning", >> LogFile)
    print("stprepare: ERROR: Julian Date not set for all input objects =! returning", >> WarningFile)
    print("stprepare: ERROR: Julian Date not set for all input objects =! returning", >> ErrorFile)
# --- clean up
    P_ParameterList = ""
    return
  }
  print("stprepare: Julian Date set for images in "//ObjectsList)
  if (LogLevel > 2)
    print("stprepare: Julian Date set for images in "//ObjectsList, >> LogFile)

  if (DoCalibs){
    if (!access(CalibsList)){
      print("stprepare: ERROR: cannot access CalibsList (="//CalibsList//")")
      print("stprepare: ERROR: cannot access CalibsList (="//CalibsList//")", >> LogFile)
      print("stprepare: ERROR: cannot access CalibsList (="//CalibsList//")", >> WarningFile)
      print("stprepare: ERROR: cannot access CalibsList (="//CalibsList//")", >> ErrorFile)
# --- clean up
      P_ParameterList = ""
      return
    }
    if (access(LogFile_setjd))
      del(LogFile_setjd, ver-)
    setjd(images="@"//CalibsList,
          observatory=Observatory,
          date=IHDate,
          time=IHUTC,
          exposur=IHExpTime,
          ra="",
          dec="",
          epoch=IHEpoch,
          jd=IHJD,
          hjd="",
          ljd=IHLJD,
          utdate+,
          uttime+,
          listonly-, >> LogFile_setjd)
    if (!access(LogFile_setjd)){
      print("stprepare: ERROR: cannot access LogFile_setjd (="//LogFile_setjd//")")
      print("stprepare: ERROR: cannot access LogFile_setjd (="//LogFile_setjd//")", >> LogFile)
      print("stprepare: ERROR: cannot access LogFile_setjd (="//LogFile_setjd//")", >> WarningFile)
      print("stprepare: ERROR: cannot access LogFile_setjd (="//LogFile_setjd//")", >> ErrorFile)
# --- clean up
      P_ParameterList = ""
      return
    }
    cat(LogFile_setjd, >> LogFile)
    jobs()
    wait()
    cntlines(CalibsList)
    NLinesList = cntlines.nlines
    cntlines(LogFile_setjd)
    NLinesSetJDLogFile = cntlines.nlines
    if (NLinesList + 3 != NLinesSetJDLogFile){
      print("stprepare: ERROR: Julian Date not set for all input calibs =! returning")
      print("stprepare: ERROR: Julian Date not set for all input calibs =! returning", >> LogFile)
      print("stprepare: ERROR: Julian Date not set for all input calibs =! returning", >> WarningFile)
      print("stprepare: ERROR: Julian Date not set for all input calibs =! returning", >> ErrorFile)
# --- clean up
      P_ParameterList = ""
      return
    }
    print("stprepare: Julian Date set for images in "//CalibsList)
    if (LogLevel > 2)
      print("stprepare: Julian Date set for images in "//CalibsList, >> LogFile)
  }
# --- hedit

  # --- objects
  print("stprepare: running hedit (objects)")
  print("stprepare: running hedit (objects)", >> LogFile)
  if (access(ObjectsList)){
    hedit(images = "@"//ObjectsList,
	  fields = "IMAGETYPE",
	  value = "object",
	  add+,
	  delete-,
	  ver-,
	  show+,
	  update+)
    print("stprepare: IMAGETYPE for images in "//ObjectsList//" set")
    if (LogLevel > 2)
      print("stprepare: IMAGETYPE for images in "//ObjectsList//" set", >> LogFile)
  }
  else{
    print("stprepare: ERROR: cannot access "// ObjectsList //"!")
    print("stprepare: ERROR: cannot access "// ObjectsList //"!", >> LogFile)
    print("stprepare: ERROR: cannot access "// ObjectsList //"!", >> ErrorFile)
    print("stprepare: ERROR: cannot access "// ObjectsList //"!", >> WarningFile)
  }

  # --- calibs
  if (DoCalibs){
    print("stprepare: running hedit (calibs)")
    print("stprepare: running hedit (calibs)", >> LogFile)
    if (access(CalibsList)){
      hedit(images = "@"//CalibsList,
            fields = "IMAGETYPE",
            value = "comp",
	    add+,
            addonly+,
	    delete-,
	    ver-,
	    show+,
	    update+)
      print("stprepare: IMAGETYPE for images in "//CalibsList//" set")
      if (LogLevel > 2)
        print("stprepare: IMAGETYPE for images in "//CalibsList//" set", >> LogFile)
    }
    else{
      print("stprepare: ERROR: cannot access "// CalibsList //"!")
      print("stprepare: ERROR: cannot access "// CalibsList //"!", >> LogFile)
      print("stprepare: ERROR: cannot access "// CalibsList //"!", >> ErrorFile)
      print("stprepare: ERROR: cannot access "// CalibsList //"!", >> WarningFile)
    }
  }
# --- clean up
  P_ParameterList = ""
end
