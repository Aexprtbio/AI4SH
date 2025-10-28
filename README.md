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

## 2-FINLANDRiikka

## 3-SoilFariR

## 4-DataFrames_ready

## 5-DataFrames_transients
