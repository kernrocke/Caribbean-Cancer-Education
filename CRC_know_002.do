
clear
capture log close
cls


**  DO FILE META-DATA
**  Program:		CRC_know_002.do
**  Project:      	CRC Risk Factor Study
**	Sub-Project:	CRC Risk Perception and Knowledge (ICEC 2020 Conference)
**  Analyst:		Kern Rocke
**	Date Created:	14/06/2020
**	Date Modified: 	14/06/2020
**  Algorithm Task: Analysis for ICEC 2020 Conference Data


** DO-FILE SET UP COMMANDS
version 13
clear all
macro drop _all
set more 1
set linesize 150

*Setting working directory
** Dataset to folder location
local datapath "/Users/kernrocke/Documents/Statistical Data Anlaysis/2018"

*Load in Dataset
use "`datapath'/Knowledge_CC_Study/Data/Knowledge_Paper_v1_2018_11_04.dta", clear

*riskcc knoscore perknoscore

*Create Knowledge Scores Categories
gen kno_cat = .
replace kno_cat = 0 if perknoscore >= 50
replace kno_cat = 1 if perknoscore < 50
label var kno_cat "Knowledge Score Categories"
label define kno_cat 1"Low knowledge" 0"Knowledgeable"
label value kno_cat kno_cat

*Creat new risk perception variable
gen riskcc_cat = .
replace riskcc_cat = 1 if riskcc >0 // Low or high risk
replace riskcc_cat = 0 if riskcc ==0
label var riskcc_cat "CRC Risk Perception"
label define riskcc_cat 0"No risk" 1"Risk"
label value riskcc_cat riskcc_cat

*Prevalence estimates for crc perception and knowledge
proportion riskcc_cat
proportion kno_cat

*Differences between independant factors and knowledge
ranksum totphy, by(kno_cat)
ranksum western, by(kno_cat)
ranksum prudent, by(kno_cat)
ranksum smokerisksco, by(kno_cat)
ranksum freqsco11, by(kno_cat)

ttest totphy, by(kno_cat)
ttest western, by(kno_cat)
ttest prudent, by(kno_cat)
ttest smokerisksco, by(kno_cat)
ttest freqsco11, by(kno_cat)

*Differences between independant factors and cancer risk perception
ranksum totphy, by(riskcc_cat)
ranksum western, by(riskcc_cat)
ranksum prudent, by(riskcc_cat)
ranksum smokerisksco, by(riskcc_cat)
ranksum freqsco11, by(riskcc_cat)

ttest totphy, by(riskcc_cat)
ttest western, by(riskcc_cat)
ttest prudent, by(riskcc_cat)
ttest smokerisksco, by(riskcc_cat)
ttest freqsco11, by(riskcc_cat)

*Chi-Square Associations
tab kno_cat riskcc, chi2
tab kno_cat riskcc_cat, chi2

*Bivariable logistic regression
logistic kno_cat i.riskcc, vce(robust) cformat(%9.2f)
logistic riskcc_cat i.kno_cat, vce(robust) cformat(%9.2f)

*Multivariable logistic regression
logistic riskcc_cat ib1.kno_cat sex agegrps totphy ccavg western ///
		 prudent smokerisksco freqsco11, vce(robust) cformat(%9.2f)
