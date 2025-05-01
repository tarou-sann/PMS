from sqlalchemy import create_engine, MetaData, Table, Column, String
import os
from pathlib import Path

# Import your database connection from the correct module
# Adjust this import based on where your database connection is defined
try:
    # Try to get DATABASE_URI from config file
    try:
        from config import SQLALCHEMY_DATABASE_URI as DATABASE_URI
    except ImportError:
        from config import DATABASE_URL as DATABASE_URI
except ImportError:
    # If not found, check typical environment variables or provide a default
    DATABASE_URI = os.environ.get('DATABASE_URL', 'sqlite:///app.db')

# If still not resolved, try to locate the database file
if 'sqlite:///' in DATABASE_URI and not os.path.exists(DATABASE_URI.replace('sqlite:///', '')):
    # Try to find the SQLite database file
    base_dir = Path(__file__).parent
    db_files = list(base_dir.glob('*.db'))
    if db_files:
        DATABASE_URI = f"sqlite:///{db_files[0]}"
    else:
        # Default location if everything fails
        DATABASE_URI = 'sqlite:///app.db'

print(f"Using database: {DATABASE_URI}")

def modify_email_column():
    """Make email column nullable in users table"""
    engine = create_engine(DATABASE_URI)
    
    # Connect to the database
    connection = engine.connect()
    
    try:
        # Start a transaction
        transaction = connection.begin()
        
        # Execute SQL to modify the column
        connection.execute("PRAGMA foreign_keys=off")
        
        # Create a temporary table
        connection.execute("""
        CREATE TABLE users_temp (
            id INTEGER PRIMARY KEY,
            username VARCHAR(50) NOT NULL UNIQUE,
            password_hash VARCHAR(128) NOT NULL,
            email VARCHAR(100),
            security_question VARCHAR(100) NOT NULL,
            security_answer_hash VARCHAR(128) NOT NULL,
            is_admin BOOLEAN DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """)
        
        # Copy data
        connection.execute("""
        INSERT INTO users_temp 
        SELECT id, username, password_hash, email, security_question, security_answer_hash, 
               is_admin, created_at, updated_at 
        FROM users
        """)
        
        # Drop old table
        connection.execute("DROP TABLE users")
        
        # Rename new table
        connection.execute("ALTER TABLE users_temp RENAME TO users")
        
        # Re-enable foreign keys
        connection.execute("PRAGMA foreign_keys=on")
        
        # Commit the transaction
        transaction.commit()
        
        print("Successfully made email column nullable")
        
    except Exception as e:
        # Roll back in case of error
        transaction.rollback()
        print(f"Error: {str(e)}")
        raise
    finally:
        # Close the connection
        connection.close()

if __name__ == "__main__":
    modify_email_column()