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
        grepl("Jerome", description, ignore.case = TRUE) ~ "Jerome",
        grepl("alex", description, ignore.case = TRUE) ~ "Alex",
        grepl("2025-05", observed_on_string, ignore.case = TRUE) ~ "Alex",
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
	  } else if (grepl("2025-05-17", soil$observed_on_string[i], ignore.case = TRUE)) {
	    soil$day[i] <- "day6"
	  } else {
	  	soil$day[i] <- "out"
	  }
	}

soil <- subset(soil, soil$day != "out")

}


# now we create a func to auto-assignate Tribes with GSMF taxa groups

# correspondances

# 47118 = Araneae
# 48147 = Isopoda
# 47208 = Coleoptera
# 49470 = Collembola
# 1269340 = Ants
# 61267 = Heteroptera
# 47735 = Diplopoda
# 49556 = Chilopoda
# 62164 = Trichoptera
# 47114 = Gastropoda
# 47651 = Orthoptera
# 1418362 = Lumbricina
# 81769 = Blattodea

gettaxa <- function(dataset){
	dataset <- dataset %>%
		mutate(
			taxa = case_when(
				grepl("47118", ident_taxon_ids, ignore.case=TRUE) ~ 'd_araneae',
				grepl("48147", ident_taxon_ids, ignore.case=TRUE) ~ 'd_isopoda',
				grepl("47208", ident_taxon_ids, ignore.case=TRUE) ~ 'd_coleoptera',
				grepl("49470", ident_taxon_ids, ignore.case=TRUE) ~ 'd_collembola',
				grepl("1269340", ident_taxon_ids, ignore.case=TRUE) ~ 'd_ants',
				grepl("61267", ident_taxon_ids, ignore.case=TRUE) ~ 'd_heteroptera',
				grepl("47735", ident_taxon_ids, ignore.case=TRUE) ~ 'd_diplopoda',
				grepl("49556", ident_taxon_ids, ignore.case=TRUE) ~ 'd_chilopoda',
				grepl("62164", ident_taxon_ids, ignore.case=TRUE) ~ 'd_trichoptera',
				grepl("47114", ident_taxon_ids, ignore.case=TRUE) ~ 'd_gastropoda',
				grepl("47651", ident_taxon_ids, ignore.case=TRUE) ~ 'd_orthoptera',
				grepl("1418362", ident_taxon_ids, ignore.case=TRUE) ~ 'd_earthworms',
				grepl("81769", ident_taxon_ids, ignore.case=TRUE) ~ 'd_blattodea',
				grepl("52788", ident_taxon_ids, ignore.case=TRUE) ~ 'd_acari',

				)
			)
}