#procedure stloadpackages (instrument)

##########################################################################
#                                                                        #
#   This program loads the packages needed to execute the stall.cl task  #
#                                                                        #
# Andreas Ritter, 30.07.2004                                             #
#                                                                        #
##########################################################################
#string instrument = "echelle"   {prompt="Instrument to set",
#                                  enum="echelle|coude"}

#begin
  noao
  imred
  ccdred
  echelle
keep

