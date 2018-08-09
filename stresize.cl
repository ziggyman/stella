procedure stresize (images)

##################################################################
#                                                                #
# NAME:             stresize                                     #
# PURPOSE:          * resizes the individual spectral apertures  #
#                     automatically                              #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: stresize(images)                             #
# INPUTS:           images:                                      #
#                     either: name of single image:              #
#                               "HD175640_botzfxs.fits"          #
#                     or: name of list containing names of       #
#                         images to trace:                       #
#                           "objects_botzfxs.list":              #
#                             HD175640_botzfxs.fits              #
#                             ...                                #
#                                                                #
# OUTPUTS:          output: -                                    #
#                   outfile: database/ap<name_of_infile_root>    #
#                                                                #
# IRAF VERSION:     2.11                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED    :      14.12.2001                                   #
# LAST EDITED:      02.04.2007                                   #
#                                                                #
##################################################################

string images         = "@input.list"                 {prompt="List of input images"}
int    loglevel       = 3                             {prompt="Level for writing logfile"}
string reference      = "refFlat"                     {prompt="Reference aperture-definition FITS file"}
#string dispaxis       = "2"                           {prompt="Dispersion axis (1-hor.,2-vert.)",
#                                                        enum="1|2"}
bool   interactive    = NO                            {prompt="Edit and resize apertures interactively?"}
int    line           = INDEF                         {prompt="Dispersion line"}
int    nsum           = 10                            {prompt="Number of dispersion lines to sum or median"}
real   lowlimit         = INDEF                         {prompt="Lower aperture limit relative to center"}
real   highlimit         = INDEF                         {prompt="Upper aperture limit relative to center"}
real   ylevel         = 0.05                          {prompt="Fraction of peak or intensity for automatic width"}
bool   peak           = YES                           {prompt="Is ylevel a fraction of the peak?"}
bool   bkg            = NO                            {prompt="Subtract background in automatic width?"}
real   r_grow         = 0.                            {prompt="Grow limits by this factor"}
bool   avglimit       = NO                            {prompt="Average limits over all apertures?"}
real   aplowlimit     = -25.5                         {prompt="Minimum lower aperture limit (pixels)"}
real   aphighlimit    = 25.5                          {prompt="Maximum upper aperture limit (pixels)"}
real   multlimit      = 0.75                          {prompt="Multiply limit by this factor is limit is exceeded"}
string instrument     = "echelle"                     {prompt="Instrument (echelle|coude)",
                                                        enum="echelle|coude"}
string imtype         = "fits"                        {prompt="Image type"}
string logfile        = "logfile_stresize.log"        {prompt="Name of log file"}
string warningfile    = "warnings_stresize.log"       {prompt="Name of warning file"}
string errorfile      = "errors_stresize.log"         {prompt="Name of error file"}
string *inputlist
string *aplist
string *timelist

begin

  string bak_logfile
  string timefile = "time.txt"
  string tempdate,tempday,temptime
  real   ylow,yhigh
  int    i,j,k,iaperture
  file   infile
  string apfirst,apsecond,apthird,apfourth,apfith,apsixt
  string apdeffile,low,high,xdum,ydum
  string in,tempout,tempapfile

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)
  if (access(warningfile))
    delete(warningfile, ver-)
  if (access(errorfile))
    delete(errorfile, ver-)

  if (instrument == "echelle")
    bak_logfile = echelle.logfile
  else
    bak_logfile = kpnocoude.logfile

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                    resizing apertures                  *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*                    resizing apertures                  *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)
# --- print parameters to logfile
  print ("stresize: images         = ")
  print (images)
  print ("stresize: images         = ", >> logfile)
  print (images, >> logfile)
  print ("stresize: loglevel       = ")
  print (loglevel)
  print ("stresize: loglevel       = ", >> logfile)
  print (loglevel, >> logfile)
  print ("stresize: reference      = ")
  print (reference)
  print ("stresize: reference      = ", >> logfile)
  print (reference, >> logfile)
  if (interactive){
    print ("stresize: interactive    = ")
    print ("YES")
    print ("stresize: interactive    = ", >> logfile)
    print ("YES", >> logfile)
  }
  else{
    print ("stresize: interactive    = ")
    print ("NO")
    print ("stresize: interactive    = ", >> logfile)
    print ("NO", >> logfile)
  }
  print ("stresize: line           = ")
  print (line)
  print ("stresize: line           = ", >> logfile)
  print (line, >> logfile)
  print ("stresize: nsum           = ")
  print (nsum)
  print ("stresize: nsum           = ", >> logfile)
  print (nsum, >> logfile)
  print ("stresize: lowlimit         = ")
  print (lowlimit)
  print ("stresize: lowlimit         = ", >> logfile)
  print (lowlimit, >> logfile)
  print ("stresize: highlimit         = ")
  print (highlimit)
  print ("stresize: highlimit         = ", >> logfile)
  print (highlimit, >> logfile)
  print ("stresize: ylevel         = ")
  print (ylevel)
  print ("stresize: ylevel         = ", >> logfile)
  print (ylevel, >> logfile)
  if (peak){
    print ("stresize: peak           = ")
    print ("YES")
    print ("stresize: peak           = ", >> logfile)
    print ("YES", >> logfile)
  }
  else{
    print ("stresize: peak           = ")
    print ("NO")
    print ("stresize: peak           = ", >> logfile)
    print ("NO", >> logfile)
  }
  if (bkg){
    print ("stresize: bkg            = ")
    print ("YES")
    print ("stresize: bkg            = ", >> logfile)
    print ("YES", >> logfile)
  }
  else{
    print ("stresize: bkg            = ")
    print ("NO")
    print ("stresize: bkg            = ", >> logfile)
    print ("NO", >> logfile)
  }
  print ("stresize: r_grow         = ")
  print (r_grow)
  print ("stresize: r_grow         = ", >> logfile)
  print (r_grow, >> logfile)
  if (avglimit){
    print ("stresize: avglimit       = ")
    print ("YES")
    print ("stresize: avglimit       = ", >> logfile)
    print ("YES", >> logfile)
  }
  else{
    print ("stresize: avglimit       = ")
    print ("NO")
    print ("stresize: avglimit       = ", >> logfile)
    print ("NO", >> logfile)
  }
  print ("stresize: aplowlimit     = ")
  print (aplowlimit)
  print ("stresize: aplowlimit     = ", >> logfile)
  print (aplowlimit, >> logfile)
  print ("stresize. aphighlimit    = ")
  print (aphighlimit)
  print ("stresize. aphighlimit    = ", >> logfile)
  print (aphighlimit, >> logfile)
  print ("stresize: multlimit      = ")
  print (multlimit)
  print ("stresize: multlimit      = ", >> logfile)
  print (multlimit, >> logfile)
  print ("stresize: instrument     = ")
  print (instrument)
  print ("stresize: instrument     = ", >> logfile)
  print (instrument, >> logfile)

# --- Erzeugen von temporaeren Filenamen
  print("stresize: building temp-filenames")
  if (loglevel > 2)
    print("stresize: building temp-filenames", >> logfile)
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stresize: building lists from temp-files")
  if (loglevel > 2)
    print("stresize: building lists from temp-files", >> logfile)

  if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
   sections(images, option="root", > infile)
   inputlist = infile
  }
  else{
   if (substr(images,1,1) != "@"){
    print("stresize: ERROR: "//images//" not found!!!")
    print("stresize: ERROR: "//images//" not found!!!", >> logfile)
    print("stresize: ERROR: "//images//" not found!!!", >> errorfile)
    print("stresize: ERROR: "//images//" not found!!!", >> warningfile)
   }
   else{
    print("stresize: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
    print("stresize: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> logfile)
    print("stresize: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> errorfile)
    print("stresize: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> warningfile)
   }

# --- clean up
   if (instrument == "echelle")
     echelle.logfile = bak_logfile
   else
     kpnocoude.logfile = bak_logfile

   inputlist     = ""
   aplist        = ""
   timelist      = ""
   delete (infile, ver-, >& "dev$null")
   return
  }

# --- resize apertures
  print("stresize: ******************* processing files *********************")
  if (loglevel > 2)
    print("stresize: ******************* processing files *********************", >> logfile)

  while (fscan (inputlist, in) != EOF){

    if (substr(in,strlen(in)-strlen(imtype),strlen(in)) == "."//imtype)
      in = substr(in,1,strlen(in)-strlen(imtype)-1)

    print("stresize: in = "//in)
    if (loglevel > 2)
      print("stresize: in = "//in, >> logfile)

    apdeffile = "database/ap"//in

    if (reference == "" || reference == " "){
      reference = in
    }

# --- test if reference aperture definitions can be accessed
    if (!access("database/ap"//reference)){
      print("stresize: ERROR: no reference aperture definition for "//reference//" found!!!")
      print("stresize: ERROR: no reference aperture definition for "//reference//" found!!!", >> logfile)
      print("stresize: ERROR: no reference aperture definition for "//reference//" found!!!", >> errorfile)
      print("stresize: ERROR: no reference aperture definition for "//reference//" found!!!", >> warningfile)

# --- clean up
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile

      inputlist     = ""
      aplist        = ""
      timelist      = ""
      delete (infile, ver-, >& "dev$null")
      return
    }

    print("stresize: processing "//in//", apdeffilefile = "//apdeffile)
    if (loglevel > 1)
      print("stresize: processing "//in//", apdeffilefile = "//apdeffile, >> logfile)

# --- resize apertures
    if (!access(in//"."//imtype)){
      print("stresize: ERROR: cannot access "//in)
      print("stresize: ERROR: cannot access "//in, >> logfile)
      print("stresize: ERROR: cannot access "//in, >> errorfile)
      print("stresize: ERROR: cannot access "//in, >> warningfile)
# --- clean up
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile

      inputlist     = ""
      aplist        = ""
      timelist      = ""
      delete (infile, ver-, >& "dev$null")
      return
    }

    tempout  = substr(in,1,2)//"_temp."//imtype
    print("stresize: tempout = "//tempout)
    if (access(tempout))
      del(tempout, ver-)

    imcopy (in,tempout)

    tempapfile = "database/ap"//substr(in,1,2)//"_temp"
    print("stresize: tempapfile = "//tempapfile)
    if (loglevel > 2)
      print("stresize: tempapfile = "//tempapfile, >> logfile)
    if (access(tempapfile))
      del(tempapfile, ver-)

    if (ylevel != INDEF){
      print ("stresize: starting apresize: ylevel = "//ylevel//" ( != INDEF)")
      print ("stresize: starting apresize: ylevel = "//ylevel//" ( != INDEF)", >> logfile)
      apresize.ylevel = ylevel
      print ("stresize: apresize.ylevel set to "//apresize.ylevel)
      apresize.llimit = INDEF
      print ("stresize: apresize.llimit set to "//apresize.llimit)
      apresize.ulimit = INDEF
      print ("stresize: apresize.ulimit set to "//apresize.ulimit)
      apresize(input=tempout, 
	       apertures = "", 
	       reference = reference, 
	       interact = interactive, 
	       find-, 
	       recenter-, 
	       resize+, 
	       edit = interactive, 
	       line = line, 
	       nsum = nsum,
	       peak = peak,
	       bkg = bkg,
	       r_grow = r_grow,
	       avglimit = avglimit)
    }
    else{
      print ("stresize: starting apresize: ylevel == INDEF")
      print ("stresize: starting apresize: ylevel == INDEF", >> logfile)
      print ("stresize: starting apresize: lowlimit = "//lowlimit)
      print ("stresize: starting apresize: lowlimit = "//lowlimit, >> logfile)
      print ("stresize: starting apresize: highlimit = "//highlimit)
      print ("stresize: starting apresize: highlimit = "//highlimit, >> logfile)
      apresize.ylevel = INDEF
      apresize.llimit = lowlimit
      apresize.ulimit = highlimit
      apresize(input=tempout, 
	       apertures = "", 
	       reference = reference, 
	       interact = interactive, 
	       find-, 
	       recenter-, 
	       resize+, 
	       edit = interactive, 
	       line = line, 
	       nsum = nsum,
	       peak = peak,
	       bkg = bkg,
	       r_grow = r_grow,
	       avglimit = avglimit)
    }

# --- check resized apertures
    print("stresize: checking resized apertures")
    if (!access(tempapfile)){
      print("stresize: ERROR: cannot access "//tempapfile)
      print("stresize: ERROR: cannot access "//tempapfile, >> logfile)
      print("stresize: ERROR: cannot access "//tempapfile, >> errorfile)
      print("stresize: ERROR: cannot access "//tempapfile, >> warningfile)
# --- clean up
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile

      inputlist     = ""
      aplist        = ""
      timelist      = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    if (access(apdeffile))
      delete(apdeffile, ver-)

    aplist   = tempapfile

    apfirst   = ""
    apsecond  = ""
    apthird   = ""
    apfourth  = ""
    apfith    = ""
    apsixt    = ""

    while (fscan (aplist, apfirst, apsecond, apthird, apfourth, apfith, apsixt) != EOF){
      if (loglevel > 2)
        print("stresize: "//tempapfile//": "//apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> logfile)
# ---  begin	aperture refFlat 1 77.87693 1024.
     if (apfirst == "begin"){
#            print("stresize: "//tempapfile//": "//apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt)
        iaperture = int(apfourth)
        print(apfirst//" "//apsecond//" "//in//" "//apfourth//" "//apfith//" "//apsixt, >> apdeffile)
      }
# --- image	refFlat
      else if (apfirst == "image"){
        print(apfirst//" "//in, >> apdeffile)
      }
# --- low	-29.35464 -1023.
      else if (apfirst == "low"){
         print("stresize: "//tempapfile//": "//apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt)
# --- is low limit lower than aplowlimit?
        if (real(apsecond) < aplowlimit){
          print(apfirst//" "//aplowlimit*multlimit//" "//apthird, >> apdeffile)
          print("stresize: WARNING: low limit for aperture "//iaperture//" was lower than "//aplowlimit//" => low set to aplowlimit times "//multlimit//"!")
          print("stresize: WARNING: low limit for aperture "//iaperture//" was lower than "//aplowlimit//" => low set to aplowlimit times "//multlimit//"!", >> logfile)
          print("stresize: WARNING: low limit for aperture "//iaperture//" was lower than "//aplowlimit//" => low set to aplowlimit times "//multlimit//"!", >> warningfile)
        }
        else{
          print(apfirst//" "//apsecond//" "//apthird, >> apdeffile)        
        }
      }
# --- high	30.08885 1024.
      else if (apfirst == "high"){
#            print("stresize: "//tempapfile//": "//apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt)
  # --- is high limit greater than aphighlimit?
        if (real(apsecond) > aphighlimit){
          print(apfirst//" "//aphighlimit*multlimit//" "//apthird, >> apdeffile)
          print("stresize: WARNING: high limit for aperture "//iaperture//" was greater than "//aphighlimit//" => high set to aphighlimit times "//multlimit//"!")
          print("stresize: WARNING: high limit for aperture "//iaperture//" was greater than "//aphighlimit//" => high set to aphighlimit times "//multlimit//"!", >> logfile)
          print("stresize: WARNING: high limit for aperture "//iaperture//" was greater than "//aphighlimit//" => high set to aphighlimit times "//multlimit//"!", >> warningfile)
        }
        else{
          print(apfirst//" "//apsecond//" "//apthird, >> apdeffile)        
        }
      }
      else{
        print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> apdeffile)
      }

      apfirst  = ""
      apsecond = ""
      apthird  = ""
      apfourth = ""
      apfith   = ""
      apsixt   = ""
    }

    imdel (in, ver-)
    imcopy (tempout, in)
    imdel (tempout, ver-)

    if (access(timefile))
      del(timefile, ver-)
    time(>> timefile)
    if (access(timefile)){
      timelist = timefile
      if (fscan(timelist,tempday,temptime,tempdate) != EOF){
        hedit(images=in,
              fields="STALL",
	      value="stresize: apertures resized "//tempdate//"T"//temptime,
	      add+,
	      addonly+,
	      del-,
	      ver-,
	      show+,
	      update+)
      }
    }
    else{
      print("stresize: WARNING: timefile <"//timefile//"> not accessable!")
      print("stresize: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
      print("stresize: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
    }

      print("stresize: -----------------------")
      print("stresize: -----------------------", >> logfile)
  } # end of while(scan(inputlist))

  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("stresize: stresize finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("stresize: WARNING: timefile <"//timefile//"> not accessable!")
    print("stresize: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("stresize: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- clean up
  if (instrument == "echelle")
    echelle.logfile = bak_logfile
  else
    kpnocoude.logfile = bak_logfile

  inputlist     = ""
  aplist        = ""
  timelist      = ""
  delete (infile, ver-, >& "dev$null")

end
