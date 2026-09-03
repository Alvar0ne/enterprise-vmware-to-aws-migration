# Enterprise VMware to AWS Modernization Platform

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-4169E1?logo=postgresql&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-Backend-339933?logo=node.js&logoColor=white)

### Migración y modernización empresarial End-to-End | VMware • AWS • DevOps • Serverless • Data Platform

---

## 📖 Descripción del proyecto

Este proyecto documenta la migración y modernización de una plataforma de comercio electrónico empresarial, utilizando **Distrito Miami** como caso de negocio.

El proyecto fue implementado de extremo a extremo partiendo desde un laboratorio basado en VMware y evolucionando hacia una arquitectura moderna en AWS, aplicando networking Multi-AZ, alta disponibilidad, contenedores, servicios administrados, Infrastructure as Code, observabilidad, arquitectura orientada a eventos, analítica serverless y CI/CD.

La estrategia aplicada corresponde principalmente a una **replatformización y modernización**, evitando limitar la migración a un rehost 1:1 de las máquinas virtuales originales.

> **Estado actual:** la implementación técnica del proyecto se encuentra **finalizada**. Actualmente se está completando la documentación técnica y las evidencias de cada fase.

> **Nota:** Este repositorio utiliza una versión sanitizada de una aplicación real. No contiene credenciales de producción, información de clientes ni datos comerciales confidenciales.

---

# 🎯 Objetivos del proyecto

El proyecto demuestra experiencia práctica en:

- Administración de infraestructura VMware
- Arquitectura AWS y networking empresarial
- Migración y modernización cloud
- Infrastructure as Code con Terraform
- Docker y Amazon ECR
- Amazon EC2, Launch Templates y Auto Scaling
- Application Load Balancer y alta disponibilidad Multi-AZ
- Amazon RDS PostgreSQL
- AWS Database Migration Service (DMS)
- IAM y gestión segura de accesos
- Amazon CloudWatch y Amazon SNS
- Arquitecturas orientadas a eventos con EventBridge
- Amazon SQS, DLQ y AWS Lambda
- Data Lake en Amazon S3
- AWS Glue y Amazon Athena
- CI/CD con GitHub Actions y OIDC
- Data Engineering y analítica serverless

---

# 🏗 Arquitectura

## Infraestructura de origen — VMware

El entorno de origen fue construido como laboratorio empresarial sobre VMware Workstation utilizando máquinas virtuales Ubuntu para representar las principales capas de la plataforma:

- Frontend / Reverse Proxy con Nginx
- Aplicación Next.js contenerizada con Docker
- PostgreSQL
- Prometheus + Grafana
- Bastion / GitHub Actions Runner
- Gateway VPN para conectividad híbrida durante la migración

## Arquitectura implementada — AWS

La plataforma fue replatformizada y modernizada utilizando servicios administrados y capacidades nativas de AWS.

Principales componentes implementados:

- Amazon VPC `10.0.0.0/16`
- Arquitectura Multi-AZ
- Subnets públicas y privadas
- Internet Gateway y NAT Gateway
- Route Tables y Security Groups
- Amazon EC2
- Launch Templates
- Auto Scaling Groups
- Application Load Balancer
- Docker y Amazon ECR
- Amazon RDS PostgreSQL
- AWS DMS para migración de datos
- AWS Systems Manager Session Manager
- AWS Secrets Manager
- Amazon S3
- Amazon CloudWatch
- Amazon SNS
- AWS IAM
- Amazon EventBridge
- Amazon SQS + Dead Letter Queue
- AWS Lambda
- Data Lake en Amazon S3
- AWS Glue Data Catalog + Crawler
- Amazon Athena
- Terraform
- GitHub Actions + OIDC

---

# ✅ Estado del proyecto

**Implementación técnica: finalizada.**  
**Documentación técnica: en desarrollo.**

| Etapa | Implementación | Documentación |
|---|:---:|:---:|
| Arquitectura y planificación | ✅ Completada | ✅ Documentada |
| Laboratorio VMware | ✅ Completada | ✅ Documentada |
| Aplicación + PostgreSQL en VMware | ✅ Completada | ✅ Documentada |
| Dockerización de la aplicación | ✅ Completada | ✅ Documentada |
| Monitoreo Prometheus / Grafana | ✅ Completada | ✅ Documentada |
| CI/CD inicial en laboratorio | ✅ Completada | ✅ Documentada |
| Fundamentos Terraform / IaC | ✅ Completada | ✅ Documentada |
| Networking AWS con Terraform | ✅ Completada | 🟡 En documentación |
| Security Groups e IAM | ✅ Completada | ⏳ Pendiente |
| EC2 + Launch Template + Auto Scaling | ✅ Completada | ⏳ Pendiente |
| Application Load Balancer | ✅ Completada | ⏳ Pendiente |
| Docker + Amazon ECR | ✅ Completada | ⏳ Pendiente |
| Amazon RDS PostgreSQL | ✅ Completada | ⏳ Pendiente |
| Migración de datos con AWS DMS / CDC | ✅ Completada | ⏳ Pendiente |
| Observabilidad con CloudWatch + SNS | ✅ Completada | ⏳ Pendiente |
| Amazon SQS + DLQ + AWS Lambda | ✅ Completada | ⏳ Pendiente |
| EventBridge y arquitectura event-driven | ✅ Completada | ⏳ Pendiente |
| Data Lake en Amazon S3 | ✅ Completada | ⏳ Pendiente |
| AWS Glue + Amazon Athena | ✅ Completada | ⏳ Pendiente |
| CI/CD GitHub Actions + OIDC + ECR | ✅ Completada | ⏳ Pendiente |
| Validación End-to-End | ✅ Completada | ⏳ Pendiente |
| Desmantelamiento del laboratorio con Terraform | ✅ Completada | ⏳ Pendiente |

> La tabla separa deliberadamente **implementación** y **documentación**: la arquitectura fue desplegada y validada completamente antes de iniciar su desmantelamiento controlado. La documentación se está completando de forma progresiva.

---

# 🔄 Estrategia de migración

La arquitectura no replica directamente las máquinas virtuales VMware en AWS.

Se aplicó una estrategia de **replatform / modernization**, sustituyendo componentes tradicionales por servicios administrados y patrones cloud-native cuando aportaban ventajas operacionales, de disponibilidad o escalabilidad.

Para PostgreSQL se implementó y probó una estrategia de migración hacia **Amazon RDS PostgreSQL** utilizando **AWS Database Migration Service (DMS)**, incluyendo pruebas de replicación mediante Change Data Capture (CDC).

La conectividad híbrida necesaria durante las pruebas de migración se implementó mediante una Site-to-Site VPN entre el laboratorio VMware y la VPC de AWS. Una vez completada la fase de migración, los componentes temporales utilizados exclusivamente para este proceso fueron retirados.

AWS Application Migration Service (MGN) fue evaluado conceptualmente como alternativa para workloads que requieran una estrategia de **rehost / lift-and-shift**, pero la arquitectura final priorizó replatformización y modernización.

---

# ⚙️ Infrastructure as Code

La infraestructura AWS fue construida y administrada utilizando **Terraform**, permitiendo que la arquitectura sea:

- Reproducible
- Versionable
- Auditable
- Automatizable
- Consistente
- Desplegable y destruible de forma controlada

El código Terraform se mantiene dentro de:

```text
terraform/
```

Terraform administra, entre otros componentes, networking, seguridad, compute, balanceo, base de datos, IAM, mensajería, serverless, Data Lake, analítica y CI/CD.

Al finalizar las pruebas, la infraestructura del laboratorio fue desmantelada mediante `terraform destroy`, manteniendo el código IaC y la documentación como definición reproducible de la arquitectura.

---

# ⚡ Arquitectura Event-Driven

La aplicación publica eventos de negocio hacia un Event Bus de Amazon EventBridge.

Para el evento `order_created`, EventBridge distribuye el mismo evento hacia diferentes consumidores:

```text
Next.js
   │
   └── order_created
          ↓
      EventBridge
       /       \
      /         \
     ▼           ▼
   SQS      Lambda Analytics
    │             │
    ▼             ▼
 Lambda       S3 Data Lake
 Processor
```

La rama operacional utiliza **Amazon SQS + DLQ + AWS Lambda** para desacoplar el procesamiento de pedidos.

La rama analítica utiliza **AWS Lambda + Amazon S3** para almacenar eventos en el Data Lake, posteriormente catalogados mediante **AWS Glue** y consultados utilizando **Amazon Athena**.

---

# 📊 Data Platform

El proyecto incorpora una pipeline analítica serverless construida sobre eventos generados por la propia aplicación:

```text
Compra
  ↓
Next.js
  ↓
EventBridge
  ↓
Lambda Analytics
  ↓
Amazon S3 Data Lake
  ↓
AWS Glue Crawler
  ↓
Glue Data Catalog
  ↓
Amazon Athena
  ↓
SQL / Analytics
```

Los eventos de pedidos son almacenados en S3 utilizando particionamiento por:

```text
year/
month/
day/
```

Glue descubre el esquema y registra la tabla `orders`, permitiendo consultar mediante SQL información generada originalmente desde el e-commerce.

---

# 🔄 DevOps y CI/CD

El proyecto evolucionó desde un pipeline inicial con un runner self-hosted en el laboratorio VMware hacia un proceso de despliegue automatizado sobre AWS.

El pipeline final utiliza:

- Git
- GitHub
- GitHub Actions
- OpenID Connect (OIDC)
- AWS STS
- IAM Roles
- Docker
- Amazon ECR
- EC2 Auto Scaling

Flujo final:

```text
git push main
      ↓
GitHub Actions
      ↓
Build / Validate
      ↓
OIDC → AWS STS
      ↓
Docker Build
      ↓
Amazon ECR
      ↓
Instance Refresh
      ↓
Auto Scaling Group
      ↓
Nueva versión desplegada
```

La autenticación desde GitHub hacia AWS utiliza credenciales temporales mediante OIDC, evitando almacenar Access Keys permanentes en GitHub.

---

# 🔭 Observabilidad

La plataforma incorpora observabilidad tanto en el entorno de origen como en AWS.

**VMware:**

- Prometheus
- Grafana

**AWS:**

- Amazon CloudWatch Logs
- Métricas de infraestructura
- Alarmas de ALB y RDS
- Logs centralizados de la aplicación
- Logs de AWS Lambda
- Amazon SNS para notificaciones de alarmas

---

# 📚 Documentación

La implementación técnica está finalizada y actualmente se está completando la documentación detallada del proyecto.

Los procedimientos, decisiones de arquitectura, configuraciones, evidencias y diagramas se mantienen separados del README principal dentro de `docs/`.

**Estado actual de documentación:** se encuentra en desarrollo la sección correspondiente al **networking AWS construido con Terraform**.

La documentación cubre progresivamente:

- Arquitectura y planificación
- Infraestructura VMware
- Terraform
- Networking AWS
- Seguridad e IAM
- Compute, Auto Scaling y Load Balancing
- Base de datos y migración
- Observabilidad
- Serverless y mensajería
- Arquitectura Event-Driven
- Data Platform
- DevOps y CI/CD
- Evidencias y validaciones
- Decisiones de arquitectura
- Diagramas
- Cierre y desmantelamiento del laboratorio

---

# 📁 Estructura del repositorio

```text
enterprise-vmware-to-aws-migration/
│
├── docs/
├── terraform/
│   └── lambda/
├── diagrams/
├── scripts/
├── .github/
│   └── workflows/
└── README.md
```

---

# 🏁 Resultado final

El proyecto implementó y validó de forma práctica una migración y modernización empresarial desde un entorno VMware hacia AWS.

La solución evolucionó desde una arquitectura tradicional basada en máquinas virtuales hacia una plataforma cloud con **Infrastructure as Code, alta disponibilidad, contenedores, base de datos administrada, observabilidad, CI/CD, mensajería asíncrona, arquitectura orientada a eventos y una plataforma analítica serverless**.

Las pruebas End-to-End validaron el recorrido desde una operación realizada en la aplicación hasta su persistencia operacional y procesamiento analítico en AWS.

Una vez finalizadas las pruebas, la infraestructura temporal del laboratorio fue desmantelada de forma controlada, conservando el código Terraform, el código de aplicación, los diagramas y la documentación como evidencia reproducible del proyecto.

---

# 👨‍💻 Autor

**Álvaro Ponce**

Ingeniero Civil en Computación

**Cloud | AWS | Infraestructura | DevOps | Data Engineering**
