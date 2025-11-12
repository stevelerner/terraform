import os
import psycopg2
from flask import Flask, jsonify, request
from datetime import datetime

app = Flask(__name__)

# Database connection
def get_db_connection():
    conn = psycopg2.connect(os.environ.get('DATABASE_URL'))
    return conn

# Initialize database
def init_db():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('''
            CREATE TABLE IF NOT EXISTS visits (
                id SERIAL PRIMARY KEY,
                timestamp TIMESTAMP NOT NULL,
                message TEXT
            )
        ''')
        conn.commit()
        cur.close()
        conn.close()
        print("Database initialized successfully")
    except Exception as e:
        print(f"Database initialization error: {e}")

@app.route('/')
def home():
    return jsonify({
        "message": "Welcome to Terraform + Docker Demo!",
        "endpoints": {
            "/": "This help message",
            "/health": "Health check",
            "/visit": "Record a visit (POST)",
            "/visits": "Get all visits (GET)",
            "/stats": "Get application statistics"
        },
        "managed_by": "Terraform",
        "infrastructure": "Docker on Mac"
    })

@app.route('/health')
def health():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT 1')
        cur.close()
        conn.close()
        return jsonify({
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }), 500

@app.route('/visit', methods=['POST'])
def record_visit():
    try:
        data = request.get_json() or {}
        message = data.get('message', 'Anonymous visit')
        
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            'INSERT INTO visits (timestamp, message) VALUES (%s, %s) RETURNING id',
            (datetime.now(), message)
        )
        visit_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({
            "success": True,
            "visit_id": visit_id,
            "message": message,
            "timestamp": datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@app.route('/visits')
def get_visits():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT id, timestamp, message FROM visits ORDER BY timestamp DESC LIMIT 50')
        visits = cur.fetchall()
        cur.close()
        conn.close()
        
        return jsonify({
            "visits": [
                {
                    "id": v[0],
                    "timestamp": v[1].isoformat(),
                    "message": v[2]
                } for v in visits
            ],
            "count": len(visits)
        })
    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500

@app.route('/stats')
def stats():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT COUNT(*) FROM visits')
        total_visits = cur.fetchone()[0]
        cur.close()
        conn.close()
        
        return jsonify({
            "total_visits": total_visits,
            "database": "PostgreSQL",
            "web_server": "Nginx",
            "app_framework": "Flask",
            "provisioned_by": "Terraform",
            "infrastructure": "Docker Desktop for Mac"
        })
    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500

if __name__ == '__main__':
    # Wait a bit for database to be ready and initialize
    import time
    time.sleep(2)
    init_db()
    
    # Run the Flask app
    app.run(host='0.0.0.0', port=5000, debug=True)

