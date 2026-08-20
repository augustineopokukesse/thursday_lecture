***************************************************************************
*Project: FORECAST CLOSING PRICE
*Author: Lecturer
*Date: August 19th 2026
***************************************************************************

*******************************************
*CLEAR THE WORKSCREEN AND WORKSPACE
*******************************************

cls
clear all 

*******************************************
*LOAD THE SP500 DATASET 
******************************************

sysuse sp500, clear


*******************
*TSSET THE DATA
*******************

sort date
gen date_index  = _n
tsset date_index

*******************************
* AFFIRM OUTCOME OF INTEREST
*******************************

gen o_close = d.close
label var o_close "Outcome Close"


*************************************************************************
* EVALUATE THE STATIONARITY ASSUMPTION FOR OUTCOME OF INTEREST
*************************************************************************



/**********************Rolling Mean**************************************/

tssmooth ma o_close_ma = o_close, window(59 1 0)
replace o_close_ma = . if _n < 60
label var o_close_ma "Roll Mean Close"

tsline o_close o_close_ma, name(o_roll_mean, replace) yscale(range(0 .)) title("Closing Price with Rolling Mean") legend(off)

tabstat o_close, statistics(mean)
summarize o_close_ma


/**********************Rolling Variance**************************************/

*ssc install rangestat
rangestat (variance) o_close, interval(date -59 0)
replace o_close_var = . if _n < 60
gen o_close_sd = sqrt(o_close_variance)
label var o_close_sd "Roll SD Close"

tsline o_close, yaxis(1) || tsline o_close_sd, yaxis(2) , name(o_roll_variance, replace)  title("Closing Price with Rolling Variance") legend(off)


tabstat o_close, statistics(sd)
summarize o_close_sd




/**********************Covariance Stationarity********************************/

ac close, lags(12)
ac close if date < mdy(6,1,2001), name(ac1, replace) lags(12) title("AC: First Half Data")
ac close if date > mdy(6,1,2001), name(ac2, replace) lags(12) title("AC: Second Half Data")



*************************************************************************
* GRAPH ALL STATIONARITY TESTS TOGETHER TO FACILITATE EVALUATION
*************************************************************************

graph combine ac1 ac2 o_roll_mean o_roll_variance, cols(2) imargin(small)



*************************************************************************
* RUN FORMAL STATIONARITY TESTS
*************************************************************************

*how robust is our stationarity dfuller tests?
dfuller o_close, lags(1)
dfuller o_close, lags(2)
dfuller o_close, lags(3)
dfuller o_close, lags(4) 
dfuller o_close, lags(5)
dfuller o_close, lags(6)
dfuller o_close, lags(7)
dfuller o_close, lags(8)  
dfuller o_close, lags(9)
dfuller o_close, lags(10)
dfuller o_close, lags(11)
dfuller o_close, lags(12)   


*how robust is our stationarity pperon tests?
pperron o_close, lags(1)
pperron o_close, lags(2)
pperron o_close, lags(3)
pperron o_close, lags(4)
pperron o_close, lags(5)
pperron o_close, lags(6)
pperron o_close, lags(7)
pperron o_close, lags(8)  
pperron o_close, lags(9)
pperron o_close, lags(10)
pperron o_close, lags(11)
pperron o_close, lags(12) 




	
exit
  
   

NOTES_______________________________________________________________________________________________________________



