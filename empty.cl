procedure empty(parameter)

#########################################################################
#                                                                       #
# NAME:                  empty                                          #
# PURPOSE:               * calculates ...                               #
#                                                                       #
# CATEGORY:                                                             #
# CALLING SEQUENCE:      empty,<parametertype parameter>                #
# INPUTS:                input file: 'parameter':                       #
#                         3740.80444335938      105783.50               #
#                                            .                          #
#                                            .                          #
#                                            .                          #
#                        outfile: String                                #
# OUTPUTS:               outfile:                                       #
#                                                                       #
# IRAF VERSION:          2.11                                           #
#                                                                       #
# COPYRIGHT:             Andreas Ritter                                 #
# CONTACT:               aritter@aip.de                                 #
#                                                                       #
# LAST EDITED:           24.12.2005                                     #
#                                                                       #
#########################################################################

string image = "image.fits"                 {prompt="Name of image to find number of orders"}
string *ccdlistoutlist

begin
  string ccdlistoutfile="outfile_ccdlist.text"
end
