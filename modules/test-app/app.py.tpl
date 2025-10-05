from flask import Flask, request
import socket
import os

app = Flask(__name__)

@app.route('/')
def info():
    return {
        'ip': request.remote_addr,
        'port': request.environ.get('REMOTE_PORT'),
        'host': socket.gethostname(),
        'instance_id': os.getenv('HOSTNAME')
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
