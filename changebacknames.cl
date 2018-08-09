procedure changebacknames(inimages)
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
    del (headerfile)
    imhead(in,l+, > headerfile)

    if (access(headerfile)){

      headerlist = headerfile

      out = "Cal_Back"
      outdate = ""
      print("out = "//out)     

      while (fscan (headerlist, line) != EOF){

# --- read values
#OBJECT  = 'hd124740'
        if (substr(line,1,6) == "OBJECT"){ 
          i=16
          if (substr(line,16,19) == "WAVE")
            out=out//"ThAr"
          else{
            while(substr(line,i,i) != "'"){
              out=out//substr(line,i,i)
              i=i+1
            }
          }
          #out=out//"_CES"//outdate      
          print("out = "//out)
        }
#DATE-OBS= '2002-01-25T09:25:45.243'
        if (substr(line,1,8)=="DATE-OBS"){
          out=out//"_CES"//substr(line,12,34)//"_"
        }
#HIERARCH ESO INS GRAT1 WLEN  =  568.4000000
        else if (substr(line,1,27) == "HIERARCH ESO INS GRAT1 WLEN"){
          if (substr(line,33,37) == "568.4")
            out = out//"6145_"
          else
            out = out//substr(line,33,35)//substr(line,37,37)//"_"
          print("out = "//out)          
        }
#HIERARCH ESO DET WIN1 UIT1   =    60.000000
        else if (substr(line,1,26) == "HIERARCH ESO DET WIN1 UIT1"){
          if (substr(line,34,34) == " ")
            out = out//substr(line,35,36)//"s.fits"
          else
            out = out//substr(line,34,36)//"s.fits"
          print("out = "//out)          
        }
      }
    }

#    if (access(out)){
#     imdel(out)
#     print("changenames: old "//out//" deleted")
#    }
#    else{
#      print("changenames: ERROR: cannot access "//out)
#    }

    imcopy(input=in,output=out)

  }

# --- Aufraeumen
  headerlist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")

end



