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
from requests.adapters import HTTPAdapter
import pandas as pd
import numpy as np
import time
from tqdm import trange
from urllib3.util.retry import Retry

def check_internet(url="http://www.google.com"):
    try:
        requests.get(url, timeout=5)
        return True
    except:
        return False



##############################
# Lets get obs by taxon_id
def getobs_bytax(taxon_id, per_page=200):
    base_url = f'https://api.inaturalist.org/v1/observations?taxon_id={taxon_id}'
    params = {
        'per_page': per_page,
        'page': 1,
        'taxon_id': taxon_id,
    }

    all_observations = []  # Liste pour stocker les résultats bruts (dictionnaires)
    session = requests.Session()
    retries = Retry(total=5, backoff_factor=1, status_forcelist=[502, 503, 504, 522, 524, 408])
    adapter = HTTPAdapter(max_retries=retries)
    session.mount('https://', adapter)

    while True:
        # Récupération du nombre total de pages
        response = requests.get(base_url, params=params)
        data = response.json()

        # Ajouter les résultats (dictionnaires) à la liste
        all_observations.extend(data['results'])  # ✅ Correct : data['results'] est une liste de dictionnaires
        time.sleep(1)
                # Vérifier s'il y a plus de pages
        if len(data['results']) < per_page:
            break

        # Passer à la page suivante
        params['page'] += 1

    # Conversion en DataFrame UNE SEULE FOIS à la fin
    df = pd.DataFrame(all_observations)
        # Extraction de la latitude et longitude

    df[["latitude", "longitude"]] = df["location"].str.split(",", expand=True)
    return df

print('\n -------------------------------')
print('Function getobs_bytax loaded')

####---------------------------------------------------------------------------------------
#### GET BY USER to fetch observations


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
    observations_df["latitude", "longitude"]=observations_df["location"].str.split(",", expand=True)
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

