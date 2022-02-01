* My research project is about studying adoption of Marjuana Law by various municipalities in New Jersey based on various contributing factors such as Muncipal Revitalization Index, education, age of population, and voting patterns in preidential elections, to name a few. 

* The link for the data is: https://docs.google.com/uc?id=1MFklK6ss_5WY5QUcti93Zo50lKWGYmE9&export=download

clear all

import excel "/Users/prakashchandrakandel/Desktop/DATA MANAGEMENT/Dataset/2020_MRI_Scores_and_Rankings.xlsx", sheet("2020 MRI - Alphabetical")

browse

drop in 1/5

browse
drop in 1
browse
drop in 566/575

*Renaming of variables

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

* ordering variables for destringing functions except some that have been moved to last so as to avoid destringing

*source: https://www.researchgate.net/post/How-can-I-use-destring-for-all-my-variables-in-a-stata-file-more-than-500-vars-but-one

order muni_id, last
order muni_name, last
order county_name, last
order region, last


foreach var of varlist mri_score-urb_aid {
destring `var', replace force
}

* These below given steps are for restoring the string variabels to their original positions after destrining of other variables ranging from mri_score to urb_aid.

order region, first
order county_name, first
order muni_name, first
order muni_id, first

des

sum

clear all

exit
