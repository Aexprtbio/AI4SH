### CREATED BY ALEXI PRETAT
# 1/04/2025

# LAST UPDATE : 1/04/2025

# open shell in panel
# source AlexPI/bin/activate
# python
# copy paste script

import sys
print(sys.path)

print('\n -------------------------------')

import requests
import pandas as pd
import numpy as np

# Remplacez par l'ID de l'observation que vous souhaitez récupérer
# observation_id = '233923594'

project_id = '156800'

# taxon_id = '372739' # taxon ID for Hexapoda

######
# europe place ID : 97391
######


# URL de l'API pour récupérer les observations du projet mentionne
url=f'https://api.inaturalist.org/v1/observations?project_id=156800&order=d\
esc'

# hexurl = f'https://api.inaturalist.org/v1/taxa/{taxon_id}' # with this we get just general
                                                           # info on hexapoda

# Effectuer la requête GET
response = requests.get(url)

print("requete envoyee")

# Vérifier le statut de la réponse
if response.status_code == 200:
    data = response.json()
    print('requete reçue')
    # Afficher les informations de l'observation
    print(data)
else:
    print(f"Erreur: {response.status_code}")



##############################
# Lets get to the next level


def getobs_bytax(project_id, per_page=200):
    base_url=f'https://api.inaturalist.org/v1/observations?project_id={project_id}&order=desc'
    params = {
        'project_id': project_id,
        'per_page': per_page,
        'page': 1
    }

    all_observations = []

    while True:
        response = requests.get(base_url, params=params)
        data = response.json()

        # Ajouter les observations à la liste
        all_observations.extend(data['results'])

        # Vérifier s'il y a plus de pages
        if len(data['results']) < per_page:
            break

        # Passer à la page suivante
        params['page'] += 1

    # Convertir les observations en DataFrame
    observations_df = pd.DataFrame(all_observations)
    return observations_df


print('\n -------------------------------')

project_id=156800 # trying with eristalis cryptarum (only 115 obs on inat)
soil=getobs_bytax(project_id)

soil[["latitude", "longitude"]] = soil["location"].str.split(',', expand=True)

####---------------------------------------------------------------------------------------
#### GET BY USER (ME) to fetch observations of Laurence and Jérôme
import requests
import pandas as pd
import numpy as np

def getobs_us(user_id, per_page=200):
    base_url=f'https://api.inaturalist.org/v1/observations?user_id={user_id}'
    params = {
        'username': user_id,
        'per_page': per_page,
        'page': 1
    }

    all_observations = []

    while True:
        response = requests.get(base_url, params=params)
        data = response.json()

        # Ajouter les observations à la liste
        all_observations.extend(data['results'])

        # Vérifier s'il y a plus de pages
        if len(data['results']) < per_page:
            break

        # Passer à la page suivante
        params['page'] += 1

    # Convertir les observations en DataFrame
    observations_df = pd.DataFrame(all_observations)
    return observations_df


print('\n -------------------------------')

user_id=8003020 # my username
obs=getobs_us(user_id)
obs[["latitude", "longitude"]] = obs["location"].str.split(',', expand=True)

# is good and saved


####---------------------------------------------------------------------------------------
#### NOW TO LAUNCH R SCRIPT TO TAKE IT FROM HERE

import subprocess

def rprocess(script):
    result = subprocess.run(['Rscript', script], 
        capture_output = True, text = True)

    print('R process output : \n ', result.stdout)
    print('R errors : \n ', result.stderr)

