# Set up the libraries and all that jazz

rm(list = ls())
setwd("~/Dropbox/Projects/R Network Tutorials/Examples/New York Directors/institutions")

if(!require(networkD3)) {
  install.packages("networkD3")
  library(networkD3)
} else {
  library(networkD3)
}

# Load up and clean up the Node List and Edge List for the network

nodeList <- read.csv(file = "Institution Node List.csv", header = TRUE, sep = ",")
nodeList$value100 <- nodeList$Value/1000000
colnames(nodeList) <- c("id", "name", "group", "value", "value100")
nodeList$group <- nodeList$group - 1

edgeList <- read.csv(file = "Institution Edge List.csv", header = TRUE, sep = ",")
colnames(edgeList) <- c("source", "target", "type", "id", "label", "weight")

edgeList$label <- edgeList$type <- edgeList$id <- NULL

# Remove all nodes (institutions) that have no interlock

for (i in nrow(nodeList):1) {
  if ((is.na(match(nodeList$id[i], edgeList$source))) & (is.na(match(nodeList$id[i], edgeList$target)))) {
    nodeList <- nodeList[-c(i),]
  }
}

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

# Generate the network

NYinstitutions <- forceNetwork(Links = edgeList, Nodes = nodeList, Source = "source",
             Target = "target", Value = "weight", NodeID = "name",
             Group = "group", Nodesize = "value100", colourScale = JS("d3.scale.category10()"),
             fontSize = 12, fontFamily = "sans",
             linkDistance = 200, opacity = 0.85, zoom = TRUE)

