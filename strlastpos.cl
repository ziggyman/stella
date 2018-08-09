procedure strlastpos(tempstring,substring)

##################################################################
#                                                                #
# NAME:             strlastpos.cl                                #
# PURPOSE:          * sets output parameter strlastpos.pos to    #
#                     first position of last occurence of        #
#                     <substring> in <tempstring>                #
#                                                                #
# CATEGORY:         general                                      #
# CALLING SEQUENCE: strlastpos(tempstring, substring)            #
# INPUTS:           tempstring: String                           #
#                     input string to search                     #
#                   substring: String                            #
#                     string to search for last occurence in     #
#                     <tempstring>                               #
#                                                                #
# OUTPUTS:          output: Integer strlastpos.pos               #
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
string tempstring = "tempstring" {prompt="String to search substr"}
string substring  = "str"        {prompt="Substring to search for in string"}
string logfile    = "logfile_strlastpos.log" {prompt="Name of logfile"}
int    pos

begin
  int strlensubstr
  int strlenstr
  int i

  if (access(logfile))
    del(logfile, ver-)

  strlensubstr = strlen(substring)
  strlenstr = strlen(tempstring)

  pos = 0
  for (i=1;i<=strlenstr-strlensubstr+1;i=i+1){
#    print("strlastpos: substr(tempstr=<"//tempstr//">, i="//i//", i+strlensubstr-1="//i+strlensubstr-1//") = "//substr(tempstr,i,i+strlensubstr-1)//",    substr=<"//substr//">")
#    print("strlastpos: substr(tempstr=<"//tempstr//">, i="//i//", i+strlensubstr-1="//i+strlensubstr-1//") = "//substr(tempstr,i,i+strlensubstr-1)//",    substr=<"//substr//">", >> logfile)
    if (substr(tempstr,i,i+strlensubstr-1) == substr){
      pos = i
#      print("strlastpos: setting pos to "//pos)
#      print("strlastpos: setting pos to "//pos, >> logfile)
    }
  }
end
