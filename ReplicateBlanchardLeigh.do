********************************************************************************
* Housekeeping
********************************************************************************

* cd ""
local weo_dir "\temp"
set more off
program drop _all
clear

********************************************************************************
* Specify which countries we want to include (TODO: simplify this process)
********************************************************************************

gen iso = ""
set obs 30
replace iso = "GBR" in 1
replace iso = "AUT" in 2
replace iso = "BEL" in 3
replace iso = "DNK" in 4
replace iso = "FRA" in 5
replace iso = "DEU" in 6
replace iso = "ITA" in 7
replace iso = "LUX" in 8
replace iso = "NLD" in 9
replace iso = "NOR" in 10
replace iso = "SWE" in 11
replace iso = "CHE" in 12
replace iso = "FIN" in 13
replace iso = "GRC" in 14
replace iso = "ISL" in 15
replace iso = "IRL" in 16
replace iso = "MLT" in 17
replace iso = "PRT" in 18
replace iso = "ESP" in 19
replace iso = "CYP" in 20
replace iso = "BGR" in 21
replace iso = "CZE" in 22
replace iso = "SVK" in 23
replace iso = "EST" in 24
replace iso = "LVA" in 25
replace iso = "HUN" in 26
replace iso = "LTU" in 27
replace iso = "SVN" in 28
replace iso = "POL" in 29
replace iso = "ROM" in 30

********************************************************************************
* Obtain WEO data from Fall 2012 and Spring 2010 vintages
********************************************************************************

weo ngdp_rpch_postcrisis_2011, country(iso) year(2011) vintage("Fall2012") weovar("NGDP_RPCH") path(`weo_dir')
weo ngdp_rpch_postcrisis_2010, country(iso) year(2010) vintage("Fall2012") weovar("NGDP_RPCH") path(`weo_dir')

weo ngdp_rpch_precrisis_2011, country(iso) year(2011) vintage("Spring2010") weovar("NGDP_RPCH") path(`weo_dir')
weo ngdp_rpch_precrisis_2010, country(iso) year(2010) vintage("Spring2010") weovar("NGDP_RPCH") path(`weo_dir')

weo ggsb_gdp_precrisis_2011, country(iso) year(2011) vintage("Spring2010") weovar("GGSB_NPGDP") path(`weo_dir')
weo ggsb_gdp_precrisis_2009, country(iso) year(2009) vintage("Spring2010") weovar("GGSB_NPGDP") path(`weo_dir')

drop *_type

********************************************************************************
* Compute Fiscal Consolidation (x) and Growth Forecast Error (y)
********************************************************************************

gen y = 100*((1+ngdp_rpch_postcrisis_2011/100)*(1+ngdp_rpch_postcrisis_2010/100)-1)  -  100*((1+ngdp_rpch_precrisis_2011/100)*(1+ngdp_rpch_precrisis_2010/100)-1)
gen x = ggsb_gdp_precrisis_2011-ggsb_gdp_precrisis_2009
keep if x != .

* Regression
reg y x, r
local coef = _b[x]
local tstat = _b[x]/_se[x]
local coef = round(`coef',.01)
local tstat = round(`tstat',.01)

********************************************************************************
* Scatter Plot (Blanchard and Leigh Figure 1)
********************************************************************************

local ytitle = "growth forecast error"
local xtitle = "forecast of fiscal consolidation"
local graphindex = 1
local title="Blanchard and Leigh (Figure 1)"
drop if x==.|y==.
twoway ///
(lfit y x, ///
lwidth(thin) legend(off) title("`title'") subtitle("`subtitle'") ytitle("`ytitle'") xtitle("`xtitle'")) ///
(scatter y x, mlabel(iso) mcolor(navy) msymbol(O) mlabsize(med) mlabcolor(navy))
clist iso y x, noobs
