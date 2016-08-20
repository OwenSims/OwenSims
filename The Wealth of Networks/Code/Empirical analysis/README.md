## About

This directory provides algorithms that correspond to centrality measures discussed in Chapters 5, 6 and 7 of the monograph. In particular, these measures calculate the middleman position, the brokerage, the coverage and criticality of individual and sets of nodes. These measurements are based on game theoretic concepts--such as Strong Nash Equilibrium--which are also contained in the functions. The algorithms are written, and therefore executable, in the R statistical programming language and follow the formulae and mathematics within the monograph.

These directories also contain empirical and synthetic data; some of which is also used within the monograph. This is supplied to allow for testing the centrality measures. 

## Examples

Consider the directed network in `testData1.R`. The network contains 7 nodes--one of which is a source and another is a sink--and 8 arcs that can be interpreted as the flow of information, money, or economic goods: node 1 is connected to node 7 through the intermediation of other nodes in the network. The network of relationships is plotted in the Figure below.

### Middlemen and middleman power

It is pretty obvious from reviewing this network that nodes 2, 5, and 6 are all middlemen. Furthermore, it is noticeable that node 6 would still remain a middleman regardless of whether the network were transformed into its undirected state. We get the following values when running the `middlemanPowerDetail` function.

	number name power normPower             type
	1    1     0       0.0    Non-middleman
	2    2     1       0.1   Weak middleman
	3    3     0       0.0    Non-middleman
	4    4     0       0.0    Non-middleman
	5    5     2       0.2   Weak middleman
	6    6     5       0.5 Strong middleman
	7    7     0       0.0    Non-middleman

As hypothesised we find that nodes 2 and 5 are both weak middlemen and node 6 is a strong middleman. To add to this we also find : (a) the number of relationships brokered by all middleman, and (b) the normalised middleman power for each node. We can represent middlemen visually with the following R commands:

	> colourMiddlemen <- middlemanPowerDetail(network, N)
	> colourMiddlemen$colour <- ifelse(colourMiddlemen$power > 0, "darkred", "lightblue")
	> isTrue <- isUndirected(network, N) == FALSE
	> plot(graph_from_data_frame(network, directed = isTrue), vertex.color = middle$colour, vertex.label.dist = 3, vertex.size = 20, edge.color = "gray50")

In this case, the network is plotted such that middlemen are coloured in red and non-middlemen are coloured in blue. This is seen in the Figure below.


### Block coverage and middleman power

We can analyse sets of nodes from the functions developed in `networkFunctions.R`. Again, these functions align with the measures developed in the monograph; of particular interest is Chapter 6. An overview of the coverage of each node set in the network can be found with the `coverage()` function. Specifically, the coverage of the 7 node network is given by:

	> coverage(network, N)
	set setSize  successors predecessors noSucc noPred coverage
  1:         1       1 2,3,4,5,6,7            0      6      0        0
  2:         2       1     4,5,6,7            1      4      1        4
  3:         3       1       5,6,7            1      3      1        3
  4:         4       1         6,7          1,2      2      2        4
  5:         5       1         6,7        1,2,3      2      3        6
 ---                                                                  
115: 2,3,4,5,7       5           6          1,6      1      2        1
116: 2,3,4,6,7       5           5          1,5      1      2        1
117: 2,3,5,6,7       5           4          1,4      1      2        1
118: 2,4,5,6,7       5                      1,3      0      2        0
119: 3,4,5,6,7       5                      1,2      0      2        0

The brokerage, or middleman power, of each node set can be derived in much the same way. By executing the `blockPower()` function we arrive at the following output:

	> blockPower(network, N)
           set setSize  successors predecessors noSucc noPred power
  1:         1       1 2,3,4,5,6,7            0      6      0     0
  2:         2       1     4,5,6,7            1      4      1     1
  3:         3       1       5,6,7            1      3      1     0
  4:         4       1         6,7          1,2      2      2     0
  5:         5       1         6,7        1,2,3      2      3     2
 ---                                                               
115: 2,3,4,5,7       5           6          1,6      1      2     1
116: 2,3,4,6,7       5           5          1,5      1      2     1
117: 2,3,5,6,7       5           4          1,4      1      2     1
118: 2,4,5,6,7       5                      1,3      0      2     0
119: 3,4,5,6,7       5                      1,2      0      2     0

We can see that a positive coverage does not translate to a positive middleman power. More specifically, the middleman power of a node set is defined on the critical sets of the network. All critical sets are provided with the function `criticalSets()`. The output for the 7 node network is as below:

	> criticalSets(network, N)
          set setSize successors predecessors noSucc noPred power powerCapita
 1:         2       1    4,5,6,7            1      4      1     1       1.000
 2:         5       1        6,7        1,2,3      2      3     2       2.000
 3:         6       1          7    1,2,3,4,5      1      5     5       5.000
 4:       1,5       2  2,3,4,6,7          2,3      5      2     2       1.000
 5:       1,6       2  2,3,4,5,7      2,3,4,5      5      4     4       2.000
 ---
62: 1,3,4,5,7       5        2,6          2,6      2      2     1       0.200
63: 2,3,4,5,6       5          7            1      1      1     1       0.200
64: 2,3,4,5,7       5          6          1,6      1      2     1       0.200
65: 2,3,4,6,7       5          5          1,5      1      2     1       0.200
66: 2,3,5,6,7       5          4          1,4      1      2     1       0.200

This function also provides the middleman power per capita, used in Chapter 6 of the monograph.

### Criticality

A further measure developed within the monograph is that of criticality. The criticality of individual or sets of nodes is a measure of their assumed brokerage after they have been given the ability to form coalitions and actively broker relations. It is therefore a measure based on the resulting stable sets; within the monograph we use the notion of Strong Nash Equilibrium to determine the stability of a coalition within a network. Each network also has some cost of formation.

The 

	> blockSNE(network, N)
   set setSize successors predecessors noSucc noPred power powerCapita
1:   6       1          7    1,2,3,4,5      1      5     5           5
2: 4,5       2        6,7        1,2,3      2      3     6           3
3: 2,3       2    4,5,6,7            1      4      1     4           2



