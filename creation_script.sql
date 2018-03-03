DROP TABLE VEHICLE CASCADE CONSTRAINTS;
DROP TABLE PEOPLE CASCADE CONSTRAINTS;
DROP TABLE DRIVER CASCADE CONSTRAINTS;
DROP TABLE DRIVES_VEHICLE CASCADE CONSTRAINTS;
DROP TABLE RADAR CASCADE CONSTRAINTS;
DROP TABLE ROAD CASCADE CONSTRAINTS;
DROP TABLE SECTION CASCADE CONSTRAINTS;
DROP TABLE OBSERVATION CASCADE CONSTRAINTS;
DROP TABLE TICKET CASCADE CONSTRAINTS;
DROP TABLE ALLEGATION CASCADE CONSTRAINTS;

CREATE TABLE PEOPLE(
  Name VARCHAR2(35) NOT NULL,
  Surname_1 VARCHAR2(15) NOT NULL,
  Surname_2 VARCHAR2(15),
  Address VARCHAR2(42) NOT NULL,
  Town VARCHAR2(35) NOT NULL, /*PONERLO EN EL REPORT*/
  Dni VARCHAR2(9),
  Mobile NUMBER(9),
  Email VARCHAR2(50),
  Birth DATE NOT NULL,
  CONSTRAINT PEOPLE_PK PRIMARY KEY (Dni),
  CONSTRAINT PEOPLE_UK UNIQUE (Email, Mobile),
  CONSTRAINT PEOPLE_EMAIL CHECK (Email LIKE '%@%.%')
);

CREATE TABLE DRIVER(
  DriverDni VARCHAR2(9),
  type VARCHAR2(3) NOT NULL,
  ldate DATE NOT NULL,
  age NUMBER(2) NOT NULL,
  CONSTRAINT DRIVER_PK PRIMARY KEY (DriverDni),
  CONSTRAINT MIN_DRIVER_AGE CHECK (age >= 18),
  CONSTRAINT MAX_DRIVER_AGE CHECK (age <= 120),
  CONSTRAINT DRIVER_FK_PEOPLE FOREIGN KEY (DriverDni) REFERENCES PEOPLE ON DELETE CASCADE
);

CREATE TABLE VEHICLE(
  nPlate VARCHAR2(7),
  VIN VARCHAR2(17) NOT NULL,
  registration DATE NOT NULL,
  brand VARCHAR2(12) NOT NULL,
  model VARCHAR2(12) NOT NULL,
  color VARCHAR2(25) NOT NULL,
  itv DATE NOT NULL,
  Dni VARCHAR2(9) NOT NULL, /*1:n relation between Owner:Vehicle*/
  CONSTRAINT VEHICLE_PK PRIMARY KEY (nPlate),
  CONSTRAINT VEHICLE_UK UNIQUE (registration,VIN),
  CONSTRAINT VEHICLE_FK_PEOPLE FOREIGN KEY (Dni) REFERENCES PEOPLE
);

CREATE TABLE DRIVES_VEHICLE( /*n:n relation between Driver:Vehicle*/
  DriverDni VARCHAR2(9),
  nPlate VARCHAR2(7),
  CONSTRAINT DRIVES_VEHICLE_PK PRIMARY KEY (DriverDni,nPlate),
  CONSTRAINT DRIVES_VEHICLE_FK_DRIVER FOREIGN KEY (DriverDni) REFERENCES DRIVER ON DELETE CASCADE,
  CONSTRAINT DRIVES_VEHICLE_FK_VEHICLE FOREIGN KEY (nPlate) REFERENCES VEHICLE ON DELETE CASCADE
);

CREATE TABLE ROAD(
  rname VARCHAR2(15),
  speedlimit NUMBER(5,2) NOT NULL,
  CONSTRAINT ROAD_PK PRIMARY KEY (rname),
  CONSTRAINT MAX_SPEED CHECK (speedlimit <= 120)
);

CREATE TABLE SECTION(
  sectionID NUMBER(5),
  durationKm NUMBER(1) NOT NULL,
  speedlimitSection NUMBER(5,2) NOT NULL,
  /*
    1:n relation between Road and Section
  */
  rname VARCHAR2(15),
  CONSTRAINT SECTION_PK PRIMARY KEY (rname,sectionID),
  CONSTRAINT SECTION_FK_RADAR FOREIGN KEY (rname) REFERENCES ROAD ON DELETE CASCADE,
  CONSTRAINT MAX_SPEED_SECTION CHECK (speedlimitSection <= 120),
  CONSTRAINT SECTION_DURATION CHECK (durationKm <= 5)
);

CREATE TABLE RADAR(
  rname VARCHAR2(5), /*1:n relation between Road:Radars*/
  mileagepoint NUMBER(5,2),
  direction VARCHAR2(5),
  speedlimit NUMBER(3),
  CONSTRAINT RADAR_PK PRIMARY KEY (mileagepoint,rname,direction),
  CONSTRAINT RADARDIRECTION_TYPE CHECK (direction IN ('ASC', 'DES')),
  CONSTRAINT MAX_SPEED_RADAR CHECK (speedlimit<= 120),
  CONSTRAINT RADAR_FK_ROAD FOREIGN KEY (rname) REFERENCES ROAD ON DELETE CASCADE
);

CREATE TABLE OBSERVATION(
  odate DATE,
  otime DATE,
  speed NUMBER(5,2) NOT NULL,
  /*
	1:n relation between Radars:Observation
  */
  rname VARCHAR2(5),
  mileagepoint NUMBER(5,2),
  direction VARCHAR2(5),
  /*
	1:n relation between Vehicle:Observation
  */
  nPlate VARCHAR2(7),
  CONSTRAINT OBSERVATION_PK PRIMARY KEY (nPlate,mileagepoint,rname,direction,otime,odate),
  CONSTRAINT OBSERVATION_FK_VEHICLE FOREIGN KEY (nPlate) REFERENCES VEHICLE ON DELETE CASCADE,
  CONSTRAINT MAX_SPEED_OBS CHECK (speed <= 500),
  CONSTRAINT OBSERVATION_FK_RADAR FOREIGN KEY (mileagepoint,rname,direction) REFERENCES RADAR ON DELETE CASCADE
);

CREATE TABLE TICKET(
  /*
    In general: 1:n relation between Observation:Ticket
  */
  odate DATE,
  otime DATE,
  /*
	1:n relation between Radars:Ticket
  */
  rname VARCHAR2(5),
  mileagepoint NUMBER(5,2),
  direction VARCHAR2(5),
  /*
	1:n relation between Vehicle:Ticket
  */
  nPlate VARCHAR2(7),
  Dni VARCHAR2(9), /*1:n relation between Owner:Ticket*/
  amount NUMBER(5,2) NOT NULL,
  emission_date DATE NOT NULL,
  due_date DATE NOT NULL,
  payment VARCHAR2(14) NOT NULL,
  sanctionState VARCHAR2(10) NOT NULL,
  CONSTRAINT TICKET_PK PRIMARY KEY (nPlate,mileagepoint,rname,direction,otime,odate,Dni),
  CONSTRAINT TICKET_FK_PEOPLE FOREIGN KEY (Dni) REFERENCES PEOPLE ON DELETE CASCADE,
  CONSTRAINT TICKET_FK_OBSERVATION FOREIGN KEY (nPlate,mileagepoint,rname,direction,otime,odate) REFERENCES OBSERVATION ON DELETE CASCADE,
  CONSTRAINT TICKET_PAYMENT CHECK (payment IN ('credit card','bank transfer', 'cash')),
  CONSTRAINT TICKET_SANCTIONDATE CHECK (sanctionState IN ('Registered', 'Issued', 'Received', 'Fulflled', 'Non-paid'))
);

CREATE TABLE ALLEGATION(
  registration_date DATE NOT NULL,
  status VARCHAR2(15) NOT NULL,
  execution_date DATE,
  /*
	1:n relation between Observation:Allegation
  */
  odate DATE,
  otime DATE,
  rname VARCHAR2(5),
  mileagepoint NUMBER(5,2),
  direction VARCHAR2(5),
  nPlate VARCHAR2(7),
  Dni VARCHAR2(9), /*1:n relation between Owner:Allegation*/
  CONSTRAINT ALLEGATION_PK PRIMARY KEY (nPlate,mileagepoint,rname,direction,otime,odate,Dni,registration_date),
  CONSTRAINT ALLEGATION_FK_TICKET FOREIGN KEY (nPlate,mileagepoint,rname,direction,otime,odate,Dni) REFERENCES TICKET ON DELETE CASCADE,
  CONSTRAINT ALLEGATION_STATUS CHECK (status IN ('approved','rejected', 'under study'))
);
