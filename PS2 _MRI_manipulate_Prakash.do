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
s
et seed 123456789 //setting randomness to a constant
d
sum
save mri.dta, replace

/**************/
/* Variables  */
/**************/

use mri, clear
drop in 1/6
drop in 567/575

rename A muni_id
rename B muni_name
rename C county_name
rename D region
rename E mri_score
rename F mri_distress_score
rename G mri_rank
rename H pop_change_rank
rename I pop_change_index
rename J pop_change_value
rename K nshv_rate
rename L nshv_rate_index 
rename M nshv_rate_value
rename N snap_rank
rename O snap_index
rename P snap_value
rename Q tanf_rank
rename R tanf_index
rename S tanf_value
rename T pov_rank
rename U pov_index
rename V pov_value
rename W mhi_rank
rename X mhi_index
rename Y mhi_value
rename Z unemp_rank
rename AA unemp_index
rename AB unemp_value
rename AC edu_rank
rename AD edu_index
rename AE edu_value
rename AF proptax_rank
rename AG proptax_index
rename AH proptax_value
rename AI capita_rank
rename AJ capita_index
rename AK capita_value
rename AL urb_aid
rename nshv_rate nshv_rate_rank

label var muni_id "Municipality Name"
label var muni_id "Municipality ID"
label var muni_name "Municipality Name"
label var county_name "County Name"
label var region "New Jersey Regions"
label var mri_score "Municipal Revitalization Index Score"
label var mri_distress_score "MRI Distress Score of NJ Municipalities"
label var mri_rank "MRI Ranking of NJ Municipalities"
label var pop_change_rank "Population Change of NJ Municipalities (2009-2019)"
label var pop_change_index "Population Change Index of NJ Municipalities (2009-2019)"
label var pop_change_value "Population Change Value of NJ Municipalities (2009-2019)"
label var nshv_rate_rank "Non-seasonal Housing Vacancy Rate Ranking (2019)"
label var nshv_rate_index "Non-seasonal Housing Vacancy Rate Index (2019)"
label var nshv_rate_value "Non-seasonal Housing Vacancy Rate Value (2019)"
label var snap_rank "Supplemental Nutrition Assistance Program (2019) ranking"
label var snap_index "Supplemental Nutrition Assistance Program (2019) Index"
label var snap_value "Supplemental Nutrition Assistance Program (2019) Value"
label var tanf_rank "Children on Temporary Assistance for Needy Families (TANF, 2020) Ranking"
label var tanf_index "Children on Temporary Assistance for Needy Families (TANF, 2020) Index"
label var tanf_value "Children on Temporary Assistance for Needy Families (TANF, 2020) Value"
label var pov_rank "Poverty Rate (2019) Ranking"
label var pov_index "Poverty Rate (2019) Index"
label var pov_value "Poverty Rate (2019) Value"
label var mhi_rank "Median Household Income (2019)Ranking"
label var mhi_index "Median Household Income (2019)Index"
label var mhi_value "Median Household Income (2019) Value"
label var unemp_rank "Unemplyment Rate (2019) Ranking"
label var unemp_index "Unemplyment Rate (2019) Index"
label var unemp_value "Unemplyment Rate (2019) Value"
label var edu_rank "High School Diploma or Higher (2017-19) Ranking"
label var edu_index "High School Diploma or Higher (2017-19) Index"
label var edu_value "High School Diploma or Higher (2017-19) Value"
label var proptax_rank "Average Property Tax Rate (2017-19) Ranking"
label var proptax_index "Average Property Tax Rate (2017-19) Index"
label var proptax_value "Average Property Tax Rate (2017-19) Value"
label var capita_rank "Equalized Valuation Per Capita (2019) Ranking"
label var capita_index "Equalized Valuation Per Capita (2019) Index"
label var capita_value "Equalized Valuation Per Capita (2019) Value"
label var urb_aid "2020 Urban Aid"

drop pop_change_index nshv_rate_rank nshv_rate_index snap_rank snap_index tanf_rank tanf_index pov_rank pov_index mhi_rank mhi_index unemp_rank unemp_index edu_rank edu_index proptax_rank proptax_index capita_rank capita_index urb_aid 


save mri.dta, replace


destring mri_score, gen (mriscore_num)
drop in 566/1141
drop pop_change_rank

destring mri_distress_score, gen(mrid_num)
destring mri_rank, gen(mrir_num)
destring pop_change_value, gen (popcval_num)
destring nshv_rate_value, gen(nshvrval_num)
destring snap_value, gen(snapv_num)
destring tanf_value, gen(tanfv_num)
destring pov_value, gen(popv_num)
destring mhi_value, gen(mhiv_num)
destring unemp_value, gen(unempv_num)
destring edu_value, gen (eduv_num)
destring proptax_value, gen(proptv_num)
destring capita_value, gen(capv_num)

d
sum


tab county_name                  /*check var values*/
tab county_name, nola             /*without labels*/
tab county_name, mi               /*checking for missings*/
encode region, gen(region_numeric)
encode county_name, gen(county_id)

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


merge 1:1 id using mri 
 
clear
exit
