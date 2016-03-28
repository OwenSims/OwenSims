# Set up the libraries and all that jazz

rm(list = ls())

if(!require(networkD3)) {
  install.packages("networkD3", repos = "http://cran.ma.imperial.ac.uk/" )
  library(networkD3)
} else {
  library(networkD3)
}

# Load up `Node List` and `Edge List` for the network

nodeList <- read.csv(file = "http://owensims.co.uk/projects/FlorentineFamilies/FlorentineFamilies.csv", header = TRUE, sep = ",")
edgeList <- read.csv(file = "http://owensims.co.uk/projects/FlorentineFamilies/MarriageLinks.csv", header = TRUE, sep = ",")

# Clean up the `Node List` and `Edge List` for networkD3

nodeList$Lat <- nodeList$lat10 <- nodeList$Long <- nodeList$long10 <- NULL
nodeList$Gross.Wealth <- nodeList$Gross.Wealth/10000
colnames(nodeList) <- c("id", "name", "faction", "wealth", "brokerage")
colnames(edgeList) <- c("source", "target", "weight")

# Rebase node IDs for analysis

nodeList$newID <- data.frame(seq(1:nrow(nodeList)) - 1)
colnames(nodeList[, ncol(nodeList)]) <- "newID"

for (i in 1:nrow(nodeList)) {
  for (j in 1:nrow(edgeList)) {
    if (nodeList$id[i] == edgeList$source[j]) {
      edgeList$source[j] <- nodeList$newID[i]
    }
    if (nodeList$id[i] == edgeList$target[j]) {
      edgeList$target[j] <- nodeList$newID[i]
    }
  }
}

# Generate the Florentine marriage network

forceNetwork(Links = edgeList, Nodes = nodeList, Source = "source",
             Target = "target", Value = "weight", NodeID = "name",
             Group = "faction", colourScale = JS("d3.scale.category10()"),
             fontSize = 14, legend = FALSE, fontFamily = "Helvetica", opacityNoHover = TRUE, height = 600,
             width = 600, linkColour = "#888", linkDistance = 250, Nodesize = "wealth", opacity = 0.9, zoom = TRUE)
