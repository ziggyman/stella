procedure comparecals(goodcals,imhout)

#########################################################################
#                                                                       #
# NAME:                  comparecals                                    #
# PURPOSE:               * ...                                #
#                                                                       #
# CATEGORY:                                                             #
# CALLING SEQUENCE:      comparecals(String: goodcals)                     #
# INPUTS:                input file:  #
#                                                  file                 #
#                                                                       #
#                        output: Integer 'nlines'                      #
# OUTPUTS:               outfile:                                       #
#                                                                       #
# IRAF VERSION:          2.11                                           #
#                                                                       #
# COPYRIGHT:             Andreas Ritter                                 #
# CONTACT:               aritter@aip.de                                 #
#                                                                       #
# LAST EDITED:           24.04.2006                                     #
#                                                                       #
#########################################################################

string goodcals    = "goodcalfiles.list"              {prompt="Name of goodcals to find number of orders"}
string imhout      = "imhead_output.text"          {prompt="Name of imhead-output file"}
string imtype       = "fits"                       {prompt="Image type"}
#string outfile      = ".list"              {prompt="Name of outfile"}
string logfile     = "logfile_comparecals.log"   {prompt="Name of logfile"}
string warningfile = "warnings_comparecals.log"  {prompt="Name of warning file"}
#string errorfile   = "errors_comparecals.log"    {prompt="Name of error file"}
#int    nlines
string *goodcalslist
string *imhoutlist

begin
  string line,path,refspec,tempref,tempstr
  bool   refspecfound
  
  if (access(logfile))
    del(logfile, ver-)
  if (access(warningfile))
    del(warningfile, ver-)
#  if (access(errorfile))
#    del(errorfile, ver-)
#  if (access(wcoutfile))
#    del(wcoutfile, ver-)
#  wc(goodcals, >> wcoutfile)
  if (!access(goodcals)){
    print("comparecals: ERROR: file goodcals <"//goodcals//"> not found! => Returning")
    print("comparecals: ERROR: file goodcals <"//goodcals//"> not found! => Returning", >> logfile)
    print("comparecals: ERROR: file goodcals <"//goodcals//"> not found! => Returning", >> warningfile)
# --- clean up
    goodcalslist = ""
    imhoutlist = ""
    return
  }
  if (!access(imhout)){
    print("comparecals: ERROR: file imhout <"//imhout//"> not found! => Returning")
    print("comparecals: ERROR: file imhout <"//imhout//"> not found! => Returning", >> logfile)
    print("comparecals: ERROR: file imhout <"//imhout//"> not found! => Returning", >> warningfile)
# --- clean up
    goodcalslist = ""
    imhoutlist = ""
    return
  }
  imhoutlist = imhout
  while (fscan(imhoutlist,tempstr,line) != EOF){
    print("comparecals: line read from imhout = <"//line//">")
    strpos(line,"'")
    if (strpos.pos > 0){
      refspec = substr(line,strpos.pos+1,strlen(line))
    }
    else{
      refspec = line
    }
    print("comparecals: refspec = <"//refspec//">")
    print("comparecals: refspec = <"//refspec//">", >> logfile)
    strpos(refspec,"'")
    if (strpos.pos > 0){
      refspec = substr(refspec,1,strpos.pos-1)
      print("comparecals: refspec = <"//refspec//">")
      print("comparecals: refspec = <"//refspec//">", >> logfile)
    }

    refspecfound = NO
    goodcalslist = goodcals
    while (fscan(goodcalslist,tempref) != EOF){
      print("comparecals: tempref = <"//tempref//">")
      print("comparecals: tempref = <"//tempref//">", >> logfile)
      strlastpos(tempref,"/")
      if (strlastpos.pos > 0)
        tempref = substr(tempref,strlastpos.pos+1,strlen(tempref))
      strlastpos(tempref,".")
      if (strlastpos.pos > 0)
        tempref = substr(tempref,1,strlastpos.pos-1)
      print("comparecals: tempref = <"//tempref//">")
      print("comparecals: tempref = <"//tempref//">", >> logfile)
      if (tempref == refspec){
        print("comparecals: refspec <"//refspec//"> found in goodcals!")
        print("comparecals: refspec <"//refspec//"> found in goodcals!", >> logfile)
        refspecfound = YES
      }
    }
    if (!refspecfound){
      print("comparecals: refspec <"//refspec//"> NOT found in goodcals!")
      print("comparecals: refspec <"//refspec//"> NOT found in goodcals!", >> logfile)
      print("comparecals: refspec <"//refspec//"> NOT found in goodcals!", >> warningfile)
    }
  }
  print("comparecals: READY")
  print("comparecals: READY", >> logfile)

# --- clean up
  goodcalslist = ""
end
