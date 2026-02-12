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
        grepl("alex", user, ignore.case = TRUE) ~ "Alex",
        grepl("Jerome", description, ignore.case = TRUE) ~ "Jerome",
        grepl("collector1", user, ignore.case = TRUE) ~ "Pierre",
        grepl("collector2", user, ignore.case = TRUE) ~ "Paul",
        grepl("collector3", user, ignore.case = TRUE) ~ "Jacques"      )
    )
  return(dataset)
}




# we need to separate by days of prospect == Obsolete


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
				grepl("47118", ident_taxon_ids, ignore.case=TRUE) ~ 'araneae',
				grepl("48147", ident_taxon_ids, ignore.case=TRUE) ~ 'isopoda',
				grepl("47208", ident_taxon_ids, ignore.case=TRUE) ~ 'coleoptera',
				grepl("49470", ident_taxon_ids, ignore.case=TRUE) ~ 'collembola',
				grepl("1269340", ident_taxon_ids, ignore.case=TRUE) ~ 'ants',
				grepl("61267", ident_taxon_ids, ignore.case=TRUE) ~ 'heteroptera',
				grepl("47735", ident_taxon_ids, ignore.case=TRUE) ~ 'diplopoda',
				grepl("49556", ident_taxon_ids, ignore.case=TRUE) ~ 'chilopoda',
				grepl("62164", ident_taxon_ids, ignore.case=TRUE) ~ 'trichoptera',
				grepl("47114", ident_taxon_ids, ignore.case=TRUE) ~ 'gastropoda',
				grepl("47651", ident_taxon_ids, ignore.case=TRUE) ~ 'orthoptera',
				grepl("1418362", ident_taxon_ids, ignore.case=TRUE) ~ 'earthworm',
				grepl("81769", ident_taxon_ids, ignore.case=TRUE) ~ 'blattodea',
				grepl("52788", ident_taxon_ids, ignore.case=TRUE) ~ 'acari',

				)
			)
}



############################################################
# Working for Finland obs and transect ids

# okay let's build a loop

library(dplyr)
library(stringr)

gettransect <- function(dataset) {
    dataset <- dataset %>%
        mutate(
            transect_id = ifelse(
                grepl("Helsinki", observed_time_zone, ignore.case = TRUE),
                str_extract(description, "^[A-Za-z]{1}\\d{1,2}"),
                description        
                )
        )
    return(dataset)
}


#############################################################
# Build a function to get the order in which samples are found

get.sorder <- function(dataset){
	dataset <- dataset %>%
		mutate(
			sample_order = ifelse(
				grepl("Helsinki", observed_time_zone, ignore.case = TRUE),
				str_extract(description, "\\d+$"),
				NA_character_

				)
			)
		return(dataset)


}





#############################################################
# Function calculating time since first photo

lapsed_time <- function(dataset) {
  dataset <- dataset %>%
    arrange(transect_id, time) %>%
    group_by(transect_id) %>%
    mutate(
      first_obs_time = first(time),
      lapsed_time = as.numeric(difftime(time, first_obs_time, units = "secs"))
    ) %>%
    ungroup()

  return(dataset)
}




#############################################################
# Function retrieving habitats when possible

milieu <- function(dataset) {
	dataset <- dataset %>%
		mutate(
			vegetation = case_when(
				grepl("Ro", transect_id, ignore.case=TRUE) ~ 'forest',
				grepl("forest", description, ignore.case=TRUE) ~ 'forest',
				grepl("Helsinki", observed_time_zone, ignore.case=TRUE) ~ 'crop',
				grepl("meadow", transect_id, ignore.case=TRUE) ~ 'grassland'),
				NA_character_
				
			)
		return(dataset)
}



############################################################
# Get latin name for the species_guess on iNaturalist
library(jsonlite)
library(dplyr)


get.species <- function(dataset){
	dataset<-dataset %>%
	mutate(
		species_guess = str_extract(identifications, "('min_species_taxon_id': \\d+, 'name': ')[^']+")

			
		) %>%
	mutate(
		species_guess = str_replace(species_guess, ".*'name': '", "")

		)
}

library(dplyr)
library(purrr)
library(jsonlite)
library(stringr)

get.family <- function(dataset) {
  dataset <- dataset %>%
    mutate(
      # 1. Convertir en chaîne de caractères
      ident_json = (identifications),

      # 2. Remplacer les valeurs Python par des valeurs JSON
      ident_json = gsub("False", "false", ident_json),
      ident_json = gsub("True", "true", ident_json),
      ident_json = gsub("None", "null", ident_json),

      # 3. Remplacer les quotes simples par des doubles quotes
      ident_json = gsub("'", '"', ident_json),

      # 4. Séparer chaque JSON individuel (chaque bloc entre crochets)
      json_list = str_split(ident_json, "\\[|\\]"),

      # 5. Nettoyer les éléments vides et parser chaque JSON
      parsed = map(json_list, ~ {
        # Filtrer les chaînes non vides
        json_strings <- .x[nzchar(.x)]

        # Parser chaque JSON individuel
        map(json_strings, ~ {
          tryCatch(
            {
              # Ajouter les crochets manquants pour reformer un JSON valide
              json_str <- paste0("{", .x, "}")
              fromJSON(json_str)
            },
            error = function(e) {
              message("Erreur de parsing pour : ", substr(.x, 1, 100), "...")
              NULL
            }
          )
        })
      })
    )

  return(dataset)
}

# Assuming 'identifications' is a column of JSONs


get.filter <- function(dataset){
	dataset <- dataset %>%
  filter(!is.na(identifications) & grepl("\\]$", identifications))


}