# setup

library(naniar)
library(skimr)

# lab 3: control flow for data cleaning

# simulated trestbps and chol data

set.seed(1)
trestbps <- c(120, 130, -10, 140, NA, 150, 320, 110, 125, NA, -5, 260, 135, 128, 300)
chol <- c(200, 210, 180, 0, 220, 190, 240, 205, NA, 215, 230, 0, 195, 208, 225)

# bp cleaning function using if-else

clean_bp <- function(bp) {
  if (is.na(bp)) {
    return(NA)
  } else if (bp < 0) {
    return(NA)
  } else if (bp > 250) {
    return(250)
  } else {
    return(bp)
  }
}

trestbps_clean <- sapply(trestbps, clean_bp)

# tryCatch for safe mean calculation

safe_mean <- function(x) {
  tryCatch({
    mean(x, na.rm = TRUE)
  }, warning = function(w) {
    message("warning while calculating mean: ", w$message)
    NA
  }, error = function(e) {
    message("error while calculating mean: ", e$message)
    NA
  })
}

mean_bp <- safe_mean(trestbps_clean)
print(mean_bp)

# tryCatch for ratio calculation

safe_ratio <- function(numerator, denominator) {
  tryCatch({
    if (is.na(denominator) || denominator == 0) {
      stop("invalid denominator")
    }
    numerator / denominator
  }, error = function(e) {
    message("could not calculate ratio: ", e$message)
    NA
  })
}

ratio <- mapply(safe_ratio, chol, trestbps_clean)
print(ratio)

# loop-based outlier detection

loop_time <- system.time({
  outliers_loop <- c()
  for (i in seq_along(trestbps)) {
    val <- trestbps[i]
    if (!is.na(val) && (val < 0 || val > 250)) {
      outliers_loop <- c(outliers_loop, i)
    }
  }
})

# vectorized outlier detection

vector_time <- system.time({
  outliers_vector <- which(!is.na(trestbps) & (trestbps < 0 | trestbps > 250))
})

print(loop_time)
print(vector_time)

# validation of cleaned bp data

na_count <- sum(is.na(trestbps_clean))
bp_min <- min(trestbps_clean, na.rm = TRUE)
bp_max <- max(trestbps_clean, na.rm = TRUE)
bp_mean <- mean(trestbps_clean, na.rm = TRUE)
bp_median <- median(trestbps_clean, na.rm = TRUE)

print(na_count)
print(bp_min)
print(bp_max)
print(bp_mean)
print(bp_median)

any(trestbps_clean < 0, na.rm = TRUE)
any(trestbps_clean > 250, na.rm = TRUE)

# save cleaned heart data

heart_data <- data.frame(trestbps = trestbps, trestbps_clean = trestbps_clean, chol = chol)
write.csv(heart_data, "cleaned_heart_data.csv", row.names = FALSE)

# lab 4: advanced missing data handling

# simulated adult dataset

adult_data <- data.frame(
  age = c(25, 999, 40, NA, 35, 60, 999, 45, 30, NA),
  workclass = c("Private", "", "Self-emp", "Private", NA, "Private", "", "Govt", "Private", "Govt"),
  income = c(50000, 45000, NaN, 60000, 55000, NA, 40000, NaN, 62000, 48000),
  stringsAsFactors = FALSE
)

# identifying missing and invalid data

is.na(adult_data$age)
is.nan(adult_data$income)

sample_obj <- NULL
is.null(sample_obj)

adult_data$workclass == ""

adult_data$age == 999

miss_var_summary(adult_data)

# missing data treatment

adult_data$age[adult_data$age == 999] <- NA
adult_data$workclass[adult_data$workclass == ""] <- "Unknown"

# custom median imputation function

impute_median <- function(x) {
  med <- median(x, na.rm = TRUE)
  x[is.na(x)] <- med
  return(x)
}

adult_data$age <- impute_median(adult_data$age)

# removing unrecoverable NaN rows

adult_data <- adult_data[!is.nan(adult_data$income), ]

complete.cases(adult_data)

# missingness before and after

missing_before <- sum(is.na(adult_data))
percent_missing <- mean(is.na(adult_data)) * 100

print(missing_before)
print(percent_missing)

vis_miss(adult_data)

# validation with skimr

skim(adult_data)

# save cleaned adult data

write.csv(adult_data, "cleaned_adult_data.csv", row.names = FALSE)