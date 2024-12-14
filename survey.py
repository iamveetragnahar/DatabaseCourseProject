from flask import Flask, request, jsonify, render_template
import mysql.connector
from mysql.connector import Error
import json
from datetime import datetime

app = Flask(__name__, template_folder='.', static_folder='.')

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',  # Replace with your MySQL username
    'password': 'veetZXC@123',  # Replace with your MySQL password
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
    return render_template('survey.html')

@app.route('/api/surveys', methods=['GET'])
def get_surveys():
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("""
            SELECT s.*, 
                   GROUP_CONCAT(q.id) as question_ids,
                   GROUP_CONCAT(q.question_text) as questions,
                   GROUP_CONCAT(q.question_type) as question_types,
                   GROUP_CONCAT(q.options) as options
            FROM surveys s
            LEFT JOIN survey_questions q ON s.id = q.survey_id
            GROUP BY s.id
            ORDER BY s.created_at DESC
        """)
        surveys = cursor.fetchall()

        processed_surveys = []
        for survey in surveys:
            processed_survey = {
                'id': survey['id'],
                'title': survey['title'],
                'description': survey['description'],
                'event_type': survey['event_type'],
                'created_at': survey['created_at'].strftime('%Y-%m-%d %H:%M:%S'),
                'questions': []
            }

            if survey['question_ids']:
                question_ids = survey['question_ids'].split(',')
                question_texts = survey['questions'].split(',')
                question_types = survey['question_types'].split(',')
                options_list = survey['options'].split(',')
                
                for i in range(len(question_ids)):
                    question = {
                        'id': int(question_ids[i]),
                        'text': question_texts[i],
                        'type': question_types[i],
                        'options': json.loads(options_list[i]) if options_list[i] != 'null' else []
                    }
                    processed_survey['questions'].append(question)

            processed_surveys.append(processed_survey)

        return jsonify(processed_surveys)

    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/api/surveys', methods=['POST'])
def create_survey():
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500

    data = request.json
    try:
        cursor = connection.cursor()
        
        # Insert survey
        cursor.execute("""
            INSERT INTO surveys (title, description, event_type)
            VALUES (%s, %s, %s)
        """, (data['title'], data['description'], data['eventType']))
        
        survey_id = cursor.lastrowid
        
        # Insert questions
        for question in data['questions']:
            cursor.execute("""
                INSERT INTO survey_questions 
                (survey_id, question_text, question_type, options)
                VALUES (%s, %s, %s, %s)
            """, (
                survey_id,
                question['text'],
                question['type'],
                json.dumps(question.get('options', []))
            ))
        
        connection.commit()
        return jsonify({'message': 'Survey created successfully', 'id': survey_id})

    except Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/api/surveys/<int:survey_id>', methods=['GET'])
def get_survey(survey_id):
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("""
            SELECT s.*, q.id as question_id, q.question_text, q.question_type, q.options
            FROM surveys s
            LEFT JOIN survey_questions q ON s.id = q.survey_id
            WHERE s.id = %s
        """, (survey_id,))
        
        rows = cursor.fetchall()
        if not rows:
            return jsonify({'error': 'Survey not found'}), 404

        survey = {
            'id': rows[0]['id'],
            'title': rows[0]['title'],
            'description': rows[0]['description'],
            'event_type': rows[0]['event_type'],
            'created_at': rows[0]['created_at'].strftime('%Y-%m-%d %H:%M:%S'),
            'questions': []
        }

        for row in rows:
            if row['question_id']:
                question = {
                    'id': row['question_id'],
                    'text': row['question_text'],
                    'type': row['question_type'],
                    'options': json.loads(row['options']) if row['options'] else []
                }
                survey['questions'].append(question)

        return jsonify(survey)

    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/api/surveys/<int:survey_id>', methods=['DELETE'])
def delete_survey(survey_id):
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = connection.cursor()
        
        # Delete questions first (due to foreign key constraint)
        cursor.execute("DELETE FROM survey_questions WHERE survey_id = %s", (survey_id,))
        
        # Delete survey
        cursor.execute("DELETE FROM surveys WHERE id = %s", (survey_id,))
        
        connection.commit()
        return jsonify({'message': 'Survey deleted successfully'})

    except Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000)