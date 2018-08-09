procedure binning (input, output)
# bins 1 image
#
# Andreas Ritter, 15.05.2001
#
#


string  input   {prompt="image to bin"}
string  output   {prompt="output filename"}
#string  reference   {prompt="reference image (same size like output image)"}
int direction   {prompt="1-x 2-y"}
int columns   {prompt="number of columns (original image)"}
int rows   {prompt="number of rows (original image)"}

begin
  int nr=1
  int dum

  imdel("temp1")
  imdel("temp2")
  imdel("temp3")

  #imcopy (reference, "temp1")
  #imcopy (reference, "temp2")

  if (direction == 1){ 			#x-direction
    dum=columns/2
    imcopy (input//"[1:"//dum//",*]", "temp1")
    imcopy (input//"["//dum+1//":"//columns//",*]", "temp2")
    for (i=1; i<=columns-1;i=i+2) {
      imcopy (input//"["//i//",*]", "temp1["//nr//",*]")
      imcopy (input//"["//i+1//",*]", "temp2["//nr//",*]")      
      nr = nr+1
    }
  }
  else if (direction == 2){ 			#y-direction
    dum=rows/2
    imcopy (input//"[*,1:"//dum//"]", "temp1")
    imcopy (input//"[*,"//dum+1//":"//rows//"]", "temp2")
    for (i=1; i<=rows-1;i=i+2) {
      imcopy (input//"[*,"//i//"]", "temp1[*,"//nr//"]")
      imcopy (input//"[*,"//i+1//"]", "temp2[*,"//nr//"]")
      nr = nr+1
    }
  }
  imarith ("temp1","+","temp2","temp3")
  imarith ("temp3","/",2.,output)
#  imdel("temp1")
#  imdel("temp2")
#  imdel("temp3")

end
#cl()
