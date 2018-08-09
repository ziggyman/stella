procedure revertfilelines(filename)

string filename = "temp.text"    {prompt="Name of file to revert lines"}
string *linelist

begin
  int nlines,nwords,nchars
  string tempstr
  string tempfile  = "revertfilelines.temp"
  string tempfilea = "revertfilelines_2.temp"
  string tempfileb = "revertfilelines_wc_out.temp"

  if (!access(filename)){
    print("revertfilelines: ERROR: file '"//filename//"' not accessable!!! => returning")
    return
  }
  if (access(tempfile))
    del(tempfile, ver-)
  nlines = 1
  while (nlines > 0){
    if (access(tempfilea))
      del(tempfilea, ver-)
    if (access(tempfileb))
      del(tempfileb, ver-)
    wc(filename, > tempfileb)
    wait()
    linelist = tempfileb
    while (fscan(linelist, nlines, nwords, nchars, tempstr) != EOF){
      print("wc out: nlines = "//nlines//", nwords = "//nwords//", nchars = "//nchars//", tempstr = "//tempstr)
    }
    tail(filename, nlines=1, >> tempfile)
    head(filename, nlines=nlines-1, >> tempfilea)
    wait()
    del(filename, ver-)
    copy(input=tempfilea,
         output=filename,
         ver-)
    nlines -= 1
  }
  del(filename, ver-)
  copy(input=tempfile,
       output=filename,
       ver-)

# --- clean up
  if (access(tempfile))
    del(tempfile, ver-)
  if (access(tempfilea))
    del(tempfilea, ver-)
  if (access(tempfileb))
    del(tempfileb, ver-)

end
