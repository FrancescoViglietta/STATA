clear all

use "C:\Users\Utente\Desktop\Econometrics 1 problem set 2\ex1_group20.dta" 

*================ Question 1================*
reg lwage union


reg lwage union educ age



gen edu9_13=0
replace edu9_13=1 if educ>=9 & educ<=13


gen edu14_16=0
replace edu14_16=1 if educ>=14 & educ<=16

gen edu17_18=0
replace edu17_18=1 if educ>=17 

reg lwage union edu9_13  edu14_16 edu17_18 age

gen agesq= age*age
reg lwage union educ age agesq


tabstat age, stat(p50, mean)
di _b[age]+2*_b[agesq ]*(36.54444)
di _b[age]+2*_b[agesq ]*(34)


test  age agesq
di _b[age]+2*_b[agesq ]*(30)
di _b[age]+2*_b[agesq ]*(40)
di _b[age]+2*_b[agesq ]*(50)

twoway scatter lwage age || lfit lwage age || qfit lwage age, legend(order(1 "Linear" 2 "Quadratic"))



reg lwage union educ age agesq
estat hettest                 
estat imtest, white


*================ Question 2================*

//T


clear all




capture log close

use "C:\Users\Utente\Desktop\Econometrics 1 problem set 2\ex2_group20.dta" 

//2.1 
eststo Model1: reg breastfeed_mths d_male bord 	 current_age current_age_sqr d_educ2 d_educ3 d_educ4 d_educ5 rural age_child
keep if e(sample) == 1

//Testing for heteroskedasticity
estat hettest
estat imtest, white

//2.2
// reg breastfeed_mths i.d_male##i.bord current_age current_age_sqr d_educ2 d_educ3 d_educ4 d_educ5 rural age_child	//categorical bord
eststo Model2: reg breastfeed_mths i.d_male##c.bord current_age current_age_sqr d_educ2 d_educ3 d_educ4 d_educ5 rural age_child, robust	//continuous bord. I think this is correct

test 1.d_male#c.bord

di "The marginal effect of being male for the first child:  "  _b[1.d_male] + _b[1.d_male#c.bord] * 1
di "The marginal effect of being male for the first child (Ignoring the interaction term):  "  _b[1.d_male]


//2.3	
//I consider The simple model 2 in 2.1 not in 2.2.
gen bord_sqr = bord * bord
eststo Model3: reg breastfeed_mths d_male bord bord_sqr current_age current_age_sqr d_educ2 d_educ3 d_educ4 d_educ5 rural age_child, robust
test bord_sqr		//Null is rejected. So include bord^2

//Trying to visualize the data, linearity and quadradicity!
twoway scatter breastfeed_mths bord || lfit breastfeed_mths bord|| qfit breastfeed_mths bord, ///
legend(order(2 "Linear"  3 "Quadratic")) ///
graphregion(color(white)) 


//2.4
//The model is in the pdf file.

//2.5
eststo Model4: reg breastfeed_mths i.d_male##c.prevsons_frac current_age current_age_sqr d_educ2 d_educ3 d_educ4 d_educ5 rural age_child, robust

// esttab Model1 Model2 Model3 Model4

di _b[1.d_male] + _b[1.d_male#prevsons_frac] * (100 / 100)
lincom _b[1.d_male] + _b[1.d_male#prevsons_frac] * (100 / 100) // Should we use lincome here?

di _b[1.d_male] + _b[1.d_male#prevsons_frac] * (50 / 100)
lincom _b[1.d_male] + _b[1.d_male#prevsons_frac] * (50 / 100)


//2.6	
lincom (_b[1.d_male] + _b[1.d_male#prevsons_frac] * (100 / 100) ) - ( _b[1.d_male] + _b[1.d_male#prevsons_frac] * (50 / 100) )
test (_b[1.d_male] + _b[1.d_male#prevsons_frac] * (100 / 100) ) = ( _b[1.d_male] + _b[1.d_male#prevsons_frac] * (50 / 100) )


//2.7
// Chow-test :

reg breastfeed_mths d_male prevsons_frac current_age current_age_sqr d_educ2 d_educ3 d_educ4 d_educ5 age_child if rural == 1, robust	//Should I include rural?
scalar rss1 = e(rss)
scalar n1 = e(N)
reg breastfeed_mths d_male prevsons_frac current_age current_age_sqr d_educ2 d_educ3 d_educ4 d_educ5 age_child if rural == 0, robust	//Should I include rural?
scalar rss2 = e(rss)
scalar n2 = e(N)
reg breastfeed_mths d_male prevsons_frac current_age current_age_sqr d_educ2 d_educ3 d_educ4 d_educ5 age_child, robust
scalar rsst = e(rss)
scalar k = e(rank)

* Compute test statistic
display "F-stat = " [(rsst-rss1-rss2)/k] / [(rss1+rss2)/(n1+n2-2*k)]
display "p-value = " Ftail(k, n1+n2-2*k, [(rsst-rss1-rss2)/k] / [(rss1+rss2)/(n1+n2-2*k)])

//2.8

esttab Model1 Model2 Model3 Model4 using "esttab.tex", replace ///
star(* 0.10 ** 0.05 *** 0.01) b(a3) se(3) nonum nogaps ///
stats(N F r2, fmt(0 3) labels("Observations" "F-stat")) ///
mtitles("Model 1" "Model 2" "Model 3" "Model 4") ///
drop (current_age current_age_sqr d_educ2 d_educ3 d_educ4 d_educ5 age_child) ///
se /// // to show SEs and not t-stat
varlabel(breastfeed_mths "Breastfeeding duration" /// //
		 d_male "Male" ///
		 bord "Birth order" ///
		 bord_sqr "Birth order ^ 2" ///
		 rural "Rural resident" ///
		 prevsons_frac "Male fraction in older siblings" ///
		 _cons "Constant") ///
prehead("\begin{table}[htbp]" /// // modify your table as you want before saving it!
		"\caption{Question 2 Table \label{bwght}}" ///
		"\centering \renewcommand*{\arraystretch}{1.2}\scalefont{}" /// 
		"\begin{threeparttable}" /// 
		"\resizebox{380}{!}{%" ///
		"\begin{tabular}{l*{4}{c}}" ///
		"\hline") ///
prefoot("\hline" ///
		"Number of Controls & 8 & 8 & 8 & 8\\") ///
postfoot("\hline \hline" /// 
		"\end{tabular}%" ///
		"}" ///
		"\begin{tablenotes} \footnotesize" /// 
		"\item Note: (1), (2) and (3) robust std. errors at district level in parentheses. * \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)" ///
		"\end{tablenotes}" ///
		"\end{threeparttable}" ///
		"\end{table}")
		
		
log close








