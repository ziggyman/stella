procedure staddheader(Images,Headers)

##################################################################
#                                                                #
# NAME:             staddheader.cl                               #
# PURPOSE:          * adds fits Headers in <Headers> to Images   #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: staddheader,<Images: String(Fits file)>,     #
#                               <Headers: String(Text file)>     #
# INPUTS:           input file: 'image.fits':                    #
#                     ordinary fits file                         #
#                   input file: 'header.text':                   #
#                    ORIGIN  = 'NOAO-IRAF FITS Kernel July 2003'/#
#                                           FITS file originator #
#                    IRAF-TLM= '10:22:41 (16/12/2006)' / Time of #
#                                              last modification #
#                          ...                                   #
#                                                                #
# OUTPUTS:          outfile: = <Images>                          #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED:          14.04.2003                                   #
# LAST EDITED:      24.04.2006                                   #
#                                                                #
##################################################################

string Images      = "@staddheader.list"        {prompt="List of images to change names"}
string Headers     = "@staddheader.list"        {prompt="List of images to change names"}
int    LogLevel    = 3                          {prompt="Level for writing logfiles"}
string LogFile     = "logfile_staddheader.log"  {prompt="Name of log file"}
string WarningFile = "warnings_staddheader.log" {prompt="Name of warning file"}
string ErrorFile   = "errors_staddheader.log"   {prompt="Name of error file"}
string *P_ImagesList
string *P_HeadersList
string *P_HeaderList

begin

  file   InFile,HeadsInFile,HeaderFile
  string In, ListName, Line, HeaderKeyWord, HeaderValue, HeaderLine
  string stra,strb,strc,strd,stre,strf,strg,strh,stri,strj,strk
  int    i, j, Pos
  int    NKeyWordsSet = 0
  bool   SlashFound = NO

  HeaderKeyWord = ""

# --- delete old logfiles
  if (access(LogFile))
    delete(LogFile, ver-)
  if (access(WarningFile))
    delete(WarningFile, ver-)
  if (access(ErrorFile))
    delete(ErrorFile, ver-)

# --- Erzeugen von temporaeren Filenamen
  InFile      = mktemp ("tmp")
  HeadsInFile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  if (substr(Images,1,1) == "@")
    ListName = substr(Images,2,strlen(Images))
  else
    ListName = Images
  if (access(ListName)){
    sections(Images, option="root", > InFile)
    P_ImagesList = InFile
  }
  else{
    print("staddheader: ERROR: Images <"//ListName//"> not found!!!")
    print("staddheader: ERROR: Images <"//ListName//"> not found!!!", >> LogFile)
    print("staddheader: ERROR: Images <"//ListName//"> not found!!!", >> WarningFile)
    print("staddheader: ERROR: Images <"//ListName//"> not found!!!", >> ErrorFile)
# --- clean up
    P_HeadersList = ""
    P_HeaderList = ""
    P_ImagesList = ""
    delete (InFile, ver-, >& "dev$null")
    delete (HeadsInFile, ver-, >& "dev$null")
    return
  }

#  if (!access(Headers)){
  if (substr(Headers,1,1) == "@")
    ListName = substr(Headers,2,strlen(Headers))
  else
    ListName = Headers
  if (access(ListName)){
    sections(Headers, option="root", > HeadsInFile)
    P_HeadersList = HeadsInFile
  }
  else{
    print("staddheader: ERROR: Headers <"//ListName//"> not found! => Returning")
    print("staddheader: ERROR: Headers <"//ListName//"> not found! => Returning", >> LogFile)
    print("staddheader: ERROR: Headers <"//ListName//"> not found! => Returning", >> WarningFile)
    print("staddheader: ERROR: Headers <"//ListName//"> not found! => Returning", >> ErrorFile)
# --- clean up
    P_HeadersList = ""
    P_HeaderList = ""
    P_ImagesList = ""
    delete (InFile, ver-, >& "dev$null")
    delete (HeadsInFile, ver-, >& "dev$null")
    return
  }
#  P_HeadersList = HeadsInFile

# --- build output filenames and divide by flat
  while (fscan (P_ImagesList, In) != EOF){

    print("staddheader: In = "//In)
    print("staddheader: In = "//In, >> LogFile)

    if (fscan (P_HeadersList, HeaderFile) == EOF){
      print("staddheader: ERROR: fscan(Headers=<"//Headers//">, HeaderFile) returned EOF! => Returning")
      print("staddheader: ERROR: fscan(Headers=<"//Headers//">, HeaderFile) returned EOF! => Returning", >> LogFile)
      print("staddheader: ERROR: fscan(Headers=<"//Headers//">, HeaderFile) returned EOF! => Returning", >> WarningFile)
      print("staddheader: ERROR: fscan(Headers=<"//Headers//">, HeaderFile) returned EOF! => Returning", >> ErrorFile)
# --- clean up
      P_HeadersList = ""
      P_HeaderList = ""
      P_ImagesList = ""
      delete (InFile, ver-, >& "dev$null")
      delete (HeadsInFile, ver-, >& "dev$null")
      return
    }
    print("staddheader: HeaderFile read from Headers(=<"//Headers//">) = <"//HeaderFile//">")
    if (LogLevel > 2)
      print("staddheader: HeaderFile read from Headers(=<"//Headers//">) = <"//HeaderFile//">", >> LogFile)
# --- read values
    if (!access(HeaderFile)){
      print("staddheader: ERROR: HeaderFile <"//HeaderFile//"> not found! => Returning")
      print("staddheader: ERROR: HeaderFile <"//HeaderFile//"> not found! => Returning", >> LogFile)
      print("staddheader: ERROR: HeaderFile <"//HeaderFile//"> not found! => Returning", >> WarningFile)
      print("staddheader: ERROR: HeaderFile <"//HeaderFile//"> not found! => Returning", >> ErrorFile)
# --- clean up
      P_HeadersList = ""
      P_HeaderList = ""
      P_ImagesList = ""
      delete (InFile, ver-, >& "dev$null")
      delete (HeadsInFile, ver-, >& "dev$null")
      return
    }
    P_HeaderList = HeaderFile
    HeaderKeyWord = ""
#    stra = ""
#    strb = ""
#    strc = ""
#    strd = ""
#    stre = ""
#    strf = ""
#    strg = ""
#    strh = ""
#    stri = ""
#    strj = ""
#    strk = ""
    while(fscan(P_HeaderList, HeaderLine) != EOF){
      print("staddheader: Line read from HeaderFile(=<"//HeaderFile//">): HeaderLine = <"//HeaderLine//">")
#      print("staddheader: Line read from HeaderFile(=<"//HeaderFile//">): <"//HeaderKeyWord//" stra="//stra//" strb="//strb//" strc="//strc//" strd="//strd//" stre="//stre//" strf="//strf//" strg="//strg//" strh="//strh//" stri="//stri//" strj="//strj//" strk="//strk//">")
#      if (LogLevel > 2)
#        print("staddheader: Line read from HeaderFile(=<"//HeaderFile//">): <"//HeaderKeyWord//" stra="//stra//" strb="//strb//" strc="//strc//" strd="//strd//" stre="//stre//" strf="//strf//" strg="//strg//" strh="//strh//" stri="//stri//" strj="//strj//" strk="//strk//">", >> LogFile)
#      strpos(HeaderKeyWord," ")
#      Pos = strpos.pos
#      if (Pos < 1){
#        strpos(HeaderKeyWord,"=")
#        Pos = strpos.pos
#      }
#      if (Pos < 1){
#        print("staddheader: WARNING: No '=' found in Header Line")
#        print("staddheader: WARNING: No '=' found in Header Line", >> LogFile)
#        print("staddheader: WARNING: No '=' found in Header Line", >> WarningFile)
#      }
#      else{
#        HeaderKeyWord = substr(HeaderKeyWord,1,Pos-1)
#        print("staddheader: HeaderKeyWord = <"//HeaderKeyWord//">")
#        if (LogLevel > 2)
#          print("staddheader: HeaderKeyWord = <"//HeaderKeyWord//">", >> LogFile)
#      }
#      SlashFound = NO
#      if (stra != "="){
#        if (substr(stra,1,1) == "=")
#          stra = substr(stra,2,strlen(stra))
#        if (substr(stra,1,1) == "'")
#          stra = substr(stra,2,strlen(stra))
#        strpos(stra,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          stra = substr(stra,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        if (stra != "")
#          Line = stra
#      }
#      else
#        Line = ""
#      print("staddheader: Line after stra = <"//Line//">")
#      if (!SlashFound && strb != "" && strb != "="){
#        if (substr(strb,1,1) == "'")
#          strb = substr(strb,2,strlen(strb))
#        strpos(strb,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          strb = substr(strb,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        print("staddheader: strb = <"//strb//">")
#        if (LogLevel > 2)
#          print("staddheader: strb = <"//strb//">", >> LogFile)
#        if (strb != ""){
#          if (Line != "")
#            Line = Line//" "
#          Line = Line//strb
#        }
#      }
#      print("staddheader: Line after strb = <"//Line//">")
#      if (!SlashFound && strc != "" && strc != "="){
#        if (substr(strc,1,1) == "'")
#          strc = substr(strc,2,strlen(strc))
#        strpos(strc,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          strc = substr(strc,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        if (strc != ""){
#          if (Line != "")
#            Line = Line//" "
#          Line = Line//strc
#        }
#      }
#      print("staddheader: Line after strc = <"//Line//">")
#      if (!SlashFound && strd != "" && strd != "="){
#        if (substr(strd,1,1) == "'")
#          strd = substr(strd,2,strlen(strd))
#        strpos(strd,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          strd = substr(strd,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        if (strd != ""){
#          if (Line != "")
#            Line = Line//" "
#          Line = Line//strd
#        }
#      }
#      print("staddheader: Line after strd = <"//Line//">")
#      if (!SlashFound && stre != "" && stre != "="){
#        if (substr(stre,1,1) == "'")
#          stre = substr(stre,2,strlen(stre))
#        strpos(stre,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          stre = substr(stre,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        if (stre != ""){
#          if (Line != "")
#            Line = Line//" "
#          Line = Line//stre
#        }
#      }
#      print("staddheader: Line after stre = <"//Line//">")
#      if (!SlashFound && strf != "" && strf != "="){
#        if (substr(strf,1,1) == "'")
#          strf = substr(strf,2,strlen(strf))
#        strpos(strf,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          strf = substr(strf,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        if (strf != ""){
#          if (Line != "")
#            Line = Line//" "
#          Line = Line//strf
#        }
#      }
#      print("staddheader: Line after strf = <"//Line//">")
#      if (!SlashFound && strg != "" && strg != "="){
#        if (substr(strg,1,1) == "'")
#          strg = substr(strg,2,strlen(strg))
#        strpos(strg,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          strg = substr(strg,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        if (strg != ""){
#          if (Line != "")
#            Line = Line//" "
#          Line = Line//strg
#        }
#      }
#      print("staddheader: Line after strg = <"//Line//">")
#      if (!SlashFound && strh != "" && strh != "="){
#        if (substr(strh,1,1) == "'")
#          strh = substr(strh,2,strlen(strh))
#        strpos(strh,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          strh = substr(strh,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        if (strh != ""){
#          if (Line != "")
#            Line = Line//" "
#          Line = Line//strh
#        }
#      }
#      print("staddheader: Line after strh = <"//Line//">")
#      if (!SlashFound && stri != "" && stri != "="){
#        if (substr(stri,1,1) == "'")
#          stri = substr(stri,2,strlen(stri))
#        strpos(stri,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          stri = substr(stri,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        if (stri != ""){
#          if (Line != "")
#            Line = Line//" "
#          Line = Line//stri
#        }
#      }
#      print("staddheader: Line after stri = <"//Line//">")
#      if (!SlashFound && strj != "" && strj != "="){
#        if (substr(strj,1,1) == "'")
#          strj = substr(strj,2,strlen(strj))
#        strpos(strj,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          strj = substr(strj,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        if (strj != ""){
#          if (Line != "")
#            Line = Line//" "
#          Line = Line//strj
#        }
#      }
#      print("staddheader: Line after strj = <"//Line//">")
#      if (!SlashFound && strk != "" && strk != "="){
#        if (substr(strk,1,1) == "'")
#          strk = substr(strk,2,strlen(strk))
#        strpos(strk,"/")
#        Pos = strpos.pos
#        if (Pos > 0){
#          strk = substr(strk,1,Pos-1)
#          SlashFound = YES
#          print("staddheader: SlashFound = YES")
#          if (LogLevel > 2)
#            print("staddheader: SlashFound = YES", >> LogFile)
#        }
#        if (strk != ""){
#          if (Line != "")
#            Line = Line//" "
#          Line = Line//strk
#        }
#      }
#      print("staddheader: Line after strk = <"//Line//">")
#      print("staddheader: Value Line = <"//Line//">")
#      if (LogLevel > 2)
#        print("staddheader: Value Line = <"//Line//">", >> LogFile)
      if (substr(HeaderKeyWord,1,5) != "CTYPE" && substr(HeaderKeyWord,1,5) != "CRVAL" && substr(HeaderKeyWord,1,5) != "CRPIX" && substr(HeaderKeyWord,1,2) != "CD" && substr(HeaderKeyWord,1,6) != "WCSDIM" && substr(HeaderKeyWord,1,7) != "DC-FLAG" && substr(HeaderKeyWord,1,6) != "EXTEND" && substr(HeaderKeyWord,1,5) != "APNUM" && substr(HeaderKeyWord,1,8) != "IRAF-TLM" && substr(HeaderKeyWord,1,3) != "LTM" && substr(HeaderKeyWord,1,3) != "WAT"){
        hedit(images=In,
              fields=HeaderKeyWord,
              value=HeaderLine,
              add+,
              addonly-,
              del-,
              ver-,
              show+,
              upd+)
        NKeyWordsSet += 1
        print("staddheader: "//NKeyWordsSet//" KeyWords set")
      }
      stra = ""
      strb = ""
      strc = ""
      strd = ""
      stre = ""
      strf = ""
      strg = ""
      strh = ""
      stri = ""
      strj = ""
      strk = ""
      HeaderKeyWord = ""
    }
  }# end while (fscan (P_ImagesList, In) != EOF){

# --- Aufraeumen
  P_HeadersList = ""
  P_HeaderList = ""
  P_ImagesList = ""
  delete (InFile, ver-, >& "dev$null")
  delete (HeadsInFile, ver-, >& "dev$null")

end
