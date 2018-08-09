procedure dorvcorlist (infilelist)

#############################################################################
#                                                                           #
# This program starts the rv.rvcorrect task for every data file in infilelist #
#                                                                           #
#                                                                           #
#               outputs = <inputfile_root>_rvcor.dat                        #
#                                                                           #
# Andreas Ritter, 21.10.2004                                                #
#                                                                           #
#############################################################################

string infilelist    = "to_rvcorrect.list"       {prompt="List containing input files for rvcorrect task"}
string outfilelist   = "to_rvcorrect_out.list"   {prompt="List containing output files for rvcorrect task (output)"}
#string images        = " "                       {prompt="List of images containing observation data"}
bool   header        = YES                       {prompt="Print header?"}
bool   input         = NO                        {prompt="Print input data?"}
bool   imupdate      = NO                        {prompt="Update image header with corrections?"}
real   epoch         = 2000.                     {prompt="Epoch of observation coordinates (years)"}
string observatory   = "esovlt"                  {prompt="Observatory"}
real   vsun          = 20.                       {prompt="Solar velocity (km/s)"}
real   ra_vsun       = 18.                       {prompt="Right ascension of solar velocity (hours)"}
real   dec_vsun      = 30.                       {prompt="Declination of solar velocity (degrees)"}
real   epoch_vsun    = 1900.                     {prompt="Epoch of solar coordinates (years)"}
string *listoffiles

begin

  string datafile,outfile
  bool   run = YES
  int    i = 0

# --- load needed package
  rv

# --- set rvcorrect parameters
  rvcorrect.images      = " "
  rvcorrect.header      = header
  rvcorrect.input       = input
  rvcorrect.imupdate    = imupdate
  rvcorrect.epoch       = epoch
  rvcorrect.observatory = observatory
  rvcorrect.vsun        = vsun
  rvcorrect.ra_vsun     = ra_vsun
  rvcorrect.dec_vsun    = dec_vsun
  rvcorrect.epoch_vsun  = epoch_vsun

  if (access(outfilelist))
    del(outfilelist, ver-)

  listoffiles = infilelist
  while (fscan(listoffiles,datafile) != EOF){
    i = 0
    run = YES
    while(run){
      i = i + 1
      if (substr(datafile,strlen(datafile)-i,strlen(datafile)-i) == "."){
        outfile = substr(datafile,1,strlen(datafile)-i-1)//"_rvcor.dat"
        print(outfile, >> outfilelist)
        run = NO
      }
      else if ((i == (strlen(datafile)-1)) && run){
        outfile = datafile//"_rvcor.dat"
        print(outfile, >> outfilelist)
        run = NO
      }
    }
    print("datafile = "//datafile//", outfile = "//outfile)
    if (access(outfile))
      del(outfile, ver-)

    rvcorrect(files=datafile, >> outfile)
  }

# --- clean up
  listoffiles = ""

end
