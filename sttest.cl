procedure sttest (images)

################################################################
#                                                              #
#    This program tests the STELLA pipeline with different     #
#      values for the parameters given in the pars_to_var      #
#                             file.                            #
#                                                              #
#    Andreas Ritter, 17.02.2005                                #
#                                                              #
# usage: sttest(images = "HD175640.list",images_ecd =          #
#         "objects_botzxsf_ecd.list", par="parameterfile.prop",#
#         parameters_to_var = "pars_to_var.list"               #
#                                                              #
################################################################

string images         = "HD175640.list"            {prompt="List of input images"}
string images_ecd     = "objects_botzxsf_ecd.list" {prompt="List of dispersion corrected object spectra"}
string parameterfile  = "scripts$parameterfiles/parameterfile_UVES_blue_437_2148x3000.prop" {prompt="Parameterfile for test run"}
string pars_to_var    = "pars_to_var.list"             {prompt="File containing list of parameters to vary"}
string *parstovarlist

begin
  string parameter, parameter_value_file
  int    i

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                    testing pipeline                    *")
  print ("*                                                        *")
  print ("**********************************************************")

# --- Test if input files are accessable
  if (!access(images)){
    print ("sttest: ERROR: images file '"//images//"' not accessable => returning")
    return
  }
  if (!access(images_ecd)){
    print ("sttest: ERROR: images file '"//images_ecd//"' not accessable => returning")
    return
  }
  if (!access(parameterfile)){
    print ("sttest: ERROR: images file '"//parameterfile//"' not accessable => returning")
    return
  }
  if (!access(pars_to_var)){
    print ("sttest: ERROR: images file '"//pars_to_var//"' not accessable => returning")
    return
  }

# --- read pars_to_var
  parstovarlist = pars_to_var
  while (fscan(parstovarlist, parameter) != EOF){
    parameter_value_file = parameter//"s.list"
    if (access(parameter_value_file)){
      print("sttest: starting stvaronepar(partotest="//parameter//")")
      stvaronepar(images=images,
                  images_ecd=images_ecd,
                  partotest=parameter,
                  parameterfile=parameterfile,
                  vardatfile=parameter_value_file)
      print("sttest: stvaronepar(partotest="//parameter//") ready")
    }
  }

# --- clean
  print ("sttest: cleaning up")
  parstovarlist    = ""

end
