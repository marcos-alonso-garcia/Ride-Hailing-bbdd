# Ride-Hailing BBDD

Base de datos relacional para una plataforma de ride-hailing tipo Uber/Bolt/Lyft, desarrollada para la asignatura **Bases de Datos Avanzadas**.

El proyecto incluye:

- despliegue con **Docker Compose**
- base de datos **MySQL**
- métricas de monitorización con **mysqld_exporter + Prometheus + Grafana**
- modelo relacional con usuarios, riders, conductores, compañías, vehículos, viajes, ofertas y pagos
- procedimiento almacenado para controlar la concurrencia en la aceptación de ofertas
- vistas de negocio para dashboard
- triggers de auditoría

---

## Requisitos

- **Docker Desktop** instalado y en ejecución
- **Docker Compose** disponible
- **Git**
- Visual Studio Code u otro editor recomendado

---

## Estructura del proyecto

- `schema.sql` → crea la base de datos, tablas, índices, vistas, procedimiento y triggers
- `data.sql` → inserta datos de prueba
- `queries.sql` → consultas de operativa básica
- `dashboard.sql` → consultas para métricas de negocio y monitorización
- `backup.sql` → plan de backup y recuperación
- `permissions.sql` → usuarios y permisos de la base de datos
- `compose.yml` → despliegue de MySQL + monitorización
- `DESIGN.md` → documentación del diseño y MER
- `README.md` → instrucciones de uso del proyecto

---

## Arranque del entorno

Desde la raíz del proyecto:

```bash
docker compose up -d
```

Comprobar que los servicios están levantados:

```bash
docker compose ps
```

Ver logs de MySQL:

```bash
docker logs ridehailing-mysql
```

---

## Servicios disponibles

Una vez arrancado el entorno, deberían estar disponibles:

- **MySQL** → puerto `3306`
- **Prometheus** → `http://localhost:9090`
- **Grafana** → `http://localhost:3000`

### Credenciales de Grafana

- usuario: `admin`
- contraseña: `admin`

---

## Comprobar que MySQL está listo

```bash
docker exec -it ridehailing-mysql mysqladmin ping -h 127.0.0.1 -uroot -prootpass
```

Si todo va bien, aparecerá:

```text
mysqld is alive
```

---

## Conectarse a MySQL

```bash
docker exec -it ridehailing-mysql mysql -uroot -prootpass
```

Una vez dentro:

```sql
USE ride_hailing;
SHOW TABLES;
```

---

## Inicialización automática

La base de datos se inicializa automáticamente al arrancar el contenedor con volumen vacío mediante los scripts montados en `docker-entrypoint-initdb.d`.

Normalmente se cargan:

- `schema.sql`
- `permissions.sql`
- `data.sql`

---

## Reinicializar el entorno desde cero

Si necesitas reconstruir toda la base de datos y volver a ejecutar los scripts de inicialización:

```bash
docker compose down -v
docker compose up -d
```

> Esto elimina el volumen local de la base de datos de este proyecto y vuelve a crear todo desde cero.

---

## Consultas de operativa

Para ejecutar manualmente las consultas de `queries.sql`:

### En PowerShell

```powershell
Get-Content .\queries.sql | docker exec -i ridehailing-mysql mysql -uroot -prootpass ride_hailing
```

### En cmd

```cmd
docker exec -i ridehailing-mysql mysql -uroot -prootpass ride_hailing < queries.sql
```

Estas consultas incluyen ejemplos de:

- creación de riders
- creación de viajes y ofertas
- aceptación de ofertas
- locks con `FOR UPDATE`
- actualizaciones transaccionales
- consultas con `JOIN`

---

## Consultas de dashboard

Para ejecutar `dashboard.sql`:

### En PowerShell

```powershell
Get-Content .\dashboard.sql | docker exec -i ridehailing-mysql mysql -uroot -prootpass ride_hailing
```

### En cmd

```cmd
docker exec -i ridehailing-mysql mysql -uroot -prootpass ride_hailing < dashboard.sql
```

El dashboard incluye métricas como:

- viajes por estado
- viajes por hora
- ofertas por estado
- ofertas aceptadas por hora
- tasa de aceptación por conductor
- tasa de aceptación por company
- ingresos por conductor y company
- euros/km y euros/minuto
- métricas de conexiones, slow queries, tamaño de tablas e índices

---

## Procedimiento principal de concurrencia

El procedimiento almacenado principal es:

```sql
CALL sp_aceptar_oferta(id_oferta);
```

Su función es garantizar que:

- una oferta pendiente pueda ser aceptada
- el viaje quede asignado a un único conductor
- las demás ofertas del mismo viaje pasen a estado `caducada`
- todo ocurra dentro de una transacción con control de concurrencia

---

## Auditoría

El sistema incluye una tabla `auditoria` y triggers para registrar:

- inserciones de ofertas
- cambios de estado en viajes

Consultar auditoría:

```sql
SELECT * FROM auditoria ORDER BY fecha DESC;
```

---

## Seguridad y permisos

El archivo `permissions.sql` crea usuarios separados para distintos roles:

- `app_user` → usuario principal de la aplicación
- `analytics_user` → usuario de solo lectura para reporting
- `backup_user` → usuario para copias de seguridad
- `exporter` → usuario para monitorización con `mysqld_exporter`

Esto sigue el principio de **mínimos privilegios**.

---

## Backup y recuperación

El archivo `backup.sql` documenta la estrategia de backup y restore.

### Ejemplo de backup lógico

```powershell
docker exec ridehailing-mysql mysqldump -uroot -prootpass --databases ride_hailing --single-transaction --routines --triggers --set-gtid-purged=OFF > backup_ride_hailing.sql
```

### Ejemplo de restore en PowerShell

```powershell
Get-Content .\backup_ride_hailing.sql | docker exec -i ridehailing-mysql mysql -uroot -prootpass
```

---

## Validación rápida del proyecto

Una vez arrancado el entorno, se recomienda comprobar:

```sql
USE ride_hailing;

SHOW TABLES;
SHOW FULL TABLES WHERE Table_type = 'VIEW';
SHOW PROCEDURE STATUS WHERE Db = 'ride_hailing';
SHOW TRIGGERS FROM ride_hailing;

SELECT * FROM v_viajes_detalle;
SELECT * FROM v_tasa_aceptacion_conductor;
SELECT * FROM v_tasa_aceptacion_company;
SELECT * FROM v_ingresos_conductor;
SELECT * FROM v_ingresos_company;
```

---


## Autores

Proyecto realizado por el grupo de prácticas número 10 de **Bases de Datos Avanzadas**.

Daniel Martín Alonso, Marcos Alonso García, Roberto García Ramírez y Manuel Jimena García.