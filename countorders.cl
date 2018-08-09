procedure countorders(image)

##################################################################
#                                                                #
# NAME:             countorders.cl                               #
# PURPOSE:          * counts orders                              #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: countorders(String: image)                   #
# INPUTS:           image: String                                #
#                     name of file containing the extracted      #
#                     spectrum                                   #
#                                                                #
# OUTPUTS:          Integer 'norders'                            #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED:          14.10.2004                                   #
# LAST EDITED:      19.04.2007                                   #
#                                                                #
##################################################################

string image    = "image.fits"  {prompt="Name of image to find number of orders"}
string dispaxis = "1"           {prompt="Dispersion axis (1-horizontal, 2-vertical",
                                  enum="1|2"}
string logfile  = "logfile.log" {prompt="Name of logfile"}
int    norders
string *ccdlistoutlist

begin
  string ccdlistoutfile="outfile_ccdlist.text"
  string line,startstr,endstr
  string nordersstr=""
  int    pos=0
  
  if (access(logfile))
    del(logfile, ver-)
  if (access(ccdlistoutfile))
    del(ccdlistoutfile, ver-)
  if (dispaxis == "1"){
    startstr = "["
    endstr   = ","
  }
  else{
    startstr = ","
    endstr   = "]"
  }
  ccdlist(images=image,
          ccdtype="",
          names-,
          long-,
          ccdproc-, >> ccdlistoutfile)
  if (access(ccdlistoutfile)){
    ccdlistoutlist = ccdlistoutfile
    while (fscan(ccdlistoutlist,line) != EOF){
      print("countorders: line = <"//line//">")
      print("countorders: line = <"//line//">", >> logfile)
      while (substr(line,pos,pos) != startstr)
        pos = pos+1
      if (substr(line,pos,pos) == startstr){
        print("countorders: <"//startstr//"> found at position "//pos)
        print("countorders: <"//startstr//"> found at position "//pos, >> logfile)
        print("countorders: substr(line,"//pos//","//pos//") = "//substr(line,pos,pos))
        print("countorders: substr(line,"//pos//","//pos//") = "//substr(line,pos,pos), >> logfile)
        while(substr(line,pos,pos) != endstr){
          pos = pos+1
          nordersstr = nordersstr//substr(line,pos,pos)
          print("countorders: substr(line,"//pos//","//pos//") = "//substr(line,pos,pos))
          print("countorders: substr(line,"//pos//","//pos//") = "//substr(line,pos,pos), >> logfile)
        }
      }
    }
    norders = int(nordersstr)
    print("countorders: norders = "//norders)
    print("countorders: norders = "//norders, >> logfile)
  }
  else{
    print("countorders: ERROR: file <"//ccdlistoutfile//"> not found! => Returning")
    print("countorders: ERROR: file <"//ccdlistoutfile//"> not found! => Returning", >> logfile)
  }
end
