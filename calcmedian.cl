procedure calcmedian(filename_in)

  string filename_in      = "to_rotate.fits" {prompt="Input image"}
  int[]  area             = [1,10,1,10] {prompt="[xmin,xmax,ymin,ymax]"}

  real   median
  string *InputList

  begin
  string fname="calcmedian.out"
  string tempstr
#  file InFile
#  InFile  = mktemp ("tmp")

    writemedian(filename_in,"AREA="//area)
#    sections(fname, option="root", > InFile)
    InputList = fname
  fscan(InputList,tempstr)
  median=real(tempstr)

  delete (InFile, ver-, >& "dev$null")
  InputList      = ""

end
