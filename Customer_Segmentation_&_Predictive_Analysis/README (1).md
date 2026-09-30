# Customer Segmentation and Predictive Analytics Using Machine Learning

## Description
- Uses the UCI Online Retail dataset (541,909 transactions) to build customer-level features and group customers into segments.
- Segments come from K-Means and are compared with Hierarchical Clustering.
- Random Forest and SVM then predict whether a customer belongs to the high-value segment.

## Objective
Identify meaningful customer segments from transaction history and predict high-value customers using supervised models.
Turn the segments into targeted marketing recommendations.

## Explanation / Procedure
1. **Preprocessing:** dropped rows with missing CustomerID, cancelled invoices (InvoiceNo starting with "C"), and rows with non-positive quantity or price.
2. **Feature engineering:** built Recency, Frequency, Monetary, Quantity, Average Transaction Value and Purchase Frequency per customer.
3. **Outliers and scaling:** capped each feature at the 1st and 99th percentile, applied log transform, then standardized.
4. **Choosing k:** used the Elbow Method and average silhouette width for k = 1 to 10.
5. **K-Means:** clustered with k = 4 and checked quality with the Silhouette Score (0.26).
6. **Hierarchical clustering:** Ward's method, dendrogram cut at 4 clusters, compared with K-Means using silhouette and a cross-table.
7. **PCA:** projected customers to 2D to visualize the clusters.
8. **Profiling:** averaged each feature per cluster and named the segments Champions, Loyal, Occasional and Dormant by monetary value.
9. **Classification:** labelled the Champions cluster as high value, split the data 80/20, trained Random Forest and SVM (RBF kernel).
10. **Evaluation:** Accuracy, Precision, Recall, F1, ROC-AUC, confusion matrix and ROC curves for both models.
11. **Feature importance:** Random Forest importance (Mean Decrease Accuracy and Gini).
12. **3D view:** interactive Plotly plot of the first three principal components.
13. **Marketing:** one strategy per segment.

## Conclusion
- Four segments were found. Silhouette is highest at k = 2 (0.33), but k = 4 gives more useful business segments with an average silhouette of 0.26.
- Random Forest and SVM both separate high-value customers almost perfectly (ROC-AUC close to 1). This is expected since the labels come from clustering on the same features.
- Frequency and Monetary are the strongest predictors by Gini importance, and Champions are the smallest but most valuable group to retain.
