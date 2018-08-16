procedure getgtcmoslambdarange(grismid)

string grismid = "R1000R"              {prompt="GTCMOS Grism ID",
                                               enum="R300B|R300R|R500B|R500R|R1000B|R1000R|R2000B|R2500U|R2500V|R2500R|R2500I"}
int    lambdamin = 3600                {prompt="output parameter"}
int    lambdamax = 10000               {prompt="output parameter"}

begin
    if (grismid == "R300B"){
        lambdamin = 3600
        lambdamax = 7200
    } else if (grismid == "R300R"){
        lambdamin = 4800
        lambdamax = 10000
    } else if (grismid == "R500B"){
        lambdamin = 3600
        lambdamax = 7200
    } else if (grismid == "R500R"){
        lambdamin = 4800
        lambdamax = 10000
    } else if (grismid == "R1000B"){
        lambdamin = 3630
        lambdamax = 7500
    } else if (grismid == "R1000R"){
        lambdamin = 5100
        lambdamax = 10000
    } else if (grismid == "R2000B"){
        lambdamin = 3950
        lambdamax = 5700
    } else if (grismid == "R2500U"){
        lambdamin = 3440
        lambdamax = 4610
    } else if (grismid == "R2500V"){
        lambdamin = 4500
        lambdamax = 6000
    } else if (grismid == "R2500R"){
        lambdamin = 5575
        lambdamax = 7685
    } else if (grismid == "R2500I"){
        lambdamin = 7330
        lambdamax = 10000
    } else{
        print("gettcmoslambdarange: ERROR: grismid <"//grismid//"> not valid")
    }

end
