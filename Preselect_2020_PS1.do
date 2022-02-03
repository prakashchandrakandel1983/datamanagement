//read carefully ps insytrusctions!! eg need to save in 3 diff forats!

* This dofile is associated with the voting patterns in the 2020 Presidential Election in 2020 across municipalities in New Jersey. I will be using the related data set to find out the relationship between adoption of Marijuana Law across municipalities and voting patterns.
version 16 //a;lways say which version; can also give your name etc
clear all
//always specify data source
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
//list, sepby(County) //did not work

*list County 1/10 did not work

d
sum

clear all
exit 
//need to read ps carefully; didnt save in 3 different formats; abd should have used 2 different datasets to begin with
