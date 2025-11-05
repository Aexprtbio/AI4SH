# AI4SH
working on the AI4SH initiative
Description of folders :

## 1-ModulesPython/inatuapi
<img width="53" height="53" alt="iNatuAPI-logo_png" src="https://github.com/user-attachments/assets/106811ea-fbe4-46c3-b74b-788336a6dac6" />


Python script / Module for retrievinga DataFrame of iNaturalist observations.
Functions available in the module are :
* getobs_bytax() ==> getting observations of a given taxa.
* getobs_us() ==> getting observations of a given user.
* getobs_proj() ==> getting observations from a given iNaturalist project

The module can be called from R, using the package 'reticulate'.
The call of the function is then done by using the command line :
py$name-of-function(arguments)

To keep the downloaded dataframe, do not forget to add a py$pd$DataFrame$to_csv command line in R.

NB : inatuapi stands for INATUralist API functions.
Later will be developped a Graphical User Friendly Interface to access to these observations, ie : GUFI

## 2-FINLANDRiikka
Folder containing specific data from the LUKE team in Finland, coordinated by Elo Riikka.


<img width="53" height="53" alt="soilFarilogo_png" src="https://github.com/user-attachments/assets/6b3c1969-0fc6-4991-b594-eb03c4a3f11f" />

## 3-SoilFariR
R scripts applied to the 'SoilFari' results. 
The script 'SoilFariR_functions.R' contains the definition of functions necessary to processing dataframes and getting key elements for base and further analysis.

The 'SoilFariR_import_and_process.R' file contains the commands to call the python module and processing the different DataFrames to make it usable and coherent.

The 'SoilFariR_script.R' contains the main exploratory analysis so far, including rarecurves and CAs/PCAs analysis on community matrixes.

## 4-DataFrames_ready
The folder for the usable and processed DataFrames to import in 'SoilFariR_script.R' file.

## 5-DataFrames_transients
Transitory dataframes created during the first steps of development.

## 6-Manuscripts
Manuscripts on the project, following latest advancements.

## 7-Logos
Images for graphical enhancement of the modules proposed.
