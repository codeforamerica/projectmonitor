# coding=utf-8

from __future__ import absolute_import, division, print_function
from future import standard_library; standard_library.install_aliases()

from os.path import join, dirname, realpath
from itertools import groupby
from operator import itemgetter
from urllib.parse import urlparse
from csv import DictReader
from time import time
import json

from requests import get
from flask import Flask, render_template, jsonify

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

@app.route('/.well-known/status')
def status():
    with open(PROJECTS_FILE) as file:
        projects = json.load(file)
    
    try:
        for project in projects:
            _, host, path, _, _, _ = urlparse(project['travis url'])
            api_url = 'https://api.{host}/repos{path}'.format(**locals())
            resp = get(api_url)
        
            # See if the Github URL has moved.
            if resp.status_code == 404:
                github_url = 'https://github.com{path}'.format(**locals())
                resp = get(github_url)
            
                if resp.status_code == 200:
                    _, _, github_path, _, _, _ = urlparse(resp.url)
                
                    if github_path != path:
                        message = 'Error in {guid}: {path} has moved to {github_path}'
                        kwargs = dict(guid=project['guid'], **locals())
                        raise Exception(message.format(**kwargs))
        
            if resp.status_code != 200:
                message = 'Missing {guid}: no {travis url}'
                raise Exception(message.format(**project))
    except Exception as e:
        status = str(e)
    else:
        status = 'ok'
    
    return jsonify(dict(status=status,
                        updated=int(time()),
                        dependencies=['Travis', 'Github'],
                        resources={}))
