procedure addgrat(inimages)
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
string *imagelist
string *headerlist

#task $fits-nozero = "$foreign"

begin

  file   infile
  file   logfile="logfile.log"
  string in,out,outdate
  string grat1wlen,prsm1wlen
  file headerfile
  int    i

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

# --- write header
    headerfile="head"//in//".text"
#    del (headerfile)
    imhead(in,l+, > headerfile)

    if (access(headerfile)){

      headerlist = headerfile

      while (fscan (headerlist, line) != EOF){

# --- read values
#HIERARCH ESO INS GRAT1 WLEN  =  568.4000000
        if (substr(line,1,27) == "HIERARCH ESO INS GRAT1 WLEN"){
          grat1wlen=substr(line,33,37)
          print("grat1wlen = "//substr(line,33,37))
#          hedit(images=in,fields="GRAT1WLEN",value=substr(line,33,37),add+,ver-,show+,upd+)
        }
#HIERARCH ESO INS PRSM1 WLEN  =  614.4016770
        if (substr(line,1,27) == "HIERARCH ESO INS PRSM1 WLEN"){
          print("prsm1wlen = "//substr(line,33,38))
          prsm1wlen=substr(line,33,38)
#          hedit(images=in,fields="PRSM1WLEN",value=substr(line,33,38),add+,ver-,show+,upd+)
        }
      }
      if (grat1wlen == "568.4" && (prsm1wlen == "614.39" || prsm1wlen == "614.40"))
        hedit(images=in,fields="GRATING",value="614.5",add-,ver-,show+,upd-)
      else if (grat1wlen == "562.9" && (prsm1wlen == "563.67" || prsm1wlen == "614.68" || prsm1wlen == "614.66" ))
        hedit(images=in,fields="GRATING",value="562.9",add-,ver-,show+,upd-)
      else{
        print("in = "//in//" => kann GRATING nicht zuordnen")
        print(in, >> logfile)
      }
    }

#    if (access(out)){
#     imdel(out)
#     print("changenames: old "//out//" deleted")
#    }
#    else{
#      print("changenames: ERROR: cannot access "//out)
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



