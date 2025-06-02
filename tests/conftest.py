import pytest
import os
import sys

# Add the parent directory to the path to import the app
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Set the testing environment variable
os.environ['FLASK_ENV'] = 'testing'
os.environ['TESTING'] = 'True'

# Database connection for testing - use in-memory SQLite
os.environ['DATABASE_URL'] = 'sqlite:///:memory:'

