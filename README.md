# AI4SH
working on the AI4SH initiative

Description of folders :

## 1-ModulesPython/inatuapi
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

## 3-SoilFariR
R scripts applied to the 'SoilFari' results. 
The script 'SoilFariR_functions.R' contains the definition of functions necessary to processing dataframes and getting key elements for base and further analysis.

The 'SoilFariR_import_and_process.R' file contains the commands to call the python module and processing the different DataFrames to make it usable and coherent.

The 'SoilFariR_script.R'

## 4-DataFrames_ready

## 5-DataFrames_transients
