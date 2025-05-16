# R functions for the safari script

# getuser : retrieve user from known observers in the safari protocol
library(dplyr)

getuser <- function(dataset) {
  dataset <- dataset %>%
    mutate(
      observer = case_when(
        grepl("angemouth", user, ignore.case = TRUE) ~ "Angelique",
        grepl("erick", user, ignore.case = TRUE) ~ "Eric",
        grepl("pirajeths", user, ignore.case = TRUE) ~ "Pirajeths",
        grepl("dacar", user, ignore.case = TRUE) ~ "Dacar",
        grepl("Jerome", session, ignore.case = TRUE) ~ "Jerome",
        grepl("alex", session, ignore.case = TRUE) ~ "Alex",
        TRUE ~ "Laurence"
      )
    )
  return(dataset)
}




# we need to separate by days of prospect


getday <- function(dataset){

soil$day = ""

	for (i in 1:length(soil$observed_on_string)) {
	  if (grepl("2023-04-17", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "day1"
	  } else if (grepl("2023-04-18", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "day2"
	  } else if (grepl("2023-04-20", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "day3"
	  } else if (grepl("2023-04-30", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "out"
	  } else if (grepl("2025-05-14", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "day4"
	  } else if (grepl("2025-05-16", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "day5"
	  } else {
	  	soil$day[i] <- "out"
	  }
	}

soil <- subset(soil, soil$day != "out")

}