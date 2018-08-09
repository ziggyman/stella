procedure findgoodcals(goodcals)

#########################################################################
#                                                                       #
# NAME:                  findgoodcals                                    #
# PURPOSE:               * ...                                #
#                                                                       #
# CATEGORY:                                                             #
# CALLING SEQUENCE:      findgoodcals(String: goodcals)                     #
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
string imtype       = "fits"                       {prompt="Image type"}
string outlist      = "goodcals.list"              {prompt="Name of outfile"}
string logfile     = "logfile_findgoodcals.log"   {prompt="Name of logfile"}
#string warningfile = "warnings_findgoodcals.log"  {prompt="Name of warning file"}
#string errorfile   = "errors_findgoodcals.log"    {prompt="Name of error file"}
#int    nlines
string *goodcalslist
string *filelist

begin
  string infile,path,fitsfile
  
  if (access(logfile))
    del(logfile, ver-)
#  if (access(warningfile))
#    del(warningfile, ver-)
#  if (access(errorfile))
#    del(errorfile, ver-)
#  if (access(wcoutfile))
#    del(wcoutfile, ver-)
#  wc(goodcals, >> wcoutfile)
  if (!access(goodcals)){
    print("findgoodcals: ERROR: file goodcals <"//goodcals//"> not found! => Returning")
    print("findgoodcals: ERROR: file goodcals <"//goodcals//"> not found! => Returning", >> logfile)
#    print("findgoodcals: ERROR: file goodcals <"//goodcals//"> not found! => Returning", >> warningfile)
#    print("findgoodcals: ERROR: file goodcals <"//goodcals//"> not found! => Returning", >> errorfile)
# --- clean up
    goodcalslist = ""
    return
  }
  if (access(outlist))
    del(outlist, ver-)
  goodcalslist = goodcals
  while (fscan(goodcalslist,infile) != EOF){
    print("findgoodcals: list of good calibration images = <"//infile//">")
    if (!access(infile)){
      print("findgoodcals: ERROR: file <"//infile//"> not accessable! returning")
      print("findgoodcals: ERROR: file <"//infile//"> not accessable! returning", >> logfile)
# --- clean up
      goodcalslist = ""
      return
    }
    strlastpos(infile,"/")
    if (strlastpos.pos < 1)
      path = ""
    else
      path = substr(infile,1,strlastpos.pos)
    print("findgoodcals: path = <"//path//">")
    print("findgoodcals: path = <"//path//">", >> logfile)
    filelist = infile
    while (fscan(filelist,fitsfile) != EOF){
      print("findgoodcals: fitsfile = <"//fitsfile//">")
      print("findgoodcals: fitsfile = <"//fitsfile//">", >> logfile)
      fitsfile = path//fitsfile
      if (substr(fitsfile,strlen(fitsfile)-strlen(imtype),strlen(fitsfile)) != "."//imtype){
        print("findgoodcals: adding image type ."//imtype//" to filename!")
        print("findgoodcals: adding image type ."//imtype//" to filename!", >> logfile)
        fitsfile = fitsfile//"."//imtype
      }
      if (!access(fitsfile)){
        print("findgoodcals: ERROR: file <"//fitsfile//"> not accessable! returning")
        print("findgoodcals: ERROR: file <"//fitsfile//"> not accessable! returning", >> logfile)
# --- clean up
        goodcalslist = ""
        return
      }
      print(fitsfile, >> outlist)
    }
  }
  print("findgoodcals: READY")
  print("findgoodcals: READY", >> logfile)

# --- clean up
  goodcalslist = ""
end
