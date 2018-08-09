procedure stapcombine (images)
#,rdnoise,gain,normalbiasmean,normalbiasstddev,maxmeanbiasfailure,maxstddevbiasfailure)

################################################################################
#                                                                              #
# This program combines the STELLA (TRAFICOS) echelle apertures automatically. #
#                                                                              #
# Andreas Ritter, 13.11.2001                                                   #
#                                                                              #
################################################################################

string images        = "@input.list"                 {prompt="List of input spectra"}
int    loglevel      = 3                             {prompt="Level for writing logfile"}
#string parameterfile = "scripts$parameterfile.prop"  {prompt="Parameter file"}
string *inputlist
string *datlisti
string *datlistj
string *ccdlistoutlist
#string *statlist
#string *parameterlist

begin

  int    naps          = 31
  int    i,j,dumint1,dumint2
  string logfile       = "logfile.log"
  string errorfile     = "errors.log"
  string warningfile   = "warnings.log"
  string ccdlistout    = "ccdlistout.temp"
  file   inputfile
  string in,out,datfilei,datfilej,duml,dumi
  string fitslist,textlist,ccdliststring
  real   xi0,xi1,xi2,xi3,xj0,xj1,xj2,xj3
  real   meani0,meani1,meanj0,meanj1,dumx

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                      stapcombine.cl                    *")
  print ("*    (combines all apertures to one combined spectra)    *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*                      stapcombine.cl                    *", >> logfile)
  print ("*    (combines all apertures to one combined spectra)    *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- Erzeugen von temporaeren Filenamen
  print("stapcombine: building temp-filenames")
  if (loglevel > 2)
    print("stapcombine: building temp-filenames", >> logfile)
  inputfile    = mktemp ("tmp")

# --- Umwandeln der Listen von Frames in temporaere Files
  print("stapcombine: building lists from temp-files")
  if (loglevel > 2)
    print("stapcombine: building lists from temp-files", >> logfile)

  if ( (substr(images,1,1) == "@" && access(substr(images,2,strlen(images)))) || (substr(images,1,1) != "@" && access(images))){
   sections(images, option="root", > inputfile)
   inputlist = inputfile
  }
  else{
   if (substr(images,1,1) != "@"){
    print("stapcombine: ERROR: "//images//" not found!!!")
    print("stapcombine: ERROR: "//images//" not found!!!", >> logfile)
    print("stapcombine: ERROR: "//images//" not found!!!", >> errorfile)
    print("stapcombine: ERROR: "//images//" not found!!!", >> warningfile)
   }
   else{
    print("stapcombine: ERROR: "//substr(images,2,strlen(images))//" not found!!!")
    print("stapcombine: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> logfile)
    print("stapcombine: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> errorfile)
    print("stapcombine: ERROR: "//substr(images,2,strlen(images))//" not found!!!", >> warningfile)
   }
   return
  }

# --- count apertures and calc outname
  naps = 0
  while(fscan(inputlist,in) != EOF){
    if (access(ccdlistout))
      delete(ccdlistout, ver-)
    ccdlist(in, >> ccdlistout)
    ccdlistoutlist = ccdlistout
    while(fscan(ccdlistoutlist, ccdliststring) != EOF){
      print("stapcombine: ccdliststring = '"//ccdliststring//"'")
      print('stapcombine: stridx(ccdliststring,",") returns '//stridx(ccdliststring,","))
      naps = int(substr(ccdliststring,stridx(ccdliststring,",")+1,stridx(ccdliststring,"]")-1))
    }
    if (substr(in,strlen(in)-4,strlen(in)) == ".fits")
      out = substr(in,1,strlen(in)-5)//"_c.fits"
    else 
      out = in//"_c.fits"
  }
# --- delete output
  if (access(out)){
    imdel(out, ver-)
    if (access(out))
      del(out,ver-)
    if (!access(out)){
      print("stapcombine: old "//out//" deleted")
      if (loglevel > 2)
        print("stapcombine: old "//out//" deleted", >> logfile)
    }
    else{
      print("stapcombine: ERROR: cannot delete old "//out)
      print("stapcombine: ERROR: cannot delete old "//out, >> logfile)
      print("stapcombine: ERROR: cannot delete old "//out, >> warningfile)
      print("stapcombine: ERROR: cannot delete old "//out, >> errorfile)
    }
  }

  inputlist = inputfile
  i = 0
  xi0 = 0.
  xi1 = 0.
  xi2 = 0.
  xi3 = 0.
  xj0 = 0.
  xj1 = 0.
  xj2 = 0.
  xj3 = 0.

  while (fscan(inputlist, datfilei) != EOF){
    datlisti = datfilei
    xj0 = xi0
    xj3 = xi3
    xj1 = xi1
    xi0 = 0.
    xi3 = 0.
    npix = 0
    meani0 = 0.
    meani1 = 0.

    while (fscan(datlisti,duml,dumi) != EOF){
      if (xi0 == 0.)
        xi0 = real(duml)
      xi3_old = xi3
      xi3 = real(duml)
      if (xi3_old < xj3 && xi3 >= xj3)
        xi1 = xi3
      if (xi3 >= xj3){
        npix += 1
        meani0 += xi3
      }
    }
    meani0 = meani0 / real(npix)
    j = 0
    if (datfilej != "")
      datlistj = datfilej
    dumx_old = 0.
    dumx = 0.
    meanj1 = 0.
    npix = 0
    while(fscan(datlistj,duml,dumi) != EOF){
      dumx_old = dumx
      dumx = real(duml)
      if (dumx < xi0){
        meanj1 += dumx
        npix += 1
      }
      if (dumx_old <= xi0 && dumx > xi0)
        xj2 = dumx
    }
    meanj1 = meanj1 / real(npix)
    meanmult = meani0 / meanj1
  }

  if (access(out)){
    print("stapcombine: "//out//" ready")
    if (loglevel > 1)
      print("stapcombine: "//out//" ready", >> logfile)
  }
  else{
    print("stapcombine: ERROR: "//out//" not accessable")
    print("stapcombine: ERROR: "//out//" not accessable", >> logfile)
    print("stapcombine: ERROR: "//out//" not accessable", >> warningfile)
    print("stapcombine: ERROR: "//out//" not accessable", >> errorfile)
  }

# --- Aufraeumen
  delete (inputfile, ver-, >& "dev$null")
  inputlist      = ""

end
