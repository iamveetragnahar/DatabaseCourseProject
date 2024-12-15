from flask import Flask, request, render_template, jsonify, redirect, url_for
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

# MySQL database configuration
db_config = {
    'host': 'localhost',
    'user': 'root',   # Replace with your DB username
    'password': 'Amithesh21893',  # Replace with your DB password
    'database': 'healthcaremanagement'  # Ensure this matches your database name
}

# Database connection helper
def get_db_connection():
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except Error as e:
        print(f"Error: {e}")
        return None

# Index route
@app.route('/')
def index():
    return render_template('index.html')

# Route for displaying and creating appointments
@app.route('/appointments', methods=['GET', 'POST'])
def appointments():
    conn = get_db_connection()
    if not conn:
        return "Error connecting to the database", 500

    try:
        cursor = conn.cursor(dictionary=True)

        # Fetch all patients
        cursor.execute("SELECT patient_id, patient_name FROM patients")
        patients = cursor.fetchall()

        # Fetch all physicians
        cursor.execute("SELECT physician_id, physician_name FROM physicians")
        physicians = cursor.fetchall()

        message = None
        selected_patient_id = request.args.get('patient_id', None)

        if request.method == 'POST':
            # Handle creation of appointment
            patient_id = request.form.get('patient_id')
            appointment_date = request.form.get('appointment_date')
            appointment_time = request.form.get('appointment_time')
            physician_id = request.form.get('physician_id')
            notes = request.form.get('notes')
            status = 'Scheduled'  # Default status

            # Combine date and time into a datetime string
            appointment_datetime = f"{appointment_date} {appointment_time}"

            # Call stored procedure to create appointment
            cursor.callproc('create_appointment', [patient_id, physician_id, appointment_datetime, notes, status])
            conn.commit()
            message = "Appointment created successfully"

        # If a patient is selected, load their appointments
        patient_appointments = None
        selected_patient_name = None
        if selected_patient_id:
            # Get the patient's name
            cursor.execute("SELECT patient_name FROM patients WHERE patient_id = %s", (selected_patient_id,))
            patient_row = cursor.fetchone()
            if patient_row:
                selected_patient_name = patient_row['patient_name']

            # Retrieve that patient's appointments
            query = """
                SELECT a.appointment_id, a.appointment_datetime, a.notes, a.status, p.physician_name
                FROM appointments a
                JOIN physicians p ON a.physician_id = p.physician_id
                WHERE a.patient_id = %s
                ORDER BY a.appointment_datetime
            """
            cursor.execute(query, (selected_patient_id,))
            patient_appointments = cursor.fetchall()

        return render_template('appointments.html', 
                               patients=patients, 
                               physicians=physicians,
                               message=message,
                               selected_patient_id=selected_patient_id,
                               selected_patient_name=selected_patient_name,
                               patient_appointments=patient_appointments)

    except Error as e:
        return f"Error: {e}", 500
    finally:
        cursor.close()
        conn.close()

# Manage appointments by patient (select patient to view appointments)
@app.route('/manage_appointments', methods=['POST'])
def manage_appointments():
    patient_id = request.form.get('patient_id')
    if patient_id:
        return redirect(url_for('appointments', patient_id=patient_id))
    return redirect(url_for('appointments'))

# Delete an appointment
@app.route('/delete_appointment', methods=['POST'])
def delete_appointment():
    appointment_id = request.form.get('appointment_id')
    selected_patient_id = request.form.get('patient_id')

    conn = get_db_connection()
    if not conn:
        return "Error connecting to the database", 500

    try:
        cursor = conn.cursor()
        # Call the delete_appointment stored procedure
        cursor.callproc('delete_appointment', [appointment_id])
        conn.commit()
    except Error as e:
        return f"Error: {e}", 500
    finally:
        cursor.close()
        conn.close()

    # Redirect back to the appointments page for the same patient
    if selected_patient_id:
        return redirect(url_for('appointments', patient_id=selected_patient_id))
    else:
        return redirect(url_for('appointments'))

# Retrieve appointments route
@app.route('/retrieve_appointments', methods=['GET'])
def retrieve_appointments():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Error connecting to the database"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('retrieve_appointments')

        results = []
        for result in cursor.stored_results():
            results = result.fetchall()
        
        return jsonify(results)

    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# Patient profile route
@app.route('/profile', methods=['GET', 'POST'])
def profile():
    conn = get_db_connection()
    if not conn:
        return "Error connecting to the database", 500

    try:
        cursor = conn.cursor()

        if request.method == 'POST':
            patient_name = request.form.get('patientName')
            date_of_birth = request.form.get('patientDOB')
            contact_info = request.form.get('patientContact')
            address = request.form.get('patientAddress')

            cursor.callproc('create_patient', [patient_name, date_of_birth, contact_info, address])
            conn.commit()

            return render_template('profile.html', message="Patient profile created successfully")

        return render_template('profile.html')

    except Error as e:
        return f"Database error: {e}", 500
    finally:
        cursor.close()
        conn.close()

# Retrieve patients route
@app.route('/retrieve_patients', methods=['GET'])
def retrieve_patients():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Error connecting to the database"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('retrieve_patients')

        results = []
        for result in cursor.stored_results():
            results = result.fetchall()
        
        return jsonify(results)

    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# SOAP records route
@app.route('/soap', methods=['GET', 'POST'])
def soap():
    conn = get_db_connection()
    if not conn:
        return "Error connecting to the database", 500

    try:
        cursor = conn.cursor(dictionary=True)

        # Fetch all patients
        cursor.execute("SELECT patient_id, patient_name FROM patients")
        patients = cursor.fetchall()

        # Fetch all physicians
        cursor.execute("SELECT physician_id, physician_name FROM physicians")
        physicians = cursor.fetchall()

        if request.method == 'POST':
            patient_id = request.form.get('soapPatient')
            physician_id = request.form.get('soapPhysician')
            visit_datetime = request.form.get('visitDatetime')
            subjective_observations = request.form.get('soapSubjective')
            objective_data = request.form.get('soapObjective')
            diagnosis = request.form.get('soapDiagnosis')
            treatment_plan = request.form.get('soapTreatment')

            import json
            try:
                objective_data_json = json.dumps(objective_data)
            except:
                objective_data_json = None

            cursor.callproc('create_soap_record', [
                patient_id,
                physician_id,
                visit_datetime,
                subjective_observations,
                objective_data_json,
                diagnosis,
                treatment_plan
            ])
            conn.commit()

            return render_template('soap.html', patients=patients, physicians=physicians, message="SOAP record created successfully")

        return render_template('soap.html', patients=patients, physicians=physicians)

    except Error as e:
        return f"Database error: {e}", 500
    finally:
        cursor.close()
        conn.close()

# Retrieve SOAP records route
@app.route('/retrieve_soap_records', methods=['GET'])
def retrieve_soap_records():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Error connecting to the database"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('retrieve_soap_records')

        results = []
        for result in cursor.stored_results():
            results = result.fetchall()
        
        return jsonify(results)

    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# Visit management route
@app.route('/visit_info', methods=['GET', 'POST'])
def visit_info():
    conn = get_db_connection()
    if not conn:
        return "Error connecting to the database", 500

    try:
        cursor = conn.cursor(dictionary=True)

        # Fetch all patients
        cursor.execute("SELECT patient_id, patient_name FROM patients")
        patients = cursor.fetchall()

        # Fetch all physicians
        cursor.execute("SELECT physician_id, physician_name FROM physicians")
        physicians = cursor.fetchall()

        if request.method == 'POST':
            patient_id = request.form.get('visitPatient')
            physician_id = request.form.get('visitPhysician')
            visit_type = request.form.get('visitType')
            admission_date = request.form.get('admissionDate')
            discharge_date = request.form.get('dischargeDate')
            visit_notes = request.form.get('visitNotes')

            cursor.callproc('create_visit', [
                patient_id,
                physician_id,
                visit_type,
                admission_date,
                discharge_date,
                visit_notes
            ])
            conn.commit()

            return render_template('visit_info.html', patients=patients, physicians=physicians, message="Visit information saved successfully")

        return render_template('visit_info.html', patients=patients, physicians=physicians)

    except Error as e:
        return f"Database error: {e}", 500
    finally:
        cursor.close()
        conn.close()

# Retrieve visits route
@app.route('/retrieve_visits', methods=['GET'])
def retrieve_visits():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Error connecting to the database"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('retrieve_visits')

        results = []
        for result in cursor.stored_results():
            results = result.fetchall()
        
        return jsonify(results)

    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# After visit summary route
@app.route('/visit_summary', methods=['GET', 'POST'])
def visit_summary():
    conn = get_db_connection()
    if not conn:
        return "Error connecting to the database", 500

    try:
        cursor = conn.cursor(dictionary=True)

        # Fetch all visit IDs
        cursor.execute("SELECT visit_id FROM visits")
        visits = cursor.fetchall()

        if request.method == 'POST':
            visit_id = request.form.get('summaryVisitID')
            notes_on_care = request.form.get('summaryNotes')
            patient_instructions = request.form.get('summaryInstructions')
            follow_up_details = request.form.get('summaryFollowUp')

            cursor.callproc('create_after_visit_summary', [
                visit_id,
                notes_on_care,
                patient_instructions,
                follow_up_details
            ])
            conn.commit()

            return render_template('visit_summary.html', visits=visits, message="After Visit Summary saved successfully.")

        return render_template('visit_summary.html', visits=visits)

    except Error as e:
        return f"Database error: {e}", 500
    finally:
        cursor.close()
        conn.close()

# Retrieve after visit summaries route
@app.route('/retrieve_after_visit_summaries', methods=['GET'])
def retrieve_after_visit_summaries():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Error connecting to the database"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('retrieve_after_visit_summaries')

        results = []
        for result in cursor.stored_results():
            results = result.fetchall()
        
        return jsonify(results)

    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# Physicians creation route
@app.route('/physicians', methods=['GET', 'POST'])
def physicians():
    conn = get_db_connection()
    if not conn:
        return "Error connecting to the database", 500

    try:
        cursor = conn.cursor()

        if request.method == 'POST':
            physician_name = request.form.get('physicianName')
            physician_specialty = request.form.get('physicianSpecialty')
            physician_contact = request.form.get('physicianContact')

            cursor.callproc('create_physician', [physician_name, physician_specialty, physician_contact])
            conn.commit()

            return render_template('physicians.html', message="Physician profile created successfully")

        return render_template('physicians.html')

    except Error as e:
        return f"Database error: {e}", 500
    finally:
        cursor.close()
        conn.close()

# Retrieve physicians route
@app.route('/retrieve_physicians', methods=['GET'])
def retrieve_physicians():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Error connecting to the database"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('retrieve_physicians')

        results = []
        for result in cursor.stored_results():
            results = result.fetchall()
        
        return jsonify(results)

    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    app.run(debug=True)
