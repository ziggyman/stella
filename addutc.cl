procedure addutc(inimages)
#,flat)

################################################################
#                                                              #
# This program sets a new IMAGE-HEADER KEYWORD <UTCFIELDNAME>. #
#      calculated from <UTSTARTFIELDNAME> and <EXPTIME>        #
#                                                              #
#                       outputs = input                        #
#                                                              #
# Andreas Ritter, 26.10.05                                     #
#                                                              #
################################################################

string inimages                    = "@addutc.list"   {prompt="list of images to set utc"}
string utstartfieldname            = "UTSTART"             {prompt="Field name of UTSTART"}
int    utstartfirststringnr        = 23                    {prompt="Nr. of first value character for UTSTART"}
string utstartfirstcharnottotake   = " "                   {prompt="First character not to take for UTSTART"}
string exptimefieldname            = "EXPTIME"             {prompt="Field name for EXPTIME"}
int    exptimefirststringnr        = 20                    {prompt="Nr. of first value character for EXPTIME"}
string exptimefirstcharnottotake   = " "                   {prompt="First character not to take for EXPTIME"}
string utcfieldname                = "UTC"                 {prompt="Field name for UTC"}
bool   show                        = YES                   {prompt="show new entry?"}
bool   update                      = YES                   {prompt="update image header?"}
string *imagelist
string *headerlist

begin

  file   infile, headerfile, logfile="logfile_addutc.log"
  string in, out, outdate, value
  int    i, j, firstnot, hour, min, firststringnr, intsec
  int    slashpos = 0
  real   exptime, sec

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
    print("addutc: ERROR: "//inimages//" not found!!!")
   }
   else{
    print("addutc: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
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

    print("addutc: in = "//in)

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
#UTSTART =             19:24:45
        if (substr(line,1,strlen(utstartfieldname)) == utstartfieldname){
          firststringnr = utstartfirststringnr
          print("addutc: firststringnr = "//firststringnr)
          while(substr(line,firststringnr, firststringnr) == " "){
            firststringnr = firststringnr + 1
            print("addutc: UTSTART: firststringnr = "//firststringnr)
          }
          print("addutc: UTSTART: firststringnr = "//firststringnr)
          firstnot = firststringnr + 1
          if (strlen(line) >= firstnot){
            while((substr(line,firstnot, firstnot) != utstartfirstcharnottotake) && (strlen(line) > firstnot)){
              firstnot = firstnot + 1
              print("addutc: UTSTART: firstnot = "//firstnot)
            }
          }
          value=substr(line,firststringnr,firstnot - 1)

# --- read UTSTART
          hour = int(substr(value,1,2))
          min  = int(substr(value,4,5))
          sec  = real(substr(value,7,8))
          print("addutc: hour = "//hour//", min = "//min//", sec = "//sec)
          print("addutc: hour = "//hour//", min = "//min//", sec = "//sec, >> logfile)
        }
#EXPTIME =               45.000  /
        if (substr(line,1,strlen(exptimefieldname)) == exptimefieldname){
          firststringnr = exptimefirststringnr
          print("addutc: firststringnr = "//firststringnr)
          while(substr(line,firststringnr, firststringnr) == " "){
            firststringnr = firststringnr + 1
            print("addutc: firststringnr = "//firststringnr)
          }
          print("addutc: firststringnr = "//firststringnr)
          firstnot = firststringnr + 1
          if (strlen(line) >= firstnot){
            while((substr(line,firstnot, firstnot) != exptimefirstcharnottotake) && (strlen(line) >= firstnot)){
              firstnot = firstnot + 1
              print("addutc: EXPTIME: firstnot = "//firstnot)
            }
          }
          value=substr(line,firststringnr,firstnot - 1)

# --- read EXPTIME
          print("addutc: line = "//line)
          print("addutc: value = "//value)
          exptime = real(value)
          print("addutc: exptime = "//exptime)
          print("addutc: exptime = "//exptime, >> logfile)
        }
      }
    }

# --- calc UTC
    sec = sec + exptime
    while(sec > 59){
      min = min + 1
      sec = sec - 60
    }
    while(min > 59){
      hour = hour + 1
      min = min - 60
    }
    while(hour > 23){
      hour = hour - 24
    }
    intsec = sec
    print("addutc: sec = "//sec//", intsec = "//intsec
# --- hour
    if (hour < 10)
      value = "0"//hour//":"
    else
      value = hour//":"
# --- min
    if (min < 10)
      value = value//"0"
    value = value//min//":"
# --- sec
    if (intsec < 10)
      value = value//"0"
    value = value//intsec
    if (show)
      print(utcfieldname//" = "//value)
    if (update)
      hedit(images=in,fields=utcfieldname,value=value,add+,ver-,show+,upd+)

    del(headerfile)

  }

# --- Aufraeumen
  headerlist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")
  delete (headerfile, ver-, >& "dev$null")
 
end



