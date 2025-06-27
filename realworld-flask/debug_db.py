import os

print("=== DEBUG DATABASE ENVIRONMENT VARIABLES ===")
print(f"POSTGRES_HOST: '{os.getenv('POSTGRES_HOST')}'")
print(f"POSTGRES_PORT: '{os.getenv('POSTGRES_PORT')}'")
print(f"POSTGRES_DB: '{os.getenv('POSTGRES_DB')}'")
print(f"POSTGRES_USER: '{os.getenv('POSTGRES_USER')}'")
print(f"POSTGRES_PASSWORD: [REDACTED]")

def get_database_url():
    """Get database URL with proper configuration"""
    db_host = os.getenv('POSTGRES_HOST', 'localhost')
    db_port = os.getenv('POSTGRES_PORT', '5432')
    db_name = os.getenv('POSTGRES_DB', 'realworlddb')
    db_user = os.getenv('POSTGRES_USER')
    db_password = os.getenv('POSTGRES_PASSWORD')
    
    print(f"=== CONSTRUCTING DATABASE URL ===")
    print(f"Host: '{db_host}'")
    print(f"Port: '{db_port}'")
    print(f"Database: '{db_name}'")
    print(f"User: '{db_user}'")
    
    url = f"postgresql+psycopg2://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    print(f"Final URL (password redacted): postgresql+psycopg2://{db_user}:[REDACTED]@{db_host}:{db_port}/{db_name}")
    return url

if __name__ == "__main__":
    get_database_url()
