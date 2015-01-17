# coding=utf-8

from os.path import join, dirname, realpath
from itertools import groupby
from operator import itemgetter
from csv import DictReader
import json

from flask import Flask, render_template

with open(join(dirname(__file__), 'VERSION')) as file:
    __version__ = file.read().strip()

PROJECTS_FILE = realpath(join(dirname(__file__), '..', 'projects.json'))
STATUSES_FILE = realpath(join(dirname(__file__), '..', 'statuses.csv'))
state_classes = dict(t='success', f='failure error')
state_labels = dict(t=u'✓', f=u'❌')

app = Flask(__name__)

@app.route('/')
def index():
    with open(PROJECTS_FILE) as file:
        projects = json.load(file)

    with open(STATUSES_FILE) as file:
        statuses = sorted(DictReader(file), key=itemgetter('guid'))
    
    for (guid, group) in groupby(statuses, itemgetter('guid')):
        statuses = sorted(group, key=itemgetter('updated_at'), reverse=True)
        
        for status in statuses:
            status['state_class'] = state_classes[status['success']]
            status['state_label'] = state_labels[status['success']]

        project = [proj for proj in projects if proj['guid'] == guid][0]
        project['updated_at'] = statuses[0]['updated_at']
        project['valid_readme'] = statuses[0]['valid_readme']
        project['state_class'] = state_classes[statuses[0]['success']]
        project['statuses'] = statuses[:5]
    
    projects = [proj for proj in projects if 'updated_at' in proj]
    projects.sort(key=itemgetter('updated_at'), reverse=True)

    return render_template('index.html', projects=projects)
