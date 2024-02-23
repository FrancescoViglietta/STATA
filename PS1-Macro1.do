use "C:\Users\Utente\Desktop\PS1 Macroeconomics 1\data_ps1.dta" 
set more off 

mdesc
bysort year: missings report



gen OECD=0
replace OECD=1 if countrycode=="AUS"| countrycode== "GBR"| countrycode=="AUT"| countrycode=="BEL"| countrycode=="CAN"| countrycode=="CHE"| countrycode=="DEU"| countrycode=="DNK"| countrycode=="ESP"| countrycode=="FIN"| countrycode=="FRA"| countrycode=="GBR"| countrycode=="GRC"| countrycode=="IRE"| countrycode=="ISL"| countrycode=="ITA"| countrycode=="JPN"| countrycode=="KOR"| countrycode=="LUX"| countrycode=="MEX"| countrycode=="NLD"| countrycode=="NOR"| countrycode=="NZL"| countrycode=="PRT"| countrycode=="SWE"| countrycode=="TUR"| countrycode=="USA" 

sort country

gen NOIL=1
replace NOIL=0 if country=="Afghanistan"| country=="Bahrain"| country=="Iran"| country=="Iraq"| country=="Kuwait"| country=="Oman"| country=="Saudi Arabia"| country=="Taiwan"| country=="United Arab Emirates"| country=="Yemen"| country=="Cyprus"| country=="Iceland"| country=="Luxembourg"| country=="Malta"| country=="Barbados"| country=="Guyana"| country=="Surinam"| country=="Fiji"| country=="Gabon"| country=="Gambia"| country=="Guinea"| country=="Lesotho"| country=="Swaziland"

generate INTERMEDIATE=1
replace INTERMEDIATE=0 if country=="Angola"|country=="Benin"|country=="Burkina Faso"|country=="Burundi"|country=="Central African Republic"|country=="Chad"|country=="Congo"|country=="Egypt"|country=="Gabon"|country=="Gambia"|country=="Ghana"|country=="Guinea"|country=="Lesotho"|country=="Liberia"|country=="Mauritania"|country=="Mauritius"|country=="Mozambique"|country=="Niger"|country=="Rwanda"|country=="Sierra Leone"|country=="Somalia"|country=="Sudan"|country=="Swatiland"|country=="Togo"|country=="Uganda"|country=="Zaire"|country=="Afghanistan"|country=="Bahrain"|country=="Iran"|country=="Iraq"|country=="Kuwait"|country=="Nepal"|country=="Oman"|country=="Saudi Arabia"|country=="Taiwan"|country=="United Arab Emirates"|country=="Yemen"|country=="Cyprus"|country=="Iceland"|country=="Luxembourg"|country=="Malta"|country=="Barbados"|country=="Guyana"|country=="Surinam"|country=="Fiji"|country=="Papua New Guinea"

//estimating variables of interest
bysort countrycode: generate deltapop= pop-pop[_n-1] 
bysort countrycode: generate popgrowth=deltapop/pop[_n-1]
bysort countrycode: egen N=mean(popgrowth)
bysort countrycode: egen delta_m= mean(delta)
bysort countrycode: egen s_k= mean(sk)
gen G= 0.02
bysort countrycode: generate pop_15_19=pop1519f+pop1519m
bysort countrycode: generate frac_workingagesecS= pop_15_19/pop
bysort countrycode: generate SCHOOL= frac_workingagesecS*sscenrol
bysort countrycode: egen SCHOOL_avg=mean(SCHOOL)

generate lnSCHOOL= ln(SCHOOL_avg)

keep if year=="2016"


// firstregression
bysort countrycode: gen GDPpercapita= cgdpo/pop
generate lnGDPcapita= ln(GDPpercapita)
generate lnIonGDP= ln(s_k)
generate sumofrates = delta_m+G+N
generate lnsumofrates= ln(sumofrates)

regress lnGDPcapita lnIonGDP lnsumofrates if OECD, robust
estimates store firstoecdreg

regress lnGDPcapita lnIonGDP lnsumofrates if NOIL, robust
estimates store firstnonoilreg

regress lnGDPcapita lnIonGDP lnsumofrates if INTERMEDIATE, robust
estimates store firstintermreg

//second regression_sh


regress lnGDPcapita lnIonGDP lnsumofrates lnSCHOOL if OECD, robust
estimates store secondoecdreg

regress lnGDPcapita lnIonGDP lnsumofrates lnSCHOOL if NOIL, robust
estimates store secondnonoilreg

regress lnGDPcapita lnIonGDP lnsumofrates lnSCHOOL if INTERMEDIATE, robust
estimates store secondintermediatereg

//human capital
bysort countrycode: generate lnhumancapital=ln(hc)
regress lnGDPcapita lnIonGDP lnsumofrates lnhumancapital if OECD
estimates store thirdoecdreg

regress lnGDPcapita lnIonGDP lnsumofrates lnhumancapital if NOIL
estimates store thirdnonoilreg

regress lnGDPcapita lnIonGDP lnsumofrates lnhumancapital if INTERMEDIATE
estimates store thirdintermediatereg




estout firstoecdreg firstnonoilreg firstintermreg ,cells("b p" se)

outreg2 firstoecdreg firstnonoilreg firstintermreg