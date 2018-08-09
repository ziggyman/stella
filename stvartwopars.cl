procedure stvartwopars (images)

################################################################
#                                                              #
#     This program tests the STELLA pipeline with different    #
#             values for both parameters to test               #
#                                                              #
#    Andreas Ritter, 08.12.2003                                #
#                                                              #
# usage: stvartwopars(images = "HD175640.list",images_ecd =    #
#        "objects_botzxsf_ecd.list",paronetotest="zero_lsigma",#
#        partwototest="zero_hsigma",parameterfile=             #
#        "parameterfile.prop",paronedatfile="zero_lsigmas.dat",#
#        partwodatfile="zero_hsigmas.dat"                      #
#                                                              #
################################################################

string images         = "HD175640.list"            {prompt="List of input images"}
string images_ecd     = "objects_botzxsf_ecd.list" {prompt="List of dispersion corrected object spectra"}
string paronetotest   = "zero_lsigma"              {prompt="Name of 1st parameter to var"}
string partwototest   = "zero_hsigma"              {prompt="Name of 2nd parameter to var"}
string parameterfile  = "scripts$parameterfiles/parameterfile_UVES_blue_437_2148x3000.prop" {prompt="Parameterfile for test run"}
string varonedatfile  = "zero_lsigmas.list"        {prompt="File containing list of parameter data for 1st parameter"}
string vartwodatfile  = "zero_hsigmas.list"        {prompt="File containing list of parameter data for 2st parameter"}
string *inputlist
string *parameterlist
string *datlist
begin
  string parameter, parametervalue
  string newecdfile, newparameterfile
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

# --- read varonedatfile
  if (access(varonedatfile)){
    print ("stvartwopars: reading varonedatfile (="//varonedatfile//")")
    
    datlist = varonedatfile
    
    if (!access(paronetotest))
      mkdir(paronetotest)

    while (fscan (datlist, parval) !=EOF){
      print ("stvartwopars: "//varonedatfile//": parval = "//parval)
      
      if (substr(parval,1,1) != "#"){
# --- name new parameterfile
        i = 0
        while (i != strlen(parameterfile)){
          i += 1
          if (substr(parameterfile,i,i+13) == "parameterfile_"){
            newparameterfile = paronetotest//"/"//substr(parameterfile,i,strlen(parameterfile)-5)//"_"//paronetotest//"_"//parval//".prop"
            i = strlen(parameterfile)
          }
        }
        if (access(newparameterfile))
          delete(newparameterfile, ver-)

# --- read parameterfile
        if (access(parameterfile)){
          parameterlist = parameterfile
          print("stvartwopars: reading parameterfile")
 
          while (fscan(parameterlist, parameter, parametervalue) !=EOF){
            if (parameter == paronetotest){
              print ("stvartwopars: printing "//parameter//" "//parval//" to "//newparameterfile)
              print (parameter//" "//parval, >> newparameterfile)
            }
            else{
              print ("stvartwopars: printing "//parameter//" "//parametervalue//" to "//newparameterfile)
              print (parameter//" "//parametervalue, >> newparameterfile)
            }
          }
        }
        else{
          print("stvartwopars: ERROR: cannot access "//parameterfile)
        }
      
# --- starting stvaronepar
        print ("stvartwopars: starting stvaronepar")
        stvaronepar (images = images,
                     images_ecd = images_ecd,
                     partotest = partwototest, 
	             parameterfile = newparameterfile, 
                     vardatfile = vartwodatfile)

        if (access(partwototest)){
          if (!access(paronetotest//"/"//parval))
            mkdir(paronetotest//"/"//parval)
          move(partwototest,paronetotest//"/"//parval//"/") 
        }
        else{
          print ("stvartwopars: ERROR: cannot access directory "//vartwototest)
        }

# --- copy logfiles
        print ("stvartwopars: copying logfiles")
        if (access(paronetotest//"/logfile_"//paronetotest//"_"//parval//".log"))
          del (paronetotest//"/logfile_"//paronetotest//"_"//parval//".log", ver-)
        if (access("logfile.log"))
          copy ("logfile.log", paronetotest//"/logfile_"//paronetotest//"_"//parval//".log", ver-)
        if (access(paronetotest//"/warnings_"//paronetotest//"_"//parval//".log"))
          del (paronetotest//"/warnings_"//paronetotest//"_"//parval//".log", ver-)
        if (access("warnings.log"))
          copy ("warnings.log", paronetotest//"/warnings_"//paronetotest//"_"//parval//".log", ver-)
        if (access(paronetotest//"/errors_"//paronetotest//"_"//parval//".log"))
          del (paronetotest//"/errors_"//paronetotest//"_"//parval//".log", ver-)
        if (access("errors.log"))
         copy ("errors.log", paronetotest//"/errors_"//paronetotest//"_"//parval//".log", ver-)

        flpr
        flpr
      }#end of if (substr(parval,1,1) != "#")
    }#end of while (fscan (datlist, parval) !=EOF)

  }
  else{
    print ("stvartwopars: ERROR: varonedatfile "//varonedatfile//" not found")
  }

# --- clean
  print ("stvartwopars: cleaning")
  inputlist     = ""
  parameterlist = ""
  datlist    = ""

end
