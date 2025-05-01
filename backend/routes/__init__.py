from flask import Blueprint

# Create the API blueprint
api = Blueprint('api', __name__)

# Import routes to register them with the blueprint
from routes.auth import *
from routes.users import *
from routes.machinery import *
from routes.rice import *
# Add the import for the new repair routes
from . import repair

# Initialize the blueprint with all routes
def init_routes(app):
    app.register_blueprint(api, url_prefix='/api')