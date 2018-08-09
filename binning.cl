procedure binning (input, direction, columns, rows)
# bins 1 image from 2148x3000 to 2148x1500
#           or from 4296x4096 to 4296x2048
#
# Andreas Ritter, 15.05.2001
#
#


string  input     {prompt="image to bin"}
#string  output   {prompt="output filename"}
int direction     {prompt="1-y 2-x"}
int columns       {prompt="number of columns (original image)"}
int rows          {prompt="number of rows (original image)"}
string *inputlist

begin
  file   infile
  string in,out

  int nr=1

  imdel("temp1",ver-)
  imdel("temp2",ver-)
  imdel("temp3",ver-)

  infile = mktemp ("tmp")
  if ((substr(input,1,1) == "@" && access(substr(input,2,strlen(input)))) || (substr(input,1,1) != "@" && access(input))){
    sections(input, option="root", > infile)
    inputlist = infile
  }
  else{
    if (substr(input,1,1) != "@"){
      print("ERROR: "//input//" not found!!!")
    }
    else{
      print("ERROR: "//substr(input,2,strlen(input))//" not found!!!")
    }
  }

#  if (rows == 2148){
#    if (columns == 3000){
  while (fscan (inputlist, in) != EOF){
   if (direction == 1){
    imcopy (in//"[*,1:"//columns/2//"]", "temp1")
    imcopy (in//"[*,1:"//columns/2//"]", "temp2")
   }
   else{
    imcopy (in//"[1:"//rows/2.//",*]", "temp1")
    imcopy (in//"[1:"//rows/2.//",*]", "temp2")
   }
   if (substr (in, strlen(in)-4, strlen(in)) == ".fits")
     out = substr(in, 1, strlen(in)-5)//"_binned.fits"
   else out = in//"_binned"

   if (access(out))
     imdel(out,ver-)
  
#    }
#    if (columns == 4096){
#      imcopy ("bias_l_red_bx5o.fits", "temp1")
#      imcopy ("bias_l_red_bx5o.fits", "temp2")
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
   imarith ("temp3","/", 2., out)
   imdel("temp1",ver-)
   imdel("temp2",ver-)
   imdel("temp3",ver-)
  }
end
