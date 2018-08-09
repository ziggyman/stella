procedure changenames_RAVE(inimages)
#,flat)

############################################################
#                                                          #
# This program changes the imagenames to more usefull ones #
#                                                          #
#     outputs = type_target_date_wlen_exptime.fits         #
#                                                          #
# Andreas Ritter, 28.02.03                                 #
#                                                          #
############################################################

string inimages     = "@changenames.list"    {prompt="list of images to change names"}
string *imagelist
string *tempoutlist
string *headerlist

begin

  file   infile,tempfile,headerfile,changefile,outfile
  string in,out,type,name,date,exptime,tmpstr,tempout,object,str_exptime
  string str_pow
  int    i,i_pow

  in         = ""
  out        = ""
  tempout    = ""
  type       = ""
  name       = ""
  object     = ""
  date       = ""
  str_exptime    = ""
  tmpstr     = ""
  changefile = "name-changes.list"
  outfile    = "outfiles.list"

  if (access(changefile))
    delete(changefile,ver-, >& "dev$null")
  if (access(outfile))
    delete(outfile)

# --- Erzeugen von temporaeren Filenamen
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  if ((substr(inimages,1,1) == "@" && access(substr(inimages,2,strlen(inimages)))) || (substr(inimages,1,1) != "@" && access(inimages))){
    sections(inimages, option="root", > infile)
    imagelist = infile
  }
  else{
   if (substr(inimages,1,1) != "@"){
    print("changenames_UVES: ERROR: "//inimages//" not found!!!")
   }
   else{
    print("changenames_UVES: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
   }
   return
  }

# --- build output filenames
  while (fscan (imagelist, in) != EOF){

    print("changenames_UVES: in = "//in)

# --- write header
    headerfile="head.text"
    if (access(headerfile))
      del (headerfile)
    imhead(in,l+, > headerfile)

    if (access(headerfile)){

      headerlist = headerfile

      while (fscan (headerlist, line) != EOF){

#        print("line read = "//line)
# --- RUNCMD  = 'arc'                / Observation type
        if (substr(line,1,6) == "RUNCMD"){
          strpos(line, "'")
          i=strpos.pos+1
          type = ""
          while((substr(line,i,i) != "'") && (substr(line,i,i) != " ")){
            if  (substr(line,i,i) == ','){
              type = type//"-"
            }
            else{
              type = type//substr(line,i,i)
            }
            i = i+1
          }
          if (type != "")
            type=type//"_"
          print("type = "//type)
        }

#OBJECT  = 'J2_0949m005p1.sds'  / Observation title
        if (substr(line,1,6) == "OBJECT"){
          strpos(line, "'")
          i = strpos.pos + 1
          object = ""
          while((substr(line,i,i) != "'") && (substr(line,i,i) != ".")){
            if  (substr(line,i,i) == ','){
              object = object//"-"
            }
            else if (substr(line,i,i) != " "){
              object = object//substr(line,i,i)
            }
            i = i+1
          }
          if (object != "")
            object = object//"_"
          print("object = "//object)
        }


#EXPOSED =         1.000700E+01 / Exposure time (sec)
        if (substr(line,1,7) == "EXPOSED"){
          strpos(line, "=")
          i = strpos.pos + 1
          str_exptime = ""
          while(substr(line,i,i) != "/"){
            if (substr(line,i,i) != " ")
              str_exptime = str_exptime//substr(line,i,i)
            i = i+1
          }
          str_exptime = str_exptime//"s"
          print("str_exptime = "//str_exptime)
          strtrim(str_exptime,2)
          str_exptime = strtrim.out
          exptime = substr(str_exptime,1,1)
          strpos(str_exptime,"E")
          str_pow = substr(str_exptime,strpos.pos+3,strpos.pos+3)
          if (str_pow == "0")
            i_pow = 0
          else if (str_pow == "1")
            i_pow = 1
          else if (str_pow == "2")
            i_pow = 2
          else if (str_pow == "3")
            i_pow = 3
          else if (str_pow == "4")
            i_pow = 4
          else if (str_pow == "5")
            i_pow = 5
          else if (str_pow == "6")
            i_pow = 6
          else if (str_pow == "7")
            i_pow = 7
          else if (str_pow == "8")
            i_pow = 8
          else if (str_pow == "9")
            i_pow = 9
          for (i=1; i<=i_pow; i=i+1){
            if (i < 6)
              exptime = exptime//substr(str_exptime,i+2,i+2)
            else
              exptime = exptime//"0"
          }
          exptime = exptime//"s"
        }

#DATE-OBS= '2006-04-07T16:35:12.682'     / Date of observation
        else if (substr(line,1,8)=="DATE-OBS"){
          strpos(line, "'")
          i = strpos.pos + 1
          date = ""
          while((substr(line,i,i) != "'") && (substr(line,i,i) != " ")){
            if (substr(line,i,i) == ":"){
              date = date//"-"
            }
            else{
              date = date//substr(line,i,i)
            }
            i = i+1
          }
          date = date//"_"
        }
      }
# give output a name
      out = type//object//date//exptime//".fits"

#destroy old parts of outname
      type    = ""
      name    = ""
      date    = ""
      str_exptime = ""
      tmpstr  = ""
      delete(headerfile,ver-, >& "dev$null")

# --- is there allready a file named out?
      tempfile = mktemp ("tmp")
      if (access(outfile)){
        tempoutlist = outfile
        while (fscan (tempoutlist, tempout) != EOF){
          if (out == tempout){
            print(out//" allready exists")
            out = substr(out,1,strlen(out)-5)//"1.fits"
            print("renamed to "//out)
          }
        }
        tempoutlist = ""
      }

#delete existing out
      if (access(out))
        imdel(out,ver-)

#copy in to out
      imcopy(input=in,output=out)
      print(in," => ",out, >> changefile)
      print(out, >> outfile)

    }
  }
# --- Aufraeumen
  headerlist  = ""
  imagelist   = ""
  tempoutlist = ""
  delete (infile, ver-, >& "dev$null")
  delete (headerfile, ver-, >& "dev$null")

end



