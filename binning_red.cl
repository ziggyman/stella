procedure binning (input, output)
# bins 1 image from 4296x4096 to 2148x1500
#
# Andreas Ritter, 15.05.2001
#
#Note for Iraf setup: Taperedge 20%, cosbell, edge
#  continuum spline3, 1st order           
#


string  input   {prompt="image to bin"}
string  output   {prompt="output filename"}

begin
  #string tmp1,tmp2
  int zeile=1

  #tmp1 = mktemp("tmp$tap")
  #tmp2 = mktemp("tmp$tap")	

  imdel("temp1")
  imdel("temp2")

  imcopy ("UVES.2000-05-26T22:34:03.847", "temp1")
  imcopy ("UVES.2000-05-26T22:34:03.847", "temp2")

  #imcopy (input//"[*,1]", "temp1")
  #imcopy (input//"[*,2]", "temp2")
  #zeile =zeile+1

  for (i=1; i<=2999;i=i+2) {
    imcopy (input//"[*,"//i//"]", "temp1[*,"//zeile//"]")
    imcopy (input//"[*,"//i+1//"]", "temp2[*,"//zeile//"]")
    zeile =zeile+1
  }
  imarith ("temp1","+", "temp2", output)
  #imdel("temp1")
  #imdel("temp2")

end
cl()