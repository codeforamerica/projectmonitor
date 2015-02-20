# coding=utf-8

from __future__ import absolute_import, division, print_function
from future import standard_library; standard_library.install_aliases()

from os.path import join, dirname, realpath
from itertools import groupby
from operator import itemgetter
from urllib.parse import urlparse
from csv import DictReader
from time import time
import json, sys, os

from requests import get
from psycopg2 import connect
from psycopg2.extras import DictCursor
from flask import Flask, request, render_template, jsonify

with open(join(dirname(__file__), 'VERSION')) as file:
    __version__ = file.read().strip()

PROJECTS_FILE = realpath(join(dirname(__file__), '..', 'projects.json'))
STATUSES_FILE = realpath(join(dirname(__file__), '..', 'statuses.csv'))

app = Flask(__name__)

@app.route('/')
def index():
    with open(PROJECTS_FILE) as file:
        projects = json.load(file)

    with connect(os.environ['DATABASE_URL']) as conn:
        with conn.cursor(cursor_factory=DictCursor) as db:
            db.execute('''SELECT guid, success, url, updated_at, valid_readme
                          FROM statuses WHERE updated_at IS NOT NULL
                          ORDER BY guid''')

            statuses = map(dict, db.fetchall())

    for (guid, group) in groupby(statuses, itemgetter('guid')):
        statuses = sorted(group, key=itemgetter('updated_at'), reverse=True)

        for status in statuses:
            status['state_class'] = 'success' if status['success'] else 'failure error'
            status['state_label'] = u'✓' if status['success'] else u'❌'

        project = [proj for proj in projects if proj['guid'] == guid][0]
        project['updated_at'] = statuses[0]['updated_at'].strftime('%Y-%m-%dT%H:%M:%SZ')
        project['valid_readme'] = statuses[0]['valid_readme']
        project['state_class'] = statuses[0]['state_class']
        project['statuses'] = statuses[:5]

    projects = [proj for proj in projects if 'updated_at' in proj]
    projects.sort(key=itemgetter('updated_at'), reverse=True)

    return render_template('index.html', projects=projects)

@app.route('/projects/<guid>/status', methods=['POST'])
def post_status(guid):
    try:
        if 'payload' not in request.form:
            raise RuntimeError('Missing payload')

        payload = json.loads(request.form['payload'])
        build_url = payload.get('build_url', '')
        project = None

        with open(PROJECTS_FILE) as file:
            for other_project in json.load(file):
                if other_project['guid'] != guid:
                    continue
                if build_url.startswith(other_project['travis url']):
                    project = other_project

        if not project:
            raise RuntimeError('No match found for {}, {}'.format(guid, build_url))

        _, _, build_path, _, _, _ = urlparse(build_url)
        info_url = 'https://api.travis-ci.org{}'.format(build_path)
        print('info_url:', info_url, file=sys.stderr)

        got = get(info_url)

        if got.status_code != 200:
            raise RuntimeError('HTTP {} for {}'.format(got.status_code, info_url))

        info = got.json()
        success = (info['status'] == 0)
        updated_at = info.get('finished_at', info['started_at'])
        valid_readme = None

        with connect(os.environ['DATABASE_URL']) as conn:
            with conn.cursor(cursor_factory=DictCursor) as db:
                db.execute('''INSERT INTO statuses
                              (guid, success, url, updated_at, valid_readme)
                              VALUES (%s, %s, %s, %s, %s)''',
                           (project['guid'], success, build_url, updated_at, True))

        print('post_status: guid={guid}, success={success}, url={build_url}, updated_at={updated_at}, valid_readme=?'.format(**locals()), file=sys.stderr)

    except RuntimeError as e:
        raise

    else:
        return 'ok'

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
