library(igraph)
library(readxl)
library(netCoin)
library(tm)

data <- read_excel("EPI.xlsx")

data$Titulo <- gsub("[[:cntrl:]]", " ", data$Titulo)
data$Titulo <- gsub("¿", "?", data$Titulo)
data$Titulo <- tolower(data$Titulo)
data$Titulo <- removeWords(data$Titulo, words = c(stopwords("spanish"), stopwords("english")))
data$Titulo <- removePunctuation(data$Titulo)
data$Titulo <- removeNumbers(data$Titulo)
data$Titulo <- stripWhitespace(data$Titulo)
data$Titulo <- trimws(x = data$Titulo)

# Create edges (word co-occurrence within titles)
edges_list <- lapply(seq_len(nrow(data)), function(i) {
  words <- strsplit(data$Titulo[i], " ")[[1]]
  if (length(words) >= 2) {
    word_combinations <- combn(words, 2, simplify = FALSE)
    lapply(word_combinations, function(pair) {
      data.frame(
        source = pair[1],
        target = pair[2],
        article_title = data$Titulo[i],
        topic = data$Tema[i],
        section = data$Sección[i],
        titulo_len = length(data$Titulo[[i]]),
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
V(g)$articles <- sapply(V(g)$name, function(word) {
  articles <- data[sapply(data$Titulo, function(titulo) word %in% strsplit(titulo, " ")[[1]]), "Titulo"]
  paste(articles, collapse = "; ")
})
V(g)$num_articles <- sapply(V(g)$name, function(word) {
  word_articles <- sapply(data$Titulo, function(titulo) word %in% strsplit(titulo, " ")[[1]])
  sum(word_articles)
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
pdf("dist-titulos.pdf")
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
  size = "num_articles", lcolor = "topic",
  border = "degree", zoom = 0.1
)
plot(g3)

# Filter igraph object by topic
g4 <- subgraph.edges(g, E(g)[topic == "Información política y redes sociales (I)" |
  topic == "Información política y redes sociales (II)"], delete.vertices = TRUE)
g5 <- fromIgraph(g4)
g6 <- netCoin(g5$nodes, g5$links,
  size = "num_articles", lcolor = "topic", color = "pagerank",
  group = "articles", border = "degree", zoom = 0.4
)
plot(g6)

# Filter igraph object by topic
g7 <- subgraph.edges(g, E(g)[topic == "Indicadores I" |
  topic == "Indicadores II/Libro electrónico"], delete.vertices = TRUE)
g8 <- fromIgraph(g7)
g9 <- netCoin(g8$nodes, g8$links,
  size = "num_articles", lcolor = "topic", color = "pagerank",
  group = "articles", border = "degree", zoom = 0.4
)
plot(g9)
