# Fase 2 — Plataforma On-Premise, Observabilidad y CI/CD

## 1. Objetivo

En esta fase se implementó una infraestructura **on-premise virtualizada sobre VMware Workstation** para simular un entorno empresarial previo a su migración hacia AWS.

El objetivo fue separar los principales componentes de la plataforma en servidores especializados e incorporar:

- Contenerización de la aplicación con Docker
- Persistencia de datos en PostgreSQL
- Reverse Proxy con Nginx
- Monitoreo centralizado con Prometheus y Grafana
- Bastion Host para administración centralizada
- Pipeline CI/CD automatizado mediante GitHub Actions

La arquitectura resultante sirve como **entorno de origen** para las siguientes fases del proyecto, donde la infraestructura será rediseñada y desplegada sobre AWS utilizando servicios administrados e Infrastructure as Code.

---

## 2. Arquitectura implementada

Se utilizaron cinco máquinas virtuales Ubuntu Server con responsabilidades independientes:

| Servidor | Dirección IP | Función |
|---|---|---|
| `DM-WEB-01` | `192.168.2.10` | Nginx / Reverse Proxy |
| `DM-API-01` | `192.168.2.20` | Docker + aplicación Next.js |
| `DM-DB-01` | `192.168.2.30` | PostgreSQL |
| `DM-MON-01` | `192.168.2.40` | Prometheus + Grafana |
| `DM-BASTION-01` | `192.168.2.50` | Bastion Host + GitHub Actions Runner |

### Flujo principal de la aplicación

```text
Cliente
   │
   ▼
DM-WEB-01
Nginx :80
   │
   ▼
DM-API-01
Docker + Next.js :3000
   │
   ▼
DM-DB-01
PostgreSQL :5432
```

La separación de responsabilidades permite simular una arquitectura de múltiples capas y facilita posteriormente la equivalencia de cada componente con servicios AWS.

![Diagrama 1](images/01-diagrama.png)

> **Evidencia:** agregar un diagrama mostrando las cinco máquinas virtuales, sus direcciones IP, funciones y conexiones.

---

## 3. Configuración de red

Se configuraron direcciones IPv4 estáticas mediante **Netplan** para evitar cambios de direccionamiento provocados por DHCP.

El direccionamiento definitivo fue:

```text
DM-WEB-01      192.168.2.10
DM-API-01      192.168.2.20
DM-DB-01       192.168.2.30
DM-MON-01      192.168.2.40
DM-BASTION-01  192.168.2.50
```

Esto permitió establecer comunicaciones predecibles entre los diferentes componentes de la infraestructura.

También se implementaron reglas de firewall utilizando **UFW**, restringiendo servicios según su origen.

Ejemplos:

```text
DM-API-01 → DM-DB-01
TCP 5432

DM-MON-01 → Node Exporter
TCP 9100
```

El acceso a PostgreSQL quedó limitado al servidor de aplicación, mientras que las métricas de Node Exporter quedaron disponibles para el servidor de monitoreo.

> **Evidencia:** agregar una captura de `ip addr` mostrando la configuración de IP estática y una captura de `sudo ufw status` mostrando las reglas relevantes.

---

## 4. Contenerización de la aplicación

La aplicación Next.js fue contenerizada utilizando **Docker**.

Se utilizó un **Dockerfile multi-stage** para separar las etapas necesarias para construir la aplicación de la imagen utilizada finalmente en ejecución.

La imagen generada contiene:

- Node.js 22
- Aplicación Next.js compilada
- Dependencias necesarias en producción
- Usuario no privilegiado `nextjs`
- Puerto TCP `3000`
- Configuración de producción

La aplicación se ejecuta dentro de un contenedor administrado mediante **Docker Compose**.

```text
DM-API-01
    │
    ▼
Docker Engine
    │
    ▼
distrito-api
    │
    ▼
Next.js :3000
```

Esto permite empaquetar la aplicación junto con sus dependencias y disponer de un entorno de ejecución reproducible.

> **Evidencia:** agregar una captura de `docker ps` mostrando el contenedor `distrito-api` en estado `Up`.

> **Evidencia adicional:** captura parcial de `docker image inspect distrito-miami:latest` mostrando `NODE_VERSION`, `NODE_ENV=production`, usuario `nextjs`, puerto `3000` y arquitectura `amd64`.

---

## 5. Migración de persistencia local hacia PostgreSQL

Originalmente la aplicación utilizaba archivos JSON como mecanismo de persistencia local.

Entre los datos disponibles se encontraba:

```text
data/
└── products.imported.json
```

Se implementó un proceso de migración utilizando el script:

```text
scripts/seed-products.mjs
```

El flujo de migración fue:

```text
JSON
 │
 ▼
Script de migración Node.js
 │
 ├── Lectura y normalización de datos
 ├── Creación/actualización de marcas
 ├── Inserción de productos
 ├── Inserción de variantes
 └── Inserción de imágenes
 │
 ▼
PostgreSQL
```

Posteriormente, la aplicación fue configurada para utilizar PostgreSQL:

```text
DATA_STORE=postgres
```

También se configuró una cadena `DATABASE_URL` para establecer la comunicación con PostgreSQL ejecutándose en `DM-DB-01`.

De esta forma, PostgreSQL pasó a ser la fuente persistente de información utilizada por la aplicación.

> **Evidencia:** agregar una captura de PostgreSQL ejecutando una consulta `SELECT` donde se visualicen productos migrados.

> [!WARNING]
> Las capturas y documentación no deben exponer contraseñas, credenciales de `DATABASE_URL`, API Keys, tokens de GitHub ni otros secretos.

---

## 6. Reverse Proxy con Nginx

Se instaló **Nginx** en `DM-WEB-01` como punto de entrada HTTP de la aplicación.

Antes de implementar el Reverse Proxy, la aplicación era accedida directamente mediante:

```text
http://192.168.2.20:3000
```

Después de implementar Nginx:

```text
Cliente
   │
   │ HTTP :80
   ▼
DM-WEB-01
Nginx
   │
   │ Reverse Proxy
   ▼
192.168.2.20:3000
   │
   ▼
Next.js
```

Esto desacopla el punto de entrada utilizado por los clientes del puerto interno utilizado por la aplicación.

Nginx proporciona además una base para incorporar posteriormente funcionalidades como terminación TLS, routing, headers, compresión, caching y otras políticas de tráfico.

> **Evidencia:** agregar una captura del navegador accediendo a `http://192.168.2.10` y mostrando la aplicación funcionando sin especificar el puerto `3000`.

> **Evidencia adicional:** agregar una captura parcial de la configuración de Nginx mostrando la directiva `proxy_pass` hacia `192.168.2.20:3000`.

---

## 7. Monitoreo y observabilidad

Se implementó un servidor dedicado de monitoreo:

```text
DM-MON-01
├── Prometheus
└── Grafana
```

**Node Exporter** fue instalado como servicio systemd en los principales servidores de la infraestructura.

```text
DM-WEB-01 ── Node Exporter ──┐
                             │
DM-API-01 ── Node Exporter ──┼──► Prometheus ──► Grafana
                             │
DM-DB-01  ── Node Exporter ──┘
```

Node Exporter expone métricas del sistema operativo a través del puerto TCP `9100`.

Prometheus realiza periódicamente el **scraping** de estas métricas y almacena la información como series temporales.

Grafana utiliza Prometheus como Data Source y permite construir dashboards para visualizar:

- Utilización de CPU
- Utilización de memoria
- Almacenamiento
- Filesystem
- Tráfico de red
- Load Average
- Uptime
- Comportamiento histórico de los servidores

Se implementó el dashboard **Node Exporter Full** para centralizar la observabilidad de la infraestructura.

> **Evidencia:** agregar una captura de `Prometheus → Status → Targets` mostrando WEB, API y DB en estado `UP`.

> **Evidencia principal:** agregar una captura de Grafana mostrando el dashboard Node Exporter Full con métricas reales de uno de los servidores.

---

## 8. Bastion Host

Se incorporó `DM-BASTION-01` como punto central de administración de la infraestructura.

```text
Administrador
      │
      ▼
DM-BASTION-01
      │
      ├──► DM-WEB-01
      ├──► DM-API-01
      ├──► DM-DB-01
      └──► DM-MON-01
```

Se comprobó exitosamente la conectividad SSH desde el Bastion Host hacia los servidores internos.

En este laboratorio, el Bastion Host también fue utilizado para alojar un **self-hosted GitHub Actions Runner**, permitiendo que GitHub Actions ejecute workflows dentro de la red privada VMware sin exponer directamente los servidores internos.

> **Evidencia:** agregar una captura desde `dm-bastion-01` mostrando una conexión SSH hacia `dm-api-01` y la ejecución de `hostname`.

---

## 9. Integración Continua — CI

Se implementó **GitHub Actions** para validar automáticamente cada nueva versión enviada a la rama `main`.

El workflow se almacena en:

```text
.github/
└── workflows/
    └── ci.yml
```

Debido a que las máquinas VMware utilizan direccionamiento privado `192.168.2.0/24`, se configuró un **self-hosted GitHub Actions Runner** en `DM-BASTION-01`.

El flujo de CI implementado es:

```text
Desarrollador
   │
   │ git push
   ▼
GitHub
   │
   ▼
GitHub Actions
   │
   ▼
Self-hosted Runner
DM-BASTION-01
   │
   ├── Checkout
   ├── Setup Node.js 22
   ├── npm ci
   └── npm run build
```

El Bastion Host proporciona los recursos computacionales necesarios para realizar la validación, pero el objeto que se valida es el **código fuente de la aplicación obtenido desde GitHub**.

El comando:

```bash
npm ci
```

valida que las dependencias definidas por la aplicación puedan instalarse correctamente.

Posteriormente:

```bash
npm run build
```

comprueba que la aplicación Next.js pueda ser compilada correctamente.

Si cualquiera de estas etapas falla, el pipeline se detiene y el servidor de aplicación no es modificado.

```text
CI
 │
 ├── npm ci       ✅
 │
 └── npm build    ❌
                    │
                    ▼
                   STOP

DM-API-01 permanece sin cambios
```

Esto evita que versiones que no superen la validación lleguen a la etapa de deployment.

> **Evidencia:** agregar una captura de GitHub Actions mostrando en verde el checkout del repositorio, preparación de Node.js 22, `npm ci` y compilación de la aplicación.

---

## 10. Continuous Deployment — CD

Una vez superada correctamente la validación CI, comienza automáticamente la etapa de **Continuous Deployment**.

El job de deployment depende de la ejecución exitosa del job de CI.

```text
CI
 │
 │ SUCCESS
 ▼
CD
 │
 ▼
DM-BASTION-01
 │
 │ SSH
 ▼
DM-API-01
 │
 ├── git pull
 ├── docker build
 ├── docker compose up
 └── HTTP Health Check
```

Durante el deployment, `DM-API-01`:

1. Obtiene la última versión del código.
2. Construye una nueva imagen Docker.
3. Recrea el contenedor de la aplicación.
4. Ejecuta un Health Check HTTP.

Si la aplicación responde correctamente, GitHub Actions marca el deployment como exitoso.

El flujo requerido por el desarrollador queda reducido a:

```bash
git add .
git commit -m "descripción del cambio"
git push origin main
```

El resto del proceso de validación y deployment queda automatizado.

> **Evidencia principal:** agregar una captura de GitHub Actions mostrando ambos jobs completados correctamente:

```text
CI - Build and Validate    ✅
CD - Deploy to DM-API-01   ✅
```

---

## 11. GitHub Actions Runner como servicio

Inicialmente, el self-hosted runner debía iniciarse manualmente mediante:

```bash
./run.sh
```

Posteriormente fue registrado como un **servicio systemd**.

El proceso de inicio quedó de la siguiente manera:

```text
DM-BASTION-01
      │
      │ Inicio del sistema
      ▼
systemd
      │
      ▼
GitHub Actions Runner
      │
      ▼
Connected to GitHub
      │
      ▼
Listening for Jobs
```

Esto permite que el runner quede disponible automáticamente después de iniciar `DM-BASTION-01`, sin necesidad de ejecutar manualmente el proceso.

> **Evidencia:** agregar una captura de `systemctl` mostrando el servicio GitHub Actions Runner como `active (running)`, junto con los mensajes `Connected to GitHub` y `Listening for Jobs`.

---

## 12. Arquitectura final On-Premise

```text
                         DESARROLLADOR
                              │
                           git push
                              │
                              ▼
                            GitHub
                              │
                       GitHub Actions
                              │
                              ▼
                       DM-BASTION-01
                       Self-hosted Runner
                              │
                   ┌──────────┴──────────┐
                   │                     │
              Validación CI         Deployment CD
                                         │
                                         ▼
CLIENTE ───► DM-WEB-01 ───► DM-API-01 ───► DM-DB-01
               Nginx         Docker/Next     PostgreSQL
                                 │
                                 │ Métricas
                                 ▼
                            DM-MON-01
                       Prometheus + Grafana
```

---

## 13. Resultado

Al finalizar esta fase se obtuvo una plataforma virtualizada funcional con:

- Arquitectura de múltiples capas
- Direccionamiento IP estático
- Separación de responsabilidades
- Reverse Proxy con Nginx
- Aplicación Next.js contenerizada con Docker
- Persistencia de datos en PostgreSQL
- Reglas de firewall
- Observabilidad centralizada
- Bastion Host
- Integración con GitHub
- Continuous Integration
- Continuous Deployment
- Health Checks HTTP automatizados
- Self-hosted runner administrado mediante systemd

Esta infraestructura representa el **entorno de origen** para la siguiente etapa del proyecto:

> **Migración y modernización hacia AWS utilizando Terraform e Infrastructure as Code.**