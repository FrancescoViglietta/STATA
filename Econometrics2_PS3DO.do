 clear all
 set more off
 
 cd "C:\Users\Utente\Desktop\Problem set 3 econometrics 2"


 use "C:\Users\Utente\Desktop\Problem set 3 econometrics 2\PS3.dta" 
 

 
//Part 1
 
 global Z warlag lgdpenlag lpoplag mtnest ncontig oi nwstate instab polity2lag laamcarib ssafrica seasia
  //First LPM regression
 reg war CF $Z
est store first_reg
 
  //Second LPM regression
 reg war ELF $Z
 est store second_reg
 
  //Third LPM regression
 reg war ChiSq $Z
 est store third_reg
 
  //Fourth LPM regression
 reg  war CF ELF ChiSq $Z
 est store fourth_reg
 esttab first_reg second_reg third_reg fourth_reg
 //*for both table1 and table2 we used the STATA option in Statistics>Summaries, tables and tests
//Part 2

  //First Logit
 logit war CF $Z

 margins, dydx(CF) atmeans post
 estimate store marginaleff_firstlog
 scalar sdpartialeff1=-.001291* 3.860123
 display sdpartialeff1
  
  //Second Logit 
  logit war ELF $Z
  
  margins, dydx(ELF) atmeans post
  estimate store marginaleff_secondlog
  scalar sdpartialeff2=- .0002811* 26.33965
  display sdpartialeff2
  //Third Logit
  logit war ChiSq $Z
  margins, dydx(ChiSq) atmeans post
  estimate store marginaleff_thirdlog
  scalar sdpartialeff3=.0058592 *  2.710319 
  display sdpartialeff3
  
  //Fourth Logit 
  logit war CF ELF ChiSq $Z
    
  margins, dydx(*)  atmeans post
  estimate store marginaleff_fourthlog
scalar sdpartialCF= -.003284* 3.860123
scalar sdpartialELF= -.0002933* 26.33965
scalar sdpartialChiSq=  .0088842*2.710319
  display sdpartialCF
  display sdpartialELF
  display sdpartialChiSq
  
  
  summarize CF
  summarize ELF
  summarize ChiSq
  
  
  //Tests
logit war CF ELF ChiSq warlag lgdpenlag lpoplag mtnest ncontig oi nwstate instab polity2lag laamcarib ssafrica seasia
estimate store unres
  //Wald test
  test laamcarib ssafrica seasia
  //Likelihood  ratio test
 logit war CF ELF ChiSq warlag lgdpenlag lpoplag mtnest ncontig oi nwstate instab polity2lag
  lrtest unres
  
 //Q2.4
  
 logit war CF ELF ChiSq warlag lgdpenlag lpoplag mtnest ncontig oi nwstate instab polity2lag laamcarib ssafrica seasia 
 estimate store unres
 
 estat summarize
 matrix list r(stats)
 matrix r=r(stats)
  
  
  
 scalar pr1= logistic(_b[_cons]+_b[CF]*r[2,1]+_b[ELF]*r[3,1]+_b[ChiSq]*r[4,1]+_b[warlag]*r[5,1]+_b[lgdpenlag]*r[6,1]+_b[lpoplag]*r[7,1]+_b[mtnest]*r[8,1]+_b[ncontig]*r[9,1]+_b[oi]*r[10,1]+_b[nwstate]*1+_b[instab]*r[12,1]+_b[polity2lag]*r[13,1]+_b[laamcarib]*r[14,1]+_b[ssafrica]*r[15,1]+_b[seasia]*r[16,1])
 
 scalar pr0= logistic(_b[_cons]+_b[CF]*r[2,1]+_b[ELF]*r[3,1]+_b[ChiSq]*r[4,1]+_b[warlag]*r[5,1]+_b[lgdpenlag]*r[6,1]+_b[lpoplag]*r[7,1]+_b[mtnest]*r[8,1]+_b[ncontig]*r[9,1]+_b[oi]*r[10,1]+_b[nwstate]*0+_b[instab]*r[12,1]+_b[polity2lag]*r[13,1]+_b[laamcarib]*r[14,1]+_b[ssafrica]*r[15,1]+_b[seasia]*r[16,1])
 scalar PEA_nwstate=pr1-pr0
 
 display PEA_nwstate
 
 //Q2.5
 
scalar PEA_ChiSq=_b[ChiSq]*logisticden(_b[_cons]+_b[CF]*r[2,1]+_b[ELF]*r[3,1]+_b[ChiSq]*r[4,1]+_b[warlag]*r[5,1]+_b[lgdpenlag]*r[6,1]+_b[lpoplag]*r[7,1]+_b[mtnest]*r[8,1]+_b[ncontig]*r[9,1]+_b[oi]*r[10,1]+_b[nwstate]*r[11,1]+_b[instab]*r[12,1]+_b[polity2lag]*r[13,1]+_b[laamcarib]*r[14,1]+_b[ssafrica]*r[15,1]+_b[seasia]*r[16,1])

display PEA_ChiSq
