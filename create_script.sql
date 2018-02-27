DROP TABLE VEHICLE CASCADE CONSTRAINTS;
DROP TABLE OWNER CASCADE CONSTRAINTS;
DROP TABLE DRIVER CASCADE CONSTRAINTS;
DROP TABLE LICENSE CASCADE CONSTRAINTS;
DROP TABLE DRIVES_VEHICLE CASCADE CONSTRAINTS;
DROP TABLE RADARS CASCADE CONSTRAINTS;
DROP TABLE ROAD CASCADE CONSTRAINTS;
DROP TABLE OBSERVATION CASCADE CONSTRAINTS;
DROP TABLE TICKET CASCADE CONSTRAINTS;
DROP TABLE ALLEGATION CASCADE CONSTRAINTS;

CREATE TABLE OWNER(
  OwnerName VARCHAR2(35) NOT NULL,
  OwnerSurname_1 VARCHAR2(15) NOT NULL,
  OwnerSurname_2 VARCHAR2(15),
  OwnerAddress VARCHAR2(42) NOT NULL,
  OwnerDni VARCHAR2(9) NOT NULL,
  OwnerMobile NUMBER(9),
  OwnerEmail VARCHAR2(50),
  OwnerBirth DATE NOT NULL,
  CONSTRAINT OWNER_PK PRIMARY KEY (OwnerDni)
);

CREATE TABLE DRIVER(
  DriverName VARCHAR2(35) NOT NULL,
  DriverSurname_1 VARCHAR2(15) NOT NULL,
  DriverSurname_2 VARCHAR2(15) NOT NULL,
  DriverAddress VARCHAR2(42) NOT NULL,
  DriverDni VARCHAR2(9) NOT NULL,
  DriverMobile NUMBER(9),
  DriverEmail VARCHAR2(50),
  DriverBirth DATE NOT NULL,
  ldate DATE NOT NULL, /*1:1 relation between Driver:License*/
  CONSTRAINT DRIVER_PK PRIMARY KEY (DriverDni)
);

CREATE TABLE VEHICLE(
  nPlate VARCHAR2(7) NOT NULL,
  VIN VARCHAR2(17) NOT NULL,
  registration DATE NOT NULL,
  brand VARCHAR2(12) NOT NULL,
  model VARCHAR2(12) NOT NULL,
  color VARCHAR2(25) NOT NULL,
  itv DATE NOT NULL,
  power VARCHAR2(6) NOT NULL,
  OwnerDni VARCHAR2(9) NOT NULL, /*1:n relation between Owner:Vehicle*/
  CONSTRAINT VEHICLE_PK PRIMARY KEY (nPlate,VIN,registration),
  CONSTRAINT VEHICLE_FK_OWNER FOREIGN KEY (OwnerDni) REFERENCES OWNER ON DELETE CASCADE
);

CREATE TABLE LICENSE(
  type VARCHAR2(15) NOT NULL,
  ldate DATE NOT NULL,
  age NUMBER(2) NOT NULL,
  DriverDni VARCHAR2(9) NOT NULL, /*1:1 relation between Driver:License*/
  CONSTRAINT LICENSE_PK PRIMARY KEY (ldate,DriverDni),
  CONSTRAINT LICENSE_FK_DRIVER FOREIGN KEY (DriverDni) REFERENCES DRIVER ON DELETE CASCADE,
  CONSTRAINT LICENSE_AGE CHECK (age >= 18)
);

CREATE TABLE DRIVES_VEHICLE( /*n:n relation between Driver:Vehicle*/
  DriverDni VARCHAR2(35) NOT NULL,
  registration DATE NOT NULL,
  nPlate VARCHAR2(7) NOT NULL,
  VIN VARCHAR2(17) NOT NULL,
  CONSTRAINT DRIVES_VEHICLE PRIMARY KEY (DriverDni,registration,nPlate,VIN),
  CONSTRAINT DRIVES_VEHICLE_FK_DRIVER FOREIGN KEY (DriverDni) REFERENCES DRIVER ON DELETE CASCADE,
  CONSTRAINT DRIVES_VEHICLE_FK_VEHICLE FOREIGN KEY (nPlate,VIN,registration) REFERENCES VEHICLE ON DELETE CASCADE
);

CREATE TABLE ROAD(
  rname VARCHAR2(15) NOT NULL,
  speedlimit NUMBER(5,2) NOT NULL,
  CONSTRAINT ROAD_PK PRIMARY KEY (rname)
);

CREATE TABLE RADARS(
  rname VARCHAR2(5) NOT NULL, /*1:n relation between Road:Radars*/
  mileagepoint NUMBER(5,2) NOT NULL,
  direction VARCHAR2(5) NOT NULL,
  CONSTRAINT RADARS_PK PRIMARY KEY (mileagepoint,rname,direction),
  CONSTRAINT RADARS_FK_ROAD FOREIGN KEY (rname) REFERENCES ROAD ON DELETE CASCADE
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
  registration DATE NOT NULL,
  nPlate VARCHAR2(7) NOT NULL,
  VIN VARCHAR2(17) NOT NULL,
  CONSTRAINT OBSERVATION_PK PRIMARY KEY (registration,nPlate,VIN,mileagepoint,rname,direction,otime,odate),
  CONSTRAINT OBSERVATION_FK_VEHICLE FOREIGN KEY (nPlate,VIN,registration) REFERENCES VEHICLE ON DELETE CASCADE,
  CONSTRAINT OBSERVATION_FK_RADARS FOREIGN KEY (mileagepoint,rname,direction) REFERENCES RADARS ON DELETE CASCADE
);

CREATE TABLE TICKET(
  odate DATE NOT NULL,
  otime NUMBER(3) NOT NULL, /*Hay que ponerlo en formato TIME*/
  /*
	1:n relation between Radars:Ticket
  */
  rname VARCHAR2(5) NOT NULL,
  mileagepoint NUMBER(5,2) NOT NULL,
  direction VARCHAR2(5) NOT NULL,
  /*
	1:n relation between Vehicle:Ticket (PREGUNTAR A TONI E ISMA)
  */
  registration DATE NOT NULL,
  nPlate VARCHAR2(7) NOT NULL,
  VIN VARCHAR2(17) NOT NULL,
  OwnerDni VARCHAR2(9) NOT NULL, /*1:n relation between Owner:Ticket ???????????????????*/
  amount NUMBER(5,2) NOT NULL,
  emission_date DATE NOT NULL,
  due_date DATE NOT NULL,
  payment VARCHAR2(14) NOT NULL,
  penalty NUMBER(5,2) NOT NULL,
  sanctionDate DATE NOT NULL,
  CONSTRAINT TICKET_PK PRIMARY KEY (registration,nPlate,VIN,mileagepoint,rname,direction,otime,odate,OwnerDni),
  CONSTRAINT TICKET_FK_OWNER FOREIGN KEY (OwnerDni) REFERENCES OWNER ON DELETE CASCADE,
  CONSTRAINT TICKET_FK_OBSERVATION FOREIGN KEY (registration,nPlate,VIN,mileagepoint,rname,direction,otime,odate) REFERENCES OBSERVATION ON DELETE CASCADE,
  CONSTRAINT TICKET_PAYMENT CHECK (payment IN ('credit card','bank transfer', 'cash'))
);

CREATE TABLE ALLEGATION(
  registration_date DATE NOT NULL,
  status VARCHAR2(15),
  execution_date DATE,
  /*
	1:n relation between Observation:Allegation
  */  
  odate DATE NOT NULL,
  otime NUMBER(3) NOT NULL, /*Hay que ponerlo en formato TIME*/
  rname VARCHAR2(5) NOT NULL,
  mileagepoint NUMBER(5,2) NOT NULL,
  direction VARCHAR2(5) NOT NULL,
  registration DATE NOT NULL,
  nPlate VARCHAR2(7) NOT NULL,
  VIN VARCHAR2(17) NOT NULL,
  OwnerDni VARCHAR2(9) NOT NULL, /*1:n relation between Owner:Allegation*/
  CONSTRAINT ALLEGATION_PK PRIMARY KEY (registration,nPlate,VIN,mileagepoint,rname,direction,otime,odate,OwnerDni,registration_date),
  CONSTRAINT ALLEGATION_FK_TICKET FOREIGN KEY (registration,nPlate,VIN,mileagepoint,rname,direction,otime,odate,OwnerDni) REFERENCES TICKET ON DELETE CASCADE
);