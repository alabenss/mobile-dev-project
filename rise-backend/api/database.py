import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
# ⚠️ IMPORTANT: Use SERVICE ROLE key for backend, not anon key
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_KEY")  

if not SUPABASE_URL or not SUPABASE_KEY:
    raise RuntimeError(
        "Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in .env (rise-backend/.env)"
    )

# Create Supabase client with service role key
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# --- Simple helpers (recommended) ---

def select(table: str, columns="*", filters: dict | None = None, single=False):
    """
    Select records from a table
    
    Args:
        table: Table name
        columns: Columns to select (default: "*")
        filters: Dictionary of filters {column: value}
        single: Return single record instead of list
    
    Returns:
        Single record (dict) if single=True, otherwise list of records
    """
    q = supabase.table(table).select(columns)
    if filters:
        for k, v in filters.items():
            q = q.eq(k, v)
    res = q.execute()
    return (res.data[0] if res.data else None) if single else res.data

def insert(table: str, data: dict):
    """
    Insert a record into a table
    
    Args:
        table: Table name
        data: Dictionary of data to insert
    
    Returns:
        List containing the inserted record
    """
    res = supabase.table(table).insert(data).execute()
    return res.data

def update(table: str, data: dict, filters: dict):
    """
    Update records in a table
    
    Args:
        table: Table name
        data: Dictionary of data to update
        filters: Dictionary of filters {column: value}
    
    Returns:
        List of updated records
    """
    q = supabase.table(table).update(data)
    for k, v in filters.items():
        q = q.eq(k, v)
    res = q.execute()
    return res.data

def delete(table: str, filters: dict):
    """
    Delete records from a table
    
    Args:
        table: Table name
        filters: Dictionary of filters {column: value}
    
    Returns:
        List of deleted records
    """
    q = supabase.table(table).delete()
    for k, v in filters.items():
        q = q.eq(k, v)
    res = q.execute()
    return res.data

# --- Auth helpers ---

def verify_token(token: str):
    """
    Verify JWT token and return user
    
    Args:
        token: JWT access token
    
    Returns:
        User object if valid, None otherwise
    """
    try:
        user = supabase.auth.get_user(token)
        return user
    except Exception as e:
        print(f"Token verification error: {e}")
        return None