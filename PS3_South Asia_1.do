*Prakash Chandr Kandel
*DATA MANAGEMENT
*DATA on South Asia

local worDir "/Users/prakashchandrakandel/Desktop/Latest"
cap mkdir `worDir'


/* This project will bring together six datasets namely World Development, 
Undernutrition, Deaths related to several causes, Corruption Perception Index, 
World Happiness, and level of political freedom related to South Asia where 
poverty and inequality are high. My main objective to collect data is to identify 
whether poverty and inequality have ramifications in a person's upbringing, 
stability in the society, freedom, and sense of happiness to name a few. The South 
Asian Countries are Afghanistan, Bhutan, Bangladesh, Nepal, India, Pakistan, 
Sri Lanka, and the Maldives.
*/

*--------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------*
*WORLD DEVELOPMENT INDICATORS
*WORLD BANK DATA

/*The main objective of including World Development Indicators is to gain an 
understanding about the measures that have been taken to fight poverty. 
For example, data on access to electricity, out-of-school children, poeverty 
headcount ratio, literacy rate, women's ability to make self-decision and 
unemployment rate have been considered for analysis.
*/
//https://databank.worldbank.org/reports.aspx?source=world-development-indicators#advancedDownloadOptions

import excel "https://docs.google.com/uc?id=1-CC6tUpRdGrvrEY2o0Kh6Ls0oWcIHzHO&export=download", firstrow clear 

d
summarize

drop if CountryName ==""

tab CountryName, mi

drop SeriesCode

format %24s CountryName

*RESHAPING the Table*
reshape long YR,  i(CountryName CountryCode SeriesName) j(Year)
rename YR _

*Replacing the variables name by shortening them*
replace SeriesName = "elec_acc" if SeriesName == "Access to electricity (% of population)"
replace SeriesName = "net_enrol" if SeriesName == "Adjusted net enrollment rate, primary (% of primary school age children)"
replace SeriesName = "net_sav" if SeriesName == "Adjusted net savings, excluding particulate emission damage (current US$)"
replace SeriesName = "child_out" if SeriesName == "Children out of school (% of primary school age)"
replace SeriesName = "health_exp" if SeriesName == "Current health expenditure per capita (current US$)"
replace SeriesName = "Lit_rate" if SeriesName == "Literacy rate, youth (ages 15-24), gender parity index (GPI)"
replace SeriesName = "pov_ratio" if SeriesName == "Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)"
replace SeriesName = "unemp_perc" if SeriesName == "Unemployment, total (% of total labor force) (national estimate)"
replace SeriesName = "fem_dec" if SeriesName == "Women making their own informed decisions regarding sexual relations, contraceptive use and reproductive health care  (% of women age 15-49)"


*RESHAPING the Table*
reshape wide _, i(CountryName Year) j(SeriesName) string

*Labeling the Variables

label var _Lit_rate "Literacy rate, youth (ages 15-24), gender parity index (GPI)"
label var _child_out "Children out of school (% of primary school age)"
label var _elec_acc "Access to electricity (% of population)"
label var _fem_dec "Women making their own informed decisions regarding sexual relations, contraceptive use and reproductive health care  (% of women age 15-49)"
label var _health_exp "Current health expenditure per capita (current US$)"
label var _net_enrol "Adjusted net enrollment rate, primary (% of primary school age children)"
label var _net_sav "Adjusted net savings, excluding particulate emission damage (current US$)"
label var _pov_ratio "Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)"
label var _unemp_perc "Unemployment, total (% of total labor force) (national estimate)"
label var Year "Year of Data Collection"

order CountryCode CountryName Year 
sort CountryName Year 
edit 
save wdi, replace


*--------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------*

*FOOD AND AGRICULTURAL ORGANIZATION OF THE UNITED NATIONS
*PREVALENCE OF UNDERNUTRITION IN SOUTH ASIA 

/*"The prevalence of undernourishment (PoU) is an estimate of the proportion 
of the population whose habitual food consumption is insufficient to provide 
the dietary energy levels that are required to maintain a normal active and 
healthy life. It is expressed as a percentage. This indicator measures progress 
towards SDG Target 2.1." Undernourishment hampers proper physical and mental 
growth and development which then later manifest as inability to make progress 
on overall sphere of life--be it education, income and health. Such disadvantaged 
people cannot contribute to making a happy, haealthy and peaceful society. The 
undernutrition leads to wasting, stunting, overweight, underweight and in 
extreme cases, death. 
"Prevalence of undernourishment (% of population) Long definition. Prevalence 
of undernourishment is the percentage of the population whose habitual food 
consumption is insufficient to provide the dietary energy levels that are 
required to maintain a normal active and healthy life.Data showing as 2.5 may 
signify a prevalence of undernourishment below 2.5%.
//SourceFood and Agriculture Organization (http://www.fao.org/faostat/en/#home).
*/


//https://www.fao.org/sustainable-development-goals/indicators/211/en/

import excel "https://docs.google.com/uc?id=1OUuzpRJdYPo1sE3sP4JAV5TRHmyqGGRa&export=download", firstrow clear

d 

summarize

*Rename and Label*
rename Value undnourish
label var undnourish "Prevalence of undernourishment (%)"
rename GeoAreaName CountryName
label var CountryName "Name of the Country"
rename TimePeriod Year

format %15s CountryName

*keep*
keep if inlist(CountryName,"Afghanistan","Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka") & Year>2014 

keep CountryName Year undnourish


destring*, replace

save under_nut, replace

*Merge*

sort CountryName Year
edit

count if CountryName==CountryName[_n-1] & Year==Year[_n-1]

merge 1:1 CountryName Year using wdi 

/*

 *Merge*
. merge m:1 CountryName Year using wdi, nogen

    Result                      Number of obs
    -----------------------------------------
    Not matched                            16
        from master                         8  
        from using                          8  

    Matched                                32  
    -----------------------------------------
 The reason for non-merge is because the World Development Indicators 
 (masterdata) has time spanning from 2016 to 2020, whereas using has time period
 ranging from 2015-2020,
*/

tab _merge, mi

sort CountryName Year 

edit

drop _merge
order CountryName CountryCode Year undnourish

save under_nut, replace

*--------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------*

**DEATH BY DIFFERENT CAUSES**

/*Death by different causes is one of the world's largest health and 
environmental problems. The dataset includes statistics related to unsafe 
water sources, low birth weight child wasting, household pollution from solid
fuels, smoking, outdoor air pollution, unsafe sanitation, and lack of access to 
handwashing  facility. In South Asia, such lacking is rampant, and I want to 
how they are connected to poverty.
*/

*Source:Our World in Data: Death Due to Various Causes
//https://ourworldindata.org/air-pollution

import delimited using "https://docs.google.com/uc?id=1sIxzd5Og0tPVVKt_BA4l7ZvCIeEqxAZh&export=download", varnames(1) clear 

d

sum

*keep*
keep entity code year deathscauseallcausesriskunsafewa  deathscauseallcausesrisklowbirth deathscauseallcausesriskchildwas deathscauseallcausesriskhousehol deathscauseallcausesrisksmokings  deathscauseallcausesriskairpollu  deathscauseallcausesriskunsafesa deathscauseallcausesrisknoaccess deathscauseallcausesriskchildstu 


*rename and label
rename entity CountryName
label var CountryName "Name of the Country"
rename year Year
rename code CountryCode
rename deathscauseallcausesriskunsafewa unsafewater
rename deathscauseallcausesrisklowbirth lowweight
rename deathscauseallcausesriskchildwas childwaste
rename deathscauseallcausesriskhousehol arphouse
rename deathscauseallcausesrisksmokings smoke
rename deathscauseallcausesriskairpollu arprisk
rename deathscauseallcausesriskunsafesa unsafesani
rename deathscauseallcausesrisknoaccess nohandwash
rename deathscauseallcausesriskchildstu childstunt

*keep
keep if inlist(CountryCode,"AFG","BGD","BTN","IND","MDV","NPL","PAK","LAK") & Year>2014

edit 


*Merge

merge 1:1 CountryName Year using under_nut
/*
 *Merge
 
 merge 1:1 CountryName Year using under_nut, nogen
(variable CountryName was str48, now str92 to accommodate using data's values)

    Result                      Number of obs
    -----------------------------------------
    Not matched                            13
        from master                         0  
        from using                         13  

    Matched                                35  
    -----------------------------------------
The unmatching results because using data does not have data for 
2020.
*/

sort CountryName Year

drop _merge
save death, replace

*--------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------*

*Corruption Perception Index

/* The dataset is about Corruption Perception by people in the related countries. 
Monetray corruption is supposed to drain the state coffers, and deny the common 
people the access to necessary resources and development, which then leads to 
impoverishment and inequlity. In light of this I have included the dataset.

"The Corruption Perceptions Index (CPI) is an index which ranks countries "by 
their perceived levels of public sector[1] corruption, as determined by expert 
assessments and opinion surveys."[2] The CPI generally defines corruption as 
an "abuse of entrusted power for private gain".[3] The index is published 
annually by the non-governmental organisation Transparency International since 
1995.
(Source: Wikipedia)
The score range is from 0 to 100. Greater the score, less are the countries 
corrupted and vice-versa.
*/

//https://www.transparency.org/en/cpi/2020

import excel "https://docs.google.com/uc?id=1wPDrxSAgP5Gni9xXW5BL6qb9G7wSkKCn&export=download", clear

d 

sum

*drop & Keep
drop if B == ""
keep A B D H L P T W 

*rename and label
rename A CountryName
label var CountryName "Name of the Country"
rename B CountryCode
label var CountryCode "Country Code"
rename D YR2020
rename H YR2019
rename L YR2018
rename P YR2017
rename T YR2016
rename W YR2015

edit

*Keeping only the countries that are required for analysis
keep if inlist(CountryCode,"AFG","BGD","BTN","IND","MDV","NPL","PAK","LAK")


destring*, replace

*RESHAPE
reshape long YR,  i(CountryName CountryCode) j(Year)

rename YR CPI_Value
label var CPI "Corruption Perception Index Value"
label var Year "Year"

*MERGE
merge 1:1 CountryName Year using under_nut

/*
 merge 1:1 CountryName Year using under_nut
(variable CountryName was str62, now str92 to accommodate using data's values)

    Result                      Number of obs
    -----------------------------------------
    Not matched                             6
        from master                         0  (_merge==1)
        from using                          6  (_merge==2)

    Matched                                42  (_merge==3)
The  unmatched result is due to lack of data for master in 2015
*/

tab _merge

drop _merge  

order CountryCode CountryName Year

sort CountryName Year

edit

save cpi, replace 

*--------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------*

*World Happiness Measure

/* I am highly interested in knowing about the level of happiness of people in 
the considered region. Various indicators are used for the measurement and 
analysis of level of happiness. It will bw interesting to find out if poverty 
and inequality have anything to with the level of happines.

"The World Happiness Report, one of the best tools for evaluating global 
happiness, is based on how ecstatic people perceive themselves to be. 
It considers six characteristics to rank countries on overall happiness: GDP 
per capita, social support, life expectancy, freedom to make choices, 
generosity, and perception of corruption."
Source: https://worldhappiness.report/faq/
*/
//https://worldhappiness.report/ed/2021/

import excel "https://docs.google.com/uc?id=1kjKegNA4E24tmakV5KPiFAtzeEDrSCTJ&export=download", firstrow clear

d

sum

edit

*Rename
rename Countryname CountryName
rename year Year
label var Year "Year of Data Collection"

*Keep and drop functions
keep if inlist(CountryName,"Afghanistan","Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka") & Year>=2015

save happy, replace

*MERGE
merge 1:m CountryName Year using cpi

/*
merge 1:m CountryName Year using cpi
(variable CountryName was str25, now str92 to accommodate using data's values)

    Result                      Number of obs
    -----------------------------------------
    Not matched                            15
        from master                         0  (_merge==1)
        from using                         15  (_merge==2)

    Matched                                33  (_merge==3)
    -----------------------------------------

The unmatching may be related to the time period as the using data spans from
2015 to 2019.
*/

tab _merge
drop _merge

order CountryCode  CountryName Year

save happy, replace

*--------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------*

/*FREEDOM RANKING
To what extent a country is free is measured by  the level of Political Rights 
and Civil Rights exercised by the citizens of the concerned country. My 
motivation behind choosing the related dataset is based on prevalent notion 
that poverty and inequality correspond to less or no political and civil 
freedoms. I guess it will be interesting to find out the relationships.

"The average of each pair of ratings on political rights and civil liberties 
determines the overall status of "Free" (1.0–2.5), "Partly Free" (3.0–5.0), or 
"Not Free" (5.5–7.0)."
(Source:Wikipedia)
The range of score ranges from 0-10.
*/

//https://freedomhouse.org/reports/publication-archives


import excel "https://docs.google.com/uc?id=1QVIYs-EHiZ0SVQcY49zWprynkavmOEBz&export=download", sheet("FIW13-22") cellrange(A2:AR2097) firstrow clear


*keep
keep CountryTerritory Edition PRrating CLrating

*rename and label
rename CountryTerritory CountryName
rename Edition Year
label var PRrating "Political Rights Rating"
label var CLrating "Civil Liberties Rating"

*drop and keep

keep if inlist(CountryName,"Afghanistan","Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka") 

drop if Year<2015 | Year>2020


*MERGE*
merge 1:m CountryName Year using happy

/*
 merge 1:m CountryName Year using happy
(variable CountryName was str30, now str92 to accommodate using data's values)

    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                                48  (_merge==3)
*/

tab _merge

format %24s CountryName

replace CountryCode = "LKA" if CountryCode==""

order CountryCode CountryName Year


save freedom, replace


