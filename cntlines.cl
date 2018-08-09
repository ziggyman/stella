procedure cntlines(textfile)

##################################################################
#                                                                #
# NAME:             cntlines.cl                                  #
# PURPOSE:          * counts orders                              #
#                                                                #
# CATEGORY:                                                      #
# CALLING SEQUENCE: cntlines(String: textfile)                   #
# INPUTS:           textfile: String                             #
#                     name of file containing extracted spectrum #
#                                                                #
# OUTPUTS:          Integer 'nlines'                             #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED:          14.10.2004                                   #
# LAST EDITED:      24.04.2006                                   #
#                                                                #
##################################################################

string textfile    = "textfile.text"         {prompt="Name of textfile to find number of orders"}
string logfile     = "logfile_cntlines.log"  {prompt="Name of logfile"}
string warningfile = "warnings_cntlines.log" {prompt="Name of warning file"}
string errorfile   = "errors_cntlines.log"   {prompt="Name of error file"}
int    nlines
string *wcoutlist

begin
  string wcoutfile="outfile_wc.text"
  string line
  
  if (access(logfile))
    del(logfile, ver-)
  if (access(warningfile))
    del(warningfile, ver-)
  if (access(errorfile))
    del(errorfile, ver-)
  if (access(wcoutfile))
    del(wcoutfile, ver-)

  if (!access(textfile)){
    print("cntlines: ERROR: textfile <"//textfile//"> not found! => Returning")
    print("cntlines: ERROR: textfile <"//textfile//"> not found! => Returning", >> logfile)
    print("cntlines: ERROR: textfile <"//textfile//"> not found! => Returning", >> warningfile)
    print("cntlines: ERROR: textfile <"//textfile//"> not found! => Returning", >> errorfile)
# --- clean up
    return
  }
  wc(textfile, >> wcoutfile)
  if (!access(wcoutfile)){
    print("cntlines: ERROR: file <"//ccdlistoutfile//"> not found! => Returning")
    print("cntlines: ERROR: file <"//ccdlistoutfile//"> not found! => Returning", >> logfile)
    print("cntlines: ERROR: file <"//ccdlistoutfile//"> not found! => Returning", >> warningfile)
    print("cntlines: ERROR: file <"//ccdlistoutfile//"> not found! => Returning", >> errorfile)
# --- clean up
    del(wcoutfile, ver-)
    wcoutlist = ""
    return
  }
  wcoutlist = wcoutfile
  if (fscan(wcoutlist,line) == EOF){
    print("cntlines: ERROR: fscan(wcoutfile=<"//wcoutfile//">) returned EOF => returning")
    print("cntlines: ERROR: fscan(wcoutfile=<"//wcoutfile//">) returned EOF => returning", >> logfile)
    print("cntlines: ERROR: fscan(wcoutfile=<"//wcoutfile//">) returned EOF => returning", >> warningfile)
    print("cntlines: ERROR: fscan(wcoutfile=<"//wcoutfile//">) returned EOF => returning", >> errorfile)
# --- clean up
    del(wcoutfile, ver-)
    wcoutlist = ""
    return
  }
#  print("cntlines: line = <"//line//">")
#  print("cntlines: line = <"//line//">", >> logfile)

  nlines = int(line)
  print("cntlines: textfile <"//textfile//"> contains "//nlines//"lines")
  print("cntlines: textfile <"//textfile//"> contains "//nlines//"lines", >> logfile)

# --- clean up
  del(wcoutfile, ver-)
  wcoutlist = ""
end
