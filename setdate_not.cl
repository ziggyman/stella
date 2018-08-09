procedure setdate_not(inimages)
#,flat)

################################################################
#                                                              #
#     This program sets a new IMAGE-HEADER KEYWORD <DATE>,     #
#               calculated from <DAY> and <UTC>                #
#                                                              #
#                       outputs = input                        #
#                                                              #
# Andreas Ritter, 26.01.06                                     #
#                                                              #
################################################################

string inimages                    = "@setdate_not.list"   {prompt="List of images to set DATE"}
string utcfieldname                = "UTC"                 {prompt="Field name of UTC"}
int    utcfirststringnr        = 23                    {prompt="Nr. of first value character for UTSTART"}
string utcfirstcharnottotake   = " "                   {prompt="First character not to take for UTSTART"}
string day                         = "1999-02-06"          {prompt="Date of day when exposure was taken"}
bool   show                        = YES                   {prompt="Show new entry?"}
bool   update                      = YES                   {prompt="Update image header?"}
string *imagelist
string *headerlist

begin

  file   infile, headerfile, logfile="logfile_setdate_not.log"
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
    print("setdate_not: ERROR: "//inimages//" not found!!!")
   }
   else{
    print("setdate_not: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
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

    print("setdate_not: in = "//in)

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
#UTC     =             03:24:44
        if (substr(line,1,strlen(utcfieldname)) == utcfieldname){
          firststringnr = utcfirststringnr
          print("setdate_not: firststringnr = "//firststringnr)
          while(substr(line,firststringnr, firststringnr) == " "){
            firststringnr = firststringnr + 1
            print("setdate_not: UTSTART: firststringnr = "//firststringnr)
          }
          print("setdate_not: UTSTART: firststringnr = "//firststringnr)
          firstnot = firststringnr + 1
          if (strlen(line) >= firstnot){
            while((substr(line,firstnot, firstnot) != utcfirstcharnottotake) && (strlen(line) > firstnot)){
              firstnot = firstnot + 1
              print("setdate_not: UTC: firstnot = "//firstnot)
            }
          }
          value=substr(line,firststringnr,firstnot - 1)

# --- read UTSTART
          hour = int(substr(value,1,2))
          min  = int(substr(value,4,5))
          sec  = real(substr(value,7,8))
          print("setdate_not: hour = "//hour//", min = "//min//", sec = "//sec)
          print("setdate_not: hour = "//hour//", min = "//min//", sec = "//sec, >> logfile)
        }
      }
    }

# --- calc UTC
    intsec = sec
    print("setdate_not: sec = "//sec//", intsec = "//intsec
# --- hour
    value = day//"T"
    if (hour < 10)
      value = value//"0"
    value = value//hour//":"
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
      hedit(images=in,
	    fields="DATE",
	    value=value,
	    add+,
	    ver-,
	    show = show,
	    upd = update)

    del(headerfile)

  }

# --- Aufraeumen
  headerlist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")
  delete (headerfile, ver-, >& "dev$null")
 
end



