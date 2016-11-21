********************************************************************************
* Plot Forecasts of Greek GDP (hedgehog plot)
********************************************************************************

cd "D:\Research\FRB\WEO_plugin\Do"
set more off
clear
set obs 20
gen year1 = _n + 2000

********************************************************************************
* Obtain Data
********************************************************************************
local weo_var_name "NGDP_R"
forvalues yy = 2009(1)2015{
	di `yy'
	weo output_`yy', country("GRC") year(year1) vintage("Fall`yy'") weovar(`weo_var_name') path("D:\Research\FRB\WEO_plugin\WEO_temp")
}
	
********************************************************************************
* Compute Normalized Forecasts
********************************************************************************	
tsset year1
gen norm_output_2015 = (output_2015 / output_2015[8]) * 100 if output_2015_type != 1

* Forecasts
forvalues yy = 2009(1)2015{
	gen forecast_`yy' = (output_`yy' / output_`yy'[`yy' -1 -2000] ) * norm_output_2015[`yy' -1 - 2000] if year1 >= `yy'-1
	lab var forecast_`yy' "Forecast `yy'"
}

********************************************************************************
* Hedgehog Plot
********************************************************************************
lab var norm_output_2015 "Realized Output"
twoway (tsline forecast*) (tsline norm_output_2015, lwidth(thick) color(black))  if year >=2005 & year <=2020, title("IMF Forecasts of Greek Real GDP") note("Realized Output from the IMF WEO Fall 2015, normalized to 100 in 2008.")
graph export "Greek_Real_GDP_Forecasts.pdf", as(pdf) replace
