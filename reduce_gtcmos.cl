procedure reduce_gtcmos(indirs)

string indirs     = "@dirs.list"    {prompt="list of directories to reduce"}
string home       = "/iraf/iraf/extern/gtcmos/inputs/" {prompt="directory where tn_ext_curve.dat is stored"}
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
    string in,stdstarname,stdtblgood,stddir,stdav,tmpstr
    string dir,red,reddir,obs,goodobs,grism,std,goodstds,goodstdsfound,stdtbl,stdtbls,standardtable
    int lambdamin,lambdamax,arrsize,iarr,lammin,lammax,lammintmp,lammaxtmp,i

    if (delold == "yes"){
#        !rm logfile.log
        !rm tmp*
        !rm */tmp*
        !rm */*/tmp*
        !rm */*/*/tmp*
        !rm */*/*/*/tmp*
    }

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
#                !ls > ls.list
#
#                redfile = mktemp ("tmp")
#                sections("@ls.list", option="root", > redfile)
#                redlist = redfile
#                while (fscan (redlist, red) != EOF){
#                    print("red = <"//red//">")
#                    if (red != "ls.list"){
#                        print("starting reduction")
                reddir = osfn(dir//red)
                print("dir for reduction = <"//reddir//">")
                chdir(reddir)
                
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

                # --- reduce flats
                omstart("flat", mos+)
                omcomb("gtc*_flat_*.fits", fileout="gtc_flat_av", imtype="flat")
                omflat("gtc_flat_av", outfile="gtc_master_flat", flatcor="longslit", illcorr="none")

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
                omreduce("gtc_object_av", filarc="gtc_arc_sum", filflat="gtc_master_flat", checksky+, lamsky = 5577.838)
                omskysub("gtc_object_av_wl_flt")

                # --- reduce standards
                omstart("stds", mos-)
                omstart("stds", mos+, biasim="gtc_bias_av")
                !ls gtc*stds_*.fits > stds.list
                stdsfile = mktemp ("tmp")
                sections("@stds.list", option="root", > stdsfile)
                stdslist = stdsfile
                goodstds = ""
                goodstdsfound = ""
                stdav = ""
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

                        std = substr(std,1,strldx(".",std)-1)
                        print("std = <"//std//">")
                        if (goodstds != ""){
                            goodstds = goodstds//","
                            print("goodstds != '' => goodstds = <"//goodstds//">")
                        }
                        goodstds = goodstds//std
                        print("goodstds = <"//goodstds//">")

                        hedit(std, fields="DISPAXIS", value="2", add+, del-, ver-, update+)

                        omreduce(std, filarc="gtc_arc_sum", filflat="gtc_master_flat")

                        apall(std//"_wl_flt", nfind=1, interac-, extras+, resi-, lower=-20, upper=20, b_sampl="-50:-40,40:50", t_funct="legendre", t_order=5, backgro="median")
                        omskysub(std//"_wl_flt")

                        imgets(std,"OBJECT")
                        stdstarname=imgets.value
                        stdstarname=substr(stdstarname,7,strlen(stdstarname))
                        stdstarname=strlwr(stdstarname)
                        if (stridx("-",stdstarname) > 0){
                            tmpstr = ""
                            for (i=1;i<=strlen(stdstarname); i=i+1){
                                if (substr(stdstarname,i,i) != "-"){
                                    tmpstr = tmpstr//substr(stdstarname,i,i)
                                }
                            }
                            stdstarname = tmpstr
                        }
                        print("stdstarname = <"//stdstarname//">")
                        arrsize = 0

                        # --- find directories with our standard star
                        find("/iraf/iraf -name "//stdstarname//".dat > standardstarnamefound.list")
                        stdtblsfile=mktemp("tmp")
                        sections("@standardstarnamefound.list", option="root", > stdtblsfile)
                        stdtblslist = stdtblsfile
                        stdtblgood = ""
                        lammin = 100000
                        lammax = 0

                        # --- find stdtbl with widest wavelength range
#                            struct line
                        while(fscan(stdtblslist, stdtbl) != EOF){
                            print("reading stdtbl = <"//stdtbl//">")
#                                stdfile = mktemp("tmp")
#                                sections("@"//stdtbl, option="root", > stdfile)
                            stdlist = stdtbl
                            lammintmp = 0
                            lammaxtmp = 0
                            while(fscan(stdlist,line) != EOF){
#                                    print("line = <"//line//">")
                                if (substr(line,1,1) != "#"){
                                    if (strlen(line) > 3){
                                        while(substr(line,1,1) == " "){
                                            line = substr(line,2,strlen(line))
                                        }
#                                            print("line = <"//line//">: substr(line,1,stridx(.,line)-1) = <"//substr(line,1,stridx(".",line)-1)//">")
                                        if (lammintmp == 0){
                                            lammintmp=int(substr(line,1,stridx(".",line)-1))
                                        }
                                        lammaxtmp=int(substr(line,1,stridx(".",line)-1))
                                    }
                                }
                            }
                            delete(stdfile, ver-, >& "dev$null")
                            print("lammintmp = "//lammintmp//", lammin = "//lammin//", lammaxtmp = "//lammaxtmp//", lammax = "//lammax)
                            if (lammintmp < lammin){
                                print("lammintmp(="//lammintmp//") < lammin(="//lammin//")")
                                if (lammaxtmp > lammax){
                                    print("lammaxtmp(="//lammaxtmp//") > lammax(="//lammax//")")
                                    lammin = lammintmp
                                    lammax = lammaxtmp
                                    stdtblgood = stdtbl
                                    print("Set lammin to "//lammin//", lammax to "//lammax//", stdtblgood to <"//stdtblgood//">")
                                }
                            }
                        }
                        delete(stdtblsfile, ver-, >& "dev$null")

                        if (stdtblgood == ""){
                            print("ERROR: no good stdtable found")
                        }
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
                        stdav = substr(std,1,strldx("_",std)-1)//"_flux"
                        print("stdav = <"//stdav//">")
                        if (stddir != ""){
                            standard(std//"_wl_flt.ms", stdav//".std", extinct="gtcinputs$tn_ext_curve.dat", caldir=stddir, star_nam=stdstarname, answer="NO!",interact-)
                            if (goodstdsfound != ""){
                                goodstdsfound = goodstdsfound//","
                            }
                            goodstdsfound = goodstdsfound//std

#                                omskysub(stdav//".std")
                        }
                    }
                }

                sensfunc(stdav//".std", stdav//"_sens", extinct="gtcinputs$tn_ext_curve.dat", inter-)

                print("goodstds = <"//goodstds//">")
                print("goodstdsfound = <"//goodstdsfound//">")
                if (goodstdsfound == ""){
                    print("ERROR: no good standards found in standards directories")
                }
#                    print("goodobs = <"//goodobs//">")
#                    while(strlen(goodobs) > 0){
#                        if (stridx(",",goodobs)>0){
#                            obs = substr(goodobs,1,stridx(",",goodobs)-1)
#                            goodobs = substr(goodobs,stridx(",",goodobs)+1,strlen(goodobs))
#                        } else{
#                            obs = goodobs
#                        }
                print("calibrating object")
                calibrate("gtc_object_av_wl_flt", "gtc_object_av_wl_flt_cal", extinct+, flux+, extinction=home//"tn_ext_curve.dat", sensiti=stdav//"_sens")
                print("calibrating object finished")
#                        calibrate(gtc12b_p1abc_ccd1tbf_wl.ms gtc12b_p1abc_ccd1tbf_wl.ms_cal extinct+ flux+ extinction=home$tn_ext_curve.dat sensiti=sens_gtc12b_p1GD140_ccd2tbf.std
#                    }
    #        }
#                break
    #    }
    #    redlist = ""
    #    delete (redfile, ver-, >& "dev$null")
            }
        }
#        break
    }

# --- clean up
    dirlist = ""
    delete (infile, ver-, >& "dev$null")

end
