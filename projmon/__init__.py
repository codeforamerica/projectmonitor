from os.path import join, dirname

with open(join(dirname(__file__), 'VERSION')) as file:
    __version__ = file.read().strip()
