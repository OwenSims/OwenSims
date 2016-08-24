nodeNames <- c("Albizzi",
               "Aldobrandini",
               "Altoviti",
               "Baroncelli",
               "Benizzi",
               "Bisheri",
               "Castellani",
               "C-Donati",
               "DaUzzano",
               "Dall'Antella",
               "Davanzati",
               "DellaCasa",
               "Dietisalvi",
               "Fioravanti",
               "Ginori",
               "Guadagni",
               "Guicciardini",
               "Lamberteschi",
               "Medici",
               "Orlandini",
               "Panciatichi",
               "Pazzi",
               "Pepi",
               "Peruzzi",
               "Rondinelli",
               "Rucellai",
               "Scambrilla",
               "Solosmei",
               "Strozzi",
               "Tornabuoni",
               "Valori",
               "Velluti")

sources <- c(14, 16, 11, 31, 10, 15, 17, 19, 22, 19, 22, 9, 1, 1, 22, 29, 5, 12, 1, 21, 29, 24, 24, 24, 29, 24, 7, 7, 7, 25, 19)
targets <- c(16, 6, 20, 8, 15, 13, 19, 30, 19, 1, 9, 22, 22, 3, 29, 26, 29, 1, 24, 1, 21, 12, 21, 22, 24, 7, 25, 27, 23, 22, 15)

N <- data.frame(number = seq(from = 1,
                             to = length(nodeNames),
                             by = 1),
                nodes = nodeNames)

network <- data.frame(sources = sources,
                      targets = targets)
