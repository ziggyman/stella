procedure redocontinuum (contset,notset)

##################################################
#                                                #
# This program calculates the continuum function #
#  and sets the continuum to the NOTSET images.  #
#  outputs = NOTSET*rc.fits                       #
#            NOTSET*fit.fits                     #
#                                                #
# Andreas Ritter, 05.01.2006                     #
#                                                #
##################################################

string contset        = "@continuum_set.list"                  {prompt="List of images with continuum set"}
string notset         = "@continuum_not_set.list"              {prompt="List of images without continuum set"}
string logfile        = "logfile_redocontinuum.log"            {prompt="Name of log file"}
bool   dorecalc       = YES                                    {prompt="Calculate continuum function?"}
bool   interactive    = YES                                    {prompt="Do fitting of continuum function interactively?"}
string sample         = "*"                                    {prompt="Fitting sample regions"}
int    naverage       = 1                                      {prompt="Average (pos) of median (neg)"}
string function       = "spline3"                              {prompt="Continuum fitting function (cheb|leg|spline1|spline3)",
                                                                enum="chebyshev|legendre|spline1|spline3"}
int    order          = 5                                      {prompt="Order of fitting function"}
real   low_reject     = 2.                                     {prompt="Lower rejection sigma"}
real   high_reject    = 2.                                     {prompt="Upper rejection sigma"}
int    niterate       = 2                                      {prompt="Number of rejection iterations"}
string *contsetlist
string *notsetlist
string *timelist

begin

  file   contsetfile,notsetfile
  string timefile = "time.txt"
  string tempdate,tempday,temptime,tempout,tempoutfit
  string contsetin,notsetin
  string out,strdum
  string wcoutfile="wcout.txt"
  int    i,j,nlines,clines,duma,dumb,dumc

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                  redocontinuum.cl                      *")
  print ("*       (calculates and sets continuum function)         *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*                 redocontinuum.cl                       *", >> logfile)
  print ("*      (calculates and sets continuum function)          *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- Erzeugen von temporaeren Filenamen
  contsetfile = mktemp ("tmp")
  notsetfile = mktemp ("tmp")

# --- test if input lists contain same number of images
  if (access(wcoutfile))
    del(wcoutfile, ver-)
  wc(substr(contset,2,strlen(contset)), > wcoutfile)
  if (access(wcoutfile)){
    timelist = wcoutfile
    while (fscan(timelist,nlines,duma,dumb,strdum) != EOF){
      print("redocontinuum: "//contset//" contains "//nlines//" lines")
      print("redocontinuum: "//contset//" contains "//nlines//" lines", >> logfile)
    } 
  }
  else{
    print("redocontinuum: ERROR: wcoutfile NOT ACCESSABLE!!!")
    print("redocontinuum: ERROR: wcoutfile NOT ACCESSABLE!!!", >> logfile)
  }
  if (access(wcoutfile))
    del(wcoutfile, ver-)
  wc(substr(notset,2,strlen(notset)), > wcoutfile)
  if (access(wcoutfile)){
    timelist = wcoutfile
    while (fscan(timelist,clines,duma,dumb,strdum) != EOF){
      print("redocontinuum: "//notset//" contains "//clines//" lines")
      print("redocontinuum: "//notset//" contains "//clines//" lines", >> logfile)
    } 
  }
  else{
    print("redocontinuum: ERROR: wcoutfile NOT ACCESSABLE!!!")
    print("redocontinuum: ERROR: wcoutfile NOT ACCESSABLE!!!", >> logfile)
  }
  if (nlines != clines){
    print("redocontinuum: ERROR: Number of lines of input lists do not agree!!!")
    print("redocontinuum: ERROR: Number of lines of input lists do not agree!!!", >> logfile)
  }

# --- Umwandeln der Listen von Frames in temporaere Files
  sections(contset, option="root", > contsetfile)
  contsetlist = contsetfile
  sections(notset, option="root", > notsetfile)
  notsetlist = notsetfile

# --- build output filename and trim inputimages
  #print ("**************************************************")
  for (j=1;j<=nlines;j+=1){
    if (fscan (contsetlist, contsetin) != EOF){
      print("redocontinuum: contsetin = "//contsetin)
      if (fscan (notsetlist, notsetin) != EOF){
        print("redocontinuum: notsetin = "//notsetin)

        i = strlen(notsetin)
        if (substr (notsetin, i-4, i) == ".fits"){
          out = substr(notsetin, 1, i-5)//"rc.fits"
#          if (dorecalc == YES){
            tempout = substr(notsetin, 1, i-5)//"_temp.fits"
            tempoutfit = substr(notsetin, 1, i-5)//"_fit.fits"
#          }
        }
        else{
          out = notsetin//"rc"
#          if (dorecalc == YES){
            tempout = notsetin//"_temp"
            tempoutfit = notsetin//"_fit"
#          }
        }

        if (access(out)){
          del(out,ver-)
          print("redocontinuum: old "//out//" deleted")
          print("redocontinuum: old "//out//" deleted", >> logfile)
        }
        if (dorecalc == YES){
          if (access(tempout)){
            del(tempout,ver-)
            print("redocontinuum: old "//tempout//" deleted")
            print("redocontinuum: old "//tempout//" deleted", >> logfile)
          }
          if (access(tempoutfit)){
            del(tempoutfit,ver-)
            print("redocontinuum: old "//tempoutfit//" deleted")
            print("redocontinuum: old "//tempoutfit//" deleted", >> logfile)
          }
          imarith(operand1=contsetin,
                  op="/",
                  operand2=notsetin,
                  result=tempout,
                  title="",
                  divzero=0.,
                  hparams="",
                  pixtype="",
                  calctype="",
                  verbose-,
                  noact-)
          if (access(tempout)){
            continuum(input=tempout,
                      output=tempoutfit,
                      lines="*",
                      bands=1,
                      type="fit",
                      replace-,
                      wavesca+,
                      logscal-,
                      overrid+,
                      listonl-,
                      logfile="logfile_continuum.log",
                      interac=interactive,
                      sample=sample,
                      naverag=naverage,
                      functio=function,
                      order=order,
                      low_rej=low_reject,
                      high_re=high_reject,
                      niterat=niterate,
                      grow=1.,
                      markrej-,
                      graphic="stdgraph",
                      cursor="",
                      ask+)
          }
          else{
            print("redocontinuum: ERROR: cannot access tempout "//tempout)
            print("redocontinuum: ERROR: cannot access tempout "//tempout, >> logfile)
          }
        }
        if (access(tempoutfit)){
        imarith(operand1=notsetin,
                op="*",
                operand2=tempoutfit,
                result=out,
                title="",
                divzero=0.,
                hparams="",
                pixtype="",
                calctype="",
                verbose-,
                noact-)
        }
        else{
          print("redocontinuum: ERROR: cannot access tempoutfit "//tempoutfit)
          print("redocontinuum: ERROR: cannot access tempoutfit "//tempoutfit, >> logfile)
        }
      }
    }
    if (access(out)){
      if (access(timefile))
        del(timefile, ver-)
      time(>> timefile)
      if (access(timefile)){
        timelist = timefile
        if (fscan(timelist,tempday,temptime,tempdate) != EOF){
          hedit(images=out,
                fields="CONTSET",
                value="redocontinuum: continuum set "//tempdate//"T"//temptime,
                add+,
                addonly+,
                del-,
                ver-,
                show+,
                update+)
        }
      }
      else{
        print("redocontinuum: WARNING: timefile <"//timefile//"> not accessable!")
      }
    }
    else{
      print("redocontinuum: WARNING: outfile <"//out//"> not accessable!")
    }
  }

# --- Aufraeumen
  delete (contsetfile, ver-, >& "dev$null")
  delete (notsetfile, ver-, >& "dev$null")
  delete (wcoutfile, ver-, >& "dev$null")
end
