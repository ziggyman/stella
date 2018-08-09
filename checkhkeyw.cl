procedure checkhkeyw(image)

#########################################################################
#                                                                       #
# NAME:                  checkhkeyw                                     #
# PURPOSE:               * writes the mean of <image> to the paramerter #
#                          checkhkeyw.mean                              #
#                                                                       #
# CATEGORY:                                                             #
# CALLING SEQUENCE:      checkhkeyw,<String image>                      #
# INPUTS:                input file: 'image':                           #
#                         regularly FITS file                           #
# OUTPUTS:               parameter checkhkeyw.mean                      #
#                                                                       #
# IRAF VERSION:          2.11                                           #
#                                                                       #
# COPYRIGHT:             Andreas Ritter                                 #
# CONTACT:               aritter@aip.de                                 #
#                                                                       #
# LAST EDITED:           25.04.2006                                     #
#                                                                       #
#########################################################################

string image = "image.fits"                 {prompt="Name of image to find mean"}
real   mean
string *imstatoutlist

begin
  string imstatoutfile="outfile_imstat.text"
  string meanstring
  
  if (access(imstatoutfile))
    del(imstatoutfile, ver-)

  imstat(images=image,
         fields="mean",
         lower=INDEF,
         upper=INDEF,
         nclip=0,
         lsigma=5.,
         usigma=5.,
         binwidth=0.1,
         format-,
         cache-, >> imstatoutfile)

  if (access(imstatoutfile)){
    imstatoutlist = imstatoutfile
    while(fscan(imstatoutlist, meanstr) != EOF){
      mean = real(meanstr)
      print("checkhkeyw: Parameter mean set to "//mean)
    }
  }
  else{
    print("checkhkeyw: imstatoutfile <"//imstatoutfile//"> not found => Returning!!!")
  }
end
