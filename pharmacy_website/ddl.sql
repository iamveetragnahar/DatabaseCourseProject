-- Database Creation
CREATE DATABASE IF NOT EXISTS healthcaremanagement;
USE healthcaremanagement;

-- Table for storing hospital information
CREATE TABLE hospitals (
    hospital_id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_name VARCHAR(255) NOT NULL
);

-- Table for interactions with hospitals
CREATE TABLE hospital_interactions (
    interaction_id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_id INT NOT NULL,
    medication_order_id INT NOT NULL,
    status ENUM('pending', 'completed') NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
);

-- Table for managing prescriptions
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_name VARCHAR(255) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency ENUM('once', 'twice') NOT NULL,
    duration INT NOT NULL,
    status ENUM('active', 'inactive') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing prescribed medicines
CREATE TABLE prescribed_medicine (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    medicine_name VARCHAR(255) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency ENUM('once', 'twice') NOT NULL,
    duration INT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for medication history
CREATE TABLE medication_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    medicine_name VARCHAR(255) NOT NULL,
    date_prescribed DATE NOT NULL,
    duration INT NOT NULL,
    notes TEXT
);

-- Table for storing patient details
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing available medications
CREATE TABLE medications (
    medicine_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_name VARCHAR(255) NOT NULL,
    dosage_form VARCHAR(50) NOT NULL,
    strength VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample Data Insertion

-- Hospitals
INSERT INTO hospitals (hospital_name) VALUES ('City Hospital'), ('St. Luke Medical Center');

-- Medications
INSERT INTO medications (medicine_name, dosage_form, strength) VALUES
('Paracetamol', 'Tablet', '500mg'),
('Zytrec', 'Tablet', '50mg'),
('Ibuprofen', 'Tablet', '200mg');

-- Patients
INSERT INTO patients (patient_name, date_of_birth) VALUES
('John Doe', '1980-01-01'),
('Jerry Rice', '1967-08-23'),
('Jane Smith', '1990-06-15');

-- Prescriptions
INSERT INTO prescriptions (medicine_name, dosage, frequency, duration, status) VALUES
('Paracetamol', '500mg', 'twice', 7, 'active'),
('Ibuprofen', '200mg', 'once', 5, 'inactive');

-- Prescribed Medicine
INSERT INTO prescribed_medicine (patient_id, medicine_name, dosage, frequency, duration, notes) VALUES
(1, 'Paracetamol', '500mg', 'twice', 7, 'For headache'),
(2, 'Ibuprofen', '200mg', 'once', 5, 'For fever');

-- Medication History
INSERT INTO medication_history (patient_id, medicine_name, date_prescribed, duration, notes) VALUES
(1, 'Paracetamol', '2024-11-28', 7, 'Completed treatment for headache'),
(2, 'Ibuprofen', '2024-11-25', 5, 'Completed treatment for fever');

DELIMITER $$

CREATE PROCEDURE AddPrescription(
    IN p_PatientID INT,
    IN p_MedicineName VARCHAR(255),
    IN p_Dosage VARCHAR(255),
    IN p_Frequency VARCHAR(255),
    IN p_Duration INT,
    IN p_Notes TEXT
)
BEGIN
    INSERT INTO prescribed_medicine (patient_id, medicine_name, dosage, frequency, duration, notes)
    VALUES (p_PatientID, p_MedicineName, p_Dosage, p_Frequency, p_Duration, p_Notes);

    INSERT INTO prescriptions (medicine_name, dosage, frequency, duration, status)
    VALUES (p_MedicineName, p_Dosage, p_Frequency, p_Duration, 'active');

    INSERT INTO medication_history (patient_id, medicine_name, date_prescribed, duration, notes)
    VALUES (p_PatientID, p_MedicineName, CURDATE(), p_Duration, p_Notes);
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE UpdatePrescription(
    IN p_PrescriptionID INT,
    IN p_MedicineName VARCHAR(255),
    IN p_Dosage VARCHAR(255),
    IN p_Frequency VARCHAR(255),
    IN p_Duration INT,
    IN p_Status VARCHAR(255)
)
BEGIN
    UPDATE prescribed_medicine
    SET medicine_name = p_MedicineName, dosage = p_Dosage, frequency = p_Frequency, duration = p_Duration
    WHERE prescription_id = p_PrescriptionID;

    UPDATE prescriptions
    SET medicine_name = p_MedicineName, dosage = p_Dosage, frequency = p_Frequency, duration = p_Duration, status = p_Status
    WHERE prescription_id = p_PrescriptionID;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE GetMedicationHistory(
    IN p_PatientID INT,
    IN p_DateFrom DATE,
    IN p_DateTo DATE,
    IN p_MedicineName VARCHAR(255)
)
BEGIN
    SELECT * 
    FROM medication_history
    WHERE patient_id = p_PatientID
      AND (p_DateFrom IS NULL OR date_prescribed >= p_DateFrom)
      AND (p_DateTo IS NULL OR date_prescribed <= p_DateTo)
      AND (p_MedicineName = 'all' OR medicine_name = p_MedicineName);
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE AddHospitalInteraction(
    IN p_HospitalID INT,
    IN p_MedicationOrderID INT,
    IN p_Status VARCHAR(255),
    IN p_Notes TEXT
)
BEGIN
    INSERT INTO hospital_interactions (hospital_id, medication_order_id, status, notes)
    VALUES (p_HospitalID, p_MedicationOrderID, p_Status, p_Notes);
END$$

DELIMITER ;
