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

//that's a fancy macro, we'll cover it when we do programing; run as one chunk
local worDir "/Users/prakashchandrakandel/Desktop/DATA MANAGEMENT"
cap mkdir `worDir'
cd  `worDir'

*The Municipal Revitalization Index (MRI) serves as the State's official measure and ranking of municipal distress. The MRI ranks New Jersey's municipalities according to eight separate indicators that measure diverse aspects of social, economic, physical, and fiscal conditions in each locality. The MRI is used as a factor in distributing certain "need based" funds. (source: Department of New Jersey, Department of Community Affairs)

*The dataset below is related to Municipality Revitalization Index(MRI) of New Jersey Municipalities where MRI scores are related to level of distress for the concerned municiapalities. MRI score of 1 means least distressed and of 565 means the most distressed. The dataset will be used to find out the relationship between the legalization of Cannabis and the MRI score.


//https://www.nj.gov/dca/home/2020_MRI_Scores_and_Rankings.xlsx
import excel "https://docs.google.com/uc?id=1MFklK6ss_5WY5QUcti93Zo50lKWGYmE9&export=download", clear 

//can give it option firstr to read first row as var names, less work
*Ans: Any of the first 6 rows had no data.
// well then read it starting with 6th row:
// cellrange(A6)
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
rename B muniname
label var muniname "Municipality Name"
rename C county
label var county "County Name"
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



destring mri_score, gen (mriscore_num)
drop mri_score
destring pop_change_value, gen (popcval_num)
drop pop_change_value
destring nshv_rate_value, gen(nshvrval_num)
drop nshv_rate_value
destring snap_value, gen(snapv_num)
drop snap_value
destring tanf_value, gen(tanfv_num)
drop tanf_value
destring pov_value, gen(popv_num)
drop pov_value
destring mhi_value, gen(mhiv_num)
drop mhi_value
destring unemp_value, gen(unempv_num)
drop unemp_value
destring edu_value, gen (eduv_num)
drop edu_value 
destring proptax_value, gen(proptv_num)
drop proptax_value
destring capita_value, gen(capv_num)
drop capita_value
drop in 566/574

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
                             
save mri.dta, replace 


generate county=.
replace county=1 if county_id==1
replace county=0 if county_id>1 & county_id<22						  
							  						  

recode county_id (1=1) (2/21=), gen(county_1)

ta region region_numeric, mi



/* Egen */

use mri, clear
egen avg_cap=mean(capv_num)
sum capv_num
gen dev_capita=capv_num-avg_cap
l capv_num avg_cap dev_capita in 1/10, nola

bys county_id: egen avgm_capita=mean(capita_value)
l  capv_num county* if  county_id==3 | county_id==1

sort county_id
l  capv_num county_id, nola sepby(county_id)

order mri_score               
d
edit

aorder                        /*vars in alphabetic order*/
d
edit

use mri, clear

/*_n, _N */  
gen id= _n
label var id "New Municipal ID"
order id
save mri, replace

gen total= _N
l

gen previous_id=id[_n-1]
bys county_id: gen count_county_group= _N

l id total previous  count_county_group county_id, sepby(county_id)


/*collapse*/

use mri, clear


bys county_id: gen count_county_group=_n
bys county_id: egen count_id=count(id)

l id county_id count*, sepby(county_id)

collapse capv_num mriscore_num eduv_num, by(county_id) /*mean is default*/
l

use mri, clear
bys county_id: egen counCou=count(county_id)
l 

collapse (count) id, by(county_id)
l

*saving in different formats
export excel using mri
export delimited using mri
export dbase using mri 

clear
exit

*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*

*The another data set is about the results of 2020 Presidential Election in New Jersey, which will be used to find out the the relationship between status of cannabis legalization, parameters of MRI, and  the results of presidential election. In other words, this dataset will be used to identify the relationship between adopting Marijuana Law and voting pattern, while at the same time taking other variables into account.

//https://datawrapper.dwcdn.net/o9YRC/9/
* notes : 
clear         
set matsize 800 
version 17
set more off
*--------------------------------------------------------------------
*--------------------------------------------------------------------

local worDir "/Users/prakashchandrakandel/Desktop/DATA MANAGEMENT"
cap mkdir `worDir'
cd  `worDir'

clear

//https://datawrapper.dwcdn.net/o9YRC/9/
import delimited using "https://docs.google.com/uc?id=1sYVRk8YiSajJ-5sexhcXjLJkyCq59aow&export=download", clear


drop latitude longitude marginforbiden
rename municipality muni_name
label var muni_name "Municiplaity Name"
label var county "County Name"
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

save pres_elect,replace

gen id=_n
l
order id
l
encode county, gen (county_id)
d
sum

save pres_elect,replace
export excel using pres_elect
export delimited using pres_elect


merge 1:1 id using mri //no!!!!!!! how you merge new jersey with the world????
l 
drop muni_id muniname
save pres_elect,replace

* Ans: This is from a different project that I am doing with Dr. Hayes. I am working on global data and will be seeking your support.

 
clear
exit
