# -*- coding: utf-8 -*-

from __future__ import print_function
from future import standard_library; standard_library.install_aliases()

from urllib.parse import urlparse

from requests import get
from flask import Flask, render_template, request

app = Flask(__name__)


@app.route('/')
def all_projects():

    limit = int(request.args.get('limit',50))

    # Load 10 of this groups projects from CfAPI
    def get_projects(projects, url, limit=10):
        got = get(url)
        print(url, limit)
        new_projects = got.json()["objects"]
        projects = projects + new_projects
        if limit:
            if len(projects) >= limit:
                return projects
        if "next" in got.json()["pages"]:
            projects = get_projects(projects, got.json()["pages"]["next"], limit)
        return projects

    travis_projects = []
    projects = []
    projects = get_projects(projects, "https://www.codeforamerica.org/api/projects", limit)

    # Loop through projects and get
    for project in projects:
        if project["code_url"]:
            url = urlparse(project["code_url"])
            if url.netloc == "github.com":
                travis_url = "https://api.travis-ci.org/repositories"+url.path+"/builds"
                project["travis_url"] = travis_url
                travis_projects.append(project)

    return render_template('index.html', projects=travis_projects)



@app.route('/<cfapi_org_id>/')
def organizations_projects(cfapi_org_id):

    limit = int(request.args.get('limit',50))

    # Load 10 of this groups projects from CfAPI
    def get_projects(projects, url, limit=10):
        got = get(url)
        print(url, limit)
        new_projects = got.json()["objects"]
        projects = projects + new_projects
        if limit:
            if len(projects) >= limit:
                return projects
        if "next" in got.json()["pages"]:
            projects = get_projects(projects, got.json()["pages"]["next"], limit)
        return projects

    travis_projects = []
    projects = []
    projects = get_projects(projects, "https://www.codeforamerica.org/api/organizations/"+cfapi_org_id+"/projects", limit)

    # Loop through projects and get
    for project in projects:
        if project["code_url"]:
            url = urlparse(project["code_url"])
            if url.netloc == "github.com":
                travis_url = "https://api.travis-ci.org/repositories"+url.path+"/builds"
                project["travis_url"] = travis_url
                travis_projects.append(project)

    return render_template('index.html', projects=travis_projects, org_name=cfapi_org_id)
