import sqlalchemy
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from urllib.parse import quote_plus

# Anslutningssträng
server = "NAZARY_AI"
params = quote_plus(
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={server};"
    f"DATABASE=BokhandelDB;"
    f"Trusted_Connection=yes;"
)
connection_string = "mssql+pyodbc:///?odbc_connect=" + params

# Skapa engine och session, sätt echo=False för att undvika debug-loggning
engine = create_engine(connection_string, echo=False)
Session = sessionmaker(bind=engine)
session = Session()

def search_books(query):
    """
    Utför en fri textsökning mot kolumnen Titel i tabellen Böcker.
    Returnerar även lagersaldo och butik för varje sökträff.
    Skyddar mot SQL-injektion genom att använda parameterisering.
    """
    search_pattern = f"%{query}%"
    
    sql = text("""
        SELECT b.ISBN13, b.Titel, b.Språk, b.Pris, b.Utgivningsdatum, 
               ls.ButikID, ls.Antal, bt.Butiksnamn
        FROM Böcker AS b
        LEFT JOIN LagerSaldo AS ls ON b.ISBN13 = ls.ISBN13
        LEFT JOIN Butiker AS bt ON ls.ButikID = bt.ID
        WHERE b.Titel LIKE :pattern
        ORDER BY b.Titel;
    """)
    
    result = session.execute(sql, {"pattern": search_pattern})
    rows = result.fetchall()
    
    if rows:
        for row in rows:
            print(f"ISBN: {row.ISBN13} | Titel: {row.Titel} | Språk: {row.Språk} | "
                  f"Pris: {row.Pris} | Utgivningsdatum: {row.Utgivningsdatum} | "
                  f"Butik: {row.Butiksnamn} (ID: {row.ButikID}) | Antal: {row.Antal}")
    else:
        print(f"Inga böcker med titeln '{query}' hittades.")

if __name__ == '__main__':
    user_query = input("Ange en sökterm för boktitlar: ")
    search_books(user_query)
