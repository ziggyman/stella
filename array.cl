procedure array ()

string strarr[2] = "a","b"   {prompt="array to test"}
string arrfile   = "/home/azuri/daten/idl/RXJ1523/hjds.list"   {prompt="file to read array from"}
int    arrlength = 10        {prompt="array length to set"}
string* arrlist

begin
  string str,stra
  int nlines,i,nwords,nchars
#  int len = arrlength
  string filearr[1000,2]

  if (access("arrfile_wc_out"))
    del("arrfile_wc_out", ver-)
  wc(arrfile, > "arrfile_wc_out")
  arrlist = "arrfile_wc_out"
  while (fscan(arrlist, nlines, nwords, nchars, str) != EOF){
    print("wc out: nlines = "//nlines//", nwords = "//nwords//", nchars = "//nchars//", str = "//str)
  }

  i=0
  arrlist = arrfile
  while (fscan(arrlist,str,stra) != EOF){
    i = i+1
    filearr[i,1] = str
    filearr[i,2] = stra
    print("filearr["//i//",1] = "//filearr[i,1])
    print("filearr["//i//",2] = "//filearr[i,2])
  }


  for (i=1;i<=2;i=i+1){
#    strarr[i] = "a"
    print("array: strarr["//i//"] = "//strarr[i])
  }

end
