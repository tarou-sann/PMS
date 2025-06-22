from models import db_session, init_db
from models.rice import RiceVariety

def migrate_rice_dates():
    """
    Make production_date and expiration_date optional in existing records
    """
    init_db()
    
    try:
        # Update all existing rice varieties to have null dates if needed
        rice_varieties = RiceVariety.query.all()
        print(f"Found {len(rice_varieties)} rice varieties to check")
        
        for variety in rice_varieties:
            print(f"Rice variety: {variety.variety_name}")
            # The dates will remain as they are, but now they're optional for new entries
        
        db_session.commit()
        print("Migration completed successfully!")
        
    except Exception as e:
        db_session.rollback()
        print(f"Migration failed: {e}")

if __name__ == "__main__":
    migrate_rice_dates()