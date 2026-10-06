# ==== CELL 1: Install & load packages ========================================
options(repos = c(CRAN = "https://cloud.r-project.org"))

pkgs <- c("data.table", "ggplot2", "foreach", "doParallel", "microbenchmark",
          "purrr", "lubridate", "nanoparquet", "bench", "scales", "zip")

new_pkgs <- setdiff(pkgs, rownames(installed.packages()))
if (length(new_pkgs)) install.packages(new_pkgs)

invisible(lapply(pkgs, library, character.only = TRUE))
theme_set(theme_minimal(base_size = 12))


# ==== CELL 2: Configuration & folders ========================================
MONTHS         <- sprintf("2024-%02d", 1:6)  # Jan-Jun 2024
ROWS_PER_MONTH <- 100000   # Use 100000 for laptops with limited RAM; can raise to 500000
BOOT_B         <- 100      # Bootstrap resamples per month
SEED           <- 42
RUN_LEAFLET    <- FALSE    # Keep FALSE unless you specifically need the interactive map

DIR_DATA <- "data"
DIR_OUT  <- "outputs"
DIR_FIG  <- file.path(DIR_OUT, "figures")
DIR_TBL  <- file.path(DIR_OUT, "tables")
DIR_LOG  <- file.path(DIR_OUT, "logs")

for (d in c(DIR_DATA, DIR_FIG, DIR_TBL, DIR_LOG)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

save_tbl <- function(dt, name) {
  fwrite(dt, file.path(DIR_TBL, paste0(name, ".csv")))
  invisible(dt)
}

save_plot <- function(p, name) {
  ggsave(
    file.path(DIR_FIG, paste0(name, ".png")),
    p, width = 9, height = 5.5, dpi = 150
  )
  print(p)
}

set.seed(SEED)


# ==== CELL 3: Task 1.1 - Download & import data ==============================
options(timeout = 900)

base_url <- "https://d37ci6vzurychx.cloudfront.net/"

for (m in MONTHS) {
  f <- file.path(DIR_DATA, sprintf("yellow_tripdata_%s.parquet", m))
  if (!file.exists(f)) {
    download.file(
      sprintf("%strip-data/yellow_tripdata_%s.parquet", base_url, m),
      f, mode = "wb", quiet = TRUE
    )
  }
}

zone_file <- file.path(DIR_DATA, "taxi_zone_lookup.csv")
if (!file.exists(zone_file)) {
  download.file(
    paste0(base_url, "misc/taxi_zone_lookup.csv"),
    zone_file, mode = "wb", quiet = TRUE
  )
}

keep_cols <- c(
  "tpep_pickup_datetime", "tpep_dropoff_datetime", "passenger_count",
  "trip_distance", "PULocationID", "DOLocationID", "payment_type",
  "fare_amount", "tip_amount", "tolls_amount", "total_amount"
)

rows_available <- integer(0)

read_month <- function(m) {
  f <- file.path(DIR_DATA, sprintf("yellow_tripdata_%s.parquet", m))
  d <- as.data.table(nanoparquet::read_parquet(f, col_select = keep_cols))
  rows_available[m] <<- nrow(d)
  
  if (nrow(d) > ROWS_PER_MONTH) {
    d <- d[sample.int(.N, ROWS_PER_MONTH)]
  }
  d
}

t_load <- system.time(trips <- rbindlist(lapply(MONTHS, read_month)))

cat("Rows available in source files:", format(sum(rows_available), big.mark = ","), "\n")
cat("Rows loaded (sampled)         :", format(nrow(trips), big.mark = ","), "\n")
cat("Load time (s)                 :", t_load[["elapsed"]], "\n")


# ==== CELL 4: Task 1.2 - Inspect structure, dimensions, types, summary =======
cat("Dimensions:", dim(trips), "\n\n")
str(trips)
print(summary(trips))

cat("\nMissing values per column:\n")
print(colSums(is.na(trips)))

cat("\nExact duplicate rows:", sum(duplicated(trips)), "\n")
cat("Memory (raw):", format(object.size(trips), units = "MB"), "\n")

mem_raw <- as.numeric(object.size(trips)) / 1e6

writeLines(
  capture.output(str(trips), summary(trips)),
  file.path(DIR_LOG, "raw_data_summary.txt")
)


# ==== CELL 5: Task 1.3-1.6 - Clean, convert types, temporal features =========
clean_log <- list()

log_step <- function(label, before, after) {
  clean_log[[length(clean_log) + 1]] <<- data.table(
    step = label,
    removed = before - after,
    remaining = after
  )
}

clean_log[[1]] <- data.table(
  step = "Raw (sampled) rows",
  removed = 0L,
  remaining = nrow(trips)
)

setnames(
  trips,
  c("tpep_pickup_datetime", "tpep_dropoff_datetime"),
  c("pickup_time", "dropoff_time")
)

# 1) Missing values
n <- nrow(trips)
trips <- na.omit(trips)
log_step("Missing values (NA)", n, nrow(trips))

# 2) Duplicates
n <- nrow(trips)
trips <- unique(trips)
log_step("Duplicate rows", n, nrow(trips))

# 3) Invalid / inconsistent records
range_start <- as.POSIXct(paste0(MONTHS[1], "-01"), tz = "UTC")
range_end <- as.POSIXct(
  seq(
    as.Date(paste0(tail(MONTHS, 1), "-01")),
    by = "month",
    length.out = 2
  )[2],
  tz = "UTC"
)

trips[, duration_min := as.numeric(difftime(dropoff_time, pickup_time, units = "mins"))]

n <- nrow(trips)
trips <- trips[pickup_time >= range_start & pickup_time < range_end]
log_step("Pickup outside study period", n, nrow(trips))

n <- nrow(trips)
trips <- trips[duration_min >= 1 & duration_min <= 180]
log_step("Trip duration not in [1, 180] min", n, nrow(trips))

n <- nrow(trips)
trips <- trips[trip_distance >= 0.1 & trip_distance <= 100]
log_step("Trip distance not in [0.1, 100] mi", n, nrow(trips))

n <- nrow(trips)
trips <- trips[
  fare_amount > 0 & fare_amount <= 500 &
    total_amount > 0 & total_amount <= 1000 &
    tip_amount >= 0 & tolls_amount >= 0
]
log_step("Invalid fare / total / tip / toll", n, nrow(trips))

n <- nrow(trips)
trips <- trips[passenger_count >= 1 & passenger_count <= 6]
log_step("Passenger count not in [1, 6]", n, nrow(trips))

n <- nrow(trips)
trips <- trips[payment_type %in% 1:4]
log_step("Payment type not in 1-4", n, nrow(trips))

n <- nrow(trips)
trips[, avg_speed_mph := trip_distance / (duration_min / 60)]
trips <- trips[avg_speed_mph <= 80]
log_step("Implausible speed (> 80 mph)", n, nrow(trips))

# 4) Data types
trips[, `:=`(
  passenger_count = as.integer(passenger_count),
  PULocationID = as.integer(PULocationID),
  DOLocationID = as.integer(DOLocationID),
  payment_label = factor(
    payment_type,
    levels = 1:4,
    labels = c("Credit card", "Cash", "No charge", "Dispute")
  )
)]

# 5) Temporal attributes
trips[, `:=`(
  pickup_date = as.Date(pickup_time),
  pickup_hour = as.integer(lubridate::hour(pickup_time)),
  pickup_day = as.integer(lubridate::mday(pickup_time)),
  pickup_wday = lubridate::wday(pickup_time, label = TRUE, week_start = 1),
  pickup_month = lubridate::month(pickup_time, label = TRUE),
  pickup_month_num = as.integer(lubridate::month(pickup_time))
)]

# 6) Drop unneeded columns
trips[, c("pickup_time", "dropoff_time", "payment_type") := NULL]
invisible(gc())

clean_log_dt <- rbindlist(clean_log)
print(clean_log_dt)
save_tbl(clean_log_dt, "00_cleaning_log")

cat(sprintf(
  "Memory: raw %.1f MB -> cleaned %.1f MB\n",
  mem_raw,
  as.numeric(object.size(trips)) / 1e6
))


# ==== CELL 6: Task 1.7-1.9 - Zone lookup & data.table joins ==================
zones <- fread(zone_file)
setnames(zones, c("LocationID", "Borough", "Zone", "service_zone"))
zones[, LocationID := as.integer(LocationID)]
print(head(zones))

pu <- zones[, .(PULocationID = LocationID, PU_Borough = Borough, PU_Zone = Zone)]
do <- zones[, .(DOLocationID = LocationID, DO_Borough = Borough, DO_Zone = Zone)]

setkey(pu, PULocationID)
setkey(do, DOLocationID)

t_join <- system.time({
  trips <- merge(trips, pu, by = "PULocationID", all.x = TRUE)
  trips <- merge(trips, do, by = "DOLocationID", all.x = TRUE)
})

cat("Join time (s):", t_join[["elapsed"]], "\n")

fcols <- c("PU_Borough", "PU_Zone", "DO_Borough", "DO_Zone")

trips[, (fcols) := lapply(
  .SD,
  function(x) factor(fifelse(is.na(x), "Unknown", as.character(x)))
), .SDcols = fcols]

cat("Rows after join:", format(nrow(trips), big.mark = ","), "\n")
print(head(trips))


# ==== CELL 7: Task 2 - Transportation analytics (data.table) =================
agg_period <- function(by_col) {
  trips[
    ,
    .(
      trips = .N,
      avg_fare = mean(fare_amount),
      avg_total = mean(total_amount),
      total_revenue = sum(total_amount)
    ),
    by = by_col
  ][order(get(by_col))]
}

hourly <- agg_period("pickup_hour")
weekday <- agg_period("pickup_wday")
monthly <- agg_period("pickup_month")
daily <- agg_period("pickup_date")

print(hourly)
print(weekday)
print(monthly)

save_tbl(hourly, "01_trips_by_hour")
save_tbl(weekday, "02_trips_by_weekday")
save_tbl(monthly, "03_trips_by_month")
save_tbl(daily, "04_daily_trend")

# Routes
route_stats <- trips[
  ,
  .(
    trips = .N,
    total_revenue = sum(total_amount),
    avg_total = mean(total_amount),
    avg_distance = mean(trip_distance)
  ),
  by = .(PU_Zone, DO_Zone)
]

route_stats[, route := paste(PU_Zone, "->", DO_Zone)]

top_routes_freq <- route_stats[order(-trips)][1:15]
top_routes_rev <- route_stats[order(-total_revenue)][1:15]

print(top_routes_freq)
print(top_routes_rev)

save_tbl(top_routes_freq, "05_top_routes_by_frequency")
save_tbl(top_routes_rev, "06_top_routes_by_revenue")

top_pu <- trips[, .(trips = .N), by = PU_Zone][order(-trips)][1:10]
top_do <- trips[, .(trips = .N), by = DO_Zone][order(-trips)][1:10]

save_tbl(top_pu, "07_top_pickup_zones")
save_tbl(top_do, "08_top_dropoff_zones")

# Distance vs fare
dist_cor <- trips[, .(
  pearson = cor(trip_distance, fare_amount),
  spearman = cor(trip_distance, fare_amount, method = "spearman")
)]

fit <- lm(
  fare_amount ~ trip_distance,
  data = trips[sample.int(.N, min(.N, 500000))]
)

dist_cor[, `:=`(
  intercept_usd = coef(fit)[1],
  usd_per_mile = coef(fit)[2],
  r_squared = summary(fit)$r.squared
)]

print(dist_cor)

trips[, dist_bin := cut(
  trip_distance,
  c(0, 1, 2, 3, 5, 10, 20, Inf),
  labels = c("0-1", "1-2", "2-3", "3-5", "5-10", "10-20", "20+")
)]

dist_bins <- trips[
  ,
  .(
    trips = .N,
    avg_fare = mean(fare_amount),
    fare_per_mile = sum(fare_amount) / sum(trip_distance)
  ),
  by = dist_bin
][order(dist_bin)]

print(dist_bins)

save_tbl(dist_cor, "09_distance_fare_correlation")
save_tbl(dist_bins, "10_distance_bins")

# Payment method by pickup borough
pay_borough <- trips[, .(trips = .N), by = .(PU_Borough, payment_label)]
pay_borough[, share := trips / sum(trips), by = PU_Borough]

print(dcast(pay_borough, PU_Borough ~ payment_label, value.var = "share"))
save_tbl(pay_borough, "11_payment_by_borough")

# Additional patterns
tip_hour <- trips[
  payment_label == "Credit card",
  .(avg_tip_pct = mean(tip_amount / fare_amount * 100)),
  by = pickup_hour
][order(pickup_hour)]

speed_hr <- trips[
  ,
  .(avg_speed_mph = mean(avg_speed_mph)),
  by = pickup_hour
][order(pickup_hour)]

trips[, is_airport := grepl("Airport", PU_Zone) | grepl("Airport", DO_Zone)]

airport <- trips[
  ,
  .(
    trips = .N,
    avg_total = mean(total_amount),
    total_revenue = sum(total_amount),
    avg_distance = mean(trip_distance)
  ),
  by = is_airport
]

airport[, `:=`(
  trip_share = trips / sum(trips),
  revenue_share = total_revenue / sum(total_revenue)
)]

tip_by_pay <- trips[
  ,
  .(
    avg_tip_usd = mean(tip_amount),
    avg_tip_pct = mean(tip_amount / fare_amount * 100)
  ),
  by = payment_label
]

print(airport)
print(tip_by_pay)

save_tbl(tip_hour, "12_tip_pct_by_hour")
save_tbl(speed_hr, "13_speed_by_hour")
save_tbl(airport, "14_airport_vs_non_airport")
save_tbl(tip_by_pay, "15_tip_by_payment")


# ==== CELL 8: Task 3 - Functional vs vectorized vs data.table ================
set.seed(SEED)
sub <- trips[sample.int(.N, 100000)]

# Operation 1: grouped mean of total_amount by pickup hour
op1_base <- function(d) {
  aggregate(total_amount ~ pickup_hour, data = d, FUN = mean)
}

op1_lapply <- function(d) {
  h <- sort(unique(d$pickup_hour))
  data.frame(
    pickup_hour = h,
    avg = unlist(lapply(h, function(x) mean(d$total_amount[d$pickup_hour == x])))
  )
}

op1_purrr <- function(d) {
  h <- sort(unique(d$pickup_hour))
  data.frame(
    pickup_hour = h,
    avg = purrr::map_dbl(h, \(x) mean(d$total_amount[d$pickup_hour == x]))
  )
}

op1_vectorized <- function(d) {
  s <- rowsum(d$total_amount, d$pickup_hour)
  data.frame(
    pickup_hour = as.integer(rownames(s)),
    avg = as.vector(s) / as.vector(table(d$pickup_hour))
  )
}

op1_datatable <- function(d) {
  d[, .(avg = mean(total_amount)), by = pickup_hour]
}

ref <- op1_datatable(trips)[order(pickup_hour)]$avg

stopifnot(
  isTRUE(all.equal(ref, op1_vectorized(trips)$avg)),
  isTRUE(all.equal(ref, op1_lapply(trips)$avg)),
  isTRUE(all.equal(ref, op1_purrr(trips)$avg)),
  isTRUE(all.equal(ref, op1_base(trips)$total_amount))
)

# Operation 2: row-wise fare-per-mile
op2_apply <- function(d) {
  m <- as.matrix(d[, .(total_amount, trip_distance)])
  apply(m, 1, function(r) r[1] / r[2])
}

op2_lapply <- function(d) {
  unlist(lapply(
    seq_len(nrow(d)),
    function(i) d$total_amount[i] / d$trip_distance[i]
  ))
}

op2_purrr <- function(d) {
  purrr::map2_dbl(d$total_amount, d$trip_distance, \(a, b) a / b)
}

op2_vectorized <- function(d) {
  d$total_amount / d$trip_distance
}

op2_datatable <- function(d) {
  d[, .(fpm = total_amount / trip_distance)]$fpm
}

stopifnot(
  isTRUE(all.equal(unname(op2_apply(sub)), op2_vectorized(sub))),
  isTRUE(all.equal(op2_purrr(sub), op2_datatable(sub)))
)

# microbenchmark on 100k rows
mb1 <- microbenchmark(
  base_aggregate = op1_base(sub),
  lapply = op1_lapply(sub),
  purrr_map = op1_purrr(sub),
  vectorized_rowsum = op1_vectorized(sub),
  data.table = op1_datatable(sub),
  times = 20
)

mb1_tbl <- as.data.table(summary(mb1, unit = "ms"))
print(mb1_tbl)
save_tbl(mb1_tbl, "16_microbenchmark_op1_100k")

# bench::mark
bench_tbl <- function(b, task, n_rows) {
  data.table(
    task = task,
    rows = n_rows,
    approach = as.character(b$expression),
    median_s = as.numeric(b$median),
    mem_MB = round(as.numeric(b$mem_alloc) / 1e6, 1)
  )
}

b1 <- bench::mark(
  base_aggregate = op1_base(trips),
  lapply = op1_lapply(trips),
  purrr_map = op1_purrr(trips),
  vectorized_rowsum = op1_vectorized(trips),
  data.table = op1_datatable(trips),
  iterations = 3,
  check = FALSE
)

b2 <- bench::mark(
  apply = op2_apply(sub),
  lapply = op2_lapply(sub),
  purrr_map2 = op2_purrr(sub),
  vectorized = op2_vectorized(sub),
  data.table = op2_datatable(sub),
  iterations = 3,
  check = FALSE
)

res_op1 <- bench_tbl(b1, "Op1: grouped mean by hour (full data)", nrow(trips))
res_op2 <- bench_tbl(b2, "Op2: row-wise fare per mile (100k rows)", nrow(sub))

print(res_op1)
print(res_op2)

# Scalability
fracs <- c(0.1, 0.25, 0.5, 1)

scal <- rbindlist(lapply(fracs, function(f) {
  d <- trips[sample.int(.N, floor(.N * f))]
  
  data.table(
    fraction = f,
    rows = nrow(d),
    base_aggregate = system.time(op1_base(d))[["elapsed"]],
    lapply = system.time(op1_lapply(d))[["elapsed"]],
    vectorized = system.time(op1_vectorized(d))[["elapsed"]],
    data.table = system.time(op1_datatable(d))[["elapsed"]]
  )
}))

print(scal)
save_tbl(scal, "17_scalability")

qual <- data.table(
  approach = c(
    "Base R aggregate()",
    "lapply()/sapply()",
    "purrr::map()",
    "apply() (row-wise)",
    "Vectorized base R",
    "data.table"
  ),
  complexity = c(
    "Low",
    "Medium",
    "Medium",
    "Medium",
    "Low-Medium",
    "Low"
  ),
  readability = c(
    "High",
    "Medium",
    "High",
    "Medium",
    "Medium-High",
    "High (once DT syntax known)"
  ),
  best_for = c(
    "Small data, quick scripts",
    "Per-group custom logic",
    "Pipelines / typed outputs",
    "Small matrices; avoid on big data",
    "Element-wise math on columns",
    "Large grouped/joined data"
  )
)

save_tbl(qual, "18_qualitative_comparison")


# ==== CELL 9: Task 4 - Sequential vs parallel (foreach + doParallel) =========
month_list <- split(
  trips[, .(month = pickup_month_num, total_amount, PULocationID, DOLocationID)],
  by = "month"
)

cat(
  "Partitions:", length(month_list),
  "| rows per partition:",
  paste(format(sapply(month_list, nrow), big.mark = ","), collapse = ", "),
  "\n"
)

heavy_task <- function(d, B) {
  data.table::setDTthreads(1)
  set.seed(d$month[1])
  
  top_rev <- d[
    ,
    .(rev = sum(total_amount)),
    by = .(PULocationID, DOLocationID)
  ][order(-rev)][1]$rev
  
  v <- d$total_amount
  n <- length(v)
  
  boot <- vapply(
    seq_len(B),
    function(i) median(sample(v, n, replace = TRUE)),
    numeric(1)
  )
  
  data.table::data.table(
    month = d$month[1],
    rows = n,
    top_route_revenue = top_rev,
    boot_median = mean(boot),
    ci_low = unname(quantile(boot, .025)),
    ci_high = unname(quantile(boot, .975))
  )
}

# Sequential
t_seq <- system.time(
  res_seq <- foreach(d = month_list, .combine = rbind) %do% heavy_task(d, BOOT_B)
)[["elapsed"]]

cat("Sequential time (s):", round(t_seq, 2), "\n")

# Parallel
max_cores <- parallel::detectCores()
core_grid <- sort(unique(pmin(c(2, 4, max_cores), length(month_list))))
core_grid <- core_grid[core_grid >= 2]

cat(
  "Detected cores:", max_cores,
  "| testing:", paste(core_grid, collapse = ", "),
  "\n"
)

par_rows <- list()

for (k in core_grid) {
  t_setup <- system.time({
    cl <- parallel::makeCluster(k)
    registerDoParallel(cl)
  })[["elapsed"]]
  
  t_par <- system.time(
    res_par <- foreach(
      d = month_list,
      .combine = rbind,
      .packages = "data.table"
    ) %dopar% heavy_task(d, BOOT_B)
  )[["elapsed"]]
  
  parallel::stopCluster(cl)
  registerDoSEQ()
  
  stopifnot(isTRUE(all.equal(res_seq, res_par)))
  
  par_rows[[as.character(k)]] <- data.table(
    cores = k,
    sequential_s = t_seq,
    parallel_s = t_par,
    cluster_setup_s = t_setup,
    speedup = t_seq / t_par,
    efficiency = (t_seq / t_par) / k
  )
}

parallel_tbl <- rbindlist(par_rows)
setDTthreads(0)

print(parallel_tbl)
print(res_seq)

save_tbl(parallel_tbl, "19_parallel_speedup")
save_tbl(res_seq, "20_parallel_task_results")


# ==== CELL 10: Task 5 - Master benchmark comparison table ====================
par_for_master <- rbind(
  data.table(
    task = "Month-wise bootstrap (6 partitions)",
    rows = nrow(trips),
    approach = "sequential (foreach %do%)",
    median_s = t_seq,
    mem_MB = NA_real_
  ),
  parallel_tbl[
    ,
    .(
      task = "Month-wise bootstrap (6 partitions)",
      rows = nrow(trips),
      approach = paste0("parallel (foreach %dopar%, ", cores, " cores)"),
      median_s = parallel_s,
      mem_MB = NA_real_
    )
  ]
)

benchmark_summary <- rbind(res_op1, res_op2, par_for_master)
benchmark_summary[, relative_to_fastest := round(median_s / min(median_s), 1), by = task]
benchmark_summary[, median_s := round(median_s, 4)]

print(benchmark_summary)
save_tbl(benchmark_summary, "21_benchmark_summary")


# ==== CELL 11: Task 6 - Visualizations (ggplot2) =============================
src_note <- paste0(
  "Source: NYC TLC Yellow Taxi, ",
  MONTHS[1], " to ", tail(MONTHS, 1),
  " (sample of ", format(nrow(trips), big.mark = ","), " cleaned trips)"
)

# 1. Trips by hour
p1 <- ggplot(hourly, aes(pickup_hour, trips)) +
  geom_col(fill = "#2c7fb8") +
  scale_x_continuous(breaks = 0:23) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Taxi Trips by Hour of Day",
    subtitle = sprintf(
      "Peak at %02d:00; quietest at %02d:00",
      hourly[which.max(trips), pickup_hour],
      hourly[which.min(trips), pickup_hour]
    ),
    x = "Hour of day (0-23)",
    y = "Number of trips",
    caption = src_note
  )
save_plot(p1, "01_trips_by_hour")

# 2. Day of week
p2 <- ggplot(weekday, aes(pickup_wday, trips, fill = pickup_wday)) +
  geom_col(show.legend = FALSE) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Taxi Demand by Day of Week",
    subtitle = sprintf("Busiest day: %s", weekday[which.max(trips), pickup_wday]),
    x = "Day of week",
    y = "Number of trips",
    caption = src_note
  )
save_plot(p2, "02_demand_by_weekday")

# 3. Monthly demand
p3 <- ggplot(monthly, aes(pickup_month, trips, group = 1)) +
  geom_col(fill = "#41ab5d") +
  geom_line(colour = "#238b45", linewidth = 1) +
  geom_point(size = 2) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Monthly Taxi Demand",
    x = "Month",
    y = "Number of trips",
    caption = src_note
  )
save_plot(p3, "03_monthly_demand")

# 4. Average fare trend
p4 <- ggplot(daily, aes(pickup_date, avg_fare)) +
  geom_line(colour = "grey60") +
  geom_smooth(
    se = FALSE,
    colour = "#d95f0e",
    method = "loess",
    formula = y ~ x
  ) +
  labs(
    title = "Average Fare Trend (Daily)",
    x = "Date",
    y = "Average fare (USD)",
    caption = src_note
  )
save_plot(p4, "04_avg_fare_trend")

# 5. Revenue trend
p5 <- ggplot(monthly, aes(pickup_month, total_revenue / 1e6, group = 1)) +
  geom_col(fill = "#756bb1") +
  labs(
    title = "Monthly Revenue (Total Amount)",
    subtitle = "Based on sampled data - use for relative comparison",
    x = "Month",
    y = "Revenue (million USD)",
    caption = src_note
  )
save_plot(p5, "05_revenue_trend")

# 6. Top pickup zones
p6 <- ggplot(top_pu, aes(reorder(PU_Zone, trips), trips)) +
  geom_col(fill = "#2b8cbe") +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Top 10 Pickup Zones",
    x = "Pickup zone",
    y = "Number of trips",
    caption = src_note
  )
save_plot(p6, "06_top_pickup_zones")

# 7. Top drop-off zones
p7 <- ggplot(top_do, aes(reorder(DO_Zone, trips), trips)) +
  geom_col(fill = "#e34a33") +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Top 10 Drop-off Zones",
    x = "Drop-off zone",
    y = "Number of trips",
    caption = src_note
  )
save_plot(p7, "07_top_dropoff_zones")

# 8. Frequent routes
p8 <- ggplot(top_routes_freq[1:10], aes(reorder(route, trips), trips)) +
  geom_col(fill = "#31a354") +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Top 10 Most Frequent Routes",
    x = "Route (pickup -> drop-off)",
    y = "Number of trips",
    caption = src_note
  )
save_plot(p8, "08_top_routes_frequency")

# 9. Highest-revenue routes
p9 <- ggplot(
  top_routes_rev[1:10],
  aes(reorder(route, total_revenue), total_revenue / 1e3)
) +
  geom_col(fill = "#dd1c77") +
  coord_flip() +
  labs(
    title = "Top 10 Highest-Revenue Routes",
    x = "Route (pickup -> drop-off)",
    y = "Total revenue (thousand USD)",
    caption = src_note
  )
save_plot(p9, "09_top_routes_revenue")

# 10. Payment distribution
p10 <- ggplot(pay_borough, aes(PU_Borough, share, fill = payment_label)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = percent) +
  labs(
    title = "Payment Method Share by Pickup Borough",
    x = "Pickup borough",
    y = "Share of trips (%)",
    fill = "Payment type",
    caption = src_note
  )
save_plot(p10, "10_payment_distribution")

# 11. Distance vs fare
sc <- trips[trip_distance <= 30][sample.int(.N, min(.N, 50000))]

p11 <- ggplot(sc, aes(trip_distance, fare_amount)) +
  geom_point(alpha = 0.08, size = 0.6, colour = "#3182bd") +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    colour = "red",
    se = FALSE
  ) +
  labs(
    title = "Trip Distance vs Fare Amount",
    subtitle = sprintf(
      "Pearson r = %.3f | approx. $%.2f per mile (linear fit)",
      dist_cor$pearson,
      dist_cor$usd_per_mile
    ),
    x = "Trip distance (miles)",
    y = "Fare amount (USD)",
    caption = paste(src_note, "- 50k-trip plot sample")
  )
save_plot(p11, "11_distance_vs_fare")

# 12. Benchmark comparison
p12 <- ggplot(
  benchmark_summary[!grepl("parallel|sequential", approach)],
  aes(reorder(approach, -median_s), median_s, fill = approach)
) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_y_log10() +
  facet_wrap(~task, scales = "free", ncol = 1) +
  labs(
    title = "Execution Time by Approach (log scale)",
    x = "Approach",
    y = "Median execution time (seconds, log10)"
  )

ggsave(
  file.path(DIR_FIG, "12_benchmark_comparison.png"),
  p12, width = 9, height = 8, dpi = 150
)
print(p12)

# 13. Parallel speedup
p13 <- ggplot(parallel_tbl, aes(factor(cores), speedup)) +
  geom_col(fill = "#fd8d3c") +
  geom_hline(yintercept = 1, linetype = "dashed") +
  geom_text(aes(label = sprintf("%.2fx", speedup)), vjust = -0.4) +
  labs(
    title = "Parallel Speedup (foreach + doParallel)",
    subtitle = "Dashed line = sequential baseline (1x)",
    x = "Number of cores",
    y = "Speedup = sequential time / parallel time"
  )
save_plot(p13, "13_parallel_speedup")

# 14. Scalability
scal_long <- melt(
  scal,
  id.vars = c("fraction", "rows"),
  variable.name = "approach",
  value.name = "seconds"
)

p14 <- ggplot(scal_long, aes(rows, seconds, colour = approach)) +
  geom_line(linewidth = 1) +
  geom_point() +
  scale_x_continuous(labels = comma) +
  labs(
    title = "Scalability: Execution Time vs Data Size (grouped mean by hour)",
    x = "Number of rows",
    y = "Elapsed time (seconds)",
    colour = "Approach"
  )
save_plot(p14, "14_scalability")


# ==== CELL 12: Optional - Interactive leaflet map ============================
if (RUN_LEAFLET) {
  install.packages(c("sf", "leaflet", "htmlwidgets"))
  library(sf)
  library(leaflet)
  
  download.file(
    paste0(base_url, "misc/taxi_zones.zip"),
    file.path(DIR_DATA, "taxi_zones.zip"),
    mode = "wb"
  )
  
  unzip(
    file.path(DIR_DATA, "taxi_zones.zip"),
    exdir = file.path(DIR_DATA, "taxi_zones")
  )
  
  shp <- st_read(
    list.files(
      file.path(DIR_DATA, "taxi_zones"),
      pattern = "\\.shp$",
      full.names = TRUE,
      recursive = TRUE
    ),
    quiet = TRUE
  )
  
  shp <- st_transform(shp, 4326)
  
  pu_counts <- as.data.frame(trips[, .(trips = .N), by = PULocationID])
  shp <- merge(
    shp,
    pu_counts,
    by.x = "LocationID",
    by.y = "PULocationID",
    all.x = TRUE
  )
  
  pal <- colorNumeric("YlOrRd", shp$trips, na.color = "#dddddd")
  
  m <- leaflet(shp) |>
    addProviderTiles("CartoDB.Positron") |>
    addPolygons(
      fillColor = ~pal(trips),
      fillOpacity = 0.8,
      weight = 0.5,
      color = "white",
      label = ~sprintf(
        "%s (%s): %s pickups",
        zone,
        borough,
        comma(trips)
      )
    ) |>
    addLegend(pal = pal, values = ~trips, title = "Pickups")
  
  htmlwidgets::saveWidget(
    m,
    file.path(DIR_OUT, "leaflet_pickup_map.html"),
    selfcontained = TRUE
  )
  
  m
}


# ==== CELL 13: Save session info & zip outputs ===============================
writeLines(
  capture.output(sessionInfo()),
  file.path(DIR_LOG, "session_info.txt")
)

writeLines(
  c(
    paste("Cores detected:", parallel::detectCores()),
    paste("Months:", paste(MONTHS, collapse = ", ")),
    paste("Rows per month (cap):", ROWS_PER_MONTH),
    paste("Rows analysed:", nrow(trips)),
    paste("Bootstrap B:", BOOT_B),
    paste("Seed:", SEED)
  ),
  file.path(DIR_LOG, "run_config.txt")
)

# Cross-platform output archive; replaces Linux shell `zip`
zip::zip(
  zipfile = "outputs.zip",
  files = "outputs",
  recurse = TRUE,
  root = "."
)

list.files(DIR_OUT, recursive = TRUE)