/*
mistake! same values for different countries for same years

im;portant to interpret!!! use graphs in a meaningful way

most of these graphs dont make sense
*/

*Note: PS4 will follow PS3
                             *****************
                                  *PS3
                             ******************

*Prakash Chandra Kandel
*DATA MANAGEMENT
*DATA on South Asia
*STATA Version: 17.0

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

rename _* * //removing the special character in front of all the variables//

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
. merge m:1 CountryName Year using wdi

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
 
 merge 1:1 CountryName Year using under_nut
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
merge 1:1 CountryName Year using death

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
rename LifeLadder liflad
rename LogGDPpercapita loggdppc
rename Socialsupport socsupp
rename Healthylifeexpectancyatbirth lifexpbirth
rename Freedomtomakelifechoices lifechoice
rename Generosity generosity
rename Perceptionsofcorruption corrpercep
rename Positiveaffect poseffect
rename Negativeaffect negaffect



*Keep and drop functions
keep if inlist(CountryName,"Afghanistan","Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka") & Year>=2015

save happy, replace

*MERGE
merge 1:1 CountryName Year using cpi

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

sort CountryName Year

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
label var Year "Year"
label var PRrating "Political Rights Rating"
label var CLrating "Civil Liberties Rating"

*drop and keep

keep if inlist(CountryName,"Afghanistan","Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka") 

drop if Year<2015 | Year>2020


*MERGE*
merge 1:1 CountryName Year using happy

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

drop _merge

replace CountryCode = "LKA" if CountryCode==""

order CountryCode CountryName Year

save freedom, replace

************************************************************************************************
/*POPULATION (United Nations Population Division World Population Prospects 2019)
Population is an important criterion in determining inequality and poverty; 
therefore, I have added it to the dataset. The Population dataset has been manipulated
to select Country, Male Poplulation, Female Population
*/

//https://population.un.org/wpp/Download/Standard/CSV/

import delimited using "https://docs.google.com/uc?id=1SYF7rcAxOBJTqbTwbYYMliA5bS8kkXyR&export=download", varnames(1) clear 

d
sum 

****keep****
keep if inlist(location,"Afghanistan","Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka") & variant == "Medium" 

rename location CountryName

keep CountryName time popmale popfemale poptotal popdensity

keep if time>2014 & time<2021

*****Collapsing to take out the Average*****
collapse popmale popfemale poptotal popdensity, by(CountryName) //The collapse is for calculating the average of the variables under consideration from the time period between 2015-2021.

****labeling****
label var popmale "Average male population (thousands) from 2015-2020"
label var popfemale "Average female population (thousands) from 2015-2020"
label var poptotal "Average total population (thousands) from 2015-2020"
label var popdensity "Average population per square kilometre (thousands) from 2015-2020"

****MERGE******

merge 1:m CountryName using freedom 

/*merge 1:m CountryName using freedom 
(variable CountryName was str89, now str92 to accommodate using data's values)

    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                                48  (_merge==3)
    -----------------------------------------
*/
edit 

format %24s CountryName

order CountryCode CountryName Year

sort CountryName Year

save pop, replace

*****************************************************************************
***************************     PS4       **********************************
*****************************************************************************

/* PS4 will mainly be about my desire to find out relationship between various especially focusing on poverty.

My research questions will include the following:
1- Do various development indicators like literacy rate and female decision affect poverty?
2. How are parameters of subjective well-being associated with happiness?
3. Does exercise of political rights and civic liberties impact happiness (Life ladder); if so, in which direction ?
*/

*CHECKING Missing Data*

use pop, clear
misstable sum 

sort CountryName Year

drop if CountryName == "Afghanistan" //dropping Afghnistan as it does not have single value for poverty ratio//

***Use of Tabs and Tabstat for Deaths by Different Causes ***

tabstat unsafewater lowweight childwaste arphouse smoke arprisk unsafesani nohandwash childstunt undnourish, by(CountryName)
tabstat unsafewater lowweight childwaste arphouse smoke arprisk unsafesani nohandwash childstunt undnourish, by(CountryName) stat(mean sd min max)
tabstat unsafewater lowweight childwaste arphouse smoke arprisk unsafesani nohandwash childstunt undnourish, by(CountryName) stat(mean sd min max) nototal long format
tabstat unsafewater lowweight childwaste arphouse smoke arprisk unsafesani nohandwash childstunt undnourish, by(CountryName) stat(mean sd min max) nototal long col(stat)


**Filling in of Missing Values using of variables depending on Year using ipolate and epolate and relabeling**

ipolate liflad Year, gen (ilifelad) epolate
label var ilifelad "Ladder of Life"
ipolate loggdppc Year, gen( iloggdppc) epolate
label var iloggdppc " Log of GDP per Capita"
ipolate socsupp Year, gen (isocsupp) epolate
label var isocsupp " Social Support"
ipolate lifexpbirth Year, gen (ilifexpbirth) epolate
label var ilifexpbirth "Healthy Life Expectancy at Birth"
ipolate lifechoice Year, gen (ilifechoice) epolate
label var ilifechoice "Freedom to make life choices"
ipolate generosity Year, gen (igenerosity) epolate
label var igenerosity "Generosity"
ipolate corrpercep Year, gen (icorrpercep) epolate
label var icorrpercep "Perception of Corruption"
ipolate poseffect Year, gen (iposeffect) epolate
label var iposeffect "Positive Effect"
ipolate negaffect Year, gen (inegaffect) epolate
label var inegaffect "Negative Effect"
ipolate CPI_Value Year, gen (iCPI_Value) epolate
label var iCPI_Value "Corruption Perception Index"
ipolate unsafewater Year, gen (iunsafewater) epolate
label var iunsafewater "Death due to Unsafe Water"
ipolate lowweight Year, gen (ilowweight) epolate
label var ilowweight "Death due to Low Birth Weight"
ipolate childwaste Year, gen (ichildwaste) epolate
label var ichildwaste "Death due to Child Wasting"
ipolate arphouse Year, gen (iarphouse) epolate
label var iarphouse "Death due to Household Air Polution"
ipolate smoke Year, gen (ismoke) epolate
label var ismoke "Death due to Smoking"
ipolate unsafesani Year, gen (iunsafesani) epolate
label var iunsafesani "Death due to Unsafe Sanitation"
ipolate nohandwash Year, gen (inohandwash) epolate
label var inohandwash "Death due to Lack of Handwashing Facility"
ipolate childstunt Year, gen (ichildstunt) epolate
label var ichildstunt "Death due to Child Stunting"
ipolate undnourish Year, gen (iundnourish) epolate
label var iundnourish "Death due to Undernourishment"
ipolate Lit_rate Year, gen (iLit_rate) epolate
label var iLit_rate "Literacy Rate (ages 15-24), Gender Parity Index"
ipolate child_out Year, gen (ichild_out) epolate
label var ichild_out "% Children out of School (primary school age)"
ipolate elec_acc Year, gen (ielect_acc) epolate
label var ielect_acc "Access to Electricity (% of the Population)"
ipolate fem_dec Year, gen (ifem_dec) epolate
label var ifem_dec "Women's Ability to Take Decisions"
ipolate health_exp Year, gen (ihealth_exp) epolate
label var ihealth_exp "Current Health Expenditure Per Capita"
ipolate net_enrol Year, gen (inet_enrol) epolate
label var inet_enrol "Adjusted Enrolment Rate Primary (%)"
ipolate net_sav Year, gen(inet_sav) epolate
label var inet_sav "Adjusted Net Savings (US$)"
ipolate pov_ratio Year, gen (ipov_ratio) epolate
label var ipov_ratio "Poverty Headcount Ratio at $1.90 (% of the Population)"
ipolate unemp_perc Year, gen (iunemp_perc) epolate
label var iunemp_perc "Unemployment, Total (% of the Labor Force)"

/* Note: The relabeling had to be done because after interpolation and extrapolation, the labels automatically changed to vague names */

save pop, replace

***creating radar for World Happiness Index****


*Histograms
histogram poptotal, normal title("Total Population")
histogram poptotal, frequency title("Total Population")
histogram poptotal, discrete title("Total Population")

/*transformation*/
use pop, clear
gladder ilifelad, fraction //

*Creation of Radar for some of the variables related to Happiness Index*
ssc install radar

#delimit ;
radar  isocsupp ilifechoice iposeffect,
   aspect(1) 
   title(Range of Happiness Parameters, size(*0.6)) 
   lc(red blue maroon)  
   lw(medium) rlabel( 0 0.2 0.4 0.6 0.8 1.0) labsize(*0.7) 
   legend(label(1 "Social Support") 
          label(2 "Freedom of Life Choice")
          label(3 "Positive Effect")
          col(1) size(*.8)) ;
#delimit cr*/

**Finding association between poverty and female decision making**
sum
d
graph twoway scatter ipov_ratio ifem_dec 
gr export myfig.png, replace 
/* It appears that increased female decision making in a household is associated with decline in poverty ratio.
*/ 

graph twoway connected ipov_ratio iLit_rate, sort // twoway graph between poverty ratio and Literacy Rate

**CI plots of Population Categories	 
ciplot popmale 
ciplot popmale, by(CountryName)
ciplot popmale popfemale, by(CountryName) xla(, ang(45))
ciplot popmale popfemale, hor

**CI plots of some of the Happiness Parameters
ciplot ilifelad 
ciplot ilifelad, by(CountryName) 
ciplot ilifelad iloggdppc isocsupp, by(CountryName) hor


********************************Regressions**************************************

findit outreg2  

                             *****REGRESSION 1******
  
  /* The first regression will be about finding the relationship between poverty and other human development indicators*/

graph twoway connected ipov_ratio iLit_rate, sort

reg ipov_ratio iLit_rate, r //running  regression between poverty ratio and literacy rate with poverty ratio as dependent variable
predict yhat1
display _b[iLit]
display _se[iLit_rate]
test iLit_rate
outreg2 using poverty.xls, dec(2) excel e(all) replace

graph twoway ///
	(scatter ipov_ratio iLit_rate) /// 
	(line yhat1 iLit_rate), ///
	graphregion(color(white)) ///
	ytitle("Poverty Ratio" "in Percent", orientation(vertical)) ///
	ylabel(, angle(horizontal)) title("Association between Poverty Ratio and Literacy Rate ") ///
	name(bivariate, replace)    
  
reg ipov_ratio iLit_rate ichild_out, r //adding percentage of children out of school
outreg2 using poverty.xls, dec(2) excel e(all) append

test iLit_rate ichild_out //testing joint significance 
/* The joint test of significance is statitistically significant*/

reg ipov_ratio iLit_rate ichild_out ielect_acc, r // access to electricity as next independent variable
outreg2 using poverty.xls, dec(2) excel e(all) append

reg ipov_ratio iLit_rate ichild_out ielect_acc ifem_dec, r //  adding female deciion making as another variable into the mix
outreg2 using poverty.xls, dec(2) excel e(all) append

gen ihealth_expln = ln(ihealth_exp) // generating log of health expenditure per capita
 
reg ipov_ratio iLit_rate ichild_out ielect_acc ifem_dec ihealth_expln, r //  log of health expenditure as another variable
outreg2 using poverty.xls, dec(2) excel e(all) append 


reg ipov_ratio iLit_rate ichild_out ielect_acc ifem_dec ihealth_expln inet_enrol, r //  Adjusted Enrolment Rate for Primary School Aged Children as another variable
outreg2 using poverty.xls, dec(2) excel e(all) append 


reg ipov_ratio iLit_rate ichild_out ielect_acc ifem_dec ihealth_expln inet_enrol iunemp_perc, r //  Unemployment, Total (% of the total labor Force; National Estimates)
outreg2 using poverty.xls, dec(2) excel e(all) append 

gen poptotalln = ln(poptotal) //Natural log of total population will be considered before inserting it into the regression

reg ipov_ratio iLit_rate ichild_out ielect_acc ifem_dec ihealth_expln inet_enrol iunemp_perc poptotalln, r //  Natural log of total population added to the mix to see the latter's effect
outreg2 using poverty.xls, dec(2) excel e(all) append 

*****The Margins and Marginsplot Command***
margins, dydx(*)
marginsplot, horizontal xline(0) yscale(reverse) recast(scatter)


/* Note: Literacy rate and Unemployment Rate omitted because of collinearity

Result: It appears that  the the coefficients of the independent varibles except the population variable added to the regression show effect on poverty ratio, the dependent varaiable. We can reject th Null hypothesis that makes an assumption that explanatory variables do not affect poverty rate. In fact, at 5% significance level, the relationships are statististically significant. R-squared increases from 0.36 to 1.00 by the time all the independent variables  except the population variable are exhausted. The natural log of the total population does not seem to have any effect at the considered level of significance.

Note: I am a bit confused about R-squared reaching 1.00. Is it realistic?
*/ 



                           *****REGRESSION 2******
/*This regression modeling will consider about finding the association between Happiness score or subjective well-being (variable named as Life Ladder) and  other variables mentioned in World Happiness Report.
Source: https://happiness-report.s3.amazonaws.com/2021/Appendix1WHR2021C2.pdf
*/

reg ilifelad iloggdppc, r //running  regression between Life Ladder and Log of GDP Per Capita
outreg2 using Happy.xls, dec(3) excel e(all) replace

scatter ilifelad iloggdppc, graphregion(fcolor("white") ifcolor("yellow")) //coloring different regions of the graph

graph twoway (scatter ilifelad iloggdppc, symbol(d)) (lfit ilifelad iloggdppc) (lfitci ilifelad iloggdppc), title("Effect of Log of GDP  on Life Ladder") subtitle("95% Confidence Bands") // line of fit and twoway linear prediction plots with CIs


reg ilifelad iloggdppc isocsupp, r // addition of social support as another variable
outreg2 using Happy.xls, dec(3) excel e(all) append

/*Combination of Graphs*/
twoway (scatter ilifelad iloggdppc, sort msymbol(smcircle_hollow) ) (lfit ilifelad iloggdppc),  saving(g1,replace) 
twoway (scatter ilifelad isocsupp, sort msymbol(smcircle_hollow) ) (lfit ilifelad isocsupp),  saving(g2, replace) 
gr combine  g1.gph g2.gph, c(2) iscale(1) saving(g3, replace)


reg ilifelad iloggdppc isocsupp ilifexpbirth, r // addition of Healthy Life Expectancy at Birth as another independent variable
outreg2 using Happy.xls, dec(3) excel e(all) append

reg ilifelad iloggdppc isocsupp ilifexpbirth ilifechoice, r // addition of Freedom to Make Independent Life Choices as another independent variable
outreg2 using Happy.xls, dec(3) excel e(all) append


reg ilifelad iloggdppc isocsupp ilifexpbirth ilifechoice igenerosity, r // addition of Generosity as another independent variable
outreg2 using Happy.xls, dec(3) excel e(all) append

reg ilifelad iloggdppc isocsupp ilifexpbirth ilifechoice igenerosity icorrpercep, r // addition of Corruption Perception as another independent variable
outreg2 using Happy.xls, dec(3) excel e(all) append

reg ilifelad iloggdppc isocsupp ilifexpbirth ilifechoice igenerosity icorrpercep iposeffect, r // addition of Positive Affect as another independent variable
outreg2 using Happy.xls, dec(3) excel e(all) append

/* Positive Affect : Positive affect is defined as the average of three positive affect measures in GWP: happiness, laugh and enjoyment in the Gallup World Poll waves 3-7.
Source: https://happiness-report.s3.amazonaws.com/2021/Appendix1WHR2021C2.pdf
*/

reg ilifelad iloggdppc isocsupp ilifexpbirth ilifechoice igenerosity icorrpercep iposeffect inegaffect, r // addition of Positive Affect as another independent variable
outreg2 using Happy.xls, dec(3) excel e(all) append

/* Negative affect is defined as the average of three negative affect measures in
GWP. They are worry, sadness and anger.
Source: https://happiness-report.s3.amazonaws.com/2021/Appendix1WHR2021C2.pdf
*/

/*note: isocsupp omitted because of collinearity.
note: ilifechoice omitted because of collinearity.
note: igenerosity omitted because of collinearity.*/

*Results: It appears that at 95% confidence interval, the final model seems to show that the coefficients of the independent variables are statistically significant. Thhe variables log of GDP and Negative Affect seem to be negatively associated with Happiness or Subjective Well-being. 

                             *****REGRESSION 3******
/*This regression will consider whether ratings on political rights and civil liberties affect happiness in the South Asian countries?*/

reg ilifelad PRrating, r  //Political Rights rating as independent variable
outreg2 using Freedom.xls, dec(3) excel e(all) replace	

reg ilifelad PRrating CLrating, r  //Civic Liberties rating added as another independent variable
outreg2 using Freedom.xls, dec(3) excel e(all) append

/*Result: It appears that the beta coefficients of the independent variables do not seem statistically	 significant at 95% confidence interval. */			 







