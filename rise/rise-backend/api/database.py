import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_ANON_KEY")  # for now use anon key

if not SUPABASE_URL or not SUPABASE_KEY:
    raise RuntimeError(
        "Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env (rise-backend/.env)"
    )

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# --- Simple helpers (recommended) ---

def select(table: str, columns="*", filters: dict | None = None, single=False):
    q = supabase.table(table).select(columns)
    if filters:
        for k, v in filters.items():
            q = q.eq(k, v)
    res = q.execute()
    return (res.data[0] if res.data else None) if single else res.data

def insert(table: str, data: dict):
    res = supabase.table(table).insert(data).execute()
    return res.data

def update(table: str, data: dict, filters: dict):
    q = supabase.table(table).update(data)
    for k, v in filters.items():
        q = q.eq(k, v)
    res = q.execute()
    return res.data

def delete(table: str, filters: dict):
    q = supabase.table(table).delete()
    for k, v in filters.items():
        q = q.eq(k, v)
    res = q.execute()
    return res.data
