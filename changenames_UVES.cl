procedure changenames_UVES(inimages)
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

      out        = ""

      while (fscan (headerlist, line) != EOF){

# --- OBJECT  = 'OBJECT  '                    / Original nameet
        if (substr(line,1,6) == "OBJECT"){
          strpos(line,"'")
          i=1
          type = ""
          while((substr(line,strpos.pos+i,strpos.pos+i) != "'") && (substr(line,strpos.pos+i,strpos.pos+i) != " ")){
            if  (substr(line,strpos.pos+i,strpos.pos+i) == ','){
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

#HIERARCH ESO DPR TYPE        = 'OBJECT  '   / Observation type
        if (substr(line,1,21) == "HIERARCH ESO DPR TYPE"){
          strpos(line,"'")
          print("HIERARCH ESO DPR TYPE: strpos.pos = "//strpos.pos)
          i=1
          type = ""
          while(substr(line,strpos.pos+i,strpos.pos+i) != "'"){
            if  (substr(line,strpos.pos+i,strpos.pos+i) == ','){
              type = type//"-"
            }
            else if (substr(line,strpos.pos+i,strpos.pos+i) != " "){
              type = type//substr(line,strpos.pos+i,strpos.pos+i)
            }
            i = i+1
          }
          if (name == "BIAS_")
            type = ""
          if (type != "")
            type = type//"_"
          print("type = "//type)
        }


#HIERARCH ESO OBS NAME        = 'Calibration' / OB name
        if (substr(line,1,21) == "HIERARCH ESO OBS NAME" && targetnamefound == NO){
          strpos(line,"'")
          i=1
          name = ""
          while(substr(line,strpos.pos+i,strpos.pos+i) != "'" && substr(line,strpos.pos+i,strpos.pos+i) != "_"){
            if (substr(line,strpos.pos+i,strpos.pos+i) != " ")
              name = name//substr(line,strpos.pos+i,strpos.pos+i)
            i = i+1
          }
	  if (name == "flatfield" || name == "Calibration" || type == "LAMP-FLAT"){
            name = ""
	  }
          else{
            name = name//"_"
          }
          print("name = "//name)
        }
#HIERARCH ESO OBS TARG NAME   = 'HD_155806'  / OB target name
        if (substr(line,1,26) == "HIERARCH ESO OBS TARG NAME"){
          strpos(line,"'")
          i=1
          name = ""
          while(substr(line,strpos.pos+i,strpos.pos+i) != "'"){# && substr(line,strpos.pos+i,strpos.pos+i) != "_"){
            if (substr(line,strpos.pos+i,strpos.pos+i) != " " && substr(line,strpos.pos+i,strpos.pos+i) != "_")
              name = name//substr(line,strpos.pos+i,strpos.pos+i)
            i = i+1
          }
	  if (name == "flatfield" || name == "LAMP-FLAT" || type == "LAMP-FLAT_"){
            name = ""
	  }
          else{
            name = name//"_"
          }
          print("name = "//name)
          targetnamefound = YES
        }

# --- HIERARCH ESO OBS NAME NAME   = 'HD1909  '   / OB nameet name
#        if (substr(line,1,26) == "HIERARCH ESO OBS NAME NAME"){
#          i=33
#          name = ""
#          while((substr(line,i,i) != "'") && (substr(line,i,i) != " ")){
#            name = name//substr(line,i,i)
#            i = i+1
#          }
#          name = name//"_UVES_"
#          print("name = "//name)
#        }

#HIERARCH ESO INS PATH        = 'RED     '   / Optical path used
        if (substr(line,1,21) == "HIERARCH ESO INS PATH"){
          strpos(line,"'")
          i=1
          path = ""
          while((substr(line,strpos.pos+i,strpos.pos+i) != "'") && (substr(line,strpos.pos+i,strpos.pos+i) != " ")){
            path=path//substr(line,strpos.pos+i,strpos.pos+i)
            i = i+1
          }
          if (path == "RED")
            path = "r"
          else if (path == "BLUE")
            path = "b"
          path = path//"_"
          print("path = "//path)
        }

#HIERARCH ESO TPL NAME        = 'Red Bias Calibration' / Template name
        else if (substr(line,1,21) == "HIERARCH ESO TPL NAME" && path == ""){
          strpos(line,"'")
          if (substr(line,strpos.pos+1,strpos.pos+3) == "Red")
            path = "r_"
          else if (substr(line,strpos.pos+1,strpos.pos+4) == "Blue")
            path = "b_"
          print("path = "//path)
        }

#DATE-OBS= '2001-06-14T10:44:21.720'     / Date of observation
        else if (substr(line,1,8)=="DATE-OBS"){
          strpos(line,"'")
          i=1
          date = ""
          while((substr(line,strpos.pos+i,strpos.pos+i) != "'") && (substr(line,strpos.pos+i,strpos.pos+i) != " ")){
            if (substr(line,strpos.pos+i,strpos.pos+i) == ":"){
              date = date//"-"
            }
            else{
              date = date//substr(line,strpos.pos+i,strpos.pos+i)
            }
            i = i+1
          }
          date = date//"_"
        }

#HIERARCH ESO INS GRAT1 WLEN  =        437.0 / Grating central wavelength
        else if (substr(line,1,27) == "HIERARCH ESO INS GRAT1 WLEN"){
          strpos(line,"=")
#          tmpstr = substr(line,33,45)
#          print("tmpstr = "//tmpstr)
          wlen1   = ""
          i = 1
          while((substr(line,strpos.pos+i,strpos.pos+i) != "'") && (substr(line,strpos.pos+i,strpos.pos+i) != ".") && (substr(line,strpos.pos+i,strpos.pos+i) != "/") && i < 14){
#          for(i=1; i<14; i=i+1){
            if (substr(line,strpos.pos+i,strpos.pos+i) != " "){
              wlen1 = wlen1//substr(line,strpos.pos+i,strpos.pos+i)
              print("wlen1 = "//wlen1)
            }
           i = i+1
          }
          wlen1 = wlen1//"_"
          print("wlen1 = "//wlen1)
        }

#HIERARCH ESO INS GRAT2 WLEN  =        580.0 / Grating central wavelength
        else if (substr(line,1,27) == "HIERARCH ESO INS GRAT2 WLEN"){
          strpos(line,"=")
#          tmpstr = substr(line,31,43)
#          print("tmpstr = "//tmpstr)
          wlen2   = ""
          i = 1
          while((substr(line,strpos.pos+i,strpos.pos+i) != "'") && (substr(line,strpos.pos+i,strpos.pos+i) != ".") && (i < 14)){
#          for(i=1; i<14; i=i+1){
            if (substr(line,strpos.pos+i,strpos.pos+i) != " "){
              wlen2 = wlen2//substr(line,strpos.pos+i,strpos.pos+i)
            }
            i = i+1
          }
          wlen2 = wlen2//"_"
          print("wlen2 = "//wlen2)
        }

#HIERARCH ESO DET WIN1 UIT1   =   300.000000 / user defined subintegration time
        else if (substr(line,1,26) == "HIERARCH ESO DET WIN1 UIT1"){
          strpos(line,"=")
          i=1
          exptime = ""
          while(substr(line,strpos.pos+i,strpos.pos+i) != "."){
            if (substr(line,strpos.pos+i,strpos.pos+i) != " "){
              exptime = exptime//substr(line,strpos.pos+i,strpos.pos+i)
            }
            i = i+1
          }
          exptime = exptime//"s"
          print("exptime = "//exptime)
        }
      }
    }
# give output a name
    if (type == "LAMP-FLAT_"){
      name = ""
    }
    if (substr(name,1,12) == "Calibration_"){
      name = substr(name,13,strlen(name))
      print("name = ",name)
    }
    if (path == "r_"){
      if (type == "OBJECT_"){
        if (substr(name,1,4) == "POP_"){
          name = substr(name,5,strlen(name))
          print("name = "//name)
        }
        out = name//path//date//wlen2//exptime//".fits"
      }
      else if (type == "LAMP-WAVE_"){
        out = type//path//date//wlen2//exptime//".fits"
      }
      else{
        out = type//path//name//date//wlen2//exptime//".fits"
      }
    }
    else if (path == "b_"){
      if (type == "OBJECT_"){
        if (substr(name,1,4) == "POP_"){
          name = substr(name,5,strlen(name))
          print("name = "//name)
        }
        out = name//path//date//wlen1//exptime//".fits"
      }
      else if (type == "LAMP-WAVE_"){
        out = type//path//date//wlen1//exptime//".fits"
      }
      else{
        out = type//path//name//date//wlen1//exptime//".fits"
      }
    }
    else{
      out = type//name//path//date//wlen1//wlen2//exptime//".fits"
    }
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
