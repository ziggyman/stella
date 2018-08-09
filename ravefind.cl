procedure find_first_fibre_used(fibrelistname)

##################################################################
#                                                                #
# NAME:             stdispcor.cl                                 #
# PURPOSE:          * automatic dispersion correction            #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stdispcor(images)                            #
# INPUTS:           images: String                               #
#                     name of list containing names of           #
#                     images to correct for the dispersion:      #
#                       "objects_botzfxsEcBl.list":              #
#                         HD175640_botzfxsEcBl.fits              #
#                         ...                                    #
#                                                                #
# OUTPUTS:                                                       #
#                   Output files:                                #
#                     <Entry_in_images_Root>d.<imtype>           #
#                   Log Files:                                   #
#                     <LogFile>,<WarningFile>,<ErrorFile>        #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      04.01.2002                                   #
# LAST EDITED:      18.04.2007                                   #
#                                                                #
##################################################################

string fibrelistname = "J8_0200m575p1.lis"      {prompt="List of input images"}
string* fibrelist

begin
  string line
  bool found_fibre = NO

  if (!access(fibrelistname)){
    print("find_first_fibre_used: ERROR: cannot acces fibrelistname "//fibrelistname)
    return
  }
  fibrelist = fibrelistname
  while(!found_fibre){
    if (substr(line,1,6) == "*Fibre"){
      found_fibre = YES
    }
  }
  while(fscan(fibrelist, line) != EOF){
    strtrim(line,2,strlen(line))
    line = strtrim.out

  }
end
