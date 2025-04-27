from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session
from config import Config

engine = create_engine(Config.SQLALCHEMY_DATABASE_URI)
db_session = scoped_session(sessionmaker(autocommit=False, autoflush=False, bind=engine))

Base = declarative_base()
Base.query = db_session.query_property()

def init_db():
    # import all modules here that might define models
    from models.user import User
    from models.machinery import Machinery
    from models.rice import RiceVariety
    Base.metadata.create_all(bind=engine)

def shutdown_session(exception=None):
    db_session.remove()