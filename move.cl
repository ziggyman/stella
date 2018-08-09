procedure move(inimages,outimages)
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

string inimages = "@in.list"    {prompt="list of images to change names"}
string outimages = "@out.list"  {prompt="list of outimages"}
bool   delin    = YES                    {prompt="delete infile?"}
#string flat     = "normalizedFlat.fits"  {prompt="flat field"}
#string *imagelist
#string *headerlist

#task $fits-nozero = "$foreign"

begin

#  file   infile
#  string in,out
#  file headerfile
#  int    i


# --- Erzeugen von temporaeren Filenamen
#  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
#  if ((substr(inimages,1,1) == "@" && access(substr(inimages,2,strlen(inimages)))) || (substr(inimages,1,1) != "@" && access(inimages))){
#    sections(inimages, option="root", > infile)
#    imagelist = infile
#  }
#  else{
#   if (substr(inimages,1,1) != "@"){
#    print("changenames: ERROR: "//inimages//" not found!!!")
#   }
#   else{
#    print("changenames: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
#   }
#   return
#  }
  
# --- build output filenames and divide by flat
#  while (fscan (imagelist, in) != EOF){

#    print("changenames: in = "//in)

#    out = in//".fits"

#    if (access(out)){
#     imdel(out,ver-)
#     print("changenames: old "//out//" deleted")
#    }
#    if (access(out)){
#      del(out,ver-)
#    }
#    rfits(fits_fil=in,file_lis="*",iraf_fil=out)
#    else{
#      print("changenames: ERROR: cannot access "//out)
#    }
    if (access(outimages)){
      imdel(outimages,ver-)
    }

    imcopy(inimages,outimages)

    if (delin){
      del(inimages,ver-)
    }
#    imdel(out,ver-)
#    imcopy(input=in,output=out)

#  }

# --- Aufraeumen
#  headerlist = ""
#  imagelist = ""
#  delete (infile, ver-, >& "dev$null")
#  delete (headerfile, ver-, >& "dev$null")
 
end



