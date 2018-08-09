procedure getpathfromstring(instring)

##################################################################
#                                                                #
# NAME:             getpathfromstring.cl                         #
# PURPOSE:          * sets path to result of pwd                 #
#                                                                #
# CATEGORY:         general                                      #
# CALLING SEQUENCE: getpathfromstring(instring)                  #
# INPUTS:           instring: String                             #
#                     "<path>/<filename>"                        #
#                                                                #
# OUTPUTS:          output: String 'path'                        #
#                   outfile: -                                   #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED:          24.10.2006                                   #
# LAST EDITED:      02.04.2007                                   #
#                                                                #
##################################################################

string instring = "/path/file"                    {prompt="String to take path from"}
string logfile  = "logfile_getpathfromstring.log" {prompt="Name of logfile"}
string path

begin
  string temppath
  
  if (access(logfile))
    del(logfile, ver-)

  strlastpos(instring,"/")

  path = substr(instring,1,strlastpos.pos)
  print("getpathfromstring: path = <"//path//">")
end
