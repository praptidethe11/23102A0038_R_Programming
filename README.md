# R Programming Practical – Air Quality Data Cleaning

**Name:** Prapti Vivek Dethe  
**Course:** R Programming  
**Division:** CMPN-A  
**Batch:** 2  
**Faculty:** Prof. Sanjeev Dwivedi  

**GitHub Repository:**  
https://github.com/praptidethe11/23102A0038_R  

---

## Project Overview

This project implements air quality data cleaning using the **Beijing Multi-Site Air Quality Dataset** in R. It focuses on identifying, summarizing, and treating missing values across pollutant and weather variables.

---

## Dataset and Variables

The dataset initially contained missing values across several variables:

- **Pollutants:** PM2.5, PM10, SO2, NO2  
- **Weather:** TEMP (temperature), WSPM (wind speed)  
- **Categorical:** wd (wind direction)  

A derived variable, `pollution_ratio`, was also created, which introduced additional issues such as `NaN` and infinite values due to division by zero or missing data.

---

## Methodology

### Numerical Variables

- A **`for` loop** with **median imputation** was used to replace missing values in all numerical columns.  
- This approach avoided repetitive code for each variable.

### Categorical Variable (`wd`)

- A custom function, `calculate_mode()`, was implemented to compute and impute the mode for the wind direction variable.

### Derived Variable (`pollution_ratio`)

- Invalid results (`NaN`, `Inf`, `-Inf`) were identified and converted to `NA`.  
- These were then treated using appropriate imputation methods.

### Error Handling

- The `clean_variable()` function was wrapped in `tryCatch()` to handle invalid inputs gracefully, such as:
  - Non-existent columns  
  - Categorical variables passed by mistake  
  - Fully missing columns  

Instead of halting execution, the function returns informative messages.

---

## Results

- A **comparison table** and **bar chart** were generated to show the number of missing values before and after cleaning.  
- After processing, **missing values were reduced to zero** for all selected variables.  
- The resulting dataset is clean and ready for further pollution analysis and modeling.

---

## Files in Repository

- `air_quality_cleaning.R` – Main R script with cleaning logic  
- `cleaned_air_quality_data.csv` – Cleaned dataset  
- `missing_values_comparison.png` – Visualization of missing values before/after  
- `README.md` – Project documentation  

---

## License

This project is licensed under the **MIT License**.
