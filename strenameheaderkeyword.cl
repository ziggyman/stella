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
int    loglevel             = 3                             {prompt="Level for writing logfiles"}
string logfile              = "logfile_staddheader.log"       {prompt="Name of log file"}
string warningfile          = "warnings_staddheader.log"      {prompt="Name of warning file"}
string errorfile            = "errors_staddheader.log"        {prompt="Name of error file"}
string *imagelist
string *headerlist

begin

  file   infile, headerfile
  string in, out, outdate, value, listname
  int    i, j, firstnot, slashpos = 0

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)
  if (access(warningfile))
    delete(warningfile, ver-)
  if (access(errorfile))
    delete(errorfile, ver-)

# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  if (substr(inimages,1,1) == "@")
    listname = substr(inimages,2,strlen(inimages))
  else
    listname = inimages
  if (access(listname)){
    sections(inimages, option="root", > infile)
    imagelist = infile
  }
  else{
    print("staddheader: ERROR: inimages <"//listname//"> not found!!!")
    print("staddheader: ERROR: inimages <"//listname//"> not found!!!", >> logfile)
    print("staddheader: ERROR: inimages <"//listname//"> not found!!!", >> warningfile)
    print("staddheader: ERROR: inimages <"//listname//"> not found!!!", >> errorfile)

# --- clean up
    headerlist = ""
    imagelist = ""
    delete (infile, ver-, >& "dev$null")
    delete (headerfile, ver-, >& "dev$null")
    return
  }
  
# --- build output filenames and divide by flat
  while (fscan (imagelist, in) != EOF){

    print("staddheader: in = "//in)
    print("staddheader: in = "//in, >> logfile)

# --- write header
    strpos(in, "/")
    slashpos = strpos.pos
#    for (j = 1; j < strlen(in); j=j+1){
#      if (substr(in, j, j) == "/")
#        slashpos = j
#    }
    headerfile=substr(in, 1, slashpos)//"head"//substr(in, slashpos+1, strlen(in))//".text"
    if (access(headerfile))
      del (headerfile)
    imhead(in,l+, > headerfile)

    if (access(headerfile)){

      headerlist = headerfile

      while (fscan (headerlist, line) != EOF){

# --- read values
#HIERARCH ESO INS GRAT1 WLEN  =  568.4000000
        if (substr(line,1,strlen(oldfieldname)) == oldfieldname && (substr(line,strlen(oldfieldname)+1,strlen(oldfieldname)+1) == " " || substr(line,strlen(oldfieldname)+1,strlen(oldfieldname)+1) == "=")){
          while(substr(line,firststringnr, firststringnr) == " " || substr(line,firststringnr, firststringnr) == "'"){
            firststringnr = firststringnr + 1
            print("staddheader: firststringnr = "//firststringnr)
            if (loglevel > 2)
              print("staddheader: firststringnr = "//firststringnr, >> logfile)
          }
          print("staddheader: line = "//line)
          if (loglevel > 2)
            print("staddheader: line = "//line, >> logfile)
          firstnot = firststringnr + 1
          while(substr(line,firstnot, firstnot) != firstcharnottotake){
            firstnot += 1
            print("staddheader: firstnot = "//firstnot)
            if (loglevel > 2)
              print("staddheader: firstnot = "//firstnot, >> logfile)
          }
          value=substr(line,firststringnr,firstnot - 1)
          if (show)
            print("staddheader: newfieldname = "//newfieldname//", value = "//value)
          if (loglevel > 2)
            print("staddheader: newfieldname = "//newfieldname//", value = "//value, >> logfile)
          if (update){
            if (loglevel > 2)
              print("staddheader: updating "//in, >> logfile)
            hedit(images=in,
                  fields=newfieldname,
                  value=value,
                  add+,
                  ver-,
                  show+,
                  upd+)
          }
          else{
            if (loglevel > 2)
              print("staddheader: not updating "//in, >> logfile)
          }
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



