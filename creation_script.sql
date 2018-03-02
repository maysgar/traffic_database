DROP TABLE VEHICLE CASCADE CONSTRAINTS;
DROP TABLE OWNER CASCADE CONSTRAINTS;
DROP TABLE DRIVER CASCADE CONSTRAINTS;
DROP TABLE DRIVES_VEHICLE CASCADE CONSTRAINTS;
DROP TABLE RADAR CASCADE CONSTRAINTS;
DROP TABLE ROAD CASCADE CONSTRAINTS;
DROP TABLE SECTION CASCADE CONSTRAINTS;
DROP TABLE OBSERVATION CASCADE CONSTRAINTS;
DROP TABLE TICKET CASCADE CONSTRAINTS;
DROP TABLE ALLEGATION CASCADE CONSTRAINTS;

CREATE TABLE OWNER(
  Name VARCHAR2(35) NOT NULL,
  Surname_1 VARCHAR2(15) NOT NULL,
  Surname_2 VARCHAR2(15),
  Address VARCHAR2(42) NOT NULL,
  Dni VARCHAR2(9) NOT NULL,
  Mobile NUMBER(9),
  Email VARCHAR2(50),
  Birth DATE NOT NULL,
  CONSTRAINT OWNER_PK PRIMARY KEY (Dni),
  CONSTRAINT OWNER_UK UNIQUE (Email, Mobile),
  CONSTRAINT OWNER_EMAIL CHECK (Email LIKE '%@%.%')
);

CREATE TABLE DRIVER(
  Dni VARCHAR2(9) NOT NULL,
  type VARCHAR2(15) NOT NULL,
  ldate DATE NOT NULL,
  age NUMBER(2) NOT NULL,
  CONSTRAINT DRIVER_PK PRIMARY KEY (Dni),
  CONSTRAINT DRIVER_AGE CHECK (age >= 18),
  CONSTRAINT DRIVER_FK FOREIGN KEY (Dni) REFERENCES OWNER
);

CREATE TABLE VEHICLE(
  nPlate VARCHAR2(7) NOT NULL,
  VIN VARCHAR2(17) NOT NULL,
  registration DATE NOT NULL,
  brand VARCHAR2(12) NOT NULL,
  model VARCHAR2(12) NOT NULL,
  color VARCHAR2(25) NOT NULL,
  itv DATE NOT NULL,
  Dni VARCHAR2(9) NOT NULL, /*1:n relation between Owner:Vehicle*/
  CONSTRAINT VEHICLE_PK PRIMARY KEY (nPlate),
  CONSTRAINT VEHICLE_UK UNIQUE (registration,VIN),
  CONSTRAINT VEHICLE_FK_OWNER FOREIGN KEY (Dni) REFERENCES OWNER
);

CREATE TABLE DRIVES_VEHICLE( /*n:n relation between Driver:Vehicle*/
  Dni VARCHAR2(35) NOT NULL,
  nPlate VARCHAR2(7) NOT NULL,
  CONSTRAINT DRIVES_VEHICLE_PK PRIMARY KEY (Dni,nPlate),
  CONSTRAINT DRIVES_VEHICLE_FK_DRIVER FOREIGN KEY (Dni) REFERENCES DRIVER ON DELETE CASCADE,
  CONSTRAINT DRIVES_VEHICLE_FK_VEHICLE FOREIGN KEY (nPlate) REFERENCES VEHICLE ON DELETE CASCADE
);

CREATE TABLE ROAD(
  rname VARCHAR2(15) NOT NULL,
  speedlimit NUMBER(5,2) NOT NULL,
  CONSTRAINT ROAD_PK PRIMARY KEY (rname)
);

CREATE TABLE SECTION(
  sectionID NUMBER(5) NOT NULL,
  durationKm NUMBER(1) NOT NULL,
  speedlimitSection NUMBER(5,2) NOT NULL,
  /*
    1:n relation between Road and Section
  */
  rname VARCHAR2(15) NOT NULL,
  CONSTRAINT SECTION_PK PRIMARY KEY (rname,sectionID),
  CONSTRAINT SECTION_FK_RADAR FOREIGN KEY (rname) REFERENCES ROAD ON DELETE CASCADE,
  CONSTRAINT SECTION_DURATION CHECK (durationKm <= 5)
);

CREATE TABLE RADAR(
  rname VARCHAR2(5) NOT NULL, /*1:n relation between Road:Radars*/
  mileagepoint NUMBER(5,2) NOT NULL,
  direction VARCHAR2(5) NOT NULL,
  CONSTRAINT RADAR_PK PRIMARY KEY (mileagepoint,rname,direction),
  CONSTRAINT RADAR_FK_ROAD FOREIGN KEY (rname) REFERENCES ROAD ON DELETE CASCADE
);

CREATE TABLE OBSERVATION(
  odate DATE NOT NULL,
  otime NUMBER(3) NOT NULL, /*Hay que ponerlo en formato TIME*/
  speed NUMBER(5,2) NOT NULL,
  /*
	1:n relation between Radars:Observation
  */
  rname VARCHAR2(5) NOT NULL,
  mileagepoint NUMBER(5,2) NOT NULL,
  direction VARCHAR2(5) NOT NULL,
  /*
	1:n relation between Vehicle:Observation
  */
  nPlate VARCHAR2(7) NOT NULL,
  CONSTRAINT OBSERVATION_PK PRIMARY KEY (nPlate,mileagepoint,rname,direction,otime,odate),
  CONSTRAINT OBSERVATION_FK_VEHICLE FOREIGN KEY (nPlate) REFERENCES VEHICLE ON DELETE CASCADE,
  CONSTRAINT OBSERVATION_FK_RADAR FOREIGN KEY (mileagepoint,rname,direction) REFERENCES RADAR ON DELETE CASCADE
);

CREATE TABLE TICKET(
  /*
    In general: 1:n relation between Observation:Ticket
  */
  odate DATE NOT NULL,
  otime NUMBER(3) NOT NULL, /*Hay que ponerlo en formato TIME*/
  /*
	1:n relation between Radars:Ticket
  */
  rname VARCHAR2(5) NOT NULL,
  mileagepoint NUMBER(5,2) NOT NULL,
  direction VARCHAR2(5) NOT NULL,
  /*
	1:n relation between Vehicle:Ticket
  */
  nPlate VARCHAR2(7) NOT NULL,
  Dni VARCHAR2(9) NOT NULL, /*1:n relation between Owner:Ticket*/
  amount NUMBER(5,2) NOT NULL,
  emission_date DATE NOT NULL,
  due_date DATE NOT NULL,
  payment VARCHAR2(14) NOT NULL,
  penalty NUMBER(5,2) NOT NULL,
  sanctionDate DATE NOT NULL,
  CONSTRAINT TICKET_PK PRIMARY KEY (nPlate,mileagepoint,rname,direction,otime,odate,Dni),
  CONSTRAINT TICKET_FK_OWNER FOREIGN KEY (Dni) REFERENCES OWNER ON DELETE CASCADE,
  CONSTRAINT TICKET_FK_OBSERVATION FOREIGN KEY (nPlate,VIN,mileagepoint,rname,direction,otime,odate) REFERENCES OBSERVATION ON DELETE CASCADE,
  CONSTRAINT TICKET_PAYMENT CHECK (payment IN ('credit card','bank transfer', 'cash')),
  CONSTRAINT TICKET_SANCTIONDATE CHECK (sanctionDate IN ('Registered', 'Issued', 'Received', 'Fulflled', 'Non-paid'))
);

CREATE TABLE ALLEGATION(
  registration_date DATE NOT NULL,
  status VARCHAR2(15) NOT NULL,
  execution_date DATE,
  /*
	1:n relation between Observation:Allegation
  */
  odate DATE NOT NULL,
  otime NUMBER(3) NOT NULL, /*Hay que ponerlo en formato TIME*/
  rname VARCHAR2(5) NOT NULL,
  mileagepoint NUMBER(5,2) NOT NULL,
  direction VARCHAR2(5) NOT NULL,
  nPlate VARCHAR2(7) NOT NULL,
  Dni VARCHAR2(9) NOT NULL, /*1:n relation between Owner:Allegation*/
  CONSTRAINT ALLEGATION_PK PRIMARY KEY (nPlate,mileagepoint,rname,direction,otime,odate,Dni,registration_date),
  CONSTRAINT ALLEGATION_FK_TICKET FOREIGN KEY (nPlate,mileagepoint,rname,direction,otime,odate,Dni) REFERENCES TICKET ON DELETE CASCADE,
  CONSTRAINT ALLEGATION_STATUS CHECK (status IN ('approved','rejected', 'under study'))
);
