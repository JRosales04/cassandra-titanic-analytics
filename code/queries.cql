// CREACION KEYSPACE
CREATE KEYSPACE IF NOT EXISTS titanic
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

// CREACION E IMPORTACION DEL TOTAL DE DATOS
DROP TABLE IF EXISTS titanic.titanic_join;
CREATE TABLE titanic.titanic_join (
    passengerid int,
    name text,
    sex text,
    age float,
    sibsp int,
    parch int,
    ticket text,
    fare float,
    pclass int,
    embarked text,
    survived int,
    cabin text,
    PRIMARY KEY (passengerid)
);
COPY titanic.titanic_join (passengerid, name, sex, age, sibsp, parch, ticket, fare, pclass, embarked, survived, cabin) 
FROM '/home/lab/data_csv/titanic_join.csv' 
WITH HEADER=true AND NULL='null';

SELECT COUNT(*) FROM titanic.titanic_join;

// CREACION DE TABLAS PARA CADA CONSULTA

// Consulta 1
DROP TABLE IF EXISTS titanic.supervivientes_por_clase;
CREATE TABLE titanic.supervivientes_por_clase (
    passengerid int,
    name text,
    sex text,
    age float,
    pclass int,
    survived int,
    PRIMARY KEY (pclass, survived, passengerid)
);

// Consulta 2
DROP TABLE IF EXISTS titanic.pasajeros_por_puerto_edad;
CREATE TABLE titanic.pasajeros_por_puerto_edad (
    embarked text,
    age float,         
    passengerid int,
    name text,
    sex text,
    pclass int,
    PRIMARY KEY (embarked, age, passengerid)
) WITH CLUSTERING ORDER BY (age ASC, passengerid ASC);

// Consulta 3
DROP TABLE IF EXISTS titanic.mujeres_supervivientes_por_clase;
CREATE TABLE titanic.mujeres_supervivientes_por_clase (
    pclass int,
    sex text,
    survived int,
    passengerid int,
    name text,
    age float,
    PRIMARY KEY (pclass, sex, survived, passengerid)
);

// Consulta 4
DROP TABLE IF EXISTS titanic.pasajeros_por_rango_edad;
CREATE TABLE titanic.pasajeros_por_rango_edad (
    pclass int,
    survived int,
    age float,
    rango_edad text,
    passengerid int,
    name text,
    sex text,
    PRIMARY KEY (rango_edad, age, passengerid)
) WITH CLUSTERING ORDER BY (age ASC, passengerid ASC);

// Consulta 5
DROP TABLE IF EXISTS titanic.pasajeros_por_puerto_supervivencia;
CREATE TABLE titanic.pasajeros_por_puerto_supervivencia (
    embarked text,
    survived int,
    passengerid text,
    PRIMARY KEY (embarked, survived, passengerid)
);

// Consulta 6
DROP TABLE IF EXISTS titanic.pasajeros_por_clase_edad_supervivencia;
CREATE TABLE titanic.pasajeros_por_clase_edad_supervivencia (
    pclass int,
    survived int,
    rango_edad text,
    passengerid int,
    PRIMARY KEY (rango_edad, pclass, survived, passengerid)
);

// IMPORTACION MEDIANTE COPY

// Consulta 1
COPY titanic.supervivientes_por_clase (passengerid, name, sex, age, pclass, survived) 
FROM '/home/lab/data_csv/supervivientes_por_clase.csv' 
WITH HEADER=true AND NULL='null';
// Consulta 2
COPY titanic.pasajeros_por_puerto_edad (passengerid, name, sex, age, pclass, embarked) 
FROM '/home/lab/data_csv/pasajeros_por_puerto_edad.csv' 
WITH HEADER=true AND NULL='null';
// Consulta 3
COPY titanic.mujeres_supervivientes_por_clase (passengerid, name, sex, age, pclass, survived) 
FROM '/home/lab/data_csv/mujeres_supervivientes_por_clase.csv' 
WITH HEADER=true AND NULL='null';
// Consulta 4
COPY titanic.pasajeros_por_rango_edad (passengerid, name, sex, age, pclass, survived, rango_edad) 
FROM '/home/lab/data_csv/pasajeros_por_rango_edad.csv' 
WITH HEADER=true AND NULL='null';
// Consulta 5
COPY titanic.pasajeros_por_puerto_supervivencia (embarked, survived, passengerid) 
FROM '/home/lab/data_csv/pasajeros_por_puerto_supervivencia.csv' 
WITH HEADER=true AND NULL='null';
// Consulta 6
COPY titanic.pasajeros_por_clase_edad_supervivencia (passengerid, pclass, survived, rango_edad) 
FROM '/home/lab/data_csv/pasajeros_por_clase_edad_supervivencia.csv' 
WITH HEADER=true AND NULL='null';

// NUMERO DE REGISTROS POR TABLA

// Consulta 1
SELECT COUNT(*) FROM titanic.supervivientes_por_clase;
// Consulta 2
SELECT COUNT(*) FROM titanic.pasajeros_por_puerto_edad;
// Consulta 3
SELECT COUNT(*) FROM titanic.mujeres_supervivientes_por_clase;
// Consulta 4
SELECT COUNT(*) FROM titanic.pasajeros_por_rango_edad;
// Consulta 5
SELECT COUNT(*) FROM titanic.pasajeros_por_puerto_supervivencia;
// Consulta 6
SELECT COUNT(*) FROM titanic.pasajeros_por_clase_edad_supervivencia;

// CONSULTAS

// Consulta 1: Supervivientes por clase
SELECT pclass, COUNT(*) as supervivientes 
FROM titanic.supervivientes_por_clase 
WHERE pclass = 1 AND survived = 1;
SELECT pclass, COUNT(*) as supervivientes 
FROM titanic.supervivientes_por_clase 
WHERE pclass = 2 AND survived = 1;
SELECT pclass, COUNT(*) as supervivientes 
FROM titanic.supervivientes_por_clase 
WHERE pclass = 3 AND survived = 1;

// Consulta 2: Pasajeros por puerto ordenados por edad
SELECT embarked, age, passengerid, name, sex, pclass
FROM titanic.pasajeros_por_puerto_edad
WHERE embarked IN ('S','C','Q');

// Consulta 3: Mujeres supervivientes por clase
SELECT pclass, COUNT(*) AS num_mujeres_supervivientes
FROM titanic.mujeres_supervivientes_por_clase
WHERE pclass = 1 AND sex = 'female' AND survived = 1;
SELECT pclass, COUNT(*) AS num_mujeres_supervivientes
FROM titanic.mujeres_supervivientes_por_clase
WHERE pclass = 2 AND sex = 'female' AND survived = 1;
SELECT pclass, COUNT(*) AS num_mujeres_supervivientes
FROM titanic.mujeres_supervivientes_por_clase
WHERE pclass = 3 AND sex = 'female' AND survived = 1;

// Consulta 4: Análisis por rango de edad
SELECT * FROM titanic.pasajeros_por_rango_edad
WHERE rango_edad = 'Infante';
SELECT * FROM titanic.pasajeros_por_rango_edad
WHERE rango_edad = 'Adolescente';
SELECT * FROM titanic.pasajeros_por_rango_edad
WHERE rango_edad = 'Adulto_Joven';
SELECT * FROM titanic.pasajeros_por_rango_edad
WHERE rango_edad = 'Senior';
SELECT * FROM titanic.pasajeros_por_rango_edad
WHERE rango_edad = 'Desconocido';

// Consulta 5: Analisis por puerto y supervivencia
SELECT survived, COUNT(*) AS num_pasajeros
FROM titanic.pasajeros_por_puerto_supervivencia
WHERE embarked = 'S'
GROUP BY survived;
SELECT survived, COUNT(*) AS num_pasajeros
FROM titanic.pasajeros_por_puerto_supervivencia
WHERE embarked = 'Q'
GROUP BY survived;
SELECT survived, COUNT(*) AS num_pasajeros
FROM titanic.pasajeros_por_puerto_supervivencia
WHERE embarked = 'C'
GROUP BY survived;
SELECT survived, COUNT(*) AS num_pasajeros
FROM titanic.pasajeros_por_puerto_supervivencia
WHERE embarked = 'N'
GROUP BY survived;

// Consulta 6: Análisis por clase, edad y supervivencia
SELECT pclass, survived, COUNT(*) AS num_pasajeros
FROM titanic.pasajeros_por_clase_edad_supervivencia
WHERE rango_edad = 'Infante'
GROUP BY pclass, survived;
SELECT pclass, survived, COUNT(*) AS num_pasajeros
FROM titanic.pasajeros_por_clase_edad_supervivencia
WHERE rango_edad = 'Adolescente'
GROUP BY pclass, survived;
SELECT pclass, survived, COUNT(*) AS num_pasajeros
FROM titanic.pasajeros_por_clase_edad_supervivencia
WHERE rango_edad = 'Adulto_Joven'
GROUP BY pclass, survived;
SELECT pclass, survived, COUNT(*) AS num_pasajeros
FROM titanic.pasajeros_por_clase_edad_supervivencia
WHERE rango_edad = 'Adulto'
GROUP BY pclass, survived;
SELECT pclass, survived, COUNT(*) AS num_pasajeros
FROM titanic.pasajeros_por_clase_edad_supervivencia
WHERE rango_edad = 'Senior'
GROUP BY pclass, survived;