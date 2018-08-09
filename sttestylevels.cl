procedure sttestylevels (images)

################################################################
#                                                              #
#    This program tests the STELLA pipeline with different     #
#           ylevels for the stextract.cl procedure             #
#                                                              #
#    Andreas Ritter, 08.12.2003                                #
#                                                              #
# usage: sttestylevels(images = "HD175640.list",images_ecd =   #
#         "objects_botzxsf_ecd.list", par="parameterfile.prop",#
#         yleveldatfile = "ylevels.dat"                        #
#                                                              #
################################################################

string images         = "HD175640.list"            {prompt="List of input images"}
string images_ecd     = "objects_botzxsf_ecd.list" {prompt="List of dispersion corrected object spectra"}
string parameterfile  = "scripts$parameterfiles/parameterfile_UVES_blue_437_2148x3000.prop" {prompt="Parameterfile for test run"}
string yleveldatfile  = "ylevels.list"             {prompt="File containing list of ylevels"}
string *inputlist
string *ecdlist
string *ecdslist
string *parameterlist
string *ylevellist

begin
  string parameter, parametervalue, ecdfile, ecdfilelist
  string newecdfile, newparameterfile, ecdsfile, ecdsfilelist
  string ylevel
  int    i
  file   infile

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                    testing pipeline                    *")
  print ("*                                                        *")
  print ("**********************************************************")

# --- read yleveldatfile
  if (access(yleveldatfile)){
    print ("sttestylevels: reading yleveldatfile (="//yleveldatfile//")")
    
    ylevellist = yleveldatfile
    
    while (fscan (ylevellist, ylevel) !=EOF){
      print ("sttestylevels: "//yleveldatfile//": ylevel = "//ylevel)

# --- name new parameterfile
      i = 0
      while (i != strlen(parameterfile)){
        i += 1
        if (substr(parameterfile,i,i+13) == "parameterfile_"){
          newparameterfile = substr(parameterfile,i,strlen(parameterfile)-5)//"_ylevel"//ylevel//".prop"
          i = strlen(parameterfile)
        }
      }
      if (access(newparameterfile))
        delete(newparameterfile, ver-)

# --- read parameterfile
      if (access(parameterfile)){
        parameterlist = parameterfile
        print("sttestylevels: reading parameterfile")
 
        while (fscan(parameterlist, parameter, parametervalue) !=EOF){
          if (parameter == "extylevel"){
            print ("sttestylevels: printing "//parameter//" "//ylevel//" to "//newparameterfile)
            print (parameter//" "//ylevel, >> newparameterfile)
          }
          else{
            print ("sttestylevels: printing "//parameter//" "//parametervalue//" to "//newparameterfile)
            print (parameter//" "//parametervalue, >> newparameterfile)
          }
        }
      }
      else{
        print("sttestylevels: ERROR: cannot access "//parameterfile)
      }
      
# --- starting stall
      print ("sttestylevels: starting stall")
      stall (images = "@"//images, parameterfile = newparameterfile, dostzero-, dostbadover-, dostsubzero-, dostcosmics-, dostscatter-, dostflat-, dostnflat-, doaddheader-, dosetjd-, dostdivflat-, dohedit-, doextractthar+, dostident+, doextractobject+, dostrefspec+, dostdispcor+)

      ecdsfilelist = substr(images_ecd,1,strlen(images_ecd)-5)//"s_ylevel"//ylevel//".list"
      print ("sttestylevels: deleting ecdsfilelist (="//ecdsfilelist//")")
      if (access(ecdsfilelist))
        delete(ecdsfilelist, ver-)
#      infile = mktemp("tmp")
      if (access(images_ecd)){
#        sections("@"//images_ecd, option="root", > infile)
        ecdlist = images_ecd
        ecdfilelist = substr(images_ecd, 1, strlen(images_ecd)-5)//"_ylevel"//ylevel//".list"
        print ("sttestylevels: deleting ecdfilelist (="//ecdfilelist//")")
        if (access(ecdfilelist))
          delete(ecdfilelist, ver-)
        while (fscan (ecdlist,ecdfile) !=EOF){
          print ("sttestylevels: ecdfile = "//ecdfile)
# --- rename dispersion corrected object spectra
          if (substr(ecdfile,strlen(ecdfile)-4,strlen(ecdfile)) == ".fits"){
            newecdfile = substr(ecdfile,1,strlen(ecdfile)-5)//"_ylevel"//ylevel//".fits"
          }
          else{
            newecdfile = ecdfile//"_ylevel"//ylevel//".fits"
          }
          print ("sttestylevels: newecdfile = "//newecdfile)
          print (newecdfile, >> ecdfilelist)
#          if (access(newecdfile)){
            print ("sttestylevels: deleting "//newecdfile)
            imdel (newecdfile, ver-)
            if (access(newecdfile))
              del (newecdfile, ver-)
#          }
#          if (access(newecdfile))
#            print ("sttestylevels: ERROR: newecdfile (="//newecdfile//") is still accessable")
          if (access(ecdfile)){
            print ("sttestylevels: copying ecdfile to newecdfile")
            imcopy(ecdfile, newecdfile)
            if (access(newecdfile))
              print ("sttestylevels: "//newecdfile//" ready")
            else
              print ("sttestylevels: ERROR: "//newecdfile//" not accessable")
          }
          else{
            print ("sttestylevels: ERROR: cannot access "//ecdfile)
          }

# --- write combined-spectra list
          print ("sttestylevels: writing combined-spectra list")
          if (substr(ecdfile,strlen(ecdfile)-4,strlen(ecdfile)) == ".fits"){
            ecdsfile = substr(ecdfile,1,strlen(ecdfile)-5)//"s_ylevel"//ylevel//".fits"
            print (ecdsfile, >> ecdsfilelist)
          }
          else{
	    ecdsfile = ecdfile//"s_ylevel"//ylevel
          }
	  print ("sttestylevels: ecdsfile = "//ecdsfile)
          print (ecdsfile, >> ecdsfilelist)
        }
      }
      else{
        print ("sttestylevels: ERROR: cannot access "//images_ecd)
      }

# --- delete old combined spectra
      print ("sttestylevels: deleting old combined spectra")
      if (access (ecdsfilelist)){
        ecdslist = ecdsfilelist
        while (fscan (ecdslist, ecdsfile) !=EOF){
	  print ("sttestylevels: ecdsfile = "//ecdsfile)
          if (access(ecdsfile)){
            imdel (ecdsfile, ver-)
            if (access(ecdsfile))
              delete(ecdsfile, ver-)
          }
        }
      }
      else{
        print ("sttestylevels: ERROR: cannot access "//ecdsfilelist)
      }

# --- combine dispersion corrected object spectra
      print ("sttestylevels: combining dispersion-corrected object spectra")
      scombine (input = "@"//ecdfilelist, output = "@"//ecdsfilelist, logfile = "STDOUT", group = "images", combine = "median", reject = "avsigclip", first-, w1 = INDEF, w2 = INDEF, dw = INDEF, nw = INDEF, log-, scale = "none", zero = "none", weight = "none", sample = "", lthreshold = INDEF, hthreshold = INDEF, nlow = 3, nhigh = 3, nkeep = 3, mclip+, lsigma = 3., hsigma = 3., rdnoise = "3.9", gain = "0.49", snoise = "0.", sigscale = 0.1, pclip = -0.5, grow = 0, blank = 0.)

# --- copy logfiles
      print ("sttestylevels: copying logfiles")
      if (access("logfile_ylevel"//ylevel//".log"))
        del ("logfile_ylevel"//ylevel//".log", ver-)
      if (access("logfile.log"))
        copy ("logfile.log", "logfile_ylevel"//ylevel//".log", ver-)
      if (access("warnings_ylevel"//ylevel//".log"))
        del ("warnings_ylevel"//ylevel//".log", ver-)
      if (access("warnings.log"))
        copy ("warnings.log", "warnings_ylevel"//ylevel//".log", ver-)
      if (access("errors_ylevel"//ylevel//".log"))
        del ("errors_ylevel"//ylevel//".log", ver-)
      if (access("errors.log"))
        copy ("errors.log", "errors_ylevel"//ylevel//".log", ver-)

    }

  }
  else{
    print ("sttestylevels: ERROR: yleveldatfile "//yleveldatfile//" not found")
  }

# --- clean
  print ("sttestylevels: cleaning")
  inputlist     = ""
  ecdlist       = ""
  ecdslist      = ""
  parameterlist = ""
  ylevellist    = ""

end
