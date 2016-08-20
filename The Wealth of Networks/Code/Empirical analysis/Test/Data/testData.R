nodeNames <- c("1",
               "2",
               "3",
               "4",
               "5",
               "6",
               "7")

sources <- c(1, 1, 2, 2, 3, 4, 5, 6)
targets <- c(2, 3, 4, 5, 5, 6, 6, 7)

N <- data.frame(number = seq(from = 1,
                             to = length(nodeNames),
                             by = 1),
                nodes = nodeNames)

network <- data.frame(sources = sources,
                      targets = targets)

g <- plot(graph_from_data_frame(network, 
                                directed = TRUE),
          vertex.label.dist = 1.5,
          vertex.size = 10,
          edge.color = "gray50", 
          vertex.color = "orange")



