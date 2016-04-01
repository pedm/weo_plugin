capture program drop getweo
program getweo
	* input: weo vintage, [path_raw_data]
	* output: the path of the long dta
	syntax, vintage_str(string) [path(string)]
	
	* look to see if long dta already exists?
	* confirm file
	
	* if long dta exists, just spit that out
	* else:
	
		* confirm raw xls exists
		* if yes, convert it to long deta
		
		* else:
			* insheet from online
			* if we cant insheet it, give an error and tell them where to download it
			* https://www.imf.org/external/pubs/ft/weo/2015/02/weodata/WEOOct2015all.xls
			* else:
			
				* convert to long dta
				* save it
				
				
				
				* This file downloads and cleans the requested WEO vintage

	* TODO: will fail for other seasons / years
	* local vintage_str "Fall2012"
	* local tmp_folder "weo_tmp"
	
	local tmp_folder "`path'"
	
	clear
	
	********************************************************************************
	* Determine which WEO vintage was requested
	********************************************************************************
	
	local vintage_year = substr("`vintage_str'", -4, .)
	di "`vintage_year'"
	
	local vintage_season_str = substr("`vintage_str'", 1, 1)
	if "`vintage_season_str'" == "S"{
		local vintage_season = 1
		
		* TODO: does this fail?
		local vintage_season_name = "APR"
	}
	else{
		local vintage_season = 2
		
		* TODO: this fails at least once :/
		* might be good to first try Oct, then try Sept, etc
		local vintage_season_name = "Oct"
	}
	di "`vintage_season'"
	
	********************************************************************************
	* Create URL to download WEO vintage from IMF website
	********************************************************************************
	
	* TODO: what year is Sep not Oct
	* TODO: do I need backup url for spring?
	
	local download_url "https://www.imf.org/external/pubs/ft/weo/`vintage_year'/0`vintage_season'/weodata/WEO`vintage_season_name'`vintage_year'all.xls"
	local download_url2 "https://www.imf.org/external/pubs/ft/weo/`vintage_year'/0`vintage_season'/weodata/WEOSep`vintage_year'all.xls"
	/*
	local urllist = "`download_url'" + " `download_url2'"
	
	local exitdum = 1
	foreach urll of local urllist{
		tempfile weo_t
		capture copy `urll' `weo_t'
		if _rc == 7 {
			local exitdum = 0
			break
	}
	}
	
	if `exitdum' == 1 {
		exit, clear
	}
	*/
	
	di "`download_url'"
	
	* WEO xls files are actually csv files, so import as a csv
	* import delimited U:\GMS\Patrick\IMF_GrowthForecastErrors\Data\Raw\WEOApr2012all.xls
	* https://www.imf.org/external/pubs/ft/weo/2013/02/weodata/WEOOct2013all.xls
	
	* import delimited "Data/Raw/$f"
	* capture noisily import delimited "`download_url'"
	
	di "Import: `download_url'"
	capture noisily import delimited "`download_url'"
	di _rc
	
	if _rc != 0 {
		di "Import: `download_url2'"
		capture noisily import delimited "`download_url2'"
		di _rc
		
		if _rc != 0 {
			* TODO: best way to error?
			di "Unable to download WEO data from IMF website. Try downloading yourself using:"
			di "`download_url'"
			di "`download_url2'"
			
			exit
		}
	}
	
	
	********************************************************************************
	* Clean WEO data
	********************************************************************************
	
	* Drop IMF notice at the bottom
	drop if iso == ""
	
	foreach v of varlist v* {
	local x : variable label `v'
	rename `v' value`x'
	}
	
	reshape long value, i( weosubjectcode weocountrycode ) j(year)
	* format %12s weocountrycode
	destring weocountrycode, replace
	replace value = "" if value == "n/a" | value == "--"
	destring value, replace ignore(",")
	
	gen weo = "`vintage_str'"
	compress
	cap mkdir "`tmp_folder'"
	save "`tmp_folder'/long_`vintage_str'.dta", replace
	
	* TODO: add a message saying where the tmp data was stored. And perhaps state the file size
	
	/*
	
	
	drop subjectdescriptor subjectnotes units scale estimatesstartafter countryseriesspecificnotes
	
	gen j_val = weosubject + "_" + weo
	drop weosubject weo
	reshape wide value, i(iso weocountry year) j(j_val) string
	
	order country iso year weocountry 
	
	save "`tmp_folder'/wide_`vintage_str'.dta", replace
	di "Done"
	*/
	
end
