procedure getpath()

##################################################################
#                                                                #
# NAME:             getpath                                      #
# PURPOSE:          * sets output parameter getpath.path to      #
#                     output of Linux command "pwd"              #
#                                                                #
# CATEGORY:         general                                      #
# CALLING SEQUENCE: getpath()                                    #
# INPUTS:           -                                            #
#                                                                #
# OUTPUTS:          output: String getpath.path                  #
#                   outfile: -                                   #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      24.10.2006                                   #
# LAST EDITED:      02.04.2007                                   #
#                                                                #
##################################################################

string logfile = "logfile_getpath.log" {prompt="Name of logfile"}
string path
string *pathlist

begin
  string pwdoutfile = "pwd_out.text"
  string temppath = ""
  
  if (access(logfile))
    del(logfile, ver-)
  pwdoutfile = "pwd_out.text"
  if (access(pwdoutfile))
    del(pwdoutfile, ver-)
  pwd(, >> pwdoutfile)
  if (access(pwdoutfile)){
    pathlist = pwdoutfile
    if (fscan(pathlist,temppath) != EOF){
      print("getpath: temppath = <"//temppath//">")
      print("getpath: temppath = <"//temppath//">", >> logfile)
    }
  }
  else{
    path=""
    print("getpath: ERROR: file <"//pwdoutfile//"> not found! => Returning")
    print("getpath: ERROR: file <"//pwdoutfile//"> not found! => Returning", >> logfile)
    return
  }
  path = temppath
  print("getpath: path = <"//path//">")
  del(pwdoutfile, ver-)
end
