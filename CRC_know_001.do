

cls

*	============================================================================
*					The University of the West Indies
*
*	Title:			Knowledge_Paper.do
*	Created Date:	08/11/2018
*	Author:			Kern Rocke
*	Dataset:		Knowledge_Paper_v1_2018_11_04.dta
*	Purpose:		Regression Models for Knowledge Paper
*	Last modfied:	08/11/2018
*	
*	============================================================================


*	============
*	1. SETUP
*	============

version 13
clear all
clear matrix
capture clear all
capture log close
clear all
macro drop _all
numlabel, add

set more 10
set seed 2581240
set linesize 250


*-------------------------------------------------------------------------------

* Load dataset and open log file
global data "$G:\Statistical Data Anlaysis\2018\Knowledge_CC_Study\Data"
global log "$G:\Statistical Data Anlaysis\2018\Knowledge_CC_Study\Results\Knowledge_Regression_Results"
cd "G:\Statistical Data Anlaysis\2018\Knowledge_CC_Study"
log using "Results\Knowledge_Regression_Results", replace
use "Data\Knowledge_Paper_v1_2018_11_04.dta", clear


/* GENERAL NOTES FOR ANALYSIS

* 	CRC Risk Factor knowledge paper

* Tables 4

Table 1- Sociodemographics and lifestyle characteristics of study population

Table 2- Knowledge questions frequency and percentage

Table 3- Linear regression models

Table 4- Logistic regression models

*/

** Create single FACTOR variable for all family history of cancer 
gen cancer_type = .
replace cancer_type = 1 	if fambc==1  	
replace cancer_type = 2 	if fampc==1 	
replace cancer_type = 3 	if famcc==1  	
replace cancer_type = 4 	if famcecc==1  	
replace cancer_type = 5 	if famlc==1
replace cancer_type = 0 	if famno==1 

label define cancer_type	0 "None" 2 "Prostate Cancer" 1 "Breast Cancer" 	///
							3 "Colon/Rectal/Anal Cancer" 5 "Bronchus & Lung Cancer" ///
							4 "Cervical Cancer", modify
					
label values cancer_type cancer_type
label var cancer_type "Cancer type"

gen cancer= cancer_type
recode cancer (1/max=1)
label var cancer "Family history of cancer"
label define cancer 0"No cancer" 1"Cancer"
label value cancer cancer


/// Regression Models

regress perknoscore i.sex i.agegrps i.levofstu i.knoanycc , vce(robust)

regress perknoscore i.smokerisksco , vce(robust)
regress perknoscore i.freqsco11 , vce(robust)
regress perknoscore i.totphy , vce(robust)
regress perknoscore i.smokerisksco i.freqsco11 i.totphy, vce(robust)

regress perknoscore i.sex i.agegrps i.rateheal i.riskcc , vce(robust)

regress perknoscore fried_meat , vce(robust)
regress perknoscore prudent , vce(robust)
regress perknoscore dairy_bread , vce(robust)
regress perknoscore fried_meat  prudent dairy_bread , vce(robust)
regress perknoscore i.sex fried_meat  prudent dairy_bread , vce(robust)
regress perknoscore i.sex i.agegrps fried_meat  prudent dairy_bread , vce(robust)

///	Forward stepwise linear regression model
stepwise, pe(.2): regress perknoscore levofstu cancer sex agegrps fried_meat prudent dairy_bread smokerisksco freqsco11 totphy rateheal riskcc
*-------------------------------------------------------------------------------

/// Creating exccel file to store regressio results
putexcel set "Regression Results.xlsx", sheet("Regression results") replace


//Model 1- Sociodemographic Model
regress perknoscore i.sex i.agegrps i.levofstu i.knoanycc , vce(robust)
putexcel set "Regression Results.xlsx", sheet("Linear Model 1") modify
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F")             G2=(e(F))
putexcel E3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel E4=("R-squared")     G4=(e(r2))
putexcel E5=("Adj R-squared") G5=(e(r2_a))
putexcel E6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)
matrix a = a[.,1..10]
putexcel A8=matrix(a, names)

//Model 2- Lifestyle Model
regress perknoscore i.sex i.agegrps i.smokerisksco i.freqsco11 i.totphy, vce(robust)
putexcel set "Regression Results.xlsx", sheet("Linear Model 2") modify
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F")             G2=(e(F))
putexcel E3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel E4=("R-squared")     G4=(e(r2))
putexcel E5=("Adj R-squared") G5=(e(r2_a))
putexcel E6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)
matrix a = a[.,1..12]
putexcel A8=matrix(a, names)

//Model 3- Perceived Health Model
regress perknoscore i.sex i.agegrps i.rateheal i.riskcc , vce(robust)
putexcel set "Regression Results.xlsx", sheet("Linear Model 3") modify
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F")             G2=(e(F))
putexcel E3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel E4=("R-squared")     G4=(e(r2))
putexcel E5=("Adj R-squared") G5=(e(r2_a))
putexcel E6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)
matrix a = a[.,1..12]
putexcel A8=matrix(a, names)

//Model 4- Dietary Model
regress perknoscore i.sex i.agegrps fried_meat  prudent dairy_bread , vce(robust)
putexcel set "Regression Results.xlsx", sheet("Linear Model 4") modify
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F")             G2=(e(F))
putexcel E3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel E4=("R-squared")     G4=(e(r2))
putexcel E5=("Adj R-squared") G5=(e(r2_a))
putexcel E6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)
matrix a = a[.,1..9]
putexcel A8=matrix(a, names)

//Model 5- Final Model
regress perknoscore i.sex i.riskcc i.freqsco11 i.totphy i.smokerisksco prudent, vce(robust)
putexcel set "Regression Results.xlsx", sheet("Linear Model 5") modify
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F")             G2=(e(F))
putexcel E3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel E4=("R-squared")     G4=(e(r2))
putexcel E5=("Adj R-squared") G5=(e(r2_a))
putexcel E6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)
matrix a = a[.,1..13]
putexcel A8=matrix(a, names)

*-------------------------------------------------------------------------------
/* LOGISTIC REGRESSION ANALYSIS

Create Categorization for knowledge scores

Use the following categorizations: 
<50% and >/=50%
*/

gen kno_cat= perknoscore
recode kno_cat (min/49.9999=1) (50/max=0)
label var kno_cat "Knowledge Scores Category"
label define kno_cat 1"<50%=Poor" 0">/=50%-Good"
label value kno_cat kno_cat

*Frequency distribution of categorized variable
tab kno_cat
tab kno_cat sex, row chi2

///Logistic Regression Models

///Sociodemographic Models
logistic kno_cat i.sex, vce(robust)
logistic kno_cat i.agegrps, vce(robust)
logistic kno_cat i.levofstu, vce(robust)
logistic kno_cat i.knoanycc, vce(robust)

logistic kno_cat i.sex i.agegrps i.levofstu i.knoanycc, vce(robust)


///Lifestyle Models
logistic kno_cat i.smokerisksco, vce(robust)
logistic kno_cat i.freqsco11, vce(robust)
logistic kno_cat i.totphy, vce(robust)

logistic kno_cat i.smokerisksco i.freqsco11 i.totphy, vce(robust)
logistic kno_cat i.sex i.agegrps i.smokerisksco i.freqsco11 i.totphy, vce(robust)


///Dietary Models
logistic kno_cat fried_meat, vce(robust)
logistic kno_cat prudent, vce(robust)
logistic kno_cat dairy_bread, vce(robust)

logistic kno_cat fried_meat prudent dairy_bread, vce(robust)
logistic kno_cat i.sex i.agegrps fried_meat prudent dairy_bread, vce(robust)


///Perceived Health Models
logistic kno_cat i.rateheal, vce(robust)
logistic kno_cat i.riskcc, vce(robust)

logistic perknoscore i.sex i.agegrps i.rateheal i.riskcc , vce(robust)

///	Forward stepwise linear regression model
stepwise, pe(.2): logistic kno_cat levofstu cancer sex agegrps fried_meat prudent dairy_bread smokerisksco freqsco11 totphy rateheal riskcc

*-------------------------------------------------------------------------------

///Sociodemographic Models

logistic kno_cat i.sex i.agegrps i.levofstu i.knoanycc, vce(robust)
putexcel set "Regression Results.xlsx", sheet("Log Model 1") modify
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F")             G2=(e(F))
putexcel E3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel E4=("R-squared")     G4=(e(r2))
putexcel E5=("Adj R-squared") G5=(e(r2_a))
putexcel E6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)
matrix a = a[.,1..10]
putexcel A8=matrix(a, names)


///Lifestyle Models

logistic kno_cat i.sex i.agegrps i.smokerisksco i.freqsco11 i.totphy, vce(robust)
putexcel set "Regression Results.xlsx", sheet("Log Model 2") modify
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F")             G2=(e(F))
putexcel E3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel E4=("R-squared")     G4=(e(r2))
putexcel E5=("Adj R-squared") G5=(e(r2_a))
putexcel E6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)
matrix a = a[.,1..12]
putexcel A8=matrix(a, names)


///Perceived Health Models

logistic perknoscore i.sex i.agegrps i.rateheal i.riskcc , vce(robust)
putexcel set "Regression Results.xlsx", sheet("Log Model 3") modify
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F")             G2=(e(F))
putexcel E3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel E4=("R-squared")     G4=(e(r2))
putexcel E5=("Adj R-squared") G5=(e(r2_a))
putexcel E6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)
matrix a = a[.,1..12]
putexcel A8=matrix(a, names)


///Dietary Models
logistic kno_cat i.sex i.agegrps fried_meat prudent dairy_bread, vce(robust)
putexcel set "Regression Results.xlsx", sheet("Log Model 4") modify
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F")             G2=(e(F))
putexcel E3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel E4=("R-squared")     G4=(e(r2))
putexcel E5=("Adj R-squared") G5=(e(r2_a))
putexcel E6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)
matrix a = a[.,1..9]
putexcel A8=matrix(a, names)


//Final Model
logistic kno_cat i.sex prudent dairy_bread i.freqsco11 i.totphy i.smokerisksco i.riskcc, vce(robust)
putexcel set "Regression Results.xlsx", sheet("Log Model 5") modify
putexcel E1=("Number of obs") G1=(e(N))
putexcel E2=("F")             G2=(e(F))
putexcel E3=("Prob > F")      G3=(Ftail(e(df_m), e(df_r), e(F)))
putexcel E4=("R-squared")     G4=(e(r2))
putexcel E5=("Adj R-squared") G5=(e(r2_a))
putexcel E6=("Root MSE")      G6=(e(rmse))
matrix a = r(table)
matrix a = a[.,1..14]
putexcel A8=matrix(a, names)



///Closing log file
log close



