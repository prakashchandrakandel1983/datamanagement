*Prakash Chandra Kandel
*DATA MANAGEMENT
*DATA on South Asia

version 17

cd "/Users/prakashchandrakandel/Desktop/Latest"

/* This project will bring together eight datasets namely World Development, 
Undernutrition, Deaths related to several causes, Corruption Perception Index, 
World Happiness, and level of political freedom related to South Asia where 
poverty and inequality are high. My main objective to collect data is to identify 
whether poverty has ramifications in a person's upbringing, 
stability in the society, freedom, and sense of happiness to name a few. The South 
Asian Countries are  Bhutan, Bangladesh, Nepal, India, Pakistan, 
Sri Lanka, and the Maldives; however, I have excluded Afghanistan as the data on 
many parameters are lacking for this country
*/

/* The datasets will mainly be about my desire to find out relationship between various especially focusing on poverty.

My research questions will include the following:
1- Do various development indicators like literacy rate affect extreme poverty?
2. How are parameters of subjective well-being associated with happiness?
3. Does exercise of political rights and civic liberties impact happiness (Life ladder); if so, in which direction ?
*/



********************************************************************************
****************************EXTREME POVERTY DATASET*****************************
********************************************************************************
/* 
Extreme poverty: The share of people living on less than 1.90 int.-$ per day
The most straightforward way to measure poverty is to set a poverty line and to 
count the number of people living with incomes or consumption levels below that
 poverty line. This is the so-called poverty headcount ratio.

Measuring poverty by the headcount ratio provides information that is straightforward to interpret; by definition, it tells us the share of the population living with consumption (or incomes) below some minimum level.

The World Bank defines extreme poverty as living on less than 1.90 int.-$. In the map we show available estimates of the extreme poverty headcount ratio, country by country.

The map shows the latest available estimates by default, but with the slider (immediately below the map) you can explore changes over time. You can also switch to the `chart' tab to see the change over time for individual countries or world regions; or you simply click on a country to see how the poverty headcount ratio has changed.

Estimates are again expressed in international dollars (int.-$) using 2011 PPP conversion rates. This means that figures account for different price levels in different countries, as well as for inflation.

Source: Our World in Data 

https://ourworldindata.org/extreme-poverty#:~:text=As%20we%20can%20see%2C%20globally,million%20every%20year%20since%201990.

*/


import delimited using "https://docs.google.com/uc?id=1LikL1CKbd8TvTAdijcyF8loL2LL1MMbn&export=download", varnames(1) clear 

d
summarize

//renaming and relabelling the variables
rename entity country
label var country "Country"
rename  v4 povextreme
label var povextreme "Percentage Share of Population below Poverty Line"

keep if inlist(code, "BGD","BTN","IND","MDV","NPL","PAK","LKA") & year>2014

browse

save extremepoverty, replace

*********************** DATA IMPORT FOR MALDIVES *******************************

/*adding extreme poverty data for Malaldives from 2016-2019 because the preceding dataset "extreme poverty" does not have the related data

*Source: https://clio-infra.eu/Countries/Maldives.html
*/

import excel "https://docs.google.com/uc?id=1ie4M6h96bsuELH9I8apJ-zm1JuPM8CGz&export=download", firstrow clear 

drop CountryCode 

rename CountryName country
label var country Country

rename SZ Year2016
rename TA Year2017
rename TB Year2018
rename TC Year2019

keep country Indicator Year2016 Year2017 Year2018 Year2019 

keep if Indicator=="Global Extreme Poverty Dollar a Day"
browse

//reshaping the data from wide to long format
reshape long Year, i(country Indicator) j(year) 
rename  Year povextrem

drop Indicator 

//Ipolate command for filling missing databank for the year 2015 

ipolate povextrem year, gen(povextreme) epolate by(country)
drop povextrem

**Merging Data of Maldives with previous dataset
merge 1:1 country year using extremepoverty
/*
(variable country was str8, now str31 to accommodate using data's values)

    Result                      Number of obs
    -----------------------------------------
    Not matched                            29
        from master                         0  (_merge==1)
        from using                         29  (_merge==2)

    Matched                                 4  (_merge==3)
    -----------------------------------------

//Only data related to Maldives merged with the previous data set for years 2016-2018
*/

tab _merge, mi

sort country year

edit

drop _merge

order code country year povextrem

save maldives, replace

********************************************************************************
***********************WORLD DEVELOPMENT INDICATORS*****************************
********************************************************************************

/*The main objective of including World Development Indicators is to gain an 
understanding about the measures that have been taken to fight poverty. 
However, I plan to retrieve data only related to health expenditure per capita and literacy rate which I will use to explore relationship with extreme poverty.

Source: 
//https://databank.worldbank.org/reports.aspx?source=world-development-indicators#advancedDownloadOptions
*/

import excel "https://docs.google.com/uc?id=1-CC6tUpRdGrvrEY2o0Kh6Ls0oWcIHzHO&export=download", firstrow clear 

d
summarize

drop if CountryName =="" 

tab CountryName, mi

format %24s CountryName

drop if CountryName=="Afghanistan" //Afghanistan does not have data for many of the variables I want to explore
drop SeriesCode

*RESHAPING the Table*
reshape long YR,  i(CountryName CountryCode SeriesName) j(Year)
rename YR _

*Replacing the variables name by shortening them*
replace SeriesName = "health_exp" if SeriesName == "Current health expenditure per capita (current US$)"

replace SeriesName = "litrate" if SeriesName == "Literacy rate, youth (ages 15-24), gender parity index (GPI)"

//keeping only the desired variables
keep if inlist(SeriesName,"health_exp","litrate") //keeping only literacy rate and health expenditure rate per capita


*RESHAPING the Table*
reshape wide _, i(CountryName Year) j(SeriesName) string

rename _* * //removing the special character in front of the variable//

rename CountryName country
label var country "Country"

rename CountryCode code

rename Year year
label var year "Year" 

sort country year
edit 

//filling the missing data by using ipolate command using several steps

ipolate health_exp year, gen(healthexp) epolate by(country) //filling in health expenditure data

drop health_exp

label var healthexp "Health expenditure per capita"

ipolate litrate year, gen(literacy) epolate by(country) //filling in missing data for literacy
drop litrate

bys country: replace literacy = literacy[_n-1] if literacy >= . //filling in missing data for literacy, which could not be filled by ipolate command

ipolate literacy year, gen(litrate) epolate by(country) //fillinh in missing data for literacy which could not be done by previous command
drop literacy

label var litrate "Literacy Rate"

//Merging previous data with World Bank databank

merge 1:1 country year using maldives
/*
.  merge 1:1 country year using maldives

     Result                      Number of obs
    -----------------------------------------
    Not matched                            16
        from master                         9  (_merge==1)
        from using                          7  (_merge==2)

    Matched                                26  (_merge==3)
    -----------------------------------------

The data for health expenditure starts from 2016 only whereas the extreme poverty data
is for 2015-2019.
*/

tab _merge, mi

sort country year

drop _merge

order code country year povextreme

//filling in missing data for extreme poverty for 2020
ipolate povextreme year, gen(extremepov) epolate by(country) 

drop povextreme

label var extremepov "Extreme Poverty-Earning Below $1.90"
//filling in missing data for health expenditure as there is no data for 2015
ipolate healthexp year, gen(health_exp) epolate by(country) 

drop healthexp

label var health_exp "Health Expenditure Per Capita"

ipolate litrate year, gen(literacy) epolate by(country) //filling in missing data for literacy for 2015  because the world development indicators dataset did not ahve year 2015
drop litrate

label var literacy "Literacy Rate"

save wdi, replace

********************************************************************************
***********************CORRUPTION PERCEPTION INDEX******************************
********************************************************************************


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

import excel "https://docs.google.com/uc?id=1wPDrxSAgP5Gni9xXW5BL6qb9G7wSkKCn&export=download",  cellrange(A3:AH183) firstrow clear

d 

sum

*drop & Keep
keep Country CPIscore2020 CPIscore2019 CPIscore2018 CPIscore2017 CPIscore2016 CPIscore2015


*Keeping only the countries that are required for analysis
keep if inlist(Country,"Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan", "Sri Lanka")

*RESHAPING the wide table 
reshape long CPIscore,  i(Country) j(Year)

rename Year year //to maintain coherence across the datasets
label var year "Year"
rename Country country //to maintain coherence across the datasets


// filling in the missing data
ipolate CPIscore year, gen(cpiscore) epolate by(country)
drop CPIscore
label var cpiscore "Corruption Perception Index Value"


*MERGE
merge 1:1 country year using wdi

/*
. merge 1:1 country year using wdi

    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                                42  (_merge==3)
    -----------------------------------------
	All matched
*/

tab _merge, mi

sort country year

drop _merge

order code country year extremepov

format %10s country

save cpiscore, replace

********************************************************************************
*********************** WORLD HAPPINESS MEASURE. ******************************
********************************************************************************

/* I am highly interested in knowing about the level of happiness of people in 
the considered region. Various indicators are used for the measurement and 
analysis of level of happiness. It will bw interesting to find out if poverty 
and inequality have anything to with the level of happines.

//Additional information can be found at  https://worldhappiness.report/ed/2022/happiness-benevolence-and-trust-during-covid-19-and-beyond/

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
rename Countryname country
label var year "Year"
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
keep if inlist(country,"Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka") & year>=2015


*****MERGE****
merge 1:1 country year using cpiscore
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                            14
        from master                         0  (_merge==1)
        from using                         14  (_merge==2)

    Matched                                28  (_merge==3)
    -----------------------------------------
Bhutan, Maldives, Nepal, Pakistan and Sri Lanka have missing data for various years; therefore, only 28 matched.
*/

tab _merge, mi

drop _merge

order code country year extremepov

format %10s country

//filling in the missing values wth "replace command"
//Source: https://www.stata.com/support/faqs/data-management/replacing-missing-values/

sort country year

bys country: replace liflad = liflad[_n-1] if liflad >= .  //for life ladder
bys country: replace loggdppc = loggdppc[_n-1] if loggdppc >= .  // for log of GDP
bys country: replace socsupp = socsupp[_n-1] if socsupp >= .  //for social support
bys country: replace lifexpbirth = lifexpbirth[_n-1] if lifexpbirth >= .  //for healthy life expectancy at birth
bys country: replace lifechoice = lifechoice[_n-1] if lifechoice >= . // for Freedom to make life choices
bys country: replace generosity = generosity[_n-1] if generosity >= . // for generosity
bys country: replace corrpercep = corrpercep[_n-1] if corrpercep >= . //for perception of corruption
bys country: replace poseffect = poseffect[_n-1] if poseffect >= . //for positive effect
bys country: replace negaffect = negaffect[_n-1] if negaffect >= . //for negative affect


//use of ipolate command to fill in the remaining gaps for Maldives which does not have any data in the start year of 2015, and in which case the above command does not work

ipolate liflad year, gen(lifelad) epolate by(country) //Ladder of Life
drop liflad
label var lifelad "Ladder of Life"

ipolate loggdppc year, gen(loggdp) epolate by(country) //Log of GDP per Capita
drop loggdppc
label var loggdp "Log of GDP per Capita"

ipolate socsupp year, gen(suppsoc) epolate by(country) //Social Support
drop socsupp
label var suppsoc "Social Support"

ipolate lifexpbirth year, gen(birthlifexp) epolate by(country) //Healthy Life Expectancy at Birth
drop lifexpbirth
label var birthlifexp "Healthy Life Expectancy at Birth"

ipolate generosity year, gen(generos) epolate by(country) //Generosity
drop generosity 
label var generos "Generosity"

ipolate lifechoice year, gen(choicelife) epolate by(country) //Freedom to Make Life Choices
drop lifechoice 
label var choicelife "Freedom to Make Life Choices"

//However, Maldives does not have any data for Corruption perception, Positive Effect and Neagtive Effect Variables, so one can see missing values there.


save happiness, replace

********************************************************************************
*****************************  POPULATION    ***********************************
********************************************************************************

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
keep if inlist(location,"Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka") & variant == "Medium" 

rename location country //for consistency across the datasets
label var country "Country"

rename time year //for consistency across the datasets
label var year "Year"

keep country year popmale popfemale poptotal popdensity

keep if year>2014 & year<2021

*****Collapsing to take out the Average*****
collapse popmale popfemale poptotal popdensity, by(country) //The collapse is for calculating the average of the variables under consideration from the time period between 2015-2020.

****labeling****
label var popmale "Average male population (thousands) from 2015-2020"
label var popfemale "Average female population (thousands) from 2015-2020"
label var poptotal "Average total population (thousands) from 2015-2020"
label var popdensity "Average population per square kilometre (thousands) from 2015-2020"

****MERGE(One on Many)******

merge 1:m country using happiness

/*. merge 1:m country using happiness

    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                                42  (_merge==3)
    -----------------------------------------

    -----------------------------------------
*/

edit 

format %10s country

drop _merge 

order code country year

sort country year

save pop, replace


********************************************************************************
***************************** FREEDOM RANKING **********************************
********************************************************************************

/*To what extent a country is free is measured by  the level of Political Rights 
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
rename CountryTerritory country //for consistency across datasets
label var country "Country"

rename Edition year //for consistency across datasets
label var year "Year"

label var PRrating "Political Rights Rating"
label var CLrating "Civil Liberties Rating"

*drop and keep

keep if inlist(country,"Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka") 

drop if year<2015 | year>2020

sort country year 

*MERGE*
merge 1:1 country year using pop

/*
 merge 1:m CountryName Year using happy
(variable CountryName was str30, now str92 to accommodate using data's values)

    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                                42  (_merge==3)
*/

tab _merge

format %10s country

drop _merge

order code country year

save freedom, replace

********************************************************************************
************************** DEATH BY DIFFERENT CAUSES ***************************
********************************************************************************

/*Death by different causes is one of the world's largest health and 
environmental problems. The dataset includes statistics related to unsafe 
water sources, low birth weight child wasting, household pollution from solid
fuels, smoking, outdoor air pollution, unsafe sanitation, and lack of access to 
handwashing  facility. In South Asia, such lacking is rampant, and I want to 
how they are connected to poverty.

*Source:Our World in Data: Death Due to Various Causes
//https://ourworldindata.org/air-pollution
*/

import delimited using "https://docs.google.com/uc?id=1sIxzd5Og0tPVVKt_BA4l7ZvCIeEqxAZh&export=download", varnames(1) clear 

d

sum

*keep*
keep entity code year *unsafewa  *lowbirth *childwas *unsafesa *noaccess *childstu 

//* symbol for short varnames and for spelling mistake minimization

*rename and label
rename entity country
label var country "Country" //for consistency across the datasets

label var year "Year" // for consistency across the datasets


*Selecting South Asian Countries and years 2015 and above
keep if inlist(code,"BGD","BTN","IND","MDV","NPL","PAK","LKA") & year>2014

edit 

******MERGE******

merge 1:1 country year using freedom
/*
(variable country was str48, now str89 to accommodate using data's values)

     Result                      Number of obs
    -----------------------------------------
    Not matched                             7
        from master                         0  (_merge==1)
        from using                          7  (_merge==2)

    Matched                                35  (_merge==3)
    -----------------------------------------
The dataset does not have statistics for the year 2020; therefore, 7 could not match.

*/
tab _merge

sort country year

drop _merge



// filling in the missing data using ipolate command as the data for "dearth by different reasons has data from 2015 to 2019...  We have years from 2015-2020.

ipolate *unsafewa year, gen (unsafewater) epolate by(country) //Unsafe Water
drop *unsafewa 
label var unsafewater "Death due to Unsafe Water"

ipolate *lowbirth year, gen (lowweight) epolate by(country) //Low Weight
drop *lowbirth
label var lowweight "Death due to Low Weight"

ipolate *childwas year, gen (childwaste) epolate by(country) // Wasting
drop *childwas
label var childwaste "Death due to Wasting"

ipolate *unsafesa year, gen (unsafesani) epolate by(country) //Unsafe Sanitation
drop *unsafesa
label var unsafesani "Death due to Unsafe Sanitation"

ipolate *noaccess year, gen (nohandwash) epolate by(country) //Lack of Access to Handwash
drop *noaccess
label var nohandwash "Death due to Lack of Access to Handwashing"

ipolate *childstu year, gen (childstunt) epolate by(country) // Child Stunting
drop *childstu
label var childstunt "Death due to Stunting"

format %10s country

order code country year

save death, replace


********************************************************************************
***************************** UNEMPLOYMENT RATE ********************************
********************************************************************************

/*
Unemployment is supposed to be directly associated with poverty and want. Besides, it has a lot to do with happiness, freedom and corruption. Therefore, I have included the variable to test whether it is really statistically significant. 

Source: Internation Labor Organization(ILO)
https://www.ilo.org/shinyapps/bulkexplorer10/?lang=en&segment=indicator&id=SDG_0852_SEX_AGE_RT_A&ref_area=AFG+BGD+BTN+IND+IRN+MDV+NPL+PAK+LKA&sex=SEX_T+SEX_M+SEX_F+SEX_O&classif1=AGE_YTHADULT_YGE15+AGE_YTHADULT_Y15-24+AGE_YTHADULT_YGE25&timefrom=2010&timeto=2020
*/

import delimited using "https://docs.google.com/uc?id=1iNGnhevPgG3OiI9Jv2jPqVRxlKw1p5j-&export=download", varnames(1) clear 


rename ref_arealabel country
label var country "country"

rename time year
label var year "Year"

rename obs_value unemp_rate


keep if inlist(country,"Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka") & year>=2015
keep country year unemp_rate unemp_rate 

collapse (sum) unemp_rate, by(year country) //collapsing the unemployment rate for particular countries in particular years; necessary because a single year has unemployment rates for various age groups--15, 15-25, and 25+

sort country year

merge 1:1 country year using death 

/*
(variable country was str25, now str89 to accommodate using data's values)

    Result                      Number of obs
    -----------------------------------------
    Not matched                            23
        from master                         0  (_merge==1)
        from using                         23  (_merge==2)

    Matched                                19  (_merge==3)

    -----------------------------------------
Only 19 merged as the number of year related country in unemployment dataset varied. 
*/

sort country year


***Filling missing data
ipolate unemp_rate year, gen (unemploy) epolate by(country) //filling missing data for unemployment data
drop unemp_rate

bys country: replace unemploy = unemploy[_n-1] if unemploy >= .  //For Bhutan which has data for 2015 only 

ipolate unemploy year, gen (unemp_rate) epolate by(country) //filling missing data for unemployment data

label var unemp_rate "Unemployment Rate"

drop  unemploy //as unemp_rate has taken palce of unemploy"

tab _merge

drop _merge

format %10s country

order code country year

encode country, gen(countries) //encoding for graph purpose

save unemployment, replace
*CHECKING Missing Data*

use unemployment, clear
misstable sum 
// the variables corruption perception, positive effect, and negative effect have 6 missing data each.

count if missing(corrpercep, poseffect, negaffect)
// six data for each variable missing-values/

****INSPECTION*****

inspect extremepov
/* extreme poverty data: 42 observations, none are integers and the value ranges from 0.0129 to 14.67391%, no missing values
-------------------------------------------------------------------------------
                                             Total      Integers   Nonintegers
|  #                         Negative            -             -             -
|  #                         Zero                -             -             -
|  #                         Positive           42             -            42
|  #   #                               -----------   -----------   -----------
|  #   #   #                 Total              42             -            42
|  #   #   #   #   #         Missing             -
+----------------------                -----------
.0129224       14.67391                         42
  (42 unique values)
*/

inspect corrpercep 
//Perception of Corruption: 36 non-integers and  and 6 missing values and value ranges fro 0.63 to 0.863 with 27 unique values.

inspect unsafesani 
//Death due to Unsafe Sanitation: 42 unique,positive alues ranging from 2.9627 to 368609.4 .

inspect popmale
//Average male population (in thousands) ranging from 311.6339 to 699332.4; the decimals are due to the average taken previously for merging purpose

inspect health_exp
//Health expenditure per capita ranged from $31.74 to $1008.538

use unemployment, clear //this had to be done as the variable "unemp_rate" disppears

ta childstunt, plot
//all unique values for death due to child stunting

ta popfemale, plot
//seven unqiue values as values for 2015-2020 for each country were collapsed for merging purpose


*****TABLE & TABSTAT Commands*****
tabstat popmale popfemale popdensity poptotal // for population data
/*
   Stats |   popmale  popfem~e  popden~y  poptotal
---------+----------------------------------------
    Mean |  130337.1  122005.3  597.8387  252342.4
--------------------------------------------------
*/

tabstat popmale popfemale popdensity poptotal, by(country) //Population data
/*
Summary statistics: Mean
Group variable: country (Country)

         country |   popmale  popfem~e  popden~y  poptotal
-----------------+----------------------------------------
      Bangladesh |  81257.52  79247.66  1233.043  160505.2
          Bhutan |  397.1093  352.7667    19.673   749.876
           India |  699332.4  646069.4   452.511   1345402
        Maldives |  311.6339  190.7028  1674.456  502.3367
           Nepal |  12757.56  15201.17  195.0382  27958.73
        Pakistan |  108128.1  101980.4  272.5567  210108.4
       Sri Lanka |   10175.3   10995.2  337.5937   21170.5
-----------------+----------------------------------------
           Total |  130337.1  122005.3  597.8387  252342.4
----------------------------------------------------------
*/ 
//Happiness Variables
tabstat lifelad loggdp suppsoc birthlifexp generos choicelife corrpercep poseffect negaffect, by(country) ///
stat(mean sd min max)

tabstat lifelad loggdp suppsoc birthlifexp generos choicelife corrpercep poseffect negaffect, by(country) stat(mean sd min max) nototal long format // Data for certain variables for Maldives are clearly seen lacking

tabstat lifelad loggdp suppsoc birthlifexp generos choicelife corrpercep poseffect negaffect, by(country) stat(mean sd min max) nototal long col(stat) 
//For, Bhutan and Maldives  standard deviations are zero for all the variables because missing values were filled use ipolate and replace commands. Missing values can be clearly observed for Maldives.



**HISTOGRAM**
histogram birthlifexp, by(country)  normal title("Life Expectancy at Birth") // Maldives seems to have the highest life expectancy at birth followed by  Sri lanka, India, Nepal, and Pakistan. 

hist lowweight, by(year country) // India  reduced its proprotion of child death due to low weight from 2015-2020, and it reported the largest average number of deaths among the countries included.

***BAR GRAPHS*****
graph bar lifelad suppsoc generos choicelife extremepov unemp_rate, over(country) bargap(10) intensity(70) ///
    title(Means of Various Variables) legend(order(1 " Life Ladder" 2 "Social Support" 3 "Generosity" 4 "Life Choices" 5 "Extreme Poverty" 6 "Unemployment Rate")) //comparison
// The unemployment rate seems highest in Npal followed by India and Sri Lanka. Extreme poverty is similar between India and Bangladesh, which is higher than in any other country.
	
//combined graphs for Happiness Variables

xtset countries year
/*
Panel variable: countries (strongly balanced)
 Time variable: year, 2015 to 2020
         Delta: 1 unit
*/

//Line Trends for Panel Data
xtline lifelad // showing the trends in Ladder of Life in Various Countries 
graph save lifelad, replace //the countries except  Bhutan and Maldives show fluctuating trends as htese two countries had data for only a certain year, which then had to be ipolated to filling in data for missing years

xtline birthlifexp // showing the trends in healthy life expectancy at birth in various countries
graph save birthlifexp, replace
	
		
xtline loggdp //Log of GDP per capita 
graph save loggdp, replace //It appears that the trends for all the countries except Bhutan and Maldives exhibit upward trends.

xtline suppsoc //social support variable
graph save suppsoc, replace //the trends for countires rise and fall except for Maldives and Bhutan for which data had to be adjusted

xtline generos //generosity variable
graph save generos, replace // Sri Lanka demonstrates a different trend than other countries in terms of generosity, which can be seen declining over the years.

xtline choicelife //Freedom to make choices
graph save choicelife, replace // In Bangladesh, Pakistan, and Sri Lanka, the freedom to make life choices appeared to decline from 2015 to 2020; however, India  shows increasing freedom in terms of making life choices.

graph combine liflad.gph birthlifexp.gph loggdp.gph suppsoc.gph generos.gph choicelife.gph //combination of graphs

//using line chart to compare the extreme poverty among countries from 2015-2020
xtline extremepov, overlay // Bagladesh and India made tremendous improvement in reducing poverty frpm almost 14% to 6%, which can be considered dramatic given the time frame. Nepal and Bhutan made some progess in minimizing the extreme poverty. There is no notewothy change in poverty reduction for other countries. Maldives, it seems, had the lowest extreme poverty level.

xtline extremepov, tlabel(#3) //the above trends for extreme poverty can be seen using this command, but different graphs are displayed for different years.

***LINE CHARTS

quietly regress lifelad generos suppsoc extremepov unemp_rate // regression using life ladder as dependent variable and generosity, social support, extreme poverty and unemployment rate as regressors
predict phat
xtline phat, overlay t(year) i(country) legend(size(medium)) scheme(s2mono) //for journal publishing 
xtline phat, overlay t(year) i(country) legend(size(medium)) scheme(s1color) //for colored lines
// The fitted values for Maldives seems to be the highest; however, the values fluctuate for other countries over the years.

xtline childstunt if inlist(country,"Bangladesh","Bhutan","India","Maldives","Nepal","Pakistan","Sri Lanka"), legend(off)  
//Here, Pakistan followed by India experienced a rapid drop in child death due to stunting.
    
	  
***boxplots

graph box nohandwash, over(country) title(" Death Figures Among Countries")
//The median death figures due to lack of access to handwashing was highest in India followed by Pakistan and Bangladesh. Other countries recorded lowest number of deaths

graph box extremepov, over(country) title(" Extreme Poverty Figures Among Countries") // India had the highest median extreme poverty rate among the countries followed by Bangladesh, Nepal, Pakistan Bhutan, Sri Lanka and Maldives. Pakistan had one data point which is an outlier. 
//finding the relationship between extreme poverty and health expenditure

graph box extremepov, nooutsides over(country) asyvars //has excluded the outlier and labelled the box plots


***Scatter Plots***

scatter extremepov health_exp 
// From the scatter plot, one can observe  negative correlationship between  extremy poverty rate and health expenditure. Now let us use the line of fit.

//Finding relationship between life ladder and social support
twoway scatter lifelad extremepov, by(country) ||lfit lifelad extremepov
// the relationship is inverse in Bangladesh, Nepal, and Paikstan; surprisingly, the correaltionship seems positve for India and Sri Lanka.

scatter extremepov health_exp ||lfit  extremepov health_exp
// It is clear from the graph that as a country increases its health expenditure, its extreme poverty declines.

graph twoway (lfitci extremepov unemp_rate) ///
             (scatter extremepov unemp_rate) ///
			 , ytitle("Extreme Poverty") legend(off)
//The extreme poverty has positive correaltionship with unemployment rate as can be seen from the graph. Many of the values seem to be outliers.
                               
//labelling the countries 
graph twoway (lfitci extremepov unemp_rate) ///
             (scatter extremepov unemp_rate, mlabel(country))
			 
//Adding Titles and legends 
graph twoway (lfitci lifelad extremepov) ///
         (scatter lifelad extremepov, mlabel(country)) ///
         , title("Effect of Extreme Poverty on Life Ladder") ///
          ytitle("Life Ladder") ///
          legend(ring(0) pos(5) order(2 "linear fit" 1 "95% CI")) 
//The graph shows an inverse realtionship between life ladder and extreme poverty. As extreme poverty increases, opportunity to be progess in life declines.

// comparision of effect of unemployment rate and literacy rate on extreme poverty
twoway (scatter extremepov unemp_rate, sort msymbol(smcircle_hollow) ) (lfit extremepov unemp_rate,  saving(g3,replace))

twoway (scatter extremepov literacy, sort msymbol(smcircle_hollow) ) (lfit extremepov literacy),  saving(g4, replace) 

gr combine  g3.gph g4.gph, c(2) iscale(1) saving(g5, replace) //It is clear from the grapsh that increased literacy rate leads to drop in poverty; however, increased unemployment rate causes rise in extreme poverty.

//creation of kernel density graphs for Life Ladder variable; 
forvalues i=1/7 {
       capture drop x`i' d`i'
       kdensity lifelad if countries== `i', generate(x`i'  d`i')
}

gen zero = 0

twoway rarea d1 zero x1, color("blue%50") ///
    ||  rarea d2 zero x2, color("purple%50") ///
    ||  rarea d3 zero x3, color("orange%50")  ///
    ||  rarea d4 zero x4, color("red%50") ///
	||  rarea d5 zero x5, color("khaki%50") ///
	||  rarea d6 zero x6, color("yellow%50") ///
	||  rarea d7 zero x7, color("brown%50") ///
        title(Life Ladder by Countries) ///
       ytitle("Smoothed density") ///
        legend(ring(0) pos(2) col(1) order(1 "Nepal" 2 "Pakistan" 3 "India" 4 "Sri Lanka" 5 "Maldives" 6 "Bhutan" 7 "Bangladesh")) 

/*What is Kernel Density Estimation?
Kernel density estimation extrapolates data to an estimated population probability density function. It's called kernel density estimation because each data point is replaced with a kernel—a weighting function to estimate the pdf. The function spreads the influence of any point around a narrow region surrounding the point.
Source: 
https://www.statisticshowto.com/kernel-density-estimation-2/
*/	

*************************REGRESSIONS******************************************

findit outreg2 

                       *****REGRESSION 1******
 /* The first regression will be about finding the relationship between poverty and human development indicators such as literacy rate and unemployment rate*/

 
reg extremepov literacy, r //running  regression between poverty ratio and literacy rate with poverty ratio as dependent variable
predict yhat1
display _b[literacy]
display _se[literacy]
test literacy
outreg2 using extremepoverty.xls, dec(2) excel e(all) replace
 // line chart for predicted values for extremepov

reg extremepov literacy unemp_rate, r //adding unemployment rate in the mix
outreg2 using poverty.xls, dec(2) excel e(all) append

/*For every one percentage point increase in average literacy rate leads to 3% drop in average extreme poverty rate for South Asian countries. However, the unemployment rate is positively associated with extreme poverty rate, coontrolling for other variables. Nonetheless, the effects are statistically not significant.*/

                      *****REGRESSION 2******
reg lifelad loggdp, r //running  regression between Life Ladder and Log of GDP Per Capita
outreg2 using Happy.xls, dec(3) excel e(all) replace	
// the relationship seems positive but statitically insignificant.	

graph twoway (scatter lifelad loggdp, symbol(d)) (lfit lifelad loggdp) (lfitci lifelad loggdp), title("Effect of Log of GDP  on Life Ladder") subtitle("95% Confidence Bands") // line of fit and twoway linear prediction plots with CIs

//The line of fit is almost horizontal indicating insignificant effect of log of GDP per capita on life ladder.

//Now, other variables are added to regression model

reg lifelad loggdp suppsoc, r // addition of social support as another variable
outreg2 using Happy.xls, dec(3) excel e(all) append

//Here the relationship between life ladder and social support is statitically significant with t-score and robust standard error of 4.03 and 0.913 respecitvely. The beta coefficient is 3.7. Interestingly, the effect of the coefficient of log of GDP per capita became statistically significant with coeff. value of -0.44, controlling for other variables.

/*Combination of Graphs*/
twoway (scatter lifelad loggdp, sort msymbol(smcircle_hollow) ) (lfit lifelad loggdp),  saving(g1,replace) 
twoway (scatter lifelad suppsoc, sort msymbol(smcircle_hollow) ) (lfit lifelad suppsoc),  saving(g2, replace) 
gr combine  g1.gph g2.gph, c(2) iscale(1) saving(g3, replace)

reg lifelad loggdp suppsoc birthlifexp, r // addition of Healthy Life Expectancy at Birth as another independent variable
outreg2 using Happy.xls, dec(3) excel e(all) append
//The effect of healthy life expectancy at birth seems not to be significant.

reg lifelad loggdp suppsoc birthlifexp choicelife, r // addition of Freedom to Make Independent Life Choices as another independent variable
outreg2 using Happy.xls, dec(3) excel e(all) append 
//  Effect of freedom to make life choices is statically significant, controlling for other variables.

reg lifelad loggdp suppsoc birthlifexp choicelife generos, r // addition of Generosity as another independent variable
outreg2 using Happy.xls, dec(3) excel e(all) append
//Generosity also has positive and statistically significant effect on life ladder, holding other variables constant.

reg lifelad loggdp suppsoc birthlifexp choicelife generos poptotal, r //addition of total population as another regressor
outreg2 using Happy.xls, dec(3) excel e(all) append
//Total population does not seem have significant effect on life ladder. however, the healthy life expectancy at birth becomes significant as the additon of the population variable minimizes omitted variable bias.

                             *****REGRESSION 3******
/*This regression will consider whether ratings on political rights and civil liberties affect happiness in the South Asian countries?*/

reg lifelad PRrating, r  //Political Rights rating as independent variable
outreg2 using Freedom.xls, dec(3) excel e(all) replace	

reg lifelad PRrating CLrating, r  //Civic Liberties rating added as another independent variable
outreg2 using Freedom.xls, dec(3) excel e(all) append
//The results show that political rights and civil liberties have statistically significant effects on life ladder.


/******************************************************************************/
/***************************PS5: MACROS & LOOPS********************************/
/******************************************************************************/
use unemployment, clear

d
sum

/**********/
/* macros */
/**********/

local y "Nepal, India Bangladesh Pakistan"
disp "`y'"

local y "Nepal, India, Bangladesh, & Pakistan"
global z " SAARC countries."
disp "`y' are $z"

//Summarizing Variables

local myvars "lifelad loggdp suppsoc birthlifexp choicelife generos "
summarize `myvars'

//describing variables
local myvars "lifelad loggdp suppsoc birthlifexp choicelife generos"
describe `myvars'


//Various ways to carry out regressions using macros
use unemployment, clear
**REGRESSIONS**
codebook countries
ta country, gen(C)
 
gen log_poptotal = ln(poptotal)
reg lifelad                                       extremepov  C2 C3 C4 C5 C6 C7
reg lifelad                        log_poptotal   extremepov  C2 C3 C4 C5 C6 C7
reg lifelad             unemp_rate log_poptotal   extremepov  C2 C3 C4 C5 C6 C7 //Coeff C4 omitted removed due to collinearilty only some of the country dummies are significant; //

loc c C2 C3 C4 C5 C6 C7
reg lifelad                                       extremepov `c'
reg lifelad                        log_poptotal   extremepov `c'
reg lifelad             unemp_rate log_poptotal   extremepov `c'

//combination//
loc c  lifelad
loc c1 extremepov
loc c2 log_poptotal   extremepov
loc c3 unemp_rate log_poptotal   extremepov

reg `c' `c1' `c2' `c3' 

/*********/
/* loops */
/*********/

foreach country in Bangladesh Nepal Pakistan India Maldives Afghanistan Bhutan Sri Lanka {
display "`country'"	
} //Countries in the data

//regression
foreach yvar in unemp_rate log_poptotal extremepov {
reg `yvar' lifelad 
}

//running different models// computing mean and correlation and executing regressions
foreach command in "sum" "corr" "reg" {
`command' lifelad unemp_rate log_poptotal 	
}


// using forvalues command for running regression for each country
forvalues country=1/7 {
    display "`country'"
    reg lifelad extremepov generos
}

//each of values within the variable loops
// running regressions using each of the year in the panel data
tabulate year

levelsof year, local(newvariablename)
foreach x in `newvariablename' {
display "`x'"
reg lifelad extremepov log_poptotal if year==`x'
}

// creating centered variables and squared center variables for  variables related to Happiness Index//
foreach var of varlist lifelad loggdp suppsoc birthlifexp choicelife generos {
  quietly sum `var'
  gen c`var' = `var' - r(mean)  // creating centered variable
  gen c`var'2 = c`var'^2        // creating squared centered variable
}
edit

//generating dta files for each country
codebook countries
levelsof countries, loc(c)
di "`c'"
ls
foreach lev in `c'{
  preserve
  keep if countries==`lev'
save coun`lev',  replace
  restore
}
ls coun*

foreach oldname of varlist *{ //Upper Case Letters for Variable Names
local newname=upper("`oldname'")
rename `oldname' `newname'
}
d 

/*********/
/* nesting */
/*********/


use unemployment, clear

//determining joint-non-missings using nested foreach loops for population parameters
local varlist popmale popfemale poptotal popdensity
        foreach var1 of varlist `varlist ' {
			foreach var2 of varlist `varlist ' {
                   qui count if !missing(`var1 ',`var2 ')
				   local nonmis = round(`r(N) '/_N*100)
				   di "{res}`nonmis'% {txt} of observations are " ///
                    "non-missing for both `var1' & `var2'"
		    }
        }

**Mathematics using nested loops

//addition between male and female population
foreach i of varlist popmale* {
	foreach j of varlist popfemale* {
		gen totalpop = `i'+`j'
		list totalpop
	}
}

//difference between male and female population
foreach i of varlist popmale* {
	foreach j of varlist popfemale* {
		gen popdiff = `i'-`j' 
		list popdiff 
	}
}

use unemployment, clear 

/*using foreach and forvalues in nested loop to find out the summary statistics
for each population variable in each Year
*/
foreach v of varlist pop* {
    forvalues i = 2015/2020 {
		display  "`i'"
        summ `v' if year == `i'
    }
}

//using forvalues for Happiness Parameters to created nested loops
forval i = 2015/2020 {  
    forval j = 1/7 {
		display  "`i'"
        foreach v of var lifelad suppsoc generos {  
            summarize `v' if year == `i' & countries == `j'  
        }  
    }  
} 

//using graphs for regressions
reg lifelad suppsoc //regressing life Ladder on Poverty Ratio
local r2: display %5.2f e(r2)
twoway (lfitci lifelad suppsoc ) (scatter lifelad suppsoc), note(R-squared=`r2')


*************/
/* BRANCHING */
/*************/

d

sum
//summarizing numeric variables and displaying error if the variable is not numeric
foreach var of varlist* {
           capture confirm numeric variable `var'
           if _rc==0 {
             sum `var', meanonly
             replace `var'=`var'-r(mean)
           } 
           else display as error "`var'  cannot have a mean as it is string variable."
         }
sum //

//// Summarizing all double, ds all str, ignore the rest*/ 
foreach var of varlist * {  
     if "`:type `var' '" == "double" {
           sum `var '
      }
      else if substr("`:type `var' '",1,3) == "str" {
             ds `var '
      }
      else { 
      }
}


//Determining joint-non-missingness using nested foreachloops and branching using population parameters//

 foreach var1 of varlist popmale  {
    foreach var2 of varlist popfemale extremepov lifelad {
         local pair `var2 ' `var1 '
          if strpos("`pairs'","`pair'") == 0 {
		  	   qui count if !missing(`var1 ',`var2 ')
			   local nonmis = round(`r(N) '/_N*100)
			   di "{res}`nonmis'% {txt} of observations are " ///
			   "non-missing for both `var1' & `var2'"
			   local pairs `pairs ' `var1 ' `var2 '
		  }   
		  else {
		  }
	}	  
 }

  
//generating means and then dialogues related to the means of the variable
levelsof countries, local(countries)
foreach x of local countries {
     sum lifelad if countries==`x'
         if `r(mean)'>4.7 {
         di "Oh! The mean is above 4.7."
         }
         else {
di "Oh! This is the variable whose mean is at or below 4.7."
         }
}

********************************************************************************
********************PS6: TEXT MANIPULATIONS IN STATA****************************
********************************************************************************
use unemployment, clear 

di upper("this is problem set 6 related to regular expression command.")

//opening first dataset related to World Bank Development Indicators

import excel "https://docs.google.com/uc?id=1-CC6tUpRdGrvrEY2o0Kh6Ls0oWcIHzHO&export=download", firstrow clear 

drop if CountryCode == ""
/***********************/
/* REPLACE */
/***********************/

//relabeling the variables using REPLACE command

replace SeriesName = subinstr(SeriesName,"Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)", "povratio", .)

//doing same with other variables 

replace SeriesName = subinstr(SeriesName,"Access to electricity (% of population)", "elec_acc", .)

replace SeriesName = subinstr(SeriesName,"Adjusted net enrollment rate, primary (% of primary school age children)", "net_enrol", .)

replace SeriesName = subinstr(SeriesName,"Adjusted net savings, excluding particulate emission damage (current US$)", "net_sav", .)

replace SeriesName = subinstr(SeriesName,"Children out of school (% of primary school age)", "child_out", .)


replace SeriesName = subinstr(SeriesName,"Literacy rate, youth (ages 15-24), gender parity index (GPI)", "lit_rate", .)

replace SeriesName = subinstr(SeriesName,"Current health expenditure per capita (current US$)", "health_exp", .)

replace SeriesName = subinstr(SeriesName,"Women making their own informed decisions regarding sexual relations, contraceptive use and reproductive health care  (% of women age 15-49)", "fem_dec", .) //female decision making

replace SeriesName = subinstr(SeriesName,"Unemployment, total (% of total labor force) (national estimate)", "unemp_perc", .)

/***********************/
/* regular expressions */
/***********************/

//Opening the World Bank Development Indicators datasets
import excel "https://docs.google.com/uc?id=1-CC6tUpRdGrvrEY2o0Kh6Ls0oWcIHzHO&export=download", firstrow clear 

drop if CountryCode == ""

gen dev_indic = itrim(SeriesName)
label var dev_indic "Development Indicators"

***************************
/* REGEXCOMMAND        */
***************************
replace dev_indic= regexr(trim(dev_indic),"\([^()]*\)","") //removing content within parenthesis to shorten the variable name (step 1)

replace dev_indic= regexr(trim(dev_indic),"\([^()]*\)","") //removing additonal brackets (step 2)

//shortening the variables using "regexr command" after removing the parenthesis
replace dev_indic= regexr(trim(dev_indic),"Access to electricity","elec_acc")
 
replace dev_indic= regexr(trim(dev_indic),"Adjusted net enrollment rate, primary","net_enrol")

replace dev_indic= regexr(trim(dev_indic),"Adjusted net savings, excluding particulate emission damage","net_sav") 

replace dev_indic= regexr(trim(dev_indic),"Children out of school","child_out") 


replace dev_indic = "Poverty headcount ratio at USD 1.90 a day" if dev_indic == "Poverty headcount ratio at $1.90 a day"
replace dev_indic= regexr(trim(dev_indic),"Poverty headcount ratio at USD 1.90 a day", "pov_ratio")  

replace dev_indic= regexr(trim(dev_indic),"Literacy rate, youth , gender parity index","lit_rate")
 

replace dev_indic= regexr(trim(dev_indic),"Current health expenditure per capita","health_exp") 

 
replace dev_indic= regexr(trim(dev_indic),"Women making their own informed decisions regarding sexual relations, contraceptive use and reproductive health care","fem_dec") 


replace dev_indic= regexr(trim(dev_indic),"Literacy rate, youth , gender parity index","lit_rate") 


replace dev_indic= regexr(trim(dev_indic),"Unemployment, total","unemp_perc") 

format %10s dev_indic

*********************
/*    COUNTING.    */
*********************
count
count if (regexm(SeriesName), "^A") //count the variables starting with the letter A
l in 1/20  if (regexm((SeriesName), "^A"))

drop if (regexm((SeriesName), "^W")) //the women decsion making variable was dropped as it had too few data

use unemployment, clear


/*Conclusion
It appears that both literacy and unemployment  do not have significant effect on extreme poverty. Most possibly other variables are required for identifying whether the effect is significant.

2. The coefficients happiness parameters such as socail support, healthy life expectancy at birth, freedom to make life choices, and generosity weigh significantly on life ladder. The GDP does not have explanatory power on how people think about their lives.

3. Political rights and Civil liberties have significant effect on subjecttive wellbeing. 
*/
