# Source - https://stackoverflow.com/a/21518989
# Posted by Sanjar Stone, modified by community. See post 'Timeline' for change history
# Retrieved 2026-04-10, License - CC BY-SA 3.0
# 

#!/usr/bin/python
from PIL import Image
import os, sys

path = "D:/AIFSH-Archive/AI4SH/2 - terrain_safari/all_avril2026/ALEX/"
dirs = os.listdir(path)

pathos = list()

for item in dirs:
    print(item)
    pathos.append(path+item+"/")


def resize():
    i=1
    while i < len(pathos):
        for item in os.listdir(pathos[i]):
            print(pathos[i]+item)
            pouet=pathos[i]+item
            if os.path.isfile(pouet):
                im = Image.open(pouet)
                f, e = os.path.splitext(pouet)
                imResize = im.resize((1800,1200))
                imResize.save(f + ' resized.jpg', 'JPEG', quality=90)
        i=i+1

resize()
