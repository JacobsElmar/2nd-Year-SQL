CREATE DATABASE DBD_Project_Elmar
GO

USE DBD_Project_Elmar
GO

USE DBD_Project_Elmar
CREATE LOGIN Projec_Login WITH PASSWORD = '123'
CREATE USER Elmar FOR LOGIN Projec_Login

USE DBD_Project_Elmar
GRANT CONTROL  ON DBD_Project_Elmar to ELMAR

CREATE TABLE Locations (
LocationID INT NOT NULL PRIMARY KEY,
City VARCHAR(25)
)

CREATE TABLE Courts (
CourtID INT NOT NULL PRIMARY KEY,
CourtType VARCHAR(20) NOT NULL,
ManHours VARCHAR(30),
)

CREATE TABLE Customer (
CustomerID INT NOT NULL PRIMARY KEY,
CompanyName VARCHAR(20),
ContactNum VARCHAR(10),
LocationID INT FOREIGN KEY REFERENCES Locations(LocationID),
NumOfCourts INT,
CourtID INT FOREIGN KEY REFERENCES Courts(CourtID)
)

CREATE TABLE Branch (
BranchID INT NOT NULL PRIMARY KEY,
LocationID INT FOREIGN KEY REFERENCES Locations(LocationID),
CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID), 
BranchPhoneNum Varchar(10)
)

CREATE TABLE Teams (
TeamID INT NOT NULL PRIMARY KEY,
LocationID INT REFERENCES Locations(LocationID),
CourtID INT FOREIGN KEY REFERENCES Courts(CourtID)
)

CREATE TABLE Employees (
EmpID INT NOT NULL PRIMARY KEY,
Name VARCHAR(20),
Surname VARCHAR(20),
BranchID INT FOREIGN KEY REFERENCES Branch(BranchID),
LocationID INT FOREIGN KEY REFERENCES Locations(LocationID),
PhoneNum VARCHAR(10),
TeamID INT FOREIGN KEY REFERENCES Teams(TeamID)
)
GO

INSERT INTO Locations (LocationID, City) VALUES 
(61,'Cape Town'),
(17,'Johannesburg'),
(88,'Garden Route')

INSERT INTO Courts (CourtID, CourtType, ManHours) VALUES
(91,'Tennis','18'),
(11,'Hockey Astro','48'),
(62,'Netball','15'),
(18,'Basketball','15'),
(43,'Indoor Cricket','24'),
(81,'Soccer','16'),
(45,'Rugby','21'),
(90,'Gym Flooring','10'),
(72,'Athletics','48')

INSERT INTO Customer (CustomerID, CompanyName, ContactNum, LocationID, NumOfCourts, CourtID) VALUES
(77,'Pearson High School','0816548721',61, 2,45),
(16,'Oldview Tennis Club','0615463748',88,6,91),
(51,'Midrand Sport Club','0842687462',17,3,91),
(82,'Planet Gym','0417287676',17,1,90),
(31,'Gary Dojo','0418373645',17,3,18),
(43,'Play Sport','0420984567',88,5,90),
(59,'United Active','0821927649',61,8,81),
(39,'Superman Sports','0741029836',17,1,11),
(92,'Crazy Athletics','0721823465',88,2,91)

INSERT INTO Branch (BranchID, LocationID, CustomerID, BranchPhoneNum) VALUES
(11,61,77,'0418761432'),
(22,17,82,'0420928482'),
(33,88,43,'0463251872')

INSERT INTO Teams (TeamID,LocationID,CourtID) VALUES
(11,61,91),
(12,61,11),
(13,17,62),
(14,17,18),
(15,88,43),
(16,88,81)

INSERT INTO Employees (EmpID, Name, Surname, BranchID, LocationID, PhoneNum, TeamID) VALUES 
(21,'Jacob','Andreas',11,61,'0726473822',12),
(22 ,'Brianna','Lamb',11 ,61 ,'0825346354', 11),
(23 ,'Osian','Evans',11 ,61 ,'0983456547', 11),
(24 ,'James','Alexander',22 ,17 ,'0764530099', 13),
(25 ,'Nina','Rowe',22 ,17 ,'0756748281', 13),
(26 ,'Russell','Ford',22 ,17 ,'0611334576', 14),
(27 ,'Leonardo','Paul',22 ,17 ,'0412929999', 14),
(28 ,'Joanne','Turner',33 ,88 ,'0425678769', 15),
(29 ,'Jim','Peters',33 ,88 ,'0643450987', 15),
(30 ,'Henry','Davis',33 ,88 ,'0677684657', 16)

SELECT * FROM Locations
SELECT * from Courts
SELECT * FROM Customer
SELECT * FROM Branch
SELECT * FROM Teams
SELECT * FROM Employees
go

--Show branch employees procedure 
CREATE PROCEDURE sp_ShowBranchEmp  @Branch varchar(20)
AS
DECLARE @BranchID int
  IF (@Branch = 'Cape Town') SET @BranchID = 11
   ELSE 
    IF (@Branch = 'Johannesburg') SET @BranchID = 22
     ELSE 
      IF (@Branch = 'Garden Route') SET @BranchID = 33
	   ELSE PRINT 'There is no branch in that area'
SELECT EmpID, Name +' '+ Surname AS 'Full Name', PhoneNum, TeamID, Locations.City 
FROM Employees -- WHERE BranchID = @BranchID
INNER JOIN Locations
on Employees.LocationID = Locations.LocationID
Where BranchID = @BranchID
Go


--Executing the Branch employee procedure, type in what branch employees you would like to see
EXEC sp_ShowBranchEmp @Branch = 'Cape Town'
EXEC sp_ShowBranchEmp @Branch = 'Johannesburg'
EXEC sp_ShowBranchEmp @Branch = 'Garden Route'
GO

--View created to see all customers from Cape Town
CREATE VIEW vw_CustFrmCPT AS
SELECT * 
FROM Customer
WHERE LocationID = 61
GO

--Execute vw_CustFrmCPT
SELECT * FROM vw_CustFrmCPT;


--View created to see all customers from Johannesburg
CREATE VIEW vw_CustFrmJHB AS
SELECT * 
FROM Customer
WHERE LocationID = 17
GO

--Execute vw_CustFrmJHB
SELECT * FROM vw_CustFrmJHB;


--View created to see all customers from Garden Route
CREATE VIEW vw_CustFrmGDR AS
SELECT * 
FROM Customer
WHERE LocationID = 88
GO

--Execute vw_CustFrmGDR
SELECT * FROM vw_CustFrmGDR;
GO

--Stored procedure to show locations and how many teams are in that location 
CREATE PROCEDURE sp_ShowLocationTeams
AS
SELECT Locations.LocationID,Locations.City , COUNT(Teams.TeamID)
FROM Locations
INNER JOIN Teams
ON Locations.LocationID = Teams.LocationID
GROUP BY Locations.LocationID, Locations.City
GO

--Execute procedure sp_ShowLocationTeams
EXEC sp_ShowLocationTeams
GO

--Create view to see all customer names, phone number and locaion
CREATE VIEW vw_CustomerNames AS
SELECT CompanyName, ContactNum, city
FROM Customer
INNER JOIN Locations
ON Locations.LocationID = Customer.LocationID
GO

--Execute view vw_CustomerNames
SELECT * FROM vw_CustomerNames
GO

--Creating a trigger to see change to employees table
CREATE TRIGGER tr_EmpChange 
ON Employees
FOR INSERT, DELETE, UPDATE
AS
BEGIN
  PRINT 'A change has been made to the Employees table'
END
GO

--Creating a trigger to see change to ecustomers table
CREATE TRIGGER tr_CusChange 
ON Customer
FOR INSERT, DELETE, UPDATE
AS
BEGIN
  PRINT 'A change has been made to the Customer table'
END
GO

--Create view to see how many courts a customer has of a certain kind
CREATE VIEW vw_CusCourts AS
SELECT CompanyName, NumOfCourts, CourtType
FROM Customer
LEFT JOIN Courts
ON Customer.CourtID = Courts.CourtID
GO

--Execute view vw_CusCourts
SELECT * FROM vw_CusCourts
GO

--Create a procedure that retuns the number of courts resurfaced
CREATE PROCEDURE sp_CourtCount
AS
SELECT SUM(NumOfCourts) AS 'Total Amount of Courts Resurfaced'
FROM Customer
GO

--Execute procedure sp_CourtCount
Exec sp_CourtCount