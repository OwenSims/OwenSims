installRLibraries <- function() {
  libraries <- c("data.table",
                 "expm")
  
  newLibraries <-
    libraries[!(libraries %in% installed.packages()[, "Package"])]
  
  if (length(newLibraries) > 0) {
    install.packages(newLibraries,
                     repos = "http://cran.ma.imperial.ac.uk/")
    
  }
}


initRWorkspace <- function() {
  installRLibraries()
  
  libraries <- c("data.table",
                 "expm")
  
  catch <- capture.output(lapply(libraries,
         library,
         character.only = TRUE))
}

# Remember to source(file = "~/path/to/initRWorkspace.R") and source(file = "~/path/to/networkFunctions.R")
