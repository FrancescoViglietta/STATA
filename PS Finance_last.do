clear all
use "C:\Users\FrancescoViglietta\Downloads\Bonds (2).dta" 

//Here we generate all the variables of interest that we want to use for our analysis
generate green_bond=0
replace  green_bond=1 if greenbond=="Yes"
 
gen green_yield=yieldtomaturity if green_bond==1
gen brown_yield=yieldtomaturity if green_bond==0
 
generate date2 = date(issuedate, "DM20Y")

format date2 %td

generate year = year(date2)

generate month = month(date2)

generate ymdate = ym(year, month)

encode (issuerticker), generate(Issuer_Ticker)
encode (isin), gen(ISIN)
encode (issuedate), gen(Issue_Date)
encode (maturity), gen(Maturity)
encode (sector), gen(Sector)
encode (countryofissue), gen(Country)
encode (principalcurrency), gen(Principalcurrency)
encode (seniority), generate (Seniority)
gen yieldon100 = yieldtomaturity/100
gen ln_YTM= ln(yieldtomaturity)
gen couponon100= coupon/100
gen ln_Coupon= ln(couponon100)

generate date3 = date(maturity, "DM20Y")
format date3 %td
generate year0 = year(date3)
generate month0 = month(date3)
generate ymdate0 = ym(year0, month0)
generate timetomaturity = ymdate0 - ymdate
tab countryofissue


//Drop yield to maturity outliers
cumul yieldtomaturity, generate(freq) eq
drop if freq >.99
drop if freq <.01

//Here we drop all obs with dummy mean equal to 1 or 0, in order to keep only issuers which have issued both brown and green bonds. 
bysort Issuer_Ticker: egen mean_dummy = mean(green_bond)
drop if mean_dummy == 1 
drop if mean_dummy == 0


//Summary statistics
tab year green_bond

summarize green_yield
summarize brown_yield
graph box green_yield brown_yield



//graph box yieldtomaturity, over(green_bond)
//graph box green_yield brown_yield

drop if yieldtomaturity==.
duplicates report issuerticker ISIN
duplicates drop issuerticker ISIN, force
//graph box green_yield brown_yield



xtset Issuer_Ticker ISIN
xtsum  coupon timetomaturity amountissuedusd if green_bond == 1
xtsum coupon timetomaturity amountissuedusd if green_bond == 0

xtreg ln_YTM green_bond i.Principalcurrency amountissuedusd  i.Seniority i.ymdate, fe robust
est store fe1

xtreg ln_YTM green_bond  amountissuedusd, fe robust
est store fe2

reg ln_YTM green_bond ln_Coupon  i.Seniority i.Principalcurrency amountissuedusd i.ymdate, robust
est store ols1

ssc install psmatch2
global X ln_Coupon Principalcurrency Country amountissuedusd Seniority Sector 
global Y yieldtomaturity
psmatch2 $treatment $X, outcome($Y)
logit 
drop if _weight==.
gen WM, by (green_bond)

ttest WM, by (green_bond)

 esttab fe1 fe2 ols1 using "Table6.tex", se title("Regression coefficients and significance levels") keep(green_bond ln_Coupon i.Principalcurrency amountissuedusd i.Seniority i.ymdate) nonumbers stats(N, labels("Observations")) mtitles("Fully specified FE" "Underspecified FE" "Pooled OLS") star(* 0.10 * 0.05 ** 0.01) ///
 varlabel(green_bond "Green bond" ///
                 ln_Coupon "log of the Coupon" ///
                 i.Principalcurrency "Currency" ///
                 amountissuedusd "Amount issued" ///
                 i.Seniority "Seniority" ///
                 i.ymdate "Year-by-month" ///
                 _cons "constant")

