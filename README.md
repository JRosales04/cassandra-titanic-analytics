# Titanic Analytics: Migración de datos y consultas analíticas en Apache Cassandra

# :ok_man: Autores

- Javier Rosales Lozano
- Alonso Ríos Guerra
- Nahuel Sebastián Vargas
- Alejandro Rodríguez García

Última modificación: 31/01/2026

## :globe_with_meridians: Descripción

Trabajo de prácticas (2025-2026) para la asignatura Arquitectura de Datos del Grado de Ingeniería Informática.

Universidad Carlos III de Madrid.

## :book: Resumen

Práctica de diseño e implementación de un modelo de datos en Apache Cassandra, incluyendo preprocesado, carga y resolución de consultas analíticas sobre un dataset del Titanic.

El proyecto global consta de dos partes:

<table>
  <thead>
    <tr>
      <th>Fase</th>
      <th>Descripción</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1. Extracción y preprocesado de datos en MongoDB</td>
      <td>
        En esta fase se integran los dos ficheros CSV originales del dataset del Titanic (información personal y datos del billete y trayecto) mediante preprocesado externo en MongoDB, generando un conjunto de datos unificado. Se aplican tareas de limpieza y normalización, incluyendo el tratamiento de valores ausentes, la imputación de edades mediante la media y la generación de atributos derivados como el rango de edad. Finalmente, se generan ficheros CSV específicos para cada una de las consultas analíticas planteadas, que posteriormente se utilizan para la carga de datos en Apache Cassandra.
      </td>
    </tr>
    <tr>
      <td>2. Implementación del modelo de datos en Apache Cassandra</td>
      <td>
        En esta fase se crea el keyspace titanic y se implementan las tablas necesarias para resolver cada una de las consultas analíticas planteadas, utilizando los ficheros CSV generados en la fase de preprocesado. Se definen claves de partición y clustering adaptadas a los patrones de consulta, <strong>evitando ALLOW FILTERING</strong> y el uso de índices secundarios. Los datos se cargan mediante COPY FROM y se verifican los registros importados. Cada tabla se diseña específicamente para su consulta, optimizando la eficiencia de lectura y el equilibrio de particiones.
      </td>
    </tr>
  </tbody>
</table>

## :construction: Estructura del proyecto

```plaintext
cassandra-titanic-analytics/
├── code/                           # Scripts de código
│   ├── preprocessing.js            # Fichero de preprocesado de datos en MongoDB
│   └── queries.cql                 # Importación y análisis de datos en Apache Cassandra
├── data/                           # Compilación de datos originales y preprocesados
│   ├── csv/                        # Datos por consulta preprocesados en MongoDB
│   └── raw/                        # Ficheros de datos originales
├── docs/                           # Memorias de trabajo y enunciados
└── README.md                       # Este archivo
```

## :link: Dependencias

<img src="https://go-skill-icons.vercel.app/api/icons?i=cassandra,mongodb,js&theme=dark&titles=true"/>

- Instalación de MongoDB (servidor) compatible; los scripts usan operaciones de agregación modernas. Se recomienda **MongoDB 4.4+ o 5.x**. Para este proyecto, se ha utilizado la interfaz oficial [MongoDB Compass](https://www.mongodb.com/products/tools/compass).
- `mongosh` o `mongo` para ejecutar los scripts desde la línea de comandos.
- Instalación de Apache Cassandra; se recomienda **Cassandra 4.x**. Puede instalarse siguiendo la guía oficial: [Cassandra Installation](http://cassandra.apache.org/_/download.html). Una vez instalado-
- `cqlsh` para acceder a la shell y ejecutar los scripts de creación de keyspace, tablas y carga de datos.

## :inbox_tray: Instalación y uso

1. **Clonar el repositorio**.

```bash
git clone https://github.com/JRosales04/cassandra-titanic-analytics.git
```

2. **Crear la base de datos en MongoDB**.

```shell
# 1. Entrar al shell de MongoDB
mongosh
# 2. Seleccionar la base de datos
use titanic_db
# 3. Crear colecciones para cada CSV
db.createCollection("passenger_info")
db.createCollection("passenger_trip")
# 4. Importar información de pasajeros y billetes/trayectos
mongoimport --db titanic_db --collection pass_info --type csv --headerline --file /ruta/al/archivo/titanic_passager_info_10000.csv
mongoimport --db titanic_db --collection pass_ticket --type csv --headerline --file /ruta/al/archivo/titanic_passager_trip_10000.csv
# 5. Ejecutar script de preprocesado para generar la colección titanic_full
mongosh code/preprocessing.js
```

3. **Creación del keyspace y análisis de datos en Apache Cassandra**.

```shell
# 1. Importacion de datos limpios y archivo .cql
mkdir -p /home/lab/data_csv
cp /data/csv/*.csv /home/lab/data_csv/
cp /code/queries.cql /home/lab/
# 2. Abrir Cassandra
systemctl start cassandra
systemctl status cassandra
cqlsh
# 3. Ejecutar archivo de consultas
SOURCE '/home/lab/queries.cql';
```
