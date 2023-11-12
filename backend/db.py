import sqlite3
import uuid
from datetime import datetime
def create_db():
    db = sqlite3.connect("chess_db")
    curr = db.cursor()
    create_table_query = '''
        CREATE TABLE IF NOT EXISTS active (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT NOT NULL,
            fen TEXT NOT NULL, 
            date DATE NOT NULL
        )
    '''
    curr.execute(create_table_query)

    db.commit()
    curr.close()

def insert_db(fen, uuid):
    db = sqlite3.connect("chess_db")
    curr = db.cursor()
    insert_table_query = '''
        INSERT INTO active(uuid,fen,date) VALUES (?,?,?)
    '''

    curr.execute(insert_table_query, (uuid, fen, datetime.now()))

    db.commit()
    curr.close()

def get_entry(uuid):
    db = sqlite3.connect("chess_db")
    curr = db.cursor()
    insert_table_query = '''
        SELECT fen FROM active WHERE uuid={uuid} ORDER BY date DESC
    '''
    res = curr.execute(insert_table_query, uuid).one()
    curr.close()
    return res


if __name__ == "__main__":
    create_db()



