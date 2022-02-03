* This dofile is associated with the voting patterns in the 2020 Presidential Election in 2020 across municipalities in New Jersey. I will be using the related data set to find out the relationship between adoption of Marijuana Law across municipalities and voting patterns.

clear all

import excel using "https://docs.google.com/uc?id=1FP-RfK3nxA_PPvC6ng4ZlchsViWptlUV&export=download", firstrow

rename J Biden_Percent
rename K Trump_Percent

label var Biden_Percent "Percentage of votes secured by Biden in 2020 Election"
label var Trump_Percent "Percentage of votes secured by Trump in 2020 Election"

sample 25
count
edit
browse
edit Biden

*list sepby(Municipality) did not work

*list County 1/10 did not work

d
sum

clear all
exit 
