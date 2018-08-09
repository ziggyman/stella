procedure changenames_ALFOSC(inimages)
#,flat)

############################################################
#                                                          #
# This program changes the imagenames to useable ones      #
#                                                          #
#   outputs = OBJECT_INSTRUMENTtime_exptime_grism.fits    #
#                                                          #
# Andreas Ritter, 25.01.03                                 #
#                                                          #
############################################################

string inimages    = "@changenames.list"               {prompt="list of images to change names"}
#string flat        = "normalizedFlat.fits"             {prompt="flat field"}
bool   delin       = NO                                {prompt="delete infile?"}
int    loglevel    = 3                                 {prompt="Level for writing logfiles"}
string logfile     = "logfile_changenames_ALFOSC.log"  {prompt="Name of log file"}
string warningfile = "warnings_changenames_ALFOSC.log" {prompt="Name of warning file"}
string errorfile   = "errors_changenames_ALFOSC.log"   {prompt="Name of error file"}
string *imagelist
string *headerlist

#task $fits-nozero = "$foreign"

begin

  file   infile
  string in,out,outdate
  string outlist = "changenames_ALFOSC_out.list"
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
    print("changenames: ERROR: "//inimages//" not found!!!", >> logfile)
    print("changenames: ERROR: "//inimages//" not found!!!", >> warningfile)
    print("changenames: ERROR: "//inimages//" not found!!!", >> errorfile)
   }
   else{
    print("changenames: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
    print("changenames: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!", >> logfile)
    print("changenames: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!", >> warningfile)
    print("changenames: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!", >> errorfile)
   }
   return
  }
  
  if (access(outlist))
    del(outlist, ver-)

# --- build output filenames and divide by flat
  while (fscan (imagelist, in) != EOF){

    print("changenames: in = "//in)
    if (loglevel > 1)
      print("changenames: in = "//in, >> logfile)

# --- write header
    headerfile="head"//in//".text"
    if (access(headerfile))
      del (headerfile,ver-)
    imhead(in,l+, > headerfile)

    if (access(headerfile)){

      headerlist = headerfile

      out = ""
      outdate = ""
      print("out = "//out)     

      while (fscan (headerlist, line) != EOF){

# --- read values
#OBJECT  = 'hd124740'
        if (substr(line,1,6) == "OBJECT"){ 
          print("substr(line,1,6) == OBJECT")
          if (substr(line,12,15) == "bias"){
            out = "bias"
          }
          else if (substr(line,12,16) == "calib"){
            print("substr(line,12,16) == 'calib'")
            i=12
            while(substr(line,i,i) != "'"){
              if (substr(line,i,i) == " "){
                out = out//"_"
              }
              else if (substr(line,i,i) != "#"){
                out = out//substr(line,i,i)
              }
              i=i+1
            }
          }
          else if (substr(line,12,20) == "Gr7-calib"){
            out = "calib_grism7"
          }
          else if (substr(line,12,19) == "sky flat"){
            out = "flat"
          }
          else if (substr(line,12,18) == "halogen"){
            out = "halogen"
          }
          else{
            i=12
            while(substr(line,i,i) != "'"){
              if (substr(line,i,i) == " "){
                if (substr(out,strlen(out),strlen(out)) != "_")
                  out = out//"_"
              }
              else{
                out=out//substr(line,i,i)
              }
              i=i+1
            }
            print("out = "//out)
          }
          out=out//"_ALFOSC"//outdate      
          print("out = "//out)
        }
#DATE    = '2002-01-25T09:25:45'
        if (substr(line,1,4)=="DATE"){
          i = 12
          outdate = ""
          while(substr(line,i,i) != " " && substr(line,i,i) != "'"){
            if (substr(line,i,i) == ":"){
              outdate = outdate//"-"
            }
	    else{
              outdate = outdate//substr(line,i,i)
            }
            i = i+1
          }
          print("substr(line,1,4) == DATE")
          outdate=outdate//"_"
          print("outdate = "//outdate)
        }
#GRISM   = '6 Grism #9    '      / ALFOSC Grism ID,     step position = 200640
        if (substr(line,1,5)=="GRISM"){
          print("substr(line,1,5) == GRISM")
          i = 12
	  for (i=12;i<26;i=i+1){
            if (substr(line,i,i) != " "){
              if (substr(line,i,i) != "("){
                if (substr(line,i,i) != ")"){
                  if (substr(line,i,i) != "#"){
                    out = out//substr(line,i,i)
                  }
                }
              }
            }
          }
          print("out = "//out)
        }
#EXPTIME =               20.000  /
        if (substr(line,1,7) == "EXPTIME"){
          print("substr(line,1,7) == EXPTIME")
	  for(i = 12;i<31;i=i+1){
            if (substr(line,i,i) != " "){
              out = out//substr(line,i,i)
            }
          }
          out = out//"s_"
          print("out = "//out)
	}
#HIERARCH ESO INS GRAT1 WLEN  =  568.4000000
#        if (substr(line,1,27) == "HIERARCH ESO INS GRAT1 WLEN"){
#          print("wlen = "//substr(line,33,37))
#          if (substr(line,33,37) == "568.4")
#            out = out//"6145_"
#          else
#            out = out//substr(line,33,35)//substr(line,37,37)//"_"
#          print("out = "//out)          
#        }
#HIERARCH ESO DET WIN1 UIT1   =    60.000000
#        if (substr(line,1,26) == "HIERARCH ESO DET WIN1 UIT1"){
#          if (substr(line,34,34) == " ")
#            out = out//substr(line,35,36)//"s.fits"
#          else
#            out = out//substr(line,34,36)//"s.fits"
#          print("out = "//out)          
#        }
      }
    }
    out = out//".fits"
    print("out = "//out)          
    if (loglevel > 1)
      print("out = "//out, >> logfile)          

    if (in == out){
#      out = substr(out,1,strlen(out)-5)//"_new.fits"
      print("cnangenames: Warning: old and new image name ("//in//") are equal! Not renaming it")
      print("cnangenames: Warning: old and new image name ("//in//") are equal! Not renaming it", >> logfile)
      print("cnangenames: Warning: old and new image name ("//in//") are equal! Not renaming it", >> warningfile)
    }
    else{
      print(out, >> outlist)
      if (access(out)){
       imdel(out,ver-)
       print("changenames: old "//out//" deleted")
      }
      if (access(out)){
        del(out,ver-)
      }
 
      imcopy(input=in,output=out)
    }
    del(headerfile)
    if (delin){
      imdel(in,ver-)
    }
  }

#  changenames_ALFOSC(out,delin=delin)

# --- Aufraeumen
  headerlist = ""
  imagelist = ""
  delete (infile, ver-, >& "dev$null")
  delete (headerfile, ver-, >& "dev$null")
 
end



