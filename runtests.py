import os, os.path
import sys

os.environ["DJANGO_SETTINGS_MODULE"] = "tests.settings"

from django.test.runner import DiscoverRunner
from django import setup as django_setup

django_setup()


test_runner = DiscoverRunner(verbosity=1)
failures = test_runner.run_tests(['tests'])
if failures:
    sys.exit(failures)
