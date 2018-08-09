procedure readorders(OrderList, FileName)

string OrderList = "orders.list"   {prompt="List of orders to read"}
string FileName  = "filename.fits" {prompt="Name of existing file"}
string *TempList

begin
  int OrderNum
  string TempImage

  TempList = OrderList
  OrderNum = 0
  while(fscan(TempList,TempImage) != EOF){
    OrderNum = OrderNum + 1
    imcopy(input=TempImage,
           output=FileName//"[*,"//OrderNum//"]",
           ver-)
  }
end
