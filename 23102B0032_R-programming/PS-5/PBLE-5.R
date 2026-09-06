# Social Network Analysis with R

#install.packages("igraph")
library(igraph)

edges <- data.frame(
  from = c("A", "A", "A", "B", "B", "C", "C", "D", "D", "E"),
  to   = c("B", "C", "D", "C", "D", "D", "E", "E", "F", "F")
)

edges

network <- graph_from_data_frame(edges, directed = FALSE)

network
V(network)
E(network)

plot(
  network,
  vertex.label = V(network)$name,
  vertex.size = 30,
  edge.width = 2
)

degree(network)

degree_centrality <- degree(network, normalized = TRUE)

degree_centrality

betweenness_centrality <- betweenness(network, normalized = TRUE)

betweenness_centrality

closeness_centrality <- closeness(network, normalized = TRUE)

closeness_centrality

plot(
  network,
  vertex.size = 10 + degree(network) * 5,
  vertex.label = V(network)$name,
  edge.width = 2

  
  network_measures <- data.frame(
    Node = V(network)$name,
    Degree = degree(network),
    Degree_Centrality = degree_centrality,
    Betweenness_Centrality = betweenness_centrality,
    Closeness_Centrality = closeness_centrality
  )
  
  network_measures
  
  write.csv(
    network_measures,
    "outputs/network_measures.csv",
    row.names = FALSE
  )
  
  png("outputs/network_visualization.png", width = 800, height = 600)
  
  plot(
    network,
    vertex.label = V(network)$name,
    vertex.size = 30,
    edge.width = 2
  )
  
  dev.off()
  
  png("outputs/network_degree_visualization.png", width = 800, height = 600)
  
  plot(
    network,
    vertex.size = 10 + degree(network) * 5,
    vertex.label = V(network)$name,
    edge.width = 2
  )
  
  dev.off()