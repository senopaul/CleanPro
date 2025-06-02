-- Initialize database for CleanPro application

-- Create database tables if not exists
CREATE TABLE IF NOT EXISTS contacts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS portfolio (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS blog (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data for development
INSERT INTO portfolio (title, description, image) VALUES
('Office Cleaning', 'Professional office cleaning services', 'office-cleaning.jpg'),
('Home Cleaning', 'Residential cleaning services', 'home-cleaning.jpg'),
('Window Cleaning', 'Professional window cleaning', 'window-cleaning.jpg');

INSERT INTO blog (title, description, image) VALUES
('5 Tips for a Clean Office', 'Learn how to maintain a clean office environment...', 'blog-1.jpg'),
('Benefits of Regular Cleaning', 'Discover the health benefits of regular cleaning...', 'blog-2.jpg'),
('Eco-Friendly Cleaning Products', 'Best eco-friendly cleaning products for your home...', 'blog-3.jpg');

