procedure reduce_gtcmos(indirs)

string indirs     = "@dirs.list"    {prompt="list of directories to reduce"}
string clobber     = "yes"          {prompt="delete old ouput files?", enum="yes|no"}
string *dirlist
string *stdskieslist

begin

    file   infile,redfile,obsfile,stdskiesfile,stdtblsfile,stdfile
    string in,stdstarname,stdtblgood,stddir,stdav,tmpstr,objectsky,stdsky
    string dir,red,reddir,obs,goodobs,grism,std,goodstds,goodstdsfound,stdtbl,stdtbls,standardtable
    int    lambdamin,lambdamax,arrsize,iarr,lammin,lammax,lammintmp,lammaxtmp,i
    float  exptimestd,exptimeobs,scalingfactor


    # --- Erzeugen von temporaeren Filenamen
    infile = mktemp ("tmp")

  # --- Umwandeln der Listen von Frames in temporaere Files
    if ((substr(indirs,1,1) == "@" && access(substr(indirs,2,strlen(indirs)))) || (substr(indirs,1,1) != "@" && access(indirs))){
        sections(indirs, option="root", > infile)
        dirlist = infile
    }
    else{
        if (substr(indirs,1,1) != "@"){
            print("reduce_gtcmos: ERROR: "//indirs//" not found!!!")
        }
        else{
            print("reduce_gtcmos: ERROR: "//substr(indirs,2,strlen(indirs))//" not found!!!")
        }
        return
    }

    objectsky = "gtc_object_av_wl_flt_sky.fits"
    imgets(objectsky,"EXPTIME")
    exptimeobs = float(imgets.value)
    print("exptimeobs = "//exptimeobs//" s")

    dir = ""
    while (fscan (dirlist, in) != EOF){
        print("in = <"//in//">")
        if (substr(in,1,1) != "#"){
            if (substr(in,strlen(in),strlen(in)) == ":"){
                dir = substr(in,1,strlen(in)-1)
                print("dir = <"//dir//">")
            }
            else if (strlen(in) > 2){
                red = in
                print("starting reduction")
                reddir = osfn(dir//red)
                print("dir for reduction = <"//reddir//">")
                chdir(reddir)

                !ls gtcstdobdts_stds_*_wl_flt_sky.fits > stdskies.list
                stdskiesfile = mktemp ("tmp")
                sections("@stdskies.list", option="root", > stdskiesfile)
                stdskieslist = stdskiesfile
                if (fscan(stdskieslist, stdsky) != EOF){
                    if (access(stdsky)){
                        imgets(stdsky,"EXPTIME")
                        exptimestd = float(imgets.value)
                        print("exptimestd = "//exptimestd//" s")
                        scalingfactor = exptimeobs / exptimestd
                        print("scalingfactor = "//scalingfactor)

                        # --- scale standard sky image with scalingfactor
                        imarith(stdsky,"*",scalingfactor,"stdsky_scaled")
                        imcopy("stdsky_scaled[:,1]","extended_object")
                    }
                    else{
                        print("ERROR: stdsky = <"//stdsky//"> not found")
                    }
                }
                else{
                    print("ERROR: no standard sky found")
                    break
                }
            }
        }
    }

end
