procedure stmergelist (Images,ErrImages,WeightFitsList)

##################################################################
#                                                                #
# NAME:             stmergelist.cl                               #
# PURPOSE:          * starts stmerge.cl for a the apropriate     #
#                     files of the input lists                   #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stmergelist(Images,ErrImages,WeightFitsList) #
# INPUTS:           Images: String                               #
#                     name of list containing names of           #
#                     lists of the individual spectral orders of #
#                     an image:                                  #
#                       "to_merge.list":                         #
#                         HD175640_botzfxsEcBltRb.fits           #
#                         ...                                    #
#                                                                #
#                   ErrImages: String                            #
#                     name of list containing names of           #
#                     lists of the individual orders of the      #
#                     error image:                               #
#                       "to_merge_err.list":                     #
#                         HD175640_err_botzfxsEcBltRb.fits       #
#                         ...                                    #
#                                                                #
#                   WeightFitsList: String                       #
#                     name of list containing names of           #
#                     lists of the individual spectral orders of #
#                     the blaze image:                           #
#                       "to_merge.list":                         #
#                         refBlaze_combinedFlat_EcBltRb.fits     #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     <Entry_in_Images_Root>M.<imtype>           #
#                   Log Files:                                   # 
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      20.08.2004                                   #
# LAST EDITED:      18.04.2007                                   #
#                                                                #
##################################################################

string Images         = "@fits.list"         {prompt="List of images to merge orders"}
string ErrImages      = "@fits_err.list"     {prompt="List of error images to merge orders"}
string WeightFitsList = "@weight_fits.list"  {prompt="List of weighting spectra"}
string ParameterFile  = "parameterfile.prop" {prompt="Name of ParameterFile"}
int    LogLevel       = 3                    {prompt="Level for writing LogFile [1-3]"}
string LogFile        = "logfile_stmergelist.log"  {prompt="Name of LogFile"}
string WarningFile    = "warnings_stmergelist.log" {prompt="Name of warning file"}
string ErrorFile      = "errors_stmergelist.log"   {prompt="Name of error file"}
string *P_FileList
string *P_ErrList
string *P_WeightList

begin
  string FileName,ErrName,WeightName
  string LogFile_stmerge     = "logfile_stmerge.log"
  string WarningFile_stmerge = "warnings_stmerge.log"
  string ErrorFile_stmerge   = "errors_stmerge.log"
  file   ObsFile,ErrFile

# --- delete old LogFiles
  if (access(LogFile))
    del(LogFile, ver-)
  if (access(WarningFile))
    del(WarningFile, ver-)
  if (access(ErrorFile))
    del(ErrorFile, ver-)

  ObsFile = mktemp ("tmp")
  ErrFile = mktemp ("tmp")

# --- Umwandeln der Liste von Frames in temporaeres File
  print("stmergelist: building lists from temp-files")
  if ( (substr(Images,1,1) == "@" && access(substr(Images,2,strlen(Images)))) || (substr(Images,1,1) != "@" && access(Images))){
    sections(Images, option="root", > ObsFile)
    P_FileList = ObsFile
  }
  else{
    if (substr(Images,1,1) != "@"){
      print("stmergelist: ERROR: "//Images//" not found!!!")
      print("stmergelist: ERROR: "//Images//" not found!!!", >> LogFile)
      print("stmergelist: ERROR: "//Images//" not found!!!", >> WarningFile)
      print("stmergelist: ERROR: "//Images//" not found!!!", >> ErrorFile)
    }
    else{
      print("stmergelist: ERROR: "//substr(Images,2,strlen(Images))//" not found!!!")
      print("stmergelist: ERROR: "//substr(Images,2,strlen(Images))//" not found!!!", >> LogFile)
      print("stmergelist: ERROR: "//substr(Images,2,strlen(Images))//" not found!!!", >> WarningFile)
      print("stmergelist: ERROR: "//substr(Images,2,strlen(Images))//" not found!!!", >> ErrorFile)
    }
# --- Aufraeumen
    delete (ObsFile, ver-, >& "dev$null")
    delete (ErrFile, ver-, >& "dev$null")
    P_FileList = ""
    P_ErrList = ""
    return
  }

# --- weight images
  if ( (substr(WeightFitsList,1,1) == "@" && !access(substr(WeightFitsList,2,strlen(WeightFitsList)))) || (substr(WeightFitsList,1,1) != "@" && !access(WeightFitsList))){
    if (substr(WeightFitsList,1,1) != "@"){
      print("stmergelist: ERROR: "//WeightFitsList//" not found!!!")
      print("stmergelist: ERROR: "//WeightFitsList//" not found!!!", >> LogFile)
      print("stmergelist: ERROR: "//WeightFitsList//" not found!!!", >> WarningFile)
      print("stmergelist: ERROR: "//WeightFitsList//" not found!!!", >> ErrorFile)
    }
    else{
      print("stmergelist: ERROR: "//substr(WeightFitsList,2,strlen(WeightFitsList))//" not found!!!")
      print("stmergelist: ERROR: "//substr(WeightFitsList,2,strlen(WeightFitsList))//" not found!!!", >> LogFile)
      print("stmergelist: ERROR: "//substr(WeightFitsList,2,strlen(WeightFitsList))//" not found!!!", >> WarningFile)
      print("stmergelist: ERROR: "//substr(WeightFitsList,2,strlen(WeightFitsList))//" not found!!!", >> ErrorFile)
    }
# --- Aufraeumen
    delete (ObsFile, ver-, >& "dev$null")
    delete (ErrFile, ver-, >& "dev$null")
    P_FileList = ""
    P_ErrList = ""
    return
  }

# --- ErrImages
  if ( (substr(ErrImages,1,1) == "@" && access(substr(ErrImages,2,strlen(ErrImages)))) || (substr(ErrImages,1,1) != "@" && access(ErrImages))){
    sections(ErrImages, option="root", > ErrFile)
    P_ErrList = ErrFile
  }
  else{
    if (substr(ErrImages,1,1) != "@"){
      print("stmergelist: ERROR: "//ErrImages//" not found!!!")
      print("stmergelist: ERROR: "//ErrImages//" not found!!!", >> LogFile)
      print("stmergelist: ERROR: "//ErrImages//" not found!!!", >> WarningFile)
      print("stmergelist: ERROR: "//ErrImages//" not found!!!", >> ErrorFile)
    }
    else{
      print("stmergelist: ERROR: "//substr(ErrImages,2,strlen(ErrImages))//" not found!!!")
      print("stmergelist: ERROR: "//substr(ErrImages,2,strlen(ErrImages))//" not found!!!", >> LogFile)
      print("stmergelist: ERROR: "//substr(ErrImages,2,strlen(ErrImages))//" not found!!!", >> WarningFile)
      print("stmergelist: ERROR: "//substr(ErrImages,2,strlen(ErrImages))//" not found!!!", >> ErrorFile)
    }
# --- Aufraeumen
    delete (ObsFile, ver-, >& "dev$null")
    delete (ErrFile, ver-, >& "dev$null")
    P_FileList = ""
    P_ErrList = ""
    return
  }

  while (fscan (P_FileList, FileName) != EOF){
    if (!access(FileName)){
      print("stmergelist: ERROR: cannot access "//FileName)
      print("stmergelist: ERROR: cannot access "//FileName, >> LogFile)
      print("stmergelist: ERROR: cannot access "//FileName, >> WarningFile)
      print("stmergelist: ERROR: cannot access "//FileName, >> ErrorFile)
# --- clean up
      delete (ObsFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      P_FileList = ""
      P_ErrList = ""
      return
    }
    if (fscan(P_ErrList, ErrName) == EOF){
      print("stmergelist: ERROR: fscan(ErrImages) returned EOF!")
      print("stmergelist: ERROR: fscan(ErrImages) returned EOF!", >> LogFile)
      print("stmergelist: ERROR: fscan(ErrImages) returned EOF!", >> WarningFile)
      print("stmergelist: ERROR: fscan(ErrImages) returned EOF!", >> ErrorFile)
# --- clean up
      delete (ObsFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      P_FileList = ""
      P_ErrList = ""
      return
    }
    if (!access(ErrName)){
      print("stmergelist: ERROR: cannot access "//ErrName)
      print("stmergelist: ERROR: cannot access "//ErrName, >> LogFile)
      print("stmergelist: ERROR: cannot access "//ErrName, >> WarningFile)
      print("stmergelist: ERROR: cannot access "//ErrName, >> ErrorFile)
# --- clean up
      delete (ObsFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      P_FileList = ""
      P_ErrList = ""
      return
    }
    flpr
    print("stmergelist: starting stmerge("//FileName//", "//ErrName//", "//WeightFitsList//")")
    print("stmergelist: starting stmerge("//FileName//", "//ErrName//", "//WeightFitsList//")", >> LogFile)
    stmerge(ApsImFitsList     = FileName,
            ApsErrFitsList    = ErrName,
            ApsWeightFitsList = WeightFitsList,
            ParameterFile     = ParameterFile,
            LogLevel          = LogLevel,
            LogFile           = LogFile_stmerge,
            WarningFile       = WarningFile_stmerge,
            ErrorFile         = ErrorFile_stmerge,
            Output            = "")
    if (access(LogFile_stmerge))
      cat(LogFile_stmerge, >> LogFile)
    if (access(WarningFile_stmerge))
      cat(WarningFile_stmerge, >> WarningFile)
    if (access(ErrorFile_stmerge)){
      cat(ErrorFile_stmerge, >> ErrorFile)
      print("stmergelist: ERROR: "//ErrorFile_stmerge//" found! => Returning")
      print("stmergelist: ERROR: "//ErrorFile_stmerge//" found! => Returning", >> LogFile)
      print("stmergelist: ERROR: "//ErrorFile_stmerge//" found! => Returning", >> WarningFile)
      print("stmergelist: ERROR: "//ErrorFile_stmerge//" found! => Returning", >> ErrorFile)
# --- clean up
      delete (ObsFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      P_FileList = ""
      P_ErrList = ""
      return
    }
  }

# --- clean up
  delete (ObsFile, ver-, >& "dev$null")
  delete (ErrFile, ver-, >& "dev$null")
  P_FileList = ""
  P_ErrList = ""

end
