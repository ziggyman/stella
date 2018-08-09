procedure getpathfromlist(inlist)

##################################################################
#                                                                #
# NAME:             getpathfromlist.cl                           #
# PURPOSE:          * sets output parameter getpathfromlist.path #
#                     to the path of the last file in <inlist>   #
#                                                                #
# CATEGORY:         general                                      #
# CALLING SEQUENCE: getpathfromlist(inlist)                      #
# INPUTS:           inlist: String                               #
#                     name of filelist to search for path        #
#                                                                #
# OUTPUTS:          output: String 'path'                        #
#                   outfile: -                                   #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED:          24.10.2006                                   #
# LAST EDITED:      04.04.2007                                   #
#                                                                #
##################################################################

string inlist  = "files.list"                   {prompt="String to take path from"}
string logfile = "logfile_getpathfromlist.log"  {prompt="Name of logfile"}
string path
string *filelist

begin
  string temppath
  
  if (access(logfile))
    del(logfile, ver-)

  if (!access(inlist)){
    print("getpathfromlist: cannot access inlist(="//inlist//") => returning!")
    print("getpathfromlist: cannot access inlist(="//inlist//") => returning!", >> logfile)
    return
  }
  filelist = inlist
  if (fscan(filelist, temppath) == EOF){
    print("getpathfromlist: cannot read inlist(="//inlist//") => returning!")
    print("getpathfromlist: cannot read inlist(="//inlist//") => returning!", >> logfile)
    return
  }
  getpathfromstring(temppath)

  path = getpathfromstring.path
  print("getpathfromlist: path = <"//path//">")

  inlist = ""
end
