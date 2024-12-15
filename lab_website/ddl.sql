-- Database Creation
CREATE DATABASE IF NOT EXISTS healthcaremanagement;
USE healthcaremanagement;

-- Table for storing patient details
CREATE TABLE IF NOT EXISTS patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS LabOrders ( 
    OrderID INT AUTO_INCREMENT PRIMARY KEY, 
    PatientID INT NOT NULL, 
    TestType VARCHAR(50) NOT NULL, 
    OrderDate DATE NOT NULL, 
    Notes TEXT, 
    FOREIGN KEY (PatientID) REFERENCES patients(patient_id) 
); 

CREATE TABLE IF NOT EXISTS LabResults ( 
    ResultID INT AUTO_INCREMENT PRIMARY KEY, 
    OrderID INT NOT NULL, 
    ResultDetails TEXT NOT NULL, 
    ResultDate DATE NOT NULL, 
    AttachmentPath VARCHAR(255), 
    FOREIGN KEY (OrderID) REFERENCES LabOrders(OrderID)
); 

CREATE TABLE IF NOT EXISTS TestTypes ( 
    TestTypeID INT AUTO_INCREMENT PRIMARY KEY, 
    TestTypeName VARCHAR(50) NOT NULL UNIQUE 
); 

CREATE TABLE IF NOT exists Visits ( 
    VisitID INT AUTO_INCREMENT PRIMARY KEY, 
    PatientID INT NOT NULL, 
    VisitDate DATE NOT NULL, 
    Summary TEXT, 
    FOREIGN KEY (PatientID) REFERENCES patients(patient_id) 
); 


-- Insert sample data into `patient`
INSERT INTO patients (patient_name, date_of_birth) VALUES
('John Doe', '1990-01-01'),
('Jane Smith', '1985-06-15'),
('Robert Johnson', '1975-09-30'),
('Emily Davis', '2000-03-20');


-- Insert sample data into `testtypes`
INSERT INTO testtypes (TestTypeName) VALUES
('Blood Test'),
('X-Ray'),
('MRI Scan'),
('COVID-19 Test');


-- Insert sample data into `laborders`
INSERT INTO laborders (PatientID, TestType, OrderDate) VALUES
(1, 'MRI Scan', '2024-12-01'),
(2, 'COVID-19 Test', '2024-11-30'),
(3, 'MRI Scan', '2024-11-29'),
(4, 'X-Ray', '2024-11-28');


INSERT INTO visits (PatientID, VisitDate, Summary) VALUES
(1, '2024-12-01', 'Routine check-up; patient reported mild fatigue.'),
(2, '2024-11-30', 'Follow-up visit for high blood pressure; medication adjusted.'),
(3, '2024-11-29', 'Initial consultation for knee pain; MRI ordered.'),
(4, '2024-11-28', 'Annual physical exam; no issues reported.'),
(1, '2024-12-03', 'Flu-like symptoms; prescribed Tamiflu.'),
(2, '2024-12-02', 'Chest pain; ECG conducted and results normal.'),
(3, '2024-12-01', 'Physical therapy consultation; exercises recommended.'),
(4, '2024-11-27', 'Blood work for cholesterol levels; lifestyle changes recommended.');

DELIMITER $$

-- Lab Orders
CREATE PROCEDURE AddLabOrder(IN p_PatientID INT, IN p_TestType VARCHAR(255), IN p_OrderDate DATE)
BEGIN
    INSERT INTO laborders (PatientID, TestType, OrderDate) VALUES (p_PatientID, p_TestType, p_OrderDate);
END$$

CREATE PROCEDURE EditLabOrder(IN p_OrderID INT, IN p_TestType VARCHAR(255), IN p_OrderDate DATE)
BEGIN
    UPDATE laborders SET TestType = p_TestType, OrderDate = p_OrderDate WHERE OrderID = p_OrderID;
END$$

CREATE PROCEDURE DeleteLabOrder(IN p_OrderID INT)
BEGIN
    DELETE FROM laborders WHERE OrderID = p_OrderID;
END$$

-- Test Results
CREATE PROCEDURE AddTestResult(IN p_OrderID INT, IN p_ResultDetails TEXT)
BEGIN
    INSERT INTO labresults (OrderID, ResultDetails, ResultDate) VALUES (p_OrderID, p_ResultDetails, NOW());
END$$

CREATE PROCEDURE EditTestResult(IN p_ResultID INT, IN p_ResultDetails TEXT)
BEGIN
    UPDATE labresults SET ResultDetails = p_ResultDetails WHERE ResultID = p_ResultID;
END$$

CREATE PROCEDURE DeleteTestResult(IN p_ResultID INT)
BEGIN
    DELETE FROM labresults WHERE ResultID = p_ResultID;
END$$

-- Visit Summaries
CREATE PROCEDURE AddVisitSummary(IN p_PatientID INT, IN p_Summary TEXT, IN p_VisitDate DATE)
BEGIN
    INSERT INTO visits (PatientID, Summary, VisitDate) VALUES (p_PatientID, p_Summary, p_VisitDate);
END$$

CREATE PROCEDURE EditVisitSummary(IN p_VisitID INT, IN p_Summary TEXT, IN p_VisitDate DATE)
BEGIN
    UPDATE visits SET Summary = p_Summary, VisitDate = p_VisitDate WHERE VisitID = p_VisitID;
END$$

CREATE PROCEDURE DeleteVisitSummary(IN p_VisitID INT)
BEGIN
    DELETE FROM visits WHERE VisitID = p_VisitID;
END$$


CREATE PROCEDURE GetLabResultsByPatientID(
    IN p_PatientID INT
)
BEGIN
    SELECT 
        lr.ResultID, 
        lo.TestType AS TestTypeName, 
        lr.ResultDetails, 
        lr.ResultDate
    FROM 
        labresults lr
    INNER JOIN 
        laborders lo ON lr.OrderID = lo.OrderID
    WHERE 
        lo.PatientID = p_PatientID;
END$$

DELIMITER ;

