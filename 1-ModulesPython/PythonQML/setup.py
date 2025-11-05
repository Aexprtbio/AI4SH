# commande à taper en ligne de commande après la sauvegarde de ce fichier:
# python setup.py build

from cx_Freeze import setup, Executable
import os 

os.chdir('D:/GitHub/AI4SH/1-ModulesPython/PythonQML')
executables = [
        Executable(script = "app-pythonINAT.py",icon = "inatapi.ico", base = "Win32GUI" )
]
# ne pas mettre "base = ..." si le programme n'est pas en mode graphique, comme c'est le cas pour chiffrement.py.
  
buildOptions = dict( 
        includes = ["inatuapi_module","pandas","PySide6", "requests"],
        include_files = ["readme_inatapi.txt", "inatapi.ico"]
)
  
setup(
    name = "iNatAPI",
    version = "0.1",
    description = "Alpha version of the iNatAPI program, designed to get observations from iNaturalist.",
    author = "A. PRÉTAT",
    options = dict(build_exe = buildOptions),
    executables = executables
)