import sqlite3
import os
import sys

def fix_expected_yield_column():
    """
    Fix the expected_yield_per_hectare column issue
    """
    # Find the database file
    backend_dir = os.path.dirname(__file__)
    db_path = os.path.join(backend_dir, 'pms.db')
    
    if not os.path.exists(db_path):
        print(f"Database file not found at: {db_path}")
        print("Looking for database files...")
        for file in os.listdir(backend_dir):
            if file.endswith('.db'):
                print(f"Found database file: {file}")
        return
    
    print(f"Using database: {db_path}")
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check current table structure
        print("Current rice_varieties table structure:")
        cursor.execute("PRAGMA table_info(rice_varieties)")
        columns = cursor.fetchall()
        
        for col in columns:
            print(f"  {col[1]} ({col[2]}) - Not Null: {col[3]} - Default: {col[4]} - PK: {col[5]}")
        
        column_names = [col[1] for col in columns]
        
        if 'expected_yield_per_hectare' not in column_names:
            print("\nAdding expected_yield_per_hectare column...")
            cursor.execute("ALTER TABLE rice_varieties ADD COLUMN expected_yield_per_hectare REAL")
            conn.commit()
            print("✓ Column added successfully")
        else:
            print("\n✓ Column already exists")
        
        # Verify the column was added
        print("\nVerifying table structure after migration:")
        cursor.execute("PRAGMA table_info(rice_varieties)")
        columns = cursor.fetchall()
        
        for col in columns:
            print(f"  {col[1]} ({col[2]}) - Not Null: {col[3]} - Default: {col[4]} - PK: {col[5]}")
        
        # Test querying the column
        print("\nTesting column access...")
        cursor.execute("SELECT id, variety_name, expected_yield_per_hectare FROM rice_varieties LIMIT 1")
        result = cursor.fetchone()
        print("✓ Column access test successful")
        
        if result:
            print(f"Sample row: ID={result[0]}, Name={result[1]}, Expected Yield={result[2]}")
        
        conn.close()
        print("\n✅ Migration completed successfully!")
        
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    fix_expected_yield_column()