procedure strpos(tempstring,substring)

##################################################################
#                                                                #
# NAME:             strpos.cl                                    #
# PURPOSE:          * sets output parameter strlastpos.pos to    #
#                     first position of first occurence of       #
#                     <substring> in <tempstring>, if <substring>#
#                     is found, else to '0'                      #
#                                                                #
# CATEGORY:         general                                      #
# CALLING SEQUENCE: strpos(tempstring, substring)                #
# INPUTS:           tempstring: String                           #
#                     input string to search                     #
#                   substring: String                            #
#                     string to search for first occurence in    #
#                     <tempstring>                               #
#                                                                #
# OUTPUTS:          output: Integer strpos.pos                   #
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
int    pos

begin
  int strlensubstr
  int strlenstr
  int i

  strlensubstr = strlen(substring)
  strlenstr = strlen(tempstring)

  pos = 0
  for (i=1;i<=strlenstr-strlensubstr+1;i=i+1){
    if (substr(tempstr,i,i+strlensubstr-1) == substr){
      pos = i
      return
    }
  }

end
