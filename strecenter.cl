procedure strecenter (images)

##################################################################
#                                                                #
# NAME:             strecenter                                   #
# PURPOSE:          * recentres the individual spectral orders   #
#                     automatically                              #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: strecenter(images)                           #
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

string images          = "@input.list"             {prompt="List of input images"}
int    loglevel        = 3                         {prompt="Level for writing logfile"}
string reference       = "refFlat"                 {prompt="Reference aperture-definition FITS file"}
string dispaxis        = "2"                       {prompt="Dispersion axis (1-hor.,2-vert.)",
                                                     enum="1|2"}
bool   interactive     = NO                        {prompt="Edit and recenter apertures interactively?"}
int    line            = INDEF                     {prompt="Dispersion line"}
int    nsum            = 10                        {prompt="Number of dispersion lines to sum or median"}
string aprecenter      = ""                        {prompt="Apertures for recentering calculation"}
real   npeaks          = INDEF                     {prompt="Select brightest peaks"}
bool   shift           = NO                        {prompt="Use average shift instead of recentering?"}
real   width           = 40.                       {prompt="Profile centering width"}
real   radius          = 5.                        {prompt="Profile centering radius"}
real   threshold       = 100.                      {prompt="Detection threshold for profile centering"}
real   ddapcenterlimit = 2.                        {prompt="Maximum difference between delta_ycenter's"}
string instrument      = "echelle"                 {prompt="Instrument (echelle|coude)",
                                                     enum="echelle|coude"}
string logfile         = "logfile_strecenter.log"  {prompt="Name of log file"}
string warningfile     = "warnings_strecenter.log" {prompt="Name of warning file"}
string errorfile       = "errors_strecenter.log"   {prompt="Name of error file"}

string *inputlist
string *aplist
string *timelist

begin

  string bak_logfile
  real   xcenter,ycenter,xcenter_last,ycenter_last
  real   dycenter,dycenter_last,ddycenter,ddycenter_last
  int    i,j,k,aperture
  file   infile
  string timefile = "time.txt"
  string tempdate,tempday,temptime
  string apfirst,apsecond,apthird,apfourth,apfith,apsixt
  string apdeffile,low,high,xdum,ydum
  string aps_center_file = "aps_center.temp"
  string in

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

# --- Erzeugen von temporaeren Filenamen
  print("strecenter: building temp-filenames")
  if (loglevel > 2)
    print("strecenter: building temp-filenames", >> logfile)
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("strecenter: building lists from temp-files")
  if (loglevel > 2)
    print("strecenter: building lists from temp-files", >> logfile)

  if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
   sections(images, option="root", > infile)
   inputlist = infile
  }
  else{
   if (substr(images,1,1) != "@"){
    print("strecenter: ERROR: "//images//" not found!!!")
    print("strecenter: ERROR: "//images//" not found!!!", >> logfile)
    print("strecenter: ERROR: "//images//" not found!!!", >> errorfile)
    print("strecenter: ERROR: "//images//" not found!!!", >> warningfile)
   }
   else{
    print("strecenter: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
    print("strecenter: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> logfile)
    print("strecenter: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> errorfile)
    print("strecenter: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> warningfile)
   }

# --- clean up
   if (instrument == "echelle")
     echelle.logfile = bak_logfile
   else
     kpnocoude.logfile = bak_logfile

   inputlist       = ""
   aplist          = ""
   timelist        = ""
#   aps_center_list = ""
   delete (infile, ver-, >& "dev$null")
   return
  }

# --- recenter apertures
  print("strecenter: ******************* processing files *********************")
  if (loglevel > 2)
    print("strecenter: ******************* processing files *********************", >> logfile)

  while (fscan (inputlist, in) != EOF){

    if (substr(in,strlen(in)-4,strlen(in)) == ".fits")
      in = substr(in,1,strlen(in)-5)

    print("strecenter: in = "//in)
    if (loglevel > 2)
      print("strecenter: in = "//in, >> logfile)

    i = strlen(in)
    if (substr (in, i-4, i) == ".fits")
      apdeffile = "database/ap"//substr(in, 1, i-5)
    else 
       apdeffile = "database/ap"//in

    if (reference != "" && reference != " "){
# --- test if reference aperture definitions can be accessed
      if (!access("database/ap"//reference)){
        print("strecenter: ERROR: no reference aperture definition for "//reference//" found!!!")
        print("strecenter: ERROR: no reference aperture definition for "//reference//" found!!!", >> logfile)
        print("strecenter: ERROR: no reference aperture definition for "//reference//" found!!!", >> errorfile)
        print("strecenter: ERROR: no reference aperture definition for "//reference//" found!!!", >> warningfile)

# --- aufraeumen
        if (instrument == "echelle")
          echelle.logfile = bak_logfile
        else
          kpnocoude.logfile = bak_logfile

        inputlist     = ""
        aplist        = ""
        timelist      = ""
#        aps_center_list = ""
        delete (infile, ver-, >& "dev$null")
        return
      }
    }

# --- backup and delete old apdeffile
    if (access(apdeffile)){
      if (access(apdeffile//".bak"))
        delete(apdeffile//".bak", ver-)
      copy(input = apdeffile, output = apdeffile//".bak", ver-)
      if (reference != "" && reference != " "){
        del(apdeffile,ver-)
        if (!access(apdeffile)){
          print("strecenter: old "//apdeffile//" deleted")
          if (loglevel > 2)
            print("strecenter: old "//apdeffile//" deleted", >> logfile)
        }
        else{
          print("strecenter: ERROR: cannot delete old "//apdeffile)
          print("strecenter: ERROR: cannot delete old "//apdeffile, >> logfile)
          print("strecenter: ERROR: cannot delete old "//apdeffile, >> warningfile)
          print("strecenter: ERROR: cannot delete old "//apdeffile, >> errorfile)
        }
      }
    }
    
# --- set apedit parameters
    apedit.width     = width
    apedit.radius    = radius
    apedit.threshold = threshold

    print("strecenter: processing "//in//", apdeffilefile = "//apdeffile)
    if (loglevel > 1)
      print("strecenter: processing "//in//", apdeffilefile = "//apdeffile, >> logfile)

# --- recenter apertures
    if (access(in//".fits")){
      aprecenter(input=in, 
	         apertures = "", 
	         reference = reference, 
	         interact = interactive, 
	         recenter+, 
	         resize-, 
	         edit = interactive, 
	         line = line, 
		 nsum = nsum,
		 aprecenter = aprecenter,
		 npeaks = npeaks,
		 shift = shift)

# --- check recenterd apertures
      print("strecenter: checking recenterd apertures")
      if (access(aps_center_file))
        delete(aps_center_file,ver-)
      if (access(apdeffile)){
#        if (access(apdeffile//".temp"))
#          delete(apdeffile//".temp", ver-)
#        copy(input = apdeffile, output = apdeffile//".temp", ver-)
#        if (access(apdeffile//".temp"))
#          aplist   = apdeffile//".temp"
#        else if (access(apdeffile))
#          aplist   = apdeffile
          aplist = apdeffile
#        else{
## --- aufraeumen
#          if (instrument == "echelle")
#            echelle.logfile = bak_logfile
#          else
#            kpnocoude.logfile = bak_logfile

#          inputlist     = ""
#          aplist        = ""
#          timelist      = ""
#          aps_center_list = ""
#          delete (infile, ver-, >& "dev$null")
#          return
#        }
        apfirst  = ""
        apsecond = ""
        apthird  = ""
        apfourth = ""
        apfith   = ""
        apsixt   = ""

        aperture = 0

        xcenter   = 0.
        ycenter   = 0.
        dycenter  = 0.
        ddycenter = 0.

        while (fscan (aplist, apfirst, apsecond, apthird, apfourth, apfith, apsixt) != EOF){
          if (apfirst == "begin"){
            aperture += 1
            print("strecenter: center of aperture "//aperture//": "//apfith//", "//apsixt)
            if (loglevel > 1)
              print("strecenter: center of aperture "//aperture//": "//apfith//", "//apsixt, >> logfile)

            xcenter_last = xcenter
            ycenter_last = ycenter

            if (dispaxis == "1"){
              xcenter = real(apfith)
              ycenter = real(apsixt)
            }
            else{
              xcenter = real(apsixt)
              ycenter = real(apfith)
            }

            dycenter_last = dycenter
            dycenter = ycenter - ycenter_last
            ddycenter_last = ddycenter
            ddycenter = dycenter - dycenter_last

            print("strecenter: aperture "//aperture//": xcenter = "//xcenter//", ycenter = "//ycenter)
            print("strecenter: aperture "//aperture//": xcenter_last = "//xcenter_last//", ycenter_last = "//ycenter_last)
            print("strecenter: aperture "//aperture//": dycenter = "//dycenter//", dycenter_last = "//dycenter_last)
            print("strecenter: aperture "//aperture//": ddycenter = "//ddycenter//", ddycenter_last = "//ddycenter_last)

            if (aperture > 1){
              if (ddycenter > ddapcenterlimit){
#                if (aperture < 4){
#                  if (access(apdeffile))
#	            delete(apdeffile, ver-)
#                  copy(input = apdeffile//".bak", output = apdeffile, ver-)
#	          print("strecenter: WARNING: recenter of "//in//" FAILED! Image not recentered!")
#	          print("strecenter:          ddycenter = "//ddycenter)
#	          print("strecenter: WARNING: recenter of "//in//" FAILED! Image not recentered!", >> logfile)
#	          print("strecenter:          ddycenter = "//ddycenter, >> logfile)
#	          print("strecenter: WARNING: recenter of "//in//" FAILED! Image not recentered!", >> warningfile)
#  	          print("strecenter:          ddycenter = "//ddycenter, >> warningfile)
# --- clean up
#                  inputlist     = ""
#                  aplist        = ""
#                  timelist      = ""
##                  aps_center_list = ""
#                  delete (infile, ver-, >& "dev$null")
#                  return
#                }
#	        print("strecenter: WARNING: recenter of aperture "//aperture//" FAILED! Recalculating!")
#	        print("strecenter:          ddycenter = "//ddycenter)
#	        print("strecenter: WARNING: recenter of aperture "//aperture//" FAILED! Recalculating!", >> logfile)
#	        print("strecenter:          ddycenter = "//ddycenter, >> logfile)
#	        print("strecenter: WARNING: recenter of aperture "//aperture//" FAILED! Recalculating!", >> warningfile)
#	        print("strecenter:          ddycenter = "//ddycenter, >> warningfile)

# --- recalculating center position
#                ycenter = ycenter_last + dycenter_last + (2. * ddycenter_last)
#                dycenter = ycenter - ycenter_last
#                ddycenter = dycenter - dycenter_last
#                print("strecenter: new ycenter = "//ycenter)
#                if (dispaxis == "1")
#                  print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//ycenter, >> aps_center_file)
#                else
#                  print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//ycenter//" "//apsixt, >> aps_center_file)
#                print("strecenter: new ycenter written to aperture-data file")
###                 print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> aps_center_file)
#              }
#              else if (ddycenter > ddapcenterlimit/2.){
              if (ddycenter > ddapcenterlimit){
#	        print("strecenter: WARNING: recenter of "//in//" exceeds half ddapcenterlimit (="//ddapcenterlimit//")!")
#	        print("strecenter:          ddycenter = "//ddycenter)
#	        print("strecenter: WARNING: recenter of "//in//" exceeds half ddapcenterlimit (="//ddapcenterlimit//")!", >> logfile)
#	        print("strecenter:          ddycenter = "//ddycenter, >> logfile)
#	        print("strecenter: WARNING: recenter of "//in//" exceeds half ddapcenterlimit (="//ddapcenterlimit//")!", >> warningfile)
#	        print("strecenter:          ddycenter = "//ddycenter, >> warningfile)
#                print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> aps_center_file)
	        print("strecenter: WARNING: recenter of "//in//" exceeds ddapcenterlimit (="//ddapcenterlimit//")!")
	        print("strecenter:          ddycenter = "//ddycenter)
	        print("strecenter: WARNING: recenter of "//in//" exceeds ddapcenterlimit (="//ddapcenterlimit//")!", >> logfile)
	        print("strecenter:          ddycenter = "//ddycenter, >> logfile)
	        print("strecenter: WARNING: recenter of "//in//" exceeds ddapcenterlimit (="//ddapcenterlimit//")!", >> warningfile)
	        print("strecenter:          ddycenter = "//ddycenter, >> warningfile)
#                print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> aps_center_file)
              }
              else{
                print("strecenter: aperture "//aperture//": recenter successfull")
    	        if (loglevel > 2)
                  print("strecenter: aperture "//aperture//": recenter successfull", >> logfile)
#                print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> aps_center_file)
              }
            }
#            else{
#              print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> aps_center_file)
#            }
          }
#          else if (apfirst == "center"){
#            if (dispaxis == "1")
#              print(apfirst//" "//xcenter//" "//ycenter, >> aps_center_file)
#            else
#              print(apfirst//" "//ycenter//" "//xcenter, >> aps_center_file)
#            print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> aps_center_file)
          }
#          else{
#            print(apfirst//" "//apsecond//" "//apthird//" "//apfourth//" "//apfith//" "//apsixt, >> aps_center_file)
#          }

          apfirst  = ""
          apsecond = ""
          apthird  = ""
          apfourth = ""
          apfith   = ""
          apsixt   = ""
        } # end of while(fscan(apdeffile...
          
      } # end if (access(apdeffile)){
      else{
        print("strecenter: ERROR: cannot access "//apdeffile)
	print("strecenter: ERROR: cannot access "//apdeffile, >> logfile)
	print("strecenter: ERROR: cannot access "//apdeffile, >> errorfile)
	print("strecenter: ERROR: cannot access "//apdeffile, >> warningfile)
# --- clean up
        if (instrument == "echelle")
          echelle.logfile = bak_logfile
        else
          kpnocoude.logfile = bak_logfile

        inputlist     = ""
        aplist        = ""
        timelist      = ""
#        aps_center_list = ""
        delete (infile, ver-, >& "dev$null")
        return
      }

      if (access(timefile))
        del(timefile, ver-)
      time(>> timefile)
      if (access(timefile)){
        timelist = timefile
        if (fscan(timelist,tempday,temptime,tempdate) != EOF){
          hedit(images=in,
                fields="STALL",
                value="strecenter: apertures recentered "//tempdate//"T"//temptime,
                add+,
                addonly+,
                del-,
                ver-,
                show+,
                update+)
        }
      }
      else{
        print("strecenter: WARNING: timefile <"//timefile//"> not accessable!")
        print("strecenter: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
        print("strecenter: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
      }

      print("strecenter: -----------------------")
      print("strecenter: -----------------------", >> logfile)
    } # end if (access(in))
    else{
      print("strecenter: ERROR: cannot access "//in)
      print("strecenter: ERROR: cannot access "//in, >> logfile)
      print("strecenter: ERROR: cannot access "//in, >> errorfile)
      print("strecenter: ERROR: cannot access "//in, >> warningfile)
# --- aufraeumen
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile

      inputlist     = ""
      aplist        = ""
      timelist      = ""
#      aps_center_list = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
  } # end of while(scan(inputlist))

#  if (access(apdeffile))
#    delete(apdeffile, ver-)
#  copy(input = aps_center_file, output = apdeffile, ver-)
#  delete(aps_center_file, ver-)

# --- check ymin's and ymsx's
#  aps_center_list = aps_center_file
#  i = 0
#  xcenter = 0.
#  ycenter = 0.
#  dycenter = 0.

#  while (fscan(aps_center_list,xdum,ydum) != EOF){
#    i += 1
#    xcenter_last = xcenter
#    ycenter_last = ycenter

#    if (dispaxis == "1"){
#      xcenter = real(xdum)
#      ycenter = real(ydum)
#    }
#    else{
#      xcenter = real(ydum)
#      ycenter = real(xdum)
#    }

#    dycenter_last = dycenter
#    dycenter = ycenter - ycenter_last
#    ddycenter = dycenter - dycenter_last

#    if (i > 1){
#      if (dycenter > dapcenterlimit/2.){
#	print("strecenter: WARNING: recenter of "//in//" exceeds half dapcenterlimit (="//dapcenterlimit//")!")
#	print("strecenter:          dycenter = "//dycenter)
#	print("strecenter: WARNING: recenter of "//in//" exceeds half dapcenterlimit (="//dapcenterlimit//")!", >> logfile)
#	print("strecenter:          dycenter = "//dycenter, >> logfile)
#	print("strecenter: WARNING: recenter of "//in//" exceeds half dapcenterlimit (="//dapcenterlimit//")!", >> warningfile)
#	print("strecenter:          dycenter = "//dycenter, >> warningfile)
#      }
#      else if (dycenter > dapcenterlimit){
#        if (access(apdeffile))
#	  delete(apdeffile, ver-)
#        copy(input = apdeffile//".bak", output = apdeffile, ver-)
#	print("strecenter: WARNING: recenter of "//in//" FAILED! Image not recenterd!")
#	print("strecenter:          dycenter = "//dycenter)
#	print("strecenter: WARNING: recenter of "//in//" FAILED! Image not recenterd!", >> logfile)
#	print("strecenter:          dycenter = "//dycenter, >> logfile)
#	print("strecenter: WARNING: recenter of "//in//" FAILED! Image not recenterd!", >> warningfile)
#	print("strecenter:          dycenter = "//dycenter, >> warningfile)
#      }
#      else{
#        print("strecenter: aperture "//i//": recenter successfull")
#	if (loglevel > 2)
#          print("strecenter: aperture "//i//": recenter successfull", >> logfile)
#      }
#    }
#  }

  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("strecenter: strecenter finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("strecenter: WARNING: timefile <"//timefile//"> not accessable!")
    print("strecenter: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("strecenter: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- clean up
  if (instrument == "echelle")
    echelle.logfile = bak_logfile
  else
    kpnocoude.logfile = bak_logfile

  inputlist     = ""
  aplist        = ""
  timelist      = ""
#  aps_center_list = ""
  delete (infile, ver-, >& "dev$null")

end
