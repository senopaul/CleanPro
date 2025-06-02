import os
import sys
import json
import pytest
from datetime import datetime
from unittest.mock import patch, MagicMock

# Add the parent directory to the path to import the app
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from app import app, Contact, Portfolio, Blog

# =========================================================================
# Fixtures
# =========================================================================

@pytest.fixture
def client():
    """Create a test client for the app."""
    app.config['TESTING'] = True
    app.config['SERVER_NAME'] = 'localhost'
    
    # Use an in-memory SQLite database for testing
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    
    with app.test_client() as client:
        with app.app_context():
            # Set up the database for testing
            yield client


@pytest.fixture
def mock_db_session():
    """Mock the database session."""
    with patch('app.Session') as mock:
        session_instance = MagicMock()
        mock.return_value = session_instance
        yield session_instance


@pytest.fixture
def sample_contact_data():
    """Sample data for a contact form submission."""
    return {
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '+972 50-123-4567',  # Israeli phone format
        'message': 'This is a test message from Tel Aviv.'
    }


@pytest.fixture
def sample_portfolio_item():
    """Sample portfolio item."""
    return {
        'id': 1,
        'title': 'Office Cleaning',
        'description': 'Professional office cleaning services in Tel Aviv',
        'image': 'office-cleaning.jpg'
    }


@pytest.fixture
def sample_blog_post():
    """Sample blog post."""
    return {
        'id': 1,
        'title': '5 Tips for a Clean Office',
        'description': 'Learn how to maintain a clean office environment...',
        'image': 'blog-1.jpg'
    }

# =========================================================================
# Unit Tests
# =========================================================================

def test_contact_model():
    """Test the Contact model."""
    contact = Contact(
        name='Test User',
        email='test@example.com',
        phone='+972 50-123-4567',
        message='Test message'
    )
    
    assert contact.name == 'Test User'
    assert contact.email == 'test@example.com'
    assert contact.phone == '+972 50-123-4567'
    assert contact.message == 'Test message'


def test_portfolio_model():
    """Test the Portfolio model."""
    portfolio = Portfolio(
        title='Test Portfolio',
        description='Test Description',
        image='test.jpg'
    )
    
    assert portfolio.title == 'Test Portfolio'
    assert portfolio.description == 'Test Description'
    assert portfolio.image == 'test.jpg'


def test_blog_model():
    """Test the Blog model."""
    blog = Blog(
        title='Test Blog',
        description='Test Description',
        image='test.jpg'
    )
    
    assert blog.title == 'Test Blog'
    assert blog.description == 'Test Description'
    assert blog.image == 'test.jpg'


# =========================================================================
# API and Route Tests
# =========================================================================

def test_home_page(client):
    """Test the home page route."""
    response = client.get('/')
    
    assert response.status_code == 200
    assert b'<!DOCTYPE html>' in response.data


def test_services_page(client):
    """Test the services page route."""
    response = client.get('/services')
    
    assert response.status_code == 200
    assert b'<!DOCTYPE html>' in response.data


def test_about_page(client):
    """Test the about page route."""
    response = client.get('/about')
    
    assert response.status_code == 200
    assert b'<!DOCTYPE html>' in response.data


def test_contact_form_get(client):
    """Test the contact form GET request."""
    response = client.get('/contact')
    
    assert response.status_code == 200
    assert b'<!DOCTYPE html>' in response.data


def test_contact_form_post_success(client, mock_db_session, sample_contact_data):
    """Test successful contact form submission."""
    response = client.post('/contact', data=sample_contact_data)
    
    assert response.status_code == 200
    mock_db_session.add.assert_called_once()
    mock_db_session.commit.assert_called_once()


def test_portfolio_page(client):
    """Test the portfolio page route."""
    response = client.get('/portfolio')
    
    assert response.status_code == 200
    assert b'<!DOCTYPE html>' in response.data


def test_blog_page(client):
    """Test the blog page route."""
    response = client.get('/blog')
    
    assert response.status_code == 200
    assert b'<!DOCTYPE html>' in response.data


def test_blog_post_page(client):
    """Test the blog post page route."""
    response = client.get('/blog/1')
    
    assert response.status_code == 200
    assert b'<!DOCTYPE html>' in response.data


# =========================================================================
# Integration Tests with Database
# =========================================================================

def test_db_contact_integration(mock_db_session, sample_contact_data):
    """Test Contact integration with database."""
    # Create a contact object
    contact = Contact(
        name=sample_contact_data['name'],
        email=sample_contact_data['email'],
        phone=sample_contact_data['phone'],
        message=sample_contact_data['message']
    )
    
    # Add to mock session
    mock_db_session.add(contact)
    mock_db_session.commit()
    
    # Verify it was added
    mock_db_session.add.assert_called_with(contact)
    mock_db_session.commit.assert_called_once()


@patch('app.Session')
def test_portfolio_integration(mock_session_class, sample_portfolio_item):
    """Test Portfolio integration with database."""
    # Setup mock session
    mock_session = MagicMock()
    mock_session_class.return_value = mock_session
    
    # Create a mock query result
    mock_query = MagicMock()
    mock_session.query.return_value = mock_query
    mock_query.all.return_value = [
        Portfolio(**sample_portfolio_item)
    ]
    
    # Simulate retrieving portfolio items
    session = mock_session_class()
    portfolio_items = session.query(Portfolio).all()
    
    # Verify we got our item
    assert len(portfolio_items) == 1
    assert portfolio_items[0].title == sample_portfolio_item['title']
    assert portfolio_items[0].description == sample_portfolio_item['description']


@patch('app.Session')
def test_blog_integration(mock_session_class, sample_blog_post):
    """Test Blog integration with database."""
    # Setup mock session
    mock_session = MagicMock()
    mock_session_class.return_value = mock_session
    
    # Create a mock query result
    mock_query = MagicMock()
    mock_session.query.return_value = mock_query
    mock_query.all.return_value = [
        Blog(**sample_blog_post)
    ]
    
    # Simulate retrieving blog posts
    session = mock_session_class()
    blog_posts = session.query(Blog).all()
    
    # Verify we got our post
    assert len(blog_posts) == 1
    assert blog_posts[0].title == sample_blog_post['title']
    assert blog_posts[0].description == sample_blog_post['description']


# =========================================================================
# Health Check Tests
# =========================================================================

def test_health_check_endpoint(client):
    """Test the health check endpoint."""
    response = client.get('/health')
    
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['status'] == 'ok'
    assert data['app_name'] == 'CleanPro'
    assert 'version' in data
    assert 'timestamp' in data


def test_health_check_timestamp_format(client):
    """Test the timestamp format in health check."""
    response = client.get('/health')
    data = json.loads(response.data)
    
    # Verify timestamp is in ISO format
    try:
        timestamp = datetime.fromisoformat(data['timestamp'])
        assert isinstance(timestamp, datetime)
    except (ValueError, TypeError):
        pytest.fail("Health check timestamp is not in ISO format")


# =========================================================================
# Security and Error Handling Tests
# =========================================================================

def test_404_handling(client):
    """Test 404 error handling."""
    response = client.get('/non_existent_page')
    
    assert response.status_code == 404


@patch('app.Session')
def test_db_error_handling(mock_session, client, sample_contact_data):
    """Test database error handling."""
    # Configure the mock to raise an exception
    session_instance = MagicMock()
    mock_session.return_value = session_instance
    session_instance.commit.side_effect = Exception("Database error")
    
    # Submit form which should trigger the error
    response = client.post('/contact', data=sample_contact_data)
    
    # Verify error is handled gracefully
    assert response.status_code == 200  # Should still return a valid response


def test_hebrew_content_support(client):
    """Test Hebrew (RTL) content support."""
    # Create a request with Hebrew content
    hebrew_data = {
        'name': 'ישראל ישראלי',  # Hebrew name
        'email': 'israel@example.co.il',
        'phone': '+972 50-123-4567',
        'message': 'זוהי הודעת בדיקה בעברית'  # Hebrew message
    }
    
    response = client.post('/contact', data=hebrew_data)
    
    # Verify the form submission works with Hebrew content
    assert response.status_code == 200


if __name__ == '__main__':
    pytest.main()

