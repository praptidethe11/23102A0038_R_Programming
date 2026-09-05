# Social Network Analysis with R - Apple Tweets

## 1\. Project Title

Social Network Analysis with R - Apple Tweets

## 2\. Objective

The objective of this project is to implement a text-based social network analysis system using R Programming, representing relationships among terms and tweets as networks, analyzing their structure, identifying influential nodes, and visualizing the results.

The project follows the concepts, procedures, and implementation demonstrated in the prescribed video tutorial for the Social Network Analysis lab.

## 3\. Problem Description

Social Network Analysis (SNA) studies relationships between entities by representing them as nodes and edges rather than as independent records.

In this project, a dataset of Apple-related tweets is processed to build two networks:

* A **term co-occurrence network**, where nodes are frequently used words and edges represent words appearing together in the same tweet.
* A **tweet-tweet network**, where nodes are individual tweets and edges represent shared terms between tweets.

Both networks are analyzed to identify influential terms/tweets, detect communities, and visualize relationships.

## 4\. Reference Video

The implementation is based on the prescribed tutorial:

Social Network Analysis with R
https://www.youtube.com/watch?v=0xsM0MbRPGE\&list=PLpaxqU9O4beceS4RxsJESmFGUqpw-m2\_P\&index=1

## 5\. Dataset

The project uses `apple.csv`, a dataset of tweets mentioning Apple/AAPL, containing a `text` column with the raw tweet content.

* Total tweets: 1379
* Only terms appearing in more than 30 tweets are retained for the term network
* The tweet network is built from the same cleaned term-document matrix

## 6\. Technologies and Libraries Used

### Programming Language

R

### R Libraries

* **tm** – Used for text cleaning, corpus creation, and building the term-document matrix
* **igraph** – Used for graph construction, network measures, community detection, and visualization

## 7\. Project Workflow

```
Read Tweet Dataset (apple.csv)
        |
Build Text Corpus
        |
Clean Text (lowercase, remove punctuation/numbers/URLs/stopwords)
        |
Build Term-Document Matrix
        |
Filter Frequent Terms
        |
Build Term Co-occurrence Network
        |
Visualize Term Network + Node Degree
        |
Detect Communities (edge-betweenness, label prop, fast-greedy)
        |
Compute Hub \\\\\\\& Authority Scores
        |
Build Tweet-Tweet Network
        |
Prune Low-Degree / Weak-Edge Nodes
        |
Interpret Results
```

## 8\. Implementation Details

### Step 1: Environment Setup

Required packages are installed and loaded:

```r
install.packages(c("tm", "igraph"))
library(tm)
library(igraph)
```

### Step 2: Loading Data

Tweets are loaded from `apple.csv` using `read.csv()`.

### Step 3: Text Cleaning

The tweet text is converted to a `tm` Corpus and cleaned by:

* Lowercasing
* Removing punctuation, numbers, URLs, stopwords
* Removing dataset-specific noise words (`aapl`, `apple`)
* Normalizing terms (e.g. `stocks` → `stock`)
* Stripping extra whitespace

### Step 4: Term-Document Matrix

A `TermDocumentMatrix` is built and filtered to terms occurring in more than 30 tweets.

### Step 5: Term Co-occurrence Network

The term-document matrix is binarized and multiplied by its transpose to produce a term-term co-occurrence matrix, which is converted into an `igraph` object.

### Step 6: Network Measures

* **Degree** of each term node
* **Community detection** via `cluster\\\\\\\_edge\\\\\\\_betweenness`, `cluster\\\\\\\_label\\\\\\\_prop`, and `cluster\\\\\\\_fast\\\\\\\_greedy`
* **Hub scores** and **authority scores**

### Step 7: Tweet-Tweet Network

A parallel network is built where nodes are tweets, connected by shared terms. Low-degree vertices and weak edges are pruned to declutter the visualization.

### Step 8: Visualization

All networks are visualized with `igraph`'s `plot()`, including degree histograms, styled network diagrams, community-colored plots, and hub/authority comparisons.

## 9\. Expected Output

The project generates:

* Term-document and term co-occurrence matrices
* Term network visualizations (plain, styled, degree-highlighted)
* Community detection plots (3 algorithms)
* Hub and authority score visualizations
* Tweet-tweet network visualizations (full and pruned)
* Sample tweet text verification

Exact node/edge counts and community groupings depend on the dataset execution.

## 10\. How to Run the Project

### Prerequisites

Install:

* R / RStudio
* Required R packages (`tm`, `igraph`)

### Installation

```r
install.packages(c("tm", "igraph"))
```

### Dataset Setup

Place `apple.csv` in the project directory and update the file path in the script:

```r
apple <- read.csv("path/to/apple.csv", header = TRUE, stringsAsFactors = FALSE)
```

### Execute

Open `apple\\\\\\\_text\\\\\\\_network\\\\\\\_analysis.R` in RStudio and run the commands sequentially. Plots for the term network render directly; the tweet network's pruned plots (`g2`, `g3`) are written to PNG files to avoid rendering slowdowns on large graphs.

## 11\. Project Files

```
apple-tweets-network-analysis/
│
├── README.md
├── apple\\\\\\\_text\\\\\\\_network\\\\\\\_analysis.R
│
├── data/
│   └── apple.csv
│
├── plots/
│   ├── term\\\\\\\_network\\\\\\\_node\\\\\\\_degree\\\\\\\_histogram.png
│   ├── term\\\\\\\_network\\\\\\\_plain.png
│   ├── term\\\\\\\_network\\\\\\\_styled.png
│   ├── community\\\\\\\_edge\\\\\\\_betweenness.png
│   ├── community\\\\\\\_label\\\\\\\_prop.png
│   ├── community\\\\\\\_fast\\\\\\\_greedy.png
│   ├── hubs\\\\\\\_authorities.png
│   ├── term\\\\\\\_network\\\\\\\_degree\\\\\\\_highlighted.png
│   ├── tweet\\\\\\\_network\\\\\\\_degree\\\\\\\_histogram.png
│   ├── tweet\\\\\\\_network\\\\\\\_full.png
│   ├── tweet\\\\\\\_network\\\\\\\_pruned\\\\\\\_degree40.png
│   └── tweet\\\\\\\_network\\\\\\\_pruned\\\\\\\_weight\\\\\\\_degree20.png
│
└── screenshots/
    ├── console\\\\\\\_setup.png
    ├── tdm\\\\\\\_matrix\\\\\\\_output.png
    ├── termM\\\\\\\_matrix\\\\\\\_output.png
    └── sample\\\\\\\_tweets\\\\\\\_verification.png
```

## 12\. Result

The project successfully implements a text-based social network analysis workflow using R, `tm`, and `igraph`.

Key findings:

* **"earnings"** and **"iphone"/"stock"** emerge as the most connected and influential terms, showing the conversation centers on earnings-report reactions and iPhone/stock discussion.
* Community detection consistently surfaces **three sub-clusters**: earnings/reporting/live updates, iPhone delay/product terms, and a smaller call/discussion-related group — indicating distinct narrative threads within the same event.
* Hub and authority scores are structurally similar, meaning the same core terms act as both broadcasters and referenced points rather than the network splitting into separate roles.
* The tweet-tweet network is heavily skewed: most tweets share almost no terms with others, while sharp spikes in the degree distribution reveal clusters of near-duplicate or retweeted content. After strict pruning (weak edges + low degree removed), very few tweet pairs survive, showing the apparent density in the raw network is driven by a handful of viral/duplicate tweets rather than broad organic overlap.

## 13\. Conclusion

This project demonstrates the practical implementation of social network analysis using R, `tm`, and `igraph`. It covers text preprocessing, network construction, centrality and community analysis, hub/authority scoring, visualization, and interpretation of both term-level and tweet-level relationships.

The project also follows the laboratory requirement of organizing the implementation as a project and maintaining it using Git and GitHub.

## 14\. Git and GitHub

The project is maintained using Git for version control.

Meaningful commits are used to document different stages of development, such as:

* Initial project setup
* Added tweet dataset
* Implemented text cleaning and term-document matrix
* Added term co-occurrence network and visualizations
* Added community detection and hub/authority analysis
* Added tweet-tweet network and pruning
* Added README and screenshots

The completed project is published on GitHub.

### GitHub Repository

Repository Link:
https://github.com/praptidethe11/23102A0038\_R\_Programming

## 15\. Academic Information

Course: R Programming
Laboratory Problem: Social Network Analysis with R
Primary Course Outcome: CO3
Additional Course Outcomes: CO2, CO6

The assignment focuses on implementing an end-to-end R-based social network analysis project, testing the implementation, documenting the work, and maintaining the project using Git and GitHub.

