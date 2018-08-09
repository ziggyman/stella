procedure trimstr(tempstring)

##################################################################
#                                                                #
# NAME:             strtrim.cl                                   #
# PURPOSE:          * removes leading/trailing spaces from       #
#                     tempstring and writes result to output     #
#                     parameter strtrim.out                      #
#                                                                #
# CATEGORY:         general                                      #
# CALLING SEQUENCE: strtrim(tempstring, mode)                    #
# INPUTS:           tempstring: String                           #
#                     input string to remove spaces              #
#                   mode: int                                    #
#                     0...remove leading spaces                  #
#                     1...remove trailing spaces                 #
#                     2...remove leading and trailing spaces     #
#                                                                #
# OUTPUTS:          output: strtrim.out                          #
#                   outfile: -                                   #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      06.10.2010                                   #
# LAST EDITED:      06.10.2010                                   #
#                                                                #
##################################################################
string tempstring = "tempstring" {prompt="String to trim"}
int    mode       = 2            {prompt="mode (0..front, 1..end, 2..both)"}
string out

begin
#  int strlenstr,i,startfound

#  startfound = 0

#  strlenstr = strlen(tempstring)

#  out = ""
#  print("tempstring = "//tempstring)
#  print("mode = "//mode)
#  if (mode == 1){
#    startfound = 1
#    out = tempstring
#  }
#  if (mode == 0 || mode == 2){
#    for (i=1;i<=strlenstr;i=i+1){
#      if (startfound == 0){
#        if (substr(tempstr,i,i) != " "){
#          startfound = 1
#          out = out//substr(tempstr,i,i)
#          print("1. startfound = "//startfound)
#        }
#      }
#      else{
#        out = out//substr(tempstr,i,i)
#      }
#      print("out = "//out)
#    }
#  }

#  startfound = 0
#  if (mode == 1 || mode == 2){
#    for (i=strlenstr; i > 0; i=i-1){
#      if (startfound == 0){
#        if (substr(out,i,i) != " "){
#          startfound = 1
#          out = substr(out,1,i-1)
#          print("2. startfound = "//startfound)
#        }
#      }
#    }
#  }

end
