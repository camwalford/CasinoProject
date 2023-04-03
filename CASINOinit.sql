-- Create Database


USE master;
GO

IF EXISTS (
	SELECT name
	FROM sys.databases
	WHERE name = N'CASINO'
)

DROP DATABASE CASINO;
GO

CREATE DATABASE CASINO;
GO

USE CASINO;
GO

-- Drop Tables
DROP TABLE IF EXISTS SHIFT_INV;
DROP TABLE IF EXISTS INVENTORY;
DROP TABLE IF EXISTS LEAVE;
DROP TABLE IF EXISTS WRITTEN_WARNING;
DROP TABLE IF EXISTS ACHIEVEMENT;
DROP TABLE IF EXISTS EMPLOYEE_REGULATORY_TRAINING;
DROP INDEX IF EXISTS FK2 ON EMPLOYEE_REGULATORY_TRAINING;
DROP INDEX IF EXISTS FK1 ON EMPLOYEE_REGULATORY_TRAINING;
DROP TABLE IF EXISTS REGULATORY_TRAINING;
DROP TABLE IF EXISTS EMPLOYEE_SKILL_TRAINING;
DROP INDEX IF EXISTS FK2 ON EMPLOYEE_SKILL_TRAINING;
DROP INDEX IF EXISTS FK1 ON EMPLOYEE_SKILL_TRAINING;
DROP TABLE IF EXISTS SKILL_TRAINING;
DROP TABLE IF EXISTS TRAINING_SESSION;
DROP TABLE IF EXISTS SEC_SKILL;
DROP TABLE IF EXISTS SKILL;
DROP TABLE IF EXISTS SECTION;
DROP TABLE IF EXISTS SHIFT;
DROP TABLE IF EXISTS SCHEDULE;
DROP TABLE IF EXISTS JOB_HIST;
DROP TABLE IF EXISTS EMPLOYEE;
DROP TABLE IF EXISTS ROLE_CERTIFICATION;
DROP TABLE IF EXISTS CERTIFICATION;
DROP TABLE IF EXISTS ROLE;
DROP TABLE IF EXISTS DEPARTMENT;
GO

-- Create Tables
CREATE TABLE DEPARTMENT (
	DEP_ID INT PRIMARY KEY IDENTITY(1,1),
	DEP_NAME VARCHAR(39) NOT NULL
);
GO

--Role titles
CREATE TABLE ROLE (
	ROLE_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ROLE_TITLE VARCHAR(30) NOT NULL,
	ROLE_DESC VARCHAR(75)
);
GO

--Certifications
CREATE TABLE CERTIFICATION (
	CERT_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	CERT_NAME VARCHAR(30) NOT NULL,
	CERT_VALID_FOR DATE NOT NULL
);
GO

--Certification needed for a specific role
CREATE TABLE ROLE_CERTIFICATION (
	CERT_ID INT NOT NULL,
	ROLE_ID INT NOT NULL,
	FOREIGN KEY(CERT_ID) REFERENCES CERTIFICATION(CERT_ID),
	FOREIGN KEY(ROLE_ID) REFERENCES ROLE(ROLE_ID),
	PRIMARY KEY(CERT_ID, ROLE_ID)
);
GO

--Employee information
CREATE TABLE [EMPLOYEE] (
  [EMP_ID] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [DEP_ID] INT NOT NULL,
  [EMP_ROLE_ID] INT NOT NULL,
  [DATE_ASSIGNED] DATE NOT NULL,
  [EMP_FNAME] VARCHAR(30) NOT NULL,
  [EMP_LNAME] VARCHAR(30) NOT NULL,
  [EMP_HIRE_DATE] DATE NOT NULL,
  [EMP_PAY_RATE] DECIMAL(10, 2) NOT NULL,
  [EMP_STREET_NUM] VARCHAR(10) NOT NULL,
  [EMP_STREET] VARCHAR(30) NOT NULL,
  [EMP_CITY] VARCHAR(30) NOT NULL,
  [EMP_DOB] DATE NOT NULL,
  [EMP_FIRE_DATE] DATE,
  [EMP_LOCKER] INT,
  [EMP_VACA_ENTITLEMENT] INT NOT NULL DEFAULT 7,
  [EMP_SICK_ENTITLEMENT] INT NOT NULL DEFAULT 5,
  [EMP_GENDER] CHAR(1),
  [EMP_AGE] INT NOT NULL,
  CONSTRAINT [FK_EMPLOYEE.DEP_ID]
    FOREIGN KEY ([DEP_ID])
      REFERENCES [DEPARTMENT]([DEP_ID]),
  CONSTRAINT [FK_EMPLOYEE.EMP_ROLE]
    FOREIGN KEY ([EMP_ROLE_ID])
      REFERENCES [ROLE]([ROLE_ID])
);
GO

--Job history for each employee
CREATE TABLE JOB_HIST (
	EMP_ID INT NOT NULL,
	DATE_ASSIGNED DATE NOT NULL,
	DEP_ID INT NOT NULL,
	ROLE_ID INT NOT NULL,
	EMP_PAY_RATE DECIMAL(10, 2) NOT NULL,
	FOREIGN KEY(EMP_ID) REFERENCES EMPLOYEE(EMP_ID),
	FOREIGN KEY(DEP_ID) REFERENCES DEPARTMENT(DEP_ID),
	FOREIGN KEY(ROLE_ID) REFERENCES ROLE(ROLE_ID),
	PRIMARY KEY (EMP_ID, DATE_ASSIGNED, DEP_ID, ROLE_ID)
);
GO

--Trigger to update the JOB_HIST table when an employee's role is changed
CREATE TRIGGER trg_employee_role_change
ON EMPLOYEE
AFTER UPDATE
AS
BEGIN
  IF UPDATE(EMP_ROLE_ID)
  BEGIN
    -- Insert the new records into JOB_HIST
    INSERT INTO JOB_HIST (EMP_ID, DATE_ASSIGNED, DEP_ID, ROLE_ID, EMP_PAY_RATE)
    SELECT i.EMP_ID, i.DATE_ASSIGNED, i.DEP_ID, i.EMP_ROLE_ID, i.EMP_PAY_RATE
    FROM inserted AS i
    JOIN deleted AS d ON i.EMP_ID = d.EMP_ID
    WHERE i.EMP_ROLE_ID <> d.EMP_ROLE_ID;
  END;
END;
GO

--Daily schedule for an employee
CREATE TABLE SCHEDULE (
	SCH_ID INT PRIMARY KEY IDENTITY(1,1),
	EMP_ID INTEGER NOT NULL,
	SCH_DATE DATE NOT NULL,
	FOREIGN KEY(EMP_ID) REFERENCES EMPLOYEE(EMP_ID) ON UPDATE CASCADE
);

--Section of the casino which employees can be assigned (NORTH, EAST, SOUTH, WEST, HIGH LIMIT)
CREATE TABLE SECTION (
	SEC_ID INT PRIMARY KEY IDENTITY(1,1),
	SEC_NAME VARCHAR(30) NOT NULL
);

--
CREATE TABLE SHIFT (
	SHIFT_ID INT PRIMARY KEY IDENTITY(1,1),
	SHIFT_START TIME NOT NULL,
	SHIFT_END TIME NOT NULL,
	SCH_ID INTEGER NOT NULL,
	SEC_ID INTEGER NOT NULL,
	IS_BREAKER BIT NOT NULL DEFAULT 0,
	FOREIGN KEY(SEC_ID) REFERENCES SECTION(SEC_ID),
	FOREIGN KEY(SCH_ID) REFERENCES SCHEDULE(SCH_ID) ON UPDATE CASCADE
);

CREATE TABLE SKILL (
	SKILL_ID INT PRIMARY KEY IDENTITY(1,1),
	SKILL_NAME VARCHAR(30) NOT NULL
);

CREATE TABLE SEC_SKILL (
SKILL_ID INT NOT NULL,
SEC_ID INT NOT NULL,
PRIMARY KEY(SKILL_ID, SEC_ID),
FOREIGN KEY(SKILL_ID) REFERENCES SKILL(SKILL_ID) ON UPDATE CASCADE,
FOREIGN KEY(SEC_ID) REFERENCES SECTION(SEC_ID) ON UPDATE CASCADE
);

CREATE TABLE [TRAINING_SESSION] (
[TS_ID] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
[TS_DATE] DATE NOT NULL,
[TS_TYPE] VARCHAR(30) NOT NULL
);

CREATE TABLE [SKILL_TRAINING] (
[TS_ID] INT NOT NULL,
[SKILL_ID] INT NOT NULL,
[TS_MANAGER_ID] INT NOT NULL,
[TS_SUPERVISOR_ID] INT NOT NULL,
CONSTRAINT [FK_SKILL_TRAINING.TS_ID]
FOREIGN KEY ([TS_ID])
REFERENCES TRAINING_SESSION,
CONSTRAINT [FK_SKILL_TRAINING.SKILL_ID]
FOREIGN KEY ([SKILL_ID])
REFERENCES SKILL
);

CREATE TABLE [EMPLOYEE_SKILL_TRAINING] (
[TS_ID] INT NOT NULL,
[EMP_ID] INT NOT NULL,
PRIMARY KEY ([TS_ID], [EMP_ID]),
FOREIGN KEY([TS_ID]) REFERENCES TRAINING_SESSION,
FOREIGN KEY([EMP_ID]) REFERENCES EMPLOYEE
);

CREATE INDEX [FK1] ON [EMPLOYEE_SKILL_TRAINING] ([TS_ID]);

CREATE INDEX [FK2] ON [EMPLOYEE_SKILL_TRAINING] ([EMP_ID]);

CREATE TABLE [REGULATORY_TRAINING] (
[TS_ID] INT NOT NULL,
[CERT_ID] INT NOT NULL,
CONSTRAINT [FK_REGULATORY_TRAINING.TS_ID]
FOREIGN KEY ([TS_ID])
REFERENCES TRAINING_SESSION,
CONSTRAINT [FK_REGULATORY_TRAINING.CERT_ID]
FOREIGN KEY ([CERT_ID])
REFERENCES CERTIFICATION
);

CREATE TABLE [EMPLOYEE_REGULATORY_TRAINING] (
[TS_ID] INT NOT NULL,
[EMP_ID] INT NOT NULL,
[EXPIRATION_DATE] DATE NOT NULL,
PRIMARY KEY ([TS_ID], [EMP_ID]),
FOREIGN KEY([TS_ID]) REFERENCES TRAINING_SESSION,
FOREIGN KEY([EMP_ID]) REFERENCES EMPLOYEE
);

CREATE INDEX [FK1] ON [EMPLOYEE_REGULATORY_TRAINING] ([TS_ID]);

CREATE INDEX [FK2] ON [EMPLOYEE_REGULATORY_TRAINING] ([EMP_ID]);

CREATE TABLE [ACHIEVEMENT] (
[ACHIEVEMENT_ID] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
[EMP_ID] INT NOT NULL,
[ACH_TITLE] VARCHAR(50) NOT NULL,
[ACH_DESC] VARCHAR(200),
[SUPERVISOR_ID] INT NOT NULL,
[ACH_DATE] DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY([EMP_ID]) REFERENCES EMPLOYEE,
FOREIGN KEY([SUPERVISOR_ID]) REFERENCES EMPLOYEE
);

CREATE TABLE WRITTEN_WARNING (
WW_ID INT PRIMARY KEY IDENTITY(1,1),
EMP_ID INT NOT NULL,
WW_LEVEL INT NOT NULL CHECK (WW_LEVEL BETWEEN 0 AND 3),
WW_DATE_ISSUED DATE NOT NULL,
WW_DESC VARCHAR(300),
WW_MANAGER_ID INT NOT NULL,
WW_COMPOUNDING_UNTIL DATE,
FOREIGN KEY(WW_MANAGER_ID) REFERENCES EMPLOYEE(EMP_ID),
FOREIGN KEY(EMP_ID) REFERENCES EMPLOYEE(EMP_ID)
);

CREATE TABLE LEAVE (
LEAVE_ID INT PRIMARY KEY IDENTITY(1,1),
EMP_ID INT NOT NULL,
LEAVE_START_DATE DATE NOT NULL,
LEAVE_REASON VARCHAR(100),
LEAVE_END_DATE DATE,
LEAVE_COMMENTS VARCHAR(300),
FOREIGN KEY(EMP_ID) REFERENCES EMPLOYEE(EMP_ID) ON UPDATE CASCADE
);
GO

CREATE TABLE INVENTORY (
INV_ID INT PRIMARY KEY IDENTITY(1,1),
INV_NAME VARCHAR(50) NOT NULL,
INV_PRICE DECIMAL(10, 2) NOT NULL,
INV_QTY INT NOT NULL,
INV_EXP DATE
);

CREATE TABLE SHIFT_INV (
SHIFT_ID INT NOT NULL,
INV_ID INT NOT NULL,
SHIFT_INV_QTY INT NOT NULL,
PRIMARY KEY(SHIFT_ID, INV_ID),
FOREIGN KEY(SHIFT_ID) REFERENCES SHIFT(SHIFT_ID) ON UPDATE CASCADE,
FOREIGN KEY(INV_ID) REFERENCES INVENTORY(INV_ID) ON UPDATE CASCADE
);

-- Fill in Tables with values

INSERT INTO DEPARTMENT (DEP_NAME)
VALUES ('SLOT FLOOR'), ('HR');

INSERT INTO ROLE (ROLE_TITLE, ROLE_DESC)
VALUES ('Director', 'Head of the Slot Floor'),
('Shift Manager', 'Daily management of casino floor'),
('Floor Supervisor', 'Manages Slot Attendants'),
('Slot Attendant', 'Serve as link between guests and management'),
('Human Resources', 'Keep records of employees');

INSERT INTO EMPLOYEE (
[DEP_ID], [EMP_ROLE_ID], [DATE_ASSIGNED], [EMP_FNAME], [EMP_LNAME], [EMP_HIRE_DATE], [EMP_PAY_RATE], [EMP_STREET_NUM], [EMP_STREET], [EMP_CITY], [EMP_DOB], [EMP_GENDER], [EMP_AGE]
) VALUES
(1, 1, '2023-01-01', 'John', 'Doe', '2022-12-01', 50.00, '123', 'Main St', 'Vancouver', '1966-05-25', 'M', 48), -- Director
(1, 2, '2023-01-15', 'Jane', 'Smith', '2022-12-10', 45.00, '456', 'Park Ave', 'New York', '1969-08-12', 'F', 40), -- Shift Manager
(1, 2, '2023-01-15', 'Michael', 'Brown', '2022-12-15', 45.00, '789', 'Broadway', 'New York', '1985-03-22', 'M', 38),-- Shift Manager
(1, 5, '2023-01-15', 'Emily', 'Johnson', '2022-12-20', 45.00, '111', '5th Ave', 'New York', '1990-10-15', 'F', 32), -- HR
(1, 5, '2023-01-20', 'James', 'Williams', '2022-11-30', 30.00, '222', 'Elm St', 'New York', '1988-06-07', 'M', 34), -- HR
(1, 3, '2023-01-20', 'Sara', 'Davis', '2022-11-30', 30.00, '333', 'Maple St', 'New York', '1992-11-01', 'F', 30), -- Supervisor
(1, 4, '2023-01-20', 'A', 'Martinez', '2022-11-30', 31.00, '444', 'Cedar St', 'New York', '1994-09-20', 'F', 28), -- Slot Attendant
(1, 4, '2023-01-20', 'B', 'Garcia', '2022-11-30', 25.00, '555', 'Oak St', 'New York', '1987-12-10', 'M', 35), -- Slot Attendant
(1, 4, '2023-01-25', 'Matthew', 'Lee', '2022-11-25', 20.00, '666', 'Pine St', 'New York', '1995-04-23', 'M', 27), -- Slot Attendant
(1, 4, '2023-01-25', 'Sophia', 'Walker', '2022-11-25', 22.00, '777', 'Spruce St', 'New York', '1996-02-14', 'F', 27); -- Slot Attendant

INSERT INTO CERTIFICATION (CERT_NAME, CERT_VALID_FOR) VALUES
('Basic Regulatory Training', '2023-05-07'),
('Advanced Regulatory Training', '2023-05-07'),
('Slot Attendant Training', '2024-04-01'),
('Shift Manager Training', '2024-04-01'),
('Floor Supervisor Training', '2024-04-01');

INSERT INTO ROLE_CERTIFICATION (CERT_ID, ROLE_ID) VALUES
(1, 1), -- Director of Operations
(1, 2), -- Shift Manager
(1, 3), -- Floor Supervisor
(1, 4), -- Slot Attendant
(1, 5), -- Human Resources
(2, 1), -- Director of Operations
(2, 2), -- Shift Manager
(3, 4), -- Slot Attendant
(4, 2), -- Shift Manager
(5, 3); -- Floor Supervisor

INSERT INTO JOB_HIST (EMP_ID, DATE_ASSIGNED, DEP_ID, ROLE_ID, EMP_PAY_RATE) VALUES
(1, '2022-12-01', 1, 1, 45.00),
(2, '2022-12-10', 1, 2, 17.00),
(3, '2022-12-15', 1, 2, 22.00),
(4, '2022-12-20', 1, 2, 32.00),
(5, '2022-11-30', 1, 3, 25.00),
(6, '2022-11-30', 1, 3, 11.00),
(7, '2022-11-30', 1, 3, 13.00),
(8, '2022-11-30', 1, 3, 16.00),
(9, '2022-11-25', 1, 4, 16.00),
(10, '2022-11-25', 1, 4, 16.00);

INSERT INTO SCHEDULE (EMP_ID, SCH_DATE) VALUES
(1, '2023-03-31'),
(2, '2023-03-31'),
(3, '2023-03-31'),
(4, '2023-03-31'),
(5, '2023-03-31'),
(6, '2023-03-31'),
(7, '2023-03-31'),
(8, '2023-03-31'),
(9, '2023-03-31'),
(10, '2023-03-31'),
(1, '2023-03-30'),
(2, '2023-03-30'),
(3, '2023-03-30'),
(4, '2023-03-30'),
(5, '2023-03-30'),
(6, '2023-03-30'),
(7, '2023-03-30'),
(8, '2023-03-30'),
(9, '2023-03-30'),
(10, '2023-03-30');

INSERT INTO SECTION (SEC_NAME) VALUES
('NORTH'),
('EAST'),
('SOUTH'),
('WEST'),
('HIGH LIMIT');

--Normal Shifts--
INSERT INTO SHIFT (SHIFT_START, SHIFT_END, SCH_ID, IS_BREAKER, SEC_ID) VALUES
('08:00:00', '16:00:00', 1, 0, 1),
('08:00:00', '16:00:00', 2, 0, 1),
('08:00:00', '16:00:00', 3, 0, 1),
('16:00:00', '00:00:00', 4, 0, 2),
('16:00:00', '00:00:00', 5, 0, 2),
('16:00:00', '00:00:00', 6, 0, 2),
('00:00:00', '08:00:00', 7, 0, 3),
('00:00:00', '08:00:00', 8, 0, 3),
('00:00:00', '08:00:00', 9, 0, 3),
('00:00:00', '08:00:00', 10, 0, 3),
('08:00:00', '16:00:00', 11, 0, 4),
('08:00:00', '16:00:00', 12, 0, 4),
('08:00:00', '16:00:00', 13, 0, 4),
('16:00:00', '00:00:00', 14, 0, 5),
('16:00:00', '00:00:00', 15, 0, 5),
('16:00:00', '00:00:00', 16, 0, 5),
('00:00:00', '08:00:00', 17, 0, 3),
('00:00:00', '08:00:00', 18, 0, 3),
('00:00:00', '08:00:00', 19, 0, 3),
('00:00:00', '08:00:00', 20, 0, 3);

--Breaker Shifts--
INSERT INTO SHIFT (SHIFT_START, SHIFT_END, SCH_ID, IS_BREAKER, SEC_ID) VALUES
('09:00:00', '09:15:00', 1, 1, 1),
('10:00:00', '10:15:00', 2, 1, 2),
('11:00:00', '11:15:00', 3, 1, 3),
('18:00:00', '18:15:00', 4, 1, 1),
('19:00:00', '19:15:00', 5, 1, 2),
('20:00:00', '20:15:00', 6, 1, 3),
('01:00:00', '01:15:00', 7, 1, 1),
('02:00:00', '02:15:00', 8, 1, 2),
('03:00:00', '03:15:00', 9, 1, 3),
('04:00:00', '04:15:00', 10, 1, 1),
('09:00:00', '09:15:00', 11, 1, 1),
('10:00:00', '10:15:00', 12, 1, 4),
('11:00:00', '11:15:00', 13, 1, 5),
('18:00:00', '18:15:00', 14, 1, 4),
('19:00:00', '19:15:00', 15, 1, 4),
('20:00:00', '20:15:00', 16, 1, 5),
('01:00:00', '01:15:00', 17, 1, 5),
('02:00:00', '02:15:00', 18, 1, 2),
('03:00:00', '03:15:00', 19, 1, 4),
('04:00:00', '04:15:00', 20, 1, 2);

INSERT INTO SKILL (SKILL_NAME) VALUES
('Blackjack'),
('Poker'),
('Roulette'),
('Money Handling'),
('Food Service');

INSERT INTO SEC_SKILL (SKILL_ID, SEC_ID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO TRAINING_SESSION (TS_DATE, TS_TYPE) VALUES
('2023-03-01', 'Blackjack Training'),
('2023-03-02', 'Poker Training'),
('2023-03-03', 'Roulette Training'),
('2023-03-04', 'Money Handling Training'),
('2023-03-05', 'Food Service Training'),
('2023-03-06', 'Blackjack Refresher'),
('2023-03-07', 'Poker Refresher'),
('2023-03-08', 'Roulette Refresher'),
('2023-03-09', 'Money Handling Refresher'),
('2023-03-10', 'Food Service Refresher'),
('2023-01-15', 'Basic Regulatory Training'),
('2023-01-20', 'Advanced Regulatory Training'),
('2023-01-25', 'Slot Attendant Training'),
('2023-02-01', 'Shift Manager Training'),
('2023-02-05', 'Floor Supervisor Training'),
('2023-02-10', 'Basic Regulatory Training'),
('2023-02-15', 'Advanced Regulatory Training'),
('2023-02-20', 'Slot Attendant Training'),
('2023-02-25', 'Shift Manager Training'),
('2023-03-01', 'Floor Supervisor Training');

INSERT INTO SKILL_TRAINING (TS_ID, SKILL_ID, TS_MANAGER_ID, TS_SUPERVISOR_ID) VALUES
(1, 1, 1, 5),
(2, 2, 1, 6),
(3, 3, 1, 7),
(4, 4, 1, 8),
(5, 5, 1, 9),
(6, 1, 1, 5),
(7, 2, 1, 6),
(8, 3, 1, 7),
(9, 4, 1, 8),
(10, 5, 1, 9);

INSERT INTO EMPLOYEE_SKILL_TRAINING (TS_ID, EMP_ID) VALUES
(1, 9),
(1, 10),
(2, 9),
(2, 10),
(3, 9),
(3, 10),
(4, 9),
(4, 10),
(5, 9),
(5, 10);

INSERT INTO REGULATORY_TRAINING (TS_ID, CERT_ID) VALUES
(11, 1),
(12, 2),
(13, 3),
(14, 4),
(15, 5),
(16, 1),
(17, 2),
(18, 3),
(19, 4),
(20, 5);

INSERT INTO EMPLOYEE_REGULATORY_TRAINING (TS_ID, EMP_ID, EXPIRATION_DATE) VALUES
(11, 1, '2023-05-07'),
(12, 1, '2023-05-07'),
(13, 6, '2023-04-01'),
(14, 2, '2024-04-01'),
(15, 3, '2024-04-01'),
(11, 2, '2024-04-01'),
(12, 2, '2025-04-01'),
(11, 3, '2024-04-01'),
(12, 3, '2025-04-01'),
(13, 9, '2024-04-01');

INSERT INTO WRITTEN_WARNING (
WW_DATE_ISSUED,
WW_MANAGER_ID,
WW_COMPOUNDING_UNTIL,
WW_LEVEL,
WW_DESC,
EMP_ID
) VALUES
('2023-01-10', 2, '2024-01-10', 1, 'Late for work on multiple occasions.', 9),
('2023-02-15', 2, '2024-02-15', 1, 'Poor customer service to a guest.', 10),
('2023-03-05', 2, '2024-03-05', 1, 'Money float discrepancy.', 7),
('2023-03-20', 2, '2024-03-20', 1, 'Inappropriate conduct towards coworkers.', 8),
('2023-04-30', 3, '2024-04-30', 1, 'Violated dress code policy.', 6),
('2023-05-25', 2, '2024-05-25', 2, 'Late for work again after receiving WW I.', 9),
('2023-07-18', 3, '2024-07-18', 1, 'Failure to follow proper cash handling procedures.', 5),
('2023-08-12', 3, '2024-08-12', 2, 'Recieved two customer compaints in one shift regarding behaviour', 7),
('2023-10-01', 2, '2024-10-01', 1, 'Neglected to follow safety protocol.', 4),
('2023-11-20', 3, '2024-11-20', 1, 'Did not show up for scheduled shift.', 6),
('2023-12-20', 2, '2024-12-20', 0, 'Failed to complete mandatory training on time.', 9),
('2024-01-15', 3, '2025-01-15', 0, 'Did not follow break schedule.', 7),
('2024-01-30', 2, '2025-01-30', 1, 'Money float discrepancy.', 6),
('2024-02-18', 2, '2025-02-18', 0, 'Did not complete assigned tasks.', 4),
('2024-03-10', 3, '2025-03-10', 0, 'Improper use of company equipment.', 10),
('2024-04-05', 3, '2025-04-05', 2, 'Late for work again after receiving WW I.', 8),
('2024-05-20', 2, '2025-05-20', 1, 'Inappropriate language towards guest.', 5),
('2024-06-15', 2, '2025-06-15', 0, 'Unauthorized use of company resources.', 3),
('2024-07-07', 3, '2025-07-07', 1, 'Poor customer service to a guest.', 2),
('2024-08-25', 3, '2025-08-25', 0, 'Failed to report a safety issue.', 1)

INSERT INTO LEAVE (
EMP_ID,
LEAVE_START_DATE,
LEAVE_REASON,
LEAVE_END_DATE,
LEAVE_COMMENTS
) VALUES

(1, '2023-02-01', 'Vacation', '2023-02-08', 'Family trip to Hawaii.'),
(6, '2023-03-10', 'Sick', '2023-03-12', 'Caught the flu.'),
(6, '2023-04-20', 'Vacation', '2023-04-25', 'Attending a wedding in Mexico.'),
(4, '2023-06-01', 'Maternity leave', '2023-12-01', 'Welcoming a new baby.'),
(6, '2023-07-15', 'Personal leave', '2023-07-17', 'Attending a funeral.'),
(7, '2023-10-10', 'Sick', '2023-10-12', 'Recovering from surgery.'),
(8, '2023-11-01', 'Paternity leave', '2023-11-30', 'Welcoming a new baby.'),
(9, '2023-12-20', 'Vacation', '2023-12-27', 'Christmas vacation with family.'),
(10, '2024-01-10', 'Vacation', '2024-01-17', 'Ski trip in the mountains.');

INSERT INTO INVENTORY (
INV_NAME,
INV_PRICE,
INV_QTY,
INV_EXP
) VALUES
('Chips', 0.25, 10000, NULL),
('Playing Cards', 1.50, 500, '2024-12-31'),
('Dice', 0.75, 1000, NULL),
('Slot Machine Tickets', 0.05, 20000, '2024-12-31'),
('Drink Cups', 0.10, 3000, NULL),
('Napkins', 0.01, 5000, NULL),
('Uniforms', 30.00, 100, NULL),
('Cleaning Supplies', 5.00, 200, '2024-12-31'),
('Paper Towels', 0.02, 2000, NULL),
('Snacks', 1.00, 1500, '2024-06-30');

INSERT INTO SHIFT_INV (
SHIFT_ID,
INV_ID,
SHIFT_INV_QTY
) VALUES
(1, 1, 50),
(1, 2, 5),
(1, 3, 10),
(1, 4, 100),
(1, 5, 20),
(1, 6, 25),
(2, 1, 75),
(2, 2, 7),
(2, 3, 12),
(2, 4, 120);

INSERT INTO ACHIEVEMENT (EMP_ID, ACH_TITLE, ACH_DESC, SUPERVISOR_ID, ACH_DATE)
VALUES 
(7, 'Employee of the Month', 'Outstanding performance and dedication during the month of January', 6, '2023-01-01'),
(8, 'Amazing Customer Service', 'Recieved multiple accolades in one shift from customers', 6, '2023-03-31'),
(9, 'Perfect Attendance', 'Completed an entire year without any absences', 6, '2022-12-31'),
(7, 'Great Teamwork', 'Significant contribution to the success of the team during a stressful shift', 6, '2023-02-28');DROP PROCEDURE IF EXISTS EMP_STATS;
