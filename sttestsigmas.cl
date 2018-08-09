procedure sttestsigmas (images)

################################################################
#                                                              #
#    This program tests the STELLA pipeline with different     #
#           sigmas for the stextract.cl procedure              #
#                                                              #
#    Andreas Ritter, 08.12.2003                                #
#                                                              #
# usage: sttestsigmas(images = "HD175640.list",images_ecd =    #
#         "objects_botzxsf_ecd.list", par="parameterfile.prop",#
#         sigmadatfile = "sigmas.dat"                          #
#                                                              #
################################################################

string images         = "HD175640.list"            {prompt="List of input images"}
string images_ecd     = "objects_botzxsf_ecd.list" {prompt="List of dispersion corrected object spectra"}
string parameterfile  = "scripts$parameterfiles/parameterfile_UVES_blue_437_2148x3000.prop" {prompt="Parameterfile for test run"}
string sigmadatfile   = "sigmas.list"              {prompt="File containing list of sigmas"}
string *inputlist
string *ecdlist
string *ecdslist
string *parameterlist
string *lsigmalist
string *usigmalist

begin
  string parameter, parametervalue, ecdfile, ecdfilelist
  string newecdfile, newparameterfile, ecdsfile, ecdsfilelist
  string lsigma, usigma
  int    i
  file   infile

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                    testing pipeline                    *")
  print ("*                                                        *")
  print ("**********************************************************")

# --- read sigmadatfile
  if (access(sigmadatfile)){
    print ("sttestsigmas: reading sigmadatfile (="//sigmadatfile//")")
    
    lsigmalist = sigmadatfile
    
    while (fscan (lsigmalist, lsigma) !=EOF){
      print ("sttestsigmas: "//sigmadatfile//": lsigma = "//lsigma)
      usigmalist = sigmadatfile
      while (fscan (usigmalist, usigma) !=EOF){
        print ("sttestsigmas: "//sigmadatfile//": usigma = "//usigma)

# --- name new parameterfile
        i = 0
	while (i != strlen(parameterfile)){
          i += 1
	  if (substr(parameterfile,i,i+13) == "parameterfile_"){
	    newparameterfile = substr(parameterfile,i,strlen(parameterfile)-5)//"_lsigma"//lsigma//"_usigma"//usigma//".prop"
	    i = strlen(parameterfile)
	  }
        }
        if (access(newparameterfile))
          delete(newparameterfile, ver-)

# --- read parameterfile
        if (access(parameterfile)){
          parameterlist = parameterfile
          print("sttestsigmas: reading parameterfile")

          while (fscan(parameterlist, parameter, parametervalue) !=EOF){
            if (parameter == "extlsigma"){
              print ("sttestsigmas: printing "//parameter//" "//lsigma//" to "//newparameterfile)
              print (parameter//" "//lsigma, >> newparameterfile)
            }
            else if (parameter == "extusigma"){
              print ("sttestsigmas: printing "//parameter//" "//usigma//" to "//newparameterfile)
              print (parameter//" "//usigma, >> newparameterfile)
            }
            else{
              print ("sttestsigmas: printing "//parameter//" "//parametervalue//" to "//newparameterfile)
              print (parameter//" "//parametervalue, >> newparameterfile)
            }
          }
        }
        else{
          print("sttestsigmas: ERROR: cannot access "//parameterfile)
        }
      
# --- starting stall
        print ("sttestsigmas: starting stall")
        stall (images = "@"//images, parameterfile = newparameterfile, dostzero-, dostbadover-, dostsubzero-, dostcosmics-, dostscatter-, dostflat-, dostnflat+, doaddheader+, dosetjd+, dostdivflat+, dohedit+, doextractthar+, dostident+, doextractobject+, dostrefspec+, dostdispcor+)

        ecdsfilelist = substr(images_ecd,1,strlen(images_ecd)-5)//"s_lsigma"//lsigma//"_usigma"//usigma//".list"
        print ("sttestsigmas: deleting ecdsfilelist (="//ecdsfilelist//")")
        if (access(ecdsfilelist))
          delete(ecdsfilelist, ver-)
#      infile = mktemp("tmp")
        if (access(images_ecd)){
#        sections("@"//images_ecd, option="root", > infile)
          ecdlist = images_ecd
          ecdfilelist = substr(images_ecd, 1, strlen(images_ecd)-5)//"_lsigma"//lsigma//"_usigma"//usigma//".list"
          print ("sttestsigmas: deleting ecdfilelist (="//ecdfilelist//")")
          if (access(ecdfilelist))
            delete(ecdfilelist, ver-)
          while (fscan (ecdlist,ecdfile) !=EOF){
            print ("sttestsigmas: ecdfile = "//ecdfile)
# --- rename dispersion corrected object spectra
            if (substr(ecdfile,strlen(ecdfile)-4,strlen(ecdfile)) == ".fits"){
              newecdfile = substr(ecdfile,1,strlen(ecdfile)-5)//"_ls"//lsigma//"_us"//usigma//".fits"
            }
            else{
              newecdfile = ecdfile//"_ls"//lsigma//"_us"//usigma//".fits"
            }
            print ("sttestsigmas: newecdfile = "//newecdfile)
            print (newecdfile, >> ecdfilelist)
            if (access(newecdfile)){
              print ("sttestsigmas: deleting "//newecdfile)
            imdel (newecdfile, ver-)
            if (access(newecdfile))
              del (newecdfile, ver-)
            }
            if (access(newecdfile))
              print ("sttestsigmas: ERROR: newecdfile (="//newecdfile//") is still accessable")
            if (access(ecdfile)){
              print ("sttestsigmas: copying ecdfile to newecdfile")
              imcopy(ecdfile, newecdfile)
              if (access(newecdfile))
                print ("sttestsigmas: "//newecdfile//" ready")
              else
                print ("sttestsigmas: ERROR: "//newecdfile//" not accessable")
            }
            else{
              print ("sttestsigmas: ERROR: cannot access "//ecdfile)
            }

# --- write combined-spectra list
            print ("sttestsigmas: writing combined-spectra list")
            if (substr(ecdfile,strlen(ecdfile)-4,strlen(ecdfile)) == ".fits"){
              ecdsfile = substr(ecdfile,1,strlen(ecdfile)-5)//"s_lsigma"//lsigma//"_usigma"//usigma//".fits"
              print (ecdsfile, >> ecdsfilelist)
            }
            else{
	      ecdsfile = ecdfile//"s_lsigma"//lsigma//"_usigma"//usigma
            }
	    print ("sttestsigmas: ecdsfile = "//ecdsfile)
            print (ecdsfile, >> ecdsfilelist)
          }
        }
        else{
          print ("sttestsigmas: ERROR: cannot access "//images_ecd)
        }

# --- delete old combined spectra
        print ("sttestsigmas: deleting old combined spectra")
        if (access (ecdsfilelist)){
          ecdslist = ecdsfilelist
          while (fscan (ecdslist, ecdsfile) !=EOF){
	    print ("sttestsigmas: ecdsfile = "//ecdsfile)
            if (access(ecdsfile)){
              imdel (ecdsfile, ver-)
              if (access(ecdsfile))
                delete(ecdsfile, ver-)
            }
          }
        }
        else{
          print ("sttestsigmas: ERROR: cannot access "//ecdsfilelist)
        }

# --- combine dispersion corrected object spectra
        print ("sttestsigmas: combining dispersion-corrected object spectra")
        scombine (input = "@"//ecdfilelist, 
		  output = "@"//ecdsfilelist, 
		  logfile = "STDOUT", 
		  group = "images", 
		  combine = "median", 
		  reject = "avsigclip", 
		  first-, 
		  w1 = INDEF, 
		  w2 = INDEF, 
		  dw = INDEF, 
		  nw = INDEF, 
		  log-, 
		  scale = "none", 
		  zero = "none", 
		  weight = "none", 
		  sample = "", 
		  lthreshold = INDEF, 
		  hthreshold = INDEF, 
		  nlow = 3, 
		  nhigh = 3, 
		  nkeep = 3, 
		  mclip+, 
		  lsigma = 3., 
		  hsigma = 3., 
		  rdnoise = "3.9", 
		  gain = "0.49", 
		  snoise = "0.", 
		  sigscale = 0.1, 
		  pclip = -0.5, 
		  grow = 0, 
		  blank = 0.)

# --- copy logfiles
        print ("sttestsigmas: copying logfiles")
        if (access("logfile_lsigma"//lsigma//"_usigma"//usigma//".log"))
          del ("logfile_lsigma"//lsigma//"_usigma"//usigma//".log", ver-)
        if (access("logfile.log"))
          copy ("logfile.log", "logfile_lsigma"//lsigma//"_usigma"//usigma//".log", ver-)
        if (access("warnings_lsigma"//lsigma//"_usigma"//usigma//".log"))
          del ("warnings_lsigma"//lsigma//"_usigma"//usigma//".log", ver-)
        if (access("warnings.log"))
          copy ("warnings.log", "warnings_lsigma"//lsigma//"_usigma"//usigma//".log", ver-)
        if (access("errors_lsigma"//lsigma//"_usigma"//usigma//".log"))
          del ("errors_lsigma"//lsigma//"_usigma"//usigma//".log", ver-)
        if (access("errors.log"))
          copy ("errors.log", "errors_lsigma"//lsigma//"_usigma"//usigma//".log", ver-)

      }
    }
  }
  else{
    print ("sttestsigmas: ERROR: sigmadatfile "//sigmadatfile//" not found")
  }

# --- clean
  print ("sttestsigmas: cleaning")
  inputlist     = ""
  ecdlist       = ""
  ecdslist      = ""
  parameterlist = ""
  lsigmalist    = ""
  usigmalist    = ""

end
