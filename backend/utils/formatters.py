def format_id(id_value):
    """Format ID to 4-digit string with leading zeros"""
    if id_value is None:
        return "0000"
    return f"{int(id_value):04d}"