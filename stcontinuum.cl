procedure stcontinuum (Images)

##################################################################
#                                                                #
# NAME:             stcontinuum.cl                               #
# PURPOSE:          * continuum-normalised the extracted         #
#                     spectra in <Images> automatically          #
#                                                                #
# CATEGORY:                                                      #
# CALLING SEQUENCE: stcontinuum(Images)                          #
# INPUTS:           Images: String                               #
#                     name of file containing filenames to       #
#                     continuum-normalise                        #
#                                                                #
# OUTPUTS:          <Entry_in_Images_Root>n.<ImType>             #
#                                                                #
# IRAF VERSION:     2.12                                         #
#                                                                #
# COPYRIGHT:        Andreas Ritter                               #
# CONTACT:          aritter@aip.de                               #
#                                                                #
# CREATED:          10.01.2006                                   #
# LAST EDITED:      11.12.2006                                   #
#                                                                #
##################################################################

string Images        = "@tosetcontinuum.list"  {prompt="List of input images"}
string ErrorImages   = "@tosetcontinuum_err.list" {prompt="List error images"}
string ParameterFile = "parameterfile.prop"    {prompt="Name of ParameterFile"}
string Mode          = "orders"                {prompt="Mode: orders/single",
                                                 enum="orders|single"}
string ImType        = "fits"                  {prompt="Image Type"}
string LogFile       = "logfile_stmerge.log"   {prompt="Name of LogFile"}
string WarningFile   = "warnings_stmerge.log"  {prompt="Name of warning file"}
string ErrorFile     = "errors_stmerge.log"    {prompt="Name of error file"}
int    LogLevel      = 3                       {prompt="Level for writing LogFile [1-3]"}
bool   DoErrors      = YES                     {prompt="Calculate error propagation?"}
string Lines         = "*"                     {prompt="Image lines to be fit"}
string Bands         = "1"                     {prompt="Image bands to be fit"}
#string Type          = "ratio"                 {prompt="Type of output",
#                                                 enum="data|fit|difference|ratio"}
bool   Replace       = NO                      {prompt="Replace rejected points by fit?"}
bool   WaveScale     = YES                     {prompt="Scale the X axis with wavelength?"}
bool   LogScale      = NO                      {prompt="Take the log (base 10) of both axes?"}
bool   Override      = YES                     {prompt="Override previously fit lines?"}
bool   ListOnly      = NO                      {prompt="List fit but don't modify any images?"}
bool   Interactive   = NO                      {prompt="Set fitting parameters interactively?"}
string Sample        = "*"                     {prompt="Sample points to use in fit"}
int    NAverage      = 1                       {prompt="Number of points in sample averaging"}
string Function      = "spline3"               {prompt="Fitting function",
                                                 enum="spline3|legendre|chebyshev|spline1"}
int    Order         = 13                      {prompt="Order of fitting function"}
real   LowReject     = 0.6                     {prompt="Low rejection in sigma of fit"}
real   HighReject    = 8.                      {prompt="High rejection in sigma of fit"}
int    NIterate      = 4                       {prompt="Number of rejection iterations"}
real   Grow          = 0.                      {prompt="Rejection growing radius in pixels"}
bool   MarkRej       = NO                      {prompt="Mark rejected points?"}
string Ask           = YES                     {prompt="",
                                                 enum="yes|no|skip|YES|NO|SKIP"}
string *InList
string *ErrList
string *ParameterList

begin

  string Parameter,ParameterValue,In,Fit,Out,ErrOut,TempFileName,TempString
  string TextOut,Suffix,ListName
  string LogFile_continuum = "logfile_continuum.log"
  string LogFile_sarith    = "logfile_sarith.log"
  int    Pos,i,NRun
  file   InFile,ErrFile
  bool   FoundImType      = NO
  bool   FoundLines       = NO
  bool   FoundBands       = NO
  bool   FoundType        = NO
  bool   FoundReplace     = NO
  bool   FoundWaveScale   = NO
  bool   FoundLogScale    = NO
  bool   FoundOverride    = NO
  bool   FoundListOnly    = NO
  bool   FoundInteractive = NO
  bool   FoundSample      = NO
  bool   FoundNAverage    = NO
  bool   FoundFunction    = NO
  bool   FoundOrder       = NO
  bool   FoundLowReject   = NO
  bool   FoundHighReject  = NO
  bool   FoundNIterate    = NO
  bool   FoundGrow        = NO
  bool   FoundMarkReject  = NO
  bool   FoundAsk         = NO

# --- delete old logfiles
  if (access(LogFile))
    del(LogFile, ver-)
  if (access(WarningFile))
    del(WarningFile, ver-)
  if (access(ErrorFile))
    del(ErrorFile, ver-)

  print ("**********************************************************")
  print ("*                                                        *")
  print ("* Automatic data-reduction of the STELLA Echelle spectra *")
  print ("*                                                        *")
  print ("*                    stcontinuum.cl                      *")
  print ("*       (continuum normalizes the input fits files)      *")
  print ("*                                                        *")
  print ("**********************************************************")
  print ("**********************************************************", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("* Automatic data-reduction of the STELLA Echelle spectra *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("*                    stcontinuum.cl                      *", >> LogFile)
  print ("*       (continuum normalizes the input fits files)      *", >> LogFile)
  print ("*                                                        *", >> LogFile)
  print ("**********************************************************", >> LogFile)
  print ("stmerge: Images = <"//Images//">")
  print ("stmerge: ErrorImages = <"//ErrorImages//">")
  print ("stmerge: Mode = <"//Mode//">")
  print ("stmerge: Images = <"//Images//">", >> LogFile)
  print ("stmerge: ErrorImages = <"//ErrorImages//">", >> LogFile)
  print ("stmerge: Mode = <"//Mode//">", >> LogFile)

# --- read ParameterFile
  if (access(ParameterFile)){
    ParameterList = ParameterFile
    while(fscan(ParameterList, Parameter, ParameterValue) != EOF){
      if (Parameter == "imtype"){
        ImType = ParameterValue
        print("stcontinuum: Setting parameter ImType to <"//ImType//">")
        print("stcontinuum: Setting parameter ImType to <"//ImType//">", >> LogFile)
        FoundImType = YES
      }
#      else if (Parameter == "calc_error_propagation"){
#        if (ParameterValue == "YES" || ParameterValue == "Yes" || ParameterValue == "yes" || ParameterValue == "+")
#          DoErrors = YES
#        else
#          DoErrors = NO
#        print("stcontinuum: Setting parameter DoErrors to <"//DoErrors//">")
#        print("stcontinuum: Setting parameter DoErrors to <"//DoErrors//">", >> LogFile)
#        FoundDoErrors = YES
#      }
      else if (Parameter == "continuum_lines"){
        Lines = ParameterValue
        print("stcontinuum: Setting parameter Lines to <"//Lines//">")
        print("stcontinuum: Setting parameter Lines to <"//Lines//">", >> LogFile)
        FoundLines = YES
      }
      else if (Parameter == "continuum_bands"){
        Bands = ParameterValue
        print("stcontinuum: Setting parameter Bands to <"//Bands//">")
        print("stcontinuum: Setting parameter Bands to <"//Bands//">", >> LogFile)
        FoundBands = YES
      }
#      else if (Parameter == "continuum_type"){
#        Type = ParameterValue
#        print("stcontinuum: Setting parameter Type to <"//Type//">")
#        print("stcontinuum: Setting parameter Type to <"//Type//">", >> LogFile)
#        FoundType = YES
#     }
      else if (Parameter == "continuum_replace"){
        if (ParameterValue == "YES" || ParameterValue == "Yes" || ParameterValue == "yes" || ParameterValue == "+")
          Replace = YES
        else
          Replace = NO
        print("stcontinuum: Setting parameter Replace to <"//Replace//">")
        print("stcontinuum: Setting parameter Replace to <"//Replace//">", >> LogFile)
        FoundReplace = YES
      }
      else if (Parameter == "continuum_wavescale"){
        if (ParameterValue == "YES" || ParameterValue == "Yes" || ParameterValue == "yes" || ParameterValue == "+")
          WaveScale = YES
        else
          WaveScale = NO
        print("stcontinuum: Setting parameter WaveScale to <"//WaveScale//">")
        print("stcontinuum: Setting parameter WaveScale to <"//WaveScale//">", >> LogFile)
        FoundWaveScale = YES
      }
      else if (Parameter == "continuum_logscale"){
        if (ParameterValue == "YES" || ParameterValue == "Yes" || ParameterValue == "yes" || ParameterValue == "+")
          LogScale = YES
        else
          LogScale = NO
        print("stcontinuum: Setting parameter LogScale to <"//LogScale//">")
        print("stcontinuum: Setting parameter LogScale to <"//LogScale//">", >> LogFile)
        FoundLogScale = YES
      }
      else if (Parameter == "continuum_override"){
        if (ParameterValue == "YES" || ParameterValue == "Yes" || ParameterValue == "yes" || ParameterValue == "+")
          Override = YES
        else
          Override = NO
        print("stcontinuum: Setting parameter Override to <"//Override//">")
        print("stcontinuum: Setting parameter Override to <"//Override//">", >> LogFile)
        FoundOverride = YES
      }
      else if (Parameter == "continuum_listonly"){
        if (ParameterValue == "YES" || ParameterValue == "Yes" || ParameterValue == "yes" || ParameterValue == "+")
          ListOnly = YES
        else
          ListOnly = NO
        print("stcontinuum: Setting parameter ListOnly to <"//ListOnly//">")
        print("stcontinuum: Setting parameter ListOnly to <"//ListOnly//">", >> LogFile)
        FoundListOnly = YES
      }
      else if (Parameter == "continuum_interactive"){
        if (ParameterValue == "YES" || ParameterValue == "Yes" || ParameterValue == "yes" || ParameterValue == "+")
          Interactive = YES
        else
          Interactive = NO
        print("stcontinuum: Setting parameter Interactvie to <"//Interactive//">")
        print("stcontinuum: Setting parameter Interactive to <"//Interactive//">", >> LogFile)
        FoundInteractive = YES
      }
      else if (Mode == "single" && Parameter == "continuum_sample_single"){
        Sample = ParameterValue
        print("stcontinuum: Setting parameter sample to <"//Sample//">")
        print("stcontinuum: Setting parameter sample to <"//Sample//">", >> LogFile)
        FoundSample = YES
      }
      else if (Mode == "orders" && Parameter == "continuum_sample_orders"){
        Sample = ParameterValue
        print("stcontinuum: Setting parameter sample to <"//Sample//">")
        print("stcontinuum: Setting parameter sample to <"//Sample//">", >> LogFile)
        FoundSample = YES
      }
      else if (Mode == "single" && Parameter == "continuum_naverage_single"){
        NAverage = int(ParameterValue)
        print("stcontinuum: Setting parameter NAverage to <"//NAverage//">")
        print("stcontinuum: Setting parameter NAverage to <"//NAverage//">", >> LogFile)
        FoundNAverage = YES
      }
      else if (Mode == "orders" && Parameter == "continuum_naverage_orders"){
        NAverage = int(ParameterValue)
        print("stcontinuum: Setting parameter NAverage to <"//NAverage//">")
        print("stcontinuum: Setting parameter NAverage to <"//NAverage//">", >> LogFile)
        FoundNAverage = YES
      }
      else if (Mode == "single" && Parameter == "continuum_function_single"){
        Function = ParameterValue
        print("stcontinuum: Setting parameter Function to <"//Function//">")
        print("stcontinuum: Setting parameter Function to <"//Function//">", >> LogFile)
        FoundFunction = YES
      }
      else if (Mode == "orders" && Parameter == "continuum_function_orders"){
        Function = ParameterValue
        print("stcontinuum: Setting parameter Function to <"//Function//">")
        print("stcontinuum: Setting parameter Function to <"//Function//">", >> LogFile)
        FoundFunction = YES
      }
      else if (Mode == "single" && Parameter == "continuum_order_single"){
        Order = int(ParameterValue)
        print("stcontinuum: Setting parameter Order to <"//Order//">")
        print("stcontinuum: Setting parameter Order to <"//Order//">", >> LogFile)
        FoundOrder = YES
      }
      else if (Mode == "orders" && Parameter == "continuum_order_orders"){
        Order = int(ParameterValue)
        print("stcontinuum: Setting parameter Order to <"//Order//">")
        print("stcontinuum: Setting parameter Order to <"//Order//">", >> LogFile)
        FoundOrder = YES
      }
      else if (Mode == "single" && Parameter == "continuum_low_reject_single"){
        LowReject = real(ParameterValue)
        print("stcontinuum: Setting parameter LowReject to <"//LowReject//">")
        print("stcontinuum: Setting parameter LowReject to <"//LowReject//">", >> LogFile)
        FoundLowReject = YES
      }
      else if (Mode == "orders" && Parameter == "continuum_low_reject_orders"){
        LowReject = real(ParameterValue)
        print("stcontinuum: Setting parameter LowReject to <"//LowReject//">")
        print("stcontinuum: Setting parameter LowReject to <"//LowReject//">", >> LogFile)
        FoundLowReject = YES
      }
      else if (Mode == "single" && Parameter == "continuum_high_reject_single"){
        HighReject = real(ParameterValue)
        print("stcontinuum: Setting parameter HighReject to <"//HighReject//">")
        print("stcontinuum: Setting parameter HighReject to <"//HighReject//">", >> LogFile)
        FoundHighReject = YES
      }
      else if (Mode == "orders" && Parameter == "continuum_high_reject_orders"){
        HighReject = real(ParameterValue)
        print("stcontinuum: Setting parameter HighReject to <"//HighReject//">")
        print("stcontinuum: Setting parameter HighReject to <"//HighReject//">", >> LogFile)
        FoundHighReject = YES
      }
      else if (Mode == "single" && Parameter == "continuum_niterate_single"){
        NIterate = int(ParameterValue)
        print("stcontinuum: Setting parameter NIterate to <"//NIterate//">")
        print("stcontinuum: Setting parameter NIterate to <"//NIterate//">", >> LogFile)
        FoundNIterate = YES
      }
      else if (Mode == "orders" && Parameter == "continuum_niterate_orders"){
        NIterate = int(ParameterValue)
        print("stcontinuum: Setting parameter NIterate to <"//NIterate//">")
        print("stcontinuum: Setting parameter NIterate to <"//NIterate//">", >> LogFile)
        FoundNIterate = YES
      }
      else if (Mode == "single" && Parameter == "continuum_grow_single"){
        Grow = real(ParameterValue)
        print("stcontinuum: Setting parameter Grow to <"//Grow//">")
        print("stcontinuum: Setting parameter Grow to <"//Grow//">", >> LogFile)
        FoundGrow = YES
      }
      else if (Mode == "orders" && Parameter == "continuum_grow_orders"){
        Grow = real(ParameterValue)
        print("stcontinuum: Setting parameter Grow to <"//Grow//">")
        print("stcontinuum: Setting parameter Grow to <"//Grow//">", >> LogFile)
        FoundGrow = YES
      }
      else if (Parameter == "continuum_markrej"){
        if (ParameterValue == "YES" || ParameterValue == "Yes" || ParameterValue == "yes" || ParameterValue == "+")
          MarkRej = YES
        else
          MarkRej = NO
        print("stcontinuum: Setting parameter MarkRej to <"//MarkRej//">")
        print("stcontinuum: Setting parameter MarkRej to <"//MarkRej//">", >> LogFile)
        FoundMarkRej = YES
      }
      else if (Parameter == "continuum_ask"){
        if (ParameterValue == "YES" || ParameterValue == "Yes" || ParameterValue == "yes" || ParameterValue == "+")
          Ask = "YES"
        else if (ParameterValue == "NO" || ParameterValue == "No" || ParameterValue == "no" || ParameterValue == "-")
          Ask = "NO"
        else
          Ask = "SKIP"
        print("stcontinuum: Setting parameter Ask to <"//Ask//">")
        print("stcontinuum: Setting parameter Ask to <"//Ask//">", >> LogFile)
        FoundAsk = YES
      }
    }
    if (!FoundImType){
      print("stcontinuum: WARNING: Parameter imtype not found in ParameterFile <"//ParameterFile//"> => using standard value <"//ImType//">")
      print("stcontinuum: WARNING: Parameter imtype not found in ParameterFile <"//ParameterFile//"> => using standard value <"//ImType//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter imtype not found in ParameterFile <"//ParameterFile//"> => using standard value <"//ImType//">", >> WarningFile)
    }
#    if (!FoundDoErrors){
#      print("stcontinuum: WARNING: Parameter calc_error_propagation not found in ParameterFile <"//ParameterFile//"> => using standard value <"//DoErrors//">")
#      print("stcontinuum: WARNING: Parameter calc_error_propagation not found in ParameterFile <"//ParameterFile//"> => using standard value <"//DoErrors//">", >> LogFile)
#      print("stcontinuum: WARNING: Parameter calc_error_propagation not found in ParameterFile <"//ParameterFile//"> => using standard value <"//DoErrors//">", >> WarningFile)
#    }
    if (!FoundLines){
      print("stcontinuum: WARNING: Parameter continuum_lines not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Lines//">")
      print("stcontinuum: WARNING: Parameter continuum_lines not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Lines//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_lines not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Lines//">", >> WarningFile)
    }
    if (!FoundBands){
      print("stcontinuum: WARNING: Parameter continuum_bands not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Bands//">")
      print("stcontinuum: WARNING: Parameter continuum_bands not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Bands//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_bands not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Bands//">", >> WarningFile)
    }
#    if (!FoundType){
#      print("stcontinuum: WARNING: Parameter continuum_type not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Type//">")
#      print("stcontinuum: WARNING: Parameter continuum_type not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Type//">", >> LogFile)
#      print("stcontinuum: WARNING: Parameter continuum_type not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Type//">", >> WarningFile)
#    }
    if (!FoundReplace){
      print("stcontinuum: WARNING: Parameter continuum_replace not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Replace//">")
      print("stcontinuum: WARNING: Parameter continuum_replace not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Replace//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_replace not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Replace//">", >> WarningFile)
    }
    if (!FoundWaveScale){
      print("stcontinuum: WARNING: Parameter continuum_wavescale not found in ParameterFile <"//ParameterFile//"> => using standard value <"//WaveScale//">")
      print("stcontinuum: WARNING: Parameter continuum_wavescale not found in ParameterFile <"//ParameterFile//"> => using standard value <"//WaveScale//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_wavescale not found in ParameterFile <"//ParameterFile//"> => using standard value <"//WaveScale//">", >> WarningFile)
    }
    if (!FoundLogScale){
      print("stcontinuum: WARNING: Parameter continuum_logscale not found in ParameterFile <"//ParameterFile//"> => using standard value <"//LogScale//">")
      print("stcontinuum: WARNING: Parameter continuum_logscale not found in ParameterFile <"//ParameterFile//"> => using standard value <"//LogScale//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_logscale not found in ParameterFile <"//ParameterFile//"> => using standard value <"//LogScale//">", >> WarningFile)
    }
    if (!FoundOverride){
      print("stcontinuum: WARNING: Parameter continuum_override not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Override//">")
      print("stcontinuum: WARNING: Parameter continuum_override not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Override//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_override not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Override//">", >> WarningFile)
    }
    if (!FoundListOnly){
      print("stcontinuum: WARNING: Parameter continuum_listonly not found in ParameterFile <"//ParameterFile//"> => using standard value <"//ListOnly//">")
      print("stcontinuum: WARNING: Parameter continuum_listonly not found in ParameterFile <"//ParameterFile//"> => using standard value <"//ListOnly//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_listonly not found in ParameterFile <"//ParameterFile//"> => using standard value <"//ListOnly//">", >> WarningFile)
    }
    if (!FoundInteractive){
      print("stcontinuum: WARNING: Parameter continuum_interactive not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Interactive//">")
      print("stcontinuum: WARNING: Parameter continuum_interactive not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Interactive//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_interactive not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Interactive//">", >> WarningFile)
    }
    if (!FoundSample){
      print("stcontinuum: WARNING: Parameter continuum_sample not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Sample//">")
      print("stcontinuum: WARNING: Parameter continuum_sample not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Sample//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_sample not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Sample//">", >> WarningFile)
    }
    if (!FoundNAverage){
      print("stcontinuum: WARNING: Parameter continuum_naverage not found in ParameterFile <"//ParameterFile//"> => using standard value <"//NAverage//">")
      print("stcontinuum: WARNING: Parameter continuum_naverage not found in ParameterFile <"//ParameterFile//"> => using standard value <"//NAverage//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_naverage not found in ParameterFile <"//ParameterFile//"> => using standard value <"//NAverage//">", >> WarningFile)
    }
    if (!FoundFunction){
      print("stcontinuum: WARNING: Parameter continuum_function not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Function//">")
      print("stcontinuum: WARNING: Parameter continuum_function not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Function//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_function not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Function//">", >> WarningFile)
    }
    if (Mode == "single" && !FoundOrder){
      print("stcontinuum: WARNING: Parameter continuum_order_single not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Order//">")
      print("stcontinuum: WARNING: Parameter continuum_order_single not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Order//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_order_single not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Order//">", >> WarningFile)
    }
    if (Mode == "orders" && !FoundOrder){
      print("stcontinuum: WARNING: Parameter continuum_order_orders not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Order//">")
      print("stcontinuum: WARNING: Parameter continuum_order_orders not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Order//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_order_orders not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Order//">", >> WarningFile)
    }
    if (!FoundLowReject){
      print("stcontinuum: WARNING: Parameter continuum_low_reject not found in ParameterFile <"//ParameterFile//"> => using standard value <"//LowReject//">")
      print("stcontinuum: WARNING: Parameter continuum_low_reject not found in ParameterFile <"//ParameterFile//"> => using standard value <"//LowReject//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_low_reject not found in ParameterFile <"//ParameterFile//"> => using standard value <"//LowReject//">", >> WarningFile)
    }
    if (!FoundHighReject){
      print("stcontinuum: WARNING: Parameter continuum_high_reject not found in ParameterFile <"//ParameterFile//"> => using standard value <"//HighReject//">")
      print("stcontinuum: WARNING: Parameter continuum_high_reject not found in ParameterFile <"//ParameterFile//"> => using standard value <"//HighReject//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_high_reject not found in ParameterFile <"//ParameterFile//"> => using standard value <"//HighReject//">", >> WarningFile)
    }
    if (!FoundNIterate){
      print("stcontinuum: WARNING: Parameter continuum_niterate not found in ParameterFile <"//ParameterFile//"> => using standard value <"//NIterate//">")
      print("stcontinuum: WARNING: Parameter continuum_niterate not found in ParameterFile <"//ParameterFile//"> => using standard value <"//NIterate//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_niterate not found in ParameterFile <"//ParameterFile//"> => using standard value <"//NIterate//">", >> WarningFile)
    }
    if (!FoundGrow){
      print("stcontinuum: WARNING: Parameter continuum_grow not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Grow//">")
      print("stcontinuum: WARNING: Parameter continuum_grow not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Grow//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_grow not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Grow//">", >> WarningFile)
    }
    if (!FoundMarkRej){
      print("stcontinuum: WARNING: Parameter continuum_markrej not found in ParameterFile <"//ParameterFile//"> => using standard value <"//MarkRej//">")
      print("stcontinuum: WARNING: Parameter continuum_markrej not found in ParameterFile <"//ParameterFile//"> => using standard value <"//MarkRej//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_markrej not found in ParameterFile <"//ParameterFile//"> => using standard value <"//MarkRej//">", >> WarningFile)
    }
    if (!FoundAsk){
      print("stcontinuum: WARNING: Parameter continuum_ask not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Ask//">")
      print("stcontinuum: WARNING: Parameter continuum_ask not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Ask//">", >> LogFile)
      print("stcontinuum: WARNING: Parameter continuum_ask not found in ParameterFile <"//ParameterFile//"> => using standard value <"//Ask//">", >> WarningFile)
    }
  }
  else{
    print("stcontinuum: WARNING: Cannot access ParameterFile <"//ParameterFile//"> => using standard parameters!")
    print("stcontinuum: WARNING: Cannot access ParameterFile <"//ParameterFile//"> => using standard parameters!", >> LogFile)
    print("stcontinuum: WARNING: Cannot access ParameterFile <"//ParameterFile//"> => using standard parameters!", >> WarningFile)
  }

# --- read images
  if (substr(Images,1,1) == "@"){
    ListName = substr(Images, 2, strlen(Images))
  }
  else
    ListName = Images
  if ( !access(ListName) ){
    print("stcontinuum: ERROR: Images <"//ListName//"> not found!!!")
    print("stcontinuum: ERROR: Images <"//ListName//"> not found!!!", >> LogFile)
    print("stcontinuum: ERROR: Images <"//ListName//"> not found!!!", >> WarningFile)
    print("stcontinuum: ERROR: Images <"//ListName//"> not found!!!", >> ErrorFile)
# --- clean up
    ParameterList = ""
    return
  }
  InFile = mktemp ("tmp")
  sections(Images, option="root", > InFile)
  InList = InFile

  if (substr(ErrorImages,1,1) == "@"){
    ListName = substr(ErrorImages, 2, strlen(ErrorImages))
  }
  else
    ListName = ErrorImages
  if ( !access(ListName) ){
    print("stcontinuum: ERROR: ErrorImages <"//ListName//"> not found!!!")
    print("stcontinuum: ERROR: ErrorImages <"//ListName//"> not found!!!", >> LogFile)
    print("stcontinuum: ERROR: ErrorImages <"//ListName//"> not found!!!", >> WarningFile)
    print("stcontinuum: ERROR: ErrorImages <"//ListName//"> not found!!!", >> ErrorFile)
# --- clean up
    ParameterList = ""
    return
  }
  ErrFile = mktemp ("tmp")
  sections(ErrorImages, option="root", > ErrFile)
  ErrList = ErrFile

  while(fscan(InList,In) != EOF){
    if (!access(In)){
      print("stcontinuum: ERROR: Image <"//In//"> not found! => Returning")
      print("stcontinuum: ERROR: Image <"//In//"> not found! => Returning", >> LogFile)
      print("stcontinuum: ERROR: Image <"//In//"> not found! => Returning", >> WarningFile)
      print("stcontinuum: ERROR: Image <"//In//"> not found! => Returning", >> ErrorFile)
# --- clean up
      InList = ""
      ErrList = ""
      ParameterList = ""
      del(InFile, ver-)
      del(ErrFile, ver-)
      return
    }
# --- Set name for Fit file
    if (Mode == "single"){
      if (substr(In,strlen(In)-strlen(ImType),strlen(In)) != "."//ImType)
        In = In//"."//ImType
    }
    strlastpos(In,"_"//ImType)
    Pos = strlastpos.pos
    if (Pos == 0){
      print("stcontinuum: '_"//ImType//"' not found in String In <"//In//"> => Looking for '.'")
      if (LogLevel > 2)
        print("stcontinuum: '_"//ImType//"' not found in String In <"//In//"> => Looking for '.'", >> LogFile)
      strlastpos(In,".")
      Pos = strlastpos.pos
    }
    if (Pos == 0){
      Pos = strlen(In)+1
      print("stcontinuum: '.' not found in String In <"//In//"> => Setting Pos to strlen(In)="//Pos)
      if (LogLevel > 2)
        print("stcontinuum: '.' not found in String In <"//In//"> => Setting Pos to strlen(In)="//Pos, >> LogFile)
    }
    Fit = substr(In,1,Pos-1)//"_fit."
    if (Mode == "single")
      Fit = Fit//ImType
    else
      Fit = Fit//"list"
    print("stcontinuum: processing "//In//", fit file = "//Fit)
    print("stcontinuum: processing "//In//", fit file = "//Fit, >> LogFile)
    if (access(Fit))
      del(Fit, ver-)
    if (access(LogFile_continuum))
      del(LogFile_continuum, ver-)
    if (Mode == "orders"){
      ParameterList = In
      while(fscan(ParameterList, TempFileName) != EOF){
        print("stcontinuum: TempFileName read from In(<"//In//">) is <"//TempFileName//">")
        if (LogLevel > 2)
          print("stcontinuum: TempFileName read from In(<"//In//">) is <"//TempFileName//">")
        strlastpos(TempFileName, ".")
        Pos = strlastpos.pos
        if (Pos == 0)
          Pos = strlen(TempFileName) + 1
        TempString = substr(TempFileName, 1, Pos-1)//"fit"//substr(TempFileName, Pos, strlen(TempFileName))
        if (access(TempString))
          del(TempString, ver-)
        print("stcontinuum: Appending OutFileName <"//TempString//"> to Fit file <"//Fit//">")
        if (LogLevel > 2)
          print("stcontinuum: Appending OutFileName <"//TempString//"> to Fit file <"//Fit//">", >> LogFile)
        print(TempString, >> Fit)
      }
      In = "@"//In
      Fit = "@"//Fit
    }
    continuum(input       = In,
	      output      = Fit,
	      lines       = Lines,
	      bands       = Bands,
	      type        = "fit",
	      replace     = Replace,
	      wavescale   = WaveScale,
	      logscale    = LogScale,
	      override    = Override,
	      listonly    = ListOnly,
	      logfiles    = LogFile_continuum,
	      interactive = Interactive,
	      sample      = Sample,
	      naverage    = NAverage,
	      function    = Function,
	      order       = Order,
	      low_reject  = LowReject,
	      high_reject = HighReject,
	      niterat     = NIterate,
	      grow        = Grow,
	      markrej     = MarkRej,
	      graphics    = "stdgraph",
	      cursor      = "",
	      ask         = Ask)
    if (access(LogFile_continuum))
      cat(LogFile_continuum, >> LogFile)
    jobs()
    wait()
    if (Mode == "orders"){
      In = substr(In,2,strlen(In))
      Fit = substr(Fit,2,strlen(Fit))
    }
    if (!access(Fit)){
      print("stcontinuum: ERROR: Fit file <"//Fit//"> not found! => Returning")
      print("stcontinuum: ERROR: Fit file <"//Fit//"> not found! => Returning", >> LogFile)
      print("stcontinuum: ERROR: Fit file <"//Fit//"> not found! => Returning", >> WarningFile)
      print("stcontinuum: ERROR: Fit file <"//Fit//"> not found! => Returning", >> ErrorFile)
# --- clean up
      InList = ""
      ErrList = ""
      ParameterList = ""
      del(InFile, ver-)
      del(ErrFile, ver-)
      return
    }
    print("stcontinuum: Fit file = "//Fit//" ready")
    print("stcontinuum: Fit file = "//Fit//" ready", >> LogFile)

    if (DoErrors)
      NRun = 2
    else
      NRun = 1
    for (i = 1; i <= NRun; i = i+1){
# --- apply fit to input image
      if ( i == 2 ){
        if (fscan(ErrList,In) == EOF){
          print("stcontinuum: ERROR: fscan(ErrorImages) returned EOF! => Returning")
          print("stcontinuum: ERROR: fscan(ErrorImages) returned EOF! => Returning", >> LogFile)
          print("stcontinuum: ERROR: fscan(ErrorImages) returned EOF! => Returning", >> WarningFile)
          print("stcontinuum: ERROR: fscan(ErrorImages) returned EOF! => Returning", >> ErrorFile)
# --- clean up
          InList = ""
          ErrList = ""
          ParameterList = ""
          del(InFile, ver-)
          del(ErrFile, ver-)
          return
        }
        if (!access(In)){
          print("stcontinuum: ERROR: Error image <"//In//"> not found! => Returning")
          print("stcontinuum: ERROR: Error image <"//In//"> not found! => Returning", >> LogFile)
          print("stcontinuum: ERROR: Error image <"//In//"> not found! => Returning", >> WarningFile)
          print("stcontinuum: ERROR: Error image <"//In//"> not found! => Returning", >> ErrorFile)
# --- clean up
          InList = ""
          ErrList = ""
          ParameterList = ""
          del(InFile, ver-)
          del(ErrFile, ver-)
          return
        }
      }
      if (Mode == "single"){
        Out = substr(In,1,strlen(In)-strlen(ImType)-1)//"n."//ImType
      }
      else{
        strlastpos(In,"_"//ImType)
        Pos = strlastpos.pos
        if (Pos == 0){
          strlastpos(In,".")
          Pos = strlastpos.pos
        }
        if (Pos == 0)
          Pos = strlen(In)+1
        Out = substr(In,1,Pos-1)//"n.list"#//substr(In,Pos,strlen(In))
      }
      print("stcontinuum: processing "//In//", outfile = "//Out)
      print("stcontinuum: processing "//In//", outfile = "//Out, >> LogFile)
      if (access(Out))
        del(Out, ver-)
      if (Mode == "orders"){
        ParameterList = In
        while(fscan(ParameterList, TempFileName) != EOF){
          strlastpos(TempFileName,".")
          Pos = strlastpos.pos
          if (Pos == 0)
            Pos = strlen(TempFileName)+1
          TempString = substr(TempFileName,1,Pos-1)//"n"//substr(TempFileName,Pos,strlen(TempFileName))
          if (access(TempString))
            del(TempString, ver-)
          print("stcontinuum: Appending OutFileName <"//TempString//"> to Out file <"//Out//">")
          if (LogLevel > 2)
            print("stcontinuum: Appending OutFileName <"//TempString//"> to Out file <"//Out//">", >> LogFile)
          print(TempString, >> Out)
        }
        In = "@"//In
        Fit = "@"//Fit
        Out = "@"//Out
      }
      sarith(input1    = In,
             op        = "/",
	     input2    = Fit,
	     output    = Out,
	     w1        = INDEF,
	     w2        = INDEF,
	     apertures = "",
	     bands     = "",
	     beams     = "",
	     apmodulus = 0,
	     reverse-,
	     ignoreaps-,
	     format    = "multispec",
	     renumber-,
	     offset    = 0,
	     merge-,
	     rebin-,
	     errval    = 0.001,
	     verbose-)
      if (Mode == "orders"){
        In = substr(In,2,strlen(In))
        Fit = substr(Fit,2,strlen(Fit))
        Out = substr(Out,2,strlen(Out))
      }
      if (!access(Out)){
        print("stcontinuum: ERROR: Output image <"//Out//"> not found! => Returning")
        print("stcontinuum: ERROR: Output image <"//Out//"> not found! => Returning", >> LogFile)
        print("stcontinuum: ERROR: Output image <"//Out//"> not found! => Returning", >> WarningFile)
        print("stcontinuum: ERROR: Output image <"//Out//"> not found! => Returning", >> ErrorFile)
# --- clean up
        InList = ""
        ErrList = ""
        ParameterList = ""
        del(InFile, ver-)
        del(ErrFile, ver-)
        return
      }
# --- write text file
      if (Mode == "single"){
        Suffix = "text"
        strlastpos(Out,".")
        Pos = strlastpos.pos
        if (Pos == 0){
          Suffix = "."//Suffix
          Pos = strlen(Out)
        }
        TextOut = substr(Out,1,Pos)//Suffix
        if (access(TextOut))
          del(TextOut, ver-)
      }
      else{
        strlastpos(Out,"_"//ImType)
        Pos = strlastpos.pos
        if (Pos == 0){
          strlastpos(Out,".")
          Pos = strlastpos.pos
        }
        if (Pos == 0)
          Pos = strlen(Out)+1
        TextOut = substr(Out,1,Pos-1)//"_text.list"
        if (access(TextOut))
          del(TextOut, ver-)
        ParameterList = Out
        while(fscan(ParameterList, TempFileName) != EOF){
          strlastpos(TempFileName, ".")
          Pos = strlastpos.pos
          if (Pos == 0){
            TempFileName = TempFileName//"."
            Pos = strlen(TempFileName)
          }
          TempString = substr(TempFileName, 1, Pos)//"text"
          if (access(TempString))
            del(TempString, ver-)
          print(TempString, >> TextOut)
          print("stcontinuum: Writing TempString(="//TempString//") to TextOut list "//TextOut)
          if (LogLevel > 2)
            print("stcontinuum: Writing TempString(="//TempString//") to TextOut list "//TextOut)
        }
        Out = "@"//Out
        TextOut = "@"//TextOut
      }
#      onedspec
      wspectext(input=Out,
                output=TextOut,
                header-,
                wformat="")
      if (Mode == "orders"){
        Out = substr(Out,2,strlen(Out))
        TextOut = substr(TextOut,2,strlen(TextOut))
      }# --- Text ready
    }
  }#end while(fscan(Images,In) != EOF)

# --- clean up
  del(InFile, ver-)
  InList = ""
  ErrList = ""
  ParameterList = ""
  del(InFile, ver-)
  del(ErrFile, ver-)

end
