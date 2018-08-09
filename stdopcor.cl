procedure stdopcor (inimages)

###################################################################
#                                                                 #
#      This program the STELLA-Echelle spectra automatically      #
#            by the observed radial velocities (vobx)             #
#         (uses fxorlist output file for the input list)          #
#                                                                 #
# Andreas Ritter, 14.12.2001                                      #
#                                                                 #
###################################################################

string inimages      = "@input.list"                 {prompt="List of input inimages"}
string fxcorout      = "fxcor_out.txt"               {prompt="Name of fxcorlist-out file"}
string objectstr     = "OBJECT"                      {prompt="Object identifier"}
string *inputlist
string *fxcorlist

begin

  string object,image,ref,hjd,ap,codes,shift,hght,fwhm,tdr,vobs,vrel,vhelio,verr
  file   infile
  string in,out,fxcorline,dumstring
  string dumlinestr
  int    i,j,k
  int    nlinesin = 0
  int    nlinesfx = 0
  real   vrad

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*  correcting spectra by the observed radial velocities  *")
  print ("*                                                        *")
  print ("**********************************************************")

# --- read fxcorout
  if ( access(fxcorout)){
    fxcorlist = fxcorout
    i = 0
    while(fscan(fxcorlist,object,image,ref,hjd,ap,codes,shift,hght,fwhm,tdr,vobs,vrel,vhelio,verr) != EOF){
      i = i+1
      if (object == objectstr){
        print("stdopcor: object=<"//object//">, image =<"//image//">, ref =<"//ref//">, hjd =<"//hjd//">, ap =<"//ap//">, codes =<"//codes//">, shift =<"//shift//">, hght =<"//hght//">, fwhm =<"//fwhm//">, tdr =<"//tdr//">")
        print"vobs =<"//vobs//">, vrel =<"//vrel//">, vhelio =<"//vhelio//">, verr =<"//verr//">")
# --- outfile
        if (substr(image,strlen(image)-4,strlen(image)) == ".fits")
          out = substr(image,1,strlen(image)-5)//"v.fits"
        else
          out = image//"v"
        print("stdopcor: in = "//image//", out = "//out)
        if (access(out)){
          imdel(out, ver-)
          if (access(out))
            del(out, ver-)
        }

# --- read inimages
        print("stdopcor: reading "//inimage)
        if ( substr(inimages,1,1) == "@" )
          inimages = substr(inimages,2,strlen(inimages))
        if  (access(inimages)){

          inputlist = inimages
          j = 0
          while(fscan(inputlist,in) != EOF){
            j = j+1
            print("stdopcor: in = "//in)
            if ((substr(in,strlen(in)-4,strlen(in)) == ".fits" && substr(image,strlen(image)-4,strlen(image)) == ".fits" &&
                   image == in && access(in)) ||
                (substr(in,strlen(in)-4,strlen(in)) == ".fits" && substr(image,strlen(image)-4,strlen(image)) != ".fits" &&
                   image//".fits" == in && access(in)) ||
                (substr(in,strlen(in)-4,strlen(in)) != ".fits" && substr(image,strlen(image)-4,strlen(image)) == ".fits" &&
                   image == in//".fits" && access(in)) ||
                (substr(in,strlen(in)-4,strlen(in)) != ".fits" && substr(image,strlen(image)-4,strlen(image)) != ".fits" &&
                   image == in && access(in))){
              print("stdopcor: "//image//" found in "//inimages)
#              vrad = vobs
              print("stdopcor: vrad = "//vobs)
              print("stdopcor: starting dopcor")
              dopcor(input = in,
                     output = out,
                     redshift = vobs,
                     isvelocity+,
                     add-,
                     dispersion+,
                     flux-,
                     ver+)
            }
          }
        }
        else{
          if (substr(inimages,1,1) != "@"){
            print("stdopcor: ERROR: "//inimages//" not found!!!")
          }
          else{
            print("stdopcor: ERROR: "//substr(inimages,2,strlen(inimages))//" not found!!!")
          }

# --- clean up
          inputlist       = ""
          fxcorlist       = ""
          delete (infile, ver-, >& "dev$null")
          return
        }
      }# --- end if (... = "#  Velocity")
    }# --- end WHILE(fscan(fxcorlist,...
  }# --- end if ( access(...
  else{
    print("stdopcor: ERROR: "//fxcorout//" not found!!!")
# --- clean up
    inputlist       = ""
    fxcorlist       = ""
    delete (infile, ver-, >& "dev$null")
    return
  }

# --- aufraeumen
  inputlist = ""
  fxcorlist = ""
  delete (infile, ver-, >& "dev$null")

end
