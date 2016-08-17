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


isUndirected <- function(network, nodeNames, adjMatrix) {
  if (missing(adjMatrix)) {
    adjMatrix <- adjacenyMatrix(network, nodeNames)
  }

  return(FALSE %in% (adjMatrix == t(adjMatrix)) == FALSE)

}


undirectedAdjMatrix <- function(network, nodeNames, adjMatrix) {
  if (missing(adjMatrix)) {
    adjMatrix <- adjacenyMatrix(network,
                                nodeNames)
  }

  adjMatrix <- adjMatrix  + t(adjMatrix)

  adjMatrix[, ] <- !adjMatrix %in% c("0",
                                     "FALSE")

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

  library(expm)

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

  PS <- predecessorsSuccessors(network = network,
                               nodeNames = nodeNames,
                               adjMatrix = adjMatrix)

  K <- connectivity(adjMatrix = originalAdjMatrix)

  power <- 0

  for (i in 1:nrow(adjMatrix)) {
    adjMatrix <- originalAdjMatrix

    adjMatrix[i, ] <- adjMatrix[, i] <- 0

    kappa <- connectivity(adjMatrix = adjMatrix)

    power[i] <- K - kappa - PS$noPred[i] - PS$noSucc[i]

  }

  potBroker <- potentialBrokerage(network, nodeNames)

  power <- round(power / as.integer(potBroker),
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

  details <- data.frame(
    number = nodeNames[, 1],
    name = nodeNames[, 2],
    power = power,
    type = type
  )

  return(details)

}


setPredSucc <- function(network, nodeNames, s, adjMatrix) {
  if (missing(s)) {
    s <- nrow(nodeNames) - 2
  }

  if (s > nrow(nodeNames) - 2) {
    return(
      print(
        "s must be less than or equal to number of nodes in network minus 2 [s <= nrow(nodeNames) - 2]"
      )
    )
  }

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

  for (i in 1:s) {
    sets <- combn(seq(1:nrow(adjMatrix)),
                  m = i)

    setSize <- i

    for (j in 1:ncol(sets)) {
      set <- sets[, j]

      successors <- predecessors <-
        noSucc <- noPred <- 0

      for (k in 1:i) {
        successors <-
          c(successors, which(adjMatrix[set[k], ] == 1))
        predecessors <-
          c(predecessors, which(adjMatrix[, set[k]] == 1))
      }

      if (length(successors) > 1) {
        successors <- setdiff(unique(successors),
                              c(set,
                                0))
        noSucc <- length(successors)
      } else {
        successors <- noSucc <- 0
      }

      if (length(predecessors) > 1) {
        predecessors <- setdiff(unique(predecessors),
                                c(set,
                                  0))
        noPred <- length(predecessors)
      } else {
        predecessors <- noPred <- 0
      }

      if (i == 1 & j == 1 & k == 1) {
        PS <- list(
          set = list(set),
          setSize = setSize,
          successors = list(successors),
          predecessors = list(predecessors),
          noSucc = list(noSucc),
          noPred = list(noPred)
        )

      } else {
        a <- list(
          set = list(set),
          setSize = setSize,
          successors = list(successors),
          predecessors = list(predecessors),
          noSucc = list(noSucc),
          noPred = list(noPred)
        )

        PS <- rbindlist(list(PS,
                             a),
                        use.names = TRUE,
                        fill = TRUE)

      }

    }

  }
  return(PS)

}


coverage <-
  function(network,
           nodeNames,
           s,
           adjMatrix,
           setPS,
           perCapita) {
    if (missing(s)) {
      s <- nrow(nodeNames) - 2
    }

    if (missing(perCapita)) {
      perCapita <- FALSE
    }

    if (missing(adjMatrix)) {
      originalAdjMatrix <- adjMatrix <- adjacenyMatrix(network, nodeNames)
    } else {
      originalAdjMatrix <- adjMatrix
    }

    if (missing(setPS)) {
      setPS <- setPredSucc(network, nodeNames, s, adjMatrix)
    }

    ps <- setPredSucc(network, nodeNames, s = 1)

    coverage <- 0

    for (i in 1:nrow(setPS)) {
      for (h in 1:length(setPS$set[[i]])) {
        if (h == 1) {
          cov <-
            expand.grid(c(setdiff(ps$predecessors[[setPS$set[[i]][h]]], setPS$set[[i]])),
                        c(setdiff(ps$successors[[setPS$set[[i]][h]]], setPS$set[[i]])))
        } else {
          cov <-
            rbind(cov, expand.grid(c(
              setdiff(ps$predecessors[[setPS$set[[i]][h]]], setPS$set[[i]])
            ),
            c(
              setdiff(ps$successors[[setPS$set[[i]][h]]], setPS$set[[i]])
            )))
        }

      }

      row_sub = apply(cov, 1, function(row) all(row != 0))
      cov <- cov[row_sub, ]

      if (nrow(cov) > 0) {
        for (j in 1:nrow(cov)) {
          if (cov[j, 1] == cov[j, 2]) {
            cov[j, 1] <- cov[j, 2] <- 0
          }
        }
      }


      row_sub = apply(cov, 1, function(row) all(row != 0))
      cov <- cov[row_sub, ]

      coverage[i] <- nrow(unique(cov[, ]))

    }

    setPS$coverage <- coverage

    return(setPS)

  }


blockPower <-
  function(network,
           nodeNames,
           s,
           adjMatrix,
           setPS,
           perCapita) {
    if (missing(s)) {
      s <- nrow(nodeNames) - 2
    }

    if (missing(perCapita)) {
      perCapita <- FALSE
    }

    if (missing(adjMatrix)) {
      originalAdjMatrix <- adjMatrix <- adjacenyMatrix(network, nodeNames)
    } else {
      originalAdjMatrix <- adjMatrix
    }

    if (missing(setPS)) {
      setPS <- setPredSucc(network, nodeNames, s, adjMatrix)
    }

    K <- connectivity(adjMatrix = originalAdjMatrix)

    setPS$power <- 0

    for (i in 1:nrow(setPS)) {
      adjMatrix <- originalAdjMatrix

      K <- allSucc <- 0

      for (j in 1:nrow(nodeNames)) {
        if (!(length(setPS$successors[[j]]) == 0 ||
              setPS$successors[[j]] == 0)) {
          if (!(j %in% setPS$set[[i]])) {
            inSet <- setPS$set[[i]] %in% setPS$successors[[j]]

            noSet <- sum(inSet == TRUE)

            if (noSet > 0) {
              l <- length(setPS$successors[[j]]) - noSet + 1
              K <- K + l

            } else {
              K <- K + length(unique(setPS$successors[[j]]))

            }

          } else {
            allSucc <- c(allSucc, setPS$successors[[j]])

          }

        }

      }

      K <- K + length(setdiff(unique(allSucc), setPS$set[[i]])) - 1

      for (j in 1:length(setPS$set[[i]])) {
        adjMatrix[setPS$set[[i]][j], ] <-
          adjMatrix[, setPS$set[[i]][j]] <- 0

      }

      kappa <- connectivity(adjMatrix = adjMatrix)

      setPS$power[i] <-
        K - kappa - setPS$noSucc[[i]] - setPS$noPred[[i]]

    }

    potBroker <- potentialBrokerage(network = network,
                                    nodeNames = nodeNames)

    setPS$power <- round(setPS$power / 1,
                         digits = 3)

    if (perCapita == TRUE) {
      setPS$powerCapita <- round(setPS$power / setPS$setSize,
                                 digits = 3)
    }

    return(setPS)

  }


criticalSets <-
  function(network,
           nodeNames,
           s,
           adjMatrix,
           setPS,
           setPower) {
    if (missing(setPower)) {
      setPower <-
        blockPower(network, nodeNames, s, adjMatrix, setPS, perCapita = TRUE)
    }

    criticalSets <- subset(setPower,
                       setPower$power > 0)

    return(criticalSets)

  }


coverageMeasure <- function(network, nodeNames, s, adjMatrix, setPS, setPower) {

  crits <- criticalSets(network, nodeNames)

  critsCov <- coverage(network, nodeNames, setPS = crits)

  critsCov$coverageMeasure <- round(critsCov$coverage / critsCov$setSize,
                                    digits = 3)

  return(critsCov)

}


blockSNE <-
  function(network, nodeNames, s, adjMatrix, setPS, setPower) {
    if (missing(setPower)) {
      setPower <-
        blockPower(network, nodeNames, s, adjMatrix, setPS, perCapita = TRUE)
    }

    setPower <- subset(setPower,
                       setPower$power > 0)

    setPower <- setPower[order(-setPower$powerCapita), ]

    for (i in 1:(nrow(setPower) - 1)) {
      for (j in (i + 1):nrow(setPower)) {
        if (setPower$setSize[j] != 0) {
          if (TRUE %in% (setPower$set[[i]] %in% setPower$set[[j]])) {
            setPower$set[[j]] <- setPower$setSize[j] <- 0
          }
        }
      }
    }

    SNE <- setPower[!(setPower$setSize == 0),]

    return(SNE)

  }


criticalityMeasure <- function(network, nodeNames, s, adjMatrix, setPS, setPower) {
  critMeasure <- blockSNE(network, nodeNames)

  colnames(critMeasure) <- c("set", "setSize", "successors", "predecessors", "noSucc", "noPred", "criticality", "criticalityMeasure")

  return(critMeasure)

}


nodeCriticality <- function(network, nodeNames, s, adjMatrix, setPS, setPower) {
  critMeasure <- blockPower(network,
                            nodeNames,
                            perCapita = TRUE)

  nodeCriticality <- 0

  for (i in 1:nrow(nodeNames)) {
    s <- critMeasure

    t <- sapply(1:nrow(s),
                function(x) i %in% s$set[[x]])
    s <- s[t, ]

    nodeCriticality[i] <- sum(s$powerCapita)

  }

  return(nodeCriticality)

}

