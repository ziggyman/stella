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
  string in,out,type,name,date,exptime,tmpstr,tempout
#  string path,wlen1,wlen2
  int    i

  in         = ""
  out        = ""
  tempout    = ""
#  wlen1      = ""
#  wlen2      = ""
  type       = ""
  name       = ""
#  path       = ""
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

# --- OBJECT  = 'BIAS    '                    / Target description
        if (substr(line,1,6) == "OBJECT"){ 
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

#IMAGETYP= 'BIAS    '                    / Observation type
        if (substr(line,1,21) == "HIERARCH ESO DPR TYPE"){ 
          strpos(line, "'")
          i = strpos.pos + 1
          type = ""
          while(substr(line,i,i) != "'"){
            if  (substr(line,i,i) == ','){
              type = type//"-"
            }
            else if (substr(line,i,i) != " "){
              type = type//substr(line,i,i)
            }
            i = i+1
          }
          if (name == "BIAS_")
            type = ""
          if (type != "")
            type = type//"_"
          print("type = "//type)
        }


#HIERARCH ESO OBS NAME        = '100-FEROS-DHC-ThAr+Ne' / OB name
        if (substr(line,1,21) == "HIERARCH ESO OBS NAME"){ 
          strpos(line, "'")
          i = strpos.pos + 1
          name = ""
          while(substr(line,i,i) != "'"){
            if (substr(line,i,i) != " ")
              name = name//substr(line,i,i)
            i = i+1
          }
	  if (name == "flatfield"){
            name = ""
	  }
          else{
            name = name//"_"
          }
          print("name = "//name)
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
#        if (substr(line,1,21) == "HIERARCH ESO INS PATH"){ 
#          i=33
#          path = ""
#          while((substr(line,i,i) != "'") && (substr(line,i,i) != " ")){
#            path=path//substr(line,i,i)
#            i = i+1
#          }
#          if (path == "RED")
#            path = "r"
#          else if (path == "BLUE")
#            path = "b"
#          path = path//"_"
#          print("path = "//path)
#        }

##HIERARCH ESO TPL NAME        = 'Red Bias Calibration' / Template name
#        else if (substr(line,1,21) == "HIERARCH ESO TPL NAME" && path == ""){
#          if (substr(line,33,35) == "Red")
##            path = "r_"
#          else if (substr(line,33,36) == "Blue")
#            path = "b_"
#          print("path = "//path)
#        }

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

##HIERARCH ESO INS GRAT1 WLEN  =        437.0 / Grating central wavelength
#        else if (substr(line,1,27) == "HIERARCH ESO INS GRAT1 WLEN"){
#          tmpstr = substr(line,31,43)
#          print("tmpstr = "//tmpstr)
#          wlen1   = ""
#          for(i=1; i<14; i=i+1){
#            if (substr(tmpstr,i,i) != " "){
#              wlen1 = wlen1//substr(tmpstr,i,i)
#            }
#          }
#          wlen1 = wlen1//"_"
#          print("wlen1 = "//wlen1)
#        }

##HIERARCH ESO INS GRAT2 WLEN  =        580.0 / Grating central wavelength
#        else if (substr(line,1,27) == "HIERARCH ESO INS GRAT2 WLEN"){
#          tmpstr = substr(line,31,43)
#          print("tmpstr = "//tmpstr)
#          wlen2   = ""
#          for(i=1; i<14; i=i+1){
#            if (substr(tmpstr,i,i) != " "){
#              wlen2 = wlen2//substr(tmpstr,i,i)
#            }
#          }
#          wlen2 = wlen2//"_"
#          print("wlen2 = "//wlen2)
#        }

#HIERARCH ESO DET WIN1 UIT1   =     0.000000 / user defined subintegration time
        else if (substr(line,1,26) == "HIERARCH ESO DET WIN1 UIT1"){
          strpos(line, "=")
          i=strpos.pos + 1
          while(substr(line,i,i) == " "){
            i = i+1
          }
          exptime = ""
          while(substr(line,i,i) != "."){
            if (substr(line,i,i) != " "){
              exptime = exptime//substr(line,i,i)
            }
            i = i+1
          }
          exptime = exptime//"s"
          print("exptime = "//exptime)          
        }
      }
    }
# give output a name
    if (substr(name,1,12) == "Calibration_"){
      name = substr(name,13,strlen(name))
      print("name = ",name)
    }
#    if (path == "r_"){
      if (type == "OBJECT-SKY_"){
        if (substr(name,1,4) == "POP_"){
          name = substr(name,5,strlen(name))
#          print("name = "//name)
        }
        out = name//date//exptime//".fits"
      }
      else if (type == "WAVE_"){
        out = type//"FEROS_"//date//exptime//".fits"
      }
      else{
        out = type//date//exptime//".fits"
      }
#    }
#    else if (path == "b_"){
#      if (type == "OBJECT-POINT_"){
#        if (substr(name,1,4) == "POP_"){
#          name = substr(name,5,strlen(name))
#          print("name = "//name)
#        }
#        out = name//path//date//wlen2//exptime//".fits"
#      }
#      else if (type == "LAMP-WAVE_"){
#        out = type//path//date//wlen1//exptime//".fits"
#      }
#      else{
#        out = type//name//path//date//wlen1//exptime//".fits"
#      }
#    }
#    else{
#      out = type//name//path//date//wlen1//wlen2//exptime//".fits"
#    }
    print("out = "//out)

#destroy old parts of outname
#    wlen1   = ""
#    wlen2   = ""
    type    = ""
    name    = ""
#    path    = ""
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



