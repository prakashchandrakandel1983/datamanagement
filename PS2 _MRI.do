*______________________________________________________________________
* Data Management in Stata
*Prakash Chandra Kandel
* Date: Feb 114, 2022

* notes : 
clear         
set matsize 800 
version 17
set more off
*--------------------------------------------------------------------
*--------------------------------------------------------------------

local worDir  "/Users/prakashchandrakandel/Desktop/DATA MANAGEMENT"
cap mkdir `worDir'



*The Municipal Revitalization Index (MRI) serves as the State's official measure and ranking of municipal distress. The MRI ranks New Jersey's municipalities according to eight separate indicators that measure diverse aspects of social, economic, physical, and fiscal conditions in each locality. The MRI is used as a factor in distributing certain "need based" funds. (source: Department of New Jersey, Department of Community Affairs)

*The dataset below is related to Municipality Revitalization Index(MRI) of New Jersey Municipalities where MRI scores are related to level of distress for the concerned municiapalities. MRI score of 1 means least distressed and of 565 means the most distressed. The dataset will be used to find out the relationship between the legalization of Cannabis and the MRI score.


//https://www.nj.gov/dca/home/2020_MRI_Scores_and_Rankings.xlsx

import excel "https://docs.google.com/uc?id=1MFklK6ss_5WY5QUcti93Zo50lKWGYmE9&export=download", clear 

set seed 123456789 //setting randomness to a constant
d
sum

/**************/
/* Variables  */
/**************/

drop in 1/6
drop F G H I K L N O Q R T U W X Z AA AC AD AF AG AI AJ AL

rename A muni_id
label var muni_id "Municipality ID"
rename B muni_name
label var muni_name "Municipality Name"
rename C county_name
label var county_name "County Name"
rename D region
label var region "New Jersey Regions"
rename E mri_score
label var mri_score "Municipal Revitalization Index Score"
rename J pop_change_value
label var pop_change_value "Population Change Value of NJ Municipalities (2009-2019)"
rename M nshv_rate_value
label var nshv_rate_value "Non-seasonal Housing Vacancy Rate Value (2019)"
rename P snap_value
label var snap_value "Supplemental Nutrition Assistance Program (2019) Value"
rename S tanf_value
label var tanf_value "Children on Temporary Assistance for Needy Families (TANF, 2020) Value"
rename V pov_value
label var pov_value "Poverty Rate (2019) Value"
rename Y mhi_value
label var mhi_value "Median Household Income (2019) Value"
rename AB unemp_value
label var unemp_value "Unemplyment Rate (2019) Value"
rename AE edu_value
label var edu_value "High School Diploma or Higher (2017-19) Value"
rename AH proptax_value
label var proptax_value "Average Property Tax Rate (2017-19) Value"
rename AK capita_value
label var capita_value "Equalized Valuation Per Capita (2019) Value"



drop if muni_id ==""

destring*, replace

d
sum


tab county_name                  /*check var values*/
tab county_name, nola             /*without labels*/
tab county_name, mi               /*checking for missings*/
encode region, gen(region_numeric)
encode county, gen(county_id)

codebook county_id, tab(100)    /* codebook will show both: values and value labels; use tab(100) to */
                              /* get all values*/
codebook region_numeric
ta region region_numeric, mi                             

save mri.dta, replace 


generate county=.
replace county=1 if county_id==1
replace county=0 if county_id>1 & county_id<22						  
							  						  
recode county_id (1=1) (2/21=0), gen(county_1)

ta region region_numeric, mi

use mri, clear

replace muni_name = subinstr(muni_name, "township", "", .)
replace muni_name = subinstr(muni_name, "borough", "", .)
replace muni_name = subinstr(muni_name, "City", "", .)
replace muni_name = subinstr(muni_name, "village", "", .)
replace muni_name = subinstr(muni_name, "town", "", .)
replace muni_name = "Orange" if muni_name == " of Orange "

save mri, replace
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*

*This dataset will be used to assess the linkgae between the adoption of New Jersey Marijuana Law with the percentage of the unemployed as well people 65 and over.

*https://search.njdatabook.rutgers.edu/municipal/data

import delimited using "https://docs.google.com/uc?id=1-6KOjLAUUDjAZWkiflr-CdtkDVeXn6ke&export=download",varnames(2) clear

d
summarize

drop dlgscode-cd

rename county county_name 
label var county_name "County Name"
rename municipality muni_name
label var muni_name "Municipality Name"
rename estimatedpopulation esti_pop
label var esti_pop "Estimated Population 2019"
rename age65 age
label var age "Age 65+ in 2019"
rename unemployed unemp 
label var unemp "Percentage Unemployed 2019"
rename municipalbudgetpercapita bud_percap
label var bud_percap "Municipal Budget Per Capita 2019"

drop in 294/295 
/*The names have been dropped because the names are mentioned as "Princeton (prior to 2013)" and "Princeton Twp (prior to 2013)" and they represent "NULL" values.*/

replace muni_name = "Princeton" if muni_name == "Princeton (as of 1/1/2013)"

order muni_name
tab age
tab esti_pop 
tab unemp
tab bud_percap

replace esti_pop = "." if esti_pop == "NULL"
replace unemp = "." if unemp == "NULL"
replace bud_percap = "." if bud_percap == "NULL"

destring*, replace

d
summarize

replace muni_name = subinstr(muni_name, "Twp", "", .)
replace muni_name = subinstr(muni_name, "City", "", .)
replace muni_name = "Avon-By-The-Sea" if muni_name == "Avon By The Sea"

sort muni_name
edit

save popage, replace

merge 1:1 muni_name using mri
*--------------------------------------------------------------------
*--------------------------------------------------------------------
*The another data set is about the results of 2020 Presidential Election in New Jersey, which will be used to find out the the relationship between status of cannabis legalization, parameters of MRI, and  the results of presidential election. In other words, this dataset will be used to identify the relationship between adopting Marijuana Law and voting pattern, while at the same time taking other variables into account.

//https://datawrapper.dwcdn.net/o9YRC/9/
* notes : 
clear         
set matsize 800 
version 17
set more off


local worDir  "/Users/prakashchandrakandel/Desktop/DATA MANAGEMENT"
cap mkdir `worDir'

//https://datawrapper.dwcdn.net/o9YRC/9/
import delimited using "https://docs.google.com/uc?id=1sYVRk8YiSajJ-5sexhcXjLJkyCq59aow&export=download", clear


drop latitude longitude marginforbiden
rename municipality muni_name
label var muni_name "Municipality Name"
rename county county_name
label var county_name "County Name"
rename biden biden_vote
label var biden_vote "Voted Secured by Biden in 2020 Presidential Election NJ"
rename trump trump_vote
label var trump_vote "Voted Secured by Trump in 2020 Presidential Election NJ"
rename wonbytrump trump_win
label var trump_win "Won by Trump?"
label var margin "Vote Margin for the Presidential Candidate"
rename v10 biden_percent
label var biden_percent "Percentage of Voted Secured by Biden in 2020 Presidential Election NJ"
rename v11 trump_percent
label var trump_percent "Percentage of Voted Secured by Trump in 2020 Presidential Election NJ"

tab trump_vote
replace trump_vote="." if trump_vote == "null"
destring trump_vote, replace 

save pres_elect,replace

d
sum


replace muni_name = subinstr(muni_name, "Township", "", .)
replace muni_name = subinstr(muni_name, "Borough", "", .)
replace muni_name = subinstr(muni_name, "City", "", .)
replace muni_name = subinstr(muni_name, "Village", "", .)
replace muni_name = subinstr(muni_name, "Town", "", .)

replace muni_name = "Fairfield" if muni_name == "Fairfield  – Cumberland"
replace muni_name = "Fairfield" if muni_name == "Fairfield  – Essex"

replace muni_name = "Franklin" if muni_name == "Franklin  – Hunterdon"
replace muni_name = "Franklin" if muni_name == "Franklin  – Gloucester"

replace muni_name = "Franklin" if muni_name == "Franklin  – Warren"
replace muni_name = "Franklin" if muni_name == "Franklin  – Somerset"

replace muni_name = "Greenwich" if muni_name == "Greenwich – Gloucester"
replace muni_name = "Greenwich" if muni_name == "Greenwich  – Cumberland"
replace muni_name = "Greenwich" if muni_name == "Greenwich  – Warren"


replace muni_name = "Hamilton" if muni_name == "Hamilton  – Atlantic"
replace muni_name = "Hamilton" if muni_name == "Hamilton  – Mercer"

replace muni_name = "Hopewell" if muni_name == "Hopewell  – Cumberland"
replace muni_name = "Hopewell" if muni_name == "Hopewell  – Mercer"

replace muni_name = "Lawrence" if muni_name == "Lawrence  – Cumberland"
replace muni_name = "Lawrence" if muni_name == "Lawrence  – Mercer"

replace muni_name = "Mansfield" if muni_name == "Mansfield  – Burlington"
replace muni_name = "Mansfield" if muni_name == "Mansfield  – Warren"

replace muni_name = "Monroe" if muni_name == "Monroe  – Gloucester"
replace muni_name = "Monroe" if muni_name == "Monroe  – Middlesex"

replace muni_name = "Ocean" if muni_name == "Ocean  – Ocean "
replace muni_name = "Ocean" if muni_name == "Ocean  – Monmouth "


replace muni_name = "Union" if muni_name == "Union  – Hunterdon"
replace muni_name = "Union" if muni_name == "Union  – Union"

replace muni_name = "Springfield" if muni_name == "Springfield  – Burlington"
replace muni_name = "Springfield" if muni_name == "Springfield  – Union"


replace muni_name = "Washington" if muni_name == "Washington  – Bergen"
replace muni_name = "Washington" if muni_name == "Washington  – Bergen"
replace muni_name = "Washington" if muni_name == "Washington  – Burlington"
replace muni_name = "Washington" if muni_name == "Washington  – Morris"
replace muni_name = "Washington" if muni_name == "Washington  – Warren"
replace muni_name = "Washington" if muni_name == "Washington  – Gloucester"
replace muni_name = "Avon-By-The-Sea" if muni_name == "Avon-by-the-Sea "
replace muni_name = "Orange" if muni_name == " of Orange "

save pres_elect,replace


merge 1:1 muni_name using popage
l 
save pres_elect,replace
*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------*
*The final set of dataset for this project is related to the municipalities that adopted the New Jersey Marijuana Law in some way or the other in 2021 or declined to adopt it. 
*The data set could not be directly downloaded. Therefore, it has been copied in Excel and converted to csv file for its treatment in STATA.

*https://infogram.com/municipal-marijuana-laws-search-1hzj4o3xrdvxo4p
*The website cites USA TODAY NETWORK for analysis of municipal ordinances, Feb. 2021 - Aug. 2021 

import delimited using "https://docs.google.com/uc?id=1RFGJW_cgNFtcV80vrl-jsFCRd4arzWaf&export=download",varnames(1)clear


edit
d
summarize
 
drop v5

rename municipality muni_name
label var muni_name "Municipality Name"
rename county county_name
label var county_name "County Name"
rename ordinance ord_adopt
label var ord_adopt "Status of Marijuna Law Adoption 2021"
rename votersupport voter_supp
label var voter_supp "Percentage of Voter Support"

destring voter_supp, gen(vot_sup) i(% voter support)
drop voter_supp

replace county_name = subinstr(county_name, "County", "", .)

d
summarize
*Now, the ordinance adoption has to be categorzied into opted_in the law is adopted in one way or the other, into opted_out if not , and into unknown and to 
 
replace ord_adopt = "opted in" if ord_adopt == "Approved non-retail cannabis businesses"
replace ord_adopt = "opted in" if ord_adopt == "Approved retail cannabis businesses"
replace ord_adopt = "opted out" if ord_adopt == "Opted out of cannabis businesses"
replace ord_adopt = "opted in" if ord_adopt == "Medical marijuana businesses approved"
replace ord_adopt = "no action" if ord_adopt == "No action taken"

tab ord_adopt, mi

gen opt_status=.
replace opt_status = 1 if ord_adopt =="opted in"
replace opt_status = 0 if ord_adopt =="opted out" | ord_adopt =="no action" | ord_adopt == "Unknown"

tab opt_status, mi
d 
summarize

replace muni_name = subinstr(muni_name, "Township", "", .)
replace muni_name = subinstr(muni_name, "Borough", "", .)
replace muni_name = subinstr(muni_name, "City", "", .)
replace muni_name = regexr(muni_name, "\((.)+\)", "")
replace muni_name = "Avon-By-The-Sea" if muni_name == "Avon"

sort muni_name
save lawadoption, replace

merge 1:1 using pres_elect

*saving in different formats
export excel using mri
export delimited using mri
export dbase using mri 
