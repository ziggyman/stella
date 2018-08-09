procedure ratorahms(inimages)
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

string inimages             = "@ratorahms.list"              {prompt="list of images to change names"}
string oldfieldname         = "RA "                          {prompt="old field name"}
string newfieldname         = "RA_HMS"                       {prompt="new field name"}
int    firststringnr        = 17                             {prompt="Nr. of first value string"}
string firstcharnottotake   = " "                            {prompt="first char not to take"}
bool   show                 = NO                             {prompt="show new entry?"}
bool   update               = NO                             {prompt="update image header?"}
string *imagelist
string *headerlist

begin

  file   infile, headerfile, logfile="logfile_ratorahms.log"
  string in, out, outdate, value
  int    i, j, firstnot
#, valueint
  int    slashpos = 0
  int    hour = 0
  int    minute = 0
  real   second = 0.
  real   valuereal

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)

# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  if ((substr(inimages,1,1) == "@" && access(substr(inimages,2,strlen(inimages)))) || (substr(inimages,1,1) != "@" && access(inimages))){
    sections(inimages, option="root", > infile)
    imagelist = infile
  }
  else{
   if (substr(inimages,1,1) != "@"){
    print("ratorahms: ERROR: "//inimages//" not found!!!")
   }
   else{
    print("ratorahms: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
   }

# --- clean up
   headerlist = ""
   imagelist = ""
   delete (infile, ver-, >& "dev$null")
   delete (headerfile, ver-, >& "dev$null")
   return
  }
  
# --- build output filenames and divide by flat
  while (fscan (imagelist, in) != EOF){

    print("ratorahms: in = "//in)

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
#RA      =       202.6692478349  / Right ascention at start (13h:30m:40.62s)
        if (substr(line,1,strlen(oldfieldname)) == oldfieldname){
          firstnot = firststringnr
          while(substr(line,firstnot, firstnot) == " " || substr(line,firstnot, firstnot) == "'"){
            firstnot = firstnot + 1
            #print("ratorahms: firstnot = "//firstnot)
          }
          print("ratorahms: line = "//line)
          firstnot = firstnot + 1
          while(substr(line,firstnot, firstnot) != firstcharnottotake){
            firstnot = firstnot + 1
            #print("ratorahms: firstnot = "//firstnot)
          }
          value=substr(line,firststringnr,firstnot - 1)
# --- convert to hms
#          valueint = int(value)
          valuereal = real(value)
          #if (show)
          #  print("ratorahms: value = "//value//", valuereal = "//valuereal)
          hour = int(valuereal / 15.)
          valuereal = valuereal - (hour * 15.)
          #if (show)
          #  print("ratorahms: value = "//value//", valuereal = "//valuereal)
          minute = int(valuereal) * 4
          valuereal = valuereal - (minute /4.)
          #if (show)
          #  print("ratorahms: value = "//value//", valuereal = "//valuereal)
          second = valuereal * 60.
          second = int(second * 100.) / 100.
          if (show)
            print("ratorahms: RA_HMS = "//hour//":"//minute//":"//second)
          if (update){
            hedit(images=in,
                  fields=newfieldname,
                  add-,
                  addonl-,
                  del+,
                  show=show,
                  upda+)
            hedit(images=in,
                  fields=newfieldname,
                  value=hour//":"//minute//":"//second,
                  add+,
                  addonl+,
                  del-,
                  ver-,
                  show=show,
                  upd+)
            hedit(images=in,
                  fields=newfieldname,
                  value=hour//":"//minute//":"//second,
                  add+,
                  addonl+,
                  del-,
                  ver-,
                  show=show,
                  upd+)
          }
        }
      }
    }

#    if (access(out)){
#     imdel(out)
#     print("ratorahms: old "//out//" deleted")
#    }
#    else{
#      print("ratorahms: ERROR: cannot access "//out)
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



