from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker, Session

# ----------------------------------
# 1. DATABASE CONFIGURATION
# ----------------------------------
# Using port 3307 for XAMPP MySQL and 'student' database
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:@localhost:3307/student"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ----------------------------------
# 2. DATABASE MODEL
# ----------------------------------
class User(Base):
    __tablename__ = "users"

    # Matching your MySQL columns: idno, name, gender
    idno = Column(Integer, primary_key=True, index=True)
    name = Column(String(255))
    gender = Column(String(50))

# ----------------------------------
# 3. FASTAPI INITIALIZATION
# ----------------------------------
app = FastAPI()

# Enable CORS for future Flutter integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency to manage database sessions
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ----------------------------------
# 4. API ENDPOINTS (ROUTES)
# ----------------------------------

@app.get("/")
def read_root(db: Session = Depends(get_db)):
    """ Returns connection status and all users in a formatted JSON """
    users = db.query(User).all()
    return {
        "status": "Connected to MySQL",
        "total_users": len(users),
        "data": users
    }

@app.get("/users")
def get_users_list(db: Session = Depends(get_db)):
    """ Returns a raw list of users """
    return db.query(User).all()

@app.post("/users")
def create_user(name: str, gender: str, db: Session = Depends(get_db)):
    """ Adds a new user to the database """
    new_user = User(name=name, gender=gender)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user