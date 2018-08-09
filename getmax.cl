procedure getmax(image)

##################################################################
#                                                                #
# NAME:             getmax.cl                                    #
# PURPOSE:          * writes the maximum of <image> to the       #
#                     output parameter getmax.max                #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: getmax(image)                                #
# INPUTS:           image: String                                #
#                    name of image/spectrum to search for the    #
#                    maximum                                     #
#                                                                #
# OUTPUTS:          parameter getmax.max                         #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED:          15.10.2004                                   #
# LAST EDITED:      16.04.2007                                   #
#                                                                #
##################################################################

string image = "image.fits" {prompt="Name of image to find max"}
real   max
string *imstatoutlist

begin
  string imstatoutfile="outfile_imstat.text"
  string maxstring
  
  if (access(imstatoutfile))
    del(imstatoutfile, ver-)

  imstat(images=image,
         fields="max",
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
    while(fscan(imstatoutlist, maxstr) != EOF){
      max = real(maxstr)
      print("getmax: Parameter max set to "//max)
    }
  }
  else{
    print("getmax: imstatoutfile <"//imstatoutfile//"> not found => Returning!!!")
  }
end
