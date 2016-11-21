capture program drop weo
program weo

	syntax name, Country(string) Year(string) Vintage(string) Weovar(string) [dta(string)] [path(string)]
	* path = path where raw data saved/stored
	* `namelist' is the name
	* default= specifies how the varlist is to be filled in when the varlist is optional and the user does not specify it.  The default is to fill
    * it in with all the variables.  If default=none is specified, it is left empty.
	

	* Check if path specified
	* capture confirm variable `path'
	* di _rc
	* if _rc == 101{
	
	if "`path'" != "" {
		* TODO: will it break with or without slash?
		local weo_dir = "`path'"
	}
	else{
		* Use the default:
		* TODO: will this work?
		local weo_dir    = "weo_tmp"
	}
	* di "`weo_dir'"
	
	* Info on how to submit to ssc
	* http://repec.org/bocode/s/sscsubmit.html
	
	* gen `namelist' = ""
	local obs = _N
	forvalue i=1/`obs'{

	}
	
	****************************************************************************
	* Check that newvar name does not yet exist
	****************************************************************************	
	cap confirm variable `namelist'
	if _rc == 0{
		* already exists
		display as error "You are trying to generate a variable (`namelist') that already exists"
		exit
	}
	
	****************************************************************************
	* Has WEO vintage already been downloaded and saved in tmp folder?
	****************************************************************************	
	local merge_text = "`weo_dir'" + "\long_" + "`vintage'" + ".dta"
	* di "`merge_text'"
	
	capture confirm file "`merge_text'"
	* di _rc
	
	if _rc != 0 {
		* File does not exist. Must download and prepare WEO data
		preserve
		di "Downloading WEO from IMF website"
		getweo, vintage_str("`vintage'") path("`weo_dir'")
		restore
	}
	
	****************************************************************************
	* Merge in WEO data
	****************************************************************************		
	
	preserve
	* pull in the dta, get what we need, then save as tempfile
	
	* if country is not a variable but a string
	* gen temp_country = that string
	
	* TODO: this may cause an issue if they already have a variable named year.
	local cv         = 1
	local sc         = 0
	local inputs     = "country year weovar"
	local outputs    = "iso year weosubjectcode"
	local merge_list = ""
	
	foreach v of local inputs{
		* di "test"
		local output `: word `cv' of `outputs''
		* di "`output'"
		* Check if the input is a string or variable
		capture confirm variable ``v''
		* di _rc
		if _rc == 0{
			* `v' is a variable
			rename ``v'' `output'
			* di "`v'"
			* di "_rc == 0"
			local merge_list = "`merge_list'" + " ``v''"
			* di "`merge_list'"
		}
		else {
			* `v' is a string
			gen `output' = "``v''"
			* di "`v'"
			* di "else"
		}
		local cv = `cv' + 1
	}
	
	
	/*
	*check format of inputs
	capture confirm str# v `weovar'
	if _rc == 0{
		* `weovar' is a predefined variable name
		rename `weovar' weosubjectcode
		di "_rc == 0"
	}
	else {
		* `weovar' is a user inputted string that contains a variable name in the WEO
		gen weosubjectcode = "`weovar'"
		di "else"
	}
	
	*/
	keep `outputs'

	* TODO add vintage
	di "Loading WEO Long `vintage'"
	merge 1:1 weosubjectcode iso year using "`merge_text'", keep(match)
	gen _t = "realized"
	replace _t = "forecast" if year > estimatesstartafter
	encode _t, generate (`namelist'_type)
	drop _t
	
	* save "U:\GMS\Patrick\IMF_GrowthForecastErrors\Data\delete_me.dta", replace
	
	* TODO: add in the option to get these too:
	/*
	subjectdescri~r str86   %86s                  Subject Descriptor
subjectnotes    str1190 %1190s                Subject Notes
units           str50   %50s                  Units
scale           str8    %9s                   Scale
countryseries~s strL    %9s                   Country/Series-specific Notes
value           double  %10.0g                
estimatesstar~r int     %8.0g                 Estimates Start After
	*/
	
	
	keep weosubjectcode iso year value `namelist'_type
	rename value `namelist'
	rename weosubjectcode `weovar'
	rename iso `country'
	rename year `year'
	keep `merge_list' `namelist' `namelist'_type
	
	tempfile results
	qui save `results'
	qui count
	local count_obs = r(N)	
	
	
	if `count_obs' > 0{
		restore
		
		*merge in the tempfile
		merge 1:1 `merge_list' using `results', nogen
	}
	else{
		restore
		di "No data found. Check that you used the correct weovar, country, etc."
	}

end
