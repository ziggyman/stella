procedure stvaronepar (images)

################################################################
#                                                              #
#     This program tests the STELLA pipeline with different    #
#              values for the parameter to test                #
#                                                              #
#    Andreas Ritter, 08.12.2003                                #
#                                                              #
# usage: stvaronepar(images = "HD175640.list",images_ecd =     #
#         "objects_botzxsf_ecd.list", par="parameterfile.prop",#
#         yleveldatfile = "ylevels.dat"                        #
#                                                              #
################################################################

string images         = "HD175640.list"            {prompt="List of input images"}
string images_ecd     = "objects_botzxsf_ecd.list" {prompt="List of dispersion corrected object spectra"}
string partotest      = "ext_ylevel"                   {prompt="Name of parameter to test"}
string parameterfile  = "scripts$parameterfiles/parameterfile_UVES_blue_437_2148x3000.prop" {prompt="Parameterfile for test run"}
string vardatfile     = "ylevels.list"             {prompt="File containing list of parameter data"}
string *inputlist
string *ecdlist
string *ecdslist
string *parameterlist
string *datlist

begin
  string parameter, parametervalue, ecdfile, ecdfilelist
  string newecdfile, newparameterfile, mergedfile,newmergedfile
  string parval
  int    i
  file   infile

  flpr

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                    testing pipeline                    *")
  print ("*                                                        *")
  print ("**********************************************************")

# --- read vardatfile
  if (access(vardatfile)){
    print ("stvaronepar: reading vardatfile (="//vardatfile//")")
    
    datlist = vardatfile
    
    if (!access(partotest))
      mkdir(partotest)

    while (fscan (datlist, parval) !=EOF){
      print ("stvaronepar: "//vardatfile//": parval = "//parval)

      if(substr(parval,1,1) != "#"){
# --- name new parameterfile
        i = 0
        while (i != strlen(parameterfile)){
          i += 1
          if (substr(parameterfile,i,i+13) == "parameterfile_"){
            newparameterfile = partotest//"/"//substr(parameterfile,i,strlen(parameterfile)-5)//"_"//partotest//"_"//parval//".prop"
            i = strlen(parameterfile)
          }
        }
        if (access(newparameterfile))
          delete(newparameterfile, ver-)

# --- read parameterfile
        if (access(parameterfile)){
          parameterlist = parameterfile
          print("stvaronepar: reading parameterfile")
 
          while (fscan(parameterlist, parameter, parametervalue) !=EOF){
            if (parameter == partotest){
              print ("stvaronepar: printing "//parameter//" "//parval//" to "//newparameterfile)
              print (parameter//" "//parval, >> newparameterfile)
            }
            else{
              print ("stvaronepar: printing "//parameter//" "//parametervalue//" to "//newparameterfile)
              print (parameter//" "//parametervalue, >> newparameterfile)
            }
#	    if (strpos(partotest,"ylevel") >= 0){
#              print ("stvaronepar: strpos("//partotest//",ylevel) >= 0 returned TRUE!!!")
#            }
          }
        }
        else{
          print("stvaronepar: ERROR: cannot access "//parameterfile)
        }
      
# --- starting stall
        print ("stvaronepar: starting stall")
        stall (images = "@"//images, 
               parameterfile = newparameterfile, 
               dostprepare+, 
               dostzero+, 
               dostbadover+, 
               dostsubzero+, 
               dostflat+, 
               dostscatter+, 
               dostnflat+, 
               dostdivflat+, 
               dostcosmics+, 
               doextractthar+, 
               dostident+, 
               doextractobject+, 
               dostrefspec+, 
               dostdispcor+,
               dostmerge+,
               delinputfiles-,
               deleteoldlogfiles+)

        if (access(images_ecd)){
          ecdlist = images_ecd
          ecdfilelist = substr(images_ecd, 1, strlen(images_ecd)-5)//"_"//partotest//"_"//parval//".list"
          print ("stvaronepar: deleting ecdfilelist (="//ecdfilelist//")")
          if (access(ecdfilelist))
            delete(ecdfilelist, ver-)
          while (fscan (ecdlist,ecdfile) !=EOF){
            print ("stvaronepar: ecdfile = "//ecdfile)
# --- rename dispersion corrected object spectra
            if (substr(ecdfile,strlen(ecdfile)-4,strlen(ecdfile)) == ".fits"){
              newecdfile = partotest//"/"//substr(ecdfile,1,strlen(ecdfile)-5)//"_"//partotest//"_"//parval//".fits"
            }
            else{
              newecdfile = partotest//"/"//ecdfile//"_"//partotest//"_"//parval//".fits"
            }
            print ("stvaronepar: newecdfile = "//newecdfile)
            print (newecdfile, >> ecdfilelist)
            if (access(newecdfile)){
              print ("stvaronepar: deleting "//newecdfile)
              imdel (newecdfile, ver-)
              if (access(newecdfile))
                del (newecdfile, ver-)
            }
            if (access(ecdfile)){
              print ("stvaronepar: copying ecdfile to newecdfile")
              imcopy(ecdfile, newecdfile)
              if (access(newecdfile))
                print ("stvaronepar: "//newecdfile//" ready")
              else
                print ("stvaronepar: ERROR: "//newecdfile//" not accessable")
            }
            else{
              print ("stvaronepar: ERROR: cannot access "//ecdfile)
            }

# --- write combined-spectra list
            print ("stvaronepar: writing combined-spectra list")
            if (substr(ecdfile,strlen(ecdfile)-4,strlen(ecdfile)) == ".fits"){
              mergedfile = substr(ecdfile,1,strlen(ecdfile)-5)//"_merged.fits"
              newmergedfile = substr(ecdfile,1,strlen(ecdfile)-5)//"_merged_"//partotest//"_"//parval//".fits"
            }
            else{
	      mergedfile = partotest//"/"//ecdfile//"_merged"
	      newmergedfile = partotest//"/"//ecdfile//"_merged_"//partotest//"_"//parval
            }
	    print ("stvaronepar: mergedfile = "//mergedfile)
            if (access(newmergedfile))
              del(newmergedfile, ver-)
            imcopy(input=mergedfile, output=newmergedfile, ver-)
          }
        }
        else{
          print ("stvaronepar: ERROR: cannot access "//images_ecd)
        }

# --- copy logfiles
        print ("stvaronepar: copying logfiles")
        if (access(partotest//"/logfile_"//partotest//"_"//parval//".log"))
          del (partotest//"/logfile_"//partotest//"_"//parval//".log", ver-)
        if (access("logfile.log"))
          copy ("logfile.log", partotest//"/logfile_"//partotest//"_"//parval//".log", ver-)
        if (access(partotest//"/warnings_"//partotest//"_"//parval//".log"))
          del (partotest//"/warnings_"//partotest//"_"//parval//".log", ver-)
        if (access("warnings.log"))
          copy ("warnings.log", partotest//"/warnings_"//partotest//"_"//parval//".log", ver-)
        if (access(partotest//"/errors_"//partotest//"_"//parval//".log"))
          del (partotest//"/errors_"//partotest//"_"//parval//".log", ver-)
        if (access("errors.log"))
          copy ("errors.log", partotest//"/errors_"//partotest//"_"//parval//".log", ver-)

        flpr
        flpr
      }#end of if (substr(parval,1,1) != "#")
    }#end of while (fscan (datlist, parval) !=EOF)

  }
  else{
    print ("stvaronepar: ERROR: vardatfile "//vardatfile//" not found")
  }

# --- clean
  print ("stvaronepar: cleaning")
  inputlist     = ""
  ecdlist       = ""
  ecdslist      = ""
  parameterlist = ""
  datlist    = ""

end
