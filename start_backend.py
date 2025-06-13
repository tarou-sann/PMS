"""
Startup script for the PMS Backend
This script helps to set up and run the backend server
"""
import os
import sys
import subprocess
import webbrowser
import platform
import socket
import time

def get_local_ip():
    """Get the local IP address of the machine"""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

def setup_virtual_env():
    """Set up a virtual environment if it doesn't exist"""
    if not os.path.exists('venv'):
        print("Creating virtual environment...")
        subprocess.run([sys.executable, '-m', 'venv', 'venv'])
    
    # Install dependencies
    print("Installing dependencies...")
    
    # Use the correct pip path based on platform
    if platform.system() == 'Windows':
        pip_path = os.path.join('venv', 'Scripts', 'pip')
    else:
        pip_path = os.path.join('venv', 'bin', 'pip')
    
    # Check if requirements.txt exists
    requirements_path = 'requirements.txt'
    if not os.path.exists(requirements_path):
        # Create a basic requirements.txt file if it doesn't exist
        with open(requirements_path, 'w') as f:
            f.write("Flask==2.0.1\n")
            f.write("Flask-Cors==3.0.10\n")
            f.write("Flask-JWT-Extended==4.2.3\n")
            f.write("Flask-Bcrypt==1.0.1\n")  
            f.write("SQLAlchemy==1.4.23\n")
            f.write("Werkzeug==2.0.1\n")
        print("Created requirements.txt file with basic dependencies")
    else:
        # Check if Flask-Bcrypt is in the existing requirements.txt
        with open(requirements_path, 'r') as f:
            requirements = f.read()
            
        if 'Flask-Bcrypt' not in requirements:
            # Add Flask-Bcrypt to requirements.txt
            print("Adding Flask-Bcrypt to requirements.txt")
            with open(requirements_path, 'a') as f:
                f.write("Flask-Bcrypt==1.0.1\n")
    
    # Install dependencies
    subprocess.run([pip_path, 'install', '-r', requirements_path])
    
    # Verify bcrypt is installed
    try:
        verify_process = subprocess.run(
            [pip_path, 'show', 'Flask-Bcrypt'], 
            capture_output=True, 
            text=True
        )
        if "Name: Flask-Bcrypt" in verify_process.stdout:
            print("✓ Flask-Bcrypt is properly installed")
        else:
            print("⚠️ Flask-Bcrypt is missing - installing directly")
            subprocess.run([pip_path, 'install', 'Flask-Bcrypt==1.0.1'])
    except Exception as e:
        print(f"Error verifying bcrypt installation: {e}")

def setup_admin_user():
    """Set environment variables for admin user"""
    # Default admin credentials
    os.environ.setdefault('ADMIN_USERNAME', 'admin')
    os.environ.setdefault('ADMIN_PASSWORD', 'admin')
    os.environ.setdefault('ADMIN_EMAIL', 'admin@example.com')
    
    print(f"Admin user will be created with username: {os.environ['ADMIN_USERNAME']}")

def start_server(host='0.0.0.0', port=5000):
    """Start the Flask server"""
    local_ip = get_local_ip()
    
    print("="*50)
    print(f"Starting PMS Backend server on:")
    print(f"  Local:   http://localhost:{port}")
    print(f"  Network: http://{local_ip}:{port}")
    print("="*50)
    print("\nUse these URLs in your Flutter app to connect to the backend:")
    print(f"  For Android Emulator: http://10.0.2.2:{port}/api")
    print(f"  For iOS Simulator: http://localhost:{port}/api")
    print(f"  For Physical Devices: http://{local_ip}:{port}/api")
    print("="*50)
    
    # Set Flask environment variables
    os.environ['FLASK_APP'] = 'app.py'
    os.environ['FLASK_ENV'] = 'development'
    
    # Get the correct python path based on platform
    if platform.system() == 'Windows':
        python_path = os.path.join('venv', 'Scripts', 'python')
    else:
        python_path = os.path.join('venv', 'bin', 'python')
    
    # Try to run the server
    try:
        # Make sure we're using the app.py file in the current directory
        subprocess.run([python_path, 'app.py', '--host', host, '--port', str(port)])
    except KeyboardInterrupt:
        print("\nServer stopped.")
    except Exception as e:
        print(f"Error starting server: {e}")
        print("Make sure the app.py file exists in the backend directory.")

if __name__ == "__main__":
    # Change to the backend directory
    backend_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'backend')
    
    if os.path.exists(backend_dir):
        os.chdir(backend_dir)
    else:
        print(f"Backend directory not found at: {backend_dir}")
        print("Make sure you're running this script from the project root directory.")
        sys.exit(1)
    
    setup_virtual_env()
    setup_admin_user()
    
    # Parse command line arguments
    host = '0.0.0.0'  # Default to all interfaces
    port = 5000        # Default port
    
    # Check for custom port
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print(f"Invalid port number: {sys.argv[1]}. Using default port 5000.")
    
    start_server(host, port)