from flask import Flask, request, jsonify
import socket
import os
import json

app = Flask(__name__)

# Check if DB is enabled
DB_ENABLED = os.getenv('DB_ENABLED', 'false').lower() == 'true'

if DB_ENABLED:
    import boto3
    import psycopg2
    from psycopg2 import pool

    # Initialize connection pool
    db_pool = None

    def get_db_credentials():
        """Retrieve DB credentials from Secrets Manager"""
        secret_name = os.getenv('DB_SECRET_NAME')
        region = os.getenv('AWS_REGION', 'us-east-1')
        
        try:
            client = boto3.client('secretsmanager', region_name=region)
            response = client.get_secret_value(SecretId=secret_name)
            secret = json.loads(response['SecretString'])
            return secret
        except Exception as e:
            print(f"Error retrieving secret: {e}")
            raise

    def init_db_pool():
        """Initialize database connection pool"""
        global db_pool
        if db_pool is None:
            try:
                creds = get_db_credentials()
                db_pool = psycopg2.pool.SimpleConnectionPool(
                    1, 10,  # min and max connections
                    host=os.getenv('DB_HOST'),
                    database=os.getenv('DB_NAME', 'postgres'),
                    user=creds['username'],
                    password=creds['password'],
                    port=5432,
                    sslmode='require'
                )
                print("Database connection pool initialized")
            except Exception as e:
                print(f"Error initializing DB pool: {e}")
                raise

    def get_db_connection():
        """Get a connection from the pool"""
        if db_pool is None:
            init_db_pool()
        return db_pool.getconn()

    def return_db_connection(conn):
        """Return connection to the pool"""
        if db_pool:
            db_pool.putconn(conn)

@app.route('/')
def info():
    return jsonify({
        'ip': request.remote_addr,
        'port': request.environ.get('REMOTE_PORT'),
        'host': socket.gethostname(),
        'instance_id': os.getenv('HOSTNAME'),
        'db_enabled': DB_ENABLED
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    health_status = {
        'status': 'healthy',
        'host': socket.gethostname(),
        'db_enabled': DB_ENABLED
    }
    
    if DB_ENABLED:
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute('SELECT 1;')
            cursor.close()
            return_db_connection(conn)
            health_status['database'] = 'connected'
        except Exception as e:
            health_status['database'] = 'disconnected'
            health_status['db_error'] = str(e)
            return jsonify(health_status), 500
    
    return jsonify(health_status)

if DB_ENABLED:
    @app.route('/db/test')
    def test_db():
        """Test database connection and query"""
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute('SELECT version();')
            version = cursor.fetchone()
            cursor.close()
            return_db_connection(conn)
            return jsonify({
                'status': 'success',
                'db_version': version[0]
            })
        except Exception as e:
            return jsonify({
                'status': 'error',
                'message': str(e)
            }), 500

    @app.route('/db/init')
    def init_db():
        """Initialize sample database table"""
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            
            # Create sample table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS sample_requests (
                    id SERIAL PRIMARY KEY,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    remote_ip VARCHAR(50),
                    hostname VARCHAR(100),
                    user_agent TEXT
                );
            ''')
            
            conn.commit()
            cursor.close()
            return_db_connection(conn)
            
            return jsonify({
                'status': 'success',
                'message': 'Database table created successfully'
            })
        except Exception as e:
            return jsonify({
                'status': 'error',
                'message': str(e)
            }), 500

    @app.route('/db/log')
    def log_request():
        """Log current request to database"""
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO sample_requests (remote_ip, hostname, user_agent)
                VALUES (%s, %s, %s)
                RETURNING id, timestamp;
            ''', (
                request.remote_addr,
                socket.gethostname(),
                request.headers.get('User-Agent', 'Unknown')
            ))
            
            result = cursor.fetchone()
            conn.commit()
            cursor.close()
            return_db_connection(conn)
            
            return jsonify({
                'status': 'success',
                'record_id': result[0],
                'timestamp': str(result[1])
            })
        except Exception as e:
            return jsonify({
                'status': 'error',
                'message': str(e)
            }), 500

    @app.route('/db/records')
    def get_records():
        """Query recent records from database"""
        try:
            limit = request.args.get('limit', 10, type=int)
            conn = get_db_connection()
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT id, timestamp, remote_ip, hostname, user_agent
                FROM sample_requests
                ORDER BY timestamp DESC
                LIMIT %s;
            ''', (limit,))
            
            rows = cursor.fetchall()
            cursor.close()
            return_db_connection(conn)
            
            records = [
                {
                    'id': row[0],
                    'timestamp': str(row[1]),
                    'remote_ip': row[2],
                    'hostname': row[3],
                    'user_agent': row[4]
                }
                for row in rows
            ]
            
            return jsonify({
                'status': 'success',
                'count': len(records),
                'records': records
            })
        except Exception as e:
            return jsonify({
                'status': 'error',
                'message': str(e)
            }), 500

if __name__ == '__main__':
    if DB_ENABLED:
        print("Starting app with database support enabled")
        try:
            init_db_pool()
        except Exception as e:
            print(f"Warning: Could not initialize database pool: {e}")
    else:
        print("Starting app without database support")
    
    app.run(host='0.0.0.0', port=8080)
