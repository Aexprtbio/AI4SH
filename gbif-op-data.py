### CREATED BY ALEXI PRETAT
# 2/04/2025

# LAST UPDATE : 3/04/2025

# open shell in panel
# source AlexPI/bin/activate
# python
# copy paste script

import sys
print(sys.path)

print('\n -------------------------------')

import pandas as pd                                                                            
import requests
import time

from pygbif import occurrences as occ
from pygbif import species as species





# ==========================================================================================
# Tests for examples

splist = ['Eristalis cryptarum', 'Caliprobola speciosa'] 
keys = [species.name_backbone(x)['usageKey'] for x in splist] # lookup gbif 
                                                              # backbone tax keys

out = [ occ.search(taxonKey = x, limit=0)['count'] for x in keys ]

x = dict(zip(splist, out))
sorted(x.items(), key=lambda z:z[1], reverse=True) # dict of species names 
                                                    # and nb of records


##############################
# try out some things

insfr = occ.search(classKey=216) #limit is 300 by default

list(insfr)  # to see keys relative to insfr

data=insfr['results']
df=pd.DataFrame(data)
print(df.head())
df.to_csv('/Users/alexpretat/Documents/GBIF_openobs/gbiffr.csv')






# ==========================================================================================
# try downloading
import os
os.environ['GBIF_USER'] = 'aexprt_bio'
os.environ['GBIF_PWD'] = 'monoXylota63*2'
os.environ['GBIF_EMAIL'] = 'alexis.pretat@gmail.com'

# get a dl key for fr insects
# dl = occ.download(['classKey = 216', 'country = FR', 'hasCoordinate = True']) 

dl_key = '0001846-250402121839773'
status_url = f"https://api.gbif.org/v1/occurrence/download/{dl_key}"

# /!\ limit of 3 simultaneous dl per user.







# ==========================================================================================
# check the dl status regurlarly

def check_dlstat(dl_key):
    response = requests.get(status_url)
    status_data = response.json()
    return status_data['status']


# Vérifier l'état du téléchargement jusqu'à ce qu'il soit prêt
while True:
    status = check_dlstat(dl_key)
    print(f"Statut du téléchargement : {status}")

    if status == 'SUCCEEDED':
        # Télécharger le fichier une fois prêt
        download_url = f"https://api.gbif.org/v1/occurrence/download/request/{dl_key}.zip"
        response = requests.get(download_url, stream=True)

        # Sauvegarder le fichier localement
        with open('gbif_download.zip', 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)

        print("Téléchargement terminé. Fichier sauvegardé sous 'gbif_download.zip'.")
        break
    elif status in ['FAILED', 'KILLED']:
        print("Le téléchargement a échoué ou a été annulé.")
        break
    else:
        # Attendre avant de vérifier à nouveau
        print("En attente du téléchargement...")
        time.sleep(600)  # Attendre 10 minutes avant de vérifier à nouveau









# ==========================================================================================
# we got the gbif csv

import pandas as pd                                                                            

file_path = '/Users/alexpretat/0001846-250402121839773.csv'

# Lire le fichier CSV avec des options supplémentaires
try:
    df = pd.read_csv(file_path, encoding='utf-8', sep='\t', on_bad_lines='warn')
    print(df.head())  # Afficher les premières lignes du DataFrame
except Exception as e:
    print(f"Erreur lors de la lecture du fichier CSV : {e}")



# Right now, everything is flowing cool
# Time to get R in the process for data representation and analysis

# export the data with maybe only hymenopteras
hym = df['order']=='Hymenoptera'
dfhym=df[hym]

file_path = '/Users/alexpretat/Documents/GBIF_openobs/hymentest.csv'

dfhym.to_csv(file_path, index=False)



# ==========================================================================================
# Subprocess

import subprocess

script = '/Users/alexpretat/Documents/GBIF_openobs/GBIF_boogers.rmd'

def rprocess(script):
    result = subprocess.run(['Rscript', script], 
        capture_output = True, text = True)

    print('R process output : \n ', result.stdout)
    print('R errors : \n ', result.stderr)








