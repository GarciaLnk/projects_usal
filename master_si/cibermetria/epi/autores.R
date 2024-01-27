library(igraph)
library(readxl)
library(netCoin)

data <- read_excel("EPI.xlsx")

# Split authors
data$Autores <- gsub("-", " ", data$Autores)
data$Autores <- strsplit(as.character(data$Autores), "[;,]")

# Create edges (co-authorship)
edges_list <- lapply(seq_len(nrow(data)), function(i) {
  if (length(data$Autores[[i]]) >= 2) {
    author_combinations <- combn(data$Autores[[i]], 2, simplify = FALSE)
    lapply(author_combinations, function(authors) {
      data.frame(
        source = authors[1],
        target = authors[2],
        article_title = data$Titulo[i],
        topic = data$Tema[i],
        section = data$Sección[i],
        authors_num = length(data$Autores[[i]]),
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
V(g)$articles <- sapply(V(g)$name, function(author) {
  articles <- data[sapply(data$Autores, function(authors) author %in% authors), "Titulo"]
  paste(articles, collapse = "; ")
})
V(g)$num_articles <- sapply(V(g)$name, function(author) {
  author_articles <- sapply(data$Autores, function(authors) author %in% authors)
  sum(author_articles)
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
pdf("dist-autores.pdf")
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
  size = "degree", lcolor = "topic", lwidth = "authors_num",
  group = "articles", zoom = 0.2
)
plot(g3)
