-- ----------------------------------------------------
-- ----------------------------------------------------
-- -- TABLES CREATION SCRIPT -- ASSIGNMENT SOLUTION ---
-- ----------------------------------------------------
-- ----------------------------------------------------
-- -- Course: File Structures and DataBases -----------
-- ----------------------------------------------------
-- ------ Carlos III University of Madrid -------------
-- ----------------------------------------------------
-- ----------------------------------------------------
-- -- Part I: Destroy existent tables -----------------
-- ----------------------------------------------------

DROP TABLE CATALOG CASCADE CONSTRAINTS;
DROP TABLE PERSONS CASCADE CONSTRAINTS;
DROP TABLE DRIVERS CASCADE CONSTRAINTS;
DROP TABLE ROADS CASCADE CONSTRAINTS;
DROP TABLE RADARS CASCADE CONSTRAINTS;
DROP TABLE VEHICLES CASCADE CONSTRAINTS;
DROP TABLE ASSIGNMENTS CASCADE CONSTRAINTS;
DROP TABLE OBSERVATIONS CASCADE CONSTRAINTS;
DROP TABLE TICKETS CASCADE CONSTRAINTS;
DROP TABLE ALLEGATIONS CASCADE CONSTRAINTS;

-- ----------------------------------------------------
-- -- Part II: Create all tables ----------------------
-- ----------------------------------------------------

CREATE TABLE CATALOG (
   make     VARCHAR2(10),
   model    VARCHAR2(12),
   power    NUMBER(6) NOT NULL,
   CONSTRAINT PK_CATALOG PRIMARY KEY (make, model)
);

CREATE TABLE PERSONS(
   DNI 	     VARCHAR2(9),
   name      VARCHAR2(35) NOT NULL,
   surn_1    VARCHAR2(15) NOT NULL,
   surn_2    VARCHAR2(15),
   address   VARCHAR2(42) NOT NULL,
   town      VARCHAR2(35) NOT NULL,
   mobile    NUMBER(9),
   email     VARCHAR2(50),
   birthdate DATE NOT NULL,
   CONSTRAINT PK_PERSONS PRIMARY KEY (DNI)
);

CREATE TABLE DRIVERS(
   DNI       VARCHAR2(9),
   lic_date  DATE NOT NULL,
   lic_type  VARCHAR2(3) NOT NULL,
   CONSTRAINT PK_DRIVERS PRIMARY KEY (DNI),
   CONSTRAINT FK_DRIVERS FOREIGN KEY (DNI) REFERENCES PERSONS (DNI) ON DELETE CASCADE
);

CREATE TABLE ROADS(
   name	        VARCHAR2(5),
   speed_limit	NUMBER(3,0) NOT NULL,
   CONSTRAINT PK_ROADS PRIMARY KEY (name),
   CONSTRAINT CK_ROADS CHECK (speed_limit<150)
);

CREATE TABLE RADARS(
   road	      VARCHAR2(5) NOT NULL,
   Km_point   NUMBER(3,0) NOT NULL,
   direction  VARCHAR2(3) NOT NULL,
   speedlim   NUMBER(3,0) NOT NULL,
   CONSTRAINT PK_RADARS PRIMARY KEY(road, Km_point, direction),
   CONSTRAINT FK_RADARS FOREIGN KEY (road) REFERENCES ROADS ON DELETE CASCADE
);

CREATE TABLE VEHICLES(
   nPlate     VARCHAR2(7),
   vin        VARCHAR2(17) NOT NULL,
   make       VARCHAR2(10) NOT NULL,
   model      VARCHAR2(12) NOT NULL,
   color      VARCHAR2(25) NOT NULL,
   reg_date   DATE NOT NULL,
   MOT_date   DATE NOT NULL,
   reg_driver VARCHAR2(9) NOT NULL,
   owner      VARCHAR2(9) NOT NULL,
   CONSTRAINT PK_VEHICLES PRIMARY KEY (nPlate),
   CONSTRAINT UK_VEHICLES UNIQUE (vin),
   CONSTRAINT FK_VEHICLES1 FOREIGN KEY (make, model) REFERENCES CATALOG,
   CONSTRAINT FK_VEHICLES2 FOREIGN KEY (owner) REFERENCES PERSONS,
   CONSTRAINT FK_VEHICLES3 FOREIGN KEY (reg_driver) REFERENCES DRIVERS,
   CONSTRAINT CK_VEHICLES CHECK (reg_date<=MOT_date)
);

-- IF you decide to implement trigger 'king-is-dead', you should change integrity rule
-- alter table vehicles drop constraint FK_VEHICLES2;
-- alter table vehicles add CONSTRAINT FK_VEHICLES2 FOREIGN KEY (owner) REFERENCES PERSONS ON DELETE SET NULL;


CREATE TABLE ASSIGNMENTS(
   driver VARCHAR2(9),
   nPlate VARCHAR2(7),
   CONSTRAINT PK_DRIVE PRIMARY KEY (driver,nPlate),
   CONSTRAINT FK_DRIVE1 FOREIGN KEY (driver) REFERENCES DRIVERS ON DELETE CASCADE,
   CONSTRAINT FK_DRIVE2 FOREIGN KEY (nPlate) REFERENCES VEHICLES ON DELETE CASCADE
);

CREATE TABLE OBSERVATIONS(
   nPlate     VARCHAR2(7),
   odatetime  TIMESTAMP,
   road       VARCHAR2(5) NOT NULL,
   km_point   NUMBER(3) NOT NULL,
   direction  VARCHAR2(3) NOT NULL,
   speed      NUMBER(3) NOT NULL,
   CONSTRAINT PK_OBSERVATIONS PRIMARY KEY (odatetime, nPlate),
   CONSTRAINT UK_OBSERVATIONS UNIQUE(road, km_point, direction, odatetime),
   CONSTRAINT FK_OBSERVATIONS1 FOREIGN KEY (road, km_point, direction) REFERENCES RADARS ON DELETE CASCADE,
   CONSTRAINT FK_OBSERVATIONS2 FOREIGN KEY (nPlate) REFERENCES VEHICLES (nPlate) ON DELETE CASCADE
);

CREATE TABLE TICKETS(
   obs1_veh   VARCHAR2(7),
   obs1_date  TIMESTAMP,
   tik_type   VARCHAR2(9),
   obs2_veh   VARCHAR2(7),
   obs2_date  TIMESTAMP,
   sent_date  DATE NOT NULL,
   pay_date   DATE,
   pay_type   VARCHAR2(1),
   amount     NUMBER(7) NOT NULL,
   debtor     VARCHAR2(9),
   state      VARCHAR2(1) DEFAULT('R') NOT NULL,
   CONSTRAINT PK_TICKETS PRIMARY KEY(obs1_veh,obs1_date,tik_type),
   CONSTRAINT FK_TICKETS1 FOREIGN KEY (obs1_date,obs1_veh) REFERENCES OBSERVATIONS,
   CONSTRAINT FK_TICKETS2 FOREIGN KEY (obs2_date,obs2_veh) REFERENCES OBSERVATIONS,
   CONSTRAINT FK_TICKETS3 FOREIGN KEY (debtor) REFERENCES PERSONS,
   CONSTRAINT CK_TICKETS1 CHECK (state IN ('R','I','E','F','N')),
   CONSTRAINT CK_TICKETS2 CHECK (pay_type IN ('B','T','C')),
   CONSTRAINT CK_TICKETS3 CHECK (tik_type IN ('S','T','D')),
   CONSTRAINT CK_TICKETS4 CHECK ((tik_type='S' AND obs2_veh IS NULL AND obs2_date IS NULL) OR
                                 (tik_type!='S' AND obs2_veh IS NOT NULL AND obs2_date IS NOT NULL)),
   CONSTRAINT CK_TICKETS5 CHECK (tik_type!='T' OR obs1_veh=obs2_veh),
   CONSTRAINT CK_TICKETS6 CHECK (tik_type!='D' OR obs1_veh!=obs2_veh),
   CONSTRAINT CK_TICKETS7 CHECK ((state='F' AND pay_date IS NOT NULL AND pay_type IS NOT NULL) OR
                                 (state!='F' AND pay_date IS NULL AND pay_type IS NULL))
);

CREATE TABLE ALLEGATIONS(
   obs_veh    VARCHAR2(7),
   obs_date   TIMESTAMP,
   tik_type   VARCHAR2(9),
   reg_date   DATE,
   new_debtor VARCHAR2(9) NOT NULL,
   status     VARCHAR2(1) DEFAULT('U') NOT NULL,
   exec_date  DATE,
   CONSTRAINT PK_ALLEGATIONS PRIMARY KEY (obs_veh,obs_date,tik_type,reg_date),
   CONSTRAINT FK_ALLEGATIONS1 FOREIGN KEY (obs_veh,obs_date,tik_type) REFERENCES TICKETS,
   CONSTRAINT FK_ALLEGATIONS2 FOREIGN KEY (new_debtor) REFERENCES PERSONS,
   CONSTRAINT CK_ALLEGATIONS CHECK (status IN ('A','R','U')),
   CONSTRAINT CK_ALLEGATIONS2 CHECK ((status!='U' AND exec_date IS NOT NULL) OR
                                     (status='U' AND exec_date IS NULL))
);
