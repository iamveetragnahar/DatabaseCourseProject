from flask import Flask, flash, request, jsonify, render_template
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

# Order Lab Tests
@app.route('/order-lab-tests', methods=['GET', 'POST'])
def order_lab_tests():
    return render_template('orderLabTest.html')

# View Test Results
@app.route('/view-results', methods=['GET', 'POST'])
def view_results():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        results = []
        selected_patient_id = None

        if request.method == 'POST':
            # Get the Patient ID from the form
            patient_id = request.form.get('patient_id')
            selected_patient_id = patient_id

            if not patient_id:
                return render_template(
                    'viewResults.html',
                    error="Please enter a valid Patient ID.",
                    results=None,
                    selected_patient_id=None
                )

            # Call the stored procedure
            cursor.callproc('GetLabResultsByPatientID', [patient_id])

            # Fetch results from the stored procedure
            for result in cursor.stored_results():
                results.extend(result.fetchall())

        conn.close()

        # Render the template with results
        return render_template(
            'viewResults.html',
            results=results,
            selected_patient_id=selected_patient_id
        )
    except Exception as e:
        print(f"Error fetching lab results: {e}")
        return render_template(
            'viewResults.html',
            error=f"An error occurred: {str(e)}",
            results=None,
            selected_patient_id=None
        ), 500
    finally:
        cursor.close()
        conn.close()



# After Visit Summary
@app.route('/after-visit-summary', methods=['GET', 'POST'])
def after_visit_summary():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'GET':
        # Fetch all patient IDs from the visits table
        cursor.execute("SELECT DISTINCT PatientID FROM visits")
        patients = cursor.fetchall()
        conn.close()

        return render_template('afterVisitSummary.html', patients=patients, visit_summaries=None, selected_patient_id=None)



    
@app.route('/enter-test-results', methods=['GET', 'POST'])
def enter_test_results():
    conn = get_db_connection()
    if conn is None:
        return "Database connection failed", 500

    cursor = conn.cursor(dictionary=True)

    if request.method == 'GET':
        try:
            # Fetch distinct order IDs
            cursor.execute("SELECT DISTINCT OrderID AS id FROM laborders")
            laborders = cursor.fetchall()

            conn.close()
            return render_template(
                'enterTestResults.html',
                laborders=laborders
            )
        except Exception as e:
            print(f"Error: {e}")
            conn.close()
            return "An error occurred", 500

@app.route('/manage/<string:section>', methods=['POST'])
def manage(section):
    action = request.form.get('action')  # 'add', 'edit', or 'delete'
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        if section == 'lab-order':
            if action == 'add':
                patient_id = request.form.get('patient_id')
                test_type = request.form.get('test_type')
                order_date = request.form.get('order_date')
                cursor.callproc('AddLabOrder', (patient_id, test_type, order_date))
            elif action == 'edit':
                order_id = request.form.get('order_id')
                test_type = request.form.get('test_type')
                order_date = request.form.get('order_date')
                cursor.callproc('EditLabOrder', (order_id, test_type, order_date))
            elif action == 'delete':
                order_id = request.form.get('order_id')
                cursor.callproc('DeleteLabOrder', (order_id,))
        
        elif section == 'test-result':
            if action == 'add':
                order_id = request.form.get('order_id')
                result_details = request.form.get('result_details')
                cursor.callproc('AddTestResult', (order_id, result_details))
            elif action == 'edit':
                result_id = request.form.get('result_id')
                result_details = request.form.get('result_details')
                cursor.callproc('EditTestResult', (result_id, result_details))
            elif action == 'delete':
                result_id = request.form.get('result_id')
                cursor.callproc('DeleteTestResult', (result_id,))
        
        elif section == 'visit-summary':
            if action == 'add':
                patient_id = request.form.get('patient_id')
                summary = request.form.get('summary')
                visit_date = request.form.get('visit_date')
                cursor.callproc('AddVisitSummary', (patient_id, summary, visit_date))
            elif action == 'edit':
                visit_id = request.form.get('visit_id')
                summary = request.form.get('summary')
                visit_date = request.form.get('visit_date')
                cursor.callproc('EditVisitSummary', (visit_id, summary, visit_date))
            elif action == 'delete':
                visit_id = request.form.get('visit_id')
                cursor.callproc('DeleteVisitSummary', (visit_id,))

        conn.commit()
        return jsonify({'status': 'success', 'message': f'{section.capitalize()} {action}ed successfully.'})
    except Exception as e:
        conn.rollback()
        return jsonify({'status': 'error', 'message': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/delete-lab-order', methods=['GET', 'POST'])
def delete_lab_order():
    conn = get_db_connection()
    cursor = conn.cursor()

    if request.method == 'GET':
        # Render the delete lab order form
        return render_template('deleteLabOrder.html')

    if request.method == 'POST':
        try:
            # Extract lab order ID from the form
            lab_order_id = request.form['order_id']

            # Execute the deletion
            cursor.execute("DELETE FROM laborders WHERE OrderID = %s", (lab_order_id,))
            conn.commit()

            return render_template('deleteLabOrder.html', message="Lab order deleted successfully.")
        except Exception as e:
            print(f"Error deleting lab order: {e}")
            return render_template('deleteLabOrder.html', error=f"An error occurred: {str(e)}")
        finally:
            cursor.close()
            conn.close()

if __name__ == '__main__':
    app.run(debug=True)
