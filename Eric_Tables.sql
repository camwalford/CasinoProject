CREATE TABLE SCHEDULE (
	SCH_ID INTEGER,
	EMP_ID INTEGER,
	SCH_DATE TIME,
	PRIMARY KEY(SCH_ID),
	FOREIGN KEY(EMP_ID) REFERENCES EMPLOYEE ON UPDATE CASCADE
);

CREATE TABLE SHIFT (
	SHIFT_ID INTEGER,
	SHIFT_START TIME,
	SHIFT_END TIME,
	SCH_ID INTEGER
	PRIMARY KEY(SHIFT_ID),
	FOREIGN KEY(SCH_ID) REFERENCES SCHEDULE ON UPDATE CASCADE
);

CREATE TABLE SECTION (
	SEC_ID INTEGER,
	SEC_NAME VARCHAR(30),
	PRIMARY KEY(SEC_ID)
);

CREATE TABLE SKILL (
	SKILL_ID INTEGER,
	SKILL_NAME VARCHAR(30)
	PRIMARY KEY(SKILL_ID)
);

CREATE TABLE SEC_SKILL (
	SKILL_ID INTEGER,
	SEC_ID INTEGER,
	PRIMARY KEY(SKILL_ID, SEC_ID),
	FOREIGN KEY(SKILL_ID) REFERENCES SKILL ON UPDATE CASCADE,
	FOREIGN KEY(SEC_ID) REFERENCES SECTION ON UPDATE CASCADE
);

CREATE TABLE WRITTEN_WARNING (
	WW_ID INTEGER,
	WW_DATE_ISSUED TIME,
	WW_MANAGER_ID INTEGER,
	WW_COMPOUNDING_UNTIL TIME,
	WW_LEVEL INTEGER,
	WW_COMMENTS VARCHAR(300),
	EMP_ID INTEGER,
	PRIMARY KEY(WW_ID),
	-- FOREIGN KEY(WW_MANAGER_ID) REFERENCES ?
	FOREIGN KEY(EMP_ID) REFERENCES EMPLOYEE ON UPDATE CASCADE
);

CREATE TABLE LEAVE (
	LEAVE_ID INTEGER,
	EMP_ID INTEGER,
	LEAVE_START_DATE DATE,
	LEAVE_REASON VARCHAR(100),
	LEAVE_END_DATE DATE,
	LEAVE_COMMENTS VARCHAR(300),
	PRIMARY KEY(LEAVE_ID, EMP_ID),
	FOREIGN KEY(EMP_ID) REFERENCES EMPLOYEE ON UPDATE CASCADE
);

CREATE TABLE INVENTORY (
	INV_ID INTEGER,
	INV_NAME VARCHAR(50),
	INV_PRICE NUMERIC(5,2),
	INV_QTY CHAR(3),
	INV_EXP DATE,
	PRIMARY KEY(INV_ID)
);

CREATE TABLE SHIFT_INV (
	SHIFT_ID INTEGER,
	INV_ID INTEGER,
	SHIFT_INV_QTY INTEGER,
	PRIMARY KEY(SHIFT_ID, INV_ID),
	FOREIGN KEY(SHIFT_ID) REFERENCES SHIFT ON UPDATE CASCADE,
	FOREIGN KEY(INV_ID) REFERENCES INVENTORY ON UPDATE CASCADE
);
