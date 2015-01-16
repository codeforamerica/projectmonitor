from os.path import join, dirname, realpath
import json

from flask import Flask, render_template

with open(join(dirname(__file__), 'VERSION')) as file:
    __version__ = file.read().strip()

PROJECTS_FILE = realpath(join(dirname(__file__), '..', 'projects.json'))

app = Flask(__name__)

@app.route('/')
def index():
    with open(PROJECTS_FILE) as file:
        projects = json.load(file)

    return render_template('index.html', projects=projects)
