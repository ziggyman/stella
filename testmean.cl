procedure testmean (filename,column)

string filename = "/yoda/UVES/MNLupus/ready.text" {prompt="File name"}
int    column   = 1   {prompt="No of column"}

begin
  real meanval = 0.

  print("testmean: starting mean")
  meanval = mean(file,column)
  print("testmean: mean ready: meanval = "//meanval)
end
