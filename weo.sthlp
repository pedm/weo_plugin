{smcl}
{* *! version 1.0 - 20 November 2016}{...}
{cmd:help weo}
{hline}

{title:Title}

{phang}
{bf:weo} {hline 2} Use IMF World Economic Outlook data

{title:Syntax}

{p 8 17 2}
{cmd:weo} 
{newvar}, 
country() year() weovar() vintage() [path()]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt country()}}Country code in ISO format. Input can be a string or variable{p_end}

{synopt:{opt year()}}Year. Input must be a variable{p_end}

{synopt:{opt weovar()}}WEO subject code. Input can be a string or variable{p_end}

{synopt:{opt vintage()}}Vintage. Input must be a string. For instance, "Spring2009" or "Fall2013"{p_end}

{synopt:{opt path()}}Optional storage path to save the raw data. {p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}


{title:Description}

{pstd}
{cmd:weo} makes it easy to analyze data from the IMF WEO. It downloads the raw excel files from the IMF, reshapes the data, and extracts the variable(s) that you choose. This can be used to create new datasets or add variables to your existing data. In addition, {cmd:weo} simplifies the tedious process of comparing WEO forecasts from different vintages. It is now very easy to analyze forecast errors and to see how forecasts have evolved with time. 

{title:Options}

{phang}
{opt country()} specifies the country or countries for which to obtain data. Use a string to get data from one country or a variable to obtain data from multiple countries. Countries are specified in ISO format.  

{phang}
{opt year()} specifies the year or years for which to obtain data. Input must be a variable.

{phang}
{opt weovar()} specifies the WEO subject code of the variable you want to retrieve. For a full list of WEO subject codes, look here ______. Input can be a string or variable.

{phang}
{opt vintage()} specifies the WEO version from which to extract data. The WEO is published twice a year and contains revisions to realized data as well as forecasts. Input must be a string. For instance, "Spring2009" or "Fall2013".

{phang}
{opt path()} specifies an optional storage path for the raw data. Each vintage of the WEO is approximately 500MB, therefore the initial download can be quite slow. Using this option allows you to save the WEO vintage, making it much faster to access in future usage.


{title:Examples}

{dlgtab:Greek GDP Forecasts}

{pstd}Setup{p_end}
{phang2}{cmd:. clear }{p_end}
{phang2}{cmd:. set obs 14 }{p_end}
{phang2}{cmd:. gen y = 2000 + _n }{p_end}

{pstd}Obtain GDP growth rate from two different vintages{p_end}
{phang2}{cmd:. weo real_gdp_growth_weo2009, country("GRC") year(y) weovar("NGDP_RPCH") vintage("Fall2009") }{p_end}
{phang2}{cmd:. weo real_gdp_growth_weo2015, country("GRC") year(y) weovar("NGDP_RPCH") vintage("Fall2015")}{p_end}

{pstd}Plot{p_end}
{phang2}{cmd:. lab var real_gdp_growth_weo2009 "GDP Growth (Forecast 2009-2014)" }{p_end}
{phang2}{cmd:. lab var real_gdp_growth_weo2015 "GDP Growth (Realized)" }{p_end}
{phang2}{cmd:. drop *_type }{p_end}
{phang2}{cmd:. tsset y }{p_end}
{phang2}{cmd:. tsline real_gdp_g*, title("Greek GDP: Forecast vs Realized") }{p_end}

{dlgtab:Another example (todo)}


{title:Remarks}

{pstd}
This version is in beta mode. No warranties whatsoever.
