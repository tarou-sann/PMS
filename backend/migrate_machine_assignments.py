import sqlite3
import os

def migrate_machine_assignments():
    """
    Create machine_assignments table
    """
    db_path = os.path.join(os.path.dirname(__file__), 'pms.db')
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Create machine_assignments table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS machine_assignments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                machinery_id INTEGER NOT NULL,
                rentee_name VARCHAR(100) NOT NULL,
                start_hour_meter INTEGER NOT NULL,
                end_hour_meter INTEGER,
                assignment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                return_date DATETIME,
                is_active BOOLEAN DEFAULT 1,
                notes VARCHAR(500),
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (machinery_id) REFERENCES machinery (id) ON DELETE CASCADE
            )
        ''')
        
        print("Created machine_assignments table successfully!")
        
        conn.commit()
        print("Migration completed successfully!")
        
    except Exception as e:
        print(f"Migration failed: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    migrate_machine_assignments()