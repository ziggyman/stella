procedure movenoim(inimages)

############################################################
#                                                          #
# This program convertes FITS-files to fits-files          #
#                                                          #
#                 outputs = in.fits                        #
#                                                          #
# Andreas Ritter, 26.01.03                                 #
#                                                          #
############################################################

string inimages = "@in.list"             {prompt="list of images to change names"}
bool   delin    = NO                     {prompt="delete infile?"}
string *imagelist

begin

  file   infile
  string in,out
  int    i


# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  if ((substr(inimages,1,1) == "@" && access(substr(inimages,2,strlen(inimages)))) || (substr(inimages,1,1) != "@" && access(inimages))){
    sections(inimages, option="root", > infile)
    imagelist = infile
  }
  else{
   if (substr(inimages,1,1) != "@"){
    print("movenoim: ERROR: "//inimages//" not found!!!")
   }
   else{
    print("movenoim: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
   }
   return
  }
  
# --- build output filenames and divide by flat
  while (fscan (imagelist, in) != EOF){

    print("movenoim: infile  = "//in)

    out = ""

    for (i=1;i<=strlen(in);i=i+1){
      if (substr(in,i,i)==":"){
       out = out//"-" 
      }
      else{
       out = out//substr(in,i,i)
      }
#      print("movenoim: substr("//in//","//i//","//i//") = "//substr(in,i,i))
    }

    print("movenoim: outfile = "//out)

    if (access(out)){
     del(out,ver-)
     print("movenoim: old "//out//" deleted")
    }

    copy(in,out)

    if (delin){
      del(in,ver-)
    }
#    imdel(out,ver-)
#    imcopy(input=in,output=out)

  }

# --- Aufraeumen
#  headerlist = ""
  imagelist = ""
#  delete (infile, ver-, >& "dev$null")
#  delete (headerfile, ver-, >& "dev$null")
 
end



