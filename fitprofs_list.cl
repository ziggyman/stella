procedure fitprofs_list (images, datatab)

string images = "@RXJ_ctc.list"                   {prompt="List of input images"}
string datatab = "disc_lines_to_fit_ranges.dat"   {prompt="Data file"}
int    dispaxis = 2                               {prompt="Image axis for 2D/3D images (1-horizontal, 2-vertical)"}
int    nsum     = 1                               {prompt="Number of lines/columns to sum for 2D/3D images"}
string logfile = "logfile_fitprofs.log"           {prompt="Log file"}
string warningfile = "warnings_fitprofs.log"      {prompt="Warning file"}
string errorfile = "errors_fitprofs.log"          {prompt="Error file"}
string *datalist
string *imagelist

begin
  file datafile
  file imagefile
  string restwavelengths = "rest_wavelengths.dat"
  string positions       = "positions.dat"
  string logfile_fitprofs = "logfile_fitprofs_temp.log"
  string outputlist
  string plotfile
  string image, lambdastr, lambdaminstr, lambdamaxstr, heightstr, myprofile, fwhmstr
  real   lambda, lambdamin, lambdamax, height, fwhm

# --- load necessary packages
  onedspec

# --- delete old logfiles
  print("fitprofs_list: deleting old logfiles")
  if (access(logfile))
    del(logfile, ver-)
  if (access(warningfile))
    del(warningfile, ver-)
  if (access(errorfile))
    del(errorfile, ver-)
  if (access(restwavelengths))
    del(restwavelengths, ver-)
  print("fitprofs_list: old logfiles deleted")

  if (access(datatab)){
    datalist = datatab
  }
  else{
    if (substr(datatab,1,1) != "@"){
      print("fitprofs_list: ERROR: "//datatab//" not found!!!")
      print("fitprofs_list: ERROR: "//datatab//" not found!!!", >> logfile)
      print("fitprofs_list: ERROR: "//datatab//" not found!!!", >> errorfile)
      print("fitprofs_list: ERROR: "//datatab//" not found!!!", >> warningfile)
    }
    else{
      print("fitprofs_list: ERROR: "//substr(datatab,2,strlen(datatab))//" not found!!!")
      print("fitprofs_list: ERROR: "//substr(datatab,2,strlen(datatab))//" not found!!!", >> logfile)
      print("fitprofs_list: ERROR: "//substr(datatab,2,strlen(datatab))//" not found!!!", >> errorfile)
      print("fitprofs_list: ERROR: "//substr(datatab,2,strlen(datatab))//" not found!!!", >> warningfile)
    }

# --- clean up
    datalist = ""
    return
  }

# --- read imagelist
  while (fscan(datalist, lambdastr, lambdaminstr, lambdamaxstr, heightstr, myprofile, fwhmstr) != EOF){
    if (substr(lambdastr,1,1) != "#"){
      lambda = real(lambdastr)
      lambdamin = real(lambdaminstr)
      lambdamax = real(lambdamaxstr)
      height = real(heightstr)
      fwhm = real(fwhmstr)
      print(lambda, >> restwavelengths)
#      print("lambda = "//lambda//", lambdamin = "//lambdamin//", lambdamax = "//lambdamax//", height = "//height//", myprofile = "//myprofile//", fwhm = "//fwhm)
      if (access(positions))
        del(positions, ver-)
      print(lambdastr//" "//heightstr//" "//myprofile//" "//fwhmstr, >> positions)
      plotfile = substr(images, 2, strlen(images)-5)//"_"//lambda//".fits"
      if (access(plotfile))
        del(plotfile, ver-)
      outputlist = "fitprofs_output_"//lambda//".list"
      if (access(outputlist))
        del(outputlist, ver-)
      imagefile = mktemp("tmp")
      if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
        sections(images, option="root", > imagefile)
        imagelist = imagefile
      }
      else{
        if (substr(images,1,1) != "@"){
          print("fitprofs_list: ERROR: "//images//" not found!!!")
          print("fitprofs_list: ERROR: "//images//" not found!!!", >> logfile)
          print("fitprofs_list: ERROR: "//images//" not found!!!", >> errorfile)
          print("fitprofs_list: ERROR: "//images//" not found!!!", >> warningfile)
        }
        else{
          print("fitprofs_list: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
          print("fitprofs_list: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> logfile)
          print("fitprofs_list: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> errorfile)
          print("fitprofs_list: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> warningfile)
        }

# --- clean up
        datalist = ""
        return
      }
      while(fscan(imagelist, image) != EOF){
        print(substr(image, 1, strlen(image)-5)//"_"//lambda//".fits", >> outputlist)
      }
      print("fitprofs_list: starting fitprofs for lambda="//lambda)
      logfile_fitprofs = "logfile_fitprofs_"//lambda//".dat"
      if (access(logfile_fitprofs))
        del(logfile_fitprofs, ver-)
      fitprofs(input = images,
               lines = "",
               bands = "",
               dispaxis = dispaxis,
               nsum = nsum,
               region = lambdamin//" "//lambdamax,
               positions = positions,
               background = "",
               profile = myprofile,
               gfwhm = fwhm,
               lfwhm = 20.,
               fitbackgroun+,
               fitpositions = "all",
               fitgfwhm = "all",
               fitlfwhm = "all",
               nerrsample = 100,
               sigma0 = INDEF,
               invgain = INDEF,
               components = "",
               verbose+,
               logfile = logfile_fitprofs,
               plotfile = plotfile,
               output = outputlist,
               option = "fit",
               clobber+,
               merge-)
      print("fitprofs_list: fitprofs for lambda="//lambda//" ready")
      less(logfile_fitprofs, >> logfile)
    }
    else{
      print("fitprofs_list: comment line detected: lambdastr = "//lambdastr)
    }
  }

# --- clean up
  imagelist = ""
  datalist = ""
end
