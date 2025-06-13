from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session
from config import Config

engine = create_engine(Config.SQLALCHEMY_DATABASE_URI)
db_session = scoped_session(sessionmaker(autocommit=False, autoflush=False, bind=engine))

Base = declarative_base()
Base.query = db_session.query_property()

def init_db():
    from models.user import User
    from models.machinery import Machinery
    from models.rice import RiceVariety
    from models.production import ProductionTracking  
    Base.metadata.create_all(bind=engine)

def shutdown_session(exception=None):
    db_session.remove()


from models.user import User
from models.machinery import Machinery
from models.rice import RiceVariety
from models.production import ProductionTracking 

__all__ = ['db_session', 'Base', 'init_db', 'shutdown_session', 'User', 'Machinery', 'RiceVariety', 'ProductionTracking']