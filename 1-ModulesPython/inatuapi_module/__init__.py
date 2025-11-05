import sys
import os

print('#################################')
print('Trace of system path :')
print(sys.path)

print('#################################')
print('#################################')


os.get_exec_path()
from .inatuapi import *

print('#################################')
print('#################################')
print('#################################')

print('the module INATUAPI has been loaded')