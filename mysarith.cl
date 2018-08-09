procedure mysarith(image1, op, image2, outimage)

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

string image1 = "image1.fits" {prompt="Name of operator1"}
string op = "+" {prompt="operation [+,-,/,*,sqrt]"}
string image2 = "image2.fits" {prompt="Name of operator2"}
string outimage = "outimage.fits" {prompt="Name of output image"}

begin
  
  if (access(outimage))
    del(outimage, ver-)
  
  if (access(image1)){
    if (access(image2)){
      specarith(image1,op,image2,outimage)
    }
    else{
      print("mysarith <"//image2//"> not found => Returning!!!")
    }
  }
  else{
    print("mysarith <"//image1//"> not found => Returning!!!")
  }
end
