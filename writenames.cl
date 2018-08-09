procedure writenames(inimages)
#,flat)

############################################################
#                                                          #
#   This program copies the infiles to files with useable  #
#                                                          #
#                          names                           #
#                                                          #
# Andreas Ritter, 24.12.02                                 #
#                                                          #
############################################################

string inimages = "@writenames.list"    {prompt="list of images to change names"}
string *imagelist
string *headerlist

#task $fits-nozero = "$foreign"

begin

  file   infile
  string in,out,outdate
  file headerfile
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
    print("writenames: ERROR: "//inimages//" not found!!!")
   }
   else{
    print("writenames: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
   }
   return
  }
  
# --- build output filenames
  while (fscan (imagelist, in) != EOF){

    print("writenames: in = "//in)

# --- write header
    headerfile="head"//in//".text"
    if (access(headerfile)){
      del (headerfile)
      print("writenames: old headerfile "//headerfile//" deleted.")
    }

    imhead(in,l+, > headerfile)

    if (access(headerfile)){

      headerlist = headerfile

      out = ""
      outdate = ""

      while (fscan (headerlist, line) != EOF){

# --- read values
        if (substr(line,1,6) == "OBJECT"){ 
          i=12
          while(substr(line,i,i) != "'" && substr(line,i,i) != " "){
            out=out//substr(line,i,i)
            i=i+1
          }
        }
#DATE-OBS= '2002-01-25T09:25:45.243'
        if (substr(line,1,8)=="DATE    "){
          outdate=substr(line,12,30)
        }
      }
    }
    else{
      print("writenames: ERROR: cannot access headerfile for "//in)
#      print("writenames: ERROR: cannot access headerfile for "//in, >> logfile)
#      print("writenames: ERROR: cannot access headerfile for "//in, >> warningfile)
#      print("writenames: ERROR: cannot access headerfile for "//in, >> errorfile)
#      return
    }

    out=out//"_"//outdate//".fits"      
    print("writenames: out = "//out)

    if (access(out)){
      imdel(out)
      print("writenames: old "//out//" deleted")
    }
 
    del(headerfile)
    if (access(out)){
      del(out,ver-)
      print("writenames: old "//out//" deleted")
    }
    imcopy(input=in,output=out)

  }

# --- Aufraeumen
  headerlist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")
  delete (headerfile, ver-, >& "dev$null")
 
end



