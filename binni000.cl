procedure binning (input, output)
# bins 1 image from 2148x3000 to 2148x1500
#           or from 4296x4096 to 4296x2048
#
# Andreas Ritter, 15.05.2001
#
#


string  input   {prompt="image to bin"}
string  output   {prompt="output filename"}
string  reference   {prompt="reference image (same size like output image)"}
int direction   {prompt="1-cols 2-rows"}
int columns   {prompt="number of columns (original image)"}
int rows   {prompt="number of rows (original image)"}

begin
  int nr=1

  imdel("temp1")
  imdel("temp2")
  imdel("temp3")

#  if (rows == 2148){
#    if (columns == 3000){
#      imcopy ("UVES.2000-05-26T22:34:03.847", "temp1")
#      imcopy ("UVES.2000-05-26T22:34:03.847", "temp2")
#    }
#    if (columns == 4096){
      imcopy (reference, "temp1")
      imcopy (reference, "temp2")
#    }
#  }
#  if (rows == 4296){
#    if (columns == 4096){
#      imcopy ("UVES.2000-05-26T13:33:37.707_b.fits", "temp1")
#      imcopy ("UVES.2000-05-26T13:33:37.707_b.fits", "temp2")
#    }
#  }
  for (i=1; i<=columns-1;i=i+2) {
    if (direction == 1){
      imcopy (input//"[*,"//i//"]", "temp1[*,"//nr//"]")
      imcopy (input//"[*,"//i+1//"]", "temp2[*,"//nr//"]")
    }
    else {
      imcopy (input//"["//i//",*]", "temp1["//nr//",*]")
      imcopy (input//"["//i+1//",*]", "temp2["//nr//",*]")      
    }
    nr = nr+1
  }
  imarith ("temp1","+", "temp2", "temp3")
  imarith ("temp3","/", 2., output)
  imdel("temp1")
  imdel("temp2")
  imdel("temp3")

end
cl()