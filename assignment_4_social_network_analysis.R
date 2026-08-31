# Social Network Analysis in R
# Text Network Analysis - Apple Tweets
# builds term co-occurrence + tweet networks from tweet text and analyzes them

# install packages (run once - comment out after first successful run)
install.packages(c("tm", "igraph"))

# 1. read file
apple <- read.csv("C:/Users/Lenovo/Downloads/apple.csv", header = TRUE, stringsAsFactors = FALSE)

# 2. build corpus
library(tm)
corpus <- iconv(apple$text, to = "UTF-8", sub = "byte")   # "UTF-8" works cross-platform (utf-8-mac is Mac-only)
corpus <- Corpus(VectorSource(corpus))

# 3. clean text
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
cleanset <- tm_map(corpus, removeWords, stopwords('english'))

removeURL <- function(x) gsub('http[[:alnum:][:punct:]]*', '', x)
cleanset <- tm_map(cleanset, content_transformer(removeURL))
cleanset <- tm_map(cleanset, removeWords, c('aapl', 'apple'))
cleanset <- tm_map(cleanset, content_transformer(gsub),
                   pattern = 'stocks',
                   replacement = 'stock')
cleanset <- tm_map(cleanset, stripWhitespace)

# 4. term document matrix
tdm <- TermDocumentMatrix(cleanset)
tdm <- as.matrix(tdm)
tdm <- tdm[rowSums(tdm) > 30, ]   # keep only frequent terms
tdm[1:10, 1:10]

# 5. network of terms (term co-occurrence graph)
library(igraph)
tdm[tdm > 1] <- 1                
termM <- tdm %*% t(tdm)           
termM[1:10, 1:10]

g <- graph.adjacency(termM, weighted = TRUE, mode = 'undirected')
g <- simplify(g)                  # remove self-loops/duplicate edges
V(g)$label <- V(g)$name
V(g)$degree <- degree(g)

# 6. histogram of node degree
hist(V(g)$degree,
     breaks = 100,
     col = 'pink',
     main = 'Histogram of Node Degree',
     ylab = 'Frequency',
     xlab = 'Degree of Vertices')

# 7. network diagram
set.seed(222)
plot(g)
plot(g,
     vertex.color = 'yellow',
     vertex.size = 4,
     vertex.label.dist = 1.5,
     vertex.label = NA)

# 8. community detection
comm <- cluster_edge_betweenness(g)
plot(comm, g)

prop <- cluster_label_prop(g)
plot(prop, g)

greed <- cluster_fast_greedy(as.undirected(g))
plot(greed, as.undirected(g))

# 9. hub and authority scores
hs <- hub_score(g, weights = NA)$vector
as_scores <- authority_score(g, weights = NA)$vector   

par(mfrow = c(1, 2))
plot(g, vertex.size = hs * 50, main = 'Hubs',
     vertex.label = NA,
     vertex.color = rainbow(50))
plot(g, vertex.size = as_scores * 30, main = 'Authorities',
     vertex.label = NA,
     vertex.color = rainbow(50))
par(mfrow = c(1, 1))

# 10. highlighting degrees (bigger label = higher degree)
V(g)$label.cex <- 2.2 * V(g)$degree / max(V(g)$degree) + 0.3
V(g)$label.color <- rgb(0, 0, .2, .8)
V(g)$frame.color <- NA
egam <- (log(E(g)$weight) + .4) / max(log(E(g)$weight) + .4)
E(g)$color <- rgb(.5, .5, 0, egam)
E(g)$width <- egam
plot(g,
     vertex.color = 'yellow',
     vertex.size = V(g)$degree * .5)

# 11. network of tweets (tweet-tweet co-occurrence via shared terms)
tweetM <- t(tdm) %*% tdm
g <- graph.adjacency(tweetM, weighted = TRUE, mode = 'undirected')
V(g)$degree <- degree(g)
g <- simplify(g)

hist(V(g)$degree,
     breaks = 100,
     col = 'blue',
     main = 'Histogram of Degree',
     ylab = 'Frequency',
     xlab = 'Degree')

# set labels of vertices to tweet IDs
V(g)$label <- V(g)$name
V(g)$label.cex <- 1
V(g)$label.color <- rgb(.4, 0, 0, .7)
V(g)$size <- 2
V(g)$frame.color <- NA
plot(g, vertex.label = NA, vertex.size = 6)

# 12. delete low-degree vertices to declutter
egam <- (log(E(g)$weight) + .2) / max(log(E(g)$weight) + .2)
E(g)$color <- rgb(.5, .5, 0, egam)
E(g)$width <- egam
g2 <- delete.vertices(g, V(g)[degree(g) < 40])

png("g2_plot.png", width = 1000, height = 800)
plot(g2, vertex.label.cex = .9, vertex.label.color = 'black')
dev.off()

# 13. delete weak edges (weight <= 1), then isolated low-degree vertices
g3 <- delete.edges(g, E(g)[E(g)$weight <= 1])
g3 <- delete.vertices(g3, V(g3)[degree(g3) < 20])

png("g3_plot.png", width = 1000, height = 800)
plot(g3)
dev.off()

# 14. inspect a couple of specific tweets
apple$text[c(747, 430)]