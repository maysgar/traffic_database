 DROP TABLE vehicle CASCADE CONSTRAINTS;
 DROP TABLE owner CASCADE CONSTRAINTS;
 DROP TABLE driver CASCADE CONSTRAINTS;
 DROP TABLE license CASCADE CONSTRAINTS;
 DROP TABLE radar CASCADE CONSTRAINTS;
 DROP TABLE observation CASCADE CONSTRAINTS;
 DROP TABLE alegation CASCADE CONSTRAINTS;

 CREATE TABLE vehicle (
   nPlate          VARCHAR2(7),
   VIN             VARCHAR2(17),
   make            VARCHAR2(10), --brand
   model           VARCHAR2(12),
   power           VARCHAR2(6),
   color           VARCHAR2(25),
   reg_date        VARCHAR2(10),
   MOT_date        VARCHAR2(10),
   owner           VARCHAR2(20), --referencing owner table
   CONSTRAINT PK_Vehicle PRIMARY KEY (nPlate,VIN)
 )

 CREATE TABLE owner (
   owner_name      VARCHAR2(35),
   owner_surn1     VARCHAR2(15),
   owner_surn2     VARCHAR2(15),
   owner_address   VARCHAR2(42),
   owner_town      VARCHAR2(35),  --needed?
   owner_mobile    VARCHAR2(9),   --optional
   owner_email     VARCHAR2(50),  --optional
   owner_birth     VARCHAR2(10),
   owner_DNI       VARCHAR2(9),
   CONSTRAINT PK_Owner PRIMARY KEY (owner_name,owner_surn1,owner_surn2,owner_DNI) --no tengo claro si elegir el nombre completo o el DNI
 )

 CREATE TABLE driver (
   driver_name     VARCHAR2(35),
   driver_surn1    VARCHAR2(15),
   driver_surn2    VARCHAR2(15),
   driver_address  VARCHAR2(42),
   driver_town     VARCHAR2(35), --needed?
   driver_mobile   VARCHAR2(9),  --optional
   driver_email    VARCHAR2(50), --optional
   driver_birth    VARCHAR2(10),
   driver_DNI      VARCHAR2(9),
   driver_license  VARCHAR2(3),
   driver_age      NUMBER(2,0),
   CONSTRAINT PK_Driver PRIMARY KEY (driver_name,driver_surn1,driver_surn2,driver_DNI)
 )

 CREATE TABLE license (
   license_number  VARCHAR2(20),
   license_type    VARCHAR2(20),
   issue_date      VARCHAR2(10),
   driver          VARCHAR2(100),
   CONSTRAINT PK_License PRIMARY KEY (license_number)
 )

 CREATE TABLE radar (
   road            VARCHAR2(5),
   speed_limit     NUMBER(3,0),
   km_point        NUMBER(3,0),
   direction       VARCHAR2(3),
   radar_speedlim  NUMBER(3,0),
   CONSTRAINT PK_Radar PRIMARY KEY (road,km_point,direction)
 )

  CREATE TABLE observation (
   vehicle         VARCHAR2(20),
   date            VARCHAR2(10),
   time            VARCHAR2(12),
   speed           NUMBER(3,0),
   CONSTRAINT PK_Observation PRIMARY KEY (date, time)
  )

  CREATE TABLE alegation (
   sanction        VARCHAR2(20),
   alegation_ID    VARCHAR2(100),
   reg_date        VARCHAR2(10),
   status          VARCHAR2(10),
   ex_date         VARCHAR2(10),
   CONSTRAINT PK_Alegation PRIMARY KEY (alegation_ID)
  )
