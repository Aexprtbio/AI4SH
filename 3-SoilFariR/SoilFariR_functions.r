# R functions for the safari script -------------------------------------
####################### Processing data #################################
# getuser : retrieve user from known observers in the safari protocol
library(dplyr)

getuser <- function(dataset) {
  dataset <- dataset %>%
    mutate(
      observer = case_when(
        grepl("angemouth", user, ignore.case = TRUE) ~ "Angelique",
        grepl("eric", user, ignore.case = TRUE) ~ "Eric",
        grepl("pirajeths", user, ignore.case = TRUE) ~ "Pirajeths",
        grepl("laurence", description, ignore.case = TRUE) ~ "Laurence",
        grepl("Jerome", description, ignore.case = TRUE) ~ "Jerome",
        grepl("alex", user, ignore.case = TRUE) ~ "Alex",
        grepl("collector1", user, ignore.case = TRUE) ~ "Pierre",
        grepl("collector2", user, ignore.case = TRUE) ~ "Paul",
        grepl("collector3", user, ignore.case = TRUE) ~ "Jacques"      )
    )
  return(dataset)
}

#function for inaturalist to find which method was used:
getmethod <- function(dataset) {
	dataset <- dataset %>%
    mutate(
      saf_method = case_when(
        grepl("-SW|Sit|wait", description, ignore.case = TRUE) ~ "Sit-Wait",
        grepl("-R|Rand|rand", description, ignore.case = TRUE) ~ "Random",
        grepl("-T|transect", description, ignore.case=TRUE) ~ "Transect"
        )
      )


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
# 1418362|69758|333586 = Lumbricina
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
				grepl("47157", ident_taxon_ids, ignore.case=TRUE) ~ 'lepidoptera',
				grepl("61267", ident_taxon_ids, ignore.case=TRUE) ~ 'heteroptera',
				grepl("47735", ident_taxon_ids, ignore.case=TRUE) ~ 'diplopoda',
				grepl("49556", ident_taxon_ids, ignore.case=TRUE) ~ 'chilopoda',
				grepl("84638", ident_taxon_ids, ignore.case=TRUE) ~ 'symphyla',
				grepl("62164", ident_taxon_ids, ignore.case=TRUE) ~ 'trichoptera',
				grepl("47114", ident_taxon_ids, ignore.case=TRUE) ~ 'gastropoda',
				grepl("47651", ident_taxon_ids, ignore.case=TRUE) ~ 'orthoptera',
				grepl("1418362|69758|333586", ident_taxon_ids, ignore.case=TRUE) ~ 'earthworm',
				grepl("81769", ident_taxon_ids, ignore.case=TRUE) ~ 'blattodea',
				grepl("52788", ident_taxon_ids, ignore.case=TRUE) ~ 'acari',

				)
			)
}

############################################################
# Working for Finland obs and transect ids
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
				grepl("meadow", transect_id, ignore.case=TRUE) ~ 'grassland',
        grepl("angelique|eric|laurence|jerome|alex", observer, ignore.case=TRUE) ~ "forest"
        )
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


########################## Create sorensen matrix #################################

sorensen <- function(dataset, matrice, transect=transect_id){
  #créer une matrice aux dimensions des noms de transects
  sormat <- matrix(nrow=length(levels(dataset$transect)), 
    ncol=length(levels(dataset$transect)), 
    dimnames=list(levels(dataset$transect),levels(dataset$transect)))

  print(paste("Dimensions of end matrix: ", dim(sormat)[1], "x", dim(sormat)[2]))
  i=1
  j=1
  x = 1
  y = 1
  dims = dim(matrice)
  print(paste("Dimensions in entry matrix: ", dims[1], "x", dims[2]))
  print("---------------------------------------------------")

  #assigner à chaque case de la matrice le résultat de l'indice de sorensen
  while (i < dims[1]+1){
    S1 = 0
    S2 = 0
    c = 0

    # values for sorensen matrix coordinates
    # reset values for communities
    while (j < dims[2]+1){
      # if else
      print(paste("commu 1:", matrice[i,j], "commu 2:", matrice[i+1,j]))
      if (matrice[i,j]*matrice[i+1,j] > 0){
        S1 = S1 + 1
        S2 = S2 + 1
        c = c + 1
      }
      else if (matrice[i,j] > matrice[i+1,j]){
        S1 = S1 + 1
        S2 = S2
        c = c
      }
      else if (matrice[i,j] < matrice[i+1,j]){
        S1 = S1
        S2 = S2 + 1
        c = c
      }
      j = j + 1
      print(paste("S1: ", S1, "S2: ", S2, "c: ", c))


    }
    sorensen <- ((2*c) / (S1+S2))
    print(sorensen)
    sormat[x,y] <- sorensen
    y = y + 1
    x = x + 1
    i=i+1
  }
  return(sormat)

}