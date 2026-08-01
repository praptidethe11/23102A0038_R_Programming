########################################################################
# Practical: Air-Quality Data Cleaning Using R
# Dataset : Beijing Multi-Site Air Quality Dataset (UCI ML Repository)
# Topic   : Loops, Functions, Error Handling, Missing Data Handling
########################################################################

# ----------------------------------------------------------------------
# TASK 1: Import and Inspect the Dataset
# ----------------------------------------------------------------------

file_name <- "beijing+multi+site+air+quality+data/PRSA2017_Data_20130301-20170228/PRSA_Data_20130301-20170228/PRSA_Data_Aotizhongxin_20130301-20170228.csv"

import_dataset <- function(path) {
  tryCatch({
    if (!file.exists(path)) {
      stop("File not found at the given path.")
    }
    df <- read.csv(path, stringsAsFactors = FALSE)
    if (ncol(df) == 0) {
      stop("File format is incorrect - no columns detected.")
    }
    return(df)
  }, error = function(e) {
    message("ERROR while importing dataset: ", e$message)
    return(NULL)
  }, warning = function(w) {
    message("WARNING while importing dataset: ", w$message)
    return(NULL)
  })
}

air_data <- import_dataset(file_name)

if (!is.null(air_data)) {
  cat("\n--- First six records ---\n")
  print(head(air_data))

  cat("\n--- Structure of dataset ---\n")
  str(air_data)

  cat("\n--- Number of rows and columns ---\n")
  cat("Rows:", nrow(air_data), " Columns:", ncol(air_data), "\n")

  cat("\n--- Does the dataset contain missing values? ---\n")
  cat(any(is.na(air_data)), "\n")

  cat("\n--- Total number of missing values ---\n")
  cat(sum(is.na(air_data)), "\n")
} else {
  stop("Dataset could not be loaded. Please check the file path.")
}


# ----------------------------------------------------------------------
# TASK 2: Understand NA, NULL, and NaN
# ----------------------------------------------------------------------

cat("\n\n========== TASK 2: NA vs NULL vs NaN ==========\n")

# NA - missing observation
temperature <- c(28, 30, NA, 32)
cat("temperature vector:", temperature, "\n")
cat("is.na(temperature):", is.na(temperature), "\n")

# NULL - absent/empty object
missing_object <- NULL
cat("\nmissing_object is NULL:", is.null(missing_object), "\n")

# NaN - undefined numeric result
undefined_value <- 0 / 0
cat("\nundefined_value (0/0):", undefined_value, "\n")
cat("is.nan(undefined_value):", is.nan(undefined_value), "\n")

# Note: is.na() also returns TRUE for NaN, so NaN is technically a
# subtype detected by is.na(), while is.nan() catches ONLY NaN.
cat("\nis.na(NaN):", is.na(NaN), " | is.nan(NaN):", is.nan(NaN), "\n")
cat("is.na(NA):", is.na(NA), " | is.nan(NA):", is.nan(NA), "\n")


# ----------------------------------------------------------------------
# TASK 3: Missing-Value Summary Function
# ----------------------------------------------------------------------

missing_summary <- function(df, variables) {
  result <- data.frame(
    Variable = character(),
    Total_Records = integer(),
    Missing_Values = integer(),
    Missing_Percentage = numeric(),
    stringsAsFactors = FALSE
  )

  for (var in variables) {
    if (!(var %in% names(df))) {
      message("Column '", var, "' not found in dataset - skipping.")
      next
    }
    total <- nrow(df)
    missing <- sum(is.na(df[[var]]))
    pct <- round((missing / total) * 100, 2)

    if (pct > 20) {
      warning(paste0("Variable '", var, "' has more than 20% missing values (",
                      pct, "%)."))
    }

    result <- rbind(result, data.frame(
      Variable = var,
      Total_Records = total,
      Missing_Values = missing,
      Missing_Percentage = pct
    ))
  }
  return(result)
}

selected_vars <- c("PM2.5", "PM10", "SO2", "NO2", "TEMP", "WSPM", "wd")
summary_table_before <- missing_summary(air_data, selected_vars)

cat("\n\n========== TASK 3: Missing Value Summary ==========\n")
print(summary_table_before)


# ----------------------------------------------------------------------
# TASK 4: Identify Invalid Numerical Results
# ----------------------------------------------------------------------

cat("\n\n========== TASK 4: pollution_ratio checks ==========\n")

air_data$pollution_ratio <- air_data$PM2.5 / air_data$PM10

cat("NA count:", sum(is.na(air_data$pollution_ratio)), "\n")
cat("NaN count:", sum(is.nan(air_data$pollution_ratio)), "\n")
cat("Positive Infinity count:",
    sum(is.infinite(air_data$pollution_ratio) & air_data$pollution_ratio > 0,
        na.rm = TRUE), "\n")
cat("Negative Infinity count:",
    sum(is.infinite(air_data$pollution_ratio) & air_data$pollution_ratio < 0,
        na.rm = TRUE), "\n")

# Replace NaN and Infinite values with NA
air_data$pollution_ratio[is.nan(air_data$pollution_ratio)] <- NA
air_data$pollution_ratio[is.infinite(air_data$pollution_ratio)] <- NA

cat("After cleanup - remaining NaN/Inf:",
    sum(is.nan(air_data$pollution_ratio) | is.infinite(air_data$pollution_ratio)),
    "\n")


# ----------------------------------------------------------------------
# TASK 5: Handle Missing Numerical Values Using a Loop
# ----------------------------------------------------------------------

cat("\n\n========== TASK 5: Numerical Missing Value Treatment ==========\n")

numeric_variables <- c("PM2.5", "PM10", "SO2", "NO2", "TEMP", "WSPM")

# Keep a copy of "before" counts for the comparison table in Task 8
missing_before <- sapply(numeric_variables, function(v) sum(is.na(air_data[[v]])))

for (var in numeric_variables) {

  if (!(var %in% names(air_data))) {
    message("Column '", var, "' does not exist - skipping.")
    next
  }

  before_count <- sum(is.na(air_data[[var]]))
  med_value <- median(air_data[[var]], na.rm = TRUE)
  air_data[[var]][is.na(air_data[[var]])] <- med_value
  after_count <- sum(is.na(air_data[[var]]))

  cat("\nVariable:", var,
      "\n  Missing before:", before_count,
      "\n  Median used   :", med_value,
      "\n  Missing after :", after_count, "\n")
}


# ----------------------------------------------------------------------
# TASK 6: Handle Missing Categorical Values (wd)
# ----------------------------------------------------------------------

calculate_mode <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return(NA)
  freq_table <- table(x)
  mode_value <- names(freq_table)[which.max(freq_table)]
  return(mode_value)
}

cat("\n\n========== TASK 6: Categorical (wd) Missing Value Treatment ==========\n")

wd_missing_before <- sum(is.na(air_data$wd))
wd_mode <- calculate_mode(air_data$wd)
cat("Mode of wd:", wd_mode, "\n")

air_data$wd[is.na(air_data$wd)] <- wd_mode
wd_missing_after <- sum(is.na(air_data$wd))

cat("Missing before:", wd_missing_before, " | Missing after:", wd_missing_after, "\n")


# ----------------------------------------------------------------------
# TASK 7: Reusable clean_variable() Function with Error Handling
# ----------------------------------------------------------------------

clean_variable <- function(df, var_name) {
  tryCatch({

    if (!(var_name %in% names(df))) {
      stop(paste0("Variable '", var_name, "' does not exist in the dataset."))
    }

    column <- df[[var_name]]

    if (!is.numeric(column)) {
      stop(paste0("Variable '", var_name, "' is categorical, not numerical."))
    }

    if (all(is.na(column))) {
      stop(paste0("Variable '", var_name, "' contains only missing values."))
    }

    med_value <- median(column, na.rm = TRUE)

    if (is.na(med_value)) {
      stop(paste0("Median could not be calculated for '", var_name, "'."))
    }

    column[is.na(column)] <- med_value
    return(column)

  }, error = function(e) {
    message("clean_variable() ERROR: ", e$message)
    return(NULL)
  })
}

cat("\n\n========== TASK 7: clean_variable() demo ==========\n")

# Valid case
demo1 <- clean_variable(air_data, "SO2")
cat("SO2 cleaned successfully, sample:", head(demo1, 5), "\n")

# Invalid cases (should be handled gracefully, not crash the script)
demo2 <- clean_variable(air_data, "wd")            # categorical
demo3 <- clean_variable(air_data, "NonExistentCol") # doesn't exist


# ----------------------------------------------------------------------
# TASK 8: Comparison Table (Before vs After Cleaning)
# ----------------------------------------------------------------------

cat("\n\n========== TASK 8: Comparison Table ==========\n")

compare_vars <- c(numeric_variables, "wd")
missing_after <- sapply(compare_vars, function(v) sum(is.na(air_data[[v]])))
missing_before_full <- c(missing_before, wd = wd_missing_before)

comparison_table <- data.frame(
  Variable        = compare_vars,
  Missing_Before  = as.integer(missing_before_full[compare_vars]),
  Missing_After   = as.integer(missing_after[compare_vars]),
  Values_Replaced = as.integer(missing_before_full[compare_vars]) -
                     as.integer(missing_after[compare_vars])
)

print(comparison_table)

# Interpretation check
if (all(comparison_table$Missing_After == 0)) {
  cat("\nAll selected missing values have been successfully handled.\n")
} else {
  cat("\nSome missing values remain unhandled - review needed.\n")
}


# ----------------------------------------------------------------------
# TASK 9: Visualization - Missing Values Before vs After
# ----------------------------------------------------------------------

cat("\n\n========== TASK 9: Visualization ==========\n")

plot_matrix <- t(as.matrix(comparison_table[, c("Missing_Before", "Missing_After")]))
colnames(plot_matrix) <- comparison_table$Variable

png("missing_values_comparison.png", width = 900, height = 600)
barplot(
  plot_matrix,
  beside = TRUE,
  col = c("tomato", "steelblue"),
  main = "Missing Values Before vs After Cleaning",
  xlab = "Variables",
  ylab = "Number of Missing Values",
  legend.text = c("Before Cleaning", "After Cleaning"),
  args.legend = list(x = "topright")
)
dev.off()

cat("Chart saved as missing_values_comparison.png\n")


# ----------------------------------------------------------------------
# TASK 10: Export the Cleaned Dataset
# ----------------------------------------------------------------------

write.csv(air_data, "cleaned_air_quality_data.csv", row.names = FALSE)
cat("\nCleaned dataset exported as cleaned_air_quality_data.csv\n")


########################################################################
# INTERPRETATION (approx. 100-150 words)
########################################################################
# The Beijing air-quality station dataset initially contained missing
# values across several pollutant and weather variables such as PM2.5,
# PM10, SO2, NO2, TEMP and WSPM, along with some missing entries in the
# categorical wind-direction variable (wd). Using a for loop combined
# with median imputation, all numerical missing values were replaced
# without writing repetitive code for each column, while the
# calculate_mode() function handled the categorical wd variable.
# Invalid results in the derived pollution_ratio variable - including
# NaN and infinite values caused by division by zero or missing data -
# were also identified and converted to NA before treatment. The
# clean_variable() function, protected with tryCatch(), ensured that
# invalid inputs (non-existent columns, categorical variables passed
# by mistake, or fully-missing columns) produced informative messages
# instead of halting execution. The comparison table and bar chart
# confirm that missing values were reduced to zero for all selected
# variables, producing a clean dataset suitable for further pollution
# analysis.
########################################################################
