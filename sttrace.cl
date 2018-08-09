procedure sttrace (images)

##################################################################
#                                                                #
# NAME:             sttrace                                      #
# PURPOSE:          * traces the individual spectral orders      #
#                     automatically                              #
#                                                                #
# CATEGORY:         data reduction                               #
# CALLING SEQUENCE: sttrace(images)                              #
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

string images      = "@input.list"          {prompt="List of input images"}
int    loglevel    = 3                      {prompt="Level for writing logfile"}
string reference   = "refFlat"              {prompt="Reference aperture-definition FITS file"}
string dispaxis    = "2"                    {prompt="Dispersion axis (1-hor.,2-vert.)",
                                              enum="1|2"}
bool   interactive = NO                     {prompt="Run task interactively?"}
int    line        = INDEF                  {prompt="Dispersion line"}
int    nsum        = 10                     {prompt="Number of dispersion lines to sum or median"}
int    step        = 5                      {prompt="Tracing step"}
int    nlost       = 10                     {prompt="Number of consecutive times profile is lost before quitting"}
string function    = "legendre"             {prompt="Trace fitting function",
                                              enum="chebyshev|legendre|spline1|spline3"}
int    order       = 4                      {prompt="Trace fitting function order"}
string sample      = "*"                    {prompt="Trace sample regions"}
int    naverage    = 1                      {prompt="Trace average (pos) or median (neg)"}
int    niterate    = 2                      {prompt="Trace rejection iterations"}
real   low_reject  = 3.                     {prompt="Trace lower rejection sigma"}
real   high_reject = 3.                     {prompt="Trace upper rejection sigma"}
real   grow        = 0.                     {prompt="Trace rejection growing radius"}
real   yminlimit   = -59.                   {prompt="Minimum aperture position relative to center (pixels)"}
real   ymaxlimit   = 59.                    {prompt="Maximum aperture position relative to center (pixels)"}
string instrument  = "echelle"              {prompt="Instrument (echelle|coude)",
                                              enum="echelle|coude"}
string logfile     = "logfile_sttrace.log"  {prompt="Name of log file"}
string warningfile = "warnings_sttrace.log" {prompt="Name of warning file"}
string errorfile   = "errors_sttrace.log"   {prompt="Name of error file"}

string *inputlist
string *aplist
string *apbaklist
string *coeff_list
string *aps_ymin_list
string *aps_ymax_list
string *aps_center_list
string *aps_xmin_list
string *aps_xmax_list
string *timelist

begin

  string bak_logfile
  real   a,b,n,s,x,y,xmin,xmax,ymin,ymax,xmin_last,xmax_last,ymin_last,ymax_last
  real   xcenter,ycenter,xcenter_last,ycenter_last,z,z_last,z_before_last
  real   dymin,dymax,dycenter
  int    i,j,k,naps,ncoeffs,npars
  file   infile
  string apfirst,apsecond,apthird,apfourth,apfith,apsixt
  string apfirst2,apsecond2,apthird2,apfourth2,apfith2,apsixt2
  string apdeffile,coeff,low,high,xdum,ydum,reference_bak
  string temp_image_trace = "temp"
  string tempapfile       = "database/aptemp"
  string coeff_file       = "coeffs.temp"
  string aps_ymin_file    = "aps_low.temp"
  string aps_ymax_file    = "aps_high.temp"
  string aps_center_file  = "aps_center.temp"
  string aps_xmin_file    = "aps_xmin.temp"
  string aps_xmax_file    = "aps_xmax.temp"
  string timefile = "time.txt"
  string tempdate,tempday,temptime
  string in,reference_bak_list

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
  print ("*                    tracing apertures                   *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*                    tracing apertures                   *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- Erzeugen von temporaeren Filenamen
  print("sttrace: building temp-filenames")
  if (loglevel > 2)
    print("sttrace: building temp-filenames", >> logfile)
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("sttrace: building lists from temp-files")
  if (loglevel > 2)
    print("sttrace: building lists from temp-files", >> logfile)

  if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
    sections(images, option="root", > infile)
    inputlist = infile
  }
  else{
    if (substr(images,1,1) != "@"){
      print("sttrace: ERROR: "//images//" not found!!!")
      print("sttrace: ERROR: "//images//" not found!!!", >> logfile)
      print("sttrace: ERROR: "//images//" not found!!!", >> errorfile)
      print("sttrace: ERROR: "//images//" not found!!!", >> warningfile)
    }
    else{
      print("sttrace: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
      print("sttrace: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> logfile)
      print("sttrace: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> errorfile)
      print("sttrace: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> warningfile)
    }

# --- clean up
    if (instrument == "echelle")
      echelle.logfile = bak_logfile
    else
      kpnocoude.logfile = bak_logfile
    inputlist       = ""
    aplist          = ""
#   apbaklist         = ""
    coeff_list      = ""
    aps_ymin_list   = ""
    aps_ymax_list   = ""
    aps_center_list = ""
    aps_xmin_list   = ""
    aps_xmax_list   = ""
    timelist        = ""
    delete (infile, ver-, >& "dev$null")
    return
  }

# --- trace apertures
  print("sttrace: ******************* processing files *********************")
  if (loglevel > 2)
    print("sttrace: ******************* processing files *********************", >> logfile)

  while (fscan (inputlist, in) != EOF){

    if (substr(in,strlen(in)-4,strlen(in)) == ".fits")
      in = substr(in,1,strlen(in)-5)

    print("sttrace: in = "//in)
    if (loglevel > 2)
      print("sttrace: in = "//in, >> logfile)

    apdeffile = "database/ap"//in

    if (reference == "" || reference == " "){
      reference = in
    }
# --- test if reference aperture definitions can be accessed
    if (!access("database/ap"//reference)){
      print("sttrace: ERROR: no reference aperture definition for "//reference//" found!!!")
      print("sttrace: ERROR: no reference aperture definition for "//reference//" found!!!", >> logfile)
      print("sttrace: ERROR: no reference aperture definition for "//reference//" found!!!", >> errorfile)
      print("sttrace: ERROR: no reference aperture definition for "//reference//" found!!!", >> warningfile)

# --- aufraeumen
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      inputlist       = ""
      aplist          = ""
#      apbaklist         = ""
      coeff_list      = ""
      aps_ymin_list   = ""
      aps_ymax_list   = ""
      aps_center_list = ""
      aps_xmin_list   = ""
      aps_xmax_list   = ""
      timelist        = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
    reference_bak = reference//".bak"
    if (access("database/ap"//reference_bak))
      delete("database/ap"//reference_bak, ver-)
    copy(in="database/ap"//reference, out="database/ap"//reference_bak)

# --- backup and delete old apdeffile
    if (access(apdeffile)){
      if (access(apdeffile//".bak"))
        delete(apdeffile//".bak", ver-)
      copy(input = apdeffile, output = apdeffile//".bak", ver-)
    }
    
    print("sttrace: processing "//in//", apdeffilefile = "//apdeffile)
    if (loglevel > 1)
      print("sttrace: processing "//in//", apdeffilefile = "//apdeffile, >> logfile)

# --- trace apertures
    if (access(in//".fits")){
      if (access(temp_image_trace//".fits"))
        delete(temp_image_trace//".fits", ver-)
      if (access(tempapfile))
        delete(tempapfile, ver-)
      imcopy(in=in//".fits", 
	     out = temp_image_trace//".fits")
      aptrace(input=temp_image_trace, 
	      apertures = "", 
	      reference = reference, 
	      interact = interactive, 
	      find-, 
	      recenter-, 
	      resize-, 
	      edit = interactive, 
	      trace+, 
	      fittrace+, 
	      line = line, 
	      nsum = nsum, 
	      step = step, 
	      nlost = nlost, 
	      function = function, 
	      order = order, 
	      sample = sample, 
	      naverage = naverage, 
	      niterate = niterate, 
	      low_reject = low_reject, 
	      high_reject = high_reject, 
	      grow = grow)

# --- check traceed apertures
      print("sttrace: checking traced apertures")
      if (access(coeff_file))
        delete(coeff_file,ver-)
      if (access(aps_xmin_file))
	delete(aps_xmin_file,ver-)
      if (access(aps_xmax_file))
        delete(aps_xmax_file,ver-)
      if (access(aps_ymin_file))
	delete(aps_ymin_file,ver-)
      if (access(aps_ymax_file))
        delete(aps_ymax_file,ver-)
      if (access(aps_center_file))
        delete(aps_center_file,ver-)
      if (access(tempapfile)){
        print("sttrace: reading tempapfile")
        aplist = tempapfile

        apfirst  = ""
        apsecond = ""
        apthird  = ""
        apfourth = ""
        apfith   = ""
        apsixt   = ""

        naps = 0

        while (fscan (aplist, apfirst, apsecond, apthird, apfourth, apfith, apsixt) != EOF){
          if (apfirst == "center"){
            naps += 1
            print("sttrace: center of aperture "//naps//": "//apsecond//", "//apthird)
            if (loglevel > 1)
              print("sttrace: center of aperture "//naps//": "//apsecond//", "//apthird, >> loglevel)
            print(apsecond//" "//apthird, >> aps_center_file)
          }
          if (apfirst == "curve"){
            print("sttrace: aperture no = "//naps)
            ncoeffs = int(apsecond)
            for (i=1; i<=4; i+=1){
	      if (fscan (aplist, apfirst) != EOF){
	        if (i == 1){
	          if (int(apfirst) == 1){
	  	    function = "chebyshev"
		  }
	  	  else if (int(apfirst) == 2){
		    function = "legendre"
		  }
		  else if (int(apfirst) == 3){
		    function = "spline3"
		  }
		  else{
		    function = "spline1"
	    	  }
	        print("sttrace: function = "//function)
	        }
	        else if (i == 2){
	          order = int(apfirst)
	      	  print("sttrace: order = "//order)
	        }
	        else if (i == 3){
	          xmin = real(apfirst)
		  print(xmin, >> aps_xmin_file)
	  	  print("sttrace: xmin = "//xmin)
	        }
	        else{
	          xmax = real(apfirst)
		  print(xmin, >> aps_xmax_file)
		  print("sttrace: xmax = "//xmax)
	        }
              }
	      else{
	        print("sttrace: ERROR: cannot read from "//apdef_file)
		print("sttrace: ERROR: cannot read from "//apdef_file, >> logfile)
		print("sttrace: ERROR: cannot read from "//apdef_file, >> errorfile)
		print("sttrace: ERROR: cannot read from "//apdef_file, >> warningfile)
# --- aufraeumen
                if (instrument == "echelle")
                  echelle.logfile = bak_logfile
                else
                  kpnocoude.logfile = bak_logfile
                inputlist       = ""
                aplist          = ""
#                apbaklist         = ""
                coeff_list      = ""
                aps_ymin_list   = ""
                aps_ymax_list   = ""
                aps_center_list = ""
                aps_xmin_list   = ""
                aps_xmax_list   = ""
                timelist        = ""
                delete (infile, ver-, >& "dev$null")
                return
	      }
	    }
	    x = xmin
	    if (access(coeff_file))
	      delete(coeff_file,ver-)
	    if (function == "chebyshev" || function == "legendre"){
	      n = (2.*real(x) - (xmin + xmax)) / (xmax - xmin)
	      print("sttrace: aperture "//naps//": n(x=xmin(="//xmin//")) = "//n//" (should be -1.)")
	      for (i=1;i<=order; i+=1){
		if (fscan (aplist, apfirst) != EOF){
		  print("sttrace: apfirst = "//apfirst)
		  print(apfirst, >> coeff_file)
                }
	      }
# --- calculate ymin and ymax
#     --- n = -1
	      n = -1.
	      if (access(coeff_file))
	        coeff_list = coeff_file
	      else{
	        print("sttrace: ERROR: cannot access "//coeff_file)
		print("sttrace: ERROR: cannot access "//coeff_file, >> logfile)
		print("sttrace: ERROR: cannot access "//coeff_file, >> errorfile)
		print("sttrace: ERROR: cannot access "//coeff_file, >> warningfile)
# --- aufraeumen
                if (instrument == "echelle")
                  echelle.logfile = bak_logfile
                else
                  kpnocoude.logfile = bak_logfile
                inputlist       = ""
                aplist          = ""
#                apbaklist         = ""
                coeff_list      = ""
                aps_ymin_list   = ""
                aps_ymax_list   = ""
                aps_center_list = ""
                aps_xmin_list   = ""
                aps_xmax_list   = ""
                timelist        = ""
                delete (infile, ver-, >& "dev$null")
                return
	      }
	      y = 0.
	      for (k=1; k<=order; k+=1){
		if (fscan (coeff_list,coeff) != EOF){
		  if (k == 1){
		    z = 1
		  }
		  else if (k == 2){
		    z = n
		    z_last = 1
		  }
		  else{
		    z_before_last = z_last
		    z_last = z
		    z = 2.*n*z_last - z_before_last
		  }
		  y = y + (real(coeff) * z)
		  if (k == order){
		    print("sttrace: aperture "//naps//": y(n=-1.) = "//y)
		    if (loglevel > 1)
 		      print("sttrace: aperture "//naps//": y(n=-1.) = "//y, >> logfile)
#		    if (y < 0.)
		      print(y, >> aps_ymin_file)
#		    else
#		      print(y, >> aps_ymax_file)
		  }
		}
		else{
	          print("sttrace: ERROR: cannot read from "//coeff_file)
		  print("sttrace: ERROR: cannot read from "//coeff_file, >> logfile)
		  print("sttrace: ERROR: cannot read from "//coeff_file, >> errorfile)
		  print("sttrace: ERROR: cannot read from "//coeff_file, >> warningfile)
# --- aufraeumen
                  if (instrument == "echelle")
                    echelle.logfile = bak_logfile
                  else
                    kpnocoude.logfile = bak_logfile
                  inputlist       = ""
                  aplist          = ""
#                  apbaklist         = ""
                  coeff_list      = ""
                  aps_ymin_list   = ""
                  aps_ymax_list   = ""
                  aps_center_list = ""
                  aps_xmin_list   = ""
                  aps_xmax_list   = ""
                  timelist        = ""
                  delete (infile, ver-, >& "dev$null")
                  return
		}
	      }
#     --- n = +1
	      n = 1.
	      coeff_list = coeff_file
	      y = 0.
	      for (k=1; k<=order; k+=1){
		if (fscan (coeff_list,coeff) != EOF){
		  if (k == 1){
		    z = 1
		  }
		  else if (k == 2){
		    z = n
		    z_last = 1
		  }
		  else{
		    z_before_last = z_last
		    z_last = z
		    z = 2.*n*z_last - z_before_last
		  }
		  y = y + (real(coeff) * z)
		  if (k == order){
		    print("sttrace: aperture "//naps//": y(n=+1.) = "//y)
		    if (loglevel > 1)
 		      print("sttrace: aperture "//naps//": y(n=+1.) = "//y, >> logfile)
#		    if (y < 0.)
#		      print(y, >> aps_ymin_file)
#		    else
		      print(y, >> aps_ymax_file)
		  }
	        }
		else{
	          print("sttrace: ERROR: cannot read from "//coeff_file)
		  print("sttrace: ERROR: cannot read from "//coeff_file, >> logfile)
		  print("sttrace: ERROR: cannot read from "//coeff_file, >> errorfile)
		  print("sttrace: ERROR: cannot read from "//coeff_file, >> warningfile)
# --- aufraeumen
                  if (instrument == "echelle")
                    echelle.logfile = bak_logfile
                  else
                    kpnocoude.logfile = bak_logfile
                  inputlist       = ""
                  aplist          = ""
#                  apbaklist         = ""
                  coeff_list      = ""
                  aps_ymin_list   = ""
                  aps_ymax_list   = ""
                  aps_center_list = ""
                  aps_xmin_list   = ""
                  aps_xmax_list   = ""
                  timelist        = ""
                  delete (infile, ver-, >& "dev$null")
                  return
		}
	      }
	    }
##	    else if (function == "spline1" || function == "spline3"){
##	      s = (real(x)-xmin) / (xmax-xmin) * order
##	      j = int(s)
##	      if (function == "spline1"){
##	        for (i=1;i<=order+1; i+=1){
##		  fscan (aplist, apfirst)
##		  print(apfirst, >> coeff_file)
##	        }
##		coeff_list = coeff_file
##		y = 0.
##		for (k=1; k<=order+1; k+=1){
##		  fscan (coeff_list,coeff)
##		  if (k == 1){
##		    z = 1
##		  }
##		  else if (k == 2){
##		    z = n
##		    z_last = 1
##	  	  }
##		  else{
##		    z_before_last = z_last
##		    z_last = z
##		    z = 2.*n*z_last - z_before_last
##		  }
##		  y = y + (real(coeff) * z)
##		  print("sttrace: y(n=-1.) = "//y)
##		  print(y, >> aps_ymin_file)
##	        }
##	        else{ // spline3
##	          for (i=1;i<=order+3; i+=1){
##	 	    fscan (aplist, apfirst)
##		    print(apfirst, >> coeff_file)
##	          }
##	        }
##	      } # end if spline1 || spline3
          } # end if apfirst == "curve"

          apfirst  = ""
          apsecond = ""
          apthird  = ""
          apfourth = ""
          apfith   = ""
          apsixt   = ""
        } # end of while fscan tempapfile...
          
      } # end if accessapdeffile
      else{
        print("sttrace: ERROR: cannot access "//apdeffile)
	print("sttrace: ERROR: cannot access "//apdeffile, >> logfile)
	print("sttrace: ERROR: cannot access "//apdeffile, >> errorfile)
	print("sttrace: ERROR: cannot access "//apdeffile, >> warningfile)
# --- aufraeumen
        if (instrument == "echelle")
          echelle.logfile = bak_logfile
        else
          kpnocoude.logfile = bak_logfile
        inputlist       = ""
        aplist          = ""
#        apbaklist         = ""
        coeff_list      = ""
        aps_ymin_list   = ""
        aps_ymax_list   = ""
        aps_center_list = ""
        aps_xmin_list   = ""
        aps_xmax_list   = ""
        timelist        = ""
        delete (infile, ver-, >& "dev$null")
        return
      }

# --- check ymin's and ymsx's
      aps_center_list = aps_center_file
      aps_xmin_list   = aps_xmin_file
      aps_xmax_list   = aps_xmax_file
      aps_ymin_list   = aps_ymin_file
      aps_ymax_list   = aps_ymax_file
      i = 0
      xcenter = 0.
      ycenter = 0.
      xmin = 0.
      xmax = 0.
      ymin = 0.
      ymax = 0.

      aplist = tempapfile
      if (access("database/ap"//reference_bak)){
        print("sttrace: assigning reference_bak to apbaklist")
	reference_bak_list = "database/ap"//reference_bak
	apbaklist = reference_bak_list
        print("sttrace: reference_bak assigned to apbaklist")
      }
      else{
        print("sttrace: ERROR: cannot access database/ap"//reference_bak)
        print("sttrace: ERROR: cannot access database/ap"//reference_bak, >> logfile)
        print("sttrace: ERROR: cannot access database/ap"//reference_bak, >> warningfile)
        print("sttrace: ERROR: cannot access database/ap"//reference_bak, >> errorfile)
      }

      del(apdeffile,ver-)
      if (!access(apdeffile)){
        print("sttrace: old "//apdeffile//" deleted")
        if (loglevel > 2)
          print("sttrace: old "//apdeffile//" deleted", >> logfile)
      }
      else{
        print("sttrace: ERROR: cannot delete old "//apdeffile)
        print("sttrace: ERROR: cannot delete old "//apdeffile, >> logfile)
        print("sttrace: ERROR: cannot delete old "//apdeffile, >> warningfile)
        print("sttrace: ERROR: cannot delete old "//apdeffile, >> errorfile)
      }

      while (fscan(aps_center_list,xdum,ydum) != EOF){

        i += 1
#	print("sttrace: reading line "//i//" from aps_center_list")

# --- write aperture-data file for input image
        for (j=1;j<22;j+=1){
          apfirst  = ""
          apsecond = ""
          apthird  = ""
          apfourth = ""
          apfith   = ""
          apsixt   = ""
	  if (fscan(aplist, apfirst, apsecond, apthird, apfourth, apfith, apsixt) != EOF){
	    if (apfirst == "begin"){
	      print(apfirst//" "//apsecond//" "//in//" "//apfourth//" "//apfith//" "//apsixt, >> apdeffile)
#	      print("sttrace: writing "//apfirst//" "//apsecond//" "//in//" "//apfourth//" "//apfith//" "//apsixt//" to apdeffile")
	    }
	    else if (apfirst == "image"){
	      print(apfirst//" "//in, >> apdeffile)
#	      print("sttrace: writing "//apfirst//" "//in//" to apdeffile")
	    }
	    else if (apfirst == "curve"){
	      npars = int(apsecond)
	      print(apfirst//" "//apsecond, >> apdeffile)
#	      print("sttrace: writing "//apfirst//" "//apsecond//" to apdeffile")
#	      print("sttrace: aperture: "//i//": npars = "//npars)
	    }
	    else{
	      print(apfirst//" "//apsecond//" "//apthird, >> apdeffile)
#	      print("sttrace: writing "//apfirst//" "//apsecond//" "//apthird//" to apdeffile")
	    }
	  }
	  if (fscan(apbaklist, apfirst2, apsecond2, apthird2, apfourth2, apfith2, apsixt2) != EOF){
#	    print("sttrace: reading reference aperture-data file")
	  }
          apfirst  = ""
          apsecond = ""
          apthird  = ""
          apfourth = ""
          apfith   = ""
          apsixt   = ""
	} # end for j=1 j<22 j+=1

        
        xcenter_last = xcenter
        ycenter_last = ycenter

        if (dispaxis == "1"){
          xcenter = real(xdum)
          ycenter = real(ydum)
        }
        else{
          xcenter = real(ydum)
          ycenter = real(xdum)
        }

        xmin_last = xmin
        if (fscan(aps_xmin_list,xdum) != EOF){
          xmin = real(xdum)
        }
        xmax_last = xmax
        if (fscan(aps_xmax_list,xdum) != EOF){
          xmax = real(xdum)
        }

        ymin_last = ymin
        if (fscan(aps_ymin_list,ydum) != EOF){
          ymin = real(ydum)
	  print("sttrace: aperture "//i//": ymin = "//ymin)
        }
        ymax_last = ymax
        if (fscan(aps_ymax_list,ydum) != EOF){
          ymax = real(ydum)
	  print("sttrace: aperture "//i//": ymax = "//ymax)
        }
    
        dycenter = ycenter - ycenter_last

        dymin = ymin - ymin_last
        dymax = ymax - ymax_last

	if ((ymin < yminlimit) ||
	    (ymax > ymaxlimit)){

	  print("sttrace: WARNING: trace of aperture "//i//" failed!!! Using reference aperture data for this aperture")
          print("sttrace:          ycenter = "//ycenter//", ymin = "//ymin//", ymax = "//ymax)
	  print("sttrace: WARNING: trace of aperture "//i//" failed!!! Using reference aperture data for this aperture", >> logfile)
          print("sttrace:          ycenter = "//ycenter//", ymin = "//ymin//", ymax = "//ymax, >> logfile)
	  print("sttrace: WARNING: trace of aperture "//i//" failed!!! Using reference aperture data for this aperture", >> warningfile)
          print("sttrace:          ycenter = "//ycenter//", ymin = "//ymin//", ymax = "//ymax, >> warningfile)
          print("sttrace: aperture: "//i//": npars = "//npars)
	  for (j=1;j<=npars;j+=1){
	    if (fscan(aplist, apfirst) != EOF){
#	      print("sttrace: reading tempapfile")
	    }
	    if (fscan(apbaklist, apfirst2) != EOF){
#	      print("sttrace: writing "//apfirst2//" to apdeffile")
	      print(apfirst2, >> apdeffile)
	    }
	  }

        }
        else{
	  for (j=1;j<=npars;j+=1){
	    if (fscan(apbaklist, apfirst2) != EOF){
#	        print("sttrace: reading refapfile")
	    }
	    if (fscan(aplist, apfirst) != EOF){
#	      print("sttrace: writing "//apfirst//" to apdeffile")
	      print(apfirst, >> apdeffile)
	    }
	  }
          print("sttrace: aperture "//i//": trace successfull")
	  if (loglevel > 2)
            print("sttrace: aperture "//i//": trace successfull", >> logfile)
        }

        if (fscan(apbaklist, apfirst2) != EOF){
#	  print("sttrace: reading apbaklist: apfirst2 = "//apfirst2)
	}
	if (fscan(aplist, apfirst) != EOF){
	  print(apfirst, >> apdeffile)
#	  print("sttrace: reading aplist: apfirst = "//apfirst)
        }

      }

      if (access(timefile))
        del(timefile, ver-)
      time(>> timefile)
      if (access(timefile)){
        timelist = timefile
        if (fscan(timelist,tempday,temptime,tempdate) != EOF){
          hedit(images=in,
                fields="STALL",
                value="sttrace: apertures traced "//tempdate//"T"//temptime,
                add+,
                addonly+,
                del-,
                ver-,
                show+,
                update+)
        }
      }
      else{
        print("sttrace: WARNING: timefile <"//timefile//"> not accessable!")
        print("sttrace: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
        print("sttrace: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
      }

      print("sttrace: -----------------------")
      print("sttrace: -----------------------", >> logfile)
    }
    else{
      print("sttrace: ERROR: cannot access "//in)
      print("sttrace: ERROR: cannot access "//in, >> logfile)
      print("sttrace: ERROR: cannot access "//in, >> errorfile)
      print("sttrace: ERROR: cannot access "//in, >> warningfile)
# --- aufraeumen
      if (instrument == "echelle")
        echelle.logfile = bak_logfile
      else
        kpnocoude.logfile = bak_logfile
      inputlist       = ""
      aplist          = ""
      apbaklist       = ""
      coeff_list      = ""
      aps_ymin_list   = ""
      aps_ymax_list   = ""
      aps_center_list = ""
      aps_xmin_list   = ""
      aps_xmax_list   = ""
      timelist        = ""
      delete (infile, ver-, >& "dev$null")
      return
    }
  } # end of while scan inputlist

  if (access(timefile))
    del(timefile, ver-)
  time(>> timefile)
  if (access(timefile)){
    timelist = timefile
    if (fscan(timelist,tempday,temptime,tempdate) != EOF){
      print("sttrace: sttrace finished "//tempdate//"T"//temptime, >> logfile)
    }
  }
  else{
    print("sttrace: WARNING: timefile <"//timefile//"> not accessable!")
    print("sttrace: WARNING: timefile <"//timefile//"> not accessable!", >> logfile)
    print("sttrace: WARNING: timefile <"//timefile//"> not accessable!", >> warningfile)
  }

# --- aufraeumen
  if (instrument == "echelle")
    echelle.logfile = bak_logfile
  else
    kpnocoude.logfile = bak_logfile
  inputlist       = ""
  aplist          = ""
  apbaklist       = ""
  coeff_list      = ""
  aps_ymin_list   = ""
  aps_ymax_list   = ""
  aps_center_list = ""
  aps_xmin_list   = ""
  aps_xmax_list   = ""
  timelist        = ""
  delete (infile, ver-, >& "dev$null")

end
