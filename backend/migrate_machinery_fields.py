import sqlite3
import os

def migrate_machinery_fields():
    """
    Add hour_meter and repairs_needed columns to machinery table
    """
    db_path = os.path.join(os.path.dirname(__file__), 'pms.db')
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if columns already exist
        cursor.execute("PRAGMA table_info(machinery)")
        columns = [column[1] for column in cursor.fetchall()]
        
        # Add hour_meter column if it doesn't exist
        if 'hour_meter' not in columns:
            cursor.execute("ALTER TABLE machinery ADD COLUMN hour_meter INTEGER DEFAULT 0")
            print("Added hour_meter column to machinery table")
        
        # Add repairs_needed column if it doesn't exist
        if 'repairs_needed' not in columns:
            cursor.execute("ALTER TABLE machinery ADD COLUMN repairs_needed BOOLEAN DEFAULT 0")
            print("Added repairs_needed column to machinery table")
        
        conn.commit()
        print("Migration completed successfully!")
        
    except Exception as e:
        print(f"Migration failed: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    migrate_machinery_fields()