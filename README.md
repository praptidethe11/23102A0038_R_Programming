Name        : Prapti Vivek Dethe
Course      : R Programming
Division    : CMPN-A
Batch       : 2
Faculty     : Prof. Sanjeev Dwivedi

GitHub Repository Link: https://github.com/praptidethe11/23102A0038_R

Interpretation (100-150 words):

The Beijing air-quality station dataset initially contained missing values 
across several pollutant and weather variables such as PM2.5, PM10, SO2, 
NO2, TEMP and WSPM, along with some missing entries in the categorical 
wind-direction variable (wd). Using a for loop combined with median 
imputation, all numerical missing values were replaced without writing 
repetitive code for each column, while the calculate_mode() function 
handled the categorical wd variable. Invalid results in the derived 
pollution_ratio variable - including NaN and infinite values caused by 
division by zero or missing data - were also identified and converted to 
NA before treatment. The clean_variable() function, protected with 
tryCatch(), ensured that invalid inputs (non-existent columns, categorical 
variables passed by mistake, or fully-missing columns) produced 
informative messages instead of halting execution. The comparison table 
and bar chart confirm that missing values were reduced to zero for all 
selected variables, producing a clean dataset suitable for further 
pollution analysis.
