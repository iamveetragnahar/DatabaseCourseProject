from flask import Flask, request, render_template
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

# MySQL database configuration
db_config = {
    'host': 'localhost',
    'user': 'root',  # Replace with your username
    'password': 'Amithesh21893',  # Replace with your password
    'database': 'Insurance'  # Ensure this matches your database name
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

# Route to retrieve patients
@app.route('/patients', methods=['GET'])
def retrieve_patients():
    conn = get_db_connection()
    
    if not conn:
        return render_template('error.html', error_message="Error connecting to the database"), 500

    try:
        cursor = conn.cursor(dictionary=True)
        
        # Call stored procedure to retrieve patients
        cursor.callproc('RetrievePatients')
        
        # Fetch all results
        patients = []
        for result in cursor.stored_results():
            patients = result.fetchall()
        
        return render_template('patients.html', patients=patients)

    except Error as e:
        return render_template('error.html', error_message=f"Database error: {e}"), 500

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# Route for displaying the Insurance page and handling form submissions
@app.route('/insurance', methods=['GET', 'POST'])
def insurance():
    conn = get_db_connection()

    if not conn:
        return render_template('Information.html', error_message="Error connecting to the database"), 500

    try:
        cursor = conn.cursor(dictionary=True)
        
        # Fetch the list of patients to display in the dropdown
        cursor.execute("SELECT PatientID, CONCAT(FirstName, ' ', LastName) AS FullName FROM Patients")
        patients = cursor.fetchall()

        # Call stored procedure to retrieve insurance information
        cursor.callproc('RetrieveInsurance')
        
        # Fetch insurance data
        insurance_data = []
        for result in cursor.stored_results():
            insurance_data = result.fetchall()

        # Handle POST request (form submission)
        if request.method == 'POST':
            # Get data from the form
            patient_id = request.form.get('patient_id')
            insurance_provider = request.form.get('insurance_provider')
            policy_number = request.form.get('policy_number')
            copay = request.form.get('copay')
            deductible = request.form.get('deductible')
            covered_services = request.form.get('covered_services')

            # Validate patient_id
            cursor.execute("SELECT PatientID FROM Patients WHERE PatientID = %s", (patient_id,))
            patient_exists = cursor.fetchone()
            if not patient_exists:
                return render_template('Information.html', error_message="Patient ID not found in the database.")

            # Call stored procedure to create insurance information
            cursor.callproc('CreateInsurance', [patient_id, insurance_provider, policy_number, copay, deductible, covered_services])
            conn.commit()

            # Return a success message after inserting the data
            return render_template('Information.html', insurance_data=insurance_data, message="Insurance information saved successfully.", patients=patients)

        return render_template('Information.html', insurance_data=insurance_data, patients=patients)

    except Error as e:
        return render_template('Information.html', error_message=f"Database error: {e}"), 500

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
        
# Route for Copay/Deductible Management page
@app.route('/copay', methods=['GET', 'POST'])
def copay():
    connection = get_db_connection()
    
    if not connection:
        return render_template('copay.html', error_message="Error connecting to the database"), 500

    try:
        cursor = connection.cursor(dictionary=True)

        # Call stored procedure to retrieve copay/deductible information
        cursor.callproc('RetrieveCopayDeductible')
        copay_data = []
        for result in cursor.stored_results():
            copay_data = result.fetchall()
        
        # Fetch patients for dropdown
        cursor.execute('SELECT * FROM Patients')
        patients = cursor.fetchall()
        
        # Fetch insurance information for dropdown
        cursor.execute('SELECT * FROM InsuranceInformation')
        insurance_info = cursor.fetchall()

        # Handle POST request to insert/update copay/deductible information
        if request.method == 'POST':
            patient_id = request.form['patient_id']
            copay_amount = request.form['copay_amount']
            deductible_amount = request.form['deductible_amount']
            remaining_deductible = request.form['remaining_deductible']
            insurance_id = request.form['insurance_id']

            # Call stored procedure to create/update copay deductible
            cursor.callproc('CreateCopayDeductible', [insurance_id, patient_id, copay_amount, deductible_amount, remaining_deductible])
            
            connection.commit()

            return render_template('copay.html', 
                                   copay_data=copay_data, 
                                   patients=patients, 
                                   insurance_info=insurance_info, 
                                   message="Copay/Deductible information saved successfully.")
    
        return render_template('copay.html', 
                               copay_data=copay_data, 
                               patients=patients, 
                               insurance_info=insurance_info)

    except Error as e:
        return render_template('copay.html', error_message=f"Database error: {e}"), 500

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

# Route for Bill Remaining page
@app.route('/bill_remaining', methods=['GET'])
def bill_remaining():
    # Establish DB connection
    connection = get_db_connection()
    
    if not connection:
        return render_template('bill_remaining.html', error_message="Error connecting to the database"), 500

    try:
        cursor = connection.cursor(dictionary=True)

        # Fetch all patients for the dropdown
        cursor.execute('''SELECT PatientID, CONCAT(FirstName, ' ', LastName) AS FullName FROM Patients''')
        patients = cursor.fetchall()

        # Call stored procedure to retrieve bills
        cursor.callproc('RetrieveBills')
        bill_data = []
        for result in cursor.stored_results():
            bill_data = result.fetchall()

        # Fetch specific patient and their bill info if patient_id is passed
        patient_id = request.args.get('patient_id')
        if patient_id:
            # Filter bills for the selected patient
            bill_data = [bill for bill in bill_data if bill['PatientID'] == int(patient_id)]

        return render_template('bill_remaining.html', 
                               patients=patients, 
                               bill_data=bill_data, 
                               selected_patient_id=patient_id)

    except Error as e:
        return render_template('bill_remaining.html', error_message=f"Database error: {e}"), 500

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

# Route for payment process page
@app.route('/payment', methods=['GET', 'POST'])
def payment():
    connection = get_db_connection()
    
    if not connection:
        return render_template('payment.html', error_message="Error connecting to the database"), 500

    try:
        cursor = connection.cursor(dictionary=True)

        # Fetch all patients
        cursor.execute('''SELECT PatientID, CONCAT(FirstName, ' ', LastName) AS FullName FROM Patients''')
        patients = cursor.fetchall()

        # Call stored procedure to retrieve payments
        cursor.callproc('RetrievePayments')
        payments = []
        for result in cursor.stored_results():
            payments = result.fetchall()

        # Fetch payments for the selected patient
        patient_id = request.args.get('patient_id')  # Retrieve patient_id from query parameters
        if patient_id:
            payments = [payment for payment in payments if payment['PatientID'] == int(patient_id)]

        if request.method == 'GET':
            return render_template('payment.html', 
                                   patients=patients, 
                                   payments=payments, 
                                   selected_patient_id=patient_id)

        elif request.method == 'POST':
            # Process new payment
            patient_id = request.form['patientId']
            bill_id = request.form['billId']
            payment_amount = float(request.form['paymentAmount'])
            payment_method = request.form['paymentMethod']
            payment_date = request.form['paymentDate']

            # Call stored procedure to create payment
            cursor.callproc('CreatePayment', [patient_id, bill_id, payment_amount, payment_method, payment_date, 'Completed'])

            connection.commit()

            # Redirect to payment page with selected patient
            return render_template('payment.html', 
                                   patients=patients, 
                                   payments=payments, 
                                   selected_patient_id=patient_id, 
                                   message="Payment processed successfully.")

    except Error as e:
        return render_template('payment.html', error_message=f"Database error: {e}"), 500

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

if __name__ == '__main__':
    app.run(debug=True)