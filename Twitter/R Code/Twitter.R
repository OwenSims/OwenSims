rm(list = ls())

if(!require(twitteR)) {
  install.packages("twitteR", repos = "http://cran.ma.imperial.ac.uk/" )
  library(twitteR)
} else {
  library(twitteR)
}

if(!require(igraph)) {
  install.packages("igraph", repos = "http://cran.ma.imperial.ac.uk/" )
  library(igraph)
} else {
  library(igraph)
}

# Create a Twitter App at https://apps.twitter.com: SuperTwittR
# Get the authorisation codes and set up Twitter authorisation

consumer_key <- "Z8N4dXiQ0qgrH7j4uhHj3dUyo"
consumer_secret <- "wKwsU8medGB0L0sWMFe3EEQaII9NpA4mLSWtKagY4jHyHlxe9b"
access_token <- "19158313-uLqqn6Qz2PVfHGBPVO49i4CJoxgF7avuKA27amO0h"
access_secret <- "DcIX4LTaP847sCibRjAwbG6q450HI6Jta3b26CdWoC4Ah"

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

me <- getUser("Superyayz")

following <- lookupUsers(me$getFriendIDs())
followed <- lookupUsers(me$getFollowerIDs())

n <- length(following)
m <- length(followed)
friends <- sapply(following[1:n],name)
followers <- sapply(followed[1:m],name)


# Create a data frame that relates friends and followers to you for expression in the graph
relations <- merge(data.frame(User='Owen Sims', Follower=friends), 
                   data.frame(User=followers, Follower='Owen Sims'), all=T)

# Create graph from relations.
g <- graph.data.frame(relations, directed = TRUE)

# Assign labels to the graph (=people's names)
V(g)$label <- V(g)$name

# Plot the twitter network
plot(g)