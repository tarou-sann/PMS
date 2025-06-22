import sqlite3
import os

def migrate_production_tracking():
    """Add farmer_name and municipality columns to production_tracking table"""
    db_path = os.path.join(os.path.dirname(__file__), 'pms.db')
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if columns already exist
        cursor.execute("PRAGMA table_info(production_tracking)")
        columns = [column[1] for column in cursor.fetchall()]
        
        # Add farmer_name column if it doesn't exist
        if 'farmer_name' not in columns:
            cursor.execute("ALTER TABLE production_tracking ADD COLUMN farmer_name TEXT")
            print("Added farmer_name column")
        else:
            print("farmer_name column already exists")
            
        # Add municipality column if it doesn't exist
        if 'municipality' not in columns:
            cursor.execute("ALTER TABLE production_tracking ADD COLUMN municipality TEXT")
            print("Added municipality column")
        else:
            print("municipality column already exists")
            
        # Update existing records with default values
        cursor.execute("""
            UPDATE production_tracking 
            SET farmer_name = 'Unknown', municipality = 'Pila' 
            WHERE farmer_name IS NULL OR municipality IS NULL
        """)
        
        conn.commit()
        conn.close()
        
        print("Migration completed successfully!")
        
    except Exception as e:
        print(f"Migration failed: {e}")
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    migrate_production_tracking()