from flask import Flask, request, jsonify, render_template
import mysql.connector
from mysql.connector import Error
from datetime import datetime
import json

app = Flask(__name__, template_folder='.', static_folder='.')

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'veetZXC@123',
    'database': 'hospital_dba'
}

def get_db_connection():
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        print(f"Error connecting to database: {e}")
        return None

@app.route('/')
def home():
    return render_template('notification.html')

@app.route('/api/notifications', methods=['GET'])
def get_notifications():
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = connection.cursor(dictionary=True)
        recipient_id = request.args.get('recipient_id', 1)  # Default for testing
        
        # First get notifications
        cursor.execute("""
            SELECT n.*
            FROM notifications n
            WHERE n.recipient_id = %s
            ORDER BY 
                CASE 
                    WHEN n.priority = 'urgent' THEN 1
                    WHEN n.priority = 'high' THEN 2
                    WHEN n.priority = 'normal' THEN 3
                    ELSE 4
                END,
                n.created_at DESC
        """, (recipient_id,))
        
        notifications = cursor.fetchall()
        
        # For each notification, get its responses
        for notification in notifications:
            cursor.execute("""
                SELECT id, response_text, created_at
                FROM notification_responses
                WHERE notification_id = %s
                ORDER BY created_at DESC
            """, (notification['id'],))
            
            responses = cursor.fetchall()
            notification['responses'] = []
            
            for response in responses:
                notification['responses'].append({
                    'id': response['id'],
                    'response_text': response['response_text'],
                    'created_at': response['created_at'].strftime('%Y-%m-%d %H:%M:%S')
                })
            
            # Convert datetime objects to strings
            notification['created_at'] = notification['created_at'].strftime('%Y-%m-%d %H:%M:%S')
            if notification['read_at']:
                notification['read_at'] = notification['read_at'].strftime('%Y-%m-%d %H:%M:%S')
                
        return jsonify(notifications)

    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/api/notifications', methods=['POST'])
def create_notification():
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500

    data = request.json
    try:
        cursor = connection.cursor()
        
        cursor.execute("""
            INSERT INTO notifications 
            (sender_id, recipient_id, subject, message, priority)
            VALUES (%s, %s, %s, %s, %s)
        """, (
            data.get('sender_id', 1),  # Default sender_id for testing
            data['recipient_id'],
            data['subject'],
            data['message'],
            data.get('priority', 'normal')
        ))
        
        notification_id = cursor.lastrowid
        connection.commit()
        
        return jsonify({
            'message': 'Notification created successfully',
            'id': notification_id
        })

    except Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/api/notifications/<int:notification_id>/read', methods=['PUT'])
def mark_as_read(notification_id):
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = connection.cursor()
        cursor.execute("""
            UPDATE notifications 
            SET status = 'read', read_at = CURRENT_TIMESTAMP
            WHERE id = %s
        """, (notification_id,))
        
        connection.commit()
        return jsonify({'message': 'Notification marked as read'})

    except Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/api/notifications/<int:notification_id>/respond', methods=['POST'])
def respond_to_notification(notification_id):
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500

    data = request.json
    try:
        cursor = connection.cursor()
        
        cursor.execute("""
            INSERT INTO notification_responses 
            (notification_id, responder_id, response_text)
            VALUES (%s, %s, %s)
        """, (
            notification_id,
            data.get('responder_id', 1),  # Default responder_id for testing
            data['response']
        ))
        
        connection.commit()
        return jsonify({'message': 'Response added successfully'})

    except Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000)