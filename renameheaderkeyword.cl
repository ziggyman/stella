procedure staddheader(inimages)
#,flat)

################################################################
#                                                              #
# This program sets a new KEYWORD with the value of an old one #
#                                                              #
#                   outputs = *_botzf.fits                     #
#                                                              #
# Andreas Ritter, 07.12.01                                     #
#                                                              #
################################################################

string inimages             = "@staddheader.list"              {prompt="list of images to change names"}
string oldfieldname         = "HIERARCH ESO INS GRAT1 WLEN"  {prompt="old field name"}
string newfieldname         = "GRATING"                      {prompt="new field name"}
int    firststringnr        = 33                             {prompt="Nr. of first value string"}
string firstcharnottotake   = " "                            {prompt="first char not to take"}
bool   show                 = NO                             {prompt="show new entry?"}
bool   update               = NO                             {prompt="update image header?"}
string *imagelist
string *headerlist

begin

  file   infile, headerfile, logfile="logfile.log"
  string in, out, outdate, value
  int    i, j, firstnot, slashpos = 0

#  del(logfile)

# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  if ((substr(inimages,1,1) == "@" && access(substr(inimages,2,strlen(inimages)))) || (substr(inimages,1,1) != "@" && access(inimages))){
    sections(inimages, option="root", > infile)
    imagelist = infile
  }
  else{
   if (substr(inimages,1,1) != "@"){
    print("staddheader: ERROR: "//inimages//" not found!!!")
   }
   else{
    print("staddheader: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
   }
   return
  }
  
# --- build output filenames and divide by flat
  while (fscan (imagelist, in) != EOF){

    print("staddheader: in = "//in)

# --- write header
    for (j = 1; j < strlen(in); j=j+1){
      if (substr(in, j, j) == "/")
        slashpos = j
    }
    headerfile=substr(in, 1, slashpos)//"head"//substr(in, slashpos+1, strlen(in))//".text"
    if (access(headerfile))
      del (headerfile)
    imhead(in,l+, > headerfile)

    if (access(headerfile)){

      headerlist = headerfile

      while (fscan (headerlist, line) != EOF){

# --- read values
#HIERARCH ESO INS GRAT1 WLEN  =  568.4000000
        if (substr(line,1,strlen(oldfieldname)) == oldfieldname){
          firstnot = firststringnr + 1
          while(substr(line,firstnot, firstnot) != firstcharnottotake){
            firstnot = firstnot + 1
            #print("staddheader: firstnot = "//firstnot)
          }
          value=substr(line,firststringnr,firstnot - 1)
          if (show)
            print(newfieldname//" = "//value)
          if (update)
            hedit(images=in,fields=newfieldname,value=value,add+,ver-,show+,upd+)
        }
      }
    }

#    if (access(out)){
#     imdel(out)
#     print("staddheader: old "//out//" deleted")
#    }
#    else{
#      print("staddheader: ERROR: cannot access "//out)
#    }
 
    del(headerfile)
#    imdel(out,ver-)
#    imcopy(input=in,output=out)

  }

# --- Aufraeumen
  headerlist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")
  delete (headerfile, ver-, >& "dev$null")
 
end



