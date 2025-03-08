from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
import bcrypt
import uuid
from functools import wraps

app = Flask(__name__)

# SQLite Database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///straw_innovations.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
migrate = Migrate(app, db)

# USER MODEL
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(120), nullable=False)
    role = db.Column(db.String(20), nullable=False, default='employee')
    token = db.Column(db.String(120), nullable=True)

    def __repr__(self):
        return f'<User {self.username}, Role: {self.role}>'
    
# CREATES DATABASE AND TABLES
with app.app_context():
    db.create_all()

# FUNCTION TO HASH PASSWORDS
def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

# FUNCTION TO CHECK PASSWORD
def check_password(password, hashed):
    return bcrypt.checkpw(password.encode('utf-8'), hashed)

def role_required(required_role):
    def decorator(f):
        @wraps(f)
        def wrappped(*args, **kwargs):
            # Get username from the request
            data = request.get_json()
            username = data.get('username')

            if not username:
                return jsonify({'message': 'Username is required'}), 400
            
            # Fetches the user from the database
            user = User.query.filter_by(username=username).first()

            if not user:
                return jsonify({'message': 'User not found'}), 404
            
            # Checks if user has the required role
            if user.role != required_role:
                return jsonify({'message': 'Access Denied'}), 403
            
            # Calls the function if the user has the required role
            return f(*args, **kwargs)
        return wrappped
    return decorator    

# REGISTRATION ENDPOINT
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    role = data.get('role', 'employee')

    if not username or not password:
        return jsonify({'message': 'Username and password are required'}), 400
    
    if User.query.filter_by(username=username).first():
        return jsonify({'message': 'Username already exists'}), 400
    
    try:
        hashed_password = hash_password(password)
        new_user = User(username=username, password_hash=hashed_password, role=role)
        db.session.add(new_user)
        db.session.commit()
        return jsonify({'message': 'User registered successfully'}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': 'An error occurred', 'error': str(e)}), 500
    
# ROUTES
# LOGIN ENDPOINT
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': 'Username and password are required'}), 400
    
    if User.query.filter(User.token.isnot(None)).first():
        return jsonify({'message': 'Already logged in'}), 403
    
    user = User.query.filter_by(username=username).first()

    if not user or not check_password(password, user.password_hash):
        return jsonify({'message': 'Invalid username or password'}), 401
    

    user.token = str(uuid.uuid4())
    db.session.commit()

    if user.role == 'admin':
        return jsonify({'message': 'Login successful', 'redirect_url': '/admin/dashboard'}), 200
    elif user.role == 'employee':
        return jsonify({'message': 'Login successful', 'redirect_url': '/employee/dashboard'}), 200
    else:
        return jsonify({'message': 'Invalid role'}), 403

@app.route('/logout', methods=['POST'])
def logout():
    data = request.get_json()
    username = data.get('username')
    token = request.headers.get('Authorization')

    if not token():
        return jsonify({'message': 'Token is required'}), 400
    
    # if not username:
    #     return jsonify({'message': 'Username is required'}), 400

    user = User.query.filter_by(token=token).first()

    if not user:
        return jsonify({'message': 'User not found'}), 404

    user.token = None
    db.session.commit()
    
    return jsonify({'message': 'User logged out successfully'}), 200

# GET USERS ENDPOINT
@app.route('/users', methods=['GET'])
def get_users():
    users = User.query.all()
    user_list = []
    for user in users:
        user_list.append({
            'id': user.id,
            'username': user.username,
            'password_hash': user.password_hash.decode('utf-8'), # decodes bytes to str 
            'role': user.role
        })
    return jsonify(user_list), 200

@app.route('/admin/dashboard', methods=['GET'])
@role_required('admin') 
def admin_dashboard():
    return jsonify({'message': 'Welcome to the admin dashboard'}), 200

@app.route('/employee/dashboard', methods=['GET'])
@role_required('employee') 
def employee_dashboard():
    return jsonify({'message': 'Welcome to the employee dashboard'}), 200

# RUNS THE APP
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)