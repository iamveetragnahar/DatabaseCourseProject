from flask import Flask, request, jsonify, render_template
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

# MySQL database configuration
db_config = {
    'host': 'localhost',
    'user': 'root',  # Replace with your username
    'password': 'cubswin',  # Replace with your password
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

# Route to prescribe medicine
# Route to prescribe medicine
@app.route('/prescribe-medicine', methods=['GET', 'POST'])
def prescribe_medicine():
    conn = get_db_connection()
    cursor = conn.cursor()

    if request.method == 'GET':
        # Render the form for GET requests
        return render_template('prescribeMedicine.html')

    if request.method == 'POST':
        try:
            # Extract data from the request
            data = request.form
            patient_id = data['patientId']
            medicine_name = data['medicineName']
            dosage = data['dosage']
            frequency = data['frequency']
            duration = data['duration']
            notes = data.get('notes', '')

            # Call the stored procedure
            cursor.callproc('AddPrescription', [patient_id, medicine_name, dosage, frequency, duration, notes])
            conn.commit()
            return jsonify({'message': 'Medicine prescribed successfully'}), 200
        except Exception as e:
            print(f"Error prescribing medicine: {e}")
            return jsonify({'error': str(e)}), 500
        finally:
            cursor.close()
            conn.close()

# Route to update prescription
@app.route('/update-prescription', methods=['POST'])
def update_prescription():
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Extract data from the request
        data = request.form
        prescription_id = data['prescriptionId']
        medicine_name = data['medicineName']
        dosage = data['dosage']
        frequency = data['frequency']
        duration = data['duration']
        status = data['status']

        # Call the stored procedure
        cursor.callproc('UpdatePrescription', [prescription_id, medicine_name, dosage, frequency, duration, status])
        conn.commit()
        return jsonify({'message': 'Prescription updated successfully'}), 200
    except Exception as e:
        print(f"Error updating prescription: {e}")
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# Additions to the `manage_prescriptions` route
@app.route('/manage-prescriptions', methods=['GET', 'POST'])
def manage_prescriptions():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'GET':
        return render_template('managePrescriptions.html')

    if request.method == 'POST':
        try:
            action = request.form.get('action')  # Determine the action
            prescription_id = request.form['prescriptionId']

            if action == 'delete':
                cursor.execute("DELETE FROM Prescriptions WHERE prescription_id = %s", (prescription_id,))
                conn.commit()
                return jsonify({'message': 'Prescription deleted successfully'}), 200

            elif action == 'update':
                medicine_name = request.form['medicineName']
                dosage = request.form['dosage']
                frequency = request.form['frequency']
                duration = request.form['duration']
                status = request.form['status']
                cursor.callproc('UpdatePrescription', [prescription_id, medicine_name, dosage, frequency, duration, status])
                conn.commit()
                return jsonify({'message': 'Prescription updated successfully'}), 200

        except Exception as e:
            return jsonify({'error': str(e)}), 500
        finally:
            cursor.close()
            conn.close()



# Route to view medication history
@app.route('/view-medication-history', methods=['GET', 'POST'])
def view_medication_history():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'GET':
        # Render the form for GET requests
        return render_template('viewMedHistory.html')

    if request.method == 'POST':
        try:
            # Extract filters from the request
            patient_id = request.form.get('patientId')
            date_from = request.form.get('dateFrom')
            date_to = request.form.get('dateTo')
            medication_name = request.form.get('medicationName', 'all')

            # Call the stored procedure
            cursor.callproc('GetMedicationHistory', [patient_id, date_from, date_to, medication_name])

            # Fetch results
            records = []
            for result in cursor.stored_results():
                records = result.fetchall()

            return render_template('medicationHistoryResults.html', records=records)
        except Exception as e:
            print(f"Error fetching medication history: {e}")
            return jsonify({'error': str(e)}), 500
        finally:
            cursor.close()
            conn.close()

# Route to interface with hospitals
# Route to render the Interface with Hospitals form
@app.route('/interface-with-hospital', methods=['GET', 'POST'])
def interface_with_hospital():
    conn = get_db_connection()
    cursor = conn.cursor()

    if request.method == 'GET':
        # Render the form for GET requests
        return render_template('interfaceWithHospitals.html')

    if request.method == 'POST':
        try:
            # Extract data from the request
            data = request.form
            hospital_id = data['hospitalId']
            medication_order_id = data['medicationOrderId']
            status = data['status']
            notes = data.get('notes', '')

            # Call the stored procedure
            cursor.callproc('AddHospitalInteraction', [hospital_id, medication_order_id, status, notes])
            conn.commit()
            return jsonify({'message': 'Hospital interaction recorded successfully'}), 200
        except Exception as e:
            print(f"Error interfacing with hospital: {e}")
            return jsonify({'error': str(e)}), 500
        finally:
            cursor.close()
            conn.close()

@app.route('/show-medication-history', methods=['GET', 'POST'])
def show_medication_history():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        if request.method == 'GET':
            # Extract query parameters for GET requests
            patient_id = request.args.get('patientId')
            date_from = request.args.get('dateFrom')
            date_to = request.args.get('dateTo')
            medication_name = request.args.get('medicationName', 'all')

            # Debug: Log the received parameters
            print(f"GET request - Patient ID: {patient_id}, Date From: {date_from}, Date To: {date_to}, Medication Name: {medication_name}")

            if not patient_id:
                return render_template(
                    'viewMedHistory.html',
                    error="Patient ID is required.",
                    records=None
                )

            # Call the stored procedure
            cursor.callproc('GetMedicationHistory', [patient_id, date_from, date_to, medication_name])

            # Fetch results
            records = []
            for result in cursor.stored_results():
                records = result.fetchall()

            # Debug: Log the fetched records
            print(f"Fetched records: {records}")

            return render_template('medicationHistoryResults.html', records=records)

        elif request.method == 'POST':
            # Extract form data for POST requests
            patient_id = request.form.get('patientId')
            date_from = request.form.get('dateFrom')
            date_to = request.form.get('dateTo')
            medication_name = request.form.get('medicationName', 'all')

            # Debug: Log the received parameters
            print(f"POST request - Patient ID: {patient_id}, Date From: {date_from}, Date To: {date_to}, Medication Name: {medication_name}")

            if not patient_id:
                return render_template(
                    'viewMedHistory.html',
                    error="Patient ID is required.",
                    records=None
                )

            # Call the stored procedure
            cursor.callproc('GetMedicationHistory', [patient_id, date_from, date_to, medication_name])

            # Fetch results
            records = []
            for result in cursor.stored_results():
                records = result.fetchall()

            # Debug: Log the fetched records
            print(f"Fetched records: {records}")

            return render_template('medicationHistoryResults.html', records=records)
    except Exception as e:
        print(f"Error fetching medication history: {e}")
        return render_template(
            'viewMedHistory.html',
            error=f"An error occurred: {str(e)}",
            records=None
        )
    finally:
        cursor.close()
        conn.close()



if __name__ == '__main__':
    app.run(debug=True)
