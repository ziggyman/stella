procedure writeaps(Input,DispAxis)

##################################################################
#                                                                #
# NAME:             writeaps                                     #
# PURPOSE:          * writes the individual apertures of the     #
#                     input images to individual files           #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: writeaps(Input,DispAxis)                     #
# INPUTS:           Input: String                                #
#                     either: name of single image:              #
#                               "HD175640.fits"                  #
#                     or: name of list containing names of       #
#                         images to write the individual orders: #
#                           "objects.list":                      #
#                             HD175640.fits                      #
#                             ...                                #
#                                                                #
#                   DispAxis: Enum(1,2)                          #
#                                  1... horizontal               #
#                                  2... vertical                 #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     if <CreateDirs> == YES:                    #
#                       substr(<Entry_of_Input>,1,               #
#                              strpos(<Delimiter>))/<Entry_of_   #
#                              Input_Root>_<apertureNo>.fits     #
#                                   ...                          #
#                     if <CreateDirs> == NO:                     #
#                       <Entry_of_Input_Root>_<apertureNo>.fits  #
#                       (<Entry_of_Input_Root>_<apertureNo>.text)#
#                       (<Entry_of_Input_Root>_<apertureNo>_head #
#                                                          .text)#
#                                   ...                          #
#                   Log Files:                                   #
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                   Lists of output files:                       #
#                     <FitsOutList>,<TextOutList>,<HeadOutList>  #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      12.11.2001                                   #
# LAST EDITED:      06.04.2007                                   #
#                                                                #
##################################################################

string Input       = "file.fits"                {prompt="List of input spectra"}
int    DispAxis    = 2                          {prompt="1-horizontal, 2-vertical"}
string Delimiter   = "_"                        {prompt="1st char not belonging to object names"}
string ImType      = "fits"                     {prompt="Image Type"}
bool   WriteFits   = YES                        {prompt="Write apertures as fits files?"}
bool   WSpecText   = YES                        {prompt="Write apertures as ASCI files?"}
bool   WriteHeads  = YES                        {prompt="Write image headers to ASCI files, too?"}
bool   WriteLists  = YES                        {prompt="Write file lists?"}
bool   CreateDirs  = YES                        {prompt="Create directories for every image?"}
int    LogLevel    = 3                          {prompt="Level for writing log file"}
string LogFile     = "logfile_writeaps.log"     {prompt="Name of log file"}
string WarningFile = "warningfile_writeaps.log" {prompt="Name of warning file"}
string ErrorFile   = "errorfile_writeaps.log"   {prompt="Name of error file"}
string FitsOutList
string TextOutList
string HeadOutList
string *P_InputList

begin

  file   InFile
  string In,Out,WOut,DirName,HeaderOut,ListName,TextOutListsList,FitsOutListsList
  int    i,Len,Aperture,NAps,Pos
  bool   InputIsList = NO

  if (access(LogFile))
    del(LogFile, ver-)
  if (access(WarningFile))
    del(WarningFile, ver-)
  if (access(ErrorFile))
    del(ErrorFile, ver-)

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*          writing orders to seperate files              *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("writeaps: Input = <"//Input//">")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*          writing orders to seperate files              *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)
  print ("writeaps: Input = <"//Input//">", >> LogFile)

# --- load onedspec package
   onedspec

# --- Erzeugen von temporaeren Filenamen
  print("writeaps: building temp-filenames")
  InFile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("writeaps: building lists from temp-files")

  if (substr(Input,1,1) == "@"){
    InputIsList = YES
    ListName = substr(Input,2,strlen(Input))
  }
  else{
    InputIsList = NO
    ListName = Input
  }
  if (!access(ListName)){
    print("writeaps: ERROR: Input <"//ListName//"> not found!!! => Returning")
    print("writeaps: ERROR: Input <"//ListName//"> not found!!! => Returning", >> LogFile)
    print("writeaps: ERROR: Input <"//ListName//"> not found!!! => Returning", >> WarningFile)
    print("writeaps: ERROR: Input <"//ListName//"> not found!!! => Returning", >> ErrorFile)
# --- clean up
    P_InputList     = ""
    delete (InFile, ver-, >& "dev$null")
    return
  }
  sections(Input, option="root", > InFile)
  P_InputList = InFile

  strlastpos(ListName,".")
  Pos = strlastpos.pos
  if (Pos == 0)
    Pos = strlen(ListName)+1
  HeadOutList = substr(ListName,1,strlastpos.pos-1)//"_heads.list"
  if (access(HeadOutList))
    del(HeadOutList, ver-)
  print("writeaps: HeadOutList = <"//HeadOutList//">")
  if (LogLevel > 2){
    print("writeaps: HeadOutList = <"//HeadOutList//">", >> LogFile)
  }
  if (InputIsList){
    TextOutListsList = substr(ListName,1,strlastpos.pos-1)//"_text_lists.list"
    if (access(TextOutListsList))
      del(TextOutListsList, ver-)
    FitsOutListsList = substr(ListName,1,strlastpos.pos-1)//"_fits_lists.list"
    if (access(FitsOutListsList))
      del(FitsOutListsList, ver-)
    print("writeaps: TextOutListsList = <"//TextOutListsList//">")
    print("writeaps: FitsOutListsList = <"//FitsOutListsList//">")
    if (LogLevel > 2){
      print("writeaps: TextOutListsList = <"//TextOutListsList//">", >> LogFile)
      print("writeaps: FitsOutListsList = <"//FitsOutListsList//">", >> LogFile)
    }
  }

# --- build output filenames and correct dispersions
  print("writeaps: ******************* processing files *********************")
  print("writeaps: ******************* processing files *********************", >> LogFile)

  while (fscan (P_InputList, In) != EOF){

    print("writeaps: In = "//In)
    print("writeaps: In = "//In, >> LogFile)

    if (!access(In)){
      print("writeaps: ERROR: cannot access "//In//" => returning")
      print("writeaps: ERROR: cannot access "//In//" => returning", >> Logfile)
      print("writeaps: ERROR: cannot access "//In//" => returning", >> WarningFile)
      print("writeaps: ERROR: cannot access "//In//" => returning", >> ErrorFile)
# --- clean up
      P_InputList     = ""
      delete (InFile, ver-, >& "dev$null")
      return
    }

    Len = strlen(In)

# --- write output lists
    if (WriteLists){
      strlastpos(In,".")
      Pos = strlastpos.pos
      if (Pos == 0)
        Pos = strlen(In)+1
      FitsOutList = substr(In,1,strlastpos.pos-1)//"_fits.list"
      TextOutList = substr(In,1,strlastpos.pos-1)//"_text.list"
      if (access(FitsOutList))
        del(FitsOutList, ver-)
      if (access(TextOutList))
        del(TextOutList, ver-)
      print("writeaps: TextOutList = <"//TextOutList//">")
      print("writeaps: FitsOutList = <"//FitsOutList//">")
      if (LogLevel > 2){
        print("writeaps: TextOutList = <"//TextOutList//">", >> LogFile)
        print("writeaps: FitsOutList = <"//FitsOutList//">", >> LogFile)
      }
      if (InputIsList){
        print(TextOutList, >> TextOutListsList)
        print(FitsOutList, >> FitsOutListsList)
      }
    }

    DirName = ""
    if (CreateDirs){
      strpos(In,Delimiter)
      Pos = strpos.pos
      if (Pos == 0)
        Pos = strlen(In)+1
# --- CHANGED TO SHORTEN LINES
      Pos = 3
      DirName=substr(In,1,Pos-1)//"/"
      if (!access(DirName))
        mkdir(DirName)
      if (substr(In,Len-strlen(ImType)-3,Len-strlen(ImType)-1) == "snr"){
        DirName=DirName//"snr/"
        if (!access(DirName))
          mkdir(DirName)
      }
      else if (substr(In,Len-strlen(ImType)-2,Len-strlen(ImType)-1) == "ec"){
        DirName=DirName//"ec/"
        if (!access(DirName))
          mkdir(DirName)
      }
      if (access(DirName//In))
        del(DirName//In, ver-)
      imcopy(In,DirName//In,ver-)
    }
# --- count orders
    countorders(image=In,
                dispaxis=DispAxis)
    NAps = countorders.norders
    strlastpos(In,"."//ImType)
    Pos = strlastpos.pos
    if (Pos == 0){
      strlastpos(In, ".")
      Pos = strlastpos.pos
    }
    if (Pos == 0)
      Pos = Len + 1
    if (WriteHeads){
      HeaderOut = substr(In, 1, Pos-1)//"_head.text"
      print("writeaps: Appending HeaderOut = <"//HeaderOut//"> to HeadOutList <"//HeadOutList//">")
      if (LogLevel > 2)
        print("writeaps: Appending HeaderOut = <"//HeaderOut//"> to HeadOutList <"//HeadOutList//">", >> LogFile)
      if (access(HeaderOut))
        del(HeaderOut, ver-)
      print(HeaderOut, >> HeadOutList)
      print("writeaps: starting imhead(In=<"//In//">")
      if (LogLevel > 2)
        print("writeaps: starting imhead(In=<"//In//">", >> LogFile)

      unlearn("imheader")

      imheader(In,imlist="*."//ImType,longheader+,userfields+, >> HeaderOut)
      print("writeaps: imhead ready")
      if (LogLevel > 2)
        print("writeaps: imhead ready", >> LogFile)
    }
    for (Aperture=1;Aperture<=NAps;Aperture=Aperture+1){
      Out = DirName//substr(In, 1, Pos-1)
      if (NAps > 1){
        Out = Out//"_"
        if (NAps > 99){
          if (Aperture < 100)
            Out = Out//"0"
        }
        if (Aperture < 10)
          Out = Out//"0"
        Out = Out//Aperture
      }
      WOut = Out
      if (NAps == 1)
        Out = Out//"_temp"
      if (substr (In, Len-strlen(ImType), Len) == "."//ImType){
        Out = Out//"."//ImType
        WOut = WOut//".text"
      }
#      jobs
#      wait()
# --- write output lists
      print("writeaps: fits outfile = "//Out//", text outfile = "//WOut)
      if (LogLevel > 2)
        print("writeaps: fits outfile = "//Out//", text outfile = "//WOut, >> LogFile)
      if (WriteLists){
        print(Out, >> FitsOutList)
        print(WOut, >> TextOutList)
#        jobs
#        wait()
        if (!access(FitsOutList))
          print("writeaps: ERROR: FitsOutList(="//FitsOutList//") not accessable!!!")
        if (!access(TextOutList))
          print("writeaps: ERROR: TextOutList(="//TextOutList//") not accessable!!!")
      }
#      jobs
#      wait()

      if (access(Out)){
        del(Out,ver-)
        print("writeaps: old "//Out//" deleted")
      }
      if (access(WOut)){
        del(WOut,ver-)
        print("writeaps: old "//WOut//" deleted")
      }

      if (DispAxis == 2)
        imcopy(input=In//"[*,"//Aperture//"]",
               output=Out)
      else
        imcopy(input=In//"["//Aperture//",*]",
               output=Out)

      if(WSpecText)
        wspectext(input   = Out,
                  output  = WOut,
                  header-,
                  wformat = "")

      print("writeaps: ----------- "//Out//" ready ------------")
      if ((NAps == 1) || !WriteFits)
        del(Out, ver-)
    } # end of for...
  } # end of while(scan(P_InputList))
  if (InputIsList){
    TextOutList = TextOutListsList
    FitsOutList = FitsOutListsList
  }
# --- clean up
  P_InputList     = ""
  delete (InFile, ver-, >& "dev$null")

end
