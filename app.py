from flask import Flask, render_template, request
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

engine = create_engine("sqlite:///contacts.db")
Base.metadata.create_all(engine)
Session = sessionmaker(bind=engine)

class Contact(Base):
    __tablename__ = "contacts"
    id = Column(Integer, primary_key=True)
    name = Column(String)
    email = Column(String)
    phone = Column(String)
    message = Column(String)
    

class Portfolio(Base):
    __tablename__ = "portfolio"
    id = Column(Integer, primary_key=True)
    title = Column(String)
    description = Column(String)
    image = Column(String)
    

class Blog(Base):
    __tablename__ = "blog"
    id = Column(Integer, primary_key=True)
    title = Column(String)
    description = Column(String)
    image = Column(String)



app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        # TODO: Implement login logic
        return redirect(url_for("home"))
    return render_template("auth/login.html")

@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        # TODO: Implement registration logic
        return redirect(url_for("login"))
    return render_template("auth/register.html")

@app.route("/services")
def services():
    return render_template("services.html")

@app.route("/about")
def about():
    return render_template("about.html")

# Contact Form
@app.route("/contact", methods=["POST", "GET"])
def contact():
    if request.method == "POST":
        session = Session()
        new_contact = Contact(
            name=request.form["name"],
            email=request.form["email"],
            phone=request.form["phone"],
            message=request.form["message"]
        )
        session.add(new_contact)
        session.commit()
        session.close()
        return render_template("contact.html")
    return render_template("contact.html")

# Portfolio
@app.route("/portfolio")
def portfolio():
    return render_template("portfolio.html")

# Blog
@app.route("/blog")
def blog():
    return render_template("blog.html")

# Blog Post
@app.route("/blog/<int:post_id>")
def blog_post(post_id):
    return render_template("blog_post.html", post_id=post_id)


if __name__ == "__main__":
    app.run(debug=True)

    
    
    
