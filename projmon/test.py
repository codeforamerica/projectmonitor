import json, unittest
from urlparse import urlparse
from operator import itemgetter

from requests import get
from . import PROJECTS_FILE

class TestProjects (unittest.TestCase):

    def test_projects(self):
        '''
        '''
        with open(PROJECTS_FILE) as file:
            projects = json.load(file)
        
        guids = map(itemgetter('guid'), projects)
        self.assertEqual(len(guids), len(set(guids)), 'Unique GUIDs')
        
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
            
            message = 'Missing {guid}: no {travis url}'
            self.assertEqual(resp.status_code, 200, message.format(**project))

if __name__ == '__main__':
    unittest.main()
