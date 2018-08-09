procedure reduce_gtcmos(indirs)

string indirs     = "@dirs.list"    {prompt="list of directories to reduce"}
string delold     = "yes"           {prompt="delete old ouput files?", enum="yes|no"}
string *dirlist
string *redlist
string *obslist
string *stdslist
string *stdtblslist
string *stdlist

begin

#  gtcmos

    file   infile,redfile,obsfile,stdsfile,stdtblsfile,stdfile
    string in,stdstarname,stdstarroot,stdtblgood,stddir
    string dir,red,obs,goodobs,grism,std,goodstds,stdtbl,stdtbls,standardtable,stdline
    int lambdamin,lambdamax,arrsize,iarr,lammin,lammax,lammintmp,lammaxtmp

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

    if (defpac("images") == no) {
        print ("Loading images package")
        images
    }
    if (defpac("imutil") == no) {
        print ("Loading imutil package")
        imutil
    }
    if (defpac("gtcmos") == no) {
        print ("Loading gtcmos package")
        gtcmos
    }

# --- build output filenames
    while (fscan (dirlist, in) != EOF){
        print("in = <"//in//">")
        if (substr(in,strlen(in),strlen(in)) == ":"){
            dir = osfn(substr(in,1,strlen(in)-1))
            print("dir = <"//dir//">")
            chdir(dir)
            !ls > ls.list

            redfile = mktemp ("tmp")
            sections("@ls.list", option="root", > redfile)
            redlist = redfile
            while (fscan (redlist, red) != EOF){
                print("red = <"//red//">")
                if (red != "ls.list"){
                    print("starting reduction")
                    dir = osfn(substr(in,1,strlen(in)-1)//red)
                    print("dir for reduction = <"//dir//">")
                    chdir(dir)

                    # --- delete old results
                    if (delold == "yes"){
                        !rm *.fits
                        !rm tmp*
                        !rm *.dat
                        !rm *.mc
                        !rm *.rms
                        !rm *.rms_stat
                        !rm *.output
                        !rm *.cursor
                        !rm *.list
                        !rm *.lis
                        !rm *.log
                    }

                    # --- reduce arcs
                    omstart("arc")
                    omstart("arc", mos+)
                    omcomb("gtcarc*_arc_*.fits", fileout="gtc_arc_sum", imtype="arc")
    #                apextract.dispaxis=2
                    hedit("gtc_arc_sum", fields="DISPAXIS", value="2", add+, del-, ver-, update+)
                    omidentify("gtc_arc_sum", "DEFAULT")
                    omreidentify("identify.rms")

                    # --- reduce biases
                    omstart("bias", mos+)
                    omcomb("gtc*_bias_*.fits", fileout="gtc_bias_av", imtype="bias")

                    # --- reduce objects
                    omstart("object", mos+, biasim="gtc_bias_av")
                    !ls gtc*object_*.fits > objects.list
                    obsfile = mktemp ("tmp")
                    sections("@objects.list", option="root", > obsfile)
                    obslist = obsfile
                    goodobs = ""
                    while (fscan(obslist, obs) != EOF){
                        print("obs = <"//obs//">")
                        imgets(obs,"GRISM")
                        grism = imgets.value
                        print("grism = <"//grism//">")
                        if (grism != "OPEN"){
                            print("obs = <"//obs//">")
                            if (goodobs != ""){
                                goodobs = goodobs//","
                                print("goodobs != '' => goodobs = <"//goodobs//">")
                            }
                            goodobs = goodobs//obs
                            print("goodobs = <"//goodobs//">")
                            hedit(obs, fields="DISPAXIS", value="2", add+, del-, ver-, update+)
                        }
                    }
                    print("goodobs = <"//goodobs//">")
                    omcomb(goodobs, fileout="gtc_object_av")
                    omreduce("gtc_object_av", filarc="gtc_arc_sum", checksky+, lamsky = 5577.838)

                    # --- reduce standards
                    omstart("stds", mos-)
                    omstart("stds", mos+, biasim="gtc_bias_av")
                    !ls gtc*stds_*.fits > stds.list
                    stdsfile = mktemp ("tmp")
                    sections("@stds.list", option="root", > stdsfile)
                    stdslist = stdsfile
                    goodstds = ""
                    while (fscan(stdslist, std) != EOF){
                        print("std = <"//std//">")
                        imgets(std,"GRISM")
                        grism = imgets.value
                        print("grism = <"//grism//">")
                        if (grism != "OPEN"){
                            getgtcmoslambdarange(grism)
                            lambdamin = getgtcmoslambdarange.lambdamin
                            lambdamax = getgtcmoslambdarange.lambdamax
                            print("lambdamin = "//lambdamin//", lambdamax = "//lambdamax)

                            print("std = <"//std//">")
                            if (goodstds != ""){
                                goodstds = goodstds//","
                                print("goodstds != '' => goodstds = <"//goodstds//">")
                            }
                            goodstds = goodstds//std
                            print("goodstds = <"//goodstds//">")

                            hedit(std, fields="DISPAXIS", value="2", add+, del-, ver-, update+)

                            omreduce(std, filarc="gtc_arc_sum")

                            apall(std, interac-, extras+, resi-, lower=-20, upper=20, b_sampl="-50:-40,40:50", t_funct="legendre", t_order=5, backgro="median")

                            imgets(std,"OBJECT")
                            stdstarname=imgets.value
                            stdstarname=substr(stdstarname,7,strlen(stdstarname))
                            stdstarname=strlwr(substr(stdstarname,1,1))//substr(stdstarname,2,strlen(stdstarname))
                            print("stdstarname = <"//stdstarname//">")
                            arrsize = 0

                            # --- find directories with our standard star
                            # --- we first need to scan each directory for the star before
                            # --- we can populate our arrays
                            !find /iraf/iraf -name stdstarname//".dat" > standardstarnamefound.list
                            stdtblsfile=mktemp("tmp")
                            sections("standardstarnamefound.list", option="root", > stdtblsfile)
                            stdtblslist = stdtblsfile
                            lammin = 100000
                            lammax = 0

                            # --- find stdtbl with widest wavelength range
                            while(fscan(stdtblslist, stdtbl) != EOF){
                                stdfile = mktemp("tmp")
                                sections(stdtbl, option="root", > stdfile)
                                stdlist = stdfile
                                lammintmp = 0
                                lammaxtmp = 0
                                while(fscan(stdlist,stdline) != EOF){
                                    if (substr(stdline,1,1) != "#"){
                                        if (lammintmp == 0){lammintmp=int(substr(stdline,3,6))}
                                        lammaxtmp=int(substr(stdline,3,6))
                                    }
                                }
                                delete(stdfile, ver-, >& "dev$null")
                                if (lammintmp < lammin){
                                    if (lammaxtmp > lammax){
                                        lammin = lammintmp
                                        lammax = lammaxtmp
                                        stdtblgood = stdtbl
                                    }
                                }
                            }
                            delete(stdtblsfile, ver-, >& "dev$null")

                            print("lambdamin = "//lambdamin//", lambdamax = "//lambdamax)
                            print("lammin = "//lammin//", lammax = "//lammax)
                            if (lammin > lambdamin){
                                print("reduce_gtcmos: WARNING: lambdamin(="//lammin//") in "//stdtblgood//" is greater than lambdamin in spectrum (="//lambdamin//")")
                            }
                            if (lammax < lambdamax){
                                print("reduce_gtcmos: WARNING: lambdamax(="//lammax//") in "//stdtblgood//" is less than lambdamax in spectrum (="//lambdamax//")")
                            }
                            standardtable = stdtblgood
                            stddir = substr(standardtable,1,strldx("/",standardtable))
                            print("stddir = <"//stddir//">")

                            print("std = <"//std//">")
                            stdstarroot=substr(std,1,strlen(std)-5)
                            print("stdstarroot = <"//stdstarroot//">")
                            standard(stdstarroot//".ms", stdstarroot//".std", extinct="gtcinputs$tn_ext_curve.dat", caldir="onedstds$/spec50cal/", star_nam=stdstarname)
                        }
                    }
                    print("goodstds = <"//goodstds//">")
                }
                break
            }
            redlist = ""
            delete (redfile, ver-, >& "dev$null")
        }
        break
    }

# --- clean up
    dirlist = ""
    delete (infile, ver-, >& "dev$null")

end
