procedure calcsnr(filename,ncols,col,msigma)

###################################################################################
#                                                                                 #
# Procedure: calcsnr.cl                                                          #
# IRAF-Version: 2.12                                                              #
#                                                                                 #
# This procedure calculates the MEAN and RMS of column COL in file FILENAME.      #
# Values outside the MEAN +/- (MSIGMA * RMS) of the first run range are rejected. #
#                                                                                 #
# NOTE: COL and NCOLS need to be greater than 0 and lower than 11!!!              #
#                                                                                 #
# Andreas Ritter, 23.01.2005                                                      #
#                                                                                 #
###################################################################################

string filename    = "file_to_calc_mean.dat"     {prompt="Name of file to calculate mean"}
int    ncols       = 2                           {prompt="No of columns in file (1..10)"}
int    col         = 2                           {prompt="No of column to calc mean (1..10)"}
real   msigma      = 2.                          {prompt="Factor to multiply sigma with to skip deviant pixels"}
int    npix        = 50                          {prompt="Number of pixels to calculate mean and snr"}
string logfile     = "logfile_calcsnr.log"      {prompt="Name of logfile"}
string warningfile = "warnings_calcsnr.log"     {prompt="Name of warning file"}
string errorfile   = "errors_calcsnr.log"       {prompt="Name of error file"}
int    loglevel    = 3                           {prompt="Level for writing logfile [1-3]"}
bool   deloldlog   = NO                          {prompt="Delete old log files?"}
string *lines

begin
  string strarr[10]
  string outfile,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf,tmpstrg,tmpstrh,tmpstri,tmpstrj
  int    nlines,ngood,npixrej,icalc
  real   sum,sumsqrs,variance,sigma,tmpreal,mean

  if (deloldlog){
    if (access(logfile))
      del(logfile, ver-)
    if (access(warningfile))
      del(warningfile, ver-)
    if (access(errorfile))
      del(errorfile, ver-)
  }

  outfile = filename//"_mean_rms.dat"
  if (access(outfile))
    del(outfile, ver-)

  if (col < 1){
    print("calcsnr: ERROR: col (="//col//") < 1 => returning", >> logfile)
    print("calcsnr: ERROR: col (="//col//") < 1 => returning", >> warningfile)
    print("calcsnr: ERROR: col (="//col//") < 1 => returning", >> errorfile)
# --- clean up
    lines = ""
    return
  }
  if (col > 10){
    print("calcsnr: ERROR: col (="//col//") > 10 => returning", >> logfile)
    print("calcsnr: ERROR: col (="//col//") > 10 => returning", >> warningfile)
    print("calcsnr: ERROR: col (="//col//") > 10 => returning", >> errorfile)
# --- clean up
    lines = ""
    return
  }
  if (ncols < 1){
    print("calcsnr: ERROR: ncols (="//ncols//") < 1 => returning", >> logfile)
    print("calcsnr: ERROR: ncols (="//ncols//") < 1 => returning", >> warningfile)
    print("calcsnr: ERROR: ncols (="//ncols//") < 1 => returning", >> errorfile)
# --- clean up
    lines = ""
    return
  }
  if (ncols > 10){
    print("calcsnr: ERROR: ncols (="//ncols//") > 10 => returning", >> logfile)
    print("calcsnr: ERROR: ncols (="//ncols//") > 10 => returning", >> warningfile)
    print("calcsnr: ERROR: ncols (="//ncols//") > 10 => returning", >> errorfile)
# --- clean up
    lines = ""
    return
  }
  if (col > ncols){
    print("calcsnr: ERROR: col (="//col//") > ncols (="//ncols//" => returning", >> logfile)
    print("calcsnr: ERROR: col (="//col//") > ncols (="//ncols//" => returning", >> warningfile)
    print("calcsnr: ERROR: col (="//col//") > ncols (="//ncols//" => returning", >> errorfile)
# --- clean up
    lines = ""
    return
  }
  if (!access(filename)){
    print("calcsnr: ERROR: file "//filename//" not accessable => returning", >> logfile)
    print("calcsnr: ERROR: file "//filename//" not accessable => returning", >> warningfile)
    print("calcsnr: ERROR: file "//filename//" not accessable => returning", >> errorfile)
    return
# --- clean up
    lines = ""
  }

  if (access(outfile))
    del(outfile, ver-)

#  if (loglevel > 2){
#    print("calcsnr: starting first run to calculate sigma for rejecting deviant pixels...", >> logfile)
#  }

  lines   = filename
  nlines  = 0
  sum     = 0.
  sumsqrs = 0.
  if (ncols == 1){
    while(fscan(lines,tmpstra) != EOF){
      strarr[1] = tmpstra
      nlines += 1
#      print("calcsnr: line "//nlines//": strarr[1] = "//strarr[1])
      tmpreal = real(strarr[col])
      sum += tmpreal
      sumsqrs += tmpreal * tmpreal
#      print("calcsnr: line "//nlines//": sum = "//sum//", sumsqrs = "//sumsqrs)
    }
  }
  else if (ncols == 2){
    while(fscan(lines,tmpstra,tmpstrb) != EOF){
      strarr[1] = tmpstra
      strarr[2] = tmpstrb
      nlines += 1
#      print("calcsnr: line "//nlines//": strarr[1] = "//strarr[1]//", strarr[2] = "//strarr[2])
      tmpreal = real(strarr[col])
      sum += tmpreal
      sumsqrs += tmpreal * tmpreal
#      print("calcsnr: line "//nlines//": sum = "//sum//", sumsqrs = "//sumsqrs)
    }
  }
  else if (ncols == 3){
    while(fscan(lines,tmpstra,tmpstrb,tmpstrc) != EOF){
      strarr[1] = tmpstra
      strarr[2] = tmpstrb
      strarr[3] = tmpstrc
      nlines += 1
#      print("calcsnr: line "//nlines//": strarr[1] = "//strarr[1]//", strarr[2] = "//strarr[2]//", strarr[3] = "//strarr[3])
      tmpreal = real(strarr[col])
      sum += tmpreal
      sumsqrs += tmpreal * tmpreal
#      print("calcsnr: line "//nlines//": sum = "//sum//", sumsqrs = "//sumsqrs)
    }
  }
  else if (ncols == 4){
    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd) != EOF){
      strarr[1] = tmpstra
      strarr[2] = tmpstrb
      strarr[3] = tmpstrc
      strarr[4] = tmpstrd
      nlines += 1
#      print("calcsnr: line "//nlines//": strarr[1] = "//strarr[1]//", strarr[2] = "//strarr[2]//", strarr[3] = "//strarr[3]//", strarr[4] = "//strarr[4])
      tmpreal = real(strarr[col])
      sum += tmpreal
      sumsqrs += tmpreal * tmpreal
#      print("calcsnr: line "//nlines//": sum = "//sum//", sumsqrs = "//sumsqrs)
    }
  }
  else if (ncols == 5){
    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre) != EOF){
      strarr[1] = tmpstra
      strarr[2] = tmpstrb
      strarr[3] = tmpstrc
      strarr[4] = tmpstrd
      strarr[5] = tmpstre
      nlines += 1
#      print("calcsnr: line "//nlines//": strarr[1] = "//strarr[1]//", strarr[2] = "//strarr[2]//", strarr[3] = "//strarr[3]//", strarr[4] = "//strarr[4]//", strarr[5] = "//strarr[5])
      tmpreal = real(strarr[col])
      sum += tmpreal
      sumsqrs += tmpreal * tmpreal
#      print("calcsnr: line "//nlines//": sum = "//sum//", sumsqrs = "//sumsqrs)
    }
  }
  else if (ncols == 6){
    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf) != EOF){
      strarr[1] = tmpstra
      strarr[2] = tmpstrb
      strarr[3] = tmpstrc
      strarr[4] = tmpstrd
      strarr[5] = tmpstre
      strarr[6] = tmpstrf
      nlines += 1
#      print("calcsnr: line "//nlines//": strarr[1] = "//strarr[1]//", strarr[2] = "//strarr[2]//", strarr[3] = "//strarr[3]//", strarr[4] = "//strarr[4]//", strarr[5] = "//strarr[5]//", strarr[6] = "//strarr[6])
      tmpreal = real(strarr[col])
      sum += tmpreal
      sumsqrs += tmpreal * tmpreal
#      print("calcsnr: line "//nlines//": sum = "//sum//", sumsqrs = "//sumsqrs)
    }
  }
  else if (ncols == 7){
    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf,tmpstrg) != EOF){
      strarr[1] = tmpstra
      strarr[2] = tmpstrb
      strarr[3] = tmpstrc
      strarr[4] = tmpstrd
      strarr[5] = tmpstre
      strarr[6] = tmpstrf
      strarr[7] = tmpstrg
      nlines += 1
 #     print("calcsnr: line "//nlines//": strarr[1] = "//strarr[1]//", strarr[2] = "//strarr[2]//", strarr[3] = "//strarr[3]//", strarr[4] = "//strarr[4]//", strarr[5] = "//strarr[5]//", strarr[6] = "//strarr[6]//", strarr[7] = "//strarr[7])
      tmpreal = real(strarr[col])
      sum += tmpreal
      sumsqrs += tmpreal * tmpreal
 #     print("calcsnr: line "//nlines//": sum = "//sum//", sumsqrs = "//sumsqrs)
    }
  }
  else if (ncols == 8){
    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf,tmpstrg,tmpstrh) != EOF){
      strarr[1] = tmpstra
      strarr[2] = tmpstrb
      strarr[3] = tmpstrc
      strarr[4] = tmpstrd
      strarr[5] = tmpstre
      strarr[6] = tmpstrf
      strarr[7] = tmpstrg
      strarr[8] = tmpstrh
      nlines += 1
 #     print("calcsnr: line "//nlines//": strarr[1] = "//strarr[1]//", strarr[2] = "//strarr[2]//", strarr[3] = "//strarr[3]//", strarr[4] = "//strarr[4]//", strarr[5] = "//strarr[5]//", strarr[6] = "//strarr[6]//", strarr[7] = "//strarr[7]//", strarr[8] = "//strarr[8])
      tmpreal = real(strarr[col])
      sum += tmpreal
      sumsqrs += tmpreal * tmpreal
 #     print("calcsnr: line "//nlines//": sum = "//sum//", sumsqrs = "//sumsqrs)
    }
  }
  else if (ncols == 9){
    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf,tmpstrg,tmpstrh,tmpstri) != EOF){
      strarr[1] = tmpstra
      strarr[2] = tmpstrb
      strarr[3] = tmpstrc
      strarr[4] = tmpstrd
      strarr[5] = tmpstre
      strarr[6] = tmpstrf
      strarr[7] = tmpstrg
      strarr[8] = tmpstrh
      strarr[9] = tmpstri
      nlines += 1
 #     print("calcsnr: line "//nlines//": strarr[1] = "//strarr[1]//", strarr[2] = "//strarr[2]//", strarr[3] = "//strarr[3]//", strarr[4] = "//strarr[4]//", strarr[5] = "//strarr[5]//", strarr[6] = "//strarr[6]//", strarr[7] = "//strarr[7]//", strarr[8] = "//strarr[8]//", strarr[9] = "//strarr[9])
      tmpreal = real(strarr[col])
      sum += tmpreal
      sumsqrs += tmpreal * tmpreal
 #     print("calcsnr: line "//nlines//": sum = "//sum//", sumsqrs = "//sumsqrs)
    }
  }
  else if (ncols == 10){
    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf,tmpstrg,tmpstrh,tmpstri,tmpstrj) != EOF){
      strarr[1] = tmpstra
      strarr[2] = tmpstrb
      strarr[3] = tmpstrc
      strarr[4] = tmpstrd
      strarr[5] = tmpstre
      strarr[6] = tmpstrf
      strarr[7] = tmpstrg
      strarr[8] = tmpstrh
      strarr[9] = tmpstri
      strarr[10] = tmpstrj
      nlines += 1
 #     print("calcsnr: line "//nlines//": strarr[1] = "//strarr[1]//", strarr[2] = "//strarr[2]//", strarr[3] = "//strarr[3]//", strarr[4] = "//strarr[4]//", strarr[5] = "//strarr[5]//", strarr[6] = "//strarr[6]//", strarr[7] = "//strarr[7]//", strarr[8] = "//strarr[8]//", strarr[9] = "//strarr[9]//", strarr[10] = "//strarr[10])
      tmpreal = real(strarr[col])
      sum += tmpreal
      sumsqrs += tmpreal * tmpreal
 #     print("calcsnr: line "//nlines//": sum = "//sum//", sumsqrs = "//sumsqrs)
    }
  }
  if (nlines == 0 || nlines == 1){
    print("calcsnr: ERROR: File '"//filename//"' contains not enough data lines => returning")
    print("calcsnr: ERROR: File '"//filename//"' contains not enough data lines => returning", >> logfile)
    print("calcsnr: ERROR: File '"//filename//"' contains not enough data lines => returning", >> warningfile)
    print("calcsnr: ERROR: File '"//filename//"' contains not enough data lines => returning", >> errorfile)
# --- clean up
    lines = ""
    return
  }
  mean = sum / nlines
  variance = ((nlines * sumsqrs) - (sum * sum)) / (nlines * (nlines - 1))
  if (variance < 0)
    sigma = 0.
  else
    sigma = sqrt(variance)
#  print("calcsnr: ...first run ready")
#  print("calcsnr: MEAN of column "//col//": "//mean)
#  print("calcsnr: RMS of column  "//col//": "//sigma)
  if (loglevel > 1){
    print("calcsnr: ...first run ready", >> logfile)
    print("calcsnr: MEAN of column "//col//": "//mean, >> logfile)
    print("calcsnr: RMS of column  "//col//": "//sigma, >> logfile)
  }

# --- reject pixels with flux <> mean +/- (msigma*sigma)
#  if (loglevel > 2)
#    print("calcsnr: Starting second run...", >> logfile)
#  lines   = filename
#  ngood   = 0
#  sum     = 0.
#  sumsqrs = 0.
#  if (ncols == 1){
#    while(fscan(lines,tmpstra) != EOF){
#      strarr[1] = tmpstra
#      tmpreal = real(strarr[col])
#      if (tmpreal > (mean - (msigma * sigma)) && tmpreal < (mean + (msigma * sigma))){
#        ngood += 1
#        sum += tmpreal
#        sumsqrs += tmpreal * tmpreal
##        print("calcsnr: ngood = "//ngood//": sum = "//sum//", sumsqrs = "//sumsqrs)
#      }
#    }
#  }
#  else if (ncols == 2){
#    while(fscan(lines,tmpstra,tmpstrb) != EOF){
#      strarr[1] = tmpstra
#      strarr[2] = tmpstrb
#      tmpreal = real(strarr[col])
#      if (tmpreal > (mean - (msigma * sigma)) && tmpreal < (mean + (msigma * sigma))){
#        ngood += 1
#        sum += tmpreal
#        sumsqrs += tmpreal * tmpreal
##        print("calcsnr: ngood = "//ngood//": sum = "//sum//", sumsqrs = "//sumsqrs)
#      }
#    }
#  }
#  else if (ncols == 3){
#    while(fscan(lines,tmpstra,tmpstrb,tmpstrc) != EOF){
#      strarr[1] = tmpstra
#      strarr[2] = tmpstrb
#      strarr[3] = tmpstrc
#      tmpreal = real(strarr[col])
#      if (tmpreal > (mean - (msigma * sigma)) && tmpreal < (mean + (msigma * sigma))){
#        ngood += 1
#        sum += tmpreal
#        sumsqrs += tmpreal * tmpreal
##        print("calcsnr: ngood = "//ngood//": sum = "//sum//", sumsqrs = "//sumsqrs)
#      }
#    }
#  }
#  else if (ncols == 4){
#    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd) != EOF){
#      strarr[1] = tmpstra
#      strarr[2] = tmpstrb
#      strarr[3] = tmpstrc
#      strarr[4] = tmpstrd
#      tmpreal = real(strarr[col])
#      if (tmpreal > (mean - (msigma * sigma)) && tmpreal < (mean + (msigma * sigma))){
#        ngood += 1
#        sum += tmpreal
#        sumsqrs += tmpreal * tmpreal
##        print("calcsnr: ngood = "//ngood//": sum = "//sum//", sumsqrs = "//sumsqrs)
#      }
#    }
#  }
#  else if (ncols == 5){
#    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre) != EOF){
#      strarr[1] = tmpstra
#      strarr[2] = tmpstrb
#      strarr[3] = tmpstrc
#      strarr[4] = tmpstrd
#      strarr[5] = tmpstre
#      tmpreal = real(strarr[col])
#      if (tmpreal > (mean - (msigma * sigma)) && tmpreal < (mean + (msigma * sigma))){
#        ngood += 1
#        sum += tmpreal
#        sumsqrs += tmpreal * tmpreal
##        print("calcsnr: ngood = "//ngood//": sum = "//sum//", sumsqrs = "//sumsqrs)
#      }
#    }
#  }
#  else if (ncols == 6){
#    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf) != EOF){
#      strarr[1] = tmpstra
#      strarr[2] = tmpstrb
#      strarr[3] = tmpstrc
#      strarr[4] = tmpstrd
#      strarr[5] = tmpstre
#      strarr[6] = tmpstrf
#      tmpreal = real(strarr[col])
#      if (tmpreal > (mean - (msigma * sigma)) && tmpreal < (mean + (msigma * sigma))){
#        ngood += 1
#        sum += tmpreal
#        sumsqrs += tmpreal * tmpreal
##        print("calcsnr: ngood = "//ngood//": sum = "//sum//", sumsqrs = "//sumsqrs)
#      }
#    }
#  }
#  else if (ncols == 7){
#    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf,tmpstrg) != EOF){
#      strarr[1] = tmpstra
#      strarr[2] = tmpstrb
#      strarr[3] = tmpstrc
#      strarr[4] = tmpstrd
#      strarr[5] = tmpstre
#      strarr[6] = tmpstrf
#      strarr[7] = tmpstrg
#      tmpreal = real(strarr[col])
#      if (tmpreal > (mean - (msigma * sigma)) && tmpreal < (mean + (msigma * sigma))){
#        ngood += 1
#        sum += tmpreal
#        sumsqrs += tmpreal * tmpreal
##        print("calcsnr: ngood = "//ngood//": sum = "//sum//", sumsqrs = "//sumsqrs)
#      }
#    }
#  }
#  else if (ncols == 8){
#    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf,tmpstrg,tmpstrh) != EOF){
#      strarr[1] = tmpstra
#      strarr[2] = tmpstrb
#      strarr[3] = tmpstrc
#      strarr[4] = tmpstrd
#      strarr[5] = tmpstre
#      strarr[6] = tmpstrf
#      strarr[7] = tmpstrg
#      strarr[8] = tmpstrh
#      tmpreal = real(strarr[col])
#      if (tmpreal > (mean - (msigma * sigma)) && tmpreal < (mean + (msigma * sigma))){
#        ngood += 1
#        sum += tmpreal
#        sumsqrs += tmpreal * tmpreal
##        print("calcsnr: ngood = "//ngood//": sum = "//sum//", sumsqrs = "//sumsqrs)
#      }
#    }
#  }
#  else if (ncols == 9){
#    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf,tmpstrg,tmpstrh,tmpstri) != EOF){
#      strarr[1] = tmpstra
#      strarr[2] = tmpstrb
#      strarr[3] = tmpstrc
#      strarr[4] = tmpstrd
#      strarr[5] = tmpstre
#      strarr[6] = tmpstrf
#      strarr[7] = tmpstrg
#      strarr[8] = tmpstrh
#      strarr[9] = tmpstri
#      tmpreal = real(strarr[col])
#      if (tmpreal > (mean - (msigma * sigma)) && tmpreal < (mean + (msigma * sigma))){
#        ngood += 1
#        sum += tmpreal
#        sumsqrs += tmpreal * tmpreal
##        print("calcsnr: ngood = "//ngood//": sum = "//sum//", sumsqrs = "//sumsqrs)
#      }
#    }
#  }
#  else if (ncols == 10){
#    while(fscan(lines,tmpstra,tmpstrb,tmpstrc,tmpstrd,tmpstre,tmpstrf,tmpstrg,tmpstrh,tmpstri,tmpstrj) != EOF){
#      strarr[1] = tmpstra
#      strarr[2] = tmpstrb
#      strarr[3] = tmpstrc
#      strarr[4] = tmpstrd
#      strarr[5] = tmpstre
#      strarr[6] = tmpstrf
#      strarr[7] = tmpstrg
#      strarr[8] = tmpstrh
#      strarr[9] = tmpstri
#      strarr[10] = tmpstrj
#      tmpreal = real(strarr[col])
#      if (tmpreal > (mean - (msigma * sigma)) && tmpreal < (mean + (msigma * sigma))){
#        ngood += 1
#        sum += tmpreal
#        sumsqrs += tmpreal * tmpreal
##        print("calcsnr: ngood = "//ngood//": sum = "//sum//", sumsqrs = "//sumsqrs)
#      }
#    }
#  }
#
#  if (ngood == 0 || ngood == 1){
#    print("calcsnr: ERROR: File '"//filename//"': not enough good pixels found => returning")
#    print("calcsnr: ERROR: File '"//filename//"': not enough good pixels found => returning", >> logfile)
#    print("calcsnr: ERROR: File '"//filename//"': not enough good pixels found => returning", >> warningfile)
#    print("calcsnr: ERROR: File '"//filename//"': not enough good pixels found => returning", >> errorfile)
## --- clean up
#    lines = ""
#    return
#  }
#  mean = sum / ngood
#  variance = (ngood * sumsqrs - (sum * sum)) / (ngood * (ngood - 1))
#  if (variance < 0)
#    sigma = 0.
#  else
#    sigma = sqrt(variance)
#  
#  print("mean "//mean, >> outfile)
#  print("rms "//sigma, >> outfile)
#  npixrej = nlines - ngood
#  print("pixels_rejected "//npixrej, >> outfile)
##  print("calcsnr: ...second run ready")
##  print("calcsnr: MEAN of column "//col//": "//mean)
##  print("calcsnr: RMS of column  "//col//": "//sigma)
##  print("calcsnr: "//npixrej//" pixels rejected")
#  if (loglevel > 1){
#    print("calcsnr: ...second run ready", >> logfile)
#    print("calcsnr: MEAN of column "//col//": "//mean, >> logfile)
#    print("calcsnr: RMS of column  "//col//": "//sigma, >> logfile)
#    print("calcsnr: "//npixrej//" pixels rejected", >> logfile)
#  }

# --- clean up
  lines = ""

end
