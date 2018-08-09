procedure stsplit(images)

# 
# 
# This program splits mosaic-echelle images.
# outputs = *_l_*.fits, *_r_*.fits
# 
# pre: changenames.cl
# => images = changenames_out
#
# Andreas Ritter, 13.11.2001
# 
#

string images                       {prompt="List of images to trim"}
string format = "[4296,2048]"       {prompt="Image format"}
string firstimage = "[1:2148,*]"    {prompt="Section of first image"}
string *imagelist

begin

  file   infile
  string in,secondimage, dumstr
  string outl, outr, dirls = "lsdir"
  int    i,k,l,row
  bool   found, found2

# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  sections(images, option="root", > infile)
  imagelist = infile

# --- calculate second image section
  found = NO
  k = 0
  while(!found){
   k += 1
   if (substr(firstimage,k,k) == ":")
    found = YES
  }
  l = k
  found2 = NO
  while(!found2){
   l += 1
   if (substr(firstimage, l, l) == ",")
    found2 = YES
  }
  dumstr = substr(firstimage, k+1, l-1)
  row = int(dumstr) + 1
  print("row = "//row)
  secondimage = "["//row//":"
  found = NO
  k = 0
  while(!found){
   k += 1
   if (substr(format,k,k) == ",")
    found = YES
  }
  secondimage = secondimage//substr(format, 2, k)//"*]"
  print("secondimage section = "//secondimage)

# --- build output filename and trim inputimages
  #print ("**************************************************")
  if (!access("red_l"))
    mkdir("red_l")
  if (!access("red_r"))
    mkdir("red_r")
  while (fscan (imagelist, in) != EOF){
    #print("in = "//in)
    i = strlen(in)
    found = NO
    k = 0
    while (!found && k < strlen(in)){
      k += 1
      if (substr(in,k,k) == "r"){
        found = YES
        outl = "red_l/"//substr(in, 1, k)//"l"//substr(in,k+1,strlen(in))
        outr = "red_r/"//substr(in, 1, k)//"r"//substr(in,k+1,strlen(in))
#        outl = "thar_red_l_"//in
#        outr = "thar_red_r_"//in
      }
    }
    if (!found){
    k = 0
      while (!found){
        k += 1
        if (substr(in,k,k) == "_"){
          found = YES
          outl = "red_l/"//substr(in, 1, k)//"l_"//substr(in,k+1,strlen(in))
          outr = "red_r/"//substr(in, 1, k)//"r_"//substr(in,k+1,strlen(in))
#          outl = "thar_red_l_"//in
#          outr = "thar_red_r_"//in
        }
      }
      
    }

    if (access(outl)){
     del(outl, ver-)
     print(outl//" deleted")
    }
    if (access(outr)){
     del(outr, ver-)
     print(outr//" deleted")
    }
    
    print("processing "//in)
    print("outl = "//outl)
    print("outr = "//outr)
    imcopy(in//firstimage,outl,ver-)
    imcopy(in//secondimage,outr,ver-)
  }

# --- Aufraeumen
  delete (infile, ver-)

end



