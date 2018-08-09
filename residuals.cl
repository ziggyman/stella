procedure residuals(input, npix)

#################################################################
#                                                               #
#    This program calculates and writes the residual spectra    #
#                        (*_res.text)                           #
#                                                               #
#                                                               #
#    Andreas Ritter, 24.09.2002                                 #
#    last edited: 03.05.2004                                    #
#                                                               #
#################################################################

string input    = "@RXJ_ctcv.text.list"             {prompt="List of input spectra"}
int    npix     = 24711                             {prompt="Minimum number of pixels per spectra"}
#int    npixfirstnight = 7                           {prompt="Number of images of the first night"}
#string output   = "middle.text"                     {prompt="Root spool filename for output"}
string *inputlist


begin

  file   infile
  string in,in1,out,tempout
  int    lauf

# --- load neccessary packages
  onedspec

  if (access("hjds.text"))
   del("hjds.text", ver-)
  if (access("residuals.list"))
   del("residuals.list", ver-)
  if (access("text.list"))
   del("text.list", ver-)

# --- Erzeugen von temporaeren Filenamen
  print("residuals: building temp-filenames")
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("residuals: building lists from temp-files")

  if ((substr(input,1,1) == "@" && access(substr(input,2,strlen(input)))) || (substr(input,1,1) != "@" && access(input))){
    sections(input, option="root", > infile)
    inputlist = infile
  }
  else{
    if (substr(input,1,1) != "@"){
      print("residuals: ERROR: "//input//" not found!!!")
    }
    else{
      print("residuals: ERROR: "//substr(input,2,strlen(input))//" not found!!!")
    }
# --- aufraeumen
    inputlist     = ""
    delete (infile, ver-, >& "dev$null")
    return
  }

# --- build output filenames and correct dispersions
  print("residuals: ******************* processing files *********************")

  if (access("middle.fits"))
   imdel("middle.fits", ver-)
  lauf = 0
  while (fscan (inputlist, in) != EOF){
   lauf = lauf+1
   print("residuals: in = "//in)

   i = strlen(in)
   if (substr (in, i-4, i) == ".fits"){
     out = substr(in, 1, i-5)//".text"
     tempout = substr(in, 1, i-5)//"_temp.fits"
   }
   else{
    out = in//".text"
    tempout = in//"_temp.fits"
   }
   if (access(tempout))
     imdel(tempout, ver-)
   if (access(tempout))
     del(tempout, ver-)

   imcopy(in//"[1:"//npix//",1]", tempout)

#   if (access(out))
#     imdel(out, ver-)
   if (access(out))
     del(out, ver-)
   wspectext(input=tempout, output=out, header-, wformat=" ")
   hedit(images=in, fields="hjd", add-, del-, ver-, show+, up-, >> "hjds.text")
   print (out, >> "text.list")
#   if (lauf == npixfirstnight)
#    print("nextnight", >> "text.list")
   if (lauf == 1){
    in1 = tempout
   }
   else if (lauf == 2){
    
    if (access(tempout) && access(in1)){
     imarith(operand1=in1,
             op="+",
             operand2=tempout, 
             result="middle.fits", 
             title="", 
             divzero=0., 
             hparams="", 
             pixtype="real", 
             calctype="real", 
             ver-, 
             noact-)
    }
    else{
      print("residuals: ERROR: cannot access "//tempout)
    }
   }
   else{
    if (access(tempout)){
     imarith(operand1=tempout,
             op="+",
             operand2="middle.fits", 
             result="middle.fits", 
             title="", 
             divzero=0., 
             hparams="", 
             pixtype="real", 
             calctype="real", 
             ver-, 
             noact-)
    }
    else{
      print("residuals: ERROR: cannot access "//tempout)
    }
   }
  } # end of while(scan(inputlist))

  imarith(operand1="middle.fits",
          op="/",
          operand2=lauf, 
          result="middle.fits", 
          title="", 
          divzero=0., 
          hparams="", 
          pixtype="real", 
          calctype="real", 
          ver-, 
          noact-)
  imstat("middle.fits")

  inputlist = infile
  lauf = 0
  while (fscan (inputlist, in) != EOF){
   lauf = lauf+1
   i = strlen(in)
   if (substr (in, i-4, i) == ".fits"){
     out = substr(in, 1, i-5)//"_res.fits"
     tempout = substr(in, 1, i-5)//"_temp.fits"
   }
   else{
    out = in//"_res.fits"
    tempout = in//"_temp.fits"
   }
   if (access(out))
    imdel(out, ver-)
   if (access(out))
    del(out, ver-)
   if (access(substr(out, 1, strlen(out)-5)//".text"))
    del(substr(out, 1, strlen(out)-5)//".text", ver-)
   print("tempout = "//tempout)
   imarith(operand1=tempout,
           op="-",
           operand2="middle.fits", 
           result=out, 
           title="", 
           divzero=0., 
           hparams="", 
           pixtype="real", 
           calctype="real", 
           ver-, 
           noact-)
   wspectext(input=out, output=substr(out, 1, strlen(out)-5)//".text", header-, wformat=" ")
   print(substr(out, 1, strlen(out)-5)//".text", >> "residuals.list")
#   if (lauf == npixfirstnight)
#    print("nextnight", >> "residuals.list")
   imdel(tempout, ver-)
   if (access(tempout))
     del(tempout, ver-)
  }

# --- aufraeumen
  inputlist     = ""
#  parameterlist = ""
  delete (infile, ver-, >& "dev$null")

end




