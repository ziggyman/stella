procedure readfilenumbers (images)

string images = "filelist" {prompt="filelist containing the files with counters"}
string *myfiles

begin
  string tempstring = ""
  int    i          = 0

  if (access(images)){
    myfiles = images
  }
  else print("Error")

  while (fscan(myfiles,tempstring) != EOF){
    i = int(substr(tempstring,5,9))
    print("i = "//i)
  }

  myfiles = ""
end