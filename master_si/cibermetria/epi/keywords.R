library(igraph)
library(readxl)
library(netCoin)
library(tm)

data <- read_excel("EPI.xlsx")

# Split keywords
data$`Palabras clave/Keywords` <- gsub("[[:cntrl:]]", " ", data$`Palabras clave/Keywords`)
data$`Palabras clave/Keywords` <- gsub("¿", "?", data$`Palabras clave/Keywords`)
data$`Palabras clave/Keywords` <- tolower(data$`Palabras clave/Keywords`)
data$`Palabras clave/Keywords` <- strsplit(as.character(data$`Palabras clave/Keywords`), "[;,]")

# Cleanup keywords
data$`Palabras clave/Keywords` <- sapply(data$`Palabras clave/Keywords`, function(keyword) {
  keyword <- stripWhitespace(keyword)
  keyword <- trimws(keyword)
  keyword <- removePunctuation(keyword)
})

# Create edges (keyword co-occurrence)
edges_list <- lapply(seq_len(nrow(data)), function(i) {
  keywords <- data$`Palabras clave/Keywords`[[i]]
  if (length(keywords) >= 2) {
    keyword_combinations <- combn(keywords, 2, simplify = FALSE)
    lapply(keyword_combinations, function(pair) {
      data.frame(
        source = pair[1],
        target = pair[2],
        article_title = data$Titulo[i],
        topic = data$Tema[i],
        section = data$Sección[i],
        keywords_num = length(data$`Palabras clave/Keywords`[[i]]),
        year = data$Año[i],
        volume = data$Volumen[i],
        issue = data$Número[i]
      )
    })
  } else {
    NULL
  }
})

edges <- do.call("rbind", unlist(edges_list, recursive = FALSE))

# Create an igraph object
g <- graph_from_data_frame(edges, directed = FALSE)

# Add article titles and number of articles to the nodes
V(g)$articles <- sapply(V(g)$name, function(keyword) {
  articles <- data[sapply(data$`Palabras clave/Keywords`, function(keywords) keyword %in% keywords), "Titulo"]
  paste(articles, collapse = "; ")
})
V(g)$num_articles <- sapply(V(g)$name, function(keyword) {
  keyword_articles <- sapply(data$`Palabras clave/Keywords`, function(keywords) keyword %in% keywords)
  sum(keyword_articles)
})

# Network metrics
# Print number of nodes and edges
print(paste("Number of nodes:", vcount(g)))
print(paste("Number of edges:", ecount(g)))

# Network density
net_density <- edge_density(g)
print(paste("Network Density:", net_density))

# Network diameter
net_diameter <- diameter(g)
print(paste("Network Diameter:", net_diameter))

# Average path length
avg_path_len <- mean_distance(g)
print(paste("Average Path Length:", avg_path_len))

# Average degree
avg_degree <- mean(degree(g))
print(paste("Average Degree:", avg_degree))

# Degree distribution
degree_dist <- degree_distribution(g)
plot(degree_dist, main = "Distribución de grados", xlab = "Grado", ylab = "Frecuencia")
# Save the plot as pdf
pdf("dist-keywords.pdf")
plot(degree_dist, main = "Distribución de grados", xlab = "Grado", ylab = "Frecuencia")
dev.off()

# Node betweenness centrality
V(g)$betweenness <- betweenness(g)

# Node closeness centrality
V(g)$closeness <- closeness(g)

# Node eigenvector centrality
V(g)$eigenvector <- eigen_centrality(g)$vector

# Node pagerank
V(g)$pagerank <- page_rank(g)$vector

# Convert to netCoin object
g2 <- fromIgraph(g)
g3 <- netCoin(g2$nodes, g2$links,
  size = "degree", lcolor = "topic",
  zoom = 0.1
)
plot(g3)
Sys.sleep(0.5)

# Filter igraph object by topic
g4 <- subgraph.edges(g, E(g)[topic == "Información política y redes sociales (I)" |
  topic == "Información política y redes sociales (II)"], delete.vertices = TRUE)


# Add article titles and number of articles to the nodes
V(g4)$articles <- sapply(V(g4)$name, function(keyword) {
  articles <- data[sapply(data$`Palabras clave/Keywords`, function(keywords) keyword %in% keywords), "Titulo"]
  paste(articles, collapse = "; ")
})
V(g4)$num_articles <- sapply(V(g4)$name, function(keyword) {
  keyword_articles <- sapply(data$`Palabras clave/Keywords`, function(keywords) keyword %in% keywords)
  sum(keyword_articles)
})

# Node betweenness centrality
V(g4)$betweenness <- betweenness(g4)

# Node closeness centrality
V(g4)$closeness <- closeness(g4)

# Node eigenvector centrality
V(g4)$eigenvector <- eigen_centrality(g4)$vector

# Node pagerank
V(g4)$pagerank <- page_rank(g4)$vector

g5 <- fromIgraph(g4)
g6 <- netCoin(g5$nodes, g5$links,
  size = "degree", lcolor = "topic", color = "pagerank",
  group = "articles", zoom = 0.4
)
plot(g6)
Sys.sleep(0.5)

# Filter igraph object by topic
g7 <- subgraph.edges(g, E(g)[topic == "Indicadores I" |
  topic == "Indicadores II/Libro electrónico"], delete.vertices = TRUE)

# Add article titles and number of articles to the nodes
V(g7)$articles <- sapply(V(g7)$name, function(keyword) {
  articles <- data[sapply(data$`Palabras clave/Keywords`, function(keywords) keyword %in% keywords), "Titulo"]
  paste(articles, collapse = "; ")
})
V(g7)$num_articles <- sapply(V(g7)$name, function(keyword) {
  keyword_articles <- sapply(data$`Palabras clave/Keywords`, function(keywords) keyword %in% keywords)
  sum(keyword_articles)
})

# Node betweenness centrality
V(g7)$betweenness <- betweenness(g7)

# Node closeness centrality
V(g7)$closeness <- closeness(g7)

# Node eigenvector centrality
V(g7)$eigenvector <- eigen_centrality(g7)$vector

# Node pagerank
V(g7)$pagerank <- page_rank(g7)$vector

g8 <- fromIgraph(g7)
g9 <- netCoin(g8$nodes, g8$links,
  size = "degree", lcolor = "topic", color = "pagerank",
  group = "articles", zoom = 0.32
)
plot(g9)
