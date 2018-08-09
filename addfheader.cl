procedure addfheader(inimages)
#,flat)

############################################################
#                                                          #
# This program divides the inimages by normalizedFlat.fits #
#                                                          #
#                 outputs = *_botzf.fits                   #
#                                                          #
# Andreas Ritter, 07.12.01                                 #
#                                                          #
############################################################

string inimages = "@changenames.list"    {prompt="list of images to change names"}
#string flat     = "normalizedFlat.fits"  {prompt="flat field"}
string oldkey                            {prompt="old Keyword"}
string newkey                            {prompt="new Keyword"}
string *imagelist
string *headerlist

#task $fits-nozero = "$foreign"

begin

  file   infile
  file   logfile="logfile.log"
  string logfile             = "logfile.log"
  string errorfile           = "errors.log"
  string warningfile         = "warnings.log"
  string value
  string in,out
  file headerfile
  int    i
  bool   printit,breakit

  del(logfile)

# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  if ((substr(inimages,1,1) == "@" && access(substr(inimages,2,strlen(inimages)))) || (substr(inimages,1,1) != "@" && access(inimages))){
    sections(inimages, option="root", > infile)
    imagelist = infile
  }
  else{
   if (substr(inimages,1,1) != "@"){
    print("addfheader: ERROR: "//inimages//" not found!!!")
    print("addfheader: ERROR: "//inimages//" not found!!!", >> logfile)
    print("addfheader: ERROR: "//inimages//" not found!!!", >> warningfile)
    print("addfheader: ERROR: "//inimages//" not found!!!", >> errorfile)
   }
   else{
    print("addfheader: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
   }
   return
  }
  
# --- build output filenames and divide by flat
  while (fscan (imagelist, in) != EOF){

    print("addfheader: in = "//in)
    print("addfheader: in = "//in, >> logfile)

# --- write header
    headerfile="head"//in//".text"
    if (access(headerfile)){
      del (headerfile)
    }
    imhead(in,l+, > headerfile)

    if (access(headerfile)){

      headerlist = headerfile

      while (fscan (headerlist, line) != EOF){
        value = ""
# --- read values
#HIERARCH ESO INS GRAT1 WLEN  =  568.4000000
        if (substr(line,1,strlen(oldkey)) == oldkey){
          i=8
          breakit = NO
          while(!breakit){
            i = i+1
            if (substr(line,i,i+1) == "= "){
              i = i+1
              while(substr(line,i+1,i+3) != " / "){
                if (substr(line,i,i) != " " && substr(line,i,i) != "'"){
                  value=value//substr(line,i,i)
                  print("value = "//value)
                }
                i=i+1
              }
              breakit = YES
            }
          }

          print("value = "//value)
          hedit(images=in,fields=newkey,value=value,add+,ver-,show+,upd+)
          if (newkey == "rdtime"){
            if (value == "195.96"){
              hedit(images=in,fields="rdnoise",value="3.8",add+,ver-,show+,upd+)
              hedit(images=in,fields="gain",value="1.11",add+,ver-,show+,upd+)
            }
            else if (value == "161.85" || value == "161.86" || value == "161.87"){
              hedit(images=in,fields="rdnoise",value="5.1",add+,ver-,show+,upd+)
              hedit(images=in,fields="gain",value="2.17",add+,ver-,show+,upd+)
            }
          }
        }
      }
      del(headerfile)
    }
  }

# --- Aufraeumen
  headerlist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")
  delete (headerfile, ver-, >& "dev$null")
 
end
