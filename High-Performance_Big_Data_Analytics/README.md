# High-Performance Big Data Analytics in R — NYC Yellow Taxi

Laboratory Assignment 8 (R Programming): large-scale analysis of NYC TLC Yellow Taxi trips, comparing **base R, functional programming (`apply` / `lapply` / `purrr`), vectorized R, `data.table`**, and **sequential vs parallel (`foreach` + `doParallel`)** execution.

## Dataset

| Item | Source |
|---|---|
| Yellow Taxi Trip Records (Parquet, monthly) | https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page |
| Taxi Zone Lookup Table (CSV) | same page |

Default config: **Jan–Mar 2023 (~9M raw trips)**. Change `YEAR` / `MONTHS` in Cell 1. Raw data is downloaded by the script and is **not** stored in this repo.

Columns used: pickup/drop-off timestamps, `PULocationID`, `DOLocationID`, `passenger_count`, `trip_distance`, `payment_type`, `fare_amount`, `tip_amount`, `tolls_amount`, `total_amount`.

---

## Repository structure

```
.
├── nyc_taxi_analysis.R        # full pipeline, split into 9 Colab "cells"
├── README.md
├── outputs/
│   ├── key_findings.txt
│   ├── session_info.txt
│   ├── tables/                # analytics results (CSV)
│   ├── benchmarks/            # timing, memory, scalability, speedup (CSV/RDS)
│   └── figures/               # ggplot2 PNGs
└── report/
    └── Lab8_NYC_Taxi_R.pdf    # exported Colab notebook (submission PDF)
```

---

## How to run

1. Open Colab → **Runtime → Change runtime type → R**.
2. Copy each `#### CELL n ####` block of `nyc_taxi_analysis.R` into its own code cell, in order.
3. Run all cells. First run installs packages (several minutes).
4. Download `/content/outputs` (or `/content/lab8_outputs.tar.gz`) from the Colab Files sidebar and commit it under `outputs/`.

| Cell | Task |
|---|---|
| 1–2 | Setup, config, data download |
| 3–4 | **Task 1** import, inspection, cleaning, typing, temporal features, zone join |
| 5 | **Task 2** transportation analytics with `data.table` |
| 6 | **Task 3 & 5** functional vs vectorized vs `data.table`, base vs `data.table`, time + memory + scalability |
| 7 | **Task 4** sequential vs parallel (`foreach` + `doParallel`), speedup |
| 8 | **Task 6** `ggplot2` visualisations |
| 9 | Key findings, session info, packaging |

---

## Methodology

**Cleaning** – drop NA rows and exact duplicates; remove records outside the study period, with non-positive or extreme duration (>6 h), distance (>100 mi), fare (>$500), total (>$600), negative tips/tolls, passengers outside 1–6, speed >80 mph, or invalid zone IDs. Every step is logged in `outputs/tables/cleaning_log.csv`.

**Memory** – only needed columns are read from Parquet; datetime columns are dropped after extracting hour/day/day-of-week/month; categorical fields are stored as factors.

**Benchmarked operations** (all results verified identical before timing):

| Operation | Approaches |
|---|---|
| Mean fare per hour | `aggregate`, `tapply`, `lapply`, `purrr::map_dbl`, `split+sapply`, vectorized `rowsum`, `data.table` |
| Fare per mile (row-wise) | `apply`, `sapply`, `lapply`, `purrr::map2_dbl`, vectorized `/`, `data.table :=` |
| Revenue per route | base `aggregate`, base `tapply`, `data.table` |

Timing: `microbenchmark` (median of repeated runs) · Memory: `bench::mark` (allocated MB) · Scalability: `system.time` over 100k → full dataset.

**Parallel** – data partitioned month-wise; each partition runs route aggregation + a 300-iteration bootstrap of the fare~distance slope. Compared: sequential `%do%`, forked `doParallel`, PSOCK `doParallel`. `Speedup = T_sequential / T_parallel`.

---

## Results

> Fill these in from `outputs/benchmarks/*.csv` and `outputs/key_findings.txt` after running.

### Execution-time comparison (300k-row sample, median ms)

| Operation | Approach | Median (ms) | Memory (MB) | Speedup vs slowest |
|---|---|---|---|---|
| Mean fare by hour | Base `aggregate()` | | | |
| | `lapply()` | | | |
| | `purrr::map_dbl()` | | | |
| | Vectorized `rowsum()` | | | |
| | `data.table` | | | |
| Fare per mile | `apply()` | | | |
| | `sapply()` | | | |
| | `purrr::map2_dbl()` | | | |
| | Vectorized | | | |
| | `data.table :=` | | | |
| Revenue per route | Base `aggregate()` | | | |
| | `data.table` | | | |

### Sequential vs parallel

| Mode | Cores | Time (s) | Speedup | Efficiency (%) |
|---|---|---|---|---|
| Sequential | 1 | | 1.00 | 100 |
| Parallel (fork) | | | | |
| Parallel (PSOCK) | | | | |

### Key travel patterns

- Peak hour / busiest day / busiest month: 
- Most frequent route: 
- Highest-revenue route: 
- Payment preference (overall and by borough): 
- Distance–fare relationship (r, $/mile): 
- Other observations (airport trips, speed, tipping): 

Figures are in [`outputs/figures`](outputs/figures).

---

## Critical analysis (Task 7)

Replace the `___` with your measured values.

1. **Best execution performance:** `data.table` (and plain vectorized operations for element-wise math) — ___ ms vs ___ ms for the slowest approach.
2. **Why `data.table` is fast:** C implementation, grouping by reference without copying, radix ordering, in-place `:=` updates, multi-threaded aggregation, and low memory allocation (___ MB vs ___ MB).
3. **When functional programming is preferable:** when each iteration is a heavy, independent task (fitting a model per group, reading many files, API calls), or when readability of per-item logic matters more than raw speed. Calling `sapply`/`apply` on a tiny per-row function is ___× slower than vectorizing.
4. **When vectorized wins:** element-wise arithmetic on whole columns — the loop runs in compiled code, so there is no per-element R function-call overhead.
5. **Parallel improvement:** ___× speedup on ___ cores (efficiency ___%).
6. **Is parallel always faster?** No. With only ___ month-partitions and ___ cores, load imbalance, worker start-up, and data serialisation (PSOCK) limit gains. PSOCK gave ___× vs fork ___×. Parallelism pays off for coarse, CPU-bound tasks, not for operations `data.table` already finishes in milliseconds.
7. **Trade-offs:** speed ↔ readability (`data.table` syntax has a learning curve), memory ↔ speed (parallel workers duplicate data), simplicity ↔ scalability (base R is easy but degrades with rows; see `outputs/benchmarks/scalability.csv`).
8. **Recommendation:** use `data.table` for ingestion, cleaning, joins, and aggregation; vectorized expressions for column math; functional programming (`purrr`) for readable per-group/per-file workflows; and `foreach`/`doParallel` only for heavy per-partition computations such as simulation or bootstrapping.

---

## Notes & limitations

- Colab free tier typically has **2 CPU cores and ~12 GB RAM**, so parallel speedup is capped at ~2× (less with 3 uneven partitions). Use `MONTHS <- 1:6` or a larger runtime to see better scaling.
- Loop-based methods (`apply`, `sapply`) are benchmarked on a 300k-row sample because they take far too long on millions of rows; `data.table`/vectorized scalability is tested on the full data.
- Timings vary between runs and machines.
- The optional `leaflet` map is not included (the lookup table has no coordinates; it needs the TLC taxi-zone shapefile).

## Packages

`data.table`, `ggplot2`, `foreach`, `doParallel`, `microbenchmark`, `purrr`, `lubridate`, `nanoparquet`, `bench`, `scales` (exact versions in `outputs/session_info.txt`).

## Data attribution

NYC Taxi & Limousine Commission (TLC) Trip Record Data — public data published by the City of New York.
