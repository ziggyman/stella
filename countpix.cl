procedure countpix(image)

##################################################################
#                                                                #
# NAME:             countpix                                     #
# PURPOSE:          * counts number of pixels per order          #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: countpix(image)                              #
# INPUTS:           image: String                                #
#                     name of file containing extracted spectrum #
#                                                                #
# OUTPUTS:          Integer 'npixels'                            #
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

string image    = "image.fits"           {prompt="Name of image to find number of pixels"}
string dispaxis = "1"                    {prompt="Dispersion axis (1-horizontal, 2-vertical",
                                           enum="1|2"}
string logfile  = "logfile_countpix.log" {prompt="Name of logfile"}
int    npixels
string *ccdlistoutlist

begin
  string ccdlistoutfile="outfile_ccdlist.text"
  string line,startstr,endstr
  string npixelsstr=""
  int    pos=0
  
  if (access(logfile))
    del(logfile, ver-)
  if (access(ccdlistoutfile))
    del(ccdlistoutfile, ver-)
  if (dispaxis == "1"){
    startstr = ","
    endstr   = "]"
  }
  else{
    startstr = "["
    endstr   = ","
  }
  ccdlist(images=image,
          ccdtype="",
          names-,
          long-,
          ccdproc-, >> ccdlistoutfile)
  if (access(ccdlistoutfile)){
    ccdlistoutlist = ccdlistoutfile
    while (fscan(ccdlistoutlist,line) != EOF){
      print("countpix: line = <"//line//">")
      print("countpix: line = <"//line//">", >> logfile)
      while (substr(line,pos,pos) != startstr)
        pos = pos+1
      if (substr(line,pos,pos) == startstr){
        print("countpix: <"//startstr//"> found at position "//pos)
        print("countpix: <"//startstr//"> found at position "//pos, >> logfile)
        print("countpix: substr(line,"//pos//","//pos//") = "//substr(line,pos,pos))
        print("countpix: substr(line,"//pos//","//pos//") = "//substr(line,pos,pos), >> logfile)
        while(substr(line,pos,pos) != endstr){
          pos = pos+1
          npixelsstr = npixelsstr//substr(line,pos,pos)
          print("countpix: substr(line,"//pos//","//pos//") = "//substr(line,pos,pos))
          print("countpix: substr(line,"//pos//","//pos//") = "//substr(line,pos,pos), >> logfile)
        }
      }
    }
    npixels = int(npixelsstr)
    print("countpix: npixels = "//npixels)
    print("countpix: npixels = "//npixels, >> logfile)
  }
  else{
    print("countpix: ERROR: file <"//ccdlistoutfile//"> not found! => Returning")
    print("countpix: ERROR: file <"//ccdlistoutfile//"> not found! => Returning", >> logfile)
  }
end
