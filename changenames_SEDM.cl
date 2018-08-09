procedure changenames_SEDM(inimages)
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
  string in,out,wlen1,wlen2,type,name,path,date,exptime,tmpstr,tempout
  int    i
  bool   targetnamefound = NO

  in         = ""
  out        = ""
  tempout    = ""
  wlen1      = ""
  wlen2      = ""
  type       = ""
  name       = ""
  path       = ""
  date       = ""
  exptime    = ""
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
    print("changenames_SEDM: ERROR: "//inimages//" not found!!!")
   }
   else{
    print("changenames_SEDM: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
   }
   return
  }

# --- build output filenames
  while (fscan (imagelist, in) != EOF){

    print("changenames_SEDM: in = "//in)

# --- write header
    headerfile="head.text"
    if (access(headerfile))
      del (headerfile)
    imhead(in,l+, > headerfile)

    if (access(headerfile)){

      headerlist = headerfile

      out        = ""

      while (fscan (headerlist, line) != EOF){

#OBJECT  = 'dark dome'
        if (substr(line,1,6) == "OBJECT"){
          strpos(line,"'")
          i=1
          type = ""
          while((substr(line,strpos.pos+i,strpos.pos+i) != "'") && (substr(line,strpos.pos+i,strpos.pos+i) != " ")){
            if  (substr(line,strpos.pos+i,strpos.pos+i) == ','){
              type = type//"-"
            }
            else if  (substr(line,strpos.pos+i,strpos.pos+i) == '_'){
              type = type//"-"
            }
            else{
              type = type//substr(line,strpos.pos+i,strpos.pos+i)
            }
            i = i+1
          }
          if (type != "")
            type=type//"_"
          print("type = "//type)
        }


#DATE-OBS= '2001-06-14T10:44:21.720'     / Date of observation
#        else if (substr(line,1,8)=="DATE-OBS"){
#          strpos(line,"'")
#          i=1
#          date = ""
#          while((substr(line,strpos.pos+i,strpos.pos+i) != "'") && (substr(line,strpos.pos+i,strpos.pos+i) != " ")){
#            if (substr(line,strpos.pos+i,strpos.pos+i) == ":"){
#              date = date//"-"
#            }
#            else{
#              date = date//substr(line,strpos.pos+i,strpos.pos+i)
#            }
#            i = i+1
#          }
#          date = date//"_"
#        }


#EXPTIME =                  10. / Exposure time in s
        else if (substr(line,1,7) == "EXPTIME"){
          strpos(line,"=")
          i=1
          exptime = ""
          while(substr(line,strpos.pos+i,strpos.pos+i) != "."){
            if (substr(line,strpos.pos+i,strpos.pos+i) != " "){
              exptime = exptime//substr(line,strpos.pos+i,strpos.pos+i)
            }
            i = i+1
          }
          exptime = exptime//"s_"
          print("exptime = "//exptime)
        }
      }
    }
# give output a name
#    if (type == "LAMP-FLAT_"){
#      name = ""
#    }
#    if (substr(name,1,12) == "Calibration_"){
#      name = substr(name,13,strlen(name))
#      print("name = ",name)
#    }
    out = type//exptime//in
    print("out = "//out)

#destroy old parts of outname
    wlen1   = ""
    wlen2   = ""
    type    = ""
    name    = ""
    path    = ""
    date    = ""
    exptime = ""
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

# --- Aufraeumen
  headerlist  = ""
  imagelist   = ""
  tempoutlist = ""
  delete (infile, ver-, >& "dev$null")
  delete (headerfile, ver-, >& "dev$null")

end
