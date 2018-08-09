real procedure mean(filename, column)

#####################################################################################
#                                                                                   #
#     This program returns the mean of column <column> of file <filename>.          #
#                                                                                   #
# inputs:  string filename                                                          #
#            content: 234.2342 234.523 2356.2342 2346.23 345.4 ... <max 10 columns> #
#                     235.234  26.2342 234.23462 234.234 34.343 ...                 #
#                         ...                                                       #
#          int column (1..10)                                                       #
#                                                                                   #
# Andreas Ritter, 20.01.2005                                                        #
#                                                                                   #
#####################################################################################

string filename = "/yoda/UVES/MNLupus/ready/RXJ1523_blue_combined11-13.text" {prompt="Name of data file"}
int    column   = 2                                                          {prompt="No of column to calculate mean (1..10)"}
string *filerows

begin
  int    nrows = 0
  real   mean = 0.
  string row

  if (!access(filename))
    return (mean)

  filerows = filename
  while (fscan(filerows,row) != EOF){
    nrows = nrows + 1
    print("mean.cl: row("//nrows//") = "//row)
  }

  return (mean)

end
