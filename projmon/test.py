from __future__ import absolute_import, division, print_function
from future import standard_library; standard_library.install_aliases()

import json, unittest, re
from operator import itemgetter

from . import PROJECTS_FILE

class TestProjects (unittest.TestCase):

    def test_projects(self):
        '''
        '''
        with open(PROJECTS_FILE) as file:
            projects = json.load(file)
        
        guids = list(map(itemgetter('guid'), projects))
        self.assertEqual(len(guids), len(projects), 'A GUID in every project')
        self.assertEqual(len(guids), len(set(guids)), 'Non-unique GUIDs')
        
        matches = [bool(re.match(r'^\w+(-\w+)*$', guid)) for guid in guids]
        self.assertFalse(False in matches, r'GUIDs all match "^\w+(-\w+)*$"')
        
        names = list(map(itemgetter('name'), projects))
        self.assertEqual(len(names), len(projects), 'A name in every project')
        self.assertEqual(len(names), len(set(names)), 'Non-unique names')
        
        urls = list(map(itemgetter('travis url'), projects))
        self.assertEqual(len(urls), len(projects), 'A URL in every project')

if __name__ == '__main__':
    unittest.main()
