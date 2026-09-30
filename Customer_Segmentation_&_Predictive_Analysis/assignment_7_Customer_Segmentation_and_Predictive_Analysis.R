# packages
pkgs <- c("readxl", "dplyr", "lubridate", "ggplot2", "cluster", "factoextra",
          "caret", "randomForest", "e1071", "pROC", "plotly")
for (p in pkgs) if (!require(p, character.only = TRUE)) {
  install.packages(p); library(p, character.only = TRUE)
}
set.seed(42)

# 1. load data
# download from https://archive.ics.uci.edu/dataset/352/online+retail
if (!file.exists("Online Retail.xlsx")) {
  download.file("https://archive.ics.uci.edu/static/public/352/online+retail.zip",
                "online_retail.zip", mode = "wb")
  unzip("online_retail.zip")
}
raw <- read_excel("Online Retail.xlsx")
raw <- read_excel("Online Retail.xlsx")
str(raw)

# 2. preprocessing
df <- raw %>%
  filter(!is.na(CustomerID)) %>%
  filter(!grepl("^C", InvoiceNo)) %>%
  filter(Quantity > 0, UnitPrice > 0) %>%
  mutate(Total = Quantity * UnitPrice)
colSums(is.na(df))

# 3. customer level features
snapshot <- max(df$InvoiceDate) + days(1)

cust <- df %>%
  group_by(CustomerID) %>%
  summarise(
    Recency   = as.numeric(difftime(snapshot, max(InvoiceDate), units = "days")),
    Frequency = n_distinct(InvoiceNo),
    Monetary  = sum(Total),
    Quantity  = sum(Quantity),
    tenure    = as.numeric(difftime(max(InvoiceDate), min(InvoiceDate), units = "days")) / 30 + 1
  ) %>%
  mutate(
    AvgTransValue = Monetary / Frequency,
    PurchaseFreq  = Frequency / tenure
  ) %>%
  select(-tenure)

# 4. outlier treatment and scaling
cap <- function(x) {
  q <- quantile(x, c(0.01, 0.99))
  pmin(pmax(x, q[1]), q[2])
}
feat_cols <- c("Recency", "Frequency", "Monetary", "Quantity", "AvgTransValue", "PurchaseFreq")
capped <- cust
capped[feat_cols] <- lapply(capped[feat_cols], cap)
capped[feat_cols] <- lapply(capped[feat_cols], log1p)
X <- scale(capped[feat_cols])

# 5. elbow method
fviz_nbclust(X, kmeans, method = "wss", k.max = 10) + ggtitle("elbow method")

# 6. silhouette for different k
fviz_nbclust(X, kmeans, method = "silhouette", k.max = 10) + ggtitle("silhouette by k")

# 7. k-means
k <- 4
km <- kmeans(X, centers = k, nstart = 25)
cust$KMeans <- factor(km$cluster)
sil_km <- silhouette(km$cluster, dist(X))
mean(sil_km[, 3])
fviz_silhouette(sil_km)

# 8. hierarchical clustering
d <- dist(X)
hc <- hclust(d, method = "ward.D2")
plot(hc, labels = FALSE, hang = -1, main = "dendrogram")
rect.hclust(hc, k = k, border = 2:5)
cust$Hier <- factor(cutree(hc, k = k))
sil_hc <- silhouette(as.integer(cust$Hier), d)
mean(sil_hc[, 3])

# 9. comparison of clustering
data.frame(
  method = c("kmeans", "hierarchical"),
  silhouette = c(mean(sil_km[, 3]), mean(sil_hc[, 3]))
)
table(KMeans = cust$KMeans, Hier = cust$Hier)

# 10. pca and 2d plot
pca <- prcomp(X)
summary(pca)
pcs <- as.data.frame(pca$x[, 1:3])
pcs$Cluster <- cust$KMeans
ggplot(pcs, aes(PC1, PC2, color = Cluster)) +
  geom_point(alpha = 0.6) +
  stat_ellipse() +
  ggtitle("customer segments in pca space")

# 11. cluster profiling
profile <- cust %>%
  group_by(KMeans) %>%
  summarise(
    Customers = n(),
    Recency = mean(Recency),
    Frequency = mean(Frequency),
    Monetary = mean(Monetary),
    Quantity = mean(Quantity),
    AvgTransValue = mean(AvgTransValue),
    PurchaseFreq = mean(PurchaseFreq)
  ) %>%
  arrange(desc(Monetary))
print(profile)

# 12. name segments by monetary rank
seg_names <- c("Champions", "Loyal", "Occasional", "Dormant")
map <- setNames(seg_names, profile$KMeans)
cust$Segment <- factor(map[as.character(cust$KMeans)], levels = seg_names)
pcs$Segment <- cust$Segment

# 13. high value target
high_cluster <- as.character(profile$KMeans[1])
cust$HighValue <- factor(ifelse(cust$KMeans == high_cluster, "High", "Other"),
                         levels = c("Other", "High"))
table(cust$HighValue)

# 14. train test split
ml <- as.data.frame(X)
ml$HighValue <- cust$HighValue
idx <- createDataPartition(ml$HighValue, p = 0.8, list = FALSE)
train <- ml[idx, ]
test <- ml[-idx, ]

# 15. random forest
rf <- randomForest(HighValue ~ ., data = train, ntree = 300, importance = TRUE)
rf_pred <- predict(rf, test)
rf_prob <- predict(rf, test, type = "prob")[, "High"]

# 16. svm
svm_model <- svm(HighValue ~ ., data = train, kernel = "radial", probability = TRUE)
svm_pred <- predict(svm_model, test, probability = TRUE)
svm_prob <- attr(svm_pred, "probabilities")[, "High"]

# 17. evaluation
evaluate <- function(pred, prob, name) {
  cm <- confusionMatrix(pred, test$HighValue, positive = "High")
  roc_obj <- roc(test$HighValue, prob, levels = c("Other", "High"), quiet = TRUE)
  print(name); print(cm$table)
  data.frame(
    model = name,
    accuracy = unname(cm$overall["Accuracy"]),
    precision = unname(cm$byClass["Precision"]),
    recall = unname(cm$byClass["Recall"]),
    f1 = unname(cm$byClass["F1"]),
    auc = as.numeric(auc(roc_obj))
  )
}
results <- rbind(
  evaluate(rf_pred, rf_prob, "random forest"),
  evaluate(svm_pred, svm_prob, "svm")
)
print(results)

# 18. roc curves
roc_rf <- roc(test$HighValue, rf_prob, levels = c("Other", "High"), quiet = TRUE)
roc_svm <- roc(test$HighValue, svm_prob, levels = c("Other", "High"), quiet = TRUE)
plot(roc_rf, col = "blue", main = "roc curves")
plot(roc_svm, col = "red", add = TRUE)
legend("bottomright", legend = c("random forest", "svm"), col = c("blue", "red"), lwd = 2)

# 19. feature importance
importance(rf)
varImpPlot(rf, main = "random forest feature importance")

# 20. interactive 3d plot
plot_ly(pcs, x = ~PC1, y = ~PC2, z = ~PC3, color = ~Segment,
        type = "scatter3d", mode = "markers",
        marker = list(size = 3, opacity = 0.7)) %>%
  layout(title = "3d customer clusters")

# 21. marketing recommendations
recs <- data.frame(
  Segment = seg_names,
  Strategy = c(
    "vip program, early access to new products, personal offers, ask for referrals",
    "loyalty points, bundle and cross sell offers, nudge towards higher basket value",
    "seasonal campaigns, discount codes on next purchase, product recommendations by email",
    "win back emails with strong discounts, survey for churn reasons, low cost channels only"
  )
)
print(recs)
