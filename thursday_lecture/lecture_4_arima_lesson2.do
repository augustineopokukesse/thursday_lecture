***************************************************************************
*Project: FORECAST CLOSING PRICE
*Author: Lecturer
*Date: August 19th 2026

*NOTES--------------------------------------------------------------------------
/*
PRIOR ANALYSIS SHOWED THAT MEAN IS STATIONARY OF INTERGRATION 1. IN ADDITION THE
ASSUMPTION OF COVARIANCE STATIONARITY WAS SATISFIED. THE VARIANCE HOWEVER WAS NOT 
STATIONARY, HIGHLIGHTING THAT ONE SHOULD BE CAREFUL IN CALCULATING STANDARD ERRORS 
AROUND ESTIMATES

*FOR THE ARIMA MODEL ONE WILL THEREFORE USE ROBUST STANDARD ERRORS
*/
*END NOTES----------------------------------------------------------------------


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


*************************************************************************
* EVALUATE SOME PLAUSIBLE ARIMA MODELS
* USE RELEVANT INFORMATION FROM PRIOR ANALYSIS ON STATIONARITY
*************************************************************************

pac d.close, lags(20)  title("PAC diagram to help detect AR lags")         // determines AR lags
ac  d.close, lags(20)  title("AC diagram to help detect  MA lags")         // determines MA lags 


*ARIMA(1,1,0)
arima close, arima(1,1,0)  vce(robust)
estimates store arima110


*ARIMA(1,1)
arima close, arima(1,1,1)  vce(robust)
estimates store arima111


*ARIMAX(1,1,0)
arima close volume, arima(1,1,0)  vce(robust)
estimates store arimax110

*ARIMAX(1,1,1)
arima close volume, arima(1,1,1) vce(robust)
estimates store arimax111



/****Ascertain model with the lowest AIC BIC********************************/
estimates stats arima110 arima111 arimax110 arimax111 
*chosen arimax110 based on aic bic criteria


arima close volume, arima(1,1,0)  vce(robust)
estimates store arimax110


*************************************************************************
* ARE THE ESTIMATED ARIMA DYNAMICS STABLE?
*************************************************************************


*STABILITY TESTS
*-AR: Past shocks should have diminishing effects on the future.
*-MA: Distant observations should have diminishing effects when recovering past shocks.

estimates restore arimax110
estat aroots




*MODEL MISSPECIFICATION-RESIDUAL DIAGNOSTICS
estimates restore arimax110
predict ehat, residuals                  // predict the residuals 
tsline ehat                              // visualise the residuals 
corrgram ehat, lags(12)                  // check to make sure there are no patterns in the residual. Null hypothesis is no serial correlation




*************************************************************************
*FORECASTING
*************************************************************************


/**********************/
*IN SAMPLE FORECAST
/**********************/
estimates restore arimax110
predict close_insample_forecast, y
tsline close close_insample_forecast



/**********************/
*FORECAST PERFORMANCE
/**********************/

gen mape = abs((close - close_insample_forecast)/close)*100
summarize mape


/**********************/
*OUT OF SAMPLE FORECAST*
/**********************/


*tsset the data once again and expand the dataset into the forecast horizon
sort date
tsset date_index
tsappend, add(10)

*populate data for volume. This is where you would do the scenario analysis

replace volume = 9000 if date_index  == 249
replace volume = 7000 if date_index  == 250
replace volume = 8000 if date_index  == 251
replace volume = 7500 if date_index  == 252
replace volume = 10000 if date_index == 253
replace volume = 8000 if date_index  == 254
replace volume = 6000 if date_index  == 255
replace volume = 8500 if date_index  == 256
replace volume = 9500 if date_index  == 257
replace volume = 9800 if date_index  == 258




*Finally forecast out of sample

estimates restore arimax110
predict close_outsample_forecast, y dynamic(249)  // forecast of central path starting at the 249th observation                          


/**********************/
*VISUALISE THE FORECAST*
/**********************/


twoway (line  close date_index if date_index < 249, lcolor(black)) ///
       (line  close_outsample_forecast date_index if date_index >= 249, lcolor(blue) lwidth(medthick))
	
exit
  
   

NOTES_______________________________________________________________________________________________________________




*Note: Example of SARIMAX
arima close volume range, arima(1,1,1) sarima(1,1,1,12)
