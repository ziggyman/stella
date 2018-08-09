procedure stbadpix (images)

# 
# 
# This program replaces bad pixels of the STELLA echelle images.
# outputs = *_b.fits
# 
# Andreas Ritter, 13.11.2001
# 
#

string images    {prompt="list of images to replace bad pixels"}
string *imagelist

begin

  file   infile
  string in
  string out
  int    i

# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  sections(images, option="root", > infile)
  imagelist = infile

# --- build output filenames and replace bad pixels
  print ("**************************************************")
  while (fscan (imagelist, in) != EOF){
    print("in = "//in)
    i = strlen(in)
    if (substr (in, i-4, i) == ".fits")
      out = substr(in, 1, i-5)//"_b.fits"
    else out = in//"_b"

    if (access(out)){
     imdel(out)
     print(out//" deleted")
    }
    
    print("processing "//in//", outfile = "//out)
    ccdproc(images=in,output=out,noproc-,fixpix+,overscan-,trim-,zerocor-,darkcor-,flatcor-,illumco-,fringec-,readcor-,scancor-,readaxis="line",fixfile="fixpix_red_l_2148x2048.mask",minrepl=0.,scantyp="shortscan",nscan=1)
  }

# --- Aufraeumen
  delete (infile, ver-, >& "dev$null")

end



