*Prakash Chandra Kandel
*Data Management Class
* Spring 2022

//read carefully ps insytrusctions!! eg need to save in 3 diff formats!
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* This dofile is associated with the voting patterns in the 2020 Presidential Election in 2020 across municipalities in New Jersey. I will be using the related data set to find out the relationship between adoption of Marijuana Law across municipalities and voting patterns.
version 17.0 //a;lways say which version; can also give your name etc
clear all


//always specify data source
* Data Source : https://datawrapper.dwcdn.net/o9YRC/9/
import excel using "https://docs.google.com/uc?id=1FP-RfK3nxA_PPvC6ng4ZlchsViWptlUV&export=download", firstrow

rename J Biden_Percent //thats great to keep it clean
rename K Trump_Percent

//really good to label
label var Biden_Percent "Percentage of votes secured by Biden in 2020 Election"
label var Trump_Percent "Percentage of votes secured by Trump in 2020 Election"


sample 25
count
edit
browse
edit Biden

*
sort County
list Biden Trump County, sepby(County)

list County in 1/10 

d
sum

//need to read ps carefully; didnt save in 3 different formats; abd should have used 2 different datasets to begin with

. export excel using "/Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/Excel_PS1.xls" 
//ok fine but stuff like this:
file /Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/Excel_PS1.xls saved
//is not the command! its stata message! it must be dropped!! here and elsewhere

//and stata commands cannot be preceded by a "." like below:
. export delimited using "/Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/CSV_PS1.csv", 
replace file /Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/CSV_PS1.csv saved
 
. export sasxport8 "/Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/SAS.v8xpt"
file /Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/SAS.v8xpt saved




clear all
exit 
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*

* Using another datasource after following your instructions:

* My research project is about studying adoption of Marjuana Law by various municipalities in New Jersey based on various contributing factors such as Muncipal Revitalization Index, education, age of population, and voting patterns in preidential elections, to name a few. 



clear all

//no this wont work! i dont have this file! it must load data from online!!
//and remember to have 2 files from 2 different sources

* The link for the data is: https://www.nj.gov/dca/home/2020_MRI_Scores_and_Rankings.xlsx

import excel "https://docs.google.com/uc?id=1MFklK6ss_5WY5QUcti93Zo50lKWGYmE9&export=download", clear

browse

drop in 1/5

browse
drop in 1
browse
drop in 566/575

*Renaming of variables //can read it first row as names, see help import excel
//The first row did not have the variables.
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
rename nshv_rate nshv_rate_rank
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

*Labeling of variables

label var muni_id "Municipality Name"
label var muni_id "Municipality ID"
label var muni_name "Municipality Name"
label var county_name "County Name"
label var region "New Jersey Regions"
label var mri_score "Municipal Revitalization Index Score"
label var mri_distress_score "MRI Distress Score of NJ Municipalities"
label var mri_rank "MRI Ranking of NJ Municipalities"
label var pop_change_rank "Population Change of NJ Municipalities (2009-2019)"
label var pop_change_inde "Population Change Index of NJ Municipalities (2009-2019)"
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



foreach var of varlist mri_score-urb_aid {
destring `var', replace force
}


sample 25
count
edit
browse
edit region


sort county_name
list muni_name county_name, sepby(county_name)

list county_name in 1/10 

des

sum

*saving in three different formats

. export excel using "/Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/MRI.xls", firstrow(variables) 
file /Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/MRI.xls saved

. export delimited using "/Users/prakashchandrakandel/Desktop/DATA MA
> NAGEMENT/PS1/MRI.csv", replace
file /Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/MRI.csv saved

. export sasxport8 "/Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/MRI.v8xpt"
file /Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/PS1/MRI.v8xpt saved

clear all

exit
