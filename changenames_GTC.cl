procedure changenames_GTC(inimages)
#,flat)

################################################################
#                                                              #
# This program renames the input files according to their type #
#                                                              #
#                 outputs = TYPE_DATETIME.fits                 #
#                                                              #
# Andreas Ritter, 07.26.18                                     #
#                                                              #
################################################################

string inimages = "@changenames.list"    {prompt="list of images to change names"}
string *imagelist
string *headerlist

#task $fits-nozero = "$foreign"

begin

  file   infile,headerfile
  string in,out,outdate,tmpstr,path
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
    print("changenames: ERROR: "//inimages//" not found!!!")
   }
   else{
    print("changenames: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
   }
   return
  }

# --- build output filenames
  while (fscan (imagelist, in) != EOF){

    print("changenames: in = "//in)

    path=""
    out=""
    for (i,1,strlen(in)){
        if (substr(in,i,i)=="/"){
            path=path//out//"/"
            out=""
        }
        else{
            out=out//substr(in,i,i)
        }
    }
    print("path = "//path)

# --- write header

    headerfile="head"//in//".text"
    del (headerfile)
    imhead(in,l+, > headerfile)

    if (access(headerfile)){

      headerlist = headerfile

      out = path
      outdate = ""

      while (fscan (headerlist, line) != EOF){

# --- read values
#OBJECT  = 'hd124740'
        if (substr(line,1,6) == "OBJECT"){
          i=14
          tmpstr = ""
          while(substr(line,i,i) != "'"){
            tmpstr=tmpstr//substr(line,i,i)
            i=i+1
          }
          if (tmpstr=="SpectralFlat"){
            out = out//"FLAT"
          }
          else if (substr(tmpstr,1,7) == "ArcLamp"){
            out = out//"ARC"
          }
          else{
            out = out//tmpstr//"_"
          }
          print("out = "//out)
        }
#DATE-OBS= '2002-01-25T09:25:45.243'
        if (substr(line,1,8)=="DATE-OBS"){
          outdate=substr(line,12,34)//"_"
          i=1
          while(substr(outdate,i,i)!="_"){
            if (substr(outdate,i,i)==":"){
              out = out//"-"
            }
            else{
              out = out//substr(outdate,i,i)
            }
          }
          print("out = "//out)
        }
      }
    }
    out=out//".fits"
    print("out = "//out)

#    if (access(out)){
#     imdel(out)
#     print("changenames: old "//out//" deleted")
#    }
#    else{
#      print("changenames: ERROR: cannot access "//out)
#    }

    del(headerfile)
    imdel(out,ver-)
    imcopy(input=in,output=out)

  }

# --- Aufraeumen
  headerlist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")
  delete (headerfile, ver-, >& "dev$null")

end



