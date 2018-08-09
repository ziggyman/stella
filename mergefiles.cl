procedure mergefiles(input,output)

#################################################################
#                                                               #
#     This program merges the input spectra (*.text) to the     #
#                         output file                           #
#                                                               #
#    Andreas Ritter, 24.09.2002                                 #
#                                                               #
#################################################################

string input    = "@ctc.list"                       {prompt="List of input spectra"}
string output   = "fxcor_RXJ_l.txt"                 {prompt="Root spool filename for output"}
string *inputlist


begin

  file   infile
  string in,out,out1
  int    lauf
  task   $paste   = "$foreign"

# --- Erzeugen von temporaeren Filenamen
  print("mergefiles: building temp-filenames")
  infile = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("mergefiles: building lists from temp-files")

  if ((substr(input,1,1) == "@" && access(substr(input,2,strlen(input)))) || (substr(input,1,1) != "@" && access(input))){
    sections(input, option="root", > infile)
    inputlist = infile
  }
  else{
    if (substr(input,1,1) != "@"){
      print("mergefiles: ERROR: "//input//" not found!!!")
    }
    else{
      print("mergefiles: ERROR: "//substr(input,2,strlen(input))//" not found!!!")
    }
# --- aufraeumen
    inputlist     = ""
    delete (infile, ver-, >& "dev$null")
    return
  }

# --- build output filenames and correct dispersions
  print("mergefiles: ******************* processing files *********************")

  lauf = 0
  while (fscan (inputlist, in) != EOF){
    lauf = lauf+1
    print("mergefiles: in = "//in)

    i = strlen(in)
    if (lauf > 1){
     if (substr (in, i-4, i) == ".fits")
       out = substr(in, 1, i-5)//"_1d.txt"
     else out = in//"_1d.txt"
    }
    else{
     if (substr (in, i-4, i) == ".fits")
       out = substr(in, 1, i-5)//"_2d.txt"
     else
        out = in//"_2d.txt"
     out1 = out   
    }

    if (access(out)){
      imdel(out,ver-)
      print("mergefiles: old "//out//" deleted")
      if (loglevel > 2)
        print("mergefiles: old "//out//" deleted", >> logfile)
    }
    
    print("mergefiles: processing "//in//")

    if (access(in)){

     if (lauf == 1){
      onedspec.wspectext(input=in, output=out, header-, wformat=" ")
     }
     else{
      dataio.wtextimage(input=in, output=out, header-, pixels+, format="", maxline=15)
      paste(out1,out)
     }
     print("mergefiles: ----------- "//out//" ready ------------")
    }
    else{
      print("mergefiles: ERROR: cannot access "//in)
    }
  } # end of while(scan(inputlist))

# --- aufraeumen
  inputlist     = ""
#  parameterlist = ""
  delete (infile, ver-, >& "dev$null")

end




