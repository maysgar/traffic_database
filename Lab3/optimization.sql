

-- INDEXES
CREATE UNIQUE INDEX index_odatetime ON observations(odatetime);
CREATE UNIQUE INDEX index_radar ON radars(radars, km_point, direction);
CREATE INDEX index_speedlim ON roads(speedlim);
CREATE INDEX index_speed ON observations(speed);

-- CLUSTERS
CREATE CLUSTER road_obs (name VARCHAR2(5));

CREATE OR REPLACE TABLE OBSERVATIONS (
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
) CLUSTER road_obs(road);

CREATE OR REPLACE TABLE ROAD (
  name	        VARCHAR2(5),
  speed_limit	NUMBER(3,0) NOT NULL,
  CONSTRAINT PK_ROADS PRIMARY KEY (name),
  CONSTRAINT CK_ROADS CHECK (speed_limit<150)
) CLUSTER road_obs(name);
CREATE INDEX index_road_obs ON CLUSTER road_obs;


CREATE CLUSTER radar_obs (road VARCHAR2(5), km_point NUMBER(3), direction VARCHAR2(3));

CREATE OR REPLACE TABLE OBSERVATIONS (
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
) CLUSTER radar_obs(road, km_point, direction);

CREATE OR REPLACE TABLE RADARS (
  road	      VARCHAR2(5) NOT NULL,
  Km_point   NUMBER(3,0) NOT NULL,
  direction  VARCHAR2(3) NOT NULL,
  speedlim   NUMBER(3,0) NOT NULL,
  CONSTRAINT PK_RADARS PRIMARY KEY(road, Km_point, direction),
  CONSTRAINT FK_RADARS FOREIGN KEY (road) REFERENCES ROADS ON DELETE CASCADE
) CLUSTER radar_obs(road, km_point, direction);
CREATE INDEX index_radar_obs ON CLUSTER radar_obs;


CREATE CLUSTER vehicle_obs (nPlate VARCHAR2(7));

CREATE OR REPLACE TABLE OBSERVATIONS (
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
) CLUSTER vehicle_obs(nPlate);

CREATE OR REPLACE TABLE VEHICLES (
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
) CLUSTER vehicle_obs(nPlate);

CREATE INDEX index_road_obs ON CLUSTER road_obs;
