procedure stblaze (Images,RefBlaze)

##################################################################
#                                                                #
# NAME:             stblaze.cl                                   #
# PURPOSE:          * removes Blaze functions from extracted     #
#                     spectra                                    #
#                                                                #
# CATEGORY:                                                      #
# CALLING SEQUENCE: stblaze,<string Images>,<string RefBlaze>    #
# INPUTS:           input file: 'objects_botzfxsEc.list':        #
#                    HD175640_botzfxsEc.fits                     #
#                          ...                                   #
#                                                                #
#                   input file: 'refBlaze.fits'                  #
# OUTPUTS:          outfile:                                     #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED:          20.01.2004                                   #
# LAST EDITED:      27.11.2006                                   #
#                                                                #
################################################################## 

string Images             = "@toblaze.list"      {prompt="List of input images"}
string RefBlaze           = "refBlaze.fits"      {prompt="Reference Blaze File"}
string ErrorImages        = "@toblaze_e.list"    {prompt="List of error images"}
bool   RunTask            = YES                  {prompt="Run task?"}
string ParameterFile      = "parameterfile.prop" {prompt="Name of ParameterFile"}
string ImType             = "fits"               {prompt="Image Type"}
bool   DoErrors           = YES                  {prompt="Calculate error propagation? (YES | NO)"}
int    LogLevel           = 3                    {prompt="Level for writing LogFile"}
string LogFile            = "logfile_stblaze.log"  {prompt="Name of log file"}
string WarningFile        = "warnings_stblaze.log" {prompt="Name of warning file"}
string ErrorFile          = "errors_stblaze.log"   {prompt="Name of error file"}
string *ImageList
string *ErrorList
string *ParameterList
string *TimeList

begin
  int    i,Pos#,OrderNum
  file   InFile,ErrFile
  string ApNoStr = ""
  string HeaderText = ""
  string TimeFile = "time.txt"
  string TempDate,TempDay,TempTime,In,Out,ErrIn,ErrOut,Parameter,Parametervalue
  string combinedFlat_n,combinedFlat_n_ec,tempfits
  string RefBlazeList="refBlaze.list"
  string ListName
  bool   found_RunTask                = NO
  bool   found_imtype                 = NO

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
  print ("*            assigning reference Blaze file              *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("stblaze: Images = <"//Images//">")
  print ("stblaze: ErrorImages = <"//ErrorImages//">")
  print ("stblaze: RefBlaze = <"//RefBlaze//">")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*            assigning reference Blaze file              *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)
  print ("stblaze: Images = <"//Images//">", >> LogFile)
  print ("stblaze: ErrorImages = <"//ErrorImages//">", >> LogFile)
  print ("stblaze: RefBlaze = <"//RefBlaze//">", >> LogFile)

# --- read ParameterFile
  if (access(ParameterFile)){

    ParameterList = ParameterFile

    print ("stblaze: **************** reading ParameterFile *******************")
    if (LogLevel > 2)
      print ("stblaze: **************** reading ParameterFile *******************", >> LogFile)

    while (fscan (ParameterList, Parameter, Parametervalue) != EOF){

      if (Parameter == "blaze_run_task"){
        if (Parametervalue == "YES" || Parametervalue == "yes"){
          RunTask = YES
          print ("stblaze: Setting RunTask to YES")
          if (LogLevel > 2)
            print ("stblaze: Setting RunTask to YES", >> LogFile)
	}
	else{
	  RunTask = NO
          print ("stblaze: Setting RunTask to NO")
          if (LogLevel > 2)
            print ("stblaze: Setting RunTask to NO", >> LogFile)
	}
        found_RunTask = YES
      }
      else if (Parameter == "imtype"){ 
        ImType = Parametervalue
        print ("stblaze: Setting ImType to "//Parametervalue)
        if (LogLevel > 2)
          print ("stblaze: Setting ImType to "//Parametervalue, >> LogFile)
        found_imtype = YES
      }
    } #end while(fscan(ParameterList) != EOF)
    if (!found_RunTask){
      print("stblaze: WARNING: Parameter blaze_run_task not found in ParameterFile!!! -> using standard")
      print("stblaze: WARNING: Parameter blaze_run_task not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stblaze: WARNING: Parameter blaze_run_task not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
    if (!found_imtype){
      print("stblaze: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard")
      print("stblaze: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> LogFile)
      print("stblaze: WARNING: Parameter imtype not found in ParameterFile!!! -> using standard", >> WarningFile)
    }
  }
  else{
    print("stblaze: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard Parameters")
    print("stblaze: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard Parameters", >> LogFile)
    print("stblaze: WARNING: ParameterFile <"//ParameterFile//"> not found!!! -> using standard Parameters", >> WarningFile)
  }

# --- create tempfiles
  if (DoErrors){
    if (substr(ErrorImages,1,1) == "@"){
      ListName = substr(ErrorImages, 2, strlen(ErrorImages))
    }
    else
      ListName = ErrorImages
    if ( !access(ListName) ){
      print("stblaze: ERROR: ErrorImages <"//ListName//"> not found! => Returning")
      print("stblaze: ERROR: ErrorImages <"//ListName//"> not found! => Returning", >> LogFile)
      print("stblaze: ERROR: ErrorImages <"//ListName//"> not found! => Returning", >> ErrorFile)
      print("stblaze: ERROR: ErrorImages <"//ListName//"> not found! => Returning", >> WarningFile)
# --- clean up
      ImageList = ""
      ErrorList = ""
      ParameterList = ""
      TimeList = ""
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      return
    }
    ErrFile = mktemp ("tmp")
    sections(ErrorImages, option="root", > ErrFile)
    ErrorList = ErrFile
  }#end if (DoErrors)
# --- assign reference spectra
  if (substr(Images,1,1) == "@"){
    ListName = substr(Images,2,strlen(Images))
  }
  else
    ListName = Images
  if (!access(ListName)){
    print("stblaze: ERROR: Images <"//ListName//" not found! => Returning")
    print("stblaze: ERROR: Images <"//ListName//" not found! => Returning", >> LogFile)
    print("stblaze: ERROR: Images <"//ListName//" not found! => Returning", >> ErrorFile)
    print("stblaze: ERROR: Images <"//ListName//" not found! => Returning", >> WarningFile)
# --- clean up
    ImageList = ""
    ErrorList = ""
    ParameterList = ""
    TimeList = ""
    delete (InFile, ver-, >& "dev$null")
    delete (ErrFile, ver-, >& "dev$null")
    return
  }
  InFile = mktemp ("tmp")
  sections(Images, option="root", > InFile)
  ImageList = InFile

  while (fscan (ImageList, In) != EOF){

    print("stblaze: processing "//In)
    if (LogLevel > 2)
      print("stblaze: processing "//In, >> LogFile)

    if (!access(In)){
      print("stblaze: ERROR: In <"//In//"> not found! => Returning")
      print("stblaze: ERROR: In <"//In//"> not found! => Returning", >> LogFile)
      print("stblaze: ERROR: In <"//In//"> not found! => Returning", >> WarningFile)
      print("stblaze: ERROR: In <"//In//"> not found! => Returning", >> ErrorFile)
# --- clean up
      ImageList = ""
      ErrorList = ""
      ParameterList = ""
      TimeList = ""
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      return
    }

    strlastpos(In,".")
    Pos = strlastpos.pos
    if (Pos == 0)
      Pos = strlen(In) + 1
    Out = substr(In, 1, Pos-1)//"Bl"//substr(In,Pos,strlen(In))
        
# --- delete old OutFile
    if (access(Out)){
      imdel(Out, ver-)
      if (access(Out))
        del(Out,ver-)
      if (!access(Out)){
        print("stblaze: old "//Out//" deleted")
        if (LogLevel > 2)
          print("stblaze: old "//Out//" deleted", >> LogFile)
      }
      else{
        print("stblaze: ERROR: cannot delete old "//Out)
        print("stblaze: ERROR: cannot delete old "//Out, >> LogFile)
        print("stblaze: ERROR: cannot delete old "//Out, >> WarningFile)
        print("stblaze: ERROR: cannot delete old "//Out, >> ErrorFile)
# --- clean up
        ImageList = ""
        ErrorList = ""
        ParameterList = ""
        TimeList = ""
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        return
      }
    }# end if (access(Out))
    if (!access(In)){
      print("stblaze: ERROR: cannot access "//In)
      print("stblaze: ERROR: cannot access "//In, >> LogFile)
      print("stblaze: ERROR: cannot access "//In, >> ErrorFile)
      print("stblaze: ERROR: cannot access "//In, >> WarningFile)
# --- clean up
      ImageList = ""
      ErrorList = ""
      ParameterList = ""
      TimeList = ""
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      return
    }
    if (!RunTask){
      imcopy(input=In,
             output=Out,
             ver-)
    }
    else{
      if (!access(RefBlaze)){
        print("stblaze: ERROR: cannot access "//RefBlaze)
        print("stblaze: ERROR: cannot access "//RefBlaze, >> LogFile)
        print("stblaze: ERROR: cannot access "//RefBlaze, >> ErrorFile)
        print("stblaze: ERROR: cannot access "//RefBlaze, >> WarningFile)
# --- clean up
        ImageList = ""
        ErrorList = ""
        ParameterList = ""
        TimeList = ""
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        return
      }
      imreplace(images    = RefBlaze,
                value     = 0.,
                imaginary = 0.,
                lower     = INDEF,
                upper     = 0.,
                radius    = 0.)
#      fitsnozero(RefBlaze)
      imdivide(numerator=In,
               denominator=RefBlaze,
               resultant=Out,
               title="*",
               constant=0.,
               rescale="norescale",
               mean="1",
               ver-)
    }
    if (!access(Out)){
      print("stblaze: ERROR: cannot access OutFile "//Out)
      print("stblaze: ERROR: cannot access OutFile "//Out, >> LogFile)
      print("stblaze: ERROR: cannot access OutFile "//Out, >> ErrorFile)
      print("stblaze: ERROR: cannot access OutFile "//Out, >> WarningFile)
# --- clean up
      ImageList = ""
      ErrorList = ""
      ParameterList = ""
      TimeList = ""
      delete (InFile, ver-, >& "dev$null")
      delete (ErrFile, ver-, >& "dev$null")
      return
    }
    if (!RunTask){
      HeaderText = "NO Blaze function assigned"
    }
    else{
      HeaderText = "reference Blaze-function file "//RefBlaze//" assigned"
      if (access(TimeFile))
        del(TimeFile, ver-)
      time(>> TimeFile)
      if (access(TimeFile)){
        TimeList = TimeFile
        if (fscan(TimeList,TempDay,TempTime,TempDate) != EOF){
          HeaderText = HeaderText//" "//TempDate//"T"//TempTime
        }
      }
      else{
        print("stblaze: WARNING: TimeFile <"//TimeFile//"> not accessable!")
        print("stblaze: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
        print("stblaze: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
      }
    }
    hedit(images=Out,
          fields="STBLAZE",
          value=HeaderText,
          add+,
          addonly+,
          del-,
          ver-,
          show+,
          update+)
    print("stblaze: OutFile <"//Out//"> ready")
    print("stblaze: OutFile <"//Out//"> ready", >> LogFile)
    if (DoErrors){
      if (fscan(ErrorList,ErrIn) == EOF){
        print("stblaze: ERROR: End of ErrorImages <"//ErrorImages//"> reached => Returning!")
        print("stblaze: ERROR: End of ErrorImages <"//ErrorImages//"> reached => Returning!", >> LogFile)
        print("stblaze: ERROR: End of ErrorImages <"//ErrorImages//"> reached => Returning!", >> WarningFile)
        print("stblaze: ERROR: End of ErrorImages <"//ErrorImages//"> reached => Returning!", >> ErrorFile)
# --- clean up
        ImageList = ""
        ErrorList = ""
        ParameterList = ""
        TimeList = ""
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        return
      }
      strlastpos(ErrIn,".")
      Pos = strlastpos.pos
      if (Pos == 0)
        Pos = strlen(ErrIn) + 1
      ErrOut = substr(ErrIn, 1, Pos-1)//"Bl"//substr(ErrIn, Pos, strlen(ErrIn))
    
# --- delete old ErrOutFile
      if (access(ErrOut)){
        imdel(ErrOut, ver-)
        if (access(ErrOut))
          del(ErrOut,ver-)
        if (!access(ErrOut)){
          print("stblaze: old "//ErrOut//" deleted")
          if (LogLevel > 2)
            print("stblaze: old "//ErrOut//" deleted", >> LogFile)
        }
        else{
          print("stblaze: ERROR: cannot delete old "//ErrOut)
          print("stblaze: ERROR: cannot delete old "//ErrOut, >> LogFile)
          print("stblaze: ERROR: cannot delete old "//ErrOut, >> WarningFile)
          print("stblaze: ERROR: cannot delete old "//ErrOut, >> ErrorFile)
# --- clean up
          ImageList = ""
          ErrorList = ""
          ParameterList = ""
          TimeList = ""
          delete (InFile, ver-, >& "dev$null")
          delete (ErrFile, ver-, >& "dev$null")
          return
        }
      }# end if (access(ErrOut))
      if (!access(ErrIn)){
        print("stblaze: ERROR: cannot access ErrIn "//ErrIn)
        print("stblaze: ERROR: cannot access ErrIn "//ErrIn, >> LogFile)
        print("stblaze: ERROR: cannot access ErrIn "//ErrIn, >> ErrorFile)
        print("stblaze: ERROR: cannot access ErrIn "//ErrIn, >> WarningFile)
# --- clean up
        ImageList = ""
        ErrorList = ""
        ParameterList = ""
        TimeList = ""
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        return
      }
      if (!RunTask){
        imcopy(input=ErrIn,
               output=ErrOut,
               ver-)
      }
      else{
# --- In becomes divided by RefBlaze
# --- ErrOut = ErrIn/RefBlaze
        imdivide(numerator=ErrIn,
                 denominator=RefBlaze,
                 resultant=ErrOut,
                 title="*",
                 constant=0.,
                 rescale="norescale",
                 mean="1",
                 ver-)
      }
      if (!access(ErrOut)){
        print("stblaze: ERROR: cannot access ErrOutFile "//ErrOut)
        print("stblaze: ERROR: cannot access ErrOutFile "//ErrOut, >> LogFile)
        print("stblaze: ERROR: cannot access ErrOutFile "//ErrOut, >> ErrorFile)
        print("stblaze: ERROR: cannot access ErrOutFile "//ErrOut, >> WarningFile)
# --- clean up
        ImageList = ""
        ErrorList = ""
        ParameterList = ""
        TimeList = ""
        delete (InFile, ver-, >& "dev$null")
        delete (ErrFile, ver-, >& "dev$null")
        return
      }
      if (RunTask){
        HeaderText = "reference Blaze-function file "//RefBlaze//" assigned"
        if (access(TimeFile))
          del(TimeFile, ver-)
        time(>> TimeFile)
        if (access(TimeFile)){
          TimeList = TimeFile
          if (fscan(TimeList,TempDay,TempTime,TempDate) != EOF){
            HeaderText = HeaderText//" "//TempDate//"T"//TempTime
          }
        }
        else{
          print("stblaze: WARNING: TimeFile <"//TimeFile//"> not accessable!")
          print("stblaze: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
          print("stblaze: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
        }
      }
      hedit(images=ErrOut,
            fields="STBLAZE",
            value=HeaderText,
            add+,
            addonly+,
            del-,
            ver-,
            show+,
            update+)
      print("stblaze: ErrOutFile <"//ErrOut//"> ready")
      print("stblaze: ErrOutFile <"//ErrOut//"> ready", >> LogFile)
    }# end if (DoErrors)

  }# end while(fscan(ImageList, In) != EOF)

  if (access(TimeFile))
    del(TimeFile, ver-)
  time(>> TimeFile)
  if (access(TimeFile)){
    TimeList = TimeFile
    if (fscan(TimeList,TempDay,TempTime,TempDate) != EOF){
      print("stblaze: stblaze finished "//TempDate//"T"//TempTime, >> LogFile)
    }
  }
  else{
    print("stblaze: WARNING: TimeFile <"//TimeFile//"> not accessable!")
    print("stblaze: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> LogFile)
    print("stblaze: WARNING: TimeFile <"//TimeFile//"> not accessable!", >> WarningFile)
  }

# --- clean up
  ImageList = ""
  ErrorList = ""
  ParameterList = ""
  TimeList = ""
  delete (InFile, ver-, >& "dev$null")
  delete (ErrFile, ver-, >& "dev$null")
end
