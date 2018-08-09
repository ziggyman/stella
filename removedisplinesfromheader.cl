procedure removedisplinesfromheader(HeaderFile)

string HeaderFile  = "fits_head.text"                         {prompt="Name of Header File"}
string LogFile     = "logfile_removedisplinesfromheader.log"  {prompt="Name of Log File"}
string WarningFile = "warnings_removedisplinesfromheader.log" {prompt="Name of Warning File"}
string ErrorFile   = "errors_removedisplinesfromheader.log"   {prompt="Name of Error File"}
string *P_List

begin
  string TempHeader,ShortHeader,HeaderLine,TempShortHeader
  string LogFile_cntlines = "logfile_cntlines.log"
  string WarningFile_cntlines = "warningfile_cntlines.log"
  string ErrorFile_cntlines = "errorfile_cntlines.log"

  if (access(LogFile))
    del(LogFile, ver-)
  if (access(WarningFile))
    del(WarningFile, ver-)
  if (access(ErrorFile))
    del(ErrorFile, ver-)

  if (!access(HeaderFile)){
    print("stmerge: ERROR: HeaderFile <"//HeaderFile//"> not found! => Returning!")
    print("stmerge: ERROR: HeaderFile <"//HeaderFile//"> not found! => Returning!", >> LogFile)
    print("stmerge: ERROR: HeaderFile <"//HeaderFile//"> not found! => Returning!", >> WarningFile)
    print("stmerge: ERROR: HeaderFile <"//HeaderFile//"> not found! => Returning!", >> ErrorFile)
# --- clean up
    P_StrList = ""
    P_FileList = ""
    return
  }

  TempHeader = HeaderFile//".new.temp"
  if (access(TempHeader))
    del(TempHeader, ver-)

  TempShortHeader = HeaderFile//".short.temp"
  if (access(TempShortHeader))
    del(TempShortHeader, ver-)

  ShortHeader = HeaderFile//".temp"
  if (access(ShortHeader))
    del(ShortHeader, ver-)

  copy(HeaderFile, ShortHeader)

  P_List = HeaderFile
  while(fscan(P_List, HeaderLine) != EOF){
    print("removedisplinesfromheader: read HeaderKeyWord = <"//HeaderLine//">")
    print("removedisplinesfromheader: read HeaderKeyWord = <"//HeaderLine//">", >> LogFile)
    if (substr(HeaderLine,1,5) != "CTYPE" && substr(HeaderLine,1,5) != "CRVAL" && substr(HeaderLine,1,5) != "CRPIX" && substr(HeaderLine,1,2) != "CD" && substr(HeaderLine,1,6) != "WCSDIM" && substr(HeaderLine,1,7) != "DC-FLAG" && substr(HeaderLine,1,6) != "EXTEND" && substr(HeaderLine,1,5) != "APNUM" && substr(HeaderLine,1,4) != "DATE" && substr(HeaderLine,1,8) != "IRAF-TLM" && substr(HeaderLine,1,3) != "LTM" && substr(HeaderLine,1,3) != "WAT"){
      head(input_files = ShortHeader, 
           nlines      = 1, >> TempHeader)
      jobs
      wait()
      cntlines(textfile = TempHeader,
               logfile = LogFile_cntlines,
               warningfile = WarningFile_cntlines,
               errorfile = ErrorFile_cntlines)
      if (access(LogFile_cntlines))
        cat(LogFile_cntlines, >> LogFile)
      if (access(WarningFile_cntlines))
        cat(WarningFile_cntlines, >> LogFile)
      if (access(ErrorFile_cntlines)){
        cat(ErrorFile_cntlines, >> LogFile)
        print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!")
        print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> LogFile)
        print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> WarningFile)
        print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> ErrorFile)
# --- clean up
        P_List = ""
        return
      }
#      print("removedisplinesfromheader: cntlines(TempHeader="//TempHeader//") returned "//cntlines.nlines)
#      print("removedisplinesfromheader: cntlines(TempHeader="//TempHeader//") returned "//cntlines.nlines, >> LogFile)
    }
    else{
      print("removedisplinesfromheader: HeaderKeyWord = <"//HeaderLine//"> rejected")
      print("removedisplinesfromheader: HeaderKeyWord = <"//HeaderLine//"> rejected", >> LogFile)
    }
    jobs
    wait()
    if (access(TempShortHeader))
      del(TempShortHeader, ver-)
    cntlines(ShortHeader,
             logfile = LogFile_cntlines,
             warningfile = WarningFile_cntlines,
             errorfile = ErrorFile_cntlines)
    if (access(LogFile_cntlines))
      cat(LogFile_cntlines, >> LogFile)
    if (access(WarningFile_cntlines))
      cat(WarningFile_cntlines, >> LogFile)
    if (access(ErrorFile_cntlines)){
      cat(ErrorFile_cntlines, >> LogFile)
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!")
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> LogFile)
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> WarningFile)
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> ErrorFile)
# --- clean up
      P_List = ""
      return
    }
#    print("removedisplinesfromheader: cntlines(ShortHeader="//ShortHeader//") returned "//cntlines.nlines)
#    print("removedisplinesfromheader: cntlines(ShortHeader="//ShortHeader//") returned "//cntlines.nlines, >> LogFile)
#    return
    tail(input_files = ShortHeader, 
         nlines      = cntlines.nlines-1, >> TempShortHeader)
    cntlines(TempShortHeader,
             logfile = LogFile_cntlines,
             warningfile = WarningFile_cntlines,
             errorfile = ErrorFile_cntlines)
    if (access(LogFile_cntlines))
      cat(LogFile_cntlines, >> LogFile)
    if (access(WarningFile_cntlines))
      cat(WarningFile_cntlines, >> LogFile)
    if (access(ErrorFile_cntlines)){
      cat(ErrorFile_cntlines, >> LogFile)
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!")
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> LogFile)
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> WarningFile)
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> ErrorFile)
# --- clean up
      P_List = ""
      return
    }
#    print("removedisplinesfromheader: cntlines(TempShortHeader="//TempShortHeader//") returned "//cntlines.nlines)
#    print("removedisplinesfromheader: cntlines(TempShortHeader="//TempShortHeader//") returned "//cntlines.nlines, >> LogFile)
    del (ShortHeader)
    copy (TempShortHeader, ShortHeader)
    cntlines(ShortHeader,
             logfile = LogFile_cntlines,
             warningfile = WarningFile_cntlines,
             errorfile = ErrorFile_cntlines)
    if (access(LogFile_cntlines))
      cat(LogFile_cntlines, >> LogFile)
    if (access(WarningFile_cntlines))
      cat(WarningFile_cntlines, >> LogFile)
    if (access(ErrorFile_cntlines)){
      cat(ErrorFile_cntlines, >> LogFile)
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!")
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> LogFile)
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> WarningFile)
      print("removedisplinesfromheader: ERROR: cntlines returned with error => Returning!", >> ErrorFile)
# --- clean up
      P_List = ""
      return
    }
#    print("removedisplinesfromheader: cntlines(ShortHeader="//ShortHeader//") returned "//cntlines.nlines)
#    print("removedisplinesfromheader: cntlines(ShortHeader="//ShortHeader//") returned "//cntlines.nlines, >> LogFile)
#    return
  }
  del(HeaderFile, ver-)
  copy (TempHeader, HeaderFile)
  print("removedisplinesfromheader: HeaderFile <"//HeaderFile//"> ready")
  print("removedisplinesfromheader: HeaderFile <"//HeaderFile//"> ready", >> LogFile)

  P_List = ""

end
