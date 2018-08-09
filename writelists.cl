procedure writelists (images)

#################################################################
#                                                               #
# This program writes lists order_01.list, order_01_c.list and  #
#                           order_01_ct.list                    #
# Andreas Ritter, 04.12.2001                                    #
#                                                               #
#################################################################

string images               = "@fits.list"  {prompt="list of images to reduce"}
int    firstorder           = 1             {prompt="first order"}
int    lastorder            = 21            {prompt="last order"}

string *inimages

begin

  string list
  string list_c       
  string logfile            = "logfile.log"
  file infile
  string in
  int aperture

  print("****************************************************") 
  print("*                                                  *")
  print("*      Automatic data reduction for the STELLA     *")
  print("*                 ECHELLE spectra                  *")
  print("*                                                  *")
  print("*            Andreas Ritter, 07.12.2001            *")
  print("*                                                  *")
  print("****************************************************")

# --- Erzeugen von temporaeren Filenamen
  print("writelists: building temp-filenames")
#  if (loglevel > 2)
    print("writelists: building temp-filenames", >> logfile)
  infile       = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("writelists: building lists from temp-files")
  print("writelists: building lists from temp-files", >> logfile)

  if ((substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
   sections(images, option="root", > infile)
  }
  else{
   if (substr(images,1,1) != "@"){
    print("writelists: ERROR: "// images //" not found!!!")
    print("writelists: ERROR: "// images //" not found!!!", >> logfile)
    print("writelists: ERROR: "// images //" not found!!!", >> errorfile)
    print("writelists: ERROR: "// images //" not found!!!", >> warningfile)
   }
   else{
    print("writelists: ERROR: "//substr( images, 2, strlen( images ))//" not found!!!")
    print("writelists: ERROR: "//substr( images, 2, strlen( images ))//" not found!!!", >> logfile)
#    print("writelists: ERROR: "//substr( images, 2, strlen( images ))//" not found!!!", >> errorfile)
#    print("writelists: ERROR: "//substr( images, 2, strlen( images ))//" not found!!!", >> warningfile)

   }
   return
  }

  for(aperture=firstorder;aperture<=lastorder;aperture=aperture+1){
   if (aperture<10){
    list="order_0"//aperture//".list"
    list_c="order_0"//aperture//"_c.list"
   }
   else{
    list="order_"//aperture//".list"
    list_c="order_"//aperture//"_c.list"
   }

# --- delete old lists
   print("writelists: deleting old lists")
   print("writelists: deleting old lists", >> logfile)
   if ( access( list ))
     delete(files=list, ver-)
   if ( access( list_c ))
     delete(files=list_c, ver-)

# --- build new lists
   print("writelists: building new lists")
   print("writelists: building new lists", >> logfile)
   inimages = infile
   while ( fscan( inimages, in ) != EOF){
    print("writelists: in = "// in)
    if (substr (in, strlen(in)-4, strlen(in)) == ".fits")
      in = substr(in, 1, strlen(in)-5)
    if (aperture<10){
     print("writelists: "//in//"_0"//aperture)
     print(in//"_0"//aperture, >> list)
     print(in//"_0"//aperture//"_c", >> list_c)
    }
    else{
     print(in//"_"//aperture)
     print(in//"_"//aperture, >> list)
     print(in//"_"//aperture//"_c", >> list_c)
    }
   }
  }

# --- aufraeumen
  inimages = ""
  delete (infile, ver-, >& "dev$null")

end
