procedure reduce_gtcmos(indirs)

string indirs     = "@dirs.list"    {prompt="list of directories to reduce"}
string clobber     = "yes"          {prompt="delete old ouput files?", enum="yes|no"}
string *dirlist
string *redlist
string *obslist
string *stdslist
string *stdtblslist
string *stdlist

begin

    file   infile,redfile,obsfile,stdsfile,stdtblsfile,stdfile
    string in,stdstarname,stdtblgood,stddir,stdav,tmpstr
    string dir,red,reddir,obs,goodobs,grism,std,goodstds,goodstdsfound,stdtbl,stdtbls,standardtable
    int    lambdamin,lambdamax,arrsize,iarr,lammin,lammax,lammintmp,lammaxtmp,i


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


end
