from models import db_session, init_db
from sqlalchemy import text

def add_expected_yield_column():
    """
    Add expected_yield_per_hectare column to rice_varieties table
    """
    init_db()
    
    try:
        # Check if column already exists
        result = db_session.execute(text("PRAGMA table_info(rice_varieties)"))
        columns = [row[1] for row in result]
        
        if 'expected_yield_per_hectare' not in columns:
            # Add the new column
            db_session.execute(text(
                "ALTER TABLE rice_varieties ADD COLUMN expected_yield_per_hectare REAL"
            ))
            db_session.commit()
            print("Successfully added expected_yield_per_hectare column to rice_varieties table")
        else:
            print("Column expected_yield_per_hectare already exists")
        
    except Exception as e:
        db_session.rollback()
        print(f"Migration failed: {e}")

if __name__ == "__main__":
    add_expected_yield_column()