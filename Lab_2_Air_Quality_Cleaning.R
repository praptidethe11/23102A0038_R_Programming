# Air-Quality Data Cleaning
# Dataset: Beijing Multi-Site Air Quality Dataset

# Task 1: Import and inspect the dataset

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
    message("Error while importing dataset: ", e$message)
    return(NULL)
  }, warning = function(w) {
    message("Warning while importing dataset: ", w$message)
    return(NULL)
  })
}

air_data <- import_dataset(file_name)

if (!is.null(air_data)) {
  print(head(air_data))
  str(air_data)
  print(nrow(air_data))
  print(ncol(air_data))
  print(any(is.na(air_data)))
  print(sum(is.na(air_data)))
} else {
  stop("Dataset could not be loaded. Please check the file path.")
}


# Task 2: NA, NULL, and NaN

temperature <- c(28, 30, NA, 32)
is.na(temperature)

missing_object <- NULL
is.null(missing_object)

undefined_value <- 0 / 0
is.nan(undefined_value)

is.na(NaN)
is.nan(NaN)
is.na(NA)
is.nan(NA)


# Task 3: Missing-value summary function

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
print(summary_table_before)


# Task 4: Invalid numerical results

air_data$pollution_ratio <- air_data$PM2.5 / air_data$PM10

sum(is.na(air_data$pollution_ratio))
sum(is.nan(air_data$pollution_ratio))
sum(is.infinite(air_data$pollution_ratio) & air_data$pollution_ratio > 0, na.rm = TRUE)
sum(is.infinite(air_data$pollution_ratio) & air_data$pollution_ratio < 0, na.rm = TRUE)

air_data$pollution_ratio[is.nan(air_data$pollution_ratio)] <- NA
air_data$pollution_ratio[is.infinite(air_data$pollution_ratio)] <- NA


# Task 5: Handle missing numerical values using a loop

numeric_variables <- c("PM2.5", "PM10", "SO2", "NO2", "TEMP", "WSPM")

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
  
  cat(var, ": before =", before_count, ", median =", med_value,
      ", after =", after_count, "\n")
}


# Task 6: Handle missing categorical values (wd)

calculate_mode <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return(NA)
  freq_table <- table(x)
  mode_value <- names(freq_table)[which.max(freq_table)]
  return(mode_value)
}

wd_missing_before <- sum(is.na(air_data$wd))
wd_mode <- calculate_mode(air_data$wd)

air_data$wd[is.na(air_data$wd)] <- wd_mode
wd_missing_after <- sum(is.na(air_data$wd))

cat("wd: before =", wd_missing_before, ", mode =", wd_mode,
    ", after =", wd_missing_after, "\n")


# Task 7: Reusable clean_variable() function with error handling

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
    message("clean_variable() error: ", e$message)
    return(NULL)
  })
}

demo1 <- clean_variable(air_data, "SO2")
demo2 <- clean_variable(air_data, "wd")
demo3 <- clean_variable(air_data, "NonExistentCol")


# Task 8: Comparison table (before vs after cleaning)

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


# Task 9: Visualization

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


# Task 10: Export the cleaned dataset

write.csv(air_data, "cleaned_air_quality_data.csv", row.names = FALSE)
