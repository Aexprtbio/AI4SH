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

def getobs_bytax(taxon_id, per_page=200, country=None, region=None):
    base_url=f'https://api.inaturalist.org/v1/observations?taxon_id={taxon_id}'
    params = {
        'per_page': per_page,
        'page': 1,
        'taxon_id' : taxon_id,
        'order': 'asc'
    }

    all_observations = []
    session = requests.Session()
    retries = Retry(total=5, backoff_factor=1,
        status_forcelist=[502, 503, 504, 522, 524, 408])
    adapter = HTTPAdapter(max_retries=retries)
    session.mount('https://', adapter)

    while True:
        response = requests.get(base_url, params=params)
        data = response.json()
        


        if 'total_results' in data:
            total=data['total_results']
            n_page=int(total/per_page) + (total%per_page>0)
        else:
            n_page=1

        #progression bar
        for page in trange(1,n_page+1, desc="Downloading"):
            params['page']=page
            response = requests.get(base_url, params=params)
            data = response.json()

            # Vérification présence de la clé 'results'
            if 'results' not in data:
                print("Erreur dans la réponse API :", data)
                break
            # Ajouter les observations à la liste
            all_observations.extend(pd.DataFrame(data['results']))

            time.sleep(1)
        
        if len(data['results']) < per_page:
            break    


    if country is not None:
        if isinstance(country, str):
            country=[country]

        all_observations['country']=all_observations[['place_guess']].apply(lambda x: x.split(',')[-1].strip())
        all_observations = all_observations[all_observations['country'].isin(country)]

        
    if region is not None:
        if isinstance(region, str):
            region=[region]
        all_observations['region']=all_observations[['place_guess']].apply(lambda x: x.split(',')[-2].strip())
        all_observations = all_observations[all_observations['region'].isin(region)]

        #final recomposition of the dataframe before returning results
    all_observations[["latitude", "longitude"]]=all_observations["location"].str.split(",", expand=True)
    return all_observations


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

