-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: hospitalmanagementsystem
-- ------------------------------------------------------
-- Server version	8.0.36

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `appointment`
--

DROP TABLE IF EXISTS `appointment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment` (
  `AppointmentID` int NOT NULL AUTO_INCREMENT,
  `PatientID` int NOT NULL,
  `ProviderID` int NOT NULL,
  `RoomID` int DEFAULT NULL,
  `TypeID` int DEFAULT NULL,
  `AppointmentDate` date NOT NULL,
  `StartTime` time NOT NULL,
  `Status` enum('Scheduled','Checked-In','Completed','Cancelled') DEFAULT 'Scheduled',
  `Notes` text,
  PRIMARY KEY (`AppointmentID`),
  KEY `PatientID` (`PatientID`),
  KEY `ProviderID` (`ProviderID`),
  KEY `RoomID` (`RoomID`),
  KEY `TypeID` (`TypeID`),
  CONSTRAINT `appointment_ibfk_1` FOREIGN KEY (`PatientID`) REFERENCES `patient` (`PatientID`) ON DELETE CASCADE,
  CONSTRAINT `appointment_ibfk_2` FOREIGN KEY (`ProviderID`) REFERENCES `provider` (`ProviderID`) ON DELETE CASCADE,
  CONSTRAINT `appointment_ibfk_3` FOREIGN KEY (`RoomID`) REFERENCES `room` (`RoomID`) ON DELETE SET NULL,
  CONSTRAINT `appointment_ibfk_4` FOREIGN KEY (`TypeID`) REFERENCES `appointmenttype` (`TypeID`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `appointmenttype`
--

DROP TABLE IF EXISTS `appointmenttype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointmenttype` (
  `TypeID` int NOT NULL AUTO_INCREMENT,
  `TypeName` varchar(50) NOT NULL,
  `Duration` int DEFAULT NULL,
  `Description` text,
  PRIMARY KEY (`TypeID`),
  UNIQUE KEY `TypeName` (`TypeName`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bill`
--

DROP TABLE IF EXISTS `bill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bill` (
  `BillID` int NOT NULL AUTO_INCREMENT,
  `PatientID` int NOT NULL,
  `GeneratedDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DueDate` date NOT NULL,
  `TotalAmount` decimal(10,2) NOT NULL,
  `Status` enum('Pending','Paid','Overdue','Cancelled') DEFAULT 'Pending',
  PRIMARY KEY (`BillID`),
  KEY `PatientID` (`PatientID`),
  CONSTRAINT `bill_ibfk_1` FOREIGN KEY (`PatientID`) REFERENCES `patient` (`PatientID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `department` (
  `DepartmentID` int NOT NULL AUTO_INCREMENT,
  `DepartmentName` varchar(100) NOT NULL,
  `Location` varchar(100) DEFAULT NULL,
  `ManagerID` int DEFAULT NULL,
  PRIMARY KEY (`DepartmentID`),
  UNIQUE KEY `DepartmentName` (`DepartmentName`),
  KEY `ManagerID` (`ManagerID`),
  CONSTRAINT `department_ibfk_1` FOREIGN KEY (`ManagerID`) REFERENCES `user` (`UserID`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dutyroster`
--

DROP TABLE IF EXISTS `dutyroster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dutyroster` (
  `RosterID` int NOT NULL AUTO_INCREMENT,
  `ProviderID` int NOT NULL,
  `ShiftDate` date NOT NULL,
  `ShiftStart` time NOT NULL,
  `ShiftEnd` time NOT NULL,
  `Status` enum('Scheduled','On-Duty','Completed','Cancelled') DEFAULT 'Scheduled',
  PRIMARY KEY (`RosterID`),
  KEY `ProviderID` (`ProviderID`),
  CONSTRAINT `dutyroster_ibfk_1` FOREIGN KEY (`ProviderID`) REFERENCES `provider` (`ProviderID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event` (
  `EventID` int NOT NULL AUTO_INCREMENT,
  `EventType` enum('Reminder','Follow-up','Survey','Alert') NOT NULL,
  `RelatedID` int DEFAULT NULL,
  `UserID` int NOT NULL,
  `EventDate` timestamp NOT NULL,
  `Description` text,
  `Status` enum('Scheduled','Triggered','Completed','Cancelled') DEFAULT 'Scheduled',
  PRIMARY KEY (`EventID`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `event_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `insurance`
--

DROP TABLE IF EXISTS `insurance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurance` (
  `InsuranceID` int NOT NULL AUTO_INCREMENT,
  `ProviderName` varchar(100) NOT NULL,
  `ContactInfo` text,
  `PolicyDetails` text,
  PRIMARY KEY (`InsuranceID`),
  UNIQUE KEY `ProviderName` (`ProviderName`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `InventoryID` int NOT NULL AUTO_INCREMENT,
  `MedicationID` int NOT NULL,
  `BatchNumber` varchar(50) DEFAULT NULL,
  `StockLevel` int NOT NULL,
  `ExpiryDate` date NOT NULL,
  `Location` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`InventoryID`),
  KEY `MedicationID` (`MedicationID`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`MedicationID`) REFERENCES `medication` (`MedicationID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `labresult`
--

DROP TABLE IF EXISTS `labresult`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `labresult` (
  `ResultID` int NOT NULL AUTO_INCREMENT,
  `LabTestID` int NOT NULL,
  `ResultDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ResultValue` text,
  `ReferenceRange` varchar(100) DEFAULT NULL,
  `Interpretation` text,
  `TechnicianID` int DEFAULT NULL,
  PRIMARY KEY (`ResultID`),
  KEY `LabTestID` (`LabTestID`),
  KEY `TechnicianID` (`TechnicianID`),
  CONSTRAINT `labresult_ibfk_1` FOREIGN KEY (`LabTestID`) REFERENCES `labtest` (`LabTestID`) ON DELETE CASCADE,
  CONSTRAINT `labresult_ibfk_2` FOREIGN KEY (`TechnicianID`) REFERENCES `provider` (`ProviderID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `labtest`
--

DROP TABLE IF EXISTS `labtest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `labtest` (
  `LabTestID` int NOT NULL AUTO_INCREMENT,
  `PatientID` int NOT NULL,
  `ProviderID` int NOT NULL,
  `LabTypeID` int NOT NULL,
  `OrderDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Status` enum('Ordered','Sample-Collected','Processing','Completed','Cancelled') DEFAULT 'Ordered',
  `Priority` enum('Routine','Urgent','Emergency') DEFAULT 'Routine',
  PRIMARY KEY (`LabTestID`),
  KEY `PatientID` (`PatientID`),
  KEY `ProviderID` (`ProviderID`),
  KEY `LabTypeID` (`LabTypeID`),
  CONSTRAINT `labtest_ibfk_1` FOREIGN KEY (`PatientID`) REFERENCES `patient` (`PatientID`) ON DELETE CASCADE,
  CONSTRAINT `labtest_ibfk_2` FOREIGN KEY (`ProviderID`) REFERENCES `provider` (`ProviderID`) ON DELETE CASCADE,
  CONSTRAINT `labtest_ibfk_3` FOREIGN KEY (`LabTypeID`) REFERENCES `labtype` (`LabTypeID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `labtype`
--

DROP TABLE IF EXISTS `labtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `labtype` (
  `LabTypeID` int NOT NULL AUTO_INCREMENT,
  `TypeName` varchar(100) NOT NULL,
  `Description` text,
  `ProcessingTime` int DEFAULT NULL,
  PRIMARY KEY (`LabTypeID`),
  UNIQUE KEY `TypeName` (`TypeName`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loginattempt`
--

DROP TABLE IF EXISTS `loginattempt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loginattempt` (
  `LoginID` int NOT NULL AUTO_INCREMENT,
  `UserID` int DEFAULT NULL,
  `LoginTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `SuccessStatus` tinyint(1) DEFAULT NULL,
  `IPAddress` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`LoginID`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `loginattempt_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `medicalrecord`
--

DROP TABLE IF EXISTS `medicalrecord`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medicalrecord` (
  `RecordID` int NOT NULL AUTO_INCREMENT,
  `PatientID` int NOT NULL,
  `DateCreated` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `LastUpdated` timestamp NULL DEFAULT NULL,
  `MedicalHistory` text,
  `Allergies` text,
  PRIMARY KEY (`RecordID`),
  KEY `PatientID` (`PatientID`),
  CONSTRAINT `medicalrecord_ibfk_1` FOREIGN KEY (`PatientID`) REFERENCES `patient` (`PatientID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `medication`
--

DROP TABLE IF EXISTS `medication`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medication` (
  `MedicationID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `GenericName` varchar(100) DEFAULT NULL,
  `Category` varchar(50) DEFAULT NULL,
  `Manufacturer` varchar(100) DEFAULT NULL,
  `UnitPrice` decimal(10,2) NOT NULL,
  PRIMARY KEY (`MedicationID`),
  UNIQUE KEY `Name` (`Name`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notification`
--

DROP TABLE IF EXISTS `notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification` (
  `NotificationID` int NOT NULL AUTO_INCREMENT,
  `TypeID` int NOT NULL,
  `UserID` int NOT NULL,
  `Title` varchar(100) NOT NULL,
  `Message` text NOT NULL,
  `SentDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ReadDate` timestamp NULL DEFAULT NULL,
  `Status` enum('Pending','Sent','Read','Failed') DEFAULT 'Pending',
  PRIMARY KEY (`NotificationID`),
  KEY `TypeID` (`TypeID`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`TypeID`) REFERENCES `notificationtype` (`TypeID`) ON DELETE CASCADE,
  CONSTRAINT `notification_ibfk_2` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notificationtype`
--

DROP TABLE IF EXISTS `notificationtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notificationtype` (
  `TypeID` int NOT NULL AUTO_INCREMENT,
  `TypeName` varchar(50) NOT NULL,
  `Description` text,
  `Template` text,
  PRIMARY KEY (`TypeID`),
  UNIQUE KEY `TypeName` (`TypeName`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `passwordreset`
--

DROP TABLE IF EXISTS `passwordreset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `passwordreset` (
  `ResetToken` varchar(255) NOT NULL,
  `UserID` int DEFAULT NULL,
  `ExpirationDate` timestamp NOT NULL,
  `ResetStatus` enum('Pending','Used','Expired') DEFAULT 'Pending',
  PRIMARY KEY (`ResetToken`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `passwordreset_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient`
--

DROP TABLE IF EXISTS `patient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient` (
  `PatientID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `DateOfBirth` date NOT NULL,
  `Gender` enum('Male','Female','Other') DEFAULT NULL,
  `Address` text,
  `ContactNumber` varchar(15) DEFAULT NULL,
  `EmergencyContact` varchar(100) DEFAULT NULL,
  `BloodType` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`PatientID`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `patient_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patientinsurance`
--

DROP TABLE IF EXISTS `patientinsurance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patientinsurance` (
  `PatientInsuranceID` int NOT NULL AUTO_INCREMENT,
  `PatientID` int NOT NULL,
  `InsuranceID` int NOT NULL,
  `PolicyNumber` varchar(50) NOT NULL,
  `StartDate` date NOT NULL,
  `EndDate` date DEFAULT NULL,
  PRIMARY KEY (`PatientInsuranceID`),
  UNIQUE KEY `PolicyNumber` (`PolicyNumber`),
  KEY `PatientID` (`PatientID`),
  KEY `InsuranceID` (`InsuranceID`),
  CONSTRAINT `patientinsurance_ibfk_1` FOREIGN KEY (`PatientID`) REFERENCES `patient` (`PatientID`) ON DELETE CASCADE,
  CONSTRAINT `patientinsurance_ibfk_2` FOREIGN KEY (`InsuranceID`) REFERENCES `insurance` (`InsuranceID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment` (
  `PaymentID` int NOT NULL AUTO_INCREMENT,
  `BillID` int NOT NULL,
  `Amount` decimal(10,2) NOT NULL,
  `PaymentDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `MethodID` int NOT NULL,
  `TransactionReference` varchar(100) DEFAULT NULL,
  `Status` enum('Pending','Completed','Failed') DEFAULT 'Pending',
  PRIMARY KEY (`PaymentID`),
  UNIQUE KEY `TransactionReference` (`TransactionReference`),
  KEY `BillID` (`BillID`),
  KEY `MethodID` (`MethodID`),
  CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`BillID`) REFERENCES `bill` (`BillID`) ON DELETE CASCADE,
  CONSTRAINT `payment_ibfk_2` FOREIGN KEY (`MethodID`) REFERENCES `paymentmethod` (`MethodID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paymentmethod`
--

DROP TABLE IF EXISTS `paymentmethod`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paymentmethod` (
  `MethodID` int NOT NULL AUTO_INCREMENT,
  `MethodName` varchar(50) NOT NULL,
  `Description` text,
  PRIMARY KEY (`MethodID`),
  UNIQUE KEY `MethodName` (`MethodName`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prescription`
--

DROP TABLE IF EXISTS `prescription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescription` (
  `PrescriptionID` int NOT NULL AUTO_INCREMENT,
  `PatientID` int NOT NULL,
  `ProviderID` int NOT NULL,
  `PrescriptionDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Status` enum('Active','Completed','Cancelled') DEFAULT 'Active',
  `Notes` text,
  PRIMARY KEY (`PrescriptionID`),
  KEY `PatientID` (`PatientID`),
  KEY `ProviderID` (`ProviderID`),
  CONSTRAINT `prescription_ibfk_1` FOREIGN KEY (`PatientID`) REFERENCES `patient` (`PatientID`) ON DELETE CASCADE,
  CONSTRAINT `prescription_ibfk_2` FOREIGN KEY (`ProviderID`) REFERENCES `provider` (`ProviderID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prescriptiondetail`
--

DROP TABLE IF EXISTS `prescriptiondetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescriptiondetail` (
  `DetailID` int NOT NULL AUTO_INCREMENT,
  `PrescriptionID` int NOT NULL,
  `MedicationID` int NOT NULL,
  `Dosage` varchar(50) DEFAULT NULL,
  `Frequency` varchar(50) DEFAULT NULL,
  `Duration` int DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `Instructions` text,
  PRIMARY KEY (`DetailID`),
  KEY `PrescriptionID` (`PrescriptionID`),
  KEY `MedicationID` (`MedicationID`),
  CONSTRAINT `prescriptiondetail_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `prescription` (`PrescriptionID`) ON DELETE CASCADE,
  CONSTRAINT `prescriptiondetail_ibfk_2` FOREIGN KEY (`MedicationID`) REFERENCES `medication` (`MedicationID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `provider`
--

DROP TABLE IF EXISTS `provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `provider` (
  `ProviderID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `Specialization` varchar(100) DEFAULT NULL,
  `LicenseNumber` varchar(50) DEFAULT NULL,
  `DepartmentID` int DEFAULT NULL,
  PRIMARY KEY (`ProviderID`),
  UNIQUE KEY `LicenseNumber` (`LicenseNumber`),
  KEY `UserID` (`UserID`),
  KEY `DepartmentID` (`DepartmentID`),
  CONSTRAINT `provider_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `provider_ibfk_2` FOREIGN KEY (`DepartmentID`) REFERENCES `department` (`DepartmentID`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `RoleID` int NOT NULL AUTO_INCREMENT,
  `RoleName` varchar(50) NOT NULL,
  `Description` text,
  PRIMARY KEY (`RoleID`),
  UNIQUE KEY `RoleName` (`RoleName`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `room`
--

DROP TABLE IF EXISTS `room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room` (
  `RoomID` int NOT NULL AUTO_INCREMENT,
  `RoomNumber` varchar(10) NOT NULL,
  `RoomType` varchar(50) DEFAULT NULL,
  `Floor` int DEFAULT NULL,
  `Status` enum('Available','Occupied','Maintenance') DEFAULT 'Available',
  PRIMARY KEY (`RoomID`),
  UNIQUE KEY `RoomNumber` (`RoomNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `survey`
--

DROP TABLE IF EXISTS `survey`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey` (
  `SurveyID` int NOT NULL AUTO_INCREMENT,
  `Title` varchar(100) NOT NULL,
  `Description` text,
  `StartDate` date NOT NULL,
  `EndDate` date NOT NULL,
  `Status` enum('Draft','Active','Closed') DEFAULT 'Draft',
  PRIMARY KEY (`SurveyID`),
  UNIQUE KEY `Title` (`Title`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `surveyresponse`
--

DROP TABLE IF EXISTS `surveyresponse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `surveyresponse` (
  `ResponseID` int NOT NULL AUTO_INCREMENT,
  `SurveyID` int NOT NULL,
  `PatientID` int NOT NULL,
  `ResponseDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Responses` text NOT NULL,
  PRIMARY KEY (`ResponseID`),
  KEY `SurveyID` (`SurveyID`),
  KEY `PatientID` (`PatientID`),
  CONSTRAINT `surveyresponse_ibfk_1` FOREIGN KEY (`SurveyID`) REFERENCES `survey` (`SurveyID`) ON DELETE CASCADE,
  CONSTRAINT `surveyresponse_ibfk_2` FOREIGN KEY (`PatientID`) REFERENCES `patient` (`PatientID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Username` varchar(50) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `RoleID` int DEFAULT NULL,
  `AccountStatus` enum('Active','Inactive','Suspended') DEFAULT 'Active',
  `RegistrationDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `LastLogin` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Username` (`Username`),
  UNIQUE KEY `Email` (`Email`),
  KEY `RoleID` (`RoleID`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`RoleID`) REFERENCES `role` (`RoleID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-12 12:59:32
