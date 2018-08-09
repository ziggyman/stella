procedure contsetfunc (notset,contfunc)

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

string notset         = "@continuum_not_set.list"              {prompt="List of images without continuum set"}
string contfunc       = "contfuncimage.fits"                   {prompt="Name of image containing continuum function"}
string logfile        = "logfile_contsetfunc.log"              {prompt="Name of log file"}
string *notsetlist
string *timelist

begin

  file   notsetfile
  string timefile = "time.txt"
  string tempdate,tempday,temptime
  string notsetin,out,strdum
#  string wcoutfile="wcout.txt"
  int    i,j
#  int    nlines,clines
  int    duma,dumb,dumc

# --- delete old logfiles
  if (access(logfile))
    delete(logfile, ver-)

# --- print header
  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                  contsetfunc.cl                        *")
  print ("*          (sets given continuum function)               *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("*                 contsetfunc.cl                         *", >> logfile)
  print ("*          (sets given continuum function)               *", >> logfile)
  print ("*                                                        *", >> logfile)
  print ("**********************************************************", >> logfile)

# --- Erzeugen von temporaeren Filenamen
  notsetfile = mktemp ("tmp")

# --- test if input lists contain same number of images
#  if (access(wcoutfile))
#    del(wcoutfile, ver-)
#  wc(substr(contset,2,strlen(contfunc)), > wcoutfile)
#  if (access(wcoutfile)){
#    timelist = wcoutfile
#    while (fscan(timelist,nlines,duma,dumb,strdum) != EOF){
#      print("contsetfunc: "//contfunc//" contains "//nlines//" lines")
#      print("contsetfunc: "//contfunc//" contains "//nlines//" lines", >> logfile)
#    } 
#  }
#  else{
#    print("contsetfunc: ERROR: wcoutfile NOT ACCESSABLE!!!")
#    print("contsetfunc: ERROR: wcoutfile NOT ACCESSABLE!!!", >> logfile)
#  }
#  if (access(wcoutfile))
#    del(wcoutfile, ver-)
#  wc(substr(notset,2,strlen(notset)), > wcoutfile)
#  if (access(wcoutfile)){
#    timelist = wcoutfile
#    while (fscan(timelist,clines,duma,dumb,strdum) != EOF){
#      print("contsetfunc: "//notset//" contains "//clines//" lines")
#      print("contsetfunc: "//notset//" contains "//clines//" lines", >> logfile)
#    } 
#  }
#  else{
#    print("contsetfunc: ERROR: wcoutfile NOT ACCESSABLE!!!")
#    print("contsetfunc: ERROR: wcoutfile NOT ACCESSABLE!!!", >> logfile)
#  }
#  if (nlines != clines){
#    print("contsetfunc: ERROR: Number of lines of input lists do not agree!!!")
#    print("contsetfunc: ERROR: Number of lines of input lists do not agree!!!", >> logfile)
#  }

# --- Umwandeln der Listen von Frames in temporaere Files
  sections(notset, option="root", > notsetfile)
  notsetlist = notsetfile

# --- build output filename and trim inputimages
  #print ("**************************************************")
  while (fscan (notsetlist, notsetin) != EOF){
    print("contsetfunc: notsetin = "//notsetin)

    i = strlen(notsetin)
    if (substr (notsetin, i-4, i) == ".fits"){
      out = substr(notsetin, 1, i-5)//"csf.fits"
#        tempout = substr(notsetin, 1, i-5)//"_temp.fits"
#        tempoutfit = substr(notsetin, 1, i-5)//"_fit.fits"
    }
    else{
      out = notsetin//"csf"
#        tempout = notsetin//"_temp"
#        tempoutfit = notsetin//"_fit"
    }

    if (access(out)){
      del(out,ver-)
      print("contsetfunc: old "//out//" deleted")
      print("contsetfunc: old "//out//" deleted", >> logfile)
    }
#      if (dorecalc == YES){
#        if (access(tempout)){
#          del(tempout,ver-)
#          print("contsetfunc: old "//tempout//" deleted")
#          print("contsetfunc: old "//tempout//" deleted", >> logfile)
#        }
#        if (access(tempoutfit)){
#          del(tempoutfit,ver-)
#          print("contsetfunc: old "//tempoutfit//" deleted")
#          print("contsetfunc: old "//tempoutfit//" deleted", >> logfile)
#        }
#        imarith(operand1=contsetin,
#                op="/",
#                operand2=notsetin,
#                result=tempout,
#                title="",
#                divzero=0.,
#                hparams="",
#                pixtype="real",
#                calctype="real",
#                verbose-,
#                noact-)
#        if (access(tempout)){
#          continuum(input=tempout,
#                    output=tempoutfit,
#                    lines="*",
#                    bands=1,
#                    type="fit",
#                    replace-,
#                    wavesca+,
#                    logscal-,
#                    overrid+,
#                    listonl-,
#                    logfile="logfile_continuum.log",
#                    interac=interactive,
#                    sample=sample,
#                    naverag=naverage,
#                    functio=function,
#                    order=order,
#                    low_rej=low_reject,
#                    high_re=high_reject,
#                    niterat=niterate,
#                    grow=1.,
#                    markrej-,
#                    graphic="stdgraph",
#                    cursor="",
#                    ask+)
#        }
#        else{
#          print("contsetfunc: ERROR: cannot access tempout "//tempout)
#          print("contsetfunc: ERROR: cannot access tempout "//tempout, >> logfile)
#        }
#      }
    if (access(contfunc)){
      imarith(operand1=notsetin,
              op="*",
              operand2=contfunc,
              result=out,
              title="",
              divzero=0.,
              hparams="",
              pixtype="real",
              calctype="real",
              verbose-,
              noact-)
    }
    else{
      print("contsetfunc: ERROR: cannot access tempoutfit "//contfunc)
      print("contsetfunc: ERROR: cannot access tempoutfit "//contfunc, >> logfile)
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
                value="contsetfunc: continuum set "//tempdate//"T"//temptime,
                add+,
                addonly-,
                del-,
                ver-,
                show+,
                update+)
          hedit(images=out,
                fields="CONTSETF",
                value="Continuum function file = "//contfunc,
                add+,
                addonly-,
                del-,
                ver-,
                show+,
                update+)
        }
      }
      else{
        print("contsetfunc: WARNING: timefile <"//timefile//"> not accessable!")
      }
    }
    else{
      print("contsetfunc: WARNING: outfile <"//out//"> not accessable!")
    }
  }

# --- Aufraeumen
  delete (notsetfile, ver-, >& "dev$null")
end
