import os, sqlite3
from flask import Flask, request, jsonify
app = Flask(__name__)
DB = '/data/scores.db'
os.makedirs('/data', exist_ok=True)
def connect():
    conn = sqlite3.connect(DB)
    conn.execute('CREATE TABLE IF NOT EXISTS scores (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, score INTEGER NOT NULL)')
    return conn
@app.get('/api/health')
def health(): return jsonify(status='ok')
@app.get('/api/scores')
def scores():
    with connect() as conn:
        rows = conn.execute('SELECT name, score FROM scores ORDER BY score DESC, id ASC LIMIT 10').fetchall()
    return jsonify([{'name':name,'score':score} for name,score in rows])
@app.post('/api/scores')
def add_score():
    data = request.get_json(silent=True) or {}
    name = str(data.get('name','Player')).strip()[:24] or 'Player'
    score = data.get('score')
    if type(score) is not int or not 0 <= score <= 1000000:
        return jsonify(error='Invalid score'), 400
    with connect() as conn: conn.execute('INSERT INTO scores (name,score) VALUES (?,?)',(name,score))
    return jsonify(message='Saved'),201
if __name__=='__main__': app.run(host='0.0.0.0',port=5000)
