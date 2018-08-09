procedure pedestrial(input,pedpercent)

#################################################################
#                                                               #
#     This program calculates heliocentric radial velocities    #
#                  for a list of inputspectra                   #
#                                                               #
#    Andreas Ritter, 24.05.2002                                 #
#                                                               #
#################################################################

string input                          {prompt="List of input spectra"}
real   pedpercent = 6.2               {prompt="Pedestrial light in %"}
string *inputlist

begin

  file   infile
  string in,out,temp1,temp2
  real   op2

  op2 = 1.+(pedpercent / 100.)
# --- Erzeugen von temporaeren Filenamen
  print("pedestrial: building temp-filenames")
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("pedestrial: building lists from temp-files")

  if ((substr(input,1,1) == "@" && access(substr(input,2,strlen(input)))) || (substr(input,1,1) != "@" && access(input))){
    sections(input, option="root", > infile)
    inputlist = infile
  }
  else{
    if (substr(input,1,1) != "@"){
      print("pedestrial: ERROR: "//input//" not found!!!")
    }
    else{
      print("pedestrial: ERROR: "//substr(input,2,strlen(input))//" not found!!!")
    }
# --- aufraeumen
    inputlist     = ""
    delete (infile, ver-, >& "dev$null")
    return
  }

# --- build output filenames and correct dispersions
  print("pedestrial: ******************* processing files *********************")

  while (fscan (inputlist, in) != EOF){

    print("pedestrial: in = "//in)

    i = strlen(in)
    if (substr (in, i-4, i) == ".fits")
      out = substr(in, 1, i-5)//"p.fits"
    else out = in//"p"

    if (access(out)){
      imdel(out,ver-)
      print("pedestrial: old "//out//" deleted")
    }
    
    print("pedestrial: processing "//in)

    if (access(in)){

      imarith(operand1="1", op="-", operand2=in, result="temp1", title="", divzero=0., hparams="", pixtype="", calctyp="", ver-, noact-)
      imarith(operand1="temp1", op="*", operand2=op2, result="temp2", title="", divzero=0., hparams="", pixtype="", calctyp="", ver-, noact-)
      imarith(operand1=1, op="-", operand2="temp2", result=out, title="", divzero=0., hparams="", pixtype="", calctyp="", ver-, noact-)

      imdel ("temp1", ver-)
      imdel ("temp2", ver-)

      print("pedestrial: ----------- "//out//" ready ------------")
    }
    else{
      print("pedestrial: ERROR: cannot access "//in)
    }
  } # end of while(scan(inputlist))

# --- aufraeumen
  inputlist     = ""
  delete (infile, ver-, >& "dev$null")

end




