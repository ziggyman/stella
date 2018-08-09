procedure round(Value)

real Value = 1.5 {prompt="Value to round"}
int  Rounded = 2

begin

int  TempInt

Rounded = (int(Value))
TempInt = (int((Value - Rounded) * 10.))
if (TempInt > 4)
  Rounded = Rounded+1

end
