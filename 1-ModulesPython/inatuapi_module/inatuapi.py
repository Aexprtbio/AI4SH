### CREATED BY ALEXI PRETAT
# 1/04/2025

# LAST UPDATE : 12/11/2025

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


def check_internet(url="http://www.google.com"):
    try:
        requests.get(url, timeout=5)
        return True
    except:
        return False



##############################
# Lets get obs by taxon_id

def getobs_bytax(taxon_id, per_page=200, country=None, region=None):
    base_url=f'https://api.inaturalist.org/v1/observations?taxon_id={taxon_id}'
    params = {
        'per_page': per_page,
        'page': 1,
        'taxon_id' : taxon_id
    }

    all_observations = []

    while True:
        response = requests.get(base_url, params=params)
        data = response.json()

        # Vérification présence de la clé 'results'
        if 'results' not in data:
            print("Erreur dans la réponse API :", data)
            break

        # Ajouter les observations à la liste
        all_observations.extend(data['results'])

        # Vérifier s'il y a plus de pages
        if len(data['results']) < per_page:
            break

        # Passer à la page suivante
        params['page'] += 1

    # Convertir les observations en DataFrame
    observations_df = pd.DataFrame(all_observations)


    if country is not None:
        if isinstance(country, str):
            country=[country]

        observations_df['country']=observations_df['place_guess'].apply(lambda x: x.split(',')[-1].strip())
        observations_df = observations_df[observations_df['country'].isin(country)]

        
    if region is not None:
        if isinstance(country, str):
            country=[country]
        observations_df['region']=observations_df['place_guess'].apply(lambda x: x.split(',')[-2].strip())
        observations_df = observations_df[observations_df['region'].isin(region)]

        #final recomposition of the dataframe before returning results
    observations_df["latitude", "longitude"]=observations_df["location"].str.split(",", expand=True)
    return observations_df


print('\n -------------------------------')
print('Function getobs_bytax loaded')

####---------------------------------------------------------------------------------------
#### GET BY USER to fetch observations
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
print('Function getobs_us loaded')

# is good and saved



# Get obs by project ID
def getobs_proj(project_id, per_page=200):
    base_url=f'https://api.inaturalist.org/v1/observations?project_id={project_id}'
    params = {
        'project': project_id,
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
    observations_df["latitude", "longitude"]=observations_df["location"].str.split(",", expand=True)

    return observations_df


print('\n -------------------------------')
print('Function getobs_proj loaded')

# is good and saved

