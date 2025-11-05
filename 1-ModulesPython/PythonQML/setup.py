# commande à taper en ligne de commande après la sauvegarde de ce fichier:
# python setup.py build

from cx_Freeze import setup, Executable
  
executables = [
        Executable(script = "D:/GitHub/AI4SH/1-ModulesPython/PythonQML/app-pythonINAT.py",icon = "D:/GitHub/AI4SH/1-ModulesPython/PythonQML/inatapi.ico", base = "Win32GUI" )
]
# ne pas mettre "base = ..." si le programme n'est pas en mode graphique, comme c'est le cas pour chiffrement.py.
  
buildOptions = dict( 
        includes = ["inatuapi_module","pandas"],
        include_files = ["D:/GitHub/AI4SH/1-ModulesPython/PythonQML/readme_inatapi.txt", "D:/GitHub/AI4SH/1-ModulesPython/PythonQML/inatapi.ico"]
)
  
setup(
    name = "iNatAPI",
    version = "0.1",
    description = "Alpha version of the iNatAPI program, designed to get observations from iNaturalist.",
    author = "A. PRÉTAT",
    options = dict(build_exe = buildOptions),
    executables = executables
)