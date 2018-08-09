procedure setdatefromllout(images,datefile)

################################################################
#                                                              #
#  This program sets a new KEYWORD DATE with the value of the  #
#  'ls -l > datelist' output                                   #
#                                                              #
#                   outputfile = inputfile                     #
#                                                              #
# Andreas Ritter, 20.11.05                                     #
#                                                              #
################################################################

string images               = "@tosetdate.list"              {prompt="List of images to change names"}
string datefile             = "datestoset.list"              {prompt="List of file dates"}
bool   show                 = YES                            {prompt="Show new entry?"}
bool   update               = NO                             {prompt="Update image header?"}
bool   sverifys              = YES                            {prompt="Verify updating of image header?"}
string *imagelist
string *datelist

begin

  file   infile
  string in, date, filename
  string firstcharnottotake = " "
  int    i, j, firstnot, stringnr

# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  if ((substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
    sections(images, option="root", > infile)
    imagelist = infile
  }
  else{
   if (substr(images,1,1) != "@"){
    print("setdatefromllout: ERROR: "//images//" not found!!!")
   }
   else{
    print("setdatefromllout: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
   }
   return
  }
  
# --- build output filenames and divide by flat
  while (fscan (imagelist, in) != EOF){

    print("setdatefromllout: in = "//in)

# --- read datefile
    if (access(datefile)){

      datelist = datefile

      while (fscan (datelist, line) != EOF){

# --- read dates
#-rw-r--r--  1 azuri azuri 13260800 2005-09-19 19:27 ilya-ses.tar
        firstnot = 1
        date = ""
        for (i=0;i<5;i+=1){
# --- find next space
          while(substr(line, firstnot, firstnot) != firstcharnottotake){
            firstnot = firstnot + 1
            print("setdatefromllout: firstnot1 = "//firstnot)
          }
# --- find next char behind spaces
          while(substr(line, firstnot, firstnot) == firstcharnottotake){
            firstnot = firstnot + 1
            print("setdatefromllout: firstnot2 = "//firstnot)
          }
# --- 2005-09-19
          if (i==4){
            while(substr(line, firstnot, firstnot) != firstcharnottotake){
              date=date//substr(line, firstnot, firstnot)
              firstnot = firstnot + 1
              print("setdatefromllout: firstnot3 = "//firstnot)
            }
            date = date//"T"
# --- 17:27
            while(substr(line, firstnot, firstnot) == firstcharnottotake){
              firstnot = firstnot + 1
              print("setdatefromllout: firstnot4 = "//firstnot)
            }
            while(substr(line, firstnot, firstnot) != firstcharnottotake){
              date=date//substr(line, firstnot, firstnot)
              print("setdatefromllout: firstnot5 = "//firstnot)
              firstnot = firstnot + 1
            }
# --- set seconds to zero
            date = date//":00"
# --- find filename
            while(substr(line, firstnot, firstnot) == firstcharnottotake){
              firstnot = firstnot + 1
            }
            filename = substr(line,firstnot,strlen(line))
            print("setdatefromllout: filename = "//filename)
          }
        }
        if (filename == in){
          if (show)
            print("setdatefromllout: file="//in//": DATE = "//date)
          if (update){
            print("setdatefromllout: file="//in//": setting DATE to <"//date//">")
            hedit(images=in,
		  fields="DATE",
		  value=date,
		  add+,
		  verify=sverifys,
		  show+,
		  upd+)
          }
        }
      }
    }
    else{
      print("setdatefromllout: ERROR: datefile <"//datefile//"> not found!!!")
    }
  }

# --- Aufraeumen
  datelist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")
 
end
