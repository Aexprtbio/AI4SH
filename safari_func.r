# R functions for the safari script

# getuser : retrieve user from known observers in the safari protocol
getuser <- function(dataset){
dataset$observer <- ""
	for (i in 1:length(dataset$user)) {
	  if (grepl("angemouth", dataset$user[i], ignore.case = TRUE)) {
	    dataset$observer[i] <- "Angelique"
	  } else if (grepl("erick", dataset$user[i], ignore.case = TRUE)) {
	    dataset$observer[i] <- "Eric"
	  } else if (grepl("pirajeths", dataset$user[i], ignore.case = TRUE)) {
	    dataset$observer[i] <- "Pirajeths"
	  } else if (grepl("dacar", dataset$user[i], ignore.case = TRUE)) {
	    dataset$observer[i] <- "Dacar"
	  } else if (grepl("Jerome", dataset$description[i], ignore.case = TRUE)) {
	    dataset$observer[i] <- "Jerome"
	  } else if (grepl("alex", dataset$description[i], ignore.case = TRUE)) {
	    dataset$observer[i] <- "Alex"
	  } else {
	    dataset$observer[i] <- "Laurence"
	  }
	}
}