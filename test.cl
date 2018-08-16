procedure test (input)

string input="@stnozero.list" {prompt="files to set all negative values to zero"}
string *inimages

begin
    inimages=input
    while(fscan(inimages,line) != EOF){
        print("line = <"//line//">")
        print(substr(line,1,stridx(".",line)))
    }
end

