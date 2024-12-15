-- Create a new database
CREATE DATABASE IF NOT EXISTS Insurance;
USE Insurance;

-- Create a table for patients information
CREATE TABLE Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,         -- Unique Patient ID
    FirstName VARCHAR(100) NOT NULL,                   -- Patient's first name
    LastName VARCHAR(100) NOT NULL,                    -- Patient's last name
    DateOfBirth DATE NOT NULL,                         -- Patient's date of birth
    Address VARCHAR(255),                              -- Patient's address
    PhoneNumber VARCHAR(20),                           -- Patient's phone number
    Email VARCHAR(100)                                 -- Patient's email address
);

-- Create a table for storing Insurance Information
CREATE TABLE InsuranceInformation (
    InsuranceID INT AUTO_INCREMENT PRIMARY KEY,       -- Unique ID for each insurance entry
    PatientID INT NOT NULL,                           -- Reference to Patient (Foreign Key)
    InsuranceProvider VARCHAR(255) NOT NULL,          -- Insurance provider name
    PolicyNumber VARCHAR(255) NOT NULL,               -- Insurance policy number
    Copay DECIMAL(10, 2),                             -- Copay amount
    Deductible DECIMAL(10, 2),                        -- Deductible amount
    CoveredServices TEXT,                             -- List of covered services
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp when updated
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) -- References the Patients table
);

-- Create a table for storing Copay/Deductible information
CREATE TABLE CopayDeductible (
    CopayDeductibleID INT AUTO_INCREMENT PRIMARY KEY,  -- Unique ID for each entry
    InsuranceID INT NOT NULL,                          -- Foreign Key to InsuranceInformation
    PatientID INT NOT NULL,                            -- Foreign Key to Patients table
    CopayAmount DECIMAL(10, 2),                        -- Copay amount for the patient
    DeductibleAmount DECIMAL(10, 2),                   -- Deductible amount for the patient
    RemainingDeductible DECIMAL(10, 2),                -- Remaining deductible for the patient
    FOREIGN KEY (InsuranceID) REFERENCES InsuranceInformation(InsuranceID), -- Links to Insurance Information
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) -- Links to Patients table
);

-- Create a table for storing Bill information (Bill Remaining to Patient)
CREATE TABLE Bills (
    BillID INT AUTO_INCREMENT PRIMARY KEY,            -- Unique Bill ID
    PatientID INT NOT NULL,                            -- Foreign Key to Patients table
    TotalAmount DECIMAL(10, 2) NOT NULL,               -- Total amount of the bill
    InsurancePaid DECIMAL(10, 2) DEFAULT 0.00,         -- Amount paid by insurance
    AmountOwed DECIMAL(10, 2),                         -- Remaining balance owed by patient (regular column)
    BillDate DATE NOT NULL,                            -- Date of the bill
    BillStatus VARCHAR(50) DEFAULT 'Pending',          -- Bill status: Pending, Paid, Partial
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) -- Links to Patients table
);

-- Create a table for storing Payments
CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,          -- Unique Payment ID
    PatientID INT NOT NULL,                            -- Foreign Key to Patients table
    BillID INT NOT NULL,                               -- Foreign Key to Bills table
    PaymentAmount DECIMAL(10, 2) NOT NULL,             -- Amount paid by the patient
    PaymentMethod VARCHAR(50),                         -- Payment method (e.g., Credit Card, Cash, Insurance)
    PaymentDate DATE NOT NULL,                         -- Date of the payment
    PaymentStatus VARCHAR(50) DEFAULT 'Pending',       -- Status of the payment: Pending, Completed, Failed
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID), -- Links to Patients table
    FOREIGN KEY (BillID) REFERENCES Bills(BillID)      -- Links to Bills table
);

-- Stored Procedures

-- Patients Table Procedures
DELIMITER //
CREATE PROCEDURE CreatePatient (IN fName VARCHAR(100), IN lName VARCHAR(100), IN dob DATE, IN addr VARCHAR(255), IN phone VARCHAR(20), IN email VARCHAR(100))
BEGIN
    INSERT INTO Patients (FirstName, LastName, DateOfBirth, Address, PhoneNumber, Email)
    VALUES (fName, lName, dob, addr, phone, email);
END //

CREATE PROCEDURE UpdatePatient (IN pID INT, IN fName VARCHAR(100), IN lName VARCHAR(100), IN addr VARCHAR(255), IN phone VARCHAR(20), IN email VARCHAR(100))
BEGIN
    UPDATE Patients
    SET FirstName = fName, LastName = lName, Address = addr, PhoneNumber = phone, Email = email
    WHERE PatientID = pID;
END //

CREATE PROCEDURE DeletePatient (IN pID INT)
BEGIN
    DELETE FROM Patients WHERE PatientID = pID;
END //

CREATE PROCEDURE RetrievePatients ()
BEGIN
    SELECT * FROM Patients;
END //

-- InsuranceInformation Table Procedures
CREATE PROCEDURE CreateInsurance (IN pID INT, IN provider VARCHAR(255), IN policy VARCHAR(255), IN copay DECIMAL(10, 2), IN deductible DECIMAL(10, 2), IN services TEXT)
BEGIN
    INSERT INTO InsuranceInformation (PatientID, InsuranceProvider, PolicyNumber, Copay, Deductible, CoveredServices)
    VALUES (pID, provider, policy, copay, deductible, services);
END //

CREATE PROCEDURE UpdateInsurance (IN iID INT, IN provider VARCHAR(255), IN policy VARCHAR(255), IN copay DECIMAL(10, 2), IN deductible DECIMAL(10, 2), IN services TEXT)
BEGIN
    UPDATE InsuranceInformation
    SET InsuranceProvider = provider, PolicyNumber = policy, Copay = copay, Deductible = deductible, CoveredServices = services
    WHERE InsuranceID = iID;
END //

CREATE PROCEDURE DeleteInsurance (IN iID INT)
BEGIN
    DELETE FROM InsuranceInformation WHERE InsuranceID = iID;
END //

CREATE PROCEDURE RetrieveInsurance ()
BEGIN
    SELECT * FROM InsuranceInformation;
END //

-- CopayDeductible Table Procedures
CREATE PROCEDURE CreateCopayDeductible (IN iID INT, IN pID INT, IN copay DECIMAL(10, 2), IN deductible DECIMAL(10, 2), IN remaining DECIMAL(10, 2))
BEGIN
    INSERT INTO CopayDeductible (InsuranceID, PatientID, CopayAmount, DeductibleAmount, RemainingDeductible)
    VALUES (iID, pID, copay, deductible, remaining);
END //

CREATE PROCEDURE UpdateCopayDeductible (IN cdID INT, IN copay DECIMAL(10, 2), IN deductible DECIMAL(10, 2), IN remaining DECIMAL(10, 2))
BEGIN
    UPDATE CopayDeductible
    SET CopayAmount = copay, DeductibleAmount = deductible, RemainingDeductible = remaining
    WHERE CopayDeductibleID = cdID;
END //

CREATE PROCEDURE DeleteCopayDeductible (IN cdID INT)
BEGIN
    DELETE FROM CopayDeductible WHERE CopayDeductibleID = cdID;
END //

CREATE PROCEDURE RetrieveCopayDeductible ()
BEGIN
    SELECT * FROM CopayDeductible;
END //

-- Bills Table Procedures
CREATE PROCEDURE CreateBill (IN pID INT, IN total DECIMAL(10, 2), IN insurancePaid DECIMAL(10, 2), IN owed DECIMAL(10, 2), IN date DATE, IN status VARCHAR(50))
BEGIN
    INSERT INTO Bills (PatientID, TotalAmount, InsurancePaid, AmountOwed, BillDate, BillStatus)
    VALUES (pID, total, insurancePaid, owed, date, status);
END //

CREATE PROCEDURE UpdateBill (IN bID INT, IN total DECIMAL(10, 2), IN insurancePaid DECIMAL(10, 2), IN owed DECIMAL(10, 2), IN status VARCHAR(50))
BEGIN
    UPDATE Bills
    SET TotalAmount = total, InsurancePaid = insurancePaid, AmountOwed = owed, BillStatus = status
    WHERE BillID = bID;
END //

CREATE PROCEDURE DeleteBill (IN bID INT)
BEGIN
    DELETE FROM Bills WHERE BillID = bID;
END //

CREATE PROCEDURE RetrieveBills ()
BEGIN
    SELECT * FROM Bills;
END //

-- Payments Table Procedures
CREATE PROCEDURE CreatePayment (IN pID INT, IN bID INT, IN amount DECIMAL(10, 2), IN method VARCHAR(50), IN date DATE, IN status VARCHAR(50))
BEGIN
    INSERT INTO Payments (PatientID, BillID, PaymentAmount, PaymentMethod, PaymentDate, PaymentStatus)
    VALUES (pID, bID, amount, method, date, status);
END //

CREATE PROCEDURE UpdatePayment (IN payID INT, IN amount DECIMAL(10, 2), IN method VARCHAR(50), IN status VARCHAR(50))
BEGIN
    UPDATE Payments
    SET PaymentAmount = amount, PaymentMethod = method, PaymentStatus = status
    WHERE PaymentID = payID;
END //

CREATE PROCEDURE DeletePayment (IN payID INT)
BEGIN
    DELETE FROM Payments WHERE PaymentID = payID;
END //

CREATE PROCEDURE RetrievePayments ()
BEGIN
    SELECT * FROM Payments;
END //
DELIMITER ;