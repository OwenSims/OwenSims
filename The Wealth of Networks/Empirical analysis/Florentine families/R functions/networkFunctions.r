numberToName <- function(nodeNumbers, nodeNames) {
  translation <- ""
  
  translation <- sapply(1:length(nodeNumbers),
                        function(x) {
                          match <- match(nodeNumbers[x], nodeNames[, 1])
                          
                          translation[x] <-
                            as.character(nodeNames[match, 2])
                        })
  return(translation)
}


adjacenyMatrix <- function(network, nodeNames) {
  networkMatrix <- matrix(
    data = 0L,
    nrow = nrow(nodeNames),
    ncol = nrow(nodeNames)
  )
  
  for (i in 1:nrow(network)) {
    networkMatrix[network[i, 1], network[i, 2]] <-
      networkMatrix[network[i, 1], network[i, 2]] + 1
  }
  return(networkMatrix)
  
}


undirectedAdjMatrix <- function(network, nodeNames, adjMatrix) {
  if (missing(adjMatrix)) {
    adjMatrix <- adjacenyMatrix(network,
                                nodeNames)
  }
  
  adjMatrix[, ] <- !adjMatrix %in% c("0",
                                     "FALSE")
  
  adjMatrix <- adjMatrix  + t(adjMatrix)
  
  return(adjMatrix)
  
}


adjacenyDF <- function(network, nodeNames) {
  networkDF <- adjacenyMatrix(network = network,
                              nodeNames = nodeNames)
  
  networkDF <- as.data.frame.matrix(networkDF)
  
  colnames(networkDF) <- rownames(networkDF) <- nodeNames[, 2]
  
  return(networkDF)
  
}


degree <- function(network, nodeNames) {
  inDeg <- outDeg <- degree <- 0
  
  for (i in 1:nrow(nodeNames)) {
    inDeg[i] <- sum(network[, 2] == i)
    outDeg[i] <- sum(network[, 1] == i)
    neighbours <- c(subset(network[, 2], network[, 1] == i),
                    subset(network[, 1], network[, 2] == i))
    degree[i] <- length(unique(neighbours))
  }
  
  Deg <- data.frame(
    name = nodeNames[, 2],
    inDegree = inDeg,
    outDegree = outDeg,
    degree = degree
  )
  
  return(Deg)
}


connectivity <- function(network, nodeNames, adjMatrix) {
  if (missing(adjMatrix)) {
    adjMatrix <- adjacenyMatrix(network,
                                nodeNames)
  }
  
  adjMatrix[, ] <- !adjMatrix %in% c("0",
                                     "FALSE")
  
  for (i in 1:nrow(adjMatrix)) {
    adjMatrix <- adjMatrix + (adjMatrix %^% i)
    adjMatrix[, ] <- !adjMatrix %in% c("0",
                                       "FALSE")
  }
  
  for (i in 1:nrow(adjMatrix)) {
    adjMatrix[i, i] <- 0
  }
  
  k <- sum(adjMatrix)
  
  return(k)
  
}


predecessorsSuccessors <- function(network, nodeNames, adjMatrix) {
  if (missing(adjMatrix)) {
    adjMatrix <- adjacenyMatrix(network,
                                nodeNames)
  }
  
  adjMatrix[, ] <- !adjMatrix %in% c("0",
                                     "FALSE")
  
  for (i in 1:nrow(adjMatrix)) {
    adjMatrix <- adjMatrix + (adjMatrix %^% i)
    adjMatrix[, ] <- !adjMatrix %in% c("0",
                                       "FALSE")
  }
  
  for (i in 1:nrow(adjMatrix)) {
    adjMatrix[i, i] <- 0
  }
  
  noSuccessors <- noPredecessors <- 0
  
  for (i in 1:nrow(adjMatrix)) {
    noSuccessors[i] <- length(which(adjMatrix[i, ] == 1))
    noPredecessors[i] <- length(which(adjMatrix[, i] == 1))
  }
  
  adjMatrix <- adjacenyMatrix(network,
                              nodeNames)
  
  noPredecessorsSuccessors <-
    data.frame(
      nodeNumber = seq(1, nrow(adjMatrix)),
      nodeName = nodeNames[, 2],
      noPred = noPredecessors,
      noSucc = noSuccessors
    )
  
  return(noPredecessorsSuccessors)
  
}


potentialBrokerage <- function(network, nodeNames, adjMatrix) {
  d <- degree(network, nodeNames)
  PS <- predecessorsSuccessors(network, nodeNames, adjMatrix)
  
  potBrokerage <- 0
  
  for (i in 1:nrow(nodeNames)) {
    potBrokerage <- potBrokerage + (PS$noSucc[i] - d$outDegree[i])
  }
  
  potBrokerage <- max(potBrokerage, 1)
  
  return(potBrokerage)
}


middlemanPower <- function(network, nodeNames, adjMatrix) {
  if (missing(adjMatrix)) {
    originalAdjMatrix <- adjMatrix <- adjacenyMatrix(network, nodeNames)
  } else {
    originalAdjMatrix <- adjMatrix
  }
  
  PS <- predecessorsSuccessors(network, nodeNames, adjMatrix)
  
  K <- connectivity(adjMatrix = originalAdjMatrix)
  
  power <- 0
  
  for (i in 1:nrow(adjMatrix)) {
    adjMatrix <- originalAdjMatrix
    
    adjMatrix[i,] <- adjMatrix[, i] <- 0
    
    kappa <- connectivity(adjMatrix = adjMatrix)
    
    power[i] <- K - kappa - PS$noPred[i] - PS$noSucc[i]
    
  }
  
  potBroker <- potentialBrokerage(network, nodeNames)
  
  power <- round(power/as.integer(potBroker),
                 digits = 3)
  
  return(power)
}


strongWeak <- function(network, nodeNames, adjMatrix) {
  if (missing(adjMatrix)) {
    adjMatrix <- adjacenyMatrix(network, nodeNames)
    
  }
  power <- middlemanPower(network, nodeNames, adjMatrix)
  
  unAdjMatrix <- undirectedAdjMatrix(network, nodeNames, adjMatrix)
  
  unPower <- middlemanPower(network, nodeNames, unAdjMatrix)
  
  middlemanType <- sapply(1:length(power), function(x) {
    if (unPower[x] == 0 & power[x] == 0) {
      "Non-middleman"
    } else if (unPower[x] == 0 & power[x] > 0) {
      "Weak middleman"
    } else {
      "Strong middleman"
    }
  })
  
  return(middlemanType)
  
}

middlemanPowerDetail <- function(network, nodeNames, adjMatrix) {
  if (missing(adjMatrix)) {
    adjMatrix <- adjacenyMatrix(network, nodeNames)
    
  }
  power <- middlemanPower(network, nodeNames, adjMatrix)
  type <- strongWeak(network, nodeNames, adjMatrix)
  
  details <- data.frame(number = nodeNames[,1],
                        name = nodeNames[,2],
                        power = power,
                        type = type)
  
  return(details)
  
}


setPredSucc <- function(network, nodeNames, adjMatrix) {
  if (missing(adjMatrix)) {
    adjMatrix <- adjacenyMatrix(network,
                                nodeNames)
  }
  
  adjMatrix[, ] <- !adjMatrix %in% c("0",
                                     "FALSE")
  
  for (i in 1:nrow(adjMatrix)) {
    adjMatrix <- adjMatrix + (adjMatrix %^% i)
    adjMatrix[, ] <- !adjMatrix %in% c("0",
                                       "FALSE")
  }
  
  for (i in 1:nrow(adjMatrix)) {
    adjMatrix[i, i] <- 0
  }
  
  for (i in 1:nrow(adjMatrix)) {
    
    sets <- combn(seq(1:nrow(adjMatrix)), m = i)
    
    for (j in 1:ncol(sets)) {
      set <- sets[, j]
      
      successors <- predecessors <- noSucc <- noPred <- 0
      
      for (k in 1:i) {
        successors <- c(successors, which(adjMatrix[set[k], ] == 1))
        predecessors <- c(predecessors, which(adjMatrix[, set[k]] == 1))
      }
      
      if (length(successors) > 1) {
        successors <- setdiff(unique(successors), c(set, 0))
        noSucc <- length(successors)
      } else {
        successors <- noSucc <- 0
      }

      if (length(predecessors) > 1) {
        predecessors <- setdiff(unique(predecessors), c(set, 0))
        noPred <- length(predecessors) 
      } else {
        predecessors <- noPred <- 0
      }
      
      if (i == 1 & j == 1 & k == 1) {
        
        PS <- list(set = list(set), 
                   successors = list(successors), 
                   predecessors = list(predecessors), 
                   noSucc = list(noSucc), 
                   noPred = list(noPred))
        
      } else {
        
        a <- list(set = list(set),
                  successors = list(successors), 
                  predecessors = list(predecessors), 
                  noSucc = list(noSucc), 
                  noPred = list(noPred))
        
        PS <- rbindlist(list(PS, a), 
                        use.names = TRUE, 
                        fill = TRUE)
        
      }
  
    }
    
  }
  
  return(PS)
  
}


