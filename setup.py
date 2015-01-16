from setuptools import setup
from os.path import join, dirname

with open(join(dirname(__file__), 'projmon', 'VERSION')) as file:
    version = file.read().strip()

setup(
    name = 'Project-Monitor',
    version = version,
    url = 'https://github.com/codeforamerica/projectmonitor',
    author = 'Michal Migurski',
    author_email = 'mike@codeforamerica.org',
    packages = ['projmon'],
    package_data = {
        'projmon': ['VERSION']
    },
    install_requires = [
        'flask == 0.10.1',
        
        # http://python-future.org
        'future >= 0.14.3',
        
        # https://bugs.launchpad.net/ubuntu/+source/python-pip/+bug/1306991/comments/10
        'requests == 2.2.1',

        # https://github.com/patrys/httmock
        'httmock >= 1.2'
        ],
    entry_points = dict(
        console_scripts = []
    )
)
