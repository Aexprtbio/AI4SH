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



# we need to separate by days of prospect

soil$day = ""
getday <- function(dataset){
	for (i in 1:length(soil$observed_on_string)) {
	  if (grepl("2023-04-17", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "day1"
	  } else if (grepl("2023-04-18", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "day2"
	  } else if (grepl("2023-04-20", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "day3"
	  } else if (grepl("2023-04-30", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "out"
	  } else {
	    soil$day[i] <- "day4"
	  }
	}

soil <- subset(soil, soil$day != "out")

}