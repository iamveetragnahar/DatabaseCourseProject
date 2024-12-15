-- Create a new database
CREATE DATABASE IF NOT EXISTS healthcaremanagement;
USE healthcaremanagement;


-- Table for storing patient details (Patient Profile)
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    contact_info VARCHAR(150),
    address VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stored Procedure for 'patients'
DELIMITER //
CREATE PROCEDURE create_patient (
    IN p_name VARCHAR(255), 
    IN p_dob DATE, 
    IN p_contact VARCHAR(150), 
    IN p_address VARCHAR(255)
)
BEGIN
    INSERT INTO patients (patient_name, date_of_birth, contact_info, address)
    VALUES (p_name, p_dob, p_contact, p_address);
END //

CREATE PROCEDURE edit_patient (
    IN p_id INT,
    IN p_name VARCHAR(255),
    IN p_dob DATE,
    IN p_contact VARCHAR(150),
    IN p_address VARCHAR(255)
)
BEGIN
    UPDATE patients
    SET patient_name = p_name, date_of_birth = p_dob, contact_info = p_contact, address = p_address
    WHERE patient_id = p_id;
END //

CREATE PROCEDURE delete_patient (IN p_id INT)
BEGIN
    DELETE FROM patients WHERE patient_id = p_id;
END //

CREATE PROCEDURE retrieve_patients ()
BEGIN
    SELECT * FROM patients;
END //
DELIMITER ;


-- Table for storing physician details
CREATE TABLE physicians (
    physician_id INT AUTO_INCREMENT PRIMARY KEY,
    physician_name VARCHAR(255) NOT NULL,
    specialty VARCHAR(100),
    contact_info VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stored Procedure for 'physicians'
DELIMITER //
CREATE PROCEDURE create_physician (
    IN p_name VARCHAR(255), 
    IN p_specialty VARCHAR(100), 
    IN p_contact VARCHAR(150)
)
BEGIN
    INSERT INTO physicians (physician_name, specialty, contact_info)
    VALUES (p_name, p_specialty, p_contact);
END //

CREATE PROCEDURE edit_physician (
    IN p_id INT, 
    IN p_name VARCHAR(255), 
    IN p_specialty VARCHAR(100), 
    IN p_contact VARCHAR(150)
)
BEGIN
    UPDATE physicians
    SET physician_name = p_name, specialty = p_specialty, contact_info = p_contact
    WHERE physician_id = p_id;
END //

CREATE PROCEDURE delete_physician (IN p_id INT)
BEGIN
    DELETE FROM physicians WHERE physician_id = p_id;
END //

CREATE PROCEDURE retrieve_physicians ()
BEGIN
    SELECT * FROM physicians;
END //
DELIMITER ;

-- Table for storing appointments
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    physician_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    notes TEXT,
    status ENUM('Scheduled', 'Rescheduled', 'Cancelled', 'Completed') DEFAULT 'Scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (physician_id) REFERENCES physicians(physician_id)
);

-- Stored Procedure for 'appointments'
DELIMITER //
CREATE PROCEDURE create_appointment (
    IN p_patient_id INT,
    IN p_physician_id INT,
    IN p_datetime DATETIME,
    IN p_notes TEXT,
    IN p_status ENUM('Scheduled', 'Rescheduled', 'Cancelled', 'Completed')
)
BEGIN
    INSERT INTO appointments (patient_id, physician_id, appointment_datetime, notes, status)
    VALUES (p_patient_id, p_physician_id, p_datetime, p_notes, p_status);
END //

CREATE PROCEDURE edit_appointment (
    IN p_id INT, 
    IN p_patient_id INT, 
    IN p_physician_id INT, 
    IN p_datetime DATETIME, 
    IN p_notes TEXT, 
    IN p_status ENUM('Scheduled', 'Rescheduled', 'Cancelled', 'Completed')
)
BEGIN
    UPDATE appointments
    SET patient_id = p_patient_id, physician_id = p_physician_id, appointment_datetime = p_datetime, notes = p_notes, status = p_status
    WHERE appointment_id = p_id;
END //

CREATE PROCEDURE delete_appointment (IN p_id INT)
BEGIN
    DELETE FROM appointments WHERE appointment_id = p_id;
END //

CREATE PROCEDURE retrieve_appointments ()
BEGIN
    SELECT * FROM appointments;
END //
DELIMITER ; 


-- Table for managing SOAP Records
CREATE TABLE soap_records (
    soap_record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    physician_id INT NOT NULL,
    visit_datetime DATETIME NOT NULL,
    subjective_observations TEXT,
    objective_data JSON,
    diagnosis TEXT,
    treatment_plan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (physician_id) REFERENCES physicians(physician_id)
);


-- Stored Procedure for 'soap_records'
DELIMITER //
CREATE PROCEDURE create_soap_record (
    IN p_patient_id INT,
    IN p_physician_id INT,
    IN p_visit_datetime DATETIME,
    IN p_subjective TEXT,
    IN p_objective JSON,
    IN p_diagnosis TEXT,
    IN p_treatment TEXT
)
BEGIN
    INSERT INTO soap_records (patient_id, physician_id, visit_datetime, subjective_observations, objective_data, diagnosis, treatment_plan)
    VALUES (p_patient_id, p_physician_id, p_visit_datetime, p_subjective, p_objective, p_diagnosis, p_treatment);
END //

CREATE PROCEDURE edit_soap_record (
    IN p_id INT, 
    IN p_patient_id INT, 
    IN p_physician_id INT, 
    IN p_visit_datetime DATETIME, 
    IN p_subjective TEXT, 
    IN p_objective JSON, 
    IN p_diagnosis TEXT, 
    IN p_treatment TEXT
)
BEGIN
    UPDATE soap_records
    SET patient_id = p_patient_id, physician_id = p_physician_id, visit_datetime = p_visit_datetime, 
        subjective_observations = p_subjective, objective_data = p_objective, 
        diagnosis = p_diagnosis, treatment_plan = p_treatment
    WHERE soap_record_id = p_id;
END //

CREATE PROCEDURE delete_soap_record (IN p_id INT)
BEGIN
    DELETE FROM soap_records WHERE soap_record_id = p_id;
END //

CREATE PROCEDURE retrieve_soap_records ()
BEGIN
    SELECT * FROM soap_records;
END //
DELIMITER ;


-- Table for managing visits (Visit Management)
CREATE TABLE visits (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    physician_id INT NOT NULL,
    visit_type ENUM('Office', 'ER', 'Inpatient') NOT NULL,
    admission_date DATE,
    discharge_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (physician_id) REFERENCES physicians(physician_id)
);

-- Stored Procedure for 'visits'
DELIMITER //
CREATE PROCEDURE create_visit (
    IN p_patient_id INT,
    IN p_physician_id INT,
    IN p_visit_type ENUM('Office', 'ER', 'Inpatient'),
    IN p_admission DATE,
    IN p_discharge DATE,
    IN p_notes TEXT
)
BEGIN
    INSERT INTO visits (patient_id, physician_id, visit_type, admission_date, discharge_date, notes)
    VALUES (p_patient_id, p_physician_id, p_visit_type, p_admission, p_discharge, p_notes);
END //

CREATE PROCEDURE edit_visit (
    IN p_id INT, 
    IN p_patient_id INT, 
    IN p_physician_id INT, 
    IN p_visit_type ENUM('Office', 'ER', 'Inpatient'), 
    IN p_admission DATE, 
    IN p_discharge DATE, 
    IN p_notes TEXT
)
BEGIN
    UPDATE visits
    SET patient_id = p_patient_id, physician_id = p_physician_id, visit_type = p_visit_type, 
        admission_date = p_admission, discharge_date = p_discharge, notes = p_notes
    WHERE visit_id = p_id;
END //

CREATE PROCEDURE delete_visit (IN p_id INT)
BEGIN
    DELETE FROM visits WHERE visit_id = p_id;
END //

CREATE PROCEDURE retrieve_visits ()
BEGIN
    SELECT * FROM visits;
END //
DELIMITER ;


-- Table for After Visit Summary
CREATE TABLE after_visit_summary (
    summary_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT NOT NULL,
    notes_on_care TEXT,
    patient_instructions TEXT,
    follow_up_details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);

-- Stored Procedure for 'after_visit_summary'
DELIMITER //
CREATE PROCEDURE create_after_visit_summary (
    IN p_visit_id INT,
    IN p_notes_care TEXT,
    IN p_instructions TEXT,
    IN p_follow_up TEXT
)
BEGIN
    INSERT INTO after_visit_summary (visit_id, notes_on_care, patient_instructions, follow_up_details)
    VALUES (p_visit_id, p_notes_care, p_instructions, p_follow_up);
END //

CREATE PROCEDURE edit_after_visit_summary (
    IN p_id INT, 
    IN p_visit_id INT, 
    IN p_notes_care TEXT, 
    IN p_instructions TEXT, 
    IN p_follow_up TEXT
)
BEGIN
    UPDATE after_visit_summary
    SET visit_id = p_visit_id, notes_on_care = p_notes_care, patient_instructions = p_instructions, follow_up_details = p_follow_up
    WHERE summary_id = p_id;
END //

CREATE PROCEDURE delete_after_visit_summary (IN p_id INT)
BEGIN
    DELETE FROM after_visit_summary WHERE summary_id = p_id;
END //

CREATE PROCEDURE retrieve_after_visit_summaries ()
BEGIN
    SELECT * FROM after_visit_summary;
END //
DELIMITER ;
