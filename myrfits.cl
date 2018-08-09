procedure myrfits(inimages)
#,flat)

############################################################
#                                                          #
# This program convertes FITS-files to fits-files          #
#                                                          #
#                 outputs = in.fits                        #
#                                                          #
# Andreas Ritter, 26.01.03                                 #
#                                                          #
############################################################

string inimages = "@changenames.list"    {prompt="list of images to change names"}
bool   delin    = YES                    {prompt="delete infile after conversion?"}
bool   changenames = YES                 {prompt="Change names of images?"}
bool   doit     = NO                     {prompt="Do everything for real?"}
#string flat     = "normalizedFlat.fits"  {prompt="flat field"}
string *imagelist
#string *headerlist

#task $fits-nozero = "$foreign"

begin

  file   infile
  string in,out,outdate
  file outlist = "tempout.list"
  int    i
  task changenames_NOT=scripts$changenames_NOT.cl

# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

  if (access(outlist))
    del(outlist,ver-)

# --- Umwandeln der Listen von Frames in temporaere Files
  if ((substr(inimages,1,1) == "@" && access(substr(inimages,2,strlen(inimages)))) || (substr(inimages,1,1) != "@" && access(inimages))){
    sections(inimages, option="root", > infile)
    imagelist = infile
  }
  else{
   if (substr(inimages,1,1) != "@"){
    print("changenames: ERROR: "//inimages//" not found!!!")
   }
   else{
    print("changenames: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
   }
   return
  }
  
# --- build output filenames and divide by flat
  while (fscan (imagelist, in) != EOF){

    print("changenames: in = "//in)

    out = in//".fits"

    if (access(out) && doit){
     imdel(out,ver-)
     print("changenames: old "//out//" deleted")
    }
    if (access(out) && doit){
      del(out,ver-)
    }
    if (doit)
       rfits(fits_fil=in,file_lis="*",iraf_fil=out)
#    else{
#      print("changenames: ERROR: cannot access "//out)
#    }
 
    if (delin && doit){
      del(in,ver-)
    }
    print(out, >> outlist)
#    imdel(out,ver-)
#    imcopy(input=in,output=out)

  }
  if (changenames && doit){
    changenames_NOT("@"//outimages,delin=delin)
  }

# --- Aufraeumen
#  headerlist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")
#  delete (headerfile, ver-, >& "dev$null")
 
end



