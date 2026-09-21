from flask import Flask, jsonify
import os
import socket
from datetime import datetime, timezone

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "application": "OrderHub",
        "message": "Azure AKS HA Lab is running!",
        "version": "1.0.0",
        "hostname": socket.gethostname(),
        "region": os.getenv("REGION", "local"),
        "environment": os.getenv("ENVIRONMENT", "dev"),
        "timestamp": datetime.now(timezone.utc).isoformat()
    })

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "hostname": socket.gethostname(),
        "region": os.getenv("REGION", "local")
    }), 200

@app.route("/api/info")
def info():
    return jsonify({
        "application": "OrderHub API",
        "version": "1.0.0",
        "hostname": socket.gethostname(),
        "region": os.getenv("REGION", "local"),
        "environment": os.getenv("ENVIRONMENT", "dev")
    })

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=8080
    )