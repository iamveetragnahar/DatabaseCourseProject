from flask import Flask, request, jsonify, send_from_directory
import mysql.connector
from mysql.connector import Error
import os

app = Flask(__name__)

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',  # Change to your MySQL username
    'password': 'veetZXC@123',  # Change to your MySQL password
    'database': 'hospital_management'
}

def get_db_connection():
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

@app.route('/')
def home():
    return send_from_directory('.', 'frontend.html')

@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')

        if not username or not password:
            return jsonify({
                'success': False,
                'message': 'Username and password are required'
            })

        conn = get_db_connection()
        if not conn:
            return jsonify({
                'success': False,
                'message': 'Database connection error'
            })

        cursor = conn.cursor(dictionary=True)
        query = "SELECT user_id, role, password FROM users WHERE username = %s AND is_active = TRUE"
        cursor.execute(query, (username,))
        user = cursor.fetchone()

        cursor.close()
        conn.close()

        if not user:
            return jsonify({
                'success': False,
                'message': 'Invalid username or account not active'
            })

        # Check password (assuming plaintext; use hashing in production)
        if user['password'] != password:
            return jsonify({
                'success': False,
                'message': 'Incorrect password'
            })

        return jsonify({
            'success': True,
            'role': user['role']
        })

    except Exception as e:
        print(f"Error in login: {e}")
        return jsonify({
            'success': False,
            'message': 'An error occurred during login'
        })

@app.route('/signup', methods=['POST'])
def signup():
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        role = data.get('role')
        security_question = data.get('security_question')
        security_answer = data.get('security_answer')

        if not all([username, password, role, security_question, security_answer]):
            return jsonify({
                'success': False,
                'message': 'All fields are required'
            })

        conn = get_db_connection()
        if not conn:
            return jsonify({
                'success': False,
                'message': 'Database connection error'
            })

        cursor = conn.cursor(dictionary=True)
        query = """
        INSERT INTO users (username, password, role, security_question, security_answer)
        VALUES (%s, %s, %s, %s, %s)
        """
        try:
            cursor.execute(query, (username, password, role, security_question, security_answer))
            conn.commit()
        except mysql.connector.IntegrityError:
            return jsonify({
                'success': False,
                'message': 'Username already exists'
            })

        cursor.close()
        conn.close()

        return jsonify({
            'success': True,
            'message': 'Registration successful'
        })

    except Exception as e:
        print(f"Error in signup: {e}")
        return jsonify({
            'success': False,
            'message': 'An error occurred during registration'
        })

@app.route('/forgot-password', methods=['POST'])
def forgot_password():
    try:
        data = request.get_json()
        username = data.get('username')

        if not username:
            return jsonify({
                'success': False,
                'message': 'Username is required'
            })

        conn = get_db_connection()
        if not conn:
            return jsonify({
                'success': False,
                'message': 'Database connection error'
            })

        cursor = conn.cursor(dictionary=True)
        query = "SELECT security_question FROM users WHERE username = %s"
        cursor.execute(query, (username,))
        user = cursor.fetchone()

        cursor.close()
        conn.close()

        if not user:
            return jsonify({
                'success': False,
                'message': 'User not found'
            })

        return jsonify({
            'success': True,
            'security_question': user['security_question']
        })

    except Exception as e:
        print(f"Error in forgot password: {e}")
        return jsonify({
            'success': False,
            'message': 'An error occurred'
        })

@app.route('/reset-password', methods=['POST'])
def reset_password():
    try:
        data = request.get_json()
        username = data.get('username')
        security_answer = data.get('security_answer')
        new_password = data.get('new_password')

        if not all([username, security_answer, new_password]):
            return jsonify({
                'success': False,
                'message': 'All fields are required'
            })

        conn = get_db_connection()
        if not conn:
            return jsonify({
                'success': False,
                'message': 'Database connection error'
            })

        cursor = conn.cursor(dictionary=True)
        query = """
        SELECT security_answer FROM users WHERE username = %s
        """
        cursor.execute(query, (username,))
        user = cursor.fetchone()

        if not user or user['security_answer'] != security_answer:
            return jsonify({
                'success': False,
                'message': 'Invalid security answer'
            })

        update_query = "UPDATE users SET password = %s WHERE username = %s"
        cursor.execute(update_query, (new_password, username))
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            'success': True,
            'message': 'Password reset successful'
        })

    except Exception as e:
        print(f"Error in reset password: {e}")
        return jsonify({
            'success': False,
            'message': 'An error occurred during password reset'
        })

if __name__ == '__main__':
    app.run(debug=True)
